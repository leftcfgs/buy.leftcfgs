-- ==========================================================
-- INTERNAL | UNNAMED GOD EDITION (RE-CODE STABLE)
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local old = game.CoreGui:FindFirstChild("UnnamedGodAlpha")
if old then old:Destroy() end

-- --- グローバル設定 (再定義) ---
_G.Settings = {
    Aimbot = false,
    SilentAim = false,
    HitChance = 100,
    Ragebot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    HitPart = "Head",
    FOV = 200,
    ShowFOV = true,
    Smooth = 0.05,
    ESP = false,
    Box = false,
    Name = false,
    Dist = false,
    Underground = false,
    UG_Offset = -3,
    Noclip = false,
    SpeedHack = false,
    WalkSpeed = 80,
    Fly = false,
    FlySpeed = 70,
    MenuKey = Enum.KeyCode.Insert,
    BindingMenu = false,
    BindingAim = false
}
local S = _G.Settings

-- --- UI構築 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "UnnamedGodAlpha"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 580, 0, 750); Main.Position = UDim2.new(0.5, -290, 0.5, -375)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.Visible = false

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -60); Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 4; Content.CanvasSize = UDim2.new(0, 0, 0, 2500)

local function AddSection(text, y)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, 0, 0, 30); l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1; l.Text = "--- " .. text .. " ---"; l.TextColor3 = Color3.fromRGB(255, 0, 80); l.Font = Enum.Font.Code; l.TextSize = 16; return y + 35
end

local function AddToggle(text, key, y)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 35); btn.Position = UDim2.new(0, 5, 0, y); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.Font = Enum.Font.Code; btn.TextSize = 14; btn.TextColor3 = Color3.new(0.6,0.6,0.6)
    btn.MouseButton1Click:Connect(function() S[key] = not S[key] end)
    task.spawn(function()
        while task.wait(0.1) do
            btn.Text = "  [" .. (S[key] and "ON" or "OFF") .. "] " .. text
            btn.TextColor3 = S[key] and Color3.new(1, 0.2, 0.4) or Color3.new(0.6, 0.6, 0.6)
        end
    end)
    return y + 38
end

local function AddInput(text, key, y)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1,-10,0,35); f.Position = UDim2.new(0,5,0,y); f.BackgroundColor3 = Color3.fromRGB(20,20,20); f.BorderSizePixel = 0
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6,0,1,0); l.BackgroundTransparency = 1; l.Text = "  "..text; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = Enum.Font.Code; l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextBox", f); b.Size = UDim2.new(0.4,-5,0.8,0); b.Position = UDim2.new(0.6,0,0.1,0); b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.Text = tostring(S[key]); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code
    b.FocusLost:Connect(function() local v = tonumber(b.Text); if v then S[key] = v end b.Text = tostring(S[key]) end); return y + 38
end

-- --- UI配置 ---
task.spawn(function()
    task.wait(5.0)
    Main.Visible = true
    local y = 10
    y = AddSection("MAIN", y)
    y = AddToggle("Aimbot Master", "Aimbot", y)
    local AimBind = Instance.new("TextButton", Content); AimBind.Size = UDim2.new(1,-10,0,35); AimBind.Position = UDim2.new(0,5,0,y); AimBind.BackgroundColor3 = Color3.fromRGB(30,10,10); AimBind.Font = Enum.Font.Code; AimBind.TextColor3 = Color3.new(1,1,1); y=y+38
    AimBind.MouseButton1Click:Connect(function() S.BindingAim = true end)
    y = AddToggle("Silent Aim", "SilentAim", y)
    y = AddInput("Hit Chance", "HitChance", y)
    y = AddToggle("Ragebot", "Ragebot", y)
    y = AddInput("FOV Size", "FOV", y)
    y = AddInput("Smoothness", "Smooth", y)
    y = AddSection("ESP", y)
    y = AddToggle("Master ESP", "ESP", y)
    y = AddToggle("Box", "Box", y)
    y = AddToggle("Name", "Name", y)
    y = AddSection("CHARACTER", y)
    y = AddToggle("Underground (-3)", "Underground", y)
    y = AddToggle("Noclip", "Noclip", y)
    y = AddToggle("Speed Hack", "SpeedHack", y)
    y = AddInput("Walk Speed", "WalkSpeed", y)
    y = AddToggle("Flight", "Fly", y)
    y = AddInput("Fly Speed", "FlySpeed", y)
    y = AddSection("SETTING", y)
    local MenuBind = Instance.new("TextButton", Content); MenuBind.Size = UDim2.new(1,-10,0,35); MenuBind.Position = UDim2.new(0,5,0,y); MenuBind.BackgroundColor3 = Color3.fromRGB(20,20,20); MenuBind.Font = Enum.Font.Code; MenuBind.TextColor3 = Color3.new(1,1,1)
    MenuBind.MouseButton1Click:Connect(function() S.BindingMenu = true end)
    
    task.spawn(function()
        while task.wait(0.1) do
            AimBind.Text = S.BindingAim and "[PRESS KEY]" or ("  > Aimbot Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")))
            MenuBind.Text = S.BindingMenu and "[PRESS KEY]" or ("  > Menu Key: " .. tostring(S.MenuKey.Name))
        end
    end)
end)

-- --- 物理・視点制御コア ---
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if S.Underground then
        local ray = Ray.new(root.Position + Vector3.new(0, 5, 0), Vector3.new(0, -15, 0))
        local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
        root.CFrame = CFrame.new(root.Position.X, pos.Y + S.UG_Offset, root.Position.Z) * root.CFrame.Rotation
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        hum.CameraOffset = Vector3.new(0, -S.UG_Offset, 0) -- 視点補正
    else
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end

    if S.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if S.SpeedHack then hum.WalkSpeed = S.WalkSpeed end
end)

-- --- エイムロジック ---
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Color = Color3.new(1,0,0)
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOV; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    local aiming = (tostring(S.AimbotKey):find("MouseButton") and UserInputService:IsMouseButtonPressed(S.AimbotKey)) or UserInputService:IsKeyDown(S.AimbotKey)
    if (S.Aimbot and aiming) or S.Ragebot then
        local target = nil; local dist = (S.Ragebot and 10000 or S.FOV)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.HitPart) then
                local pos, os = Camera:WorldToViewportPoint(p.Character[S.HitPart].Position)
                if os or S.Ragebot then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < dist then dist = mag; target = p end
                end
            end
        end
        if target and mousemoverel then
            local tPos = Camera:WorldToViewportPoint(target.Character[S.HitPart].Position)
            local s = S.Ragebot and 1 or S.Smooth
            mousemoverel((tPos.X - Mouse.X) * s, (tPos.Y - (Mouse.Y + 36)) * s)
        end
    end
end)

-- --- 入力受付 ---
UserInputService.InputBegan:Connect(function(i, g)
    if S.BindingAim or S.BindingMenu then
        local k = (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType)
        if S.BindingAim then S.AimbotKey = k; S.BindingAim = false 
        elseif S.BindingMenu then S.MenuKey = k; S.BindingMenu = false end
    elseif not g and i.KeyCode == S.MenuKey then Main.Visible = not Main.Visible end
end)

-- Flight (別途ループ)
task.spawn(function()
    while task.wait() do
        if S.Fly then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                root.Velocity = dir.Unit * S.FlySpeed
            end
        end
    end
end)
