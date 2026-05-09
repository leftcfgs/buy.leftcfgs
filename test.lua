-- [[ tested internal: Rage-Master Engine for Rivals ]]
-- UI & Core Settings
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

getgenv().SwiftConfig = {
    Enabled = true,
    Prediction = true,
    VelocityMult = 1.5, -- 予測の強さ
    HitChance = 100,
    ProjectileSpeed = 850, -- 武器ごとの平均速度
    TargetPart = "Head",
    IgnoreTeam = true
}

-- // 高精度ターゲット予測システム
local function GetPredictedPosition(target)
    local character = target.Character
    local root = character:FindFirstChild("HumanoidRootPart")
    local targetPart = character:FindFirstChild(getgenv().SwiftConfig.TargetPart)
    
    if not root or not targetPart then return nil end
    
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Camera.CFrame.Position
    local distance = (targetPart.Position - myPos).Magnitude
    local timeToHit = distance / getgenv().SwiftConfig.ProjectileSpeed
    
    -- 相手の速度(Velocity)から未来の座標を計算
    local predictedPos = targetPart.Position + (root.Velocity * timeToHit * getgenv().SwiftConfig.VelocityMult)
    
    -- 重力補正 (Drop Correction)
    local drop = 0.5 * workspace.Gravity * (timeToHit ^ 2)
    return predictedPos + Vector3.new(0, drop, 0)
end

-- // 最速ターゲット検索
local function GetRageTarget()
    local closest = nil
    local shortestMouseDist = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if getgenv().SwiftConfig.IgnoreTeam and player.Team == LocalPlayer.Team then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mouseDist < shortestMouseDist then
                    closest = player
                    shortestMouseDist = mouseDist
                end
            end
        end
    end
    return closest
end
-- // Part 2: Deep Packet Manipulation & Void Stabilization
local Network = nil
-- Rivalsの通信モジュールを特定（武器発射イベントの取得）
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") and (v.Name:find("Fire") or v.Name:find("Shoot")) then
        Network = v
    end
end

-- [[ 弾道シミュレーション・オーバーライド ]]
local function BulletVelocityCalc(targetPos, startPos)
    local direction = targetPos - startPos
    local distance = direction.Magnitude
    -- 重力を無視させるための初速ブースト（Projectile Swiftの真髄）
    return direction.Unit * getgenv().SwiftConfig.ProjectileSpeed * 10
end

-- // __namecall フックの再構築（最優先割り込み）
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- 自分のスクリプト以外からの通信を全て監視
    if not checkcaller() and method == "FireServer" then
        local remoteName = self.Name
        
        -- 弓、ダガー、スリングショット、さらにはランチャー系の通信を検知
        if remoteName:find("Shoot") or remoteName:find("Fire") or remoteName:find("Throw") or remoteName:find("Projectile") then
            local target = GetRageTarget()
            
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local predictedPos = GetPredictedPosition(target)
                
                if predictedPos then
                    -- [[ Void Orbit 補正 ]]
                    -- 自分がどれだけ回転していても、発射起点を「頭」に固定し、ベクトルを未来位置へ向ける
                    local startPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")) and LocalPlayer.Character.Head.Position or Camera.CFrame.Position
                    
                    for i, arg in pairs(args) do
                        -- ベクトル引数（方向）を見つけて書き換え
                        if typeof(arg) == "Vector3" then
                            args[i] = BulletVelocityCalc(predictedPos, startPos)
                        end
                        -- CFrame引数（向き）を見つけて書き換え
                        if typeof(arg) == "CFrame" then
                            args[i] = CFrame.new(startPos, predictedPos)
                        end
                        -- Raycast結果が含まれる場合の補正
                        if typeof(arg) == "table" and arg.Hit then
                            arg.Hit = target.Character.Head
                            arg.Pos = predictedPos
                        end
                    end
                    
                    -- 書き換えたパケットを送信
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- // アンチ・バンプ（Void中のガクつきによる誤射防止）
RunService.Heartbeat:Connect(function()
    if getgenv().SwiftConfig.Enabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false -- 衝突判定を消してVoid中の弾きを防止
            end
        end
    end
end)

print("🎯 Part 2: Packet Interceptor & Void Stabilizer Active.")
-- // Part 3: Weapon Auto-Scanner & Final UI Integration
local CurrentWeapon = "None"

-- 武器ごとの詳細プロファイル（弾速・予測強度）
local WeaponProfiles = {
    ["Slingshot"] = {Speed = 450, Prediction = 1.2, Gravity = true},
    ["Bow"] = {Speed = 380, Prediction = 1.8, Gravity = true},
    ["Dagger"] = {Speed = 600, Prediction = 1.0, Gravity = false},
    ["RPG"] = {Speed = 300, Prediction = 2.5, Gravity = false},
    ["Default"] = {Speed = 850, Prediction = 1.5, Gravity = true}
}

-- [[ 武器スキャン・ループ ]]
task.spawn(function()
    while task.wait(0.5) do
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                CurrentWeapon = tool.Name
                local profile = WeaponProfiles[CurrentWeapon] or WeaponProfiles["Default"]
                getgenv().SwiftConfig.ProjectileSpeed = profile.Speed
                getgenv().SwiftConfig.VelocityMult = profile.Prediction
            end
        end
    end
end)

-- [[ 最終UI構築 (Delta / PC 両対応) ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
local Title = Instance.new("TextLabel", MainFrame)
local Toggle = Instance.new("TextButton", MainFrame)
local Info = Instance.new("TextLabel", MainFrame)

MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0) -- 他のUIと被らない位置
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)

Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "tested internal v3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

Toggle.Size = UDim2.new(0.9, 0, 0, 35)
Toggle.Position = UDim2.new(0.05, 0, 0.35, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Toggle.Text = "Projectile Swift: ON"
Toggle.TextColor3 = Color3.fromRGB(0, 255, 150)
Toggle.Font = Enum.Font.Gotham
Toggle.TextSize = 14

Info.Size = UDim2.new(1, 0, 0, 25)
Info.Position = UDim2.new(0, 0, 0.75, 0)
Info.Text = "Detecting Weapon..."
Info.TextColor3 = Color3.fromRGB(180, 180, 180)
Info.BackgroundTransparency = 1
Info.TextSize = 10

Toggle.MouseButton1Click:Connect(function()
    getgenv().SwiftConfig.Enabled = not getgenv().SwiftConfig.Enabled
    Toggle.Text = getgenv().SwiftConfig.Enabled and "Projectile Swift: ON" or "Projectile Swift: OFF"
    Toggle.TextColor3 = getgenv().SwiftConfig.Enabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 80, 80)
end)

-- 情報更新ループ
task.spawn(function()
    while task.wait(0.1) do
        Info.Text = "Weapon: " .. CurrentWeapon .. " | Dist: " .. (GetRageTarget() and math.floor((GetRageTarget().Character.Head.Position - Camera.CFrame.Position).Magnitude) or 0) .. "s"
    end
end)

print("🌌 [tested internal] ALL SYSTEMS GO. Rage-Master v3 Activated.")
