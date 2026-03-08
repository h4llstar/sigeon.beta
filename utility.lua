local cloneref = cloneref or function(obj) return obj end

local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CurrentCamera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Utility = {}

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude
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

Utility.BindUpdate = function(types, name, delays)
	local Bind = Connections[types][name]
	if not Bind then return end
	if Bind.delay == delays then return end
	Bind.conn:Disconnect()
	Bind.delay = delays or 0
	Bind.elapsed = 0
	local Handler
	if Bind.delay > 0 then
		Handler = function(dt)
			Bind.elapsed += dt
			if Bind.elapsed < Bind.delay then return end
			Bind.elapsed = 0
			Bind.callback()
		end
	else
		Handler = Bind.callback
	end
	Bind.conn = RunService[types]:Connect(Handler)
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

Utility.IsFirstPerson = function()
	if not Utility.IsAlive(LocalPlayer) then return end
	return (LocalPlayer.Character.Head.CFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 1
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
		if v:IsA("Tool") and v.Name:lower():find(toolname:lower(), 1, true) then
			return v
		end
	end
end

Utility.CheckTool = function(toolname)
	for _, v in pairs(LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():find(toolname:lower(), 1, true) then
			return v
		end
	end
end

Utility.GetNearestEntity = {
	Distance = function(MaxDist, Mode, TeamCheck, WallCheck, Direction)
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
						Entity = v
					end
				end
			end
		end
		return Entity
	end,
	Mouse = function(MaxDist, FOV, TeamCheck, WallCheck)
		local MinDist = math.huge
		local Entity
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and Utility.IsAlive(v) then
				if TeamCheck and Utility.GetTeam(v) then continue end
				if WallCheck and not Utility.IsExposed(v) then continue end

				local Distances = (v.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position)
				local Magnitude = Distances.Magnitude
				if Magnitude <= MaxDist then
					local Pos, Visible = CurrentCamera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
					if Visible then
						local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
						if Dist <= FOV and Dist < MinDist then
							MinDist = Dist
							Entity = v
						end
					end
				end
			end
		end

		return Entity
	end,
}

Utility.GetPrediction = function(primarypart, origin, speed)
	local rel = primarypart.Position - origin
	local velo = Vector3.new(primarypart.AssemblyLinearVelocity.X, 0, primarypart.AssemblyLinearVelocity.Z)

	local a = velo:Dot(velo) - speed * speed
	local b = 2 * rel:Dot(velo)
	local c = rel:Dot(rel)

	local disc = b * b - 4 * a * c
	if disc < 0 then return primarypart.Position end

	local t1 = (-b + math.sqrt(disc)) / (2 * a)
	local t2 = (-b - math.sqrt(disc)) / (2 * a)
	local t
	if t1 > 0 and t2 > 0 then
		t = math.min(t1, t2)
	elseif t1 > 0 then
		t = t1
	elseif t2 > 0 then
		t = t2
	else
		return primarypart.Position
	end
	local predicted = primarypart.Position + velo * t
	return Vector3.new(predicted.X, primarypart.Position.Y, predicted.Z)
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

Utility.BillBoard = {
	Create = function(obj)
		if not obj or not obj:IsA("Model") then return end
		if obj:FindFirstChildWhichIsA("BillboardGui") then return end
		
		local BillboardGui = Instance.new("BillboardGui")
		BillboardGui.Parent = obj
		BillboardGui.AlwaysOnTop = true
		BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
		BillboardGui.Size = UDim2.fromOffset(36, 36)
		BillboardGui.ClipsDescendants = false

		local Frame = Instance.new("Frame")
		Frame.Size = UDim2.fromScale(1, 1)
		Frame.BackgroundTransparency = 1
		Frame.Parent = BillboardGui
		
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 4)
		Corner.Parent = Frame

		local Layout = Instance.new("UIListLayout")
		Layout.FillDirection = Enum.FillDirection.Horizontal
		Layout.Padding = UDim.new(0, 4)
		Layout.VerticalAlignment = Enum.VerticalAlignment.Center
		Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Layout.Parent = Frame
		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			BillboardGui.Size = UDim2.fromOffset(math.max(Layout.AbsoluteContentSize.X + 4, 36), 36)
		end)
	end,
	Add = function(obj, image)
		if not obj or not obj:IsA("Model") then return end
		local BillboardGui = obj:FindFirstChildWhichIsA("BillboardGui")
		if not BillboardGui then return end

		local ImageLabel = Instance.new("ImageLabel")
		ImageLabel.Size = UDim2.fromOffset(32, 32)
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.Image = image
		ImageLabel.Parent = BillboardGui:FindFirstChildWhichIsA("Frame")
	end,
	Delete = function(obj, image)
		if not obj or not obj:IsA("Model") then return end
		if not obj:FindFirstChildWhichIsA("BillboardGui") then return end
		for _, v in pairs(obj:FindFirstChildWhichIsA("BillboardGui"):GetChildren()) do
			if v:IsA("ImageLabel") and v.Image == image then
				v:Destroy()
			end
		end
	end,
	Remove = function(obj)
		if not obj or not obj:IsA("Model") then return end
		local BillboardGui = obj:FindFirstChildWhichIsA("BillboardGui")
		if BillboardGui then
			BillboardGui:Destroy()
		end
	end,
}

return Utility
