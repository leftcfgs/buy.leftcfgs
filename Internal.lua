-- Internal | unnamed Edition (Auto-Recovery & Keybind Update)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local existing = game.CoreGui:FindFirstChild("Internal")
if existing then existing:Destroy() end

-- --- 設定 ---
_G.Settings = {
    Aimbot = false,
    AimbotKey = Enum.KeyCode.E,
    AimbotKeyType = "Keyboard",
    HitPart = "HumanoidRootPart",
    FOV = 150,
    ShowFOV = true,
    Smooth = 0.15,
    ESP = false,
    Box = false,
    Name = false,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    MaxDist = 500,
    Binding = false
}
local S = _G.Settings

-- --- UIの土台 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Internal"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 420)
Main.Position = UDim2.new(0.5, -150, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true

local HeaderLine = Instance.new("Frame", Main)
HeaderLine.Size = UDim2.new(1, 0, 0, 2); HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 0, 50); HeaderLine.BorderSizePixel = 0
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30); Title.Position = UDim2.new(0, 0, 0, 2); Title.Text = "  unnamed"; Title.TextColor3 = Color3.new(1, 1, 1); Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Title.Font = Enum.Font.Code
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40); Scroll.Position = UDim2.new(0, 5, 0, 35); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 0, 550); Scroll.ScrollBarThickness = 3

-- --- UIパーツ作成 ---
local function createTgl(txt, key, y)
    task.wait(0.02)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -10, 0, 30); btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.TextColor3 = S[key] and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
    btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF"); btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Font = Enum.Font.Code
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF")
        btn.TextColor3 = S[key] and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
        if key == "Fly" then applyFly() end
        if key == "Noclip" then applyNoclip() end
    end)
    return btn
end

-- キーバインド専用ボタン
local KeyBtn = Instance.new("TextButton", Scroll)
KeyBtn.Size = UDim2.new(1, -10, 0, 30); KeyBtn.Position = UDim2.new(0, 5, 0, 55)
KeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); KeyBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
KeyBtn.Text = "  Aimbot Key: E"; KeyBtn.TextXAlignment = Enum.TextXAlignment.Left; KeyBtn.Font = Enum.Font.Code
KeyBtn.MouseButton1Click:Connect(function()
    S.Binding = true
    KeyBtn.Text = "  Press any key..."
end)

-- --- 起動シーケンス ---
createTgl("Aimbot", "Aimbot", 25)
-- (KeyBtnは25の次、55に配置済み)
createTgl("Show FOV", "ShowFOV", 85)
createTgl("Master ESP", "ESP", 140)
createTgl("- Box", "Box", 170)
createTgl("- Name", "Name", 200)
createTgl("Fly", "Fly", 260)
createTgl("Noclip", "Noclip", 290)

-- --- ロジック ---

-- Aimbot Keybind 処理
UserInputService.InputBegan:Connect(function(input)
    if S.Binding then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            S.AimbotKey = input.KeyCode; S.AimbotKeyType = "Keyboard"
            KeyBtn.Text = "  Aimbot Key: " .. input.KeyCode.Name
        elseif input.UserInputType.Name:find("MouseButton") then
            S.AimbotKey = input.UserInputType; S.AimbotKeyType = "Mouse"
            KeyBtn.Text = "  Aimbot Key: " .. input.UserInputType.Name
        end
        S.Binding = false
    end
end)

-- Movement 自動復旧ロジック (applyFly / applyNoclip)
function applyFly()
    if _G.FlyLoop then _G.FlyLoop:Disconnect(); _G.FlyLoop = nil end
    local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then if root:FindFirstChild("FlyBV") then root.FlyBV:Destroy() end if root:FindFirstChild("FlyBG") then root.FlyBG:Destroy() end end
    
    if S.Fly and char and root then
        local bv = Instance.new("BodyVelocity", root); bv.Name = "FlyBV"; bv.MaxForce = Vector3.new(1,1,1) * math.huge
        local bg = Instance.new("BodyGyro", root); bg.Name = "FlyBG"; bg.MaxTorque = Vector3.new(1,1,1) * math.huge
        char.Humanoid.PlatformStand = true
        _G.FlyLoop = RunService.RenderStepped:Connect(function()
            bg.CFrame = Camera.CFrame
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            bv.Velocity = move.Unit * S.FlySpeed
            if move == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
        end)
    elseif char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

function applyNoclip()
    if _G.NoclipLoop then _G.NoclipLoop:Disconnect(); _G.NoclipLoop = nil end
    if S.Noclip then
        _G.NoclipLoop = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        end)
    end
end

-- 【重要】リスポーン時の自動再適用
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1) -- キャラクタが完全にロードされるのを待つ
    if S.Fly then applyFly() end
    if S.Noclip then applyNoclip() end
end)

-- --- Aimbot & ESP (軽量版継続) ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.new(1,0,0); FOVCircle.Visible = false
local ESP_Pool = {}

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOV; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    local isDown = false
    if S.AimbotKeyType == "Keyboard" then isDown = UserInputService:IsKeyDown(S.AimbotKey)
    else isDown = UserInputService:IsMouseButtonPressed(S.AimbotKey) end

    if S.Aimbot and isDown then
        local target, lastDist = nil, S.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.HitPart) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character[S.HitPart].Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < lastDist then lastDist = mag; target = p end
                end
            end
        end
        if target and mousemoverel then
            local tPos = Camera:WorldToViewportPoint(target.Character[S.HitPart].Position)
            mousemoverel((tPos.X - Mouse.X) * S.Smooth, (tPos.Y - (Mouse.Y + 36)) * S.Smooth)
        end
    end

    if S.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen and (root.Position - Camera.CFrame.Position).Magnitude < S.MaxDist then
                    if not ESP_Pool[p.Name] then
                        ESP_Pool[p.Name] = { B = Drawing.new("Square"), N = Drawing.new("Text") }
                        ESP_Pool[p.Name].B.Color = Color3.new(1,0,0); ESP_Pool[p.Name].B.Thickness = 1
                        ESP_Pool[p.Name].N.Color = Color3.new(1,1,1); ESP_Pool[p.Name].N.Size = 13; ESP_Pool[p.Name].N.Outline = true; ESP_Pool[p.Name].N.Center = true
                    end
                    local o = ESP_Pool[p.Name]
                    local sizeX, sizeY = 2000/pos.Z, 3000/pos.Z
                    o.B.Visible = S.Box; o.B.Size = Vector2.new(sizeX, sizeY); o.B.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    o.N.Visible = S.Name; o.N.Text = p.Name; o.N.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 15)
                    continue
                end
            end
            if ESP_Pool[p.Name] then ESP_Pool[p.Name].B.Visible = false; ESP_Pool[p.Name].N.Visible = false end
        end
    end
end)
