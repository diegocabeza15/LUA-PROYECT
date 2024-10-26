-- Variables
local NPC_MODEL = "s_m_m_chemsec_01"
local NPC_COORDS = vector3(-1806.6305, 450.4791, 127.5119)
local NPC_HEADING = 356.400
local INTERACTION_DISTANCE = 2.0
local WEAPONS = {
    "WEAPON_PISTOL",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_SMG",
    "WEAPON_MICROSMG",
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_CARBINERIFLE",
}

-- Función para crear el NPC
local function CreateInmortalNPC()
    local npcHash = GetHashKey(NPC_MODEL)
    RequestModel(npcHash)
    while not HasModelLoaded(npcHash) do 
        Citizen.Wait(1) 
    end
    
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
    local weaponsGiven = 0 -- Contador de armas dadas

    -- Dar armas del array o munición si ya tiene el arma
    for _, weapon in ipairs(WEAPONS) do
        local weaponHash = GetHashKey(weapon)
        if HasPedGotWeapon(playerPed, weaponHash, false) then
            local maxAmmo = GetMaxAmmoInClip(playerPed, weaponHash, true)
            AddAmmoToPed(playerPed, weaponHash, maxAmmo * 10) -- Otorgar munición
        else
            GiveWeaponToPed(playerPed, weaponHash, 500, false, true)
            weaponsGiven = weaponsGiven + 1 -- Incrementar el contador
        end
    end

    -- Asegurarse de que se den al menos 8 armas si el jugador no tiene armas o tiene espacio
    while weaponsGiven < 8 do
        local additionalWeapon = GetHashKey("WEAPON_PISTOL") -- Cambia esto por cualquier arma deseada
        if (not HasPedGotWeapon(playerPed, additionalWeapon, false) or GetNumberOfPedWeapons(playerPed) < 10) then
            GiveWeaponToPed(playerPed, additionalWeapon, 500, false, true)
            weaponsGiven = weaponsGiven + 1
        end
    end

    TriggerEvent('chat:addMessage', { args = { "NPC", "¡Equípate como un verdadero guerrero!" } })
    TriggerServerEvent('npc:giveAmmo')
end)

-- Evento para dar munición
RegisterNetEvent('npc:giveAmmo')
AddEventHandler('npc:giveAmmo', function()
    local playerPed = PlayerPedId()
    for _, weapon in ipairs(WEAPONS) do
        local weaponHash = GetHashKey(weapon)
        local maxAmmo = GetMaxAmmoInClip(playerPed, weaponHash, true)
        AddAmmoToPed(playerPed, weaponHash, maxAmmo * 10)
    end
end)

-- Función para dibujar texto 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
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
end

-- Crear el blip
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(-1806.6305, 450.4791, 128.5119)

    -- Configurar el blip
    SetBlipSprite(blip, 567) -- Ícono del blip
    SetBlipDisplay(blip, 4) -- Tipo de display
    SetBlipScale(blip, 1.0) -- Escala del blip
    SetBlipColour(blip, 2) -- Color del blip (2 = verde)
    SetBlipAsShortRange(blip, true) -- Mostrar sólo cuando está cerca

    -- Añadir un nombre al blip
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mi Ubicación Personalizada")
    EndTextCommandSetBlipName(blip)
end)