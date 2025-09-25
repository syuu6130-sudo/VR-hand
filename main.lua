-- =============================================
-- R15 VR風腕 + 左右スティック移動 + PermanentDeath対応
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- R15肩Motor6D取得
local function getMotor(partName)
    local part = character:FindFirstChild(partName)
    if part then
        return part:FindFirstChildOfClass("Motor6D")
    end
    return nil
end

local leftShoulder = getMotor("LeftUpperArm")
local rightShoulder = getMotor("RightUpperArm")

-- =============================================
-- Mobile Joystick
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
local leftInput = Vector3.zero
local rightInput = Vector2.zero

-- スティック操作
local function stickHandler(stick, frame, updateFunc)
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
            stick.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)
            updateFunc(offset/maxDist)
        end
    end)
end

stickHandler(leftStick, leftFrame, function(vec)
    leftInput = Vector3.new(vec.X,0,-vec.Y)
end)
stickHandler(rightStick, rightFrame, function(vec)
    rightInput = vec
end)

-- =============================================
-- Arm VR Update
-- =============================================
local armSensitivity = 1.2
local armReachZ = -0.5 -- 前後補正

RunService.RenderStepped:Connect(function()
    -- 移動
    if leftInput.Magnitude > 0 then
        local camCFrame = workspace.CurrentCamera.CFrame
        local moveDir = (camCFrame:VectorToWorldSpace(leftInput))
        humanoid:Move(moveDir, true)
    end

    -- 右腕
    if rightShoulder then
        local rot = CFrame.Angles(-rightInput.Y*armSensitivity, rightInput.X*armSensitivity, 0)
        rightShoulder.C0 = CFrame.new(1.5,0,armReachZ) * rot
    end

    -- 左腕
    if leftShoulder then
        local rot = CFrame.Angles(-leftInput.Y*armSensitivity, leftInput.X*armSensitivity, 0)
        leftShoulder.C0 = CFrame.new(-1.5,0,armReachZ) * rot
    end
end)

-- =============================================
-- PermanentDeath Off
-- =============================================
local PermanentDeathEnabled = false
if not PermanentDeathEnabled then
    humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end
