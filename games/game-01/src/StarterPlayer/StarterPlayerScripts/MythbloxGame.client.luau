-- Mythblox game-01: glass bridge race prototype (client)
-- Client only renders UI and submits requests; the server decides all outcomes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local network = ReplicatedStorage:WaitForChild("MythbloxGame01")
local command = network:WaitForChild("Command")
local stateEvent = network:WaitForChild("State")

local old = playerGui:FindFirstChild("MythbloxGame01UI")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "MythbloxGame01UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local WHITE = Color3.fromRGB(245, 248, 255)
local MUTED = Color3.fromRGB(183, 197, 219)
local BLUE = Color3.fromRGB(52, 122, 223)
local GREEN = Color3.fromRGB(44, 166, 104)
local GOLD = Color3.fromRGB(232, 164, 49)
local DARK = Color3.fromRGB(21, 30, 52)

local function rounded(frame, pixels)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, pixels)
	c.Parent = frame
end

local function panel(name, position, size, anchor)
	local f = Instance.new("Frame")
	f.Name = name
	f.Position = position
	f.Size = size
	f.AnchorPoint = anchor or Vector2.zero
	f.BackgroundColor3 = DARK
	f.BackgroundTransparency = 0.1
	f.BorderSizePixel = 0
	f.Parent = gui
	rounded(f, 14)
	return f
end

local function text(parent, name, content, position, size, font, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = content
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.TextColor3 = color or WHITE
	label.Font = font or Enum.Font.Gotham
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function button(parent, name, content, color)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = content
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.TextColor3 = WHITE
	b.BackgroundColor3 = color or BLUE
	b.BorderSizePixel = 0
	b.AutoButtonColor = true
	b.Parent = parent
	rounded(b, 10)
	return b
end

local top = panel("MainHUD", UDim2.new(0.5, 0, 0, 10), UDim2.new(0.9, 0, 0, 130), Vector2.new(0.5, 0))
local topConstraint = Instance.new("UISizeConstraint")
topConstraint.MaxSize = Vector2.new(610, 130)
topConstraint.Parent = top
local title = text(top, "Title", "GLASS BRIDGE · PROTOTYPE", UDim2.new(0.04, 0, 0.04, 0), UDim2.new(0.92, 0, 0, 26), Enum.Font.GothamBold)
local timer = text(top, "Timer", "", UDim2.new(0.04, 0, 0.30, 0), UDim2.new(0.92, 0, 0, 25), Enum.Font.GothamBold, GOLD)
local description = text(top, "Description", "Press JOIN to enter the next race.", UDim2.new(0.04, 0, 0.50, 0), UDim2.new(0.92, 0, 0, 33), Enum.Font.Gotham, WHITE)
local personal = text(top, "MyProgress", "", UDim2.new(0.04, 0, 0.79, 0), UDim2.new(0.92, 0, 0, 20), Enum.Font.GothamBold, MUTED)

local ranks = panel("Standings", UDim2.new(1, -8, 0, 150), UDim2.fromOffset(200, 125), Vector2.new(1, 0))
ranks.BackgroundTransparency = 0.24
local ranksTitle = text(ranks, "Header", "BRIDGE POSITIONS", UDim2.new(0.06, 0, 0.06, 0), UDim2.new(0.88, 0, 0, 20), Enum.Font.GothamBold, GOLD)
local ranksBody = text(ranks, "Entries", "Waiting for players...", UDim2.new(0.06, 0, 0.26, 0), UDim2.new(0.88, 0, 0, 88), Enum.Font.Gotham, WHITE)
ranksBody.TextYAlignment = Enum.TextYAlignment.Top
ranksBody.TextXAlignment = Enum.TextXAlignment.Left

local join = button(gui, "JoinButton", "JOIN NEXT MATCH", GREEN)
join.Size = UDim2.new(0.74, 0, 0, 58)
join.Position = UDim2.new(0.5, 0, 0.78, 0)
join.AnchorPoint = Vector2.new(0.5, 0)
local joinConstraint = Instance.new("UISizeConstraint")
joinConstraint.MaxSize = Vector2.new(370, 58)
joinConstraint.Parent = join
join.MouseButton1Click:Connect(function()
	command:FireServer("Join")
	join.Visible = false
end)

local choicePanel = panel("ChooseNumber", UDim2.new(0.5, 0, 0.72, 0), UDim2.new(0.91, 0, 0, 123), Vector2.new(0.5, 0))
local choiceConstraint = Instance.new("UISizeConstraint")
choiceConstraint.MaxSize = Vector2.new(510, 123)
choiceConstraint.Parent = choicePanel
local instructions = text(choicePanel, "Instructions", "CHOOSE 1–5 STEPS · POPULAR PICKS CRACK", UDim2.new(0.04, 0, 0.03, 0), UDim2.new(0.92, 0, 0, 30), Enum.Font.GothamBold, WHITE)

local numberRow = Instance.new("Frame")
numberRow.BackgroundTransparency = 1
numberRow.Position = UDim2.new(0.03, 0, 0.30, 0)
numberRow.Size = UDim2.new(0.94, 0, 0, 75)
numberRow.Parent = choicePanel
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0.015, 0)
layout.Parent = numberRow

