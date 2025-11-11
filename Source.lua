local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ====== GUI CREATION ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WyZkHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 28)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "WyZk hub (educativo)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Buttons
local function makeButton(name, y, text, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 130, 0, 34)
    b.Position = UDim2.new(0, 10 + (y * 140), 0, 40)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = color or Color3.fromRGB(60,120,200)
    b.BorderSizePixel = 0
    b.Parent = frame
    return b
end

local btnAuto = makeButton("AutoFarmBtn", 0, "AutoFarm (simulado)", Color3.fromRGB(50,150,80))
local btnFly = makeButton("FlyBtn", 1, "Fly (toggle)", Color3.fromRGB(120,80,200))
local btnMore = Instance.new("TextButton")
btnMore.Name = "MoreBtn"
btnMore.Size = UDim2.new(0, 120, 0, 28)
btnMore.Position = UDim2.new(0, 150, 0, 120)
btnMore.Text = "Más"
btnMore.Font = Enum.Font.Gotham
btnMore.TextSize = 14
btnMore.TextColor3 = Color3.new(1,1,1)
btnMore.BackgroundColor3 = Color3.fromRGB(80,80,80)
btnMore.BorderSizePixel = 0
btnMore.Parent = frame

-- Status label
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 20)
status.Position = UDim2.new(0, 5, 0, 134)
status.BackgroundTransparency = 1
status.Text = "Estado: Inactivo (Solo en Studio)"
status.TextColor3 = Color3.fro
