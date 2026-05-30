local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

-- [ СИСТЕМА ЛОКАЛИЗАЦИИ И СОХРАНЕНИЯ ]
local Language = "EN"
pcall(function()
    if isfile and readfile and isfile("WareHub_Lang.txt") then
        local saved = readfile("WareHub_Lang.txt")
        if saved == "RU" or saved == "EN" then Language = saved end
    end
end)

local L = {
    EN = {
        Main = "Main", Atk = "Attack", Farm = "AutoFarm", Worlds = "Worlds", Vis = "Visuals",
        LangSec = "— Language —", LangSel = "Select Language", LangWarn = "Restart script to apply language!",
        ServSec = "— Servers —", Hop = "Hop to Empty Server",
        PlrSec = "— Player Settings —", Walk = "Walk Speed", InfJ = "Infinite Jump", Stats = "Show FPS / Ping",
        PosSec = "— Save Position —", PosBtn = "Save Point", AutoRet = "Auto-Return on Death",
        AtkSec = "— Attack Functions —", FastAtk = "Fast Attack (Manual/Tap)", AutoAtk = "Auto-Attack",
        TpFarmSec = "— Normal AutoFarm (TP) —", TpFarmTog = "Enable TP AutoFarm",
        FlyFarmSec = "— Fly AutoFarm —", FlyFarmTog = "Enable Fly AutoFarm", FlySpd = "Fly Speed", SphereRad = "Sphere Loot Radius",
        MobSec = "— Target Settings —", MobSel = "Select Mobs", MobUpd = "Refresh Mob List",
        PathSec = "— Path Farming —", PathTog = "Enable Path Farm", RecStr = "Start Recording Route", RecStp = "Stop Recording", AgroRad = "Agro Radius",
        LootSec = "— Loot Collection —", AutoLoot = "Auto-Pickup Items", LootAll = "Collect EVERYTHING",
        FiltGear = "— Filter: Gear —", GearSel = "Gear to Collect",
        FiltWep = "— Filter: Weapons —", WepSel = "Weapons to Collect",
        FiltOth = "— Filter: Others —", OthSel = "Other Items",
        W1 = "World 1 Locations", W2 = "World 2 Locations", TPBtn = "TELEPORT",
        EspSec = "— Object Highlight (ESP) —", EspPlr = "Show Players", EspMob = "Show Mobs", EspItm = "Show Items", EspDist = "Display Distance"
    },
    RU = {
        Main = "Главная", Atk = "Атака", Farm = "Автофарм", Worlds = "Миры", Vis = "Визуалы",
        LangSec = "— Выбор языка —", LangSel = "Язык (Language)", LangWarn = "Перезапустите скрипт для применения!",
        ServSec = "— Сервера —", Hop = "Перейти на пустой сервер",
        PlrSec = "— Настройки игрока —", Walk = "Скорость бега", InfJ = "Бесконечный прыжок", Stats = "Показать FPS / Ping",
        PosSec = "— Сохранение позиции —", PosBtn = "Сохранить точку", AutoRet = "Авто-возврат после смерти",
        AtkSec = "— Функции атаки —", FastAtk = "Фаст-атака (Ручная)", AutoAtk = "Авто-атака",
        TpFarmSec = "— Обычный автофарм (Телепорт) —", TpFarmTog = "Включить ТП-автофарм",
        FlyFarmSec = "— Флай-автофарм (Полет) —", FlyFarmTog = "Включить флай-автофарм", FlySpd = "Скорость полета", SphereRad = "Радиус сбора лута сферой",
        MobSec = "— Настройка целей —", MobSel = "Выбор мобов", MobUpd = "Обновить список мобов на карте",
        PathSec = "— Фарм по путям (Path Farm) —", PathTog = "Включить Path Farm", RecStr = "Начать запись маршрута", RecStp = "Остановить запись", AgroRad = "Радиус агра",
        LootSec = "— Настройки сбора лута —", AutoLoot = "Авто-подбор предметов", LootAll = "Собирать абсолютно все",
        FiltGear = "— Фильтр: Снаряжение —", GearSel = "Снаряжение для сбора",
        FiltWep = "— Фильтр: Оружие —", WepSel = "Оружие для сбора",
        FiltOth = "— Фильтр: Остальное —", OthSel = "Прочие предметы",
        W1 = "1 МИР — Локации", W2 = "2 МИР — Локации", TPBtn = "ТЕЛЕПОРТИРОВАТЬСЯ",
        EspSec = "— Подсветка объектов (ESP) —", EspPlr = "Показывать игроков", EspMob = "Показывать мобов", EspItm = "Показывать предметы", EspDist = "Дистанция отображения"
    }
}

