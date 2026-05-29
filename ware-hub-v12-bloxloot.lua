local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

-- [ КОНФИГ ]
local Config = {
    -- Главная
    WalkSpeed = 16,
    InfiniteJump = false,
    ShowStats = false,
    SavedPos = nil,
    AutoReturnEnabled = false,
    
    -- Атака
    AutoAttack = false,
    MultiHit = false,
    
    -- Автофарм
    AutoFarm = false, 
    FlyFarm = false,  
    FarmSpeed = 28,       
    HeightOffset = 1.5,   
    DistanceOffset = 3.5, 
    BallSize = 40,        
    WalkRadius = 1250,    -- ИСПРАВЛЕНО: Радиус увеличен до 1250, чтобы видеть всю карту целиком
    PostKillWait = 0.3,
    SelectedMobs = {}, 

    -- Фарм по путям
    PathFarming = false,
    Recording = false,
    CurrentRadius = 20,
    CurrentIdx = 1,
    IsJumpingNow = false,
    Waypoints = {},
    Visuals = {},

    -- Фильтр и сбор лута
    CollectEnabled = false,   
    LootRadius = 25,
    LootFilter = {
        CollectAll = false,
        Helmet = true,
        Chestplate = true,
        Leggings = true,
        Boots = true,
        Shield = true,
        Weapon = true,
        Diamonds = true,
        RunePuzzles = true,
        Potions = true,
        RebirthItems = true
    },
    
    -- Телепорты и ESP
    SelectedCoords = nil,
    EspPlayers = false,
    EspMobs = false,
    EspItems = false,
    EspMaxDistance = 150
}

-- [ БАЗА ДАННЫХ ПРЕДМЕТОВ ]
local LootDatabase = {
    {Category = "RebirthItems", Keywords = {"WOLF CLAW", "CLAW", "REBIRTH", "MATERIAL", "LOOTPOINT", "ENEMY"}},
    {Category = "Helmet", Keywords = {"HELMET"}},
    {Category = "Chestplate", Keywords = {"CHESTPLATE"}},
    {Category = "Leggings", Keywords = {"LEGGINGS"}},
    {Category = "Boots", Keywords = {"BOOTS"}},
    {Category = "Shield", Keywords = {"SHIELD"}},
    {Category = "Weapon", Keywords = {"WEAPON", "SWORD", "SABER", "SPEAR", "MACE", "KNIFE", "DAGGER", "HAMMER", "PICKAXE", "AXE", "SHOVEL", "HOE"}},
    {Category = "Diamonds", Keywords = {"DIAMOND"}},
    {Category = "RunePuzzles", Keywords = {"RUNE", "FRAGMENT"}},
    {Category = "Potions", Keywords = {"POTION"}}
}

