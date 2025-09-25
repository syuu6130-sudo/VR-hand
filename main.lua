-- =============================================
-- SETTINGS
-- =============================================
local PermanentDeathEnabled = false -- true = PermanentDeath ON
local control = "mobile" -- "pc" or "mobile"

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
-- ARM SETUP
-- =============================================
local function getArmJoints(char)
    local joints = {}
    -- R15パーツ
    joints.LeftUpper = char:FindFirstChild("LeftUpperArm")
    joints.LeftLower = char:FindFirstChild("LeftLowerArm")
    joints.LeftHand = char:FindFirstChild("LeftHand")
    joints.RightUpper = char:FindFirstChild("RightUpperArm")
    joints.RightLower = char:FindFirstChild("RightLowerArm")
    joints.RightHand = char:FindFirstChild("RightHand")
    return joints
end

local joints = getArmJoints(character)

-- 初期C0を保存
local initC0 = {
    LeftUpper = joints.LeftUpper.CFrame,
    LeftLower = joints.LeftLower.CFrame,
    LeftHand = joints.LeftHand.CFrame,
    RightUpper = joints.RightUpper.CFrame,
    RightLower = joints.RightLower.CFrame,
    RightHand = joints.RightHand.CFrame
}

-- =============================================
-- MOBILE JOYSTICKS
-- =============================================
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local function createStick(side)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,120,0,120)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BackgroundTransparency = 0.3
    frame.Parent = screenGui

    if side == "left" then
        frame.Position = UDim2.new(0.35,0,0.8,0)
    else
        frame.Position = UDim2.new(0.65,0,0.8,0)
    end

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

local leftInput = Vector2.zero
local rightInput = Vector2.zero

local function stickHandler(stick,frame,updateFunc)
    local dragging = false
    local center = stick.Position

    stick.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
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
            if offset.Magnitude > maxDist then
                offset = offset.Unit*maxDist
            end
            stick.Position = UDim2.new(0.5,offset.X,0.5,offset.Y)
            updateFunc(offset/maxDist)
        end
    end)
end

stickHandler(leftStick,leftFrame,function(vec)
    leftInput = vec
end)
stickHandler(rightStick,rightFrame,function(vec)
    rightInput = vec
end)

-- =============================================
-- UPDATE LOOP
-- =============================================
local armSensitivity = 1.2
local lerpSpeed = 0.15
local armStretch = 1.5
local zOffset = -0.5

RunService.RenderStepped:Connect(function()
    -- 左腕
    if joints.LeftUpper and joints.LeftLower and joints.LeftHand then
        local pitch = -leftInput.Y*armSensitivity
        local yaw = leftInput.X*armSensitivity
        joints.LeftUpper.CFrame = joints.LeftUpper.CFrame:Lerp(initC0.LeftUpper * CFrame.Angles(pitch/2, yaw/2, 0) * CFrame.new(0,0,zOffset), lerpSpeed)
        joints.LeftLower.CFrame = joints.LeftLower.CFrame:Lerp(initC0.LeftLower * CFrame.Angles(pitch/2, yaw/2, 0), lerpSpeed)
        joints.LeftHand.CFrame = joints.LeftHand.CFrame:Lerp(initC0.LeftHand * CFrame.Angles(pitch/3, yaw/3, 0), lerpSpeed)
    end

    -- 右腕
    if joints.RightUpper and joints.RightLower and joints.RightHand then
        local pitch = -rightInput.Y*armSensitivity
        local yaw = rightInput.X*armSensitivity
        joints.RightUpper.CFrame = joints.RightUpper.CFrame:Lerp(initC0.RightUpper * CFrame.Angles(pitch/2, yaw/2, 0) * CFrame.new(0,0,zOffset), lerpSpeed)
        joints.RightLower.CFrame = joints.RightLower.CFrame:Lerp(initC0.RightLower * CFrame.Angles(pitch/2, yaw/2, 0), lerpSpeed)
        joints.RightHand.CFrame = joints.RightHand.CFrame:Lerp(initC0.RightHand * CFrame.Angles(pitch/3, yaw/3, 0), lerpSpeed)
    end
end)

-- =============================================
-- CHARACTER MOVEMENT
-- =============================================
RunService.RenderStepped:Connect(function()
    local moveDir = Vector3.zero
    moveDir += Vector3.new(leftInput.X,0,-leftInput.Y)
    humanoid:Move(moveDir,true)
end)

-- =============================================
-- PERMANENT DEATH
-- =============================================
if not PermanentDeathEnabled then
    humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end
