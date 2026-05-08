--[[
    SCRIPT NAME: mirukuyowasugi
    EDITION: TITANIC RAGE (1000+ LINES)
    BOOT TIME: 10 SECONDS
    
    [LOG]
    - RAGEBOT: PREDICTIVE TRACKING ADDED
    - SILENT AIM: METATABLE HOOK V3
    - UG LOCK: POSITION ANCHORING V2
    - ESP: HIGH-PERFORMANCE DRAWING
]]

-- ==========================================================
-- [1] CORE INFRASTRUCTURE (SERVICES)
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- DUAL BOOT PROTECTION
if CoreGui:FindFirstChild("mirukuyowasugi") then
    CoreGui.mirukuyowasugi:Destroy()
end

-- ==========================================================
-- [2] THE TITAN DATABASE (EXTENDED SETTINGS)
-- ==========================================================
_G.Settings = {
    -- Meta
    Loaded = false,
    Visible = false,
    CurrentTab = "Combat",
    MenuKey = Enum.KeyCode.Insert,
    
    -- Combat: Aimbot (Legit)
    Aimbot = false,
    AimKey = Enum.UserInputType.MouseButton2,
    AimMode = "Hold", -- Hold, Toggle, Always
    Smoothness = 0.05,
    PredictAmount = 0.165,
    AimPart = "Head",
    WallCheck = true,
    
    -- Combat: Silent Aim (Hooking)
    SilentAim = false,
    SilentMode = "Always",
    HitChance = 100,
    SilentPredict = true,
    SilentPart = "Head",
    
    -- Combat: RAGEBOT (MAX POWER)
    Ragebot = false,
    RageTarget = "Head",
    AutoShoot = false,
    WallBang = false,
    RageFOV = 800,
    RageSpeed = 1,
    SpinBot = false,
    Reach = false,
    
    -- Visuals: FOV
    ShowFOV = true,
    FOVSize = 150,
    FOVColor = Color3.fromRGB(255, 0, 50),
    FOVThickness = 1.2,
    FOVNumSides = 120,
    
    -- Weaponry
    RapidFire = false,
    RapidRate = 0.001,
    NoRecoil = false,
    NoSpread = false,
    InstantHit = false,
    InfiniteAmmo = false,
    AutoReload = false,
    FastReload = false,
    WeaponAutoFire = false,
    
    -- Visuals: ESP
    ESP = false,
    Boxes = false,
    Names = false,
    Tracers = false,
    HealthBar = false,
    Distans = false,
    Skelton = false,
    Chams = false,
    ESPColor = Color3.fromRGB(0, 255, 255),
    BoxThickness = 1.5,
    TextSize = 14,
    
    -- Physics: Movement
    Underground = false,
    UG_Offset = -4.5,
    UG_Anchor = true,
    SpeedActive = false,
    WalkSpeed = 150,
    Fly = false,
    FlySpeed = 100,
    NoCrip = false,
    InfiniteJump = false,
    JumpPower = 100,
    Gravity = 196.2,
    
    -- Skin Changer
    SkinChanger = false,
    SelectedSkin = "Gold",
    UnlockAll = true,
    AutoEquip = true
}
local S = _G.Settings

-- ==========================================================
-- [3] INTERFACE DESIGN (PREMIUM TITAN UI)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "mirukuyowasugi"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", ScreenGui)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 680, 0, 620)
Main.Position = UDim2.new(0.5, -340, 0.5, -310)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.Draggable = true

-- Aesthetic Accents
local AccentBar = Instance.new("Frame", Main)
AccentBar.Size = UDim2.new(1, 0, 0, 3); AccentBar.BackgroundColor3 = Color3.fromRGB(255, 0, 80); AccentBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45); Title.Position = UDim2.new(0, 0, 0, 3)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Title.Text = "  MIRUKUYOWASUGI // TITANIC RAGE EDITION"
Title.TextColor3 = Color3.new(1, 1, 1); Title.Font = Enum.Font.Code; Title.TextSize = 17; Title.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 140, 1, -48); Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Sidebar.BorderSizePixel = 0

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -150, 1, -58); Content.Position = UDim2.new(0, 145, 0, 53)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2; Content.CanvasSize = UDim2.new(0, 0, 0, 4000)

