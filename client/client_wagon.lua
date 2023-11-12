local RSGCore = exports['rsg-core']:GetCoreObject()
local hutingwagonspawned = false
local currentHuntingWagon = nil
local currentHuntinPlate = nil
local closestWagonStore = nil

-------------------------------------------------------------------------------------------
-- prompts and blips if needed
-------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    for _, v in pairs(Config.HunterLocations) do
        exports['rsg-core']:createPrompt(v.location, v.coords, RSGCore.Shared.Keybinds[Config.HunterKeybind], 'Open Hunter Menu', {
            type = 'client',
            event = 'rsg-hunting:client:openhuntermenu',
            args = { v.location, v.wagonspawn},
        })
        if v.showblip == true then
            local HunterBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
            SetBlipSprite(HunterBlip,  joaat(Config.Blip.blipSprite), true)
            SetBlipScale(Config.Blip.blipScale, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, HunterBlip, Config.Blip.blipName)
        end
    end
end)

-------------------------------------------------------------------------------------------
-- hunter camp main menu
-------------------------------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:openhuntermenu', function(location, wagonspawn)

    lib.registerContext({
        id = 'hunter_mainmenu',
        title = 'Hunter Wagon Menu',
        options = {
            {
                title = 'Buy Hunter Wagon ($'..Config.WagonPrice..')',
                description = 'buy a hunter wagon',
                icon = 'fa-solid fa-horse-head',
                serverEvent = 'rsg-hunting:server:buyhuntingcart',
                args = { huntingcamp = location },
                arrow = true
            },
            {
                title = 'Spawn Hunting Wagon',
                description = 'spawn your hunting wagaon',
                icon = 'fa-solid fa-eye',
                event = 'rsg-hunting:client:spawnwagon',
                args = { huntingcamp = location, spawncoords = wagonspawn },
                arrow = true
            },
        }
    })
    lib.showContext('hunter_mainmenu')

end)

---------------------------------------------------------------------
-- get wagon
---------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:spawnwagon', function(data)
    RSGCore.Functions.TriggerCallback('rsg-hunting:server:getwagons', function(results)

        if results == nil then return lib.notify({ title = 'No Wagons', description = 'you have no wagson stored here', type = 'inform', duration = 5000 }) end
        if hutingwagonspawned then return lib.notify({ title = 'Hunting Wagon Out', description = 'your hunting wagon is already out!', type = 'error', duration = 5000 }) end
        
        for i = 1, #results do
            local wagon = results[i]

            if wagon.huntingcamp == data.huntingcamp then
                
                local carthash = joaat('huntercart01')
                local propset = joaat('pg_mp005_huntingWagonTarp01')
                local lightset = joaat('pg_teamster_cart06_lightupgrade3')

                if IsModelAVehicle(carthash) then
                    Citizen.CreateThread(function()
                        RequestModel(carthash)
                        while not HasModelLoaded(carthash) do
                            Citizen.Wait(0)
                        end
                        local huntingcart = CreateVehicle(carthash, data.spawncoords, true, false)
						Citizen.InvokeNative(0x06FAACD625D80CAA, huntingcart)
                        SetVehicleOnGroundProperly(huntingcart)
                        currentHuntingWagon = huntingcart
                        currentHuntingPlate = wagon.plate
                        Wait(200)
                        Citizen.InvokeNative(0x75F90E4051CC084C, huntingcart, propset) -- AddAdditionalPropSetForVehicle
                        Citizen.InvokeNative(0xC0F0417A90402742, huntingcart, lightset) -- AddLightPropSetToVehicle
                        Citizen.InvokeNative(0xF89D82A0582E46ED, huntingcart, 5) -- SetVehicleLivery
                        Citizen.InvokeNative(0x8268B098F6FCA4E2, huntingcart, 2) -- SetVehicleTint
                        Citizen.InvokeNative(0x06FAACD625D80CAA, huntingcart) -- NetworkRegisterEntityAsNetworked

                        --Citizen.InvokeNative(0x31F343383F19C987, huntingcart, 1.0, 1)

                        SetEntityVisible(huntingcart, true)
                        SetModelAsNoLongerNeeded(carthash)

                        Wait(1000)

                        -- set hunting wagon tarp
                        RSGCore.Functions.TriggerCallback('rsg-hunting:server:gettarpinfo', function(results)
                            local percentage = results * Config.TotalAnimalsStored / 100
                            Citizen.InvokeNative(0x31F343383F19C987, huntingcart, tonumber(percentage), 1)
                        end, wagon.plate)

                        lib.notify({ title = 'Hunting Wagon Spawned', description = 'your hunting is now out!', type = 'inform', duration = 5000 })
                        hutingwagonspawned = true
                        
                    end)
                end
            else
                lib.notify({ title = 'No Wagon Stored Here', description = 'you don\'t have a wagon stored here!', type = 'inform', duration = 5000 })
            end
        end
    end)
