--// Haze Seas Ultra v3.0 - Solo Frutas Reales | Zero Lag | UI Premium
--// Detección: SOLO frutas caídas (no spawns, no árboles)

if getgenv().HazeSeasUltraLoaded then return end
getgenv().HazeSeasUltraLoaded = true

--// SERVICIOS ESENCIALES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--// CONFIG
local config = {
    AutoTween = false,
    AutoHop = false,
    AutoBag = false,
    EspFruits = false,
    TweenSpeed = 90,
    HopDelay = 10,
    ESPUpdateRate = 0.15
}

--// LISTA EXACTA DE 36 FRUTAS
local FRUIT_NAMES = {
    "Saturn", "Okuchi", "Wolf", "Vanish", "Circus", "Spin", "Spike", 
    "Bomb", "Barrier", "Paw", "Smoke", "Sand", "String", "Mammoth",
    "Buddha", "Snow", "Tremor", "Gas", "Gravity", "Flame", "Shadow",
    "Light", "Operation", "Ice", "Electricity", "Magma", "Love", "Gum",
    "Darkness", "Magnet", "Phoenix", "Soul", "Leopard", "Venom", "Dragon", "Dough"
}

--// CACHE DE FRUTAS (PARA 0 LAG)
local fruitCache = {}
local lastCacheUpdate = 0
local CACHE_DURATION = 0.5

--// ESTADOS
local states = {
    tweening = false,
    hopping = false,
    fruitsCount = 0,
    targetFruit = nil
}

--// COLORES PREMIUM
local COLORS = {
    Primary = Color3.fromRGB(99, 102, 241),
    Secondary = Color3.fromRGB(139, 92, 246),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 146, 60),
    Danger = Color3.fromRGB(239, 68, 68),
    Glass = Color3.fromRGB(15, 15, 25),
    GlassLight = Color3.fromRGB(25, 25, 40),
    Text = Color3.fromRGB(243, 244, 246),
    TextDim = Color3.fromRGB(156, 163, 175)
}

--// PROTECCIÓN GUI
local function protectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = CoreGui
    end
end

--// GUI PRINCIPAL - GLASSMORPHISM
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HSU_" .. tostring(math.random(1000, 9999))
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
protectGui(screenGui)

-- Frame principal glass
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(0.5, -160, 0.5, -210)
main.BackgroundColor3 = COLORS.Glass
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Parent = screenGui

-- Blur effect (simulado con imagen)
local blur = Instance.new("ImageLabel")
blur.Size = UDim2.new(1, 40, 1, 40)
blur.Position = UDim2.new(0, -20, 0, -20)
blur.BackgroundTransparency = 1
blur.Image = "rbxassetid://6015897843"
blur.ImageColor3 = Color3.new(0, 0, 0)
blur.ImageTransparency = 0.6
blur.ScaleType = Enum.ScaleType.Slice
blur.SliceCenter = Rect.new(49, 49, 50, 50)
blur.ZIndex = -1
blur.Parent = main

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 24)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(99, 102, 241)
stroke.Thickness = 1.5
stroke.Transparency = 0.5

--// HEADER MINIMALISTA
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 70)
header.BackgroundTransparency = 1
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.new(0, 15, 0, 12)
title.BackgroundTransparency = 1
title.Text = "HAZE SEAS"
title.Font = Enum.Font.GothamBlack
title.TextSize = 26
title.TextColor3 = COLORS.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local gradient = Instance.new("UIGradient", title)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.Primary),
    ColorSequenceKeypoint.new(1, COLORS.Secondary)
})

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 18)
subtitle.Position = UDim2.new(0, 15, 0, 42)
subtitle.BackgroundTransparency = 1
subtitle.Text = "ULTRA v3.0 • 36 FRUTAS"
subtitle.Font = Enum.Font.GothamBold
subtitle.TextSize = 11
subtitle.TextColor3 = COLORS.TextDim
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Botón cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 15)
closeBtn.BackgroundColor3 = COLORS.Danger
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = COLORS.Text
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

-- Botón minimizar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -78, 0, 15)
minBtn.BackgroundColor3 = COLORS.GlassLight
minBtn.Text = "−"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.TextColor3 = COLORS.Text
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 10)

