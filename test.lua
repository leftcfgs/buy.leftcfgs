-- Bridge Duel Simple Reach (On/Off UI)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local reachMultiplier = 1.6  -- ここを変更（1.3 = 低リスク, 1.6 = バランス, 2.0 = 強力）
local enabled = false

-- シンプルUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReachToggle"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 80)
Frame.Position = UDim2.new(0.5, -90, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.BackgroundTransparency = 1
Title.Text = "Bridge Duel Reach"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0.4, 0)
ToggleButton.Position = UDim2.new(0.05, 0, 0.55, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = Frame

-- Reach機能
local function applyReach()
    while enabled and player.Character do
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                handle.Size = handle.Size * reachMultiplier  -- 大きくする
                handle.Transparency = 0.7
            end
        end
        wait(0.1)
    end
end

-- トグル
ToggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        applyReach()
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

print("Bridge Duel Reach Cheat Loaded! Default: " .. (reachMultiplier*100) .. "%")
