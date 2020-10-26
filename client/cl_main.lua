ESX,currentSelected,CurPolice = nil,nil,false
Citizen.CreateThread(function()
    RegisterNetEvent('lentokone:armor:equip')

    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0) 
    end

    local function loadOldData()
        ESX.TriggerServerCallback('lentokone:armor:GetSQL', function(data, police)
            if not (data == nil) and not (data == false) then 
                if ( tonumber(data['health']) < 10.0 ) then
                    SetEntityHealth(GetPlayerPed(-1),10.0)
                else
                    SetEntityHealth(GetPlayerPed(-1), data['health'])
                end
                
                if ( data.armour and data.armour > 0) then
                    SetPedArmour(GetPlayerPed(-1),  tonumber(data.armour))
                    if not (police ) then SetPropToPed(data.armourType) else CurPolice = true end
                currentSelected = data.armourType 
                end
            end
        end)
    end

    local function SetPropToPed(armortype)
        if ( armors[armortype] ) then
            SetPedComponentVariation(GetPlayerPed(-1), 9, armors[armortype]['drawid'], armors[armortype]['texture'], armors[armortype]['paletteId'])
            exports['mythic_notify']:SendAlert('success', 'Sinulla oli luotiliivit!', 3000)
        else
            print("[ERROR] bulletbroof not found")
        end
    end

    local function UpdatePlayerData()
        local insert = {}
        insert['health'] = GetEntityHealth(GetPlayerPed(-1))
    
        if not ( currentSelected == nil ) then
            insert['armour'] = GetPedArmour(GetPlayerPed(-1))
            insert['armourType'] = currentSelected
        end
        TriggerServerEvent('lentokone:armor:updateSQL', insert)
    end

    
    local function removeItem (item, amount) 
        ESX.TriggerServerCallback('lentokone:armor:addItem', function(status)
            if ( status ) then
                SetPedArmour(GetPlayerPed(-1), 0)
                SetPedComponentVariation(GetPlayerPed(-1), 9, 0, 0, 2)
                currentSelected = nil
                exports['mythic_notify']:SendAlert('error', 'Otit luotiliivit pois päältä!', 3000)
                UpdatePlayerData()
            end
        end, item, amount)
    end

    Citizen.CreateThread(function()
        while true do
            if ( currentSelected ~= nil and not CurPolice ) then
                local currentArmorProp = GetPedDrawableVariation(GetPlayerPed(-1), 9)
                if not ( currentArmorProp == armors[currentSelected]['drawid']) then
                    local CurArmor = GetPedArmour(GetPlayerPed(-1))
                    if ( CurArmor < armors[currentSelected]['armor']) then
                        if ( (CurArmor - 10) >= armors[currentSelected]['armor'] ) then
                            removeItem(armors[currentSelected]['itemname'], 1)
                        else
                            SetPedArmour(GetPlayerPed(-1), 0)
                            SetPedComponentVariation(GetPlayerPed(-1), 9, 0, 0, 2)
                            currentSelected = nil
                            exports['mythic_notify']:SendAlert('error', 'Otit luotiliivit pois päältä!', 3000)
                            UpdatePlayerData()
                        end
                    else
                        removeItem(armors[currentSelected]['itemname'], 1)
                    end
                end
                Wait(2000)
            else
                Wait(2000)
            end
        end
    end)

    AddEventHandler('playerDropped', function(reason)
        UpdatePlayerData()
    end)
    
    AddEventHandler('lentokone:armor:equip', function(type, police)
        CurPolice = police
        if ( armors[type] ) then
            if ( armors[type]['armor'] <= GetPedArmour(GetPlayerPed(-1)) ) then
                exports['mythic_notify']:SendAlert('error', 'Sinulla on jo luotiliivit päälläsi!', 3000)
            else
                local armorEquipt = true
                exports['mythic_progbar']:Progress({
                    name = "apply_bulletvest",
                    duration = armors[type]['equiptime'],
                    label = 'Puet luotiliivejä',
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovementSprint = true,
                        disableMovement = false,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    animation = {
                        animDict = "move_f@hiking",
                        anim = "idle_intro",
                        flags = 49,
                    }
                }, function(cancelled)
                    if not cancelled then
                        local d = armors[type]
                        ESX.TriggerServerCallback('lentokone:armor:RemoveItem', function(status)
                            if ( status ) then
                                if not police then 
                                    SetPedComponentVariation(GetPlayerPed(-1), 9, d['drawid'], d['texture'], d['paletteId'])
                                end
                                AddArmourToPed(GetPlayerPed(-1), d['armor'])
                                SetPedArmour(GetPlayerPed(-1), d['armor'])
                                currentSelected = type
                                armorEquipt = false
                                exports['mythic_notify']:SendAlert('success', 'Puit luotiliivit päällesi!', 3000)
                                UpdatePlayerData()
                            end
                        end, d['itemname'], 1)
                    else
                        armorEquipt = false
                        exports['mythic_notify']:SendAlert('error', 'Keskeytit luotiliivien pukemisen!', 3000)
                    end
                end)
        
                while armorEquipt do 
                    Wait(3)
                    DisableControlAction(0, 21, false) -- INPUT_SPRINT
                    DisableControlAction(0, 22, false) -- INPUT_JUMP
                    DisableControlAction(0, 137, false) -- INPUT_VEH_PUSHBIKE_SPRINT
                    -- DisableControlAction(0, 36, false) -- INPUT_DUCK
                end
            end
        end
    end)

    loadOldData()
end)