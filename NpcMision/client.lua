local missionNPC = { x = -1806.6305, y = 450.4791, z = 127.5119, heading = 356.400, model = "s_m_m_chemsec_01" }
local targetVehicle = { x = -50.0, y = -1100.0, z = 26.4, model = "adder" }
local deliveryPoint = { x = -1600.0, y = -500.0, z = 34.4 }
local enemies = {}
local missionStarted = false
local vehicleStolen = false
local vehicleBlip
local deliveryBlip
local vehicle

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
            local vehicleDist = GetDistanceBetweenCoords(playerCoords, targetVehicle.x, targetVehicle.y, targetVehicle.z, true)
            if vehicleDist < 50.0 then
                if not DoesEntityExist(vehicle) then
                    RequestModel(GetHashKey(targetVehicle.model))
                    while not HasModelLoaded(GetHashKey(targetVehicle.model)) do
                        Wait(1)
                    end

                    vehicle = CreateVehicle(GetHashKey(targetVehicle.model), targetVehicle.x, targetVehicle.y, targetVehicle.z, 0.0, true, false)
                    SetEntityAsMissionEntity(vehicle, true, true)
                    vehicleBlip = AddBlipForEntity(vehicle)
                    SetBlipSprite(vehicleBlip, 1)
                    SetBlipColour(vehicleBlip, 3)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Objetivo: Coche")
                    EndTextCommandSetBlipName(vehicleBlip)
                end
            end

            local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if playerVehicle == vehicle then
                vehicleStolen = true
                RemoveBlip(vehicleBlip)
                TriggerEvent('chat:addMessage', { args = { "Misión", "¡Has robado el vehículo!" } })
                ShowDeliveryPoint()
            end
        end

        if vehicleStolen then
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
    missionStarted = true
    TriggerEvent('chat:addMessage', { args = { "Misión", "¡La misión ha comenzado! Ve a robar el coche." } })
    CreateEnemies()
end

function CompleteMission()
    missionStarted = false
    vehicleStolen = false
    TriggerEvent('chat:addMessage', { args = { "Misión", "¡Misión completada! Gracias por tu ayuda." } })
    RemoveBlip(deliveryBlip)
    -- Eliminar el coche robado
    SetEntityAsNoLongerNeeded(vehicle)
    DeleteEntity(vehicle)
end

function ShowDeliveryPoint()
    deliveryBlip = AddBlipForCoord(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipColour(deliveryBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Punto de Entrega")
    EndTextCommandSetBlipName(deliveryBlip)
end

function CreateEnemies()
    for i = 1, 5 do
        local enemy = CreatePed(4, GetHashKey("g_m_y_ballaorig_01"), targetVehicle.x + math.random(-5, 5), targetVehicle.y + math.random(-5, 5), targetVehicle.z, 0.0, true, true)
        GiveWeaponToPed(enemy, GetHashKey("WEAPON_PISTOL"), 250, false, true)
        SetPedCombatAttributes(enemy, 46, true) -- Aggressive
        TaskCombatPed(enemy, PlayerPedId(), 0, 16)
        table.insert(enemies, enemy)
    end
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
