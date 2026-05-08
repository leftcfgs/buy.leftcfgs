-- ==========================================================
-- UNNAMED PROFESSIONAL (WAVE STABLE / SEQUENTIAL)
-- DO NOT RUN AT ONCE - LOADING STEP BY STEP
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 重複防止 (静かに消す)
local old = game.CoreGui:FindFirstChild("UnnamedSequential")
if old then old:Destroy() end

-- --- グローバル設定 ---
_G.Settings = {
    Tab = "Main",
    SilentAim = false, HitChance = 100, HitPart = "Head", FOV = 200,
    RapidFire = false, RapidRate = 0.05,
    Underground = false, UG_Offset = -3.5, 
    SpeedActive = false, WalkSpeed = 100,
    MenuKey = Enum.KeyCode.Insert
}
local S = _G.Settings

-- --- 1. UI枠の構築 (即時) ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "UnnamedSequential"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 520, 0, 420); Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.BorderSizePixel = 0; Main.Visible = false; Main.Draggable = true; Main.Active = true

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, 0, 0, 40); TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabBar.BorderSizePixel = 0

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60); Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1; Container.BorderSizePixel = 0; Container.ScrollBarThickness = 2

-- --- UI Refresh Logic ---
function RefreshUI()
    for _, v in pairs(Container:GetChildren()) do v:Destroy() end
    local y = 10
    local function AddTog(txt, key)
        local b = Instance.new("TextButton", Container); b.Size = UDim2.new(1,0,0,32); b.Position = UDim2.new(0,0,0,y)
        b.BackgroundColor3 = S[key] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(25, 25, 25)
        b.Text = " " .. txt .. " [" .. (S[key] and "ON" or "OFF") .. "]"; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.TextSize = 13
        b.MouseButton1Click:Connect(function() S[key] = not S[key]; RefreshUI() end); y = y + 36
    end
    if S.Tab == "Main" then
        AddTog("Silent Aim (Hook)", "SilentAim")
        AddTog("Rapid Fire (VIM)", "RapidFire")
    elseif S.Tab == "Misc" then
        AddTog("Underground (Camera Fix)", "Underground")
        AddTog("Speed Hack", "SpeedActive")
    end
end

-- --- 2. 段階的起動 (Sequential Boot) ---
task.spawn(function()
    task.wait(1.0) -- まず1秒待機
    
    -- タブ生成
    local function CreateTab(name, x)
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0, 90, 1, 0); btn.Position = UDim2.new(0, x, 0, 0)
        btn.BackgroundTransparency = 1; btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Code; btn.TextSize = 14
        btn.MouseButton1Click:Connect(function() S.Tab = name; RefreshUI() end)
    end
    CreateTab("Main", 10); CreateTab("Misc", 110); CreateTab("Settings", 210)
    RefreshUI()
    Main.Visible = true
    print("[1/3] UI Loaded.")
    
    task.wait(0.5)
    -- Silent Aim フック
    local function GetTarg()
        local target, near = nil, S.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.HitPart) then
                local pos, os = Camera:WorldToViewportPoint(p.Character[S.HitPart].Position)
                if os then
                    local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if d < near then near = d; target = p end
                end
            end
        end
        return target
    end

    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local m = getnamecallmethod()
        if S.SilentAim and (m == "Raycast" or m == "FindPartOnRayWithIgnoreList") then
            local t = GetTarg()
            if t and math.random(1,100) <= S.HitChance then
                local args = {...}
                if m == "Raycast" then args[2] = (t.Character[S.HitPart].Position - args[1]).Unit * 1000
                else args[1] = Ray.new(args[1].Origin, (t.Character[S.HitPart].Position - args[1].Origin).Unit * 1000) end
                return old(self, unpack(args))
            end
        end
        return old(self, ...)
    end)
    print("[2/3] Metatable Hooked.")
    
    task.wait(0.5)
    -- 地下・連射システムの起動
    local CamPart = Instance.new("Part", workspace); CamPart.Transparency = 1; CamPart.Anchored = true; CamPart.CanCollide = false
    
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            if S.Underground then
                root.Velocity = Vector3.new(0,0,0)
                root.CFrame = root.CFrame * CFrame.new(0, S.UG_Offset, 0)
                CamPart.CFrame = root.CFrame * CFrame.new(0, -S.UG_Offset, 0)
                Camera.CameraSubject = CamPart
            else
                Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if S.RapidFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
        end
    end)
    print("[3/3] Systems Stabilized.")
end)

-- メニュー開閉
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == S.MenuKey then Main.Visible = not Main.Visible end
end)
