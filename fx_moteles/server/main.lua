local FX

cachedData = {
    ["motelRooms"] = {}
}

TriggerEvent('fx:get', function(core) FX = core end)
    FX = library




    FX = nil

    TriggerEvent('fx:get', function(core) FX = core end)


RegisterServerEvent("fx_motels:syncDoorState")
AddEventHandler("fx_motels:syncDoorState", function(roomId, roomLocked)
    cachedData["motelRooms"][roomId]["roomLocked"] = roomLocked
    TriggerClientEvent("fx_motels:syncDoorState", -1, roomId, roomLocked)
end)


RegisterServerEvent("fx_motels:a")
AddEventHandler("fx_motels:a", function(source, args)
    local player = FX.GetPlayerById(source)
    --player:Global().triggerEvent('fx:notification', source, 'No puedes desbloquear esta puerta', 'error')
end)



FX.RegisterCallback("fx_motels:fetchMotelRooms", function(source, callback)
    local currentTime = os.time()
    local fetchSqlQuery = [[
        SELECT
            *
        FROM
            fx_motels
    ]]

    MySQL.Async.fetchAll(fetchSqlQuery, {
        ["@owner"] = identifier
    }, function(fetchedData)
        if fetchedData[1] then
            for _, data in ipairs(fetchedData) do
                if not cachedData["motelRooms"][data["interiorId"]] then
                    local hoursSincePayment = os.difftime(currentTime, data["latestPayment"]) / 3600
                    local decodedRoomData = json.decode(data["roomData"])
                    if hoursSincePayment >= Config.AutoRemoveRoom then
                        RemoveRoom(data["interiorId"])
                    else
                        cachedData["motelRooms"][data["interiorId"]] = {
                            ["roomOwner"] = data["roomOwner"],  
                            ["roomLocked"] = decodedRoomData["roomLocked"],
                            ["roomFinish"] = decodedRoomData["roomFinish"],
                            ["roomStorages"] = decodedRoomData["roomStorages"],
                            ["roomData"] = decodedRoomData,
                            ["latestPayment"] = data["latestPayment"],
                            ["paymentTimer"] =  hoursSincePayment
                        }
                    end
                end
            end
            callback(cachedData["motelRooms"])
        else
            callback(false)
        end
    end)
end)

FX.RegisterCallback("fx_motels:payRent", function(source, callback, roomId, payments, motelData)
    local player = FX.GetPlayerById(source)

    if not player then return callback(false) end

    if cachedData["motelRooms"][roomId] then
        local sqlQuery = [[
            UPDATE
                fx_motels
            SET
                latestPayment = @latestPayment
            WHERE
                interiorId = @interiorId
        ]]

        MySQL.Async.execute(sqlQuery, {
            ["@latestPayment"] = os.time(),
            ["@interiorId"] = roomId
        }, function(rowsChanged)
            if rowsChanged > 0 then
                player.removeMoney(payments * motelData["motelPrice"])
                cachedData["motelRooms"][roomId]["latestPayment"] = os.time()
                TriggerClientEvent("fx_motels:syncRooms", -1, cachedData["motelRooms"])
                callback(true)
            else
                Trace("Room not found.")
            end
        end)
    end
end)    

FX.RegisterCallback("fx_motels:fetchRentTime", function(source, callback, roomId)
    local player = FX.GetPlayerById(source)

    if not player then return callback(false, "player") end
    if not roomId then return callback(false, "room") end

    if cachedData["motelRooms"][roomId] then
        local currentTime = os.time()
        local hoursSincePayment = os.difftime(currentTime, cachedData["motelRooms"][roomId]["latestPayment"]) / 3600

        callback(hoursSincePayment)
    else
        callback(false, "don't exist")
    end
end)

FX.RegisterCallback("fx_motels:canBuyKey", function(source, callback)
    local player = FX.GetPlayerById(source)

    if not player then return callback(false, "player") end

    local money = Config.NewESX and player.getAccount("money")["money"] or player.getMoney()

    if money >= Config.KeyPrice then
        callback(true)
    else
        callback(false)
    end
end)


