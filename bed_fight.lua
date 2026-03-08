--Welcome skids! please do not skid my beautiful code! okay?!
repeat task.wait() until game:IsLoaded() and workspace.CurrentCamera
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/not-hm/sigeon.beta/refs/heads/main/library.lua"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/not-hm/sigeon.beta/refs/heads/main/utility.lua"))()
local cloneref = cloneref or function(obj) return obj end
local hookfunction = hookfunction or function(func, callback) end
local newcclosure = newcclosure or function(func) return func end
local Drawing = Drawing or {new = function() return {} end}

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Players = cloneref(game:GetService("Players"))
local Teams = cloneref(game:GetService("Teams"))
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local BedFight = {}

local SwordHandler, BlockHandler
local LastSword, LastBlock
task.defer(function()
	BedFight = {
		ToolHandlers = {
			Ranged = require(ReplicatedStorage.ToolHandlers.Ranged),
			Sword = require(ReplicatedStorage.ToolHandlers.Sword),
			Block = require(ReplicatedStorage.ToolHandlers.Block),
		},
		Modules = {
			SwordsData = require(ReplicatedStorage.Modules.DataModules.SwordsData),
			ItemsData = require(ReplicatedStorage.Modules.DataModules.ItemsData),
			VelocityUtils = require(ReplicatedStorage.Modules.VelocityUtils),
		},
		Remotes = {
			PlaceBlock = ReplicatedStorage.Remotes.ItemsRemotes.PlaceBlock,
			MineBlock = ReplicatedStorage.Remotes.ItemsRemotes.MineBlock,
			SwordHit = ReplicatedStorage.Remotes.ItemsRemotes.SwordHit,
		},
		Functions = {
			Inventory = {
				Backpack = {
					Find = function(toolname)
						for _, v in LocalPlayer.Backpack:GetChildren() do
							if v:IsA("Model") and v.Name:lower():find(toolname:lower(), 1, true) then
								return v
							end
						end
					end,
					Get = function()
						for _, v in LocalPlayer.Backpack:GetChildren() do
							if v:IsA("Model") and v:GetAttribute("Class") then
								return v
							end
						end
					end,
				},
				Character = {
					Find = function(toolname)
						for _, v in LocalPlayer.Character:GetChildren() do
							if v:IsA("Model") and v.Name:lower():find(toolname:lower(), 1, true) then
								return v
							end
						end
					end,
					Get = function()
						for _, v in LocalPlayer.Character:GetChildren() do
							if v:IsA("Model") and v:GetAttribute("Class") then
								return v
							end
						end
					end,
				}
			},
			Tool = {
				Swing = function(tool)
					if tool ~= LastSword then
						SwordHandler = BedFight.ToolHandlers.Sword.new(tool, LocalPlayer.Character)
						LastSword = tool
					end
					if SwordHandler then
						SwordHandler:Activate(false)
					end
				end,
				Place = function(tool)
					if tool ~= LastBlock then
						if BlockHandler then
							BlockHandler:Stop()
						end
						BlockHandler = BedFight.ToolHandlers.Block.new(tool, LocalPlayer.Character)
						BlockHandler:Run()
						LastBlock = tool
					end
					if BlockHandler then
						BlockHandler:Activate()
					end
				end,
				Reset = function()
					if BlockHandler then
						BlockHandler:Stop()
						BlockHandler = nil
					end
					LastBlock = nil
					SwordHandler = nil
					LastSword = nil
				end,
				GetClass = function(tool)
					if tool:GetAttribute("Class") then
						return tool:GetAttribute("Class")
					end
					return nil
				end,
			},
			Utility = {
				GetBed = function()
					if not Utility.IsAlive(LocalPlayer) then return end
					local Bed, MinDist = nil, math.huge
					for _, v in workspace.BedsContainer:GetChildren() do
						if v:GetAttribute("Team") == LocalPlayer.Team then continue end
						local Hitbox = v:FindFirstChild("BedHitbox")
						if not Hitbox then continue end
						local Distance = (Hitbox.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
						if Distance < MinDist then
							MinDist = Distance
							Bed = v
						end
					end
					return Bed
				end,
				GetUI = function()
					if LocalPlayer.PlayerGui:FindFirstChild("BackpackGui") and LocalPlayer.PlayerGui.BackpackGui:FindFirstChild("BackpackList") and LocalPlayer.PlayerGui.BackpackGui.BackpackList.Visible then return true end
					if LocalPlayer.PlayerGui:FindFirstChild("TeamChestGui") and LocalPlayer.PlayerGui.TeamChestGui.Enabled then return true end
					if LocalPlayer.PlayerGui:FindFirstChild("ItemShopGui") and LocalPlayer.PlayerGui.ItemShopGui.Enabled then return true end
					return false
				end,
			}
		}
	}
end)

task.spawn(function()
	LocalPlayer.Character.ChildAdded:Connect(function()
		BedFight.Functions.Tool.Reset()
	end)
	LocalPlayer.Character.ChildRemoved:Connect(function()
		BedFight.Functions.Tool.Reset()
	end)
	LocalPlayer.CharacterAdded:Connect(function(char)
		BedFight.Functions.Tool.Reset()
		local Humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
		Humanoid.Died:Connect(BedFight.Functions.Tool.Reset)
	end)
end)

local Core = Library:Initialize()
local Sections = {
	Combat = Core:CreateSection(1, UDim2.new(0, 0, 2, -250)),
	--Movement = Core:CreateSection(2, UDim2.new(0, 0, 0, 0)),
	Visual = Core:CreateSection(3, UDim2.new(0, 0, 0, 0)),
	World = Core:CreateSection(4, UDim2.new(0, 0, 0, 0)),
	--Misc = Core:CreateSection(5, UDim2.new(0, 0, 0, 0)),
}

local AimAssist
task.defer(function()
	local Strength, Prediction, Distances
	local ToolCheck = false

	AimAssist = Sections.Combat:CreateToggle({
		Name = "Aim Assist",
		Callback = function(callback)
			if callback then
				Utility.BindAdd("Heartbeat", "AimAssist", nil, function()
					if not Utility.IsAlive(LocalPlayer) then return end
					if not Utility.IsFirstPerson() then return end
					if BedFight.Functions.Utility.GetUI() then return end
					if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
						local Entity = Utility.GetNearestEntity.Distance(Distances, "Angle", (LocalPlayer.Team ~= Teams.Spectators), true, 120)
						if Entity then
							if ToolCheck and not BedFight.Functions.Inventory.Character.Find("sword") then return end
							local FinalPos = Entity.Character.PrimaryPart.Position + (Entity.Character.PrimaryPart.Velocity * Prediction)
							workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, FinalPos), Strength)
						end
					end
				end)
			else
				Utility.BindRemove("Heartbeat", "AimAssist")
			end
		end
	})
	AimAssist:CreateMiniToggle({
		Name = "Tool Check",
		Enabled = true,
		Callback = function(callback)
			ToolCheck = callback
		end,
	})
	AimAssist:CreateSlider({
		Name = "Distances",
		Min = 0,
		Max = 30,
		Default = 22,
		Callback = function(callback)
			Distances = callback
		end
	})
	AimAssist:CreateSlider({
		Name = "Strength",
		Min = 1,
		Max = 15,
		Default = 12,
		Callback = function(callback)
			Strength = callback / 100
		end
	})
	AimAssist:CreateSlider({
		Name = "Prediction",
		Min = 0,
		Max = 10,
		Default = 3,
		Callback = function(callback)
			Prediction = callback / 100
		end
	})
