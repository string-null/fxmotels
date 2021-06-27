FX = nil

cachedData = {
	["motelRooms"] = {},
	["blips"] = {}
}



Citizen.CreateThread(function()
    while FX == nil do
        TriggerEvent('fx:get', function(core) FX = core end)
        Citizen.Wait(0)
    end
--end)
	
	if FX.IsPlayerLoaded() then
		Init()
	end

end)



FX = nil

Citizen.CreateThread(function()
    while FX == nil do
        TriggerEvent('fx:get', function(core) FX = core end)
        Citizen.Wait(0)
    end
	
	FX.Data = FX.GetData()
end)


RegisterNetEvent("fx:spawned", function(data)
	FX.Data = data
end)

Citizen.CreateThread(function()
	while true do
		local sleepThread = 5000

		local ped = PlayerPedId()
		
		if ped ~= cachedData["ped"] then
			cachedData["ped"] = ped
		end

		Citizen.Wait(sleepThread)
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(500)

	if Config.EnableKeySystem and not exports["dav_keymotel"] then
		Trace("Eğer diazmotelkey script'ini başlatmazsanız hata alacaksın.")
		Config.EnableKeySystem = false
	end

	while true do
		
		local sleepThread = 500

		local ped = cachedData["ped"]
		cachedData["pedCoords"] = GetEntityCoords(ped)

		for _, motelData in pairs(Config.Motels) do
			
			local motelDistance = #(cachedData["pedCoords"] - motelData["motelPosition"])
			local raidText = nil

			CreateBlips(motelData)
			
			if motelDistance <= 50.0 then

				if not cachedData["stopSearching"] then
					cachedData["doorHandle"] = GetClosestObjectOfType(cachedData["pedCoords"], 5.0, motelData["doorHash"])
					cachedData["doorCoords"] = GetEntityCoords(cachedData["doorHandle"])
					cachedData["doorRoom"] = GetInteriorFromEntity(cachedData["doorHandle"])
				elseif cachedData["stopSearching"] and not cachedData["doorHandle"] or not cachedData["doorCoords"] or not cachedData["doorRoom"] then
					cachedData["doorHandle"] = GetClosestObjectOfType(cachedData["pedCoords"], 5.0, motelData["doorHash"])
					cachedData["doorCoords"] = GetEntityCoords(cachedData["doorHandle"])
					cachedData["doorRoom"] = GetInteriorFromEntity(cachedData["doorHandle"])
				end
				
				local interiorId = GetInteriorFromEntity(ped)
				local roomId = cachedData["doorCoords"]["y"] .. cachedData["doorCoords"]["x"]  .. cachedData["doorCoords"]["z"]
				local roomNumber = string.sub(cachedData["doorCoords"]["x"], 7, 8) .. string.sub(cachedData["doorCoords"]["y"], 4, 4) .. string.sub(cachedData["doorCoords"]["z"], 2, 2)
				local doorUnlockable = false
				local doorState = DoorSystemGetDoorState(cachedData["doorHandle"])
				local helpText = motelData["rentMode"] and "- Oda kirala $" .. (Config.RentTimer >= 24 and motelData["motelPrice"] .. "/gün" or round(motelData["motelPrice"] / Config.RentTimer, 2) .. "/saat") or "Buy room for $" .. motelData["motelPrice"] .. "."
				local dstCheck = #(cachedData["pedCoords"] - cachedData["doorCoords"])
				local roomRentable = true
				
				if not IsDoorRegisteredWithSystem(cachedData["doorHandle"]) then
					AddDoorToSystem(cachedData["doorHandle"], motelData["doorHash"], cachedData["doorCoords"], 0, true, false)

					if cachedData["motelRooms"][roomId] and cachedData["motelRooms"][roomId]["roomLocked"] ~= doorState then
						DoorSystemSetDoorState(cachedData["doorHandle"], cachedData["motelRooms"][roomId]["roomLocked"], true, true)
					else
						DoorSystemSetDoorState(cachedData["doorHandle"], true, true, true)
					end
				else
					if cachedData["motelRooms"][roomId] and cachedData["motelRooms"][roomId]["roomLocked"] ~= doorState then
						DoorSystemSetDoorState(cachedData["doorHandle"], cachedData["motelRooms"][roomId]["roomLocked"], true, true)
					end
				end
				
				if cachedData["motelRooms"][roomId] then
					roomRentable = false
					helpText = ""

					if Config.EnableKeySystem then
						if exports["dav_keymotel"]:HasKey("room-"..roomId) then
							doorUnlockable = true
							helpText = ""
						end
					end
					
					if cachedData["motelRooms"][roomId]["roomOwner"] == FX.Data["identifier"] then
						local h, m = ConvertTime(cachedData["motelRooms"][roomId]["paymentTimer"]) 
						local latestPayment = cachedData["motelRooms"][roomId]["paymentTimer"]
						helpText = latestPayment > Config.RentTimer and "- Tienes que pagar, pagar desde la gestión de la habitación." or ""
						doorUnlockable = true
					end
					
					if Config.RaidEnabled and not doorUnlockable and not roomRentable or not doorState == 0 then
						if FX.Data["job"] and FX.Data["job"]["name"] == Config.RaidJob then
							raidText = "Roba la habitación " .. roomNumber
						end
					else
						raidText = nil
					end
				end
				
				if motelData["roomFinish"] then
					if not cachedData["previewingDesign"] then
						if not IsInteriorEntitySetActive(cachedData["doorRoom"], cachedData["motelRooms"][roomId] and cachedData["motelRooms"][roomId]["roomFinish"] or motelData["roomFinish"]) then
							ActivateInteriorEntitySet(cachedData["doorRoom"], cachedData["motelRooms"][roomId] and cachedData["motelRooms"][roomId]["roomFinish"] or motelData["roomFinish"])
							if cachedData["motelRooms"][roomId] and cachedData["motelRooms"][roomId]["oldFinish"] then
								DeactivateInteriorEntitySet(cachedData["doorRoom"], cachedData["motelRooms"][roomId]["oldFinish"])
							end
							RefreshInterior(cachedData["doorRoom"])
						end
					end
				end

                 
				
				if dstCheck <= 10.0 then
					sleepThread = 0

					if dstCheck <= 5.0 then
						local doorOffset = GetOffsetFromEntityInWorldCoords(cachedData["doorHandle"], motelData["doorOffset"])
						
						if dstCheck <= 1.2 then
							if IsControlJustReleased(0, 47) then
								if doorUnlockable then 
									doorState = doorState == 1 and 0 or 1
									cachedData["motelRooms"][roomId]["roomLocked"] = doorState
									DoorSystemSetDoorState(cachedData["doorHandle"], doorState, true, true)
									TriggerServerEvent("fx_motels:syncDoorState", roomId, doorState)
								else
									
								TriggerServerEvent("fx_motels:a", source, args)
								end
							end

							if roomRentable and IsControlJustReleased(0, 47) then
								FX.UseCallback("fx_motels:rentRoom", function(rented, errorMessage)
									if rented then
										exports["dav_keymotel"]:AddKey({
											["label"] = motelData["motelName"] .. " - room " .. roomNumber,
											["keyId"] = "room-" .. roomId,
											["uuid"] = NetworkGetRandomInt()
										})
										("You just " .. (motelData["rentMode"] and "rented room " or "bought room ") .. roomNumber .. " for $" .. motelData["motelPrice"])
										FX.Notification("Has comprado un Motel!", "inform", 1500)
									else
										--ESX.ShowNotification(errorMessage)
									end
								end, roomId, motelData)
							end
							
							if raidText and IsControlJustReleased(0, 74) then
								RaidRoom(roomId, cachedData["doorHandle"])
							end

							if doorUnlockable or roomRentable or raidText then
								local displayText = not roomRentable and raidText and "Press ~INPUT_VEH_HEADLIGHT~ to " or "Press ~INPUT_DETONATE~ to "
								displayText = displayText .. (doorUnlockable and (doorState == 1 and "kilidi aç." or "kilitle.") or roomRentable and (motelData["rentMode"] and "kirala." or "satın al.") or raidText and (not roomRentable and raidText or "") or "")
								HelpNotification(displayText)
							end
						end

						DrawScriptText(doorOffset, "Habitación " ..  roomNumber .. " - " ..(doorState == 1 and "~r~Bloqueado~s~ " or "~g~ABIERTO~s~ ") .. helpText)
					end
					
					if interiorId ~= 0 then

						cachedData["stopSearching"] = true

						inRoom = true

						for furnitureName, furnitureData in pairs(motelData["furniture"]) do
							local furnitureCoords = GetOffsetFromInteriorInWorldCoords(interiorId, furnitureData["offset"])
							local furnitureDistance = #(cachedData["pedCoords"] - furnitureCoords)

							if not furnitureData["restricted"] then
								if furnitureDistance <= 1.0 then
									if IsControlJustReleased(0, 38) then
										furnitureData["callback"](roomId, furnitureName)
									end
									HelpNotification("~INPUT_CONTEXT~ acceder a la fuerza "..furnitureData["text"])
								end
								DrawScriptText(furnitureCoords, furnitureData["text"])
							else
								if cachedData["motelRooms"][roomId] and cachedData["motelRooms"][roomId]["roomOwner"] == FX.Data["identifier"] then
									if furnitureDistance <= 1.0 then
										if IsControlJustReleased(0, 38) then
											furnitureData["callback"](roomId, roomNumber, motelData)
										end
										HelpNotification("~INPUT_CONTEXT~ acceder a la fuerza "..furnitureData["text"])
									end
									DrawScriptText(furnitureCoords, furnitureData["text"])
								end
							end
						end
					else
						cachedData["stopSearching"] = false
					end
				end
			end
		end

		Citizen.Wait(sleepThread)
	end
end)

