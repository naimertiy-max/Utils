-- LocalScript (Execute no StarterPlayerScripts ou no seu Executor)
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Limpa interface antiga se já existir
if CoreGui:FindFirstChild("DevStatsOverlay") then
    CoreGui.DevStatsOverlay:Destroy()
end

-- ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DevStatsOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local localPlayer = Players.LocalPlayer
if localPlayer then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainContainer"
MainFrame.Size = UDim2.new(0, 140, 0, 52)
MainFrame.Position = UDim2.new(1, -150, 1, -62) -- Posição inicial (canto inferior direito)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 65)
UIStroke.Thickness = 1.2
UIStroke.Transparency = 0.2
UIStroke.Parent = MainFrame

-- Padding interno
local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 6)
UIPadding.PaddingBottom = UDim.new(0, 6)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = MainFrame

-- Layout em lista vertical
local UIList = Instance.new("UIListLayout")
UIList.Parent = MainFrame
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 2)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Left

-- Função auxiliar para criar linhas de texto
local function criarLinha(nome, ordem)
    local Label = Instance.new("TextLabel")
    Label.Name = nome
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 12
    Label.LayoutOrder = ordem
    Label.Parent = MainFrame
    return Label
end

local fpsLabel = criarLinha("FPSLabel", 1)
local pingLabel = criarLinha("PingLabel", 2)

-- Lógica de arrastar suave (Draggable com InputGlobal)
local dragging = false
local dragInput, mousePos, framePos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - mousePos
        
        -- Calcula o novo posicionamento baseando-se na tela inteira de forma fluida
        local targetPosition = UDim2.new(
            framePos.X.Scale, 
            framePos.X.Offset + delta.X, 
            framePos.Y.Scale, 
            framePos.Y.Offset + delta.Y
        )
        
        -- Aplica um Tween rápido para deixar o arrasto extremamente suave e fluido
        TweenService:Create(MainFrame, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = targetPosition
        }):Play()
    end
end)

-- Lógica de medição do FPS e PING
local frameCount = 0
local lastUpdate = tick()
local currentFps = 60

RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    local now = tick()
    local delta = now - lastUpdate

    if delta >= 0.2 then
        currentFps = math.floor(frameCount / delta)
        frameCount = 0
        lastUpdate = now

        -- Cor do FPS
        local fpsColor = "rgb(80, 255, 140)"
        if currentFps < 45 and currentFps >= 25 then
            fpsColor = "rgb(255, 200, 80)"
        elseif currentFps < 25 then
            fpsColor = "rgb(255, 80, 80)"
        end
        fpsLabel.Text = string.format("<font color=\"rgb(150, 150, 170)\">FPS:</font>  <font color=\"%s\">%d</font>", fpsColor, currentFps)
        fpsLabel.RichText = true

        -- Cor do Ping
        local pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        local pingColor = "rgb(80, 255, 140)"
        if pingVal > 120 and pingVal <= 220 then
            pingColor = "rgb(255, 200, 80)"
        elseif pingVal > 220 then
            pingColor = "rgb(255, 80, 80)"
        end
        pingLabel.Text = string.format("<font color=\"rgb(150, 150, 170)\">PING:</font> <font color=\"%s\">%d ms</font>", pingColor, pingVal)
        pingLabel.RichText = true
    end
end)