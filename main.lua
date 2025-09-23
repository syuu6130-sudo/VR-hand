-- サービス取得
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- 手のパーツ作成 or 取得
local function getOrCreateHand(name, offset)
    local part = char:FindFirstChild(name)
    if not part then
        part = Instance.new("Part")
        part.Name = name
        part.Size = Vector3.new(1,1,1)
        part.Anchored = true
        part.CanCollide = false
        part.Position = root.Position + offset
        part.Parent = char
    end
    return part
end

local leftHand = getOrCreateHand("LeftHandPart", Vector3.new(-1,0,0))
local rightHand = getOrCreateHand("RightHandPart", Vector3.new(1,0,0))

-- ドラッグ管理
local draggingLeft, draggingRight = false, false

-- =====================
-- PC操作
-- =====================
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = workspace.CurrentCamera:ScreenPointToRay(mousePos.X, mousePos.Y)
        local targetPos = ray.Origin + ray.Direction * 5
        if (leftHand.Position - targetPos).Magnitude < (rightHand.Position - targetPos).Magnitude then
            draggingLeft = true
        else
            draggingRight = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingLeft = false
        draggingRight = false
    end
end)

-- =====================
-- モバイル操作
-- =====================
if UserInputService.TouchEnabled then
    UserInputService.TouchStarted:Connect(function(touch)
        local ray = workspace.CurrentCamera:ScreenPointToRay(touch.Position.X, touch.Position.Y)
        local targetPos = ray.Origin + ray.Direction * 5
        if (leftHand.Position - targetPos).Magnitude < (rightHand.Position - targetPos).Magnitude then
            draggingLeft = true
        else
            draggingRight = true
        end
    end)

    UserInputService.TouchEnded:Connect(function(touch)
        draggingLeft = false
        draggingRight = false
    end)
end

-- =====================
-- 毎フレーム反映
-- =====================
RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
    local targetPos = ray.Origin + ray.Direction * 5
    if draggingLeft then
        leftHand.Position = targetPos
    elseif draggingRight then
        rightHand.Position = targetPos
    end
end)
