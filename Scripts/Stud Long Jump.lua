local u=game:GetService("UserInputService")
local p=game.Players.LocalPlayer
local s=workspace:WaitForChild("Stages")
local run,con
local function go()
	if run then return end
	run=true
	local h=(p.Character or p.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
	for i=1,135 do
		if not run then break end
		local f=s:FindFirstChild(tostring(i))
		if f then h.CFrame=f.CFrame+Vector3.new(0,3,0) end
		task.wait(.1)
	end
	run=false
end
con=u.InputBegan:Connect(function(k,g)
	if g then return end
	if k.KeyCode==Enum.KeyCode.V then go()
	elseif k.KeyCode==Enum.KeyCode.F5 then run=false con:Disconnect() script:Destroy()
	end
end)