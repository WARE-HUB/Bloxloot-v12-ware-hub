local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
        Main = "Main", Atk = "Attack", Farm = "AutoFarm", LootTab = "Auto Loot Items", Worlds = "Worlds", Vis = "Visuals", Misc = "Misc",
        LangSec = "— Language —", LangSel = "Select Language", LangWarn = "Restart script to apply language!",
        ServSec = "— Servers —", Hop = "Hop to Empty Server",
        PlrSec = "— Player Settings —", Walk = "Walk Speed", InfJ = "Infinite Jump", Stats = "Show FPS / Ping / Coords",
        PosSec = "— Save Position —", PosBtn = "Save Point", AutoRet = "Auto-Return on Death",
        AtkSec = "— Attack Functions —", FastAtk = "Fast Attack (Manual/Tap)", AutoAtk = "Auto-Attack",
        FlyFarmSec = "— Fly AutoFarm —", FlyFarmTog = "Enable Fly AutoFarm", FlySpd = "Fly Speed", SphereRad = "Sphere Loot Radius",
        MobSec = "— Target Settings —", MobSel = "Select Mobs", MobUpd = "Refresh Mob List",
        PathSec = "— Path Farming —", PathTog = "Enable Path Farm", RecStr = "Start Recording Route", RecStp = "Stop Recording", AgroRad = "Agro Radius",
        RouteInput = "Route Name to Save", RouteSelect = "Select Route", RouteSave = "Save Recorded Route", RouteLoad = "Load Selected Route", RouteDel = "Delete Selected Route",
        RecStartNotif = "Started recording a new route", RecStopNotif = "Route recording stopped",
        ErrNoName = "Enter route name!", ErrNameTaken = "Name already taken!", ErrTooShort = "Route too short!",
        SuccessSave = "Route [%s] saved!", SuccessLoad = "Route loaded and drawn", SuccessDel = "Route erased",
        
        LootModeSec = "— LOOT COLLECTION MODES —",
        LootFilterTog = "Automatic item pickup (Strict Filter)",
        LootAllTog = "Automatic pickup of ALL items",
        FiltWorldSec = "— WORLD FILTER CONFIG —",
        WorldSelect = "Select Current World",
        WorldsArray = {"World 1", "World 2", "World 3"},
        EquipSec = "— Equipment —", HelmName = "🎩 Helmets", ChestName = "🧥 Chestplates", LegName = "👖 Leggings", BootName = "🥾 Boots", ShieldName = "🛡️ Shields", WepName = "⚔️ Weapons & Tools",
        SpecSec = "— Special & Consumables —", PotName = "🧪 Potions", RuneName = "🌀 Runes & Boss Drops", DiamName = "💎 Diamonds", RebirthName = "🔁 Rebirth Items",
        
        W1 = "World 1 Locations", W2 = "World 2 Locations", TPBtn = "TELEPORT",
        EspSec = "— Object Highlight (ESP) —", EspPlr = "Show Players", EspMob = "Show Mobs", EspItm = "Show Items", EspDist = "Display Distance",
        GodModeSec = "— Survival —", GodMode = "God Mode (Invincibility)", HudSec = "— HUD Settings —"
    },
    RU = {
        Main = "Главная", Atk = "Атака", Farm = "Автофарм", LootTab = "Автоподбор предметов", Worlds = "Миры", Vis = "Визуалы", Misc = "Прочее",
        LangSec = "— Выбор языка —", LangSel = "Язык (Language)", LangWarn = "Перезапустите скрипт для применения!",
        ServSec = "— Сервера —", Hop = "Перейти на пустой сервер",
        PlrSec = "— Настройки игрока —", Walk = "Скорость бега", InfJ = "Бесконечный прыжок", Stats = "Показать FPS / Ping / Координаты",
        PosSec = "— Сохранение позиции —", PosBtn = "Сохранить точку", AutoRet = "Авто-возврат после смерти",
        AtkSec = "— Функции атаки —", FastAtk = "Фаст-атака (Ручная)", AutoAtk = "Auto-Attack",
        FlyFarmSec = "— Флай-автофарм (Полет) —", FlyFarmTog = "Включить флай-автофарм", FlySpd = "Скорость полета", SphereRad = "Радиус сбора лута сферой",
        MobSec = "— Настройка целей —", MobSel = "Выбор мобов", MobUpd = "Обновить список мобов на карте",
        PathSec = "— Фарм по путям (Path Farm) —", PathTog = "Включить Path Farm", RecStr = "Начать запись маршрута", RecStp = "Остановить запись", AgroRad = "Радиус агра",
        RouteInput = "Имя для сохранения маршрута", RouteSelect = "Выбор маршрута", RouteSave = "Сохранить записанный маршрут", RouteLoad = "Загрузить выбранный маршрут", RouteDel = "Удалить выбранный маршрут",
        RecStartNotif = "Начата запись нового маршрута", RecStopNotif = "Запись маршрута остановлена",
        ErrNoName = "Введите имя маршрута!", ErrNameTaken = "Имя уже занято!", ErrTooShort = "Маршрут слишком короткий!",
        SuccessSave = "Маршрут [%s] сохранен!", SuccessLoad = "Маршрут загружен и отрисован", SuccessDel = "Маршрут стерт",
        
        LootModeSec = "— РЕЖИМЫ СБОРА ЛУТА —",
        LootFilterTog = "Автоматический подбор (Строгий Фильтр)",
        LootAllTog = "Автоматический подбор ВСЕХ предметов",
        FiltWorldSec = "— НАСТРОЙКА ФИЛЬТРА МИРА —",
        WorldSelect = "Выбери текущий Мир",
        WorldsArray = {"Мир 1", "Мир 2", "Мир 3"},
        EquipSec = "— Экипировка —", HelmName = "🎩 Шлемы", ChestName = "🧥 Нагрудники", LegName = "👖 Штаны", BootName = "🥾 Ботинки", ShieldName = "🛡️ Щиты", WepName = "⚔️ Оружие и Инструменты",
        SpecSec = "— Специальное и Расходники —", PotName = "🧪 Зелья", RuneName = "🌀 Руны и Дроп Боссов", DiamName = "💎 Алмазы", RebirthName = "🔁 Предметы для Перерождения",
        
        W1 = "1 МИР — Локации", W2 = "2 МИР — Локации", TPBtn = "ТЕЛЕПОРТИРОВАТЬСЯ",
        EspSec = "— Подсветка объектов (ESP) —", EspPlr = "Показывать игроков", EspMob = "Показывать мобов", EspItm = "Показывать предметы", EspDist = "Дистанция отображения",
        GodModeSec = "— Выживание —", GodMode = "God Mode (Бессмертие)", HudSec = "— Настройки HUD —"
    }
}