if Config.CancelRoomCommand then
	RegisterCommand(Config.CancelRoomCommand, function()
		local roomId = cachedData["doorCoords"]["y"] .. cachedData["doorCoords"]["x"]  .. cachedData["doorCoords"]["z"]
		
		for _, motelData in pairs(Config.Motels) do
			if #(cachedData["pedCoords"] - motelData["motelPosition"]) <= 50.0 then
				if #(cachedData["pedCoords"] - cachedData["doorCoords"]) <= 2.0 then
					if cachedData["motelRooms"][roomId] and cachedData["motelRooms"][roomId]["roomOwner"] == FX.Data["identifier"] then
						if GetInteriorFromEntity(cachedData["ped"]) == 0 then
							FX.UseCallback("fx_motels:cancelRoom", function(canceled)
								if canceled then
									ESX.ShowNotification("You now no longer own this room.")
								end
							end, roomId, motelData)
						else
							ESX.ShowNotification("Please step out of the room and make sure no one else is in it.")
						end
					else
						ESX.ShowNotification("You dont own this room.")
					end
				else
					ESX.ShowNotification("Get closer to the door.")
				end
			end
		end
	end)
end

RegisterNetEvent("fx_motels:syncRooms")
AddEventHandler("fx_motels:syncRooms", function(motelData)
	if motelData then
		cachedData["motelRooms"] = motelData
	end
end)

RegisterNetEvent("fx_motels:syncDoorState")
AddEventHandler("fx_motels:syncDoorState", function(roomId, roomLocked)
	cachedData["motelRooms"][roomId]["roomLocked"] = roomLocked
end)

RegisterNetEvent("fx_motels:changeInteriorFinish")
AddEventHandler("fx_motels:changeInteriorFinish", function(roomId, interiorId, oldInterior, newInterior)
	DeactivateInteriorEntitySet(interiorId, oldInterior)
	ActivateInteriorEntitySet(interiorId, newInterior)
	RefreshInterior(interiorId)
end)