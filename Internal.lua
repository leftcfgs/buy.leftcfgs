-- Internal | Optimized ESP & Custom Menu
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 重複防止
local existing = game.CoreGui:FindFirstChild("Internal")
if existing then existing:Destroy() end

-- --- 設定（ここをメニューでいじる） ---
_G.Settings = {
    Aimbot = false,
    AimbotKey = Enum.KeyCode.E,
    AimbotType = "Keyboard",
    AimbotMode = "Toggle",
    HitPart = "HumanoidRootPart",
    FOV = 150,
    ShowFOV = true,
    Smooth = 0.15,
    -- ESP設定（最初は全部OFFにして負荷を抑える）
    ESP = false,
    Box = false,
    Skel = false,
    Name = false,
    Health = false,
    Dist = false,
    Weapon = false,
    Binding = false
}
local S = _G.Settings

-- --- 描画オブジェクト ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = false

local ESP_Objects = {}

-- --- UI ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Internal"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Draggable = true
Main.Active = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "INTERNAL | STABLE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 50)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, 0, 1, -35)
Scroll.Position = UDim2.new(0, 0, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 550)
Scroll.ScrollBarThickness = 4

-- ボタン作成関数（トグル用）
local function createTgl(text, key, pos)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0, 260, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = S[key] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
    btn.Text = text .. ": " .. (S[key] and "ON" or "OFF")
    
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        btn.Text = text .. ": " .. (S[key] and "ON" or "OFF")
        btn.TextColor3 = S[key] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
    end)
    return btn
end

-- UI配置
createTgl("Enable Aimbot", "Aimbot", UDim2.new(0, 20, 0, 10))
createTgl("Show FOV", "ShowFOV", UDim2.new(0, 20, 0, 45))
createTgl("Enable ESP", "ESP", UDim2.new(0, 20, 0, 90))
createTgl("- Box", "Box", UDim2.new(0, 20, 0, 125))
createTgl("- Skeleton", "Skel", UDim2.new(0, 20, 0, 160))
createTgl("- Name", "Name", UDim2.new(0, 20, 0, 195))
createTgl("- Health Bar", "Health", UDim2.new(0, 20, 0, 230))
createTgl("- Distance", "Dist", UDim2.new(0, 20, 0, 265))
createTgl("- Weapon", "Weapon", UDim2.new(0, 20, 0, 300))

-- Aimbot ロジック（負荷軽減版）
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = S.ShowFOV
    FOVCircle.Radius = S.FOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    if S.Aimbot then
        local target = nil
        local dist = S.FOV
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(S.HitPart) then
                local hum = v.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(v.Character[S.HitPart].Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mag < dist then dist = mag; target = v end
                    end
                end
            end
        end
        if target and mousemoverel then
            local tPos = Camera:WorldToViewportPoint(target.Character[S.HitPart].Position)
            mousemoverel((tPos.X - Mouse.X) * S.Smooth, (tPos.Y - (Mouse.Y + 36)) * S.Smooth)
        end
    end
end)

-- ESP 描画処理（1人ずつ丁寧に処理してクラッシュ防止）
local function makeDraw(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do d[k] = v end
    return d
end

RunService.RenderStepped:Connect(function()
    if not S.ESP then
        for _, obj in pairs(ESP_Objects) do for _, d in pairs(obj) do d.Visible = false end end
        return
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not ESP_Objects[p.Name] then
                ESP_Objects[p.Name] = {
                    B = makeDraw("Square", {Thickness = 1, Color = Color3.fromRGB(255,0,0)}),
                    N = makeDraw("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1)}),
                    H = makeDraw("Line", {Thickness = 2, Color = Color3.new(0,1,0)})
                }
            end
            local draws = ESP_Objects[p.Name]
            local char = p.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if root and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local sizeX, sizeY = 2000/pos.Z, 3000/pos.Z
                    draws.B.Visible = S.Box
                    draws.B.Size = Vector2.new(sizeX, sizeY)
                    draws.B.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    
                    draws.N.Visible = S.Name
                    draws.N.Text = p.Name .. (S.Dist and " ["..math.floor(pos.Z).."m]" or "")
                    draws.N.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 15)
                    
                    draws.H.Visible = S.Health
                    draws.H.From = Vector2.new(pos.X - sizeX/2 - 5, pos.Y + sizeY/2)
                    draws.H.To = Vector2.new(pos.X - sizeX/2 - 5, pos.Y + sizeY/2 - (sizeY * (hum.Health/hum.MaxHealth)))
                    
                    continue
                end
            end
            for _, d in pairs(draws) do d.Visible = false end
        end
    end
end)
