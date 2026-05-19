-- Roblox Studio の StarterPlayerScripts 内の LocalScript に丸ごと上書き
-- [[ THE NEXUS OMNI-HUB : TELEPORT EXTREME + FAST SHOT ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =============================================
-- ================== CONFIG ===================
-- =============================================
local HubConfig = {
    Enabled = true,                    -- メインシステム全体
    Radius = 15,
    Speed = 2.5,
    HeightOffset = 4,
    Smoothness = 0.12,
    ShowMarker = true,
    MarkerColor = Color3.fromRGB(0, 255, 150),
    ToggleKey = Enum.KeyCode.K,

    -- === TELEPORT SETTINGS ===
    TeleportEnabled = true,
    TeleportMode = "Under",            -- Under / Behind / Side / Random / Predict
    UnderOffset = -3.2,
    BackOffset = 3.5,
    SideOffset = 4.0,
    RandomOffsetMin = 2.0,
    RandomOffsetMax = 6.0,
    PredictAhead = 0.15,
    FaceEnemy = true,
    TeleportSmooth = 0.65,
    MinDistanceToTeleport = 3.0,

    -- === FAST SHOT SETTINGS ===
    FastShotEnabled = true,            -- 自動連射機能
    FastShotSpeed = 0.08,              -- 連射間隔（小さいほど速い・0.05がかなりヤバい）
    FastShotOnlyTeleport = true,       -- テレポート中だけ連射するかどうか
}

local currentAngle = 0
local smoothedCameraPos = nil
local LockMarker = nil
local frameCounter = 0
local lastShotTime = 0

-- =============================================
-- =============== TARGET SYSTEM ===============
local function GetClosestTarget()
    local closest = nil
    local shortest = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = myChar.HumanoidRootPart.Position

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

-- =============================================
-- ============= TELEPORT ENGINE ===============
local function CalculateTeleportPosition(targetRoot)
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local tPos = targetRoot.Position
    local myPos = myRoot.Position
    local finalPos = tPos

    if HubConfig.TeleportMode == "Under" then
        local dir = (tPos - myPos).Unit
        finalPos = tPos - dir * HubConfig.BackOffset
        finalPos = Vector3.new(finalPos.X, tPos.Y + HubConfig.UnderOffset, finalPos.Z)
    elseif HubConfig.TeleportMode == "Behind" then
        local dir = (tPos - myPos).Unit
        finalPos = tPos - dir * (HubConfig.BackOffset + 3)
        finalPos = Vector3.new(finalPos.X, tPos.Y + HubConfig.UnderOffset, finalPos.Z)
    -- Side, Random, Predict は省略（必要なら言え）
    end

    return finalPos
end

local function DoTeleport(target)
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local targetPos = CalculateTeleportPosition(target.Character.HumanoidRootPart)
    local newPos = myRoot.Position:Lerp(targetPos, HubConfig.TeleportSmooth)

    myRoot.CFrame = CFrame.new(newPos)

    if HubConfig.FaceEnemy then
        local lookPos = Vector3.new(target.Character.HumanoidRootPart.Position.X, newPos.Y, target.Character.HumanoidRootPart.Position.Z)
        myRoot.CFrame = CFrame.lookAt(newPos, lookPos)
    end
end

-- =============================================
-- ================= FAST SHOT =================
local function FireWeapon()
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end

    local mouse = LocalPlayer:GetMouse()
    
    -- 可能な限り高速で撃つ（シミュレート）
    if tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Shoot") then
        -- 多くのゲームで効く方法
        local activate = tool:FindFirstChild("Activate") or tool.Activate
        if activate then
            tool:Activate()
        end
    else
        -- マウスクリックシミュレート
        mouse.Button1Down:Fire()
        task.wait(0.001)
        mouse.Button1Up:Fire()
    end
end

-- =============================================
-- ================= MAIN LOOP =================
RunService.RenderStepped:Connect(function(dt)
    if not HubConfig.Enabled then
        Camera.CameraType = Enum.CameraType.Custom
        return
    end

    frameCounter += 1
    local target = GetClosestTarget()

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart

        -- テレポート
        if HubConfig.TeleportEnabled and (frameCounter % 1 == 0) then
            local dist = (targetRoot.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist >= HubConfig.MinDistanceToTeleport then
                DoTeleport(target)
            end
        end

        -- VFX Marker
        if HubConfig.ShowMarker and target.Character:FindFirstChild("Head") then
            if not LockMarker then
                LockMarker = Instance.new("Part")
                LockMarker.Size = Vector3.new(3,0.3,3)
                LockMarker.Color = HubConfig.MarkerColor
                LockMarker.Material = Enum.Material.Neon
                LockMarker.CanCollide = false
                LockMarker.Anchored = true
                LockMarker.Parent = workspace
                local m = Instance.new("SpecialMesh", LockMarker)
                m.MeshType = Enum.MeshType.FileMesh
                m.MeshId = "rbxassetid://3270017"
                m.Scale = Vector3.new(3,3,0.6)
            end
            local head = target.Character.Head
            LockMarker.CFrame = CFrame.new(head.Position + Vector3.new(0,3,0)) * CFrame.Angles(0, os.clock()*5, math.rad(90))
        end

        -- Fast Shot 自動連射
        if HubConfig.FastShotEnabled then
            local shouldShoot = true
            if HubConfig.FastShotOnlyTeleport and not HubConfig.TeleportEnabled then
                shouldShoot = false
            end

            if shouldShoot and tick() - lastShotTime >= HubConfig.FastShotSpeed then
                FireWeapon()
                lastShotTime = tick()
            end
        end

        -- カメラ
        currentAngle = currentAngle + (HubConfig.Speed * dt)
        local ox = math.cos(currentAngle) * HubConfig.Radius
        local oz = math.sin(currentAngle) * HubConfig.Radius
        local rawPos = targetRoot.Position + Vector3.new(ox, HubConfig.HeightOffset, oz)

        smoothedCameraPos = smoothedCameraPos and smoothedCameraPos:Lerp(rawPos, HubConfig.Smoothness) or rawPos

        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(smoothedCameraPos, targetRoot.Position)
    else
        Camera.CameraType = Enum.CameraType.Custom
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
    end
end)

-- =============================================
-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 620)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13,13,17)
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,55)
Title.BackgroundColor3 = Color3.fromRGB(20,20,28)
Title.Text = "NEXUS TELEPORT EXTREME + FAST SHOT"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title)

