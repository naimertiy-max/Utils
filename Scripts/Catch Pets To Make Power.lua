local player = game.Players.LocalPlayer

local TOOL_NAME = "Pet Whacker"
local SCALE = 1000 -- 👈 agora 1000x

-- =========================
-- TOOL (sem peso + gigante)
-- =========================
local function scaleTool(tool)
	for _, obj in ipairs(tool:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Size = obj.Size * SCALE
			obj.Massless = true
			obj.CanCollide = false
		elseif obj:IsA("SpecialMesh") then
			obj.Scale = obj.Scale * SCALE
		end
	end
end

local function checkTool(container)
	local tool = container:FindFirstChild(TOOL_NAME)
	if tool then
		scaleTool(tool)
	end
end

checkTool(player:WaitForChild("Backpack"))

player.CharacterAdded:Connect(function(char)
	checkTool(char)
end)

if player.Character then
	checkTool(player.Character)
end

-- =========================
-- SISTEMA DE PLOT
-- =========================
local plotsFolder = workspace:WaitForChild("Plots")

local function scaleHitbox(part)
	if part:IsA("BasePart") then
		part.Size = part.Size * SCALE
		part.Massless = true
		part.CanCollide = false
	end
end

local function processModel(model)
	for _, obj in ipairs(model:GetDescendants()) do
		if obj.Name == "Hitbox" then
			scaleHitbox(obj)
		end
	end
end

local function monitorHighlightModel(highlightModel)
	for _, model in ipairs(highlightModel:GetChildren()) do
		processModel(model)
	end

	highlightModel.ChildAdded:Connect(function(child)
		task.wait()
		processModel(child)
	end)
end

local function findMyPlot()
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		local occupied = plot:GetAttribute("Occupied")
		if occupied == player.Name then
			return plot
		end
	end
end

task.spawn(function()
	local myPlot

	repeat
		myPlot = findMyPlot()
		task.wait(1)
	until myPlot

	local highlightModel = myPlot:WaitForChild("HighlightModel")
	monitorHighlightModel(highlightModel)
end)