local P,U,R=game:GetService("Players"),game:GetService("UserInputService"),game:GetService("RunService")
local pl,cam=P.LocalPlayer,workspace.CurrentCamera
local tgt,sp=nil,false
local idx,btns=1,{}
local rc,ic

local g=Instance.new("ScreenGui",pl:WaitForChild("PlayerGui")) g.Name="StalkGUI" g.ResetOnSpawn=false
local f=Instance.new("Frame",g) f.Size=UDim2.new(0,270,0,230) f.Position=UDim2.new(0,20,0,20) f.BackgroundColor3=Color3.fromRGB(25,25,25) Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)

local top=Instance.new("Frame",f) top.Size=UDim2.new(1,0,0,30) top.BackgroundColor3=Color3.fromRGB(35,35,35) Instance.new("UICorner",top).CornerRadius=UDim.new(0,10)
local title=Instance.new("TextLabel",top) title.Size=UDim2.new(1,0,1,0) title.BackgroundTransparency=1 title.Text="StalkGUI" title.Font=Enum.Font.GothamBold title.TextSize=14 title.TextColor3=Color3.new(1,1,1)

local drag,ds,sp0=false
top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true ds=i.Position sp0=f.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end) end end)
U.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds f.Position=UDim2.new(sp0.X.Scale,sp0.X.Offset+d.X,sp0.Y.Scale,sp0.Y.Offset+d.Y) end end)

local t=Instance.new("TextBox",f)
t.Size=UDim2.new(1,-20,0,35)
t.Position=UDim2.new(0,10,0,45)
t.Text=""
t.PlaceholderText="nome ou display..."
t.BackgroundColor3=Color3.fromRGB(35,35,35)
t.TextColor3=Color3.new(1,1,1)
t.Font=Enum.Font.Gotham
t.TextSize=14
t.ClearTextOnFocus=false
Instance.new("UICorner",t).CornerRadius=UDim.new(0,6)

local sug=Instance.new("Frame",f)
sug.Size=UDim2.new(1,-20,0,90)
sug.Position=UDim2.new(0,10,0,90)
sug.BackgroundTransparency=1
Instance.new("UIListLayout",sug).Padding=UDim.new(0,4)

local m=Instance.new("TextLabel",f)
m.Size=UDim2.new(1,-20,0,35)
m.Position=UDim2.new(0,10,1,-40)
m.BackgroundTransparency=1
m.Text="V = stalk toggle | F5 = end"
m.Font=Enum.Font.Gotham
m.TextSize=12
m.TextColor3=Color3.fromRGB(200,200,200)

local function clear() for _,b in pairs(btns) do b:Destroy() end btns={} idx=1 end
local function hi() for i,b in ipairs(btns) do b.BackgroundColor3=(i==idx) and Color3.fromRGB(70,70,70) or Color3.fromRGB(40,40,40) end end

local function update()
	clear() local txt=t.Text:lower() if txt=="" then return end
	local m={}
	for _,p in pairs(P:GetPlayers()) do
		if p.Name:lower():find(txt) or p.DisplayName:lower():find(txt) then
			table.insert(m,p)
		end
	end
	for i=1,math.min(5,#m) do
		local p=m[i]
		local b=Instance.new("TextButton",sug)
		b.Size=UDim2.new(1,0,0,22)
		b.Text=p.DisplayName.." (@"..p.Name..")"
		b.BackgroundColor3=Color3.fromRGB(40,40,40)
		b.TextColor3=Color3.new(1,1,1)
		b.Font=Enum.Font.Gotham
		b.TextSize=13
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
		b.MouseButton1Click:Connect(function() t.Text=p.Name clear() end)
		table.insert(btns,b)
	end
	hi()
end
t:GetPropertyChangedSignal("Text"):Connect(update)

local function toggle()
	if sp then
		sp=false tgt=nil
		if pl.Character and pl.Character:FindFirstChild("Humanoid") then
			cam.CameraSubject=pl.Character.Humanoid
		end
	else
		local p=P:FindFirstChild(t.Text)
		if p and p.Character and p.Character:FindFirstChild("Humanoid") then
			tgt=p sp=true
		end
	end
end

local function kill()
	if pl.Character and pl.Character:FindFirstChild("Humanoid") then
		cam.CameraSubject=pl.Character.Humanoid
	end
	if rc then rc:Disconnect() end
	if ic then ic:Disconnect() end
	g:Destroy()
end

ic=U.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode==Enum.KeyCode.Down then idx=math.clamp(idx+1,1,#btns) hi() end
	if i.KeyCode==Enum.KeyCode.Up then idx=math.clamp(idx-1,1,#btns) hi() end
	if i.KeyCode==Enum.KeyCode.Return and btns[idx] then t.Text=btns[idx].Text:match("@(.+)") clear() end
	if i.KeyCode==Enum.KeyCode.V then toggle() end
	if i.KeyCode==Enum.KeyCode.F5 then kill() end
end)

rc=R.RenderStepped:Connect(function()
	if sp and tgt and tgt.Character and tgt.Character:FindFirstChild("Humanoid") then
		cam.CameraSubject=tgt.Character.Humanoid
		cam.CameraType=Enum.CameraType.Custom
	end
end)