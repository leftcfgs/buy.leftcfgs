-- Roblox Rivals Unlock All Skins 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusUnlockAll"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 200)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "NEXUS Rivals Unlock All"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame
Instance.new("UICorner", Title)

local UnlockButton = Instance.new("TextButton")
UnlockButton.Size = UDim2.new(1, -40, 0, 60)
UnlockButton.Position = UDim2.new(0, 20, 0, 70)
UnlockButton.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
UnlockButton.Text = "UNLOCK ALL SKINS"
UnlockButton.TextColor3 = Color3.new(1,1,1)
UnlockButton.Font = Enum.Font.GothamBold
UnlockButton.TextSize = 18
UnlockButton.Parent = Frame
Instance.new("UICorner", UnlockButton)

-- Unlock All 処理
UnlockButton.MouseButton1Click:Connect(function()
    print("Unlock All Skins Activated")
    
    -- 武器スキン強制変更
    local function unlockTool(tool)
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("MeshPart") or v:IsA("SpecialMesh") or v:IsA("Texture") then
                v.TextureID = "rbxassetid://0" -- デフォルト解除風
                -- 必要ならここに好きなスキンIDを入れる
            end
        end
    end

    -- 現在持ってる武器
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then unlockTool(tool) end
        end
    end

    -- バックパック
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then unlockTool(tool) end
    end
end)

-- Kキーで表示/非表示
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        Frame.Visible = not Frame.Visible
    end
end)

print("best skinchange LOADED - KキーでUI表示")
