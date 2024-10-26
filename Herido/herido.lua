local isInjured = false
local injuryTimer = 0
local injuredPlayers = {}

-- Función para manejar el estado herido del jugador
function handleInjury()
    while true do
        Citizen.Wait(1000)
        if isInjured then
            injuryTimer = injuryTimer + 1

            -- Reducir salud gradualmente
            local playerPed = PlayerPedId()
            local currentHealth = GetEntityHealth(playerPed)
            SetEntityHealth(playerPed, currentHealth - 1)

            -- Si el jugador está herido durante 30 segundos, muere
            if injuryTimer >= 30 then
                TriggerEvent("chat:addMessage", { args = { "Estás gravemente herido y no puedes continuar." } })
                SetEntityHealth(playerPed, 0) -- Matar al jugador
                isInjured = false
                injuryTimer = 0
                break
            end
        end
    end
end

-- Comando para herir al jugador
RegisterCommand("herir", function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    if not isInjured then
        isInjured = true
        injuryTimer = 0
        injuredPlayers[PlayerId()] = true
        TriggerEvent("chat:addMessage", { args = { "Has sufrido una herida. Necesitas ayuda." } })
        handleInjury()
    else
        TriggerEvent("chat:addMessage", { args = { "Ya estás herido." } })
    end
end)

-- Comando para curar al jugador
RegisterCommand("curar", function(source, args, rawCommand)
    if isInjured then
        isInjured = false
        injuryTimer = 0
        local playerPed = PlayerPedId()
        local currentHealth = GetEntityHealth(playerPed)
        SetEntityHealth(playerPed, math.min(currentHealth + 20, 200)) -- Curar 20 puntos de salud
        TriggerEvent("chat:addMessage", { args = { "Has sido curado." } })
    else
        TriggerEvent("chat:addMessage", { args = { "No estás herido." } })
    end
end)

-- Función para comprobar si el jugador está herido
function isPlayerInjured()
    return isInjured
end

-- Agregar comando para comprobar el estado
RegisterCommand("estado", function()
    if isPlayerInjured() then
        TriggerEvent("chat:addMessage", { args = { "Estás herido." } })
    else
        TriggerEvent("chat:addMessage", { args = { "Estás en buena salud." } })
    end
end)
