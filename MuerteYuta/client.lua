-- client.lua
-- Configuración
local Config = {
    cooldownDuration = 60000, -- 60 segundos de cooldown
    maxWantedLevel = 5,
    cameraDetectionRadius = 20.0,
    speedLimit = 120, -- km/h
    copClearRadius = 1000.0,
    cameraModels = {
        "prop_cctv_cam_01a", "prop_cctv_cam_01b", "prop_cctv_cam_02a",
        "prop_cctv_cam_03a", "prop_cctv_cam_04a", "prop_cctv_cam_04b",
        "prop_v_cam_01", "prop_v_cam_02", "prop_v_cam_03"
    },
    notificationDuration = 5000, -- Duración de la notificación en ms
}

-- Funciones auxiliares
local function IsPlayerBeingWatched(ped)
    local playerCoords = GetEntityCoords(ped)
    for _, model in ipairs(Config.cameraModels) do
        local camera = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, Config.cameraDetectionRadius, GetHashKey(model), false, false, false)
        if DoesEntityExist(camera) and HasEntityClearLosToEntity(camera, ped, 17) then
            return true
        end
    end
    return false
end

local function ShowAdvancedNotification(title, subtitle, message, icon, flash, type)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    SetNotificationMessage(icon, icon, flash, type, title, subtitle)
    DrawNotification(false, true)
end

local function IsPlayerPerformingSuspiciousActivity(playerPed)
    local isShooting = IsPedShooting(playerPed)
    local isMeleeCombat = IsPedInMeleeCombat(playerPed)
    local isAiming = IsPlayerFreeAiming(PlayerId())
    local isInVehicle = IsPedInAnyVehicle(playerPed, false)
    local isSpeedingInVehicle = false
    local isShootingInArea = false

    if isInVehicle then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleSpeed = GetEntitySpeed(vehicle) * 3.6 -- Convertir a km/h
        isSpeedingInVehicle = vehicleSpeed > Config.speedLimit
    end

    local playerCoords = GetEntityCoords(playerPed)
    isShootingInArea = IsPedShootingInArea(playerPed, playerCoords.x - 5.0, playerCoords.y - 5.0, playerCoords.z - 5.0, playerCoords.x + 5.0, playerCoords.y + 5.0, playerCoords.z + 5.0, false, true)

    return isShooting or isMeleeCombat or isAiming or isSpeedingInVehicle or isShootingInArea
end

-- Variables globales para la notificación
local lastNotificationTime = 0
local isNotificationActive = false

-- Hilo principal
Citizen.CreateThread(function()
    local cooldownTimer = 0

    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local isObservedByCamera = IsPlayerBeingWatched(playerPed)
        local suspiciousActivity = IsPlayerPerformingSuspiciousActivity(playerPed)

        -- Gestionar notificación de cámara
        local currentTime = GetGameTimer()
        if currentTime - lastNotificationTime > Config.notificationDuration then
            isNotificationActive = false
        end

        if not isNotificationActive then
            if isObservedByCamera then
                ShowAdvancedNotification(
                    "Sistema de Vigilancia",
                    "Alerta",
                    "La cámara te está observando",
                    "CHAR_CALL911", -- Icono de emergencia
                    true, -- Flash
                    1 -- Tipo de notificación (1 = alerta)
                )
            else
                ShowAdvancedNotification(
                    "Sistema de Vigilancia",
                    "Información",
                    "No hay cámaras observándote",
                    "CHAR_SOCIAL_CLUB", -- Icono genérico
                    false, -- Sin flash
                    4 -- Tipo de notificación (4 = información)
                )
            end
            lastNotificationTime = currentTime
            isNotificationActive = true
        end

        -- Gestionar nivel de búsqueda
        if isObservedByCamera and suspiciousActivity then
            SetMaxWantedLevel(Config.maxWantedLevel)
            cooldownTimer = GetGameTimer() + Config.cooldownDuration
        elseif GetGameTimer() > cooldownTimer then
            SetMaxWantedLevel(0)
        end

        -- Limpiar área de policías si no hay nivel de búsqueda
        if GetPlayerWantedLevel(PlayerId()) == 0 then
            local playerCoords = GetEntityCoords(playerPed)
            ClearAreaOfCops(playerCoords.x, playerCoords.y, playerCoords.z, Config.copClearRadius)
        end
    end
end)
