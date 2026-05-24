-- Nemesis Alpha ESP + Silent Aim + Aimbot (FOV調整 + Left Shift UI)

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
    AimFOV = 120,          -- ← FOV変更可能
    SilentFOV = 150,       -- Silent Aimの範囲
}

local ESPTable = {}
local target = nil

-- ====================== UI ======================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 480)
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
Title.TextSize = 17
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
CreateToggle("Aimbot", 190, "Aimbot")

-- FOV調整
local function CreateSlider(label, y, default, key, min, max)
    local lbl = Instance.new("TextLabel", MainFrame)
    lbl.Size = UDim2.new(0.5,0,0,30)
    lbl.Position = UDim2.new(0,20,0,y)
    lbl.Text = label .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.BackgroundTransparency = 1

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0, 100, 0, 30)
    box.Position = UDim2.new(1, -130, 0, y)
    box.Text = tostring(default)
    box.BackgroundColor3 = Color3.fromRGB(30,30,40)
    box.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", box)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            Config[key] = math.clamp(num, min, max)
            lbl.Text = label .. ": " .. Config[key]
        end
    end)
end

CreateSlider("Aimbot FOV", 250, Config.AimFOV, "AimFOV", 30, 500)
CreateSlider("Silent Aim FOV", 290, Config.SilentFOV, "SilentFOV", 30, 500)

-- Left Shift でUIトグル
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==================== ESP ====================
local function CreateESP(plr)
    if ESPTable[plr] then return end
    -- (ESPコードは前のものと同じなので省略せず簡略化)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(0, 255, 100)
    box.Filled = false

    ESPTable[plr] = {Box = box}
end

local function UpdateESP()
    for plr, drawing in pairs(ESPTable) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local screen, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0)).Y) * 0.9
                drawing.Box.Size = Vector2.new(size * 1.8, size * 2.8)
                drawing.Box.Position = Vector2.new(screen.X - drawing.Box.Size.X/2, screen.Y - drawing.Box.Size.Y/2)
                drawing.Box.Visible = Config.ESP
            else
                drawing.Box.Visible = false
            end
        end
    end
end

-- ==================== Aimbot & Silent Aim ====================
local function GetClosestTarget()
    local closest, dist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Config.AimPart) then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local d = (plr.Character[Config.AimPart].Position - Camera.CFrame.Position).Magnitude
                if d < dist and d <= Config.AimFOV then
                    dist = d
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- Silent Aim
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

-- Aimbot
RunService.RenderStepped:Connect(function()
    if Config.Aimbot then
        target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(Config.AimPart) then
            local aimPos = target.Character[Config.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, aimPos), Config.Smoothness)
        end
    end
    UpdateESP()
end)

print("Nemesis Alpha ESP + Silent Aim + Aimbot LOADED")
print("Left Shift = UIトグル | 右クリック = Aimbot")
