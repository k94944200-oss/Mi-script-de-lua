--// Auto Server Hop For Fruits - HAZE SEAS EDITION
--// Solo Míticas/Legendarias | Auto Bag 7s + Auto Equip + Auto Fruit Bag

if getgenv().AutoServerHopForFruitsLoaded then return end
getgenv().AutoServerHopForFruitsLoaded = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

--// CONFIG
local config = {
    ESPFruitDrop = false,
    AutoTween = false,
    AutoBagFruit = false,
    AutoServerHop = false,
    SmartHopIfFull = true,
    AutoEquipFruit = true,      -- NUEVO: Auto equipar fruta
    AutoStoreFruit = true,      -- NUEVO: Auto guardar en Fruit Bag
    TweenSpeed = 250,
    HopDelay = 15,
    ESPUpdateRate = 0.1,
    FruitScanRate = 0.3,
    BagRange = 20,
    BagHoldDuration = 7,
    StoreDelay = 2              -- Esperar 2s para que aparezca el menú
}

--// FRUTAS MÍTICAS Y LEGENDARIAS
local FRUIT_NAMES = {
    "Dragon", "Gum", "Dough", "Electricity", "Phoenix", "Okuchi", 
    "Saturn", "Magma", "Darkness", "Venom", "Tremor", "Shadow", 
    "Magnet", "Wolf", "Leopard", "Soul"
}

--// COLORES
local COLORS = {
    BG = Color3.fromRGB(18, 18, 24),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 180),
    Green = Color3.fromRGB(34, 197, 94),
    Orange = Color3.fromRGB(251, 146, 60),
    Purple = Color3.fromRGB(168, 85, 247),
    Red = Color3.fromRGB(239, 68, 68),
    Yellow = Color3.fromRGB(250, 204, 21),
    Gray = Color3.fromRGB(75, 75, 85),
    Gold = Color3.fromRGB(255, 215, 0),
    Mythic = Color3.fromRGB(148, 0, 211),
    Cyan = Color3.fromRGB(6, 182, 212),
    Pink = Color3.fromRGB(236, 72, 153)
}

--// ESTADOS
local states = {
    tweening = false,
    hopping = false,
    hopTime = config.HopDelay,
    currentHop = config.HopDelay,
    hasFruit = false,
    inventoryFull = false,
    dragging = false,
    dragStart = nil,
    startPos = nil,
    bagging = false,
    bagStartTime = 0,
    currentBagFruit = nil,
    storing = false,
    lastStoredFruit = nil
}

--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoServerHopForFruits"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = CoreGui
elseif gethui then
    screenGui.Parent = gethui()
else
    screenGui.Parent = CoreGui
end

--// FRAME PRINCIPAL
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 480)
main.Position = UDim2.new(0.5, -170, 0.5, -240)
main.BackgroundColor3 = COLORS.BG
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6015897843"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ZIndex = -1
shadow.Parent = main

--// TÍTULO
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, -24, 0, 50)
titleBar.Position = UDim2.new(0, 12, 0, 12)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = main

local appleIcon = Instance.new("TextLabel")
appleIcon.Size = UDim2.new(0, 24, 0, 24)
appleIcon.BackgroundTransparency = 1
appleIcon.Text = "👑"
appleIcon.Font = Enum.Font.GothamBold
appleIcon.TextSize = 20
appleIcon.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -80, 0, 24)
titleText.Position = UDim2.new(0, 28, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "HAZE SEAS - MYTHIC ONLY"
titleText.Font = Enum.Font.GothamBlack
titleText.TextSize = 15
titleText.TextColor3 = COLORS.Gold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, -80, 0, 20)
subTitle.Position = UDim2.new(0, 28, 0, 22)
subTitle.BackgroundTransparency = 1
subTitle.Text = "Auto Bag + Auto Equip + Auto Store"
subTitle.Font = Enum.Font.GothamBold
subTitle.TextSize = 10
subTitle.TextColor3 = COLORS.TextDim
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = titleBar

