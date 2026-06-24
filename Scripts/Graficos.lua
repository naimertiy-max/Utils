local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- Remove efeitos antigos
for _, v in ipairs(Lighting:GetChildren()) do
	if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") then
		v:Destroy()
	end
end

-- Remove nuvens antigas
if Terrain then
	local OldClouds = Terrain:FindFirstChildOfClass("Clouds")
	if OldClouds then
		OldClouds:Destroy()
	end
end

-- Iluminação
Lighting.Technology = Enum.Technology.Future
Lighting.Ambient = Color3.fromRGB(10, 10, 10)
Lighting.Brightness = 2
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
Lighting.ShadowSoftness = 1
Lighting.ClockTime = 17.2
Lighting.GeographicLatitude = 45
Lighting.ExposureCompensation = 0.2

-- Bloom
local Bloom = Instance.new("BloomEffect")
Bloom.Parent = Lighting
Bloom.Intensity = 0.15
Bloom.Size = 24
Bloom.Threshold = 1

-- Blur
local Blur = Instance.new("BlurEffect")
Blur.Parent = Lighting
Blur.Size = 1

-- Correção de cor
local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Parent = Lighting
ColorCorrection.Brightness = 0.03
ColorCorrection.Contrast = 0.18
ColorCorrection.Saturation = -0.05
ColorCorrection.TintColor = Color3.fromRGB(255, 245, 235)

-- Raios de sol
local SunRays = Instance.new("SunRaysEffect")
SunRays.Parent = Lighting
SunRays.Intensity = 0.06
SunRays.Spread = 0.8

-- Depth of Field
local DoF = Instance.new("DepthOfFieldEffect")
DoF.Parent = Lighting
DoF.FocusDistance = 30
DoF.InFocusRadius = 60
DoF.NearIntensity = 0.08
DoF.FarIntensity = 0.06

-- Atmosfera
local Atmosphere = Instance.new("Atmosphere")
Atmosphere.Parent = Lighting
Atmosphere.Density = 0.28
Atmosphere.Offset = 0.1
Atmosphere.Color = Color3.fromRGB(199, 220, 255)
Atmosphere.Decay = Color3.fromRGB(106, 112, 125)
Atmosphere.Glare = 0.15
Atmosphere.Haze = 0.8

-- Skybox
local Sky = Instance.new("Sky")
Sky.Parent = Lighting
Sky.SkyboxBk = "http://www.roblox.com/asset/?id=151165214"
Sky.SkyboxDn = "http://www.roblox.com/asset/?id=151165197"
Sky.SkyboxFt = "http://www.roblox.com/asset/?id=151165224"
Sky.SkyboxLf = "http://www.roblox.com/asset/?id=151165191"
Sky.SkyboxRt = "http://www.roblox.com/asset/?id=151165206"
Sky.SkyboxUp = "http://www.roblox.com/asset/?id=151165227"
Sky.SunAngularSize = 11
Sky.MoonAngularSize = 8

-- Nuvens volumétricas
if Terrain then
	local Clouds = Instance.new("Clouds")
	Clouds.Parent = Terrain

	Clouds.Cover = 0.3
	Clouds.Density = 0.95
	Clouds.Color = Color3.fromRGB(255, 255, 255)
end

-- Vinheta
local Gui = Instance.new("ScreenGui")
Gui.Name = "RealismEffects"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.Parent = StarterGui

local ShadowFrame = Instance.new("ImageLabel")
ShadowFrame.Parent = Gui
ShadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ShadowFrame.Position = UDim2.fromScale(0.5, 0.5)
ShadowFrame.Size = UDim2.fromScale(1.15, 1.15)
ShadowFrame.BackgroundTransparency = 1
ShadowFrame.Image = "rbxassetid://4576475446"
ShadowFrame.ImageTransparency = 0.3
ShadowFrame.ZIndex = 100

script:Destroy()