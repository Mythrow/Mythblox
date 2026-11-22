-- Mythblox Game 01 · cosmetic glass shop v0.14
-- Presentation only. The server still owns votes, movement, cracks, winners and coins.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local BUILD_VERSION = "v0.14"
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

-- Bright white panels + colorful blue/green buttons, readable against daylight.
local COLOR = {
	Ink = Color3.fromRGB(255, 255, 255),         -- cards
	InkBright = Color3.fromRGB(231, 244, 255),   -- alternate rows and tracks
	Text = Color3.fromRGB(29, 63, 103),          -- dark text on bright cards
	Muted = Color3.fromRGB(90, 119, 151),
	Blue = Color3.fromRGB(41, 137, 242),
	Green = Color3.fromRGB(35, 180, 100),
	Red = Color3.fromRGB(224, 73, 83),
	Gold = Color3.fromRGB(255, 198, 63),
	Purple = Color3.fromRGB(35, 112, 211),       -- blue accent, kept variable name
	Border = Color3.fromRGB(179, 218, 247),
	White = Color3.fromRGB(255, 255, 255),
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
	frame.BackgroundTransparency = 0.015
	frame.BorderSizePixel = 0
	frame.Parent = gui
	addCorner(frame, 13)
	addStroke(frame, COLOR.Border, 1)
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
progressFill.BackgroundColor3 = COLOR.Green
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
	feedback.BackgroundColor3 = isGood and Color3.fromRGB(224, 251, 235) or Color3.fromRGB(255, 227, 227)
	feedbackText.TextColor3 = isGood and Color3.fromRGB(25, 133, 77) or Color3.fromRGB(192, 52, 72)
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
local join = button(gui, "JoinButton", "JOIN BRIDGE RACE", COLOR.Green)
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

-- Movement warning: big enough to read but kept near the bottom.
local movement = panel("MovementPanel")
movement.AnchorPoint = Vector2.new(0.5, 1)
local movementText = label(movement, "MovementText", "", 14, 8, -28, 50, 16, COLOR.Text, true)
movementText.TextXAlignment = Enum.TextXAlignment.Center

-- Results appear in the compact top status strip instead of a centered
-- modal. The arena and other players remain visible when a match ends.

-- Reveal panel displays every player's number, risk and permitted movement.
-- No one can see choices during secret voting; the server only publishes after.
local reveal = panel("RevealPanel")
local revealHeader = label(reveal, "Heading", "NUMBER REVEAL", 13, 7, -26, 26, 16, COLOR.Purple, true)
local revealSubtitle = label(reveal, "Rule", "MOST PICKED = CRACK", 13, 34, -26, 25, 13, COLOR.Muted)
local countsRow = Instance.new("Frame")
countsRow.Name = "CountRow"
countsRow.BackgroundTransparency = 1
countsRow.Position = UDim2.new(0, 12, 0, 67)
countsRow.Size = UDim2.new(1, -24, 0, 54)
countsRow.Parent = reveal
local countLayout = Instance.new("UIListLayout")
countLayout.FillDirection = Enum.FillDirection.Horizontal
countLayout.SortOrder = Enum.SortOrder.LayoutOrder
countLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
countLayout.Padding = UDim.new(0.01, 0)
countLayout.Parent = countsRow
local countCards = {}
for n = 1, 5 do
	local card = Instance.new("Frame")
	card.Name = "Number" .. n
	card.LayoutOrder = n
	card.Size = UDim2.new(0.19, 0, 0, 52)
	card.BackgroundColor3 = COLOR.InkBright
	card.BorderSizePixel = 0
	card.Parent = countsRow
	addCorner(card, 7)
	local numberLabel = label(card, "Number", tostring(n), 0, 2, 0, 24, 18, COLOR.Text, true)
	numberLabel.Size = UDim2.fromScale(1, 0.51)
	numberLabel.TextXAlignment = Enum.TextXAlignment.Center
	local countLabel = label(card, "Votes", "0 votes", 0, 28, 0, 19, 12, COLOR.Muted, true)
	countLabel.Size = UDim2.new(1, 0, 0, 19)
	countLabel.TextXAlignment = Enum.TextXAlignment.Center
	countCards[n] = {frame = card, number = numberLabel, votes = countLabel}
end

local revealList = Instance.new("ScrollingFrame")
revealList.Name = "PlayerOutcomes"
revealList.BackgroundTransparency = 1
revealList.BorderSizePixel = 0
revealList.Position = UDim2.new(0, 12, 0, 132)
revealList.Size = UDim2.new(1, -24, 1, -143)
revealList.ScrollBarThickness = 3
revealList.ScrollingDirection = Enum.ScrollingDirection.Y
revealList.CanvasSize = UDim2.fromOffset(0, 0)
revealList.Parent = reveal
local outcomesLayout = Instance.new("UIListLayout")
outcomesLayout.FillDirection = Enum.FillDirection.Vertical
outcomesLayout.SortOrder = Enum.SortOrder.LayoutOrder
outcomesLayout.Padding = UDim.new(0, 4)
outcomesLayout.Parent = revealList

local lastTurnRendered = -1
local function drawOutcomes(state)
	local counts = state.voteCounts or {}
	local blocked = {}
	for n = 1, 5 do
		local hit = state.unsafe and state.unsafe[n] == true
		local card = countCards[n]
		card.frame.BackgroundColor3 = hit and Color3.fromRGB(255, 225, 226) or COLOR.InkBright
		card.number.TextColor3 = hit and COLOR.Red or COLOR.Text
		card.votes.Text = tostring(counts[n] or 0) .. " picked"
		if hit then table.insert(blocked, tostring(n)) end
	end
	revealSubtitle.Text = #blocked > 0
		and ("BLOCKED: " .. table.concat(blocked, ", ") .. "  ·  SAME PICK = CRACK")
		or "NO COLLISION · EVERYONE CAN WALK"

	if lastTurnRendered == state.turn then return end
	lastTurnRendered = state.turn
	for _, child in ipairs(revealList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local entries = state.voteOutcomes or {}
	for idx, entry in ipairs(entries) do
		local row = Instance.new("Frame")
		row.Name = "Outcome" .. idx
		row.Size = UDim2.new(1, -3, 0, 29)
		row.LayoutOrder = idx
		local isMe = entry.userId == player.UserId
		row.BackgroundColor3 = isMe
			and (entry.status == "GO" and Color3.fromRGB(223, 249, 231) or Color3.fromRGB(255, 234, 236))
			or (idx % 2 == 0 and COLOR.InkBright or Color3.fromRGB(248, 252, 255))
		row.BorderSizePixel = 0
		row.Parent = revealList
		addCorner(row, 7)

		local safe = entry.status == "GO"
		local number = entry.number and tostring(entry.number) or "–"
		local entryName = isMe and "YOU" or tostring(entry.name or "Player")
		local outcomeText
		if safe then
			outcomeText = "GO +" .. tostring(entry.steps or 0)
		elseif entry.out then
			outcomeText = "ELIMINATED"
		elseif entry.status == "NO_VOTE" then
			outcomeText = "NO PICK"
		else
			outcomeText = "CRACK " .. tostring(entry.cracks or 0) .. "/3"
		end
		local who = label(row, "Name", entryName .. "  [" .. number .. "]", 9, 2, -102, 25, 13, COLOR.Text, true)
		who.TextTruncate = Enum.TextTruncate.AtEnd
		local outcome = label(row, "Outcome", outcomeText, 0, 2, -9, 25, 12, safe and COLOR.Green or COLOR.Red, true)
		outcome.AnchorPoint = Vector2.new(1, 0)
		outcome.Position = UDim2.new(1, -8, 0, 2)
		outcome.Size = UDim2.fromOffset(95, 25)
		outcome.TextXAlignment = Enum.TextXAlignment.Right
	end
	revealList.CanvasSize = UDim2.fromOffset(0, #entries * 33)
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
	movement.Size = UDim2.fromOffset(math.min(width - 18, 545), 66)
	movement.Position = UDim2.new(0.5, 0, 1, -26)
	movementText.TextSize = compact and 14 or 17

	local shopW = math.min(width - 20, 350)
	shop.Size = UDim2.fromOffset(shopW, math.max(218, math.min(358, height - 118)))
	shop.AnchorPoint = compact and Vector2.new(0.5, 0.5) or Vector2.new(1, 0.5)
	shop.Position = compact and UDim2.new(0.5, 0, 0.56, 0) or UDim2.new(1, -18, 0.54, 0)

	local revealW = math.min(compact and width - 16 or 322, 322)
	local revealH = math.max(165, math.min(compact and 242 or 388, height - (compact and 156 or 171)))
	reveal.Size = UDim2.fromOffset(revealW, revealH)
	reveal.Position = UDim2.fromOffset(compact and 8 or 11, compact and 103 or 107)
	revealHeader.TextSize = compact and 14 or 16
	revealSubtitle.TextSize = compact and 11 or 13
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
			showFeedback("GREEN TILES · WALK NOW!", true)
		else
			showFeedback("RED TILES · STAY PUT!", false)
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
	phaseText.Text = ("v0.14 · ROUND %d · %s"):format(state.turn or 0, phaseNames[phase] or phase)
	clockText.Text = tostring(state.time or 0) .. "s"
	clockText.TextColor3 = phase == "VOTE" and (state.time or 0) <= 2 and COLOR.Red or COLOR.Purple
	description.Text = state.message or ""

	join.Visible = phase == "JOIN" and state.queued ~= true and (state.ready or 0) < (state.capacity or 8)
	voting.Visible = phase == "VOTE" and mine ~= nil and mine.alive == true
	if voting.Visible then shop.Visible = false end
	movement.Visible = phase == "MOVE" and mine ~= nil and mine.alive == true

	if phase == "JOIN" then
		phaseText.Text = "v0.14 · NEXT MATCH"
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
		phaseText.Text = "v0.14 · ROUND OVER"
		ownStats.Text = "NEXT MATCH STARTS SOON"
	end

	if voting.Visible and mine then
		local hurry = (state.time or 0) <= 2
		voteTitle.Text = hurry and ("CHOOSE NOW · " .. tostring(state.time) .. "s") or "PICK YOUR STEPS · 1–5"
		voteTitle.TextColor3 = hurry and COLOR.Red or COLOR.Text
		voting.BackgroundColor3 = hurry and Color3.fromRGB(255, 245, 230) or COLOR.Ink
		for n, b in ipairs(choiceButtons) do
			b.BackgroundColor3 = mine.vote == n and COLOR.Gold or COLOR.Blue
			b.TextColor3 = mine.vote == n and COLOR.Text or COLOR.White
		end
		voteHint.Text = mine.vote
			and ("Number " .. mine.vote .. " locked in · tap another to change")
			or "Most picked numbers crack · choose before time ends!"
	end

	if movement.Visible and mine then
		local blocked = {}
		for n = 1, 5 do
			if state.unsafe and state.unsafe[n] then table.insert(blocked, tostring(n)) end
		end
		description.Text = #blocked > 0
			and ("BLOCKED: " .. table.concat(blocked, ", ") .. "  ·  Watch your next tile")
			or "NO BLOCKED NUMBERS · Watch your next tile"
		local allowed = mine.allowed or 0
		if allowed > 0 then
			movement.BackgroundColor3 = Color3.fromRGB(220, 252, 231)
			movementText.TextColor3 = Color3.fromRGB(22, 128, 72)
			movementText.Text = ("GO! Walk 1–%d GREEN tiles. Leave your old tile!"):format(allowed)
		else
			movement.BackgroundColor3 = Color3.fromRGB(255, 229, 230)
			movementText.TextColor3 = Color3.fromRGB(198, 47, 68)
			movementText.Text = "STAY! Your next tile is unsafe. Do not walk forward."
		end
	end

	-- Make the full breakdown visible on desktop during walking. On mobile,
	-- display it during REVEAL only, so controls/gameplay remain unobstructed.
	-- Keep racers' walking camera clear, show extended results to observers.
	local observing = mine == nil or mine.alive ~= true
	reveal.Visible = phase == "REVEAL" or (phase == "MOVE" and observing and not isCompact)
	if reveal.Visible then drawOutcomes(state) end


end

join.Visible = false
shop.Visible = false
feedback.Visible = false
voting.Visible = false
movement.Visible = false
reveal.Visible = false
stateEvent.OnClientEvent:Connect(update)
command:FireServer("Sync")