local buttons = {}
local lastVote = nil
for n = 1, 5 do
	local b = button(numberRow, "Choice" .. n, tostring(n), BLUE)
	b.LayoutOrder = n
	b.Size = UDim2.new(0.185, 0, 0, 65)
	buttons[n] = b
	b.MouseButton1Click:Connect(function()
		lastVote = n
		command:FireServer("Vote", n)
		for choice, other in pairs(buttons) do
			other.BackgroundColor3 = choice == n and GOLD or BLUE
		end
	end)
end

local hint = panel("MovementHint", UDim2.new(0.5, 0, 0.76, 0), UDim2.new(0.91, 0, 0, 58), Vector2.new(0.5, 0))
local hintConstraint = Instance.new("UISizeConstraint")
hintConstraint.MaxSize = Vector2.new(510, 58)
hintConstraint.Parent = hint
local hintText = text(hint, "Hint", "", UDim2.new(0.04, 0, 0.12, 0), UDim2.new(0.92, 0, 0.76, 0), Enum.Font.GothamBold, WHITE)

-- During the reveal and movement phases, show exactly how every player voted.
-- This is read-only: all vote counts/outcomes come from the server.
local revealPanel = panel("VoteReveal", UDim2.fromOffset(10, 150), UDim2.fromOffset(265, 270))
revealPanel.BackgroundTransparency = 0.05

local revealTitle = text(revealPanel, "RevealTitle", "VOTE RESULTS", UDim2.new(0, 10, 0, 8), UDim2.new(1, -20, 0, 26), Enum.Font.GothamBold, GOLD)
revealTitle.TextXAlignment = Enum.TextXAlignment.Left
revealTitle.TextScaled = false
revealTitle.TextSize = 17

local countLine = text(revealPanel, "VoteCounts", "1:0  2:0  3:0  4:0  5:0", UDim2.new(0, 10, 0, 39), UDim2.new(1, -20, 0, 26), Enum.Font.GothamBold, WHITE)
countLine.TextXAlignment = Enum.TextXAlignment.Left
countLine.TextScaled = false
countLine.TextSize = 15

local nameRows = Instance.new("Frame")
nameRows.Name = "PlayersAndPicks"
nameRows.BackgroundTransparency = 1
nameRows.Position = UDim2.new(0, 10, 0, 75)
nameRows.Size = UDim2.new(1, -20, 1, -85)
nameRows.Parent = revealPanel

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Vertical
rowLayout.Padding = UDim.new(0, 2)
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Parent = nameRows