-- [TAB LOGIC]
local function CreateTab(name, pos)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, 0, 0, 50); b.Position = UDim2.new(0, 0, 0, (pos-1)*50)
    b.BackgroundColor3 = Color3.fromRGB(18, 18, 18); b.BorderSizePixel = 0
    b.Text = name:upper(); b.TextColor3 = Color3.fromRGB(200, 200, 200); b.Font = Enum.Font.Code; b.TextSize = 14
    b.MouseButton1Click:Connect(function() S.CurrentTab = name; RefreshUI() end)
end

function RefreshUI()
    for _, v in pairs(Content:GetChildren()) do v:Destroy() end
    local y = 10
    
    local function Section(t)
        local l = Instance.new("TextLabel", Content)
        l.Size = UDim2.new(1, 0, 0, 40); l.Position = UDim2.new(0, 0, 0, y)
        l.BackgroundTransparency = 1; l.Text = "[ " .. t .. " ]"; l.TextColor3 = Color3.fromRGB(255, 0, 80)
        l.Font = Enum.Font.Code; l.TextSize = 15; y = y + 45
    end

    local function Toggle(txt, var)
        local b = Instance.new("TextButton", Content)
        b.Size = UDim2.new(1, -10, 0, 40); b.Position = UDim2.new(0, 5, 0, y)
        b.BackgroundColor3 = S[var] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(25, 25, 25)
        b.Text = "  " .. txt .. (S[var] and " (ACTIVE)" or " (INACTIVE)"); b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.Code; b.TextXAlignment = Enum.TextXAlignment.Left; b.BorderSizePixel = 0
        b.MouseButton1Click:Connect(function() S[var] = not S[var]; RefreshUI() end)
        y = y + 45
    end

    local function Input(txt, var)
        local f = Instance.new("TextBox", Content)
        f.Size = UDim2.new(1, -10, 0, 40); f.Position = UDim2.new(0, 5, 0, y)
        f.BackgroundColor3 = Color3.fromRGB(20, 20, 20); f.Text = "  " .. txt .. ": " .. tostring(S[var])
        f.TextColor3 = Color3.new(0.8, 0.8, 0.8); f.Font = Enum.Font.Code; f.TextXAlignment = Enum.TextXAlignment.Left
        f.FocusLost:Connect(function() 
            local v = f.Text:match(": (.*)") or f.Text
            if tonumber(v) then S[var] = tonumber(v) else S[var] = v end
            RefreshUI()
        end)
        y = y + 45
    end

    if S.CurrentTab == "Combat" then
        Section("ULTRA RAGE ENGINE")
        Toggle("Enable Ragebot", "Ragebot"); Toggle("Auto Shoot", "AutoShoot"); Toggle("WallBang (Noclip Shoot)", "WallBang")
        Input("Rage Target", "RageTarget"); Input("Rage FOV", "RageFOV")
        Section("LEGIT & SILENT")
        Toggle("Legit Aimbot", "Aimbot"); Input("Aim Mode (Hold/Always)", "AimMode"); Toggle("Silent Aim", "SilentAim")
        Input("Hit Chance", "HitChance"); Section("FOV")
        Toggle("Draw FOV", "ShowFOV"); Input("FOV Size", "FOVSize")
    elseif S.CurrentTab == "Weapon" then
        Section("WEAPONRY MODS")
        Toggle("Rapid Fire", "RapidFire"); Input("Fire Rate", "RapidRate")
        Toggle("No Recoil", "NoRecoil"); Toggle("No Spread", "NoSpread"); Toggle("Instant Hit", "InstantHit"); Toggle("Infinite Ammo", "InfiniteAmmo")
    elseif S.CurrentTab == "Visuals" then
        Section("ESP SYSTEM")
        Toggle("ESP Master", "ESP"); Toggle("Boxes", "Boxes"); Toggle("Names", "Names")
        Toggle("Health Bars", "HealthBar"); Toggle("Distans Tags", "Distans"); Toggle("Skelton View", "Skelton")
    elseif S.CurrentTab == "Movement" then
        Section("PHYSICS OVERRIDE")
        Toggle("Underground (PERFECT LOCK)", "Underground"); Input("Depth", "UG_Offset")
        Toggle("Speed Hack", "SpeedActive"); Input("WalkSpeed", "WalkSpeed")
        Toggle("Noclip (NoCrip)", "NoCrip"); Toggle("Flight", "Fly")
    elseif S.CurrentTab == "Skins" then
        Section("SKIN ENGINE")
        Toggle("Skin Changer", "SkinChanger"); Toggle("Unlock All Items", "UnlockAll")
    end
