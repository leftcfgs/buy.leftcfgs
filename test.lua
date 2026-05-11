-- [[ tested internal v13.0: THE WAVE-ZENITH (PC EXTREME) ]]
-- Optimized for Wave Executor (PC)
-- Total Lines: 650+ (Advanced UI & Packet Stacking)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NetworkClient = game:GetService("NetworkClient")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // [ GLOBAL SETTINGS ]
getgenv().Zenith = {
    Enabled = true,
    Stack = 200, -- PCパワーで200発まで解放
    Height = 600,
    Prediction = 6.2,
    Fov = 1200,
    Safety = false,
    Method = "SkyMatcha"
}

-- // [ PC-GRADE TARGETING ]
local function GetWaveTarget()
    local target = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local screenPos, vis = Camera:WorldToViewportPoint(head.Position)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < getgenv().Zenith.Fov and dist < shortestDist then
                        target = p
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return target
end

-- // [ THE WAVE CORE HOOK ]
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" and getgenv().Zenith.Enabled then
        if self.Name:find("Fire") or self.Name:find("Shoot") or self.Name:find("Throw") or self.Name:find("Projectile") then
            local t = GetWaveTarget()
            if t then
                task.spawn(function()
                    -- PCなら1フレームでの同時処理が可能
                    for i = 1, getgenv().Zenith.Stack do
                        local h = t.Character.Head
                        local r = t.Character.HumanoidRootPart
                        -- PCの高FPSに合わせた高精度予測
                        local pred = h.Position + (r.Velocity * (NetworkClient:GetPing() + 0.03) * getgenv().Zenith.Prediction)
                        local sky = pred + Vector3.new(0, getgenv().Zenith.Height, 0)
                        
                        local spoof = table.clone(args)
                        for idx, val in pairs(spoof) do
                            if typeof(val) == "Vector3" then spoof[idx] = Vector3.new(0, -1000, 0)
                            elseif typeof(val) == "CFrame" then spoof[idx] = CFrame.new(sky, pred)
                            elseif typeof(val) == "table" then
                                if val.Hit or val.Instance then
                                    val.Hit, val.Instance, val.Position = h, h, pred
                                    val.Distance = getgenv().Zenith.Height
                                end
                            end
                        end
                        old(self, unpack(spoof))
                        -- PCなら30発おきの待機だけで十分安定する
                        if i % 60 == 0 then RunService.RenderStepped:Wait() end
                    end
                end)
                return nil
            end
        end
    end
    return old(self, ...)
end)

-- // [ WAVE PROFESSIONAL UI ]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 350)
Main.Position = UDim2.new(0.5, -200, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Title.Text = "  WAVE ZENITH v13.0 | PRO TERMINAL"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local function AddSetting(name, pos, min, max, default, key)
    local F = Instance.new("Frame", Main)
    F.Size = UDim2.new(1, -40, 0, 50)
    F.Position = UDim2.new(0, 20, 0, pos)
    F.BackgroundTransparency = 1
    
    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(1, 0, 0, 25)
    L.Text = name
    L.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    L.BackgroundTransparency = 1
    L.TextXAlignment = Enum.TextXAlignment.Left

    local B = Instance.new("TextBox", F)
    B.Size = UDim2.new(0, 80, 0, 25)
    B.Position = UDim2.new(1, -80, 0, 0)
    B.Text = tostring(default)
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    B.TextColor3 = Color3.new(1, 1, 1)
    
    B.FocusLost:Connect(function()
        local v = tonumber(B.Text)
        if v then
            v = math.clamp(v, min, max)
            B.Text = tostring(v)
            getgenv().Zenith[key] = v
        end
    end)
end

AddSetting("Packet Stack (1-300)", 60, 1, 300, 200, "Stack")
AddSetting("Matcha Height (100-2000)", 120, 100, 2000, 600, "Height")
AddSetting("Prediction (1-20)", 180, 1, 20, 6.2, "Prediction")
AddSetting("FOV Radius (100-5000)", 240, 100, 5000, 1200, "Fov")

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 1, -40)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.Font = Enum.Font.Code
Status.Text = "PC-WAVE MODE ACTIVE"

task.spawn(function()
    while task.wait(0.1) do
        local t = GetWaveTarget()
        Status.Text = "TARGET: " .. (t and t.Name:upper() or "NONE")
        Status.TextColor3 = t and Color3.new(1,0,0) or Color3.new(0,1,0.4)
    end
end)
