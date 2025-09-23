-- LocalScriptとして StarterPlayerScripts に配置
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- キャラクターのロードを待つ
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- R15パーツ取得
local leftUpper = char:WaitForChild("LeftUpperArm")
local leftLower = char:WaitForChild("LeftLowerArm")
local leftHand = char:WaitForChild("LeftHand")
local rightUpper = char:WaitForChild("RightUpperArm")
local rightLower = char:WaitForChild("RightLowerArm")
local rightHand = char:WaitForChild("RightHand")

-- 手の回転用変数
local yaw, pitch = 0, 0

-- スティック入力で回転
local function handleThumbstick(_, state, input)
	if state == Enum.UserInputState.Change and input.Position then
		yaw = yaw - input.Position.X * 0.1
		pitch = math.clamp(pitch - input.Position.Y * 0.1, -80, 80)
	end
end
CAS:BindAction("HandControl", handleThumbstick, false, Enum.KeyCode.Thumbstick2)

-- 腕IK関数
local function applyArmIK(upper, lower, hand, rootCF, targetCF)
	if not (upper and lower and hand and rootCF and targetCF) then return end
	local upperPos = upper.Position
	local lowerPos = lower.Position
	local handPos = (rootCF * targetCF).Position

	local dir = (handPos - upperPos).Unit
	local elbowDir = Vector3.new(dir.X, math.clamp(dir.Y, -0.8, 0.8), dir.Z)

	upper.CFrame = CFrame.new(upperPos, upperPos + elbowDir)
	lower.CFrame = CFrame.new(lowerPos, handPos)
	hand.CFrame = rootCF * targetCF
end

-- 毎フレーム更新
RunService.RenderStepped:Connect(function()
	if not char or not root then return end

	local cf = CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)

	-- ジャイロが使えるなら上書き
	if UIS.GyroscopeEnabled then
		local gyroRot = UIS:GetDeviceRotation()
		if gyroRot then
			cf = CFrame.fromOrientation(gyroRot.X, gyroRot.Y, gyroRot.Z)
		end
	end

	-- 左腕
	applyArmIK(leftUpper, leftLower, leftHand, root.CFrame, cf)
	-- 右腕
	applyArmIK(rightUpper, rightLower, rightHand, root.CFrame, cf)
end)
