-- Roblox Studio の StarterPlayerScripts 内の LocalScript に丸ごと上書き
-- [[ THE NEXUS OMNI-HUB : COMPLETE EDITION + UNDER ENEMY TELEPORT ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // 統合システム設定
local HubConfig = {
    Enabled = true,
    Radius = 15,
    Speed = 2,
    HeightOffset = 3,
    Smoothness = 0.15,
    ShowMarker = true,
    MarkerColor = Color3.fromRGB(0, 255, 150),
    ToggleKey = Enum.KeyCode.K,
    
    -- 真下テレポート設定
    TeleportEnabled = true,     -- ← これがメインのオンオフ
    UnderOffset = -3.5,         -- 敵の真下からのYオフセット
    FaceEnemy = true,           -- 敵の方を向く
}

-- // 内部管理用変数
local currentAngle = 0
local smoothedCameraPos = nil
local LockMarker = nil

-- // 追従ターゲット取得
local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myCharacter = LocalPlayer.Character
   
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
   
    local myPos = myCharacter.HumanoidRootPart.Position
   
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPos = player.Character.HumanoidRootPart.Position
                local distance = (targetPos - myPos).Magnitude
               
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- // 敵の真下にテレポート
local function TeleportUnderEnemy(targetPlayer)
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    local root = myChar.HumanoidRootPart
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    
    local targetPos = targetRoot.Position
    local newPos = Vector3.new(targetPos.X, targetPos.Y + HubConfig.UnderOffset, targetPos.Z)
    
    root.CFrame = CFrame.new(newPos)
    
    if HubConfig.FaceEnemy then
        local lookPos = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        root.CFrame = CFrame.lookAt(root.Position, lookPos)
    end
end

-- // VFXマーカー
local function UpdateVFXMarker(targetCharacter)
    if not HubConfig.ShowMarker or not targetCharacter or not targetCharacter:FindFirstChild("Head") then
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        return
    end
   
    if not LockMarker or not LockMarker.Parent then
        LockMarker = Instance.new("Part")
        LockMarker.Size = Vector3.new(2, 0.2, 2)
        LockMarker.Color = HubConfig.MarkerColor
        LockMarker.Material = Enum.Material.Neon
        LockMarker.CanCollide = false
        LockMarker.Anchored = true
        LockMarker.Parent = workspace
       
        local mesh = Instance.new("SpecialMesh", LockMarker)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://3270017"
        mesh.Scale = Vector3.new(2, 2, 0.5)
    end
   
    local head = targetCharacter.Head
    LockMarker.CFrame = CFrame.new(head.Position + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, os.clock() * 4, math.rad(90))
end

-- // メインフレーム更新
RunService.RenderStepped:Connect(function(deltaTime)
    if not HubConfig.Enabled then
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        Camera.CameraType = Enum.CameraType.Custom
        return
    end
   
    local targetPlayer = GetClosestTarget()
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = targetPlayer.Character.HumanoidRootPart
       
        UpdateVFXMarker(targetPlayer.Character)
        
        -- 真下テレポート（オンオフ対応）
        if HubConfig.TeleportEnabled then
            TeleportUnderEnemy(targetPlayer)
        end
        
        -- カメラの周回
        currentAngle = currentAngle + (HubConfig.Speed * deltaTime)
        local offsetX = math.cos(currentAngle) * HubConfig.Radius
        local offsetZ = math.sin(currentAngle) * HubConfig.Radius
        local targetPosition = targetRoot.Position
        local rawCameraPos = targetPosition + Vector3.new(offsetX, HubConfig.HeightOffset, offsetZ)
       
        if not smoothedCameraPos then
            smoothedCameraPos = rawCameraPos
        else
            smoothedCameraPos = smoothedCameraPos:Lerp(rawCameraPos, HubConfig.Smoothness)
        end
       
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(smoothedCameraPos, targetPosition)
    else
        Camera.CameraType = Enum.CameraType.Custom
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        smoothedCameraPos = nil
    end
end)

-- // GUI部分
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 380)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Title.Text = " NEXUS HUB + UNDER TELEPORT"
Title.TextColor3 = Color3.fromRGB(0, 180, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title)

local function CreateConfigBox(labelText, posY, defaultValue, configKey)
    local Label = Instance.new("TextLabel", MainFrame)
    Label.Size = UDim2.new(0.62, 0, 0, 30)
    Label.Position = UDim2.new(0, 15, 0, posY)
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Box = Instance.new("TextBox", MainFrame)
    Box.Size = UDim2.new(0, 85, 0, 25)
    Box.Position = UDim2.new(1, -105, 0, posY + 2)
    Box.Text = tostring(defaultValue)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Code
    Instance.new("UICorner", Box)
   
    Box.FocusLost:Connect(function()
        local newValue = tonumber(Box.Text)
        if newValue then HubConfig[configKey] = newValue end
    end)
end

CreateConfigBox("Orbit Radius", 55, HubConfig.Radius, "Radius")
CreateConfigBox("Orbit Speed", 95, HubConfig.Speed, "Speed")
CreateConfigBox("Height Offset", 135, HubConfig.HeightOffset, "HeightOffset")
CreateConfigBox("Smoothness", 175, HubConfig.Smoothness, "Smoothness")
CreateConfigBox("Under Offset (Y)", 215, HubConfig.UnderOffset, "UnderOffset")

-- === オンオフ切り替えボタン ===
local TeleportToggle = Instance.new("TextButton", MainFrame)
TeleportToggle.Size = UDim2.new(1, -30, 0, 40)
TeleportToggle.Position = UDim2.new(0, 15, 0, 260)
TeleportToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
TeleportToggle.Text = "UNDER TELEPORT: ON"
TeleportToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportToggle.Font = Enum.Font.GothamBold
TeleportToggle.TextSize = 14
Instance.new("UICorner", TeleportToggle)

TeleportToggle.MouseButton1Click:Connect(function()
    HubConfig.TeleportEnabled = not HubConfig.TeleportEnabled
    if HubConfig.TeleportEnabled then
        TeleportToggle.Text = "UNDER TELEPORT: ON"
        TeleportToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    else
        TeleportToggle.Text = "UNDER TELEPORT: OFF"
        TeleportToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == HubConfig.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("👑 NEXUS HUB + UNDER TELEPORT LOADED! (オンオフ追加済)")
