local missionNPC = { x= -1812.0613, y= 453.500, z= 127.300, heading = 280.400, model = "cs_martinmadrazo" }
local targetVehicle = { x= -2294.8767, y= 375.0648, z= 174.7636, model="mule4"} 
local deliveryPoint = { x= -1795.4498, y= 457.4403, z= 128.3080 }

local missionStarted = false
local vehicleStolen = false
local targetVehicleBlip
local deliveryPointBlip

Citizen.CreateThread(function()
    RequestModel(GetHashKey(missionNPC.model))
    while not HasModelLoaded(GetHashKey(missionNPC.model)) do
        Wait(1)
    end

    local npc = CreatePed(4, GetHashKey(missionNPC.model), missionNPC.x, missionNPC.y, missionNPC.z, missionNPC.heading, false, true)
    SetEntityAsMissionEntity(npc, true, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    while true do
        Citizen.Wait(0)
        DrawMarker(1, missionNPC.x, missionNPC.y, missionNPC.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 255, 0, 0, 200, false, true, 2, nil, nil, false)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = GetDistanceBetweenCoords(playerCoords, missionNPC.x, missionNPC.y, missionNPC.z, true)
        if distance < 2.0 then
            DrawText3D(missionNPC.x, missionNPC.y, missionNPC.z + 1.0, "Presiona E para iniciar la misión")
            if IsControlJustReleased(0, 38) and not missionStarted then -- E key
                StartMission()
            end
        end

        if missionStarted and not vehicleStolen then
            if not DoesEntityExist(vehicle) then
                vehicle, vehicleBlip = CreateVehicleAndBlip(targetVehicle)
            else
                local vehicleDist = GetDistanceBetweenCoords(playerCoords, targetVehicle.x, targetVehicle.y, targetVehicle.z, true)
                DrawMarker(1, targetVehicle.x, targetVehicle.y, targetVehicle.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 255, 0, 200, false, true, 2, nil, nil, false)
                
                -- Verificar si el jugador está cerca del vehículo
                if vehicleDist < 2.0 then
                    DrawText3D(targetVehicle.x, targetVehicle.y, targetVehicle.z + 1.0, "Robando el coche...")
                    -- Entrar al vehículo automáticamente
                    TaskEnterVehicle(PlayerPedId(), vehicle, -1, -1, 1.0, 1, 0)
                end
            end

            if IsPedInVehicle(PlayerPedId(), vehicle, false) then
                vehicleStolen = true
                RemoveBlip(vehicleBlip)
                ShowNotification("¡Has robado el vehículo!")
                ShowDeliveryPoint()
            end
        end

        if vehicleStolen then
            DrawMarker(1, deliveryPoint.x, deliveryPoint.y, deliveryPoint.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 0, 255, 200, false, true, 2, nil, nil, false)
            local deliveryDist = GetDistanceBetweenCoords(playerCoords, deliveryPoint.x, deliveryPoint.y, deliveryPoint.z, true)
            if deliveryDist < 2.0 then
                DrawText3D(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z + 1.0, "Entrega el coche")
                if IsControlJustReleased(0, 38) then -- E key
                    CompleteMission()
                end
            end
        end
    end
end)

local enemies = {}
local enemyModels = {
  "u_m_y_zombie_01",
		"a_f_m_bevhills_01",
		"a_f_m_downtown_01",
		"a_f_m_ktown_01",
		"a_f_m_skidrow_01",
		"a_f_m_trampbeac_01",
		"a_f_y_hiker_01",
		"a_f_y_rurmeth_01",
		"a_m_m_afriamer_01",
		"a_m_m_bevhills_01",
		"a_m_m_eastsa_01",
		"a_m_m_farmer_01",
		"a_m_m_hasjew_01",
		"a_m_m_hillbilly_01",
		"a_m_m_mexcntry_01",
		"a_m_m_rurmeth_01",
		"a_m_m_tramp_01",
		"a_m_m_trampbeac_01",
		"a_m_o_acult_02",
		"a_m_o_salton_01",
		"a_m_y_methhead_01",
		"g_m_m_chemwork_01",
		"g_m_y_salvagoon_01",
		"s_f_y_cop_01",
		"s_m_y_cop_01",
		"u_m_o_filmnoir",
		"u_m_y_corpse_01",
		"u_f_m_corpse_01",
		"u_f_y_corpse_01",
		"u_f_y_corpse_02"
}

function StartMission()
    if missionStarted then return end
    missionStarted = true
    ShowNotification("¡La misión ha comenzado! Ve a robar el coche.")
    vehicle, targetVehicleBlip = CreateVehicleAndBlip(targetVehicle)

    -- Generar enemigos iniciales
    GenerateEnemies()

    -- Iniciar un temporizador para generar enemigos adicionales
    Citizen.CreateThread(function()
        while missionStarted do
            Wait(30000) -- Esperar 30 segundos antes de generar un nuevo enemigo
            GenerateEnemies()
        end
    end)
end

function GenerateEnemies()
    local playerCoords = GetEntityCoords(PlayerPedId()) -- Obtener las coordenadas del jugador
    local newEnemyPosition = {
        x = playerCoords.x + math.random(-5, 5), -- Generar una nueva posición en un radio de 5 metros
        y = playerCoords.y + math.random(-5, 5),
        z = playerCoords.z -- Mantener la misma altura
    }
    local enemyModel = enemyModels[math.random(#enemyModels)]

    RequestModel(GetHashKey(enemyModel))
    while not HasModelLoaded(GetHashKey(enemyModel)) do
        Wait(1)
    end

    local ped = CreatePed(4, GetHashKey(enemyModel), newEnemyPosition.x, newEnemyPosition.y, newEnemyPosition.z, 0.0, true, true)
    SetEntityAsMissionEntity(ped, true, true)
    TaskCombatPed(ped, PlayerPedId(), 0, 16) -- Hacer que el enemigo ataque al jugador
    table.insert(enemies, ped) -- Agregar el nuevo enemigo a la lista
end

function ShowDeliveryPoint()
    deliveryPointBlip = AddBlipForCoord(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z)
    SetBlipSprite(deliveryPointBlip, 1)
    SetBlipColour(deliveryPointBlip, 3)
    SetBlipAsShortRange(deliveryPointBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Punto de entrega")
    EndTextCommandSetBlipName(deliveryPointBlip)
end

function CompleteMission()
    missionStarted = false
    vehicleStolen = false
    RemoveBlip(deliveryPointBlip)
    ShowNotification("¡Misión completada! Gracias por tu ayuda.")

    -- Eliminar enemigos al completar la misión
    for _, enemy in ipairs(enemies) do
        if DoesEntityExist(enemy) then
            DeleteEntity(enemy)
        end
    end
    enemies = {} -- Limpiar la lista de enemigos
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
    Citizen.SetTimeout(5000, function() -- Temporizador de 5 segundos
        RemoveNotification(GetCurrentNotification()) -- Eliminar la notificación actual
    end)
end

function CreateVehicleAndBlip(vehicleData)
    RequestModel(GetHashKey(vehicleData.model))
    while not HasModelLoaded(GetHashKey(vehicleData.model)) do
        Wait(1)
    end
    local vehicle = CreateVehicle(GetHashKey(vehicleData.model), vehicleData.x, vehicleData.y, vehicleData.z, 0.0, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local vehicleBlip = AddBlipForEntity(vehicle)
    SetBlipSprite(vehicleBlip, 1)
    SetBlipColour(vehicleBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Objetivo: Coche")
    EndTextCommandSetBlipName(vehicleBlip)
    return vehicle, vehicleBlip
end