--// PANEL DE STATS COMPACTO
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, -24, 0, 60)
statsPanel.Position = UDim2.new(0, 12, 0, 75)
statsPanel.BackgroundColor3 = COLORS.GlassLight
statsPanel.BackgroundTransparency = 0.5
statsPanel.BorderSizePixel = 0
statsPanel.Parent = main
Instance.new("UICorner", statsPanel).CornerRadius = UDim.new(0, 16)

local fruitsCount = Instance.new("TextLabel")
fruitsCount.Size = UDim2.new(0.5, 0, 1, 0)
fruitsCount.BackgroundTransparency = 1
fruitsCount.Text = "0"
fruitsCount.Font = Enum.Font.GothamBlack
fruitsCount.TextSize = 28
fruitsCount.TextColor3 = COLORS.Success
fruitsCount.Parent = statsPanel

local fruitsLabel = Instance.new("TextLabel")
fruitsLabel.Size = UDim2.new(0.5, 0, 0, 16)
fruitsLabel.Position = UDim2.new(0, 0, 0.65, 0)
fruitsLabel.BackgroundTransparency = 1
fruitsLabel.Text = "FRUTAS CERCANAS"
fruitsLabel.Font = Enum.Font.GothamBold
fruitsLabel.TextSize = 10
fruitsLabel.TextColor3 = COLORS.TextDim
fruitsLabel.Parent = statsPanel

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.5, 0, 1, 0)
statusLabel.Position = UDim2.new(0.5, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ESPERANDO"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.TextColor3 = COLORS.TextDim
statusLabel.Parent = statsPanel

-- Línea divisoria
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 0, 36)
divider.Position = UDim2.new(0.5, 0, 0.5, -18)
divider.BackgroundColor3 = COLORS.TextDim
divider.BackgroundTransparency = 0.8
divider.BorderSizePixel = 0
divider.Parent = statsPanel

--// TIMER DE HOP
local hopPanel = Instance.new("Frame")
hopPanel.Size = UDim2.new(1, -24, 0, 40)
hopPanel.Position = UDim2.new(0, 12, 0, 140)
hopPanel.BackgroundColor3 = COLORS.Warning
hopPanel.BackgroundTransparency = 0.9
hopPanel.BorderSizePixel = 0
hopPanel.Visible = false
hopPanel.Parent = main
Instance.new("UICorner", hopPanel).CornerRadius = UDim.new(0, 12)

local hopBar = Instance.new("Frame")
hopBar.Size = UDim2.new(1, 0, 1, 0)
hopBar.BackgroundColor3 = COLORS.Warning
hopBar.BorderSizePixel = 0
hopBar.Parent = hopPanel
Instance.new("UICorner", hopBar).CornerRadius = UDim.new(0, 12)

local hopText = Instance.new("TextLabel")
hopText.Size = UDim2.new(1, 0, 1, 0)
hopText.BackgroundTransparency = 1
hopText.Text = "HOP EN: 10s"
hopText.Font = Enum.Font.GothamBold
hopText.TextSize = 13
hopText.TextColor3 = COLORS.Text
hopText.ZIndex = 2
hopText.Parent = hopPanel

--// CONTENEDOR DE TOGGLES
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(1, -24, 1, -200)
toggleContainer.Position = UDim2.new(0, 12, 0, 188)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = main

local toggleLayout = Instance.new("UIListLayout")
toggleLayout.Padding = UDim.new(0, 10)
toggleLayout.SortOrder = Enum.SortOrder.LayoutOrder
toggleLayout.Parent = toggleContainer

