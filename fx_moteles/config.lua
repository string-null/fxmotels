Config = {}

-- [General Settings] -- 
Config.AutoDatabaseCreator = true -- Once this script has been started once with this turned on true you can put it to false, this runs the code to create a database in databaseCreator.lua
Config.EnableKeySystem = true -- This is set to true if you have the resource fx-keys.
Config.NewESX = false -- Set this to true if you have the final esx version.
Config.DiscInventory = false -- Enable if you use disc inventorhud or want to use their ui for storage.
Config.EnableDebug = false

-- [Motel Settings] --
Config.RentTimer = 24 -- Time in hours, time between payments if rent mode is enabled.
Config.AutoRemoveRoom = Config.RentTimer * 7 -- This will remove the room after 7 missed payments.
Config.StoreCash = true -- Enable if you want player to be able to store cash in storage.
Config.StoreBlackMoney = true -- Enable if you want player to be able to store black money in storage.
Config.KeyPrice = 10 -- Price to purchase extra key.
Config.RaidJob = "police" -- The job you need to have to raid if you have raid enabled.
Config.RaidTimer = 10 -- Time in seconds that it takes for a police man to open up the door.
Config.RaidEnabled = true -- Enable this if you want police to have the ability to raid rooms.
Config.CancelRoomCommand = "oteliptal" -- Set to false if you don't want to have the ability to cancel room.

Config.Motels = {
     { -- Breze Sandy Motel
         ["motelName"] = "Hotel David", -- Name that appears in map as a blip.
         ["motelPosition"] = vector3(326.92, -210.41, 53.6), -- Position of motel.
         ["doorHash"] = -1156992775,
         ["doorOffset"] = vector3(1.0, 0.0, 0.0),
         ["motelPrice"] = 25, -- Price to buy if rentMode is false or the price you pay for the rent every time.
         ["rentMode"] = true, -- If true then rooms are only rented, if set to false you buy the room and no other charges are made afterwards.
         ["roomFinish"] = "sandy_motel",
         ["furniture"] = {
             ["drawer"] = {
                 ["restricted"] = false, -- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(2.85, -0.9, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Armario", -- Text that appears in 3D Text.
                 ["type"] = "storage", -- Set the type to storage if you want to be able to store stuff.
                 ["callback"] = function(interiorId, furnitureName)
                     OpenStash(interiorId, furnitureName)
                 end
             },
             ["wardrobe"] = {
                 ["restricted"] = false, -- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(-0.3, 2.6, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Armario de ropa",
                 ["callback"] = function(interiorId, furnitureName)
                     Wardrobe()
                 end
             },
             ["manager"] = {
                 ["restricted"] = true,-- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(-4.85, -1.3, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Gestión de habitaciones",
                 ["callback"] = function(interiorId, roomNumber, motelData)
                     RoomManagment(interiorId, roomNumber, motelData)
                 end
             },
         }
     },
	 { -- Breze Sandy Motel
         ["motelName"] = "Hotel COBO", -- Name that appears in map as a blip.
         ["motelPosition"] = vector3(-691.41, 5794.51, 22.35), -- Position of motel.
         ["doorHash"] = -664582244,
         ["doorOffset"] = vector3(-1.0, 0.0, 0.0),
         ["motelPrice"] = 25, -- Price to buy if rentMode is false or the price you pay for the rent every time.
         ["rentMode"] = true, -- If true then rooms are only rented, if set to false you buy the room and no other charges are made afterwards.
         ["roomFinish"] = "sandy_motel",
         ["furniture"] = {
             ["drawer"] = {
                 ["restricted"] = false, -- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(-0.5, -0.5, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Armario", -- Text that appears in 3D Text.
                 ["type"] = "storage", -- Set the type to storage if you want to be able to store stuff.
                 ["callback"] = function(interiorId, furnitureName)
                     OpenStash(interiorId, furnitureName)
                 end
             },
             ["wardrobe"] = {
                 ["restricted"] = false, -- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(-1, -3, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Armario de ropa",
                 ["callback"] = function(interiorId, furnitureName)
                     Wardrobe()
                 end
             },
             ["manager"] = {
                 ["restricted"] = true,-- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(1.85, -1.8, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Opciones de Habitacion",
                 ["callback"] = function(interiorId, roomNumber, motelData)
                     RoomManagment(interiorId, roomNumber, motelData)
                 end
             },
         }
     },
	 { -- Beach Motel
         ["motelName"] = "Hotel bambino", -- Name that appears in map as a blip.
         ["motelPosition"] = vector3(-1472.64, -659.33, 29.08), -- Position of motel.
         ["doorHash"] = -2123441472,
         ["doorOffset"] = vector3(-1.0, 0.0, 0.0),
         ["motelPrice"] = 25, -- Price to buy if rentMode is false or the price you pay for the rent every time.
         ["rentMode"] = true, -- If true then rooms are only rented, if set to false you buy the room and no other charges are made afterwards.
         ["roomFinish"] = "sandy_motel",
         ["furniture"] = {
             ["drawer"] = {
                 ["restricted"] = false, -- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(-1.7, 1.5, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Armario", -- Text that appears in 3D Text.
                 ["type"] = "storage", -- Set the type to storage if you want to be able to store stuff.
                 ["callback"] = function(interiorId, furnitureName)
                     OpenStash(interiorId, furnitureName)
                 end
             },
             ["wardrobe"] = {
                 ["restricted"] = false, -- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(-1.7, -0.5, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Armario de ropa",
                 ["callback"] = function(interiorId, furnitureName)
                     Wardrobe()
                 end
             },
             ["manager"] = {
                 ["restricted"] = true,-- If this should only be accesed by owner of room set to true
                 ["offset"] = vector3(1.3, -0.3, -0.4), -- Offsets coords from door to set position of furniture.
                 ["text"] = "Gestión de habitaciones",
                 ["callback"] = function(interiorId, roomNumber, motelData)
                     RoomManagment(interiorId, roomNumber, motelData)
                 end
             },
         }
     },
}

Config.RoomFinishes = { -- These are the interior designs you can change to in the room.
    {
        ["name"] = "Default design", -- Name that appears in menu.
        ["finish"] = "sandy_motel", -- Do not touch if you don't know what this is.
        ["price"] = 1 -- The price it cost to change to this interior.
    }
}