-- [[ tested internal v3.2: Full Rage Projectile Engine ]]
-- Rivalsの武器システムを完全に支配するためのガチ構成だ。

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // グローバル設定（UEと競合しないようにUE風の構造に）
getgenv().SwiftSettings = {
    Enabled = true,
    TeamCheck = true,
    VisibleCheck = false, -- Ragebot前提なのでfalse
    TargetPart = "Head",
    PredictionScale = 1.65, -- 予測の強さ
    ProjectileSpeed = 800,
    DropAmount = 0.05, -- 弾道落下の補正値
    FovSize = 400
}

-- // 武器プロファイル（これがあるから重くなるが、正確になる）
local WeaponData = {
    ["Slingshot"] = {Speed = 430, Prediction = 1.35, Gravity = true},
    ["Recurve Bow"] = {Speed = 350, Prediction = 1.9, Gravity = true},
    ["Dagger"] = {Speed = 620, Prediction = 1.1, Gravity = false},
    ["Rocket Launcher"] = {Speed = 280, Prediction = 2.4, Gravity = false},
    ["Crossbow"] = {Speed = 500, Prediction = 1.5, Gravity = true},
    ["Firework Launcher"] = {Speed = 320, Prediction = 2.2, Gravity = false}
}

local CurrentWeapon = "Default"

-- // 高精度予測エンジン（心臓部）
local function CalculatePrediction(target)
    local char = target.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild(getgenv().SwiftSettings.TargetPart)
    
    if not root or not head then return nil end
    
    -- 弾速の取得
    local speed = getgenv().SwiftSettings.ProjectileSpeed
    local startPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")) and LocalPlayer.Character.Head.Position or Camera.CFrame.Position
    
    -- 距離と着弾時間の計算
    local distance = (head.Position - startPos).Magnitude
    local timeToHit = distance / speed
    
    -- [[ 未来予測ロジック ]]
    -- 相手の移動速度(Velocity)から座標を算出
    local vel = root.Velocity
    local predictedPos = head.Position + (vel * timeToHit * getgenv().SwiftSettings.PredictionScale)
    
    -- 重力加速度による弾道落下の計算 (G * t^2 / 2)
    if WeaponData[CurrentWeapon] and WeaponData[CurrentWeapon].Gravity then
        local gravity = workspace.Gravity * getgenv().SwiftSettings.DropAmount
        predictedPos = predictedPos + Vector3.new(0, (gravity * (timeToHit ^ 2)), 0)
    end
    
    -- 空中・ジャンプ時の追加補正
    if not (char.Humanoid:GetState() == Enum.HumanoidStateType.Running) then
        predictedPos = predictedPos + Vector3.new(0, 0.1, 0)
    end
    
    return predictedPos
end

-- // 武器スキャナー (Noneバグ対策版)
local function ScanWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        CurrentWeapon = tool.Name
    else
        -- 持ち替え中のモデル名を全スキャン
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Model") and WeaponData[v.Name] then
                CurrentWeapon = v.Name
                break
            end
        end
    end
    
    -- プロファイル適用
    local profile = WeaponData[CurrentWeapon] or {Speed = 850, Prediction = 1.5, Gravity = true}
    getgenv().SwiftSettings.ProjectileSpeed = profile.Speed
    getgenv().SwiftSettings.PredictionScale = profile.Prediction
end

-- // ターゲット検索 (Ragebot用)
local function GetBestTarget()
    local target = nil
    local dist = getgenv().SwiftSettings.FovSize
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health <= 0 then continue end
            if getgenv().SwiftSettings.TeamCheck and p.Team == LocalPlayer.Team then continue end
            
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then
                    target = p
                    dist = mag
                end
            end
        end
    end
    return target
end

-- // 通信オーバーライド (FireServer Hook)
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if getgenv().SwiftSettings.Enabled and not checkcaller() and method == "FireServer" then
        if self.Name:find("Shoot") or self.Name:find("Fire") or self.Name:find("Throw") then
            local t = GetBestTarget()
            if t then
                local pred = CalculatePrediction(t)
                local start = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")) and LocalPlayer.Character.Head.Position or Camera.CFrame.Position
                
                if pred then
                    for i, arg in pairs(args) do
                        if typeof(arg) == "Vector3" then
                            args[i] = (pred - start).Unit * getgenv().SwiftSettings.ProjectileSpeed * 10
                        end
                        if typeof(arg) == "CFrame" then
                            args[i] = CFrame.new(start, pred)
                        end
                    end
                    return old(self, unpack(args))
                end
            end
        end
    end
    return old(self, ...)
end)

-- // UI構築 (Delta対応・高機能版)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 130)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "tested internal | RAGE v3.2"
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.new(1, 1, 1)

local Log = Instance.new("TextLabel", Frame)
Log.Size = UDim2.new(1, -10, 1, -40)
Log.Position = UDim2.new(0, 5, 0, 35)
Log.BackgroundTransparency = 1
Log.TextColor3 = Color3.new(0.8, 0.8, 0.8)
Log.TextXAlignment = Enum.TextXAlignment.Left
Log.TextYAlignment = Enum.TextYAlignment.Top
Log.TextSize = 12

-- // メインループ
task.spawn(function()
    while task.wait(0.2) do
        ScanWeapon()
        local t = GetBestTarget()
        Log.Text = string.format(
            "Weapon: %s\nSpeed: %d\nTarget: %s\nStatus: %s",
            CurrentWeapon,
            getgenv().SwiftSettings.ProjectileSpeed,
            t and t.Name or "Searching...",
            getgenv().SwiftSettings.Enabled and "READY" or "OFF"
        )
    end
end)

print("🌌 Full Specification Rage-Master Loaded. Destroy them, Paisen.")