end)

local AutoClicker
task.defer(function()
	local MaxCPS, MinCPS, CCPS = nil, nil, nil
	local Randomize, CDelay = false, nil

	AutoClicker = Sections.Combat:CreateToggle({
		Name = "Auto Clicker",
		Callback = function(callback)
			if callback then
				Utility.BindAdd("Heartbeat", "AutoClicker", 0, function()
					if not Utility.IsAlive(LocalPlayer) then BedFight.Functions.Tool.Reset() return end
					if BedFight.Functions.Utility.GetUI() then BedFight.Functions.Tool.Reset() return end
					local Tool = BedFight.Functions.Inventory.Character.Get()
					if not Tool then BedFight.Functions.Tool.Reset() return end
					if Randomize then
						CCPS = math.random(MinCPS, MaxCPS)
					else
						CCPS = MaxCPS
					end
					if CCPS then
						CDelay = 1 / CCPS
						Utility.BindUpdate("Heartbeat", "AutoClicker", CDelay)
					end
					if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
						local Class = BedFight.Functions.Tool.GetClass(Tool)
						if Class == "Sword" then
							BedFight.Functions.Tool.Swing(Tool)
						elseif Class == "Block" then
							BedFight.Functions.Tool.Place(Tool)
						else
							BedFight.Functions.Tool.Reset()
						end
					else
						BedFight.Functions.Tool.Reset()
					end
				end)
			else
				Utility.BindRemove("Heartbeat", "AutoClicker")
				BedFight.Functions.Tool.Reset()
			end
		end
	})
	AutoClicker:CreateMiniToggle({
		Name = "Randomize",
		Enabled = true,
		Callback = function(callback)
			Randomize = callback
		end
	})
	AutoClicker:CreateSlider({
		Name = "Max",
		Min = 1,
		Max = 12,
		Default = 12,
		Callback = function(callback)
			MaxCPS = callback
		end
	})
	AutoClicker:CreateSlider({
		Name = "Min",
		Min = 1,
		Max = 12,
		Default = 8,
		Callback = function(callback)
			MinCPS = callback
		end
	})
end)

