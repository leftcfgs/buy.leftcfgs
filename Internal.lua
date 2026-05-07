-- Internal | unnamed God Edition (Anti-Fall / Hover UG)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local existing = game.CoreGui:FindFirstChild("UnnamedUltimate")
if existing then existing:Destroy() end

-- --- 全設定 ---
_G.Settings = {
    Aimbot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotMode = "Hold",
    HitPart = "HumanoidRootPart",
    FOV = 150,
    ShowFOV = true,
    Smooth = 0.15,
    ESP = false,
    Box = false,
    Name = false,
    Dist = false,
    Weapon = false,
    MaxDist = 1000,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Underground = false,
    UG_Offset = -5, -- ぱいせん指定の深さ
    MenuKey = Enum.KeyCode.Insert
}
local S = _G.Settings

-- --- UIベース ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "UnnamedUltimate"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 600); Main.Position = UDim2.new(0.5, -250, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.Visible = false
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 3); Header.BackgroundColor3 = Color3.fromRGB(255, 0, 80); Header.BorderSizePixel = 0

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -40); Content.Position = UDim2.new(0, 10, 0, 30)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 5; Content.CanvasSize = UDim2.new(0, 0, 0, 1200)

local function createTgl(txt, key, y)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 35); btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.TextColor3 = S[key] and Color3.new(1,1,1) or Color3.new(0.6,0.6,0.6)
    btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF"); btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Font = Enum.Font.Code
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF")
        btn.TextColor3 = S[key] and Color3.new(1,1,1) or Color3.new(0.6,0.6,0.6)
        if key == "Fly" then applyFly() end
        if key == "Underground" then applyUG() end
    end)
end

local function createInput(txt, key, y)
    local box = Instance.new("TextBox", Content)
    box.Size = UDim2.new(1, -10, 0, 35); box.Position = UDim2.new(0, 5, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box.TextColor3 = Color3.new(1, 1, 1); box.Font = Enum.Font.Code
    box.Text = "  " .. txt .. ": " .. tostring(S[key]); box.TextXAlignment = Enum.TextXAlignment.Left
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text:match("-?%d+"))
        if val then S[key] = val; box.Text = "  " .. txt .. ": " .. tostring(S[key]) end
    end)
end

-- --- 段階的ロードシステム (Sequential Loading) ---
task.spawn(function()
    task.wait(2.0) -- 全体起動2秒遅延
    Main.Visible = true
    
    task.wait(1.0) -- 3秒時点
    createTgl("Aimbot Master", "Aimbot", 10)
    createTgl("Show FOV Circle", "ShowFOV", 50)
    createInput("FOV Radius", "FOV", 90)
    createTgl("Master ESP", "ESP", 140)
    createTgl("Draw Box", "Box", 180)
    createTgl("Draw Name", "Name", 220)
    createTgl("Draw Distance", "Dist", 260)

    task.wait(1.0) -- 4秒時点
    createTgl("Fly Enabled", "Fly", 310)
    createInput("Fly Speed", "FlySpeed", 350)
    createTgl("Noclip (Anti-Fall Mode)", "Noclip", 400)
    createTgl("Underground (Hover Lock)", "Underground", 440)
    createInput("UG Depth Offset", "UG_Offset", 480)
    
    local MenuKeyBtn = Instance.new("TextButton", Content)
    MenuKeyBtn.Size = UDim2.new(1,-10,0,35); MenuKeyBtn.Position = UDim2.new(0,5,0,530); MenuKeyBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); MenuKeyBtn.Text = "  Menu Key: Insert"; MenuKeyBtn.TextColor3 = Color3.new(1,1,1); MenuKeyBtn.TextXAlignment = Enum.TextXAlignment.Left; MenuKeyBtn.Font = Enum.Font.Code
end)

-- --- 改良版 Underground (飛行の力で高度維持) ---
function applyUG()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if _G.UGLoop then _G.UGLoop:Disconnect(); _G.UGLoop = nil end
    if root:FindFirstChild("UG_BV") then root.UG_BV:Destroy() end

    if S.Underground then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "UG_BV"
        bv.MaxForce = Vector3.new(0, math.huge, 0) -- Y軸（高さ）だけを支配
        bv.Velocity = Vector3.new(0, 0, 0)

        _G.UGLoop = RunService.PostSimulation:Connect(function()
            if not S.Underground or not root.Parent then 
                if bv then bv:Destroy() end
                _G.UGLoop:Disconnect() 
                return 
            end

            -- 地面の高さを検知
            local ray = Ray.new(root.Position + Vector3.new(0, 20, 0), Vector3.new(0, -50, 0))
            local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})

            -- 強制的に地面から-5の位置にホバリング（飛行）させる
            local targetY = pos.Y + S.UG_Offset
            root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z) * root.CFrame.Rotation
            bv.Velocity = Vector3.new(0, 0, 0) -- 自由落下をキャンセル
        end)
    end
end

-- --- Noclip (落下防止用パーツ追加型) ---
RunService.Stepped:Connect(function()
    if S.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- --- Aimbot / ESP / Fly (通常通り) ---
function applyFly()
    if _G.FlyLoop then _G.FlyLoop:Disconnect(); _G.FlyLoop = nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("FlyBV") then root.FlyBV:Destroy() end
    if not S.Fly then return end

    task.spawn(function()
        local bv = Instance.new("BodyVelocity", root); bv.Name = "FlyBV"; bv.MaxForce = Vector3.new(1,1,1) * math.huge
        local bg = Instance.new("BodyGyro", root); bg.Name = "FlyBG"; bg.MaxTorque = Vector3.new(1,1,1) * math.huge
        _G.FlyLoop = RunService.RenderStepped:Connect(function()
            if not S.Fly or not root.Parent then _G.FlyLoop:Disconnect(); return end
            bg.CFrame = Camera.CFrame
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
            bv.Velocity = move.Unit * S.FlySpeed
            if move == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
        end)
    end)
end

-- Aimbot & ESP Core
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.fromRGB(255, 0, 80)
local ESP_Pool = {}

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOV; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    local aiming = (tostring(S.AimbotKey):find("MouseButton") and UserInputService:IsMouseButtonPressed(S.AimbotKey)) or UserInputService:IsKeyDown(S.AimbotKey)
    if S.Aimbot and aiming then
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
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                if onScreen and dist < S.MaxDist then
                    if not ESP_Pool[p.Name] then ESP_Pool[p.Name] = { B = Drawing.new("Square"), N = Drawing.new("Text") } end
                    local o = ESP_Pool[p.Name]; local sizeX, sizeY = 2000/pos.Z, 3000/pos.Z
                    o.B.Visible = S.Box; o.B.Size = Vector2.new(sizeX, sizeY); o.B.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2); o.B.Color = Color3.new(1,0,0); o.B.Thickness = 1
                    local info = p.Name; if S.Dist then info ..= " [" .. math.floor(dist) .. "]" end
                    o.N.Visible = S.Name; o.N.Text = info; o.N.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 25); o.N.Center = true; o.N.Outline = true; o.N.Size = 14; o.N.Color = Color3.new(1,1,1)
                    continue
                end
            end
            if ESP_Pool[p.Name] then ESP_Pool[p.Name].B.Visible = false; ESP_Pool[p.Name].N.Visible = false end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == S.MenuKey then Main.Visible = not Main.Visible end
end)
