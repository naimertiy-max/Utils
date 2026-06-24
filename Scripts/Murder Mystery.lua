local P=game:GetService("Players")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")

local LP=P.LocalPlayer

local ativo=true
local H={}
local GESP={}

-- =========================
-- TOOL
-- =========================
local function tem(plr,n)
	local b=plr:FindFirstChild("Backpack")
	local c=plr.Character
	if b then
		for _,v in pairs(b:GetChildren()) do
			if v:IsA("Tool") and v.Name==n then return true end
		end
	end
	if c then
		for _,v in pairs(c:GetChildren()) do
			if v:IsA("Tool") and v.Name==n then return true end
		end
	end
end

-- =========================
-- HIGHLIGHT PLAYER
-- =========================
local function setH(cor,char)
	if not char then return end
	local h=H[char]
	if not h then
		h=Instance.new("Highlight")
		h.FillTransparency=0.5
		h.Parent=char
		H[char]=h
	end
	h.FillColor=cor
	h.OutlineColor=cor
end

-- =========================
-- GUNDROP ESP
-- =========================
local function criarGunESP(part)
	if GESP[part] then return end

	local h=Instance.new("Highlight")
	h.FillColor=Color3.fromRGB(170,0,255)
	h.OutlineColor=h.FillColor
	h.FillTransparency=0.3
	h.Parent=part

	local bill=Instance.new("BillboardGui")
	bill.Size=UDim2.new(0,100,0,40)
	bill.AlwaysOnTop=true
	bill.Adornee=part

	local txt=Instance.new("TextLabel")
	txt.Size=UDim2.new(1,0,1,0)
	txt.BackgroundTransparency=1
	txt.Text="ARMA"
	txt.TextColor3=Color3.fromRGB(170,0,255)
	txt.TextScaled=true
	txt.Font=Enum.Font.SourceSansBold
	txt.Parent=bill

	bill.Parent=part

	GESP[part]={h,bill}
end

local function limparGunESP(part)
	if GESP[part] then
		for _,v in pairs(GESP[part]) do
			if v then v:Destroy() end
		end
		GESP[part]=nil
	end
end

local function scanGunDrops()
	for _,m in pairs(workspace:GetChildren()) do
		local g=m:FindFirstChild("GunDrop")
		if g and g:IsA("BasePart") then
			criarGunESP(g)
		end
	end
end

workspace.ChildAdded:Connect(function(m)
	local g=m:FindFirstChild("GunDrop")
	if g and g:IsA("BasePart") then
		criarGunESP(g)
	end
end)

workspace.ChildRemoved:Connect(function(m)
	local g=m:FindFirstChild("GunDrop")
	if g then limparGunESP(g) end
end)

-- =========================
-- LOOP
-- =========================
R.RenderStepped:Connect(function()
	if not ativo then return end

	-- players ESP
	for _,plr in pairs(P:GetPlayers()) do
		if plr~=LP and plr.Character then
			if tem(plr,"Knife") then
				setH(Color3.fromRGB(255,0,0),plr.Character)
			elseif tem(plr,"Gun") then
				setH(Color3.fromRGB(0,0,255),plr.Character)
			else
				setH(Color3.fromRGB(0,255,0),plr.Character)
			end
		end
	end

	-- gun drop ESP
	scanGunDrops()
end)

-- =========================
-- F5 DESLIGA
-- =========================
U.InputBegan:Connect(function(i,g)
	if g then return end
	if i.KeyCode==Enum.KeyCode.F5 then
		ativo=false
		
		for _,h in pairs(H) do
			if h then h:Destroy() end
		end
		H={}
		
		for _,v in pairs(GESP) do
			for _,x in pairs(v) do
				if x then x:Destroy() end
			end
		end
		GESP={}
	end
end)