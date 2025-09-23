-- サービス取得
local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- デバイス判定
local isVR = VRService and VRService.VREnabled
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPC = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled

-- 視点角度
local yaw, pitch = 0, 0

-- =====================
-- PC操作: マウスで視点回転
-- =====================
if isPC then
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            yaw = yaw - input.Delta.X * 0.2
            pitch = math.clamp(pitch - input.Delta.Y * 0.2, -80, 80)
        end
    end)
end

-- =====================
-- モバイル操作: スティック & ジャイロ
-- =====================
if isMobile then
    -- 右スティック操作
    ContextActionService:BindAction("LookControl", function(_, state, input)
        if state == Enum.UserInputState.Change and input.Position then
            local delta = input.Position
            yaw = yaw - delta.X * 0.1
            pitch = math.clamp(pitch - delta.Y * 0.1, -80, 80)
        end
    end, true, Enum.KeyCode.Thumbstick2)

    -- ジャイロ対応
    if UserInputService.GyroscopeEnabled then
        RunService.RenderStepped:Connect(function()
            local rot = UserInputService:GetDeviceRotation()
            if rot then
                -- 補正が必要な場合あり
                local _, y, _ = rot:ToEulerAnglesYXZ()
                yaw = math.deg(y)
            end
        end)
    end
end

-- =====================
-- 毎フレームカメラ更新
-- =====================
RunService.RenderStepped:Connect(function()
    if isVR then
        -- VRヘッド追従
        local headCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
        if headCFrame then
            camera.CFrame = camera.CFrame * headCFrame
        end
    else
        -- PC/モバイル: キャラクター位置 + yaw/pitch
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local camRot = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
            camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 5, 0)) * camRot
        end
    end
end)
