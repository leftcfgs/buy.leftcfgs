local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Version = Instance.new("TextLabel")
local DecorationLine = Instance.new("Frame")

ScreenGui.Parent = game.CoreGui
MainFrame.Name = "L-Internal_UI"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

DecorationLine.Parent = MainFrame
DecorationLine.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
DecorationLine.Position = UDim2.new(0, 0, 0, 0)
DecorationLine.Size = UDim2.new(1, 0, 0, 2)

Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Size = UDim2.new(0, 200, 0, 30)
Title.Text = "L-INTERNAL.hook"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left

Version.Parent = MainFrame
Version.BackgroundTransparency = 1
Version.Position = UDim2.new(0, 10, 0, 25)
Version.Size = UDim2.new(0, 200, 0, 20)
Version.Text = "v1.0.0 | Private Development"
Version.TextColor3 = Color3.fromRGB(150, 150, 150)
Version.TextSize = 10
Version.Font = Enum.Font.Code
Version.TextXAlignment = Enum.TextXAlignment.Left

print("L-Internal.hook: Successfully Injected")
