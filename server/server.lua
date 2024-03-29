ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('getOwnedVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        local vehicles = {}

        for i = 1, #result do
            table.insert(vehicles, {
                plate = result[i].plate,
                owner = result[i].owner
            })
        end

        cb(vehicles)
    end)
end)

RegisterServerEvent('createVehicleKey')
AddEventHandler('createVehicleKey', function(plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= KeyPrice then
        xPlayer.removeMoney(KeyPrice) 

        local metadata = {
            type = ITEM,
            model = ITEM,
            label = plate,
            description = 'This key belongs to the vehicle with the registration number ' .. plate .. '.',
            plate = plate
        }

        xPlayer.addInventoryItem(ITEM, 1, metadata)
        
        TriggerClientEvent('ox_lib:notify', source, { type = 'success', title = _("successkey"), position = 'top' })
        
        local message = "**Steam:** " .. GetPlayerName(source) .. "\n**Identifier:** " .. xPlayer.identifier .. "\n**ID:** " .. source .. "\n**Log:** The player had a key made for the vehicle with registration number " .. plate .. "."
        discordLog(message, Webhook) 
    else
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', title = _("nomoney"), position = 'top' })
    end
end)

RegisterServerCallback('azakit_vehiclekey:PlayerLockCars', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

        local inventoryItems = xPlayer.getInventory()
      --  print(plate)
    
        local hasMatchingKey = false
        for _, item in pairs(inventoryItems) do
          --  print(item.metadata.plate)
            if item.name == ITEM and item.metadata and item.metadata.plate == plate then
                hasMatchingKey = true
                break
         end
        end

    if hasMatchingKey then
        cb(true)
        return
    end

    if OWNER then 
        MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate
        }, function(result)
            cb(result[1] ~= nil)
        end)
    end
end)


RegisterServerEvent('azakit_vehiclekey:deletelockpick')
AddEventHandler('azakit_vehiclekey:deletelockpick', function(plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local random = math.random(1,100)
   -- print(random)

    if random > 60 then
        xPlayer.removeInventoryItem(LOCKPICK_DOOR, 1)        
    end
end)

RegisterServerCallback('azakit_vehiclekey:PlayerTryUseLockpickOnVehicle', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasMatchingKey = false    

    if xPlayer.getInventoryItem(LOCKPICK_DOOR).count > 0 then
        xPlayer.removeInventoryItem(LOCKPICK_DOOR, 1)        
        cb(true)
        
    else
        cb(false)
    end
end)

RegisterServerCallback('azakit_vehiclekey:PlayerEngineCars', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

        local inventoryItems = xPlayer.getInventory()
        print(plate)
    
        local hasMatchingKey = false
        for _, item in pairs(inventoryItems) do
            print(item.metadata.plate)
            if item.name == ITEM and item.metadata and item.metadata.plate == plate then
                hasMatchingKey = true
                break
         end
        end

    if hasMatchingKey then
        cb(true)
        return
    end

    if OWNER then 
        MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate
        }, function(result)
            cb(result[1] ~= nil)
        end)
    end

    if LOCKPICK_ENGINE_REMOVE and xPlayer.getInventoryItem(LOCKPICK_ENGINE).count > 0 then
        xPlayer.removeInventoryItem(LOCKPICK_ENGINE, 1)        
        cb(true)
    elseif not LOCKPICK_ENGINE_REMOVE and xPlayer.getInventoryItem(LOCKPICK_ENGINE).count > 0 then        
        cb(true)
    else
        cb(false)
    end
end)


RegisterServerEvent('azakit_vehiclekey:CheckLockpick')
AddEventHandler('azakit_vehiclekey:CheckLockpick', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local hasLockpick = false
    local lockpickItem = LOCKPICK_ENGINE 

    local inventory = xPlayer.inventory
    for _, item in ipairs(inventory) do
        if item.name == lockpickItem then
            hasLockpick = true
            break
        end
    end

    TriggerClientEvent('azakit_vehiclekey:LockpickStatus', src, hasLockpick)
end)

function discordLog(message, webhook)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = 'AzakitBOT', embeds = {{["description"] = "".. message .."",["footer"] = {["text"] = "Azakit Development - https://discord.com/invite/DmsF6DbCJ9",["icon_url"] = "https://cdn.discordapp.com/attachments/1150477954430816456/1192512440215277688/azakitdevelopmentlogoavatar.png?ex=65a958c1&is=6596e3c1&hm=fc6638bef39209397047b55d8afbec6e8a5d4ca932d8b49aec74cb342e2910dc&",},}}, avatar_url = "https://cdn.discordapp.com/attachments/1150477954430816456/1192512440215277688/azakitdevelopmentlogoavatar.png?ex=65a958c1&is=6596e3c1&hm=fc6638bef39209397047b55d8afbec6e8a5d4ca932d8b49aec74cb342e2910dc&"}), { ['Content-Type'] = 'application/json' })
end
