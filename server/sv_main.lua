ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local policeJob = "police"
ESX.RegisterUsableItem('bulletprooflight', function(source)
    local police,xPlayer = false,ESX.GetPlayerFromId(source)
    if ( xPlayer.getJob().name == policeJob ) then
        police = true
    end
    TriggerClientEvent('lentokone:armor:equip', xPlayer.source, 'bulletprooflight', police)
end)

ESX.RegisterUsableItem('bulletproof', function(source)
    local police,xPlayer = false,ESX.GetPlayerFromId(source)
    if ( xPlayer.getJob().name == policeJob ) then
        police = true
    end
    TriggerClientEvent('lentokone:armor:equip', xPlayer.source, 'bulletproof', police)
end)

ESX.RegisterUsableItem('bulletproofhard', function(source) 
    local police,xPlayer = false,ESX.GetPlayerFromId(source)
    if ( xPlayer.getJob().name == policeJob ) then
        police = true
    end
    TriggerClientEvent('lentokone:armor:equip', xPlayer.source, 'bulletproofhard', police)
end)

ESX.RegisterServerCallback('lentokone:armor:addItem', function(source, cb, itemname, count)
    if ( itemname ) then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem(itemname, count)
        cb(true)
        
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('lentokone:armor:RemoveItem', function(source, cb, itemname, count)
    if ( itemname ) then
        local xPlayer = ESX.GetPlayerFromId(source)
        if ( xPlayer.getInventoryItem(itemname).count >= count ) then
            xPlayer.removeInventoryItem(itemname, count)
            cb(true)
        else
            xPlayer.showNotification('~r~Sinulla ei ole mitä poistaa!')
            cb(false)
        end
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('lentokone:armor:getItemAmount', function(source, cb, itemname)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getInventoryItem(itemname).count)
end)

ESX.RegisterServerCallback('lentokone:armor:GetSQL', function(source, cb)
    local police,xPlayer = false,ESX.GetPlayerFromId(source)
    if ( xPlayer.getJob().name == policeJob ) then
        police = true
    end

    MySQL.Async.fetchAll('SELECT data FROM users WHERE identifier = @identifier LIMIT 1', { ['identifier'] = xPlayer.identifier }, function(result)
        if ( result[1]['data'] ) then 
            cb(json.decode(result[1]['data']), police)
        end
    end)
end)

RegisterServerEvent('lentokone:armor:updateSQL')
AddEventHandler('lentokone:armor:updateSQL', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('UPDATE users SET data = @data WHERE identifier = @identifier',
        { ['data']= json.encode(data), ['identifier'] = xPlayer.identifier }
    )
end)
