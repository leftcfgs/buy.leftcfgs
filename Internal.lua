-- Internal | unnamed Ultimate Edition (Complete v3)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local existing = game.CoreGui:FindFirstChild("InternalUltimate")
if existing then existing:Destroy() end

-- --- 全設定 ---
_G.Settings = {
    Aimbot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotMode = "Hold", -- "Always", "Toggle", "Hold"
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
    UG_Offset = -6,
    MenuKey = Enum.KeyCode.Insert,
    BindingMenu = false,
    BindingAim = false
}
local S = _G.Settings

-- --- UIベース ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "InternalUltimate"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 450, 0, 500); Main.Position = UDim2.new(0.5, -225, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.Visible = false
local HeaderLine = Instance.new("Frame", Main)
HeaderLine.Size = UDim2.new(1, 0, 0, 2); HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 0, 80); HeaderLine.BorderSizePixel = 0
local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1, 0, 0, 35); TabContainer.Position = UDim2.new(0, 0, 0, 2); TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18); TabContainer.BorderSizePixel = 0

local Pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame", Main)
    page.Size = UDim2.new(1, -20, 1, -45); page.Position = UDim2.new(0, 10, 0, 40)
    page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2; page.CanvasSize = UDim2.new(0, 0, 0, 750)
    Pages[name] = page; return page
end
local MainCol = createPage("Main"); local VisCol = createPage("Visuals"); local MiscCol = createPage("Misc")

-- --- 共通コンポーネント ---
local function createTgl(txt, key, y, parent)
    task.wait(0.04)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 30); btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.TextColor3 = S[key] and Color3.new(1,1,1) or Color3.new(0.7,0.7,0.7)
    btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF"); btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Font = Enum.Font.Code
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]; btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF")
        btn.TextColor3 = S[key] and Color3.new(1,1,1) or Color3.new(0.7,0.7,0.7)
        if key == "Fly" then applyFly() end
        if key == "Noclip" then applyNoclip() end
    end)
    return btn
end

local function createInput(txt, key, y, parent)
    task.wait(0.04)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -10, 0, 30); box.Position = UDim2.new(0, 5, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box.TextColor3 = Color3.new(1, 1, 1)
    box.Text = "  " .. txt .. ": " .. tostring(S[key]); box.TextXAlignment = Enum.TextXAlignment.Left; box.Font = Enum.Font.Code
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text:match("%d+"))
        if val then S[key] = val; box.Text = "  " .. txt .. ": " .. tostring(S[key]) end
    end)
end

