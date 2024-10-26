RegisterNetEvent('npc_give_weapon:giveWeapon')
AddEventHandler('npc_give_weapon:giveWeapon', function()
    local _source = source
    local xPlayer = GetPlayerPed(_source)

    local weaponName = 'WEAPON_PISTOL'
    local ammo = 50
    
    GiveWeaponToPed(xPlayer, GetHashKey(weaponName), ammo, false, true)
end)