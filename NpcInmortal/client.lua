-- client.lua
Citizen.CreateThread(function()
    local npcHash = GetHashKey("s_m_m_chemsec_01")
    RequestModel(npcHash)

    while not HasModelLoaded(npcHash) do
        Wait(1)
    end
    
    local npc = CreatePed(4, npcHash, -1806.6305, 450.4791, 127.5119, 356.400, false, true) -- Bajamos el NPC más
    SetEntityAsMissionEntity(npc, true, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local npcCoords = GetEntityCoords(npc)
        local distance = GetDistanceBetweenCoords(playerCoords, npcCoords, true)
        
        if distance < 2.0 then
            DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "Presiona E para interactuar")
            
            if IsControlJustReleased(0, 38) then -- Tecla E
                TriggerEvent('npc:interact')
            end
        end
    end
end)

RegisterNetEvent('npc:interact')
AddEventHandler('npc:interact', function()
    local playerPed = PlayerPedId()
    local weapons = {
        "WEAPON_PISTOLXM3",
        "WEAPON_COMBATSHOTGUN",
        "WEAPON_COMBATPISTOL",
        "WEAPON_SMG",
        "WEAPON_NIGHTSTICK",
        "WEAPON_CARBINERIFLE", 
    }
    
    for _, weapon in ipairs(weapons) do
        GiveWeaponToPed(playerPed, GetHashKey(weapon),500w, false, true)
    end
    
    TriggerEvent('chat:addMessage', { args = { "NPC", "¡Equípate como un verdadero guerrero!" } })
    TriggerServerEvent('npc:giveAmmo')
end)

RegisterNetEvent('npc:giveAmmo')
AddEventHandler('npc:giveAmmo', function()
    local playerPed = PlayerPedId()
    AddAmmoToPed(playerPed, GetHashKey("WEAPON_PISTOLXM3"), 1000)
    AddAmmoToPed(playerPed, GetHashKey("WEAPON_COMBATSHOTGUN"), 1000)
    AddAmmoToPed(playerPed, GetHashKey("WEAPON_COMBATPISTOL"), 1000)
    AddAmmoToPed(playerPed, GetHashKey("WEAPON_SMG"), 1000)
    AddAmmoToPed(playerPed, GetHashKey("WEAPON_NIGHTSTICK"), 1000)
    AddAmmoToPed(playerPed, GetHashKey("WEAPON_CARBINERIFLE"), 1000)
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 0, 112, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
end
