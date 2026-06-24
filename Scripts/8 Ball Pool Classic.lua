local Table1 = workspace.Tables.Table1
local HitTrajectory = Table1.Guides.HitTrajectory

local maxSegments = 5
local segmentLength = 10
local trajectoryParts = {}

local function clearTrajectory()
    for _, part in pairs(trajectoryParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    trajectoryParts = {}
end

local function updateTrajectory()
    clearTrajectory()

    local startPos = HitTrajectory.Position
    local direction = HitTrajectory.CFrame.LookVector.Unit
    local currentPos = startPos

    for i = 1, maxSegments do
        local nextPos = currentPos + direction * segmentLength

        local line = Instance.new("Part")
        line.Size = Vector3.new(0.2, 0.2, segmentLength)
        line.CFrame = CFrame.lookAt(currentPos, nextPos) * CFrame.new(0, 0, -segmentLength / 2)
        line.BrickColor = BrickColor.Green()
        line.Anchored = true
        line.CanCollide = false
        line.Parent = workspace

        table.insert(trajectoryParts, line)
        currentPos = nextPos
    end
end

HitTrajectory:GetPropertyChangedSignal("CFrame"):Connect(updateTrajectory)

updateTrajectory()