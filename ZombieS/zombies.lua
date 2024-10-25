local Shooting = false
local Running = false

local SafeZones = {
    {x = 450.5966, y = -998.9636, z = 28.4284, radius = 80.0},-- Mission Row
    {x = 1853.6666, y = 3688.0222, z = 33.2777, radius = 40.0},-- Sandy Shores
    {x = -104.1444, y = 6469.3888, z = 30.6333, radius = 60.0}-- Paleto Bay
}

DecorRegister('RegisterZombie', 2)

AddRelationshipGroup('ZOMBIE')
SetRelationshipBetweenGroups(0, GetHashKey('ZOMBIE'), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(5, GetHashKey('PLAYER'), GetHashKey('ZOMBIE'))

function IsPlayerShooting()
    return Shooting
end

function IsPlayerRunning()
    return Running
end

Citizen.CreateThread(function()-- Solo funcionará en su propio bucle while
    while true do
        Citizen.Wait(0)

        -- Peds
        SetPedDensityMultiplierThisFrame(1.0)
        SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)

        -- Vehicles
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
    end
end)

Citizen.CreateThread(function()-- Solo funcionará en su propio bucle while
    while true do
        Citizen.Wait(100) -- Aumentar el tiempo de espera

        Shooting = IsPedShooting(PlayerPedId())
        Running = IsPedSprinting(PlayerPedId()) or IsPedRunning(PlayerPedId())

        if Shooting then
            Citizen.Wait(5000)
        end
    end
end)

Citizen.CreateThread(function()
	for _, zone in pairs(SafeZones) do
    	local Blip = AddBlipForRadius(zone.x, zone.y, zone.z, zone.radius)
		SetBlipHighDetail(Blip, true)
    	SetBlipColour(Blip, 2)
    	SetBlipAlpha(Blip, 128)
	end

    while true do
        Citizen.Wait(0)

    	for _, zone in pairs(SafeZones) do
	        local Handler, Zombie = FindFirstPed()
	        repeat
	            updateZombieState(Zombie) -- Llamada a la función refactorizada

	            local pedcoords = GetEntityCoords(Zombie)
	            local zonecoords = vector3(zone.x, zone.y, zone.z)
	            local distance = #(zonecoords - pedcoords)

	            if distance <= zone.radius then
	                DeleteEntity(Zombie)
	            end

	            Success, Zombie = FindNextPed(Handler)
	        until not (Success)

	        EndFindPed(Handler)
	    end
	        
		local Handler, Zombie = FindFirstPed()

	    repeat
        	Citizen.Wait(10)

	        if IsPedHuman(Zombie) and not IsPedAPlayer(Zombie) and not IsPedDeadOrDying(Zombie, true) then
	            if not DecorExistOn(Zombie, 'RegisterZombie') then
	                initializeZombie(Zombie) -- Llamada a la función para inicializar el zombie
	            end

	            handleZombieBehavior(Zombie) -- Llamada a la función para manejar el comportamiento del zombie

	            local PlayerCoords = GetEntityCoords(PlayerPedId())
	            local PedCoords = GetEntityCoords(Zombie)
	            local Distance = #(PedCoords - PlayerCoords)
	            local DistanceTarget = getDistanceTarget() -- Llamada a la función para obtener la distancia objetivo

	            if Distance <= DistanceTarget and not IsPedInAnyVehicle(PlayerPedId(), false) then
	                TaskGoToEntity(Zombie, PlayerPedId(), -1, 0.0, 2.0, 1073741824, 0)
	            end

	            if Distance <= 1.3 then
	                handleZombieAttack(Zombie) -- Llamada a la función para manejar el ataque del zombie
	            end

	            if not NetworkGetEntityIsNetworked(Zombie) then
	                DeleteEntity(Zombie)
	            end
	        end
	        
	        Success, Zombie = FindNextPed(Handler)
	   	until not (Success)

    	EndFindPed(Handler)
   	end
end)