local CategoryLabels = {
    Helmet = "ШЛЕМ",
    Chestplate = "НАГРУДНИК",
    Leggings = "ШТАНЫ",
    Boots = "БОТИНКИ",
    Shield = "ЩИТ",
    Weapon = "ОРУЖИЕ",
    Diamonds = "АЛМАЗЫ",
    RunePuzzles = "ПАЗЛЫ РУН",
    Potions = "ЗЕЛЬЯ",
    RebirthItems = "ПРЕДМЕТ ДЛЯ ПЕРЕРОЖДЕНИЯ"
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
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if pickedCache[prompt] then return end
    
    if prompt:IsDescendantOf(workspace) then
        pickedCache[prompt] = true
        pcall(function()
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 60
            fireproximityprompt(prompt)
        end)
        task.delay(0.4, function()
            if prompt and prompt:IsDescendantOf(workspace) then
                pickedCache[prompt] = nil
            end
        end)
    end
end

local function GetCleanItemName(prompt)
    local rawIdentifiers = {}
    if prompt.ObjectText and prompt.ObjectText ~= "" then table.insert(rawIdentifiers, prompt.ObjectText) end
    if prompt.ActionText and prompt.ActionText ~= "" then table.insert(rawIdentifiers, prompt.ActionText) end
    
    local current = prompt.Parent
    for i = 1, 3 do
        if current and current ~= workspace then
            if current.Name ~= "BasePart" and current.Name ~= "Part" and current.Name ~= "MeshPart" then
                table.insert(rawIdentifiers, current.Name)
            end
            for _, child in pairs(current:GetChildren()) do
                if child:IsA("StringValue") or child:IsA("TextValue") then
                    table.insert(rawIdentifiers, child.Value)
                elseif (child:IsA("BillboardGui") or child:IsA("SurfaceGui")) and child.Name ~= "ItemTag" then
                    for _, textLabel in pairs(child:GetDescendants()) do
                        if textLabel:IsA("TextLabel") and textLabel.Text ~= "" and not string.find(textLabel.Text, "%[") then
                            table.insert(rawIdentifiers, textLabel.Text)
                        end
                    end
                end
            end
            pcall(function()
                for attrName, attrValue in pairs(current:GetAttributes()) do
                    if type(attrValue) == "string" then table.insert(rawIdentifiers, attrValue) end
                end
            end)
            current = current.Parent
        else
            break
        end
    end
    
    for _, text in pairs(rawIdentifiers) do
        local upperText = string.upper(text)
        for _, data in ipairs(LootDatabase) do
            for _, keyword in pairs(data.Keywords) do
                if string.find(upperText, keyword) then
                    return text, data.Category
                end
            end
        end
    end
    
    for _, text in pairs(rawIdentifiers) do
        if text ~= "BasePart" and text ~= "Part" and text ~= "MeshPart" and text ~= "ProximityPrompt" and text ~= "Pick" and text ~= "" and not string.find(text, "%[") then
            return text, nil
        end
    end
    return "Unknown Item", nil
end

local function ShouldPickupItem(prompt)
    local realName, category = GetCleanItemName(prompt)
    if Config.LootFilter.CollectAll then return true, category or "UNKNOWN", realName end
    if not Config.CollectEnabled then return false, category or "UNKNOWN", realName end

    if category then
        if Config.LootFilter[category] then return true, category, realName end
        return false, category, realName
    end
    return false, "UNKNOWN", realName
end

local function TeleportTo(coords)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and coords then
        PlayClick()
        hrp.CFrame = CFrame.new(coords)
    end
end

local function MoveTowards(currentCFrame, targetPosition, speed, deltaTime)
    local currentPosition = currentCFrame.Position
    local direction = (targetPosition - currentPosition)
    local distance = direction.Magnitude
    if distance <= 0.05 then return CFrame.new(targetPosition, targetPosition + currentCFrame.LookVector) end
    local moveDistance = math.min(speed * deltaTime, distance)
    return CFrame.new(currentPosition + (direction.Unit * moveDistance))
end

-- [ ВИЗУАЛЬНЫЕ ЭЛЕМЕНТЫ ФАРМА ]
local AgroBox = Instance.new("Part")
AgroBox.Name = "AgroVisualBox"; AgroBox.Shape = Enum.PartType.Block; AgroBox.Material = Enum.Material.ForceField; AgroBox.Color = Color3.fromRGB(255, 0, 0); AgroBox.Transparency = 0.75; AgroBox.CanCollide = false; AgroBox.Anchored = true
AgroBox.Parent = nil 

RunService.Heartbeat:Connect(function()
    if Config.PathFarming and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        AgroBox.Parent = workspace
        AgroBox.CFrame = Player.Character.HumanoidRootPart.CFrame
    else
        AgroBox.Parent = nil
    end
end)

local VisualBall = nil 
local function DestroyVisualBall()
    if VisualBall then VisualBall:Destroy(); VisualBall = nil end
end

local function CreateVisualBall(character)
    if not Config.FlyFarm then return end
    local hrp = character:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end
    DestroyVisualBall()
    VisualBall = Instance.new("Part")
    VisualBall.Name = "FarmVisualBall"; VisualBall.Shape = Enum.PartType.Ball; VisualBall.Size = Vector3.new(Config.BallSize, Config.BallSize, Config.BallSize)
    VisualBall.Color = Color3.fromRGB(255, 235, 50); VisualBall.Transparency = 0.8; VisualBall.Material = Enum.Material.ForceField; VisualBall.CanCollide = false; VisualBall.Anchored = true
    VisualBall.Parent = workspace
end

RunService.RenderStepped:Connect(function()
    if VisualBall and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        VisualBall.Position = Player.Character.HumanoidRootPart.Position
    end
end)

local function HopToEmptyServer()
    PlayClick()
    Rayfield:Notify({Title = "Поиск сервера", Content = "Сканируем открытые сервера...", Duration = 4})
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local bestServer = nil
    local minPlayers = math.huge
    local cursor = ""
    
    pcall(function()
        for i = 1, 15 do 
            local targetUrl = url .. (cursor ~= "" and "&cursor=" .. cursor or "")
            local response = game:HttpGet(targetUrl)
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                for _, server in pairs(data.data) do
                    local playerCount = tonumber(server.playing)
                    local maxPlayers = tonumber(server.maxPlayers)
                    if playerCount and playerCount > 0 and playerCount < minPlayers and playerCount < maxPlayers and server.id ~= game.JobId then
                        minPlayers = playerCount
                        bestServer = server.id
                    end
                end
                if data.nextPageCursor and data.nextPageCursor ~= "" then cursor = data.nextPageCursor else break end
            else break end
        end
        if bestServer then
            Rayfield:Notify({Title = "Сервер найден!", Content = "Перемещаемся на server с игроками: " .. tostring(minPlayers), Duration = 3})
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(placeId, bestServer, Player)
        else
            Rayfield:Notify({Title = "Внимание", Content = "Не удалось найти подходящий server.", Duration = 3})
        end
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
                local posStr = hrp and string.format("X:%.1f Y:%.1f Z:%.1f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z) or "N/A"
                lb.Text = "FPS: "..math.floor(1/task.wait()).."\nPING: "..math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()).."ms\n"..posStr
            else sg.Enabled = false end
            task.wait(0.5)
        end
    end)
end
SetupStats()

local function CreateTag(parent, tagName, textColor)
    local bb = parent:FindFirstChild(tagName) or Instance.new("BillboardGui", parent)
    bb.Name = tagName; bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 200, 0, 20); bb.ExtentsOffset = Vector3.new(0, 3, 0)
    local txt = bb:FindFirstChild("TextLabel") or Instance.new("TextLabel", bb)
    txt.BackgroundTransparency = 1; txt.Size = UDim2.new(1, 0, 1, 0); txt.TextStrokeTransparency = 0.5; txt.TextSize = 10; txt.Font = Enum.Font.SourceSansBold
    txt.TextColor3 = textColor or Color3.new(1, 1, 1)
    return txt
