local ServerCallbacks, CurrentRequestId = {}, 0

function TriggerServerCallback(name, cb, ...)
	ServerCallbacks[CurrentRequestId] = cb

	TriggerServerEvent('azakit_vehiclekey:triggerServerCallback', name, CurrentRequestId, ...)

	if CurrentRequestId < 65535 then
		CurrentRequestId = CurrentRequestId + 1
	else
		CurrentRequestId = 0
	end
end

RegisterNetEvent('azakit_vehiclekey:serverCallback')
AddEventHandler('azakit_vehiclekey:serverCallback', function(requestId, ...)
	ServerCallbacks[requestId](...)
	ServerCallbacks[requestId] = nil
end)

function SpawnNPC(model, position, heading)
	model = GetHashKey(model)
	RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end
	local npc = CreatePed(4, model, position, heading, false, true)
	SetEntityHeading(npc, heading)
	return npc
end