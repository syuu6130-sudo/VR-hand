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
-- FUNCTION: Fix Arms (always visible)
-- =============================================
local function FixArms()
    for _, limbName in pairs({"Left Arm","Right Arm"}) do
        local arm = character:FindFirstChild(limbName)
        if not arm then
            arm = Instance.new("Part")
            arm.Name = limbName
            arm.Size = Vector3.new(1,2,1)
            arm.Anchored = false
            arm.CanCollide = false
            arm.BrickColor = BrickColor.new("Pastel brown")
            arm.Parent = character
            local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            if torso then
                local weld = Instance.new("Motor6D")
                weld.Part0 = torso
                weld.Part1 = arm
                weld.Parent = arm
            end
        end
    end
end

-- =============================================
-- FUNCTION: Mobile Joysticks (left=left arm, right=right arm)
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

-- Drag handling
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
-- ARM CONTROL SETTINGS
-- =============================================
local armSensitivity = 1.8
-- 修正版オフセット（前に出さない）
local rightOffset = CFrame.new(0.6, -0.5, 0) -- 少し左寄り
local leftOffset  = CFrame.new(-0.6, -0.5, 0) -- 少し右寄り

-- =============================================
-- UPDATE LOOP
-- =============================================
RunService.RenderStepped:Connect(function()
    FixArms()

    -- 左手操作
    local leftArm = character:FindFirstChild("Left Arm")
    if leftArm and leftArm:FindFirstChildOfClass("Motor6D") then
        local joint = leftArm:FindFirstChildOfClass("Motor6D")
        joint.C0 = leftOffset * CFrame.Angles(-leftInput.Y*armSensitivity, leftInput.X*armSensitivity, 0)
    end

    -- 右手操作
    local rightArm = character:FindFirstChild("Right Arm")
    if rightArm and rightArm:FindFirstChildOfClass("Motor6D") then
        local joint = rightArm:FindFirstChildOfClass("Motor6D")
        joint.C0 = rightOffset * CFrame.Angles(-rightInput.Y*armSensitivity, rightInput.X*armSensitivity, 0)
    end
end)

-- =============================================
-- PermanentDeath
-- =============================================
if not PermanentDeathEnabled then
    humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

