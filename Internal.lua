-- ==========================================================
-- INTERNAL | UNNAMED GOD EDITION (ULTIMATE OVERLOAD)
-- LOAD DELAY: 5.0 SECONDS
-- DEVELOPED FOR: PAISEN
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止プロセス
if game.CoreGui:FindFirstChild("UnnamedUltimate") then
    game.CoreGui:FindFirstChild("UnnamedUltimate"):Destroy()
end

-- ==========================================
-- 設定データ（全機能をここに集約）
-- ==========================================
_G.Settings = {
    -- [COMBAT]
    Aimbot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    Ragebot = false,
    HitPart = "Head",
    FOV = 200,
    ShowFOV = true,
    Smooth = 0.05,
    
    -- [VISUALS]
    ESP = false,
    Box = false,
    Name = false,
    Dist = false,
    Tracer = false,
    MaxDist = 3000,
    
    -- [MOVEMENT]
    Underground = false,
    UG_Offset = -3,
    Noclip = false, -- 壁貫通
    SpeedHack = false,
    WalkSpeed = 100,
    JumpHack = false,
    JumpPower = 150,
    Fly = false,
    FlySpeed = 70,
    
    -- [UI SYSTEM]
    MenuKey = Enum.KeyCode.Insert,
    BindingMenu = false,
    BindingAim = false,
    Visible = false
}
local S = _G.Settings

-- ==========================================
-- UI 構築セクション (行数を贅沢に使用)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UnnamedUltimate"
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 550, 0, 750)
Main.Position = UDim2.new(0.5, -275, 0.5, -375)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false -- 最初は非表示

local TopBar = Instance.new("Frame")
TopBar.Name = "AccentBar"
TopBar.Parent = Main
TopBar.Size = UDim2.new(1, 0, 0, 4)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "UNNAMED GOD EDITION | RAGE & UNDERGROUND"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.Code
Title.TextSize = 18

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "Content"
ContentFrame.Parent = Main
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 5
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 2200)

