-- server.lua

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    print('Misión de checkpoints iniciada: ' .. resourceName)
end)
