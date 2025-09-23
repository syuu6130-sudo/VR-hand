local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

-- 視点用（スティック/ジャイロ）
local yaw, pitch = 0, 0

-- スティック入力で手の向きを変える（Thumbstick2）
ContextActionService:BindAction("HandControl", function(_, state, input)
    if state == Enum.UserInputState.Change and input.Position then
        yaw -= input.Position.X * 0.1
        pitch = math.clamp(pitch - input.Position.Y * 0.1, -80, 80)
    end
end, false, Enum.KeyCode.Thumbstick2)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local leftUpper = char:FindFirstChild("LeftUpperArm")
    local leftLower = char:FindFirstChild("LeftLowerArm")
    local leftHand = char:FindFirstChild("LeftHand")
    local rightUpper = char:FindFirstChild("RightUpperArm")
    local rightLower = char:FindFirstChild("RightLowerArm")
    local rightHand = char:FindFirstChild("RightHand")
    if not (root and leftUpper and leftLower and leftHand and rightUpper and rightLower and rightHand) then return end

    -- ジャイロの回転取得（端末傾き）
    local cf = CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)
    if UserInputService.GyroscopeEnabled then
        local gyroRot = UserInputService:GetDeviceRotation()
        if gyroRot then
            cf = CFrame.fromOrientation(gyroRot.X, gyroRot.Y, gyroRot.Z)
        end
    end

    local function applyArmIK(upper, lower, hand, targetCF)
        if not (upper and lower and hand and targetCF) then return end
        local upperPos = upper.Position
        local lowerPos = lower.Position
        local handPos = (root.CFrame * targetCF).Position

        local dir = (handPos - upperPos).Unit
        local elbowDir = Vector3.new(dir.X, math.clamp(dir.Y, -0.8, 0.8), dir.Z)

        upper.CFrame = CFrame.new(upperPos, upperPos + elbowDir)
        lower.CFrame = CFrame.new(lowerPos, handPos)
        hand.CFrame = root.CFrame * targetCF
    end

    -- 左腕
    applyArmIK(leftUpper, leftLower, leftHand, cf)
    -- 右腕
    applyArmIK(rightUpper, rightLower, rightHand, cf)
end)
