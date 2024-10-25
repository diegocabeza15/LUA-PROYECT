local model = GetHashKey('a_f_m_fatcult_01') 

spawnpoint 'a_m_y_hipster_01' { -1772.3885, 444.3736, 127.2703, 119.0825 }

AddEventHandler('onClientMapStart', function()
  exports.spawnmanager:setAutoSpawn(true)
  exports.spawnmanager:forceRespawn()
end)

-- Permitir fuego amigo
Citizen.CreateThread(function()
  while true do
      Wait(0)
      NetworkSetFriendlyFireOption(true)
      SetCanAttackFriendly(PlayerPedId(), true, false)
  end
end)

-- Manejador del evento de spawn del jugador
AddEventHandler('playerSpawned', function()
  local playerPed = PlayerPedId()
  
  -- Configurar spawn en una ubicación específica
  local spawnCoords = vector3(-1767.9266, 445.3730, 127.2791, 106.2196) -- Cambia estas coordenadas según lo necesites
  SetEntityCoords(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)
end)