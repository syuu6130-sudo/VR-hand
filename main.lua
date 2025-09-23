-- サービス取得
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- 手のパーツを用意
local leftHand = character:FindFirstChild("LeftHandPart")
local rightHand = character:FindFirstChild("RightHandPart")

if not leftHand or not rightHand then
    warn("LeftHandPart / RightHandPart がキャラクターに存在しません")
    return
end

-- 手の位置を保持
local leftTargetPos = leftHand.Position
local rightTargetPos = rightHand.Position

-- 操作設定
local isDraggingLeft, isDraggingRight = false, false

-- =====================
-- PC用マウス操作
-- =====================
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local leftDist = (leftHand.Position - workspace.CurrentCamera:ScreenPointToRay(mousePos.X, mousePos.Y).Origin).Magnitude
        local rightDist = (rightHand.Position - workspace.CurrentCamera:ScreenPointToRay(mousePos.X, mousePos.Y).Origin).Magnitude
        -- 近い方を選択してドラッグ
        if leftDist < rightDist then
            isDraggingLeft = true
        else
            isDraggingRight = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingLeft = false
        isDraggingRight = false
    end
end)

-- =====================
-- 毎フレーム更新
-- =====================
RunService.RenderStepped:Connect(function()
    if isDraggingLeft or isDraggingRight then
        local mouse = UserInputService:GetMouseLocation()
        local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
        local targetPos = ray.Origin + ray.Direction * 5 -- 距離調整
        if isDraggingLeft then
            leftHand.Position = targetPos
        elseif isDraggingRight then
            rightHand.Position = targetPos
        end
    end
end)

-- =====================
-- モバイル用（タッチで操作）
-- =====================
if UserInputService.TouchEnabled then
    local activeTouchId
    UserInputService.TouchMoved:Connect(function(touch)
        if activeTouchId ~= touch.UserInputType then return end
        local ray = workspace.CurrentCamera:ScreenPointToRay(touch.Position.X, touch.Position.Y)
        local targetPos = ray.Origin + ray.Direction * 5
        if isDraggingLeft then
            leftHand.Position = targetPos
        elseif isDraggingRight then
            rightHand.Position = targetPos
        end
    end)
    
    UserInputService.TouchStarted:Connect(function(touch)
        activeTouchId = touch.UserInputType
        local ray = workspace.CurrentCamera:ScreenPointToRay(touch.Position.X, touch.Position.Y)
        local targetPos = ray.Origin + ray.Direction * 5
        local leftDist = (leftHand.Position - targetPos).Magnitude
        local rightDist = (rightHand.Position - targetPos).Magnitude
        if leftDist < rightDist then
            isDraggingLeft = true
        else
            isDraggingRight = true
        end
    end)
    
    UserInputService.TouchEnded:Connect(function(touch)
        isDraggingLeft = false
        isDraggingRight = false
    end)
end
