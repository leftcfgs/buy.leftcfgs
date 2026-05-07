-- Internal | unnamed Ultimate Overload (3s Phased Load / Full Features)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local existing = game.CoreGui:FindFirstChild("UnnamedUltimate")
if existing then existing:Destroy() end

-- --- 全設定 (大幅増量) ---
_G.Settings = {
    Aimbot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    HitPart = "HumanoidRootPart",
    FOV = 150,
    ShowFOV = true,
    Smooth = 0.1,
    -- Visuals
    ESP = false,
    Box = false,
    Name = false,
    Dist = false,
    Tracer = false,
    MaxDist = 2000,
    -- Movement
    SpeedHack = false,
    WalkSpeed = 50,
    JumpHack = false,
    JumpPower = 100,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Underground = false,
    UG_Offset = -5,
    -- Combat (Experimental)
    InfiniteAmmo = false, -- 弾丸消費無効(一部ゲーム)
    NoRecoil = false,     -- 反動抑制
    RapidFire = false,    -- 連射
    -- UI
    MenuKey = Enum.KeyCode.Insert,
    BindingMenu = false,
    BindingAim = false
}
local S = _G.Settings

-- --- UI構築 ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "UnnamedUltimate"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 550, 0, 650); Main.Position = UDim2.new(0.5, -275, 0.5, -325)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.Visible = false
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 4); Header.BackgroundColor3 = Color3.fromRGB(0, 255, 200); Header.BorderSizePixel = 0

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -50); Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 6; Content.CanvasSize = UDim2.new(0, 0, 0, 1500)

local function createTgl(txt, key, y)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 35); btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.TextColor3 = S[key] and Color3.new(0,1,0.8) or Color3.new(0.6,0.6,0.6)
    btn.Text = "  [+] " .. txt .. ": " .. (S[key] and "ACTIVE" or "OFF"); btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Font = Enum.Font.Code; btn.TextSize = 14
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        btn.Text = "  [+] " .. txt .. ": " .. (S[key] and "ACTIVE" or "OFF")
        btn.TextColor3 = S[key] and Color3.new(0,1,0.8) or Color3.new(0.6,0.6,0.6)
        if key == "Fly" then applyFly() end
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

-- --- 3秒遅延ロード (全機能一気出し) ---
task.spawn(function()
    task.wait(3.0) 
    Main.Visible = true
    
    -- [Combat Section]
    createTgl("Aimbot System", "Aimbot", 10)
    createTgl("Show FOV Range", "ShowFOV", 50)
    createInput("FOV Radius", "FOV", 90)
    createTgl("No Recoil (Safe)", "NoRecoil", 130)
    createTgl("Rapid Fire (Experimental)", "RapidFire", 170)

    -- [Visuals Section]
    createTgl("Player ESP", "ESP", 220)
    createTgl("ESP Box", "Box", 260)
    createTgl("ESP Name", "Name", 300)
    createTgl("ESP Tracers", "Tracer", 340)

    -- [Movement Section]
    createTgl("Underground Mode", "Underground", 390)
    createTgl("Noclip (Anti-Void)", "Noclip", 430)
    createTgl("Fly Enabled", "Fly", 470)
    createTgl("Speed Hack", "SpeedHack", 510)
    createInput("Custom Speed", "WalkSpeed", 550)
    createTgl("Jump Hack", "JumpHack", 590)
    createInput("Jump Power", "JumpPower", 630)

    -- [Settings Section]
    local AimBind = Instance.new("TextButton", Content)
    AimBind.Size = UDim2.new(1,-10,0,35); AimBind.Position = UDim2.new(0,5,0,680); AimBind.BackgroundColor3 = Color3.fromRGB(30,30,30); AimBind.TextColor3 = Color3.new(1,1,1); AimBind.Font = Enum.Font.Code; AimBind.TextXAlignment = Enum.TextXAlignment.Left
    AimBind.MouseButton1Click:Connect(function() S.BindingAim = true; AimBind.Text = "  [Waiting for Input...]" end)

    local MenuBind = Instance.new("TextButton", Content)
    MenuBind.Size = UDim2.new(1,-10,0,35); MenuBind.Position = UDim2.new(0,5,0,720); MenuBind.BackgroundColor3 = Color3.fromRGB(30,30,30); MenuBind.TextColor3 = Color3.new(1,1,1); MenuBind.Font = Enum.Font.Code; MenuBind.TextXAlignment = Enum.TextXAlignment.Left
    MenuBind.MouseButton1Click:Connect(function() S.BindingMenu = true; MenuBind.Text = "  [Waiting for Input...]" end)

    task.spawn(function()
        while task.wait(0.2) do
            if not S.BindingAim then AimBind.Text = "  Aim Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")) end
            if not S.BindingMenu then MenuBind.Text = "  Menu Key: " .. tostring(S.MenuKey.Name) end
        end
    end)
end)

-- --- コアロジック (Underground / Movement) ---
RunService.PostSimulation:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    -- 地下潜行 & 地上視点
    if S.Underground then
        local ray = Ray.new(root.Position + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0))
        local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
        root.CFrame = CFrame.new(root.Position.X, pos.Y + S.UG_Offset, root.Position.Z) * root.CFrame.Rotation
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        hum.CameraOffset = Vector3.new(0, -S.UG_Offset, 0)
    else
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end

    -- スピード・ジャンプハック
    if S.SpeedHack then hum.WalkSpeed = S.WalkSpeed end
    if S.JumpHack then hum.JumpPower = S.JumpPower; hum.UseJumpPower = true end

    -- Noclip
    if S.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- --- キーバインド処理 ---
UserInputService.InputBegan:Connect(function(i, g)
    if S.BindingAim or S.BindingMenu then
        local k = (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType)
        if S.BindingAim then S.AimbotKey = k; S.BindingAim = false 
        elseif S.BindingMenu then S.MenuKey = k; S.BindingMenu = false end
    elseif not g and i.KeyCode == S.MenuKey then
        Main.Visible = not Main.Visible
    end
end)

-- --- 飛行 & エイム ---
function applyFly()
    if _G.FlyLoop then _G.FlyLoop:Disconnect(); _G.FlyLoop = nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not S.Fly or not root then return end
    task.spawn(function()
        local bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(1,1,1) * math.huge
        _G.FlyLoop = RunService.RenderStepped:Connect(function()
            if not S.Fly or not root.Parent then _G.FlyLoop:Disconnect(); if bv then bv:Destroy() end return end
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            bv.Velocity = move.Unit * S.FlySpeed
        end)
    end)
end

local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Color = Color3.fromRGB(0, 255, 200)
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV; FOVCircle.Radius = S.FOV; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    if S.Aimbot and ((tostring(S.AimbotKey):find("MouseButton") and UserInputService:IsMouseButtonPressed(S.AimbotKey)) or UserInputService:IsKeyDown(S.AimbotKey)) then
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
end)