end)

---------------------------------------------------------------------
-- get wagon
---------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Wait(1)
        if hutingwagonspawned == true then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local wagonpos = GetEntityCoords(currentHuntingWagon)
            local dist = #(pos - wagonpos)
            inRange = false
            if dist < 3.0 then
                inRange = true
                lib.showTextUI('[J] Open Hunting Wagon Menu', {
                    position = "top-center",
                    icon = 'fa-solid fa-bars',
                    style = {
                        borderRadius = 0,
                        backgroundColor = '#82283E',
                        color = 'white'
                    }
                })
                if IsControlJustReleased(0, RSGCore.Shared.Keybinds['J']) then
                    TriggerEvent('rsg-hunting:client:openmenu')
                end
            else
                lib.hideTextUI()
            end
            if not inRange then
                Wait(2500)
            end
        end
    end
end)

---------------------------------------------------------------------
-- get closest hunter camp to store wagon
---------------------------------------------------------------------
local function SetClosestStoreLocation()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil

    for k, v in pairs(Config.HunterLocations) do
        local dest = vector3(v.coords.x, v.coords.y, v.coords.z)
        local dist2 = #(pos - dest)

        if current then
            if dist2 < dist then
                current = v.location
                dist = dist2
            end
        else
            dist = dist2
            current = v.location
        end
    end

    if current ~= closestWagonStore then
        closestWagonStore = current
    end
end

---------------------------------------------------------------------
-- store wagon
---------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:storewagon', function(data)
    if hutingwagonspawned then
        DeleteVehicle(currentHuntingWagon)
        SetEntityAsNoLongerNeeded(currentHuntingWagon)
        hutingwagonspawned = false
        SetClosestStoreLocation()
        TriggerServerEvent('rsg-hunting:client:updatewagonstore', closestWagonStore)
        lib.hideTextUI()
    end
end)

---------------------------------------------------------------------
-- hutning wagon menu
---------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:openmenu', function(data)
	local sellprice = (Config.WagonPrice * Config.WagonSellRate)
    lib.registerContext({
        id = 'hunterwagon_menu',
        title = 'Hunter Wagon Menu',
        options = {
            {
                title = 'Store Animal',
                description = 'store your animal',
                icon = 'fa-solid fa-circle-down',
                iconColor = 'green',
                event = 'rsg-hunting:client:addanimal',
                args = { plate = currentHuntingPlate },
                arrow = true
            },
            {
                title = 'Hunting Wagon Animal Store',
                description = 'view your animals you have stored',
                icon = 'fa-solid fa-circle-up',
                iconColor = 'red',
                event = 'rsg-hunting:client:getHuntingWagonStore',
                args = { plate = currentHuntingPlate },
                arrow = true
            },
            {
                title = 'Hunting Wagon Inventory',
                description = 'view your hunting wagon inventory',
                icon = 'fa-solid fa-box',
                iconColor = 'yellow',
                event = 'rsg-hunting:client:getHuntingWagonInventory',
                args = { plate = currentHuntingPlate },
                arrow = true
            },
            {
                title = 'Store Hunting Wagon',
                description = 'put your hunting wagaon away',
                icon = 'fa-solid fa-circle-xmark',
                event = 'rsg-hunting:client:storewagon',
                arrow = true
            },
            {
                title = 'Sell Hunting Wagon ($'..sellprice..')',
                description = 'sell your hunting wagon',
                icon = 'fa-solid fa-dollar-sign',
                iconColor = 'red',
                event = 'rsg-hunting:client:sellwagoncheck',
                args = { plate = currentHuntingPlate },
                arrow = true
            },
        }
    })
    lib.showContext('hunterwagon_menu')

end)

---------------------------------------------------------------------
-- sell wagon check
---------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:sellwagoncheck', function(data)
    local input = lib.inputDialog('Hunting Wagon Sell Check', {
        { 
            label = 'Are you sure you want to sell?',
            type = 'select',
            options = { 
                { value = 'yes', label = 'Yes' },
                { value = 'no', label = 'No' }
            },
            required = true,
            icon = 'fa-solid fa-circle-question'
        },
    })

    if not input then
        return
    end

    if input[1] == 'no' then
        return
    end

    if input[1] == 'yes' then
        TriggerServerEvent('rsg-hunting:server:sellhuntingcart', data.plate )
		if hutingwagonspawned then
			DeleteVehicle(currentHuntingWagon)
			SetEntityAsNoLongerNeeded(currentHuntingWagon)
			hutingwagonspawned = false
			lib.hideTextUI()
		end
    end