end

local function CreateHighlight(parent)
    local hl = parent:FindFirstChild("EspHighlight") or Instance.new("Highlight", parent)
    hl.Name = "EspHighlight"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.FillColor = Color3.fromRGB(255, 255, 255)
    return hl
end

local function FullClearESP()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CleanTag" or v.Name == "EspHighlight" or v.Name == "ItemTag" then v:Destroy() end
    end
end

local function IsTarget(model)
    if #Config.SelectedMobs == 0 then return true end
    local currentName = model:FindFirstChildOfClass("Humanoid") and model.Humanoid.DisplayName ~= "" and model.Humanoid.DisplayName or model.Name
    return table.find(Config.SelectedMobs, currentName) ~= nil
end

local function IsEnemy(model)
    if not model or not model:FindFirstChild("Humanoid") or model.Humanoid.Health <= 0 then return false end
    if Players:GetPlayerFromCharacter(model) or model == Player.Character then return false end
    if not IsTarget(model) then return false end
    return true
end

-- [[ ИНТЕРФЕЙС RAYFIELD ]]
local Window = Rayfield:CreateWindow({
   Name = "bloxloot v12 Ware hub update 3",
   LoadingTitle = "Загрузка...",
   ConfigurationSaving = {Enabled = false}
})

-- Вкладка: Главная
local Tab1 = Window:CreateTab("Главная")
Tab1:CreateSection("— Сервера —")
Tab1:CreateButton({Name = "Перейти на пустой сервер", Callback = HopToEmptyServer})
Tab1:CreateSection("— Настройки игрока —")
Tab1:CreateSlider({Name = "Скорость бега", Range = {16, 40}, Increment = 1, CurrentValue = 16, Callback = function(v) Config.WalkSpeed = v end})
Tab1:CreateToggle({Name = "Бесконечный прыжок", CurrentValue = false, Callback = function(v) PlayClick(); Config.InfiniteJump = v end})
Tab1:CreateToggle({Name = "Показать FPS / Ping / Координаты", CurrentValue = false, Callback = function(v) PlayClick(); Config.ShowStats = v end})
Tab1:CreateSection("— Сохранение позиции —")
Tab1:CreateButton({Name = "Сохранить точку", Callback = function()
    PlayClick()
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then Config.SavedPos = hrp.CFrame; Rayfield:Notify({Title = "Успех", Content = "Точка сохранена!", Duration = 3}) end
end})
Tab1:CreateToggle({Name = "Авто-возврат после смерти", CurrentValue = false, Callback = function(v) PlayClick(); Config.AutoReturnEnabled = v end})

