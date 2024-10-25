-- client.lua
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Verificar si el jugador está siendo observado por cámaras
        local isObservedByCamera = IsPlayerBeingWatched(playerPed)
        
        if isObservedByCamera then
            -- Mostrar mensaje cuando la cámara detecta al jugador
            ShowNotification("La cámara te está observando")
        end
        
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
    local cameraModels = {
        "prop_cctv_cam_01a",
        "prop_cctv_cam_01b",
        "prop_cctv_cam_02a",
        "prop_cctv_cam_03a",
        "prop_cctv_cam_04a",
        "prop_cctv_cam_04b",
        "prop_v_cam_01",
        "prop_v_cam_02",
        "prop_v_cam_03"
    }
    
    local playerCoords = GetEntityCoords(ped)
    
    for _, model in ipairs(cameraModels) do
        local cameras = GetGamePool('CObject')
        for _, camera in ipairs(cameras) do
            if GetEntityModel(camera) == GetHashKey(model) then
                local cameraCoords = GetEntityCoords(camera)
                local distance = #(playerCoords - cameraCoords)
                
                if distance <= 20.0 and HasEntityClearLosToEntity(camera, ped, 17) then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Función para mostrar notificación
function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end
