repeat task.wait() until game:IsLoaded() and workspace.CurrentCamera
local Library = {}
local makefolder = makefolder or function(folder) end
local isfolder = isfolder or function(folder) end
local writefile = writefile or function(file, data) end
local isfile = isfile or function(file) end
local readfile = readfile or function(file) end
local cloneref = cloneref or function(obj)
	return obj
end

local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local ConfigTable = {Modules = {}}
local Configuration = {}
Configuration.SetupModule = function(tname, ena, keyb)
	if not ConfigTable.Modules[tname] then
		ConfigTable.Modules[tname] = {
			Enabled = ena,
			Keybind = keyb,

			Sliders = {},
			Dropdowns = {},
			MiniToggles = {}
		}
	else
		ena = ConfigTable.Modules[tname].Enabled
		keyb = ConfigTable.Modules[tname].Keybind
	end
	
	return ena, keyb
end
Configuration.Register = {
	ToggleButton = function(tname, ena, keyb)
		return Configuration.SetupModule(tname, ena, keyb)
	end,
	Slider = function(tname, sname, val)
		Configuration.SetupModule(tname)
		ConfigTable.Modules[tname].Sliders[sname] = val
	end,
	Dropdown = function(tname, dname, val)
		Configuration.SetupModule(tname)
		ConfigTable.Modules[tname].Dropdowns[dname] = val
	end,
	MiniToggle = function(tname, mname, val)
		Configuration.SetupModule(tname)
		ConfigTable.Modules[tname].MiniToggles[mname] = val
	end,
}

local gethui = gethui or function()
	return (RunService:IsStudio() and LocalPlayer.PlayerGui) or cloneref(game:GetService("CoreGui"))
end

local CurrentGame = "sigeon" .. "/" .. game.PlaceId .. ".lua"
if not isfolder("sigeon") then makefolder("sigeon") end

if isfile(CurrentGame) then
	local GetMain = readfile(CurrentGame)
	if GetMain and GetMain ~= "" then
		local Success, OldSettings = pcall(HttpService.JSONDecode, HttpService, GetMain)
		if Success and OldSettings then
			ConfigTable = OldSettings
		end
	end
end

task.spawn(function()
	while task.wait(5) do
		writefile(CurrentGame, HttpService:JSONEncode(ConfigTable))
	end
end)

local function TotalY(obj)
	local layout = obj:FindFirstChildOfClass("UIListLayout")
	if not layout then return obj.Size end
	return UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset, 0, layout.AbsoluteContentSize.Y + 10)
	--slider = 10
end

local function CreateStroke(obj, clr, thick, trans, mode)
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Parent = obj
	UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Center
	UIStroke.Color = clr or Color3.fromRGB(45, 65, 95)
	UIStroke.Thickness = thick or 3
	UIStroke.Transparency = trans or 0
	UIStroke.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
end

local function Draggable(Frame)
	local Dragging, DragStart, StartPos
	
	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = input.Position
			StartPos = Frame.Position
		end
	end)

	Frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = input.Position - DragStart
			Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
		end
	end)
end