-- Вкладка: Атака
local TabAtk = Window:CreateTab("Атака")
TabAtk:CreateSection("— Функции атаки —")
TabAtk:CreateToggle({Name = "Multi-Hit (Множитель ударов)", CurrentValue = false, Callback = function(v) Config.MultiHit = v end})
TabAtk:CreateToggle({Name = "Авто-атака", CurrentValue = false, Callback = function(v) PlayClick(); Config.AutoAttack = v end})

-- Вкладка: Автофарм
local TabFarm = Window:CreateTab("Автофарм")
TabFarm:CreateSection("— Обычный автофарм (Телепорт) —")
TabFarm:CreateToggle({Name = "Включить ТП-автофарм", CurrentValue = false, Callback = function(v) PlayClick(); Config.AutoFarm = v end})

TabFarm:CreateSection("— Флай-автофарм (Полет) —")
TabFarm:CreateToggle({Name = "Включить флай-автофарм", CurrentValue = false, Callback = function(v) 
    Config.FlyFarm = v 
    if v then if Player.Character then CreateVisualBall(Player.Character) end else DestroyVisualBall() end
end})
TabFarm:CreateSlider({Name = "Скорость полета", Range = {15, 42}, Increment = 1, CurrentValue = 28, Callback = function(v) Config.FarmSpeed = v end})
TabFarm:CreateSlider({Name = "Радиус сбора лута сферой", Range = {10, 20}, Increment = 1, CurrentValue = 20, Callback = function(v) 
    Config.BallSize = v * 2 
    if VisualBall and VisualBall.Parent then VisualBall.Size = Vector3.new(Config.BallSize, Config.BallSize, Config.BallSize) end
end})

TabFarm:CreateSection("— Настройка целей —")
local MobDropdown = TabFarm:CreateDropdown({
   Name = "Выбор мобов",
   Options = {"Обновите список целей"},
   CurrentOption = {" "},
   MultipleOptions = true,
   Callback = function(Options) Config.SelectedMobs = Options end,
})
TabFarm:CreateButton({Name = "Обновить список мобов на карте", Callback = function()
    local newList = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and not Players:GetPlayerFromCharacter(v.Parent) then
            local displayName = v.DisplayName ~= "" and v.DisplayName or v.Parent.Name
            if not table.find(newList, displayName) then table.insert(newList, displayName) end
        end
    end
    MobDropdown:Refresh(newList, true)
end})

TabFarm:CreateSection("— Фарм по путям (Path Farm) —")
TabFarm:CreateToggle({Name = "Включить Path Farm", CurrentValue = false, Callback = function(v) PlayClick(); Config.PathFarming = v; if v then Config.CurrentIdx = 1 end end})
TabFarm:CreateButton({Name = "Начать запись маршрута", Callback = function() PlayClick(); Config.Recording = true; Config.Waypoints = {}; for _,v in pairs(Config.Visuals) do if v then v:Destroy() end end; Config.Visuals = {}; Config.CurrentIdx = 1 end})
TabFarm:CreateButton({Name = "Остановить запись", Callback = function() PlayClick(); Config.Recording = false end})
TabFarm:CreateSlider({Name = "Радиус агра", Range = {5, 30}, Increment = 1, CurrentValue = 20, Callback = function(v) Config.CurrentRadius = v; AgroBox.Size = Vector3.new(v*2, 14, v*2) end})