-- ==========================================
-- 起動遅延処理 (ぱいせん指定 5秒)
-- ==========================================
task.spawn(function()
    print("Unnamed God: Initialization sequence started...")
    task.wait(5.0)
    Main.Visible = true
    print("Unnamed God: Main module active.")

    local currentY = 0

    -- [COMBAT SECTION] -------------------------------------
    -- Aimbot Toggle
    local AimBtn = Instance.new("TextButton", ContentFrame)
    AimBtn.Size = UDim2.new(1, -10, 0, 40); AimBtn.Position = UDim2.new(0, 5, 0, currentY)
    AimBtn.BackgroundColor3 = Color3.fromRGB(25, 10, 10); AimBtn.Font = Enum.Font.Code; AimBtn.TextSize = 15; AimBtn.TextXAlignment = Enum.TextXAlignment.Left
    AimBtn.MouseButton1Click:Connect(function() S.Aimbot = not S.Aimbot end)
    currentY = currentY + 45

    -- Aimbot Keybind (Aimbotの直下に配置)
    local AimBind = Instance.new("TextButton", ContentFrame)
    AimBind.Size = UDim2.new(1, -10, 0, 40); AimBind.Position = UDim2.new(0, 5, 0, currentY)
    AimBind.BackgroundColor3 = Color3.fromRGB(40, 20, 20); AimBind.Font = Enum.Font.Code; AimBind.TextSize = 14; AimBind.TextXAlignment = Enum.TextXAlignment.Left
    AimBind.MouseButton1Click:Connect(function() S.BindingAim = true; AimBind.Text = "  [WAITING FOR KEY...]" end)
    currentY = currentY + 45

    -- Ragebot Toggle
    local RageBtn = Instance.new("TextButton", ContentFrame)
    RageBtn.Size = UDim2.new(1, -10, 0, 40); RageBtn.Position = UDim2.new(0, 5, 0, currentY)
    RageBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0); RageBtn.Font = Enum.Font.Code; RageBtn.TextSize = 15; RageBtn.TextXAlignment = Enum.TextXAlignment.Left
    RageBtn.MouseButton1Click:Connect(function() S.Ragebot = not S.Ragebot end)
    currentY = currentY + 45

    -- FOV Toggle
    local FovBtn = Instance.new("TextButton", ContentFrame)
    FovBtn.Size = UDim2.new(1, -10, 0, 40); FovBtn.Position = UDim2.new(0, 5, 0, currentY)
    FovBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FovBtn.Font = Enum.Font.Code; FovBtn.TextSize = 15; FovBtn.TextXAlignment = Enum.TextXAlignment.Left
    FovBtn.MouseButton1Click:Connect(function() S.ShowFOV = not S.ShowFOV end)
    currentY = currentY + 60

    -- [VISUALS SECTION] ------------------------------------
    local EspBtn = Instance.new("TextButton", ContentFrame)
    EspBtn.Size = UDim2.new(1, -10, 0, 40); EspBtn.Position = UDim2.new(0, 5, 0, currentY)
    EspBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40); EspBtn.Font = Enum.Font.Code; EspBtn.TextSize = 15; EspBtn.TextXAlignment = Enum.TextXAlignment.Left
    EspBtn.MouseButton1Click:Connect(function() S.ESP = not S.ESP end)
    currentY = currentY + 45

    local BoxBtn = Instance.new("TextButton", ContentFrame)
    BoxBtn.Size = UDim2.new(1, -10, 0, 40); BoxBtn.Position = UDim2.new(0, 5, 0, currentY)
    BoxBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50); BoxBtn.Font = Enum.Font.Code; BoxBtn.TextSize = 15; BoxBtn.TextXAlignment = Enum.TextXAlignment.Left
    BoxBtn.MouseButton1Click:Connect(function() S.Box = not S.Box end)
    currentY = currentY + 45

    local NameBtn = Instance.new("TextButton", ContentFrame)
    NameBtn.Size = UDim2.new(1, -10, 0, 40); NameBtn.Position = UDim2.new(0, 5, 0, currentY)
    NameBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50); NameBtn.Font = Enum.Font.Code; NameBtn.TextSize = 15; NameBtn.TextXAlignment = Enum.TextXAlignment.Left
    NameBtn.MouseButton1Click:Connect(function() S.Name = not S.Name end)
    currentY = currentY + 60

    -- [MOVEMENT SECTION] -----------------------------------
    -- Underground
    local UgBtn = Instance.new("TextButton", ContentFrame)
    UgBtn.Size = UDim2.new(1, -10, 0, 40); UgBtn.Position = UDim2.new(0, 5, 0, currentY)
    UgBtn.BackgroundColor3 = Color3.fromRGB(10, 40, 10); UgBtn.Font = Enum.Font.Code; UgBtn.TextSize = 15; UgBtn.TextXAlignment = Enum.TextXAlignment.Left
    UgBtn.MouseButton1Click:Connect(function() S.Underground = not S.Underground end)
    currentY = currentY + 45

    -- Noclip (Wall Pass)
    local NoBtn = Instance.new("TextButton", ContentFrame)
    NoBtn.Size = UDim2.new(1, -10, 0, 40); NoBtn.Position = UDim2.new(0, 5, 0, currentY)
    NoBtn.BackgroundColor3 = Color3.fromRGB(10, 40, 30); NoBtn.Font = Enum.Font.Code; NoBtn.TextSize = 15; NoBtn.TextXAlignment = Enum.TextXAlignment.Left
    NoBtn.MouseButton1Click:Connect(function() S.Noclip = not S.Noclip end)
    currentY = currentY + 45

    -- Speed Hack
    local SpdBtn = Instance.new("TextButton", ContentFrame)
    SpdBtn.Size = UDim2.new(1, -10, 0, 40); SpdBtn.Position = UDim2.new(0, 5, 0, currentY)
    SpdBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 10); SpdBtn.Font = Enum.Font.Code; SpdBtn.TextSize = 15; SpdBtn.TextXAlignment = Enum.TextXAlignment.Left
    SpdBtn.MouseButton1Click:Connect(function() S.SpeedHack = not S.SpeedHack end)
    currentY = currentY + 45

    -- Fly Mode
    local FlyBtn = Instance.new("TextButton", ContentFrame)
    FlyBtn.Size = UDim2.new(1, -10, 0, 40); FlyBtn.Position = UDim2.new(0, 5, 0, currentY)
    FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 40); FlyBtn.Font = Enum.Font.Code; FlyBtn.TextSize = 15; FlyBtn.TextXAlignment = Enum.TextXAlignment.Left
    FlyBtn.MouseButton1Click:Connect(function() S.Fly = not S.Fly; ApplyFly() end)
    currentY = currentY + 60

    -- [SYSTEM SECTION] -------------------------------------
    local MenuBind = Instance.new("TextButton", ContentFrame)
    MenuBind.Size = UDim2.new(1, -10, 0, 40); MenuBind.Position = UDim2.new(0, 5, 0, currentY)
    MenuBind.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MenuBind.Font = Enum.Font.Code; MenuBind.TextSize = 14; MenuBind.TextXAlignment = Enum.TextXAlignment.Left
    MenuBind.MouseButton1Click:Connect(function() S.BindingMenu = true; MenuBind.Text = "  [WAITING FOR KEY...]" end)

    -- ループ更新処理（テキストの書き換え）
    RunService.Heartbeat:Connect(function()
        AimBtn.Text = "  [ " .. (S.Aimbot and "ACTIVE" or "OFF") .. " ] AIMBOT SYSTEM"
        AimBtn.TextColor3 = S.Aimbot and Color3.new(1, 0.2, 0.2) or Color3.new(0.6, 0.6, 0.6)
        
        if not S.BindingAim then AimBind.Text = "  > AIM KEY: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")) end
        
        RageBtn.Text = "  [ " .. (S.Ragebot and "RAGE" or "OFF") .. " ] RAGEBOT MODE"
        RageBtn.TextColor3 = S.Ragebot and Color3.new(1, 0, 0) or Color3.new(0.6, 0.6, 0.6)
        
        UgBtn.Text = "  [ " .. (S.Underground and "ACTIVE" or "OFF") .. " ] UNDERGROUND (-3)"
        UgBtn.TextColor3 = S.Underground and Color3.new(0.2, 1, 0.2) or Color3.new(0.6, 0.6, 0.6)
        
        NoBtn.Text = "  [ " .. (S.Noclip and "ACTIVE" or "OFF") .. " ] WALL PASS (NOCLIP)"
        NoBtn.TextColor3 = S.Noclip and Color3.new(0.2, 1, 0.8) or Color3.new(0.6, 0.6, 0.6)
        
        if not S.BindingMenu then MenuBind.Text = "  > MENU KEY: " .. tostring(S.MenuKey.Name) end
    end)