-- Botones
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -28, 0, 0)
closeBtn.BackgroundColor3 = COLORS.Red
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = COLORS.Text
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.BackgroundColor3 = COLORS.Gray
minBtn.Text = "−"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = COLORS.Text
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

--// STATUS LABELS
local invStatus = Instance.new("TextLabel")
invStatus.Size = UDim2.new(1, -24, 0, 16)
invStatus.Position = UDim2.new(0, 12, 0, 65)
invStatus.BackgroundTransparency = 1
invStatus.Text = "Inventario: Vacío"
invStatus.Font = Enum.Font.GothamBold
invStatus.TextSize = 11
invStatus.TextColor3 = COLORS.TextDim
invStatus.TextXAlignment = Enum.TextXAlignment.Left
invStatus.Parent = main

local bagStatus = Instance.new("TextLabel")
bagStatus.Size = UDim2.new(1, -24, 0, 18)
bagStatus.Position = UDim2.new(0, 12, 0, 82)
bagStatus.BackgroundTransparency = 1
bagStatus.Text = "🎒 Esperando..."
bagStatus.Font = Enum.Font.GothamBold
bagStatus.TextSize = 13
bagStatus.TextColor3 = COLORS.Cyan
bagStatus.TextXAlignment = Enum.TextXAlignment.Left
bagStatus.Parent = main

local storeStatus = Instance.new("TextLabel")
storeStatus.Size = UDim2.new(1, -24, 0, 16)
storeStatus.Position = UDim2.new(0, 12, 0, 100)
storeStatus.BackgroundTransparency = 1
storeStatus.Text = "💼 Auto Store: Listo"
storeStatus.Font = Enum.Font.GothamBold
storeStatus.TextSize = 11
storeStatus.TextColor3 = COLORS.Pink
storeStatus.TextXAlignment = Enum.TextXAlignment.Left
storeStatus.Parent = main

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -24, 0, 16)
timerLabel.Position = UDim2.new(0, 12, 0, 116)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "⏱️ Hop in: " .. states.currentHop .. "s"
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextSize = 12
timerLabel.TextColor3 = COLORS.Orange
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = main

local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1, -24, 0, 16)
modeLabel.Position = UDim2.new(0, 12, 0, 48)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "🎯 Modo: Solo Míticas/Legendarias"
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextSize = 10
modeLabel.TextColor3 = COLORS.Mythic
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Parent = main

--// CONTENEDOR DE TOGGLES
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(1, -24, 1, -145)
toggleContainer.Position = UDim2.new(0, 12, 0, 135)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = main

local toggleLayout = Instance.new("UIListLayout")
toggleLayout.Padding = UDim.new(0, 8)
toggleLayout.Parent = toggleContainer

--// FUNCIÓN TOGGLE
local toggleButtons = {}

local function createToggle(name, key, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = toggleContainer
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = COLORS.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 30)
    btn.Position = UDim2.new(1, -60, 0.5, -15)
    btn.BackgroundColor3 = COLORS.Gray
    btn.Text = "OFF"
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 12
    btn.TextColor3 = COLORS.Text
    btn.AutoButtonColor = false
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    toggleButtons[key] = btn
    
    local function update()
        if config[key] then
            btn.BackgroundColor3 = color
            btn.Text = "ON"
        else
            btn.BackgroundColor3 = COLORS.Gray
            btn.Text = "OFF"
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        config[key] = not config[key]
        update()
    end)
    
    update()
    return btn
end

-- Toggles
createToggle("👑 ESP Mythic Only", "ESPFruitDrop", COLORS.Mythic)
createToggle("🏃 Auto Tween", "AutoTween", COLORS.Orange)
createToggle("🎒 Auto Bag (7s)", "AutoBagFruit", COLORS.Cyan)
createToggle("⚔️ Auto Equip", "AutoEquipFruit", COLORS.Gold)
createToggle("💼 Auto Fruit Bag", "AutoStoreFruit", COLORS.Pink)
createToggle("🌐 Auto Server Hop", "AutoServerHop", COLORS.Red)
createToggle("💼 Hop If Full", "SmartHopIfFull", COLORS.Yellow)

