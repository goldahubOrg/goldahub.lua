local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer

local TOGGLE_KEY = Enum.KeyCode.G
local FLY_SPEED = 60
local ICON = "🥇"
local START_VISIBLE = true

local C = {
	bg = Color3.fromRGB(16, 15, 13),
	side = Color3.fromRGB(11, 10, 9),
	row = Color3.fromRGB(26, 24, 21),
	line = Color3.fromRGB(52, 46, 36),
	off = Color3.fromRGB(48, 44, 38),
	text = Color3.fromRGB(236, 229, 212),
	muted = Color3.fromRGB(137, 128, 108),
	gold = Color3.fromRGB(240, 185, 60),
	goldLight = Color3.fromRGB(255, 226, 130),
	goldDark = Color3.fromRGB(184, 128, 28),
	good = Color3.fromRGB(120, 210, 130),
	warn = Color3.fromRGB(240, 190, 60),
	bad = Color3.fromRGB(235, 95, 85),
}

local GOLD_GRADIENT = ColorSequence.new(C.goldLight, C.goldDark)

local function new(class, props, parent)
	local obj = Instance.new(class)
	for key, value in pairs(props) do
		obj[key] = value
	end
	obj.Parent = parent
	return obj
end

local function round(obj, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius) }, obj)
end

local function goldStroke(obj, thickness)
	local s = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = thickness }, obj)
	new("UIGradient", { Color = GOLD_GRADIENT, Rotation = 90 }, s)
	return s
end

local function goldText(label)
	new("UIGradient", { Color = GOLD_GRADIENT, Rotation = 90 }, label)
end

local function makeDraggable(handle, target)
	local dragging, dragStart, startPos
	handle.Active = true
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local gui = new("ScreenGui", {
	Name = "goldahub",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
}, player:WaitForChild("PlayerGui"))

local topBar = new("Frame", {
	Name = "TopBar",
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromOffset(320, 34),
	Position = UDim2.new(0.5, 0, 0, 10),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
}, gui)
round(topBar, 17)
goldStroke(topBar, 1.5)

local topName = new("TextLabel", {
	Size = UDim2.new(0, 84, 1, 0),
	Position = UDim2.new(0, 16, 0, 0),
	BackgroundTransparency = 1,
	Text = "GoldHub",
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBlack,
	TextSize = 17,
	TextXAlignment = Enum.TextXAlignment.Left,
}, topBar)
goldText(topName)

new("TextLabel", {
	Size = UDim2.new(0, 24, 1, 0),
	Position = UDim2.new(0, 98, 0, 0),
	BackgroundTransparency = 1,
	Text = ICON,
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	TextColor3 = C.text,
}, topBar)

new("Frame", {
	Size = UDim2.new(0, 1, 0, 16),
	Position = UDim2.new(0, 128, 0.5, -8),
	BackgroundColor3 = C.line,
	BorderSizePixel = 0,
}, topBar)

local statsLabel = new("TextLabel", {
	Size = UDim2.new(1, -146, 1, 0),
	Position = UDim2.new(0, 138, 0, 0),
	BackgroundTransparency = 1,
	RichText = true,
	Text = "FPS --   PING --",
	TextColor3 = C.muted,
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
}, topBar)

makeDraggable(topBar, topBar)

local function fpsColor(fps)
	if fps >= 50 then return C.good end
	if fps >= 30 then return C.warn end
	return C.bad
end

local function pingColor(ping)
	if ping <= 80 then return C.good end
	if ping <= 150 then return C.warn end
	return C.bad
end

local frames = 0
local lastTick = os.clock()

RunService.RenderStepped:Connect(function()
	frames += 1
	local now = os.clock()
	local elapsed = now - lastTick
	if elapsed < 0.5 then return end

	local fps = math.floor(frames / elapsed + 0.5)
	frames = 0
	lastTick = now

	local ping = 0
	local ok, value = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and value then
		ping = math.floor(value + 0.5)
	end

	local muted = "#" .. C.muted:ToHex()
	statsLabel.Text = string.format(
		'<font color="%s">FPS</font> <font color="#%s">%d</font>    <font color="%s">PING</font> <font color="#%s">%d</font><font color="%s">ms</font>',
		muted, fpsColor(fps):ToHex(), fps,
		muted, pingColor(ping):ToHex(), ping, muted
	)
end)

local main = new("Frame", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(400, 240),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	BackgroundColor3 = C.bg,
	BorderSizePixel = 0,
	Visible = START_VISIBLE,
}, gui)
round(main, 10)
goldStroke(main, 1.5)

local scale = new("UIScale", { Scale = START_VISIBLE and 1 or 0.9 }, main)
local menuOpen = START_VISIBLE

local function setMenu(open)
	menuOpen = open
	if open then
		main.Visible = true
		TweenService:Create(
			scale,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	else
		local tween = TweenService:Create(
			scale,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Scale = 0.9 }
		)
		tween:Play()
		tween.Completed:Connect(function()
			if not menuOpen then
				main.Visible = false
			end
		end)
	end
end

local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundTransparency = 1,
}, main)

local title = new("TextLabel", {
	Size = UDim2.new(0, 160, 1, 0),
	Position = UDim2.new(0, 16, 0, 0),
	BackgroundTransparency = 1,
	Text = "GoldHub",
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBlack,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
}, header)
goldText(title)

new("TextLabel", {
	Size = UDim2.new(0, 40, 1, 0),
	Position = UDim2.new(1, -54, 0, 0),
	BackgroundTransparency = 1,
	Text = "v4",
	TextColor3 = C.muted,
	Font = Enum.Font.Code,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Right,
}, header)

makeDraggable(header, main)