-- --- 起動シーケンス (1.0秒待機) ---
task.spawn(function()
    task.wait(1.0) -- ぱいせん指定の1秒ラグ
    Main.Visible = true
    local function createTabBtn(name, x)
        local b = Instance.new("TextButton", TabContainer); b.Size = UDim2.new(0, 100, 1, 0); b.Position = UDim2.new(0, x, 0, 0); b.BackgroundTransparency = 1; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code
        b.MouseButton1Click:Connect(function() for k, v in pairs(Pages) do v.Visible = (k == name) end end)
    end
    createTabBtn("Main", 0); createTabBtn("Visuals", 100); createTabBtn("Misc", 200)
    Pages["Main"].Visible = true

    -- Mainタブ
    createTgl("Aimbot Enabled", "Aimbot", 10, MainCol)
    local AimKeyBtn = Instance.new("TextButton", MainCol)
    AimKeyBtn.Size = UDim2.new(1,-10,0,30); AimKeyBtn.Position = UDim2.new(0,5,0,45); AimKeyBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); AimKeyBtn.Text = "  Aim Key: Mouse2"; AimKeyBtn.TextColor3 = Color3.new(1,1,1); AimKeyBtn.TextXAlignment = Enum.TextXAlignment.Left; AimKeyBtn.Font = Enum.Font.Code
    AimKeyBtn.MouseButton1Click:Connect(function() S.BindingAim = true; AimKeyBtn.Text = "  [Press Key/Mouse]" end)
    
    local ModeBtn = Instance.new("TextButton", MainCol)
    ModeBtn.Size = UDim2.new(1,-10,0,30); ModeBtn.Position = UDim2.new(0,5,0,80); ModeBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); ModeBtn.Text = "  Aim Mode: " .. S.AimbotMode; ModeBtn.TextColor3 = Color3.new(1,1,1); ModeBtn.TextXAlignment = Enum.TextXAlignment.Left; ModeBtn.Font = Enum.Font.Code
    ModeBtn.MouseButton1Click:Connect(function()
        S.AimbotMode = (S.AimbotMode == "Hold" and "Toggle" or S.AimbotMode == "Toggle" and "Always" or "Hold")
        ModeBtn.Text = "  Aim Mode: " .. S.AimbotMode
    end)
    
    local PartBtn = Instance.new("TextButton", MainCol)
    PartBtn.Size = UDim2.new(1,-10,0,30); PartBtn.Position = UDim2.new(0,5,0,115); PartBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); PartBtn.Text = "  Hit Part: " .. S.HitPart; PartBtn.TextColor3 = Color3.new(1,1,1); PartBtn.TextXAlignment = Enum.TextXAlignment.Left; PartBtn.Font = Enum.Font.Code
    PartBtn.MouseButton1Click:Connect(function() S.HitPart = (S.HitPart == "HumanoidRootPart" and "Head" or "HumanoidRootPart"); PartBtn.Text = "  Hit Part: " .. S.HitPart end)
    
    createInput("FOV Size", "FOV", 150, MainCol)
    createTgl("Show FOV", "ShowFOV", 185, MainCol)

    -- Visualsタブ
    createTgl("Master ESP", "ESP", 10, VisCol)
    createTgl("Draw Box", "Box", 45, VisCol)
    createTgl("Draw Name", "Name", 80, VisCol)
    createTgl("Draw Dist", "Dist", 115, VisCol)
    createTgl("Draw Weapon", "Weapon", 150, VisCol)
    createInput("Max Distance", "MaxDist", 185, VisCol)

    -- Miscタブ
    createTgl("Fly Mode", "Fly", 10, MiscCol)
    createInput("Fly Speed", "FlySpeed", 45, MiscCol)
    createTgl("Noclip (Wall)", "Noclip", 80, MiscCol)
    createTgl("Underground", "Underground", 115, MiscCol)
    local MenuKeyBtn = Instance.new("TextButton", MiscCol)
    MenuKeyBtn.Size = UDim2.new(1,-10,0,30); MenuKeyBtn.Position = UDim2.new(0,5,0,150); MenuKeyBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); MenuKeyBtn.Text = "  Menu Key: " .. S.MenuKey.Name; MenuKeyBtn.TextColor3 = Color3.new(1,1,1); MenuKeyBtn.TextXAlignment = Enum.TextXAlignment.Left; MenuKeyBtn.Font = Enum.Font.Code
    MenuKeyBtn.MouseButton1Click:Connect(function() S.BindingMenu = true; MenuKeyBtn.Text = "  [Press Key]" end)
    
    -- キー表示更新ループ
    task.spawn(function()
        while task.wait(0.2) do
            if not S.BindingAim then AimKeyBtn.Text = "  Aim Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")) end
            if not S.BindingMenu then MenuKeyBtn.Text = "  Menu Key: " .. tostring(S.MenuKey.Name) end
        end
    end)
end)

-- --- コアロジック (Underground / Fly / Aimbot / ESP) ---

-- Underground 修正版
RunService.Stepped:Connect(function()
    if S.Underground and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.new(0, S.UG_Offset, 0)
    end
    if S.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- Fly 自動再適用
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
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
                    bv.Velocity = move.Unit * S.FlySpeed
                    if move == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
                end)
            end
            task.wait(1)
        end
    end)
end

-- Aimbot / ESP
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
                    if not ESP_Pool[p.Name] then
                        ESP_Pool[p.Name] = { B = Drawing.new("Square"), N = Drawing.new("Text") }
                        ESP_Pool[p.Name].N.Size = 14; ESP_Pool[p.Name].N.Outline = true; ESP_Pool[p.Name].N.Center = true
                    end
                    local o = ESP_Pool[p.Name]; local sizeX, sizeY = 2000/pos.Z, 3000/pos.Z
                    o.B.Visible = S.Box; o.B.Size = Vector2.new(sizeX, sizeY); o.B.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2); o.B.Color = Color3.new(1,0,0)
                    local info = p.Name; if S.Dist then info = info .. " [" .. math.floor(dist) .. "]" end
                    if S.Weapon then local tool = p.Character:FindFirstChildOfClass("Tool"); info = info .. "\n(" .. (tool and tool.Name or "None") .. ")" end
                    o.N.Visible = S.Name; o.N.Text = info; o.N.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 25); o.N.Color = Color3.new(1,1,1)
                    continue
                end
            end
            if ESP_Pool[p.Name] then ESP_Pool[p.Name].B.Visible = false; ESP_Pool[p.Name].N.Visible = false end
        end
    end
end)

-- キー入力バインド
UserInputService.InputBegan:Connect(function(i, g)
    if S.BindingAim or S.BindingMenu then
        local k = (i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType)
        if S.BindingAim then S.AimbotKey = k; S.BindingAim = false elseif S.BindingMenu then S.MenuKey = k; S.BindingMenu = false end
    elseif not g and i.KeyCode == S.MenuKey then Main.Visible = not Main.Visible end
end)
