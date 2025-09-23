-- サイズ入力用 TextBox
local sizeBox = Instance.new("TextBox", MainFrame)
sizeBox.Size = UDim2.new(0.8,0,0,30)
sizeBox.Position = UDim2.new(0.1,0,0.65,0)
sizeBox.PlaceholderText = "例: 1.5"
sizeBox.ClearTextOnFocus = false
sizeBox.Font = Enum.Font.Gotham
sizeBox.TextSize = 16
sizeBox.TextColor3 = Color3.fromRGB(255,255,255)
sizeBox.BackgroundColor3 = Color3.fromRGB(60,60,60)

-- 適用ボタン
local applyBtn = Instance.new("TextButton", MainFrame)
applyBtn.Size = UDim2.new(0.4,0,0,30)
applyBtn.Position = UDim2.new(0.3,0,0.8,0)
applyBtn.Text = "適用"
applyBtn.Font = Enum.Font.Gotham
applyBtn.TextSize = 16
applyBtn.BackgroundColor3 = Color3.fromRGB(0,170,120)
applyBtn.TextColor3 = Color3.fromRGB(255,255,255)

applyBtn.MouseButton1Click:Connect(function()
    if active then
        local val = tonumber(sizeBox.Text)
        if val then
            val = math.clamp(val, 0.1, 5) -- 0.1～5倍の範囲
            heightScale.Value = val
            widthScale.Value = val
            depthScale.Value = val
        end
    end
end)
