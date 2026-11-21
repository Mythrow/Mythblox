-- Mythblox Game 01 · bright Roblox-style visuals v0.4
-- Presentation only. The server still owns votes, movement, cracks, winners and coins.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local network = ReplicatedStorage:WaitForChild("MythbloxGame01")
local command = network:WaitForChild("Command")
local stateEvent = network:WaitForChild("State")

local previous = playerGui:FindFirstChild("MythbloxGame01UI")
if previous then previous:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MythbloxGame01UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 10
gui.Parent = playerGui

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

-- Top status panel: always visible and readable on narrow screens.
local top = panel("StatusPanel")
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 8)
local phaseText = label(top, "Phase", "JOINING", 16, 7, -125, 25, 17, COLOR.Purple, true)
local clockText = label(top, "Clock", "10s", 16, 7, -32, 26, 21, COLOR.Purple, true)
clockText.TextXAlignment = Enum.TextXAlignment.Right
local description = label(top, "Guidance", "Join the next round.", 16, 36, -32, 47, 15, COLOR.Text, false)
local ownStats = label(top, "Progress", "", 16, 86, -32, 24, 14, COLOR.Muted, true)
local progressBackground = Instance.new("Frame")
progressBackground.Name = "ProgressTrack"
progressBackground.Position = UDim2.new(0, 16, 1, -12)
progressBackground.Size = UDim2.new(1, -32, 0, 5)
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

-- Optional standings on desktop; hidden on smaller screens.
local standings = panel("Standings")
standings.AnchorPoint = Vector2.new(1, 0)
local standingsHeader = label(standings, "Header", "LEADERBOARD", 12, 7, -24, 27, 15, COLOR.Purple, true)
local standingsRows = label(standings, "Rows", "Waiting for racers", 12, 40, -24, 128, 13, COLOR.Text)
standingsRows.TextYAlignment = Enum.TextYAlignment.Top

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
	b.MouseButton1Click:Connect(function()
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

-- A strong result banner, instead of using only small status text.
local result = panel("ResultPanel")
result.AnchorPoint = Vector2.new(0.5, 0.5)
result.Position = UDim2.fromScale(0.5, 0.48)
local resultKicker = label(result, "Kicker", "ROUND COMPLETE", 18, 10, -36, 30, 17, COLOR.Purple, true)
resultKicker.TextXAlignment = Enum.TextXAlignment.Center
local resultMessage = label(result, "Winner", "", 18, 43, -36, 76, 22, COLOR.Text, true)
resultMessage.TextXAlignment = Enum.TextXAlignment.Center

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
		row.BackgroundColor3 = idx % 2 == 0 and COLOR.InkBright or Color3.fromRGB(248, 252, 255)
		row.BorderSizePixel = 0
		row.Parent = revealList
		addCorner(row, 7)

		local safe = entry.status == "GO"
		local number = entry.number and tostring(entry.number) or "–"
		local entryName = tostring(entry.name or "Player")
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

local isCompact = false
local function layoutForViewport()
	local cam = workspace.CurrentCamera
	local view = cam and cam.ViewportSize or Vector2.new(1100, 700)
	local width = math.max(300, view.X)
	local height = math.max(320, view.Y)
	local compact = width < 760
	isCompact = compact
	local shortScreen = height < 570

	local topW = math.min(width - 16, compact and 530 or 610)
	top.Size = UDim2.fromOffset(topW, compact and 120 or 132)
	phaseText.Size = UDim2.new(1, -116, 0, 25)
	clockText.Position = UDim2.new(1, -103, 0, 7)
	clockText.Size = UDim2.fromOffset(86, 26)
	description.Position = UDim2.fromOffset(16, 35)
	description.Size = UDim2.new(1, -32, 0, compact and 43 or 48)
	description.TextSize = compact and 13 or 15
	ownStats.Position = UDim2.new(0, 16, 1, -38)
	ownStats.Size = UDim2.new(1, -32, 0, 20)
	ownStats.TextSize = compact and 12 or 14

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

	result.Size = UDim2.fromOffset(math.min(width - 18, 550), 135)
	resultMessage.TextSize = compact and 17 or 22

	standings.Visible = not compact
	standings.Position = UDim2.new(1, -10, 0, 148)
	standings.Size = UDim2.fromOffset(232, 186)

	local revealW = math.min(compact and width - 16 or 322, 322)
	local revealH = math.max(165, math.min(compact and 242 or 388, height - (compact and 156 or 171)))
	reveal.Size = UDim2.fromOffset(revealW, revealH)
	reveal.Position = UDim2.fromOffset(compact and 8 or 11, compact and 136 or 150)
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
	JOIN = "JOIN THE ROUND",
	VOTE = "SECRET VOTE",
	REVEAL = "THE NUMBERS ARE IN",
	MOVE = "MOVE OR STAY",
	RESULTS = "MATCH RESULTS",
}

