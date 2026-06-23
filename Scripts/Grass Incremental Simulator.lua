local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local union = workspace:WaitForChild("World")
    :WaitForChild("Props")
    :WaitForChild("Field")
    :WaitForChild("Union")

local size = union.Size
local cf = union.CFrame

local step = 7
local running = true

-- câmera
local center = cf.Position
local height = 2
local yaw = 0

-- sensibilidade (ajusta aqui se quiser)
local rotSpeed = 0.5   -- rotação (antes era ~1.5)
local heightSpeed = 0.2 -- subir/descer

-- salvar estado original
local originalType = camera.CameraType
local originalSubject = camera.CameraSubject

camera.CameraType = Enum.CameraType.Scriptable

-- input
local keys = {}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    keys[input.KeyCode] = true

    if input.KeyCode == Enum.KeyCode.F5 then
        running = false
    end
end)

UserInputService.InputEnded:Connect(function(input)
    keys[input.KeyCode] = false
end)

-- controle da câmera
RunService.RenderStepped:Connect(function()
    if not running then return end

    -- 🔄 invertido corretamente agora
    if keys[Enum.KeyCode.Left] then
        yaw += rotSpeed
    end
    if keys[Enum.KeyCode.Right] then
        yaw -= rotSpeed
    end

    if keys[Enum.KeyCode.Up] then
        height += heightSpeed
    end
    if keys[Enum.KeyCode.Down] then
        height -= heightSpeed
    end

    local camPos = center + Vector3.new(0, height, 0)
    local camCF = CFrame.new(camPos) * CFrame.Angles(0, math.rad(yaw), 0)

    camera.CFrame = camCF
end)

-- loop de varredura
while running do
    for x = -size.X/2, size.X/2, step do
        if not running then break end

        local invert = math.floor((x + size.X/2) / step) % 2 == 1

        if not invert then
            for z = -size.Z/2, size.Z/2, step do
                if not running then break end

                local pos = cf:PointToWorldSpace(Vector3.new(x, 0, z))
                root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))

                task.wait(0.01)
            end
        else
            for z = size.Z/2, -size.Z/2, -step do
                if not running then break end

                local pos = cf:PointToWorldSpace(Vector3.new(x, 0, z))
                root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))

                task.wait(0.01)
            end
        end
    end
end

-- restaurar câmera
camera.CameraType = originalType
camera.CameraSubject = character:FindFirstChildOfClass("Humanoid")