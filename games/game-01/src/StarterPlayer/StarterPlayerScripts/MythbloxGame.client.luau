-- Mythblox Game 01 · Soft Earth Coast mobile UI v0.22
-- Presentation only. The server still owns votes, movement, cracks, winners and coins.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local BUILD_VERSION = "v0.22"
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local network = ReplicatedStorage:WaitForChild("MythbloxGame01")
local command = network:WaitForChild("Command")
local stateEvent = network:WaitForChild("State")
local shopEvent = network:WaitForChild("Shop")
local remoteBuild = network:WaitForChild("BuildVersion", 5)
if not remoteBuild or remoteBuild.Value ~= BUILD_VERSION then
	warn("[Mythblox] Client " .. BUILD_VERSION .. " does not match server version; old scripts may still be running.")
end
print("[Mythblox] CLIENT RUNNING " .. BUILD_VERSION)

-- Remove all previous copies (not just the first) of this game's GUI.
for _, child in ipairs(playerGui:GetChildren()) do
	if child.Name == "MythbloxGame01UI" and child:IsA("ScreenGui") then
		child:Destroy()
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "MythbloxGame01UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 10
gui.Parent = playerGui
-- If a legacy LocalScript creates an older copy later, remove only that copy.
playerGui.ChildAdded:Connect(function(child)
	if child ~= gui and child.Name == "MythbloxGame01UI" and child:IsA("ScreenGui") then
		warn("[Mythblox] Removed duplicate UI from another script: " .. child:GetFullName())
		child:Destroy()
	end
end)

-- Soft Earth Coast UI: warm cream/oat, muted sage and dusty rose.
-- Only functional SAFE/BLOCKED indicators use a readable green/red.
local COLOR = {
	Ink = Color3.fromRGB(239, 230, 214),      -- warm cream
	InkBright = Color3.fromRGB(217, 200, 174),-- oat beige
	Text = Color3.fromRGB(110, 90, 75),       -- soft brown
	Muted = Color3.fromRGB(127, 110, 95),
	Blue = Color3.fromRGB(145, 160, 136),     -- sage vote button
	Green = Color3.fromRGB(90, 144, 106),     -- safe result
	Red = Color3.fromRGB(176, 103, 99),       -- blocked result
	Gold = Color3.fromRGB(185, 137, 115),     -- terracotta selection
	Purple = Color3.fromRGB(110, 90, 75),     -- brown phase heading
	Border = Color3.fromRGB(191, 167, 144),
	White = Color3.fromRGB(250, 244, 233),    -- legible on sage/dusty rose
}

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or COLOR.Border
	stroke.Thickness = thickness or 1
	stroke.Transparency = 0.25
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function panel(name)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = COLOR.Ink
	frame.BackgroundTransparency = 0.07
	frame.BorderSizePixel = 0
	frame.Parent = gui
	addCorner(frame, 13)
	addStroke(frame, COLOR.Border, 1)
	-- A soft vertical color grade adds depth without relying on a texture ID.
	local gradient = Instance.new("UIGradient")
	gradient.Name = "SoftEarthOatCard"
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 247, 239)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(239, 228, 209)),
	})
	gradient.Rotation = 90
	gradient.Parent = frame
	return frame
end

local function label(parent, name, content, x, y, w, h, size, color, bold)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Text = content
	l.Position = UDim2.new(0, x, 0, y)
	l.Size = UDim2.new(1, w, 0, h)
	l.BackgroundTransparency = 1
	l.BorderSizePixel = 0
	l.TextColor3 = color or COLOR.Text
	l.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
	l.TextSize = size or 15
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.Parent = parent
	return l
end