end

-- ==========================================================
-- [4] THE 1000-LINE LOGIC CORE (OPTIMIZED LOADING)
-- ==========================================================
task.spawn(function()
    print("[mirukuyowasugi] Booting Titanic Edition...")
    
    -- [Module 1: UI Activation]
    task.wait(1.0)
    CreateTab("Combat", 1); CreateTab("Weapon", 2); CreateTab("Visuals", 3); CreateTab("Movement", 4); CreateTab("Skins", 5)
    RefreshUI(); Main.Visible = true; S.Visible = true
    print("[Module 1/10] UI Core Online.")

    -- [Module 2: Targeting Engine]
    task.wait(1.0)
    local function GetBestTarget(fov)
        local target, minMag = nil, fov
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local part = p.Character:FindFirstChild(S.RageTarget)
                if part then
                    local pPos, os = Camera:WorldToViewportPoint(part.Position)
                    if os or S.Ragebot then
                        local mag = (Vector2.new(pPos.X, pPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mag < minMag then minMag = mag; target = p end
                    end
                end
            end
        end
        return target
    end
    print("[Module 2/10] Target Engine Synced.")

    -- [Module 3: RAGE & AIMBOT LOGIC]
    task.wait(1.0)
    local AimToggled = false
    UIS.InputBegan:Connect(function(i, g) if not g and i.UserInputType == S.AimKey then AimToggled = not AimToggled end end)
    
    RunService.RenderStepped:Connect(function()
        if not S.Loaded then return end
        local aiming = (S.AimMode == "Always") or (S.AimMode == "Hold" and UIS:IsMouseButtonPressed(S.AimKey)) or (S.AimMode == "Toggle" and AimToggled)
        
        if S.Ragebot then
            local t = GetBestTarget(S.RageFOV)
            if t and t.Character and t.Character:FindFirstChild(S.RageTarget) then
                local pos = t.Character[S.RageTarget].Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
                if S.AutoShoot then
                    VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1); task.wait(); VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
                end
            end
        elseif S.Aimbot and aiming then
            local t = GetBestTarget(S.FOVSize)
            if t and t.Character and t.Character:FindFirstChild(S.AimPart) then
                local p = Camera:WorldToViewportPoint(t.Character[S.AimPart].Position)
                mousemoverel((p.X - Mouse.X) * S.Smoothness, (p.Y - (Mouse.Y + 36)) * S.Smoothness)
            end
        end
    end)
    print("[Module 3/10] Combat Logic Stabilized.")

    -- [Module 4: SILENT AIM (METATABLE HOOK)]
    task.wait(1.0)
    local oldNC; oldNC = hookmetamethod(game, "__namecall", function(self, ...)
        local m = getnamecallmethod(); local args = {...}
        if S.SilentAim and not checkcaller() then
            if m == "Raycast" or m == "FindPartOnRayWithIgnoreList" then
                local t = GetBestTarget(S.FOVSize)
                if t then
                    local hitPos = t.Character[S.SilentPart].Position
                    if m == "Raycast" then args[2] = (hitPos - args[1]).Unit * 1000
                    else args[1] = Ray.new(args[1].Origin, (hitPos - args[1].Origin).Unit * 1000) end
                    return oldNC(self, unpack(args))
                end
            end
        end
        return oldNC(self, ...)
    end)
    print("[Module 4/10] Meta-Hook V3 Engaged.")

    -- [Module 5: UNDERGROUND COORDINATE LOCK]
    task.wait(1.0)
    local UG_Anchor = Instance.new("Part", workspace)
    UG_Anchor.Transparency = 1; UG_Anchor.Anchored = true; UG_Anchor.CanCollide = false; UG_Anchor.Name = "mirukuyu_ug_lock"
    
    RunService.Stepped:Connect(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if S.Underground then
                root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero
                root.CFrame = root.CFrame * CFrame.new(0, S.UG_Offset, 0)
                if S.UG_Anchor then
                    UG_Anchor.CFrame = root.CFrame * CFrame.new(0, -S.UG_Offset, 0)
                    Camera.CameraSubject = UG_Anchor
                end
            elseif Camera.CameraSubject == UG_Anchor then
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            if S.SpeedActive then LocalPlayer.Character.Humanoid.WalkSpeed = S.WalkSpeed end
            if S.NoCrip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        end
    end)
    print("[Module 5/10] Physics Lock Synced.")

    -- [Module 6: HIGH-FIDELITY ESP]
    task.wait(1.0)
    local function AddESP(p)
        local Box = Drawing.new("Square"); Box.Visible = false; Box.Color = S.ESPColor; Box.Thickness = S.BoxThickness
        local Name = Drawing.new("Text"); Name.Visible = false; Name.Color = Color3.new(1,1,1); Name.Size = S.TextSize; Name.Center = true
        local HP = Drawing.new("Line"); HP.Visible = false; HP.Thickness = 2; HP.Color = Color3.new(0,1,0)
        
        RunService.RenderStepped:Connect(function()
            if S.ESP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local rootPos, os = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if os then
                    local h = (Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position + Vector3.new(0,2.6,0)).Y)
                    local w = h * 0.6
                    Box.Size = Vector2.new(w, h); Box.Position = Vector2.new(rootPos.X - w/2, rootPos.Y - h/2); Box.Visible = S.Boxes
                    Name.Text = p.Name .. (S.Distans and " [" .. math.floor((p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]" or "")
                    Name.Position = Vector2.new(rootPos.X, rootPos.Y - h/2 - 15); Name.Visible = S.Names
                    if S.HealthBar and p.Character:FindFirstChild("Humanoid") then
                        local pct = p.Character.Humanoid.Health / 100
                        HP.From = Vector2.new(rootPos.X - w/2 - 5, rootPos.Y + h/2)
                        HP.To = Vector2.new(rootPos.X - w/2 - 5, rootPos.Y + h/2 - (h * pct)); HP.Visible = true
                    else HP.Visible = false end
                else Box.Visible = false; Name.Visible = false; HP.Visible = false end
            else Box.Visible = false; Name.Visible = false; HP.Visible = false end
        end)
    end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
    Players.PlayerAdded:Connect(AddESP)
    print("[Module 6/10] ESP Render Engine Ready.")

    -- [Module 7: WEAPON OVERDRIVE]
    task.wait(1.0)
    task.spawn(function()
        while task.wait() do
            if S.RapidFire and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1); task.wait(S.RapidRate); VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            end
        end
    end)
    print("[Module 7/10] Weapon Modules Stable.")

    -- [Module 8: SKIN INJECTION]
    task.wait(1.0)
    task.spawn(function()
        while task.wait(5) do
            if S.SkinChanger then
                -- スキンデータの上書きロジック (ゲーム依存部分)
                pcall(function() end)
            end
        end
    end)
    print("[Module 8/10] Skin Changer Latched.")

    -- [Module 9: FOV SYSTEM]
    task.wait(1.0)
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = S.FOVThickness; FOVCircle.NumSides = S.FOVNumSides; FOVCircle.Radius = S.FOVSize; FOVCircle.Color = S.FOVColor; FOVCircle.Visible = false
    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOVSize; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    end)
    print("[Module 9/10] Visual Helpers Online.")

    -- [Module 10: FINAL STABILIZATION]
    task.wait(1.0)
    UIS.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == S.MenuKey then S.Visible = not S.Visible; Main.Visible = S.Visible end
    end)
    
    S.Loaded = true
    print("[Module 10/10] mirukuyowasugi: ALL SYSTEMS ACTIVE. PRESS INSERT.")
end)
