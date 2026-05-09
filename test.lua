-- [[ tested internal: Delta & UE Compatibility Edition ]]
print("🚀 Delta Engine Initializing...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- DeltaでUIが出ないのを防ぐために親をPlayerGuiにする
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TestedSwiftDelta"
ScreenGui.Parent = (game:GetService("RunService"):IsStudio() and Players.LocalPlayer.PlayerGui or game:GetService("CoreGui"))
ScreenGui.ResetOnSpawn = false

-- // Configuration
getgenv().SwiftEnabled = false

-- // UI (Deltaでも操作しやすいサイズ)
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.Size = UDim2.new(0, 150, 0, 40)
Main.Active = true
Main.Draggable = true -- スマホだとドラッグしにくいが一応

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = Main
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Text = "SWIFT: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().SwiftEnabled = not getgenv().SwiftEnabled
    ToggleBtn.Text = getgenv().SwiftEnabled and "SWIFT: ON" or "SWIFT: OFF"
    ToggleBtn.TextColor3 = getgenv().SwiftEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end)

-- // Deltaでも動くように簡略化したパケット補正
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if getgenv().SwiftEnabled and method == "FireServer" and not checkcaller() then
        -- Rivalsの弓・スリング・ダガーの検知
        if self.Name:find("Fire") or self.Name:find("Shoot") or self.Name:find("Throw") then
            -- ターゲット取得（一番近い敵）
            local target = nil
            local dist = 300
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                    local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mag < dist then target = v; dist = mag end
                    end
                end
            end

            if target then
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = (target.Character.Head.Position - Camera.CFrame.Position).Unit * 5000
                    end
                end
                return old(self, unpack(args))
            end
        end
    end
    return old(self, ...)
end)

print("✅ Delta Swift Loaded!")
