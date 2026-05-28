local PromptService = game:GetService("ProximityPromptService")

local tp1 = workspace.tp1
local tp2 = workspace.tp2
local tp3 = workspace.tp3
local tp4 = workspace.tp4

local PromptTp1 = tp1.ProximityPrompt
local PromptTp2 = tp2.ProximityPrompt
local PromptTp3 = tp3.ProximityPrompt
local PromptTp4 = tp4.ProximityPrompt

local function PromptAtivado(Prompt, Player)
	if Prompt == PromptTp1 then
		Player.Character.PrimaryPart.Position = tp2.Position + Vector3.new(0, 5, 0)
	elseif Prompt == PromptTp2 then
		Player.Character.PrimaryPart.Position = tp1.Position + Vector3.new(0, 5, 0)
	elseif Prompt == PromptTp3 then
		Player.Character.PrimaryPart.Position = tp4.Position + Vector3.new(0, 5, 0)

		end
	end

PromptService.PromptTriggered:Connect(PromptAtivado)