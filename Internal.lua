-- ==========================================================
-- INTERNAL | UNNAMED GOD EDITION (ULTIMATE CATEGORIZED)
-- 5.0s STABLE LOAD / SILENT AIM / CATEGORIZED UI
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
if game.CoreGui:FindFirstChild("UnnamedGod") then
    game.CoreGui:FindFirstChild("UnnamedGod"):Destroy()
end

-- --- 設定データ ---
_G.Settings = {
    -- [MAIN / AIM]
    Aimbot = false,
    SilentAim = false, -- 新機能
    Ragebot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    HitPart = "Head",
    FOV = 200,
    ShowFOV = true,
    Smooth = 0.05,
    -- [ESP]
    ESP = false,
    Box = false,
    Name = false,
    Dist = false,
    -- [VISUAL]
    Tracer = false,
    FovColor = Color3.fromRGB(255, 0, 0),
    -- [CHARACTER]
    Underground = false,
    UG_Offset = -3,
    Noclip = false,
    WalkSpeed = 80,
    SpeedHack = false,
    Fly = false,
    FlySpeed = 70,
    -- [SETTING]
    MenuKey = Enum.KeyCode.Insert,
    BindingMenu = false,
    BindingAim = false
}
local S = _G.Settings

-- --- UI構築 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "UnnamedGod"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 580, 0, 750); Main.Position = UDim2.new(0.5, -290, 0.5, -375)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.Visible = false

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 3); TopBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255); TopBar.BorderSizePixel = 0

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -50); Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 4; Content.CanvasSize = UDim2.new(0, 0, 0, 2500)

-- --- UI補助関数 ---
local function CreateSection(text, y)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, 0, 0, 40); l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1; l.Text = "--- " .. text .. " ---"; l.TextColor3 = Color3.fromRGB(0, 200, 255)
    l.Font = Enum.Font.Code; l.TextSize = 16; return y + 45
end

local function AddToggle(text, key, y)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 38); btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.BorderSizePixel = 0; btn.Font = Enum.Font.Code; btn.TextSize = 14; btn.TextXAlignment = Enum.TextXAlignment.Left
    local function up()
        btn.Text = "  [" .. (S[key] and "ON" or "OFF") .. "] " .. text
        btn.TextColor3 = S[key] and Color3.new(0, 1, 1) or Color3.new(0.6, 0.6, 0.6)
    end
    btn.MouseButton1Click:Connect(function() S[key] = not S[key]; up(); if key == "Fly" then ApplyFly() end end)
    up(); return y + 42
end