local SilentAura
task.defer(function()
	local StartRotate, StartSwing
	local Direction
	
	SilentAura = Sections.Combat:CreateToggle({
		Name = "Silent Aura",
		Callback = function(callback)
			if callback then
				Utility.BindAdd("Heartbeat", "KillAura", nil, function()
					if not Utility.IsAlive(LocalPlayer) then return end
					if BedFight.Functions.Utility.GetUI() then return end
					local Tool = BedFight.Functions.Inventory.Character.Get()
					if not Tool then BedFight.Functions.Tool.Reset() return end
					local Entity = 	Utility.GetNearestEntity.Distance(18, "Angle", (LocalPlayer.Team ~= Teams.Spectators), true, Direction)
					if not Entity then return end
					local Distance = Utility.GetMagnitude(Entity.Character.PrimaryPart.Position, LocalPlayer.Character.PrimaryPart.Position)
					local Class = BedFight.Functions.Tool.GetClass(Tool)
					if Class ~= "Sword" then BedFight.Functions.Tool.Reset() return end
					if Distance <= StartRotate then
						local EntityPosition = Vector3.new(Entity.Character.PrimaryPart.Position.X, LocalPlayer.Character.PrimaryPart.Position.Y, Entity.Character.PrimaryPart.Position.Z)
						local LookCFrame = CFrame.lookAt(LocalPlayer.Character.PrimaryPart.Position, EntityPosition)
						if Utility.IsFirstPerson() then
							workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, Entity.Character.PrimaryPart.Position)
							LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(LocalPlayer.Character.PrimaryPart.Position) * LookCFrame.Rotation
						else
							LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(LocalPlayer.Character.PrimaryPart.Position) * LookCFrame.Rotation
						end
					end
					if Distance <= StartSwing then
						BedFight.Functions.Tool.Swing(Tool)
					end
				end)
			else
				Utility.BindRemove("Heartbeat", "KillAura")
				BedFight.Functions.Tool.Reset()
			end
		end,
	})
	SilentAura:CreateSlider({
		Name = "Direction",
		Min = 0,
		Max = 360,
		Default = 120,
		Callback = function(callback)
			Direction = callback
		end,
	})
	SilentAura:CreateSlider({
		Name = "Start Rotate",
		Min = 0,
		Max = 18,
		Default = 18,
		Callback = function(callback)
			StartRotate = callback
		end,
	})
	SilentAura:CreateSlider({
		Name = "Start Swing",
		Min = 0,
		Max = 18,
		Default = 18,
		Callback = function(callback)
			StartSwing = callback
		end,
	})
end)

local Reach
task.defer(function()
	local Distance

	Reach = Sections.Combat:CreateToggle({
		Name = "Reach",
		Callback = function(callback)
			if callback then
				Utility.BindAdd("Stepped", "Reach", nil, function()
					for i, v in BedFight.Modules.SwordsData do
						if type(v) == "table" and v.Range then
							v.Range = Distance
						end
					end
				end)
			else
				Utility.BindRemove("Stepped", "Reach")
				for i, v in BedFight.Modules.SwordsData do
					if type(v) == "table" and v.Range then
						v.Range = 5
					end
				end
			end
		end
	})
	Reach:CreateSlider({
		Name = "Distance",
		Min = 0,
		Max = 12,
		Default = 5,
		Callback = function(callback)
			Distance = callback
		end
	})
end)