--// SISTEMA DE TOGGLES PREMIUM
local function createToggle(name, key, icon, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 56)
    frame.BackgroundColor3 = COLORS.GlassLight
    frame.BackgroundTransparency = 0.6
    frame.BorderSizePixel = 0
    frame.Parent = toggleContainer
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    
    -- Icono
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 0, 40)
    iconLabel.Position = UDim2.new(0, 8, 0.5, -20)
    iconLabel.BackgroundColor3 = color or COLORS.Primary
    iconLabel.BackgroundTransparency = 0.8
    iconLabel.Text = icon
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 18
    iconLabel.Parent = frame
    Instance.new("UICorner", iconLabel).CornerRadius = UDim.new(0, 10)
    
    -- Nombre
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -130, 0, 20)
    nameLabel.Position = UDim2.new(0, 56, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = COLORS.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    -- Toggle switch
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 48, 0, 26)
    switch.Position = UDim2.new(1, -60, 0.5, -13)
    switch.BackgroundColor3 = config[key] and (color or COLORS.Primary) or COLORS.GlassLight
    switch.BorderSizePixel = 0
    switch.Parent = frame
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = config[key] and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = COLORS.Text
    knob.BorderSizePixel = 0
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    -- Botón invisible
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    
    local function updateState()
        local isOn = config[key]
        local targetColor = isOn and (color or COLORS.Primary) or COLORS.GlassLight
        local targetPos = isOn and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        
        if key == "AutoHop" and not isOn then
            hopPanel.Visible = false
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        config[key] = not config[key]
        updateState()
    end)
    
    -- Hover
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
    end)
    frame.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundTransparency = 0.6}):Play()
    end)
    
    if config[key] then updateState() end
end

-- Crear toggles
createToggle("AUTO TWEEN", "AutoTween", "🎯", COLORS.Primary)
createToggle("AUTO HOP", "AutoHop", "🌍", COLORS.Warning)
createToggle("AUTO BAG", "AutoBag", "🎒", COLORS.Success)
createToggle("ESP FRUTAS", "EspFruits", "👁️", COLORS.Secondary)

--// BOTÓN FLOTANTE MINIMALISTA
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.Position = UDim2.new(0, 20, 0.5, -25)
floatBtn.BackgroundColor3 = COLORS.Primary
floatBtn.Text = "🍎"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 24
floatBtn.Visible = false
floatBtn.Parent = screenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = COLORS.Text
floatStroke.Thickness = 2
floatStroke.Transparency = 0.5

--// FUNCIONES DE DRAG
local function makeDraggable(frame, target)
    target = target or frame
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

makeDraggable(header, main)
makeDraggable(floatBtn)

--// BOTONES DE CONTROL
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    getgenv().HazeSeasUltraLoaded = false
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

--// SISTEMA DE FRUTAS - SOLO FRUTAS REALES (0 LAG)
local function updateFruitCache()
    local currentTime = tick()
    if currentTime - lastCacheUpdate < CACHE_DURATION then
        return fruitCache
    end
    
    fruitCache = {}
    local hrpPos = hrp and hrp.Position
    if not hrpPos then return fruitCache end
    
    -- Buscar SOLO en Workspace (más rápido que GetDescendants)
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name
            -- Verificar si es una fruta real (no spawn)
            for _, fruitName in ipairs(FRUIT_NAMES) do
                if name == fruitName then
                    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                    if part and part:IsA("BasePart") then
                        local dist = (hrpPos - part.Position).Magnitude
                        table.insert(fruitCache, {
                            obj = obj,
                            part = part,
                            name = name,
                            distance = dist,
                            position = part.Position
                        })
                    end
                    break
                end
            end
        end
    end
    
    -- Ordenar por distancia
    table.sort(fruitCache, function(a, b) return a.distance < b.distance end)
    
    lastCacheUpdate = currentTime
    states.fruitsCount = #fruitCache
    fruitsCount.Text = tostring(#fruitCache)
    
    return fruitCache
end

local function getClosestFruit()
    local fruits = updateFruitCache()
    return fruits[1]
end

--// TWEEN ULTRA-RÁPIDO
local function tweenToFruit(fruit)
    if not fruit or not fruit.part or not hrp or states.tweening then return end
    
    states.tweening = true
    states.targetFruit = fruit
    statusLabel.Text = "YENDO..."
    statusLabel.TextColor3 = COLORS.Primary
    
    local distance = fruit.distance
    local time = math.clamp(distance / config.TweenSpeed, 0.3, 3)
    
    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Quad), {
        CFrame = CFrame.new(fruit.position + Vector3.new(0, 2, 0))
    })
    
    tween:Play()
    tween.Completed:Wait()
    
    states.tweening = false
    statusLabel.Text = "ESPERANDO"
    statusLabel.TextColor3 = COLORS.TextDim
