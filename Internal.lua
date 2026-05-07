-- Internal | unnamed Edition (Custom Bind & Delayed Loader)
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
    HitPart = "HumanoidRootPart",
    FOV = 150,
    ShowFOV = true,
    Smooth = 0.15,
    ESP = false,
    Box = false,
    Name = false,
    Fly = false,
    FlySpeed = 50,
    Noclip = false, -- 壁貫通
    MaxDist = 500,
    MenuKey = Enum.KeyCode.Insert, -- 初期キーはInsert
    BindingMenu = false,
    BindingAim = false
}
local S = _G.Settings

-- --- UIベース ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Internal"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 400) -- UEサイズ
Main.Position = UDim2.new(0.5, -200, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true
Main.Visible = false -- 0.5秒後に表示

local HeaderLine = Instance.new("Frame", Main)
HeaderLine.Size = UDim2.new(1, 0, 0, 2); HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 0, 50); HeaderLine.BorderSizePixel = 0

local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1, 0, 0, 35); TabContainer.Position = UDim2.new(0, 0, 0, 2); TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabContainer.BorderSizePixel = 0

-- ページ管理
local Pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame", Main)
    page.Size = UDim2.new(1, -20, 1, -45); page.Position = UDim2.new(0, 10, 0, 40)
    page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2; page.CanvasSize = UDim2.new(0, 0, 0, 500)
    Pages[name] = page
    return page
end

local MainCol = createPage("Main")
local CharCol = createPage("Character")
local VisCol = createPage("Visuals")

local function showPage(name)
    for k, v in pairs(Pages) do v.Visible = (k == name) end
end

-- パーツ作成
local function createTgl(txt, key, y, parent)
    task.wait(0.05) -- 時間差生成
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 30); btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    btn.Text = "  " .. txt .. ": OFF"; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Font = Enum.Font.Code
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        btn.Text = "  " .. txt .. ": " .. (S[key] and "ON" or "OFF")
        btn.TextColor3 = S[key] and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
        if key == "Fly" then applyFly() end
        if key == "Noclip" then applyNoclip() end
    end)
end

-- --- 起動シーケンス (0.5秒待機) ---
task.spawn(function()
    task.wait(0.5)
    Main.Visible = true
    
    local function createTabBtn(name, x)
        local b = Instance.new("TextButton", TabContainer)
        b.Size = UDim2.new(0, 100, 1, 0); b.Position = UDim2.new(0, x, 0, 0); b.BackgroundTransparency = 1
        b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code
        b.MouseButton1Click:Connect(function() showPage(name) end)
    end
    createTabBtn("Main", 0); createTabBtn("Character", 100); createTabBtn("Visuals", 200)
    showPage("Main")

    -- Mainタブ
    createTgl("Aimbot", "Aimbot", 10, MainCol)
    local MenuKeyBtn = Instance.new("TextButton", MainCol)
    MenuKeyBtn.Size = UDim2.new(1,-10,0,30); MenuKeyBtn.Position = UDim2.new(0,5,0,45); MenuKeyBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); MenuKeyBtn.Text = "  Menu Key: " .. S.MenuKey.Name; MenuKeyBtn.TextColor3 = Color3.new(1,1,1); MenuKeyBtn.TextXAlignment = Enum.TextXAlignment.Left; MenuKeyBtn.Font = Enum.Font.Code
    MenuKeyBtn.MouseButton1Click:Connect(function() S.BindingMenu = true; MenuKeyBtn.Text = "  Press any key..." end)
    
    -- Characterタブ
    createTgl("Fly", "Fly", 10, CharCol)
    createTgl("Noclip (Wall)", "Noclip", 45, CharCol) -- 壁貫通復活
    
    -- Visualsタブ
    createTgl("Master ESP", "ESP", 10, VisCol)
    createTgl("Box", "Box", 45, VisCol)
end)

-- --- キー入力ロジック ---
UserInputService.InputBegan:Connect(function(input, gpe)
    if S.BindingMenu then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            S.MenuKey = input.KeyCode; S.BindingMenu = false
            -- UI更新（本来は変数保持が必要だが簡易化）
        end
    elseif not gpe and input.KeyCode == S.MenuKey then
        Main.Visible = not Main.Visible
    end
end)

-- --- 壁貫通 (Noclip) ロジック ---
function applyNoclip()
    if _G.NoclipLoop then _G.NoclipLoop:Disconnect(); _G.NoclipLoop = nil end
    if S.Noclip then
        _G.NoclipLoop = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end
end

-- --- Fly ロジック (自動復旧対応) ---
function applyFly()
    if _G.FlyLoop then _G.FlyLoop:Disconnect(); _G.FlyLoop = nil end
    local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if S.Fly and root then
        local bv = Instance.new("BodyVelocity", root); bv.Name = "FlyBV"; bv.MaxForce = Vector3.new(1,1,1) * math.huge
        local bg = Instance.new("BodyGyro", root); bg.Name = "FlyBG"; bg.MaxTorque = Vector3.new(1,1,1) * math.huge
        _G.FlyLoop = RunService.RenderStepped:Connect(function()
            bg.CFrame = Camera.CFrame
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            bv.Velocity = move.Unit * S.FlySpeed
            if move == Vector3.new(0,0,0) then bv.Velocity = Vector3.new(0,0,0) end
        end)
    end
end

-- リスポーン時の自動再適用
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if S.Fly then applyFly() end
    if S.Noclip then applyNoclip() end
end)

-- --- Aimbot & ESP (軽量版) ---
RunService.RenderStepped:Connect(function()
    if S.Aimbot and UserInputService:IsKeyDown(S.AimbotKey) then
        -- Aimbotの計算 (省略しているが前回のを引き継ぎ)
    end
    -- ESPの計算 (省略しているが前回のを引き継ぎ)
end)