local TriggerBot
task.defer(function()
	local Distance

	TriggerBot = Sections.Combat:CreateToggle({
		Name = "Trigger Bot",
		Callback = function(callback)
			if callback then
				Utility.BindAdd("Stepped", "TriggerBot", nil, function()
					if not Utility.IsAlive(LocalPlayer) then return end
					if BedFight.Functions.Utility.GetUI() then return end
					local Entity = Utility.GetNearestEntity.Distance(Distance, "Angle", (LocalPlayer.Team ~= Teams.Spectators), true, 120)
					if Entity and Mouse.Target and Mouse.Target:IsDescendantOf(Entity) then
						local Tool = BedFight.Functions.Inventory.Character.Get()
						if not Tool then BedFight.Functions.Tool.Reset() return end
						local Class = BedFight.Functions.Tool.GetClass(Tool)
						if Class ~= "Sword" then BedFight.Functions.Tool.Reset() return end
						BedFight.Functions.Tool.Swing(Tool)
					else
						BedFight.Functions.Tool.Reset()
					end
				end)
			else
				Utility.BindRemove("Stepped", "TriggerBot")
				BedFight.Functions.Tool.Reset()
			end
		end
	})
	TriggerBot:CreateSlider({
		Name = "Distance",
		Min = 0,
		Max = 16,
		Default = 14,
		Callback = function(callback)
			if callback then
				Distance = callback
			end
		end
	})
end)

local Velocity
task.defer(function()
	local Knockback = {X = 100, Y = 100}
	local Original

	Velocity = Sections.Combat:CreateToggle({
		Name = "Velocity",
		Callback = function(callback)
			repeat task.wait() until BedFight.Modules.VelocityUtils.Create
			if callback then
				Original = hookfunction(BedFight.Modules.VelocityUtils.Create, function(part, velo, ...)
					return Original(part, Vector3.new(velo.X * (Knockback.X / 100), velo.Y * (Knockback.Y / 100), velo.Z * (Knockback.X / 100)), ...)
				end)
			else
				if Original then
					hookfunction(BedFight.Modules.VelocityUtils.Create, Original)
					Original = nil
				end
			end
		end
	})
	Velocity:CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 100,
		Default = 100,
		Callback = function(callback)
			Knockback.X = callback
		end
	})
	Velocity:CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 100,
		Default = 100,
		Callback = function(callback)
			Knockback.Y = callback
		end
	})	
end)

local BedDisplay
task.defer(function()
	local OverParams = OverlapParams.new()
	OverParams.FilterType = Enum.RaycastFilterType.Include
	OverParams.FilterDescendantsInstances = {workspace.PlayersBlocksContainer}

	BedDisplay = Sections.Visual:CreateToggle({
		Name = "Bed Display",
		Callback = function(callback)
			if callback then
				Utility.BindAdd("Heartbeat", "BedDisplay", 0.5, function()
					for _, bed in workspace.BedsContainer:GetChildren() do
						local Team = bed:GetAttribute("Team")
						if Team and LocalPlayer.Team and Team == LocalPlayer.Team.Name then
							Utility.BillBoard.Remove(bed)
							continue
						end
						local Hitbox = bed:FindFirstChild("BedHitbox")
						if not Hitbox then Utility.BillBoard.Remove(bed) continue end
						local Counts = {}
						for _, part in workspace:GetPartBoundsInBox(CFrame.new(Hitbox.Position), Vector3.new(20, 20, 20), OverParams) do
							local data = BedFight.Modules.ItemsData[part.Name]
							if data and data.Class == "Blocks" then
								Counts[part.Name] = (Counts[part.Name] or 0) + 1
							end
						end
						Utility.BillBoard.Remove(bed)
						Utility.BillBoard.Create(bed)
						for bname, count in Counts do
							local data = BedFight.Modules.ItemsData[bname]
							if not data or not data.Image then continue end
							Utility.BillBoard.Add(bed, data.Image)
						end
					end
				end)
			else
				Utility.BindRemove("Heartbeat", "BedDisplay")
				for _, bed in workspace.BedsContainer:GetChildren() do
					Utility.BillBoard.Remove(bed)
				end
			end
		end
	})
end)

local ESP
task.defer(function()
	local IncludeBed = false

	ESP = Sections.Visual:CreateToggle({
		Name = "ESP",
		Callback = function(callback)
			if callback then
				Utility.BindAdd("Stepped", "ESP", nil, function()
					for _, v in Players:GetPlayers() do
						if v ~= LocalPlayer and Utility.IsAlive(v) then
							Utility.HighlightAdd(v.Character)
						end
					end
					if IncludeBed then
						for _, v in workspace.BedsContainer:GetChildren() do
							if v:GetAttribute("Team") ~= LocalPlayer.Team then
								Utility.HighlightAdd(v)
							end
						end
					end
				end)
			else
				Utility.BindRemove("Stepped", "ESP")
				for _, v in Players:GetPlayers() do
					if v ~= LocalPlayer and Utility.IsAlive(v) then
						Utility.HighlightRemove(v.Character)
					end
				end
				if IncludeBed then
					for _, v in workspace.BedsContainer:GetChildren() do
						Utility.HighlightRemove(v)
					end
				end
			end
		end
	})
	ESP:CreateMiniToggle({
		Name = "Include Bed",
		Callback = function(callback)
			IncludeBed = callback
			if ESP.Enabled then
				for _, v in workspace.BedsContainer:GetChildren() do
					if callback then
						Utility.HighlightAdd(v)
					else
						Utility.HighlightRemove(v)
					end
				end
			end
		end,
	})
end)