-- [ КОНФИГ ]
local Config = {
    WalkSpeed = 16, InfiniteJump = false, ShowStats = false, SavedPos = nil, AutoReturnEnabled = false,
    AutoAttack = false, FastAttackEnabled = false, GodMode = false,
    FlyFarm = false, FarmSpeed = 28, HeightOffset = 1.5, DistanceOffset = 3.5, 
    BallSize = 40, WalkRadius = 1250, PostKillWait = 0.3, SelectedMobs = {}, 
    PathFarming = false, Recording = false, CurrentRadius = 20, CurrentIdx = 1, Waypoints = {}, Visuals = {},
    SavedRoutes = {}, SelectedRouteName = nil, RouteInputName = "",
    
    AutoLoot = false,
    LootAll = false,
    SelectedItems = { Helmet = {}, Chestplate = {}, Leggings = {}, Boots = {}, Shield = {}, Weapon = {}, Diamonds = {}, Potions = {}, RunePuzzles = {}, RebirthItems = {} },
    
    SelectedCoords = nil, EspPlayers = false, EspMobs = false, EspItems = false, EspMaxDistance = 150
}

local ProximityBlacklist = {
    ["teleport"] = true, ["talk"] = true, ["open"] = true, ["take"] = true, ["buy"] = true, 
    ["craft"] = true, ["upgrade"] = true, ["quest"] = true, ["use"] = true, ["interact"] = true,
    ["portal"] = true, ["телепорт"] = true, ["портал"] = true, ["repair"] = true, ["починить"] = true,
    ["ремонт"] = true
}

local RawGameDatabase = {}
local DropdownOptions = { Helmet = {}, Chestplate = {}, Leggings = {}, Boots = {}, Shield = {}, Weapon = {}, Diamonds = {}, Potions = {}, RunePuzzles = {}, RebirthItems = {} }
local DisplayNameToTechnicalId = {}
local activeSelectedIds = {}
local pickedCache = {}

-- [ СОХРАНЕНИЕ МАРШРУТОВ ]
local function SaveRoutesToFile()
    pcall(function()
        if writefile then
            local dataToSave = {}
            for routeName, wps in pairs(Config.SavedRoutes) do
                dataToSave[routeName] = {}
                for _, wp in ipairs(wps) do table.insert(dataToSave[routeName], {wp.Pos.X, wp.Pos.Y, wp.Pos.Z}) end
            end
            writefile("WareHub_Routes.txt", HttpService:JSONEncode(dataToSave))
        end
    end)
end

local function LoadRoutesFromFile()
    pcall(function()
        if isfile and readfile and isfile("WareHub_Routes.txt") then
            local raw = readfile("WareHub_Routes.txt")
            local decoded = HttpService:JSONDecode(raw)
            if decoded then
                Config.SavedRoutes = {}
                for routeName, wps in pairs(decoded) do
                    Config.SavedRoutes[routeName] = {}
                    for _, coords in ipairs(wps) do table.insert(Config.SavedRoutes[routeName], {Pos = Vector3.new(coords[1], coords[2], coords[3])}) end
                end
            end
        end
    end)
end
LoadRoutesFromFile()

