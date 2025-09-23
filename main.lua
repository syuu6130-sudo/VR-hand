-- サービス
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- BodyScale がなければ作成
for _, name in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale"}) do
    if not humanoid:FindFirstChild(name) then
        local val = Instance.new("NumberValue")
        val.Name = name
        val.Value = 1
        val.Parent = humanoid
    end
end

local heightScale = humanoid.BodyHeightScale
local widthScale = humanoid.BodyWidthScale
local depthScale = humanoid.BodyDepthScale

-- GUI 作成
local guiParent = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui", guiParent)
ScreenGui.Name = "SizeControlGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.3,0,0.4,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "キャラクターサイズ調整"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundTransparency = 1

-- TextBox
local sizeBox = Instance.new("TextBox", MainFrame)
sizeBox.Size = UDim2.new(0.8,0,0,30)
sizeBox.Position = UDim2.new(0.1,0,0.5,0)
sizeBox.PlaceholderText = "例: 1.5 (0.1~5)"
sizeBox.ClearTextOnFocus = false
sizeBox.Font = Enum.Font.Gotham
sizeBox.TextSize = 16
sizeBox.TextColor3 = Color3.fromRGB(255,255,255)
sizeBox.BackgroundColor3 = Color3.fromRGB(60,60,60)

-- 適用ボタン
local applyBtn = Instance.new("TextButton", MainFrame)
applyBtn.Size = UDim2.new(0.4,0,0,30)
applyBtn.Position = UDim2.new(0.3,0,0.75,0)
applyBtn.Text = "適用"
applyBtn.Font = Enum.Font.Gotham
applyBtn.TextSize = 16
applyBtn.BackgroundColor3 = Color3.fromRGB(0,170,120)
applyBtn.TextColor3 = Color3.fromRGB(255,255,255)

-- サイズ適用関数
local function applySize()
    local val = tonumber(sizeBox.Text)
    if val then
        val = math.clamp(val, 0.1, 5)
        heightScale.Value = val
        widthScale.Value = val
        depthScale.Value = val
    end
end

-- ボタンで適用
applyBtn.MouseButton1Click:Connect(applySize)

-- Enter / タップで適用 (PC とスマホ対応)
sizeBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        applySize()
    end
end)
