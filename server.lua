local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

-- Admin SteamIDs Permissions
local Admins = {
    ["steam:1100001478145xx"] = true, --Beispiel
    ["steam:1100001478145xx"] = true  --Beispiel
}

-- Koordinaten
local einreiseCoords = vector3(1299.5785, -6867.1758, 43.3210)
local ausgangCoords = vector3(1524.9584, 444.9614, 90.6807)

local cities = {
    ["sd"] = {coords = vector3(2716.0957, -1449.2935, 46.2525), name="Saint Denis"},
    ["rh"] = {coords = vector3(1242.0620, -1303.5657, 76.8933), name="Rhodes"},
    ["va"] = {coords = vector3(-166.5762, 638.9116, 114.0321), name="Valentine"},
    ["bw"] = {coords = vector3(-689.7525, -1242.6406, 43.1713), name="Blackwater"},
    ["sb"] = {coords = vector3(-1756.5894, -437.3360, 152.9814), name="Strawberry"},
    ["am"] = {coords = vector3(-3736.1094, -2603.7593, -12.9141), name="Armadillo"},
    ["tw"] = {coords = vector3(-5539.1621, -2954.5271, -0.7117), name="Tumbleweed"},
}

-- Discord Webhook URL
local discordWebhook = ""

-- Help Functions
local function teleportPlayer(playerId, coords)
    local playerPed = GetPlayerPed(playerId)
    if playerPed then
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
    end
end

local function isAdmin(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, id in ipairs(identifiers) do
        if Admins[id] then
            return true
        end
    end
    return false
end

local function getPlayerIdentifiers(playerId)
    local steamID = "N/A"
    local rockstar = "N/A"
    local discordTag = "N/A"

    for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.find(id, "steam:") then
            steamID = id
        elseif string.find(id, "license:") then
            rockstar = id
        elseif string.find(id, "discord:") then
            discordTag = id
        end
    end

    local name = GetPlayerName(playerId) or "Unknown"
    return {name=name, steam=steamID, rockstar=rockstar, discord=discordTag}
end

local function sendToDiscord(title, message, color)
    local embed = {
        {
            ["color"] = color or 3447003,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = { ["text"] = "Whitelist" }
        }
    }
    PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({embeds=embed}), { ['Content-Type']='application/json' })
end

-- commands
RegisterCommand("einreise", function(source, args)
    if not isAdmin(source) then
        TriggerClientEvent('vorp:TipRight', source, "You are not a admin")
        return
    end

    local targetId = tonumber(args[1])
    local cityKey = args[2] and string.lower(args[2])
    if not targetId or not GetPlayerName(targetId) then return end
    if not cityKey or not cities[cityKey] then
        TriggerClientEvent('vorp:TipRight', source, "Invalid city code")
        return
    end

    teleportPlayer(targetId, cities[cityKey].coords)
    TriggerClientEvent('vorp:TipRight', targetId, "Du bist in "..cities[cityKey].name.." angekommen")
    TriggerClientEvent('vorp:TipRight', source, "Spieler "..targetId.." wurde nach "..cities[cityKey].name.." teleportiert")

    -- Discord Log
    local admin = getPlayerIdentifiers(source)
    local target = getPlayerIdentifiers(targetId)
    local msg = "**🐺 Admin:** "..admin.name.." ("..admin.discord..")\n**👥 Spieler:** "..target.name.." ("..target.discord..")\n**✨ Stadt:** "..cities[cityKey].name.."\n**🆔 SteamID:** "..target.steam.."\n**🎮 Rockstar License:** "..target.rockstar
    sendToDiscord("Einreise Befehl", msg, 3066993)
end)

RegisterCommand("rein", function(source, args)
    if not isAdmin(source) then
        TriggerClientEvent('vorp:TipRight', source, "Du bist kein Admin")
        return
    end
    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then return end
    teleportPlayer(targetId, einreiseCoords)
    TriggerClientEvent('vorp:TipRight', targetId, "Du bist derzeit in der Einreisezone")
    TriggerClientEvent('vorp:TipRight', source, "Spieler "..targetId.." wurde in die Einreise teleportiert")

    local admin = getPlayerIdentifiers(source)
    local target = getPlayerIdentifiers(targetId)
    local msg = "**Admin:** "..admin.name.." ("..admin.discord..")\n**Spieler:** "..target.name.." ("..target.discord..")\n**SteamID:** "..target.steam.."\n**Rockstar License:** "..target.rockstar
    sendToDiscord("Einreisezone Betreten", msg, 3447003)
end)

RegisterCommand("raus", function(source, args)
    if not isAdmin(source) then
        TriggerClientEvent('vorp:TipRight', source, "Du bist kein Admin")
        return
    end
    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then return end
    teleportPlayer(targetId, ausgangCoords)
    TriggerClientEvent('vorp:TipRight', targetId, "Du wurdest aus der Einreisezone heraus teleportiert")
    TriggerClientEvent('vorp:TipRight', source, "Spieler "..targetId.." wurde raus teleportiert")

    local admin = getPlayerIdentifiers(source)
    local target = getPlayerIdentifiers(targetId)
    local msg = "**Admin:** "..admin.name.." ("..admin.discord..")\n**Spieler:** "..target.name.." ("..target.discord..")\n**SteamID:** "..target.steam.."\n**Rockstar License:** "..target.rockstar
    sendToDiscord("Einreisezone Verlassen", msg, 15158332)
end)

-- NPC
RegisterNetEvent("einreise:requestAdmin")
AddEventHandler("einreise:requestAdmin", function()
    local source = source
    for _, playerId in ipairs(GetPlayers()) do
        if isAdmin(playerId) then
            TriggerClientEvent('vorp:TipRight', playerId, "Ein neuer Spieler ist in der Einreisezone! Spieler-ID: "..source)

            local admin = getPlayerIdentifiers(playerId)
            local target = getPlayerIdentifiers(source)
            local msg = "**Admin:** "..admin.name.." ("..admin.discord..")\n**Spieler:** "..target.name.." ("..target.discord..")\n**SteamID:** "..target.steam.."\n**Rockstar License:** "..target.rockstar.."\nSpieler ruft Admin über NPC."
            sendToDiscord("Einreise NPC Aufruf", msg, 16776960)
        end
    end
end)
