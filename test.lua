-- [[ tested internal: Void & Rage Projectile Engine ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().SwiftEnabled = true -- 最初からONに設定

-- 最も近い敵を自動ロック（Rage用）
local function GetRageTarget()
    local closest = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Team ~= LocalPlayer.Team then
            local d = (v.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
            if d < dist then
                closest = v
                dist = d
            end
        end
    end
    return closest
end

-- // Rage-Void Packet Hook
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if getgenv().SwiftEnabled and method == "FireServer" and not checkcaller() then
        -- Rivalsの全ての遠距離攻撃リモートを網羅
        if self.Name:find("Shoot") or self.Name:find("Fire") or self.Name:find("Throw") or self.Name:find("Projectile") then
            local t = GetRageTarget()
            if t and t.Character then
                local head = t.Character.Head
                
                -- [[ Void-Hit Logic ]]
                -- 自分の現在位置(Void中)を無視し、ターゲットの頭に直接弾を生成する
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        -- 方向ベクトルを「ターゲットの目の前」に固定
                        args[i] = (head.Position - (head.Position + Vector3.new(0, 0.1, 0))).Unit * 10000
                    end
                    -- CFrameが含まれるパケットの場合も、ターゲット方向へ強制向ける
                    if typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(head.Position + Vector3.new(0, 1, 0), head.Position)
                    end
                end
                return old(self, unpack(args))
            end
        end
    end
    return old(self, ...)
end)

-- Deltaでも見やすい簡易通知UI
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 120, 0, 30)
f.Position = UDim2.new(0.1, 0, 0.1, 0)
f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
local t = Instance.new("TextLabel", f)
t.Size = UDim2.new(1, 0, 1, 0)
t.Text = "RAGE SWIFT: ON"
t.TextColor3 = Color3.fromRGB(0, 255, 120)
t.BackgroundTransparency = 1
t.TextSize = 12

print("🌌 Void-Hit Engine Loaded: Ready for Ragebot!")