--// BOTÓN FLOTANTE
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 55, 0, 55)
floatBtn.Position = UDim2.new(0, 20, 0.5, -27)
floatBtn.BackgroundColor3 = COLORS.BG
floatBtn.Text = "👑"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 26
floatBtn.Visible = false
floatBtn.Parent = screenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

--// SISTEMA DE DRAG
local function setupDrag(frame, target)
    target = target or frame
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            states.dragging = true
            states.dragStart = input.Position
            states.startPos = target.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            states.dragInput = input
        end
    end)
end

setupDrag(titleBar, main)
setupDrag(floatBtn)

UserInputService.InputChanged:Connect(function(input)
    if states.dragging and input == states.dragInput then
        local delta = input.Position - states.dragStart
        main.Position = UDim2.new(
            states.startPos.X.Scale, 
            states.startPos.X.Offset + delta.X,
            states.startPos.Y.Scale, 
            states.startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        states.dragging = false
    end
end)

--// BOTONES DE CONTROL
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if espFolder then espFolder:Destroy() end
    getgenv().AutoServerHopForFruitsLoaded = false
end)

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
    floatBtn.Position = UDim2.new(0, main.AbsolutePosition.X + 20, 0, main.AbsolutePosition.Y + 20)
end)

floatBtn.MouseButton1Click:Connect(function()
    floatBtn.Visible = false
    main.Visible = true
end)

--// SISTEMA DE FRUTAS
local fruitCache = {}
local lastUpdate = 0

local FRUIT_FOLDERS = {
    Workspace,
    Workspace:FindFirstChild("Fruits"),
    Workspace:FindFirstChild("SpawnedFruits"),
    Workspace:FindFirstChild("Drops"),
    Workspace:FindFirstChild("Items"),
    Workspace:FindFirstChild("Map"),
    Workspace:FindFirstChild("World"),
    Workspace:FindFirstChild("Entities")
}

local MYTHIC_FRUITS = {
    ["Dragon"] = true, ["Dough"] = true, ["Okuchi"] = true,
    ["Saturn"] = true, ["Darkness"] = true, ["Leopard"] = true
}

local function getFruitRarity(fruitName)
    if MYTHIC_FRUITS[fruitName] then
        return "Mythic", COLORS.Mythic
    else
        return "Legendary", COLORS.Gold
    end
end

local function getFruits()
    if tick() - lastUpdate < config.FruitScanRate then return fruitCache end
    
    fruitCache = {}
    local hrpPos = hrp and hrp.Position
    if not hrpPos then return fruitCache end
    
    local checked = {}
    local function scanContainer(container)
        if checked[container] then return end
        checked[container] = true
        
        for _, obj in pairs(container:GetChildren()) do
            local name = obj.Name
            for _, fruitName in ipairs(FRUIT_NAMES) do
                if name == fruitName then
                    local part = nil
                    local fruitModel = nil
                    
                    if obj:IsA("Model") then
                        fruitModel = obj
                        part = obj.PrimaryPart or obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                        if not part then
                            for _, child in pairs(obj:GetDescendants()) do
                                if child:IsA("BasePart") then
                                    part = child
                                    break
                                end
                            end
                        end
                    elseif obj:IsA("Tool") then
                        fruitModel = obj
                        part = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    elseif obj:IsA("BasePart") then
                        part = obj
                        fruitModel = obj
                    end
                    
                    if part and part:IsA("BasePart") and part.Parent then
                        local isStored = false
                        local current = part
                        while current do
                            if current == ReplicatedStorage then
                                isStored = true
                                break
                            end
                            current = current.Parent
                        end
                        
                        if not isStored then
                            local rarity, color = getFruitRarity(fruitName)
                            table.insert(fruitCache, {
                                obj = fruitModel,
                                part = part,
                                name = fruitName,
                                rarity = rarity,
                                rarityColor = color,
                                distance = (hrpPos - part.Position).Magnitude,
                                id = fruitModel:GetFullName() .. "_" .. tostring(fruitModel)
                            })
                        end
                    end
                    break
                end
            end
            
            if obj:IsA("Folder") or obj:IsA("Model") then
                scanContainer(obj)
            end
        end
    end
    
    for _, folder in ipairs(FRUIT_FOLDERS) do
        if folder then
            scanContainer(folder)
        end
    end
    
    table.sort(fruitCache, function(a, b)
        if a.rarity == b.rarity then
            return a.distance < b.distance
        end
        return a.rarity == "Mythic"
    end)
    
    lastUpdate = tick()
    return fruitCache