-- [ КОНФИГ ]
local Config = {
    WalkSpeed = 16, InfiniteJump = false, ShowStats = false, SavedPos = nil, AutoReturnEnabled = false,
    AutoAttack = false, FastAttackEnabled = false,
    AutoFarm = false, FlyFarm = false, FarmSpeed = 28, HeightOffset = 1.5, DistanceOffset = 3.5, 
    BallSize = 40, WalkRadius = 1250, PostKillWait = 0.3, SelectedMobs = {}, 
    PathFarming = false, Recording = false, CurrentRadius = 20, CurrentIdx = 1, IsJumpingNow = false, Waypoints = {}, Visuals = {},
    CollectEnabled = false, LootRadius = 25,
    LootFilter = { CollectAll = false, Helmet = true, Chestplate = true, Leggings = true, Boots = true, Shield = true, Weapon = true, Diamonds = true, RunePuzzles = true, Potions = true, RebirthItems = true },
    SelectedCoords = nil, EspPlayers = false, EspMobs = false, EspItems = false, EspMaxDistance = 150
}

-- [ БАЗА ДАННЫХ ПРЕДМЕТОВ ]
local LootDatabase = {
    {Category = "RebirthItems", Keywords = {"WOLF CLAW", "CLAW", "REBIRTH", "MATERIAL", "LOOTPOINT", "ENEMY"}},
    {Category = "Helmet", Keywords = {"HELMET"}}, {Category = "Chestplate", Keywords = {"CHESTPLATE"}},
    {Category = "Leggings", Keywords = {"LEGGINGS"}}, {Category = "Boots", Keywords = {"BOOTS"}},
    {Category = "Shield", Keywords = {"SHIELD"}}, {Category = "Weapon", Keywords = {"WEAPON", "SWORD", "SABER", "SPEAR", "MACE", "KNIFE", "DAGGER", "HAMMER", "PICKAXE", "AXE", "SHOVEL", "HOE"}},
    {Category = "Diamonds", Keywords = {"DIAMOND"}}, {Category = "RunePuzzles", Keywords = {"RUNE", "FRAGMENT"}}, {Category = "Potions", Keywords = {"POTION"}}
}

local CategoryLabels = {
    Helmet = (Language == "RU" and "ШЛЕМ" or "HELMET"), Chestplate = (Language == "RU" and "НАГРУДНИК" or "CHESTPLATE"),
    Leggings = (Language == "RU" and "ШТАНЫ" or "LEGGINGS"), Boots = (Language == "RU" and "БОТИНКИ" or "BOOTS"),
    Shield = (Language == "RU" and "ЩИТ" or "SHIELD"), Weapon = (Language == "RU" and "ОРУЖИЕ" or "WEAPON"),
    Diamonds = (Language == "RU" and "АЛМАЗЫ" or "DIAMONDS"), RunePuzzles = (Language == "RU" and "ПАЗЛЫ РУН" or "RUNE PUZZLES"),
    Potions = (Language == "RU" and "ЗЕЛЬЯ" or "POTIONS"), RebirthItems = (Language == "RU" and "ПЕРЕРОЖДЕНИЕ" or "REBIRTH")
}

local pickedCache = {}
local activeLootObject = nil
local activeMobObject = nil

-- [ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ]
local function PlayClick()
    local sound = Instance.new("Sound", game:GetService("SoundService"))
    sound.SoundId = "rbxassetid://6895079853" 
    sound.Volume = 0.5
    sound:Play()
    sound.Stopped:Connect(function() sound:Destroy() end)
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or pickedCache[prompt] then return end
    if prompt:IsDescendantOf(workspace) then
        pickedCache[prompt] = true
        pcall(function() prompt.HoldDuration = 0; prompt.MaxActivationDistance = 60; fireproximityprompt(prompt) end)
        task.delay(0.4, function() pickedCache[prompt] = nil end)
    end
end

local function GetCleanItemName(prompt)
    local rawIdentifiers = {}
    if prompt.ObjectText ~= "" then table.insert(rawIdentifiers, prompt.ObjectText) end
    if prompt.ActionText ~= "" then table.insert(rawIdentifiers, prompt.ActionText) end
    local current = prompt.Parent
    for i = 1, 3 do
        if current and current ~= workspace then
            if current.Name ~= "BasePart" and current.Name ~= "Part" and current.Name ~= "MeshPart" then table.insert(rawIdentifiers, current.Name) end
            for _, child in pairs(current:GetChildren()) do
                if child:IsA("StringValue") or child:IsA("TextValue") then table.insert(rawIdentifiers, child.Value)
                elseif (child:IsA("BillboardGui") or child:IsA("SurfaceGui")) and child.Name ~= "ItemTag" then
                    for _, textLabel in pairs(child:GetDescendants()) do
                        if textLabel:IsA("TextLabel") and textLabel.Text ~= "" and not string.find(textLabel.Text, "%[") then table.insert(rawIdentifiers, textLabel.Text) end
                    end
                end
            end
            pcall(function() for _, attrValue in pairs(current:GetAttributes()) do if type(attrValue) == "string" then table.insert(rawIdentifiers, attrValue) end end end)
            current = current.Parent
        else break end
    end
    for _, text in pairs(rawIdentifiers) do
        local upperText = string.upper(text)
        for _, data in ipairs(LootDatabase) do
            for _, keyword in pairs(data.Keywords) do if string.find(upperText, keyword) then return text, data.Category end end
        end
    end
    for _, text in pairs(rawIdentifiers) do
        if text ~= "BasePart" and text ~= "Part" and text ~= "MeshPart" and text ~= "ProximityPrompt" and text ~= "Pick" and text ~= "" and not string.find(text, "%[") then return text, nil end
    end
    return "Unknown Item", nil
