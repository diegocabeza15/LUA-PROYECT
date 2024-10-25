-- Manejador del evento de spawn del jugador
AddEventHandler('playerSpawned', function()
    local playerPed = PlayerPedId()
    
    -- Configurar spawn en una ubicación específica
    local spawnCoords = vector3(-1767.9266, 445.3730, 127.2791, 106.2196) -- Cambia estas coordenadas según lo necesites
    SetEntityCoords(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)
end)

-- Permitir fuego amigo
Citizen.CreateThread(function()
    while true do
        Wait(0)
        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(PlayerPedId(), true, false)
    end
end)

-- Permitir el uso de armas desde vehículos
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            SetVehicleModKit(vehicle, 0)
            ToggleVehicleMod(vehicle, 10, true)
        end
    end
end)


--