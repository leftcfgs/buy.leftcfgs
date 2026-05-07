-- L-Internal.hook | God Tier Update
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "L-Internal_God" then v:Destroy() end
end

-- --- 設定 ---
local Settings = {
    AimbotEnabled = false,
    AimbotKey = Enum.KeyCode.E,
    AimbotKeyType = "Keyboard", -- "Keyboard" or "Mouse"
    AimbotMode = "Toggle", -- "Toggle", "Hold", "Always"
    HitPart = "HumanoidRootPart", -- "Head", "UpperTorso", "HumanoidRootPart"
    FOV = 150,
    Smoothness = 0.2,
    Binding = false
}

-- --- FOVの円 ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
FOVCircle.Visible = true
FOVCircle.Radius = Settings.FOV

-- --- UI作成 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "L-Internal_God"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Active = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "L-INTERNAL | GOD"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
Title.Font = Enum.Font.Code

-- 汎用作成関数
local function createBox(text, pos, parent, placeholder)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0, 220, 0, 30)
    box.Position = pos
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = text
    box.PlaceholderText = placeholder or ""
    box.Font = Enum.Font.Code
    return box
end

local function createBtn(text, pos, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 220, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = text
    btn.Font = Enum.Font.Code
    return btn
end

-- 各パーツ
local KeyBtn = createBtn("Key: E", UDim2.new(0, 10, 0, 45), MainFrame)
local ModeBtn = createBtn("Mode: Toggle", UDim2.new(0, 10, 0, 85), MainFrame)
local PartBtn = createBtn("Target: Body", UDim2.new(0, 10, 0, 125), MainFrame)

local FOVInput = createBox(tostring(Settings.FOV), UDim2.new(0, 10, 0, 165), MainFrame, "FOV (Number)")
local SmoothInput = createBox(tostring(Settings.Smoothness), UDim2.new(0, 10, 0, 205), MainFrame, "Smooth (0.05 - 1)")

local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, 0, 0, 40)
Status.Position = UDim2.new(0, 0, 0, 260)
Status.Text = "READY"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.BackgroundTransparency = 1

-- --- ロジック ---

-- 数値入力の反映
FOVInput.FocusLost:Connect(function() Settings.FOV = tonumber(FOVInput.Text) or Settings.FOV end)
SmoothInput.FocusLost:Connect(function() Settings.Smoothness = tonumber(SmoothInput.Text) or Settings.Smoothness end)

-- 部位切替
PartBtn.MouseButton1Click:Connect(function()
    if Settings.HitPart == "HumanoidRootPart" then Settings.HitPart = "Head"
    elseif Settings.HitPart == "Head" then Settings.HitPart = "UpperTorso"
    else Settings.HitPart = "HumanoidRootPart" end
    PartBtn.Text = "Target: " .. Settings.HitPart
end)

-- キーバインド（マウス対応）
KeyBtn.MouseButton1Click:Connect(function()
    Settings.Binding = true
    KeyBtn.Text = "Press any Key/Mouse..."
end)

local function handleInput(input, isBegan)
    if Settings.Binding then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Settings.AimbotKey = input.KeyCode
            Settings.AimbotKeyType = "Keyboard"
            KeyBtn.Text = "Key: " .. input.KeyCode.Name
        elseif input.UserInputType.Name:find("MouseButton") then
            Settings.AimbotKey = input.UserInputType
            Settings.AimbotKeyType = "Mouse"
            KeyBtn.Text = "Key: " .. input.UserInputType.Name
        end
        Settings.Binding = false
        return
    end

    local match = false
    if Settings.AimbotKeyType == "Keyboard" then
        match = (input.KeyCode == Settings.AimbotKey)
    else
        match = (input.UserInputType == Settings.AimbotKey)
    end

    if match then
        if Settings.AimbotMode == "Toggle" then
            if isBegan then Settings.AimbotEnabled = not Settings.AimbotEnabled end
        elseif Settings.AimbotMode == "Hold" then
            Settings.AimbotEnabled = isBegan
        end
    end
end

UserInputService.InputBegan:Connect(function(i, g) if not g then handleInput(i, true) end end)
UserInputService.InputEnded:Connect(function(i, g) if not g then handleInput(i, false) end end)

-- モード切替
ModeBtn.MouseButton1Click:Connect(function()
    if Settings.AimbotMode == "Toggle" then Settings.AimbotMode = "Hold"
    elseif Settings.AimbotMode == "Hold" then Settings.AimbotMode = "Always"
    else Settings.AimbotMode = "Toggle" end
    ModeBtn.Text = "Mode: " .. Settings.AimbotMode
    Settings.AimbotEnabled = (Settings.AimbotMode == "Always")
end)

-- ターゲット取得
local function getTarget()
    local nearest = nil
    local lastDist = Settings.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.HitPart) and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character[Settings.HitPart].Position)
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

-- ループ
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = true
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = Settings.FOV
    Status.TextColor3 = Settings.AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
    Status.Text = Settings.AimbotEnabled and "AIMBOT: ACTIVE" or "AIMBOT: WAITING"

    if Settings.AimbotEnabled then
        local target = getTarget()
        if target and mousemoverel then
            local targetPos = Camera:WorldToViewportPoint(target.Character[Settings.HitPart].Position)
            mousemoverel((targetPos.X - Mouse.X) * Settings.Smoothness, (targetPos.Y - (Mouse.Y + 36)) * Settings.Smoothness)
        end
    end
end)
