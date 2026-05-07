-- Internale (No Hidden Features)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local existing = game.CoreGui:FindFirstChild("UnnamedUltimate")
if existing then existing:Destroy() end

-- --- 全設定 (1つも省いてないぜ) ---
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
    UG_Height = 0,
    UG_Offset = -6,
    MenuKey = Enum.KeyCode.Insert,
    BindingMenu = false,
    BindingAim = false
}
local S = _G.Settings

-- --- UI構築 (視認性MAX) ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "UnnamedUltimate"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 550); Main.Position = UDim2.new(0.5, -250, 0.5, -275)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.Visible = false
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 3); Header.BackgroundColor3 = Color3.fromRGB(255, 0, 80); Header.BorderSizePixel = 0

-- スクロールを廃止して直接配置するか、キャンバスを巨大にする
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -40); Content.Position = UDim2.new(0, 10, 0, 30)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 5; Content.CanvasSize = UDim2.new(0, 0, 0, 1100) -- 余裕を持たせた

local function createTgl(txt, key, y)
    task.wait(0.02)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 35); btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28); btn.TextColor3 = S[key] and Color3.new(1,1,1) or Color3.new(0.6,0.6,0.6)
    btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF"); btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Font = Enum.Font.Code
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        if key == "Underground" and S[key] then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                S.UG_Height = LocalPlayer.Character.HumanoidRootPart.Position.Y + S.UG_Offset
            end
        end
        btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF")
        btn.TextColor3 = S[key] and Color3.new(1,1,1) or Color3.new(0.6,0.6,0.6)
        if key == "Fly" then applyFly() end
    end)
end

local function createInput(txt, key, y)
    task.wait(0.02)
    local box = Instance.new("TextBox", Content)
    box.Size = UDim2.new(1, -10, 0, 35); box.Position = UDim2.new(0, 5, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(22, 22, 22); box.TextColor3 = Color3.new(1, 1, 1); box.Font = Enum.Font.Code
    box.Text = "  " .. txt .. ": " .. tostring(S[key]); box.TextXAlignment = Enum.TextXAlignment.Left
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text:match("-?%d+"))
        if val then S[key] = val; box.Text = "  " .. txt .. ": " .. tostring(S[key]) end
    end)
end

-- 起動シーケンス (1.0秒)
task.spawn(function()
    task.wait(1.0)
    Main.Visible = true
    
    -- --- [Aimbot Section] ---
    createTgl("Aimbot Master", "Aimbot", 10)
    local AimKeyBtn = Instance.new("TextButton", Content)
    AimKeyBtn.Size = UDim2.new(1,-10,0,35); AimKeyBtn.Position = UDim2.new(0,5,0,50); AimKeyBtn.BackgroundColor3 = Color3.fromRGB(28,28,28); AimKeyBtn.Text = "  Aim Key: Mouse2"; AimKeyBtn.TextColor3 = Color3.new(1,1,1); AimKeyBtn.TextXAlignment = Enum.TextXAlignment.Left; AimKeyBtn.Font = Enum.Font.Code
    AimKeyBtn.MouseButton1Click:Connect(function() S.BindingAim = true; AimKeyBtn.Text = "  [Press Key]" end)
    
    local PartBtn = Instance.new("TextButton", Content)
    PartBtn.Size = UDim2.new(1,-10,0,35); PartBtn.Position = UDim2.new(0,5,0,90); PartBtn.BackgroundColor3 = Color3.fromRGB(28,28,28); PartBtn.Text = "  Hit Part: " .. S.HitPart; PartBtn.TextColor3 = Color3.new(1,1,1); PartBtn.TextXAlignment = Enum.TextXAlignment.Left; PartBtn.Font = Enum.Font.Code
    PartBtn.MouseButton1Click:Connect(function() S.HitPart = (S.HitPart == "HumanoidRootPart" and "Head" or "HumanoidRootPart"); PartBtn.Text = "  Hit Part: " .. S.HitPart end)
    
    createTgl("Show FOV Circle", "ShowFOV", 130)
    createInput("FOV Radius", "FOV", 170)
    
    -- --- [Visuals Section] ---
    createTgl("Master ESP", "ESP", 220)
    createTgl("Draw Box", "Box", 260)
    createTgl("Draw Name", "Name", 300)
    createTgl("Draw Distance", "Dist", 340)
    createTgl("Draw Weapon", "Weapon", 380)
    
    -- --- [Misc Section] ---
    createTgl("Fly Enabled", "Fly", 430)
    createInput("Fly Speed", "FlySpeed", 470)
    createTgl("Noclip (Wall Pass)", "Noclip", 510)
    createTgl("Underground (GACHI LOCK)", "Underground", 550)
    createInput("UG Offset (Ground Depth)", "UG_Offset", 590)
    
    -- キーバインド監視
    task.spawn(function()
        while task.wait(0.1) do
            if not S.BindingAim then AimKeyBtn.Text = "  Aim Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")) end
        end
    end)
end)

-- --- ガチ固定 Underground ＆ ロジック ---
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if S.Underground and root then
        root.CFrame = CFrame.new(root.Position.X, S.UG_Height, root.Position.Z) * root.CFrame.Rotation
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
    end
    if S.Noclip and char then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

function applyFly()
    if _G.FlyLoop then _G.FlyLoop:Disconnect(); _G.FlyLoop = nil end
    if not S.Fly then return end
    task.spawn(function()
        while S.Fly do
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and not root:FindFirstChild("FlyBV") then
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
            end
            task.wait(1)
        end
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
                    if S.Weapon then local t = p.Character:FindFirstChildOfClass("Tool"); info ..= "\n(" .. (t and t.Name or "None") .. ")" end
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
