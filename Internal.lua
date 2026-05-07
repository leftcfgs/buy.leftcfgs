-- L-Internal.hook | Ultimate Custom Update
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "L-Internal_Ultimate" then v:Destroy() end
end

-- --- デフォルト設定 ---
local Settings = {
    AimbotEnabled = false,
    AimbotKey = Enum.KeyCode.E,
    AimbotMode = "Toggle", -- "Toggle", "Hold", "Always"
    FOV = 150,
    Smoothness = 0.2,
    Binding = false
}

-- --- FOVの円 ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
FOVCircle.Visible = true
FOVCircle.Radius = Settings.FOV

-- --- UI作成 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "L-Internal_Ultimate"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Active = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "L-INTERNAL | ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 50)

-- 設定用関数（ボタン作成の自動化）
local function createButton(text, pos, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = text
    btn.Font = Enum.Font.Code
    return btn
end

-- 各ボタン
local KeyBtn = createButton("Key: E", UDim2.new(0, 10, 0, 45), MainFrame)
local ModeBtn = createButton("Mode: Toggle", UDim2.new(0, 10, 0, 85), MainFrame)
local FOVPlus = createButton("FOV +", UDim2.new(0, 10, 0, 125), MainFrame)
local FOVMinus = createButton("FOV -", UDim2.new(0, 115, 0, 125), MainFrame)
FOVPlus.Size = UDim2.new(0, 95, 0, 30)
FOVMinus.Size = UDim2.new(0, 95, 0, 30)

local SmoothPlus = createButton("Smooth +", UDim2.new(0, 10, 0, 165), MainFrame)
local SmoothMinus = createButton("Smooth -", UDim2.new(0, 115, 0, 165), MainFrame)
SmoothPlus.Size = UDim2.new(0, 95, 0, 30)
SmoothMinus.Size = UDim2.new(0, 95, 0, 30)

local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, 0, 0, 40)
Status.Position = UDim2.new(0, 0, 0, 210)
Status.Text = "STATUS: OFF"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.BackgroundTransparency = 1

-- --- ロジック ---

-- キーバインド変更
KeyBtn.MouseButton1Click:Connect(function()
    Settings.Binding = true
    KeyBtn.Text = "Press any key..."
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if Settings.Binding and input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.AimbotKey = input.KeyCode
        KeyBtn.Text = "Key: " .. tostring(input.KeyCode.Name)
        Settings.Binding = false
        return
    end

    if not gp then
        if Settings.AimbotMode == "Toggle" and input.KeyCode == Settings.AimbotKey then
            Settings.AimbotEnabled = not Settings.AimbotEnabled
        elseif Settings.AimbotMode == "Hold" and input.KeyCode == Settings.AimbotKey then
            Settings.AimbotEnabled = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if Settings.AimbotMode == "Hold" and input.KeyCode == Settings.AimbotKey then
        Settings.AimbotEnabled = false
    end
end)

-- モード切替
ModeBtn.MouseButton1Click:Connect(function()
    if Settings.AimbotMode == "Toggle" then Settings.AimbotMode = "Hold"
    elseif Settings.AimbotMode == "Hold" then Settings.AimbotMode = "Always"
    else Settings.AimbotMode = "Toggle" end
    ModeBtn.Text = "Mode: " .. Settings.AimbotMode
    Settings.AimbotEnabled = (Settings.AimbotMode == "Always")
end)

-- FOV & Smooth 調整
FOVPlus.MouseButton1Click:Connect(function() Settings.FOV = Settings.FOV + 10 end)
FOVMinus.MouseButton1Click:Connect(function() Settings.FOV = Settings.FOV - 10 end)
SmoothPlus.MouseButton1Click:Connect(function() Settings.Smoothness = math.min(Settings.Smoothness + 0.05, 1) end)
SmoothMinus.MouseButton1Click:Connect(function() Settings.Smoothness = math.max(Settings.Smoothness - 0.05, 0.05) end)

-- エイムターゲット取得
local function getTarget()
    local nearest = nil
    local lastDist = Settings.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < lastDist then
                    lastDist = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- メインループ
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = Settings.FOV
    Status.Text = "Smooth: " .. string.format("%.2f", Settings.Smoothness) .. " | FOV: " .. Settings.FOV
    Status.TextColor3 = Settings.AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)

    if Settings.AimbotEnabled then
        local target = getTarget()
        if target and mousemoverel then
            local targetPos = Camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            mousemoverel((targetPos.X - Mouse.X) * Settings.Smoothness, (targetPos.Y - (Mouse.Y + 36)) * Settings.Smoothness)
        end
    end
end)
