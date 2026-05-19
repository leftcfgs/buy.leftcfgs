-- Roblox Studio の StarterPlayerScripts 内の LocalScript に配置してくれ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // システム設定（UIからリアルタイムに変更可能）
local CameraConfig = {
    Enabled = true,
    Radius = 15,       -- ターゲットとの距離
    Speed = 2,         -- 旋回速度
    HeightOffset = 3,  -- 見下ろす高さ
    ToggleKey = Enum.KeyCode.K
}

-- // 旋回角度のカウント用変数
local currentAngle = 0

-- // 追従するターゲット（自分以外の最寄りのプレイヤー）を探す関数
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

-- // カメラーワークの毎フレーム更新処理
RunService.RenderStepped:Connect(function(deltaTime)
    if not CameraConfig.Enabled then return end
    
    local targetPlayer = GetClosestTarget()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = targetPlayer.Character.HumanoidRootPart
        
        -- カメラの回転角度を進める
        currentAngle = currentAngle + (CameraConfig.Speed * deltaTime)
        
        -- 円運動の座標計算（三角関数）
        local offsetX = math.cos(currentAngle) * CameraConfig.Radius
        local offsetZ = math.sin(currentAngle) * CameraConfig.Radius
        
        -- ターゲットの頭上・周囲の新しいカメラ位置を決定
        local targetPosition = targetRoot.Position
        local newCameraPosition = targetPosition + Vector3.new(offsetX, CameraConfig.HeightOffset, offsetZ)
        
        -- カメラの座標を設定（常にターゲットを凝視する）
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(newCameraPosition, targetPosition)
    else
        -- ターゲットがいない場合は通常のカメラ操作に戻す
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

-- // [[ モダンUI構築（スクリプトでのGUI自動生成） ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 200)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- マウスでドラッグ移動可能

-- 角丸効果
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- ヘッダータイトル
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = "  MODERN CAMERA CONTROLLER"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
local TitleCorner = Instance.new("UICorner", Title)

-- 設定入力項目を作る関数
local function CreateConfigBox(labelText, posY, defaultValue, configKey)
    local Label = Instance.new("TextLabel", MainFrame)
    Label.Size = UDim2.new(0.6, 0, 0, 30)
    Label.Position = UDim2.new(0, 15, 0, posY)
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Box = Instance.new("TextBox", MainFrame)
    Box.Size = UDim2.new(0, 80, 0, 25)
    Box.Position = UDim2.new(1, -95, 0, posY + 2)
    Box.Text = tostring(defaultValue)
    Box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Code
    local BoxCorner = Instance.new("UICorner", Box)
    
    -- 数値が入力されて確定した時の処理
    Box.FocusLost:Connect(function()
        local newValue = tonumber(Box.Text)
        if newValue then
            CameraConfig[configKey] = newValue
        else
            Box.Text = tostring(CameraConfig[configKey]) -- 無効な入力なら元に戻す
        end
    end)
end

-- UIパーツの配置
CreateConfigBox("Orbit Radius (距離)", 55, CameraConfig.Radius, "Radius")
CreateConfigBox("Orbit Speed (速度)", 95, CameraConfig.Speed, "Speed")
CreateConfigBox("Height Offset (高さ)", 135, CameraConfig.HeightOffset, "HeightOffset")

-- [K] キーでUI全体の表示・非表示を切り替える
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CameraConfig.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✨ Modern Camera & UI System Loaded. Press 'K' to toggle UI.")
-- [[ THE NEXUS CAMERA HUB - EXPANSION PACK ]]
-- ターゲットへの滑らかな追従(Lerp)と、頭上ネオンエフェクトを追加

local TweenService = game:GetService("TweenService")

-- // 拡張用追加設定
local VisualConfig = {
    ShowMarker = true,
    MarkerColor = Color3.fromRGB(0, 255, 150), -- サイバーグリーン
    Smoothness = 0.15, -- 値が小さいほどカメラが『ヌルッ』と滑らかに動く（0.01 ～ 1.0）
    ActiveTab = "Main"
}

-- // エフェクト用パーツの生成管理
local LockMarker = nil

local function CreateOrUpdateMarker(targetCharacter)
    if not VisualConfig.ShowMarker or not targetCharacter or not targetCharacter:FindFirstChild("Head") then
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        return
    end
    
    -- マーカーがまだ無い場合は作成
    if not LockMarker or not LockMarker.Parent then
        LockMarker = Instance.new("Part")
        LockMarker.Size = Vector3.new(2, 0.2, 2)
        LockMarker.Shape = Enum.PartType.Cylinder
        LockMarker.Color = VisualConfig.MarkerColor
        LockMarker.Material = Enum.Material.Neon
        LockMarker.CanCollide = false
        LockMarker.Anchored = true
        LockMarker.Parent = workspace
        
        -- 光るリングっぽく見せるための穴あきメッシュ（オプション）
        local mesh = Instance.new("SpecialMesh", LockMarker)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://3270017" -- ドーナツ型の公式メッシュ
        mesh.Scale = Vector3.new(2, 2, 0.5)
    end
    
    -- ターゲットの頭上に配置して常に回転させる
    local head = targetCharacter.Head
    LockMarker.CFrame = CFrame.new(head.Position + Vector3.new(0, 2, 0)) * CFrame.Angles(0, os.clock() * 5, math.rad(90))
end

-- // カメラーワーク処理の「滑らか化」アップデート
-- （前のスクリプトのRenderStepped部分をこのLerp版に強化して処理するぜ）
local smoothedCameraPos = nil

RunService.RenderStepped:Connect(function(deltaTime)
    if not CameraConfig.Enabled then 
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        return 
    end
    
    local targetPlayer = GetClosestTarget()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = targetPlayer.Character.HumanoidRootPart
        
        -- マーカーエフェクトの更新
        CreateOrUpdateMarker(targetPlayer.Character)
        
        -- 円運動の位置計算
        currentAngle = currentAngle + (CameraConfig.Speed * deltaTime)
        local offsetX = math.cos(currentAngle) * CameraConfig.Radius
        local offsetZ = math.sin(currentAngle) * CameraConfig.Radius
        local targetPosition = targetRoot.Position
        local rawTargetCameraPos = targetPosition + Vector3.new(offsetX, CameraConfig.HeightOffset, offsetZ)
        
        -- 【ここが重要！】Lerp（線形補間）を使って、現在のカメラ位置から目標位置まで滑らかに移動させる
        if not smoothedCameraPos then
            smoothedCameraPos = rawTargetCameraPos
        else
            smoothedCameraPos = smoothedCameraPos:Lerp(rawTargetCameraPos, VisualConfig.Smoothness)
        end
        
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(smoothedCameraPos, targetPosition)
    else
        Camera.CameraType = Enum.CameraType.Custom
        if LockMarker then LockMarker:Destroy(); LockMarker = nil end
        smoothedCameraPos = nil
    end
end)

-- // [[ UI拡張：タブシステムの追加 ]]
-- （既存のMainFrameの下部に新しい設定項目を追加するぜ）
MainFrame.Size = UDim2.new(0, 320, 0, 260) -- UIの縦幅を少し広げる

-- エフェクトON/OFF用のトグルボタン
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -30, 0, 35)
ToggleBtn.Position = UDim2.new(0, 15, 0, 180)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Text = "Toggle VFX Marker: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
local BtnCorner = Instance.new("UICorner", ToggleBtn)

ToggleBtn.MouseButton1Click:Connect(function()
    VisualConfig.ShowMarker = not VisualConfig.ShowMarker
    if VisualConfig.ShowMarker then
        ToggleBtn.Text = "Toggle VFX Marker: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    else
        ToggleBtn.Text = "Toggle VFX Marker: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end
end)

-- 滑らかさ(Smoothness)を調整する入力ボックスも追加
CreateConfigBox("Smooth Delay (滑らかさ)", 220, VisualConfig.Smoothness, "Smoothness")

print("🚀 Nexus Expansion Pack Loaded! Smoothed Camera and VFX are active.")
