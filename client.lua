local einreiseNPC = {
    coords = vector3(1284.0676, -6862.7515, 43.3185),
    heading = 90.0,
    model = "s_m_m_strfreight_01"
}

-- NPC spawn
Citizen.CreateThread(function()
    RequestModel(GetHashKey(einreiseNPC.model))
    while not HasModelLoaded(GetHashKey(einreiseNPC.model)) do
        Wait(100)
    end

    local ped = CreatePed(einreiseNPC.model, einreiseNPC.coords.x, einreiseNPC.coords.y, einreiseNPC.coords.z, einreiseNPC.heading, false, true, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end)

-- NPC Interaction with E (0xCEFD9220)
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - einreiseNPC.coords)

        if dist < 2.0 then
            TriggerEvent('vorp:TipBottom', "[E] Admin Rufen")
            if IsControlJustReleased(0, 0xCEFD9220) then
                TriggerServerEvent("einreise:requestAdmin")
                TriggerEvent('vorp:TipBottom', "Admin wurde informiert, bitte warte in der Einreisezone")
            end
        end
    end
end)
