Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local coords = GetEntityCoords(PlayerPedId(), true)
        for k in pairs(Config.Zones) do
            if GetDistanceBetweenCoords(Config.Zones[k].x, Config.Zones[k].y, Config.Zones[k].z, coords) < 1 then
                Marker("~w~[~r~E~w~] Buy food", 27, Config.Zones[k].x, Config.Zones[k].y, Config.Zones[k].z - 0.99)
                if IsControlJustReleased(0, Keys['E']) then
                    FoodMeny()
                end
            elseif GetDistanceBetweenCoords(Config.Zones[k].x, Config.Zones[k].y, Config.Zones[k].z, coords) < 10 then
                Marker("~w~Buy food", 27, Config.Zones[k].x, Config.Zones[k].y, Config.Zones[k].z - 0.99)
            end
        end
    end
end)

function FoodMeny()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'foodstand',
        {
            title    = 'Food Stand',
            align    = 'center',
            elements = {
                {label = 'Hotdog <span style="color:green"> ' .. Config.EatPrice ..':-</span> ',                  prop = 'prop_cs_hotdog_01',    type = 'food'},
                {label = 'Burger <span style="color:green"> ' .. Config.EatPrice ..':-</span>',                   prop = 'prop_cs_burger_01',    type = 'food'},
                {label = 'Sandwich <span style="color:green"> ' .. Config.EatPrice ..':-</span>',                 prop = 'prop_sandwich_01',     type = 'food'},
                {label = 'Sparkling Water 50cl <span style="color:green"> ' .. Config.DrinkPrice ..':-</span>',   prop = 'prop_ld_flow_bottle',  type = 'drink'},
                {label = 'Coca Cola 33cl<span style="color:green"> ' .. Config.DrinkPrice ..':-</span>',          prop = 'prop_ecola_can',       type = 'drink'},
            }
        }, function(data, menu)
            local selected = data.current.type
            if selected == 'food' then
                ESX.TriggerServerCallback("gamz-food:checkMoney", function(money)
                    if money >= Config.EatPrice then
                        ESX.UI.Menu.CloseAll()
                        TriggerServerEvent("gamz-food:removeMoney", Config.EatPrice)
                        eat(data.current.prop)
                    else
                        ESX.ShowNotification("~r~You don't have enough cash.")
                    end
                end)
            elseif selected == 'drink' then
                ESX.TriggerServerCallback("gamz-food:checkMoney", function(money)
                    if money >= Config.DrinkPrice then
                        ESX.UI.Menu.CloseAll()
                        TriggerServerEvent("gamz-food:removeMoney", Config.DrinkPrice)
                        drink(data.current.prop) 
                    else
                        ESX.ShowNotification("~r~You don't have enough cash.")
                    end
                end)
            end
        end, function(data, menu)
            menu.close() 
    end)
end

-- Food --

function eat(prop)
    local playerPed = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(playerPed))
    prop = CreateObject(GetHashKey(prop), x, y, z+0.2,  true,  true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 18905), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
    RequestAnimDict('mp_player_inteat@burger')
    while not HasAnimDictLoaded('mp_player_inteat@burger') do
        Wait(0)
    end
    TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
    for i=1, 50 do
        Wait(300)
        TriggerEvent('esx_status:add', 'hunger', 10000)
    end
    IsAnimated = false
    ClearPedSecondaryTask(playerPed)
    DeleteObject(prop)
end

-- Drink --

function drink(prop)
    local playerPed = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(playerPed))
    prop = CreateObject(GetHashKey(prop), x, y, z+0.2,  true,  true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 18905), 0.15, 0.025, 0.010, 270.0, 175.0, 0.0, true, true, false, true, 1, true)
    RequestAnimDict('mp_player_intdrink')
    while not HasAnimDictLoaded('mp_player_intdrink') do
        Wait(0)
    end
    TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 8.0, -8, -1, 49, 0, 0, 0, 0)
    for i=1, 50 do
        Wait(300)
        TriggerEvent('esx_status:add', 'thirst', 10000)
    end
    IsAnimated = false
    ClearPedSecondaryTask(playerPed)
    DeleteObject(prop)
end

-- Utils --

function Draw3DText(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*1
    local fov = (1/GetGameplayCamFov())*100
    local scale = 1.9
    if onScreen then
        SetTextScale(0.0*scale, 0.18*scale)
        SetTextFont(4)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(0, 0, 0, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 600
        DrawRect(_x,_y+0.0115, 0.01+ factor, 0.025, 41, 11, 41, 68)
    end
end

function Marker(hint, type, x, y, z)
    Draw3DText(x, y, z + 1.0, hint)
    DrawMarker(type, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 2.0, 55, 175, 55, 100, false, true, 2, false, false, false, false)
end