-- Short, low-volume classic Roblox cues. The game stays playable if an
-- audio file is unavailable or the player has muted sound.
local soundIds = {
	pick = "rbxasset://sounds/switch.wav",
	tick = "rbxasset://sounds/electronicpingshort.mp3",
	safe = "rbxasset://sounds/electronicpingshort.mp3",
	crack = "rbxasset://sounds/snap.mp3",
	fall = "rbxasset://sounds/collide.mp3",
	win = "rbxasset://sounds/electronicpingshort.mp3",
}
local sounds = {}
for kind, asset in pairs(soundIds) do
	local audio = Instance.new("Sound")
	audio.Name = "GlassRace_" .. kind
	audio.SoundId = asset
	audio.Volume = kind == "fall" and 0.36 or (kind == "tick" and 0.13 or 0.22)
	audio.PlaybackSpeed = kind == "safe" and 1.35 or (kind == "tick" and 1.15 or (kind == "win" and 0.85 or 1))
	audio.Parent = SoundService
	sounds[kind] = audio
end
gui.Destroying:Connect(function()
	for _, audio in pairs(sounds) do audio:Destroy() end
end)
local function cue(kind)
	local audio = sounds[kind]
	if not audio then return end
	audio.TimePosition = 0
	audio:Play()
end

local function button(parent, name, content, bg)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = content
	b.TextColor3 = COLOR.White
	b.Font = Enum.Font.GothamBold
	b.TextSize = 23
	b.BackgroundColor3 = bg or COLOR.Blue
	b.BorderSizePixel = 0
	b.AutoButtonColor = true
	b.Parent = parent
	addCorner(b, 11)
	addStroke(b, COLOR.White, 1)
	return b
end

-- Compact phase/countdown HUD with personal progress and no leaderboard.
local top = panel("StatusPanel")
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 8)
local phaseText = label(top, "Phase", "NEXT MATCH", 14, 6, -112, 22, 15, COLOR.Purple, true)
local clockText = label(top, "Clock", "10s", 14, 6, -28, 23, 19, COLOR.Purple, true)
clockText.TextXAlignment = Enum.TextXAlignment.Right
local description = label(top, "Guidance", "", 14, 29, -28, 21, 13, COLOR.Text, false)
local ownStats = label(top, "Progress", "", 14, 53, -28, 19, 12, COLOR.Muted, true)
-- Compact phone view keeps wins and coins in one tiny right-hand chip;
-- the actual match instructions stay in the private vote/reveal controls.
local currencyChip = label(top, "WinsAndCoins", "", 0, 0, 0, 18, 11, COLOR.Text, true)
currencyChip.TextXAlignment = Enum.TextXAlignment.Right
currencyChip.Visible = false
local progressBackground = Instance.new("Frame")
progressBackground.Name = "ProgressTrack"
progressBackground.Position = UDim2.new(0, 14, 1, -7)
progressBackground.Size = UDim2.new(1, -28, 0, 4)
progressBackground.BorderSizePixel = 0
progressBackground.BackgroundColor3 = COLOR.InkBright
progressBackground.Parent = top
addCorner(progressBackground, 4)
local progressFill = Instance.new("Frame")
progressFill.Name = "ProgressFill"
progressFill.Size = UDim2.fromScale(0, 1)
progressFill.BackgroundColor3 = COLOR.Blue
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBackground
addCorner(progressFill, 4)

-- Leaderboard lives in the world near spawn, not as a duplicate HUD overlay.

-- Brief nonmodal feedback chip below the compact HUD. Hidden on small screens
-- to keep the play view, controls and two-second vote reveal unobstructed.
local feedback = panel("FeedbackChip")
feedback.AnchorPoint = Vector2.new(0.5, 0)
feedback.Position = UDim2.new(0.5, 0, 0, 98)
feedback.Size = UDim2.fromOffset(334, 42)
feedback.BackgroundTransparency = 0.02
feedback.Visible = false
local feedbackText = label(feedback, "FeedbackText", "", 11, 4, -22, 33, 15, COLOR.Text, true)
feedbackText.TextXAlignment = Enum.TextXAlignment.Center
local feedbackGeneration = 0
local isCompact = false
local function showFeedback(message, isGood)
	if isCompact then return end
	feedbackGeneration += 1
	local generation = feedbackGeneration
	feedback.BackgroundColor3 = isGood and Color3.fromRGB(221, 230, 213) or Color3.fromRGB(239, 208, 203)
	feedbackText.TextColor3 = isGood and COLOR.Green or COLOR.Red
	feedbackText.Text = message
	feedback.Visible = true
	feedback.BackgroundTransparency = 0.02
	feedbackText.TextTransparency = 0
	task.delay(1.05, function()
		if generation ~= feedbackGeneration or not feedback.Parent then return end
		TweenService:Create(feedback, TweenInfo.new(0.22), {BackgroundTransparency = 1}):Play()
		TweenService:Create(feedbackText, TweenInfo.new(0.22), {TextTransparency = 1}):Play()
		task.delay(0.24, function()
			if generation == feedbackGeneration and feedback.Parent then feedback.Visible = false end
		end)
	end)
