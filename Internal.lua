-- Roblox Studio の StarterPlayerScripts 内の LocalScript に丸ごと上書きしてくれ
-- [[ THE NEXUS OMNI-HUB : COMPLETE EDITION ]]
-- 機能：軌道周回カメラ + 滑らか補間(Lerp) + 頭上ネオンVFX + モダンUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // 統合システム設定
local HubConfig = {
    Enabled = true,
    Radius = 15,          -- ターゲットとの距離
    Speed = 2,            -- 旋回速度
    HeightOffset = 3,     -- 見下ろす高さ
    Smoothness = 0.15,    -- カメラの滑らかさ（値が小さいほどヌルヌル動く）
    ShowMarker = true,    -- ネオンエフェクトの表示
    MarkerColor = Color3.fromRGB(0, 255, 150), -- サイバーグリーン
    ToggleKey = Enum.KeyCode.K
}

-- // 内部管理用変数
local currentAngle = 0
local smoothedCameraPos = nil
local LockMarker = nil

-- // 追従ターゲット（最も近いプレイヤー）を取得する関数
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
            if player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
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

-- // マーカーエフェクト（ネオンリング）の生成・更新
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
        
        -- 光る円盤・リングに見せるためのメッシュ設定
        local mesh = Instance.new("SpecialMesh", LockMarker)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://3270017" -- ドーナツ型の公式メッシュ
        mesh.Scale = Vector3.new(2, 2, 0.5)
    end
    
    local head = targetCharacter.Head
    -- 頭上に配置し、時間経過（os.clock）でスタイリッシュに回転させる
    LockMarker.CFrame = CFrame.new(head.Position + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, os.clock() * 4, math.rad(90))
end

-- // メインフレーム更新（カメラ挙動）
RunService.RenderStepped:Connect(function(deltaTime)
    if not HubConfig.Enabled then 
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        Camera.CameraType = Enum.CameraType.Custom
        return 
    end
    
    local targetPlayer = GetClosestTarget()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = targetPlayer.Character.HumanoidRootPart
        
        -- VFXマーカーの更新
        UpdateVFXMarker(targetPlayer.Character)
        
        -- 三角関数による円軌道の計算
        currentAngle = currentAngle + (HubConfig.Speed * deltaTime)
        local offsetX = math.cos(currentAngle) * HubConfig.Radius
        local offsetZ = math.sin(currentAngle) * HubConfig.Radius
        local targetPosition = targetRoot.Position
        local rawCameraPos = targetPosition + Vector3.new(offsetX, HubConfig.HeightOffset, offsetZ)
        
        -- Lerpを使ってカメラ位置を滑らかに補間
        if not smoothedCameraPos then
            smoothedCameraPos = rawCameraPos
        else
            smoothedCameraPos = smoothedCameraPos:Lerp(rawCameraPos, HubConfig.Smoothness)
        end
        
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(smoothedCameraPos, targetPosition)
    else
        -- ターゲットがいない時は通常のカメラに戻す
        Camera.CameraType = Enum.CameraType.Custom
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        smoothedCameraPos = nil
    end
end)

-- // [[ MODERN GLOBAL GUI SYSTEM ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- ヘッダー
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Title.Text = "  WAVE-STYLE NEXUS HUB v1.0"
Title.TextColor3 = Color3.fromRGB(0, 180, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
local TitleCorner = Instance.new("UICorner", Title)

-- 設定ボックス生成用関数
local function CreateConfigBox(labelText, posY, defaultValue, configKey)
    local Label = Instance.new("TextLabel", MainFrame)
    Label.Size = UDim2.new(0.6, 0, 0, 30)
    Label.Position = UDim2.new(0, 15, 0, posY)
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Box = Instance.new("TextBox", MainFrame)
    Box.Size = UDim2.new(0, 80, 0, 25)
    Box.Position = UDim2.new(1, -95, 0, posY + 2)
    Box.Text = tostring(defaultValue)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Code
    local BoxCorner = Instance.new("UICorner", Box)
    
    Box.FocusLost:Connect(function()
        local newValue = tonumber(Box.Text)
        if newValue then
            HubConfig[configKey] = newValue
        else
            Box.Text = tostring(HubConfig[configKey])
        end
    end)
end

-- 各パーツのレイアウト配置
CreateConfigBox("Orbit Radius (距離)", 55, HubConfig.Radius, "Radius")
CreateConfigBox("Orbit Speed (速度)", 95, HubConfig.Speed, "Speed")
CreateConfigBox("Height Offset (高さ)", 135, HubConfig.HeightOffset, "HeightOffset")
CreateConfigBox("Smooth Delay (滑らかさ)", 175, HubConfig.Smoothness, "Smoothness")

-- VFXトグルボタン
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -30, 0, 35)
ToggleBtn.Position = UDim2.new(0, 15, 0, 225)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
ToggleBtn.Text = "VFX Neon Marker: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
local BtnCorner = Instance.new("UICorner", ToggleBtn)

ToggleBtn.MouseButton1Click:Connect(function()
    HubConfig.ShowMarker = not HubConfig.ShowMarker
    if HubConfig.ShowMarker then
        ToggleBtn.Text = "VFX Neon Marker: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    else
        ToggleBtn.Text = "VFX Neon Marker: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end
end)

-- UI表示切り替え（Kキー）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == HubConfig.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("👑 COMPLETE EDITION LOADED. Everything combined perfectly, Paisen!")
