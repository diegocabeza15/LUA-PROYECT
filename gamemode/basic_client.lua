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
  
  -- Definir un conjunto de coordenadas posibles
  local spawnPoints = vector3(-1806.6305, 450.4791, 127.5119)
  
  -- Establecer las coordenadas del jugador
  SetEntityCoords(playerPed, spawnPoints.x, spawnPoints.y, spawnPoints.z, false, false, false, true)

  -- Equipar un arma blanca (por ejemplo, un cuchillo)
  local weaponHash = GetHashKey("WEAPON_KNIFE") -- Cambia "WEAPON_KNIFE" por el arma que desees
  GiveWeaponToPed(playerPed, weaponHash, 1, false, true) -- 1 es la cantidad de munición
end)
