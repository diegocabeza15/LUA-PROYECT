Citizen.CreateThread(function()
    -- Espera unos segundos después de que el jugador entre
    Citizen.Wait(1000)
    -- Envía el mensaje al chat
    TriggerEvent('chat:addMessage', {
        color = { 255, 234, 112 },
        multiline = true,
        args = { "Sistema", "¡Hola, bienvenido al servidor, pasala bien y disfruta!" }
    })
end)