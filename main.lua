local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local guiParent = player:WaitForChild("PlayerGui")

-- BodyScale作成
for _, name in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale"}) do
    if not humanoid:FindFirstChild(name) then
        local val = Instance.new("NumberValue")
        val.Name = name
        val.Value = 1
        val.Parent = humanoid
    end
end

local heightScale = humanoid:FindFirstChild("BodyHeightScale")
local widthScale = humanoid:FindFirstChild("BodyWidthScale")
local depthScale = humanoid:FindFirstChild("BodyDepthScale")

-- GUI作成
local ScreenGui = Instance.new("ScreenGui", guiParent)
ScreenGui.Name = "SizeControlGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.3, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

-- ドラッグ可能
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "サイズ調整"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundTransparency = 1

-- ON/OFFボタン
local toggleBtn = Instance.new("TextButton", MainFrame)
toggleBtn.Size = UDim2.new(0.4,0,0,30)
toggleBtn.Position = UDim2.new(0.05,0,0.25,0)
toggleBtn.Text = "ON"
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 16
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,170,120)
local active = true

toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    toggleBtn.Text = active and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,170,120) or Color3.fromRGB(170,0,0)
end)

-- スライダー本体
local sliderFrame = Instance.new("Frame", MainFrame)
sliderFrame.Size = UDim2.new(0.9,0,0,20)
sliderFrame.Position = UDim2.new(0.05,0,0.65,0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
sliderFrame.BorderSizePixel = 0

local sliderHandle = Instance.new("Frame", sliderFrame)
sliderHandle.Size = UDim2.new(0,20,1,0)
sliderHandle.Position = UDim2.new(0,0,0,0)
sliderHandle.BackgroundColor3 = Color3.fromRGB(0,170,120)

-- ドラッグ機能
local dragging = false
local sliderWidth = sliderFrame.AbsoluteSize.X

sliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
sliderHandle.InputEnded:Connect(function(input)
    dragging = false
end)
sliderFrame.InputEnded:Connect(function(input)
    dragging = false
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouse = UIS:GetMouseLocation()
        local framePos = sliderFrame.AbsolutePosition.X
        local x = math.clamp(mouse.X - framePos - sliderHandle.AbsoluteSize.X/2, 0, sliderFrame.AbsoluteSize.X - sliderHandle.AbsoluteSize.X)
        sliderHandle.Position = UDim2.new(0, x, 0, 0)
        local scale = x / (sliderFrame.AbsoluteSize.X - sliderHandle.AbsoluteSize.X) * 2 -- 0~2倍
        if active then
            heightScale.Value = scale
            widthScale.Value = scale
            depthScale.Value = scale
        end
    end
end)