end

-- Join prompt: does not cover touch movement controls during a match.
local join = button(gui, "JoinButton", "JOIN BRIDGE RACE", COLOR.Blue)
join.AnchorPoint = Vector2.new(0.5, 1)
join.TextSize = 21
join.MouseButton1Click:Connect(function()
	command:FireServer("Join")
	join.Visible = false
end)

-- Selection tray: five consistently sized targets, regardless of player count.
local voting = panel("VotePanel")
voting.AnchorPoint = Vector2.new(0.5, 1)
local voteTitle = label(voting, "VoteTitle", "PICK YOUR STEPS  ·  1–5", 14, 7, -28, 25, 18, COLOR.Text, true)
local voteHint = label(voting, "VoteHint", "Most-picked numbers crack. Select before time runs out.", 14, 34, -28, 24, 13, COLOR.Muted)
local choiceRow = Instance.new("Frame")
choiceRow.Name = "Choices"
choiceRow.BackgroundTransparency = 1
choiceRow.Position = UDim2.new(0, 12, 0, 65)
choiceRow.Size = UDim2.new(1, -24, 0, 63)
choiceRow.Parent = voting
local chooseLayout = Instance.new("UIListLayout")
chooseLayout.FillDirection = Enum.FillDirection.Horizontal
chooseLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
chooseLayout.VerticalAlignment = Enum.VerticalAlignment.Center
chooseLayout.SortOrder = Enum.SortOrder.LayoutOrder
chooseLayout.Padding = UDim.new(0.012, 0)
chooseLayout.Parent = choiceRow

local choiceButtons = {}
for n = 1, 5 do
	local number = n
	local b = button(choiceRow, "Choice" .. n, tostring(n), COLOR.Blue)
	b.LayoutOrder = n
	b.Size = UDim2.new(0.19, 0, 0, 61)
	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = b
	b.MouseButton1Click:Connect(function()
		cue("pick")
		scale.Scale = 1.06
		TweenService:Create(scale, TweenInfo.new(0.14), {Scale = 1}):Play()
		command:FireServer("Vote", number)
		for chosen, other in ipairs(choiceButtons) do
			other.BackgroundColor3 = chosen == number and COLOR.Gold or COLOR.Blue
			other.TextColor3 = chosen == number and COLOR.Text or COLOR.White
		end
		voteHint.Text = "Choice " .. number .. " selected · you can change it before time ends"
	end)
	choiceButtons[n] = b
end

-- The large bottom GO/STAY banner was redundant with the bridge colors and
-- compact top status. Removing it keeps the arena and touch controls clear.

-- Results appear in the compact top status strip instead of a centered
-- modal. The arena and other players remain visible when a match ends.

-- v0.22: Secret selections are never displayed to others while voting.
-- ONLY during the five-second REVEAL do five non-clickable results cards
-- show every numbered choice, picking players' avatars, totals, and safety.
-- The existing teal voting buttons remain PRIVATE selection controls.
local reveal = panel("RevealPanel")
reveal.AnchorPoint = Vector2.new(0.5, 0)
reveal.Position = UDim2.new(0.5, 0, 0, 103)
reveal.Visible = false

local revealHeader = label(reveal, "Heading", "VOTES REVEALED", 13, 7, -26, 27, 19, COLOR.Purple, true)
revealHeader.TextXAlignment = Enum.TextXAlignment.Center
local revealSubtitle = label(reveal, "Legend", "GREEN = SAFE      RED = BLOCKED", 13, 34, -26, 20, 13, COLOR.Muted, true)
revealSubtitle.TextXAlignment = Enum.TextXAlignment.Center

