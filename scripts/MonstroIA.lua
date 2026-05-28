-- MonstroIA: Script de IA do monstro "Medo"
-- Comportamentos: Patrulha → Perseguição → Ataque

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local monstro = workspace:WaitForChild("Medo")
local humanoid = monstro:WaitForChild("Humanoid")
local rootPart = monstro:WaitForChild("HumanoidRootPart")

local VELOCIDADE_PATRULHA = 8
local VELOCIDADE_PERSEGUICAO = 16
local DISTANCIA_DETECTAR = 40
local DISTANCIA_ATACAR = 4
local DANO = 50
local COOLDOWN_ATAQUE = 1.5

local atacando = false

local function getJogadorMaisProximo()
	local alvo = nil
	local menorDist = DISTANCIA_DETECTAR
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
			humanoid.MoveToFinished:Wait(1)
		end
	else
		humanoid:MoveTo(posicao)
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

local pontosPatrulha = { Vector3.new(0,0,0), Vector3.new(20,0,0), Vector3.new(20,0,20), Vector3.new(0,0,20) }
local indexPatrulha = 1

while true do
	local alvo = getJogadorMaisProximo()
	if alvo then
		local dist = (rootPart.Position - alvo.HumanoidRootPart.Position).Magnitude
		if dist <= DISTANCIA_ATACAR then atacar(alvo)
		else moverPara(alvo.HumanoidRootPart.Position, VELOCIDADE_PERSEGUICAO) end
	else
		moverPara(pontosPatrulha[indexPatrulha], VELOCIDADE_PATRULHA)
		indexPatrulha = (indexPatrulha % #pontosPatrulha) + 1
		task.wait(1)
	end
	task.wait(0.1)
end
