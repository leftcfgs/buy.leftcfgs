-- Internal | unnamed Edition
-- optimized & full features (Fly, Noclip, Aimbot, ESP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local existing = game.CoreGui:FindFirstChild("Internal")
if existing then existing:Destroy() end

-- --- unnamed スタイル設定 ---
_G.Settings = {
    -- Aimbot
    Aimbot = false,
    AimbotKey = Enum.KeyCode.E,
    HitPart = "HumanoidRootPart", -- "Head", "HumanoidRootPart"
    FOV = 150,
    ShowFOV = true,
    Smooth = 0.15,
    -- ESP
    ESP = false,
    Box = false,
    Name = false,
    -- Movement
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    -- Light Optimization
    MaxDist = 500,
}
local S = _G.Settings

-- --- unnamed UI 作成 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Internal"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 420)
Main.Position = UDim2.new(0.5, -150, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- 深い黒
Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true

-- unnamedスタイルの赤いヘッダー線
local HeaderLine = Instance.new("Frame", Main)
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 0, 50) -- 赤
HeaderLine.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 2)
Title.Text = "  unnamed" -- アネームド風に少しスペース
Title.TextColor3 = Color3.new(1, 1, 1) -- 白
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- 少し明るい黒
Title.Font = Enum.Font.Code

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 550)
Scroll.ScrollBarThickness = 3

-- --- unnamedスタイルのUIパーツ作成関数 ---
local function createTgl(txt, key, y)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.Text = "  " .. txt .. ": OFF" -- 左寄せ用スペース
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Code
    
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF")
        btn.TextColor3 = S[key] and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
        
        -- Fly/Noclipの初期化処理
        if key == "Fly" then toggleFly() end
        if key == "Noclip" then toggleNoclip() end
    end)
    return btn
end

