-- Roblox Studio の StarterPlayerScripts 内の LocalScript に丸ごと上書き
-- [[ THE NEXUS OMNI-HUB : TELEPORT EXTREME + ULTRA FAST SHOT FINAL v3 ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HubConfig = {
    Enabled = true,
    Radius = 16,
    Speed = 2.8,
    HeightOffset = 4.8,
    Smoothness = 0.1,
    ShowMarker = true,
    MarkerColor = Color3.fromRGB(0, 255, 170),
    ToggleKey = Enum.KeyCode.K,

    -- Teleport
    TeleportEnabled = true,
    UnderOffset = -3.1,
    BackOffset = 3.8,
    TeleportSmooth = 0.68,
    FaceEnemy = true,

    -- Ultra Fast Shot
    FastShotEnabled = true,
    FastShotRate = 0.018,
    FastShotOnlyWhenTeleport = true,
}

local currentAngle = 0
local smoothedCameraPos = nil
local LockMarker = nil
local lastShotTime = 0

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

local function DoTeleport(target)
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local tRoot = target.Character.HumanoidRootPart
    local tPos = tRoot.Position
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

local function UltraFastShot()
    local char = LocalPlayer.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
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

    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("BindableEvent") then
            pcall(function() v:Fire() end)
        end
    end
end

local function UpdateVFX(targetChar)
    if not HubConfig.ShowMarker or not targetChar:FindFirstChild("Head") then
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        return
    end

    if not LockMarker then
        LockMarker = Instance.new("Part")
        LockMarker.Size = Vector3.new(3.2, 0.35, 3.2)
        LockMarker.Color = HubConfig.MarkerColor
        LockMarker.Material = Enum.Material.Neon
        LockMarker.CanCollide = false
        LockMarker.Anchored = true
        LockMarker.Parent = workspace

        local mesh = Instance.new("SpecialMesh", LockMarker)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://3270017"
        mesh.Scale = Vector3.new(3.5, 3.5, 0.7)
    end

    local head = targetChar.Head
    LockMarker.CFrame = CFrame.new(head.Position + Vector3.new(0, 3.3, 0)) * CFrame.Angles(0, os.clock() * 7, math.rad(90))
end

-- ===================== MAIN LOOP =====================
RunService.Heartbeat:Connect(function(dt)
    if not HubConfig.Enabled then
        Camera.CameraType = Enum.CameraType.Custom
        return
    end

    local target = GetClosestTarget()

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart

        if HubConfig.TeleportEnabled then
            DoTeleport(target)
        end

        UpdateVFX(target.Character)

        if HubConfig.FastShotEnabled then
            local canShoot = not HubConfig.FastShotOnlyWhenTeleport or HubConfig.TeleportEnabled
            if canShoot and (tick() - lastShotTime >= HubConfig.FastShotRate) then
                UltraFastShot()
                lastShotTime = tick()
            end
        end

        currentAngle = currentAngle + (HubConfig.Speed * dt)
        local ox = math.cos(currentAngle) * HubConfig.Radius
        local oz = math.sin(currentAngle) * HubConfig.Radius
        local rawPos = targetRoot.Position + Vector3.new(ox, HubConfig.HeightOffset, oz)

        smoothedCameraPos = smoothedCameraPos and smoothedCameraPos:Lerp(rawPos, HubConfig.Smoothness) or rawPos

        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(smoothedCameraPos, targetRoot.Position)
    else
        Camera.CameraType = Enum.CameraType.Custom
        if LockMarker then
            LockMarker:Destroy()
            LockMarker = nil
        end
    end
end)

print("👑 NEXUS EXTREME v3 LOADED - KキーでUIが出るはず")
