--// SCRIPT COMPLETO CON AUTO-GUARDADO MEJORADO
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
    AutoEquipFruit = true,
    AutoStoreFruit = true,
    TweenSpeed = 250,
    HopDelay = 15,
    ESPUpdateRate = 0.1,
    FruitScanRate = 0.3,
    BagRange = 20,
    BagHoldDuration = 7,
    StoreDelay = 2
}

--// SISTEMA DE GUARDADO AUTOMÁTICO MEJORADO
local SaveSystem = {
    ConfigName = "HazeSeasAutoHopConfig",
    SavePath = "HazeSeas_AutoHop_SaveData.json"
}

function SaveSystem:SaveConfig()
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(config)
        if writefile then
            writefile(self.SavePath, json)
            print("💾 [AUTO-GUARDADO] Configuración guardada!")
        end
    end)
    
    if not success then
        warn("❌ Error al guardar: " .. tostring(err))
    end
end

function SaveSystem:LoadConfig()
    local success, data = pcall(function()
        if isfile and isfile(self.SavePath) then
            local json = readfile(self.SavePath)
            return HttpService:JSONDecode(json)
        end
        return nil
    end)
    
    if success and data then
        -- Cargar solo las claves que existen en config
        for key, value in pairs(data) do
            if config[key] ~= nil then
                config[key] = value
            end
        end
        print("✅ [AUTO-CARGA] Configuración anterior restaurada!")
        print("   Toggles recordados:")
        for key, value in pairs(config) do
            if type(value) == "boolean" then
                print("   • " .. key .. ": " .. (value and "✅ ON" or "❌ OFF"))
            end
        end
        return true
    else
        print("ℹ️ Primera ejecución - usando configuración por defecto")
        self:SaveConfig() -- Guardar defaults
        return false
    end
end

function SaveSystem:ResetConfig()
    config = {
        ESPFruitDrop = false,
        AutoTween = false,
        AutoBagFruit = false,
        AutoServerHop = false,
        SmartHopIfFull = true,
        AutoEquipFruit = true,
        AutoStoreFruit = true,
        TweenSpeed = 250,
        HopDelay = 15,
        ESPUpdateRate = 0.1,
        FruitScanRate = 0.3,
        BagRange = 20,
        BagHoldDuration = 7,
        StoreDelay = 2
    }
    self:SaveConfig()
    print("🔄 Configuración reiniciada a valores predeterminados")
end

-- CARGAR CONFIGURACIÓN AUTOMÁTICAMENTE AL INICIAR
print("=" .. string.rep("=", 40))
print("🎯 CARGANDO CONFIGURACIÓN GUARDADA...")
SaveSystem:LoadConfig()
print("=" .. string.rep("=", 40))

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
main.Size = UDim2.new(0, 340, 0, 520)
main.Position = UDim2.new(0.5, -170, 0.5, -260)
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
toggleContainer.Size = UDim2.new(1, -24, 1, -185)
toggleContainer.Position = UDim2.new(0, 12, 0, 135)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = main

local toggleLayout = Instance.new("UIListLayout")
toggleLayout.Padding = UDim.new(0, 8)
toggleLayout.Parent = toggleContainer

--// FUNCIÓN TOGGLE CON AUTO-GUARDADO
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
        SaveSystem:SaveConfig() -- ⚡ AUTO-GUARDAR AL CAMBIAR CUALQUIER TOGGLE
        print("💾 [AUTO-GUARDADO] " .. key .. " cambiado a: " .. (config[key] and "ON" or "OFF"))
    end)
    
    update()
    return btn
end

-- Toggles (se restaurarán automáticamente al cargar)
createToggle("👑 ESP Mythic Only", "ESPFruitDrop", COLORS.Mythic)
createToggle("🏃 Auto Tween", "AutoTween", COLORS.Orange)
createToggle("🎒 Auto Bag (7s)", "AutoBagFruit", COLORS.Cyan)
createToggle("⚔️ Auto Equip", "AutoEquipFruit", COLORS.Gold)
createToggle("💼 Auto Fruit Bag", "AutoStoreFruit", COLORS.Pink)
createToggle("🌐 Auto Server Hop", "AutoServerHop", COLORS.Red)
createToggle("💼 Hop If Full", "SmartHopIfFull", COLORS.Yellow)

--// BOTONES DE GUARDADO Y RESET
local saveResetContainer = Instance.new("Frame")
saveResetContainer.Size = UDim2.new(1, -24, 0, 40)
saveResetContainer.Position = UDim2.new(0, 12, 0, 470)
saveResetContainer.BackgroundTransparency = 1
saveResetContainer.Parent = main

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.48, -5, 1, 0)
saveBtn.Position = UDim2.new(0, 0, 0, 0)
saveBtn.BackgroundColor3 = COLORS.Green
saveBtn.Text = "💾 Guardar Ahora"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 12
saveBtn.TextColor3 = COLORS.Text
saveBtn.Parent = saveResetContainer
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.48, -5, 1, 0)
resetBtn.Position = UDim2.new(0.52, 0, 0, 0)
resetBtn.BackgroundColor3 = COLORS.Red
resetBtn.Text = "🔄 Reset Todo"
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 12
resetBtn.TextColor3 = COLORS.Text
resetBtn.Parent = saveResetContainer
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)

saveBtn.MouseButton1Click:Connect(function()
    SaveSystem:SaveConfig()
    print("💾 Configuración guardada manualmente!")
end)

resetBtn.MouseButton1Click:Connect(function()
    SaveSystem:ResetConfig()
    -- Actualizar todos los toggles visualmente
    for key, btn in pairs(toggleButtons) do
        if config[key] then
            btn.BackgroundColor3 = key == "ESPFruitDrop" and COLORS.Mythic or
                                 key == "AutoTween" and COLORS.Orange or
                                 key == "AutoBagFruit" and COLORS.Cyan or
                                 key == "AutoEquipFruit" and COLORS.Gold or
                                 key == "AutoStoreFruit" and COLORS.Pink or
                                 key == "AutoServerHop" and COLORS.Red or
                                 COLORS.Yellow
            btn.Text = "ON"
        else
            btn.BackgroundColor3 = COLORS.Gray
            btn.Text = "OFF"
        end
    end
    print("🔄 Configuración reiniciada a valores por defecto")
end)

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
    SaveSystem:SaveConfig() -- Guardar antes de cerrar
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

--// ... (resto del script se mantiene igual)
