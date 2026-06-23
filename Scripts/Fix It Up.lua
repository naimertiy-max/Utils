--// CORE
local P=game:GetService("Players").LocalPlayer if not P then return end
local UIS,TS,TP,RS,W=game:GetService("UserInputService"),game:GetService("TweenService"),game:GetService("TeleportService"),game:GetService("RunService"),workspace
local PLACE,JOB=game.PlaceId,game.JobId
local C,ESP,WC={},setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"})
local function con(s,f)local c=s:Connect(f)table.insert(C,c)return c end

--// GUI
local G=Instance.new("ScreenGui",P:WaitForChild("PlayerGui")) G.ResetOnSpawn=false
local M=Instance.new("Frame",G) M.Size=UDim2.fromOffset(420,300) M.Position=UDim2.fromScale(.5,.5)-UDim2.fromOffset(210,150)
M.BackgroundColor3=Color3.fromRGB(18,18,22) M.Active=true Instance.new("UICorner",M).CornerRadius=UDim.new(0,16)

local T=Instance.new("Frame",M) T.Size=UDim2.new(1,0,0,42) T.BackgroundColor3=Color3.fromRGB(30,30,35) T.Active=true
Instance.new("UICorner",T).CornerRadius=UDim.new(0,16)

local function btn(txt,x,col)
	local b=Instance.new("TextButton",T)
	b.Size=UDim2.fromOffset(28,28) b.Position=UDim2.new(1,x,0.5,-14)
	b.Text=txt b.Font=Enum.Font.GothamBold b.TextSize=14
	b.BackgroundColor3=col or Color3.fromRGB(45,45,50)
	b.TextColor3=Color3.new(1,1,1) b.BorderSizePixel=0
	Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
	return b
end

local MIN=btn("-", -68)
local CLS=btn("X", -36, Color3.fromRGB(60,40,40))
local REJ=btn("!", -100)

local DIV=Instance.new("Frame",M) DIV.Size=UDim2.new(1,0,0,1) DIV.Position=UDim2.new(0,0,0,42)
DIV.BackgroundColor3=Color3.new(1,1,1) DIV.BackgroundTransparency=.85

local CT=Instance.new("Frame",M) CT.Position=UDim2.new(0,0,0,43) CT.Size=UDim2.new(1,0,1,-43)
CT.BackgroundTransparency=1

--// DRAG
do
	local d,sp,op
	con(T.InputBegan,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then d=true sp=i.Position op=M.Position end end)
	con(UIS.InputChanged,function(i)
		if d and i.UserInputType==Enum.UserInputType.MouseMovement then
			local delta=i.Position-sp
			M.Position=UDim2.new(op.X.Scale,op.X.Offset+delta.X,op.Y.Scale,op.Y.Offset+delta.Y)
		end
	end)
	con(UIS.InputEnded,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end end)
end

--// ROT
local function rot(b)TS:Create(b,TweenInfo.new(.2),{Rotation=180}):Play()end

--// MIN
local min=false; local sz
con(MIN.MouseButton1Click,function()
	rot(MIN) min=not min
	if min then sz=M.Size M.Size=UDim2.fromOffset(108,42) CT.Visible=false DIV.Visible=false MIN.Text="+"
	else M.Size=sz CT.Visible=true DIV.Visible=true MIN.Text="-"
	end
end)

--// CLOSE
local function close()
	for _,c in ipairs(C)do pcall(function()c:Disconnect()end)end
	G:Destroy()
end
con(CLS.MouseButton1Click,function()rot(CLS)task.delay(.1,close)end)

--// REJOIN
local rstate="idle"
con(REJ.MouseButton1Click,function()
	if rstate=="idle" then rstate="confirm" REJ.Text="?" task.delay(3,function()if rstate=="confirm"then rstate="idle"REJ.Text="!"end end)
	else
		REJ.Text="..." TP:TeleportToPlaceInstance(PLACE,JOB,P)
	end
end)

