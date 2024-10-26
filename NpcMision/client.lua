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
            DrawMarker(1, targetVehicle.x, targetVehicle.y, targetVehicle.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 255, 0, 200, false, true, 2, nil, nil, false)
            local vehicleDist = GetDistanceBetweenCoords(playerCoords, targetVehicle.x, targetVehicle.y, targetVehicle.z, true)
            if vehicleDist < 2.0 then
                DrawText3D(targetVehicle.x, targetVehicle.y, targetVehicle.z + 1.0, "Presiona E para robar el coche")
                if IsPedInVehicle(PlayerPedId(), vehicle, false) then -- Verifica si el jugador está en el vehículo
                    vehicleStolen = true
                    ShowNotification("¡Has robado el vehículo!") -- Mensaje al robar el vehículo
                    RemoveBlip(targetVehicleBlip) -- Asegúrate de que esta línea se ejecute
                    targetVehicleBlip = nil -- Opcional: limpiar la referencia del blip
                    ShowDeliveryPoint()
                end
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

function StartMission()
    if missionStarted then return end -- Evitar reiniciar la misión si ya está en curso
    missionStarted = true
    ShowNotification("¡La misión ha comenzado! Ve a robar el coche.") -- Cambiado a notificación

    -- Añadir blip del vehículo objetivo
    RequestModel(GetHashKey(targetVehicle.model))
    while not HasModelLoaded(GetHashKey(targetVehicle.model)) do
        Wait(1)
    end

    local vehicle = CreateVehicle(GetHashKey(targetVehicle.model), targetVehicle.x, targetVehicle.y, targetVehicle.z, 0.0, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    targetVehicleBlip = AddBlipForEntity(vehicle)
    SetBlipSprite(targetVehicleBlip, 225)
    SetBlipColour(targetVehicleBlip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Vehículo objetivo")
    EndTextCommandSetBlipName(targetVehicleBlip)
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
    ShowNotification("¡Misión completada! Gracias por tu ayuda.") -- Cambiado a notificación
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
