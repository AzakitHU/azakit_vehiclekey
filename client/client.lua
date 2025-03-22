ESX = nil
StartNPC, HasGold = {},

ESX = exports["es_extended"]:getSharedObject()

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

function PlayKeyAnim(vehicle, isUnlock)
    local playerPed = PlayerPedId()

    local animDict = "anim@mp_player_intmenu@key_fob@"
    local animName = "fob_click"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, 1.0, -1, 49, 0, 0, 0, 0)

    Citizen.Wait(1000)

    ClearPedTasks(playerPed)
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
                PlayKeyAnim(vehicle, false) 
                SetVehicleDoorsLocked(vehicle, 2)
                PlayVehicleDoorCloseSound(vehicle, 1)  
                lib.notify({
                    position = 'top',
                    title = "you closed it",
                    type = 'info'
                })
            elseif lockStatus == 2 then
                PlayKeyAnim(vehicle, true) 
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


local isEventActive = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local nearbyVehicles = ESX.Game.GetVehiclesInArea(coords, 10.0)

        local hasLockpick = HasItemInInventory('lockpick')

        if hasLockpick and not isEventActive then
            local vehicle = GetClosestVehicle(coords, 10.0, 0, 71)
            if DoesEntityExist(vehicle) then
                if LOCKPICK then
                    exports.ox_target:addGlobalVehicle({
                        label = "Lockpick Vehicle",
                        name = 'lockpick_vehicle',
                        icon = 'fa-solid fa-key',
                        distance = 3.0,
                        onSelect = function()
                                      InteractLockpick()
                                 end
                    })
                    end    
                isEventActive = true
            end
        end
    end
end)

function HasItemInInventory(itemName)
    local inventory = ESX.GetPlayerData().inventory
    for _, item in ipairs(inventory) do
        if item.name == itemName then
            return true
        end
    end
    return false
end

function InteractLockpick(index)
    if Interact then return end
    Interact = true
        local ped = PlayerPedId()
        
RequestAnimDict('mini@repair')
while not HasAnimDictLoaded('mini@repair') do
    Wait(500)
end
       -- lib.requestAnimDict('mini@repair', 10)
        TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 48, 0)
             local success = lib.skillCheck({'easy', 'easy', 'easy', 'easy'}, { 'w', 'a', 's', 'd' }) 
            if success then 
                ExchangeRequest(index)
            else
                TriggerServerEvent('azakit_vehiclekey:deletelockpick')
                lib.notify({
                    position = 'top',
                    title = "you messed it up",
                    type = 'error'
                  })
            end
        ClearPedTasks(ped)
        Interact = false  
end

function ExchangeRequest(index)
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

    TriggerServerCallback("azakit_vehiclekey:PlayerTryUseLockpickOnVehicle", function(result)
        if result then
            local lockStatus = GetVehicleDoorLockStatus(vehicle)
            if lockStatus == 1 then
                SetVehicleDoorsLocked(vehicle, 2)
                PlayVehicleDoorCloseSound(vehicle, 1)  
                lib.notify({
                    position = 'top',
                    title = "Success",
                    type = 'success'
                })
            elseif lockStatus == 2 then
                SetVehicleDoorsLocked(vehicle, 1)
                PlayVehicleDoorOpenSound(vehicle, 0)
                lib.notify({
                    position = 'top',
                    title = "Success",
                    type = 'success'
                })
            end
        else                
            lib.notify({
                position = 'top',
                title = "You don't have a lockpick",
                type = 'error'
            })
        end
    end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
    
end

RegisterCommand('lockVehicleFromServer', function()    
    VehicleLock()
end, false)

RegisterKeyMapping('lockVehicleFromServer', 'Use the vehicle key', 'keyboard', LockKey)

RegisterCommand('toggleengine', function()
    ToggleVehicleEngine()
end, false)

RegisterKeyMapping('toggleengine', 'Toggle Vehicle Engine', 'keyboard', EngineKey)

function ToggleVehicleEngine()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local coords = GetEntityCoords(playerPed)

    TriggerServerCallback('azakit_vehiclekey:PlayerEngineCars', function(isOwnedEngineVehicle)
   -- print(isOwnedEngineVehicle)
        if isOwnedEngineVehicle then
            if DoesEntityExist(vehicle) and IsPedInAnyVehicle(playerPed, false) then
                local engineRunning = GetIsVehicleEngineRunning(vehicle)
        
                if engineRunning then
                    SetVehicleEngineOn(vehicle, false, false, true)
                else
                    SetVehicleEngineOn(vehicle, true, false, true)
                end
            end            
        elseif DoesEntityExist(vehicle) and IsPedInAnyVehicle(playerPed, false) then
            local coords = GetEntityCoords(playerPed)
            local lockpickItem = LOCKPICK_ENGINE
            
            TriggerServerEvent('azakit_vehiclekey:CheckLockpick')
    
            RegisterNetEvent('azakit_vehiclekey:LockpickStatus')
            AddEventHandler('azakit_vehiclekey:LockpickStatus', function(hasLockpick)
                if hasLockpick then                  
                    if DoesEntityExist(vehicle) and IsPedInAnyVehicle(playerPed, false) then
                        local engineRunning = GetIsVehicleEngineRunning(vehicle)
                
                        if engineRunning then
                            SetVehicleEngineOn(vehicle, false, false, true)
                        else
                            SetVehicleEngineOn(vehicle, true, false, true)
                        end
                    end            
                else            
                  --  lib.notify({
                   --     position = 'top',
                   --     title = "You don't have a lockpick",
                   --     type = 'error'
                  --  })
                end
            end)
        else                
           -- lib.notify({
           --     position = 'top',
           --     title = "You don't have a key",
           --     type = 'error'
          --  })
        end
    end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))  
end
