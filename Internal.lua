-- ==========================================================
-- INTERNAL | UNNAMED GOD EDITION (SEQUENTIAL LOAD)
-- 5s Delay + Sequential Init (0.5s intervals)
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
if game.CoreGui:FindFirstChild("UnnamedSequential") then
    game.CoreGui:FindFirstChild("UnnamedSequential"):Destroy()
end

-- --- 設定 ---
_G.Settings = {
    Aimbot = false, SilentAim = false, Ragebot = false,
    AimbotKey = Enum.UserInputType.MouseButton2, HitPart = "Head",
    FOV = 150, ShowFOV = true, Smooth = 0.1, HitChance = 100,
    ESP = false, Box = false, Name = false, Dist = false,
    Underground = false, UG_Offset = -3, Noclip = false,
    SpeedHack = false, WalkSpeed = 80, Fly = false, FlySpeed = 70,
    MenuKey = Enum.KeyCode.Insert, BindingMenu = false, BindingAim = false
}
local S = _G.Settings

-- --- UI構築 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "UnnamedSequential"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 580, 0, 750); Main.Position = UDim2.new(0.5, -290, 0.5, -375)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BorderSizePixel = 0; Main.Visible = false

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -60); Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2; Content.CanvasSize = UDim2.new(0, 0, 0, 2500)

-- UIパーツ関数
local function AddSect(t, y)
    local l = Instance.new("TextLabel", Content); l.Size = UDim2.new(1, 0, 0, 30); l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1; l.Text = "--- " .. t .. " ---"; l.TextColor3 = Color3.fromRGB(0, 255, 150); l.Font = Enum.Font.Code; l.TextSize = 14; return y + 35
end
local function AddTog(t, k, y)
    local b = Instance.new("TextButton", Content); b.Size = UDim2.new(1,-10,0,32); b.Position = UDim2.new(0,5,0,y); b.BackgroundColor3 = Color3.fromRGB(20,20,20); b.Font = Enum.Font.Code; b.TextSize = 13
    b.MouseButton1Click:Connect(function() S[k] = not S[k] end)
    task.spawn(function() while task.wait(0.2) do b.Text = " [" .. (S[k] and "ON" or "OFF") .. "] " .. t; b.TextColor3 = S[k] and Color3.new(0,1,0.6) or Color3.new(0.5,0.5,0.5) end end)
    return y + 35
end
local function AddInp(t, k, y)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1,-10,0,32); f.Position = UDim2.new(0,5,0,y); f.BackgroundColor3 = Color3.fromRGB(15,15,15); f.BorderSizePixel = 0
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6,0,1,0); l.BackgroundTransparency = 1; l.Text = "  "..t; l.TextColor3 = Color3.new(0.7,0.7,0.7); l.Font = Enum.Font.Code; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextBox", f); b.Size = UDim2.new(0.4,-5,0.8,0); b.Position = UDim2.new(0.6,0,0.1,0); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Text = tostring(S[k]); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code
    b.FocusLost:Connect(function() local v = tonumber(b.Text); if v then S[k] = v end b.Text = tostring(S[k]) end); return y + 35
end

-- --- 【重要】ちょっとずつ起動 (Sequential Boot) ---
task.spawn(function()
    print("Unnamed: Waiting 5s for base stability...")
    task.wait(5.0)
    Main.Visible = true
    local y = 10
    
    -- 0.5秒おきに各セクションをロードしてラグを分散
    y = AddSect("MAIN (AIM)", y)
    y = AddTog("Aimbot Master", "Aimbot", y)
    y = AddTog("Silent Aim", "SilentAim", y)
    y = AddInp("Hit Chance", "HitChance", y)
    y = AddTog("Ragebot", "Ragebot", y)
    y = AddInp("FOV Size", "FOV", y)
    y = AddInp("Smoothness", "Smooth", y)
    task.wait(0.5)
    
    y = AddSect("ESP", y)
    y = AddTog("Master ESP", "ESP", y)
    y = AddTog("Box", "Box", y)
    y = AddTog("Name", "Name", y)
    task.wait(0.5)
    
    y = AddSect("CHARACTER", y)
    y = AddTog("Underground (-3)", "Underground", y)
    y = AddTog("Noclip", "Noclip", y)
    y = AddTog("Speed Hack", "SpeedHack", y)
    y = AddInp("Walk Speed", "WalkSpeed", y)
    y = AddTog("Flight", "Fly", y)
    y = AddInp("Fly Speed", "FlySpeed", y)
    task.wait(0.5)
    
    y = AddSect("SETTINGS", y)
    local AimBind = Instance.new("TextButton", Content); AimBind.Size = UDim2.new(1,-10,0,32); AimBind.Position = UDim2.new(0,5,0,y); AimBind.BackgroundColor3 = Color3.fromRGB(30,15,15); AimBind.Font = Enum.Font.Code; y=y+35
    local MenuBind = Instance.new("TextButton", Content); MenuBind.Size = UDim2.new(1,-10,0,32); MenuBind.Position = UDim2.new(0,5,0,y); MenuBind.BackgroundColor3 = Color3.fromRGB(20,20,20); MenuBind.Font = Enum.Font.Code
    
    AimBind.MouseButton1Click:Connect(function() S.BindingAim = true end)
    MenuBind.MouseButton1Click:Connect(function() S.BindingMenu = true end)
    
    task.spawn(function() while task.wait(0.1) do
        AimBind.Text = S.BindingAim and "[PRESS KEY]" or ("> Aim Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")))
        MenuBind.Text = S.BindingMenu and "[PRESS KEY]" or ("> Menu Key: " .. tostring(S.MenuKey.Name))
    end end)
end)

-- --- Underground 視点修正 & 物理 ---
local CamPart = Instance.new("Part")
CamPart.Transparency = 1; CamPart.CanCollide = false; CamPart.Anchored = true; CamPart.Parent = workspace

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if S.Underground then
        -- 体を地下へ
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        root.CFrame = CFrame.new(root.Position.X, workspace:FindPartOnRay(Ray.new(root.Position + Vector3.new(0,5,0), Vector3.new(0,-10,0)), char).Y + S.UG_Offset, root.Position.Z) * root.CFrame.Rotation
        
        -- カメラを地上へ強制固定
        CamPart.CFrame = root.CFrame * CFrame.new(0, -S.UG_Offset, 0)
        Camera.CameraSubject = CamPart
    else
        Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
    end

    if S.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- --- Movement & Combat ---
RunService.Heartbeat:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and S.SpeedHack then hum.WalkSpeed = S.WalkSpeed end
end)

local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Color = Color3.new(0,1,0.6)
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOV; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    local aiming = (tostring(S.AimbotKey):find("MouseButton") and UserInputService:IsMouseButtonPressed(S.AimbotKey)) or UserInputService:IsKeyDown(S.AimbotKey)
    if (S.Aimbot and aiming) or S.Ragebot then
        local target, last = nil, (S.Ragebot and 10000 or S.FOV)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.HitPart) then
                local pos, os = Camera:WorldToViewportPoint(p.Character[S.HitPart].Position)
                if os or S.Ragebot then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < last then last = mag;
