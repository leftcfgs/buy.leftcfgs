-- ==========================================================
-- INTERNAL | UNNAMED GOD EDITION (FIXED & CATEGORIZED)
-- CATEGORIES: Main, ESP, Visual, Character, Setting
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

-- --- 設定データ (完全版) ---
_G.Settings = {
    -- [MAIN]
    Aimbot = false,
    SilentAim = false,
    HitChance = 100,
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
    FovColor = Color3.fromRGB(255, 0, 80),
    -- [CHARACTER]
    Underground = false,
    UG_Offset = -3,
    Noclip = false,
    SpeedHack = false,
    WalkSpeed = 80,
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
Main.Size = UDim2.new(0, 580, 0, 800); Main.Position = UDim2.new(0.5, -290, 0.5, -400)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.Visible = false

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 3); TopBar.BackgroundColor3 = Color3.fromRGB(255, 0, 80); TopBar.BorderSizePixel = 0

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -50); Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 4; Content.CanvasSize = UDim2.new(0, 0, 0, 2600)

-- --- UI補助関数 ---
local function CreateSection(text, y)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, 0, 0, 40); l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1; l.Text = "--- " .. text .. " ---"; l.TextColor3 = Color3.fromRGB(255, 0, 80)
    l.Font = Enum.Font.Code; l.TextSize = 16; return y + 45
end

local function AddToggle(text, key, y)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 38); btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.BorderSizePixel = 0; btn.Font = Enum.Font.Code; btn.TextSize = 14; btn.TextXAlignment = Enum.TextXAlignment.Left
    local function up()
        btn.Text = "  [" .. (S[key] and "ON" or "OFF") .. "] " .. text
        btn.TextColor3 = S[key] and Color3.new(1, 0.2, 0.4) or Color3.new(0.6, 0.6, 0.6)
    end
    btn.MouseButton1Click:Connect(function() S[key] = not S[key]; up(); if key == "Fly" then ApplyFly() end end)
    up(); return y + 42
end

local function AddInput(text, key, y)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1,-10,0,38); f.Position = UDim2.new(0,5,0,y); f.BackgroundColor3 = Color3.fromRGB(20,20,20); f.BorderSizePixel = 0
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6,0,1,0); l.BackgroundTransparency = 1; l.Text = "  "..text; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = Enum.Font.Code; l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextBox", f); b.Size = UDim2.new(0.4,-5,0.8,0); b.Position = UDim2.new(0.6,0,0.1,0); b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.Text = tostring(S[key]); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code
    b.FocusLost:Connect(function() local v = tonumber(b.Text:match("-?%d+%.?%d*")); if v then S[key] = v end b.Text = tostring(S[key]) end)
    return y + 42
end

