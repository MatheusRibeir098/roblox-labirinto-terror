# Descobertas do OpenAPI Spec (openapi.json)

Arquivo completo em: `docs/openapi.json` (3.3MB)

## Endpoints mais importantes para o projeto

### 1. Engine Instance API
```
GET/PATCH /cloud/v2/universes/{id}/places/{id}/instances/{id}
GET       /cloud/v2/universes/{id}/places/{id}/instances/{id}:listChildren
```
- Lê e atualiza Source de Script/LocalScript/ModuleScript
- Requer Team Create ativo
- Opera assincronamente (retorna operation path)
- Máximo 200.000 bytes por script
- NÃO cria instâncias

### 2. Luau Execution API ⭐ (PODEROSO)
```
POST /cloud/v2/universes/{id}/places/{id}/luau-execution-session-tasks
```
Executa código Lua no contexto do jogo. Pode:
- Ler propriedades de qualquer instância (Position, Anchored, etc.)
- Acessar DataStores
- Retornar valores via `return`
- Ver logs via `print`

**Limitações:**
- Physics não roda
- Scripts do jogo não rodam automaticamente
- Mudanças no DataModel NÃO persistem
- 5 calls/min por API key, 45/min por IP
- Máximo 10 tasks incompletas por place

**Exemplo de uso:**
```bash
curl -X POST \
  "https://apis.roblox.com/cloud/v2/universes/10232472687/places/77285087788790/luau-execution-session-tasks" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "script": "local medo = workspace:FindFirstChild(\"Medo\") if medo then local root = medo:FindFirstChild(\"HumanoidRootPart\") if root then return {anchored=root.Anchored, pos={root.Position.X, root.Position.Y, root.Position.Z}} end end",
    "timeout": "10s"
  }'
```

### 3. Team Create API
```
GET/PATCH /legacy-develop/v1/universes/{id}/teamcreate
```
- Ativa/desativa Team Create
- Requer permissão de owner (nossa chave retornou Forbidden)

### 4. Universe/Place API
```
GET/PATCH /cloud/v2/universes/{id}
GET/PATCH /cloud/v2/universes/{id}/places/{id}
POST      /universes/v1/{universeId}/places/{placeId}/versions  ← publicar nova versão!
```

### 5. DataStore API
```
GET/POST/PATCH/DELETE /cloud/v2/universes/{id}/data-stores/{id}/entries/{id}
```
- CRUD completo de DataStores via API
- Útil para gerenciar dados de jogadores externamente

### 6. Messaging API
```
POST /cloud/v2/universes/{id}:publishMessage
```
- Envia mensagem para servidores ativos do jogo
- Útil para comunicação em tempo real

### 7. Restart Servers
```
POST /cloud/v2/universes/{id}:restartServers
```
- Reinicia todos os servidores do jogo

## Escopos de API Key necessários

| Funcionalidade | Escopo |
|----------------|--------|
| Ler/atualizar scripts | `universe-place-instances` |
| Executar Lua | `universe-place-instances` (mesmo escopo) |
| DataStores | `universe-datastores` |
| Publicar mensagens | `universe-messaging-service:publish` |
| Reiniciar servidores | `universe-restart-servers` |
| Publicar versão | `universe-places:write` |