end)

---------------------------------------------------------------------
-- add animal to the database
---------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:addanimal', function(data)
    local ped = PlayerPedId()
    local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
    local holdinghash = GetEntityModel(holding)
    local holdinganimal = Citizen.InvokeNative(0x9A100F1CF4546629, holding)
    local holdinglooted = Citizen.InvokeNative(0x8DE41E9902E85756, holding)

    if Config.Debug == true then
        print("holding: "..tostring(holding))
        print("holdinghash: "..tostring(holdinghash))
        print("holdinganimal: "..tostring(holdinganimal))
        print("wagon: "..tostring(data.plate))
        print("holdinglooted: "..tostring(holdinglooted))
    end

    if holding ~= false and holdinganimal == 1 then
        for i = 1, #Config.Animals do
            if Config.Animals[i].modelhash == holdinghash then
                local modelhash = Config.Animals[i].modelhash
                local modellabel = Config.Animals[i].modellabel
                local modellooted = holdinglooted
                local deleted = DeleteThis(holding)
                if deleted then
                    TriggerServerEvent('rsg-hunting:server:addanimal', modelhash, modellabel, modellooted, data.plate)
                else
                    lib.notify({ title = 'Something Went Wrong!', description = 'something went wrong while deleting the animal!', type = 'error', duration = 5000 })
                end
            end
        end
    end
    
    -- update hunting wagon tarp
    RSGCore.Functions.TriggerCallback('rsg-hunting:server:gettarpinfo', function(results)
        local change = (results + 1)
        local percentage = change * Config.TotalAnimalsStored / 100
        Citizen.InvokeNative(0x31F343383F19C987, currentHuntingWagon, tonumber(percentage), 1)
    end, currentHuntingPlate)
    
end)

---------------------------------------------------------------------
-- delete animal player is holding
---------------------------------------------------------------------
function DeleteThis(holding)
    NetworkRequestControlOfEntity(holding)
    SetEntityAsMissionEntity(holding, true, true)
    Wait(100)
    DeleteEntity(holding)
    Wait(500)
    local entitycheck = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
    local holdingcheck = GetPedType(entitycheck)
    if holdingcheck == 0 then
        return true
    else
        return false
    end
end

---------------------------------------------------------------------
-- get what is stored in the hunting wagon / remove carcus
---------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:getHuntingWagonStore', function(data)
    RSGCore.Functions.TriggerCallback('rsg-hunting:server:getwagonstore', function(results)
        local options = {}
        for k, v in ipairs(results) do
            options[#options + 1] = {
                title = v.animallabel,
                description = '',
                icon = 'fa-solid fa-box',
                serverEvent = 'rsg-hunting:server:removeanimal',
                args = {
                    id = v.id,
                    plate = v.plate,
                    animallooted = v.animallooted,
                    animalhash = v.animalhash,
                },
                arrow = true,
            }
        end
        lib.registerContext({
            id = 'hunting_inv_menu',
            title = 'Hunting Wagon Inventory',
            position = 'top-right',
            options = options
        })
        lib.showContext('hunting_inv_menu')
    end, data.plate)
end)

---------------------------------------------------------------------
-- takeout animal
---------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:takeoutanimal', function(animalhash, animallooted)
    local pos = GetOffsetFromEntityInWorldCoords(currentHuntingWagon, 0.0, -3.0, 0.0)
    
    modelHash = tonumber(animalhash)

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end
    end

    animal = CreatePed(modelHash, pos.x, pos.y, pos.z, true, true, true)
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, animal, 0, false)

    if animallooted == 1 then
        Citizen.InvokeNative(0x6BCF5F3D8FFE988D, animal, animallooted)
        SetEntityHealth(animal, 0, 0)
        SetEntityAsMissionEntity(animal, true, true)
    else
        SetEntityHealth(animal, 0, 0)
        SetEntityAsMissionEntity(animal, true, true)
    end
    
    -- update hunting wagon tarp
    RSGCore.Functions.TriggerCallback('rsg-hunting:server:gettarpinfo', function(results)
        local change = (results - 1)
        local percentage = change * Config.TotalAnimalsStored / 100
        Citizen.InvokeNative(0x31F343383F19C987, currentHuntingWagon, tonumber(percentage), 1)
    end, currentHuntingPlate)

end)

---------------------------------------------------------------------
-- hunting wagon storage
---------------------------------------------------------------------
RegisterNetEvent('rsg-hunting:client:getHuntingWagonInventory', function(data)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", data.plate, { maxweight = Config.WagonInventoryMaxWeight, slots = Config.WagonInventorySlots })
    TriggerEvent("inventory:client:SetCurrentStash", data.plate)
end)