TabFarm:CreateSection("— Настройки сбора лута —")
TabFarm:CreateToggle({Name = "Авто-подбор предметов", CurrentValue = false, Callback = function(v) PlayClick(); Config.CollectEnabled = v end})
TabFarm:CreateToggle({Name = "Собирать абсолютно все предметы", CurrentValue = false, Callback = function(v) Config.LootFilter.CollectAll = v end})

TabFarm:CreateSection("— Фильтр: Снаряжение —")
TabFarm:CreateDropdown({
   Name = "Снаряжение для сбора",
   Options = {"Шлем", "Нагрудник", "Штаны", "Ботинки", "Щит"},
   CurrentOption = {"Шлем", "Нагрудник", "Штаны", "Ботинки", "Щит"},
   MultipleOptions = true,
   Callback = function(Options)
      Config.LootFilter.Helmet = table.find(Options, "Шлем") ~= nil
      Config.LootFilter.Chestplate = table.find(Options, "Нагрудник") ~= nil
      Config.LootFilter.Leggings = table.find(Options, "Штаны") ~= nil
      Config.LootFilter.Boots = table.find(Options, "Ботинки") ~= nil
      Config.LootFilter.Shield = table.find(Options, "Щит") ~= nil
   end,
})

TabFarm:CreateSection("— Фильтр: Оружие —")
TabFarm:CreateDropdown({
   Name = "Оружие для сбора",
   Options = {"Оружие и Инструменты"},
   CurrentOption = {"Оружие и Инструменты"},
   MultipleOptions = true,
   Callback = function(Options)
      Config.LootFilter.Weapon = table.find(Options, "Оружие и Инструменты") ~= nil
   end,
})

TabFarm:CreateSection("— Фильтр: Остальное —")
TabFarm:CreateDropdown({
   Name = "Прочие предметы",
   Options = {"Алмазы", "Пазлы рун", "Зелья", "Предметы для перерождения"},
   CurrentOption = {"Алмазы", "Пазлы рун", "Зелья", "Предметы для перерождения"},
   MultipleOptions = true,
   Callback = function(Options)
      Config.LootFilter.Diamonds = table.find(Options, "Алмазы") ~= nil
      Config.LootFilter.RunePuzzles = table.find(Options, "Пазлы рун") ~= nil
      Config.LootFilter.Potions = table.find(Options, "Зелья") ~= nil
      Config.LootFilter.RebirthItems = table.find(Options, "Предметы для перерождения") ~= nil
   end,
})

-- Вкладка: Миры
local TabWorlds = Window:CreateTab("Миры")
TabWorlds:CreateSection("— Быстрое перемещение —")

local World1Points = {
    ["тп 1 король скелетов"] = Vector3.new(-66, 41.7, -12.4),
    ["тп 2 королева пауков"] = Vector3.new(-89.5, 52.2, -160.7),
    ["тп 3 король грязи"] = Vector3.new(-18.2, 81.5, -505.9),
    ["Тп 4 эвокер 'призыватель'"] = Vector3.new(-91.3, 141.7, -632.9),
    ["World 1 Boss Rune"] = Vector3.new(2.5, 58.8, -24.5)
}
local World2Points = {
    ["тп 1 генерал свино человек"] = Vector3.new(75, 6, -112),
    ["тп 2 мутированный грибок"] = Vector3.new(51, -13, -449),
    ["тп 3 Магма лорд"] = Vector3.new(78, 41.1, -835),
    ["тп 4 визер"] = Vector3.new(60, 4, -1012)
}

