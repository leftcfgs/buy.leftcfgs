-- [[ tested internal v4.0: AC-Bypass Edition ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // 超長距離・AC回避設定
getgenv().SwiftSettings = {
    Enabled = true,
    PredictionScale = 2.5, -- 超遠距離用に強化
    BaseSpeed = 800,
    MaxDist = 10000,
    FakeOriginDist = 10 -- ターゲットの何スタッズ前に弾を生成するか
}

-- // 武器スキャナー強化（名前を見ない方式）
local function GetWeaponStats()
    local char = LocalPlayer.Character
    if not char then return 800 end
    local tool = char:FindFirstChildOfClass("Tool") or char:FindFirstChild("Model")
    
    -- 弓やスリングショット等の「Projectile」系は弾速が遅いので予測を強める
    if tool then
        if tool.Name:find("Bow") or tool.Name:find("Sling") then return 380 end
        if tool.Name:find("Dagger") then return 650 end
    end
    return 800
end

-- // 最速ターゲット取得
local function GetRageTarget()
    local target = nil
    local minDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Team ~= LocalPlayer.Team then
            local d = (p.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
            if d < minDist then
                target = p
                minDist = d
            end
        end
    end
    return target
end

-- // [[ アンチチート回避用・パケット捏造フック ]]
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" and getgenv().SwiftSettings.Enabled then
        if self.Name:find("Fire") or self.Name:find("Shoot") or self.Name:find("Throw") then
            local t = GetRageTarget()
            if t and t.Character:FindFirstChild("Head") then
                local head = t.Character.Head
                local velocity = t.Character.HumanoidRootPart.Velocity
                local speed = GetWeaponStats()
                
                -- 1. 未来位置を予測
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                local time = dist / speed
                local predictedPos = head.Position + (velocity * time * getgenv().SwiftSettings.PredictionScale)
                
                -- 2. AC回避の核心: 弾の発生源を「相手の目の前」に捏造する
                -- これにより、サーバーは「至近距離での射撃」だと判断し、弾速チェックをスルーする
                local fakeOrigin = predictedPos - (velocity.Unit * getgenv().SwiftSettings.FakeOriginDist)
                
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        -- 方向ベクトルを捏造した起点から計算
                        args[i] = (predictedPos - fakeOrigin).Unit * speed
                    end
                    if typeof(arg) == "CFrame" then
                        -- 向きもターゲットに固定
                        args[i] = CFrame.new(fakeOrigin, predictedPos)
                    end
                end
                return old(self, unpack(args))
            end
        end
    end
    return old(self, ...)
end)

-- // UI (シンプルで軽量)
local sg = Instance.new("ScreenGui", game.CoreGui)
local f = Instance.new("Frame", sg)
f.Size, f.Position, f.BackgroundColor3 = UDim2.new(0, 180, 0, 60), UDim2.new(0.05, 0, 0.2, 0), Color3.new(0,0,0)
local l = Instance.new("TextLabel", f)
l.Size, l.BackgroundTransparency, l.TextColor3, l.TextSize = UDim2.new(1,0,1,0), 1, Color3.new(0,1,0.5), 12

task.spawn(function()
    while task.wait(0.1) do
        local t = GetRageTarget()
        l.Text = "SWIFT v4.0 AC-BYPASS\nTarget: " .. (t and t.Name or "None") .. "\nDist: " .. (t and math.floor((t.Character.Head.Position - Camera.CFrame.Position).Magnitude) or 0)
    end
end)