end

local function ShouldPickupItem(prompt)
    local realName, category = GetCleanItemName(prompt)
    if Config.LootFilter.CollectAll then return true, category or "UNKNOWN", realName end
    if not Config.CollectEnabled then return false, category or "UNKNOWN", realName end
    if category then if Config.LootFilter[category] then return true, category, realName end return false, category, realName end
    return false, "UNKNOWN", realName
end

local function TeleportTo(coords)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and coords then PlayClick(); hrp.CFrame = CFrame.new(coords) end
end

local function MoveTowards(currentCFrame, targetPosition, speed, deltaTime)
    local currentPosition = currentCFrame.Position
    local direction = (targetPosition - currentPosition)
    local distance = direction.Magnitude
    if distance <= 0.05 then return CFrame.new(targetPosition, targetPosition + currentCFrame.LookVector) end
    return CFrame.new(currentPosition + (direction.Unit * math.min(speed * deltaTime, distance)))
end

-- [ ВИЗУАЛЫ ]
local AgroBox = Instance.new("Part")
AgroBox.Name = "AgroVisualBox"; AgroBox.Shape = Enum.PartType.Block; AgroBox.Material = Enum.Material.ForceField; AgroBox.Color = Color3.fromRGB(255, 0, 0); AgroBox.Transparency = 0.75; AgroBox.CanCollide = false; AgroBox.Anchored = true; AgroBox.Parent = nil 
RunService.Heartbeat:Connect(function()
    if Config.PathFarming and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        AgroBox.Parent = workspace; AgroBox.CFrame = Player.Character.HumanoidRootPart.CFrame
    else AgroBox.Parent = nil end
end)

local VisualBall = nil 
local function DestroyVisualBall() if VisualBall then VisualBall:Destroy(); VisualBall = nil end end
local function CreateVisualBall(char)
    if not Config.FlyFarm then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end
    DestroyVisualBall()
    VisualBall = Instance.new("Part", workspace)
    VisualBall.Name = "FarmVisualBall"; VisualBall.Shape = Enum.PartType.Ball; VisualBall.Size = Vector3.new(Config.BallSize, Config.BallSize, Config.BallSize)
    VisualBall.Color = Color3.fromRGB(255, 235, 50); VisualBall.Transparency = 0.8; VisualBall.Material = Enum.Material.ForceField; VisualBall.CanCollide = false; VisualBall.Anchored = true
end
RunService.RenderStepped:Connect(function() if VisualBall and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then VisualBall.Position = Player.Character.HumanoidRootPart.Position end end)

local function HopToEmptyServer()
    PlayClick()
    Rayfield:Notify({Title = "Server", Content = "Scanning...", Duration = 4})
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local bestServer, minPlayers, cursor = nil, math.huge, ""
    pcall(function()
        for i = 1, 15 do 
            local response = game:HttpGet(url .. (cursor ~= "" and "&cursor=" .. cursor or ""))
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                for _, s in pairs(data.data) do
                    local pc, mc = tonumber(s.playing), tonumber(s.maxPlayers)
                    if pc and pc > 0 and pc < minPlayers and pc < mc and s.id ~= game.JobId then minPlayers = pc; bestServer = s.id end
                end
                if data.nextPageCursor and data.nextPageCursor ~= "" then cursor = data.nextPageCursor else break end
            else break end
        end
        if bestServer then Rayfield:Notify({Title = "Server Found", Content = "Teleporting...", Duration = 3}); task.wait(1); TeleportService:TeleportToPlaceInstance(placeId, bestServer, Player) end
    end)
end