TabWorlds:CreateDropdown({
   Name = "1 МИР — Локации",
   Options = {" ", "тп 1 король скелетов", "тп 2 королева пауков", "тп 3 король грязи", "Тп 4 эвокер 'призыватель'", "World 1 Boss Rune"},
   CurrentOption = " ",
   Callback = function(Option)
      local choice = type(Option) == "table" and Option[1] or Option
      Config.SelectedCoords = (choice ~= " ") and World1Points[choice] or nil
   end,
})
TabWorlds:CreateDropdown({
   Name = "2 МИР — Локации",
   Options = {" ", "тп 1 генерал свино человек", "тп 2 мутированный грибок", "тп 3 Магма лорд", "тп 4 визер"},
   CurrentOption = " ",
   Callback = function(Option)
      local choice = type(Option) == "table" and Option[1] or Option
      Config.SelectedCoords = (choice ~= " ") and World2Points[choice] or nil
   end,
})
TabWorlds:CreateButton({Name = "ТЕЛЕПОРТИРОВАТЬСЯ", Callback = function() if Config.SelectedCoords then TeleportTo(Config.SelectedCoords) else Rayfield:Notify({Title = "Ошибка", Content = "Сначала выберите локацию!", Duration = 3}) end end})

-- Вкладка: Визуалы
local TabVisuals = Window:CreateTab("Визуалы")
TabVisuals:CreateSection("— Подсветка объектов (ESP) —")
TabVisuals:CreateToggle({Name = "Показывать игроков", CurrentValue = false, Callback = function(v) PlayClick(); Config.EspPlayers = v if not v then FullClearESP() end end})
TabVisuals:CreateToggle({Name = "Показывать мобов", CurrentValue = false, Callback = function(v) PlayClick(); Config.EspMobs = v if not v then FullClearESP() end end})
TabVisuals:CreateToggle({Name = "Показывать предметы", CurrentValue = false, Callback = function(v) Config.EspItems = v if not v then FullClearESP() end end})
TabVisuals:CreateSlider({Name = "Дистанция отображения", Range = {50, 1000}, Increment = 10, CurrentValue = 150, Callback = function(v) Config.EspMaxDistance = v end})


-- [[ СИСТЕМЫ АВТОМАТИЗАЦИИ СЛУЖБ ]]

-- 1. Сканнер объектов (Поиск лута и мобов)
task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and (Config.AutoFarm or Config.FlyFarm or Config.CollectEnabled) then
            local currentLoot = {}
            local currentMobs = {}

            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local root = v.Parent:IsA("BasePart") and v.Parent or v.Parent:FindFirstChildOfClass("BasePart")
                    if root then table.insert(currentLoot, {Prompt = v, Part = root}) end
                elseif v:IsA("Humanoid") and v.Parent and v.Parent:IsA("Model") and v.Health > 0 then
                    if IsEnemy(v.Parent) then table.insert(currentMobs, v.Parent) end
                end
            end

            local currentLootRadius = Config.FlyFarm and (Config.BallSize / 2) or Config.LootRadius
            local closestLoot = nil
            local minLootDist = currentLootRadius

            for _, loot in pairs(currentLoot) do
                local dist = (hrp.Position - loot.Part.Position).Magnitude
                if dist <= minLootDist then
                    local realName = GetCleanItemName(loot.Prompt)
                    local promptInfo = tostring(realName):lower()
                    if not (promptInfo:find("teleport") or promptInfo:find("portal") or promptInfo:find("телепорт") or promptInfo:find("портал")) then
                        local canPick = ShouldPickupItem(loot.Prompt)
                        if canPick then
                            minLootDist = dist; closestLoot = loot
                        end
                    end
                end
            end
            
            activeLootObject = closestLoot

            if (Config.AutoFarm or Config.FlyFarm) and not activeLootObject then
                local closestMob = nil
                local minMobDist = Config.WalkRadius -- Использует новый огромный радиус 1250
                for _, mob in pairs(currentMobs) do
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
            for _, p in pairs(Player.Character:GetDescendants()) do 
                if p:IsA("BasePart") then p.CanCollide = false end 
            end
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            
            if activeLootObject and activeLootObject.Part then
                hrp.CFrame = CFrame.new(activeLootObject.Part.Position + Vector3.new(0, 1, 0))
                task.wait(0.05)
                TriggerPrompt(activeLootObject.Prompt)
            elseif activeMobObject and activeMobObject:FindFirstChild("HumanoidRootPart") then
                local targetHrp = activeMobObject.HumanoidRootPart
                local targetPos = targetHrp.Position + (targetHrp.CFrame.LookVector * 2.75) + Vector3.new(0, 0.6, 0)
                
                hrp.CFrame = CFrame.new(targetPos, Vector3.new(targetHrp.Position.X, targetPos.Y, targetHrp.Position.Z)) 
                if activeMobObject.Humanoid.Health <= 0 then task.wait(Config.PostKillWait) end
            end
        end
        task.wait()
    end
