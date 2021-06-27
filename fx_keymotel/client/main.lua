ESX = nil

cachedData = {}

Citizen.CreateThread(function()
	
	while not ESX do

		TriggerEvent("esx:getSharedObject", function(library) 
			ESX = library 
		end)

		Citizen.Wait(0)
	end

	if ESX.IsPlayerLoaded() then
		FetchKeys()
	end

end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData)
	ESX.PlayerData = playerData
	Wait(500)
	FetchKeys()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(newJob)
	ESX.PlayerData["job"] = newJob
end)

RegisterNetEvent("dav-keys:insertKey")
AddEventHandler("dav-keys:insertKey", function(key)
	ESX.TriggerServerCallback("dav-keys:fetchKeys", function(fetchedKeys)
		if fetchedKeys then
			cachedData["fetchedKeys"] = fetchedKeys
		end
	end)
end)

RegisterNetEvent("dav-keys:syncKeys")
AddEventHandler("dav-keys:syncKeys", function()
	Wait(5000)
	ESX.TriggerServerCallback("dav-keys:fetchKeys", function(fetchedKeys)
		if fetchedKeys then
			print(json.encode(fetchedKeys))
			cachedData["fetchedKeys"] = fetchedKeys
		end
	end)
end)

RegisterCommand("otelver", function()
	if not cachedData["fetchedKeys"] then
		ESX.TriggerServerCallback("dav-keys:fetchKeys", function(fetchedKeys)
			if fetchedKeys then
				cachedData["fetchedKeys"] = fetchedKeys
				KeyMenu()
			else
				print("Couldn't fetch keys")
			end
		end)
	else
		KeyMenu()
	end
end)