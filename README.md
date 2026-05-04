# Knowledge Engine - Valorant VCT Brasil 2021

Projeto da disciplina Lógica e Matemática Discreta (2026/1) — Insper.

## Dataset

O dataset contém estatísticas de jogadores de todos os torneios profissionais de Valorant de 2021.

Fonte: https://www.kaggle.com/datasets/visualize25/valorant-pro-matches-full-data

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

Pergunta 4 — O chase melhorou seus kills ao trocar de time?

```prolog
?- evolucao_kills(chase, terrornet, stars_horizon, MediaAntiga, MediaNova, Resultado).
```

Calcula a média de kills em cada time e compara, retornando melhorou, piorou ou igual.

Pergunta 5 — Qual foi a fase mais difícil para o chase?

```prolog
?- fases_mais_dificeis(chase, Ranking).
```

Calcula o KDA médio por fase e ordena de forma crescente, a fase com menor KDA é considerada a mais difícil.