end)

-- 3. КИНЕМАТИЧЕСКИЙ ФЛАЙ-АВТОФАРМ С МОДИФИКАЦИЕЙ СЛЭМА И КОРРЕКЦИЕЙ ОСИ ВЗГЛЯДА
local waveTime = 0
RunService.Heartbeat:Connect(function(deltaTime)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if Config.FlyFarm and not Config.AutoFarm and hrp then
        for _, part in pairs(Player.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)

        if activeLootObject and activeLootObject.Part then
            waveTime = waveTime + (deltaTime * 26)
            local bounce = (math.cos(waveTime) - 1) * 2.0 
            local targetPos = activeLootObject.Part.Position + Vector3.new(0, bounce + 1.2, 0)
            hrp.CFrame = MoveTowards(hrp.CFrame, targetPos, Config.FarmSpeed, deltaTime)
            if (hrp.Position - targetPos).Magnitude <= 6 then 
                TriggerPrompt(activeLootObject.Prompt) 
            end
        elseif activeMobObject and activeMobObject:FindFirstChild("HumanoidRootPart") then
            local eHrp = activeMobObject.HumanoidRootPart
            local frontPos = eHrp.Position + (eHrp.CFrame.LookVector * Config.DistanceOffset) + Vector3.new(0, Config.HeightOffset, 0)
            
            waveTime = waveTime + (deltaTime * 28) 
            local sharpBounce = (math.cos(waveTime) - 1) * 2.0 
            
            local finalTargetPos = frontPos + Vector3.new(0, sharpBounce, 0)
            local nextCFrame = MoveTowards(hrp.CFrame, finalTargetPos, Config.FarmSpeed, deltaTime)
            
            -- Выравнивание взгляда по горизонтали (Персонаж стоит прямо)
            hrp.CFrame = CFrame.new(nextCFrame.Position, Vector3.new(eHrp.Position.X, nextCFrame.Position.Y, eHrp.Position.Z)) 
        end
    end
end)

