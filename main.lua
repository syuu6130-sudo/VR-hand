-- サービス
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Character のロード待機
local char = player.Character or player.CharacterAdded:Wait()
char:WaitForChild("Humanoid")
char:WaitForChild("HumanoidRootPart")

-- GUI 作成
local guiParent = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui", guiParent)
ScreenGui.Name = "SizeControlGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.3,0,0.4,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true

-- タイトル
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "サイズ調整（直接変更）"
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

-- 適用処理
applyBtn.MouseButton1Click:Connect(function()
    local scale = tonumber(sizeBox.Text)
    if not scale then return end
    scale = math.clamp(scale, 0.1, 5)

    -- 全パーツに対して Scale を適用
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Size = part.Size * scale / (part.Size.Magnitude / 3) -- 適当に比率調整
        end
    end
end)
