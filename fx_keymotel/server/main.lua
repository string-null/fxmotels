FX = nil

TriggerEvent('fx:get', function(core) FX = core end)

local FX

cachedData = {
	["cbData"] = {},
}

TriggerEvent('fx:get', function(core) FX = core end)
	FX = library 
--end)

FX = nil

TriggerEvent('fx:get', function(core) FX = core end)

RegisterServerEvent("dav-keys:giveKey")
AddEventHandler("dav-keys:giveKey", function(key, player)
	TriggerClientEvent("dav-keys:insertKey", player, key)
end)

RegisterServerEvent("dav-keys:removeKeyByName")
AddEventHandler("dav-keys:removeKeyByName", function(key)
	local fetchSqlQuery = [[
		SELECT
			*
		FROM
			user_keys
	]]

	MySQL.Async.fetchAll(fetchSqlQuery, {}, function(responses)
		if not responses[1] then return end

		for _, fetchedData in ipairs(responses) do
			print(json.encode(fetchedData))
			local decodedKeys = json.decode(fetchedData["keyTable"])
			local newKeys = {}

			for _, keyData in ipairs(decodedKeys) do
				if keyData["keyId"] ~= key then
					table.insert(newKeys, keyData)
				end
			end

			local sqlQuery = [[
				UPDATE
					user_keys
				SET
					keyTable = @keyTable
				WHERE
					identifier = @identifier
			]]

			MySQL.Async.execute(sqlQuery, {
				["@keyTable"] = json.encode(newKeys),
				["@identifier"] = fetchedData["identifier"]
			}, function(rowsChanged)
				if rowsChanged > 0 then
					print("Changed keys for " ..fetchedData["identifier"])
				end
			end)
		end
	end)
	TriggerClientEvent("dav-keys:syncKeys", -1)
end)

if Config.CreateDBTable then
	local sqlQuery = {}
	MySQL.ready(function()
		table.insert(sqlQuery, function(callback)
            MySQL.Async.execute([[
				CREATE TABLE IF NOT EXISTS `user_keys` (
					`identifier` varchar(50) NOT NULL,
					`keyTable` longtext NOT NULL,
					PRIMARY KEY (`identifier`)
				) ENGINE=InnoDB DEFAULT CHARSET=latin1;
			]], {}, function(rowsChanged)
                callback(rowsChanged > 0)
            end)
		end)
		
		Async.parallel(sqlQuery, function(responses)
			if #responses >= #sqlQuery then
				print("Created table [pluto_keys] in db.")
			end
		end)
    end)
end

FX.RegisterCallback("dav-keys:fetchKeys", function(source, cb)
	
	local player = FX.GetPlayerById(source)["identifier"]

	if not player then cb(false) end

	FetchKeys(player, function(fetchedKeys)

		if fetchedKeys then

			local menuElements = {}

			for _, keyData in ipairs(fetchedKeys) do

				table.insert(menuElements, {
					["label"] = keyData["label"],
					["keyId"] = keyData["keyId"],
					["uuid"] = keyData["uuid"]
				})
			end

			cb(menuElements)

		else

			cb(false)

		end

	end)

end)

FX.RegisterCallback("dav-keys:removeKey", function(source, cb, removeKeyData)
	local player = FX.GetPlayerById(source)["identifier"]

	if player then
		RemoveKey(player, removeKeyData, function(removedKey)
			if removedKey then
				cb(true)
			else
				cb(false)
			end
		end)
	else
		cb(false)
	end
end)

FX.RegisterCallback("dav-keys:transferKey", function(source, cb, keyData, newOwner)
	
	local player = FX.GetPlayerById(source)["identifier"]
	local newPlayer = FX.GetPlayerById(newOwner)["identifier"]
	local newKeys = {}
	
	if player and newOwner then

		RemoveKey(player, keyData, function(removedKey)
			if removedKey then
				AddKey(newPlayer, keyData, function(addedKey)
					if addedKey then
						cb(true)
					else
						cb(false)
					end
				end)
			else
				cb(false)
			end
		end)

	else

		cb(false)

	end

end)

FX.RegisterCallback("dav-keys:addKey", function(source, cb, newKey)

	local player = FX.GetPlayerById(source)["identifier"]

	if player then

		AddKey(player, newKey, function(addedKey)

			if addedKey then
				cb(true)
			else
				cb(false)
			end

		end)

	else

		cb(false)

	end

end)

FetchKeys = function(player, cb)

	local fetchSqlQuery = [[
		SELECT
			keyTable
		FROM
			user_keys
		WHERE
			identifier = @identifier
	]]

	MySQL.Async.fetchAll(fetchSqlQuery, {
		["@identifier"] = player
	}, function(retrievedKeys)
		if not retrievedKeys[1] then return cb(false) end

		if cb then
			for _, keyData in pairs(retrievedKeys) do
				decodedKeys = json.decode(keyData["keyTable"])

				cb(decodedKeys)
			end
		end
	end)
end

RemoveKey = function(player, removeKeyData, cb)
	FetchKeys(player, function(fetchedKeys)
			
		if fetchedKeys then

			local updatedKeys = {}

			for _, keyData in ipairs(fetchedKeys) do

				if keyData["uuid"] ~= removeKeyData["uuid"] then
					table.insert(updatedKeys, {
						["label"] = keyData["label"],
						["keyId"] = keyData["keyId"],
						["uuid"] = keyData["uuid"]
					})
				end
			end

			local sqlQuery = [[
				UPDATE
					user_keys
				SET
					keyTable = @keyTable
				WHERE
					identifier = @identifier
			]]

			MySQL.Async.execute(sqlQuery, {
				["@keyTable"] = json.encode(updatedKeys),
				["@identifier"] = player
			}, function(rowsChanged)
				if rowsChanged > 0 then
					cb(true)
				else
					cb(false)
				end
			end)

		else
			cb(false)
		end
	end)
end

AddKey = function(player, newKey, cb)
	FetchKeys(player, function(fetchedKeys)
		
		local newKeys = {}

		table.insert(newKeys, newKey)

		if fetchedKeys then

			for _, keyData in ipairs(fetchedKeys) do

				table.insert(newKeys, {
					["label"] = keyData["label"],
					["keyId"] = keyData["keyId"],
					["uuid"] = keyData["uuid"]
				})
			end
	
			local sqlQuery = [[
				UPDATE
					user_keys
				SET
					keyTable = @keyTable
				WHERE
					identifier = @identifier
			]]

			MySQL.Async.execute(sqlQuery, {
				["@keyTable"] = json.encode(newKeys),
				["@identifier"] = player
			}, function(rowsChanged)
				if rowsChanged > 0 then
					cb(true)
				else
					cb(false)
				end
			end)
			
		else
			local sqlQuery = [[
				INSERT
					INTO
				user_keys
					(identifier, keyTable)
				VALUES
					(@identifier, @keyTable)
			]]

			MySQL.Async.execute(sqlQuery, {
				["@keyTable"] = json.encode(newKeys),
				["@identifier"] = player
			}, function(rowsChanged)
				if rowsChanged > 0 then
					cb(true)
				else
					cb(false)
				end
			end)
		end
	end)
end