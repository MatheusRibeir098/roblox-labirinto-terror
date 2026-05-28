# Steering: Como funciona este repositório

## Visão Geral

Este repositório contém os scripts Lua do jogo **Maze of Fear** (Labirinto do Medo) no Roblox.
O cenário, modelos e propriedades ficam no Studio/nuvem do Roblox.
O código-fonte dos scripts fica aqui no Git.

---

## Estrutura

```
roblox-labirinto-terror/
├── scripts/          → Scripts Lua do jogo (fonte da verdade)
│   ├── MonstroIA.lua     → IA do monstro "Medo"
│   └── TeleScript.lua    → Sistema de teleporte
├── docs/             → Documentação e referências
│   ├── game-design.md
│   ├── roblox-scripting-reference.md
│   └── open-cloud-api-reference.md
├── deploy.py         → Script de deploy para o Roblox
├── jogo.rbxl         → Backup do arquivo do projeto
└── README.md
```

---

## Fluxo de trabalho

### Kiro escreve/edita um script

```
1. Kiro edita scripts/MeuScript.lua
2. Kiro roda: python3 deploy.py
3. Script vai direto para o jogo no Roblox via API
4. Kiro faz git add + git commit + git push
```

### Você edita algo no Studio

```
1. Você edita no Studio e salva (Ctrl+Alt+S)
2. Kiro roda: python3 deploy.py --pull
3. Scripts são baixados para a pasta scripts/
4. Kiro faz git commit + git push
```

---

## Como fazer push para o GitHub

```bash
# Ver o que mudou
git status
git diff

# Adicionar arquivos modificados
git add scripts/MeuScript.lua
# ou adicionar tudo:
git add .

# Criar commit (mensagem em português)
git commit -m "feat: descrição do que foi feito"

# Enviar para o GitHub
git push
```

### Prefixos de commit
| Prefixo | Quando usar |
|---------|-------------|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `docs:` | Documentação |
| `chore:` | Manutenção, limpeza |
| `refactor:` | Refatoração sem mudar comportamento |

---

## Como adicionar um novo script ao fluxo

1. No Studio: botão direito no serviço desejado → Insert Object → Script
2. Dê um nome ao script
3. Salve: **Ctrl+Alt+S**
4. Descubra o ID: `python3 deploy.py --list`
5. Adicione em `deploy.py`:
```python
SCRIPTS = {
    "scripts/NovoScript.lua": "ID-AQUI",
}
```
6. Crie o arquivo: `scripts/NovoScript.lua`
7. Rode `python3 deploy.py` para enviar

---

## Requisitos para o deploy funcionar

- Python 3 instalado
- Biblioteca `requests`: `pip3 install requests`
- Chave API em `~/.roblox-api-key`
- Studio fechado OU sem scripts abertos (Live Scripting desativado)
- Jogo publicado no Roblox (Universe ID: `10232472687`)

---

## Conta GitHub

- **Usuário:** MatheusRibeir098
- **Repositório:** https://github.com/MatheusRibeir098/roblox-labirinto-terror
- **Branch principal:** `main`
