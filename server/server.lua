local RSGCore = exports['rsg-core']:GetCoreObject()

-----------------------------------------------------------------------
-- version checker
-----------------------------------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'

    print(('^5['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Rexshack-RedM/rsg-hunting/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end

        --versionCheckPrint('success', ('Current Version: %s'):format(currentVersion))
        --versionCheckPrint('success', ('Latest Version: %s'):format(text))
        
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

-----------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()