local resultRow = Instance.new("Frame")
resultRow.Name = "LockedNumberResults"
resultRow.Position = UDim2.new(0, 10, 0, 60)
resultRow.Size = UDim2.new(1, -20, 1, -72)
resultRow.BackgroundTransparency = 1
resultRow.Parent = reveal
local resultLayout = Instance.new("UIListLayout")
resultLayout.FillDirection = Enum.FillDirection.Horizontal
resultLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
resultLayout.VerticalAlignment = Enum.VerticalAlignment.Center
resultLayout.SortOrder = Enum.SortOrder.LayoutOrder
resultLayout.Padding = UDim.new(0.012, 0)
resultLayout.Parent = resultRow

local resultCards = {}
for number = 1, 5 do
	local card = Instance.new("Frame") -- Not a button: voting is locked during REVEAL.
	card.Name = "NumberResult_" .. number
	card.LayoutOrder = number
	card.Size = UDim2.new(0.19, 0, 1, 0)
	card.BackgroundColor3 = Color3.fromRGB(222, 231, 215)
	card.BorderSizePixel = 0
	card.Parent = resultRow
	addCorner(card, 10)
	local outline = addStroke(card, COLOR.Green, 2)

	local avatarBox = Instance.new("Frame")
	avatarBox.Name = "Voters"
	avatarBox.BackgroundTransparency = 1
	avatarBox.Position = UDim2.new(0, 4, 0, 7)
	avatarBox.Size = UDim2.new(1, -8, 0, 55)
	avatarBox.Parent = card
	local grid = Instance.new("UIGridLayout")
	grid.Name = "AvatarGrid"
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.FillDirection = Enum.FillDirection.Horizontal
	grid.FillDirectionMaxCells = 4
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.VerticalAlignment = Enum.VerticalAlignment.Center
	grid.CellSize = UDim2.fromOffset(24, 24)
	grid.CellPadding = UDim2.fromOffset(2, 2)
	grid.Parent = avatarBox

	local numberLabel = label(card, "Number", tostring(number), 0, 62, 0, 42, 38, COLOR.Green, true)
	numberLabel.TextXAlignment = Enum.TextXAlignment.Center
	local votesLabel = label(card, "Picks", "0 PICKS", 0, 108, 0, 23, 13, COLOR.Text, true)
	votesLabel.TextXAlignment = Enum.TextXAlignment.Center
	local status = label(card, "Status", "SAFE", 0, 135, 0, 20, 12, COLOR.Green, true)
	status.TextXAlignment = Enum.TextXAlignment.Center

	resultCards[number] = {
		frame = card, outline = outline, avatars = avatarBox,
		grid = grid, number = numberLabel, votes = votesLabel, status = status,
	}
end

local lastTurnRendered = -1
local function drawOutcomes(state)
	-- Explicit guard: cannot show aggregate data while voting or moving.
	if state.phase ~= "REVEAL" then return end
	if lastTurnRendered == state.turn then return end
	lastTurnRendered = state.turn

	local chosenByNumber = {{}, {}, {}, {}, {}}
	for _, entry in ipairs(state.voteOutcomes or {}) do
		local n = entry.number
		local userId = entry.userId
		if type(n) == "number" and n % 1 == 0 and n >= 1 and n <= 5
			and type(userId) == "number" then
			table.insert(chosenByNumber[n], userId)
		end
	end

	for number = 1, 5 do
		local card = resultCards[number]
		local blocked = state.unsafe and state.unsafe[number] == true
		local ids = chosenByNumber[number]
		local total = (state.voteCounts and state.voteCounts[number]) or #ids

		card.frame.BackgroundColor3 = blocked
			and Color3.fromRGB(236, 206, 199) or Color3.fromRGB(213, 226, 207)
		card.outline.Color = blocked and COLOR.Red or COLOR.Green
		card.number.TextColor3 = blocked and COLOR.Red or COLOR.Green
		card.status.TextColor3 = blocked and COLOR.Red or COLOR.Green
		card.status.Text = blocked and "BLOCKED" or "SAFE"
		card.votes.Text = tostring(total) .. (total == 1 and " PICK" or " PICKS")

		for _, child in ipairs(card.avatars:GetChildren()) do
			if child:IsA("ImageLabel") then child:Destroy() end
		end
		table.sort(ids)
		for i, userId in ipairs(ids) do
			local avatar = Instance.new("ImageLabel")
			avatar.Name = "Voter_" .. tostring(userId)
			avatar.LayoutOrder = i
			avatar.Size = UDim2.fromOffset(24, 24)
			avatar.BackgroundColor3 = COLOR.White
			avatar.BorderSizePixel = 0
			avatar.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(userId)
			avatar.ScaleType = Enum.ScaleType.Crop
			avatar.Parent = card.avatars
			addCorner(avatar, 99)
			addStroke(avatar, userId == player.UserId and COLOR.Gold or COLOR.Border,
				userId == player.UserId and 2 or 1)
		end
	end
