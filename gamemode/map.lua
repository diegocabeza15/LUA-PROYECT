-- Definición del mapa
local mapa = {
    nombre = "Mi Mapa",
    exteriores = {
        { tipo = "bosque", coordenadas = { x = 0, y = 0 } },
        { tipo = "río", coordenadas = { x = 5, y = 2 } },
    },
    interiores = {
        casa = {
            habitaciones = {
                { nombre = "salón", tamaño = "grande" },
                { nombre = "cocina", tamaño = "pequeña" },
                { nombre = "dormitorio", tamaño = "mediano" },
            },
        },
        tienda = {
            habitaciones = {
                { nombre = "mostrador", tamaño = "pequeña" },
                { nombre = "almacén", tamaño = "grande" },
            },
        },
    },
}

-- Función para mostrar el mapa
function mostrarMapa()
    print("Mapa: " .. mapa.nombre)
    print("Exteriores:")
    for _, exterior in ipairs(mapa.exteriores) do
        print("- " .. exterior.tipo .. " en (" .. exterior.coordenadas.x .. ", " .. exterior.coordenadas.y .. ")")
    end
    print("Interiores:")
    for lugar, detalles in pairs(mapa.interiores) do
        print("- " .. lugar .. ":")
        for _, habitacion in ipairs(detalles.habitaciones) do
            print("  * " .. habitacion.nombre .. " (" .. habitacion.tamaño .. ")")
        end
    end
end

-- Llamar a la función para mostrar el mapa
mostrarMapa()

