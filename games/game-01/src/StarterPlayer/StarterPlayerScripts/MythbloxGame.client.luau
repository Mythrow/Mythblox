-- Mythblox Game 01 · Soft Earth Coast mobile UI v0.30
-- Presentation only. The server still owns votes, movement, cracks, winners and coins.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local BUILD_VERSION = "v0.30"
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
	Blue = Color3.fromRGB(105, 133, 105),     -- readable deep sage controls
	Green = Color3.fromRGB(90, 144, 106),     -- safe result
	Red = Color3.fromRGB(176, 103, 99),       -- blocked result
	Gold = Color3.fromRGB(185, 137, 115),     -- terracotta selection
	Purple = Color3.fromRGB(110, 90, 75),     -- brown phase heading
	Border = Color3.fromRGB(191, 167, 144),
	White = Color3.fromRGB(250, 244, 233),    -- legible on sage/dusty rose
}

local prefs = {tutorialSeen=false, soundOn=true, musicOn=false, lowEffects=false, largeText=false, highContrast=false}
local prefsReady = false
local latestState = nil
local layoutForViewport
local menuDismissedTutorial = false

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
	if not audio or not prefs.soundOn then return end
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
-- Dedicated always-visible wallet instead of tiny, hard-to-find phone text.
-- Server-owned replicated leaderstats are display-only; the client cannot
-- change saved Coins or Wins. This stays visible in both lobby and races.
local wallet = panel("CoinsWallet")
wallet.AnchorPoint = Vector2.new(1, 0)
wallet.Size = UDim2.fromOffset(172, 28)
wallet.Position = UDim2.new(1, -8, 0, 50)
local walletText = label(wallet, "CoinsAndWins", "COINS 0  ·  WINS 0",
	9, 3, -18, 22, 12, COLOR.Text, true)
walletText.TextWrapped = false
walletText.TextTruncate = Enum.TextTruncate.AtEnd
walletText.TextXAlignment = Enum.TextXAlignment.Center

local function refreshWallet()
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	local wins = stats and stats:FindFirstChild("Wins")
	walletText.Text = ("COINS %d  ·  WINS %d"):format(
		coins and coins.Value or 0, wins and wins.Value or 0)
end
task.spawn(function()
	local stats = player:WaitForChild("leaderstats", 30)
	if not stats then return end
	for _, name in ipairs({"Coins", "Wins"}) do
		local value = stats:WaitForChild(name, 30)
		if value then value:GetPropertyChangedSignal("Value"):Connect(refreshWallet) end
	end
	refreshWallet()
end)
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

-- No on-screen JOIN button. The server detects all players standing
-- anywhere on the front JOIN deck and removes them if they leave it.

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

-- v0.30: Secret selections are never displayed to others while voting.
-- ONLY during the five-second REVEAL do five non-clickable results cards
-- show every numbered choice, picking players' avatars, totals, and safety.
-- The existing teal voting buttons remain PRIVATE selection controls.
local reveal = panel("RevealPanel")
reveal.AnchorPoint = Vector2.new(0.5, 0)
reveal.Position = UDim2.new(0.5, 0, 0, 103)
reveal.Visible = false

-- The five cards already say SAFE or BLOCKED. Do not repeat the obvious
-- color legend above them or waste mobile vertical space.
local revealHeader = label(reveal, "Heading", "VOTES REVEALED", 13, 7, -26, 27, 19, COLOR.Purple, true)
revealHeader.TextXAlignment = Enum.TextXAlignment.Center

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
		card.status.Text = prefs.highContrast
			and (blocked and "X BLOCKED" or "+ SAFE") or (blocked and "BLOCKED" or "SAFE")
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
	if kind == "Open" then
		shop.Visible = true
		inventory.Visible = false
		settings.Visible = false
		tutorial.Visible = false
	end
	if type(details) == "table" then
		shopCache=details
		if details.ui then acceptUIState(details) end
		if inventory.Visible then showInventory() end
	end
	if shop.Visible and (kind == "Open" or kind == "Update") then
		renderShop(details, message)
	end
	if kind == "Update" and type(message) == "string" then
		if string.find(message,"Purchased ",1,true)
			or string.find(message," equipped.",1,true) then notify(message) end
	end
end)