local function SetupStats()
    local pg = Player:WaitForChild("PlayerGui")
    if pg:FindFirstChild("StatsGui") then pg.StatsGui:Destroy() end
    local sg = Instance.new("ScreenGui", pg); sg.Name = "StatsGui"; sg.ResetOnSpawn = false
    local lb = Instance.new("TextLabel", sg); lb.Name = "Label"; lb.Size = UDim2.new(0, 200, 0, 80); lb.Position = UDim2.new(0, 10, 0, 50); lb.BackgroundTransparency = 1; lb.TextColor3 = Color3.new(1, 1, 1); lb.TextSize = 14; lb.Font = Enum.Font.Code; lb.TextXAlignment = Enum.TextXAlignment.Left
    task.spawn(function()
        while true do
            if Config.ShowStats then
                sg.Enabled = true
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                lb.Text = "FPS: "..math.floor(1/task.wait()).."\nPING: "..math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()).."ms\n"..(hrp and string.format("X:%.1f Y:%.1f Z:%.1f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z) or "N/A")
            else sg.Enabled = false end
            task.wait(0.5)
        end
    end)
end
SetupStats()

local function CreateTag(parent, tagName, textColor)
    local bb = parent:FindFirstChild(tagName) or Instance.new("BillboardGui", parent); bb.Name = tagName; bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 200, 0, 20); bb.ExtentsOffset = Vector3.new(0, 3, 0)
    local txt = bb:FindFirstChild("TextLabel") or Instance.new("TextLabel", bb); txt.BackgroundTransparency = 1; txt.Size = UDim2.new(1, 0, 1, 0); txt.TextStrokeTransparency = 0.5; txt.TextSize = 10; txt.Font = Enum.Font.SourceSansBold; txt.TextColor3 = textColor or Color3.new(1, 1, 1)
    return txt
end
local function CreateHighlight(parent)
    local hl = parent:FindFirstChild("EspHighlight") or Instance.new("Highlight", parent); hl.Name = "EspHighlight"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.FillColor = Color3.fromRGB(255, 255, 255); return hl
end
local function FullClearESP() for _, v in pairs(workspace:GetDescendants()) do if v.Name == "CleanTag" or v.Name == "EspHighlight" or v.Name == "ItemTag" then v:Destroy() end end end

local function IsTarget(model)
    if #Config.SelectedMobs == 0 then return true end
    local n = model:FindFirstChildOfClass("Humanoid") and model.Humanoid.DisplayName ~= "" and model.Humanoid.DisplayName or model.Name
    return table.find(Config.SelectedMobs, n) ~= nil
end
local function IsEnemy(model)
    if not model or not model:FindFirstChild("Humanoid") or model.Humanoid.Health <= 0 then return false end
    if Players:GetPlayerFromCharacter(model) or model == Player.Character then return false end
    return IsTarget(model)
end

-- [[ ИНТЕРФЕЙС RAYFIELD ]]
local Window = Rayfield:CreateWindow({Name = "bloxloot v12 Ware hub update 3", LoadingTitle = "Loading...", ConfigurationSaving = {Enabled = false}})

-- Вкладка: Главная
local Tab1 = Window:CreateTab(L[Language].Main)

Tab1:CreateSection(L[Language].LangSec)
Tab1:CreateDropdown({
    Name = L[Language].LangSel, Options = {"EN 🇺🇸", "RU 🇷🇺"}, CurrentOption = {"EN 🇺🇸"}, MultipleOptions = false,
    Callback = function(Option)
        local choice = type(Option) == "table" and Option[1] or Option
        local code = choice:sub(1,2)
        pcall(function() if writefile then writefile("WareHub_Lang.txt", code) end end)
        Rayfield:Notify({Title = "Language", Content = L[Language].LangWarn, Duration = 4})
    end,
})

Tab1:CreateSection(L[Language].ServSec)
Tab1:CreateButton({Name = L[Language].Hop, Callback = HopToEmptyServer})

Tab1:CreateSection(L[Language].PlrSec)
Tab1:CreateSlider({Name = L[Language].Walk, Range = {16, 40}, Increment = 1, CurrentValue = 16, Callback = function(v) Config.WalkSpeed = v end})
Tab1:CreateToggle({Name = L[Language].InfJ, CurrentValue = false, Callback = function(v) PlayClick(); Config.InfiniteJump = v end})
Tab1:CreateToggle({Name = L[Language].Stats, CurrentValue = false, Callback = function(v) PlayClick(); Config.ShowStats = v end})

Tab1:CreateSection(L[Language].PosSec)
Tab1:CreateButton({Name = L[Language].PosBtn, Callback = function()
    PlayClick(); local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then Config.SavedPos = hrp.CFrame; Rayfield:Notify({Title = "Saved", Content = "Point Saved!", Duration = 2}) end
end})
Tab1:CreateToggle({Name = L[Language].AutoRet, CurrentValue = false, Callback = function(v) PlayClick(); Config.AutoReturnEnabled = v end})

-- Вкладка: Атака
local TabAtk = Window:CreateTab(L[Language].Atk)
TabAtk:CreateSection(L[Language].AtkSec)
TabAtk:CreateToggle({Name = L[Language].FastAtk, CurrentValue = false, Callback = function(v) Config.FastAttackEnabled = v end})
TabAtk:CreateToggle({Name = L[Language].AutoAtk, CurrentValue = false, Callback = function(v) PlayClick(); Config.AutoAttack = v end})

