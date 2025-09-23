local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

-- GUIドラッグ可能
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

-- サイズ調整用ボタン
local incrementBtn = Instance.new("TextButton", MainFrame)
incrementBtn.Size = UDim2.new(0.4,0,0,30)
incrementBtn.Position = UDim2.new(0.55,0,0.25,0)
incrementBtn.Text = "サイズ +"
incrementBtn.Font = Enum.Font.Gotham
incrementBtn.TextSize = 16
incrementBtn.BackgroundColor3 = Color3.fromRGB(0,120,170)

local decrementBtn = Instance.new("TextButton", MainFrame)
decrementBtn.Size = UDim2.new(0.4,0,0,30)
decrementBtn.Position = UDim2.new(0.55,0,0.55,0)
decrementBtn.Text = "サイズ -"
decrementBtn.Font = Enum.Font.Gotham
decrementBtn.TextSize = 16
decrementBtn.BackgroundColor3 = Color3.fromRGB(170,120,0)

local step = 0.1

incrementBtn.MouseButton1Click:Connect(function()
    if active then
        local val = math.clamp(heightScale.Value + step, 0.1, 5)
        heightScale.Value = val
        widthScale.Value = val
        depthScale.Value = val
    end
end)

decrementBtn.MouseButton1Click:Connect(function()
    if active then
        local val = math.clamp(heightScale.Value - step, 0.1, 5)
        heightScale.Value = val
        widthScale.Value = val
        depthScale.Value = val
    end
end)
