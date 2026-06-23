local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local placeId = game.PlaceId

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ServerJoinGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 140)
frame.Position = UDim2.new(0.5, -160, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Parent = gui

local textbox = Instance.new("TextBox")
textbox.Size = UDim2.new(0, 300, 0, 35)
textbox.Position = UDim2.new(0, 10, 0, 10)
textbox.PlaceholderText = "Cole o JobId do servidor aqui..."
textbox.Text = ""
textbox.ClearTextOnFocus = false
textbox.BackgroundColor3 = Color3.fromRGB(55,55,55)
textbox.TextColor3 = Color3.new(1,1,1)
textbox.Parent = frame

local joinButton = Instance.new("TextButton")
joinButton.Size = UDim2.new(0, 145, 0, 40)
joinButton.Position = UDim2.new(0, 10, 0, 55)
joinButton.Text = "Entrar"
joinButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
joinButton.TextColor3 = Color3.new(1,1,1)
joinButton.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 145, 0, 40)
copyButton.Position = UDim2.new(0, 165, 0, 55)
copyButton.Text = "Copiar JobId"
copyButton.BackgroundColor3 = Color3.fromRGB(0,170,0)
copyButton.TextColor3 = Color3.new(1,1,1)
copyButton.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 300, 0, 25)
status.Position = UDim2.new(0, 10, 0, 105)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.new(1,1,1)
status.Parent = frame

copyButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(game.JobId)
        status.Text = "JobId copiado!"
    else
        status.Text = "Seu executor não suporta setclipboard."
    end
end)

joinButton.MouseButton1Click:Connect(function()
    local jobId = textbox.Text:gsub("%s+", "")

    if jobId == "" then
        status.Text = "Digite um JobId."
        return
    end

    status.Text = "Entrando..."

    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)

    if not success then
        status.Text = "Erro: "..tostring(err)
    end
end)