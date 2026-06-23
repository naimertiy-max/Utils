-- ===================== CONFIG =====================
local WEBHOOK_URL = "https://discordapp.com/api/webhooks/1459870420869058744/YAuAVyDlzqi1SOKfStxWgYX2jVzjlVPv_8LIXqUkiY7hOw2KZRXU-PXaQQtjjovLArgT"

local SPAWN_LIMIT = 1
local MIN_DIAMETER = 20

local RARE_RIMS = {
    Rim2 = true, Rim12 = true, Rim17 = true, Rim18 = true,
    Rim19 = true, Rim49 = true, Rim53 = true, Rim57 = true, Rim69 = true,
}

-- ===================== SERVICES =====================
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local NOTIFY_ENABLED = true

local request = (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

if not request then
    warn("Executor sem suporte a HTTP")
    return
end

-- ===================== WEBHOOK =====================
local sentMessages = {}

local function notify(text)
    if not NOTIFY_ENABLED then return end

    local res = request({
        Url = WEBHOOK_URL .. "?wait=true",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ content = text })
    })

    if res and res.Body then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(res.Body)
        end)
        if ok and data and data.id then
            table.insert(sentMessages, data.id)
        end
    end
end

local function clearMessages(amount)
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end

    for _ = 1, amount do
        local id = table.remove(sentMessages)
        if not id then break end
        request({
            Url = WEBHOOK_URL .. "/messages/" .. id,
            Method = "DELETE"
        })
    end
end

-- ===================== UTIL =====================
local notified = {}

local function resetNotifications()
    table.clear(notified)
end

local function getValueOrAttr(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local v = obj:FindFirstChild(name)
    if v and v:IsA("ValueBase") then
        return v.Value
    end
    return nil
end

local function isRareCar(car)
    local raw = tostring(getValueOrAttr(car, "SpawnChance"))
    raw = raw:gsub("%%", "")
    local spawn = tonumber(raw)
    if not spawn then return false end
    if spawn > SPAWN_LIMIT then return false end
    return true, spawn
end

local function getRareWheel(car)
    local wheels = car:FindFirstChild("Wheels")
    if not wheels then return false end

    for _, side in ipairs({ "FL", "FR", "RL", "RR" }) do
        local sm = wheels:FindFirstChild(side)
        if sm then
            local parts = sm:FindFirstChild("Parts")
            if parts then
                local rim = tostring(getValueOrAttr(parts, "RimName"))
                local dia = tonumber(getValueOrAttr(parts, "Diameter"))
                if RARE_RIMS[rim] and dia and dia >= MIN_DIAMETER then
                    return true, rim, dia
                end
            end
        end
    end
    return false
end

-- ===================== CHAT COMMANDS =====================
LocalPlayer.Chatted:Connect(function(msg)
    local text = msg:lower()

    if text == "!stop" then
        if NOTIFY_ENABLED then
            notify("𝑵𝑶𝑻𝑰𝑭𝑰𝑪𝑨𝑪̧𝑨̃𝑶 𝑫𝑬 𝑪𝑨𝑹𝑹𝑶𝑺 𝑫𝑬𝑺𝑳𝑰𝑮𝑨𝑫𝑨 🔴")
            NOTIFY_ENABLED = false
        end
        return
    end

    if text == "!start" then
        if not NOTIFY_ENABLED then
            NOTIFY_ENABLED = true
            resetNotifications()
            notify("𝑵𝑶𝑻𝑰𝑭𝑰𝑪𝑨𝑪̧𝑨̃𝑶 𝑫𝑬 𝑪𝑨𝑹𝑹𝑶𝑺 𝑳𝑰𝑮𝑨𝑫𝑨 🟢")
        end
        return
    end

    local amount = text:match("^!clear%s+(%d+)$") or text:match("^!clean%s+(%d+)$")
    if amount then
        clearMessages(amount)
    end
end)

-- ===================== START =====================
notify("𝑵𝑶𝑻𝑰𝑭𝑰𝑪𝑨𝑪̧𝑨̃𝑶 𝑫𝑬 𝑪𝑨𝑹𝑹𝑶𝑺 𝑳𝑰𝑮𝑨𝑫𝑨 🟢")

RunService.Heartbeat:Connect(function()
    if not NOTIFY_ENABLED then return end

    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then return end

    for _, car in ipairs(vehicles:GetChildren()) do
        if not car:IsA("Model") or notified[car] then
            continue
        end

        -- 🔒 SE TEM OWNER, IGNORA TUDO
        local owner = getValueOrAttr(car, "Owner")
        if owner ~= nil and tostring(owner) ~= "" then
            notified[car] = true
            continue
        end

        local rareCar, spawn = isRareCar(car)
        local hasWheel, rim, dia = getRareWheel(car)

        if not rareCar and not hasWheel then
            continue
        end

        notified[car] = true

        local msg = ""

        if rareCar then
            msg = msg ..
                "𝑪𝑨𝑹𝑹𝑶 𝑹𝑨𝑹𝑶 𝑨𝑷𝑨𝑹𝑬𝑪𝑬𝑼!\n" ..
                "𝑪𝑯𝑨𝑵𝑪𝑬: `" .. spawn .. "%`\n"
        end

        if hasWheel then
            msg = msg ..
                "𝑹𝑶𝑫𝑨 𝑹𝑨𝑹𝑨 𝑨𝑷𝑨𝑹𝑬𝑪𝑬𝑼!\n" ..
                "𝑻𝑰𝑷𝑶: `" .. rim .. "`\n" ..
                "𝑫𝑰𝑨̂𝑴𝑬𝑻𝑹𝑶: `" .. dia .. "`\n"
        end

        notify(msg)
    end
end)
