-- LocalScriptとして配置（StarterPlayerScripts推奨）
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 手の回転用
local yaw, pitch = 0, 0

-- スティック入力で回転
local function handleThumbstick(_, state, input)
	if state == Enum.UserInputState.Change and input.Position then
		yaw = yaw - input.Position.X * 0.1
		pitch = math.clamp(pitch - input.Position.Y * 0.1, -80, 80)
	end
end
local CAS = game:GetService("ContextActionService")
CAS:BindAction("HandControl", handleThumbstick, false, Enum.KeyCode.Thumbstick2)

-- 腕IK関数
local function applyArmIK(upper, lower, hand, rootCF, targetCF)
	if not (upper and lower and hand and rootCF and targetCF) then return end
	local upperPos = upper.Position
	local lowerPos = lower.Position
	local handPos = (rootCF * targetCF).Position

	-- 上腕向き
	local dir = (handPos - upperPos).Unit
	local elbowDir = Vector3.new(dir.X, math.clamp(dir.Y, -0.8, 0.8), dir.Z)
	upper.CFrame = CFrame.new(upperPos, upperPos + elbowDir)
	lower.CFrame = CFrame.new(lowerPos, handPos)
	hand.CFrame = rootCF * targetCF
end

-- 毎フレーム更新
RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- ジャイロが使えるなら回転取得
	local cf = CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)
	if UIS.GyroscopeEnabled then
		local gyroRot = UIS:GetDeviceRotation()
		if gyroRot then
			cf = CFrame.fromOrientation(gyroRot.X, gyroRot.Y, gyroRot.Z)
		end
	end

	-- 左腕
	applyArmIK(char:FindFirstChild("LeftUpperArm"),
			   char:FindFirstChild("LeftLowerArm"),
			   char:FindFirstChild("LeftHand"),
			   root.CFrame,
			   cf)
	-- 右腕
	applyArmIK(char:FindFirstChild("RightUpperArm"),
			   char:FindFirstChild("RightLowerArm"),
			   char:FindFirstChild("RightHand"),
			   root.CFrame,
			   cf)
end)
