import csv

def normalize(text):
    replacements = {
        ' ': '_', ':': '', ',': '', '/': '_', '(': '', ')': '',
        'a': 'a', 'a': 'a', 'a': 'a', 'a': 'a',
        'e': 'e', 'e': 'e', 'i': 'i', 'o': 'o', 'o': 'o', 'u': 'u',
        'c': 'c', '-': '_', "'": '', '%': '', '.': ''
    }
    text = text.lower().strip()
    for old, new in replacements.items():
        text = text.replace(old, new)
    while '__' in text:
        text = text.replace('__', '_')
    return text.strip('_')

INPUT_FILE = 'players_stats.csv'
OUTPUT_FILE = 'chase_vct.pl'

predicados = []

with open(INPUT_FILE, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        if row['Player'].lower() != 'chase':
            continue
        if 'Brazil' not in row['Tournament']:
            continue
        if ',' in row['Agents']:
            continue
        if row['Stage'] == 'All Stages' or row['Match Type'] == 'All Match Types':
            continue

        jogador = normalize(row['Player'])
        time    = normalize(row['Teams'])
        agente  = normalize(row['Agents'])
        torneio = normalize(row['Tournament'])
        fase    = normalize(row['Match Type'])
        kills   = int(row['Kills'])
        deaths  = int(row['Deaths'])
        assists = int(row['Assists'])
        acs     = int(float(row['Average Combat Score']))

        predicado = (
            f"partida({jogador}, {time}, {agente}, {torneio}, "
            f"{fase}, {kills}, {deaths}, {assists}, {acs})."
        )
        predicados.append(predicado)

REGRAS = """

% PREDICADOS AUXILIARES GERAIS

media_lista(Lista, Media) :-
    length(Lista, N),
    N > 0,
    sumlist(Lista, Soma),
    Media is Soma / N.

agente_do_jogador(Jogador, Agente) :-
    findall(A, partida(Jogador, _, A, _, _, _, _, _, _), Todos),
    list_to_set(Todos, Set),
    member(Agente, Set).

torneio_do_jogador(Jogador, Torneio) :-
    findall(T, partida(Jogador, _, _, T, _, _, _, _, _), Todos),
    list_to_set(Todos, Set),
    member(Torneio, Set).

fase_do_jogador(Jogador, Fase) :-
    findall(F, partida(Jogador, _, _, _, F, _, _, _, _), Todos),
    list_to_set(Todos, Set),
    member(Fase, Set).

% Ao colar as perguntas no swish, remova o ?-, pois ele ja possui por padrão ao inserir na query

% PERGUNTA 1 - Qual agente teve o maior ACS medio?
% ?- ranking_agentes_acs(chase, Ranking). 

media_acs_agente(Jogador, Agente, Media) :-
    agente_do_jogador(Jogador, Agente),
    findall(ACS, partida(Jogador, _, Agente, _, _, _, _, _, ACS), Lista),
    media_lista(Lista, Media).

ranking_agentes_acs(Jogador, Ranking) :-
    findall(Media-Agente, media_acs_agente(Jogador, Agente, Media), Lista),
    sort(0, @>=, Lista, Ranking).


% PERGUNTA 2 - Em qual torneio o jogador teve o melhor KDA total?
% ?- ranking_torneios_kda(chase, Ranking).

kda_torneio(Jogador, Torneio, KDA) :-
    torneio_do_jogador(Jogador, Torneio),
    findall(K, partida(Jogador, _, _, Torneio, _, K, _, _, _), Ks),
    findall(D, partida(Jogador, _, _, Torneio, _, _, D, _, _), Ds),
    findall(A, partida(Jogador, _, _, Torneio, _, _, _, A, _), As),
    sumlist(Ks, TotalK),
    sumlist(Ds, TotalD),
    sumlist(As, TotalA),
    TotalD > 0,
    KDA is (TotalK + TotalA) / TotalD.

ranking_torneios_kda(Jogador, Ranking) :-
    findall(KDA-Torneio, kda_torneio(Jogador, Torneio, KDA), Lista),
    sort(0, @>=, Lista, Ranking).


% PERGUNTA 3 - Em quais partidas o jogador performou acima da sua propria media de ACS?
% ?- acima_da_media(chase, Torneio, Fase, Agente, ACS, Media).

media_geral_acs(Jogador, Media) :-
    findall(ACS, partida(Jogador, _, _, _, _, _, _, _, ACS), Lista),
    media_lista(Lista, Media).

acima_da_media(Jogador, Torneio, Fase, Agente, ACS, Media) :-
    media_geral_acs(Jogador, Media),
    partida(Jogador, _, Agente, Torneio, Fase, _, _, _, ACS),
    ACS > Media.


% PERGUNTA 4 - O jogador melhorou seus kills da terrornet para a stars_horizon?
% ?- evolucao_kills(chase, terrornet, stars_horizon, MediaAntiga, MediaNova, Resultado)

media_kills_time(Jogador, Time, Media) :-
    findall(K, partida(Jogador, Time, _, _, _, K, _, _, _), Lista),
    Lista \= [],
    media_lista(Lista, Media).

evolucao_kills(Jogador, TimeAntigo, TimeNovo, MediaAntiga, MediaNova, Resultado) :-
    media_kills_time(Jogador, TimeAntigo, MediaAntiga),
    media_kills_time(Jogador, TimeNovo, MediaNova),
    (   MediaNova > MediaAntiga -> Resultado = melhorou
    ;   MediaNova < MediaAntiga -> Resultado = piorou
    ;   Resultado = igual
    ).


% PERGUNTA 5 - Qual foi a fase mais dificil (menor KDA medio)?
% ?- fases_mais_dificeis(chase, Ranking).

kda_fase(Jogador, Fase, KDA) :-
    fase_do_jogador(Jogador, Fase),
    findall(K, partida(Jogador, _, _, _, Fase, K, _, _, _), Ks),
    findall(D, partida(Jogador, _, _, _, Fase, _, D, _, _), Ds),
    findall(A, partida(Jogador, _, _, _, Fase, _, _, A, _), As),
    sumlist(Ks, TotalK),
    sumlist(Ds, TotalD),
    sumlist(As, TotalA),
    TotalD > 0,
    KDA is (TotalK + TotalA) / TotalD.

fases_mais_dificeis(Jogador, Ranking) :-
    findall(KDA-Fase, kda_fase(Jogador, Fase, KDA), Lista),
    sort(0, @=<, Lista, Ranking).
"""

with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
    f.write("% Base de conhecimento - Chase @ VCT Brazil 2021\n")
    f.write("% partida(jogador, time, agente, torneio, fase, kills, deaths, assists, acs).\n\n")
    for p in predicados:
        f.write(p + '\n')
    f.write(REGRAS)

print(f"{len(predicados)} predicados gerados em '{OUTPUT_FILE}'.")