FX.RegisterCallback("fx_motels:cancelRoom", function(source, callback, roomId, motelData)
    local player = FX.GetPlayerById(source)

    if not player then return callback(false, "player") end
    if not roomId then return callback(false) end
    if not motelData then return callback(false) end

    RemoveRoom(roomId)
     
    if Config.EnableKeySystem then
        TriggerEvent("fx-keys:removeKeyByName", "room-" .. roomId)
    end

    if not motelData["rentMode"] then
        player.giveMoney(motelData["motelPrice"])
        callback(true)
    else
        callback(true)
    end
end)

FX.RegisterCallback("fx_motels:updateInteriorFinish", function(source, callback, price, roomId, oldInterior, newInterior)
    local player = FX.GetPlayerById(source)

    if not player then return callback(false, "player") end
    if not roomId then return callback(false, "room") end

    Trace("price:",price,"roomid:", roomId, "old:",oldInterior, "new:", newInterior)

    local playerMoney = Config.NewESX and player.getAccount("money")["money"] or player.getMoney()

    if playerMoney < price then return callback(false, "Not enough money.") end 

    if cachedData["motelRooms"][roomId] then
        cachedData["motelRooms"][roomId]["roomData"]["roomFinish"] = newInterior
        cachedData["motelRooms"][roomId]["roomFinish"] = newInterior
        cachedData["motelRooms"][roomId]["oldFinish"] = oldInterior
        UpdateRoomData(roomId, function(updated)
            if updated then
                callback(true)
                TriggerClientEvent("fx_motels:syncRooms", -1, cachedData["motelRooms"])
                return
            else
                callback(false, "Didn't update.")
                return
            end
        end)
    else
        callback(false, "don't exist")
    end
end)


FX.RegisterCallback("fx_motels:rentRoom", function(source, callback, interiorId, motelData)
    local player = FX.GetPlayerById(source)
    local playerMoney = player:Cash().get()
    local playerBankMoney = player:Bank().get()
    local defaultRoomData = {
        ["roomFinish"] = motelData["roomFinish"],
        ["roomLocked"] = 1,
        ["roomStorages"] = {},
        ["motelName"] = motelData["motelName"]
    }

    if player then

        if not interiorId then return callback(false, "No room number got specified.") end

        if playerMoney < motelData["motelPrice"] and playerBankMoney < motelData["motelPrice"] then return callback(false, "You don't have enough money, you need $" .. motelData["motelPrice"] - playerMoney) end
        
        if not Config.DiscInventory then
            for furnitureName, furnitureData in pairs(motelData["furniture"]) do
                if furnitureData["type"] == "storage" then
                    defaultRoomData["roomStorages"][furnitureName] = {
                        ["cash"] = 0,
                        ["black_money"] = 0,
                        ["items"] = {}
                    }
                end
            end
        end

        local sqlQuery = [[
            INSERT
                INTO
            fx_motels
                (interiorId, roomOwner, roomData, latestPayment)
            VALUES
                (@interiorId, @roomOwner, @roomData, @latestPayment)
        ]]

        MySQL.Async.execute(sqlQuery, {
            ["@interiorId"] = interiorId,
            ["@roomOwner"] = player["identifier"],
            ["@roomData"] = json.encode(defaultRoomData),
            ["@latestPayment"] = os.time()
        }, function(rowsChanged)
            if rowsChanged and rowsChanged > 0 then
                if playerMoney >= motelData["motelPrice"] then
                    player.removeMoney(motelData["motelPrice"])
                    cachedData["motelRooms"][interiorId] = {
                        ["roomOwner"] = player["identifier"],  
                        ["roomLocked"] = 1,
                        ["roomData"] = defaultRoomData,
                        ["roomFinish"] = defaultRoomData["roomFinish"],
                        ["roomStorages"] = defaultRoomData["roomStorages"],
                        ["latestPayment"] = os.time(),
                        ["paymentTimer"] =  os.difftime(os.time(), os.time()) / 3600
                    }
                    callback(true)
                    TriggerClientEvent("fx_motels:syncRooms", -1, cachedData["motelRooms"])
                elseif playerBankMoney >= motelData["motelPrice"] then
  
                    player:Bank().removeBank(motelData["motelPrice"], "test", function()
                    end) 
                    
                    cachedData["motelRooms"][interiorId] = {
                        ["roomOwner"] = player["identifier"],  
                        ["roomLocked"] = 1,
                        ["roomData"] = defaultRoomData,
                        ["roomFinish"] = defaultRoomData["roomFinish"],
                        ["roomStorages"] = defaultRoomData["roomStorages"],
                        ["latestPayment"] = os.time(),
                        ["paymentTimer"] =  os.difftime(os.time(), os.time()) / 3600
                    }
                    callback(true)
                    TriggerClientEvent("fx_motels:syncRooms", -1, cachedData["motelRooms"])
                end
            else
                callback(false, "Couldn't insert in db.")
            end
        end)
    else
        callback(false, "Player doesn't exist.")
    end
end)

