repeat task.wait() until game:IsLoaded() and workspace.CurrentCamera
local Utility = {}
local cloneref = cloneref or function(obj) return obj end

local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude
local Connections = {
	RenderStepped = {},
	Heartbeat = {},
	Stepped = {}
}

Utility.BindAdd = function(types, name, delays, callback)
	if Connections[types][name] then return end
	if (delays == 0 or delays == nil) then
		Connections[types][name] = {
			conn = RunService[types]:Connect(callback),
			delay = 0,
			elapsed = 0,
			callback = callback
		}
		return
	end
	local data = {
		delay = delays,
		elapsed = 0,
		callback = callback
	}
	data.conn = RunService[types]:Connect(function(dt)
		data.elapsed += dt
		if data.elapsed >= data.delay then
			data.elapsed = 0
			data.callback()
		end
	end)
	Connections[types][name] = data
end

Utility.BindUpdate = function(types, name, delays)
	local data = Connections[types][name]
	if not data then return end
	if not data.delay then return end
	if data.delay == delays then return end
	data.delay = delays
	data.elapsed = 0
end

Utility.BindRemove = function(types, name)
	local data = Connections[types][name]
	if data then
		if data.conn then
			data.conn:Disconnect()
		end
		Connections[types][name] = nil
	end
end

Utility.IsAlive = function(obj)
	return obj.Character and obj.Character.PrimaryPart and obj.Character:FindFirstChildOfClass("Humanoid") and obj.Character:FindFirstChildOfClass("Humanoid").Health > 0
end

Utility.IsExposed = function(obj)
	if not Utility.IsAlive(LocalPlayer) or not Utility.IsAlive(obj) then return false end

	RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
	local Result = workspace:Raycast(LocalPlayer.Character.PrimaryPart.Position, obj.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position, RayParams)
	if Result then
		return Result.Instance:IsDescendantOf(obj.Character)
	end
	
	return true
end

Utility.CheckTool = function(toolname)
	for _, v in pairs(LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():match(toolname) then
			return v
		end
	end
end

Utility.GetNearestEntity = function(MaxDist, Mode, TeamCheck, WallCheck, Direction)
	local Entity
	local MinDist = math.huge

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and Utility.IsAlive(plr) then
			if not TeamCheck or plr.Team ~= LocalPlayer.Team then

				if WallCheck and not Utility.IsExposed(plr) then continue end

				local Distances = (plr.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position)
				local Magnitude = Distances.Magnitude

				if Magnitude <= MaxDist then
					local Angle = math.deg(LocalPlayer.Character.PrimaryPart.CFrame.LookVector:Angle(Distances.Unit))

					if Direction and Direction < 360 and Angle > (Direction / 2) then continue end
					local Selected
					if Mode == "Closest" then
						Selected = Magnitude
					elseif Mode == "Lowest" then
						Selected = plr.Character:FindFirstChildOfClass("Humanoid").Health
					elseif Mode == "Angle" then
						Selected = Angle
					end

					if Selected < MinDist then
						MinDist = Selected
						Entity = plr.Character
					end
				end
			end
		end
	end

	return Entity
end

Utility.GetNearestPart = function(obj)
	local Closest
	local MinDist = math.huge
	
	for _, v in pairs(obj:GetChildren()) do
		if v:IsA("BasePart") or v:IsA("MeshPart") then
			local Distance = Utility.GetMagnitude(v.Position - LocalPlayer.Character.PrimaryPart.Position)
			if Distance < MinDist then
				MinDist = Distance
				Closest = v
			end
		end
	end
	
	return Closest
end

Utility.HighlightAdd = function(obj)
	if not obj:FindFirstChildWhichIsA("Highlight") then
		local Highlight = Instance.new("Highlight")
		Highlight.FillTransparency = 1
		Highlight.OutlineColor = Color3.fromRGB(63, 92, 132)
		Highlight.Parent = obj
		Highlight.OutlineTransparency = 0
	end
end

Utility.HighlightRemove = function(obj)
	local Highlight = obj:FindFirstChildWhichIsA("Highlight")
	if Highlight then
		Highlight:Destroy()
	end
end

return Utility
