local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local pointFolder = workspace:WaitForChild("PointFolder")
local chestFolder = workspace:WaitForChild("ChestFolder")

local function teleportObjects(folder)
    for _, obj in ipairs(folder:GetDescendants()) do
        -- Teleporta MeshParts ou qualquer BasePart (mais completo)
        if obj:IsA("BasePart") then
            obj.CFrame = humanoidRootPart.CFrame
        end
    end
end

-- Executa uma vez
teleportObjects(pointFolder)
teleportObjects(chestFolder)