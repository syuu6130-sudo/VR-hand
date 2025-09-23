-- LocalScriptとして配置
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

print("LocalScript is running. Character loaded:", char.Name)

for _, v in pairs(char:GetChildren()) do
    print(v.Name, v.ClassName)
end
