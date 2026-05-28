-- MonstroIA: Script de IA do monstro "Medo"
-- Comportamentos: Patrulha aleatória → Perseguição → Ataque

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local monstro = workspace:WaitForChild("Medo")

-- Garantir que nenhuma parte está ancorada (fix para modelos importados)
for _, part in ipairs(monstro:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Anchored = false
    end
end
local humanoid = monstro:WaitForChild("Humanoid")
local rootPart = monstro:WaitForChild("HumanoidRootPart")

local VELOCIDADE_PATRULHA = 8
local VELOCIDADE_PERSEGUICAO = 18
local DISTANCIA_DETECTAR = 45
local DISTANCIA_ATACAR = 4
local DANO = 50
local COOLDOWN_ATAQUE = 1.5
local RAIO_PATRULHA = 30  -- vaga até 30 studs da posição atual

local atacando = false
local posicaoInicial = rootPart.Position  -- memoriza onde o Medo começa

local function getJogadorMaisProximo()
	local alvo, menorDist = nil, DISTANCIA_DETECTAR
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
			if char.Humanoid.Health > 0 then
				local dist = (rootPart.Position - char.HumanoidRootPart.Position).Magnitude
				if dist < menorDist then
					menorDist = dist
					alvo = char
				end
			end
		end
	end
	return alvo
end

local function moverPara(posicao, velocidade)
	humanoid.WalkSpeed = velocidade
	local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
	local ok = pcall(function() path:ComputeAsync(rootPart.Position, posicao) end)
	if ok and path.Status == Enum.PathStatus.Success then
		for _, waypoint in ipairs(path:GetWaypoints()) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
			humanoid:MoveTo(waypoint.Position)
			local chegou = humanoid.MoveToFinished:Wait(2)
			if not chegou then break end
		end
	else
		-- Fallback: mover direto sem pathfinding
		humanoid:MoveTo(posicao)
		humanoid.MoveToFinished:Wait(3)
	end
end

local function atacar(char)
	if atacando then return end
	atacando = true
	local h = char:FindFirstChild("Humanoid")
	if h and h.Health > 0 then h:TakeDamage(DANO) end
	task.wait(COOLDOWN_ATAQUE)
	atacando = false
end

local function pontoAleatorio()
	-- Gera um ponto aleatório ao redor da posição inicial do Medo
	local angulo = math.random() * math.pi * 2
	local raio = math.random(10, RAIO_PATRULHA)
	return posicaoInicial + Vector3.new(
		math.cos(angulo) * raio,
		0,
		math.sin(angulo) * raio
	)
end

-- Loop principal
while true do
	local alvo = getJogadorMaisProximo()

	if alvo then
		local dist = (rootPart.Position - alvo.HumanoidRootPart.Position).Magnitude
		if dist <= DISTANCIA_ATACAR then
			atacar(alvo)
		else
			moverPara(alvo.HumanoidRootPart.Position, VELOCIDADE_PERSEGUICAO)
		end
	else
		-- Patrulha aleatória
		moverPara(pontoAleatorio(), VELOCIDADE_PATRULHA)
		task.wait(math.random(1, 3))
	end

	task.wait(0.1)
end
