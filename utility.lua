local cloneref = cloneref or function(obj) return obj end

local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude

local Utility = {}
local Connections = {RenderStepped = {}, Heartbeat = {}, Stepped = {}}

Utility.BindAdd = function(types, name, delays, callback)
	if Connections[types][name] then return end
	local Bind = {delay = delays or 0, elapsed = 0, callback = callback}
	local Handler
	if delays and delays > 0 then
		Handler = function(dt)
			Bind.elapsed += dt
			if Bind.elapsed < Bind.delay then return end
			Bind.elapsed = 0
			callback()
		end
	else
		Handler = callback
	end
	Bind.conn = RunService[types]:Connect(Handler)
	Connections[types][name] = Bind
end

Utility.BindRemove = function(types, name)
	local Bind = Connections[types][name]
	if not Bind then return end
	Bind.conn:Disconnect()
	Connections[types][name] = nil
end

Utility.IsAlive = function(obj)
	return obj.Character and obj.Character.PrimaryPart and obj.Character:FindFirstChildOfClass("Humanoid") and obj.Character:FindFirstChildOfClass("Humanoid").Health > 0
end

Utility.IsExposed = function(obj)
	if not Utility.IsAlive(LocalPlayer) or not Utility.IsAlive(obj) then return false end
	RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
	local Result = workspace:Raycast(LocalPlayer.Character.PrimaryPart.Position, obj.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position, RayParams)
	if Result then
		return Result.Instance:IsDescendantOf(obj.Character)
	end
	return true
end

Utility.GetTeam = function(v)
	if v.Team and LocalPlayer.Team then
		if v.Team == LocalPlayer.Team then
			return LocalPlayer.Team
		end
		if v.Team.Name == LocalPlayer.Team.Name then
			return LocalPlayer.Team
		end
		if v.Team.TeamColor == LocalPlayer.Team.TeamColor then
			return LocalPlayer.Team
		end
	end
	return nil
end

Utility.GetMagnitude = function(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

Utility.GetTool = function(toolname)
	for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():match(toolname) then
			return v
		end
	end
end

Utility.CheckTool = function(toolname)
	for _, v in pairs(LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():match(toolname) then
			return v
		end
	end
end

Utility.GetNearestEntity = function(MaxDist, Mode, TeamCheck, WallCheck, Direction)
	local MinDist = math.huge
	local Entity
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and Utility.IsAlive(v) then
			if TeamCheck and Utility.GetTeam(v) then continue end
			if WallCheck and not Utility.IsExposed(v) then continue end
			
			local Distances = (v.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position)
			local Magnitude = Distances.Magnitude
			if Magnitude <= MaxDist then
				local Angle = math.deg(LocalPlayer.Character.PrimaryPart.CFrame.LookVector:Angle(Distances.Unit))
				if Direction and Direction < 360 then
					if Angle > (Direction / 2) then continue end
				end
				local Selected
				if Mode == "Closest" then
					Selected = Magnitude
				elseif Mode == "Lowest" then
					Selected = v.Character:FindFirstChildOfClass("Humanoid").Health
				elseif Mode == "Angle" then
					Selected = Angle
				end
				if Selected and Selected < MinDist then
					MinDist = Selected
					Entity = v.Character
				end
			end
		end
	end
	return Entity
end

Utility.HighlightAdd = function(obj)
	if not obj or not obj:IsA("Model") then return end
	if obj:FindFirstChildWhichIsA("Highlight") then return end
	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 0
	local NewColor = Color3.fromRGB(63, 92, 132)
	local plr = Players:GetPlayerFromCharacter(obj)
	if plr and plr.Team and plr.Team.TeamColor then
		NewColor = plr.Team.TeamColor.Color
	end
	Highlight.OutlineColor = NewColor
	Highlight.Parent = obj
end

Utility.HighlightRemove = function(obj)
	if not obj or not obj:IsA("Model") then return end
	local Highlight = obj:FindFirstChildWhichIsA("Highlight")
	if Highlight then
		Highlight:Destroy()
	end
end

return Utility
