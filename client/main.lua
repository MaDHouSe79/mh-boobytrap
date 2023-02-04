local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local boobytraps = {}
local explode = false
local isBisy = false

local function PlaceBoobytrap(coords)
    local ped = PlayerPedId()
    isBisy = true
    QBCore.Functions.Progressbar("arming_boobytrap", Lang:t('progressbar.place_trap'), 8000, false, true,{
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@",
        anim = "weed_spraybottle_crouch_base_inspector"
    }, {}, {}, function() -- Done
        ClearPedTasksImmediately(ped)
        TriggerServerEvent('mh-boobytrap:server:addBoobytrap', coords)
        isBisy = false
    end, function()
        isBisy = false
        ClearPedTasks(ped)
    end)
end

local function PickupBoobytrap(data)
    isBisy = true
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("arming_boobytrap", Lang:t('progressbar.pickup_trap'), 8000, false, true,{
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@",
        anim = "weed_spraybottle_crouch_base_inspector"
    }, {}, {}, function() -- Done
        isBisy = false
        ClearPedTasksImmediately(ped)
        TriggerServerEvent("mh-boobytrap:server:pickup", data)
    end, function()
        isBisy = false
        ClearPedTasks(ped)
    end)
end

local function ToggleBoobytrap(data)
    TriggerServerEvent("mh-boobytrap:server:toggleBoobytrap", data)
end

local function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

local function DisplayHelpText(text)
    drawTxt(text, 8, 0.5, 0.90, 0.30, 255, 255, 255, 180)
end

local function Timeout()
    SetTimeout(5000, function() explode = false end)
end

local function IsAtBoobytrapPosition()
    local coords = GetEntityCoords(PlayerPedId())
    for _, data in pairs(boobytraps) do
        if data.citizenid ~= PlayerData.citizenid then
            local distance = #(vector3(coords.x,coords.y, coords.z) - vector3(data.coords.x, data.coords.y, data.coords.z))
            if distance <= tonumber(data.radius) and data.enable == 1 then
                if not explode then
                    explode = true
                    data.enable = 0
                    AddExplosion(coords.x, coords.y, coords.z, 5, 50.0, true, false, true)
                    TriggerServerEvent('mh-boobytrap:server:notifyOwner', data)
                    Timeout()
                end
            end
        end
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = QBCore.Functions.GetPlayerData()
        TriggerServerEvent('mh-boobytrap:server:onjoin')
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent('mh-boobytrap:server:onjoin')
end)

RegisterNetEvent('mh-boobytrap:client:update', function()
    boobytraps = {}
    QBCore.Functions.TriggerCallback('mh-boobytrap:server:GetAllBoobytraps', function(boobytrapList)
        boobytraps = boobytrapList
    end)
end)

RegisterNetEvent('mh-boobytrap:server:addBoobytrap', function()
    local coords = GetEntityCoords(PlayerPedId())
    PlaceBoobytrap(coords)
end)

CreateThread(function()
	while true do
        IsAtBoobytrapPosition()
		Wait(1000)
	end
end)

CreateThread(function()
	while true do
		Wait(0)
        local coords = GetEntityCoords(PlayerPedId())
        if boobytraps ~= nil then
            for _, data in pairs(boobytraps) do
                if data.citizenid == PlayerData.citizenid then
                    local distance = #(vector3(coords.x,coords.y, coords.z) - vector3(data.coords.x, data.coords.y, data.coords.z))
                    if distance <= 10 and not isBisy then
                        DrawMarker(27, data.coords.x, data.coords.y, data.coords.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 200, false, false, false, true, false, false, false)
                        if data.enable == 1 then
                            local enable = {r = 17, g = 255, b = 0}
                            DrawMarker(2, data.coords.x, data.coords.y, data.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, enable.r, enable.g, enable.b, 222, false, false, false, true, false, false, false)
                        end
                        if data.enable == 0 then
                            local disable = {r = 255, g = 0, b = 0}
                            DrawMarker(2, data.coords.x, data.coords.y, data.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, disable.r, disable.g, disable.b, 222, false, false, false, true, false, false, false)
                        end
                        if distance > 2.0 then
                            DisplayHelpText(Lang:t('help.press_e_to_toggle'))
                            if IsControlJustReleased(0, 47) then ToggleBoobytrap(data)  end
                        end
                    end
                    if distance <= 2.0 and not isBisy then
                        DisplayHelpText(Lang:t('help.press_e_to_pickup'))
                        if IsControlJustReleased(0, 38) then 
                            PickupBoobytrap(data) 
                        end
                    end
                end
            end
        end
    end
end)