-- 4. Сборщик лута на полу (Если отключен основной автофарм)
task.spawn(function()
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if (Config.CollectEnabled or Config.LootFilter.CollectAll) and hrp and not Config.AutoFarm and not Config.FlyFarm then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if not Config.CollectEnabled and not Config.LootFilter.CollectAll then break end
                if prompt:IsA("ProximityPrompt") then
                    local root = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildOfClass("BasePart")
                    if root and (hrp.Position - root.Position).Magnitude <= Config.LootRadius then
                        local realName = GetCleanItemName(prompt)
                        local promptInfo = tostring(realName):lower()
                        if not (promptInfo:find("teleport") or promptInfo:find("portal") or promptInfo:find("телепорт") or promptInfo:find("портал")) then
                            local allowed = ShouldPickupItem(prompt)
                            if allowed then TriggerPrompt(prompt) end
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- 5. Движение по записанным путям (Path Farming)
task.spawn(function()
    local lastPos = Vector3.new(0,0,0); local stuckTimer = 0
    while true do
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if Config.PathFarming and not Config.AutoFarm and not Config.FlyFarm and hrp and hum and #Config.Waypoints > 0 then
            local target = nil; local dist = math.huge
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Humanoid") and IsEnemy(v.Parent) then
                    local tHrp = v.Parent:FindFirstChild("HumanoidRootPart")
                    if tHrp then
                        local diff = tHrp.Position - hrp.Position
                        if math.abs(diff.X) <= Config.CurrentRadius and math.abs(diff.Z) <= Config.CurrentRadius then
                            if diff.Magnitude < dist then dist = diff.Magnitude; target = v.Parent end
                        end
                    end
                end
            end
            if target then 
                hum:MoveTo(target.HumanoidRootPart.Position)
            else
                local data = Config.Waypoints[Config.CurrentIdx]
                if data then
                    if (hrp.Position - lastPos).Magnitude < 0.2 then stuckTimer = stuckTimer + 0.1 else stuckTimer = 0 end
                    lastPos = hrp.Position
                    if (data.Jumped or stuckTimer > 0.6) and not Config.IsJumpingNow then hum:ChangeState(Enum.HumanoidStateType.Jumping); Config.IsJumpingNow = true end
                    if hum:GetState() == Enum.HumanoidStateType.Landed then Config.IsJumpingNow = false end
                    hum:MoveTo(data.Pos)
                    if (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(data.Pos.X, data.Pos.Z)).Magnitude < 4.5 then
                        Config.CurrentIdx = (Config.CurrentIdx < #Config.Waypoints) and Config.CurrentIdx + 1 or 1
                    end
                end
            end
        end
        task.wait(0.03)
    end
end)

-- 6. Запись маршрутов для Path Farm
task.spawn(function()
    while true do
        if Config.Recording then
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (#Config.Waypoints == 0 or (hrp.Position - Config.Waypoints[#Config.Waypoints].Pos).Magnitude > 3.2) then
                table.insert(Config.Waypoints, {Pos = hrp.Position, Jumped = Player.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping})
                local p = Instance.new("Part", workspace); p.Anchored = true; p.CanCollide = false; p.Position = hrp.Position; p.Size = Vector3.new(0.6,0.6,0.6); p.Color = Color3.fromRGB(0, 255, 150); table.insert(Config.Visuals, p)
            end
        end
        task.wait(0.12)
    end
end)

-- 7. Циклы атаки и Multi-Hit
task.spawn(function()
    while true do
        if Config.AutoAttack and Player.Character and Player.Character:FindFirstChildOfClass("Tool") then
            Player.Character:FindFirstChildOfClass("Tool"):Activate()
        end
        task.wait(0.09)
    end
end)

task.spawn(function()
    while task.wait(0.04) do
        if Config.MultiHit then
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

-- 8. Игровые бинды и Хуки
RunService.Stepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then Player.Character.Humanoid.WalkSpeed = Config.WalkSpeed end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Player.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if not Player.PlayerGui:FindFirstChild("StatsGui") then SetupStats() end
    if Config.AutoReturnEnabled and Config.SavedPos then
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        if hrp then task.wait(0.2); hrp.CFrame = Config.SavedPos end
    end
    if Config.FlyFarm then CreateVisualBall(char) end
end)

-- 9. Поток ESP
task.spawn(function()
    while true do
        if Config.EspPlayers or Config.EspMobs or Config.EspItems then
            local myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v ~= Player.Character then
                    local targetPart = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                    local p = game.Players:GetPlayerFromCharacter(v)
                    if targetPart and myHrp and (myHrp.Position - targetPart.Position).Magnitude <= Config.EspMaxDistance then
                        if (p and Config.EspPlayers) or (not p and Config.EspMobs) then
                            local tag = CreateTag(targetPart, "CleanTag")
                            tag.Text = ((v.Humanoid.DisplayName ~= "" and v.Humanoid.DisplayName) or v.Name).." | HP: "..math.floor(v.Humanoid.Health)
                            CreateHighlight(v).FillColor = p and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 0, 0)
                        end
                    end
                elseif Config.EspItems and v:IsA("ProximityPrompt") then
                    local targetPart = v.Parent:IsA("BasePart") and v.Parent or v.Parent:FindFirstChildOfClass("BasePart")
                    if targetPart and myHrp and (myHrp.Position - targetPart.Position).Magnitude <= Config.EspMaxDistance then
                        local realName, category = GetCleanItemName(v)
                        local itemColor = Color3.fromRGB(255, 60, 60)
                        local statusText = "[ПРЕДМЕТ]"
                        
                        if category and CategoryLabels[category] then
                            itemColor = Color3.fromRGB(0, 255, 130)
                            statusText = "[" .. CategoryLabels[category] .. "]"
                        end
                        
                        local tag = CreateTag(targetPart, "ItemTag", itemColor)
                        tag.Text = statusText .. " " .. tostring(realName)
                    end
                end
            end
        end
        task.wait(1.0)
    end
end)