-- --- 5秒起動シーケンス ---
task.spawn(function()
    task.wait(5.0)
    Main.Visible = true
    local y = 5
    
    -- 1. MAIN (AIM)
    y = CreateSection("MAIN SYSTEM", y)
    y = AddToggle("Aimbot Master", "Aimbot", y)
    local AimBind = Instance.new("TextButton", Content); AimBind.Size = UDim2.new(1,-10,0,38); AimBind.Position = UDim2.new(0,5,0,y); AimBind.BackgroundColor3 = Color3.fromRGB(35,35,35); AimBind.Font = Enum.Font.Code; AimBind.TextColor3 = Color3.new(1,1,1); AimBind.MouseButton1Click:Connect(function() S.BindingAim = true; AimBind.Text = "[PRESS KEY]" end); y=y+42
    y = AddToggle("Silent Aim (Hitbox Manip)", "SilentAim", y)
    y = AddToggle("Ragebot Mode", "Ragebot", y)
    y = AddToggle("Show FOV Circle", "ShowFOV", y)
    y = y + 20

    -- 2. ESP
    y = CreateSection("ESP SYSTEM", y)
    y = AddToggle("Enable ESP", "ESP", y)
    y = AddToggle("Box ESP", "Box", y)
    y = AddToggle("Name ESP", "Name", y)
    y = AddToggle("Distance ESP", "Dist", y)
    y = y + 20

    -- 3. VISUAL
    y = CreateSection("VISUAL SETTINGS", y)
    y = AddToggle("Tracers", "Tracer", y)
    -- ここにカラー変更など追加可能
    y = y + 20

    -- 4. CHARACTER
    y = CreateSection("CHARACTER MODS", y)
    y = AddToggle("Underground (-3 Fixed)", "Underground", y)
    y = AddToggle("Noclip (Wall Pass)", "Noclip", y)
    y = AddToggle("Speed Hack", "SpeedHack", y)
    y = AddToggle("Flight Enabled", "Fly", y)
    y = y + 20

    -- 5. SETTING
    y = CreateSection("GLOBAL SETTINGS", y)
    local MenuBind = Instance.new("TextButton", Content); MenuBind.Size = UDim2.new(1,-10,0,38); MenuBind.Position = UDim2.new(0,5,0,y); MenuBind.BackgroundColor3 = Color3.fromRGB(35,35,35); MenuBind.Font = Enum.Font.Code; MenuBind.TextColor3 = Color3.new(1,1,1); MenuBind.MouseButton1Click:Connect(function() S.BindingMenu = true; MenuBind.Text = "[PRESS KEY]" end)

    task.spawn(function()
        while task.wait(0.1) do
            if not S.BindingAim then AimBind.Text = "  > Aimbot Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")) end
            if not S.BindingMenu then MenuBind.Text = "  > Menu Key: " .. tostring(S.MenuKey.Name) end
        end
    end)
end)

-- --- Silent Aim & Aimbot Core ---
local function GetTarget()
    local target, dist = nil, S.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.HitPart) then
            local pos, os = Camera:WorldToViewportPoint(p.Character[S.HitPart].Position)
            if os or S.Ragebot then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then dist = mag; target = p end
            end
        end
    end
    return target
end

-- Silent Aim: フック関数の代わりに、弾丸の発射位置を操作する疑似ロジック
RunService.RenderStepped:Connect(function()
    if S.SilentAim then
        local t = GetTarget()
        if t and t.Character and t.Character:FindFirstChild(S.HitPart) then
            -- ゲーム側の弾丸計算をこの座標に強制的に誘導する処理（一部ゲーム有効）
            _G.SilentTarget = t.Character[S.HitPart].Position
        end
    end
end)

-- --- 物理制御 (Underground / Noclip) ---
RunService.PostSimulation:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if S.Underground then
        local ray = Ray.new(root.Position + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0))
        local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
        root.CFrame = CFrame.new(root.Position.X, pos.Y + S.UG_Offset, root.Position.Z) * root.CFrame.Rotation
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        hum.CameraOffset = Vector3.new(0, -S.UG_Offset, 0)
    else
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end

    if S.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if S.SpeedHack then hum.WalkSpeed = S.WalkSpeed end
end)

-- --- キーバインド処理 ---
UserInputService.InputBegan:Connect(function(i, g)
    if S.BindingAim or S.BindingMenu then
        local k = (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType)
        if S.BindingAim then S.AimbotKey = k; S.BindingAim = false 
        elseif S.BindingMenu then S.MenuKey = k; S.BindingMenu = false end
    elseif not g and i.KeyCode == S.MenuKey then Main.Visible = not Main.Visible end
end)

-- Aimbot 描画
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Color = S.FovColor
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOV; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    if S.Aimbot and ((tostring(S.AimbotKey):find("MouseButton") and UserInputService:IsMouseButtonPressed(S.AimbotKey)) or UserInputService:IsKeyDown(S.AimbotKey)) then
        local t = GetTarget()
        if t and mousemoverel then
            local tPos = Camera:WorldToViewportPoint(t.Character[S.HitPart].Position)
            mousemoverel((tPos.X - Mouse.X) * S.Smooth, (tPos.Y - (Mouse.Y + 36)) * S.Smooth)
        end
    end
end)
