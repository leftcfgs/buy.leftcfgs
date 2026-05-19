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
