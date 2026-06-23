local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- controle
local ativo = false

-- lista de posições
local pontos = {}

-- índice atual
local index = 1

-- estado do clique (down/up)
local segurando = false

-- salvar posição com C
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.C then
        local mousePos = UserInputService:GetMouseLocation()
        
        table.insert(pontos, {
            x = mousePos.X,
            y = mousePos.Y
        })

        print("Posição salva:", #pontos, mousePos.X, mousePos.Y)
    end

    if input.KeyCode == Enum.KeyCode.V then
        ativo = not ativo
        print("AutoClick:", ativo and "ON" or "OFF")

        if not ativo then
            -- reset total
            pontos = {}
            index = 1
            segurando = false
            print("Pontos resetados.")
        end
    end
end)

-- loop ultra rápido (por frame)
RunService.RenderStepped:Connect(function()
    if not ativo or #pontos == 0 then return end

    local p = pontos[index]

    if not segurando then
        -- mouse down
        VirtualInputManager:SendMouseButtonEvent(
            p.x,
            p.y,
            0,
            true,
            game,
            0
        )
        segurando = true
    else
        -- mouse up
        VirtualInputManager:SendMouseButtonEvent(
            p.x,
            p.y,
            0,
            false,
            game,
            0
        )
        segurando = false

        -- próximo ponto
        index += 1
        if index > #pontos then
            index = 1
        end
    end
end)