local cachedRevealKey = ""
local function updateRevealBoard(state)
	local visible = state.phase == "REVEAL" or state.phase == "MOVE" or state.phase == "RESULTS"
	revealPanel.Visible = visible and state.turn > 0
	if not revealPanel.Visible then return end

	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1200, 700)
	local compact = viewport.X < 700
	revealPanel.Size = UDim2.fromOffset(compact and 193 or 265, 270)
	countLine.TextSize = compact and 12 or 15

	local counts = state.voteCounts or {}
	local nums = {}
	for n = 1, 5 do
		table.insert(nums, ("%d:%d"):format(n, counts[n] or 0))
	end
	countLine.Text = table.concat(nums, "   ")

	local cacheKey = tostring(state.turn) .. ":" .. tostring(state.phase == "RESULTS")
	if cachedRevealKey == cacheKey then return end
	cachedRevealKey = cacheKey
	for _, child in ipairs(nameRows:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end

	for i, result in ipairs(state.voteOutcomes or {}) do
		local label = Instance.new("TextLabel")
		label.Name = "VoteRow" .. i
		label.LayoutOrder = i
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0, 21)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextScaled = false
		label.TextSize = compact and 12 or 14
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.Font = Enum.Font.GothamMedium
		label.TextColor3 = result.status == "GO" and Color3.fromRGB(95, 245, 154) or Color3.fromRGB(255, 121, 111)
		local name = tostring(result.name or "Player")
		local selection = result.number and tostring(result.number) or "-"
		local outcome
		if result.status == "GO" then
			outcome = "MOVE " .. tostring(result.steps or 0)
		elseif result.status == "NO_VOTE" then
			outcome = "NO PICK · CRACK"
		else
			outcome = result.out and "OUT" or "CRACK " .. tostring(result.cracks or 0) .. "/3"
		end
		label.Text = name .. "  [" .. selection .. "]  " .. outcome
		label.Parent = nameRows
	end
end

local phaseLabels = {
	JOIN = "JOINING",
	VOTE = "SECRET VOTE",
	REVEAL = "REVEAL",
	MOVE = "MOVE / STAY",
	RESULTS = "RESULT",
}

local function update(state)
	local phase = state.phase or "JOIN"
	updateRevealBoard(state)
	local mine = state.mine
	timer.Text = ("%s  ·  %ds  ·  Turn %d"):format(phaseLabels[phase] or phase, state.time or 0, state.turn or 0)
	description.Text = state.message or ""
	join.Visible = phase == "JOIN" and not state.queued and (state.ready or 0) < (state.capacity or 8)
	choicePanel.Visible = phase == "VOTE" and mine ~= nil and mine.alive == true
	hint.Visible = phase == "MOVE" and mine ~= nil and mine.alive == true
	ranks.Visible = phase ~= "JOIN" and phase ~= "RESULTS"

	if phase == "JOIN" then
		timer.Text = ("JOINING · %ds · %d/%d ready"):format(state.time or 0, state.ready or 0, state.capacity or 8)
		if state.queued then
			personal.Text = "Joined! Waiting for countdown..."
		else
			personal.Text = "Join for the next bridge race."
		end
	elseif mine then
		local vote = mine.vote and tostring(mine.vote) or "—"
		personal.Text = ("Tiles: %d/20   ·   Cracks: %d/3   ·   Pick: %s"):format(mine.position or 0, mine.cracks or 0, vote)
		if not mine.alive then
			personal.Text = personal.Text .. "   ·   ELIMINATED"
		end
	else
		personal.Text = "Spectating · join during the next countdown."
	end

	if phase == "VOTE" and mine then
		lastVote = mine.vote or lastVote
		for n, b in pairs(buttons) do
			b.BackgroundColor3 = mine.vote == n and GOLD or BLUE
		end
	else
		lastVote = nil
	end

	if hint.Visible and mine then
		if (mine.allowed or 0) > 0 then
			hint.BackgroundColor3 = Color3.fromRGB(20, 88, 58)
			hintText.Text = ("GO! Walk 1–%d green tiles before time runs out."):format(mine.allowed)
		else
			hint.BackgroundColor3 = Color3.fromRGB(115, 40, 41)
			hintText.Text = "STAY! Your next tile is unsafe. Do not step ahead."
		end
	end

	local entries = {}
	for index, info in ipairs(state.roster or {}) do
		if index > 5 then break end
		table.insert(entries, ("%s  ·  %d/20%s"):format(
			info.name or "Player",
			info.position or 0,
			not info.alive and " (OUT)" or ""
		))
	end
	ranksBody.Text = #entries > 0 and table.concat(entries, "\n") or "Waiting..."
end

join.Visible = false
choicePanel.Visible = false
hint.Visible = false
revealPanel.Visible = false
stateEvent.OnClientEvent:Connect(update)
command:FireServer("Sync")
