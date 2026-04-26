-- LocalScript: ESP completo + FIX respawn + players novos + otimizado

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CAMERA = Workspace.CurrentCamera

-- CONFIG
local MAX_DISTANCE = 250
local VISIBLE_COLOR = Color3.fromRGB(0, 200, 0)
local HIDDEN_COLOR  = Color3.fromRGB(220, 40, 40)
local LERP_SPEED    = 6
local VIS_CHECK_DT  = 0.25

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 110, 0, 36)
ToggleButton.Position = UDim2.new(0, 15, 0, 15)
ToggleButton.BackgroundColor3 = Color3.fromRGB(28,28,28)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Text = "ESP: ON"
ToggleButton.Parent = ScreenGui

local PlusButton = Instance.new("TextButton")
PlusButton.Size = UDim2.new(0, 50, 0, 36)
PlusButton.Position = UDim2.new(0, 130, 0, 15)
PlusButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
PlusButton.TextColor3 = Color3.fromRGB(0,255,0)
PlusButton.Font = Enum.Font.GothamBold
PlusButton.TextSize = 18
PlusButton.Text = "+"
PlusButton.Parent = ScreenGui

local MinusButton = Instance.new("TextButton")
MinusButton.Size = UDim2.new(0, 50, 0, 36)
MinusButton.Position = UDim2.new(0, 185, 0, 15)
MinusButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinusButton.TextColor3 = Color3.fromRGB(255,80,80)
MinusButton.Font = Enum.Font.GothamBold
MinusButton.TextSize = 18
MinusButton.Text = "-"
MinusButton.Parent = ScreenGui

local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(0, 150, 0, 25)
DistanceLabel.Position = UDim2.new(0, 15, 0, 55)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.TextColor3 = Color3.new(1,1,1)
DistanceLabel.Font = Enum.Font.Gotham
DistanceLabel.TextSize = 14
DistanceLabel.Text = "Distância: " .. MAX_DISTANCE
DistanceLabel.Parent = ScreenGui

local ESPEnabled = true

ToggleButton.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	ToggleButton.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
end)

PlusButton.MouseButton1Click:Connect(function()
	MAX_DISTANCE += 50
	DistanceLabel.Text = "Distância: " .. MAX_DISTANCE
end)

MinusButton.MouseButton1Click:Connect(function()
	MAX_DISTANCE = math.max(50, MAX_DISTANCE - 50)
	DistanceLabel.Text = "Distância: " .. MAX_DISTANCE
end)

local espData = {}

-- CRIAR ESP (FIX PRINCIPAL)
local function createESP(player, char)
	if player == LocalPlayer then return end

	local head = char:WaitForChild("Head", 3)
	if not head then return end

	-- REMOVE ESP ANTIGO
	if espData[player] then
		local old = espData[player]
		if old.highlight then old.highlight:Destroy() end
		if old.billboard then old.billboard:Destroy() end
		espData[player] = nil
	end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = char
	highlight.FillTransparency = 0.6
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = VISIBLE_COLOR
	highlight.Parent = char

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 140, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.8, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1,0,1,0)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = Color3.new(1,1,1)
	text.RichText = true
	text.Parent = billboard

	espData[player] = {
		highlight = highlight,
		billboard = billboard,
		label = text,
		visible = true,
		timer = 0
	}
end

-- RAYCAST
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local function isVisible(char)
	local head = char:FindFirstChild("Head")
	if not head then return false end

	local origin = CAMERA.CFrame.Position
	local direction = (head.Position - origin)

	rayParams.FilterDescendantsInstances = {LocalPlayer.Character}

	local result = Workspace:Raycast(origin, direction, rayParams)

	return result and result.Instance and result.Instance:IsDescendantOf(char)
end

-- SETUP PLAYER (FIX NOVOS PLAYERS)
local function setupPlayer(p)

	p.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		createESP(p, char)
	end)

	if p.Character then
		createESP(p, p.Character)
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	setupPlayer(p)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(p)
	if espData[p] then
		espData[p].highlight:Destroy()
		espData[p].billboard:Destroy()
		espData[p] = nil
	end
end)

-- LOOP
RunService.RenderStepped:Connect(function(dt)
	CAMERA = Workspace.CurrentCamera

	for player, data in pairs(espData) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if not char or not hrp then continue end

		local dist = (hrp.Position - CAMERA.CFrame.Position).Magnitude

		if dist > MAX_DISTANCE then
			data.highlight.Enabled = false
			data.billboard.Enabled = false
			continue
		end

		data.highlight.Enabled = ESPEnabled
		data.billboard.Enabled = ESPEnabled

		local hum = char:FindFirstChildOfClass("Humanoid")
		local tool = char:FindFirstChildOfClass("Tool")

		if hum then
			data.label.Text = string.format(
				"<b>%s</b>\n<font color='rgb(0,255,0)'>HP: %d</font>\n<font color='rgb(200,200,200)'>%s</font>",
				player.Name,
				math.floor(hum.Health),
				tool and tool.Name or "Sem arma"
			)
		end

		data.timer += dt
		if data.timer >= VIS_CHECK_DT then
			data.timer = 0
			data.visible = isVisible(char)
		end

		local target = data.visible and VISIBLE_COLOR or HIDDEN_COLOR
		data.highlight.FillColor = data.highlight.FillColor:Lerp(target, dt * LERP_SPEED)
	end
end)