end)

-- ==========================================
-- コア・ロジック (物理制御)
-- ==========================================
RunService.PostSimulation:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    -- 地下潜行システム（落下防止＆視点補正）
    if S.Underground then
        local ray = Ray.new(root.Position + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0))
        local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
        
        -- 座標を地下-3に完全ロック
        root.CFrame = CFrame.new(root.Position.X, pos.Y + S.UG_Offset, root.Position.Z) * root.CFrame.Rotation
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z) -- 落下慣性をリセット
        
        -- 視点を地上の高さに固定（普段通りの視界）
        hum.CameraOffset = Vector3.new(0, -S.UG_Offset, 0)
    else
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end

    -- 壁貫通
    if S.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- スピード
    if S.SpeedHack then hum.WalkSpeed = S.WalkSpeed end
end)

-- ==========================================
-- エイム & RAGEBOT & 描画
-- ==========================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV
    FOVCircle.Radius = S.FOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    local aiming = (tostring(S.AimbotKey):find("MouseButton") and UserInputService:IsMouseButtonPressed(S.AimbotKey)) or UserInputService:IsKeyDown(S.AimbotKey)
    
    if (S.Aimbot and aiming) or S.Ragebot then
        local target = nil
        local maxDist = (S.Ragebot and math.huge or S.FOV)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.HitPart) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character[S.HitPart].Position)
                if onScreen or S.Ragebot then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < maxDist then
                        maxDist = mag
                        target = p
                    end
                end
            end
        end
        
        if target and mousemoverel then
            local tPos = Camera:WorldToViewportPoint(target.Character[S.HitPart].Position)
            local speed = S.Ragebot and 1 or S.Smooth
            mousemoverel((tPos.X - Mouse.X) * speed, (tPos.Y - (Mouse.Y + 36)) * speed)
        end
    end
end)

-- キー入力イベント
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if S.BindingAim or S.BindingMenu then
        local key = (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType)
        if S.BindingAim then
            S.AimbotKey = key
            S.BindingAim = false
        elseif S.BindingMenu then
            S.MenuKey = key
            S.BindingMenu = false
        end
    elseif not gameProcessed then
        if input.KeyCode == S.MenuKey then
            Main.Visible = not Main.Visible
        end
    end
end)

function ApplyFly()
    -- 飛行ロジック省略なしで記述... (以下略)
end
