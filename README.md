# Knowledge Engine - Valorant VCT Brazil 2021

Projeto da disciplina Lógica e Matemática Discreta - Insper.

## Dataset

O dataset contém estatísticas de jogadores de todos os torneios profissionais oficiais de Valorant de 2021.

Esses dados são do meu primeiro campeonato profissional de Valorant. Meu nick era Chase e achei interessante usar como dataset para o projeto analisando alguns dados que eu nunca parei pra analisar. O filtro aplicado mantém apenas partidas de mim (chase) em torneios brasileiros (há outro chase que competiu na região NA, excluído intencionalmente). Registros com múltiplos agentes por mapa e linhas de agregação foram removidos.

Campos selecionados (5 qualitativos, 4 quantitativos): jogador, time, agente, torneio, fase, kills, deaths, assists, acs.

## Como rodar

O arquivo players_stats.csv deve estar na raiz do projeto (download pelo link acima).

```
python etl.py
```

Isso gera o arquivo chase_vct.pl com os fatos. O arquivo já presente no repositório contém os fatos e todas as regras prontas para uso.

## Rodando as queries

1. Acesse https://swish.swi-prolog.org/
2. Crie um novo notebook
3. Cole o conteúdo de chase_vct.pl na área Program
4. Execute as queries abaixo na área Query
5. No Swish, pode ser que nao seja necessário usar o ?- antes dar perguntas pelo fato do site ja ter por padrão

## Perguntas

Pergunta 1 — Qual agente teve o maior ACS médio?

```prolog
?- ranking_agentes_acs(chase, Ranking).
```

Agrega o ACS de todas as partidas por agente, calcula a média de cada um e retorna ordenado do maior para o menor.

Pergunta 2 — Em qual torneio o chase teve o melhor KDA total?

```prolog
?- ranking_torneios_kda(chase, Ranking).
```

Agrupa kills, deaths e assists por torneio, calcula KDA = (K+A)/D para cada um e retorna ordenado do melhor para o pior.

Pergunta 3 — Em quais partidas o chase performou acima da sua própria média geral de ACS?

```prolog
?- acima_da_media(chase, Torneio, Fase, Agente, ACS, Media).
```

Calcula a média geral de ACS do jogador e filtra apenas as partidas onde o ACS superou essa média.

Pergunta 4 — O chase melhorou seus kills ao trocar da terror net para a stars horizon?

```prolog
?- evolucao_kills(chase, terrornet, stars_horizon, MediaAntiga, MediaNova, Resultado).
```

Calcula a média de kills em cada time e compara, retornando melhorou, piorou ou igual.

Pergunta 5 — Qual foi a fase mais difícil para o chase(menor kda medio)?

```prolog
?- fases_mais_dificeis(chase, Ranking).
```

Calcula o KDA médio por fase e ordena de forma crescente, a fase com menor KDA é considerada a mais difícil.

Respostas esperadas:

Qual agente teve o maior ACS médio?
R- [239-reyna, 218.33333333333334-raze, 200.57142857142858-kayo, 182-skye]

Em qual torneio o chase teve o melhor KDA total?
R- [1.7272727272727273-champions_tour_brazil_stage_3_challengers_2, 1.575-champions_tour_brazil_stage_3_challengers_playoffs, 1.2777777777777777-champions_tour_brazil_stage_3_challengers_1]

Em quais partidas o jogador performou acima da sua propria media de ACS?
R- ACS = 273,
Agente = raze,
Fase = upper_semifinals,
Media = 209,
Torneio = champions_tour_brazil_stage_3_challengers_playoffs
ACS = 249,
Agente = kayo,
Fase = round_of_16,
Media = 209,
Torneio = champions_tour_brazil_stage_3_challengers_2
ACS = 237,
Agente = raze,
Fase = opening_a,
Media = 209,
Torneio = champions_tour_brazil_stage_3_challengers_1
ACS = 229,
Agente = raze,
Fase = round_of_32,
Media = 209,
Torneio = champions_tour_brazil_stage_3_challengers_1
ACS = 239,
Agente = reyna,
Fase = round_of_32,
Media = 209,
Torneio = champions_tour_brazil_stage_3_challengers_1

O jogador melhorou seus kills da terrornet para a stars_horizon?
R- MediaAntiga = 18,
MediaNova = 21.916666666666668,
Resultado = melhorou

Qual foi a fase mais dificil(menor KDA medio)?
R- [0.8571428571428571-elimination_a, 1.3225806451612903-opening_a, 1.3421052631578947-lower_round_2, 1.5-upper_semifinals, 1.6304347826086956-round_of_16, 1.6551724137931034-quarterfinals, 1.7307692307692308-winners_a, 1.8409090909090908-upper_quarterfinals, 1.8888888888888888-round_of_32]