end

--// CHECK INVENTARIO
local function checkInventory()
    states.hasFruit = false
    states.inventoryFull = false
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            for _, fruitName in ipairs(FRUIT_NAMES) do
                if item.Name == fruitName then
                    states.hasFruit = true
                    states.inventoryFull = true
                    break
                end
            end
        end
    end
    
    if character then
        for _, obj in pairs(character:GetChildren()) do
            if obj:IsA("Tool") then
                for _, fruitName in ipairs(FRUIT_NAMES) do
                    if obj.Name == fruitName then
                        states.hasFruit = true
                        states.inventoryFull = true
                        break
                    end
                end
            end
        end
    end
    
    local dataFolders = {"Data", "Inventory", "Fruits", "StoredFruits", "PlayerData", "PlayerStats"}
    for _, folderName in ipairs(dataFolders) do
        local folder = player:FindFirstChild(folderName) or (character and character:FindFirstChild(folderName))
        if folder then
            for _, item in pairs(folder:GetChildren()) do
                if table.find(FRUIT_NAMES, item.Name) then
                    states.hasFruit = true
                    states.inventoryFull = true
                    break
                end
            end
        end
    end
    
    if states.hasFruit then
        invStatus.Text = "Inventario: LLENO 👑"
        invStatus.TextColor3 = COLORS.Gold
    else
        invStatus.Text = "Inventario: Vacío"
        invStatus.TextColor3 = COLORS.TextDim
    end
end

--// ESP MEJORADO
local espFolder = Instance.new("Folder")
espFolder.Name = "FruitESP_MythicOnly"
espFolder.Parent = CoreGui

local espCache = {}

