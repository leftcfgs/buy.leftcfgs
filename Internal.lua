-- Roblox Rivals Skin Changer with UI (他の人も見える版)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local SkinConfig = {
    Enabled = true,
}

local SelectedSkin = nil

-- ====================== UI ======================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 500)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundColor3 = Color3.fromRGB(25,25,35)
Title.Text = "NEXUS Rivals Skin Changer"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title)

-- Unlock All ボタン
local UnlockAll = Instance.new("TextButton", MainFrame)
UnlockAll.Size = UDim2.new(1, -40, 0, 50)
UnlockAll.Position = UDim2.new(0, 20, 0, 70)
UnlockAll.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
UnlockAll.Text = "UNLOCK ALL SKINS"
UnlockAll.TextColor3 = Color3.new(1,1,1)
UnlockAll.Font = Enum.Font.GothamBold
UnlockAll.TextSize = 15
Instance.new("UICorner", UnlockAll)

UnlockAll.MouseButton1Click:Connect(function()
    print("Unlock All Activated (Rivalsでは限界あり)")
    -- ここに全スキン解除処理を入れる（ゲームによる）
end)

-- スキン選択例（実際のIDは自分で調べて入れて）
local skins = {
    {Name = "Default", ID = ""},
    {Name = "Golden Knife", ID = "rbxassetid://YOUR_GOLDEN_ID"},
    {Name = "Red Dragon", ID = "rbxassetid://YOUR_DRAGON_ID"},
    {Name = "Galaxy", ID = "rbxassetid://YOUR_GALAXY_ID"},
}

local y = 140
for _, skin in ipairs(skins) do
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -40, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = skin.Name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        SelectedSkin = skin.ID
        print("Selected Skin: " .. skin.Name)
    end)
    y = y + 50
end

-- ====================== スキン適用 ======================
local function ApplySkinToTool(tool)
    if not tool or not SelectedSkin or SelectedSkin == "" then return end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("MeshPart") or v:IsA("SpecialMesh") then
            v.TextureID = SelectedSkin
            -- MeshIdも変えたい場合はここに追加
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not SkinConfig.Enabled then return end

    -- 武器にスキン適用
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                ApplySkinToTool(tool)
            end
        end
    end

    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            ApplySkinToTool(tool)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("NEXUS Rivals Skin Changer with UI LOADED")
print("KキーでUI表示")
