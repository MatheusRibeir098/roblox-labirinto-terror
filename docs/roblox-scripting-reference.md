# Referência: Scripting Roblox / Luau

## Arquitetura Cliente-Servidor

O Roblox usa um modelo cliente-servidor obrigatório:

| Tipo | Onde roda | Uso |
|------|-----------|-----|
| `Script` | Servidor | Lógica do jogo, NPCs, dano, dados |
| `LocalScript` | Cliente | Input do jogador, UI, efeitos visuais |
| `ModuleScript` | Ambos | Código compartilhado, bibliotecas |

**Regra de ouro:** O servidor tem autoridade. Nunca confie no cliente.

---

## Comunicação Cliente ↔ Servidor

```lua
-- Criar RemoteEvent em ReplicatedStorage
-- SERVER: receber evento do cliente
local evento = game.ReplicatedStorage.MeuEvento
evento.OnServerEvent:Connect(function(player, dados)
    -- validar dados aqui
end)

-- CLIENT: enviar evento para o servidor
local evento = game.ReplicatedStorage.MeuEvento
evento:FireServer(dados)

-- SERVER: enviar para cliente específico
evento:FireClient(player, dados)

-- SERVER: enviar para todos os clientes
evento:FireAllClients(dados)
```

---

## Humanoid e NPCs

```lua
local npc = workspace.MeuNPC
local humanoid = npc:WaitForChild("Humanoid")
local rootPart = npc:WaitForChild("HumanoidRootPart")

-- Mover NPC
humanoid:MoveTo(Vector3.new(10, 0, 10))
humanoid.MoveToFinished:Wait()

-- Velocidade
humanoid.WalkSpeed = 16

-- Dano
humanoid:TakeDamage(50)

-- Morte
humanoid.Died:Connect(function()
    print("NPC morreu")
end)
```

### Por que o NPC não se move?

Causas mais comuns (em ordem de frequência):

1. **Partes Anchored=true** — seleciona todas as partes do NPC no Studio e verifica se `Anchored` está desmarcado
2. **Motor6D quebrado** — as juntas entre as partes do corpo estão corrompidas
3. **Script no cliente** — script de NPC deve ser `Script` (servidor), nunca `LocalScript`
4. **HipHeight errado** — o Humanoid não consegue calcular a altura correta do corpo
5. **Colisão entre partes** — partes do próprio NPC colidindo entre si

**Fix rápido para Anchored:**
```lua
-- Colocar no início do script do NPC
for _, part in ipairs(script.Parent:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Anchored = false
    end
end
```

---

## PathfindingService

```lua
local PathfindingService = game:GetService("PathfindingService")

local function moverPara(humanoid, rootPart, destino)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = false,
    })

    local ok, err = pcall(function()
        path:ComputeAsync(rootPart.Position, destino)
    end)

    if not ok or path.Status ~= Enum.PathStatus.Success then
        -- Fallback: mover direto
        humanoid:MoveTo(destino)
        return
    end

    for _, waypoint in ipairs(path:GetWaypoints()) do
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid:MoveTo(waypoint.Position)
        humanoid.MoveToFinished:Wait(2) -- timeout de 2s por waypoint
    end
end
```

---

## Players e Characters

```lua
local Players = game:GetService("Players")

-- Jogador entrou
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")
    end)
end)

-- Pegar todos os jogadores
for _, player in ipairs(Players:GetPlayers()) do
    local char = player.Character
    if char then
        -- fazer algo
    end
end

-- Pegar jogador de um character
local player = Players:GetPlayerFromCharacter(character)
```

---

## DataStore (salvar dados)

```lua
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("DadosJogador")

-- Salvar
local ok, err = pcall(function()
    store:SetAsync("Player_" .. player.UserId, dados)
end)

-- Carregar
local ok, dados = pcall(function()
    return store:GetAsync("Player_" .. player.UserId)
end)
```

---

## Padrões importantes

### Debounce (evitar spam)
```lua
local debounce = false
part.Touched:Connect(function(hit)
    if debounce then return end
    debounce = true
    -- lógica aqui
    task.wait(1)
    debounce = false
end)
```

### WaitForChild (evitar erros de timing)
```lua
-- Sempre usar WaitForChild ao acessar filhos
local humanoid = character:WaitForChild("Humanoid")
-- Nunca: character.Humanoid (pode ser nil)
```

### task.wait vs wait
```lua
task.wait(1)  -- ✅ moderno, use sempre
wait(1)       -- ❌ deprecated
```

---

## Services úteis

| Service | Uso |
|---------|-----|
| `game:GetService("Players")` | Gerenciar jogadores |
| `game:GetService("PathfindingService")` | Navegação de NPCs |
| `game:GetService("TweenService")` | Animações suaves |
| `game:GetService("RunService")` | Loop de jogo (Heartbeat) |
| `game:GetService("CollectionService")` | Tags em objetos |
| `game:GetService("DataStoreService")` | Persistência de dados |
| `game:GetService("ReplicatedStorage")` | Objetos compartilhados |
| `game:GetService("ServerScriptService")` | Scripts do servidor |
