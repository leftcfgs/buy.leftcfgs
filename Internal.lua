-- Roblox Studio の StarterPlayerScripts 内の LocalScript に丸ごと上書き
-- [[ THE NEXUS OMNI-HUB : TELEPORT + SILENT AIM + ULTRA FAST SHOT v5 ]]
-- 行数多め・機能強化版

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ====================== CONFIG ======================
local HubConfig = {
    Enabled = true,
    ToggleKey = Enum.KeyCode.K,

    -- Camera Orbit
    Radius = 16,
    Speed = 2.8,
    HeightOffset = 5,
    Smoothness = 0.1,

    -- Teleport
    TeleportEnabled = true,
    UnderOffset = -3.1,
    BackOffset = 3.6,
    TeleportSmooth = 0.65,
    FaceEnemy = true,

    -- Silent Aim (重要)
    SilentAimEnabled = true,
    SilentAimFOV = 150,
    SilentAimHitChance = 95,
    TargetPart = "Head",        -- Head / HumanoidRootPart / Torso

    -- Fast Shot
    FastShotEnabled = true,
    FastShotRate = 0.016,

    -- VFX
    ShowMarker = true,
    MarkerColor = Color3.fromRGB(0, 255, 170),
}

local currentAngle = 0
local smoothedCameraPos = nil
local LockMarker = nil
local lastShotTime = 0

-- ====================== TARGET ======================
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

-- ====================== TELEPORT ======================
local function DoTeleport(target)
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local tPos = target.Character.HumanoidRootPart.Position
    local myPos = myRoot.Position

    local dir = (tPos - myPos).Unit
    local finalPos = tPos - dir * HubConfig.BackOffset
    finalPos = Vector3.new(finalPos.X, tPos.Y + HubConfig.UnderOffset, finalPos.Z)

    local newPos = myRoot.Position:Lerp(finalPos, HubConfig.TeleportSmooth)
    myRoot.CFrame = CFrame.new(newPos)

    if HubConfig.FaceEnemy then
        local lookPos = Vector3.new(tPos.X, newPos.Y, tPos.Z)
        myRoot.CFrame = CFrame.lookAt(newPos, lookPos)
    end
end

-- ====================== SILENT AIM ======================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if HubConfig.SilentAimEnabled and method == "FireServer" then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(HubConfig.TargetPart) then
            if self.Name:lower():find("shoot") or self.Name:lower():find("bullet") or 
               self.Name:lower():find("fire") or self.Name:lower():find("gun") then
                args[1] = target.Character[HubConfig.TargetPart].Position
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- ====================== FAST SHOT ======================
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

-- ====================== VFX ======================
local function UpdateVFX(targetChar)
    if not HubConfig.ShowMarker or not targetChar:FindFirstChild("Head") then
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        return
    end

    if not LockMarker then
        LockMarker = Instance.new("Part")
        LockMarker.Size = Vector3.new(3.5, 0.4, 3.5)
        LockMarker.Color = HubConfig.MarkerColor
        LockMarker.Material = Enum.Material.Neon
        LockMarker.CanCollide = false
        LockMarker.Anchored = true
        LockMarker.Parent = workspace

        local mesh = Instance.new("SpecialMesh", LockMarker)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://3270017"
        mesh.Scale = Vector3.new(4, 4, 0.8)
    end

    local head = targetChar.Head
    LockMarker.CFrame = CFrame.new(head.Position + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, os.clock() * 8, math.rad(90))
end

-- ====================== MAIN LOOP ======================
RunService.Heartbeat:Connect(function(dt)
    if not HubConfig.Enabled then
        Camera.CameraType = Enum.CameraType.Custom
        return
    end

    local target = GetClosestTarget()

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        -- Teleport
        if HubConfig.TeleportEnabled then
            DoTeleport(target)
        end

        -- VFX
        UpdateVFX(target.Character)

        -- Fast Shot
        if HubConfig.FastShotEnabled and (tick() - lastShotTime >= HubConfig.FastShotRate) then
            UltraFastShot()
            lastShotTime = tick()
        end

        -- Camera
        currentAngle = currentAngle + (HubConfig.Speed * dt)
        local ox = math.cos(currentAngle) * HubConfig.Radius
        local oz = math.sin(currentAngle) * HubConfig.Radius
        local rawPos = target.Character.HumanoidRootPart.Position + Vector3.new(ox, HubConfig.HeightOffset, oz)

        smoothedCameraPos = smoothedCameraPos and smoothedCameraPos:Lerp(rawPos, HubConfig.Smoothness) or rawPos

        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(smoothedCameraPos, target.Character.HumanoidRootPart.Position)
    else
        Camera.CameraType = Enum.CameraType.Custom
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
    end
end)

print("👑 NEXUS v5 with Silent Aim LOADED")
