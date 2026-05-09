-- [[ tested internal: Projectile Swift Only ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Configuration
getgenv().SwiftEnabled = false

-- // UI Creation
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local Status = Instance.new("Frame")

ScreenGui.Name = "TestedInternal_Swift"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Position = UDim2.new(0.05, 0, 0.4, 0) -- 画面左側に配置（UEの邪魔にならない位置）
Main.Size = UDim2.new(0, 180, 0, 50)
Main.Draggable = true
Main.Active = true

local MCorner = Instance.new("UICorner")
MCorner.CornerRadius = UDim.new(0, 8)
MCorner.Parent = Main

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = Main
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Position = UDim2.new(0, 5, 0, 5)
ToggleBtn.Size = UDim2.new(1, -10, 1, -10)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "Projectile Swift"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14

local TCorner = Instance.new("UICorner")
TCorner.Parent = ToggleBtn

Status.Name = "Status"
Status.Parent = ToggleBtn
Status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Status.Position = UDim2.new(1, -20, 0.5, -5)
Status.Size = UDim2.new(0, 10, 0, 10)

local SCorner = Instance.new("UICorner")
SCorner.CornerRadius = UDim.new(1, 0)
SCorner.Parent = Status

-- // Toggle Logic
ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().SwiftEnabled = not getgenv().SwiftEnabled
    Status.BackgroundColor3 = getgenv().SwiftEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    print("Swift Mode: ", getgenv().SwiftEnabled)
end)

-- // Heart of Swift (Packet Hook)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if getgenv().SwiftEnabled and not checkcaller() and method == "FireServer" then
        if self.Name == "ShootProjectile" or self.Name == "ThrowDagger" or self.Name == "FireSlingshot" or self.Name == "Fire" then
            -- ターゲット取得
            local target = nil
            local dist = 500
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                    local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mag < dist then target = v; dist = mag end
                    end
                end
            end

            -- 弾道書き換え
            if target and target.Character:FindFirstChild("Head") then
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = (target.Character.Head.Position - Camera.CFrame.Position).Unit * 10000
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

print("🚀 tested internal - Swift UI Loaded!")
