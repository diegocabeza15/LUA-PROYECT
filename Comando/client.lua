-- Lista de comandos disponibles
local comandos = {
    {nombre = "/ayuda", descripcion = "Muestra esta lista de comandos"},
    {nombre = "/heal", descripcion = "Restaurar la salud del jugador"},
    {nombre = "/tpm", descripcion = "Teletransportarse al marcador en el mapa"},
    {nombre = "/recargar", descripcion = "Recargar todas las armas del jugador"},
    {nombre = "/restuarar",descripcion= "Te lo deja ready para pistear"}
}

-- Función para mostrar la ayuda
local function MostrarAyuda()
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        multiline = true,
        args = {"AYUDA", "Lista de comandos disponibles:"}
    })
    
    for _, comando in ipairs(comandos) do
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {"", comando.nombre .. " - " .. comando.descripcion}
        })
    end
end

-- Función para curar al jugador
local function CurarJugador()
    local jugador = PlayerPedId()
    SetEntityHealth(jugador, GetEntityMaxHealth(jugador))
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"SISTEMA", "Has sido curado completamente."}
    })
end

-- Función para teletransportar al jugador al marcador
local function TeleportarAlMarcador()
    local jugador = PlayerPedId()
    local blip = GetFirstBlipInfoId(8) -- 8 es el ID del sprite del marcador de destino

    if DoesBlipExist(blip) then
        local coord = GetBlipInfoIdCoord(blip)
        local groundZ, foundGround = 0, false
        
        for i = 0, 1000, 50 do
            SetEntityCoordsNoOffset(jugador, coord.x, coord.y, i + 0.0, false, false, false)
            Wait(0)
            groundZ, foundGround = GetGroundZFor_3dCoord(coord.x, coord.y, i + 0.0)
            if foundGround then
                SetEntityCoordsNoOffset(jugador, coord.x, coord.y, groundZ, false, false, false)
                break
            end
        end

        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"SISTEMA", "Has sido teletransportado al marcador."}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"SISTEMA", "No se ha encontrado ningún marcador en el mapa."}
        })
    end
end

-- Función para recargar todas las armas del jugador
local function RecargarArmas()
    local jugador = PlayerPedId()
    
    -- Obtener todas las armas que tiene el jugador
    for i = 1, 9 do -- Recorre todas las categorías de armas
        local _, hash = GetCurrentPedWeapon(jugador, true)
        if hash ~= GetHashKey("WEAPON_UNARMED") then
            local maxAmmo = GetMaxAmmoInClip(jugador, hash, true)
            SetPedAmmo(jugador, hash, maxAmmo)
        end
        
        -- Cambiar a la siguiente arma en el inventario
        SetCurrentPedWeapon(jugador, GetHashKey("WEAPON_UNARMED"), true)
        Citizen.Wait(100)
        SetCurrentPedWeapon(jugador, hash, true)
    end

    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"SISTEMA", "Todas tus armas han sido recargadas."}
    })
end

-- Función para rellenar la gasolina del vehículo, resetear el kilometraje y restaurar el estado del vehículo
local function Restuarar()
    local jugador = PlayerPedId()
    local vehiculo = GetVehiclePedIsIn(jugador, false)

    if vehiculo and vehiculo ~= 0 then
        SetVehicleFuelLevel(vehiculo, 100.0) -- Rellena la gasolina al 100%
        SetVehicleOdometer(vehiculo, 0.0) -- Resetear el kilometraje a 0
        SetVehicleFixed(vehiculo) -- Restaurar el estado del vehículo, eliminando daños o abolladuras
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"SISTEMA", "La gasolina del vehículo ha sido rellenada, el kilometraje ha sido reseteado y el estado del vehículo ha sido restaurado."}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"SISTEMA", "No estás en un vehículo."}
        })
    end
end


RegisterCommand("ayuda", function()
    MostrarAyuda()
end, false)

RegisterCommand("heal", function()
    CurarJugador()
end, false)

RegisterCommand("tpm", function()
    TeleportarAlMarcador()
end, false)

RegisterCommand("recargar", function()
    RecargarArmas()
end, false)


RegisterCommand("restuarar", function()
    Restuarar()
end, false)

-- Mensaje de bienvenida
AddEventHandler('playerSpawned', function()
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"BIENVENIDO", "Usa /ayuda para ver la lista de comandos disponibles."}
    })
end)
