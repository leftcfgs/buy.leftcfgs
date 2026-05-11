-- [[ tested internal v10.0: THE SKY-STRIKER (Universal Edition) ]]
-- 弓・ダガー・銃、全ての武器に対応した「真上テレポート」必中スクリプト。

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().SkyStriker = {
    Enabled = true,
    Height = 400, -- 相手の400スタッズ上に発射点を捏造
    Stack = 80, -- 連射数（武器を選ばず一瞬で溶かす）
    Method = "Global_Sync",
    AutoTarget = true
}

-- // 全マップ対応・ターゲット取得
local function GetAnnihilationTarget()
    local target = nil
    local shortestDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- 距離に関係なく、最も近い敵をロックオン
                    local d = (root.Position - LocalPlayer.Character.Head.Position).Magnitude
                    if d < shortestDist then
                        target = p
                        shortestDist = d
                    end
                end
            end
        end
    end
    return target
end

-- // [[ SKY-STRIKE HOOK SYSTEM ]]
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" and getgenv().SkyStriker.Enabled then
        local remote = self.Name
        -- 射撃・投擲・ヒット判定、全ての通信をキャッチ
        if remote:find("Fire") or remote:find("Shoot") or remote:find("Throw") or remote:find("Hit") or remote:find("Projectile") then
            local t = GetAnnihilationTarget()
            if t and t.Character:FindFirstChild("Head") then
                local head = t.Character.Head
                local targetPos = head.Position
                
                -- [[ 抹茶（Matcha）式・垂直落下ボム ]]
                task.spawn(function()
                    for i = 1, getgenv().SkyStriker.Stack do
                        local spoofArgs = table.clone(args)
                        -- 相手の真上から弾を生成
                        local skyPos = targetPos + Vector3.new(0, getgenv().SkyStriker.Height, 0)
                        
                        for idx, val in pairs(spoofArgs) do
                            -- ベクトルを「真下への超高速」に固定
                            if typeof(val) == "Vector3" then
                                spoofArgs[idx] = Vector3.new(0, -1000, 0)
                            end
                            -- 発射位置を天界にセット
                            if typeof(val) == "CFrame" then
                                spoofArgs[idx] = CFrame.new(skyPos, targetPos)
                            end
                            -- 判定データのテーブルがあれば「頭」に強制ヒット
                            if typeof(val) == "table" then
                                val.Hit = head
                                val.Instance = head
                                val.Part = head
                                val.Position = targetPos
                                val.Distance = getgenv().SkyStriker.Height
                            end
                        end
                        
                        -- 改竄パケット射出
                        oldNamecall(self, unpack(spoofArgs))
                        
                        -- 連射キック対策（30発おきに微休止）
                        if i % 30 == 0 then RunService.Heartbeat:Wait() end
                    end
                end)
                
                -- オリジナルのパケット（外れる可能性があるやつ）を消去
                return nil
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- // UI: SKY-STRIKER MONITOR
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local f = Instance.new("Frame", sg)
f.Size, f.Position, f.BackgroundColor3 = UDim2.new(0, 240, 0, 110), UDim2.new(0.05, 0, 0.4, 0), Color3.new(0,0,0)
local l = Instance.new("TextLabel", f)
l.Size, l.BackgroundTransparency, l.TextColor3, l.TextSize = UDim2.new(1,0,1,0), 1, Color3.new(0.5, 1, 0), 13

task.spawn(function()
    while task.wait(0.1) do
        local t = GetAnnihilationTarget()
        l.Text = string.format([[
  [ tested internal v10.0 ]
  -------------------------
  TARGET: %s
  DIST  : %d
  MODE  : SKY-TELEPORT
  STACK : %dx PER CLICK
  STATUS: DESTROYING...
  -------------------------
        ]], (t and t.Name or "NONE"), (t and (t.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude or 0), getgenv().SkyStriker.Stack)
    end
end)

print("🚀 SKY-STRIKER v10.0 LOADED. Universal Domination Start.")
