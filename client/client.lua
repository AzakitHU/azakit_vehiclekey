ESX = nil
StartNPC, HasGold = {},

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
    StartNPC = SpawnNPC(START_NPC.ped.model, START_NPC.ped.coords, START_NPC.ped.heading)
    FreezeEntityPosition(StartNPC, true)
    SetEntityInvincible(StartNPC, true)
    SetBlockingOfNonTemporaryEvents(StartNPC, true)
    TaskStartScenarioInPlace(StartNPC, "WORLD_HUMAN_SMOKING", 0, true)
    AddEntityMenuItem({
        entity = StartNPC,
        event = "azakit_vehiclekey:openVehicleKeyMenu",
        desc = "Talk"
    })

end)

local ownedVehicles = {}

ESX.TriggerServerCallback('getOwnedVehicles', function(vehicles)
    ownedVehicles = vehicles
end)

local vehicles = {}

RegisterNetEvent('azakit_vehiclekey:openVehicleKeyMenu')
AddEventHandler('azakit_vehiclekey:openVehicleKeyMenu', function()
    OpenVehicleKeyMenu()
end)

function OpenVehicleKeyMenu()
    ESX.TriggerServerCallback('getOwnedVehicles', function(ownedVehicles)
        local elements = {}

        for _,v in ipairs(ownedVehicles) do
            table.insert(elements, {label = v.plate, plate = v.plate})
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_key_menu',
        {
            title    = 'Key copy $150. Your vehicles:',
            align    = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()
            TriggerServerEvent('createVehicleKey', data.current.plate)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

local RunWork = false

function StartWork()
	if RunWork then
		return
	end

	local timer = 0
	local playerPed = PlayerPedId()
	RunWork = true

	while timer < 100 do
		Citizen.Wait(0)
		timer = timer + 1

		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end

	RunWork = false
end

function VehicleLock()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle

	Citizen.CreateThread(function()
		StartWork()
	end)

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end

	if not DoesEntityExist(vehicle) then
		return
	end

	TriggerServerCallback('azakit_vehiclekey:PlayerLockCars', function(isOwnedVehicle)

		if isOwnedVehicle then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 1 then
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)  
                lib.notify({
                    position = 'top',
                    title = "you closed it",
                    type = 'info'
                  })
			elseif lockStatus == 2 then
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
                lib.notify({
                    position = 'top',
                    title = "you opened it",
                    type = 'info'
                  })
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, LockKey) and IsInputDisabled(0) then
			VehicleLock()
			Citizen.Wait(300)
		end
	end
end)
