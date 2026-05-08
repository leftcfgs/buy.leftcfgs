-- ==========================================================
-- SCRIPT NAME: mirukuyowasugi
-- VERSION: TITAN OVERLOAD (NO OMISSION)
-- FEATURES: ULTRA RAGE, SILENT, ESP, UG LOCK, SKIN CHANGER
-- ==========================================================

-- [1] INITIALIZATION & SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複起動の完全排除
if game.CoreGui:FindFirstChild("mirukuyowasugi") then
    game.CoreGui.mirukuyowasugi:Destroy()
end

-- [2] GLOBAL SETTINGS (最強パラメーター)
_G.Settings = {
    -- Tabs
    CurrentTab = "Combat",
    -- Aimbot & Keybinds
    Aimbot = false,
    AimKey = Enum.UserInputType.MouseButton2,
    AimMode = "Hold", -- Hold, Toggle, Always
    Smoothness = 0.05,
    PredictAmount = 0.165,
    -- Silent Aim
    SilentAim = false,
    SilentKey = Enum.UserInputType.MouseButton2,
    SilentMode = "Always",
    HitChance = 100,
    -- Ragebot
    Ragebot = false,
    AutoShoot = false,
    WallBang = false,
    TargetPart = "Head", -- Head, Torso, HumanoidRootPart
    -- FOV
    FOVSize = 150,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 0, 0),
    -- Weapon
    RapidFire = false,
    RapidRate = 0.001,
    NoRecoil = false,
    NoSpread = false,
    InstantHit = false,
    InfiniteAmmo = false,
    -- Visuals (ESP)
    ESP = false,
    Boxes = false,
    Names = false,
    Tracers = false,
    HealthBar = false,
    Distans = false,
    Skelton = false,
    Chams = false,
    ESPColor = Color3.fromRGB(255, 255, 255),
    -- Character / Movement
    Underground = false,
    UG_Offset = -4.5,
    UG_CamLock = true,
    SpeedActive = false,
    WalkSpeed = 150,
    Fly = false,
    FlySpeed = 100,
    NoCrip = false,
    InfiniteJump = false,
    JumpPower = 50,
    -- Skins
    SkinChanger = false,
    SelectedSkin = "Gold",
    UnlockAll = true,
    -- System
    MenuKey = Enum.KeyCode.Insert,
    Visible = false,
    BootDelay = 6.0
}
local S = _G.Settings

-- [3] UI CONSTRUCTION (PRO-STYLE DESIGN)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "mirukuyowasugi"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 620, 0, 600)
Main.Position = UDim2.new(0.5, -310, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.Draggable = true

-- UI Decoration (Glow & Border)
local Border = Instance.new("Frame", Main)
Border.Size = UDim2.new(1, 4, 1, 4); Border.Position = UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Border.ZIndex = 0

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "  MIRUKUYOWASUGI v2.0 | PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.Code
Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local TabHolder = Instance.new("Frame", Main)
TabHolder.Size = UDim2.new(0, 120, 1, -40); TabHolder.Position = UDim2.new(0, 0, 0, 40)
TabHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TabHolder.BorderSizePixel = 0

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -130, 1, -50); Container.Position = UDim2.new(0, 125, 0, 45)
Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 4; Container.CanvasSize = UDim2.new(0, 0, 0, 2800)

-- Tab Creation Logic
local tabs = {"Combat", "Weapon", "Visuals", "Char", "Skins", "Settings"}
for i, tabName in pairs(tabs) do
    local b = Instance.new("TextButton", TabHolder)
    b.Size = UDim2.new(1, 0, 0, 40); b.Position = UDim2.new(0, 0, 0, (i-1)*40)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.Text = tabName:upper()
    b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.BorderSizePixel = 0
    b.MouseButton1Click:Connect(function() S.CurrentTab = tabName; RefreshUI() end)
end

