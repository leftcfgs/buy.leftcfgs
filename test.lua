-- [[ tested internal v11.0: THE GENESIS OVERLORD ]]
-- Rivals Universal Multi-Packet Annihilator
-- Developed for Paisen (Extreme Rage Environment)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NetworkClient = game:GetService("NetworkClient")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // GLOBAL ENGINE CONFIGURATION
getgenv().GenesisConfig = {
    Enabled = true,
    Method = "SkyMatcha", -- 真上テレポート偽装
    StackLimit = 150, -- 1クリックでの最大パケット数
    TeleportHeight = 600, -- さらに高く。ACの検知外へ
    PredictionValue = 6.5, -- 超高速移動対応
    HitPart = "Head",
    MagicBullet = true,
    InstantKill = true,
    SafetyCheck = false -- Ragebotなので安全策はオフ
}

-- // [ 武器・パケット・キャッシュ ]
local InternalCache = {
    Weapon = "Scanning...",
    LastTarget = "None",
    PacketCount = 0,
    TargetPos = Vector3.new(0,0,0)
}

-- // [ 全自動武器スキャン ]
local function ScanCurrentArsenal()
    local char = LocalPlayer.Character
    if not char then return "None" end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        InternalCache.Weapon = tool.Name
        return tool.Name
    end
    return "Searching..."
end

-- // [ 究極・全距離ターゲット追跡 ]
local function SeekAnnihilationTarget()
    local target = nil
    local minPriority = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- 距離と角度を無視。全マップから最も生存している敵を狙う
                    local distance = (root.Position - LocalPlayer.Character.Head.Position).Magnitude
                    if distance < minPriority then
                        target = p
                        minPriority = distance
                    end
                end
            end
        end
    end
    return target
end

-- // [[ THE CORE OVERRIDE - PACKET MANIPULATOR ]]
local oldHook
oldHook = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" and getgenv().GenesisConfig.Enabled then
        local rName = self.Name
        
        -- Rivalsで使用される可能性がある全てのパケット名を網羅
        if rName:find("Fire") or rName:find("Shoot") or rName:find("Throw") or rName:find("Hit") or 
           rName:find("Projectile") or rName:find("Attack") or rName:find("Damage") or rName:find("Bullet") then
            
            local t = SeekAnnihilationTarget()
            if t and t.Character:FindFirstChild("Head") then
                local head = t.Character.Head
                local root = t.Character.HumanoidRootPart
                
                -- [[ 抹茶式・天界からの粛清アドオン ]]
                task.spawn(function()
                    for i = 1, getgenv().GenesisConfig.StackLimit do
                        local ping = NetworkClient:GetPing()
                        -- 相手の爆速移動(Velocity)と自分のラグを計算
                        local movePred = root.Velocity * (ping + (i * 0.001)) * getgenv().GenesisConfig.PredictionValue
                        local finalTargetPos = head.Position + movePred
                        
                        -- 発射点を相手の真上に固定
                        local skyOrigin = finalTargetPos + Vector3.new(0, getgenv().GenesisConfig.TeleportHeight, 0)
                        
                        local spoofedArgs = table.clone(args)
                        for index, val in pairs(spoofArgs) do
                            -- 1. ベクトル情報の書き換え（垂直落下）
                            if typeof(val) == "Vector3" then
                                spoofedArgs[index] = (finalTargetPos - skyOrigin).Unit * 10000
                            end
                            -- 2. 発射位置(CFrame)の書き換え
                            if typeof(val) == "CFrame" then
                                spoofedArgs[index] = CFrame.new(skyOrigin, finalTargetPos)
                            end
                            -- 3. 当たり判定（Raycast/Impact）の完全捏造
                            if typeof(val) == "table" then
                                -- テーブル内のプロパティを全検索して書き換える
                                if val.Hit or val.Instance or val.Part or val.Position then
                                    val.Hit = head
                                    val.Instance = head
                                    val.Part = head
                                    val.Position = finalTargetPos
                                    val.Distance = getgenv().GenesisConfig.TeleportHeight
                                    val.Normal = Vector3.new(0, 1, 0)
                                end
                            end
                        end
                        
                        -- パケット連射
                        oldHook(self, unpack(spoofedArgs))
                        
                        -- サーバー保護キックを回避する超微細ウェイト
                        if i % 40 == 0 then RunService.Heartbeat:Wait() end
                    end
                end)
                
                -- オリジナルのパケットは無効化
                return nil
            end
        end
    end
    return oldHook(self, unpack(args))
end)

-- // UI CONSTRUCTION (PROFESSIONAL RAGE UI)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
title.Text = " GENESIS OVERLORD v11.0 "
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local log = Instance.new("TextLabel", frame)
log.Size = UDim2.new(1, -20, 1, -50)
log.Position = UDim2.new(0, 10, 0, 45)
log.BackgroundTransparency = 1
log.TextColor3 = Color3.fromRGB(0, 255, 150)
log.TextXAlignment = Enum.TextXAlignment.Left
log.TextYAlignment = Enum.TextYAlignment.Top
log.Font = Enum.Font.Code
log.TextSize = 12

-- // INFORMATION UPDATE LOOP
task.spawn(function()
    while task.wait(0.05) do
        local t = SeekAnnihilationTarget()
        ScanCurrentArsenal()
        log.Text = string.format([[
[ STATUS ] RUNNING - MAXIMUM RAGE
[ TARGET ] %s
[ WEAPON ] %s
[ METHOD ] %s
[ HEIGHT ] %d STUDS
[ STACK  ] %d x PACKETS
[ PING   ] %.2f MS
[ FPS    ] %d
-------------------------------
[ AC-BYPASS ] ENABLED (SKY)
[ MAGIC-B   ] ACTIVE
-------------------------------
GIVE THEM NO MERCY.
        ]], 
        (t and t.Name or "SEARCHING..."), 
        InternalCache.Weapon,
        getgenv().GenesisConfig.Method,
        getgenv().GenesisConfig.TeleportHeight,
        getgenv().GenesisConfig.StackLimit,
        NetworkClient:GetPing() * 1000,
        math.floor(1/RunService.RenderStepped:Wait()))
    end
end)

print("🌌 GENESIS OVERLORD v11.0 LOADED. THE ULTIMATE POWER IS YOURS.")
