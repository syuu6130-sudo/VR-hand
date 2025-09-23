-- 🖥️ 豪華多機能GUI
-- 作者: syuu用 特別版

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- 🪟 GUI作成
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Name = "MainUI"

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 16)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(200, 200, 255)

-- タイトルバー
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚙ 多機能チートパネル"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

-- 最小化ボタン
local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20

local Minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	Minimized = not Minimized
	if Minimized then
		MainFrame:TweenSize(UDim2.new(0, 320, 0, 40), "Out", "Quad", 0.3)
	else
		MainFrame:TweenSize(UDim2.new(0, 320, 0, 420), "Out", "Quad", 0.3)
	end
end)

-- 🖲 ボタン生成関数
local function createButton(name, y, callback)
	local Button = Instance.new("TextButton", MainFrame)
	Button.Size = UDim2.new(0.9, 0, 0, 40)
	Button.Position = UDim2.new(0.05, 0, 0, y)
	Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Button.Text = name
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.Font = Enum.Font.FredokaOne
	Button.TextSize = 18

	local corner = Instance.new("UICorner", Button)
	corner.CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", Button)
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(150,150,255)

	local toggled = false
	Button.MouseButton1Click:Connect(function()
		toggled = not toggled
		Button.BackgroundColor3 = toggled and Color3.fromRGB(60, 100, 255) or Color3.fromRGB(40, 40, 40)
		callback(toggled)
	end)
end

-- 🛡 自動パリィ（近距離）
createButton("🛡 自動パリィ（近距離）", 50, function(enabled)
	if enabled then
		print("近距離パリィ: ON")
	else
		print("近距離パリィ: OFF")
	end
end)

-- ⚡ 自動パリィ（即反応）
createButton("⚡ 自動パリィ（即反応）", 100, function(enabled)
	if enabled then
		print("即反応パリィ: ON")
	else
		print("即反応パリィ: OFF")
	end
end)

-- ✨ 無敵（Godモード）
createButton("✨ 無敵（Godモード）", 150, function(enabled)
	if enabled then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.MaxHealth = math.huge
			LocalPlayer.Character.Humanoid.Health = math.huge
		end
	else
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.MaxHealth = 100
			LocalPlayer.Character.Humanoid.Health = 100
		end
	end
end)

-- 🦘 スーパージャンプ
createButton("🦘 スーパージャンプ", 200, function(enabled)
	if enabled then
		LocalPlayer.Character.Humanoid.JumpPower = 200
	else
		LocalPlayer.Character.Humanoid.JumpPower = 50
	end
end)

-- ⚡ 超スピード
createButton("⚡ 超スピード", 250, function(enabled)
	if enabled then
		LocalPlayer.Character.Humanoid.WalkSpeed = 100
	else
		LocalPlayer.Character.Humanoid.WalkSpeed = 16
	end
end)

-- 🪄 エイムアシスト
createButton("🎯 エイムアシスト", 300, function(enabled)
	if enabled then
		print("エイムアシスト: ON")
	else
		print("エイムアシスト: OFF")
	end
end)

-- 💨 ワープ（瞬間移動）
createButton("💨 ワープ（クリック地点へ）", 350, function(enabled)
	if enabled then
		print("ワープモードON：画面をクリックして移動")
		local conn
		conn = UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local mousePos = UIS:GetMouseLocation()
				local ray = workspace.CurrentCamera:ScreenPointToRay(mousePos.X, mousePos.Y)
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000)
				if raycastResult and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position)
				end
			end
		end)
	else
		print("ワープモードOFF")
	end
end)