end

-- Shop opens ONLY when interacting with the cosmetics stall. No new
-- always-visible shop HUD button, and no purchases from the client's prices.
local shop = panel("CosmeticsShop")
shop.AnchorPoint = Vector2.new(1, 0.5)
shop.Position = UDim2.new(1, -18, 0.54, 0)
shop.Size = UDim2.fromOffset(350, 358)
shop.Visible = false

local shopTitle = label(shop, "Title", "GLASS COLORS", 15, 10, -68, 31, 19, COLOR.Purple, true)
local shopCoins = label(shop, "Balance", "0 COINS", 15, 46, -32, 25, 14, COLOR.Muted, true)
local closeShop = button(shop, "Close", "X", COLOR.Red)
closeShop.AnchorPoint = Vector2.new(1, 0)
closeShop.Position = UDim2.new(1, -12, 0, 11)
closeShop.Size = UDim2.fromOffset(34, 32)
closeShop.TextSize = 15
closeShop.MouseButton1Click:Connect(function()
	shop.Visible = false
end)
local shopList = Instance.new("ScrollingFrame")
shopList.Name = "Items"
shopList.BackgroundTransparency = 1
shopList.BorderSizePixel = 0
shopList.ScrollingDirection = Enum.ScrollingDirection.Y
shopList.ScrollBarThickness = 4
shopList.CanvasSize = UDim2.fromOffset(0, 230)
shopList.Position = UDim2.fromOffset(12, 82)
shopList.Size = UDim2.new(1, -24, 1, -124)
shopList.Parent = shop
local shopLayout = Instance.new("UIListLayout")
shopLayout.FillDirection = Enum.FillDirection.Vertical
shopLayout.SortOrder = Enum.SortOrder.LayoutOrder
shopLayout.Padding = UDim.new(0, 5)
shopLayout.Parent = shopList
local shopFeedback = label(shop, "Feedback", "", 12, 0, -24, 30, 12, COLOR.Muted, true)
shopFeedback.AnchorPoint = Vector2.new(0, 1)
shopFeedback.Position = UDim2.new(0, 12, 1, -5)
shopFeedback.TextXAlignment = Enum.TextXAlignment.Center

