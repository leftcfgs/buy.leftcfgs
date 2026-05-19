-- Roblox Studio の StarterPlayerScripts 内の LocalScript に丸ごと上書き
-- [[ NEXUS HUB for Rivals - 最強版 v9 ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HubConfig = {
    Enabled = true,
    ToggleKey = Enum.KeyCode.K,

    -- Teleport
    TeleportEnabled = true,
    UnderOffset = -3.0,
    BackOffset = 3.0,
    TeleportSmooth = 0.55,

    -- Silent Aim (Rivals特化)
    SilentAimEnabled = true,
    SilentAimHitChance = 100,
    TargetPart = "Head",

    -- Fast Shot
    FastShotEnabled = true,
    FastShotRate = 0.012,   -- かなり速い
}

local currentAngle = 0
local smoothedCameraPos = nil
local LockMarker = nil
local lastShotTime = 0

-- ==================== TARGET ====================
local function GetClosestTarget()
    local closest = nil
    local shortest = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local myPos = myRoot.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - myPos).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- ==================== TELEPORT ====================
local function DoTeleport(target)
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local tPos = target.Character.HumanoidRootPart.Position
    local dir = (tPos - myRoot.Position).Unit
    local finalPos = tPos - dir * HubConfig.BackOffset
    finalPos = Vector3.new(finalPos.X, tPos.Y + HubConfig.UnderOffset, finalPos.Z)

    local newPos = myRoot.Position:Lerp(finalPos, HubConfig.TeleportSmooth)
    myRoot.CFrame = CFrame.new(newPos)

    local lookPos = Vector3.new(tPos.X, newPos.Y, tPos.Z)
    myRoot.CFrame = CFrame.lookAt(newPos, lookPos)
end

-- ==================== SILENT AIM (Rivals向け) ====================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if HubConfig.SilentAimEnabled and method == "FireServer" then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(HubConfig.TargetPart) then
            -- Rivalsの射撃関連Remoteに反応
            if self.Name:lower():find("shoot") or self.Name:lower():find("bullet") or 
               self.Name:lower():find("fire") or self.Name:lower():find("gun") or self.Name:lower():find("remote") then
                
                args[1] = target.Character[HubConfig.TargetPart].Position
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- ==================== FAST SHOT ====================
local function UltraFastShot()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end

    pcall(function() tool:Activate() end)

    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function()
                v:FireServer()
                v:FireServer()
            end)
        end
    end
end

-- ==================== VFX ====================
local function UpdateVFX(targetChar)
    if not LockMarker then
        LockMarker = Instance.new("Part")
        LockMarker.Size = Vector3.new(4, 0.4, 4)
        LockMarker.Color = Color3.fromRGB(0, 255, 150)
        LockMarker.Material = Enum.Material.Neon
        LockMarker.Anchored = true
        LockMarker.CanCollide = false
        LockMarker.Parent = workspace
    end
    local head = targetChar:FindFirstChild("Head")
    if head then
        LockMarker.CFrame = CFrame.new(head.Position + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, os.clock() * 8, math.rad(90))
    end
end

-- ==================== MAIN LOOP ====================
RunService.Heartbeat:Connect(function(dt)
    if not HubConfig.Enabled then
        Camera.CameraType = Enum.CameraType.Custom
        return
    end

    local target = GetClosestTarget()

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if HubConfig.TeleportEnabled then
            DoTeleport(target)
        end

        UpdateVFX(target.Character)

        if HubConfig.FastShotEnabled and (tick() - lastShotTime >= HubConfig.FastShotRate) then
            UltraFastShot()
            lastShotTime = tick()
        end
    end
end)

print("👑 NEXUS Rivals 最強版 LOADED")
print("テレポート + 強Silent Aim + 高速連射")