-- v0.30: Seven lightweight UI capabilities, each with independent
-- visibility and no changes to humanoid movement or bridge rules.
local lobbyMenu = Instance.new("Frame")
lobbyMenu.Name = "LobbyMenu"
lobbyMenu.BackgroundTransparency = 1
lobbyMenu.Size = UDim2.fromOffset(206, 34)
lobbyMenu.Parent = gui
local ml = Instance.new("UIListLayout")
ml.FillDirection = Enum.FillDirection.Horizontal
ml.HorizontalAlignment = Enum.HorizontalAlignment.Right
ml.Padding = UDim.new(0, 5)
ml.Parent = lobbyMenu
local bagButton = button(lobbyMenu,"Bag","BAG",COLOR.Blue)
bagButton.LayoutOrder=1; bagButton.Size=UDim2.fromOffset(59,32); bagButton.TextSize=12
local settingsButton = button(lobbyMenu,"Settings","SETTINGS",COLOR.Blue)
settingsButton.LayoutOrder=2; settingsButton.Size=UDim2.fromOffset(94,32); settingsButton.TextSize=12
local helpButton = button(lobbyMenu,"Help","?",COLOR.Gold)
helpButton.LayoutOrder=3; helpButton.Size=UDim2.fromOffset(32,32); helpButton.TextSize=17
local function closeButton(container)
	local b = button(container,"Close","X",COLOR.Red)
	b.AnchorPoint=Vector2.new(1,0)
	b.Position=UDim2.new(1,-10,0,10)
	b.Size=UDim2.fromOffset(33,30)
	b.TextSize=13
	b.MouseButton1Click:Connect(function() container.Visible=false end)
	return b
end
local function scrollArea(container,name,top)
	local sf=Instance.new("ScrollingFrame")
	sf.Name=name; sf.Position=UDim2.fromOffset(11,top)
	sf.Size=UDim2.new(1,-22,1,-top-12)
	sf.BackgroundTransparency=1; sf.BorderSizePixel=0
	sf.ScrollBarThickness=4; sf.ScrollingDirection=Enum.ScrollingDirection.Y
	sf.Parent=container
	local list=Instance.new("UIListLayout")
	list.SortOrder=Enum.SortOrder.LayoutOrder
	list.Padding=UDim.new(0,5)
	list.Parent=sf
	return sf
end

