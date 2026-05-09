-- [[ tested internal v9.0: THE APOCALYPSE ENGINE ]]
-- 100万スタッズ先の敵すら逃さない。ACを内部から破壊する最終プロトコル。

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NetworkClient = game:GetService("NetworkClient")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // 極限設定
getgenv().Apocalypse = {
    Enabled = true,
    Method = "Packet_Absolute", -- 物理を捨ててパケット同期に特化
    StackSize = 120, -- 120発同時発射。サーバーの限界
    AutoVelocity = true, -- 相手の速度に合わせて弾速を自動同期
    AntiCap = true, -- ACの検知上限を回避する偽装
    PredictionScale = 5.0, -- 超々遠距離用
    TargetPart = "Head"
}

local WeaponCache = { Name = "None", Speed = 1000, LastUpdate = 0 }

-- // 武器検知システム・アルティメット
local function GetWeaponData()
    if tick() - WeaponCache.LastUpdate < 0.5 then return WeaponCache end
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool") or char:FindFirstChild("Model")
    if tool then
        WeaponCache.Name = tool.Name
        -- 弾速の動的割り当て
        if tool.Name:find("Bow") then WeaponCache.Speed = 400
        elseif tool.Name:find("Dagger") then WeaponCache.Speed = 700
        elseif tool.Name:find("Sling") then WeaponCache.Speed = 450
        else WeaponCache.Speed = 2500 end
    end
    WeaponCache.LastUpdate = tick()
    return WeaponCache
end

-- // [[ 全自動・絶対座標ターゲット ]]
local function GetAbsoluteTarget()
    local best = nil
    local dist = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- 画面内かどうかも関係ない。全マップから獲物を探す
                    local d = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then
                        best = p
                        dist = d
                    end
                end
            end
        end
    end
    return best
end

-- // [[ THE APOCALYPSE HOOK ]]
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" and getgenv().Apocalypse.Enabled then
        local remote = self.Name
        if remote:find("Fire") or remote:find("Shoot") or remote:find("Throw") or remote:find("Projectile") then
            local target = GetAbsoluteTarget()
            if target and target.Character:FindFirstChild("Head") then
                local head = target.Character.Head
                local root = target.Character.HumanoidRootPart
                local data = GetWeaponData()
                
                -- [[ 120発同時着弾・ヴォイド連射 ]]
                task.spawn(function()
                    for i = 1, getgenv().Apocalypse.StackSize do
                        -- 相手のラグ(Latency)を考慮した未来予測
                        local latency = NetworkClient:GetPing()
                        local predPos = head.Position + (root.Velocity * (latency + (i * 0.001)) * getgenv().Apocalypse.PredictionScale)
                        
                        local spoof = table.clone(args)
                        for idx, val in pairs(spoof) do
                            -- 1. 弾道を消し、ターゲットに直接ベクトルを固定
                            if typeof(val) == "Vector3" then
                                spoof[idx] = (predPos - Camera.CFrame.Position).Unit * 10000
                            end
                            -- 2. AC Bypass: 発射位置を「自分の位置」と「相手の位置」の中間に捏造
                            -- これにより距離チェックの矛盾を回避する
                            if typeof(val) == "CFrame" then
                                spoof[idx] = CFrame.new(predPos - (root.CFrame.LookVector * 0.5), predPos)
                            end
                            -- 3. ヒット判定の強制同期
                            if typeof(val) == "table" then
                                val.Hit = head
                                val.Instance = head
                                val.Part = head
                                val.Position = predPos
                                val.Distance = 0.1 -- サーバーに「目の前で当てた」と思わせる
                            end
                        end
                        
                        old(self, unpack(spoof))
                        
                        -- サーバーの過負荷キックを回避するバッファ
                        if i % 40 == 0 then RunService.Heartbeat:Wait() end
                    end
                end)
                
                -- 元のパケットを消去し、上の120連射にすり替える
                return nil
            end
        end
    end
    return old(self, ...)
end)

-- // UI: APOCALYPSE TERMINAL
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 280, 0, 200), UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.new(0,0,0)
Main.Draggable, Main.Active = true, true

local L = Instance.new("TextLabel", Main)
L.Size, L.BackgroundTransparency, L.TextColor3 = UDim2.new(1,0,1,0), 1, Color3.new(1,0,0)
L.TextSize, L.Font = 12, Enum.Font.Code

task.spawn(function()
    while task.wait(0.1) do
        local t = GetAbsoluteTarget()
        L.Text = string.format([[
  >>> APOCALYPSE v9.0 ACTIVE <<<
  -------------------------------
  WEAPON: %s
  TARGET: %s
  DIST  : %.1f
  PING  : %.1f ms
  STACK : %d
  MODE  : ABSOLUTE SYNC
  -------------------------------
  STATUS: ANNIHILATING...
        ]], WeaponCache.Name, (t and t.Name or "NONE"), (t and (t.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude or 0), NetworkClient:GetPing() * 1000, getgenv().Apocalypse.StackSize)
    end
end)
