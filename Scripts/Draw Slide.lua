-- ======================================
-- CONFIG
-- ======================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local running = true

-- ======================================
-- STOP COM F5
-- ======================================
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F5 then
		running = false
		print("Script parado!")
	end
end)

-- ======================================
-- FUNÇÃO PRA PEGAR POSIÇÃO DO PLAYER
-- ======================================
local function getRoot()
	local char = player.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

-- ======================================
-- LOOP PRINCIPAL
-- ======================================
task.spawn(function()
	while running do
		local root = getRoot()
		if root then
			local stages = workspace:FindFirstChild("Stages")
			if stages then
				for _, stage in ipairs(stages:GetChildren()) do
					if stage:IsA("Model") then
						
						-- REMOVE OBSTACLES
						local obstacles = stage:FindFirstChild("Obstacles")
						if obstacles then
							obstacles:Destroy()
						end
						
						-- FUNÇÃO PRA PUXAR ITENS
						local function pullItems(folder)
							if folder then
								for _, item in ipairs(folder:GetDescendants()) do
									if item:IsA("BasePart") then
										item.CFrame = root.CFrame
										item.Velocity = Vector3.zero
										item.AssemblyLinearVelocity = Vector3.zero
									end
								end
							end
						end
						
						-- PUXA CASH E LUCKY
						pullItems(stage:FindFirstChild("Cash"))
						pullItems(stage:FindFirstChild("Lucky"))
					end
				end
			end
		end
		
		task.wait(0.1) -- loop rápido (pode diminuir se quiser mais agressivo)
	end
end)