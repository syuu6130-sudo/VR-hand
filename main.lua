-- プレイヤーの見た目サイズを周期的に変化させるスクリプト
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- キャラクターのロードを待つ
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- サイズ変化の設定
local minScale = 0.5   -- 最小サイズ
local maxScale = 2.0   -- 最大サイズ
local speed = 2        -- 変化速度

local t = 0

RunService.RenderStepped:Connect(function(delta)
    if not humanoid then return end
    t = t + delta * speed
    local scale = (math.sin(t) + 1) / 2 * (maxScale - minScale) + minScale
    -- HumanoidのBodyScaleを変更
    humanoid.BodyHeightScale.Value = scale
    humanoid.BodyWidthScale.Value = scale
    humanoid.BodyDepthScale.Value = scale
end)
