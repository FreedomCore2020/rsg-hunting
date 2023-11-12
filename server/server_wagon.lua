local RSGCore = exports['rsg-core']:GetCoreObject()

----------------------------------------------------
-- buy and add hunting cart
----------------------------------------------------
RegisterServerEvent('rsg-hunting:server:buyhuntingcart', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local cashBalance = Player.PlayerData.money["cash"]
    if cashBalance >= Config.WagonPrice then
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM hunting_wagons WHERE citizenid = ?", { citizenid })
        if result == 0 then
            local plate = GeneratePlate()
            MySQL.insert('INSERT INTO hunting_wagons(citizenid, plate, huntingcamp, active) VALUES(@citizenid, @plate, @huntingcamp, @active)', {
                ['@citizenid'] = citizenid,
                ['@plate'] = plate,
                ['@huntingcamp'] = data.huntingcamp,
                ['@active'] = 1,
            })
            Player.Functions.RemoveMoney("cash", Config.WagonPrice, "hunting-wagon")
            TriggerClientEvent('ox_lib:notify', src, {title = 'Wagon Purchased', description = 'you successfully purchased a hunting wagon', type = 'success', duration = 5000 })
        else
            TriggerClientEvent('ox_lib:notify', src, {title = 'Wagon Limit Reached', description = 'you have reached the limit of wagons allowed!', type = 'error', duration = 5000 })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Not Enough Cash', description = 'you don\'t have enough cash to do that!', type = 'error', duration = 5000 })
    end
end)

----------------------------------------------------
-- get wagons
----------------------------------------------------
RSGCore.Functions.CreateCallback('rsg-hunting:server:getwagons', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local wagon = MySQL.query.await('SELECT * FROM hunting_wagons WHERE citizenid=@citizenid', { ['@citizenid'] = citizenid })
    if wagon[1] == nil then return end
    cb(wagon)
end)

----------------------------------------------------
-- get wagon store
----------------------------------------------------
RSGCore.Functions.CreateCallback('rsg-hunting:server:getwagonstore', function(source, cb, plate)
    local wagonstore = MySQL.query.await('SELECT * FROM hunting_inventory WHERE plate=@plate', { ['@plate'] = plate })
    if wagonstore[1] == nil then return end
    cb(wagonstore)
end)

----------------------------------------------------
-- get tarp info
----------------------------------------------------
RSGCore.Functions.CreateCallback('rsg-hunting:server:gettarpinfo', function(source, cb, plate)
    local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM hunting_inventory WHERE plate = ?", { plate })
    cb(result)
end)

----------------------------------------------------
-- store hunting wagon
----------------------------------------------------
RegisterServerEvent('rsg-hunting:client:updatewagonstore', function(location)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local newLocation = MySQL.query.await('UPDATE hunting_wagons SET huntingcamp = ? WHERE citizenid = ?' , { location, citizenid })

    if newLocation == nil then
        TriggerClientEvent('ox_lib:notify', src, {title = 'Failed', description = 'failed to store hunting cart in new location!', type = 'error', duration = 5000 })
        return
    end
    
    TriggerClientEvent('ox_lib:notify', src, {title = 'Hunting Wagon Stored', description = 'you hunting wagon was stored at '..location, type = 'success', duration = 5000 })
end)

----------------------------------------------------
-- add holding animal to database
----------------------------------------------------
RegisterServerEvent('rsg-hunting:server:addanimal', function(animalhash, animallabel, animallooted, plate)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM hunting_inventory WHERE plate = ?", { plate })
    if result < Config.TotalAnimalsStored then
        MySQL.insert('INSERT INTO hunting_inventory(animalhash, animallabel, animallooted, citizenid, plate) VALUES(@animalhash, @animallabel, @animallooted, @citizenid, @plate)', {
            ['@animalhash'] = animalhash,
            ['@animallabel'] = animallabel,
            ['@animallooted'] = animallooted,
            ['@citizenid'] = citizenid,
            ['@plate'] = plate
        })
        TriggerClientEvent('ox_lib:notify', src, {title = 'Animal Stored', description = animallabel..' stored successfully!', type = 'success', duration = 5000 })
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Max Animals Stored', description = 'you have the maximum of '..Config.TotalAnimalsStored..' animals stored!', type = 'error', duration = 5000 })
    end
end)

RegisterServerEvent('rsg-hunting:server:removeanimal', function(data)
    local src = source
    MySQL.update('DELETE FROM hunting_inventory WHERE id = ? AND plate = ?', { data.id, data.plate })
    TriggerClientEvent('rsg-hunting:client:takeoutanimal', src, data.animalhash, data.animallooted)
end)

----------------------------------------------------
-- sell hunting wagon
----------------------------------------------------
RegisterServerEvent('rsg-hunting:server:sellhuntingcart')
AddEventHandler('rsg-hunting:server:sellhuntingcart', function(plate)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    local sellPrice = (Config.WagonPrice * Config.WagonSellRate)

    local wagon = MySQL.query.await("SELECT * FROM hunting_wagons WHERE citizenid=@citizenid AND plate=@plate", {
        ['@citizenid'] = citizenid,
        ['@plate'] = plate
    })

    if wagon[1] then
        MySQL.update('DELETE FROM hunting_wagons WHERE id = ?', { wagon[1].id })
        MySQL.update('DELETE FROM stashitems WHERE stash = ?', { wagon[1].plate })
        Player.Functions.AddMoney('cash', sellPrice, 'hunting-wagon-sell')
        TriggerClientEvent('ox_lib:notify', src, { title = 'Wagon Sold', description = 'you sold your hunting wagon for $' .. sellPrice, type = 'success', duration = 5000 })
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'No Wagon Found', description = 'you don\'t have a hunting wagon to sell!', type = 'error', duration = 5000 })
    end
end)

----------------------------------------------------
-- generate wagon plate
----------------------------------------------------
function GeneratePlate()
    local UniqueFound = false
    local plate = nil
    while not UniqueFound do
        plate = tostring(RSGCore.Shared.RandomStr(3) .. RSGCore.Shared.RandomInt(3)):upper()
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM hunting_wagons WHERE plate = ?", { plate })
        if result == 0 then
            UniqueFound = true
        end
    end
    return plate
end