-- [ УЛЬТРА ПАРСЕР ИГРОВЫХ МОДУЛЕЙ ДЛЯ ЛУТА ]
local function ParseGameModules()
    for _, module in pairs(ReplicatedStorage:GetDescendants()) do
        if module:IsA("ModuleScript") then
            local success, result = pcall(require, module)
            if success and type(result) == "table" then
                for id, info in pairs(result) do
                    if type(info) == "table" and (info.Name or info.DisplayName) then
                        pcall(function()
                            local realName = info.DisplayName or info.Name
                            if type(realName) ~= "string" or realName == "" then return end
                            local idStr = tostring(id)
                            if not idStr or idStr == "" then return end
                            
                            local lowerId = string.lower(idStr)
                            local parentName = string.upper(module.Name)
                            
                            if lowerId:find("1000", 1, true) or lowerId:find("greatsword", 1, true) or lowerId:find("bossrune", 1, true) then return end
                            
                            local digitParts = {}
                            for part in string.gmatch(idStr, "%d+") do
                                local num = tonumber(part)
                                if num then table.insert(digitParts, num) end
                            end
                            
                            -- Проверка на принадлежность к боссу (ID зоны 100/101 или ключевые слова)
                            local isBossItem = (digitParts[3] == 100 or digitParts[3] == 101 or lowerId:find("queen", 1, true) or lowerId:find("king", 1, true) or lowerId:find("boss", 1, true))
                            
                            local category = nil
                            
                            -- Фильтрация категорий
                            if lowerId:find("runefragment", 1, true) or lowerId:find("fragment", 1, true) or lowerId:find("rune", 1, true) or lowerId:find("bossrune", 1, true) or string.upper(idStr):find("RUNE") or parentName:find("RUNE") then
                                category = "RunePuzzles"
                            elseif #digitParts == 4 and digitParts[3] ~= 100 and digitParts[3] ~= 101 then
                                category = "RebirthItems"
                            elseif lowerId:find("diamond", 1, true) or string.upper(idStr):find("DIAMOND") then 
                                category = "Diamonds"
                            elseif lowerId:find("potion", 1, true) or string.upper(idStr):find("POTION") or parentName:find("POTION") then 
                                category = "Potions"
                            -- Обычное снаряжение пропускаем только если это НЕ вещь босса
                            elseif not isBossItem then
                                if lowerId:find("weapon", 1, true) or lowerId:find("sword", 1, true) or lowerId:find("pickaxe", 1, true) or lowerId:find("axe", 1, true) or string.upper(idStr):find("WEAPON") or parentName:find("WEAPON") then
                                    category = "Weapon"
                                elseif lowerId:find("shield", 1, true) or string.upper(idStr):find("SHIELD") or parentName:find("SHIELD") then
                                    category = "Shield"
                                elseif lowerId:find("helmet", 1, true) or string.upper(idStr):find("HELMET") or parentName:find("HELMET") then 
                                    category = "Helmet"
                                elseif lowerId:find("chest", 1, true) or lowerId:find("armor", 1, true) or lowerId:find("cloak", 1, true) or string.upper(idStr):find("CHESTPLATE") or parentName:find("CHESTPLATE") then 
                                    category = "Chestplate"
                                elseif lowerId:find("leg", 1, true) or lowerId:find("pants", 1, true) or string.upper(idStr):find("LEGGINGS") or parentName:find("LEGGINGS") then 
                                    category = "Leggings"
                                elseif lowerId:find("boots", 1, true) or string.upper(idStr):find("BOOTS") or parentName:find("BOOTS") then 
                                    category = "Boots"
                                elseif lowerId:find("heart", 1, true) then 
                                    category = "RunePuzzles"
                                end
                                
                                if not category then
                                    if info.Damage or info.Dmg then category = "Weapon"
                                    elseif info.Block or info.Defence then category = "Shield" end
                                end
                            end
                            
                            -- Если предмет подошел и это НЕ экипировка босса — добавляем в базу
                            if category and not (isBossItem and category ~= "RunePuzzles" and category ~= "Potions" and category ~= "RebirthItems" and category ~= "Diamonds") then
                                local cleanName = realName:gsub("Рецепт на ", ""):gsub("Рецепт ", ""):gsub("[Rr]ecipe", ""):gsub("_", " ")
                                table.insert(RawGameDatabase, {
                                    Id = idStr, CleanIdLower = lowerId, RealName = realName, CleanName = cleanName, Category = category,
                                    IsBoss = false, Digits = digitParts
                                })
                            end
                        end)
                    end
                end
            end
        end
    end
end

