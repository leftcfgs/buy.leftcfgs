-- Internal | unnamed God Edition (Expanded & Professional Structure)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止 & 既存のクリーンアップ
local existing = game.CoreGui:FindFirstChild("UnnamedUltimate")
if existing then existing:Destroy() end

-- --- 全設定 (さらに細分化) ---
_G.Settings = {
    -- Aimbot
    Aimbot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    HitPart = "HumanoidRootPart", -- "Head" も選択可能に
    FOV = 150,
    ShowFOV = true,
    Smooth = 0.1,
    -- Visuals (ESP)
    ESP = false,
    Box = false,
    Name = false,
    Dist = false,
    Tracer = false,
    ESP_Color = Color3.fromRGB(0, 255, 200),
    MaxDist = 3000,
    -- Movement & Physics
    Underground = false,
    UG_Offset = -5,
    Noclip = false,
    Fly = false,
    FlySpeed = 60,
    SpeedHack = false,
    WalkSpeed = 60,
    JumpHack = false,
    JumpPower = 100,
    -- Combat / Misc
    InfiniteJump = false,
    NoRecoil = false,
    RapidFire = false,
    -- UI State
    MenuKey = Enum.KeyCode.Insert,
    BindingMenu = false,
    BindingAim = false,
    Visible = false
}
local S = _G.Settings

-- --- UIコンポーネント (コード密度向上) ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "UnnamedUltimate"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 550, 0, 700)
Main.Position = UDim2.new(0.5, -275, 0.5, -350)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 3)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Text = "INTERNAL | UNNAMED GOD EDITION"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.Code
Title.TextSize = 16
Title.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 1600)

-- --- トグル & 入力 生成 ---
local function AddToggle(text, settingKey, yPos)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local function update()
        btn.Text = "  [" .. (S[settingKey] and "X" or " ") .. "] " .. text
        btn.TextColor3 = S[settingKey] and Color3.new(0, 1, 0.8) or Color3.new(0.5, 0.5, 0.5)
    end
    
    btn.MouseButton1Click:Connect(function()
        S[settingKey] = not S[settingKey]
        update()
        if settingKey == "Fly" then ApplyFlight() end
    end)
    update()
    return btn
end

local function AddInput(text, settingKey, yPos)
    local frame = Instance.new("Frame", Content)
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.4, -5, 0.8, 0)
    box.Position = UDim2.new(0.6, 0, 0.1, 0)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.Text = tostring(S[settingKey])
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Code
    
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text:match("-?%d+%.?%d*"))
        if val then S[settingKey] = val end
        box.Text = tostring(S[settingKey])
    end)
end

-- --- 3秒段階ロード (機能配置) ---
task.spawn(function()
    task.wait(3.0) -- ぱいせん指定の3秒
    Main.Visible = true
    
    local curY = 0
    local function gap(v) curY = curY + v end

    -- [COMBAT]
    AddToggle("Aimbot Master", "Aimbot", curY); gap(42)
    AddToggle("Show FOV Circle", "ShowFOV", curY); gap(42)
    AddInput("FOV Radius", "FOV", curY); gap(42)
    AddToggle("Target: Head Only", "HitPart", curY); gap(42) -- 切り替えロジックは下に
    
    gap(20) -- Section Space
    
    -- [VISUALS]
    AddToggle("Enable Player ESP", "ESP", curY); gap(42)
    AddToggle("ESP Box", "Box", curY); gap(42)
    AddToggle("ESP Names", "Name", curY); gap(42)
    AddToggle("ESP Distance", "Dist", curY); gap(42)
    AddToggle("ESP Tracers", "Tracer", curY); gap(42)
    
    gap(20)
    
    -- [MOVEMENT & UNDERGROUND]
    AddToggle("Underground (-5 Fixed)", "Underground", curY); gap(42)
    AddToggle("Noclip (Ghost Mode)", "Noclip", curY); gap(42)
    AddToggle("Flight Enabled", "Fly", curY); gap(42)
    AddInput("Flight Speed", "FlySpeed", curY); gap(42)
    AddToggle("Speed Hack", "SpeedHack", curY); gap(42)
    AddInput("Walk Speed Value", "WalkSpeed", curY); gap(42)
    
    -- [BINDS]
    local AimBind = Instance.new("TextButton", Content)
    AimBind.Size = UDim2.new(1,-10,0,38); AimBind.Position = UDim2.new(0,5,0,curY); AimBind.BackgroundColor3 = Color3.fromRGB(25,25,25); AimBind.TextSize = 14; AimBind.Font = Enum.Font.Code; AimBind.TextColor3 = Color3.new(1,1,1)
    AimBind.MouseButton1Click:Connect(function() S.BindingAim = true; AimBind.Text = "[Press Key]" end)
    gap(42)
    
    local MenuBind = Instance.new("TextButton", Content)
    MenuBind.Size = UDim2.new(1,-10,0,38); MenuBind.Position = UDim2.new(0,5,0,curY); MenuBind.BackgroundColor3 = Color3.fromRGB(25,25,25); MenuBind.TextSize = 14; MenuBind.Font = Enum.Font.Code; MenuBind.TextColor3 = Color3.new(1,1,1)
    MenuBind.MouseButton1Click:Connect(function() S.BindingMenu = true; MenuBind.Text = "[Press Key]" end)

    task.spawn(function()
        while task.wait(0.1) do
            if not S.BindingAim then AimBind.Text = "  Aim Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")) end
            if not S.BindingMenu then MenuBind.Text = "  Menu Key: " .. tostring(S.MenuKey.Name) end
            S.HitPart = S.HitPart == true and "Head" or "HumanoidRootPart"
        end
    end)
end)

-- --- コア物理エンジン (Underground / Anti-Void) ---
RunService.PostSimulation:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if S.Underground then
        local ray = Ray.new(root.Position + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0))
        local _, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
        
        -- 物理ロック (落下防止)
        root.CFrame = CFrame.new(root.Position.X, pos.Y + S.UG_Offset, root.Position.Z) * root.CFrame.Rotation
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        
        -- 地上視点オフセット
        hum.CameraOffset = Vector3.new(0, -S.UG_Offset, 0)
    else
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end

    if S.SpeedHack then hum.WalkSpeed = S.WalkSpeed end
    if S.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- --- バインド & 入力 ---
UserInputService.InputBegan:Connect(function(i, g)
    if S.BindingAim or S.BindingMenu then
        local k = (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType)
        if S.BindingAim then S.AimbotKey = k; S.BindingAim = false 
        elseif S.BindingMenu then S.MenuKey = k; S.BindingMenu = false end
    elseif not g and i.KeyCode == S.MenuKey then
        Main.Visible = not Main.Visible
    end
end)

-- --- Flight / Aimbot / ESP ---
function ApplyFlight()
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
            if move == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
        end)
    end)
end

-- [エイム & ESP コア]
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Color = Color3.fromRGB(0, 255, 200)
local ESP_Lines = {}

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
