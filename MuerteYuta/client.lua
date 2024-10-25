-- client.lua
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Deshabilitar la generación de vehículos de policía
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        SetMaxWantedLevel(0) -- Establecer nivel máximo de búsqueda a 0
        ClearAreaOfCops(playerCoords.x, playerCoords.y, playerCoords.z, 1000.0) -- Limpiar el área de policías
        
    end
end)
