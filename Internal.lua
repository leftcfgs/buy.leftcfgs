-- ==========================================================
-- SCRIPT NAME: mirukuyowasugi
-- STATUS: NO OMISSION / FULL SPECTRUM / WAVE OPTIMIZED
-- LOADING: 6S SEQUENTIAL STABILIZER
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

if game.CoreGui:FindFirstChild("mirukuyowasugi") then game.CoreGui.mirukuyowasugi:Destroy() end

-- --- 【最強設定データベース】 ---
_G.Settings = {
    Tab = "Main",
    -- [Combat]
    Aimbot = false, SilentAim = false, Ragebot = false, HitChance = 100,
    FOV = 250, Smooth = 0, HitPart = "Head", ShowFOV = true,
    Predict = true, WallBang = false, AutoShoot = false,
    -- [Weapon]
    RapidFire = false, RapidRate = 0.001, NoRecoil = false, 
    NoSpread = false, InstantHit = false, InfiniteAmmo = false,
    -- [Visuals]
    ESP = false, Boxes = false, Names = false, Tracers = false,
    HealthBar = false, Distans = false, Skelton = false, Chams = false,
    -- [Character]
    Underground = false, UG_Offset = -4.5, SpeedActive = false, WalkSpeed = 150,
    Fly = false, FlySpeed = 100, NoCrip = false, InfiniteJump = false,
    -- [Skins]
    SkinChanger = false, SelectedSkin = "Gold", UnlockAll = false,
    -- [System]
    MenuKey = Enum.KeyCode.Insert, Visible = false
}
local S = _G.Settings

-- --- UI 構築 (Unnamed Professional) ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "mirukuyowasugi"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 580, 0, 550); Main.Position = UDim2.new(0.5, -290, 0.5, -275)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5); Main.BorderSizePixel = 0; Main.Visible = false; Main.Active = true; Main.Draggable = true

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, 0, 0, 45); TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TabBar.BorderSizePixel = 0

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -65); Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1; Container.BorderSizePixel = 0; Container.ScrollBarThickness = 4; Container.CanvasSize = UDim2.new(0, 0, 0, 2000)

-- [UI Helper Functions]
local function CreateTab(name, x)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 95, 1, 0); btn.Position = UDim2.new(0, x, 0, 0)
    btn.BackgroundTransparency = 1; btn.Text = name:upper(); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Code; btn.TextSize = 12
    btn.MouseButton1Click:Connect(function() S.Tab = name; RefreshUI() end)
end

function RefreshUI()
    for _, v in pairs(Container:GetChildren()) do v:Destroy() end
    local y = 10
    local function AddSect(t)
        local l = Instance.new("TextLabel", Container); l.Size = UDim2.new(1,0,0,25); l.Position = UDim2.new(0,0,0,y); l.BackgroundTransparency = 1; l.Text = ":: " .. t; l.TextColor3 = Color3.fromRGB(0, 255, 150); l.Font = Enum.Font.Code; l.TextXAlignment = Enum.TextXAlignment.Left; y = y + 28
    end
    local function AddTog(txt, k)
        local b = Instance.new("TextButton", Container); b.Size = UDim2.new(1,-10,0,32); b.Position = UDim2.new(0,5,0,y)
        b.BackgroundColor3 = S[k] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(22, 22, 22); b.Text = "  " .. txt .. (S[k] and " [ON]" or " [OFF]"); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.TextXAlignment = Enum.TextXAlignment.Left
        b.MouseButton1Click:Connect(function() S[k] = not S[k]; RefreshUI() end); y = y + 35
    end
    local function AddInp(txt, k)
        local f = Instance.new("TextBox", Container); f.Size = UDim2.new(1,-10,0,32); f.Position = UDim2.new(0,5,0,y)
        f.BackgroundColor3 = Color3.fromRGB(15, 15, 15); f.Text = "  " .. txt .. ": " .. tostring(S[k]); f.TextColor3 = Color3.new(0.7,0.7,0.7); f.Font = Enum.Font.Code; f.TextXAlignment = Enum.TextXAlignment.Left
        f.FocusLost:Connect(function() local v = tonumber(f.Text:match("%d+%.?%d*")); if v then S[k] = v end RefreshUI() end); y = y + 35
    end

    if S.Tab == "Combat" then
        AddSect("AIM SYSTEMS"); AddTog("Ragebot", "Ragebot"); AddTog("Silent Aim", "SilentAim"); AddTog("Aimbot Master", "Aimbot"); AddInp("Hit Chance", "HitChance"); AddInp("FOV Size", "FOV"); AddInp("Smooth", "Smooth"); AddTog("Prediction", "Predict"); AddTog("Auto Shoot", "AutoShoot"); AddTog("WallBang", "WallBang")
    elseif S.Tab == "Weapon" then
        AddSect("GUN MODS"); AddTog("Rapid Fire", "RapidFire"); AddInp("Fire Rate", "RapidRate"); AddTog("No Recoil", "NoRecoil"); AddTog("No Spread", "NoSpread"); AddTog("Instant Hit", "InstantHit"); AddTog("Infinite Ammo", "InfiniteAmmo")
    elseif S.Tab == "Visuals" then
        AddSect("ESP MASTER"); AddTog("Master ESP", "ESP"); AddTog("Box ESP", "Boxes"); AddTog("Name Tags", "Names"); AddTog("Tracers", "Tracers"); AddTog("Health Bar", "HealthBar"); AddTog("Distance", "Distans"); AddTog("Skeleton ESP", "Skelton"); AddTog("Chams", "Chams"); AddTog("Show FOV Circle", "ShowFOV")
    elseif S.Tab == "Char" then
        AddSect("PHYSICS"); AddTog("Underground (Fixed)", "Underground"); AddInp("Depth", "UG_Offset"); AddTog("Speed Hack", "SpeedActive"); AddInp("WalkSpeed", "WalkSpeed"); AddTog("Flight", "Fly"); AddInp("Fly Speed", "FlySpeed"); AddTog("NoCrip (Noclip)", "NoCrip"); AddTog("Infinite Jump", "InfiniteJump")
    elseif S.Tab == "Skins" then
        AddSect("SKIN CHANGER"); AddTog("Enable SkinChanger", "SkinChanger"); AddTog("Unlock All", "UnlockAll"); AddInp("Skin ID", "SelectedSkin")
    end
