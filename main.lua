-- =============================================
-- Roblox Universal Arm Script (Executer + Mobile/PC)
-- Features:
-- 1. PermanentDeath ON/OFF
-- 2. Automatic Left/Right Arm reattachment
-- 3. Arm movement via Mouse or Touch
-- 4. CoreGui Executer対応
-- =============================================

-- SETTINGS
local PermanentDeathEnabled = false
local control = "mobile" -- "pc" or "mobile"

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- =============================================
-- FUNCTION: Ensure Arms Are Visible
-- =============================================
local function FixArms()
    local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftHand")
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")

    if not leftArm then
        leftArm = Instance.new("Part")
        leftArm.Name = "Left Arm"
        leftArm.Size = Vector3.new(1,2,1)
        leftArm.CanCollide = false
        leftArm.Anchored = false
        leftArm.Parent = character
        local weld = Instance.new("Motor6D")
        weld.Part0 = humanoid.RootPart
        weld.Part1 = leftArm
        weld.C0 = CFrame.new(-2,0,0)
        weld.Parent = leftArm
    end

    if not rightArm then
        rightArm = Instance.new("Part")
        rightArm.Name = "Right Arm"
        rightArm.Size = Vector3.new(1,2,1)
        rightArm.CanCollide = false
        rightArm.Anchored = false
        rightArm.Parent = character
        local weld = Instance.new("Motor6D")
        weld.Part0 = humanoid.RootPart
        weld.Part1 = rightArm
        weld.C0 = CFrame.new(2,0,0)
        weld.Parent = rightArm
    end
end

-- =============================================
-- FUNCTION: Permanent Death Handling
-- =============================================
local function SetupPermanentDeath()
    if PermanentDeathEnabled then
        print("PermanentDeath ENABLED")
    else
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        print("PermanentDeath DISABLED")
    end
end

-- =============================================
-- MAIN
-- =============================================
FixArms()
SetupPermanentDeath()

-- =============================================
-- Arm Movement Handling
-- =============================================
local leftArm = character:FindFirstChild("Left Arm")
local rightArm = character:FindFirstChild("Right Arm")

local function MoveArm(arm, targetPos)
    if arm and targetPos then
        arm.CFrame = CFrame.new(targetPos)
    end
end

-- PC or Touch
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    if control == "pc" then
        local ray = workspace.CurrentCamera:ScreenPointToRay(mousePos.X, mousePos.Y)
        local pos = ray.Origin + ray.Direction * 5
        MoveArm(leftArm, pos)
        MoveArm(rightArm, pos)
    elseif control == "mobile" then
        -- タッチ入力があれば取得
        local touches = UserInputService:GetTouches()
        for _, t in pairs(touches) do
            local ray = workspace.CurrentCamera:ScreenPointToRay(t.Position.X, t.Position.Y)
            local pos = ray.Origin + ray.Direction * 5
            MoveArm(leftArm, pos)
            MoveArm(rightArm, pos)
        end
    end
end)

-- Keep arms fixed every frame
RunService.RenderStepped:Connect(FixArms)

print("Universal Arm Script (Executer) loaded successfully")