local tutorial = panel("Tutorial")
tutorial.Visible=false; tutorial.AnchorPoint=Vector2.new(0.5,0)
closeButton(tutorial)
local tutTitle=label(tutorial,"Title","HOW TO PLAY",12,10,-61,29,17,COLOR.Purple,true)
local tutBody=label(tutorial,"Body","",12,44,-24,89,14,COLOR.Text,false)
tutBody.TextYAlignment=Enum.TextYAlignment.Top
local tutCounter=label(tutorial,"Progress","",12,138,-24,20,12,COLOR.Muted,true)
local tutSkip=button(tutorial,"Skip","SKIP",COLOR.Gold)
tutSkip.Size=UDim2.fromOffset(86,34)
tutSkip.Position=UDim2.new(0,12,1,-43)
tutSkip.TextSize=12
local tutNext=button(tutorial,"Next","NEXT",COLOR.Blue)
tutNext.AnchorPoint=Vector2.new(1,0)
tutNext.Size=UDim2.fromOffset(98,34)
tutNext.Position=UDim2.new(1,-12,1,-43)
tutNext.TextSize=12
local tutPages={
	{"JOIN ZONE","Stand anywhere on the wide front deck. Stay inside at zero to enter; step out to unqueue."},
	{"PICK 1–5","Vote privately for how many steps to try. The most popular number becomes blocked."},
	{"CROSS SAFELY","MOVE only when GO appears. Walk and jump freely, but an early or forbidden step shatters glass."},
	{"COINS & COLORS","Multiplayer races earn Coins and Wins. Solo practice has no rewards. Own colors in BAG; buy new ones at COSMETICS."},
}
local tutStep=1
local function drawTutorial()
	tutTitle.Text=tutPages[tutStep][1]
	tutBody.Text=tutPages[tutStep][2]
	tutCounter.Text=("%d / %d"):format(tutStep,#tutPages)
	tutNext.Text=tutStep==#tutPages and "DONE" or "NEXT"
end
local function tutorialDone()
	menuDismissedTutorial=true
	tutorial.Visible=false
	if not prefs.tutorialSeen then
		prefs.tutorialSeen=true
		command:FireServer("UI",{key="tutorialSeen",value=true})
	end
end
tutSkip.MouseButton1Click:Connect(tutorialDone)
tutNext.MouseButton1Click:Connect(function()
	if tutStep==#tutPages then tutorialDone()
	else tutStep+=1;drawTutorial() end
end)

local inventory=panel("Inventory")
inventory.Visible=false; inventory.AnchorPoint=Vector2.new(0.5,0.5)
label(inventory,"Title","MY GLASS COLORS",12,9,-65,32,18,COLOR.Purple,true)
closeButton(inventory)
local invHelp=label(inventory,"Hint","Owned colors · equip anywhere",12,43,-24,26,12,COLOR.Muted)
local invScroll=scrollArea(inventory,"Owned",75)
local shopCache=nil
local function showInventory()
	for _,child in ipairs(invScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	if not shopCache then invHelp.Text="LOADING OWNED COLORS";return end
	local count=0
	for _,item in ipairs(shopCache.items or {}) do
		if item.id=="classic" or (shopCache.owned and shopCache.owned[item.id]==true) then
			count+=1
			local row=Instance.new("Frame")
			row.Name="Owned_"..item.id;row.LayoutOrder=count
			row.Size=UDim2.new(1,-7,0,50)
			row.BorderSizePixel=0;row.BackgroundColor3=COLOR.InkBright;row.Parent=invScroll
			addCorner(row,8)
			local sw=Instance.new("Frame")
			sw.Name="Color";sw.Position=UDim2.fromOffset(8,10);sw.Size=UDim2.fromOffset(29,29)
			sw.BackgroundColor3=typeof(item.color)=="Color3" and item.color or COLOR.Blue
			sw.Parent=row;addCorner(sw,7)
			local nm=label(row,"Name",item.title,43,7,-145,36,12,COLOR.Text,true)
			nm.TextWrapped=false;nm.TextTruncate=Enum.TextTruncate.AtEnd
			local equip=button(row,"Equip",shopCache.equipped==item.id and "EQUIPPED" or "EQUIP",
				shopCache.equipped==item.id and COLOR.Green or COLOR.Blue)
			equip.AnchorPoint=Vector2.new(1,0.5)
			equip.Position=UDim2.new(1,-7,0.5,0)
			equip.Size=UDim2.fromOffset(85,31)
			equip.TextSize=11
			if shopCache.equipped==item.id or not shopCache.ready then
				equip.Active=false;equip.AutoButtonColor=false
			else
				equip.MouseButton1Click:Connect(function()
					equip.Text="..."
					command:FireServer("Equip",item.id)
				end)
			end
		end
	end
	invScroll.CanvasSize=UDim2.fromOffset(0,count*55)
	invHelp.Text=shopCache.ready and (count.." OWNED · EQUIP ANYWHERE") or "PROFILE IS SESSION-ONLY"
end

local settings=panel("Preferences")
settings.Visible=false;settings.AnchorPoint=Vector2.new(0.5,0.5)
label(settings,"Title","SETTINGS",12,9,-65,32,18,COLOR.Purple,true)
closeButton(settings)
local settingScroll=scrollArea(settings,"Options",49)
settingScroll.Size=UDim2.new(1,-22,1,-75)
local settingNote=label(settings,"Note","Saved with your profile",12,0,-24,18,10,COLOR.Muted)
settingNote.AnchorPoint=Vector2.new(0,1)
settingNote.Position=UDim2.new(0,12,1,-4)
local settingOrder={
	{"soundOn","SOUND EFFECTS"},
	{"musicOn","MUSIC (NO TRACK YET)"},
	{"lowEffects","REDUCE EFFECTS"},
	{"largeText","LARGER TEXT"},
	{"highContrast","EXTRA SAFE/BLOCKED CUES"},
}
local toggles={}
local function applyPreferences()
	for _,sound in pairs(sounds) do
		local base=sound:GetAttribute("BaseMythbloxVolume")
		if base==nil then base=sound.Volume;sound:SetAttribute("BaseMythbloxVolume",base) end
		sound.Volume=prefs.soundOn and base or 0
	end
	local group=SoundService:FindFirstChild("MythbloxMusicGroup")
	if not group then
		group=Instance.new("SoundGroup")
		group.Name="MythbloxMusicGroup"
		group.Parent=SoundService
	end
	group.Volume=prefs.musicOn and 0.35 or 0
	local world=workspace:FindFirstChild("MythbloxGame01")
	if world then
		for _,obj in ipairs(world:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				local base=obj:GetAttribute("MythbloxOriginalEffectEnabled")
				if base==nil then
					base=obj.Enabled
					obj:SetAttribute("MythbloxOriginalEffectEnabled",base)
				end
				obj.Enabled=not prefs.lowEffects and base or false
			end
		end
	end
end
workspace.DescendantAdded:Connect(function(obj)
	if not prefs.lowEffects then return end
	local w=workspace:FindFirstChild("MythbloxGame01")
	if w and obj:IsDescendantOf(w) and
		(obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")) then
		task.defer(function()
			if not obj.Parent or not prefs.lowEffects then return end
			if obj:GetAttribute("MythbloxOriginalEffectEnabled")==nil then
				obj:SetAttribute("MythbloxOriginalEffectEnabled",obj.Enabled)
			end
			obj.Enabled=false
		end)
	end
end)
local function redrawSettings()
	for key,btn in pairs(toggles) do
		btn.Text=prefs[key] and "ON" or "OFF"
		btn.BackgroundColor3=prefs[key] and COLOR.Green or COLOR.Gold
	end
	settingNote.Text=player:GetAttribute("MythbloxDataStatus")=="READY"
		and "Saved with your profile" or "Session-only until data loads"
	applyPreferences()
	if layoutForViewport then layoutForViewport() end
	if latestState and latestState.phase=="REVEAL" then
		lastTurnRendered=-1
		drawOutcomes(latestState)
	end
end
for n,entry in ipairs(settingOrder) do
	local key,text=entry[1],entry[2]
	local row=Instance.new("Frame")
	row.LayoutOrder=n;row.Name=key;row.Size=UDim2.new(1,-6,0,44)
	row.BackgroundColor3=COLOR.InkBright;row.BorderSizePixel=0;row.Parent=settingScroll
	addCorner(row,8)
	local nm=label(row,"Name",text,8,6,-93,31,11,COLOR.Text,true)
	nm.TextWrapped=false;nm.TextTruncate=Enum.TextTruncate.AtEnd
	local b=button(row,"Toggle","ON",COLOR.Green)
	b.AnchorPoint=Vector2.new(1,0.5)
	b.Position=UDim2.new(1,-6,0.5,0)
	b.Size=UDim2.fromOffset(66,30);b.TextSize=12
	toggles[key]=b
	b.MouseButton1Click:Connect(function()
		prefs[key]=not prefs[key]
		command:FireServer("UI",{key=key,value=prefs[key]})
		redrawSettings()
	end)
end
settingScroll.CanvasSize=UDim2.fromOffset(0,#settingOrder*49)

local raceHud=panel("RaceStatus")
raceHud.Visible=false;raceHud.AnchorPoint=Vector2.new(1,0)
local raceLine=label(raceHud,"Progress","TILE 0/20 · 0/3 CRACKS",8,3,-16,18,12,COLOR.Text,true)
raceLine.TextWrapped=false;raceLine.TextTruncate=Enum.TextTruncate.AtEnd
local permissionLine=label(raceHud,"Permission","VOTE 1–5",8,22,-16,17,11,COLOR.Muted,true)
permissionLine.TextWrapped=false;permissionLine.TextTruncate=Enum.TextTruncate.AtEnd

local recap=panel("RoundRecap")
recap.Visible=false;recap.AnchorPoint=Vector2.new(0.5,0)
local recapTitle=label(recap,"Winner","ROUND COMPLETE",10,7,-20,28,16,COLOR.Purple,true)
local recapPlace=label(recap,"Place","",10,41,-20,26,13,COLOR.Text,true)
local recapReward=label(recap,"Rewards","",10,72,-20,27,15,COLOR.Green,true)
local recapTimer=label(recap,"NextMatch","",10,103,-20,20,11,COLOR.Muted)
for _,lbl in ipairs({recapTitle,recapPlace,recapReward,recapTimer}) do
	lbl.TextXAlignment=Enum.TextXAlignment.Center
end

local toast=panel("Toast")
toast.Visible=false;toast.AnchorPoint=Vector2.new(0.5,0)
local toastText=label(toast,"Message","",9,3,-18,25,12,COLOR.Text,true)
toastText.TextWrapped=false;toastText.TextTruncate=Enum.TextTruncate.AtEnd
toastText.TextXAlignment=Enum.TextXAlignment.Center
local toastTick=0
local function notify(message)
	toastTick+=1
	local ticket=toastTick
	toastText.Text=message
	toast.Visible=true
	task.delay(2.6,function()
		if toast.Parent and ticket==toastTick then toast.Visible=false end
	end)
end

local spectator=panel("SpectatorControls")
spectator.Visible=false;spectator.AnchorPoint=Vector2.new(0.5,1)
local prev=button(spectator,"Previous","<",COLOR.Blue)
local nextButton=button(spectator,"Next",">",COLOR.Blue)
local stop=button(spectator,"Stop","EXIT",COLOR.Gold)
local watchedName=label(spectator,"Target","FOLLOW A RACER",0,5,0,24,12,COLOR.Text,true)
watchedName.TextXAlignment=Enum.TextXAlignment.Center
local spectateIds={}
local spectateIndex=1
local isFollowing=false
local function ownCamera()
	isFollowing=false
	local camera=workspace.CurrentCamera
	local character=player.Character
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	if camera and humanoid then
		camera.CameraType=Enum.CameraType.Custom
		camera.CameraSubject=humanoid
	end
end
local function followRacer()
	local id=spectateIds[spectateIndex]
	local target=id and Players:GetPlayerByUserId(id)
	local humanoid=target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	local cam=workspace.CurrentCamera
	if not cam or not humanoid or humanoid.Health<=0 then
		watchedName.Text="RACER UNAVAILABLE"
		return
	end
	cam.CameraType=Enum.CameraType.Custom
	cam.CameraSubject=humanoid
	isFollowing=true
	watchedName.Text=target.DisplayName
end
prev.MouseButton1Click:Connect(function()
	if #spectateIds==0 then return end
	spectateIndex=(spectateIndex-2)%#spectateIds+1
	followRacer()
end)
nextButton.MouseButton1Click:Connect(function()
	if #spectateIds==0 then return end
	spectateIndex=spectateIndex%#spectateIds+1
	followRacer()
end)
stop.MouseButton1Click:Connect(function()
	ownCamera()
	watchedName.Text="FOLLOW A RACER"
end)
player.CharacterAdded:Connect(function(character)
	if isFollowing then
		isFollowing=false
		task.spawn(function()
			local humanoid=character:WaitForChild("Humanoid",5)
			local camera=workspace.CurrentCamera
			if camera and humanoid and not isFollowing then
				camera.CameraType=Enum.CameraType.Custom
				camera.CameraSubject=humanoid
			end
		end)
	end
end)

bagButton.MouseButton1Click:Connect(function()
	inventory.Visible=not inventory.Visible
	if inventory.Visible then
		settings.Visible=false;tutorial.Visible=false;shop.Visible=false
		command:FireServer("Inventory")
		showInventory()
	end
end)
settingsButton.MouseButton1Click:Connect(function()
	settings.Visible=not settings.Visible
	if settings.Visible then
		inventory.Visible=false;tutorial.Visible=false;shop.Visible=false
		redrawSettings()
	end
end)
helpButton.MouseButton1Click:Connect(function()
	tutStep=1;drawTutorial()
	tutorial.Visible=not tutorial.Visible
	inventory.Visible=false;settings.Visible=false
end)
local function acceptUIState(data)
	if type(data)~="table" or type(data.ui)~="table" then return end
	-- Inventory may load before the cloud profile. Wait for a real server
	-- READY/SESSION_ONLY status before deciding tutorialSeen is false.
	if player:GetAttribute("MythbloxDataStatus")=="LOADING" then return end
	local first=not prefsReady
	prefsReady=true
	for key in pairs(prefs) do
		if type(data.ui[key])=="boolean" then prefs[key]=data.ui[key] end
	end
	redrawSettings()
	if first and not prefs.tutorialSeen and not menuDismissedTutorial
		and (not latestState or latestState.phase=="JOIN") then
		tutStep=1;drawTutorial();tutorial.Visible=true
	end
end

layoutForViewport = function()
	local cam = workspace.CurrentCamera
	local view = cam and cam.ViewportSize or Vector2.new(1100, 700)
	local width = math.max(300, view.X)
	local height = math.max(320, view.Y)
	local compact = width < 760 or height < 540 -- portrait AND landscape phones
	isCompact = compact
	if compact then feedback.Visible = false end
	local shortScreen = height < 570

	-- v0.30: phone status is smaller, at the TOP RIGHT of the core-UI safe
	-- area rather than a wide center banner obscuring the avatar/camera.
	-- Never put it above Roblox's native safe-area inset.
	local topW = compact and math.min(270, math.max(180, width - 110))
		or math.min(width - 20, 470)
	top.AnchorPoint = compact and Vector2.new(1, 0) or Vector2.new(0.5, 0)
	top.Size = UDim2.fromOffset(topW, compact and 43 or 83)
	top.Position = compact and UDim2.new(1, -8, 0, 0) or UDim2.new(0.5, 0, 0, 8)
	top.BackgroundTransparency = compact and 0.10 or 0.07
	phaseText.Position = UDim2.fromOffset(compact and 9 or 14, compact and 2 or 6)
	phaseText.Size = UDim2.new(1, compact and -70 or -107, 0, compact and 19 or 23)
	phaseText.TextSize = compact and 11 or 15
	phaseText.TextWrapped = false
	phaseText.TextTruncate = Enum.TextTruncate.AtEnd
	clockText.Position = UDim2.new(1, compact and -54 or -82, 0, compact and 2 or 6)
	clockText.Size = UDim2.fromOffset(compact and 45 or 68, compact and 19 or 23)
	clockText.TextSize = compact and 15 or 19
	description.Visible = not compact
	description.Position = UDim2.fromOffset(14, 30)
	description.Size = UDim2.new(1, -28, 0, 20)
	description.TextSize = 13
	ownStats.Position = UDim2.fromOffset(compact and 9 or 14, compact and 23 or 53)
	ownStats.Size = UDim2.new(1, compact and -20 or -28, 0, compact and 15 or 18)
	ownStats.TextSize = compact and 10 or 12
	ownStats.TextWrapped = false
	ownStats.TextTruncate = Enum.TextTruncate.AtEnd
	-- Keep the currency display near the small phase bar, but separate so
	-- balance is visible on desktop as well as phone.
	wallet.AnchorPoint = Vector2.new(1, 0)
	wallet.Size = UDim2.fromOffset(compact and 158 or 176, 27)
	wallet.Position = UDim2.new(1, compact and -8 or -16, 0, compact and 47 or 8)
	walletText.TextSize = compact and 11 or 12
	progressBackground.Visible = not compact

	local voteW = math.min(width - 18, 535)
	local voteHeight = compact and (shortScreen and 111 or 120) or 140
	voting.Size = UDim2.fromOffset(voteW, voteHeight)
	voting.Position = UDim2.new(0.5, 0, 1, -14)
	voteTitle.Position = UDim2.fromOffset(12, compact and 4 or 7)
	voteTitle.Size = UDim2.new(1, -24, 0, compact and 22 or 25)
	voteTitle.TextSize = compact and 15 or 18
	voteHint.Position = UDim2.fromOffset(12, compact and 27 or 34)
	voteHint.Size = UDim2.new(1, -24, 0, compact and 18 or 24)
	voteHint.TextSize = compact and 10 or 13
	choiceRow.Position = UDim2.new(0, 12, 0, compact and 52 or 66)
	choiceRow.Size = UDim2.new(1, -24, 0, compact and (shortScreen and 47 or 53) or 64)
	for _, b in ipairs(choiceButtons) do
		b.Size = UDim2.new(0.19, 0, 0, compact and (shortScreen and 47 or 53) or 61)
		b.TextSize = compact and 19 or 23
	end

	local shopW = math.min(width - 20, 350)
	shop.Size = UDim2.fromOffset(shopW, math.max(218, math.min(358, height - 118)))
	shop.AnchorPoint = compact and Vector2.new(0.5, 0.5) or Vector2.new(1, 0.5)
	shop.Position = compact and UDim2.new(0.5, 0, 0.56, 0) or UDim2.new(1, -18, 0.54, 0)

	-- v0.30: Omit the unnecessary red/green legend and reclaim its 16–18px.
	-- Avatar grids, vote totals, numbered SAFE/BLOCKED cards and five-second
	-- server reveal duration are unchanged. The phone tray obscures less play.
	local revealW = math.min(width - 18, compact and 560 or 780)
	local revealH = compact and (shortScreen and 140 or 156)
		or math.max(160, math.min(210, height - 128))
	reveal.Size = UDim2.fromOffset(revealW, revealH)
	reveal.Position = UDim2.new(0.5, 0, 0, compact and 51 or 100)
	revealHeader.Position = UDim2.fromOffset(8, compact and 1 or 7)
	revealHeader.Size = UDim2.new(1, -16, 0, compact and 21 or 27)
	revealHeader.TextSize = compact and 14 or 19
	resultRow.Position = UDim2.fromOffset(compact and 6 or 10, compact and 24 or 42)
	resultRow.Size = UDim2.new(1, compact and -12 or -20, 1, compact and -29 or -54)
	local cardHeight = revealH - (compact and 29 or 54)
	local avatarHeight = compact and (shortScreen and 37 or 43) or 55
	local cardWidth = (revealW - (compact and 12 or 20)) * 0.19
	local columns = cardWidth < 80 and 3 or 4
	local rows = math.ceil(8 / columns)
	local avatarSize = math.max(10, math.min(24,
		math.floor((cardWidth - 12 - (columns - 1) * 2) / columns),
		math.floor((avatarHeight - (rows - 1) * 2) / rows)))
	for _, card in ipairs(resultCards) do
		card.avatars.Position = UDim2.fromOffset(compact and 3 or 4, compact and 2 or 7)
		card.avatars.Size = UDim2.new(1, compact and -6 or -8, 0, avatarHeight)
		card.grid.FillDirectionMaxCells = columns
		card.grid.CellSize = UDim2.fromOffset(avatarSize, avatarSize)
		card.number.Position = UDim2.new(0, 0, 0, avatarHeight + (compact and 3 or 8))
		card.number.Size = UDim2.new(1, 0, 0, compact
			and math.max(25, cardHeight - avatarHeight - 39)
			or math.max(24, cardHeight - avatarHeight - 55))
		card.number.TextSize = compact and math.floor(math.clamp(cardWidth * 0.42, 20, 29)) or 39
		card.votes.Position = UDim2.new(0, 0, 1, compact and -34 or -45)
		card.votes.Size = UDim2.new(1, 0, 0, compact and 15 or 23)
		card.votes.TextSize = compact and 9 or 13
		card.status.Position = UDim2.new(0, 0, 1, compact and -18 or -23)
		card.status.Size = UDim2.new(1, 0, 0, compact and 14 or 20)
		card.status.TextSize = compact and (prefs.largeText and 11 or 9)
			or (prefs.largeText and 14 or 12)
	end

	-- The lobby menu remains unobtrusive; all its panels close during
	-- racing. Use scrolling panels on short landscape mobile viewports.
	lobbyMenu.AnchorPoint=Vector2.new(1,0)
	lobbyMenu.Position=UDim2.new(1,-8,0,compact and 83 or 47)
	local sheetW=math.min(width-20,330)
	local sheetH=math.min(336,math.max(202,height-112))
	for _,sheet in ipairs({inventory,settings}) do
		sheet.Size=UDim2.fromOffset(sheetW,sheetH)
		sheet.Position=UDim2.new(0.5,0,0.54,0)
	end
	tutorial.Size=UDim2.fromOffset(math.min(width-20,324),203)
	tutorial.Position=UDim2.new(0.5,0,0,compact and 123 or 131)
	tutBody.TextSize=prefs.largeText and 16 or 14
	raceHud.Size=UDim2.fromOffset(compact and 199 or 234,44)
	raceHud.Position=UDim2.new(1,compact and -8 or -16,0,compact and 84 or 45)
	raceLine.TextSize=prefs.largeText and 13 or 12
	permissionLine.TextSize=prefs.largeText and 12 or 11
	recap.Size=UDim2.fromOffset(math.min(width-20,compact and 306 or 350),135)
	recap.Position=UDim2.new(0.5,0,0,compact and 137 or 109)
	toast.Size=UDim2.fromOffset(math.min(width-26,320),31)
	toast.Position=UDim2.new(0.5,0,0,compact and 131 or 153)
	spectator.Size=UDim2.fromOffset(math.min(width-24,327),43)
	spectator.Position=UDim2.new(0.5,0,1,compact and -113 or -92)
	local sw=spectator.Size.X.Offset
	prev.Position=UDim2.fromOffset(6,6)
	prev.Size=UDim2.fromOffset(35,31)
	prev.TextSize=17
	nextButton.Position=UDim2.fromOffset(sw-85,6)
	nextButton.Size=UDim2.fromOffset(35,31)
	nextButton.TextSize=17
	stop.Position=UDim2.fromOffset(sw-46,6)
	stop.Size=UDim2.fromOffset(40,31)
	stop.TextSize=11
	watchedName.Position=UDim2.fromOffset(44,5)
	watchedName.Size=UDim2.fromOffset(sw-133,32)
	watchedName.TextSize=prefs.largeText and 13 or 12
	phaseText.TextSize=compact and (prefs.largeText and 12 or 11) or 15
	ownStats.TextSize=compact and (prefs.largeText and 11 or 10) or 12
	walletText.TextSize=compact and (prefs.largeText and 12 or 11) or 12
	for _,b in ipairs(choiceButtons) do
		b.TextSize=compact and (prefs.largeText and 22 or 19) or 23
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
local lastNotifiedRound = -1
local function update(state)
	latestState = state
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
	phaseText.Text = ("v0.30 · ROUND %d · %s"):format(state.turn or 0, phaseNames[phase] or phase)
	clockText.Text = tostring(state.time or 0) .. "s"
	clockText.TextColor3 = phase == "VOTE" and (state.time or 0) <= 2 and COLOR.Red or COLOR.Purple
	description.Text = state.message or ""

	-- Show zone membership via server snapshots; nobody must tap JOIN.
	voting.Visible = phase == "VOTE" and mine ~= nil and mine.alive == true
	if voting.Visible then shop.Visible = false end

	if phase == "JOIN" then
		phaseText.Text = "v0.30 · JOIN ZONE"
		description.Text = state.queued
			and ((state.ready or 0) == 1 and state.liveSoloPractice
				and "In zone · stay for solo practice (no rewards)."
				or "In zone · stay until zero to enter the next race.")
			or "Walk onto the entire front deck to join automatically."
		ownStats.Text = ("%d/%d IN ZONE"):format(state.ready or 0, state.capacity or 8)
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
		phaseText.Text = "v0.30 · ROUND OVER"
		ownStats.Text = state.practiceNoRewards and "PRACTICE · NO WINS / COINS"
			or "NEXT MATCH STARTS SOON"
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

	-- Phone HUD only: compress three descriptive rows into two slim lines.
	-- The actual VOTE buttons and five-number reveal are unchanged.
	-- Wins/coins are read from server-owned replicated leaderstats; no
	-- purchases or scores can be changed from this presentation-only UI.
	if isCompact then
		phaseText.Text = phase == "JOIN" and "JOIN ZONE"
			or (state.practiceNoRewards and "SOLO · " or ("R%d · "):format(state.turn or 0))
				.. (phaseNames[phase] or phase)
		if phase == "JOIN" then
			ownStats.Text = state.queued
				and ((state.ready or 0) == 1 and state.liveSoloPractice
					and "IN ZONE · SOLO PRACTICE" or "IN ZONE · STAY")
				or "ENTER FRONT DECK TO JOIN"
		elseif phase == "RESULTS" then
			ownStats.Text = state.practiceNoRewards and "PRACTICE · NO REWARDS"
				or "ROUND OVER · NEXT SOON"
		elseif mine and not mine.alive then
			ownStats.Text = "ELIMINATED · SPECTATING"
		elseif phase == "MOVE" and mine and mine.alive then
			local allowed = mine.allowed or 0
			ownStats.Text = allowed > 0
				and ("GO 1–%d · TILE %d/20"):format(allowed, mine.position or 0)
				or ("WAIT · TILE %d/20"):format(mine.position or 0)
		elseif mine then
			ownStats.Text = ("T%d/20 · %d CR · PICK %s"):format(
				mine.position or 0, mine.cracks or 0,
				mine.vote and tostring(mine.vote) or "—")
		else
			ownStats.Text = "SPECTATING"
		end
	end

	-- Save failures appear in the existing HUD line without extra overlays,
	-- and never displace GO/WAIT guidance while racing.
	local dataStatus = player:GetAttribute("MythbloxDataStatus")
	if (phase == "JOIN" or phase == "RESULTS")
		and (dataStatus == "SESSION_ONLY" or dataStatus == "SAVE_ERROR") then
		ownStats.Text = dataStatus == "SAVE_ERROR"
			and "SAVE ERROR · REJOIN TO VERIFY"
			or "SESSION ONLY · NO PROGRESS SAVED"
		ownStats.TextColor3 = COLOR.Red
	else
		ownStats.TextColor3 = COLOR.Muted
	end

	-- Seven approved features: lightweight in-lobby controls, a clear
	-- actionable race progress strip, server-confirmed results, follow
	-- camera, and a temporary reward toast (not an extra persistent overlay).
	refreshWallet()
	wallet.Visible = not (isCompact and phase == "REVEAL")
	local inRace = phase == "VOTE" or phase == "REVEAL" or phase == "MOVE"
	lobbyMenu.Visible = phase == "JOIN" or phase == "RESULTS"
	if inRace then
		inventory.Visible=false
		settings.Visible=false
		tutorial.Visible=false
		shop.Visible=false
	end
	raceHud.Visible = inRace and mine ~= nil and mine.alive == true
	if raceHud.Visible then
		raceLine.Text = ("TILE %d/20 · CRACKS %d/3"):format(
			mine.position or 0,mine.cracks or 0)
		local remaining = state.time or 0
		if phase == "MOVE" then
			local allowed = mine.allowed or 0
			permissionLine.Text = allowed > 0
				and ("GO %d STEPS · %ds LEFT"):format(allowed,remaining)
				or ("WAIT · %ds LEFT"):format(remaining)
			permissionLine.TextColor3=allowed>0 and COLOR.Green or COLOR.Red
		elseif phase == "VOTE" then
			permissionLine.Text=("PICK 1–5 · %ds LEFT"):format(remaining)
			permissionLine.TextColor3=COLOR.Text
		else
			permissionLine.Text=("REVEAL · %ds"):format(remaining)
			permissionLine.TextColor3=COLOR.Text
		end
	end
	-- In short mobile screens the 5-card reveal stays the only foreground
	-- gameplay tray; hide the race strip until MOVE.
	if isCompact and phase == "REVEAL" then raceHud.Visible=false end

	local isSpectator = inRace and (mine == nil or not mine.alive)
	spectator.Visible = isSpectator
	if not isSpectator then
		if isFollowing then ownCamera() end
		table.clear(spectateIds)
	else
		local previous = spectateIds[spectateIndex]
		table.clear(spectateIds)
		for _,racer in ipairs(state.roster or {}) do
			if racer.alive and type(racer.userId)=="number"
				and racer.userId ~= player.UserId then
				table.insert(spectateIds,racer.userId)
			end
		end
		if #spectateIds==0 then
			if isFollowing then ownCamera() end
			watchedName.Text="NO RACERS LEFT"
		else
			local matchIndex=nil
			for idx,userId in ipairs(spectateIds) do
				if userId==previous then matchIndex=idx;break end
			end
			spectateIndex=matchIndex or 1
			if isFollowing then
				if not matchIndex then
					ownCamera()
					watchedName.Text="TAP ARROWS TO FOLLOW"
				else
					followRacer()
				end
			else
				watchedName.Text="TAP ARROWS TO FOLLOW"
			end
		end
	end

	recap.Visible=phase=="RESULTS" and type(state.results)=="table"
	if recap.Visible then
		local results=state.results
		local names=results.winners or {}
		local winner= #names==0 and "NO WINNER"
			or (#names==1 and (names[1].." WINS") or ("TIE · "..table.concat(names,", ")))
		recapTitle.Text=winner
		local personal=results.personal
		recapPlace.Text=personal
			and ("YOUR PLACE: #%d OF %d · TILE %d/20"):format(
				personal.place or 1,results.total or 1,personal.distance or 0)
			or "SPECTATING THIS ROUND"
		local coins=personal and personal.coins or 0
		local wins=personal and personal.wins or 0
		recapReward.Text=state.practiceNoRewards and "PRACTICE · NO REWARDS"
			or ("+%d COINS · +%d WINS"):format(coins,wins)
		recapTimer.Text=("NEXT MATCH SOON · %ds"):format(state.time or 0)
		if type(results.serial)=="number" and results.serial~=lastNotifiedRound then
			lastNotifiedRound=results.serial
			if personal and (coins>0 or wins>0) then
				notify(("+%d COINS · +%d WINS"):format(coins,wins))
			end
		end
	end
	if prefsReady and not prefs.tutorialSeen and not menuDismissedTutorial
		and phase=="JOIN" and not tutorial.Visible and previousPhase=="RESULTS" then
		tutStep=1;drawTutorial();tutorial.Visible=true
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

shop.Visible = false
feedback.Visible = false
voting.Visible = false
reveal.Visible = false
stateEvent.OnClientEvent:Connect(update)
-- The DataStore status can change between server countdown snapshots.
player:GetAttributeChangedSignal("MythbloxDataStatus"):Connect(function()
	if latestState then update(latestState) end
end)
-- The server may finish loading before the shop UI listener exists. An
-- explicit request ensures the saved tutorial/settings and owned colors
-- are always hydrated, even when the first UIState event was missed.
command:FireServer("Sync")
command:FireServer("Inventory")
