local missionNPC = { x= -1812.0613, y= 453.500, z= 127.300, heading = 280.400, model = "cs_martinmadrazo" }
local targetVehicle = { x= -2294.8767, y= 375.0648, z= 174.7636, model="manchez3"} 
local deliveryPoint = { x= -1795.4498, y= 457.4403, z= 128.3080 }

local missionStarted, vehicleStolen = false, false
local vehicle, vehicleBlip, deliveryPointBlip, npc
local enemies = {}
local enemyModels = { "g_m_y_mexgoon_01", "g_m_y_mexgoon_02", "g_m_y_mexgoon_03" }
local enemyWeapons = { "WEAPON_PISTOL", "WEAPON_MICROSMG" }
local enemyGroup = GetHashKey("EnemyGroup")
AddRelationshipGroup("EnemyGroup")


-- Crear NPC inmortal y quieto
Citizen.CreateThread(function()
    RequestModel(GetHashKey(missionNPC.model))
    while not HasModelLoaded(GetHashKey(missionNPC.model)) do Wait(1) end

    npc = CreatePed(4, GetHashKey(missionNPC.model), missionNPC.x, missionNPC.y, missionNPC.z, missionNPC.heading, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end)

-- Iniciar misión al interactuar con NPC
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        if not missionStarted and #(playerCoords - vector3(missionNPC.x, missionNPC.y, missionNPC.z)) < 2.0 then
            ShowHelpText("Presiona ~INPUT_CONTEXT~ para iniciar la misión")
            if IsControlJustReleased(0, 51) then StartMission() end
        end
    end
end)

-- Función para iniciar la misión
function StartMission()
    missionStarted = true
    ShowNotification("¡La misión ha comenzado! Ve a robar el coche.")
    vehicle, vehicleBlip = CreateVehicleAndBlip(targetVehicle)
    GenerateEnemies()  -- Generar enemigos iniciales
end

-- Crear vehículo objetivo y blip
function CreateVehicleAndBlip(vehicleData)
    RequestModel(GetHashKey(vehicleData.model))
    while not HasModelLoaded(GetHashKey(vehicleData.model)) do Wait(1) end

    local veh = CreateVehicle(GetHashKey(vehicleData.model), vehicleData.x, vehicleData.y, vehicleData.z, 0.0, true, false)
    SetEntityAsMissionEntity(veh, true, true)

    local vehBlip = AddBlipForEntity(veh)
    SetBlipSprite(vehBlip, 1)
    SetBlipColour(vehBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Objetivo: Coche")
    EndTextCommandSetBlipName(vehBlip)

    return veh, vehBlip
end

function GenerateEnemies()
    local numEnemies = math.random(4, 12) -- Genera entre 4 y 12 enemigos
    for i = 1, numEnemies do
        local enemyPos = {
            x = targetVehicle.x + math.random(-15, 15),
            y = targetVehicle.y + math.random(-15, 15),
            z = targetVehicle.z
        }
        local model = GetHashKey(enemyModels[math.random(#enemyModels)])
        local weapon = GetHashKey(enemyWeapons[math.random(#enemyWeapons)])

        RequestModel(model)
        while not HasModelLoaded(model) do Wait(1) end

        local enemy = CreatePed(4, model, enemyPos.x, enemyPos.y, enemyPos.z, 0.0, true, true)
        SetPedArmour(enemy, 100)
        SetEntityHealth(enemy, 100)
        GiveWeaponToPed(enemy, weapon, 200, false, true)
        
        -- Configurar relación de enemigos
        SetPedRelationshipGroupHash(enemy, enemyGroup)
        TaskGuardCurrentPosition(enemy, 15.0, 15.0, 1)  -- Guardar posición hasta que detecten al jugador
        table.insert(enemies, enemy)
    end

    -- Ajustar relaciones para que no se ataquen entre sí y sean hostiles solo con el jugador
    SetRelationshipBetweenGroups(1, enemyGroup, enemyGroup)  -- No se atacan entre ellos
    SetRelationshipBetweenGroups(5, enemyGroup, GetHashKey("PLAYER"))  -- Hostiles con el jugador
end

-- Detectar jugador cercano y reaccionar
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)  -- Revisa cada segundo
        if missionStarted then
            for _, enemy in ipairs(enemies) do
                if DoesEntityExist(enemy) and not IsPedDeadOrDying(enemy, true) then
                    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(enemy)) < 15.0 then
                        TaskCombatPed(enemy, PlayerPedId(), 0, 16)
                    end
                end
            end
        end
    end
end)

-- Monitorear progreso de la misión
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if missionStarted and DoesEntityExist(vehicle) then
            local playerCoords = GetEntityCoords(PlayerPedId())
            if not vehicleStolen and #(playerCoords - vector3(targetVehicle.x, targetVehicle.y, targetVehicle.z)) < 3.0 then
                ShowHelpText("Presiona ~INPUT_CONTEXT~ para robar el coche")
                if IsControlJustReleased(0, 38) then
                    TaskEnterVehicle(PlayerPedId(), vehicle, -1, -1, 1.0, 1, 0)
                    vehicleStolen = true
                    RemoveBlip(vehicleBlip)
                    ShowNotification("¡Has robado el vehículo! Llévalo al punto de entrega.")
                    ShowDeliveryCheckpoint()  -- Mostrar el punto de entrega en el mundo
                end
            end

            if vehicleStolen and IsPedInVehicle(PlayerPedId(), vehicle, false) then
                if #(playerCoords - vector3(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z)) < 3.0 then
                    ShowHelpText("Presiona ~INPUT_CONTEXT~ para entregar el vehículo")
                    if IsControlJustReleased(0, 38) then CompleteMission() end
                end
            end
        end
    end
end)

-- Completar misión
function CompleteMission()
    missionStarted, vehicleStolen = false, false
    RemoveBlip(deliveryPointBlip)
    DeleteEntity(vehicle)
    ShowNotification("¡Misión completada! Gracias por tu ayuda.")

    -- Eliminar enemigos
    for _, enemy in ipairs(enemies) do
        if DoesEntityExist(enemy) then DeleteEntity(enemy) end
    end
    enemies = {}
end

-- Mostrar checkpoint visible
function ShowDeliveryCheckpoint()
    deliveryPointBlip = AddBlipForCoord(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z)
    SetBlipSprite(deliveryPointBlip, 1)
    SetBlipColour(deliveryPointBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Punto de entrega")
    EndTextCommandSetBlipName(deliveryPointBlip)
    
    Citizen.CreateThread(function()
        while vehicleStolen do
            Citizen.Wait(0)
            DrawMarker(1, deliveryPoint.x, deliveryPoint.y, deliveryPoint.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 255, 255, 200, false, true, 2, nil, nil, false)  -- Se agregó un argumento adicional
        end
    end)
end

-- Mostrar texto en pantalla
function ShowHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, true)
end
