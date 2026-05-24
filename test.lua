-- Nemesis Alpha ESP + Silent Aim

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Enabled = true,
    ESP = true,
    SilentAim = true,
    Aimbot = false,
    AimPart = "Head",
    Smoothness = 0.18,
    AimFOV = 90,
    SilentFOV = 120,
}

local ESPTable = {}

-- ==================== ESP ====================
local function UpdateESP()
    for plr, data in pairs(ESPTable) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local screen, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0)).Y) * 0.9
                data.Box.Size = Vector2.new(size * 1.8, size * 2.8)
                data.Box.Position = Vector2.new(screen.X - data.Box.Size.X/2, screen.Y - data.Box.Size.Y/2)
                data.Box.Visible = Config.ESP
            else
                data.Box.Visible = false
            end
        end
    end
end

-- ==================== Silent Aim ====================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if Config.SilentAim and method == "FireServer" then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(Config.AimPart) then
            if self.Name:lower():find("shoot") or self.Name:lower():find("bullet") or self.Name:lower():find("fire") then
                args[1] = target.Character[Config.AimPart].Position
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
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
                if d < dist and d <= Config.SilentFOV then
                    dist = d
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- ==================== Main Loop ====================
RunService.RenderStepped:Connect(function()
    if Config.ESP then
        UpdateESP()
    end
end)

print("Nemesis Alpha ESP + Silent Aim