-- Вкладка: Автофарм
local TabFarm = Window:CreateTab(L[Language].Farm)
TabFarm:CreateSection(L[Language].TpFarmSec)
TabFarm:CreateToggle({Name = L[Language].TpFarmTog, CurrentValue = false, Callback = function(v) PlayClick(); Config.AutoFarm = v end})

TabFarm:CreateSection(L[Language].FlyFarmSec)
TabFarm:CreateToggle({Name = L[Language].FlyFarmTog, CurrentValue = false, Callback = function(v) Config.FlyFarm = v; if v then if Player.Character then CreateVisualBall(Player.Character) end else DestroyVisualBall() end end})
TabFarm:CreateSlider({Name = L[Language].FlySpd, Range = {15, 42}, Increment = 1, CurrentValue = 28, Callback = function(v) Config.FarmSpeed = v end})
TabFarm:CreateSlider({Name = L[Language].SphereRad, Range = {10, 20}, Increment = 1, CurrentValue = 20, Callback = function(v) Config.BallSize = v * 2; if VisualBall then VisualBall.Size = Vector3.new(Config.BallSize, Config.BallSize, Config.BallSize) end end})

TabFarm:CreateSection(L[Language].MobSec)
local MobDropdown = TabFarm:CreateDropdown({Name = L[Language].MobSel, Options = {"..."}, CurrentOption = {"..."}, MultipleOptions = true, Callback = function(Options) Config.SelectedMobs = Options end})
TabFarm:CreateButton({Name = L[Language].MobUpd, Callback = function()
    local newList = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and not Players:GetPlayerFromCharacter(v.Parent) then
            local n = v.DisplayName ~= "" and v.DisplayName or v.Parent.Name
            if not table.find(newList, n) then table.insert(newList, n) end
        end
    end
    MobDropdown:Refresh(newList, true)
end})

TabFarm:CreateSection(L[Language].PathSec)
TabFarm:CreateToggle({Name = L[Language].PathTog, CurrentValue = false, Callback = function(v) PlayClick(); Config.PathFarming = v; if v then Config.CurrentIdx = 1 end end})
TabFarm:CreateButton({Name = L[Language].RecStr, Callback = function() PlayClick(); Config.Recording = true; Config.Waypoints = {}; for _,v in pairs(Config.Visuals) do if v then v:Destroy() end end; Config.Visuals = {}; Config.CurrentIdx = 1 end})
TabFarm:CreateButton({Name = L[Language].RecStp, Callback = function() PlayClick(); Config.Recording = false end})
TabFarm:CreateSlider({Name = L[Language].AgroRad, Range = {5, 30}, Increment = 1, CurrentValue = 20, Callback = function(v) Config.CurrentRadius = v; AgroBox.Size = Vector3.new(v*2, 14, v*2) end})

TabFarm:CreateSection(L[Language].LootSec)
TabFarm:CreateToggle({Name = L[Language].AutoLoot, CurrentValue = false, Callback = function(v) PlayClick(); Config.CollectEnabled = v end})
TabFarm:CreateToggle({Name = L[Language].LootAll, CurrentValue = false, Callback = function(v) Config.LootFilter.CollectAll = v end})

local gOpts = Language == "RU" and {"Шлем", "Нагрудник", "Штаны", "Ботинки", "Щит"} or {"Helmet", "Chestplate", "Leggings", "Boots", "Shield"}
TabFarm:CreateSection(L[Language].FiltGear)
TabFarm:CreateDropdown({Name = L[Language].GearSel, Options = gOpts, CurrentOption = gOpts, MultipleOptions = true, Callback = function(Opt)
    Config.LootFilter.Helmet = table.find(Opt, gOpts[1]) ~= nil; Config.LootFilter.Chestplate = table.find(Opt, gOpts[2]) ~= nil
    Config.LootFilter.Leggings = table.find(Opt, gOpts[3]) ~= nil; Config.LootFilter.Boots = table.find(Opt, gOpts[4]) ~= nil
    Config.LootFilter.Shield = table.find(Opt, gOpts[5]) ~= nil
end})

local wOpts = Language == "RU" and {"Оружие и Инструменты"} or {"Weapons and Tools"}
TabFarm:CreateSection(L[Language].FiltWep)
TabFarm:CreateDropdown({Name = L[Language].WepSel, Options = wOpts, CurrentOption = wOpts, MultipleOptions = true, Callback = function(Opt) Config.LootFilter.Weapon = table.find(Opt, wOpts[1]) ~= nil end})