local function update(state)
	local phase = state.phase or "JOIN"
	-- Turn numbers restart every match; never reuse a previous match's vote rows.
	if phase == "JOIN" or phase == "VOTE" then
		lastTurnRendered = -1
	end
	local mine = state.mine
	phaseText.Text = ("ROUND %d  ·  %s"):format(state.turn or 0, phaseNames[phase] or phase)
	clockText.Text = tostring(state.time or 0) .. "s"
	description.Text = state.message or ""

	join.Visible = phase == "JOIN" and state.queued ~= true and (state.ready or 0) < (state.capacity or 8)
	voting.Visible = phase == "VOTE" and mine ~= nil and mine.alive == true
	movement.Visible = phase == "MOVE" and mine ~= nil and mine.alive == true
	result.Visible = phase == "RESULTS"

	if phase == "JOIN" then
		phaseText.Text = ("JOIN THE ROUND  ·  %d/%d READY"):format(state.ready or 0, state.capacity or 8)
		ownStats.Text = state.queued and "You're in! The match starts after the countdown."
			or "Press JOIN to reserve your bridge."
		progressFill.Size = UDim2.fromScale(0, 1)
	elseif mine then
		local selection = mine.vote and tostring(mine.vote) or "—"
		local marker = mine.alive and "" or "   ·   ELIMINATED"
		ownStats.Text = ("DISTANCE %d/20   ·   CRACKS %d/3   ·   PICK %s%s"):format(
			mine.position or 0, mine.cracks or 0, selection, marker
		)
		progressFill.Size = UDim2.fromScale(math.clamp((mine.position or 0) / 20, 0, 1), 1)
	else
		ownStats.Text = "SPECTATING  ·  Join when the next countdown begins."
		progressFill.Size = UDim2.fromScale(0, 1)
	end

	if voting.Visible and mine then
		for n, b in ipairs(choiceButtons) do
			b.BackgroundColor3 = mine.vote == n and COLOR.Gold or COLOR.Blue
			b.TextColor3 = mine.vote == n and COLOR.Text or COLOR.White
		end
		voteHint.Text = mine.vote
			and ("Number " .. mine.vote .. " locked in · tap another to change")
			or "Most picked numbers crack · choose before time ends!"
	end

	if movement.Visible and mine then
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

	if result.Visible then
		resultMessage.Text = state.message or "Next race starts soon."
	end

	-- Make the full breakdown visible on desktop during walking. On mobile,
	-- display it during REVEAL only, so controls/gameplay remain unobstructed.
	reveal.Visible = phase == "REVEAL" or (phase == "MOVE" and not isCompact)
	if reveal.Visible then drawOutcomes(state) end

	local rows = {}
	for index, entry in ipairs(state.roster or {}) do
		if index > 6 then break end
		local status = entry.alive and ("· " .. tostring(entry.cracks or 0) .. " cracks") or "· OUT"
		table.insert(rows, ("%d. %s  ·  %d/20 %s"):format(
			index, tostring(entry.name or "Player"), entry.position or 0, status
		))
	end
	standingsRows.Text = #rows > 0 and table.concat(rows, "\n") or "Waiting for racers..."
end

join.Visible = false
voting.Visible = false
movement.Visible = false
result.Visible = false
reveal.Visible = false
stateEvent.OnClientEvent:Connect(update)
command:FireServer("Sync")