-- Función para inicializar el estado del zombie
local function initializeZombie(Zombie)
    if currentZombies < maxZombies then
        ClearPedTasks(Zombie)
        ClearPedSecondaryTask(Zombie)
        ClearPedTasksImmediately(Zombie)
        TaskWanderStandard(Zombie, 10.0, 10)
        SetPedRelationshipGroupHash(Zombie, 'ZOMBIE')
        ApplyPedDamagePack(Zombie, 'BigHitByVehicle', 0.0, 1.0)
        SetEntityHealth(Zombie, 200)

        RequestAnimSet('move_m@drunk@verydrunk')
        while not HasAnimSetLoaded('move_m@drunk@verydrunk') do
            Citizen.Wait(0)
        end
        SetPedMovementClipset(Zombie, 'move_m@drunk@verydrunk', 1.0)

        SetPedConfigFlag(Zombie, 100, false)
        DecorSetBool(Zombie, 'RegisterZombie', true)
        currentZombies = currentZombies + 1
    else
        DeleteEntity(Zombie) -- Elimina el zombie si se excede el límite
    end
end

-- Función para manejar el comportamiento del zombie
local function handleZombieBehavior(Zombie)
    SetPedRagdollBlockingFlags(Zombie, 1)
    SetPedCanRagdollFromPlayerImpact(Zombie, false)
    SetPedSuffersCriticalHits(Zombie, true)
    SetPedEnableWeaponBlocking(Zombie, true)
    DisablePedPainAudio(Zombie, true)
    StopPedSpeaking(Zombie, true)
    SetPedDiesWhenInjured(Zombie, false)
    StopPedRingtone(Zombie)
    SetPedMute(Zombie)
    SetPedIsDrunk(Zombie, true)
    SetPedConfigFlag(Zombie, 166, false)
    SetPedConfigFlag(Zombie, 170, false)
    SetBlockingOfNonTemporaryEvents(Zombie, true)
    SetPedCanEvasiveDive(Zombie, false)
    RemoveAllPedWeapons(Zombie, true)

    if math.random() < 0.1 then -- 10% de probabilidad de cambiar de dirección
        TaskWanderStandard(Zombie, 10.0, 10)
    end
end

-- Función para obtener la distancia objetivo
local function getDistanceTarget()
    if IsPlayerShooting() then
        return 120.0
    elseif IsPlayerRunning() then
        return 50.0
    else
        return 20.0
    end
end

-- Función para manejar el ataque del zombie
local function handleZombieAttack(Zombie)
    if not IsPedRagdoll(Zombie) and not IsPedGettingUp(Zombie) then
        local health = GetEntityHealth(PlayerPedId())
        if health == 0 then
            ClearPedTasks(Zombie)
            TaskWanderStandard(Zombie, 10.0, 10)
        else
            RequestAnimSet('melee@unarmed@streamed_core_fps')
            while not HasAnimSetLoaded('melee@unarmed@streamed_core_fps') do
                Citizen.Wait(10)
            end

            TaskPlayAnim(Zombie, 'melee@unarmed@streamed_core_fps', 'ground_attack_0_psycho', 8.0, 1.0, -1, 48, 0.001, false, false, false)

            ApplyDamageToPed(PlayerPedId(), 5, false)
        end
    end
end

-- Función para actualizar el estado del zombie
local function updateZombieState(Zombie)
    if IsPedHuman(Zombie) and not IsPedAPlayer(Zombie) and not IsPedDeadOrDying(Zombie, true) then
        -- Obtener las coordenadas del jugador y del zombie
        local PlayerCoords = GetEntityCoords(PlayerPedId())
        local ZombieCoords = GetEntityCoords(Zombie)
        local distance = #(PlayerCoords - ZombieCoords)

        -- Si el jugador está cerca, el zombie lo sigue
        if distance < 30.0 then
            TaskGoToEntity(Zombie, PlayerPedId(), -1, 0.0, 1.0, 1073741824, 0)
        end

        -- Si el jugador está muy cerca, el zombie ataca
        if distance <= 1.3 then
            handleZombieAttack(Zombie) -- Llamada a la función para manejar el ataque del zombie
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distanceToSafeZone = #(playerCoords - vector3(450.5966, -998.9636, 28.4284)) -- Ejemplo con la primera zona segura

        if distanceToSafeZone < 100 then
            SetPedDensityMultiplierThisFrame(1.0)
            SetVehicleDensityMultiplierThisFrame(1.0)
        else
            SetPedDensityMultiplierThisFrame(0.0)
            SetVehicleDensityMultiplierThisFrame(0.0)
        end
    end
end)

local maxZombies = 50
local currentZombies = 0

function handleZombieDeath(Zombie)
    currentZombies = currentZombies - 1
end
