-- Roblox Studio の StarterPlayerScripts 内の LocalScript に丸ごと上書き
-- [[ THE NEXUS OMNI-HUB : TELEPORT EXTREME + ULTRA FAST SHOT FINAL ]]

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
    FastShotRate = 0.022,           -- ここを下げれば下げるほど連射が速くなる
    FastShotOnlyWhenTeleport = true,
}

local currentAngle = 0
local smoothedCameraPos = nil
local LockMarker = nil
local lastShotTime = 0

-- 最寄りターゲット取得
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

-- テレポート実行
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

-- 超高速射撃
local function UltraFastShot()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end

    -- メインの連射方法
    tool:Activate()

    -- RemoteEventを全力で探して発火
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function()
                v:FireServer()
            end)
        end
    end
end

-- VFXマーカー
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

        -- テレポート
        if HubConfig.TeleportEnabled then
            DoTeleport(target)
        end

        -- VFX
        UpdateVFX(target.Character)

        -- Fast Shot
        if HubConfig.FastShotEnabled then
            local canShoot = not HubConfig.FastShotOnlyWhenTeleport or HubConfig.TeleportEnabled
            if canShoot and (tick() - lastShotTime >= HubConfig.FastShotRate) then
                UltraFastShot()
                lastShotTime = tick()
            end
        end

        -- カメラ周回
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

-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 580)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,55)
Title.BackgroundColor3 = Color3.fromRGB(20,20,30)
Title.Text = "NEXUS TELEPORT EXTREME + ULTRA FAST SHOT"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15.5
Instance.new("UICorner", Title)

local function CreateBox(label, y, default, key)
    local lbl = Instance.new("TextLabel", MainFrame)
    lbl.Position = UDim2.new(0,20,0,y)
    lbl.Size = UDim2.new(0.5,0,0,30)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(190,190,190)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", MainFrame)
    box.Position = UDim2.new(1,-140,0,y)
    box.Size = UDim2.new(0,120,0,28)
    box.Text = tostring(default)
    box.BackgroundColor3 = Color3.fromRGB(28,28,38)
    box.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", box)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then HubConfig[key] = num end
    end)
end

CreateBox("FastShot Rate", 80, HubConfig.FastShotRate, "FastShotRate")
CreateBox("Under Offset", 120, HubConfig.UnderOffset, "UnderOffset")
CreateBox("Back Offset", 160, HubConfig.BackOffset, "BackOffset")
CreateBox("Teleport Smooth", 200, HubConfig.TeleportSmooth, "TeleportSmooth")

-- トグル
local function MakeToggle(text, y, key, onText)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1,-40,0,48)
    btn.Position = UDim2.new(0,20,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    btn.Text = onText
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        HubConfig[key] = not HubConfig[key]
        btn.Text = HubConfig[key] and onText or onText:gsub("ON", "OFF")
        btn.BackgroundColor3 = HubConfig[key] and Color3.fromRGB(0,170,255) or Color3.fromRGB(65,65,75)
    end)
end

MakeToggle("MAIN SYSTEM", 270, "Enabled", "MAIN SYSTEM: ON")
MakeToggle("TELEPORT", 330, "TeleportEnabled", "TELEPORT: ON")
MakeToggle("ULTRA FAST SHOT", 390, "FastShotEnabled", "ULTRA FAST SHOT: ON")

print("👑 NEXUS EXTREME LOADED - 繋げて使え")

-- ここから続き

-- 追加設定（さらに細かく調整できるように）
HubConfig.Extra = {
    CameraShake = false,
    MarkerSpinSpeed = 7,
    AutoFaceStrength = 1,
}

-- より強力なFastShot（複数方法同時実行）
local function UltraFastShotAdvanced()
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    -- 1. 通常Activate
    pcall(function() tool:Activate() end)

    -- 2. すべてのRemoteEventを連打
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj:FireServer()
                obj:FireServer() -- 2回撃つ
            end)
        end
    end

    -- 3. ツール内のBindableEventも起動
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("BindableEvent") and (obj.Name:lower():find("shoot") or obj.Name:lower():find("fire")) then
            pcall(function() obj:Fire() end)
        end
    end
end

-- メインループの続き（より安定させる）
RunService.Heartbeat:Connect(function(dt)
    if not HubConfig.Enabled then
        Camera.CameraType = Enum.CameraType.Custom
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        return
    end

    local target = GetClosestTarget()

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart

        -- テレポート
        if HubConfig.TeleportEnabled then
            DoTeleport(target)
        end

        -- VFX
        UpdateVFX(target.Character)

        -- Ultra Fast Shot
        if HubConfig.FastShotEnabled then
            local canShoot = true
            if HubConfig.FastShotOnlyWhenTeleport and not HubConfig.TeleportEnabled then
                canShoot = false
            end

            if canShoot and (tick() - lastShotTime >= HubConfig.FastShotRate) then
                UltraFastShotAdvanced()   -- 強化版を使用
                lastShotTime = tick()
            end
        end

        -- カメラ処理
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
        smoothedCameraPos = nil
    end
end)

print("👑 NEXUS TELEPORT EXTREME + ULTRA FAST SHOT COMPLETE")
print("貼り付け完了！ テストしてみてくれ")
