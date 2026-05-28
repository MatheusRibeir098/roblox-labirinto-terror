# Steering: Fix-Loop / Forge-Loop — Maze of Fear

## Contexto do Projeto

**Jogo:** Maze of Fear (Labirinto do Medo) — Roblox  
**Gênero:** Terror, labirinto, sobrevivência  
**Universe ID:** `10232472687`  
**Place ID:** `77285087788790`  

O jogador começa com uma arma e deve atravessar um labirinto infestado de monstros.
Pode fugir, se esconder ou tentar matar os monstros.

---

## O que já existe e funciona

| Sistema | Status | Arquivo |
|---------|--------|---------|
| Cenário (labirinto, castelo, tochas) | ✅ Pronto | Studio |
| Arma (Pistola) | ✅ Funciona | Studio/Workspace |
| Teleportes (tp1-tp4) | ✅ Funciona | `scripts/TeleScript.lua` |
| NPC Medo (modelo) | ✅ Existe | Studio/Workspace |
| IA do Medo | ⚠️ Escrita, não testada | `scripts/MonstroIA.lua` |

---

## O que NÃO funciona / precisa ser feito

- [ ] IA do Medo não se move (possível causa: partes Anchored=true)
- [ ] Sistema de saúde do jogador (HUD)
- [ ] Sistema de stamina (correr esgota energia)
- [ ] Esconderijos funcionais
- [ ] Tela inicial (existe GUI mas não funciona)
- [ ] Sistema de diálogo (DialogoGui existe mas está incompleto)
- [ ] Game Over / Vitória

---

## Como fazer deploy de scripts

```bash
# Enviar scripts para o Roblox
cd ~/forge/projects/roblox-labirinto-terror
python3 deploy.py

# Baixar scripts do Roblox
python3 deploy.py --pull

# Ver IDs dos scripts
python3 deploy.py --list
```

---

## Regras obrigatórias ao escrever scripts

### 1. Scripts de NPC SEMPRE no servidor
```lua
-- ✅ Correto: Script (não LocalScript) no ServerScriptService
-- O MonstroIA.lua é um Script no ServerScriptService
```

### 2. Sempre desancorar partes do NPC
```lua
-- Adicionar no início de qualquer script de NPC
for _, part in ipairs(script.Parent:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Anchored = false
    end
end
```

### 3. Sempre usar WaitForChild
```lua
-- ✅ Correto
local humanoid = npc:WaitForChild("Humanoid")
-- ❌ Errado (pode ser nil)
local humanoid = npc.Humanoid
```

### 4. Pathfinding com timeout
```lua
-- Sempre definir timeout no MoveToFinished:Wait()
humanoid.MoveToFinished:Wait(2) -- máximo 2 segundos por waypoint
```

### 5. Nunca confiar no cliente
```lua
-- Toda lógica de dano, morte, pontuação = servidor
-- Cliente só faz: input, UI, efeitos visuais
```

---

## Estrutura de NPCs no Roblox

Um NPC funcional precisa de:
- `HumanoidRootPart` — parte raiz, **não pode estar Anchored**
- `Humanoid` — controla movimento e saúde
- Partes do corpo conectadas por `Motor6D` (não Weld)
- Nenhuma parte com `Anchored = true`

**NPC "Medo":**
- Modelo R15 com armadura cinza/azul
- Está no Workspace
- ID: `4e2895fd-5c8c-9910-033e-bcbe0002fa53`

---

## Diagnóstico: NPC não se move

Se o NPC não se mover após deploy do script:

1. **Verificar Anchored:** No Studio, selecionar todas as partes do Medo → Properties → `Anchored` deve ser `false`
2. **Verificar script:** O `MonstroIA` deve ser um `Script` (ícone azul), não `LocalScript`
3. **Verificar erros:** No Studio → Output → ver se há erros em vermelho
4. **Verificar nome:** O script busca `workspace:WaitForChild("Medo")` — o NPC deve se chamar exatamente "Medo"

---

## Referências

- Scripting Roblox: `docs/roblox-scripting-reference.md`
- Open Cloud API: `docs/open-cloud-api-reference.md`
- Repositório: `docs/steering-repositorio.md`
- Game Design: `docs/game-design.md`
