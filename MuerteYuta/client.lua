-- client.lua
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Verificar si el jugador está siendo observado por cámaras
        local isObservedByCamera = IsPlayerBeingWatched(playerPed)
        
        -- Verificar si el jugador está disparando
        local isShooting = IsPedShooting(playerPed)
        
        if isObservedByCamera and isShooting then
            -- Reactivar el nivel de búsqueda
            SetMaxWantedLevel(5) -- Puedes ajustar este valor según tus necesidades
        else
            -- Mantener el nivel de búsqueda en 0 si no se cumplen las condiciones
            SetMaxWantedLevel(0)
        end
        
        -- Limpiar el área de policías solo si el nivel de búsqueda es 0
        if GetPlayerWantedLevel(PlayerId()) == 0 then
            ClearAreaOfCops(playerCoords.x, playerCoords.y, playerCoords.z, 1000.0)
        end
    end
end)

-- Función para verificar si el jugador está siendo observado por cámaras
function IsPlayerBeingWatched(ped)
    -- Implementa aquí la lógica para detectar si el jugador está en el campo de visión de una cámara
    -- Esta es una implementación de ejemplo, deberás adaptarla según tu sistema de cámaras
    local cameraObjects = GetGamePool('CObject')
    for _, camera in ipairs(cameraObjects) do
        if GetEntityModel(camera) == GetHashKey('prop_cctv_cam_01a') then -- Ajusta este hash según el modelo de cámara que uses
            if HasEntityClearLosToEntity(camera, ped, 17) then
                return true
            end
        end
    end
    return false
end
