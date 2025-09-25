-- =============================================
-- SETTINGS
-- =============================================
local PermanentDeathEnabled = false
local armStretch = 2        -- 肩から手首までの伸び倍率
local sensitivity = 1.5     -- スティック操作感度
local lerpSpeed = 0.15      -- 補間速度

-- =============================================
-- SERVICES
-- =============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- =============================================
-- ARM REFERENCES (R15)
-- =============================================
local function getArmJoints(side)
    local upper = character:FindFirstChild(side.."UpperArm")
    local lower = character:FindFirstChild(side.."LowerArm")
    local hand = character:FindFirstChild(side.."Hand")
    if upper and lower and hand then
        return {
            Upper = upper:FindFirstChild(side.."Shoulder"),
            Lower = lower:FindFirstChild(side.."Elbow"),
            Hand = hand:FindFirstChild(side.."Wrist"),
            Parts = {Upper=upper, Lower=lower, Hand=hand}
        }
    end
end

local rightJoints = getArmJoints("Right")
local leftJoints = getArmJoints("Left")

-- =============================================
-- INITIAL C0s
-- =============================================
local initC0 = {}
if rightJoints then
    initC0.RightShoulder = rightJoints.Upper.C0
    initC0.RightElbow = rightJoints.Lower.C0
    initC0.RightWrist = rightJoints.Hand.C0
end
if leftJoints then
    initC0.LeftShoulder = leftJoints.Upper.C0
    initC0.LeftElbow = leftJoints.Lower.C0
    initC0.LeftWrist = leftJoints.Hand.C0
end

-- =============================================
-- MOBILE STICKS
-- =============================================
local rightInput = Vector2.zero
local leftInput = Vector2.zero

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local function createStick(side)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,120,0,120)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BackgroundTransparency = 0.3
    frame.Parent = screenGui
    frame.Position = UDim2.new(side=="left" and 0.35 or 0.65,0,0.8,0)

    local stick = Instance.new("ImageButton")
    stick.Size = UDim2.new(0,60,0,60)
    stick.Position = UDim2.new(0.5,0,0.5,0)
    stick.AnchorPoint = Vector2.new(0.5,0.5)
    stick.BackgroundColor3 = Color3.fromRGB(200,200,200)
    stick.BackgroundTransparency = 0.2
    stick.AutoButtonColor = false
    stick.Parent = frame

    return frame, stick
end

local leftFrame,leftStick = createStick("left")
local rightFrame,rightStick = createStick("right")

local function stickHandler(stick, frame, updateFunc)
    local dragging = false
    local center = stick.Position
    stick.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    stick.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            stick.Position = center
            updateFunc(Vector2.zero)
        end
    end)
    stick.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local rel = frame.AbsolutePosition + frame.AbsoluteSize/2
            local offset = Vector2.new(input.Position.X-rel.X, input.Position.Y-rel.Y)
            local maxDist = frame.AbsoluteSize.X/2
            if offset.Magnitude > maxDist then offset = offset.Unit*maxDist end
            stick.Position = UDim2.new(0.5,offset.X,0.5,offset.Y)
            updateFunc(offset/maxDist)
        end
    end)
end

stickHandler(leftStick,leftFrame,function(vec) leftInput = vec end)
stickHandler(rightStick,rightFrame,function(vec) rightInput = vec end)

-- =============================================
-- ARM VR NATURAL MOVEMENT
-- =============================================
RunService.RenderStepped:Connect(function()
    local function updateArm(joints,input,initC0)
        if not joints then return end

        local pitch = -input.Y*sensitivity
        local yaw = input.X*sensitivity

        -- 肩→肘→手首を自然に補間
        local shoulderTarget = initC0.Upper * CFrame.Angles(pitch,yaw,0) * CFrame.new(0,0,-0.5)
        joints.Upper.C0 = joints.Upper.C0:Lerp(shoulderTarget, lerpSpeed)

        local elbowTarget = initC0.Lower * CFrame.Angles(pitch/2,yaw/2,0)
        joints.Lower.C0 = joints.Lower.C0:Lerp(elbowTarget, lerpSpeed)

        local wristTarget = initC0.Hand * CFrame.Angles(pitch/3,yaw/3,0)
        joints.Hand.C0 = joints.Hand.C0:Lerp(wristTarget, lerpSpeed)

        -- 肩から手首まで自然に伸ばす
        for _,part in pairs(joints.Parts) do
            part.Size = Vector3.new(part.Size.X, part.Size.Y*armStretch, part.Size.Z)
        end
    end

    updateArm(rightJoints,rightInput,{Upper=initC0.RightShoulder,Lower=initC0.RightElbow,Hand=initC0.RightWrist})
    updateArm(leftJoints,leftInput,{Upper=initC0.LeftShoulder,Lower=initC0.LeftElbow,Hand=initC0.LeftWrist})
end)

-- =============================================
-- PERMANENT DEATH
-- =============================================
if not PermanentDeathEnabled then
    humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then humanoid.Health = humanoid.MaxHealth end
    end)
end
