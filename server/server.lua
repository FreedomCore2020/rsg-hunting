local RSGCore = exports['rsg-core']:GetCoreObject()

RSGCore.Functions.CreateUseableItem('basic_hunt_bait', function(source)
    local src = source
    TriggerClientEvent('rsg-hunting:server:useHuntingBait', src, 'basic_hunt_bait')
end)

RSGCore.Functions.CreateUseableItem('prime_hunt_bait', function(source)
    local src = source
    TriggerClientEvent('rsg-hunting:server:useHuntingBait', src, 'prime_hunt_bait')
end)

RegisterServerEvent('rsg-hunting::server:removeItem')
AddEventHandler("rsg-hunting::server:removeItem", function(item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src) 
    Player.Functions.RemoveItem(item, 1) 
end) 