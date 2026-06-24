-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Config
local SIZE = 100
local ENABLED = false

local baseplate = nil
local connection = nil
local fixedY = nil -- altura travada

-- Criar baseplate
local function createPlate()
    if baseplate then baseplate:Destroy() end

    baseplate = Instance.new("Part")
    baseplate.Size = Vector3.new(SIZE, 1, SIZE)
    baseplate.Anchored = true
    baseplate.Material = Enum.Material.Concrete
    baseplate.Name = "InfinitePlate"
    baseplate.Parent = workspace
end

-- Pegar altura do "pé"
local function getFootY()
    local char = player.Character
    if not char then return nil end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if not hrp or not humanoid then return nil end

    -- calcula altura do pé (aproximação estável)
    return hrp.Position.Y - (humanoid.HipHeight + (hrp.Size.Y / 2))
end

-- Iniciar
local function start()
    createPlate()

    fixedY = getFootY()
    if not fixedY then return end

    connection = RunService.RenderStepped:Connect(function()
        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local pos = hrp.Position

        -- X e Z seguem você, Y fica fixo
        baseplate.Position = Vector3.new(pos.X, fixedY, pos.Z)
    end)
end

-- Parar
local function stop()
    if connection then
        connection:Disconnect()
        connection = nil
    end

    if baseplate then
        baseplate:Destroy()
        baseplate = nil
    end

    fixedY = nil
end

-- Toggle G
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.G then
        ENABLED = not ENABLED

        if ENABLED then
            start()
        else
            stop()
        end
    end
end)