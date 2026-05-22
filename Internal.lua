-- Roblox Rivals Skin Changer - 超長め複雑版 (Unlock All 強化)
-- コメント多め・設定項目多め・処理分散版

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

print("=== NEXUS Rivals Skin Changer ===")

local SkinConfig = {
    Enabled = true,
    UnlockAll = false,
    SelectedSkinID = "",
    ApplyToWeapons = true,
    ApplyToCharacter = true,
    ForceTexture = true,
    ForceMesh = true,
    SpamApply = true,  -- 毎フレーム適用
}

-- ====================== UI作成 ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusSkinChanger"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 580)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundColor3 = Color3.fromRGB(25,25,35)
Title.Text = "NEXUS Rivals Skin Changer"
Title.TextColor3 = Color3.fromRGB(0, 255, 220)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame
Instance.new("UICorner", Title)

-- Unlock All ボタン
local UnlockAllBtn = Instance.new("TextButton")
UnlockAllBtn.Size = UDim2.new(1, -40, 0, 65)
UnlockAllBtn.Position = UDim2.new(0, 20, 0, 80)
UnlockAllBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 90)
UnlockAllBtn.Text = "UNLOCK ALL SKINS"
UnlockAllBtn.TextColor3 = Color3.new(1,1,1)
UnlockAllBtn.Font = Enum.Font.GothamBold
UnlockAllBtn.TextSize = 18
UnlockAllBtn.Parent = MainFrame
Instance.new("UICorner", UnlockAllBtn)

UnlockAllBtn.MouseButton1Click:Connect(function()
    SkinConfig.UnlockAll = true
    print("Unlock All 強制モード ON")
end)

-- Kキー でUI表示/非表示
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ====================== スキン適用関数 ======================
local function ApplySkinToTool(tool)
    if not tool or not SkinConfig.UnlockAll then return end

    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            if SkinConfig.ForceTexture then
                obj.TextureID = ""
            end
            if SkinConfig.ForceMesh and obj:FindFirstChild("Mesh") then
                obj.Mesh.MeshId = ""
            end
        end
    end
end

local function ApplyToCharacter(char)
    if not char or not SkinConfig.UnlockAll then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("MeshPart") or part:IsA("Part") then
            if SkinConfig.ForceTexture then
                part.TextureID = ""
            end
        end
    end
end

-- ====================== メインループ ======================
RunService.Heartbeat:Connect(function()
    if not SkinConfig.Enabled then return end

    local char = LocalPlayer.Character
    if char then
        ApplyToCharacter(char)
    end

    -- 武器に適用
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

print("NEXUS Skin Changer 複雑長め版 ロード完了")
print("KキーでUI表示 / Unlock Allボタン押してみ")