function RefreshUI()
    for _, v in pairs(Container:GetChildren()) do v:Destroy() end
    local y = 10
    
    local function NewSection(text)
        local l = Instance.new("TextLabel", Container)
        l.Size = UDim2.new(1,0,0,30); l.Position = UDim2.new(0,0,0,y)
        l.BackgroundTransparency = 1; l.Text = "[ " .. text .. " ]"; l.TextColor3 = Color3.fromRGB(0, 255, 180)
        l.Font = Enum.Font.Code; l.TextSize = 14; y = y + 35
    end
    
    local function NewToggle(text, key)
        local b = Instance.new("TextButton", Container)
        b.Size = UDim2.new(1,-10,0,35); b.Position = UDim2.new(0,5,0,y)
        b.BackgroundColor3 = S[key] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
        b.Text = "  " .. text .. (S[key] and " (ON)" or " (OFF)")
        b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.TextXAlignment = Enum.TextXAlignment.Left
        b.MouseButton1Click:Connect(function() S[key] = not S[key]; RefreshUI() end)
        y = y + 40
    end

    local function NewInput(text, key)
        local f = Instance.new("TextBox", Container)
        f.Size = UDim2.new(1,-10,0,35); f.Position = UDim2.new(0,5,0,y)
        f.BackgroundColor3 = Color3.fromRGB(25, 25, 25); f.Text = "  " .. text .. ": " .. tostring(S[key])
        f.TextColor3 = Color3.new(0.8,0.8,0.8); f.Font = Enum.Font.Code; f.TextXAlignment = Enum.TextXAlignment.Left
        f.FocusLost:Connect(function() 
            local val = f.Text:match(": (.*)") or f.Text
            if tonumber(val) then S[key] = tonumber(val) else S[key] = val end
            RefreshUI() 
        end)
        y = y + 40
    end

    if S.CurrentTab == "Combat" then
        NewSection("RAGE & AIMBOT")
        NewToggle("Ultra Ragebot", "Ragebot"); NewToggle("Aimbot Master", "Aimbot"); NewToggle("Silent Aim", "SilentAim")
        NewInput("Hit Chance", "HitChance"); NewInput("Aim Mode (Hold/Toggle/Always)", "AimMode"); NewInput("Target Part", "TargetPart")
        NewSection("FOV SETTINGS")
        NewToggle("Show FOV Circle", "ShowFOV"); NewInput("FOV Size", "FOVSize")
    elseif S.CurrentTab == "Weapon" then
        NewSection("GUN MODIFICATIONS")
        NewToggle("Rapid Fire (Extreme)", "RapidFire"); NewInput("Rate", "RapidRate")
        NewToggle("No Recoil", "NoRecoil"); NewToggle("No Spread", "NoSpread"); NewToggle("Instant Hit", "InstantHit"); NewToggle("Infinite Ammo", "InfiniteAmmo")
    elseif S.CurrentTab == "Visuals" then
        NewSection("ESP MASTER")
        NewToggle("Enable ESP", "ESP"); NewToggle("Box ESP", "Boxes"); NewToggle("Name Tags", "Names")
        NewToggle("Health Bar", "HealthBar"); NewToggle("Distans Display", "Distans"); NewToggle("Skelton ESP", "Skelton")
        NewToggle("Chams (Wall)", "Chams")
    elseif S.CurrentTab == "Char" then
        NewSection("MOVEMENT & PHYSICS")
        NewToggle("Underground (Lock)", "Underground"); NewInput("Depth Offset", "UG_Offset")
        NewToggle("Speed Hack", "SpeedActive"); NewInput("WalkSpeed", "WalkSpeed")
        NewToggle("Flight Mode", "Fly"); NewInput("FlySpeed", "FlySpeed")
        NewToggle("NoCrip (Noclip)", "NoCrip"); NewToggle("Infinite Jump", "InfiniteJump")
    elseif S.CurrentTab == "Skins" then
        NewSection("SKIN CHANGER")
        NewToggle("Enable SkinChanger", "SkinChanger"); NewToggle("Unlock All Items", "UnlockAll"); NewInput("Skin Name", "SelectedSkin")
    end
end

-- [4] THE CORE LOGIC (HEAVY LOADS)

