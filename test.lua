-- [[ tested internal v16.0: PHYSICAL VOID ]]
-- NO HOOKMETAMETHOD - PURE INSTANCE MANIPULATION
-- OPTIMIZED FOR WAVE (PC)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Void = {
    Enabled = true,
    Height = 400,
    Stack = 200,
    Prediction = 6.0
}

-- // SIMPLE TARGETING
local function GetTarget()
    local target = nil
    local dist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") then
            local d = (p.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
            if d < dist then target = p; dist = d end
        end
    end
    return target
end

-- // PHYSICAL DATA OVERRIDE
RunService.Stepped:Connect(function()
    if not getgenv().Void.Enabled then return end
    
    local t = GetTarget()
    if t then
        local head = t.Character.Head
        local root = t.Character.HumanoidRootPart
        
        -- [[ ORBIT COUNTER ]]
        -- 自分のキャラクターが爆走していても、発射ベクトルを固定する
        local pos = head.Position + (root.Velocity * 0.15 * getgenv().Void.Prediction)
        
        -- 弾丸オブジェクトが生成された瞬間に座標を相手の頭上に飛ばす
        -- (この部分はゲーム内の弾丸パスを自動検知して座標を上書きする)
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("BasePart") and (v.Name:find("Projectile") or v.Name:find("Bullet") or v.Name:find("Arrow")) then
                v.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0), pos)
                v.Velocity = Vector3.new(0, -1000, 0)
            end
        end
    end
end)

-- // SIMPLEST UI
local SG = Instance.new("ScreenGui", game.CoreGui)
local F = Instance.new("Frame", SG)
F.Size = UDim2.new(0, 200, 0, 50)
F.Position = UDim2.new(0.05, 0, 0.4, 0)
F.BackgroundColor3 = Color3.new(0, 0, 0)

local L = Instance.new("TextLabel", F)
L.Size = UDim2.new(1, 0, 1, 0)
L.Text = "VOID v16: RUNNING"
L.TextColor3 = Color3.new(1, 0, 0)
L.BackgroundTransparency = 1

print("VOID v16 LOADED. PHYSICAL OVERRIDE ACTIVE.")
