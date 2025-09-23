-- デバッグ用: キャラのパーツ名を全部表示
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

print("=== Character Parts ===")
for _, v in pairs(char:GetChildren()) do
    print(v.Name, v.ClassName)
end
