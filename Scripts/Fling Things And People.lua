-- Compact Script + GUI + Persistência + ZOOM + Q FIX

local P=game:GetService("Players")
local U=game:GetService("UserInputService")
local G=game:GetService("StarterGui")
local RS=game:GetService("RunService")

local L=P.LocalPlayer
local C=workspace.CurrentCamera

repeat task.wait() until C

local base=C.FieldOfView
local normal,zoom,on,dead=base+70,30,true,false
local zoomAtual=zoom

C.FieldOfView=normal

G:SetCore("SendNotification",{Title="Loaded",Text="Q Spam | V Safe | Zoom C | F5 Finalizar"})

local conns={}
local gdVis=false
local holdQ=false
local clearLOS=false
local ignored={}

-- 🔥 CONFIG ZOOM
local zoomStep=2
local zoomMin=10
local zoomMax=80
local segurandoC=false

-- GUI
local gui=Instance.new("ScreenGui")
gui.Name="SafeGUI"
gui.ResetOnSpawn=false
gui.Parent=L:WaitForChild("PlayerGui")

local frame=Instance.new("Frame",gui)
frame.Size=UDim2.new(0,200,0,250)
frame.Position=UDim2.new(0,50,0,50)
frame.BackgroundColor3=Color3.fromRGB(20,20,20)
frame.Active=true
frame.Draggable=true
Instance.new("UICorner",frame)

local title=Instance.new("TextLabel",frame)
title.Size=UDim2.new(1,0,0,30)
title.BackgroundTransparency=1
title.Text="Aliados"
title.TextColor3=Color3.new(1,1,1)
title.TextScaled=true
title.Font=Enum.Font.GothamBold

local scroll=Instance.new("ScrollingFrame",frame)
scroll.Position=UDim2.new(0,0,0,30)
scroll.Size=UDim2.new(1,0,1,-30)
scroll.BackgroundTransparency=1
scroll.ScrollBarThickness=6

local layout=Instance.new("UIListLayout",scroll)
layout.Padding=UDim.new(0,4)

local function refresh()
	for _,v in pairs(scroll:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end
	
	for name,_ in pairs(ignored) do
		local f=Instance.new("Frame",scroll)
		f.Size=UDim2.new(1,0,0,25)
		f.BackgroundTransparency=1
		
		local txt=Instance.new("TextLabel",f)
		txt.Size=UDim2.new(1,-30,1,0)
		local pl=P:FindFirstChild(name)
		txt.Text=pl and pl.DisplayName or name
		txt.TextColor3=Color3.new(1,1,1)
		txt.BackgroundTransparency=1
		txt.TextXAlignment=Enum.TextXAlignment.Left
		
		local btn=Instance.new("TextButton",f)
		btn.Size=UDim2.new(0,25,0,25)
		btn.Position=UDim2.new(1,-25,0,0)
		btn.Text="X"
		btn.BackgroundColor3=Color3.fromRGB(150,0,0)
		btn.TextColor3=Color3.new(1,1,1)
		
		btn.MouseButton1Click:Connect(function()
			ignored[name]=nil
			refresh()
		end)
	end
	
	task.wait()
	scroll.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
end

-- FUNÇÕES
local function getGD()
	local pg=L:FindFirstChild("PlayerGui")
	local cg=pg and pg:FindFirstChild("ControlsGui")
	local pc=cg and cg:FindFirstChild("PCFrame")
	return pc and pc:FindFirstChild("GrabDrop")
end

local function getHRP(c) return c and c:FindFirstChild("HumanoidRootPart") end

local function closest(max)
	local t,d=nil,max or math.huge
	local ch=L.Character
	local my=getHRP(ch)
	if not my then return end
	
	for _,v in pairs(P:GetPlayers()) do
		if v~=L and v.Character then
			local h=getHRP(v.Character)
			if h then
				local dist=(h.Position-my.Position).Magnitude
				if dist<d then t,d=v,dist end
			end
		end
	end
	return t
end

-- AIM
local click=false
local function aim(p)
	if not on or dead or not p then return end
	if ignored[p.Name] then return end
	
	local h=getHRP(p.Character)
	if h then
		C.CFrame=CFrame.new(C.CFrame.Position,h.Position)
		if not click then
			click=true
			mouse1click()
			click=false
		end
	end
end

local function stop()
	if dead then return end
	dead,on=true,false
	C.FieldOfView=base
	for _,c in pairs(conns) do pcall(function() c:Disconnect() end) end
	gui:Destroy()
end

-- RAYCAST
local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Blacklist

-- RESPAWN FIX
L.CharacterAdded:Connect(function()
	task.wait(1)
	C=workspace.CurrentCamera
	C.FieldOfView=normal
end)

-- LOOP PRINCIPAL
table.insert(conns,RS.RenderStepped:Connect(function()
	if dead then return end
	
	local g=getGD()
	gdVis=g and g.Visible or false
	
	local t=closest()
	clearLOS=false
	
	if t and L.Character then
		local h=getHRP(t.Character)
		local my=getHRP(L.Character)
		
		if h and my then
			rp.FilterDescendantsInstances={L.Character,t.Character}
			clearLOS = not workspace:Raycast(C.CFrame.Position,(h.Position-C.CFrame.Position),rp)
		end
	end
end))

-- 🔥 SCROLL ZOOM
table.insert(conns,U.InputChanged:Connect(function(input,g)
	if g or dead then return end
	
	if segurandoC and input.UserInputType==Enum.UserInputType.MouseWheel then
		if input.Position.Z > 0 then
			zoomAtual = math.max(zoomMin, zoomAtual - zoomStep)
		else
			zoomAtual = math.min(zoomMax, zoomAtual + zoomStep)
		end
		
		C.FieldOfView = zoomAtual
	end
end))

-- INPUT
table.insert(conns,U.InputBegan:Connect(function(i,g)
	if g or dead then return end
	
	if i.KeyCode==Enum.KeyCode.F5 then return stop() end
	if not on then return end
	
	-- 🔥 ZOOM
	if i.KeyCode==Enum.KeyCode.C then
		segurandoC=true
		zoomAtual=zoom -- SEMPRE RESET
		C.FieldOfView=zoomAtual
	end
	
	-- 🔥 Q FUNCIONANDO
	if i.KeyCode==Enum.KeyCode.Q then
		holdQ=true
		
		task.spawn(function()
			while holdQ and not dead do
				local t=closest()
				if t and not gdVis and clearLOS then
					aim(t)
				end
				task.wait(0.05)
			end
		end)
	end
	
	-- SAFE LIST
	if i.KeyCode==Enum.KeyCode.V then
		local t=closest(10)
		if t then
			if ignored[t.Name] then
				ignored[t.Name]=nil
			else
				ignored[t.Name]=true
			end
			refresh()
		end
	end
end))

table.insert(conns,U.InputEnded:Connect(function(i)
	if i.KeyCode==Enum.KeyCode.Q then holdQ=false end
	
	if i.KeyCode==Enum.KeyCode.C then
		segurandoC=false
		if on and not dead then
			C.FieldOfView=normal
		end
	end
end))