-- Roblox Studio の StarterPlayerScripts 内の LocalScript に丸ごと上書き
-- [[ NEXUS Rivals 最強版 with UI ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HubConfig = {
    Enabled = true,
    TeleportEnabled = true,
    SilentAimEnabled = true,
    FastShotEnabled = true,
    UnderOffset = -3.0,
    BackOffset = 3.2,
    FastShotRate = 0.012,
    TargetPart = "Head",
}

local currentAngle = 0
local smoothedCameraPos = nil
local LockMarker = nil
local lastShotTime = 0

-- GetClosestTarget, DoTeleport, Silent Aim, UltraFastShot は省略せず全部入れる
local function GetClosestTarget()
    local closest, dist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local d = (root.Position - myRoot.Position).Magnitude
                if d < dist then dist = d closest = plr end
            end
        end
    end
    return closest
end

local function DoTeleport(target)
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local tPos = target.Character.HumanoidRootPart.Position
    local dir = (tPos - myRoot.Position).Unit
    local finalPos = tPos - dir * HubConfig.BackOffset
    finalPos = Vector3.new(finalPos.X, tPos.Y + HubConfig.UnderOffset, finalPos.Z)
    local newPos = myRoot.Position:Lerp(finalPos, 0.55)
    myRoot.CFrame = CFrame.new(newPos)
    myRoot.CFrame = CFrame.lookAt(newPos, Vector3.new(tPos.X, newPos.Y, tPos.Z))
end

-- Silent Aim
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if HubConfig.SilentAimEnabled and getnamecallmethod() == "FireServer" then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(HubConfig.TargetPart) then
            if self.Name:lower():find("shoot") or self.Name:lower():find("bullet") or self.Name:lower():find("fire") then
                args[1] = target.Character[HubConfig.TargetPart].Position
                return old(self, unpack(args))
            end
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

local function UltraFastShot()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                v:FireServer()
            end
        end
    end
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundColor3 = Color3.fromRGB(25,25,35)
Title.Text = "NEXUS Rivals 最強版"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title)

local function MakeToggle(name, posY, configKey, defaultText)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -40, 0, 45)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    btn.Text = defaultText
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        HubConfig[configKey] = not HubConfig[configKey]
        btn.Text = HubConfig[configKey] and defaultText or defaultText:gsub("ON", "OFF")
        btn.BackgroundColor3 = HubConfig[configKey] and Color3.fromRGB(0,170,255) or Color3.fromRGB(70,70,80)
    end)
end

MakeToggle("TELEPORT", 70, "TeleportEnabled", "TELEPORT: ON")
MakeToggle("SILENT AIM", 130, "SilentAimEnabled", "SILENT AIM: ON")
MakeToggle("FAST SHOT", 190, "FastShotEnabled", "FAST SHOT: ON")

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == HubConfig.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("👑 NEXUS Rivals 最強版 with UI LOADED")
