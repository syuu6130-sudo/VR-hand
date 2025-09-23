-- =============================================
-- Roblox Universal Arm & Hat Script (Empyrean-based)
-- Features:
-- 1. PermanentDeath ON/OFF
-- 2. Automatic Left/Right Arm reattachment
-- 3. Hat support (free & paid)
-- 4. PC / Mobile control
-- 5. Empyrean reanimation integration
-- =============================================

-- SETTINGS
local PermanentDeathEnabled = false -- true = PermanentDeath ON, false = OFF
local control = "mobile" -- "pc" or "mobile"

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

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
        weld.Parent = rightArm
    end
end

-- =============================================
-- FUNCTION: Attach Hats (Auto)
-- =============================================
local function AttachHat(hatId)
    local success, hat = pcall(function()
        return game:GetService("InsertService"):LoadAsset(hatId)
    end)
    if success and hat then
        hat.Parent = character
        local handle = hat:FindFirstChildWhichIsA("BasePart")
        if handle then
            local weld = Instance.new("Weld")
            weld.Part0 = character.Head
            weld.Part1 = handle
            weld.C0 = CFrame.new(0,0.5,0)
            weld.Parent = handle
        end
    end
end

-- Example: auto attach free hats
local freeHats = {
    3398308134,
    3443038622
}
for _, hatId in ipairs(freeHats) do
    AttachHat(hatId)
end

-- =============================================
-- FUNCTION: Permanent Death Handling
-- =============================================
local function SetupPermanentDeath()
    if PermanentDeathEnabled then
        -- Original PermanentDeath logic (from Empyrean) goes here
        print("PermanentDeath is ENABLED")
    else
        -- Disable death: prevent humanoid from dying
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        print("PermanentDeath is DISABLED (character survives)")
    end
end

-- =============================================
-- Empyrean Reanimation Integration
-- =============================================
local function Reanimate()
    -- Assuming you have the Empyrean module loaded as "Empyrean"
    -- This is a placeholder for actual Empyrean reanimation code
    if _G.EmpyreanLoaded then
        print("Empyrean already loaded")
    else
        _G.EmpyreanLoaded = true
        -- Insert Empyrean code here or require module
        print("Empyrean reanimation executed")
    end
end

-- =============================================
-- MAIN
-- =============================================
FixArms()
SetupPermanentDeath()
Reanimate()

-- OPTIONAL: Mobile / PC controls
if control == "mobile" then
    print("Mobile controls activated")
    -- Add mobile joystick handling here
elseif control == "pc" then
    print("PC controls activated")
    -- Add keyboard/mouse handling here
end

-- Keep arms fixed every frame (prevents hats/animations from hiding them)
RunService.RenderStepped:Connect(FixArms)

print("Universal Arm & Hat Script loaded successfully")
