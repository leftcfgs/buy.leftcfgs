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
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 1, -25)
Status.Text = "LOADED | INTERNAL"
Status.TextColor3 = S.ThemeColor
Status.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

-- --- Aimbot & ESP ロジック ---

-- Aimbot 設定反映
FOVInput.FocusLost:Connect(function() S.FOV = tonumber(FOVInput.Text) or S.FOV end)
SmoothInput.FocusLost:Connect(function() S.Smoothness = math.clamp(tonumber(SmoothInput.Text) or S.Smoothness, 0.01, 1) end)

local partNames = {HumanoidRootPart = "Body", Head = "Head", UpperTorso = "Chest"}
PartBtn.MouseButton1Click:Connect(function()
    if S.HitPart == "HumanoidRootPart" then S.HitPart = "Head"
    elseif S.HitPart == "Head" then S.HitPart = "UpperTorso"
    else S.HitPart = "HumanoidRootPart" end
    PartBtn.Text = "Target: " .. partNames[S.HitPart]
end)

FOVBtn.MouseButton1Click:Connect(function() S.ShowFOV = not S.ShowFOV; FOVBtn.Text = "Show FOV: " .. (S.ShowFOV and "ON" or "OFF") end)

-- ESP 設定反映（トグルボタン全集）
TglESP.MouseButton1Click:Connect(function() S.ESPEnabled = not S.ESPEnabled; TglESP.Text = "ESP: " .. (S.ESPEnabled and "ON" or "OFF"); if not S.ESPEnabled then clearESP() end end)
local espSubTgl = { {btn = TglBox, key = "Boxes", txt = "Box"}, {btn = TglSkel, key = "Skeletons", txt = "Skeleton"}, {btn = TglName, key = "Names", txt = "Name"}, {btn = TglHP, key = "HealthBar", txt = "Health"}, {btn = TglDist, key = "Distance", txt = "Distance"}, {btn = TglWpn, key = "Weapons", txt = "Weapon"} }
for _, esp in pairs(espSubTgl) do esp.btn.MouseButton1Click:Connect(function() S[esp.key] = not S[esp.key]; esp.btn.Text = esp.txt .. ": " .. (S[esp.key] and "ON" or "OFF") end) end

-- キーバインド
KeyBtn.MouseButton1Click:Connect(function() S.Binding = true; KeyBtn.Text = "Press any key..." end)
local function handleInput(input, isBegan) if S.Binding then if input.UserInputType == Enum.UserInputType.Keyboard then S.AimbotKey = input.KeyCode; S.AimbotKeyType = "Keyboard"; KeyBtn.Text = "Key: " .. input.KeyCode.Name elseif input.UserInputType.Name:find("MouseButton") then S.AimbotKey = input.UserInputType; S.AimbotKeyType = "Mouse"; KeyBtn.Text = "Key: " .. input.UserInputType.Name end S.Binding = false; return end local match = (S.AimbotKeyType == "Keyboard" and input.KeyCode == S.AimbotKey) or (S.AimbotKeyType == "Mouse" and input.UserInputType == S.AimbotKey) if match then if S.AimbotMode == "Toggle" then if isBegan then S.AimbotEnabled = not S.AimbotEnabled end elseif S.AimbotMode == "Hold" then S.AimbotEnabled = isBegan end end end
UserInputService.InputBegan:Connect(function(i, g) if not g then handleInput(i, true) end end); UserInputService.InputEnded:Connect(function(i) handleInput(i, false) end)
ModeBtn.MouseButton1Click:Connect(function() if S.AimbotMode == "Toggle" then S.AimbotMode = "Hold" elseif S.AimbotMode == "Hold" then S.AimbotMode = "Always" else S.AimbotMode = "Toggle" end; ModeBtn.Text = "Mode: " .. S.AimbotMode; S.AimbotEnabled = (S.AimbotMode == "Always") end)

-- ESP 描画ヘルパー
local function createDraw(type, properties)
    local draw = Drawing.new(type)
    for k, v in pairs(properties) do draw[k] = v end
    return draw
end

-- スケルトンの接続情報
local SkeletonConnections = { R6 = {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}, R15 = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}} }

