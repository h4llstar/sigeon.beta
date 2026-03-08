repeat task.wait() until game:IsLoaded()
if game.PlaceId == 11630038968 or game.PlaceId == 10810646982 or game.PlaceId == 139566161526375 then
	--loadstring(game:HttpGet("https://raw.githubusercontent.com/h4llstar/LimeForRoblox/refs/heads/main/bridge_duel.lua"))()
elseif game.PlaceId == 71480482338212 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/h4llstar/sigeon.beta/refs/heads/main/bed_fight.lua"))()
else
	game:GetService("Chat"):Chat(game.Players.LocalPlayer.Character:WaitForChild("Head"), "I love eating AquaVClip feces")
end
