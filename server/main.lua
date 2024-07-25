local QBCore = exports['qb-core']:GetCoreObject()
local boobytraps = {}

local function TrapExsist(id)
    if boobytraps ~= nil then
        for _, data in pairs(boobytraps) do
            if data.id == id then return true end
        end
    end
    return false
end

local function CreateTrapList(data)
    if TrapExsist(data.id) then return end
    boobytraps[#boobytraps+1] = {
        id = data.id, 
        citizenid = data.citizenid, 
        radius = data.radius,
        gang = nil,
        enable = data.enable, 
        coords = json.decode(data.coords),
    }
end

local function GenerateMailId()
    return math.random(111111, 999999)
end

local function sendMail(data)
    local Player = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
    local mailData = {sender = Lang:t('mail.sender'), subject = Lang:t('mail.subject'), message = Lang:t('mail.message', {username = username})}
    if Player then
        MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {Player.PlayerData.citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
        TriggerClientEvent('qb-phone:client:NewMailNotify', Player.PlayerData.source, mailData)
        SetTimeout(200, function()
            local mails = MySQL.query.await('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` DESC',{Player.PlayerData.citizenid})
            TriggerClientEvent('qb-phone:client:UpdateMails', Player.PlayerData.source, mails)
        end)
    else
        TriggerEvent('qb-phone:server:sendNewMailToOffline', data.citizenid, mailData)
    end
end

local function IsBoobytrapOnLocation(coords)
    MySQL.Async.fetchAll("SELECT * FROM player_boobytraps", {}, function(rs)
        for k, v in pairs(rs) do
            if v ~= nil then
                local tmpCoords = json.decode(v.coords)
                local pos1 = vector3(coords.x, coords.y, coords.z)
                local pos2 = vector3(tmpCoords.x, tmpCoords.y, tmpCoords.z)
                local distance = #(pos1 - pos2)
                if distance < 2.0 then return true end
            end
        end
        return false
    end)
end

local function DeleteTrap(data)
    MySQL.Async.execute('DELETE FROM player_boobytraps WHERE id = ?', {data.id})
end

local function FindAllBoobytraps(id)
    if id == nil then id = -1 end
    boobytraps = {}
    MySQL.Async.fetchAll("SELECT * FROM player_boobytraps", {}, function(rs)
        for k, v in pairs(rs) do
            if v ~= nil then CreateTrapList(v) end
        end
        TriggerClientEvent('mh-boobytrap:client:update', -1)
    end)
end

QBCore.Functions.CreateCallback('mh-boobytrap:server:GetAllBoobytraps', function(source, cb)
    boobytraps = {}
    MySQL.Async.fetchAll("SELECT * FROM player_boobytraps", {}, function(rs)
        for k, v in pairs(rs) do
            if v ~= nil then CreateTrapList(v) end
        end
        cb(boobytraps)
    end)
end)

QBCore.Functions.CreateUseableItem('boobytrap', function(source)
    local src = source
    TriggerClientEvent('mh-boobytrap:server:addBoobytrap', src)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        boobytraps = {}
        MySQL.Async.fetchAll("SELECT * FROM player_boobytraps", {}, function(rs)
            for k, v in pairs(rs) do
                if v ~= nil then CreateTrapList(v) end
            end
        end)
    end
end)

RegisterServerEvent('mh-boobytrap:server:toggleBoobytrap', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        MySQL.Async.fetchAll("SELECT * FROM player_boobytraps WHERE id = ?", {data.id}, function(traps)
            if type(traps) == 'table' and #traps > 0 then
                for _, trap in pairs(traps) do
                    if trap.id == data.id then
                        if trap.enable == 1 then 
                            MySQL.Async.execute('UPDATE player_boobytraps SET enable = ? WHERE id = ?', {0, data.id})
                            TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.disable_trap'), "success", 5000)
                            FindAllBoobytraps(src)
                        else 
                            MySQL.Async.execute('UPDATE player_boobytraps SET enable = ? WHERE id = ?', {1, data.id})
                            TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.enable_trap'), "success", 5000)
                            FindAllBoobytraps(src)
                        end
                    end
                end
            end
        end)
    end
end)

RegisterServerEvent('mh-boobytrap:server:onjoin', function(coords)
    local src = source
    FindAllBoobytraps(src)
end)

RegisterServerEvent('mh-boobytrap:server:addBoobytrap', function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsBoobytrapOnLocation(coords) then
        MySQL.Async.execute("INSERT INTO player_boobytraps (citizenid, radius, coords, enable) VALUES (?, ?, ?, ?)", {
            Player.PlayerData.citizenid, 3, json.encode(coords), 1,
        })
        Player.Functions.RemoveItem('boobytrap', 1, nil)
	TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['boobytrap'], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.place_a_trap'), "success", 5000)
        FindAllBoobytraps(src)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('notify.cant_place_trap'), "error", 5000)
    end
end)

RegisterServerEvent('mh-boobytrap:server:pickup', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    DeleteTrap(data)
    Player.Functions.AddItem('boobytrap', 1, nil)
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['boobytrap'], 'add', 1)
    FindAllBoobytraps(src)
end)

RegisterServerEvent('mh-boobytrap:server:notifyOwner', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
    if Player then
        local target = QBCore.Functions.GetPlayer(src)
        local username = target.PlayerData.charinfo.firstname ..' '.. target.PlayerData.charinfo.lastname
        DeleteTrap(data)
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('notify.walk_in_to_trap',{username = username}), "success", 5000)
        FindAllBoobytraps()
    else
        sendMail(data)
    end
end)