local function createBox(txt, key, y, placeholder)
    local box = Instance.new("TextBox", Scroll)
    box.Size = UDim2.new(1, -10, 0, 30)
    box.Position = UDim2.new(0, 5, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Text = "  " .. txt .. ": " .. tostring(S[key])
    box.PlaceholderText = placeholder or ""
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Font = Enum.Font.Code
    
    box.FocusLost:Connect(function()
        local val = box.Text:match(": (%d+)") or box.Text:match(": ([%d%.]+)")
        local n = tonumber(val)
        if n then
            S[key] = n
            box.Text = "  " .. txt .. ": " .. tostring(S[key])
        end
    end)
    return box
end

local function createPartBtn(y)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.Text = "  Target Part: Body"
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Code
    
    btn.MouseButton1Click:Connect(function()
        if S.HitPart == "HumanoidRootPart" then
            S.HitPart = "Head"
            btn.Text = "  Target Part: Head"
        else
            S.HitPart = "HumanoidRootPart"
            btn.Text = "  Target Part: Body"
        end
    end)
end

-- --- UI配置 ---
local AimTitle = Instance.new("TextLabel", Scroll)
AimTitle.Size = UDim2.new(1, 0, 0, 25); AimTitle.Position = UDim2.new(0,0,0,0); AimTitle.Text = "== Aimbot =="; AimTitle.TextColor3 = Color3.fromRGB(255,0,50); AimTitle.BackgroundTransparency = 1; AimTitle.Font = Enum.Font.Code
createTgl("Aimbot", "Aimbot", 25)
createPartBtn(55) -- HitPart復活
createTgl("Show FOV", "ShowFOV", 85)
createBox("FOV Size", "FOV", 115, "10 - 500") -- FOV数値入力復活
createBox("Smooth", "Smooth", 145, "0.01 - 1")

local ESPTitle = Instance.new("TextLabel", Scroll)
ESPTitle.Size = UDim2.new(1, 0, 0, 25); ESPTitle.Position = UDim2.new(0,0,0,185); ESPTitle.Text = "== Visuals =="; ESPTitle.TextColor3 = Color3.fromRGB(255,0,50); ESPTitle.BackgroundTransparency = 1; ESPTitle.Font = Enum.Font.Code
createTgl("Master ESP", "ESP", 210)
createTgl("- Box", "Box", 240)
createTgl("- Name", "Name", 270)

local MovTitle = Instance.new("TextLabel", Scroll)
MovTitle.Size = UDim2.new(1, 0, 0, 25); MovTitle.Position = UDim2.new(0,0,0,310); MovTitle.Text = "== Movement =="; MovTitle.TextColor3 = Color3.fromRGB(255,0,50); MovTitle.BackgroundTransparency = 1; MovTitle.Font = Enum.Font.Code
createTgl("Fly", "Fly", 335) -- Fly追加
createBox("Fly Speed", "FlySpeed", 365, "10 - 200")
createTgl("Noclip", "Noclip", 395) -- Noclip追加

-- --- ロジック ---

-- 描画オブジェクト
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.new(1,0,0); FOVCircle.Visible = false
local ESP_Pool = {}

-- Aimbot & ESP ループ (UE方式軽量化入り)
RunService.RenderStepped:Connect(function()
    -- FOV円
    FOVCircle.Visible = S.ShowFOV
    FOVCircle.Radius = S.FOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    -- Aimbot (視界内の近い敵のみ)
    if S.Aimbot then
        local target, lastDist = nil, S.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local root = p.Character:FindFirstChild(S.HitPart)
                local hum = p.Character:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    if dist < S.MaxDist then -- 距離制限
                        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen then -- UE方式：画面に映ってる奴だけ
                            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            if mag < lastDist then lastDist = mag; target = p end
                        end
                    end
                end
            end
        end
        if target and mousemoverel then
            local tPos = Camera:WorldToViewportPoint(target.Character[S.HitPart].Position)
            mousemoverel((tPos.X - Mouse.X) * S.Smooth, (tPos.Y - (Mouse.Y + 36)) * S.Smooth)
        end
    end

    -- ESP (距離と視界で制限)
    if not S.ESP then
        for _, o in pairs(ESP_Pool) do o.B.Visible = false; o.N.Visible = false end
        return
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not ESP_Pool[p.Name] then
                ESP_Pool[p.Name] = { B = Drawing.new("Square"), N = Drawing.new("Text") }
                local o = ESP_Pool[p.Name]
                o.B.Thickness = 1; o.B.Color = Color3.fromRGB(255,0,50) -- unnamed赤
                o.N.Size = 13; o.N.Center = true; o.N.Outline = true; o.N.Color = Color3.new(1,1,1)
            end
            
            local o = ESP_Pool[p.Name]
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")

            if root and hum and hum.Health > 0 then
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                if dist < S.MaxDist then -- 遠すぎる奴は無視
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local sizeX, sizeY = 2000/pos.Z, 3000/pos.Z
                        o.B.Visible = S.Box; o.B.Size = Vector2.new(sizeX, sizeY); o.B.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                        o.N.Visible = S.Name; o.N.Text = p.Name; o.N.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 15)
                        continue
                    end
                end
            end
            o.B.Visible = false; o.N.Visible = false
        end
    end
end)

-- --- Movement ロジック (Fly & Noclip) ---

local FlyDrawing = nil
function toggleFly()
    if S.Fly then
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        
        -- Fly用の物理オブジェクト
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyBV"; bv.MaxForce = Vector3.new(1,1,1) * math.huge; bv.Velocity = Vector3.new(0,0,0)
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "FlyBG"; bg.MaxTorque = Vector3.new(1,1,1) * math.huge; bg.CFrame = root.CFrame
        
        hum.PlatformStand = true -- アニメーション停止
        
        -- Fly制御ループ
        FlyDrawing = RunService.RenderStepped:Connect(function()
            char = LocalPlayer.Character; root = char and char:FindFirstChild("HumanoidRootPart")
            bv = root and root:FindFirstChild("FlyBV"); bg = root and root:FindFirstChild("FlyBG")
            if not root or not bv or not bg then return end
            
            bg.CFrame = Camera.CFrame
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            
            bv.Velocity = move.Unit * S.FlySpeed
            if move == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end -- 停止
        end)
    else
        if FlyDrawing then FlyDrawing:Disconnect(); FlyDrawing = nil end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum then hum.PlatformStand = false end
        if root then
            if root:FindFirstChild("FlyBV") then root.FlyBV:Destroy() end
            if root:FindFirstChild("FlyBG") then root.FlyBG:Destroy() end
        end
    end
end

local NoclipDrawing = nil
function toggleNoclip()
    if S.Noclip then
        NoclipDrawing = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipDrawing then NoclipDrawing:Disconnect(); NoclipDrawing = nil end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

-- スポーン時にMovementリセット
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if S.Fly then S.Fly = false; toggleFly() end
    if S.Noclip then S.Noclip = false; toggleNoclip() end
end)