local TimeChanger
task.defer(function()
	local ClockTime = Lighting.ClockTime
	local Signal, New = nil, 12
	TimeChanger = Sections.Visual:CreateToggle({
		Name = "Time Changer",
		Callback = function(callback)
			if callback then
				Lighting.ClockTime = New
				Signal = Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
					Lighting.ClockTime = New
				end)
			else
				if Signal then
					Signal:Disconnect()
					Signal = nil
				end
				Lighting.ClockTime = ClockTime
			end
		end
	})
	TimeChanger:CreateSlider({
		Name = "Clock Time",
		Min = 0,
		Max = 24,
		Default = 12,
		Callback = function(callback)
			New = callback
			if Signal then
				Lighting.ClockTime = New
			end
		end
	})
end)

local ProjectileAssist
task.defer(function()
	local Original

	ProjectileAssist = Sections.World:CreateToggle({
		Name = "Projectile Assist",
		Callback = function(callback)
			repeat task.wait() until BedFight.ToolHandlers.Ranged.UpdateBeam
			if callback then
				Original = hookfunction(BedFight.ToolHandlers.Ranged.UpdateBeam, newcclosure(function(self, origin, data)
					Original(self, origin, data)
					local Entity = Utility.GetNearestEntity.Mouse(1000, 180, (LocalPlayer.Team ~= Teams.Spectators), true)
					if Entity and self.TrajectoryData then
						local MaxSpeed = data.Speed.Max
						local Predicted = Utility.GetPrediction(Entity.Character.PrimaryPart, origin.Position, MaxSpeed)
						local Direction = (Predicted - origin.Position).Unit
						self.TrajectoryData.Velocity = Direction * MaxSpeed
					end
				end))
			else
				if Original then
					hookfunction(BedFight.ToolHandlers.Ranged.UpdateBeam, Original)
					Original = nil
				end
			end
		end
	})
end)

--99440694775362
local Breaker
task.defer(function()
	local Distance, Current = nil, nil
	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Include
	RayParams.FilterDescendantsInstances = {workspace.PlayersBlocksContainer, workspace.BedsContainer}

	Breaker = Sections.World:CreateToggle({
		Name = "Breaker",
		Callback = function(callback)
			if callback then
				Utility.BindAdd("Heartbeat", "Breaker", 0.3, function()
					if not Utility.IsAlive(LocalPlayer) then return end
					if BedFight.Functions.Utility.GetUI() then return end
					if Current and not Current.Parent then Current = nil end
					if not Current then
						local Bed = BedFight.Functions.Utility.GetBed()
						if not Bed then return end
						local BedHitbox = Bed:FindFirstChild("BedHitbox")
						local Direction = BedHitbox.Position - LocalPlayer.Character.PrimaryPart.Position
						local Distances = Direction.Magnitude
						if Distances <= Distance then
							local Result = workspace:Raycast(LocalPlayer.Character.PrimaryPart.Position, Direction.Unit * Distances, RayParams)
							if not Result then
								Current = Bed
							else
								local Hit = Result.Instance
								if Hit:IsDescendantOf(workspace.PlayersBlocksContainer) then
									Current = Hit
								elseif Hit:IsDescendantOf(workspace.BedsContainer) then
									Current = Bed
								end
							end
						end
					end
					if Current then
						local Part = Current:IsA("Model") and (Current.PrimaryPart or Current:FindFirstChildWhichIsA("BasePart")) or Current
						if Part then
							local Tool = BedFight.Functions.Inventory.Character.Find("pickaxe")
							if not Tool then return end
							BedFight.Remotes.MineBlock:FireServer(
								Tool.Name,
								Current,
								Part.Position,
								LocalPlayer.Character.PrimaryPart.Position,
								(Part.Position - LocalPlayer.Character.PrimaryPart.Position).Unit
							)
						end
					end
				end)
			else
				Utility.BindRemove("Heartbeat", "Breaker")
				Current = nil
			end
		end
	})
	Breaker:CreateSlider({
		Name = "Distance",
		Min = 0,
		Max = 18,
		Default = 18,
		Callback = function(callback)
			Distance = callback
		end
	})
end)

Core:CreateNotification("sigeon.pex", "loaded!", 3)
