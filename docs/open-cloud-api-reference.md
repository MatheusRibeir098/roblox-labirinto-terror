# Referência: Roblox Open Cloud API

## Visão Geral

A Open Cloud API permite interagir com jogos Roblox externamente via HTTP.
Usamos ela para **ler e atualizar scripts** do jogo sem abrir o Studio.

**Base URL:** `https://apis.roblox.com/cloud/v2`

---

## Autenticação

Toda requisição precisa do header:
```
x-api-key: SUA_CHAVE_API
```

A chave fica em: `~/.roblox-api-key`

### Como criar uma API Key
1. Acesse: https://create.roblox.com/dashboard/credentials?activeTab=ApiKeysTab
2. Clique **Create API Key**
3. Em **API System** selecione `universe-place-instances`
4. Selecione o jogo e marque **Read + Write**
5. IP: `0.0.0.0/0`
6. Salve e copie a chave

---

## IDs do Projeto

| Campo | Valor |
|-------|-------|
| Universe ID | `10232472687` |
| Place ID | `77285087788790` |
| ServerScriptService ID | `44b188da-ce63-2b47-02e9-c68d0048309e` |
| StarterGui ID | `44b188da-ce63-2b47-02e9-c68d00483077` |
| ReplicatedStorage ID | `44b188da-ce63-2b47-02e9-c68d004830a0` |

### Scripts conhecidos
| Script | ID |
|--------|----|
| MonstroIA | `01f61402-1bc3-1137-0a29-324800000a82` |
| TeleScript | `65797ea6-ae74-2671-033a-5204000c66b0` |

---

## Operações disponíveis

### ⚠️ Limitações importantes
- **Só funciona com Team Create ativo** no Studio
- Opera **assincronamente** — toda operação retorna um `path` de operação que precisa ser consultado
- Só suporta: `Script`, `LocalScript`, `ModuleScript`, `Folder`
- **NÃO cria instâncias** — só lê e atualiza existentes
- Não pode atualizar scripts abertos no Studio (Live Scripting ativo)

---

## Listar filhos de uma instância

```bash
# Passo 1: iniciar operação
curl -X GET \
  "https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/instances/{instanceId}:listChildren" \
  -H "x-api-key: $API_KEY"
# Retorna: { "path": "universes/.../operations/UUID", "done": false }

# Passo 2: aguardar e buscar resultado (aguardar ~2-3s)
curl -X GET \
  "https://apis.roblox.com/cloud/v2/{path_retornado}" \
  -H "x-api-key: $API_KEY"
```

---

## Atualizar source de um script (PATCH)

```bash
curl -X PATCH \
  "https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/instances/{instanceId}" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "engineInstance": {
      "Id": "{instanceId}",
      "Details": {
        "Script": {
          "Source": "print(\"Hello World\")"
        }
      }
    }
  }'
# Retorna: { "path": "...", "done": false }
# Consultar o path para confirmar sucesso
```

---

## Erros comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `Invalid API Key` | Chave errada ou expirada | Gerar nova chave |
| `Live scripting session is active` | Script aberto no Studio | Fechar todas as abas de script |
| `WAF Blocked Request` | Tentativa de criar instância | Não é possível criar via API |
| `done: false` sem resultado | Operação ainda processando | Aguardar mais e consultar novamente |

---

## Script de deploy (deploy.py)

O repositório tem um script Python que automatiza o deploy:

```bash
# Enviar todos os scripts para o Roblox
python3 deploy.py

# Baixar scripts do Roblox para arquivos locais
python3 deploy.py --pull

# Listar scripts com seus IDs
python3 deploy.py --list
```

### Adicionar novo script ao deploy
1. Criar o script vazio no Studio
2. Salvar com Ctrl+Alt+S
3. Rodar `python3 deploy.py --list` para ver o ID
4. Adicionar em `deploy.py` no dicionário `SCRIPTS`:
```python
SCRIPTS = {
    "scripts/MeuScript.lua": "ID-DO-SCRIPT-AQUI",
}
```