-- 設定ボックス関数（省略せず長く）
local function CreateConfigBox(label, y, default, key)
    local lbl = Instance.new("TextLabel", MainFrame)
    lbl.Size = UDim2.new(0.55,0,0,30)
    lbl.Position = UDim2.new(0,20,0,y)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0,100,0,28)
    box.Position = UDim2.new(1,-130,0,y)
    box.Text = tostring(default)
    box.BackgroundColor3 = Color3.fromRGB(30,30,38)
    box.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", box)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then HubConfig[key] = num end
    end)
end

-- 設定項目
CreateConfigBox("Orbit Radius", 70, HubConfig.Radius, "Radius")
CreateConfigBox("Orbit Speed", 110, HubConfig.Speed, "Speed")
CreateConfigBox("Under Offset (Y)", 150, HubConfig.UnderOffset, "UnderOffset")
CreateConfigBox("Back Offset", 190, HubConfig.BackOffset, "BackOffset")
CreateConfigBox("Teleport Smooth", 230, HubConfig.TeleportSmooth, "TeleportSmooth")
CreateConfigBox("Fast Shot Speed (秒)", 270, HubConfig.FastShotSpeed, "FastShotSpeed")

-- メインオンオフ
local MainToggle = Instance.new("TextButton", MainFrame)
MainToggle.Size = UDim2.new(1,-40,0,45)
MainToggle.Position = UDim2.new(0,20,0,320)
MainToggle.BackgroundColor3 = Color3.fromRGB(0,180,255)
MainToggle.Text = "MAIN SYSTEM: ON"
MainToggle.TextColor3 = Color3.new(1,1,1)
MainToggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", MainToggle)

MainToggle.MouseButton1Click:Connect(function()
    HubConfig.Enabled = not HubConfig.Enabled
    MainToggle.Text = HubConfig.Enabled and "MAIN SYSTEM: ON" or "MAIN SYSTEM: OFF"
    MainToggle.BackgroundColor3 = HubConfig.Enabled and Color3.fromRGB(0,180,255) or Color3.fromRGB(60,60,70)
end)

-- Teleportオンオフ
local TpToggle = Instance.new("TextButton", MainFrame)
TpToggle.Size = UDim2.new(1,-40,0,45)
TpToggle.Position = UDim2.new(0,20,0,375)
TpToggle.BackgroundColor3 = Color3.fromRGB(0,180,255)
TpToggle.Text = "UNDER TELEPORT: ON"
TpToggle.TextColor3 = Color3.new(1,1,1)
TpToggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", TpToggle)

TpToggle.MouseButton1Click:Connect(function()
    HubConfig.TeleportEnabled = not HubConfig.TeleportEnabled
    TpToggle.Text = HubConfig.TeleportEnabled and "UNDER TELEPORT: ON" or "UNDER TELEPORT: OFF"
    TpToggle.BackgroundColor3 = HubConfig.TeleportEnabled and Color3.fromRGB(0,180,255) or Color3.fromRGB(60,60,70)
end)

-- Fast Shotオンオフ
local FastToggle = Instance.new("TextButton", MainFrame)
FastToggle.Size = UDim2.new(1,-40,0,45)
FastToggle.Position = UDim2.new(0,20,0,430)
FastToggle.BackgroundColor3 = Color3.fromRGB(0,180,255)
FastToggle.Text = "FAST SHOT: ON"
FastToggle.TextColor3 = Color3.new(1,1,1)
FastToggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", FastToggle)

FastToggle.MouseButton1Click:Connect(function()
    HubConfig.FastShotEnabled = not HubConfig.FastShotEnabled
    FastToggle.Text = HubConfig.FastShotEnabled and "FAST SHOT: ON" or "FAST SHOT: OFF"
    FastToggle.BackgroundColor3 = HubConfig.FastShotEnabled and Color3.fromRGB(0,180,255) or Color3.fromRGB(60,60,70)
end)

print("👑 NEXUS TELEPORT EXTREME + FAST SHOT LOADED!")