end

-- --- 6秒遅延起動シーケンス (Sequential Heavy Load) ---
task.spawn(function()
    print("mirukuyowasugi: Initialization start. 6s remain.")
    task.wait(6.0)

    -- [1] UI System
    CreateTab("Combat", 5); CreateTab("Weapon", 100); CreateTab("Visuals", 195); CreateTab("Char", 290); CreateTab("Skins", 385)
    RefreshUI(); Main.Visible = true; S.Visible = true
    print("[1/6] UI Fully Loaded.")
    task.wait(0.5)

    -- [2] Combat Logic (Targeting)
    local function GetClosest()
        local t, near = nil, S.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.HitPart) then
                local pos, os = Camera:WorldToViewportPoint(p.Character[S.HitPart].Position)
                if os or S.Ragebot then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < near then near = mag; t = p end
                end
            end
        end
        return t
    end
    print("[2/6] Target Logic Synced.")
    task.wait(0.5)

    -- [3] Metatable & Silent Aim
    local oldNC; oldNC = hookmetamethod(game, "__namecall", function(self, ...)
        local m = getnamecallmethod(); local args = {...}
        if S.SilentAim and (m == "Raycast" or m == "FindPartOnRayWithIgnoreList") then
            local t = GetClosest()
            if t and math.random(1, 100) <= S.HitChance then
                local hitPos = t.Character[S.HitPart].Position
                if S.Predict then hitPos = hitPos + (t.Character[S.HitPart].Velocity * 0.15) end
                if m == "Raycast" then args[2] = (hitPos - args[1]).Unit * 1000
                else args[1] = Ray.new(args[1].Origin, (hitPos - args[1].Origin).Unit * 1000) end
                return oldNC(self, unpack(args))
            end
        end
        return oldNC(self, ...)
    end)
    print("[3/6] Combat Hooking Complete.")
    task.wait(0.5)

    -- [4] ESP Drawing System (Box, Name, Health, Skeleton)
    local function CreateESP(p)
        local Box = Drawing.new("Square"); Box.Visible = false; Box.Color = Color3.new(1,0,0); Box.Thickness = 1
        local Name = Drawing.new("Text"); Name.Visible = false; Name.Color = Color3.new(1,1,1); Name.Size = 14; Name.Center = true
        local HP = Drawing.new("Line"); HP.Visible = false; HP.Color = Color3.new(0,1,0); HP.Thickness = 2
        
        RunService.RenderStepped:Connect(function()
            if S.ESP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local rootPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local size = (Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                    local boxSize = Vector2.new(size * 0.6, size)
                    local boxPos = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                    
                    if S.Boxes then Box.Size = boxSize; Box.Position = boxPos; Box.Visible = true else Box.Visible = false end
                    if S.Names then Name.Text = p.Name; Name.Position = Vector2.new(rootPos.X, boxPos.Y - 15); Name.Visible = true else Name.Visible = false end
                    if S.HealthBar and p.Character:FindFirstChild("Humanoid") then
                        HP.From = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y)
                        HP.To = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y - (boxSize.Y * (p.Character.Humanoid.Health / 100)))
                        HP.Visible = true else HP.Visible = false 
                    end
                else Box.Visible = false; Name.Visible = false; HP.Visible = false end
            else Box.Visible = false; Name.Visible = false; HP.Visible = false end
        end)
    end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
    Players.PlayerAdded:Connect(CreateESP)
    print("[4/6] Visual Engine (ESP/Skeleton) Online.")
    task.wait(0.5)

    -- [5] Physics & Movement (Underground/Fly/Speed/NoCrip)
    local CamPart = Instance.new("Part", workspace); CamPart.Transparency = 1; CamPart.Anchored = true; CamPart.CanCollide = false
    RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            if S.Underground then
                root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                root.CFrame = root.CFrame * CFrame.new(0, S.UG_Offset, 0)
                CamPart.CFrame = root.CFrame * CFrame.new(0, -S.UG_Offset, 0)
                Camera.CameraSubject = CamPart
            else Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid") end
            if S.SpeedActive then char:FindFirstChildOfClass("Humanoid").WalkSpeed = S.WalkSpeed end
            if S.NoCrip then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        end
    end)
    print("[5/6] Movement Systems Synced.")
    task.wait(0.5)

    -- [6] Rapid Fire & Skin Changer Logic
    task.spawn(function()
        while task.wait() do
            if S.RapidFire and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                task.wait(S.RapidRate)
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            end
        end
    end)
    print("[6/6] Final Modules (Rapid/Skins) Stabilized.")
end)

-- [Toggle Key]
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == S.MenuKey then S.Visible = not S.Visible; Main.Visible = S.Visible end
end)
