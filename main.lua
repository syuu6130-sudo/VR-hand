local VRService = game:GetService("VRService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not VRService.VREnabled then return end

    -- 左腕
    local leftUpper = char:FindFirstChild("LeftUpperArm")
    local leftLower = char:FindFirstChild("LeftLowerArm")
    local leftHand = char:FindFirstChild("LeftHand")

    -- 右腕
    local rightUpper = char:FindFirstChild("RightUpperArm")
    local rightLower = char:FindFirstChild("RightLowerArm")
    local rightHand = char:FindFirstChild("RightHand")

    local function applyIK(upper, lower, hand, handCFrame)
        if not (upper and lower and hand and handCFrame) then return end

        -- 手首の目標位置
        local targetCF = root.CFrame * handCFrame

        -- 簡易IK: 手首に向かう方向でUpperArm/LowerArmのCFrameを調整
        upper.CFrame = CFrame.new(upper.Position, targetCF.Position) -- 上腕を手に向ける
        lower.CFrame = CFrame.new(lower.Position, targetCF.Position) -- 前腕も手に向ける
        hand.CFrame = targetCF -- 手は正確にCFrameを反映
    end

    -- 左腕
    applyIK(leftUpper, leftLower, leftHand, VRService:GetUserCFrame(Enum.UserCFrame.LeftHand))
    -- 右腕
    applyIK(rightUpper, rightLower, rightHand, VRService:GetUserCFrame(Enum.UserCFrame.RightHand))
end)