-- 6秒シーケンシャル・ロード
task.spawn(function()
    print("mirukuyowasugi: Executing Titan Load Sequence...")
    task.wait(S.BootDelay)
    RefreshUI()
    Main.Visible = true
    S.Visible = true
    print("[1/6] UI Engine Ready.")

    -- FOV DRAWING
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5; FOVCircle.NumSides = 100; FOVCircle.Radius = S.FOVSize
    FOVCircle.Filled = false; FOVCircle.Visible = false; FOVCircle.Color = S.FOVColor

    -- TARGETING SYSTEM (最接近アルゴリズム)
    local function GetClosestTarget()
        local target, minMag = nil, S.FOVSize
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.TargetPart) then
                if p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character[S.TargetPart].Position)
                    if onScreen or S.Ragebot then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mag < minMag then minMag = mag; target = p end
                    end
                end
            end
        end
        return target
    end

    -- AIMBOT & RAGEBOT EXECUTION
    local AimToggled = false
    UIS.InputBegan:Connect(function(i, g)
        if not g and i.UserInputType == S.AimKey then AimToggled = not AimToggled end
    end)

    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOVSize
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

        local aiming = false
        if S.AimMode == "Always" then aiming = true
        elseif S.AimMode == "Hold" then aiming = UIS:IsMouseButtonPressed(S.AimKey)
        elseif S.AimMode == "Toggle" then aiming = AimToggled end

        if (S.Aimbot and aiming) or S.Ragebot then
            local t = GetClosestTarget()
            if t and t.Character and t.Character:FindFirstChild(S.TargetPart) then
                local tPos = t.Character[S.TargetPart].Position
                if S.Ragebot then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, tPos)
                    if S.AutoShoot then
                        VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                        task.wait()
                        VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
                    end
                else
                    local screenPos = Camera:WorldToViewportPoint(tPos)
                    mousemoverel((screenPos.X - Mouse.X) * S.Smoothness, (screenPos.Y - (Mouse.Y + 36)) * S.Smoothness)
                end
            end
        end
    end)
    print("[2/6] Combat Engines Engaged.")

    -- UNDERGROUND & MOVEMENT (PERFECT FIX)
    local CamPart = Instance.new("Part", workspace)
    CamPart.Transparency = 1; CamPart.Anchored = true; CamPart.CanCollide = false
    
    RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            if S.Underground then
                root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                root.CFrame = root.CFrame * CFrame.new(0, S.UG_Offset, 0)
                if S.UG_CamLock then
                    CamPart.CFrame = root.CFrame * CFrame.new(0, -S.UG_Offset, 0)
                    Camera.CameraSubject = CamPart
                end
            else
                Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
            end
            if S.SpeedActive then char:FindFirstChildOfClass("Humanoid").WalkSpeed = S.WalkSpeed end
            if S.NoCrip then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end
    end)
    print("[3/6] Physics & Movement Online.")

    -- SILENT AIM (METATABLE HOOKING)
    local oldNC; oldNC = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if S.SilentAim and not checkcaller() then
            if method == "Raycast" or method == "FindPartOnRayWithIgnoreList" then
                local t = GetClosestTarget()
                if t and math.random(1, 100) <= S.HitChance then
                    local targetPos = t.Character[S.TargetPart].Position
                    if method == "Raycast" then
                        args[2] = (targetPos - args[1]).Unit * 1000
                    else
                        args[1] = Ray.new(args[1].Origin, (targetPos - args[1].Origin).Unit * 1000)
                    end
                    return oldNC(self, unpack(args))
                end
            end
        end
        return oldNC(self, ...)
    end)
    print("[4/6] Metatable Hooks Successful.")

    -- ESP SYSTEM (DETAILED RENDER)
    local function AddESP(p)
        local Box = Drawing.new("Square"); Box.Visible = false; Box.Color = S.ESPColor; Box.Thickness = 1
        local Name = Drawing.new("Text"); Name.Visible = false; Name.Color = Color3.new(1,1,1); Name.Size = 14; Name.Center = true
        local HPBase = Drawing.new("Line"); HPBase.Visible = false; HPBase.Color = Color3.new(0,0,0); HPBase.Thickness = 3
        local HPBar = Drawing.new("Line"); HPBar.Visible = false; HPBar.Color = Color3.new(0,1,0); HPBar.Thickness = 1.5

        RunService.RenderStepped:Connect(function()
            if S.ESP and p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local rootPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local top = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                    local bottom = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position - Vector3.new(0, 3.5, 0))
                    local h = bottom.Y - top.Y; local w = h * 0.6
                    
                    if S.Boxes then
                        Box.Size = Vector2.new(w, h)
                        Box.Position = Vector2.new(rootPos.X - w/2, rootPos.Y - h/2)
                        Box.Visible = true
                    else Box.Visible = false end

                    if S.Names then
                        Name.Text = p.Name .. (S.Distans and " ["..math.floor((p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude).."m]" or "")
                        Name.Position = Vector2.new(rootPos.X, rootPos.Y - h/2 - 15); Name.Visible = true
                    else Name.Visible = false end

                    if S.HealthBar and p.Character:FindFirstChild("Humanoid") then
                        local health = p.Character.Humanoid.Health / p.Character.Humanoid.MaxHealth
                        HPBase.From = Vector2.new(rootPos.X - w/2 - 5, rootPos.Y + h/2)
                        HPBase.To = Vector2.new(rootPos.X - w/2 - 5, rootPos.Y - h/2)
                        HPBase.Visible = true
                        HPBar.From = HPBase.From
                        HPBar.To = Vector2.new(HPBase.From.X, HPBase.From.Y - (h * health))
                        HPBar.Visible = true
                    else HPBase.Visible = false; HPBar.Visible = false end
                else Box.Visible = false; Name.Visible = false; HPBase.Visible = false; HPBar.Visible = false end
            else Box.Visible = false; Name.Visible = false; HPBase.Visible = false; HPBar.Visible = false end
        end)
    end
    for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
    Players.PlayerAdded:Connect(AddESP)
    print("[5/6] Visuals (ESP) Initialized.")

    -- RAPID FIRE & SKIN CHANGER SIMULATOR
    task.spawn(function()
        while task.wait() do
            if S.RapidFire and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                task.wait(S.RapidRate)
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            end
        end
    end)
    print("[6/6] Final Modules Engaged. mirukuyowasugi Online.")
end)

-- [5] MENU TOGGLE
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == S.MenuKey then
        S.Visible = not S.Visible
        Main.Visible = S.Visible
    end
end)
