# Game Design Document — Labirinto do Terror

## Visão Geral

Jogo de terror single/multiplayer no Roblox. O jogador atravessa um labirinto
enfrentando monstros com três abordagens: fuga, furtividade ou combate.

## Loop de Gameplay

1. Jogador spawna na entrada do labirinto com uma arma
2. Navega pelo labirinto em busca da saída
3. Encontra monstros ao longo do caminho
4. Chega à saída → vitória / morre → tela de game over

## Monstros (planejado)

| Monstro | Comportamento | Fraqueza |
|---------|--------------|----------|
| Perseguidor | Corre atrás do jogador ao ver | Pode ser morto com tiros |
| Patrulheiro | Rota fixa, campo de visão limitado | Pode ser evitado |
| Emboscador | Fica parado, ataca ao aproximar | Difícil de matar |

## Sistemas

### Stamina
- Correr consome stamina
- Stamina regenera ao andar ou parar
- Sem stamina = velocidade reduzida

### Sanidade
- Diminui ao ficar perto de monstros
- Efeitos visuais progressivos (tremor, distorção, escuridão)
- Chega a zero = game over

### Esconderijos
- Armários, caixas, embaixo de mesas
- Monstro perde o rastro se jogador se esconder a tempo

## Dificuldades

- **Fácil** — monstros lentos, mais munição, labirinto menor
- **Médio** — padrão
- **Difícil** — monstros rápidos, pouca munição, labirinto maior
- **Impossível** — Game Pass exclusivo

## Referências

- Doors (Roblox) — sistema de susto e progressão por salas
- Flee the Facility (Roblox) — fuga e esconderijo
- Outlast — sanidade e câmera
