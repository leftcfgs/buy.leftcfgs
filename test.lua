-- Nemesis Alpha ESP + Aimbot (シンプル最強版)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    ESP = true,
    Aimbot = true,
    AimbotKey = Enum.UserInputType.MouseButton2, -- 右クリックでエイム
    AimPart = "Head",
    Smoothness = 0.15,
    TeamCheck = true,
}

local ESPObjects = {}

-- ==================== ESP ====================
local function CreateESP(plr)
    if ESPObjects[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(0, 255, 100)
    box.Filled = false
    box.Transparency = 1

    local name = Drawing.new("Text")
    name.Size = 14
    name.Color = Color3.new(1,1,1)
    name.Outline = true
    name.Center = true

    ESPObjects[plr] = {Box = box, Name = name}
end

local function UpdateESP()
    for plr, obj in pairs(ESPObjects) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local root = plr.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0)).Y) * 0.8
                obj.Box.Size = Vector2.new(size * 1.5, size * 2.5)
                obj.Box.Position = Vector2.new(screenPos.X - obj.Box.Size.X/2, screenPos.Y - obj.Box.Size.Y/2)
                obj.Box.Visible = Config.ESP

                obj.Name.Text = plr.Name .. " [" .. math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                obj.Name.Position = Vector2.new(screenPos.X, screenPos.Y - obj.Box.Size.Y/2 - 15)
                obj.Name.Visible = Config.ESP
            else
                obj.Box.Visible = false
                obj.Name.Visible = false
            end
        else
            obj.Box.Visible = false
            obj.Name.Visible = false
        end
    end
end

-- ==================== AIMBOT ====================
local target = nil
local function GetClosest()
    local closest, dist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Config.AimPart) then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if Config.TeamCheck and plr.Team == LocalPlayer.Team then continue end
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

RunService.RenderStepped:Connect(function()
    if not Config.Aimbot then return end
    target = GetClosest()

    if target and target.Character and target.Character:FindFirstChild(Config.AimPart) then
        local aimPos = target.Character[Config.AimPart].Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, aimPos), Config.Smoothness)
    end
end)

-- ==================== ESP Loop ====================
RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

-- ==================== Keybind ====================
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Config.AimbotKey then
        Config.Aimbot = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimbotKey then
        Config.Aimbot = false
    end
end)

print("Nemesis Alpha ESP + Aimbot LOADED")
print("右クリックでAimbot / ESP常時ON")