local oOpts = Language == "RU" and {"Алмазы", "Пазлы рун", "Зелья", "Предметы для перерождения"} or {"Diamonds", "Rune Puzzles", "Potions", "Rebirth Items"}
TabFarm:CreateSection(L[Language].FiltOth)
TabFarm:CreateDropdown({Name = L[Language].OthSel, Options = oOpts, CurrentOption = oOpts, MultipleOptions = true, Callback = function(Opt)
    Config.LootFilter.Diamonds = table.find(Opt, oOpts[1]) ~= nil; Config.LootFilter.RunePuzzles = table.find(Opt, oOpts[2]) ~= nil
    Config.LootFilter.Potions = table.find(Opt, oOpts[3]) ~= nil; Config.LootFilter.RebirthItems = table.find(Opt, oOpts[4]) ~= nil
end})

-- Вкладка: Миры
local TabWorlds = Window:CreateTab(L[Language].Worlds)
local World1Points = {
    ["Boss 1"] = Vector3.new(-66, 41.7, -12.4), ["Boss 2"] = Vector3.new(-89.5, 52.2, -160.7),
    ["Boss 3"] = Vector3.new(-18.2, 81.5, -505.9), ["Boss 4"] = Vector3.new(-91.3, 141.7, -632.9), ["World 1 Boss Rune"] = Vector3.new(2.5, 58.8, -24.5)
}
local World2Points = {
    ["Boss 1"] = Vector3.new(75, 6, -112), ["Boss 2"] = Vector3.new(51, -13, -449),
    ["Boss 3"] = Vector3.new(78, 41.1, -835), ["Boss 4"] = Vector3.new(60, 4, -1012)
}
TabWorlds:CreateDropdown({Name = L[Language].W1, Options = {" ", "Boss 1", "Boss 2", "Boss 3", "Boss 4", "World 1 Boss Rune"}, CurrentOption = " ", Callback = function(O) local c = type(O)=="table" and O[1] or O; Config.SelectedCoords = (c~=" ") and World1Points[c] or nil end})
TabWorlds:CreateDropdown({Name = L[Language].W2, Options = {" ", "Boss 1", "Boss 2", "Boss 3", "Boss 4"}, CurrentOption = " ", Callback = function(O) local c = type(O)=="table" and O[1] or O; Config.SelectedCoords = (c~=" ") and World2Points[c] or nil end})
TabWorlds:CreateButton({Name = L[Language].TPBtn, Callback = function() if Config.SelectedCoords then TeleportTo(Config.SelectedCoords) end end})

-- Вкладка: Визуалы
local TabVisuals = Window:CreateTab(L[Language].Vis)
TabVisuals:CreateSection(L[Language].EspSec)
TabVisuals:CreateToggle({Name = L[Language].EspPlr, CurrentValue = false, Callback = function(v) PlayClick(); Config.EspPlayers = v if not v then FullClearESP() end end})
TabVisuals:CreateToggle({Name = L[Language].EspMob, CurrentValue = false, Callback = function(v) PlayClick(); Config.EspMobs = v if not v then FullClearESP() end end})
TabVisuals:CreateToggle({Name = L[Language].EspItm, CurrentValue = false, Callback = function(v) Config.EspItems = v if not v then FullClearESP() end end})
TabVisuals:CreateSlider({Name = L[Language].EspDist, Range = {50, 1000}, Increment = 10, CurrentValue = 150, Callback = function(v) Config.EspMaxDistance = v end})

-- [[ ФАСТ-АТАКА (РУЧНАЯ ПО ТАПУ) ]]
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if Config.FastAttackEnabled then
            pcall(function()
                for _, v in pairs(game:GetService("ReplicatedStorage").Runtime.Actors:GetDescendants()) do
                    if v.Name == "Attack" and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                        if v.Parent.Parent.Name:find("Tool") and v.Parent.Parent.Name:find(tostring(Player.UserId)) then
                            if v:IsA("RemoteEvent") then v:FireServer() else task.spawn(function() v:InvokeServer() end) end
                        end
                    end
                end
            end)
        end
    end
end)

-- [[ СИСТЕМЫ АВТОМАТИЗАЦИИ (С ГЛОБАЛЬНЫМ КЭШЕМ ДЛЯ ОПТИМИЗАЦИИ) ]]
local SharedLoot = {}
local SharedMobs = {}