new("Frame", {
	Size = UDim2.new(1, -24, 0, 1),
	Position = UDim2.new(0, 12, 0, 40),
	BackgroundColor3 = C.line,
	BorderSizePixel = 0,
}, main)

local sidebar = new("Frame", {
	Size = UDim2.new(0, 112, 1, -54),
	Position = UDim2.new(0, 8, 0, 46),
	BackgroundColor3 = C.side,
	BorderSizePixel = 0,
}, main)
round(sidebar, 8)

local content = new("Frame", {
	Size = UDim2.new(1, -134, 1, -54),
	Position = UDim2.new(0, 126, 0, 46),
	BackgroundTransparency = 1,
}, main)

new("TextLabel", {
	Size = UDim2.new(1, -4, 0, 16),
	Position = UDim2.new(0, 4, 1, -16),
	BackgroundTransparency = 1,
	Text = "G - свернуть меню",
	TextColor3 = C.muted,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local tabs = {}

local function selectTab(name)
	for tabName, tab in pairs(tabs) do
		local active = tabName == name
		tab.page.Visible = active
		tab.indicator.Visible = active
		tab.button.BackgroundTransparency = active and 0 or 1
		tab.button.TextColor3 = active and C.goldLight or C.muted
	end
end

local function addTab(name, index)
	local button = new("TextButton", {
		Size = UDim2.new(1, -12, 0, 32),
		Position = UDim2.new(0, 6, 0, 8 + (index - 1) * 36),
		BackgroundColor3 = C.row,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = C.muted,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
	}, sidebar)
	round(button, 6)
	new("UIPadding", { PaddingLeft = UDim.new(0, 14) }, button)

	local indicator = new("Frame", {
		Size = UDim2.new(0, 3, 0, 14),
		Position = UDim2.new(0, -10, 0.5, -7),
		BackgroundColor3 = C.gold,
		BorderSizePixel = 0,
		Visible = false,
	}, button)
	round(indicator, 2)

	local page = new("Frame", {
		Size = UDim2.new(1, 0, 1, -20),
		BackgroundTransparency = 1,
		Visible = false,
	}, content)

	tabs[name] = { button = button, indicator = indicator, page = page }
	button.MouseButton1Click:Connect(function()
		selectTab(name)
	end)
	return page
end

local function makeRow(page, index, titleText, descText, onChange)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		Position = UDim2.new(0, 0, 0, 4 + (index - 1) * 58),
		BackgroundColor3 = C.row,
		BorderSizePixel = 0,
	}, page)
	round(row, 6)
	new("UIStroke", { Color = C.line, Thickness = 1 }, row)

	new("TextLabel", {
		Size = UDim2.new(1, -70, 0, 18),
		Position = UDim2.new(0, 14, 0, 8),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = C.text,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	new("TextLabel", {
		Size = UDim2.new(1, -70, 0, 16),
		Position = UDim2.new(0, 14, 0, 27),
		BackgroundTransparency = 1,
		Text = descText,
		TextColor3 = C.muted,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local track = new("Frame", {
		Size = UDim2.fromOffset(38, 20),
		Position = UDim2.new(1, -52, 0.5, -10),
		BackgroundColor3 = C.off,
		BorderSizePixel = 0,
	}, row)
	round(track, 10)

	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 3, 0.5, -7),
		BackgroundColor3 = C.muted,
		BorderSizePixel = 0,
	}, track)
	round(knob, 7)

	local click = new("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 2,
	}, row)

	local state = false
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function set(value)
		state = value
		TweenService:Create(track, info, {
			BackgroundColor3 = value and C.gold or C.off,
		}):Play()
		TweenService:Create(knob, info, {
			Position = value and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
			BackgroundColor3 = value and C.bg or C.muted,
		}):Play()
	end

	click.MouseButton1Click:Connect(function()
		local target = not state
		local result = onChange(target)
		if target and result == false then
			target = false
		end
		set(target)
	end)

	return { set = set }
end

local movementPage = addTab("Movement", 1)
local teleportPage = addTab("Teleport", 2)

local noclipConn

local function setNoclip(on)
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end

	if on then
		noclipConn = RunService.Stepped:Connect(function()
			local char = player.Character
			if not char then return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end

local flySwitch
local bv, bg, flyConn

local function stopFly()
	if flyConn then flyConn:Disconnect() flyConn = nil end
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
	if flySwitch then flySwitch.set(false) end
end

local function startFly()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return false end

	hum.PlatformStand = true

	bv = new("BodyVelocity", {
		MaxForce = Vector3.new(1e9, 1e9, 1e9),
		Velocity = Vector3.zero,
	}, root)

	bg = new("BodyGyro", {
		MaxTorque = Vector3.new(1e9, 1e9, 1e9),
		P = 1e4,
		CFrame = root.CFrame,
	}, root)

	flyConn = RunService.RenderStepped:Connect(function()
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end

		bv.Velocity = dir.Magnitude > 0 and dir.Unit * FLY_SPEED or Vector3.zero
		bg.CFrame = cam.CFrame
	end)

	return true
end

makeRow(movementPage, 1, "Noclip", "ебаный ноуклип", setNoclip)

flySwitch = makeRow(movementPage, 2, "Fly", "Ну это бля палет", function(on)
	if on then
		return startFly()
	end
	stopFly()
end)

local clickTp = false

makeRow(teleportPage, 1, "Click TP", "какой далбаеб это не знает", function(on)
	clickTp = on
end)

selectTab("Movement")

local function teleportToMouse()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera
	if not root or not cam then return end

	local mousePos = UIS:GetMouseLocation()
	local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	if result then
		root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
	end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == TOGGLE_KEY then
		setMenu(not menuOpen)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and clickTp then
		teleportToMouse()
	end
end)

player.CharacterAdded:Connect(function()
	stopFly()
end)
