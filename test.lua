local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("MVSD OP チート", "DarkTheme")

local Tab = Window:NewTab("Combat")
local Section = Tab:NewSection("攻撃系")

local aimbotEnabled = false
local silentEnabled = false
local allkillEnabled = false

-- All Kill
Section:NewToggle("All Kill (超高速)", "0.0001秒で全員キル", function(state)
    allkillEnabled = state
    if state then
        spawn(function()
            while allkillEnabled do
                pcall(function()
                    for _, plr in pairs(game.Players:GetPlayers()) do
                        if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                            plr.Character.Humanoid.Health = 0
                        end
                    end
                end)
                wait(0.0001)
            end
        end)
    end
end)

Section:NewToggle("Aimbot", "自動照準", function(state)
    aimbotEnabled = state
end)

Section:NewToggle("Silent Aim", "無音エイム", function(state)
    silentEnabled = state
end)

-- Velocity
Section:NewSlider("Velocity", "移動速度倍率", 300, 50, 500, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Velocity = Vector3.new(char.HumanoidRootPart.Velocity.X * (value/100), char.HumanoidRootPart.Velocity.Y, char.HumanoidRootPart.Velocity.Z * (value/100))
    end
end)

-- Fly (ちゃんと上下左右動くやつ)
local flyEnabled = false
local flySpeed = 50
Section:NewToggle("Fly", "飛行モード", function(state)
    flyEnabled = state
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    local root = character:WaitForChild("HumanoidRootPart")
    
    if flyEnabled then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(400000, 400000, 400000)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = root
        
        game:GetService("RunService").Heartbeat:Connect(function()
            if not flyEnabled then return end
            local cam = workspace.CurrentCamera
            local move = Vector3.new(0,0,0)
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            bv.Velocity = move.Unit * flySpeed
        end)
    else
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    end
end)
local ESPSection = Tab:NewSection("視覚系")

-- ESP
ESPSection:NewToggle("ESP", "敵をハイライト", function(state)
    if state then
        spawn(function()
            while state do
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= game.Players.LocalPlayer and plr.Character then
                        if not plr.Character:FindFirstChild("ESPHighlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESPHighlight"
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Parent = plr.Character
                        end
                    end
                end
                wait(1)
            end
        end)
    else
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("ESPHighlight") then
                plr.Character.ESPHighlight:Destroy()
            end
        end
    end
end)

-- Auto Farm（超高速連射）
local AutoFarmSection = Tab:NewSection("Auto Farm")
AutoFarmSection:NewButton("Auto Farm 開始（最強）", "0.0001秒連射", function()
    spawn(function()
        while true do
            local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Activate") then
                tool:Activate()
            end
            wait(0.0001)
        end
    end)
end)

-- 追加設定
local Settings = Tab:NewSection("設定")
Settings:NewKeybind("メニュー開閉", "Insertキー", Enum.KeyCode.Insert, function()
    Library:ToggleUI()
end)

print("✅ MVSD OP チート 完全版 起動！")
print("Insertキーでメニュー開閉できます")
