-- L-Internal.hook | Aimbot Fix Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 古いUIがあれば消す（二重表示防止）
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "L-Internal_UI" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "L-Internal_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "L-INTERNAL.hook"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Parent = MainFrame

local AimbotBtn = Instance.new("TextButton")
AimbotBtn.Text = "Aimbot: OFF"
AimbotBtn.Size = UDim2.new(0, 180, 0, 40)
AimbotBtn.Position = UDim2.new(0, 10, 0, 50)
AimbotBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotBtn.Parent = MainFrame

local Enabled = false

-- ボタンクリックの処理（一番安全な書き方に変更）
AimbotBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        AimbotBtn.Text = "Aimbot: ON"
        AimbotBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        AimbotBtn.Text = "Aimbot: OFF"
        AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- エイムループ
RunService.RenderStepped:Connect(function()
    if Enabled then
        local Target = nil
        local Dist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local mag = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if mag < Dist then
                    Dist = mag
                    Target = v
                end
            end
        end
        if Target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, Target.Character.HumanoidRootPart.Position)
        end
    end
end)