-- --- 5秒起動 ---
task.spawn(function()
    task.wait(5.0)
    Main.Visible = true
    local y = 5
    
    -- 1. MAIN
    y = CreateSection("MAIN", y)
    y = AddToggle("Aimbot Master", "Aimbot", y)
    local AimBind = Instance.new("TextButton", Content); AimBind.Size = UDim2.new(1,-10,0,38); AimBind.Position = UDim2.new(0,5,0,y); AimBind.BackgroundColor3 = Color3.fromRGB(30,10,10); AimBind.Font = Enum.Font.Code; AimBind.TextColor3 = Color3.new(1,1,1); AimBind.MouseButton1Click:Connect(function() S.BindingAim = true; AimBind.Text = "[PRESS KEY]" end); y=y+42
    y = AddToggle("Silent Aim", "SilentAim", y)
    y = AddInput("Hit Chance (%)", "HitChance", y)
    y = AddToggle("Ragebot", "Ragebot", y)
    y = AddInput("Smoothness", "Smooth", y)
    y = AddInput("FOV Size", "FOV", y)
    local partBtn = Instance.new("TextButton", Content); partBtn.Size = UDim2.new(1,-10,0,38); partBtn.Position = UDim2.new(0,5,0,y); partBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); partBtn.Font = Enum.Font.Code; partBtn.TextColor3 = Color3.new(1,1,1); 
    partBtn.MouseButton1Click:Connect(function() if S.HitPart == "Head" then S.HitPart = "HumanoidRootPart" else S.HitPart = "Head" end partBtn.Text = "  Hit Part: " .. S.HitPart end); partBtn.Text = "  Hit Part: " .. S.HitPart; y=y+50

    -- 2. ESP
    y = CreateSection("ESP", y)
    y = AddToggle("Master ESP", "ESP", y)
    y = AddToggle("Box", "Box", y)
    y = AddToggle("Name", "Name", y)
    y = AddToggle("Distance", "Dist", y); y=y+20

    -- 3. VISUAL
    y = CreateSection("VISUAL", y)
    y = AddToggle("Show FOV", "ShowFOV", y); y=y+20

    -- 4. CHARACTER
    y = CreateSection("CHARACTER", y)
    y = AddToggle("Underground (-3 Fixed)", "Underground", y)
    y = AddToggle("Noclip", "Noclip", y)
    y = AddToggle("Speed Hack", "SpeedHack", y)
    y = AddInput("Walk Speed", "WalkSpeed", y)
    y = AddToggle("Flight", "Fly", y)
    y = AddInput("Fly Speed", "FlySpeed", y); y=y+20

    -- 5. SETTING
    y = CreateSection("SETTING", y)
    local MenuBind = Instance.new("TextButton", Content); MenuBind.Size = UDim2.new(1,-10,0,38); MenuBind.Position = UDim2.new(0,5,0,y); MenuBind.BackgroundColor3 = Color3.fromRGB(20,20,20); MenuBind.Font = Enum.Font.Code; MenuBind.TextColor3 = Color3.new(1,1,1); MenuBind.MouseButton1Click:Connect(function() S.BindingMenu = true; MenuBind.Text = "[PRESS KEY]" end)

    task.spawn(function()
        while task.wait(0.1) do
            if not S.BindingAim then AimBind.Text = "  > Aimbot Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")) end
            if not S.BindingMenu then MenuBind.Text = "  > Menu Key: " .. tostring(S.MenuKey.Name) end
        end
    end)
end)

-- --- コア制御 (Underground修正版) ---
RunService.PostSimulation:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if S.Underground then
        local ray = Ray.new(root.Position + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0))
        local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char, workspace.CurrentCamera})
        -- 物理固定
        root.CFrame = CFrame.new(root.Position.X, pos.Y + S.UG_Offset, root.Position.Z) * root.CFrame.Rotation
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        -- 視点補正：-3の分だけ上にオフセットさせて地上視点を維持
        hum.CameraOffset = Vector3.new(0, -S.UG_Offset, 0)
    else
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end

    if S.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    
    if S.SpeedHack then hum.WalkSpeed = S.WalkSpeed end
end)

-- --- Aimbot / Rage / Silent ---
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Color = S.FovColor
local function GetClosest()
    local target, dist = nil, (S.Ragebot and 10000 or S.FOV)
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

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOV; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    local aiming = (tostring(S.AimbotKey):find("MouseButton") and UserInputService:IsMouseButtonPressed(S.AimbotKey)) or UserInputService:IsKeyDown(S.AimbotKey)
    
    if (S.Aimbot and aiming) or S.Ragebot then
        local t = GetClosest()
        if t and mousemoverel then
            local tPos = Camera:WorldToViewportPoint(t.Character[S.HitPart].Position)
            local s = S.Ragebot and 1 or S.Smooth
            mousemoverel((tPos.X - Mouse.X) * s, (tPos.Y - (Mouse.Y + 36)) * s)
        end
    end
end)

-- --- Keybind & Fly ---
UserInputService.InputBegan:Connect(function(i, g)
    if S.BindingAim or S.BindingMenu then
        local k = (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType)
        if S.BindingAim then S.AimbotKey = k; S.BindingAim = false 
        elseif S.BindingMenu then S.MenuKey = k; S.BindingMenu = false end
    elseif not g and i.KeyCode == S.MenuKey then Main.Visible = not Main.Visible end
end)

function ApplyFly()
    if _G.FlyLoop then _G.FlyLoop:Disconnect(); _G.FlyLoop = nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not S.Fly or not root then return end
    task.spawn(function()
        local bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(1,1,1) * math.huge
        _G.FlyLoop = RunService.RenderStepped:Connect(function()
            if not S.Fly or not root.Parent then _G.FlyLoop:Disconnect(); if bv then bv:Destroy() end return end
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            bv.Velocity = move.Unit * S.FlySpeed
        end)
    end)
end