end

--// SERVER HOP OPTIMIZADO
local function serverHop()
    if states.hopping then return end
    states.hopping = true
    statusLabel.Text = "HOPPING..."
    statusLabel.TextColor3 = COLORS.Warning
    
    local success = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=50"
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)
        
        local servers = {}
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], player)
        end
    end)
    
    if not success then
        states.hopping = false
        statusLabel.Text = "ERROR"
        statusLabel.TextColor3 = COLORS.Danger
    end
end

--// ESP SIMPLIFICADO (SOLO FRUTAS)
local espFolder = Instance.new("Folder")
espFolder.Name = "HSU_ESP"
espFolder.Parent = CoreGui

local activeESP = {}

local function updateESP()
    if not config.EspFruits then
        for _, v in pairs(activeESP) do
            if v.gui then v.gui:Destroy() end
        end
        activeESP = {}
        return
    end
    
    local fruits = updateFruitCache()
    local currentFruits = {}
    
    -- Crear/actualizar ESP
    for _, fruit in ipairs(fruits) do
        currentFruits[fruit.part] = true
        
        if not activeESP[fruit.part] then
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = fruit.part
            billboard.Size = UDim2.new(0, 180, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = espFolder
            
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = COLORS.Glass
            bg.BackgroundTransparency = 0.3
            bg.BorderSizePixel = 0
            bg.Parent = billboard
            Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, -8, 1, -8)
            text.Position = UDim2.new(0, 4, 0, 4)
            text.BackgroundTransparency = 1
            text.Text = fruit.name .. "\n" .. math.floor(fruit.distance) .. "m"
            text.Font = Enum.Font.GothamBold
            text.TextSize = 13
            text.TextColor3 = fruit.distance < 50 and COLORS.Success or COLORS.Warning
            text.Parent = bg
            
            activeESP[fruit.part] = {gui = billboard, text = text}
        else
            -- Actualizar distancia
            activeESP[fruit.part].text.Text = fruit.name .. "\n" .. math.floor(fruit.distance) .. "m"
            activeESP[fruit.part].text.TextColor3 = fruit.distance < 50 and COLORS.Success or COLORS.Warning
        end
    end
    
    -- Limpiar ESP de frutas que ya no existen
    for part, data in pairs(activeESP) do
        if not currentFruits[part] then
            data.gui:Destroy()
            activeESP[part] = nil
        end
    end
end

--// LOOPS PRINCIPALES (OPTIMIZADOS)

-- Loop principal (2Hz - bajo consumo)
task.spawn(function()
    while task.wait(0.5) do
        -- Actualizar cache de frutas
        updateFruitCache()
        
        -- Auto Tween
        if config.AutoTween and not states.tweening then
            local closest = getClosestFruit()
            if closest then
                tweenToFruit(closest)
                
                -- Auto Bag
                if config.AutoBag then
                    task.wait(0.1)
                    pcall(function()
                        firetouchinterest(hrp, closest.part, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, closest.part, 1)
                    end)
                end
            end
        end
        
        -- Auto Hop
        if config.AutoHop and not states.hopping then
            if states.fruitsCount == 0 then
                hopPanel.Visible = true
                
                for i = config.HopDelay, 0, -1 do
                    if not config.AutoHop then break end
                    hopText.Text = "HOP EN: " .. i .. "s"
                    hopBar.Size = UDim2.new(i / config.HopDelay, 0, 1, 0)
                    task.wait(1)
                end
                
                if config.AutoHop and states.fruitsCount == 0 then
                    serverHop()
                end
            else
                hopPanel.Visible = false
            end
        else
            hopPanel.Visible = false
        end
    end
end)

-- ESP Loop (10Hz)
task.spawn(function()
    while task.wait(config.ESPUpdateRate) do
        if config.EspFruits then
            updateESP()
        end
    end
end)

-- Reconexión de personaje
player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    states.tweening = false
    fruitCache = {}
end)

print("✅ Haze Seas Ultra v3.0 cargado | 36 frutas | 0 lag")
