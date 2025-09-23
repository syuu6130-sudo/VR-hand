-- サービス取得
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- キャラクター取得
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- BodyScaleがない場合作成
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
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SizeControlGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

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

-- スライダー（簡易版）
local slider = Instance.new("TextBox", MainFrame)
slider.Size = UDim2.new(0.9,0,0,30)
slider.Position = UDim2.new(0.05,0,0.65,0)
slider.Text = "1"  -- 初期値
slider.ClearTextOnFocus = false
slider.TextScaled = true

-- 毎フレーム更新
RunService.RenderStepped:Connect(function()
    if not active then return end
    local val = tonumber(slider.Text)
    if val then
        heightScale.Value = val
        widthScale.Value = val
        depthScale.Value = val
    end
end)