RemoveRoom = function(roomId)
    local sqlQuery = [[
        DELETE
            FROM
        fx_motels
            WHERE
        interiorId=@interiorId
    ]]
    MySQL.Async.execute(sqlQuery, {
        ["@interiorId"] = roomId,
    }, function(rowsChanged)
        if rowsChanged > 0 then
            cachedData["motelRooms"][roomId] = nil
            TriggerClientEvent("fx_motels:syncRooms", -1, cachedData["motelRooms"])
            Trace("[fx_motels] - Removed room " .. roomId)
        else
            Trace("[fx_motels] - Couldn't remove room " .. roomId)
        end
    end)
end

FX.RegisterCallback("fx_motels:updateStorage", function(source, callback, roomId, action)
    local player = FX.GetPlayerById(source)
    local done = false

    if not player then return callback(false) end
    if not action then return callback(false) end

    if action["store"] then
        local itemAmount = player.getInventoryItem(action["itemData"]["itemName"])["count"]

        if itemAmount and itemAmount >= action["itemData"]["itemAmount"] then
            if action["storageName"] then
                local storage = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]]["items"]

                for _, storageItems in ipairs(storage) do
                    if storageItems["item"] == action["itemData"]["itemName"] then
                        storageItems["amount"] = storageItems["amount"] + action["itemData"]["itemAmount"]
                        player.removeInventoryItem(action["itemData"]["itemName"], action["itemData"]["itemAmount"])

                        UpdateRoomData(roomId, function(updated)
                            if updated then
                                callback(true) 
                            else
                                callback(false, "Didn't update.")
                            end
                        end)
                        return
                    end
                end
                table.insert(storage, {
                    ["item"] = action["itemData"]["itemName"],
                    ["label"] = action["itemData"]["itemLabel"],
                    ["amount"] = action["itemData"]["itemAmount"]
                })
                player.removeInventoryItem(action["itemData"]["itemName"], action["itemData"]["itemAmount"])
                UpdateRoomData(roomId, function(updated)
                    if updated then
                        callback(true) 
                    else
                        callback(false, "Didn't update.")
                    end
                end)
                return
            else
                callback(false, "No storage specified.")
            end
        else
            callback(false, "You don't have that amount of that item.")
        end
    elseif action["take"] then
        if action["storageName"] then
            local storage = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]]["items"]

            for _, storageItems in ipairs(storage) do
                if storageItems["item"] == action["itemData"]["itemName"] then
                    if storageItems["amount"] >= action["itemData"]["itemAmount"] then
                        storageItems["amount"] = storageItems["amount"] - action["itemData"]["itemAmount"]
                        player.addInventoryItem(action["itemData"]["itemName"], action["itemData"]["itemAmount"])

                        if storageItems["amount"] == 0 then
                            table.remove(storage, _)
                        end

                        UpdateRoomData(roomId, function(updated)
                            if updated then
                                callback(true)
                                return
                            else
                                callback(false, "Didn't update.")
                                return
                            end
                        end)
                    else
                        callback(false, "Amount is higher than what is stored.")
                        return
                    end
                end
            end
        else
            callback(false, "Couldn't find storage.")
        end
    elseif action["storeCurrency"] then
        if action["storageName"] then
            local currency = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]]
            local currencyAmount = 0
            local currencyCallback

            if action["currency"] == "cash" then
                currencyAmount = Config.NewESX and player.getAccount("money")["money"] or player.getMoney()
                currencyCallback = function(amount)
                    cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]] = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]] + amount
                    player.removeMoney(amount)
                    UpdateRoomData(roomId, function(updated)
                        if updated then
                            callback(true)
                        else
                            callback(false, "Didn't update.")
                        end
                    end)
                end
            elseif action["currency"] == "black_money" then
                currencyAmount = player.getAccount(action["currency"])["money"]
                currencyCallback = function(amount)
                    cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]] = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]] + amount
                    player.removeAccountMoney(action["currency"], amount)
                    UpdateRoomData(roomId, function(updated)
                        if updated then
                            callback(true)
                        else
                            callback(false, "Didn't update.")
                        end
                    end)
                end
            end

            if currencyAmount >= action["amount"] then
                currencyCallback(action["amount"])
            else
                callback(false, "Not enough " .. action["cash"] and "cash on you." or "black money on you.")
            end
        else
            callback(false, "Couldn't find storage.")
        end
    elseif action["takeCurrency"] then
        if action["storageName"] then
            local currency = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]]
            local currencyAmount = 0
            local currencyCallback

            if action["currency"] == "cash" then
                currencyAmount = Config.NewESX and player.getAccount("money")["money"] or player.getMoney()
                currencyCallback = function(amount)
                    cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]] = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]] - amount
                    player.addMoney(amount)
                    UpdateRoomData(roomId, function(updated)
                        if updated then
                            callback(true)
                            return
                        else
                            callback(false, "Didn't update.")
                            return
                        end
                    end)
                end
            elseif action["currency"] == "black_money" then
                currencyAmount = player.getAccount(action["currency"])["money"]
                currencyCallback = function(amount)
                    cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]] = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][action["storageName"]][action["currency"]] - amount
                    player.addAccountMoney(action["currency"], amount)
                    UpdateRoomData(roomId, function(updated)
                        if updated then
                            callback(true)
                            return
                        else
                            callback(false, "Didn't update.")
                            return
                        end
                    end)
                end
            end

            if currency >= action["amount"] then
                currencyCallback(action["amount"])
            else
                callback(false, "Not enough " .. action["cash"] and "cash on you." or "black money on you.")
            end
        else
            callback(false, "Couldn't find storage.")
        end
    end
    TriggerClientEvent("fx_motels:syncRooms", -1, cachedData["motelRooms"])
end)


FX.RegisterCallback("fx_motels:fetchStorage", function(source, callback, roomId, storageName)
    local player = FX.GetPlayerById(source)

    if not player then return callback(false, "No player") end
    if not roomId or not storageName then return callback(false, "No room id or storageName") end
    
    local storage = cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][storageName]["items"]
    if storage and storage[1] then
        callback(cachedData["motelRooms"][roomId]["roomData"]["roomStorages"][storageName])
    else
        callback(false, "Couldn't find storage")
    end
end)


UpdateRoomData = function(roomId, callback)
    local sqlQuery = [[
        UPDATE
            fx_motels
        SET
            roomData = @roomData
        WHERE
            interiorId = @interiorId
    ]]

    MySQL.Async.execute(sqlQuery, {
        ["@roomData"] = json.encode(cachedData["motelRooms"][roomId]["roomData"]),
        ["@interiorId"] = roomId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            callback(true)
        else
            callback(false)
        end
    end)
end