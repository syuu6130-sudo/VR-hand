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
-- INITIALIZE ARMS
-- =============================================
local rightShoulder = character:WaitForChild("RightUpperArm"):WaitForChild("RightShoulder")
local leftShoulder = character:WaitForChild("LeftUpperArm"):WaitForChild("LeftShoulder")
local initRightC0 = rightShoulder.C0
local initLeftC0 = leftShoulder.C0

local rightInput = Vector2.zero
local leftInput = Vector2.zero

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

-- =============================================
-- STICK INPUT HANDLER
-- =============================================
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
            stick.Position = UDim2.new(0.5,offset.X,0.5,offset.Y)
            updateFunc(offset/maxDist)
        end
    end)
end

stickHandler(leftStick,leftFrame,function(vec) leftInput = vec end)
stickHandler(rightStick,rightFrame,function(vec) rightInput = vec end)

-- =============================================
-- UPDATE LOOP
-- =============================================
RunService.RenderStepped:Connect(function()
    -- 左手回転
    leftShoulder.C0 = initLeftC0 * CFrame.Angles(-leftInput.Y*1.5, leftInput.X*1.5, 0) * CFrame.new(0,0,-0.5)
    -- 右手回転
    rightShoulder.C0 = initRightC0 * CFrame.Angles(-rightInput.Y*1.5, rightInput.X*1.5, 0) * CFrame.new(0,0,-0.5)
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
