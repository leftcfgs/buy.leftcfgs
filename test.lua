-- Nemesis Alpha ESP + Silent Aim + UI (高機能版)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Enabled = true,
    ESP = true,
    SilentAim = true,
    Aimbot = true,
    AimPart = "Head",
    Smoothness = 0.12,
}

local ESPTable = {}

-- ==================== UI ====================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,22)
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundColor3 = Color3.fromRGB(25,25,35)
Title.Text = "NEXUS Nemesis Alpha"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title)

local function CreateToggle(text, y, key)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -40, 0, 45)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    btn.Text = text .. ": ON"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        btn.Text = text .. (Config[key] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(0,170,255) or Color3.fromRGB(70,70,80)
    end)
end

CreateToggle("ESP", 70, "ESP")
CreateToggle("Silent Aim", 130, "SilentAim")
CreateToggle("Aimbot (Right Click)", 190, "Aimbot")

-- ==================== ESP ====================
local function CreateESP(plr)
    if ESPTable[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(0, 255, 100)
    box.Filled = false

    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Filled = true

    local name = Drawing.new("Text")
    name.Size = 13
    name.Color = Color3.new(1,1,1)
    name.Outline = true
    name.Center = true

    local weapon = Drawing.new("Text")
    weapon.Size = 12
    weapon.Color = Color3.fromRGB(255, 200, 100)
    weapon.Outline = true
    weapon.Center = true

    ESPTable[plr] = {Box = box, HealthBar = healthBar, Name = name, Weapon = weapon}
end

local function UpdateESP()
    for plr, drawing in pairs(ESPTable) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local screen, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen and hum then
                local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0)).Y) * 0.9

                drawing.Box.Size = Vector2.new(size * 1.8, size * 2.8)
                drawing.Box.Position = Vector2.new(screen.X - drawing.Box.Size.X/2, screen.Y - drawing.Box.Size.Y/2)
                drawing.Box.Visible = Config.ESP

                -- Health Bar
                local healthPercent = hum.Health / hum.MaxHealth
                drawing.HealthBar.Size = Vector2.new(3, drawing.Box.Size.Y * healthPercent)
                drawing.HealthBar.Position = Vector2.new(drawing.Box.Position.X - 6, drawing.Box.Position.Y + drawing.Box.Size.Y * (1 - healthPercent))
                drawing.HealthBar.Visible = Config.ESP

                -- Name + Distance
                local distance = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                drawing.Name.Text = plr.Name .. " [" .. distance .. "m]"
                drawing.Name.Position = Vector2.new(screen.X, screen.Y - drawing.Box.Size.Y/2 - 18)
                drawing.Name.Visible = Config.ESP

                -- Weapon
                local weaponName = "None"
                if plr.Character:FindFirstChildOfClass("Tool") then
                    weaponName = plr.Character:FindFirstChildOfClass("Tool").Name
                end
                drawing.Weapon.Text = weaponName
                drawing.Weapon.Position = Vector2.new(screen.X, screen.Y + drawing.Box.Size.Y/2 + 5)
                drawing.Weapon.Visible = Config.ESP
            else
                drawing.Box.Visible = false
                drawing.HealthBar.Visible = false
                drawing.Name.Visible = false
                drawing.Weapon.Visible = false
            end
        end
    end
end

-- ==================== SILENT AIM ====================
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if Config.SilentAim and getnamecallmethod() == "FireServer" then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(Config.AimPart) then
            if self.Name:lower():find("shoot") or self.Name:lower():find("bullet") or self.Name:lower():find("fire") then
                args[1] = target.Character[Config.AimPart].Position
                return old(self, unpack(args))
            end
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

local function GetClosestTarget()
    local closest, dist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Config.AimPart) then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local d = (plr.Character[Config.AimPart].Position - Camera.CFrame.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- ==================== MAIN LOOP ====================
RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

print("Nemesis Alpha ESP + Silent Aim LOADED")
print("Kキー でUI表示 | 右クリックでAimbot")