local function updateESP()
    if not config.ESPFruitDrop then
        for id, data in pairs(espCache) do
            if data.gui then data.gui:Destroy() end
        end
        espCache = {}
        return
    end
    
    local fruits = getFruits()
    local currentIds = {}
    local hrpPos = hrp and hrp.Position
    
    for _, fruit in ipairs(fruits) do
        currentIds[fruit.id] = true
        
        if not espCache[fruit.id] then
            local bill = Instance.new("BillboardGui")
            bill.Name = "ESP_" .. fruit.name
            bill.Adornee = fruit.part
            bill.Size = UDim2.new(0, 200, 0, 60)
            bill.StudsOffset = Vector3.new(0, 4.5, 0)
            bill.AlwaysOnTop = true
            bill.MaxDistance = 5000
            bill.Parent = espFolder
            
            local bg = Instance.new("Frame")
            bg.Name = "Background"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = COLORS.BG
            bg.BackgroundTransparency = 0.05
            bg.BorderSizePixel = 0
            bg.Parent = bill
            Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)
            
            local stroke = Instance.new("UIStroke")
            stroke.Name = "Border"
            stroke.Color = fruit.rarityColor
            stroke.Thickness = 3
            stroke.Parent = bg
            
            if fruit.rarity == "Mythic" then
                local glow = Instance.new("ImageLabel")
                glow.Name = "Glow"
                glow.Size = UDim2.new(1.2, 0, 1.2, 0)
                glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
                glow.BackgroundTransparency = 1
                glow.Image = "rbxassetid://6015897843"
                glow.ImageColor3 = fruit.rarityColor
                glow.ImageTransparency = 0.8
                glow.ZIndex = -1
                glow.Parent = bg
            end
            
            local content = Instance.new("Frame")
            content.Name = "Content"
            content.Size = UDim2.new(1, -12, 1, -12)
            content.Position = UDim2.new(0, 6, 0, 6)
            content.BackgroundTransparency = 1
            content.Parent = bg
            
            local icon = Instance.new("TextLabel")
            icon.Name = "Icon"
            icon.Size = UDim2.new(0, 28, 0, 28)
            icon.BackgroundTransparency = 1
            icon.Text = fruit.rarity == "Mythic" and "🔮" or "⭐"
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 24
            icon.Parent = content
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "FruitName"
            nameLabel.Size = UDim2.new(1, -35, 0, 16)
            nameLabel.Position = UDim2.new(0, 32, 0, 2)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = fruit.name
            nameLabel.Font = Enum.Font.GothamBlack
            nameLabel.TextSize = 15
            nameLabel.TextColor3 = fruit.rarityColor
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = content
            
            local rarityLabel = Instance.new("TextLabel")
            rarityLabel.Name = "Rarity"
            rarityLabel.Size = UDim2.new(0, 60, 0, 14)
            rarityLabel.Position = UDim2.new(0, 32, 0, 18)
            rarityLabel.BackgroundColor3 = fruit.rarityColor
            rarityLabel.BackgroundTransparency = 0.8
            rarityLabel.Text = fruit.rarity:upper()
            rarityLabel.Font = Enum.Font.GothamBold
            rarityLabel.TextSize = 8
            rarityLabel.TextColor3 = COLORS.Text
            rarityLabel.Parent = content
            Instance.new("UICorner", rarityLabel).CornerRadius = UDim.new(0, 4)
            
            local distLabel = Instance.new("TextLabel")
            distLabel.Name = "Distance"
            distLabel.Size = UDim2.new(1, 0, 0, 20)
            distLabel.Position = UDim2.new(0, 0, 0, 32)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = math.floor(fruit.distance) .. "m"
            distLabel.Font = Enum.Font.GothamBold
            distLabel.TextSize = 14
            distLabel.TextColor3 = fruit.distance < 50 and COLORS.Green or COLORS.Orange
            distLabel.TextXAlignment = Enum.TextXAlignment.Center
            distLabel.Parent = content
            
            espCache[fruit.id] = {
                gui = bill,
                part = fruit.part,
                distLabel = distLabel,
                stroke = stroke
            }
        else
            local data = espCache[fruit.id]
            if data and data.part and data.part.Parent then
                local newDist = hrpPos and (hrpPos - data.part.Position).Magnitude or fruit.distance
                data.distLabel.Text = math.floor(newDist) .. "m"
                data.distLabel.TextColor3 = newDist < 50 and COLORS.Green or COLORS.Orange
            end
        end
    end
    
    for id, data in pairs(espCache) do
        if not currentIds[id] then
            if data.gui then data.gui:Destroy() end
            espCache[id] = nil
        end
    end
end

--// TWEEN MEJORADO
local function tweenToFruit(fruit)
    if not fruit or not fruit.part or not hrp or states.tweening then return false end
    if not fruit.part.Parent then return false end
    
    states.tweening = true
    
    local startPos = hrp.Position
    local targetPos = fruit.part.Position
    local distance = (startPos - targetPos).Magnitude
    
    if distance < 6 then
        states.tweening = false
        return true
    end
    
    local tweenTime = math.clamp(distance / config.TweenSpeed, 0.5, 6)
    
    print("🚀 [" .. fruit.rarity:upper() .. "] " .. fruit.name .. " (" .. math.floor(distance) .. "m)")
    
    local offset = CFrame.new(0, 3, 0)
    local targetCFrame = CFrame.new(targetPos) * offset
    
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    local connection = nil
    local cancelled = false
    
    connection = RunService.Heartbeat:Connect(function()
        if not fruit.part or not fruit.part.Parent then
            cancelled = true
            tween:Cancel()
            if connection then connection:Disconnect() end
        end
    end)
    
    tween:Play()
    tween.Completed:Wait()
    
    if connection then connection:Disconnect() end
    states.tweening = false
    
    if cancelled then
        print("⚠️ Fruta desapareció")
        return false
    end
    
    print("✅ Llegado a " .. fruit.name)
    return true
