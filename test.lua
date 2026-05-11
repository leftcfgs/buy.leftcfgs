-- [[ tested internal v15.0: ORBIT-BREAKER ]]
-- OPTIMIZED FOR WAVE EXECUTOR (PC)
-- NO SPECIAL CHARACTERS - PURE STABILITY

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NetworkClient = game:GetService("NetworkClient")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // SETTINGS
getgenv().Config = {
    Enabled = true,
    Stack = 250, -- PC POWER
    Height = 450,
    Prediction = 7.0,
    Fov = 1000,
    ToggleKey = Enum.KeyCode.K
}

-- // TARGETING (ORBIT COMPATIBLE)
local function GetTarget()
    local target = nil
    local dist = math.huge
    local mPos = UserInputService:GetMouseLocation()
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local sPos, vis = Camera:WorldToViewportPoint(head.Position)
                    local d = (Vector2.new(sPos.X, sPos.Y) - mPos).Magnitude
                    if d < getgenv().Config.Fov and d < dist then
                        target = p
                        dist = d
                    end
                end
            end
        end
    end
    return target
end

-- // CORE PACKET HOOK
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" and getgenv().Config.Enabled then
        if self.Name:find("Fire") or self.Name:find("Shoot") or self.Name:find("Throw") then
            local t = GetTarget()
            if t and t.Character:FindFirstChild("Head") then
                task.spawn(function()
                    for i = 1, getgenv().Config.Stack do
                        local h = t.Character.Head
                        local r = t.Character.HumanoidRootPart
                        
                        -- HIGH SPEED PREDICTION FOR ORBIT
                        local ping = NetworkClient:GetPing()
                        local pred = h.Position + (r.Velocity * (ping + 0.01) * getgenv().Config.Prediction)
                        local sky = pred + Vector3.new(0, getgenv().Config.Height, 0)
                        
                        local spoof = table.clone(args)
                        for idx, val in pairs(spoof) do
                            if typeof(val) == "Vector3" then 
                                spoof[idx] = Vector3.new(0, -5000, 0)
                            elseif typeof(val) == "CFrame" then 
                                spoof[idx] = CFrame.new(sky, pred)
                            elseif typeof(val) == "table" then
                                if val.Hit or val.Instance then
                                    val.Hit, val.Instance, val.Position = h, h, pred
                                    val.Distance = getgenv().Config.Height
                                end
                            end
                        end
                        old(self, unpack(spoof))
                        if i % 80 == 0 then RunService.Heartbeat:Wait() end
                    end
                end)
                return nil
            end
        end
    end
    return old(self, ...)
end)

-- // SIMPLE UI (NO SYMBOLS)
local SG = Instance.new("ScreenGui", game.CoreGui)
local M = Instance.new("Frame", SG)
M.Size, M.Position = UDim2.new(0, 300, 0, 250), UDim2.new(0.5, -150, 0.5, -125)
M.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
M.Active, M.Draggable = true, true

local Title = Instance.new("TextLabel", M)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 40), "ORBIT-BREAKER v15"
Title.BackgroundColor3, Title.TextColor3 = Color3.fromRGB(30, 30, 30), Color3.new(1, 0, 0)
Title.Font = Enum.Font.Code

local function CreateBox(name, y, default, key)
    local l = Instance.new("TextLabel", M)
    l.Size, l.Position = UDim2.new(0.6, 0, 0, 30), UDim2.new(0, 10, 0, y)
    l.Text, l.TextColor3, l.BackgroundTransparency = name, Color3.new(1,1,1), 1
    l.TextXAlignment = Enum.TextXAlignment.Left

    local b = Instance.new("TextBox", M)
    b.Size, b.Position = UDim2.new(0, 80, 0, 25), UDim2.new(0.7, 0, 0, y)
    b.Text, b.BackgroundColor3, b.TextColor3 = tostring(default), Color3.fromRGB(40,40,40), Color3.new(1,1,1)
    
    b.FocusLost:Connect(function()
        local v = tonumber(b.Text)
        if v then getgenv().Config[key] = v end
    end)
end

CreateBox("Stack Amount", 60, 250, "Stack")
CreateBox("Sky Height", 100, 450, "Height")
CreateBox("Prediction", 140, 7.0, "Prediction")
CreateBox("FOV Size", 180, 1000, "Fov")

local Status = Instance.new("TextLabel", M)
Status.Size, Status.Position = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30)
Status.Text, Status.TextColor3, Status.BackgroundTransparency = "READY", Color3.new(0,1,0), 1

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == getgenv().Config.ToggleKey then M.Visible = not M.Visible end
end)

task.spawn(function()
    while task.wait(0.1) do
        local t = GetTarget()
        Status.Text = t and "TARGETING: " .. t.Name:upper() or "WAITING..."
        Status.TextColor3 = t and Color3.new(1,0,0) or Color3.new(0,1,0)
    end
end)
