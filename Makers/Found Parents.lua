local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FinderGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Parent = screenGui

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 40)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.PlaceholderText = "Digite o nome da GUI..."
textBox.Text = ""
textBox.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 0, 30)
button.Position = UDim2.new(0, 10, 0, 60)
button.Text = "Buscar"
button.Parent = frame

-- 🔍 Listar hierarquia
local function listar(obj, indent)
    indent = indent or ""
    print(indent .. obj.Name .. " -- " .. obj.ClassName)

    for _, child in ipairs(obj:GetChildren()) do
        listar(child, indent .. "  ")
    end
end

-- 🔍 Procurar objeto
local function procurar(nome)
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj.Name == nome then
            return obj
        end
    end
end

-- 🔍 Buscar com espera
local function buscar(nome)
    local encontrado = procurar(nome)

    if encontrado then
        print("===== ENCONTRADO =====")
        listar(encontrado)
        return
    end

    print("Não encontrado, esperando até 5 segundos...")

    local tempo = 0
    local intervalo = 0.1

    while tempo < 5 do
        task.wait(intervalo)
        tempo += intervalo

        encontrado = procurar(nome)
        if encontrado then
            print("===== ENCONTRADO (DELAY) =====")
            listar(encontrado)
            return
        end
    end

    warn("Não encontrado após 5 segundos: " .. nome)
end

-- Botão
button.MouseButton1Click:Connect(function()
    local nome = textBox.Text
    if nome ~= "" then
        buscar(nome)
    end
end)

-- 🖱️ Arrastar GUI
local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ⌨️ F5 finaliza
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F5 then
        screenGui:Destroy()
        print("FinderGUI finalizado.")
    end
end)