local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

local isVR = VRService.VREnabled
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPC = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled

-- 視点角度
local yaw, pitch = 0, 0  

-- PC: マウスで回転
if isPC then
    UserInputService.InputChanged:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            yaw -= input.Delta.X * 0.2
            pitch = math.clamp(pitch - input.Delta.Y * 0.2, -80, 80)
        end
    end)
end

-- モバイル: スティックで回転
if isMobile then
    ContextActionService:BindAction("LookControl", function(_, state, input)
        if state == Enum.UserInputState.Change and input.Position then
            yaw -= input.Position.X * 0.1
            pitch = math.clamp(pitch - input.Position.Y * 0.1, -80, 80)
        end
    end, true, Enum.KeyCode.Thumbstick2)
end

-- 毎フレーム更新
RunService.RenderStepped:Connect(function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    if isVR then
        local headCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
        camera.CFrame = root.CFrame * headCFrame
    else
        local rootPos = root.Position
        local camRot = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
        camera.CFrame = CFrame.new(rootPos + Vector3.new(0, 5, 0)) * camRot
    end
end)
