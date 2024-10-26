-- server.lua

local playerMissions = {}  -- Tabla para almacenar el estado de la misión de cada jugador

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    print('Misión de checkpoints iniciada: ' .. resourceName)
end)

-- Función para iniciar la misión para un jugador específico
function StartPlayerMission(playerId)
    -- Validar que playerId es un número y no está vacío
    if type(playerId) ~= "number" or playerId <= 0 then
        print("ID de jugador inválido: " .. tostring(playerId))
        return
    end

    playerMissions[playerId] = { missionStarted = true, vehicleStolen = false }  -- Cambiar a true al iniciar la misión
    print("Misión iniciada para el jugador: " .. playerId)  -- Mensaje de confirmación
    -- Aquí puedes agregar más lógica para iniciar la misión
end

-- Función para completar la misión de un jugador específico
function CompletePlayerMission(playerId)
    -- Validar que playerId es un número y no está vacío
    if type(playerId) ~= "number" or playerId <= 0 then
        print("ID de jugador inválido: " .. tostring(playerId))
        return
    end

    if playerMissions[playerId] then
        playerMissions[playerId] = nil  -- Eliminar el estado de la misión
        print("Misión completada para el jugador: " .. playerId)  -- Mensaje de confirmación
        -- Aquí puedes agregar más lógica para completar la misión
    else
        print("No hay misión activa para el jugador: " .. playerId)  -- Mensaje si no hay misión
    end
end
