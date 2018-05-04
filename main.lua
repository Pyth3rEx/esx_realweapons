ESX = nil
local Weapons = {}
local Loaded = false
-----------------------------------------------------------
-----------------------------------------------------------
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('efsx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
	end

	while not Loaded do
		Wait(250)
	end

	while true do
		local playerPed = GetPlayerPed(-1) --Détetion entitée "playerPed"

		for i=1, #Config.RealWeapons, 1 do

    		local weaponHash = GetHashKey(Config.RealWeapons[i].name)

    		if HasPedGotWeapon(playerPed, weaponHash, false) then
    			local onPlayer = false

				for weaponName, entity in pairs(Weapons) do
      				if weaponName == Config.RealWeapons[i].name then
      					onPlayer = true
      					break
      				end
      			end

      			if not onPlayer and weaponHash ~= GetSelectedPedWeapon(playerPed) then
	      			SetGear(Config.RealWeapons[i].name)
      			elseif onPlayer and weaponHash == GetSelectedPedWeapon(playerPed) then
	      			RemoveGear(Config.RealWeapons[i].name)
      			end

    		end
  		end
		Wait(500) --Cooldown
	end
end)
-----------------------------------------------------------
-----------------------------------------------------------
AddEventHandler('skinchanger:modelLoaded', function()
	SetGears()
	Loaded = true
end)
-----------------------------------------------------------
-----------------------------------------------------------
RegisterNetEvent('esx:removeWeapon')
AddEventHandler('esx:removeWeapon', function(weaponName)
	RemoveGear(weaponName)
end)
-----------------------------------------------------------
-----------------------------------------------------------
-- Remove only one weapon that's on the ped
function RemoveGear(weapon)
	local _Weapons = {}

	for i, entity in pairs(Weapons) do
		if entity.weapon ~= weapon then
			_Weapons[i] = entity
		else
			DeleteWeapon(entity.obj)
		end
	end

	Weapons = _Weapons
end
-----------------------------------------------------------
-----------------------------------------------------------
-- Remove all weapons that are on the ped
function RemoveGears()
	for weaponName, entity in pairs(Weapons) do
		ESX.Game.DeleteObject(entity)
	end
	Weapons = {}
	TriggerServerEvent('esx:clientLog', "[GEAR REMOVED] ")
end
-----------------------------------------------------------
-----------------------------------------------------------
-- Add one weapon on the ped
function SetGear(weaponFromConfig)
	local bone       = nil
	local boneX      = 0.0
	local boneY      = 0.0
	local boneZ      = 0.0
	local boneXRot   = 0.0
	local boneYRot   = 0.0
	local boneZRot   = 0.0
	local playerPed  = GetPlayerPed(-1)
	local model      = nil
	local playerData = ESX.GetPlayerData()


--Assignations des muscles du mesh "playerPed"
	for i=1, #Config.RealWeapons, 1 do
		if Config.RealWeapons[i].name == weaponFromConfig then
			bone     = Config.RealWeapons[i].bone
			boneX    = Config.RealWeapons[i].x
			boneY    = Config.RealWeapons[i].y
			boneZ    = Config.RealWeapons[i].z
			boneXRot = Config.RealWeapons[i].xRot
			boneYRot = Config.RealWeapons[i].yRot
			boneZRot = Config.RealWeapons[i].zRot
			model    = Config.RealWeapons[i].model
			break
		end
	end
--Fin Assignations des muscles du mesh "playerPed"

	ESX.Game.SpawnObject(model, {
		x = x,
		y = y,
		z = z
	}, function(obj)
		local playerPed = GetPlayerPed(-1)
		local boneIndex = GetPedBoneIndex(playerPed, bone)
		local bonePos 	= GetWorldPositionOfEntityBone(playerPed, boneIndex)
		AttachEntityToEntity(obj, playerPed, boneIndex, boneX, boneY, boneZ, boneXRot, boneYRot, boneZRot, false, false, false, false, 2, true)
		Weapons[weaponFromConfig] = obj
		TriggerServerEvent('esx:clientLog', "[SetGear] ATTACHED")
	end)
	TriggerServerEvent('esx:clientLog', "[SET GEAR] " .. weapon)
end
-----------------------------------------------------------
-----------------------------------------------------------
-- Add all the weapons in the xPlayer's loadout
-- on the ped
function SetGears()
	local bone       = nil
	local boneX      = 0.0
	local boneY      = 0.0
	local boneZ      = 0.0
	local boneXRot   = 0.0
	local boneYRot   = 0.0
	local boneZRot   = 0.0
	local playerPed  = GetPlayerPed(-1)
	local model      = nil
	local playerData = ESX.GetPlayerData()
	local weaponFromConfig 	 = nil

	for i=1, #playerData.loadout, 1 do

		for j=1, #Config.RealWeapons, 1 do
			if Config.RealWeapons[j].name == playerData.loadout[i].name then

				bone     = Config.RealWeapons[j].bone
				boneX    = Config.RealWeapons[j].x
				boneY    = Config.RealWeapons[j].y
				boneZ    = Config.RealWeapons[j].z
				boneXRot = Config.RealWeapons[j].xRot
				boneYRot = Config.RealWeapons[j].yRot
				boneZRot = Config.RealWeapons[j].zRot
				model    = Config.RealWeapons[j].model
				weaponFromConfig   = Config.RealWeapons[j].name

				break

			end
		end

		local _wait = true

		ESX.Game.SpawnObject(model, {
			x = x,
			y = y,
			z = z
		}, function(obj)

			local playerPed = GetPlayerPed(-1)
			local boneIndex = GetPedBoneIndex(playerPed, bone)
			local bonePos 	= GetWorldPositionOfEntityBone(playerPed, boneIndex)

			AttachEntityToEntity(obj, playerPed, boneIndex, boneX, boneY, boneZ, boneXRot, boneYRot, boneZRot, false, false, false, false, 2, true)

			Weapons[weaponFromConfig] = obj

			_wait = false

		end)

		while _wait do
			Wait(0)
		end
    end

end