local function SortByItemStructure(tbl)
    table.sort(tbl, function(a, b)
        local firstPartA = a:match("^([^|]+)") or ""
        local firstPartB = b:match("^([^|]+)") or ""
        local numA = {} for p in string.gmatch(firstPartA, "%d+") do table.insert(numA, tonumber(p)) end
        local numB = {} for p in string.gmatch(firstPartB, "%d+") do table.insert(numB, tonumber(p)) end
        for i = 1, math.max(#numA, #numB) do
            local valA = numA[i] or 0 local valB = numB[i] or 0
            if valA ~= valB then return valA < valB end
        end
        return a < b
    end)
end

local function UpdateMenuForWorld(worldNum)
    for cat, _ in pairs(DropdownOptions) do DropdownOptions[cat] = {} end
    table.clear(DisplayNameToTechnicalId)
    
    for _, item in pairs(RawGameDatabase) do
        local idStr = item.Id
        local category = item.Category
        local cleanName = item.CleanName
        local itemWorld = item.Digits[1] or 1
        local itemZone = item.Digits[2] or 1
        local itemTier = item.Digits[3] or 1
        local itemSubTier = item.Digits[4]
        
        local canAdd = false
        local displayName = cleanName
        
        if category == "RebirthItems" then
            if itemWorld == worldNum then
                local subStr = itemSubTier and ("-" .. itemSubTier) or ""
                displayName = itemWorld .. "-" .. itemZone .. "-" .. itemTier .. subStr .. " | " .. cleanName
                canAdd = true
            end
        elseif category == "Potions" or category == "RunePuzzles" or category == "Diamonds" then
            if category == "Diamonds" or itemWorld == worldNum then
                local zoneStr = itemZone and ("-" .. itemZone) or ""
                displayName = itemWorld .. zoneStr .. " | " .. cleanName
                canAdd = true
            end
        else
            if itemWorld == worldNum then
                local tierLabel = tostring(itemTier)
                if #item.Digits >= 3 then displayName = itemWorld .. "-" .. itemZone .. "-" .. tierLabel .. " | " .. cleanName
                else displayName = itemWorld .. "-1-" .. tierLabel .. " | " .. cleanName end
                canAdd = true
            end
        end
        
        if canAdd then
            if not table.find(DropdownOptions[category], displayName) then
                table.insert(DropdownOptions[category], displayName)
                DisplayNameToTechnicalId[displayName] = string.lower(idStr)
            end
        end
    end
    
    for cat, list in pairs(DropdownOptions) do
        SortByItemStructure(list)
        if #list == 0 then table.insert(list, (Language == "RU" and "Нет предметов" or "No Items")) end
    end
end

pcall(ParseGameModules)
UpdateMenuForWorld(1)

local function RecalculateSelectedCache()
    table.clear(activeSelectedIds)
    for cat, list in pairs(Config.SelectedItems) do
        for _, displayName in pairs(list) do
            local realId = DisplayNameToTechnicalId[displayName]
            if realId then activeSelectedIds[realId] = true end
        end
    end
end

local function PlayClick()
    local sound = Instance.new("Sound", game:GetService("SoundService"))
    sound.SoundId = "rbxassetid://6895079853"; sound.Volume = 0.5; sound:Play()
    sound.Stopped:Connect(function() sound:Destroy() end)
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or pickedCache[prompt] then return end
    if prompt:IsDescendantOf(workspace) then
        pickedCache[prompt] = true
        pcall(function() prompt.HoldDuration = 0; prompt.MaxActivationDistance = 60; fireproximityprompt(prompt) end)
        task.delay(0.05, function() pickedCache[prompt] = nil end)
    end
end

local function CheckLootFilterMatch(prompt)
    if not prompt.Enabled then return false end
    local actionText = string.lower(prompt.ActionText or "")
    local objectText = string.lower(prompt.ObjectText or "")
    if ProximityBlacklist[actionText] or ProximityBlacklist[objectText] then return false end
    if Config.LootAll then return true end
    if not Config.AutoLoot then return false end
    
    local current = prompt.Parent
    for i = 1, 4 do
        if not current or current == workspace then break end
        local objNameLower = string.lower(current.Name)
        if activeSelectedIds[objNameLower] then return true end
        
        for targetId, _ in pairs(activeSelectedIds) do
            if objNameLower == targetId or objNameLower:find("_" .. targetId .. "$") or objNameLower:find("^" .. targetId .. "_") or objNameLower:find("_" .. targetId .. "_") then
                return true
            end
        end
        
        for _, child in pairs(current:GetChildren()) do
            if child:IsA("StringValue") or child:IsA("TextValue") then
                local valLower = string.lower(tostring(child.Value))
                if activeSelectedIds[valLower] then return true end
            end
        end
        current = current.Parent
    end
    return false
end

local function GetCleanItemName(prompt)
    local current = prompt.Parent
    for i = 1, 3 do
        if not current or current == workspace then break end
        local nameLower = string.lower(current.Name)
        for _, item in pairs(RawGameDatabase) do
            if nameLower == string.lower(item.Id) or nameLower:find(string.lower(item.Id)) then
                return item.CleanName, item.Category
            end
        end
        current = current.Parent
    end
    return prompt.ObjectText ~= "" and prompt.ObjectText or "Item", nil
end

local CategoryLabels = {
    Helmet = (Language == "RU" and "ШЛЕМ" or "HELMET"), Chestplate = (Language == "RU" and "НАГРУДНИК" or "CHESTPLATE"),
    Leggings = (Language == "RU" and "ШТАНЫ" or "LEGGINGS"), Boots = (Language == "RU" and "БОТИНКИ" or "BOOTS"),
    Shield = (Language == "RU" and "ЩИТ" or "SHIELD"), Weapon = (Language == "RU" and "ОРУЖИЕ" or "WEAPON"),
    Diamonds = (Language == "RU" and "АЛМАЗЫ" or "DIAMONDS"), RunePuzzles = (Language == "RU" and "ПАЗЛЫ РУН" or "RUNE PUZZLES"),
    Potions = (Language == "RU" and "ЗЕЛЬЯ" or "POTIONS"), RebirthItems = (Language == "RU" and "ПЕРЕРОЖДЕНИЕ" or "REBIRTH")
}

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

local function ApplyGodModeHook(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    pcall(function()
        local mt = getrawmetatable(hum)
        if mt and mt.__index then
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__index = newcclosure(function(self, key)
                if key == "Health" and self == hum and Config.GodMode then return hum.MaxHealth end
                return oldIndex(self, key)
            end)
        end
    end)
end

-- [ ВИЗУАЛИЗАЦИЯ АГРА ]
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

-- [[ СБОР ДАННЫХ ДЛЯ ЦИКЛОВ ]]
local SharedLoot = {}
local SharedMobs = {}
local activeLootObject = nil
local activeMobObject = nil

task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
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

            local maxLootDist = Config.FlyFarm and (Config.BallSize / 2) or 35
            local closestLoot = nil
            for _, loot in pairs(SharedLoot) do
                local dist = (hrp.Position - loot.Part.Position).Magnitude
                if dist <= maxLootDist then
                    if CheckLootFilterMatch(loot.Prompt) then maxLootDist = dist; closestLoot = loot end
                end
            end
            activeLootObject = closestLoot

            if not activeLootObject then
                local allowedRadius = Config.PathFarming and Config.CurrentRadius or Config.WalkRadius
                local minMobDist, closestMob = allowedRadius, nil
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
        task.wait(0.12)
    end
end)

-- [[ СТРОИТЕЛЬ ИНТЕРФЕЙСА RAYFIELD ]]
local Window = Rayfield:CreateWindow({Name = "BloxLoot WareHub v13 [Update 0]", LoadingTitle = "Loading Ultimate Script...", ConfigurationSaving = {Enabled = false}})

local Tab1 = Window:CreateTab(L[Language].Main)
Tab1:CreateSection(L[Language].LangSec)
Tab1:CreateDropdown({
    Name = L[Language].LangSel, Options = {"EN 🇺🇸", "RU 🇷🇺"}, CurrentOption = (Language == "RU" and {"RU 🇷🇺"} or {"EN 🇺🇸"}), MultipleOptions = false,
    Callback = function(Option)
        local choice = type(Option) == "table" and Option[1] or Option
        local code = choice:sub(1,2)
        pcall(function() if writefile then writefile("WareHub_Lang.txt", code) end end)
        Rayfield:Notify({Title = "Language", Content = L[Language].LangWarn, Duration = 4})
    end,
})
Tab1:CreateSection(L[Language].GodModeSec)
Tab1:CreateToggle({Name = L[Language].GodMode, CurrentValue = false, Callback = function(v) 
    PlayClick(); Config.GodMode = v 
    if Player.Character then for _, part in pairs(Player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanTouch = not v end end end
end})
Tab1:CreateSection(L[Language].PlrSec)
Tab1:CreateSlider({Name = L[Language].Walk, Range = {16, 40}, Increment = 1, CurrentValue = 16, Callback = function(v) Config.WalkSpeed = v end})
Tab1:CreateToggle({Name = L[Language].InfJ, CurrentValue = false, Callback = function(v) PlayClick(); Config.InfiniteJump = v end})

local TabAtk = Window:CreateTab(L[Language].Atk)
TabAtk:CreateSection(L[Language].AtkSec)
TabAtk:CreateToggle({Name = L[Language].FastAtk, CurrentValue = false, Callback = function(v) Config.FastAttackEnabled = v end})
TabAtk:CreateToggle({Name = L[Language].AutoAtk, CurrentValue = false, Callback = function(v) PlayClick(); Config.AutoAttack = v end})

local TabFarm = Window:CreateTab(L[Language].Farm)
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
TabFarm:CreateSlider({Name = L[Language].AgroRad, Range = {5, 30}, Increment = 1, CurrentValue = 20, Callback = function(v) Config.CurrentRadius = v; AgroBox.Size = Vector3.new(v*2, 14, v*2) end})
TabFarm:CreateButton({Name = L[Language].RecStr, Callback = function() PlayClick(); Config.Recording = true; Config.Waypoints = {}; for _,v in pairs(Config.Visuals) do if v then v:Destroy() end end Config.Visuals = {}; Config.CurrentIdx = 1 Rayfield:Notify({Title = "Route", Content = L[Language].RecStartNotif, Duration = 2}) end})
TabFarm:CreateButton({Name = L[Language].RecStp, Callback = function() PlayClick(); Config.Recording = false Rayfield:Notify({Title = "Route", Content = L[Language].RecStopNotif, Duration = 2}) end})
TabFarm:CreateInput({Name = L[Language].RouteInput, PlaceholderText = "Route 1", RemoveTextAfterFocusLost = false, Callback = function(Text) Config.RouteInputName = Text end})

local initialRoutes = {}
for k, _ in pairs(Config.SavedRoutes) do table.insert(initialRoutes, k) end
if #initialRoutes == 0 then table.insert(initialRoutes, "...") end
local RouteSelectDrop = TabFarm:CreateDropdown({Name = L[Language].RouteSelect, Options = initialRoutes, CurrentOption = {initialRoutes[1]}, MultipleOptions = false, Callback = function(Opt) Config.SelectedRouteName = type(Opt) == "table" and Opt[1] or Opt end})

TabFarm:CreateButton({Name = L[Language].RouteSave, Callback = function()
    local rName = Config.RouteInputName
    if rName == "" then Rayfield:Notify({Title = "Error", Content = L[Language].ErrNoName, Duration = 2}) return end
    if Config.SavedRoutes[rName] then Rayfield:Notify({Title = "Error", Content = L[Language].ErrNameTaken, Duration = 2}) return end
    if #Config.Waypoints < 2 then Rayfield:Notify({Title = "Error", Content = L[Language].ErrTooShort, Duration = 2}) return end
    Config.SavedRoutes[rName] = table.clone(Config.Waypoints); SaveRoutesToFile()
    local opts = {} for k,_ in pairs(Config.SavedRoutes) do table.insert(opts, k) end RouteSelectDrop:Refresh(opts, true)
    Rayfield:Notify({Title = "Success", Content = string.format(L[Language].SuccessSave, rName), Duration = 2})
end})
TabFarm:CreateButton({Name = L[Language].RouteLoad, Callback = function()
    if Config.SelectedRouteName and Config.SavedRoutes[Config.SelectedRouteName] then
        for _,v in pairs(Config.Visuals) do if v then v:Destroy() end end Config.Visuals = {}
        Config.Waypoints = table.clone(Config.SavedRoutes[Config.SelectedRouteName]); Config.CurrentIdx = 1
        for _, w in ipairs(Config.Waypoints) do
            local p = Instance.new("Part", workspace); p.Anchored = true; p.CanCollide = false; p.Position = w.Pos; p.Size = Vector3.new(0.6, 0.6, 0.6); p.Color = Color3.fromRGB(0, 255, 150); table.insert(Config.Visuals, p)
        end
        Rayfield:Notify({Title = "Success", Content = L[Language].SuccessLoad, Duration = 2})
    end
end})
TabFarm:CreateButton({Name = L[Language].RouteDel, Callback = function()
    if Config.SelectedRouteName and Config.SavedRoutes[Config.SelectedRouteName] then
        Config.Waypoints = {}; for _,v in pairs(Config.Visuals) do if v then v:Destroy() end end Config.Visuals = {}
        Config.SavedRoutes[Config.SelectedRouteName] = nil; SaveRoutesToFile()
        local opts = {} for k,_ in pairs(Config.SavedRoutes) do table.insert(opts, k) end if #opts == 0 then table.insert(opts, "...") end RouteSelectDrop:Refresh(opts, true)
        Config.SelectedRouteName = nil; Rayfield:Notify({Title = "Removed", Content = L[Language].SuccessDel, Duration = 2})
    end
end})

-- [ ВКЛАДКА: АВТОПОДБОР ПРЕДМЕТОВ ]
local TabLoot = Window:CreateTab(L[Language].LootTab)
TabLoot:CreateSection(L[Language].LootModeSec)
TabLoot:CreateToggle({Name = L[Language].LootFilterTog, CurrentValue = false, Callback = function(v) Config.AutoLoot = v end})
TabLoot:CreateToggle({Name = L[Language].LootAllTog, CurrentValue = false, Callback = function(v) Config.LootAll = v end})

local DropHelmets, DropChestplates, DropLeggings, DropBoots, DropShields, DropWeapons, DropDiamonds, DropPotions, DropRunes, DropRebirthItems

TabLoot:CreateSection(L[Language].FiltWorldSec)
TabLoot:CreateDropdown({
    Name = L[Language].WorldSelect, Options = L[Language].WorldsArray, CurrentOption = {L[Language].WorldsArray[1]}, MultipleOptions = false,
    Callback = function(selectedTable)
        local choice = selectedTable[1]
        local worldNum = (choice:find("2") and 2) or (choice:find("3") and 3) or 1
        UpdateMenuForWorld(worldNum); RecalculateSelectedCache()
        
        DropHelmets:Refresh(DropdownOptions.Helmet, {}) 
        DropChestplates:Refresh(DropdownOptions.Chestplate, {})
        DropLeggings:Refresh(DropdownOptions.Leggings, {}) 
        DropBoots:Refresh(DropdownOptions.Boots, {})
        DropShields:Refresh(DropdownOptions.Shield, {}) 
        DropWeapons:Refresh(DropdownOptions.Weapon, {})
        DropDiamonds:Refresh(DropdownOptions.Diamonds, {}) 
        DropPotions:Refresh(DropdownOptions.Potions, {})
        DropRunes:Refresh(DropdownOptions.RunePuzzles, {}) 
        DropRebirthItems:Refresh(DropdownOptions.RebirthItems, {})
    end
})

TabLoot:CreateSection(L[Language].EquipSec)
DropHelmets = TabLoot:CreateDropdown({Name = L[Language].HelmName, Options = DropdownOptions.Helmet, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.Helmet = s; RecalculateSelectedCache() end})
DropChestplates = TabLoot:CreateDropdown({Name = L[Language].ChestName, Options = DropdownOptions.Chestplate, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.Chestplate = s; RecalculateSelectedCache() end})
DropLeggings = TabLoot:CreateDropdown({Name = L[Language].LegName, Options = DropdownOptions.Leggings, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.Leggings = s; RecalculateSelectedCache() end})
DropBoots = TabLoot:CreateDropdown({Name = L[Language].BootName, Options = DropdownOptions.Boots, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.Boots = s; RecalculateSelectedCache() end})
DropShields = TabLoot:CreateDropdown({Name = L[Language].ShieldName, Options = DropdownOptions.Shield, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.Shield = s; RecalculateSelectedCache() end})
DropWeapons = TabLoot:CreateDropdown({Name = L[Language].WepName, Options = DropdownOptions.Weapon, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.Weapon = s; RecalculateSelectedCache() end})

TabLoot:CreateSection(L[Language].SpecSec)
DropPotions = TabLoot:CreateDropdown({Name = L[Language].PotName, Options = DropdownOptions.Potions, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.Potions = s; RecalculateSelectedCache() end})
DropRunes = TabLoot:CreateDropdown({Name = L[Language].RuneName, Options = DropdownOptions.RunePuzzles, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.RunePuzzles = s; RecalculateSelectedCache() end})
DropDiamonds = TabLoot:CreateDropdown({Name = L[Language].DiamName, Options = DropdownOptions.Diamonds, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.Diamonds = s; RecalculateSelectedCache() end})
DropRebirthItems = TabLoot:CreateDropdown({Name = L[Language].RebirthName, Options = DropdownOptions.RebirthItems, CurrentOption = {}, MultipleOptions = true, Callback = function(s) Config.SelectedItems.RebirthItems = s; RecalculateSelectedCache() end})

local World1Points = { ["Boss 1"] = Vector3.new(-66, 41.7, -12.4), ["Boss 2"] = Vector3.new(-89.5, 52.2, -160.7), ["Boss 3"] = Vector3.new(-18.2, 81.5, -505.9), ["Boss 4"] = Vector3.new(-91.3, 141.7, -632.9), ["World 1 Boss Rune"] = Vector3.new(2.5, 58.8, -24.5) }
local World2Points = { ["Boss 1"] = Vector3.new(75, 6, -112), ["Boss 2"] = Vector3.new(51, -13, -449), ["Boss 3"] = Vector3.new(78, 41.1, -835), ["Boss 4"] = Vector3.new(60, 4, -1012) }
local TabWorlds = Window:CreateTab(L[Language].Worlds)
TabWorlds:CreateDropdown({Name = L[Language].W1, Options = {" ", "Boss 1", "Boss 2", "Boss 3", "Boss 4", "World 1 Boss Rune"}, CurrentOption = " ", Callback = function(O) local c = type(O)=="table" and O[1] or O; Config.SelectedCoords = (c~=" ") and World1Points[c] or nil end})
TabWorlds:CreateDropdown({Name = L[Language].W2, Options = {" ", "Boss 1", "Boss 2", "Boss 3", "Boss 4"}, CurrentOption = " ", Callback = function(O) local c = type(O)=="table" and O[1] or O; Config.SelectedCoords = (c~=" ") and World2Points[c] or nil end})
TabWorlds:CreateButton({Name = L[Language].TPBtn, Callback = function() if Config.SelectedCoords then TeleportTo(Config.SelectedCoords) end end})

local TabVisuals = Window:CreateTab(L[Language].Vis)
TabVisuals:CreateSection(L[Language].EspSec)
TabVisuals:CreateToggle({Name = L[Language].EspPlr, CurrentValue = false, Callback = function(v) PlayClick(); Config.EspPlayers = v if not v then FullClearESP() end end})
TabVisuals:CreateToggle({Name = L[Language].EspMob, CurrentValue = false, Callback = function(v) PlayClick(); Config.EspMobs = v if not v then FullClearESP() end end})
TabVisuals:CreateToggle({Name = L[Language].EspItm, CurrentValue = false, Callback = function(v) Config.EspItems = v if not v then FullClearESP() end end})
TabVisuals:CreateSlider({Name = L[Language].EspDist, Range = {50, 1000}, Increment = 10, CurrentValue = 150, Callback = function(v) Config.EspMaxDistance = v end})

local TabMisc = Window:CreateTab(L[Language].Misc)
TabMisc:CreateSection(L[Language].ServSec)
TabMisc:CreateButton({Name = L[Language].Hop, Callback = HopToEmptyServer})
TabMisc:CreateSection(L[Language].PosSec)
TabMisc:CreateButton({Name = L[Language].PosBtn, Callback = function() PlayClick(); local hrp = Player.Character:FindFirstChild("HumanoidRootPart") if hrp then Config.SavedPos = hrp.CFrame; Rayfield:Notify({Title = "Saved", Content = "Point Saved!", Duration = 2}) end end})
TabMisc:CreateToggle({Name = L[Language].AutoRet, CurrentValue = false, Callback = function(v) PlayClick(); Config.AutoReturnEnabled = v end})
TabMisc:CreateSection(L[Language].HudSec)
TabMisc:CreateToggle({Name = L[Language].Stats, CurrentValue = false, Callback = function(v) PlayClick(); Config.ShowStats = v end})

-- [[ ПОТОК ДЛЯ СБОРА НА ПОЛУ В РЕЖИМЕ СВОБОДНОГО БЕГА ]]
task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if (Config.AutoLoot or Config.LootAll) and hrp and not Config.FlyFarm and not Config.PathFarming then
            for _, item in pairs(SharedLoot) do
                if (hrp.Position - item.Part.Position).Magnitude <= 35 then
                    if CheckLootFilterMatch(item.Prompt) then TriggerPrompt(item.Prompt) end
                end
            end
        end
        task.wait(0.12)
    end
end)

-- [[ ОБНОВЛЕННЫЙ, ИСПРАВЛЕННЫЙ ФЛАЙ-АВТОФАРМ ]]
local waveTime = 0
RunService.Heartbeat:Connect(function(dt)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if Config.FlyFarm and hrp then
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

-- [[ ПАТ-ФАРМИНГ ]]
local engagedWithMob = false
task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        
        if Config.PathFarming and not Config.FlyFarm and hrp and hum and #Config.Waypoints > 0 then
            if activeLootObject and activeLootObject.Part then
                hum:MoveTo(activeLootObject.Part.Position)
                if (hrp.Position - activeLootObject.Part.Position).Magnitude <= 6 then
                    TriggerPrompt(activeLootObject.Prompt)
                end
            elseif activeMobObject and activeMobObject:FindFirstChild("HumanoidRootPart") then
                engagedWithMob = true
                hum:MoveTo(activeMobObject.HumanoidRootPart.Position)
            else
                if engagedWithMob then
                    engagedWithMob = false
                    local closestIdx = 1
                    local minDistance = math.huge
                    for idx, wp in ipairs(Config.Waypoints) do
                        local dist = (hrp.Position - wp.Pos).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            closestIdx = idx
                        end
                    end
                    Config.CurrentIdx = closestIdx
                end
                
                local w = Config.Waypoints[Config.CurrentIdx]
                if w then
                    hum:MoveTo(w.Pos)
                    if (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(w.Pos.X, w.Pos.Z)).Magnitude < 4.5 then 
                        Config.CurrentIdx = (Config.CurrentIdx < #Config.Waypoints) and Config.CurrentIdx + 1 or 1 
                    end
                end
            end
        end
        task.wait(0.03)
    end
end)

-- [[ ОСТАЛЬНЫЕ СИСТЕМЫ ]]
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not Config.FastAttackEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
end)

task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if Config.Recording and hrp and (#Config.Waypoints == 0 or (hrp.Position - Config.Waypoints[#Config.Waypoints].Pos).Magnitude > 3.2) then
            table.insert(Config.Waypoints, {Pos = hrp.Position})
            local p = Instance.new("Part", workspace); p.Anchored = true; p.CanCollide = false; p.Position = hrp.Position; p.Size = Vector3.new(0.6,0.6,0.6); p.Color = Color3.fromRGB(0, 255, 150); table.insert(Config.Visuals, p)
        end
        task.wait(0.12)
    end
end)

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
        task.wait(0.05)
    end
end)

