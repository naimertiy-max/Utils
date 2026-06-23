local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local NomeDoScript = "WEIRDGUN"
local AtivosModule = nil
local AtivosEntry = nil

local function cleanup()
	destroyed = true
	active = false
	lockedTarget = nil
	if screenGui and screenGui.Parent then
		screenGui:Destroy()
	end
	if AtivosEntry and AtivosEntry.destroy then
		pcall(AtivosEntry.destroy)
	end
end

local lockedTarget = nil
local active = false
local destroyed = false

pcall(function()
	local mod = game:GetService("ReplicatedStorage"):FindFirstChild("Ativos")
	if mod and mod:IsA("ModuleScript") then
		AtivosModule = require(mod)
		AtivosEntry = AtivosModule:Registrar(NomeDoScript, cleanup)
	end
end)

local FOV_RADIUS = 120
local TARGET_UPDATE_INTERVAL = 0.1 -- 🔥 atualiza 10x por segundo
local lastTargetUpdate = 0

-- ===== UI DO ANEL =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FOVRing"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local ring = Instance.new("Frame")
ring.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
ring.Position = UDim2.new(0.5, -FOV_RADIUS, 0.5, -FOV_RADIUS)
ring.BackgroundTransparency = 1
ring.Parent = screenGui

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Parent = ring

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = ring
-- ======================

local function isAlive(model)
	local humanoid = model and model:FindFirstChild("Humanoid")
	return humanoid and humanoid.Health > 0
end

local function hasRedHighlight(model)
	return model:FindFirstChild("RedHighlight", true) ~= nil
end

-- 🔥 VISIBILIDADE OTIMIZADA
local function isVisible(targetPart)
	local origin = camera.CFrame.Position
	local direction = (targetPart.Position - origin)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {
		player.Character,
		targetPart.Parent
	}
	params.IgnoreWater = true
	params.RespectCanCollide = true -- ignora partes sem colisão

	local result = workspace:Raycast(origin, direction, params)

	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(targetPart.Parent)
end

local function evaluateModel(model, screenCenter, shortest)
	if model
		and model:IsA("Model")
		and model:FindFirstChild("Head")
		and isAlive(model)
		and hasRedHighlight(model) then
		
		local head = model.Head
		local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
		
		if onScreen then
			local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
			local distance = (screenPoint - screenCenter).Magnitude
			
			if distance <= FOV_RADIUS and isVisible(head) then
				if distance < shortest then
					return head, distance
				end
			end
		end
	end
	
	return nil, shortest
end

local function findBestTarget()
	local closest = nil
	local shortest = math.huge
	
	local screenCenter = Vector2.new(
		camera.ViewportSize.X / 2,
		camera.ViewportSize.Y / 2
	)

	-- Players
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local result
			result, shortest = evaluateModel(plr.Character, screenCenter, shortest)
			if result then
				closest = result
			end
		end
	end
	
	-- ClientBots
	local botsFolder = workspace:FindFirstChild("ClientBots")
	if botsFolder then
		for _, bot in pairs(botsFolder:GetChildren()) do
			local result
			result, shortest = evaluateModel(bot, screenCenter, shortest)
			if result then
				closest = result
			end
		end
	end
	
	return closest
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or destroyed then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		active = not active
		if not active then
			lockedTarget = nil
		end
	end
	
	if input.KeyCode == Enum.KeyCode.F5 then
		cleanup()
		if script and script.Parent then
			pcall(function() script:Destroy() end)
		end
	end
end)

-- 🔥 LOOP PRINCIPAL OTIMIZADO
RunService.RenderStepped:Connect(function(deltaTime)
	if destroyed or not active then return end

	-- Atualiza alvo apenas em intervalo
	if tick() - lastTargetUpdate >= TARGET_UPDATE_INTERVAL then
		lastTargetUpdate = tick()
		lockedTarget = findBestTarget()
	end
	
	-- Se houver alvo válido, mira nele
	if lockedTarget
		and lockedTarget.Parent
		and lockedTarget:IsDescendantOf(workspace)
		and isAlive(lockedTarget.Parent)
		and hasRedHighlight(lockedTarget.Parent)
		and isVisible(lockedTarget) then
		
		camera.CFrame = CFrame.new(
			camera.CFrame.Position,
			lockedTarget.Position
		)
	end
end)
