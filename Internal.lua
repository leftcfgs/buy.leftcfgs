-- L-Internal.hook | Ultimate Edition (ESP & Aimbot Update)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止（Internalに名称変更）
local existing = game.CoreGui:FindFirstChild("Internal")
if existing then existing:Destroy() end

-- --- 全体設定 ---
_G.L_Internal_Settings = {
    -- Aimbot
    AimbotEnabled = false,
    AimbotKey = Enum.KeyCode.E,
    AimbotKeyType = "Keyboard", -- "Keyboard" or "Mouse"
    AimbotMode = "Toggle", -- "Toggle", "Hold", "Always"
    HitPart = "HumanoidRootPart", -- "Head", "UpperTorso", "HumanoidRootPart"
    FOV = 150,
    ShowFOV = true,
    Smoothness = 0.2,
    
    -- ESP
    ESPEnabled = true,
    Boxes = true,
    Skeletons = true,
    Names = true,
    HealthBar = true,
    Distance = true,
    Weapons = true,
    
    -- 他
    ThemeColor = Color3.fromRGB(255, 0, 50),
    Binding = false
}
local S = _G.L_Internal_Settings

-- --- 描画オブジェクト管理 ---
local Drawings = {
    FOV = Drawing.new("Circle"),
    ESP = {}
}

Drawings.FOV.Thickness = 1
Drawings.FOV.Color = S.ThemeColor
Drawings.FOV.Visible = S.ShowFOV
Drawings.FOV.Radius = S.FOV

local function clearESP()
    for _, playerObj in pairs(Drawings.ESP) do
        for _, draw in pairs(playerObj) do
            draw.Visible = false
            draw:Remove()
        end
    end
    Drawings.ESP = {}
end

-- --- UI作成 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Internal"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 360, 0, 360)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "L-INTERNAL | ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = S.ThemeColor
Title.Font = Enum.Font.Code

-- スクロールフレーム（機能が増えたため）
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, 0, 1, -35)
Scroll.Position = UDim2.new(0, 0, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
Scroll.ScrollBarThickness = 5

-- 汎用関数
local function createBtn(text, pos, parent, sizeX, sizeY)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, sizeX or 340, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = text
    btn.Font = Enum.Font.Code
    return btn
end

local function createBox(text, pos, parent, placeholder)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0, 340, 0, 30)
    box.Position = pos
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = text
    box.PlaceholderText = placeholder or ""
    box.Font = Enum.Font.Code
    return box
end

-- Aimbot セクション
local AimTitle = Instance.new("TextLabel", Scroll)
AimTitle.Size = UDim2.new(1, 0, 0, 30)
AimTitle.Position = UDim2.new(0, 0, 0, 0)
AimTitle.Text = "=== AIMBOT ==="
AimTitle.TextColor3 = S.ThemeColor
AimTitle.BackgroundTransparency = 1

local KeyBtn = createBtn("Key: E", UDim2.new(0, 10, 0, 30), Scroll)
local ModeBtn = createBtn("Mode: Toggle", UDim2.new(0, 10, 0, 65), Scroll)
local PartBtn = createBtn("Target: Body", UDim2.new(0, 10, 0, 100), Scroll)
local FOVBtn = createBtn("Show FOV: ON", UDim2.new(0, 10, 0, 135), Scroll)

local FOVInput = createBox(tostring(S.FOV), UDim2.new(0, 10, 0, 170), Scroll, "FOV (10 - 500)")
local SmoothInput = createBox(tostring(S.Smoothness), UDim2.new(0, 10, 0, 205), Scroll, "Smooth (0.01 - 1)")

-- ESP セクション
local ESPTitle = Instance.new("TextLabel", Scroll)
ESPTitle.Size = UDim2.new(1, 0, 0, 30)
ESPTitle.Position = UDim2.new(0, 0, 0, 245)
ESPTitle.Text = "=== ESP ==="
ESPTitle.TextColor3 = S.ThemeColor
ESPTitle.BackgroundTransparency = 1

local TglESP = createBtn("ESP: ON", UDim2.new(0, 10, 0, 275), Scroll)
local TglBox = createBtn("Box: ON", UDim2.new(0, 10, 0, 310), Scroll, 165)
local TglSkel = createBtn("Skeleton: ON", UDim2.new(0, 185, 0, 310), Scroll, 165)
local TglName = createBtn("Name: ON", UDim2.new(0, 10, 0, 345), Scroll, 165)
local TglHP = createBtn("Health: ON", UDim2.new(0, 185, 0, 345), Scroll, 165)
local TglDist = createBtn("Distance: ON", UDim2.new(0, 10, 0, 380), Scroll, 165)
local TglWpn = createBtn("Weapon: ON", UDim2.new(0, 185, 0, 380), Scroll, 165)

local Status = Instance.new("TextLabel", MainFrame)