-- 1. Глобальный Сканнер объектов (обновляет списки раз в 0.15с, спасает от лагов)
task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and (Config.AutoFarm or Config.FlyFarm or Config.CollectEnabled or Config.PathFarming) then
            local currentLoot, currentMobs = {}, {}
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local root = v.Parent:IsA("BasePart") and v.Parent or v.Parent:FindFirstChildOfClass("BasePart")
                    if root then table.insert(currentLoot, {Prompt = v, Part = root}) end
                elseif v:IsA("Humanoid") and v.Parent and v.Parent:IsA("Model") and v.Health > 0 then
                    if IsEnemy(v.Parent) then table.insert(currentMobs, v.Parent) end
                end
            end
            SharedLoot, SharedMobs = currentLoot, currentMobs

            local minLootDist = Config.FlyFarm and (Config.BallSize / 2) or Config.LootRadius
            local closestLoot = nil
            for _, loot in pairs(SharedLoot) do
                local dist = (hrp.Position - loot.Part.Position).Magnitude
                if dist <= minLootDist then
                    local rn = tostring(GetCleanItemName(loot.Prompt)):lower()
                    if not (rn:find("teleport") or rn:find("portal") or rn:find("телепорт") or rn:find("портал")) then
                        if ShouldPickupItem(loot.Prompt) then minLootDist = dist; closestLoot = loot end
                    end
                end
            end
            activeLootObject = closestLoot

            if (Config.AutoFarm or Config.FlyFarm) and not activeLootObject then
                local minMobDist, closestMob = Config.WalkRadius, nil
                for _, mob in pairs(SharedMobs) do
                    if mob:FindFirstChild("HumanoidRootPart") then
                        local dist = (hrp.Position - mob.HumanoidRootPart.Position).Magnitude
                        if dist < minMobDist then minMobDist = dist; closestMob = mob end
                    end
                end
                activeMobObject = closestMob
            else
                activeMobObject = nil
            end
        end
        task.wait(0.15)
    end
end)

-- 2. Классический ТП-Автофарм
task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if Config.AutoFarm and not Config.FlyFarm and hrp then
            for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            if activeLootObject and activeLootObject.Part then
                hrp.CFrame = CFrame.new(activeLootObject.Part.Position + Vector3.new(0, 1, 0))
                task.wait(0.05); TriggerPrompt(activeLootObject.Prompt)
            elseif activeMobObject and activeMobObject:FindFirstChild("HumanoidRootPart") then
                local tHrp = activeMobObject.HumanoidRootPart
                local tPos = tHrp.Position + (tHrp.CFrame.LookVector * 2.75) + Vector3.new(0, 0.6, 0)
                hrp.CFrame = CFrame.new(tPos, Vector3.new(tHrp.Position.X, tPos.Y, tHrp.Position.Z)) 
                if activeMobObject.Humanoid.Health <= 0 then task.wait(Config.PostKillWait) end
            end
        end
        task.wait()
    end
end)

