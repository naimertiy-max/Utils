local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local running = true
local currentTrack = nil
local currentTarget = nil
local movementConnection = nil

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.F5 then
        running = false

        if movementConnection then
            movementConnection:Disconnect()
        end

        if currentTrack then
            currentTrack:Stop()
            currentTrack:Destroy()
        end
    end
end)

local function getCurrentAnimation(player)
    if not player.Character then return nil end

    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return nil end

    local tracks = animator:GetPlayingAnimationTracks()

    for _, track in ipairs(tracks) do
        if track.Animation and track.Animation.AnimationId ~= "" then
            return track
        end
    end

    return nil
end

local function stopAnimation()
    if movementConnection then
        movementConnection:Disconnect()
        movementConnection = nil
    end

    if currentTrack then
        currentTrack:Stop()
        currentTrack:Destroy()
        currentTrack = nil
    end

    currentTarget = nil
end

local function playAnimation(animationId, speed, timePos)
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    if currentTrack then
        currentTrack:Stop()
        currentTrack:Destroy()
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = animationId

    currentTrack = animator:LoadAnimation(anim)

    currentTrack.Looped = true
    currentTrack.Priority = Enum.AnimationPriority.Action4

    currentTrack:Play(0)

    currentTrack.TimePosition = timePos or 0
    currentTrack:AdjustSpeed(speed or 1)

    if movementConnection then
        movementConnection:Disconnect()
    end

    movementConnection = RunService.Heartbeat:Connect(function()
        if humanoid.MoveDirection.Magnitude > 0 then
            stopAnimation()
        end
    end)
end

Mouse.Button1Down:Connect(function()
    if not running then return end

    local target = Mouse.Target
    if not target then return end

    local character = target:FindFirstAncestorOfClass("Model")
    if not character then return end

    local player = Players:GetPlayerFromCharacter(character)

    if not player or player == LocalPlayer then
        return
    end

    if currentTarget == player then
        stopAnimation()
        return
    end

    local targetTrack = getCurrentAnimation(player)

    if not targetTrack then
        return
    end

    currentTarget = player

    playAnimation(
        targetTrack.Animation.AnimationId,
        targetTrack.Speed,
        targetTrack.TimePosition
    )
end)