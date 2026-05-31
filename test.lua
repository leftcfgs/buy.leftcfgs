local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("MVSD OP チート", "DarkTheme")

local Tab = Window:NewTab("メイン機能")
local Section = Tab:NewSection("All Kill & Combat")

local aimbot = false
local silent = false
local flyon = false
local velocity = 1
local allkill = false

-- All Kill (超高速)
Section:NewToggle("All Kill (0.0001秒)", "全員即キル", function(state)
    allkill = state
    if allkill then
        spawn(function()
            while allkill do
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
                        v.Character.Humanoid.Health = 0
                    end
                end
                wait(0.0001)
            end
        end)
    end
end)

Section:NewToggle("Aimbot", "自動で敵に狙う", function(state)
    aimbot = state
    print("Aimbot ".. (aimbot and "ON" or "OFF"))
end)

Section:NewToggle("Silent Aim", "当たるようにする", function(state)
    silent = state
    print("Silent Aim ".. (silent and "ON" or "OFF"))
end)

Section:NewSlider("Velocity", "移動速度", 100, 1, 500, function(val)
    velocity = val
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Velocity = char.HumanoidRootPart.Velocity * (velocity/50)
    end
end)

Section:NewToggle("Fly", "空を飛ぶ", function(state)
    flyon = state
    local player = game.Players.LocalPlayer
    local char = player.Character
    if flyon and char then
        local body = Instance.new("BodyVelocity")
        body.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        body.Velocity = Vector3.new(0,0,0)
        body.Parent = char.HumanoidRootPart
        game:GetService("UserInputService").InputBegan:Connect(function(key)
            if key.KeyCode == Enum.KeyCode.Space then body.Velocity = Vector3.new(0,50,0) end
        end)
    end
end)

-- Auto Farm
Section:NewButton("Auto Farm 最強", "0.0001秒で銃連射", function()
    spawn(function()
        while true do
            local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
            wait(0.0001)
        end
    end)
end)

local ESPSection = Tab:NewSection("ESP")
ESPSection:NewToggle("ESP", "敵が見える", function(state)
    if state then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                local esp = Instance.new("Highlight")
                esp.Parent = plr.Character
                esp.FillColor = Color3.new(1,0,0)
                esp.OutlineColor = Color3.new(1,1,1)
            end
        end
    end
end)

print("MVSD チート起動！ Kavo UIで全部操作してね")