RunService.Stepped:Connect(function() 
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then 
        Player.Character.Humanoid.WalkSpeed = Config.WalkSpeed 
        if Config.GodMode then
            for _, part in pairs(Player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanTouch = false end end
        end
    end 
end)

UserInputService.JumpRequest:Connect(function() if Config.InfiniteJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
if Player.Character then task.spawn(ApplyGodModeHook, Player.Character) end
Player.CharacterAdded:Connect(function(char)
    task.spawn(ApplyGodModeHook, char) task.wait(0.3)
    if not Player.PlayerGui:FindFirstChild("StatsGui") then SetupStats() end
    if Config.AutoReturnEnabled and Config.SavedPos then local hrp = char:WaitForChild("HumanoidRootPart", 10) if hrp then task.wait(0.2); hrp.CFrame = Config.SavedPos end end
    if Config.FlyFarm then CreateVisualBall(char) end
end)

-- [[ ЖЕЛЕЗОБЕТОННАЯ СИСТЕМА ФОРМАТИРОВАНИЯ ХП ]]
local function FormatHP(val)
    if not val then return "0" end
    if val < 1000 then return tostring(math.floor(val)) end
    
    local formatted, suffix
    if val >= 10^12 then
        formatted = string.format("%.2f", val / 10^12) suffix = "T"
    elseif val >= 10^9 then
        formatted = string.format("%.2f", val / 10^9) suffix = "B"
    elseif val >= 10^6 then
        formatted = string.format("%.2f", val / 10^6) suffix = "M"
    elseif val >= 10^3 then
        formatted = string.format("%.2f", val / 10^3) suffix = "K"
    end
    
    formatted = formatted:gsub("%.00", "")
    if formatted:find("%.") then
        formatted = formatted:gsub("0+$", "")
        formatted = formatted:gsub("%.$", "")
    end
    
    return formatted .. suffix
end

local function GetHealthColor(percent) return Color3.fromHSV((math.clamp(percent, 0, 1) * 120) / 360, 1, 1) end

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
                            local hum = v:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                local currentHp = hum.Health local maxHp = hum.MaxHealth
                                local percent = maxHp > 0 and (currentHp / maxHp) or 0
                                local hpColor = GetHealthColor(percent)
                                local tag = CreateTag(t, "CleanTag", hpColor)
                                tag.Text = string.format("%s | [%s/%s]", (hum.DisplayName ~= "" and hum.DisplayName) or v.Name, FormatHP(currentHp), FormatHP(maxHp))
                                tag.TextColor3 = hpColor
                                CreateHighlight(v).FillColor = p and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 0, 0)
                            else
                                if t:FindFirstChild("CleanTag") then t.CleanTag:Destroy() end
                                if v:FindFirstChild("EspHighlight") then v.EspHighlight:Destroy() end
                            end
                        else
                            if t:FindFirstChild("CleanTag") then t.CleanTag:Destroy() end
                            if v:FindFirstChild("EspHighlight") then v.EspHighlight:Destroy() end
                        end
                    else
                        if t and t:FindFirstChild("CleanTag") then t.CleanTag:Destroy() end
                        if v:FindFirstChild("EspHighlight") then v.EspHighlight:Destroy() end
                    end
                elseif Config.EspItems and v:IsA("ProximityPrompt") then
                    local t = v.Parent:IsA("BasePart") and v.Parent or v.Parent:FindFirstChildOfClass("BasePart")
                    if t and mHrp and (mHrp.Position - t.Position).Magnitude <= Config.EspMaxDistance then
                        local rn, cat = GetCleanItemName(v)
                        local tag = CreateTag(t, "ItemTag", cat and CategoryLabels[cat] and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(255, 60, 60))
                        tag.Text = (cat and CategoryLabels[cat] and "["..CategoryLabels[cat].."] " or "[ПРЕДМЕТ] ") .. tostring(rn)
                    else
                        if t and t:FindFirstChild("ItemTag") then t.ItemTag:Destroy() end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)
