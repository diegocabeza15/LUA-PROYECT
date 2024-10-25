-- Constantes
local NPC_MODEL = "s_m_m_chemsec_01"
local NPC_COORDS = vector3(-1806.6305, 450.4791, 127.5119)
local NPC_HEADING = 356.400
local INTERACTION_DISTANCE = 2.0
local WEAPONS = {
    "WEAPON_PISTOLXM3", "WEAPON_COMBATSHOTGUN", "WEAPON_COMBATPISTOL",
    "WEAPON_SMG", "WEAPON_NIGHTSTICK", "WEAPON_CARBINERIFLE"
}

-- Función para crear el NPC
local function CreateInmortalNPC()
    local npcHash = GetHashKey(NPC_MODEL)
    RequestModel(npcHash)
    while not HasModelLoaded(npcHash) do Wait(1) end
    
    local npc = CreatePed(4, npcHash, NPC_COORDS, NPC_HEADING, false, true)
    SetEntityAsMissionEntity(npc, true, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    return npc
end

-- Función principal
Citizen.CreateThread(function()
    local npc = CreateInmortalNPC()
    
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - NPC_COORDS)
        
        if distance < INTERACTION_DISTANCE then
            DrawText3D(NPC_COORDS.x, NPC_COORDS.y, NPC_COORDS.z + 1.0, "Presiona E para interactuar")
            
            if IsControlJustReleased(0, 38) then -- Tecla E
                TriggerEvent('npc:interact')
            end
        else
            Citizen.Wait(500) -- Espera más tiempo si el jugador está lejos
        end
    end
end)

-- Evento de interacción
RegisterNetEvent('npc:interact')
AddEventHandler('npc:interact', function()
    local playerPed = PlayerPedId()
    
    for _, weapon in ipairs(WEAPONS) do
        GiveWeaponToPed(playerPed, GetHashKey(weapon), 500, false, true)
    end
    
    TriggerEvent('chat:addMessage', { args = { "NPC", "¡Equípate como un verdadero guerrero!" } })
    TriggerServerEvent('npc:giveAmmo')
end)

-- Evento para dar munición
RegisterNetEvent('npc:giveAmmo')
AddEventHandler('npc:giveAmmo', function()
    local playerPed = PlayerPedId()
    for _, weapon in ipairs(WEAPONS) do
        SetPedAmmo(playerPed, GetHashKey(weapon), 9999999)
    end
end)

-- Función para dibujar texto 3D (sin cambios)
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
