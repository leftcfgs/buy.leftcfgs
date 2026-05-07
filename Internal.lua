-- L-Internal.hook | Stable God Update
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止（古いUIを確実に消す）
local existing = game.CoreGui:FindFirstChild("L-Internal_God")
if existing then existing:Destroy() end

-- --- 設定 ---
local Settings = {
    AimbotEnabled = false,
    AimbotKey = Enum.KeyCode.E,
    AimbotKeyType = "Keyboard",
    AimbotMode = "Toggle",
    HitPart = "HumanoidRootPart",
    FOV = 150,
    Smoothness = 0.2,
    Binding = false
}

-- --- FOVの円（描画負荷を軽減） ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
FOVCircle.Visible = true
FOVCircle.Radius = Settings.FOV

-- --- UI作成 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "L-Internal_God"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "L-INTERNAL | GOD v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 50)

-- 汎用関数
local function createBtn(text, pos, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 220, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = text
    return btn
end

local KeyBtn = createBtn("Key: E", UDim2.new(0, 10, 0, 45), MainFrame)
local ModeBtn = createBtn("Mode: Toggle", UDim2.new(0, 10, 0, 85), MainFrame)
local PartBtn = createBtn("Target: Body", UDim2.new(0, 10, 0, 125), MainFrame)

-- 数値入力（TextBoxの変更を即時反映させず、FocusLostで安全に処理）
local FOVInput = Instance.new("TextBox", MainFrame)
FOVInput.Size = UDim2.new(0, 220, 0, 30)
FOVInput.Position = UDim2.new(0, 10, 0, 165)
FOVInput.Text = "150"
FOVInput.PlaceholderText = "FOV (Number)"
FOVInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FOVInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local SmoothInput = Instance.new("TextBox", MainFrame)
SmoothInput.Size = UDim2.new(0, 220, 0, 30)
SmoothInput.Position = UDim2.new(0, 10, 0, 205)
SmoothInput.Text = "0.2"
SmoothInput.PlaceholderText = "Smooth (0.05-1)"
SmoothInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SmoothInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, 0, 0, 40)
Status.Position = UDim2.new(0, 0, 0, 260)
Status.Text = "STABLE READY"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.BackgroundTransparency = 1

-- --- 修正版ロジック ---

FOVInput.FocusLost:Connect(function() 
    local n = tonumber(FOVInput.Text)
    if n then Settings.FOV = n end
end)

SmoothInput.FocusLost:Connect(function()
    local n = tonumber(SmoothInput.Text)
    if n then Settings.Smoothness = math.clamp(n, 0.01, 1) end
end)

PartBtn.MouseButton1Click:Connect(function()
    if Settings.HitPart == "HumanoidRootPart" then Settings.HitPart = "Head"
    elseif Settings.HitPart == "Head" then Settings.HitPart = "UpperTorso"
    else Settings.HitPart = "HumanoidRootPart" end
    PartBtn.Text = "Target: " .. Settings.HitPart
end)

KeyBtn.MouseButton1Click:Connect(function()
    Settings.Binding = true
    KeyBtn.Text = "Press any key..."
end)

-- 入力処理
UserInputService.InputBegan:Connect(function(input, gp)
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

    if not gp then
        local match = (Settings.AimbotKeyType == "Keyboard" and input.KeyCode == Settings.AimbotKey) or (Settings.AimbotKeyType == "Mouse" and input.UserInputType == Settings.AimbotKey)
        if match and Settings.AimbotMode == "Toggle" then
            Settings.AimbotEnabled = not Settings.AimbotEnabled
        elseif match and Settings.AimbotMode == "Hold" then
            Settings.AimbotEnabled = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local match = (Settings.AimbotKeyType == "Keyboard" and input.KeyCode == Settings.AimbotKey) or (Settings.AimbotKeyType == "Mouse" and input.UserInputType == Settings.AimbotKey)
    if match and Settings.AimbotMode == "Hold" then
        Settings.AimbotEnabled = false
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    if Settings.AimbotMode == "Toggle" then Settings.AimbotMode = "Hold"
    elseif Settings.AimbotMode == "Hold" then Settings.AimbotMode = "Always"
    else Settings.AimbotMode = "Toggle" end
    ModeBtn.Text = "Mode: " .. Settings.AimbotMode
    Settings.AimbotEnabled = (Settings.AimbotMode == "Always")
end)

-- ターゲット取得（負荷軽減：生きているプレイヤーのみ検索）
local function getTarget()
    local nearest = nil
    local lastDist = Settings.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.HitPart) then
            local hum = v.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
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
    end
    return nearest
end

-- メインループ
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = Settings.FOV
    Status.Text = Settings.AimbotEnabled and "AIMBOT: ACTIVE" or "AIMBOT: WAITING"
    Status.TextColor3 = Settings.AimbotEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 200, 200)

    if Settings.AimbotEnabled then
        local target = getTarget()
        if target and mousemoverel then
            local targetPos = Camera:WorldToViewportPoint(target.Character[Settings.HitPart].Position)
            -- 計算を安定させるために小さな待ち時間を考慮したような処理
            mousemoverel((targetPos.X - Mouse.X) * Settings.Smoothness, (targetPos.Y - (Mouse.Y + 36)) * Settings.Smoothness)
        end
    end
end)