end

--// AUTO BAG FRUIT - MANTENER PRESIONADO 7 SEGUNDOS
local function autoBagFruit(fruit)
    if not fruit or not fruit.part then return false end
    if states.bagging then return false end
    
    local distance = (hrp.Position - fruit.part.Position).Magnitude
    if distance > config.BagRange then
        return false
    end
    
    states.bagging = true
    states.currentBagFruit = fruit
    
    print("🎒 INICIANDO BAG: " .. fruit.name .. " (7s manteniendo)")
    bagStatus.Text = "🎒 BAGGING: " .. fruit.name .. " [7s]"
    bagStatus.TextColor3 = COLORS.Yellow
    
    local success = false
    
    -- MÉTODO 1: firetouchinterest mantenido
    local touchHeld = false
    pcall(function()
        if firetouchinterest then
            firetouchinterest(hrp, fruit.part, 0) -- Iniciar touch
            touchHeld = true
        end
    end)
    
    -- MÉTODO 2: Tecla E mantenida
    local keyHeld = false
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        keyHeld = true
    end)
    
    -- CONTAR 7 SEGUNDOS
    local startTime = tick()
    while tick() - startTime < config.BagHoldDuration do
        if not fruit.part or not fruit.part.Parent then
            success = true
            break
        end
        
        checkInventory()
        if states.hasFruit then
            success = true
            break
        end
        
        local elapsed = tick() - startTime
        local remaining = math.ceil(config.BagHoldDuration - elapsed)
        bagStatus.Text = "🎒 BAGGING: " .. fruit.name .. " [" .. remaining .. "s]"
        
        task.wait(0.1)
    end
    
    -- LIBERAR
    if touchHeld then
        pcall(function()
            firetouchinterest(hrp, fruit.part, 1)
        end)
    end
    
    if keyHeld then
        pcall(function()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end
    
    task.wait(0.3)
    checkInventory()
    if states.hasFruit then
        success = true
    end
    
    states.bagging = false
    states.currentBagFruit = nil
    
    if success then
        print("✅ " .. fruit.name .. " RECOGIDA!")
        bagStatus.Text = "✅ " .. fruit.name .. " RECOGIDA!"
        bagStatus.TextColor3 = COLORS.Green
        
        -- INICIAR AUTO EQUIP
        if config.AutoEquipFruit then
            task.spawn(function()
                autoEquipFruit(fruit.name)
            end)
        end
    else
        bagStatus.Text = "🎒 Esperando..."
        bagStatus.TextColor3 = COLORS.Cyan
    end
    
    task.wait(1)
    if not states.bagging then
        bagStatus.Text = "🎒 Esperando..."
        bagStatus.TextColor3 = COLORS.Cyan
    end
    
    return success
end

--// AUTO EQUIP FRUIT
local function autoEquipFruit(fruitName)
    if not config.AutoEquipFruit then return end
    
    print("⚔️ Intentando equipar: " .. fruitName)
    storeStatus.Text = "⚔️ Equipando " .. fruitName .. "..."
    storeStatus.TextColor3 = COLORS.Gold
    
    task.wait(1) -- Esperar a que aparezca en backpack
    
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    
    -- Buscar la fruta en backpack
    local fruitTool = nil
    for _, item in pairs(backpack:GetChildren()) do
        if item.Name == fruitName and item:IsA("Tool") then
            fruitTool = item
            break
        end
    end
    
    if fruitTool then
        -- Equipar la fruta
        pcall(function()
            humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(fruitTool)
                print("✅ " .. fruitName .. " equipada!")
                storeStatus.Text = "✅ " .. fruitName .. " equipada!"
                
                -- INICIAR AUTO STORE DESPUÉS DE EQUIPAR
                if config.AutoStoreFruit then
                    task.wait(2) -- Esperar menú
                    autoStoreFruit()
                end
            end
        end)
    else
        print("⚠️ No se encontró " .. fruitName .. " en backpack")
        storeStatus.Text = "💼 Auto Store: Listo"
    end
end

--// AUTO STORE FRUIT - SELECCIONAR FRUIT BAG (SEGUNDA OPCIÓN)
local function autoStoreFruit()
    if states.storing then return end
    states.storing = true
    
    print("💼 Buscando menú de Fruit Bag...")
    storeStatus.Text = "💼 Buscando menú..."
    storeStatus.TextColor3 = COLORS.Pink
    
    -- Esperar a que aparezca el menú de opciones (hasta 5 segundos)
    local menuFound = false
    local startSearch = tick()
    
    while tick() - startSearch < 5 do
        -- Buscar el menú de opciones en PlayerGui
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            -- Buscar frames/comunes que contengan opciones de fruta
            local possibleNames = {"FruitMenu", "Options", "Choose", "Select", "Menu", "UI", "Main", "Dialog"}
            
            for _, name in ipairs(possibleNames) do
                local gui = playerGui:FindFirstChild(name, true)
                if gui and gui:IsA("GuiObject") and gui.Visible then
                    -- Buscar botones dentro del menú
                    local buttons = {}
                    for _, child in pairs(gui:GetDescendants()) do
                        if child:IsA("TextButton") or child:IsA("ImageButton") then
                            table.insert(buttons, child)
                        end
                    end
                    
                    -- Si hay al menos 2 botones, seleccionar el segundo (Fruit Bag)
                    if #buttons >= 2 then
                        menuFound = true
                        
                        -- Ordenar botones por posición Y (de arriba a abajo)
                        table.sort(buttons, function(a, b)
                            return a.AbsolutePosition.Y < b.AbsolutePosition.Y
                        end)
                        
                        local secondButton = buttons[2] -- Segunda opción = Fruit Bag
                        
                        print("🎯 Menú encontrado! Seleccionando opción 2 (Fruit Bag)")
                        storeStatus.Text = "🎯 Seleccionando Fruit Bag..."
                        
                        -- Simular click/touch en el botón
                        pcall(function()
                            -- Método 1: firesignal
                            if secondButton.Activated then
                                secondButton.Activated:Fire()
                            end
                        end)
                        
                        pcall(function()
                            -- Método 2: VirtualInputManager click
                            local pos = secondButton.AbsolutePosition
                            local size = secondButton.AbsoluteSize
                            local centerX = pos.X + size.X/2
                            local centerY = pos.Y + size.Y/2
                            
                            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                        end)
                        
                        pcall(function()
                            -- Método 3: InputObject simulation
                            secondButton.InputBegan:Fire({
                                UserInputType = Enum.UserInputType.MouseButton1,
                                Position = secondButton.AbsolutePosition + secondButton.AbsoluteSize/2
                            })
                        end)
                        
                        -- También intentar con tecla numérica 2
                        task.wait(0.2)
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                        end)
                        
                        print("✅ Fruit Bag seleccionado!")
                        storeStatus.Text = "✅ Guardada en Fruit Bag!"
                        storeStatus.TextColor3 = COLORS.Green
                        
                        states.lastStoredFruit = tick()
                        break
                    end
                end
            end
            
            if menuFound then break end
        end
        
        task.wait(0.2)
    end
    
    if not menuFound then
        print("⚠️ Menú no encontrado, intentando métodos alternativos...")
        
        -- Método alternativo: Buscar RemoteEvents comunes de guardado
        pcall(function()
            local storeRemotes = {"StoreFruit", "SaveFruit", "PutInBag", "FruitBag", "StoreTool"}
            for _, remoteName in ipairs(storeRemotes) do
                local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    print("✅ Usado RemoteEvent: " .. remoteName)
                    storeStatus.Text = "✅ Guardada vía Remote!"
                    storeStatus.TextColor3 = COLORS.Green
                    menuFound = true
                    break
                end
            end
        end)
        
        if not menuFound then
            storeStatus.Text = "⚠️ Menú no encontrado"
            storeStatus.TextColor3 = COLORS.Red
        end
    end
    
    task.wait(2)
    storeStatus.Text = "💼 Auto Store: Listo"
    storeStatus.TextColor3 = COLORS.Pink
    states.storing = false