--// TOGGLE MAKER
local function toggle(txt,y,cb)
	local l=Instance.new("TextLabel",CT)
	l.Text=txt l.Size=UDim2.new(0,120,0,20) l.Position=UDim2.new(0,16,0,y)
	l.BackgroundTransparency=1 l.TextColor3=Color3.new(1,1,1)
	local b=Instance.new("TextButton",CT)
	b.Size=UDim2.fromOffset(50,28) b.Position=UDim2.new(1,-66,0,y-4)
	b.BackgroundColor3=Color3.fromRGB(120,120,120) b.Text="" b.BorderSizePixel=0
	Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
	local h=Instance.new("Frame",b)
	h.Size=UDim2.fromOffset(24,24) h.Position=UDim2.fromOffset(2,2)
	h.BackgroundColor3=Color3.new(1,1,1) h.BorderSizePixel=0
	Instance.new("UICorner",h).CornerRadius=UDim.new(1,0)
	local on=false
	con(b.MouseButton1Click,function()
		on=not on
		TS:Create(h,TweenInfo.new(.15),{Position=UDim2.fromOffset(on and 24 or 2,2)}):Play()
		TS:Create(b,TweenInfo.new(.15),{BackgroundColor3=on and Color3.fromRGB(84,190,118) or Color3.fromRGB(120,120,120)}):Play()
		cb(on)
	end)
end

--// FREE ZOOM (auto)
con(RS.Heartbeat,function()
	pcall(function()
		P.CameraMaxZoomDistance=1000
		P.CameraMinZoomDistance=0
	end)
end)

--// SPEED
local spdConn
toggle("Speed",48,function(v)
	if spdConn then spdConn:Disconnect() spdConn=nil end
	if v then
		spdConn=con(RS.Heartbeat,function()
			local h=P.Character and P.Character:FindFirstChildOfClass("Humanoid")
			if h then h.WalkSpeed=60 end
		end)
	end
end)

--// TELEPORT
local tpConn
toggle("Teleport",84,function(v)
	if tpConn then tpConn:Disconnect() tpConn=nil end
	if v then
		tpConn=con(UIS.InputBegan,function(i,g)
			if not g and i.KeyCode==Enum.KeyCode.V then
				local m=P:GetMouse()
				local hrp=P.Character and P.Character:FindFirstChild("HumanoidRootPart")
				if m and hrp then hrp.CFrame=CFrame.new(m.Hit.p+Vector3.new(0,3,0))end
			end
		end)
	end
end)

--// CAR ESP (compact)
local rare={Rim2=1,Rim12=1,Rim17=1,Rim18=1,Rim19=1,Rim49=1,Rim53=1,Rim57=1,Rim69=1}
local function hasRareWheel(m)
	if WC[m]~=nil then return WC[m] end
	local w=m:FindFirstChild("Wheels")
	if not w then WC[m]=false return false end
	for _,s in ipairs({"FL","FR","RL","RR"})do
		local p=w:FindFirstChild(s)
		local r=p and p:FindFirstChild("Parts")
		local rn=r and (r:GetAttribute("RimName") or r:FindFirstChild("RimName") and r.RimName.Value)
		local d=r and (r:GetAttribute("Diameter") or r:FindFirstChild("Diameter") and r.Diameter.Value)
		if rn and rare[tostring(rn)] and tonumber(d)>=20 then WC[m]=true return true end
	end
	WC[m]=false return false
end

local function makeESP(m)
	if ESP[m] then return end
	local bp=m:FindFirstChildWhichIsA("BasePart",true) if not bp then return end
	local bb=Instance.new("BillboardGui",G) bb.Adornee=bp bb.Size=UDim2.fromOffset(140,36) bb.AlwaysOnTop=true
	local t=Instance.new("TextLabel",bb) t.Size=UDim2.new(1,0,1,0)
	t.BackgroundTransparency=1 t.TextWrapped=true t.TextColor3=Color3.fromRGB(200,255,200)
	local h=Instance.new("Highlight",m)
	ESP[m]={bb=bb,t=t,h=h}
end

local function updateESP()
	local V=W:FindFirstChild("Vehicles") if not V then return end
	for _,m in ipairs(V:GetChildren())do
		if m:IsA("Model")then
			makeESP(m)
			local e=ESP[m]
			if e then
				local sc=m:GetAttribute("SpawnChance") or (m:FindFirstChild("SpawnChance") and m.SpawnChance.Value)
				local rareSpawn=sc and sc<=1
				local wheel=hasRareWheel(m)
				e.t.Text=(wheel and "RODA RARA!\n" or "").."Pity: "..(sc and sc.."%" or "N/A")
				if wheel then e.h.FillColor=Color3.fromRGB(84,118,255)
				elseif rareSpawn then e.h.FillColor=Color3.fromRGB(255,80,80)
				else e.h.FillColor=Color3.fromRGB(84,190,118)end
			end
		end
	end
end

local carConn
toggle("Car ESP",12,function(v)
	if carConn then carConn:Disconnect() carConn=nil end
	if v then carConn=con(RS.Heartbeat,function()updateESP()end)
	else for m,e in pairs(ESP)do if e.bb then e.bb:Destroy()end if e.h then e.h:Destroy()end ESP[m]=nil end end
end)