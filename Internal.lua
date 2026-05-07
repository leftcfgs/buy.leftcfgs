-- L-Internal.hook | Aimbot Update
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Version = Instance.new("TextLabel")
local DecorationLine = Instance.new("Frame")
local AimbotBtn = Instance.new("TextButton")

-- UI設定
ScreenGui.Parent = game.CoreGui
MainFrame.Name = "L-Internal_UI"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

-- 赤いデコレーションライン
DecorationLine.Parent = MainFrame
DecorationLine.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
DecorationLine.Size = UDim2.new(1, 0, 0, 2)

-- タイトル
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Size = UDim2.new(0, 200, 0, 30)
Title.Text = "L-INTERNAL.hook"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left

-- エイムボット起動ボタン
AimbotBtn.Parent = MainFrame
AimbotBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AimbotBtn.BorderSizePixel = 0
AimbotBtn.Position = UDim2.new(0, 10, 0, 60)
AimbotBtn.Size = UDim2.new(0, 200, 0, 40)
AimbotBtn.Font = Enum.Font.Code
AimbotBtn.Text = "Aimbot: OFF"
AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotBtn.TextSize = 14

-- Aimbotのロジック
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local _G.AimbotEnabled = false

AimbotBtn.MouseButton1Click:Connect(function()
    _G.AimbotEnabled = not _G.AimbotEnabled
    if _G.AimbotEnabled then
        AimbotBtn.Text = "Aimbot: ON"
        AimbotBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        AimbotBtn.Text = "Aimbot: OFF"
        AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- 一番近い敵を探してエイムするループ
RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled then
        local Target = nil
        local MaxDist = math.huge

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local Dist = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if Dist < MaxDist then
                    MaxDist = Dist
                    Target = v
                end
            end
        end

        if Target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, Target.Character.HumanoidRootPart.Position)
        end
    end
end)

print("L-Internal: Aimbot Module Loaded")
