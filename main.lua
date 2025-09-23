local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Character がロードされるまで待つ
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- Humanoid がまだロードされてなければ再取得
if not humanoid:IsDescendantOf(game) then
    humanoid = char:WaitForChild("Humanoid")
end

-- BodyScale が無ければ作る
for _, name in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale"}) do
    if not humanoid:FindFirstChild(name) then
        local val = Instance.new("NumberValue")
        val.Name = name
        val.Value = 1
        val.Parent = humanoid
    end
end
local heightScale = humanoid.BodyHeightScale
local widthScale = humanoid.BodyWidthScale
local depthScale = humanoid.BodyDepthScale