-- 3. ФЛАЙ-АВТОФАРМ 
local waveTime = 0
RunService.Heartbeat:Connect(function(dt)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if Config.FlyFarm and not Config.AutoFarm and hrp then
        for _, p in pairs(Player.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        if activeLootObject and activeLootObject.Part then
            waveTime = waveTime + (dt * 26)
            local tp = activeLootObject.Part.Position + Vector3.new(0, ((math.cos(waveTime)-1)*2.0) + 1.2, 0)
            hrp.CFrame = MoveTowards(hrp.CFrame, tp, Config.FarmSpeed, dt)
            if (hrp.Position - tp).Magnitude <= 6 then TriggerPrompt(activeLootObject.Prompt) end
        elseif activeMobObject and activeMobObject:FindFirstChild("HumanoidRootPart") then
            local tHrp = activeMobObject.HumanoidRootPart
            local fp = tHrp.Position + (tHrp.CFrame.LookVector * Config.DistanceOffset) + Vector3.new(0, Config.HeightOffset, 0)
            waveTime = waveTime + (dt * 28) 
            local ncf = MoveTowards(hrp.CFrame, fp + Vector3.new(0, (math.cos(waveTime)-1)*2.0, 0), Config.FarmSpeed, dt)
            hrp.CFrame = CFrame.new(ncf.Position, Vector3.new(tHrp.Position.X, ncf.Position.Y, tHrp.Position.Z)) 
        end
    end
end)

-- 4. Сборщик лута на полу (Без автофарма)
task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if (Config.CollectEnabled or Config.LootFilter.CollectAll) and hrp and not Config.AutoFarm and not Config.FlyFarm then
            for _, item in pairs(SharedLoot) do
                if not Config.CollectEnabled and not Config.LootFilter.CollectAll then break end
                if item.Prompt and item.Part and (hrp.Position - item.Part.Position).Magnitude <= Config.LootRadius then
                    local rn = tostring(GetCleanItemName(item.Prompt)):lower()
                    if not (rn:find("teleport") or rn:find("portal") or rn:find("телепорт") or rn:find("портал")) then
                        if ShouldPickupItem(item.Prompt) then TriggerPrompt(item.Prompt) end
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- 5. Движение по путям (Path Farming)
task.spawn(function()
    local lastPos, stuckTimer = Vector3.new(0,0,0), 0
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if Config.PathFarming and not Config.AutoFarm and not Config.FlyFarm and hrp and hum and #Config.Waypoints > 0 then
            local target, dist = nil, math.huge
            for _, mob in pairs(SharedMobs) do
                local tHrp = mob:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local diff = tHrp.Position - hrp.Position
                    if math.abs(diff.X) <= Config.CurrentRadius and math.abs(diff.Z) <= Config.CurrentRadius and diff.Magnitude < dist then 
                        dist = diff.Magnitude; target = mob 
                    end
                end
            end
            if target then hum:MoveTo(target.HumanoidRootPart.Position) else
                local w = Config.Waypoints[Config.CurrentIdx]
                if w then
                    stuckTimer = (hrp.Position - lastPos).Magnitude < 0.2 and stuckTimer + 0.1 or 0
                    lastPos = hrp.Position
                    if (w.Jumped or stuckTimer > 0.6) and not Config.IsJumpingNow then hum:ChangeState(Enum.HumanoidStateType.Jumping); Config.IsJumpingNow = true end
                    if hum:GetState() == Enum.HumanoidStateType.Landed then Config.IsJumpingNow = false end
                    hum:MoveTo(w.Pos)
                    if (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(w.Pos.X, w.Pos.Z)).Magnitude < 4.5 then Config.CurrentIdx = (Config.CurrentIdx < #Config.Waypoints) and Config.CurrentIdx + 1 or 1 end
                end
            end
        end
        task.wait(0.03)
    end
end)

-- 6. Запись маршрутов
task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if Config.Recording and hrp and (#Config.Waypoints == 0 or (hrp.Position - Config.Waypoints[#Config.Waypoints].Pos).Magnitude > 3.2) then
            table.insert(Config.Waypoints, {Pos = hrp.Position, Jumped = Player.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping})
            local p = Instance.new("Part", workspace); p.Anchored = true; p.CanCollide = false; p.Position = hrp.Position; p.Size = Vector3.new(0.6,0.6,0.6); p.Color = Color3.fromRGB(0, 255, 150); table.insert(Config.Visuals, p)
        end
        task.wait(0.12)
    end
end)

-- 7. УСИЛЕННАЯ АВТО-АТАКА
task.spawn(function()
    while true do
        if Config.AutoAttack then
            pcall(function()
                for _, v in pairs(game:GetService("ReplicatedStorage").Runtime.Actors:GetDescendants()) do
                    if v.Name == "Attack" and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                        if v.Parent.Parent.Name:find("Tool") and v.Parent.Parent.Name:find(tostring(Player.UserId)) then
                            if v:IsA("RemoteEvent") then v:FireServer() else task.spawn(function() v:InvokeServer() end) end
                        end
                    end
                end
            end)
        end
        task.wait(0.05) -- Уменьшенная задержка для максимальной скорости спама
    end
end)

-- 8. Игровые бинды
RunService.Stepped:Connect(function() if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character.Humanoid.WalkSpeed = Config.WalkSpeed end end)
UserInputService.JumpRequest:Connect(function() if Config.InfiniteJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
Player.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if not Player.PlayerGui:FindFirstChild("StatsGui") then SetupStats() end
    if Config.AutoReturnEnabled and Config.SavedPos then local hrp = char:WaitForChild("HumanoidRootPart", 10) if hrp then task.wait(0.2); hrp.CFrame = Config.SavedPos end end
    if Config.FlyFarm then CreateVisualBall(char) end
end)

-- 9. Поток ESP
task.spawn(function()
    while true do
        if Config.EspPlayers or Config.EspMobs or Config.EspItems then
            local mHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v ~= Player.Character then
                    local t = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                    local p = game.Players:GetPlayerFromCharacter(v)
                    if t and mHrp and (mHrp.Position - t.Position).Magnitude <= Config.EspMaxDistance then
                        if (p and Config.EspPlayers) or (not p and Config.EspMobs) then
                            local tag = CreateTag(t, "CleanTag")
                            tag.Text = ((v.Humanoid.DisplayName ~= "" and v.Humanoid.DisplayName) or v.Name).." | HP: "..math.floor(v.Humanoid.Health)
                            CreateHighlight(v).FillColor = p and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 0, 0)
                        end
                    end
                elseif Config.EspItems and v:IsA("ProximityPrompt") then
                    local t = v.Parent:IsA("BasePart") and v.Parent or v.Parent:FindFirstChildOfClass("BasePart")
                    if t and mHrp and (mHrp.Position - t.Position).Magnitude <= Config.EspMaxDistance then
                        local rn, cat = GetCleanItemName(v)
                        local tag = CreateTag(t, "ItemTag", cat and CategoryLabels[cat] and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(255, 60, 60))
                        tag.Text = (cat and CategoryLabels[cat] and "["..CategoryLabels[cat].."] " or "[ПРЕДМЕТ] ") .. tostring(rn)
                    end
                end
            end
        end
        task.wait(1.0)
    end
end)
