-- Internal | unnamed Ultimate Edition (Refined Logic)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local existing = game.CoreGui:FindFirstChild("InternalUltimate")
if existing then existing:Destroy() end

-- --- 設定 ---
_G.Settings = {
    Aimbot = false,
    AimbotKey = Enum.UserInputType.MouseButton2, -- デフォルト右クリック
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
    UG_Offset = -5, -- 埋まる深さ（固定）
    MenuKey = Enum.KeyCode.Insert,
    BindingMenu = false,
    BindingAim = false
}
local S = _G.Settings

-- --- UIベース (省略せず構築) ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "InternalUltimate"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 450, 0, 480); Main.Position = UDim2.new(0.5, -225, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true; Main.Visible = false
local HeaderLine = Instance.new("Frame", Main)
HeaderLine.Size = UDim2.new(1, 0, 0, 2); HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 0, 50); HeaderLine.BorderSizePixel = 0
local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1, 0, 0, 35); TabContainer.Position = UDim2.new(0, 0, 0, 2); TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabContainer.BorderSizePixel = 0

local Pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame", Main)
    page.Size = UDim2.new(1, -20, 1, -45); page.Position = UDim2.new(0, 10, 0, 40)
    page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2; page.CanvasSize = UDim2.new(0, 0, 0, 650)
    Pages[name] = page; return page
end
local MainCol = createPage("Main"); local VisCol = createPage("Visuals"); local MiscCol = createPage("Misc")
local function showPage(name) for k, v in pairs(Pages) do v.Visible = (k == name) end end

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

-- --- 起動シーケンス ---
task.spawn(function()
    task.wait(0.5)
    Main.Visible = true
    local function createTabBtn(name, x)
        local b = Instance.new("TextButton", TabContainer)
        b.Size = UDim2.new(0, 100, 1, 0); b.Position = UDim2.new(0, x, 0, 0); b.BackgroundTransparency = 1
        b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code
        b.MouseButton1Click:Connect(function() showPage(name) end)
    end
    createTabBtn("Main", 0); createTabBtn("Visuals", 100); createTabBtn("Misc", 200)
    showPage("Main")

    createTgl("Aimbot Enabled", "Aimbot", 10, MainCol)
    local AimKeyBtn = Instance.new("TextButton", MainCol)
    AimKeyBtn.Size = UDim2.new(1,-10,0,30); AimKeyBtn.Position = UDim2.new(0,5,0,45); AimKeyBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); AimKeyBtn.Text = "  Aim Key: Mouse2"; AimKeyBtn.TextColor3 = Color3.new(1,1,1); AimKeyBtn.TextXAlignment = Enum.TextXAlignment.Left; AimKeyBtn.Font = Enum.Font.Code
    AimKeyBtn.MouseButton1Click:Connect(function() S.BindingAim = true; AimKeyBtn.Text = "  [Press Key/Mouse]" end)
    
    -- ロジック用UI更新ループ
    task.spawn(function()
        while task.wait(0.1) do
            if not S.BindingAim then AimKeyBtn.Text = "  Aim Key: " .. (tostring(S.AimbotKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")) end
        end
    end)
end)

-- --- キー入力検知 (マウス特化修正) ---
UserInputService.InputBegan:Connect(function(input, gpe)
    if S.BindingAim or S.BindingMenu then
        local key = (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType)
        if S.BindingAim then S.AimbotKey = key; S.BindingAim = false
        elseif S.BindingMenu then S.MenuKey = key; S.BindingMenu = false end
        return
    end
    if not gpe and input.KeyCode == S.MenuKey then Main.Visible = not Main.Visible end
end)

-- --- Aimbot 判定ロジック (マウス入力の修正) ---
local function isAiming()
    if S.AimbotMode == "Always" then return true end
    local pressed = false
    if tostring(S.AimbotKey):find("MouseButton") then
        pressed = UserInputService:IsMouseButtonPressed(S.AimbotKey)
    else
        pressed = UserInputService:IsKeyDown(S.AimbotKey)
    end
    return pressed
end

-- --- 改良型 Underground & Fly ---
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        -- Underground: 視点に追従しつつ、体だけ下に固定オフセット
        if S.Underground and not S.Fly then
            root.Velocity = Vector3.new(0, 0, 0)
            -- 常に現在の位置から一定距離下に固定。視点移動しても追従するように
            char:MoveTo(root.Position + Vector3.new(0, S.UG_Offset, 0))
        end
    end
end)

function applyFly()
    if _G.FlyLoop then _G.FlyLoop:Disconnect(); _G.FlyLoop = nil end
    if not S.Fly then return end
    
    task.spawn(function()
        while S.Fly do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
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
            task.wait(1) -- ロビー等の再スポーン監視
        end
    end)
end

-- --- Aimbot & ESP (前回と同様) ---
-- (ここに前回の Aimbot/ESP ロジックを統合)
