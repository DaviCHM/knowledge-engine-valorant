% Base de conhecimento - Chase @ VCT Brazil 2021
% partida(jogador, time, agente, torneio, fase, kills, deaths, assists, acs).

partida(chase, stars_horizon, kayo, champions_tour_brazil_stage_3_challengers_playoffs, upper_quarterfinals, 49, 44, 32, 205).
partida(chase, stars_horizon, raze, champions_tour_brazil_stage_3_challengers_playoffs, upper_semifinals, 31, 24, 8, 273).
partida(chase, stars_horizon, kayo, champions_tour_brazil_stage_3_challengers_playoffs, upper_semifinals, 12, 14, 6, 192).
partida(chase, stars_horizon, kayo, champions_tour_brazil_stage_3_challengers_playoffs, lower_round_2, 21, 20, 13, 189).
partida(chase, stars_horizon, raze, champions_tour_brazil_stage_3_challengers_playoffs, lower_round_2, 14, 18, 3, 207).
partida(chase, stars_horizon, kayo, champions_tour_brazil_stage_3_challengers_2, opening_a, 14, 14, 5, 196).
partida(chase, stars_horizon, kayo, champions_tour_brazil_stage_3_challengers_2, winners_a, 24, 26, 21, 165).
partida(chase, stars_horizon, kayo, champions_tour_brazil_stage_3_challengers_2, round_of_16, 18, 9, 10, 249).
partida(chase, stars_horizon, skye, champions_tour_brazil_stage_3_challengers_2, round_of_16, 11, 10, 1, 182).
partida(chase, stars_horizon, kayo, champions_tour_brazil_stage_3_challengers_2, quarterfinals, 32, 29, 16, 208).
partida(chase, stars_horizon, raze, champions_tour_brazil_stage_3_challengers_1, opening_a, 17, 17, 5, 237).
partida(chase, stars_horizon, raze, champions_tour_brazil_stage_3_challengers_1, elimination_a, 20, 28, 4, 166).
partida(chase, terrornet, raze, champions_tour_brazil_stage_3_challengers_1, round_of_32, 15, 10, 7, 229).
partida(chase, terrornet, reyna, champions_tour_brazil_stage_3_challengers_1, round_of_32, 11, 8, 1, 239).
partida(chase, terrornet, raze, champions_tour_brazil_stage_3_challengers_1, round_of_16, 28, 27, 7, 198).


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
