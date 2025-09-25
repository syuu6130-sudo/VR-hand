-- =============================================
-- SETTINGS
-- =============================================
local PermanentDeathEnabled = false
local control = "mobile"
local sensitivity = 1.2
local lerpSpeed = 0.12

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
    local upperArm = character:FindFirstChild(side.."UpperArm")
    local lowerArm = character:FindFirstChild(side.."LowerArm")
    local hand = character:FindFirstChild(side.."Hand")
    if upperArm and lowerArm and hand then
        return {
            Upper = upperArm:FindFirstChild(side.."Shoulder"),
            Lower = lowerArm:FindFirstChild(side.."Elbow"),
            Hand = hand:FindFirstChild(side.."Wrist")
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
-- STICK INPUTS
-- =============================================
local rightInput = Vector2.zero
local leftInput = Vector2.zero
local leftStickFixed = false
local rightStickFixed = false
local armStretch = 1.5

-- =============================================
-- CREATE MOBILE STICKS
-- =============================================
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

local leftFrame, leftStick = createStick("left")
local rightFrame, rightStick = createStick("right")

local function stickHandler(stick, frame, updateFunc, fixedFlag)
    local dragging = false
    local center = stick.Position
    stick.InputBegan:Connect(function(input)
        if not fixedFlag() and input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    stick.InputEnded:Connect(function(input)
        if not fixedFlag() and input.UserInputType == Enum.UserInputType.Touch then
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

stickHandler(leftStick,leftFrame,function(vec) leftInput = vec, function() return leftStickFixed end)
stickHandler(rightStick,rightFrame,function(vec) rightInput = vec, function() return rightStickFixed end)

-- =============================================
-- FIXED STICK TOGGLE
-- =============================================
local function createStickToggle(name, pos, flagRef)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,120,0,50)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.ZIndex = 10
    btn.Parent = screenGui
    btn.MouseButton1Click:Connect(function()
        flagRef[1] = not flagRef[1]
    end)
end

createStickToggle("左スティック固定", UDim2.new(0.1,0,0.6,0), {leftStickFixed})
createStickToggle("右スティック固定", UDim2.new(0.8,0,0.6,0), {rightStickFixed})

-- =============================================
-- UPDATE LOOP (VR風腕)
-- =============================================
RunService.RenderStepped:Connect(function()
    local function updateArm(joints,input,initC0)
        if not joints then return end
        local pitch = -input.Y*sensitivity
        local yaw = input.X*sensitivity

        -- 肩回転 + 少し後ろに下げる
        local targetShoulder = initC0.Upper * CFrame.Angles(pitch, yaw, 0) * CFrame.new(0,0,-0.2)
        joints.Upper.C0 = joints.Upper.C0:Lerp(targetShoulder, lerpSpeed)

        -- 肘回転
        local targetElbow = initC0.Lower * CFrame.Angles(pitch/2, yaw/2, 0)
        joints.Lower.C0 = joints.Lower.C0:Lerp(targetElbow, lerpSpeed)

        -- 手首回転
        local targetWrist = initC0.Hand * CFrame.Angles(pitch/3, yaw/3, 0)
        joints.Hand.C0 = joints.Hand.C0:Lerp(targetWrist, lerpSpeed)
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