local function renderShop(info, response)
	if type(info) ~= "table" or type(info.items) ~= "table" then return end
	shopCoins.Text = tostring(info.coins or 0) .. " COINS"
	shopFeedback.Text = response or ""
	shopFeedback.TextColor3 = COLOR.Muted
	for _, child in ipairs(shopList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	shopList.CanvasSize = UDim2.fromOffset(0, #info.items * 56)
	for index, item in ipairs(info.items) do
		if type(item) == "table" and type(item.id) == "string" then
			local row = Instance.new("Frame")
			row.Name = "Skin_" .. item.id
			row.LayoutOrder = index
			row.Size = UDim2.new(1, 0, 0, 51)
			row.BackgroundColor3 = COLOR.InkBright
			row.BorderSizePixel = 0
			row.Parent = shopList
			addCorner(row, 9)

			local swatch = Instance.new("Frame")
			swatch.Name = "Color"
			swatch.Size = UDim2.fromOffset(30, 30)
			swatch.Position = UDim2.fromOffset(10, 10)
			swatch.BackgroundColor3 = typeof(item.color) == "Color3" and item.color or COLOR.Blue
			swatch.BorderSizePixel = 0
			swatch.Parent = row
			addCorner(swatch, 7)
			addStroke(swatch, COLOR.Border, 1)

			local skinName = label(row, "Name", tostring(item.title or item.id), 49, 8, -161, 36, 14, COLOR.Text, true)
			skinName.TextWrapped = false
			skinName.TextTruncate = Enum.TextTruncate.AtEnd
			local action = button(row, "Action", "", COLOR.Blue)
			action.AnchorPoint = Vector2.new(1, 0.5)
			action.Position = UDim2.new(1, -9, 0.5, 0)
			action.Size = UDim2.fromOffset(102, 33)
			action.TextSize = 12
			local owns = item.id == "classic" or (info.owned and info.owned[item.id] == true)
			local equipped = info.equipped == item.id
			if not info.ready then
				action.Text = "UNAVAILABLE"
				action.Active = false
				action.AutoButtonColor = false
				action.BackgroundColor3 = COLOR.Muted
			elseif equipped then
				action.Text = "EQUIPPED"
				action.Active = false
				action.AutoButtonColor = false
				action.BackgroundColor3 = COLOR.Green
			else
				action.Text = owns and "EQUIP" or (tostring(item.price or 0) .. " COINS")
				action.BackgroundColor3 = owns and COLOR.Green or COLOR.Blue
				action.MouseButton1Click:Connect(function()
					action.Text = "..."
					action.Active = false
					command:FireServer("Shop", item.id)
				end)
			end
		end
	end
end

shopEvent.OnClientEvent:Connect(function(kind, details, message)
	if kind == "Open" then shop.Visible = true end
	if shop.Visible and (kind == "Open" or kind == "Update") then
		renderShop(details, message)
	end
end)

local function layoutForViewport()
	local cam = workspace.CurrentCamera
	local view = cam and cam.ViewportSize or Vector2.new(1100, 700)
	local width = math.max(300, view.X)
	local height = math.max(320, view.Y)
	local compact = width < 760
	isCompact = compact
	if compact then feedback.Visible = false end
	local shortScreen = height < 570

	local topW = math.min(width - 20, compact and 410 or 470)
	top.Size = UDim2.fromOffset(topW, 83)
	phaseText.Size = UDim2.new(1, -107, 0, 23)
	phaseText.TextSize = compact and 13 or 15
	clockText.Position = UDim2.new(1, -82, 0, 6)
	clockText.Size = UDim2.fromOffset(68, 23)
	description.Position = UDim2.fromOffset(14, 30)
	description.Size = UDim2.new(1, -28, 0, 20)
	description.TextSize = compact and 12 or 13
	ownStats.Position = UDim2.fromOffset(14, 53)
	ownStats.Size = UDim2.new(1, -28, 0, 18)
	ownStats.TextSize = compact and 11 or 12

	local voteW = math.min(width - 18, 535)
	voting.Size = UDim2.fromOffset(voteW, shortScreen and 121 or 140)
	voting.Position = UDim2.new(0.5, 0, 1, -18)
	voteTitle.TextSize = compact and 15 or 18
	voteHint.TextSize = compact and 11 or 13
	choiceRow.Position = UDim2.new(0, 12, 0, shortScreen and 57 or 66)
	choiceRow.Size = UDim2.new(1, -24, 0, shortScreen and 53 or 64)
	for _, b in ipairs(choiceButtons) do
		b.Size = UDim2.new(0.19, 0, 0, shortScreen and 50 or 61)
		b.TextSize = compact and 19 or 23
	end

	join.Size = UDim2.fromOffset(math.min(width - 28, 345), 58)
	join.Position = UDim2.new(0.5, 0, 1, -26)

	local shopW = math.min(width - 20, 350)
	shop.Size = UDim2.fromOffset(shopW, math.max(218, math.min(358, height - 118)))
	shop.AnchorPoint = compact and Vector2.new(0.5, 0.5) or Vector2.new(1, 0.5)
	shop.Position = compact and UDim2.new(0.5, 0, 0.56, 0) or UDim2.new(1, -18, 0.54, 0)

	-- A centered row of five result cards, shown for REVEAL only.
	local revealW = math.min(width - 16, compact and 580 or 780)
	local revealH = math.max(172, math.min(228, height - 110))
	reveal.Size = UDim2.fromOffset(revealW, revealH)
	reveal.Position = UDim2.new(0.5, 0, 0, 100)
	revealHeader.TextSize = compact and 16 or 19
	revealSubtitle.TextSize = compact and 11 or 13
	local cardHeight = revealH - 72
	local avatarHeight = math.min(55, math.max(39, cardHeight - 80))
	local approximateCardWidth = (revealW - 20) * 0.19
	local columns = approximateCardWidth < 90 and 3 or 4
	local rows = math.ceil(8 / columns)
	local avatarSize = math.max(11, math.min(24,
		math.floor((approximateCardWidth - 11 - (columns - 1) * 2) / columns),
		math.floor((avatarHeight - (rows - 1) * 2) / rows)))
	for _, card in ipairs(resultCards) do
		card.avatars.Size = UDim2.new(1, -8, 0, avatarHeight)
		card.grid.FillDirectionMaxCells = columns
		card.grid.CellSize = UDim2.fromOffset(avatarSize, avatarSize)
		card.number.Position = UDim2.new(0, 0, 0, 8 + avatarHeight)
		card.number.Size = UDim2.new(1, 0, 0, math.max(24, cardHeight - avatarHeight - 55))
		card.number.TextSize = compact and 29 or 39
		card.votes.Position = UDim2.new(0, 0, 1, -45)
		card.votes.TextSize = compact and 10 or 13
		card.status.Position = UDim2.new(0, 0, 1, -23)
		card.status.TextSize = compact and 10 or 12
	end
end

local function hookCamera(camera)
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutForViewport)
	end
	layoutForViewport()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	hookCamera(workspace.CurrentCamera)
end)
hookCamera(workspace.CurrentCamera)

