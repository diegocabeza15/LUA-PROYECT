-- client.lua
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Verificar si el jugador está siendo observado por cámaras
        local isObservedByCamera = IsPlayerBeingWatched(playerPed)

        if isObservedByCamera then
            ShowNotification("La cámara te está observando")
        else
            ShowNotification("No hay cámaras observándote")
        end

        -- Verificar varias acciones del jugador
        local isShooting = IsPedShooting(playerPed)
        local isMeleeCombat = IsPedInMeleeCombat(playerPed)
        local isAiming = IsPlayerFreeAiming(PlayerId())
        local isInVehicle = IsPedInAnyVehicle(playerPed, false)
        local vehicleSpeed = 0

        if isInVehicle then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            vehicleSpeed = GetEntitySpeed(vehicle) * 3.6 -- Convertir a km/h
        end

        local isSpeedingInVehicle = isInVehicle and vehicleSpeed > 120
        local isShootingInArea = IsPedShootingInArea(playerPed, playerCoords.x - 5.0, playerCoords.y - 5.0, playerCoords.z - 5.0, playerCoords.x + 5.0, playerCoords.y + 5.0, playerCoords.z + 5.0, false, true)
        local shouldActivateWantedLevel = isShooting or isMeleeCombat or isAiming or isSpeedingInVehicle or isShootingInArea

        if isObservedByCamera and shouldActivateWantedLevel then
            SetMaxWantedLevel(5)
        else
            SetMaxWantedLevel(0)
        end

        if GetPlayerWantedLevel(PlayerId()) == 0 then
            ClearAreaOfCops(playerCoords.x, playerCoords.y, playerCoords.z, 1000.0)
        end
    end
end)

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
        local camera = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 20.0, GetHashKey(model), false, false, false)
        if DoesEntityExist(camera) then
            local cameraCoords = GetEntityCoords(camera)
            if #(playerCoords - cameraCoords) <= 20.0 and HasEntityClearLosToEntity(camera, ped, 17) then
                return true
            end
        end
    end
    return false
end

function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end
