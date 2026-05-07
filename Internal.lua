-- L-Internal.hook | Precision Aimbot Update
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "L-Internal_Pro" then v:Destroy() end
end

-- --- 設定 ---
_G.AimbotEnabled = false
_G.AimbotKey = Enum.KeyCode.E
_G.AimbotFOV = 150
_G.Smoothness = 0.2 -- 0.1(超速) ～ 1(低速) で調整してくれ

-- FOV円
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = true
FOVCircle.Radius = _G.AimbotFOV

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "L-Internal_Pro"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Draggable = true
MainFrame.Active = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "L-INTERNAL | AIM"
Title.TextColor3 = Color3.fromRGB(255, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 70)
StatusLabel.Position = UDim2.new(0, 0, 0, 30)
StatusLabel.Text = "Status: OFF [E]"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1

-- キー判定
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == _G.AimbotKey then
        _G.AimbotEnabled = not _G.AimbotEnabled
        StatusLabel.Text = _G.AimbotEnabled and "Status: ON [E]" or "Status: OFF [E]"
        StatusLabel.TextColor3 = _G.AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    end
end)

-- ターゲット取得
local function getTarget()
    local nearest = nil
    local lastDist = _G.AimbotFOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
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
    
    if _G.AimbotEnabled then
        local target = getTarget()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            -- ここでマウスを直接動かす（mousemoverelはExecutorの機能）
            if mousemoverel then
                local centerX = Mouse.X
                local centerY = Mouse.Y + 36
                mousemoverel((targetPos.X - centerX) * _G.Smoothness, (targetPos.Y - centerY) * _G.Smoothness)
            else
                -- mousemoverelがないExecutor用の予備
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end
end)