local phaseNames = {
	JOIN = "NEXT MATCH",
	VOTE = "SECRET VOTE",
	REVEAL = "VOTE RESULTS",
	MOVE = "MOVE OR STAY",
	RESULTS = "RESULTS",
}

local previousPhase = nil
local previousTurn = -1
local previousAlive = nil
local lastTickKey = ""
local function update(state)
	local phase = state.phase or "JOIN"
	local mine = state.mine
	local changedPhase = phase ~= previousPhase or state.turn ~= previousTurn
	if phase == "VOTE" and mine and mine.alive and (state.time or 0) <= 3 and (state.time or 0) > 0 then
		local key = tostring(state.turn) .. ":" .. tostring(state.time)
		if lastTickKey ~= key then
			lastTickKey = key
			cue("tick")
		end
	end
	if changedPhase and phase == "REVEAL" and mine then
		if mine.alive and (mine.allowed or 0) > 0 then
			cue("safe")
			showFeedback("SAFE PICK · MOVE UP TO " .. mine.allowed .. " TILES", true)
		elseif mine.alive then
			cue("crack")
			showFeedback("BLOCKED PICK · " .. mine.cracks .. "/3 CRACKS", false)
		end
	elseif changedPhase and phase == "MOVE" and mine and mine.alive then
		if (mine.allowed or 0) > 0 then
			showFeedback("SAFE PICK · ADVANCE NOW", true)
		else
			showFeedback("BLOCKED PICK · DO NOT ADVANCE", false)
		end
	end
	if mine and previousAlive == true and not mine.alive then
		cue("fall")
		showFeedback("YOUR GLASS BROKE!", false)
	end
	if changedPhase and phase == "RESULTS"
		and type(state.message) == "string"
		and (string.find(state.message, "WINS!", 1, true) or string.find(state.message, "TIE!", 1, true)) then
		cue("win")
	end
	previousPhase = phase
	previousTurn = state.turn
	previousAlive = mine and mine.alive or nil
	-- Turn numbers restart every match; never reuse a previous match's vote rows.
	if phase == "JOIN" or phase == "VOTE" then
		lastTurnRendered = -1
	end
	phaseText.Text = ("v0.22 · ROUND %d · %s"):format(state.turn or 0, phaseNames[phase] or phase)
	clockText.Text = tostring(state.time or 0) .. "s"
	clockText.TextColor3 = phase == "VOTE" and (state.time or 0) <= 2 and COLOR.Red or COLOR.Purple
	description.Text = state.message or ""

	join.Visible = phase == "JOIN" and state.queued ~= true and (state.ready or 0) < (state.capacity or 8)
	voting.Visible = phase == "VOTE" and mine ~= nil and mine.alive == true
	if voting.Visible then shop.Visible = false end

	if phase == "JOIN" then
		phaseText.Text = "v0.22 · NEXT MATCH"
		description.Text = state.queued and "You're queued for the next race."
			or "Join at the gold pad or use the button below."
		ownStats.Text = ("%d/%d PLAYERS READY"):format(state.ready or 0, state.capacity or 8)
		progressFill.Size = UDim2.fromScale(0, 1)
	elseif mine then
		local selection = mine.vote and tostring(mine.vote) or "—"
		local marker = mine.alive and "" or "   ·   ELIMINATED"
		ownStats.Text = ("DISTANCE %d/20   ·   CRACKS %d/3   ·   PICK %s%s"):format(
			mine.position or 0, mine.cracks or 0, selection, marker
		)
		progressFill.Size = UDim2.fromScale(math.clamp((mine.position or 0) / 20, 0, 1), 1)
	else
		ownStats.Text = "SPECTATING  ·  WATCH FROM THE FRONT DECK"
		progressFill.Size = UDim2.fromScale(0, 1)
	end
	if phase == "RESULTS" then
		-- Server sends winner/draw text in state.message; show it only in
		-- the small status panel and avoid blocking the camera.
		phaseText.Text = "v0.22 · ROUND OVER"
		ownStats.Text = "NEXT MATCH STARTS SOON"
	end

	if voting.Visible and mine then
		local hurry = (state.time or 0) <= 2
		voteTitle.Text = hurry and ("CHOOSE NOW · " .. tostring(state.time) .. "s") or "PICK YOUR STEPS · 1–5"
		voteTitle.TextColor3 = hurry and COLOR.Red or COLOR.Text
		voting.BackgroundColor3 = hurry and Color3.fromRGB(231, 211, 191) or COLOR.Ink
		for n, b in ipairs(choiceButtons) do
			b.BackgroundColor3 = mine.vote == n and COLOR.Gold or COLOR.Blue
			b.TextColor3 = mine.vote == n and COLOR.Text or COLOR.White
		end
		voteHint.Text = mine.vote
			and ("Number " .. mine.vote .. " locked in · tap another to change")
			or "Most picked numbers crack · choose before time ends!"
	end

	-- Keep the essential permission in the compact HUD, not a separate banner.
	if phase == "MOVE" and mine and mine.alive then
		local allowed = mine.allowed or 0
		description.Text = allowed > 0 and ("GO · ADVANCE 1–%d PANELS"):format(allowed)
			or "NO ADVANCE · WAIT THIS TURN"
	end

	-- The five non-interactive number cards appear ONLY in the five-second reveal.
	-- Never show aggregates, avatars or the previous turn's choices in VOTE/MOVE.
	reveal.Visible = phase == "REVEAL"
	if reveal.Visible then
		-- The reveal is the only foreground feedback during these five seconds.
		-- Hide earlier vote chips and any open stall panel rather than overlap it.
		shop.Visible = false
		feedback.Visible = false
		feedbackGeneration += 1
		drawOutcomes(state)
	end


end

join.Visible = false
shop.Visible = false
feedback.Visible = false
voting.Visible = false
reveal.Visible = false
stateEvent.OnClientEvent:Connect(update)
command:FireServer("Sync")
