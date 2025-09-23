local VRService = game:GetService("VRService") 
local UserInputService = game:GetService("UserInputService") 
local ContextActionService = game:GetService("ContextActionService") 
local RunService = game:GetService("RunService") 
local player = game.Players.LocalPlayer 
local camera = workspace.CurrentCamera 
local isVR = VRService and VRService.VREnabled 
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled 
local isPC = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled 
-- 視点の角度保持 
local yaw, pitch = 0, 0 
-- PC用: マウスでカメラ回転 
if isPC then UserInputService.InputChanged:Connect(function(input, gpe) if gpe then return end if input.UserInputType == Enum.UserInputType.MouseMovement then yaw = yaw - input.Delta.X * 0.2 pitch = math.clamp(pitch - input.Delta.Y * 0.2, -80, 80) end end) end 
-- モバイル用: 
Thumbstickで視点回転 if isMobile then ContextActionService:BindAction("LookControl", function(_, state, input) if state == Enum.UserInputState.Change and input.Position then 
local delta = input.Position yaw = yaw - delta.X * 0.1 pitch = math.clamp(pitch - delta.Y * 0.1, -80, 80) end end, true, Enum.KeyCode.Thumbstick2) 
-- ジャイロ対応ならジャイロも反映 
if UserInputService.GyroscopeEnabled then RunService.RenderStepped:Connect(function() 
local rot = UserInputService:GetDeviceRotation() if rot then local cf = rot 
-- Yaw/Pitchをジャイロから直接取る例（補正が必要） 
yaw = math.deg(cf:ToEulerAnglesYXZ()) end end) end end 
-- 毎フレーム更新 
RunService.RenderStepped:Connect(function() if isVR then 
-- VRヘッド追従 
local headCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head) if headCFrame then camera.CFrame = camera.CFrame * headCFrame end else 
-- PC/モバイル: yaw/pitchからカメラCFrameを作る 
local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") if root then 
local rootPos = root.Position 
local camRot = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0) camera.CFrame = CFrame.new(rootPos + Vector3.new(0, 5, 0)) * camRot end end end)