end

--// SERVER HOP
local function serverHop()
    if states.hopping then return end
    states.hopping = true
    timerLabel.Text = "🔄 Buscando servidor..."
    
    local success = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100&sort=Desc&excludeFullGames=true"
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)
        
        local servers = {}
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            local selectedServer = servers[math.random(1, math.min(10, #servers))]
            timerLabel.Text = "🔄 Teletransportando..."
            TeleportService:TeleportToPlaceInstance(game.PlaceId, selectedServer, player)
        else
            timerLabel.Text = "⚠️ No hay servidores"
            task.wait(2)
            states.hopping = false
        end
    end)
    
    if not success then
        timerLabel.Text = "❌ Error"
        task.wait(2)
        states.hopping = false
    end
end

--// LOOPS PRINCIPALES

-- Loop principal
task.spawn(function()
    while task.wait(0.2) do
        if not character or not hrp then
            character = player.Character
            if character then
                hrp = character:WaitForChild("HumanoidRootPart", 5)
            end
            continue
        end
        
        local fruits = getFruits()
        checkInventory()
        
        -- Si está baggeando o almacenando, no hacer otras cosas
        if states.bagging or states.storing then
            if states.bagging and states.currentBagFruit then
                if states.currentBagFruit.part and states.currentBagFruit.part.Parent then
                    local dist = (hrp.Position - states.currentBagFruit.part.Position).Magnitude
                    if dist > config.BagRange * 1.5 then
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end)
                        states.bagging = false
                        states.currentBagFruit = nil
                        bagStatus.Text = "🎒 Esperando..."
                        bagStatus.TextColor3 = COLORS.Cyan
                    end
                end
            end
            continue
        end
        
        -- Auto Tween + Auto Bag
        if #fruits > 0 then
            local target = fruits[1]
            
            if target.distance <= config.BagRange and config.AutoBagFruit and not states.bagging then
                autoBagFruit(target)
            elseif config.AutoTween and not states.tweening and not states.bagging then
                tweenToFruit(target)
                if config.AutoBagFruit then
                    task.wait(0.3)
                    autoBagFruit(target)
                end
            end
        end
        
        -- Server Hop
        if not states.bagging and not states.storing then
            local shouldHop = false
            local hopReason = ""
            
            if config.AutoServerHop and #fruits == 0 then
                shouldHop = true
                hopReason = "No hay frutas míticas"
            end
            
            if config.SmartHopIfFull and states.inventoryFull then
                shouldHop = true
                hopReason = "Inventario lleno"
            end
            
            if shouldHop and not states.hopping then
                states.currentHop = states.currentHop - 0.2
                
                if states.currentHop <= 0 then
                    serverHop()
                    states.currentHop = config.HopDelay
                else
                    timerLabel.Text = "⏱️ " .. hopReason .. " - Hop: " .. math.floor(states.currentHop) .. "s"
                end
            elseif not shouldHop then
                states.currentHop = config.HopDelay
                timerLabel.Text = "⏱️ Hop in: " .. states.currentHop .. "s"
            end
        end
    end
end)

-- ESP Loop
task.spawn(function()
    while task.wait(config.ESPUpdateRate) do
        if config.ESPFruitDrop then
            updateESP()
        end
    end
end)

-- Reconexión
player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    states.tweening = false
    states.bagging = false
    states.storing = false
    states.currentBagFruit = nil
    pcall(function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
    print("🔄 Personaje reconectado")
end)

-- Mensaje de carga
print("=" .. string.rep("=", 60))
print("  👑 Auto Server Hop - HAZE SEAS")
print("  🎯 SOLO FRUTAS MÍTICAS/LEGENDARIAS")
print("  🎒 Auto Bag: 7s manteniendo presionado")
print("  ⚔️ Auto Equip: Equipa automáticamente")
print("  💼 Auto Store: Selecciona Fruit Bag (opción 2)")
print("=" .. string.rep("=", 60))
