local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local ativo = true

-- monta caminho completo
local function getPath(obj)
    local path = obj.Name
    local parent = obj.Parent

    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end

    return path
end

-- clique do mouse
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not ativo then return end

    -- clique esquerdo
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local x, y = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
        
        local guis = player.PlayerGui:GetGuiObjectsAtPosition(x, y)

        if #guis > 0 then
            print("📦 Caminho:", getPath(guis[1]))
        end
    end

    -- F5 finaliza
    if input.KeyCode == Enum.KeyCode.F5 then
        ativo = false
        print("🛑 Script finalizado")
    end
end)