function Library:Initialize()
	local Core = {}
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = HttpService:GenerateGUID(false)
	ScreenGui.ResetOnSpawn = false
	if RunService:IsStudio() then
		ScreenGui.Parent = LocalPlayer.PlayerGui
	else
		ScreenGui.Parent = gethui()
	end
	
	--

	local MainFrame = Instance.new("Frame")
	MainFrame.Parent = ScreenGui
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
	MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.Size = UDim2.new(0, 650, 0, 450)
	MainFrame.Visible = false

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 4)
	UICorner.Parent = MainFrame
	
	CreateStroke(MainFrame)

	local MainContainer = Instance.new("Frame")
	MainContainer.Parent = MainFrame
	MainContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MainContainer.BackgroundTransparency = 1.000
	MainContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainContainer.BorderSizePixel = 0
	MainContainer.Size = UDim2.new(0, 200, 1, 0)

	local ProfileContainer = Instance.new("Frame")
	ProfileContainer.Parent = MainContainer
	ProfileContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ProfileContainer.BackgroundTransparency = 1.000
	ProfileContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ProfileContainer.BorderSizePixel = 0
	ProfileContainer.Size = UDim2.new(1, 0, 0, 100)

	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.Parent = ProfileContainer
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BackgroundTransparency = 1.000
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.25, 0, 0.5, 0)
	ImageLabel.Size = UDim2.new(0, 50, 0, 50)
	ImageLabel.Image = "rbxassetid://89022270094032"

	local UICorner_2 = Instance.new("UICorner")
	UICorner_2.CornerRadius = UDim.new(0, 4)
	UICorner_2.Parent = ImageLabel
	
	CreateStroke(ImageLabel)

	local UserLabel = Instance.new("TextLabel")
	UserLabel.Parent = ProfileContainer
	UserLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	UserLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	UserLabel.BackgroundTransparency = 1.000
	UserLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	UserLabel.BorderSizePixel = 0
	UserLabel.Position = UDim2.new(0.680000007, 0, 0.349999994, 0)
	UserLabel.Size = UDim2.new(0, 100, 0, 25)
	UserLabel.Font = Enum.Font.Nunito
	UserLabel.Text = string.lower(LocalPlayer.DisplayName)
	UserLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	UserLabel.TextScaled = true
	UserLabel.TextSize = 18.000
	UserLabel.TextWrapped = true
	UserLabel.TextXAlignment = Enum.TextXAlignment.Left

	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint.Parent = UserLabel
	UITextSizeConstraint.MaxTextSize = 18

	local GameLabel = Instance.new("TextLabel")
	GameLabel.Parent = ProfileContainer
	GameLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	GameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	GameLabel.BackgroundTransparency = 1.000
	GameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	GameLabel.BorderSizePixel = 0
	GameLabel.Position = UDim2.new(0.680000007, 0, 0.5, 0)
	GameLabel.Size = UDim2.new(0, 100, 0, 23)
	GameLabel.Font = Enum.Font.Nunito
	GameLabel.Text = game.PlaceId
	GameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	GameLabel.TextScaled = true
	GameLabel.TextSize = 16.000
	GameLabel.TextTransparency = 0.350
	GameLabel.TextWrapped = true
	GameLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_2.Parent = GameLabel
	UITextSizeConstraint_2.MaxTextSize = 16

	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Parent = ProfileContainer
	StatusLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	StatusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	StatusLabel.BackgroundTransparency = 1.000
	StatusLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	StatusLabel.BorderSizePixel = 0
	StatusLabel.Position = UDim2.new(0.680000007, 0, 0.649999976, 0)
	StatusLabel.Size = UDim2.new(0, 100, 0, 23)
	StatusLabel.Font = Enum.Font.Nunito
	StatusLabel.Text = "beta"
	StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	StatusLabel.TextScaled = true
	StatusLabel.TextSize = 16.000
	StatusLabel.TextTransparency = 0.350
	StatusLabel.TextWrapped = true
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

	local UITextSizeConstraint_3 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_3.Parent = StatusLabel
	UITextSizeConstraint_3.MaxTextSize = 16

	local Seperator_1 = Instance.new("Frame")
	Seperator_1.Parent = ProfileContainer
	Seperator_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Seperator_1.BackgroundColor3 = Color3.fromRGB(32, 45, 65)
	Seperator_1.BackgroundTransparency = 0.500
	Seperator_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Seperator_1.BorderSizePixel = 0
	Seperator_1.Position = UDim2.new(0.5, 0, 1, 0)
	Seperator_1.Size = UDim2.new(0, 100, 0, 4)

	local UICorner_3 = Instance.new("UICorner")
	UICorner_3.CornerRadius = UDim.new(0, 4)
	UICorner_3.Parent = Seperator_1

	local TabsContainer = Instance.new("Frame")
	TabsContainer.Parent = MainContainer
	TabsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabsContainer.BackgroundTransparency = 1.000
	TabsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabsContainer.BorderSizePixel = 0
	TabsContainer.Position = UDim2.new(0, 0, 0, 100)
	TabsContainer.Size = UDim2.new(1, 0, 1, -100)
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = TabsContainer
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 15)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = TabsContainer
	UIPadding.PaddingTop = UDim.new(0, 25)
	
	local Seperator_2 = Instance.new("Frame")
	Seperator_2.Parent = MainContainer
	Seperator_2.AnchorPoint = Vector2.new(0.5, 0.5)
	Seperator_2.BackgroundColor3 = Color3.fromRGB(32, 45, 65)
	Seperator_2.BackgroundTransparency = 0.500
	Seperator_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Seperator_2.BorderSizePixel = 0
	Seperator_2.Position = UDim2.new(1, -5, 0.550000012, 0)
	Seperator_2.Size = UDim2.new(0, 4, 0, 150)

	local UICorner_9 = Instance.new("UICorner")
	UICorner_9.CornerRadius = UDim.new(0, 4)
	UICorner_9.Parent = Seperator_2
	
	local OtherContainer = Instance.new("Frame")
	OtherContainer.Parent = MainFrame
	OtherContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	OtherContainer.BackgroundTransparency = 1.000
	OtherContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	OtherContainer.BorderSizePixel = 0
	OtherContainer.Position = UDim2.new(0, 205, 0, 15)
	OtherContainer.Size = UDim2.new(0, 435, 0, 420)

	--
	
	local VisualFrame = Instance.new("Frame")
	VisualFrame.Parent = ScreenGui
	VisualFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	VisualFrame.BackgroundTransparency = 1.000
	VisualFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	VisualFrame.BorderSizePixel = 0
	VisualFrame.Size = UDim2.new(1, 0, 1, 0)

	local ArrayContainer = Instance.new("Frame")
	ArrayContainer.Parent = VisualFrame
	ArrayContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ArrayContainer.BackgroundTransparency = 1.000
	ArrayContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ArrayContainer.BorderSizePixel = 0
	ArrayContainer.Position = UDim2.new(0, 15, 0, 15)
	ArrayContainer.Size = UDim2.new(0.196470603, 0, 0.855223835, 0)

	local UIListLayout_5 = Instance.new("UIListLayout")
	UIListLayout_5.Parent = ArrayContainer
	UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder

	local Title = Instance.new("TextLabel")
	Title.Parent = ArrayContainer
	Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Title.BackgroundTransparency = 1.000
	Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title.BorderSizePixel = 0
	Title.LayoutOrder = -1
	Title.Position = UDim2.new(1, -42, 0, 0)
	Title.Size = UDim2.new(1, 0, 0, 45)
	Title.ZIndex = -1
	Title.Font = Enum.Font.Nunito
	Title.Text = "sigeon.pex"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 35.000
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left
	
	local Logo = Instance.new("ImageLabel")
	Logo.Parent = VisualFrame
	Logo.AnchorPoint = Vector2.new(0.5, 0.5)
	Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Logo.BackgroundTransparency = 1.000
	Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Logo.BorderSizePixel = 0
	Logo.Position = UDim2.new(0.930000007, 0, 0.879999995, 0)
	Logo.Size = UDim2.new(0, 125, 0, 125)
	Logo.Image = "rbxassetid://135318918544831"
	Logo.ScaleType = Enum.ScaleType.Crop
	
	--
	 
	local TargetHUD = Instance.new("Frame")
	TargetHUD.Parent = VisualFrame
	TargetHUD.BackgroundColor3 = Color3.fromRGB(24, 34, 48)
	TargetHUD.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TargetHUD.Position = UDim2.new(0, 620, 0, 520)
	TargetHUD.Size = UDim2.new(0, 160, 0, 70)
	TargetHUD.Visible = false
	Draggable(TargetHUD)
	
	local UICorner_15 = Instance.new("UICorner")
	UICorner_15.CornerRadius = UDim.new(0, 4)
	UICorner_15.Parent = TargetHUD
	
	CreateStroke(TargetHUD)

	local ImageLabel_2 = Instance.new("ImageLabel")
	ImageLabel_2.Parent = TargetHUD
	ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel_2.BackgroundTransparency = 1.000
	ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel_2.BorderSizePixel = 0
	ImageLabel_2.Position = UDim2.new(0.184375003, 0, 0.407142848, 0)
	ImageLabel_2.Size = UDim2.new(0, 40, 0, 40)
	ImageLabel_2.Image = "rbxassetid://89022270094032"

	local UICorner_16 = Instance.new("UICorner")
	UICorner_16.CornerRadius = UDim.new(0, 4)
	UICorner_16.Parent = ImageLabel_2
		
	CreateStroke(ImageLabel_2, Color3.fromRGB(255, 255, 255), 1)

	local BackFrame = Instance.new("Frame")
	BackFrame.Parent = TargetHUD
	BackFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	BackFrame.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
	BackFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	BackFrame.BorderSizePixel = 0
	BackFrame.Position = UDim2.new(0.5, 0, 0.82, 0)
	BackFrame.Size = UDim2.new(1, -20, 0, 5)

	local FrontFrame = Instance.new("Frame")
	FrontFrame.Parent = BackFrame
	FrontFrame.BackgroundColor3 = Color3.fromRGB(45, 65, 95)
	FrontFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FrontFrame.BorderSizePixel = 0
	FrontFrame.Size = UDim2.new(1, -50, 1, 0)

	local TextLabel_10 = Instance.new("TextLabel")
	TextLabel_10.Parent = TargetHUD
	TextLabel_10.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel_10.BackgroundTransparency = 1.000
	TextLabel_10.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel_10.BorderSizePixel = 0
	TextLabel_10.Position = UDim2.new(0, 55, 0, 5)
	TextLabel_10.Size = UDim2.new(1, -55, 0, 25)
	TextLabel_10.Font = Enum.Font.SourceSans
	TextLabel_10.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel_10.TextScaled = true
	TextLabel_10.TextSize = 14.000
	TextLabel_10.TextWrapped = true
	TextLabel_10.TextXAlignment = Enum.TextXAlignment.Left

	local UITextSizeConstraint_17 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_17.Parent = TextLabel_10
	UITextSizeConstraint_17.MaxTextSize = 14

	local TextLabel_11 = Instance.new("TextLabel")
	TextLabel_11.Parent = TargetHUD
	TextLabel_11.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel_11.BackgroundTransparency = 1.000
	TextLabel_11.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel_11.BorderSizePixel = 0
	TextLabel_11.Position = UDim2.new(0, 55, 0, 25)
	TextLabel_11.Size = UDim2.new(1, -55, 0, 25)
	TextLabel_11.Font = Enum.Font.SourceSans
	TextLabel_11.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel_11.TextScaled = true
	TextLabel_11.TextSize = 14.000
	TextLabel_11.TextWrapped = true
	TextLabel_11.TextXAlignment = Enum.TextXAlignment.Left

	local UITextSizeConstraint_18 = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint_18.Parent = TextLabel_11
	UITextSizeConstraint_18.MaxTextSize = 14
	
	--
	
	local ArrayTable = {}
	local function Insert_Array(name)
		
		local ArrayLabel = Instance.new("TextLabel")
		ArrayLabel.Parent = ArrayContainer
		ArrayLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		ArrayLabel.BackgroundTransparency = 1.000
		ArrayLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ArrayLabel.BorderSizePixel = 0
		ArrayLabel.LayoutOrder = 1
		ArrayLabel.Position = UDim2.new(1, -42, 0, 0)
		ArrayLabel.Size = UDim2.new(1, 0, 0, 25)
		ArrayLabel.ZIndex = -1
		ArrayLabel.Font = Enum.Font.Nunito
		ArrayLabel.Text = " " .. string.lower(name)
		ArrayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		ArrayLabel.TextSize = 18.000
		ArrayLabel.TextWrapped = true
		ArrayLabel.TextXAlignment = Enum.TextXAlignment.Left

		local MaxWidth = ArrayContainer.AbsoluteSize.X
		local TextSize = TextService:GetTextSize("  " .. name .. "  ", ArrayLabel.TextSize, ArrayLabel.Font, Vector2.new(MaxWidth, math.huge))
		local NewSize = UDim2.new(0, TextSize.X, 0, 20)
		if name == "" then
			NewSize = UDim2.new(0, 0, 0, 0)
		end
		ArrayLabel.Size = NewSize

		table.insert(ArrayTable, ArrayLabel)
		table.sort(ArrayTable, function(a, b) return TextService:GetTextSize(a.Text, a.TextSize, a.Font, Vector2.new(MaxWidth, math.huge)).X > game.TextService:GetTextSize(b.Text, b.TextSize, b.Font, Vector2.new(MaxWidth, math.huge)).X end)
		for i, v in ipairs(ArrayTable) do
			v.LayoutOrder = i
		end
	end

	local function Remove_Array(name)
		local MaxWidth = ArrayContainer.AbsoluteSize.X
		table.sort(ArrayTable, function(a, b) return TextService:GetTextSize(a.Text, a.TextSize, a.Font, Vector2.new(MaxWidth, math.huge)).X > game.TextService:GetTextSize(b.Text, b.TextSize, b.Font, Vector2.new(MaxWidth, math.huge)).X end)
		for i, v in ipairs(ArrayTable) do
			if v.Text == " " .. string.lower(name) then
				v:Destroy()
				table.remove(ArrayTable, i)
			end
		end
		for i, v in ipairs(ArrayTable) do
			v.LayoutOrder = i
		end
	end
	
	function Core:DisplayTarget(Datas)
		Datas = {
			Name = Datas.Name or "failed_get_name",
			Thumbnail = Datas.Thumbnail or "rbxassetid://89022270094032",
			Humanoid = Datas.Humanoid or LocalPlayer.Character:FindFirstChildOfClass("Humanoid"),
			Visible = Datas.Visible or false,
		}
		
		TargetHUD.Visible = Datas.Visible
		TextLabel_10.Text = string.lower(Datas.Name)
		ImageLabel_2.Image = Datas.Thumbnail
		
		local Calculated = Datas.Humanoid.Health / Datas.Humanoid.MaxHealth
		if Datas.Humanoid.Health > 0 then
			TweenService:Create(FrontFrame, TweenInfo.new(0.5), {Size = UDim2.new(Calculated, 0, 1, 0)}):Play()
		elseif Datas.Humanoid.Health < 0 then
			TweenService:Create(FrontFrame, TweenInfo.new(0.5), {Size = UDim2.new(-0, 0, 1, 0)}):Play()
		else
			TweenService:Create(FrontFrame, TweenInfo.new(0.5), {Size = UDim2.new(-0, 0, 1, 0)}):Play()
		end
		if LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health > Datas.Humanoid.Health then
			TextLabel_11.Text = "winning"
		elseif LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health < Datas.Humanoid.Health then
			TextLabel_11.Text = "losing"
		elseif LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health == Datas.Humanoid.Health then
			TextLabel_11.Text = "tie"
		end
		return Datas
	end
	
	function Core:CreateNotification(title, desc, dur)
		
		local Notification = Instance.new("Frame")
		Notification.Parent = VisualFrame
		Notification.AnchorPoint = Vector2.new(0.5, 0.5)
		Notification.BackgroundColor3 = Color3.fromRGB(24, 34, 48)
		Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Notification.Position = UDim2.new(1.5, 0, 0.1, 0)
		Notification.Size = UDim2.new(0, 200, 0, 60)
		CreateStroke(Notification)

		local UICorner_23232 = Instance.new("UICorner")
		UICorner_23232.CornerRadius = UDim.new(0, 4)
		UICorner_23232.Parent = Notification
		
		local TextLabel42121 = Instance.new("TextLabel")
		TextLabel42121.Parent = Notification
		TextLabel42121.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel42121.BackgroundTransparency = 1.000
		TextLabel42121.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel42121.BorderSizePixel = 0
		TextLabel42121.Position = UDim2.new(0, 10, 0, 5)
		TextLabel42121.Size = UDim2.new(1, -10, 0, 25)
		TextLabel42121.Font = Enum.Font.SourceSans
		TextLabel42121.Text = tostring(title)
		TextLabel42121.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel42121.TextScaled = true
		TextLabel42121.TextSize = 14.000
		TextLabel42121.TextWrapped = true
		TextLabel42121.TextXAlignment = Enum.TextXAlignment.Left
		
		local UITextSizeConstraint_111111 = Instance.new("UITextSizeConstraint")
		UITextSizeConstraint_111111.Parent = TextLabel42121
		UITextSizeConstraint_111111.MaxTextSize = 20
	
		local TextLabel_25555 = Instance.new("TextLabel")
		TextLabel_25555.Parent = Notification
		TextLabel_25555.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel_25555.BackgroundTransparency = 1.000
		TextLabel_25555.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel_25555.BorderSizePixel = 0
		TextLabel_25555.Position = UDim2.new(0, 10, 0, 30)
		TextLabel_25555.Size = UDim2.new(1, -10, 0, 30)
		TextLabel_25555.Font = Enum.Font.SourceSans
		TextLabel_25555.Text = tostring(desc)
		TextLabel_25555.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel_25555.TextScaled = true
		TextLabel_25555.TextSize = 14.000
		TextLabel_25555.TextWrapped = true
		TextLabel_25555.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel_25555.TextYAlignment = Enum.TextYAlignment.Top
		
		local UITextSizeConstraint_11112 = Instance.new("UITextSizeConstraint")
		UITextSizeConstraint_11112.Parent = TextLabel_25555
		UITextSizeConstraint_11112.MaxTextSize = 14
		
		TweenService:Create(Notification, TweenInfo.new(0.4), {Position = UDim2.new(0.9, 0, 0.1, 0)}):Play()
		task.wait(dur or 3)
		TweenService:Create(Notification, TweenInfo.new(0.4), {Position = UDim2.new(1.5, 0, 0.1, 0)}):Play()
		task.wait(0.4)
		Notification:Destroy()
	end
	
	UserInputService.InputBegan:Connect(function(Input, gameProcessedEvent)
		if Input.KeyCode == Enum.KeyCode.RightShift and not gameProcessedEvent then
			MainFrame.Visible = not MainFrame.Visible
			--[[
			if MainFrame.Visible then
				if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then 
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default 
				end
			else
				if UserInputService.MouseBehavior == Enum.MouseBehavior.Default then 
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter 
				end
			end
			--]]
		end
	end)
	
	--
	
	function Core:CreateSection(types, offsets)
		local Sections = {}
		
		local TextButton = Instance.new("TextButton")
		TextButton.Parent = TabsContainer
		TextButton.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
		TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.BorderSizePixel = 0
		TextButton.Position = UDim2.new(-0.103448279, 0, 0, 0)
		TextButton.Size = UDim2.new(0, 150, 0, 40)
		TextButton.AutoButtonColor = false
		TextButton.Font = Enum.Font.Nunito
		TextButton.Text = ""
		TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextButton.TextScaled = true
		TextButton.TextSize = 18.000
		TextButton.TextWrapped = true

		local ImageButton = Instance.new("ImageButton")
		ImageButton.Parent = TextButton
		ImageButton.AnchorPoint = Vector2.new(0.5, 0.5)
		ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ImageButton.BackgroundTransparency = 1.000
		ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ImageButton.BorderSizePixel = 0
		ImageButton.Position = UDim2.new(0.150000006, 0, 0.5, 0)
		ImageButton.Size = UDim2.new(0, 20, 0, 20)
		ImageButton.Image = "rbxassetid://10734943902"

		local TextLabel = Instance.new("TextLabel")
		TextLabel.Parent = TextButton
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 1.000
		TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0, 50, 0, 0)
		TextLabel.Size = UDim2.new(1, -50, 1, 0)
		TextLabel.Font = Enum.Font.SourceSans
		TextLabel.Text = "Combat"
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextScaled = true
		TextLabel.TextSize = 18.000
		TextLabel.TextWrapped = true
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left

		local UITextSizeConstraint_4 = Instance.new("UITextSizeConstraint")
		UITextSizeConstraint_4.Parent = TextLabel
		UITextSizeConstraint_4.MaxTextSize = 18
		
		local UICorner_4 = Instance.new("UICorner")
		UICorner_4.Parent = TextButton
		
		local ModulesContainer = Instance.new("ScrollingFrame")
		ModulesContainer.Parent = OtherContainer
		ModulesContainer.Active = true
		ModulesContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ModulesContainer.BackgroundTransparency = 1.000
		ModulesContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ModulesContainer.BorderSizePixel = 0
		ModulesContainer.Size = UDim2.new(1, 0, 1, 0)
		ModulesContainer.ScrollBarThickness = 0
		ModulesContainer.Visible = false
		ModulesContainer.CanvasSize = offsets or UDim2.new(0, 0, 3, 90)
		--3, 90
		local UIPadding_2 = Instance.new("UIPadding")
		UIPadding_2.Parent = ModulesContainer
		UIPadding_2.PaddingLeft = UDim.new(0, 15)
		UIPadding_2.PaddingTop = UDim.new(0, 15)
		
		local UIListLayout_2 = Instance.new("UIListLayout")
		UIListLayout_2.Parent = ModulesContainer
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.Padding = UDim.new(0, 15)
		UIListLayout_2.Wraps = true
		
		--
		
		if types == 1 then
			ImageButton.Image = "rbxassetid://10734943902"
			TextLabel.Text = "Combat"
		elseif types == 2 then
			ImageButton.Image = "rbxassetid://10723354671"
			TextLabel.Text = "Movement"
		elseif types == 3 then
			ImageButton.Image = "rbxassetid://10709782497"
			TextLabel.Text = "Visual"
		elseif types == 4 then
			ImageButton.Image = "rbxassetid://10734897956"
			TextLabel.Text = "World"
		elseif types == 5 then
			ImageButton.Image = "rbxassetid://10734910187"
			TextLabel.Text = "Miscellaneous"
		end
		
		--
		
		ImageButton.MouseButton1Click:Connect(function()
			for _, v in pairs(OtherContainer:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
			for _, v in pairs(TabsContainer:GetDescendants()) do
				if v:IsA("UIStroke") then 
					v:Destroy() 
				end
			end
			ModulesContainer.Visible = true
			CreateStroke(TextButton, Color3.fromRGB(45, 65, 95), 1.5, 0.5)
		end)
		
		TextButton.MouseButton1Click:Connect(function()
			for _, v in pairs(OtherContainer:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
			for _, v in pairs(TabsContainer:GetDescendants()) do
				if v:IsA("UIStroke") then 
					v:Destroy() 
				end
			end
			ModulesContainer.Visible = true
			CreateStroke(TextButton, Color3.fromRGB(45, 65, 95), 1.5, 0.5)
		end)
		
		function Sections:CreateToggle(ToggleButton)
			ToggleButton = {
				Name = ToggleButton.Name,
				Enabled = ToggleButton.Enabled or false,
				Keybind = ToggleButton.Keybind or "Euro",
				Callback = ToggleButton.Callback or function() end,
			}
			local Enabled, Keybind = Configuration.Register.ToggleButton(ToggleButton.Name, ToggleButton.Enabled, ToggleButton.Keybind)

			ToggleButton.Enabled = Enabled
			ToggleButton.Keybind = Keybind
			local ToggleHolder = Instance.new("Frame")
			ToggleHolder.Parent = ModulesContainer
			ToggleHolder.Transparency = 1.000
			ToggleHolder.Size = UDim2.new(0, 200, 0, 40)
			
			local UIListLayout_55 = Instance.new("UIListLayout")
			UIListLayout_55.Parent = ToggleHolder
			UIListLayout_55.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_55.Padding = UDim.new(0, 10)
			--UIListLayout_55.Wraps = true
			
			local ToggleMain = Instance.new("TextButton")
			ToggleMain.Parent = ToggleHolder
			ToggleMain.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
			ToggleMain.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleMain.BorderSizePixel = 0
			ToggleMain.Position = UDim2.new(-0.103448279, 0, 0, 0)
			ToggleMain.Size = UDim2.new(0, 200, 0, 40)
			ToggleMain.AutoButtonColor = false
			ToggleMain.Font = Enum.Font.Nunito
			ToggleMain.Text = ""
			ToggleMain.TextColor3 = Color3.fromRGB(255, 255, 255)
			ToggleMain.TextScaled = true
			ToggleMain.TextSize = 18.000
			ToggleMain.TextWrapped = true
			CreateStroke(ToggleMain, Color3.fromRGB(45, 65, 95), 1.5, 0.5)
			local ToggleStroke = ToggleMain:FindFirstChildOfClass("UIStroke")

			local TextLabel_6 = Instance.new("TextLabel")
			TextLabel_6.Parent = ToggleMain
			TextLabel_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_6.BackgroundTransparency = 1.000
			TextLabel_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel_6.BorderSizePixel = 0
			TextLabel_6.Position = UDim2.new(0, 15, 0, 0)
			TextLabel_6.Size = UDim2.new(1, -15, 1, 0)
			TextLabel_6.Font = Enum.Font.SourceSans
			TextLabel_6.Text = ToggleButton.Name
			TextLabel_6.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_6.TextScaled = true
			TextLabel_6.TextSize = 18.000
			TextLabel_6.TextWrapped = true
			TextLabel_6.TextXAlignment = Enum.TextXAlignment.Left
			
			local UITextSizeConstraint_9 = Instance.new("UITextSizeConstraint")
			UITextSizeConstraint_9.Parent = TextLabel_6
			UITextSizeConstraint_9.MaxTextSize = 18

			local UICorner_10 = Instance.new("UICorner")
			UICorner_10.Parent = ToggleMain

			local TextBox = Instance.new("TextBox")
			TextBox.Parent = ToggleMain
			TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
			TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextBox.BackgroundTransparency = 1.000
			TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextBox.BorderSizePixel = 0
			TextBox.Position = UDim2.new(0.899999976, 0, 0.5, 0)
			TextBox.Size = UDim2.new(0, 20, 0, 20)
			TextBox.Font = Enum.Font.SourceSans
			TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			TextBox.PlaceholderText = "-"
			TextBox.Text = ""
			TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextBox.TextScaled = true
			TextBox.TextSize = 14.000
			TextBox.TextWrapped = true
			CreateStroke(TextBox, Color3.fromRGB(45, 65, 95), 1.5, 0.5)
			
			local UICorner_11 = Instance.new("UICorner")
			UICorner_11.CornerRadius = UDim.new(0, 4)
			UICorner_11.Parent = TextBox

			local UITextSizeConstraint_10 = Instance.new("UITextSizeConstraint")
			UITextSizeConstraint_10.Parent = TextBox
			UITextSizeConstraint_10.MaxTextSize = 14

			local MenuContainer = Instance.new("Frame")
			MenuContainer.Parent = ToggleHolder
			MenuContainer.BackgroundColor3 = Color3.fromRGB(24, 34, 48)
			MenuContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
			MenuContainer.BorderSizePixel = 0
			MenuContainer.Size = UDim2.new(0, 200, 0, 105)
			
			CreateStroke(MenuContainer, Color3.fromRGB(45, 65, 95), 1.5, 0.5)
			local MenuStoke = MenuContainer:FindFirstChildOfClass("UIStroke")
			
			task.spawn(function()
				MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
					if MainFrame.Visible then
						MenuContainer.Size = TotalY(MenuContainer)
						ToggleHolder.Size = TotalY(MenuContainer)
					end
				end)
			end)
			
			local UICorner_12 = Instance.new("UICorner")
			UICorner_12.CornerRadius = UDim.new(0, 4)
			UICorner_12.Parent = MenuContainer
			
			local UIListLayout_3 = Instance.new("UIListLayout")
			UIListLayout_3.Parent = MenuContainer
			UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

			local UIPadding_3 = Instance.new("UIPadding")
			UIPadding_3.Parent = MenuContainer
			UIPadding_3.PaddingTop = UDim.new(0, 5)
			
			local Frame_69 = Instance.new("Frame")
			Frame_69.Parent = ModulesContainer
			Frame_69.BackgroundTransparency = 1.000
			Frame_69.Size = UDim2.new(0, 200, 0, 30)

			task.spawn(function()
				if not MenuContainer then return end
				while true do
					task.wait(5)
					if not MenuContainer.Parent then
						break
					end
					if #MenuContainer:GetChildren() <= 4 then
						MenuContainer:Destroy()
						Frame_69.Size = UDim2.new(0, 200, 0, 10)
						ToggleHolder.Size = TotalY(MenuContainer)
						print("!")
						break
					end
				end
			end)
			
			--
			
			local function OnClicked()
				if ToggleButton.Enabled then
					ToggleStroke.Color = Color3.fromRGB(121, 175, 255)
					MenuStoke.Color = Color3.fromRGB(121, 175, 255)
					Insert_Array(ToggleButton.Name)
				else
					ToggleStroke.Color = Color3.fromRGB(45, 65, 95)
					MenuStoke.Color = Color3.fromRGB(45, 65, 95)
					Remove_Array(ToggleButton.Name)
				end
				ConfigTable.Modules[ToggleButton.Name].Enabled = ToggleButton.Enabled
			end
			
			UserInputService.InputBegan:Connect(function(Input, isTyping)
				if Input.UserInputType == Enum.UserInputType.Keyboard then
					if TextBox:IsFocused() then
						ToggleButton.Keybind = Input.KeyCode.Name
						TextBox.PlaceholderText = ""
						TextBox.Text = Input.KeyCode.Name
						TextBox:ReleaseFocus()
						ConfigTable.Modules[ToggleButton.Name].Keybind = ToggleButton.Keybind
					elseif ToggleButton.Keybind == "Backspace" then
						ToggleButton.Keybind = "Euro"
						TextBox.Text = ""
						TextBox.PlaceholderText = "-"
						TextBox:ReleaseFocus()
						ConfigTable.Modules[ToggleButton.Name].Keybind = ToggleButton.Keybind
					end       
				end
			end)
			
			if ToggleButton.Enabled then
				ToggleButton.Enabled = true
				OnClicked()

				if ToggleButton.Callback then
					ToggleButton.Callback(ToggleButton.Enabled)
				end
			end

			ToggleMain.MouseButton1Click:Connect(function()
				ToggleButton.Enabled = not ToggleButton.Enabled
				OnClicked()

				if ToggleButton.Callback then
					ToggleButton.Callback(ToggleButton.Enabled)
				end
			end)

			if ToggleButton.Keybind then
				UserInputService.InputBegan:Connect(function(Input, isTyping)
					if Input.KeyCode == Enum.KeyCode[ToggleButton.Keybind] and not isTyping then
						ToggleButton.Enabled = not ToggleButton.Enabled
						OnClicked()

						if ToggleButton.Callback then
							ToggleButton.Callback(ToggleButton.Enabled)
						end
					end
				end)
			end
			
			function ToggleButton:CreateDropdown(Dropdown)
				Dropdown = {
					Name = Dropdown.Name,
					List = Dropdown.List or {},
					Default = Dropdown.Default,
					Callback = Dropdown.Callback or function() end
				}
				Configuration.Register.Dropdown(ToggleButton.Name, Dropdown.Name, Dropdown.Default)
				if ConfigTable.Modules[ToggleButton.Name].Dropdowns[Dropdown.Name] then
					Dropdown.Default = ConfigTable.Modules[ToggleButton.Name].Dropdowns[Dropdown.Name]
				end
				
				local Frame_4 = Instance.new("Frame")
				Frame_4.Parent = MenuContainer
				Frame_4.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				Frame_4.BackgroundTransparency = 1.000
				Frame_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_4.BorderSizePixel = 0
				Frame_4.Size = UDim2.new(1, 0, 0, 28)

				local TextLabel_9 = Instance.new("TextLabel")
				TextLabel_9.Parent = Frame_4
				TextLabel_9.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_9.BackgroundTransparency = 1.000
				TextLabel_9.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel_9.BorderSizePixel = 0
				TextLabel_9.Position = UDim2.new(0, 8, 0, 0)
				TextLabel_9.Size = UDim2.new(0, 175, 1, 0)
				TextLabel_9.Font = Enum.Font.Nunito
				TextLabel_9.Text = Dropdown.Name
				TextLabel_9.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_9.TextSize = 18.000
				TextLabel_9.TextWrapped = true
				TextLabel_9.TextXAlignment = Enum.TextXAlignment.Left

				local TextButton_8 = Instance.new("TextButton")
				TextButton_8.Parent = Frame_4
				TextButton_8.AnchorPoint = Vector2.new(0.5, 0.5)
				TextButton_8.BackgroundTransparency = 1.000
				TextButton_8.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextButton_8.BorderSizePixel = 0
				TextButton_8.Position = UDim2.new(0.75999999, 0, 0.5, 0)
				TextButton_8.Size = UDim2.new(0, 75, 0, 18)
				TextButton_8.AutoButtonColor = false
				TextButton_8.Font = Enum.Font.SourceSans
				TextButton_8.Text = Dropdown.Default
				TextButton_8.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextButton_8.TextScaled = true
				TextButton_8.TextSize = 16.000
				TextButton_8.TextWrapped = true
				CreateStroke(TextButton_8, Color3.fromRGB(45, 65, 95), 1.5, 0.5)
				
				local UICorner_14 = Instance.new("UICorner")
				UICorner_14.CornerRadius = UDim.new(0, 4)
				UICorner_14.Parent = TextButton_8

				local Frame_5 = Instance.new("Frame")
				Frame_5.Parent = TextButton_8
				Frame_5.BackgroundColor3 = Color3.fromRGB(24, 34, 48)
				Frame_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_5.BorderSizePixel = 0
				Frame_5.Position = UDim2.new(0, 0, 1, 0)
				Frame_5.Size = UDim2.new(1, 0, 0, 100)
				Frame_5.Visible = false
				Frame_5.ZIndex = 2
				CreateStroke(Frame_5, Color3.fromRGB(45, 65, 95), 1.5, 0.5)
				
				task.spawn(function()
					Frame_5:GetPropertyChangedSignal("Visible"):Connect(function()
						if Frame_5.Visible then
							Frame_5.Size = TotalY(Frame_5)
						end
					end)
				end)
				
				local UIListLayout_4 = Instance.new("UIListLayout")
				UIListLayout_4.Parent = Frame_5
				UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
				
				for _, v in ipairs(Dropdown.List) do
					local TextButton_9 = Instance.new("TextButton")
					TextButton_9.Parent = Frame_5
					TextButton_9.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					TextButton_9.BackgroundTransparency = 1.000
					TextButton_9.BorderColor3 = Color3.fromRGB(0, 0, 0)
					TextButton_9.BorderSizePixel = 0
					TextButton_9.Size = UDim2.new(1, 0, 0, 20)
					TextButton_9.Font = Enum.Font.SourceSans
					TextButton_9.TextColor3 = Color3.fromRGB(255, 255, 255)
					TextButton_9.TextScaled = true
					TextButton_9.TextSize = 14.000
					TextButton_9.TextTransparency = 0.45
					TextButton_9.TextWrapped = true
					TextButton_9.Text = v
					TextButton_9.ZIndex = 3
					
					local UITextSizeConstraint_11 = Instance.new("UITextSizeConstraint")
					UITextSizeConstraint_11.Parent = TextButton_9
					UITextSizeConstraint_11.MaxTextSize = 14

					--
					
					TextButton_9.MouseButton1Click:Connect(function()
						Dropdown.Default = v
						TextButton_8.Text = v
						Dropdown.Callback(v)
						ConfigTable.Modules[ToggleButton.Name].Dropdowns[Dropdown.Name] = v
					end)
				end

				TextButton_8.MouseButton1Click:Connect(function() 
					Frame_5.Visible = not Frame_5.Visible
				end)
				
				if Dropdown.Default then
					TextButton_8.Text = Dropdown.Default
					Dropdown.Callback(Dropdown.Default)
				end
				
				return Dropdown	
			end
			
			function ToggleButton:CreateSlider(Slider)
				Slider = {
					Name = Slider.Name,
					Min = Slider.Min or 0,
					Max = Slider.Max or 100,
					Default = Slider.Default,
					Callback = Slider.Callback or function() end
				}
				Configuration.Register.Slider(ToggleButton.Name, Slider.Name, Slider.Default)
				if ConfigTable.Modules[ToggleButton.Name].Sliders[Slider.Name] then
					Slider.Default = ConfigTable.Modules[ToggleButton.Name].Sliders[Slider.Name]
				end
				
				local Dragged, Value = false, nil
				local Frame = Instance.new("Frame")
				Frame.Parent = MenuContainer
				Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				Frame.BackgroundTransparency = 1.000
				Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame.BorderSizePixel = 0
				Frame.Size = UDim2.new(1, 0, 0, 38)

				local TextLabel_7 = Instance.new("TextLabel")
				TextLabel_7.Parent = Frame
				TextLabel_7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_7.BackgroundTransparency = 1.000
				TextLabel_7.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel_7.BorderSizePixel = 0
				TextLabel_7.Position = UDim2.new(0, 8, 0, 5)
				TextLabel_7.Size = UDim2.new(1, 0, 0, 15)
				TextLabel_7.Font = Enum.Font.Nunito
				TextLabel_7.Text = Slider.Name
				TextLabel_7.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_7.TextSize = 18.000
				TextLabel_7.TextWrapped = true
				TextLabel_7.TextXAlignment = Enum.TextXAlignment.Left

				local TextBox_2 = Instance.new("TextBox")
				TextBox_2.Parent = Frame
				TextBox_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextBox_2.BackgroundTransparency = 1.000
				TextBox_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextBox_2.BorderSizePixel = 0
				TextBox_2.Position = UDim2.new(0, 110, 0, 5)
				TextBox_2.Size = UDim2.new(0, 80, 0, 15)
				TextBox_2.Font = Enum.Font.SourceSans
				TextBox_2.Text = "50"
				TextBox_2.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextBox_2.TextSize = 18.000
				TextBox_2.TextWrapped = true
				TextBox_2.TextXAlignment = Enum.TextXAlignment.Right
				
				local UITextSizeConstraint_69 = Instance.new("UITextSizeConstraint")
				UITextSizeConstraint_69.Parent = TextBox_2
				UITextSizeConstraint_69.MaxTextSize = 18
				
				local TextButton_6 = Instance.new("TextButton")
				TextButton_6.Parent = Frame
				TextButton_6.BackgroundColor3 = Color3.fromRGB(22, 31, 44)
				TextButton_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextButton_6.BorderSizePixel = 0
				TextButton_6.Position = UDim2.new(0, 8, 0, 28)
				TextButton_6.Size = UDim2.new(0, 181, 0, 8)
				TextButton_6.AutoButtonColor = false
				TextButton_6.Text = ""
				TextButton_6.TextColor3 = Color3.fromRGB(27, 42, 53)
				
				local Frame_2 = Instance.new("Frame")
				Frame_2.Parent = TextButton_6
				Frame_2.BackgroundColor3 = Color3.fromRGB(45, 65, 95)
				Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_2.BorderSizePixel = 0
				Frame_2.Size = UDim2.new(0.5, 0, 1, 0)
				
				local function UpdateValue(Input)
					local MouseX = math.clamp(Input.Position.X, TextButton_6.AbsolutePosition.X, TextButton_6.AbsolutePosition.X + TextButton_6.AbsoluteSize.X)
					Value = math.floor(((MouseX - TextButton_6.AbsolutePosition.X) / TextButton_6.AbsoluteSize.X) * (Slider.Max - Slider.Min) + Slider.Min + 0.05) * 10 / 10
					Frame_2.Size = UDim2.new((Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
					TextBox_2.Text = Value
					Slider.Callback(Value)
					ConfigTable.Modules[ToggleButton.Name].Sliders[Slider.Name] = Value
				end

				TextButton_6.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragged = true
						local MouseX = math.clamp(UserInputService:GetMouseLocation().X, TextButton_6.AbsolutePosition.X, TextButton_6.AbsolutePosition.X + TextButton_6.AbsoluteSize.X)
						Value = math.floor(((MouseX - TextButton_6.AbsolutePosition.X) / TextButton_6.AbsoluteSize.X) * (Slider.Max - Slider.Min) + Slider.Min + 0.05) * 10 / 10
						Frame_2.Size = UDim2.new((Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
						TextBox_2.Text = Value
						Slider.Callback(Value)
					end
				end)

				TextButton_6.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragged = false
					end
				end)

				UserInputService.InputChanged:Connect(function(Input)
					if Dragged and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
						UpdateValue(Input)
					end
				end)

				TextBox_2.FocusLost:Connect(function(Return)
					if not Return then return end
					local NumValue = tonumber(TextBox_2.Text)
					if NumValue then
						Value = math.clamp(NumValue, Slider.Min, Slider.Max)
						Frame_2.Size = UDim2.new((Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
						TextBox_2.Text = Value
						Slider.Callback(Value)
						ConfigTable.Modules[ToggleButton.Name].Sliders[Slider.Name] = Value
					else
						TextBox_2.Text = Value
					end
				end)

				if Slider.Default then
					Value = math.clamp(Slider.Default, Slider.Min, Slider.Max)
					Frame_2.Size = UDim2.new((Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
					TextBox_2.Text = Value
					Slider.Callback(Value)
				else
					Value = math.clamp(0, Slider.Min, Slider.Max)
					Frame_2.Size = UDim2.new((Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
					TextBox_2.Text = Value
					Slider.Callback(Value)
				end
				
				return Slider	
			end
			
			function ToggleButton:CreateMiniToggle(MiniToggle)
				MiniToggle = {
					Name = MiniToggle.Name,
					Enabled = MiniToggle.Enabled or false,
					Callback = MiniToggle.Callback or function() end
				}
				Configuration.Register.MiniToggle(ToggleButton.Name, MiniToggle.Name, MiniToggle.Enabled)
				if ConfigTable.Modules[ToggleButton.Name].MiniToggles[MiniToggle.Name] ~= nil then
					MiniToggle.Enabled = ConfigTable.Modules[ToggleButton.Name].MiniToggles[MiniToggle.Name]
				end
				
				local Frame_3 = Instance.new("Frame")
				Frame_3.Parent = MenuContainer
				Frame_3.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				Frame_3.BackgroundTransparency = 1.000
				Frame_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame_3.BorderSizePixel = 0
				Frame_3.Size = UDim2.new(1, 0, 0, 28)

				local TextLabel_8 = Instance.new("TextLabel")
				TextLabel_8.Parent = Frame_3
				TextLabel_8.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_8.BackgroundTransparency = 1.000
				TextLabel_8.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel_8.BorderSizePixel = 0
				TextLabel_8.Position = UDim2.new(0, 8, 0, 0)
				TextLabel_8.Size = UDim2.new(0, 175, 1, 0)
				TextLabel_8.Font = Enum.Font.Nunito
				TextLabel_8.Text = MiniToggle.Name
				TextLabel_8.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel_8.TextSize = 18.000
				TextLabel_8.TextWrapped = true
				TextLabel_8.TextXAlignment = Enum.TextXAlignment.Left
				
				local TextButton_7 = Instance.new("TextButton")
				TextButton_7.Parent = Frame_3
				TextButton_7.AnchorPoint = Vector2.new(0.5, 0.5)
				TextButton_7.BackgroundColor3 = Color3.fromRGB(22, 31, 44)
				TextButton_7.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextButton_7.BorderSizePixel = 0
				TextButton_7.Position = UDim2.new(0.899999976, 0, 0.5, 0)
				TextButton_7.Size = UDim2.new(0, 18, 0, 18)
				TextButton_7.AutoButtonColor = false
				TextButton_7.Font = Enum.Font.SourceSans
				TextButton_7.Text = ""
				TextButton_7.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextButton_7.TextScaled = true
				TextButton_7.TextSize = 18.000
				TextButton_7.TextTransparency = 1.000
				TextButton_7.TextWrapped = true
	
				local UICorner_13 = Instance.new("UICorner")
				UICorner_13.CornerRadius = UDim.new(0, 4)
				UICorner_13.Parent = TextButton_7
				
				local function OnClick()
					if MiniToggle.Enabled then
						TextButton_7.BackgroundColor3 = Color3.fromRGB(45, 65, 95)
					else
						TextButton_7.BackgroundColor3 = Color3.fromRGB(22, 31, 44)
					end
					ConfigTable.Modules[ToggleButton.Name].MiniToggles[MiniToggle.Name] = MiniToggle.Enabled
				end

				if MiniToggle.Enabled then
					MiniToggle.Enabled = true
					OnClick()

					if MiniToggle.Callback then
						MiniToggle.Callback(MiniToggle.Enabled)
					end
				end

				TextButton_7.MouseButton1Click:Connect(function()
					MiniToggle.Enabled = not MiniToggle.Enabled
					OnClick()

					if MiniToggle.Callback then
						MiniToggle.Callback(MiniToggle.Enabled)
					end
				end)
				
				return MiniToggle	
			end
		
			return ToggleButton
		end
		
		return Sections
	end
	
	return Core
end

return Library
