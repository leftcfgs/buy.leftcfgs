-- ==========================================================
-- UNNAMED GOD-TIER | OVERLOAD EDITION
-- WARNING: HIGH RISK / HIGH PERFORMANCE
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
if game.CoreGui:FindFirstChild("UnnamedOverload") then game.CoreGui.UnnamedOverload:Destroy() end

-- --- 設定 ---
_G.Settings = {
    Tab = "Main",
    -- Aim
    SilentAim = false, HitChance = 100, HitPart = "Head", FOV = 200,
    -- Weapon
    RapidFire = false, InstantHit = false,
    -- Character
    Underground = false, UG_Offset = -3.5, WalkSpeed = 100, SpeedActive = false,
    -- System
    MenuKey = Enum.KeyCode.Insert
}
local S = _G.Settings

-- --- UI構築 (Unnamed Clone) ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "UnnamedOverload"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 520, 0, 420); Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, 0, 0, 40); TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabBar.BorderSizePixel = 0

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60); Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1; Container.BorderSizePixel = 0; Container.ScrollBarThickness = 2

local function CreateTab(name, x)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 90, 1, 0); btn.Position = UDim2.new(0, x, 0, 0)
    btn.BackgroundTransparency = 1; btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Code; btn.TextSize = 14
    btn.MouseButton1Click:Connect(function() S.Tab = name; RefreshUI() end)
end

CreateTab("Main", 10); CreateTab("Visuals", 110); CreateTab("Misc", 210); CreateTab("Settings", 310)

function RefreshUI()
    for _, v in pairs(Container:GetChildren()) do v:Destroy() end
    local y = 10
    local function AddTog(txt, key)
        local b = Instance.new("TextButton", Container); b.Size = UDim2.new(1,0,0,32); b.Position = UDim2.new(0,0,0,y)
        b.BackgroundColor3 = S[key] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(25, 25, 25)
        b.Text = " " .. txt .. " [" .. (S[key] and "ON" or "OFF") .. "]"; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.TextSize = 13
        b.MouseButton1Click:Connect(function() S[key] = not S[key]; RefreshUI() end); y = y + 36
    end
    local function AddInp(txt, key)
        local f = Instance.new("TextBox", Container); f.Size = UDim2.new(1,0,0,32); f.Position = UDim2.new(0,0,0,y)
        f.BackgroundColor3 = Color3.fromRGB(20, 20, 20); f.Text = txt .. ": " .. tostring(S[key]); f.TextColor3 = Color3.new(0.8,0.8,0.8); f.Font = Enum.Font.Code
        f.FocusLost:Connect(function() local v = tonumber(f.Text:match("%d+")); if v then S[key] = v end RefreshUI() end); y = y + 36
    end

    if S.Tab == "Main" then
        AddTog("Silent Aim (Metatable Hook)", "SilentAim")
        AddInp("Hit Chance", "HitChance")
        AddTog("Rapid Fire (Engine Overload)", "RapidFire")
    elseif S.Tab == "Misc" then
        AddTog("Underground (Perfect Fixed)", "Underground")
        AddTog("Speed Hack", "SpeedActive")
        AddInp("WalkSpeed Value", "WalkSpeed")
    end
end
RefreshUI()

-- --- 核心機能：Silent Aim (ガチ勢仕様) ---
local function GetClosestPlayer()
    local target, nearest = nil, S.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.HitPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character[S.HitPart].Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < nearest then nearest = dist; target = p end
            end
        end
    end
    return target
end

local oldNC
oldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if S.SilentAim and method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
        local t = GetClosestPlayer()
        if t and math.random(1, 100) <= S.HitChance then
            -- 弾丸のレイを敵のHitPartへ強制書き換え
            if method == "Raycast" then
                args[2] = (t.Character[S.HitPart].Position - args[1]).Unit * 1000
            else
                args[1] = Ray.new(args[1].Origin, (t.Character[S.HitPart].Position - args[1].Origin).Unit * 1000)
            end
        end
    end
    return oldNC(self, unpack(args))
end)

-- --- 核心機能：Underground (完全地上固定) ---
local CamPart = Instance.new("Part", workspace)
CamPart.Transparency = 1; CamPart.Anchored = true; CamPart.CanCollide = false
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if S.Underground then
        root.Velocity = Vector3.new(0, 0, 0)
        root.CFrame = root.CFrame * CFrame.new(0, S.UG_Offset, 0)
        -- カメラを地上の元の高さに維持
        CamPart.CFrame = root.CFrame * CFrame.new(0, -S.UG_Offset, 0)
        Camera.CameraSubject = CamPart
    else
        Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
    end
end)

-- --- 核心機能：Rapid Fire ---
RunService.Heartbeat:Connect(function()
    if S.RapidFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        -- 物理的なクリック入力をバイパスして発射判定をループさせる
        -- (この部分はゲームごとのRemoteイベント発火に書き換えるとさらに最強になる)
        for i = 1, 5 do -- 1フレームに5回発射命令
            task.spawn(function()
                -- マウスクリックの擬似信号
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            end)
        end
    end
    if S.SpeedActive and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = S.WalkSpeed
    end
end)

-- メニュー開閉
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == S.MenuKey then Main.Visible = not Main.Visible end
end)