-- メインループ
RunService.RenderStepped:Connect(function()
    -- FOV
    Drawings.FOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36); Drawings.FOV.Radius = S.FOV; Drawings.FOV.Visible = S.ShowFOV

    -- Aimbot Target
    local AimbotTarget = nil
    if S.AimbotEnabled then
        local nearest = nil; local lastDist = S.FOV
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(S.HitPart) then
                local hum = v.Character:FindFirstChild("Humanoid"); if hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(v.Character[S.HitPart].Position)
                    if onScreen then local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude; if dist < lastDist then lastDist = dist; nearest = v end end
                end
            end
        end
        AimbotTarget = nearest
    end

    -- Aimbot 実行（Head精度向上補正入り）
    if AimbotTarget and mousemoverel then
        local part = AimbotTarget.Character[S.HitPart]
        local targetPos = Camera:WorldToViewportPoint(part.Position)
        
        -- Head狙いの時の座標補正（少し上を狙う）
        if S.HitPart == "Head" then
            local _, headOnScreen = Camera:WorldToViewportPoint(part.Position + Vector3.new(0, part.Size.Y / 2, 0))
            if headOnScreen then targetPos = Camera:WorldToViewportPoint(part.Position + Vector3.new(0, 0.1, 0)) end -- ゲームによって調整が必要かも
        end
        
        mousemoverel((targetPos.X - Mouse.X) * S.Smoothness, (targetPos.Y - (Mouse.Y + 36)) * S.Smoothness)
    end

    -- --- ESP 実行 ---
    if S.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not Drawings.ESP[player.Name] then
                    Drawings.ESP[player.Name] = { Box = createDraw("Square", {Thickness = 1, Color = S.ThemeColor, Filled = false, ZIndex = 2}), Name = createDraw("Text", {Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), ZIndex = 3}), HealthOutline = createDraw("Line", {Thickness = 3, Color = Color3.fromRGB(0, 0, 0), ZIndex = 1}), HealthBar = createDraw("Line", {Thickness = 1, Color = Color3.fromRGB(0, 255, 0), ZIndex = 2}), Skeleton = {}, Weapon = createDraw("Text", {Size = 12, Center = true, Outline = true, Color = Color3.fromRGB(200, 200, 200), ZIndex = 3}) }
                end
                
                local char = player.Character; local hum = char:FindFirstChild("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
                local draws = Drawings.ESP[player.Name]
                
                if hum and root and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local scale = 1000 / (pos.Z * Camera.FieldOfView); local sizeX, sizeY = 2500 / pos.Z, 3500 / pos.Z
                        local posX, posY = pos.X - sizeX / 2, pos.Y - sizeY / 2
                        
                        -- Box
                        draws.Box.Visible = S.Boxes; draws.Box.Size = Vector2.new(sizeX, sizeY); draws.Box.Position = Vector2.new(posX, posY)
                        
                        -- Name & Distance
                        if S.Names or S.Distance then
                            local txt = (S.Names and player.Name or "") .. (S.Distance and " [" .. math.floor(pos.Z) .. "m]" or "")
                            draws.Name.Visible = true; draws.Name.Text = txt; draws.Name.Position = Vector2.new(pos.X, posY - 15)
                        else draws.Name.Visible = false end
                        
                        -- HealthBar
                        if S.HealthBar then
                            local hpPercent = hum.Health / hum.MaxHealth
                            draws.HealthOutline.Visible = true; draws.HealthOutline.From = Vector2.new(posX - 4, posY + sizeY); draws.HealthOutline.To = Vector2.new(posX - 4, posY)
                            draws.HealthBar.Visible = true; draws.HealthBar.From = Vector2.new(posX - 4, posY + sizeY); draws.HealthBar.To = Vector2.new(posX - 4, posY + sizeY * (1 - hpPercent)); draws.HealthBar.Color = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                        else draws.HealthOutline.Visible = false; draws.HealthBar.Visible = false end
                        
                        -- Weapon
                        if S.Weapons then
                            local tool = char:FindFirstChildOfClass("Tool"); draws.Weapon.Visible = true; draws.Weapon.Text = tool and tool.Name or "[None]"; draws.Weapon.Position = Vector2.new(pos.X, posY + sizeY + 5)
                        else draws.Weapon.Visible = false end
                        
                        -- Skeleton
                        if S.Skeletons then
                            local connections = SkeletonConnections[hum.RigType.Name]
                            if connections then
                                for i, conn in pairs(connections) do
                                    local p1, p2 = char:FindFirstChild(conn[1]), char:FindFirstChild(conn[2])
                                    if p1 and p2 then
                                        local pos1, onS1 = Camera:WorldToViewportPoint(p1.Position); local pos2, onS2 = Camera:WorldToViewportPoint(p2.Position)
                                        if not draws.Skeleton[i] then draws.Skeleton[i] = createDraw("Line", {Thickness = 1, Color = S.ThemeColor, ZIndex = 2}) end
                                        draws.Skeleton[i].Visible = onS1 and onS2; draws.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y); draws.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                    else if draws.Skeleton[i] then draws.Skeleton[i].Visible = false end end
                                end
                            else for _, skel in pairs(draws.Skeleton) do skel.Visible = false end end
                        else for _, skel in pairs(draws.Skeleton) do skel.Visible = false end end
                        
                        continue
                    end
                end
                
                -- OFF Screen or Dead
                for _, draw in pairs(draws) do if type(draw) == "table" then for _, sk in pairs(draw) do sk.Visible = false end else draw.Visible = false end end
            end
        end
        
        -- 退出したプレイヤーのESPを掃除
        for name, _ in pairs(Drawings.ESP) do if not Players:FindFirstChild(name) then for _, draw in pairs(Drawings.ESP[name]) do if type(draw) == "table" then for _, sk in pairs(draw) do sk:Remove() end else draw:Remove() end end; Drawings.ESP[name] = nil end end
    else clearESP() end
end)
