local p=game.Players.LocalPlayer
local rs=game:GetService("RunService")
local uis=game:GetService("UserInputService")
local cam=workspace.CurrentCamera
local vim=game:GetService("VirtualInputManager")

local rsConn
local forcaAim = 0.12 -- 0 a 1

local lockR,defR,acc,click=30,7,"M1ing",0.2
local ctrl,cKey,char,hrp,lock,ativo=false,false,nil,nil,nil,true

local ultimoAlvo=nil

local function setNoCol(m)
	for _,v in pairs(m:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide=false
		end
	end
end

local function resetCol(m)
	for _,v in pairs(m:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide=true
		end
	end
end

local function cleanup()
	ativo=false
	lock=nil
	ctrl=false
	cKey=false
	
	if ultimoAlvo then
		resetCol(ultimoAlvo)
		ultimoAlvo=nil
	end
	
	if rsConn then
		rsConn:Disconnect()
	end
end

local function upd(c)
	char=c
	hrp=c:WaitForChild("HumanoidRootPart")
	lock=nil
end

if p.Character then upd(p.Character) end
p.CharacterAdded:Connect(upd)

local function d(a,b)
	return (a.Position-b.Position).Magnitude
end

local function accHas(m)
	for _,v in pairs(m:GetChildren())do
		if v:IsA("Accessory")and v.Name==acc then
			return true
		end
	end
end

local function f()
	vim:SendKeyEvent(true,Enum.KeyCode.F,false,game)
	task.wait(click)
	vim:SendKeyEvent(false,Enum.KeyCode.F,false,game)
end

uis.InputBegan:Connect(function(i,g)
	if g then return end
	
	if i.KeyCode==Enum.KeyCode.F5 then
		cleanup()
		if script then pcall(function() script:Destroy() end) end
	end
	
	if i.KeyCode==Enum.KeyCode.LeftControl then
		ctrl=true
	end
	
	if i.KeyCode==Enum.KeyCode.C then
		cKey=true
	end
end)

uis.InputEnded:Connect(function(i)
	if i.KeyCode==Enum.KeyCode.LeftControl then
		ctrl=false
		lock=nil
	end
	
	if i.KeyCode==Enum.KeyCode.C then
		cKey=false
	end
end)

rsConn = rs.RenderStepped:Connect(function()
	if not ativo or not char or not hrp then return end
	
	local live=workspace:FindFirstChild("Live")
	if not live then return end

	-- AIM
	if ctrl and forcaAim>0 then
		if not lock or not lock.Parent then
			local m=lockR
			for _,v in pairs(live:GetChildren())do
				if v:IsA("Model") and v~=char and v:FindFirstChild("HumanoidRootPart") then
					local dist=d(hrp,v.HumanoidRootPart)
					if dist<m then
						m=dist
						lock=v
					end
				end
			end
		end

		if lock then
			if lock~=ultimoAlvo then
				if ultimoAlvo then resetCol(ultimoAlvo) end
				ultimoAlvo=lock
			end

			-- força no-collision TODO FRAME
			if ultimoAlvo then setNoCol(ultimoAlvo) end

			local rp=hrp.Position
			local tp=lock.HumanoidRootPart.Position

			local flat=Vector3.new(tp.X-rp.X,0,tp.Z-rp.Z).Unit
			local va=math.asin(cam.CFrame.LookVector.Y)

			local look=Vector3.new(
				flat.X*math.cos(va),
				math.sin(va),
				flat.Z*math.cos(va)
			)

			local cp=cam.CFrame.Position
			local targetCF=CFrame.new(cp,cp+look)

			cam.CFrame=cam.CFrame:Lerp(targetCF,forcaAim)

			hrp.CFrame=hrp.CFrame:Lerp(
				CFrame.new(rp,Vector3.new(tp.X,rp.Y,tp.Z)),
				forcaAim*0.7
			)
		end
	else
		if ultimoAlvo then
			resetCol(ultimoAlvo)
			ultimoAlvo=nil
		end
	end

	-- DEFLECT
	if cKey then
		for _,v in pairs(live:GetChildren())do
			if v:IsA("Model") and v~=char and v:FindFirstChild("HumanoidRootPart") then
				if d(hrp,v.HumanoidRootPart)<=defR and accHas(v) then
					local tp=v.HumanoidRootPart.Position
					hrp.CFrame=CFrame.new(hrp.Position,Vector3.new(tp.X,hrp.Position.Y,tp.Z))
					f()
				end
			end
		end
	end
end)