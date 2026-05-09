-- [[ tested internal: UE (Unnamed Enhancements) Add-on ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- UEの内部ターゲット設定をシミュレートしつつ弾道を上書き
local function GetUESwiftTarget()
    local target = nil
    local dist = 300 -- UEの標準的なFOVに合わせる
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(game:GetService("Players").LocalPlayer:GetMouse().X, game:GetService("Players").LocalPlayer:GetMouse().Y)).Magnitude
                if mag < dist then target = v; dist = mag end
            end
        end
    end
    return target
end

-- [UE連動: パケット上書きエンジン]
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Rivalsのスリングショット、弓、ダガーのリモート名を網羅
    if not checkcaller() and method == "FireServer" then
        if self.Name == "ShootProjectile" or self.Name == "ThrowDagger" or self.Name == "FireSlingshot" or self.Name == "Fire" then
            
            local t = GetUESwiftTarget()
            if t and t.Character and t.Character:FindFirstChild("Head") then
                -- UEがロックしている敵の頭に、弾道を一直線に飛ばす
                local headPos = t.Character.Head.Position
                
                -- 引数の位置（通常はVector3）をターゲットへ書き換え
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        -- 弾速を極限まで高めて重力を無視させる（Projectile Swift）
                        args[i] = (headPos - Camera.CFrame.Position).Unit * 5000 
                        break
                    end
                end
                return old(self, unpack(args))
            end
        end
    end
    return old(self, ...)
end)

print("✅ Unnamed Enhancements Expansion: Projectile Swift Loaded!")
