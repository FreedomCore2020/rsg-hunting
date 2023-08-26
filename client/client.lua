local RSGCore = exports['rsg-core']:GetCoreObject()
local Zones = {}
local zonename = NIL
local inHuntingZone = false
local baitLocation = nil
local spawnLocation = nil
local animal = {}

--------------------------------------------------------------------------------------------------

CreateThread(function() 
    for k=1, #Config.HuntingZones do
        Zones[k] = CircleZone:Create(Config.HuntingZones[k].coords,Config.HuntingZones[k].radius, {
            name = Config.HuntingZones[k].name,
            debugPoly=false,
        })
        Zones[k]:onPlayerInOut(function(isPointInside)
            if isPointInside then
                inHuntingZone = true
                zonename = Zones[k].name
                RSGCore.Functions.Notify(Lang:t('primary.enter_hunting_zone'), 'primary')
            else
                inHuntingZone = false
                zonename = NIL
                RSGCore.Functions.Notify(Lang:t('primary.left_hunting_zone'), 'primary')
            end
        end)
        if Config.HuntingZones[k].showblip == true then
            local HuntingBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, Config.HuntingZones[k].coords)
            local blipSprite = Config.HuntingZones[k].blipSprite
            SetBlipSprite(HuntingBlip, Config.HuntingZones[k].blipSprite, true)
            SetBlipScale(HuntingBlip, Config.HuntingZones[k].blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, HuntingBlip, Config.HuntingZones[k].blipName)
        end
    end
end)

-- spawn location
local function getSpawnLoc()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local spawnCoords = nil
    while spawnCoords == nil do
        local spawnX = math.random(-Config.SpawnDistanceRadius, Config.SpawnDistanceRadius)
        local spawnY = math.random(-Config.SpawnDistanceRadius, Config.SpawnDistanceRadius)
        local spawnZ = baitLocation.z
        local vec = vector3(baitLocation.x + spawnX, baitLocation.y + spawnY, spawnZ)
        if #(playerCoords - vec) > Config.SpawnDistanceRadius then
            spawnCoords = vec
        end
    end
    local worked, groundZ, normal = GetGroundZAndNormalFor_3dCoord(spawnCoords.x, spawnCoords.y, 1023.9)
    spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ)
    return spawnCoords
end

RegisterNetEvent('rsg-hunting:server:useHuntingBait', function(item)
    if inHuntingZone == true then
        if item == 'basic_hunt_bait' then
            local ped = PlayerPedId()
            baitLocation = GetEntityCoords(PlayerPedId())
            spawnLocation = getSpawnLoc()
            TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
            Wait(10000)
            ClearPedTasks(ped)
            TriggerServerEvent('rsg-hunting::server:removeItem', 'basic_hunt_bait')
            RSGCore.Functions.Notify(Lang:t('primary.bait_set'), 'primary')
            Wait(Config.HideTime)
            local spawnanimal = Config.BasicHuntingAnimals[math.random(#Config.BasicHuntingAnimals)]
            local model = spawnanimal
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
            animal = CreatePed(model, spawnLocation.x, spawnLocation.y, spawnLocation.z, true, true, true)
            Citizen.InvokeNative(0x283978A15512B2FE, animal, true)
            Citizen.InvokeNative(0xDC19C288082E586E, animal, true, false)
            TaskGoStraightToCoord(animal, baitLocation.x, baitLocation.y, baitLocation.z, 1.0, -1, 0.0, 0.0)
            SetModelAsNoLongerNeeded(spawnanimal)
            CreateThread(function()
                local finished = false
                while not IsPedDeadOrDying(animal) and not finished do
                    local spawnedAnimalCoords = GetEntityCoords(animal)
                    local distance = #(baitLocation - spawnedAnimalCoords)
                    if distance < 1.0 then
                        Wait(Config.AnimalWait)
                        Citizen.InvokeNative(0xBB9CE077274F6A1B, animal, 10.0, 10)
                        finished = true
                    end
                    Wait(1000)
                end
            end)
        end
        if item == 'prime_hunt_bait' then
            local ped = PlayerPedId()
            baitLocation = GetEntityCoords(PlayerPedId())
            spawnLocation = getSpawnLoc()
            TaskStartScenarioInPlace(ped, `WORLD_HUMAN_CROUCH_INSPECT`, 0, true)
            Wait(10000)
            ClearPedTasks(ped)
            TriggerServerEvent('rsg-hunting::server:removeItem', 'prime_hunt_bait')
            RSGCore.Functions.Notify(Lang:t('primary.bait_set'), 'primary')
            Wait(Config.HideTime)
            local spawnanimal = Config.PrimeHuntingAnimals[math.random(#Config.PrimeHuntingAnimals)]
            local model = spawnanimal
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
            animal = CreatePed(model, spawnLocation.x, spawnLocation.y, spawnLocation.z, true, true, true)
            Citizen.InvokeNative(0x283978A15512B2FE, animal, true)
            Citizen.InvokeNative(0xDC19C288082E586E, animal, true, false)
            TaskGoStraightToCoord(animal, baitLocation.x, baitLocation.y, baitLocation.z, 1.0, -1, 0.0, 0.0)
            SetModelAsNoLongerNeeded(spawnanimal)
            CreateThread(function()
                local finished = false
                while not IsPedDeadOrDying(animal) and not finished do
                    local spawnedAnimalCoords = GetEntityCoords(animal)
                    local distance = #(baitLocation - spawnedAnimalCoords)
                    if distance < 1.0 then
                        Wait(Config.AnimalWait)
                        Citizen.InvokeNative(0xBB9CE077274F6A1B, animal, 10.0, 10)
                        finished = true
                    end
                    Wait(1000)
                end
            end)
        end
    else
        RSGCore.Functions.Notify(Lang:t('error.cant_use'), 'error')
    end
end)
