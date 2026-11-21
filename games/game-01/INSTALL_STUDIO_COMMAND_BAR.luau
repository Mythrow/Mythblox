-- Mythblox Game 01 — one-paste installation into Roblox Studio's Command Bar.
-- IMPORTANT: Run in EDIT mode, not during Play/Test. This adds 2 scripts.
-- This prototype intentionally has no permanent player-data storage or paid products.

assert(not game:GetService("RunService"):IsRunning(), "Stop the test session before installing.")

local SERVER_SOURCE = [====[
-- Mythblox game-01: glass bridge race prototype (server)
-- The server owns votes, movement permissions, cracks, results and rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SETTINGS = {
	MaxPlayers = 8,
	JoinSeconds = 10,
	VoteSeconds = 5,
	RevealSeconds = 2,
	MoveSeconds = 6,
	ResultsSeconds = 5,
	BridgeLength = 20,
	MaxCracks = 3,
	MaxTurns = 22,
	TileSpacing = 7,
	LaneSpacing = 9,
	BridgeY = 24,
	WalkSpeed = 19,
	StudioSoloPractice = true,
}

local GREEN = Color3.fromRGB(64, 235, 142)
local RED = Color3.fromRGB(255, 85, 84)
local GLASS = Color3.fromRGB(105, 201, 240)
local AMBER = Color3.fromRGB(255, 192, 85)

local oldWorld = workspace:FindFirstChild("MythbloxGame01")
if oldWorld then oldWorld:Destroy() end
local world = Instance.new("Model")
world.Name = "MythbloxGame01"
world.Parent = workspace

local oldNet = ReplicatedStorage:FindFirstChild("MythbloxGame01")
if oldNet then oldNet:Destroy() end
local network = Instance.new("Folder")
network.Name = "MythbloxGame01"
network.Parent = ReplicatedStorage
local command = Instance.new("RemoteEvent")
command.Name = "Command"
command.Parent = network
local stateEvent = Instance.new("RemoteEvent")
stateEvent.Name = "State"
stateEvent.Parent = network

local function part(name, size, position, color, material, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Color = color
	p.Material = material
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or world
	return p
end

local function textSign(parent, text, yOffset, width)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(width or 220, 55)
	gui.StudsOffset = Vector3.new(0, yOffset or 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(23, 29, 48)
	label.BackgroundTransparency = 0.16
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = label
	return gui
end

local lobby = Instance.new("SpawnLocation")
lobby.Name = "MythbloxLobbySpawn"
lobby.Neutral = true
lobby.Duration = 0
lobby.Anchored = true
lobby.Size = Vector3.new(34, 1.5, 24)
lobby.Position = Vector3.new(0, SETTINGS.BridgeY, -39)
lobby.Material = Enum.Material.SmoothPlastic
lobby.Color = Color3.fromRGB(47, 61, 100)
lobby.Parent = world
textSign(lobby, "MYTHBLOX | GLASS RACE", 8, 350)

local lava = part("Lava", Vector3.new(105, 2, 235), Vector3.new(0, 7, 68), Color3.fromRGB(255, 91, 30), Enum.Material.Neon)
lava.CanCollide = false
lava.Transparency = 0.12
lava.Touched:Connect(function(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.Health = 0 end
end)

local lanes = {}
for lane = 1, SETTINGS.MaxPlayers do
	local x = (lane - (SETTINGS.MaxPlayers + 1) / 2) * SETTINGS.LaneSpacing
	lanes[lane] = { x = x, tiles = {} }
	for index = 0, SETTINGS.BridgeLength do
		local tile = part(
			("Lane%02d_Tile%02d"):format(lane, index),
			Vector3.new(6.7, 0.9, 6.7),
			Vector3.new(x, SETTINGS.BridgeY, index * SETTINGS.TileSpacing),
			index == SETTINGS.BridgeLength and AMBER or GLASS,
			Enum.Material.Glass
		)
		tile.Transparency = 0.22
		lanes[lane].tiles[index] = tile
	end
	textSign(lanes[lane].tiles[SETTINGS.BridgeLength], "FINISH", 5, 115)
end

local phase = "JOIN"
local secondsLeft = SETTINGS.JoinSeconds
local turnNumber = 0
local queue = {}
local active = {}
local unsafe = {}
local message = "Join the next match!"
local winnerPlayer = nil
local initialMatchCount = 0
local labelFolder = nil
local publish

local function numberReady()
	local n = 0
	for player in pairs(queue) do
		if player.Parent == Players then n += 1 end
	end
	return n
end

local function survivors()
	local alive = {}
	for player, info in pairs(active) do
		if info.alive and player.Parent == Players then
			table.insert(alive, player)
		end
	end
	return alive
end

local function lobbyTeleport(player)
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if root then
		local offset = math.random(-9, 9)
		root.CFrame = CFrame.new(offset, SETTINGS.BridgeY + 4, -39)
		root.AssemblyLinearVelocity = Vector3.zero
	end
	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		humanoid.JumpHeight = 7.2
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end

local function setWalking(player, canMove)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid then
		humanoid.WalkSpeed = canMove and SETTINGS.WalkSpeed or 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	end
	if not canMove and root then
		local vel = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
	end
end

local function resetTiles()
	for _, lane in ipairs(lanes) do
		for index = 0, SETTINGS.BridgeLength do
			local tile = lane.tiles[index]
			tile.CanCollide = true
			tile.CanTouch = true
			tile.Transparency = 0.22
			tile.Color = index == SETTINGS.BridgeLength and AMBER or GLASS
		end
	end
	if labelFolder then labelFolder:Destroy() end
	labelFolder = Instance.new("Folder")
	labelFolder.Name = "PlayerLaneLabels"
	labelFolder.Parent = world
end

local function shatter(tile)
	if not tile or not tile.CanCollide then return end
	tile.CanCollide = false
	tile.CanTouch = false
	tile.Color = RED
	TweenService:Create(tile, TweenInfo.new(0.3), {Transparency = 1}):Play()
end

local function eliminate(player, reason, tileToBreak)
	local info = active[player]
	if not info or not info.alive then return end
	info.alive = false
	info.elimination = reason
	info.allowed = 0
	setWalking(player, false)
	if tileToBreak then shatter(tileToBreak) end
	-- Remove their supporting panel too, so an invalid step always causes a visible fall.
	local standingTile = lanes[info.lane].tiles[info.index]
	if standingTile ~= tileToBreak then shatter(standingTile) end
	message = player.DisplayName .. " fell! (" .. reason .. ")"
	if publish then publish() end
end

local function crack(player)
	local info = active[player]
	if not info or not info.alive then return end
	info.cracks += 1
	info.allowed = 0
	local currentTile = lanes[info.lane].tiles[info.index]
	if info.cracks >= SETTINGS.MaxCracks then
		eliminate(player, "three cracks", currentTile)
	else
		currentTile.Color = info.cracks == 1 and AMBER or RED
	end
end

local function paintAllowedTiles()
	for player, info in pairs(active) do
		if info.alive then
			local lane = lanes[info.lane]
			local current = lane.tiles[info.index]
			if current and current.CanCollide then
				current.Color = info.cracks == 0 and GLASS or (info.cracks == 1 and AMBER or RED)
			end
			if phase == "MOVE" then
				local from = info.startIndex + 1
				for i = from, math.min(info.startIndex + info.allowed, SETTINGS.BridgeLength) do
					if lane.tiles[i] and lane.tiles[i].CanCollide then
						lane.tiles[i].Color = GREEN
					end
				end
				local nextUnsafe = info.startIndex + info.allowed + 1
				if nextUnsafe <= SETTINGS.BridgeLength and lane.tiles[nextUnsafe].CanCollide then
					lane.tiles[nextUnsafe].Color = RED
				end
			end
		end
	end
end

local function publicRoster()
	local roster = {}
	for player, info in pairs(active) do
		table.insert(roster, {
			name = player.DisplayName,
			position = info.index,
			cracks = info.cracks,
			alive = info.alive,
			vote = phase == "VOTE" and nil or info.vote,
		})
	end
	table.sort(roster, function(a, b)
		return a.position > b.position
	end)
	return roster
end

local function snapshot(player)
	local mine = active[player]
	return {
		phase = phase,
		time = secondsLeft,
		turn = turnNumber,
		ready = numberReady(),
		capacity = SETTINGS.MaxPlayers,
		queued = queue[player] == true,
		participating = mine ~= nil,
		mine = mine and {
			position = mine.index,
			cracks = mine.cracks,
			alive = mine.alive,
			vote = mine.vote,
			allowed = mine.allowed,
			start = mine.startIndex,
		} or nil,
		unsafe = unsafe,
		roster = publicRoster(),
		message = message,
	}
end

publish = function()
	for _, player in ipairs(Players:GetPlayers()) do
		stateEvent:FireClient(player, snapshot(player))
	end
end

local function makeLeaderstats(player)
	if player:FindFirstChild("leaderstats") then return end
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player
	for _, name in ipairs({"Wins", "Coins"}) do
		local val = Instance.new("IntValue")
		val.Name = name
		val.Value = 0
		val.Parent = folder
	end
end

local function onPlayerAdded(player)
	makeLeaderstats(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		local info = active[player]
		if not info or not info.alive then
			lobbyTeleport(player)
		else
			-- A respawn while actively competing must not restore the player.
			eliminate(player, "respawned", nil)
			lobbyTeleport(player)
		end
	end)
	task.delay(1, function()
		if player.Parent == Players then stateEvent:FireClient(player, snapshot(player)) end
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end

Players.PlayerRemoving:Connect(function(player)
	queue[player] = nil
	if active[player] and active[player].alive then
		eliminate(player, "left the server", nil)
	end
end)

command.OnServerEvent:Connect(function(player, action, payload)
	if typeof(action) ~= "string" then return end
	if action == "Sync" then
		stateEvent:FireClient(player, snapshot(player))
	elseif action == "Join" then
		if phase ~= "JOIN" or queue[player] or numberReady() >= SETTINGS.MaxPlayers then return end
		queue[player] = true
		publish()
	elseif action == "Vote" then
		if phase ~= "VOTE" then return end
		local info = active[player]
		if not info or not info.alive then return end
		if typeof(payload) ~= "number" or payload % 1 ~= 0 or payload < 1 or payload > 5 then return end
		info.vote = payload
		stateEvent:FireClient(player, snapshot(player))
	end
end)

local function teleportToLane(player, lane)
	local character = player.Character
	if not character then player:LoadCharacter() end
	character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if root then
		local position = Vector3.new(lanes[lane].x, SETTINGS.BridgeY + 4, 0)
		root.CFrame = CFrame.lookAt(position, position + Vector3.new(0, 0, 1))
		root.AssemblyLinearVelocity = Vector3.zero
	end
	if humanoid then
		humanoid.Health = humanoid.MaxHealth
		humanoid.Died:Connect(function()
			if active[player] and active[player].alive then
				eliminate(player, "fell into lava", nil)
			end
		end)
	end
	setWalking(player, false)
	return root
end

local function countdown(duration, stopIfFinished)
	for remaining = duration, 1, -1 do
		secondsLeft = remaining
		publish()
		task.wait(1)
		if stopIfFinished and winnerPlayer then break end
	end
	secondsLeft = 0
	publish()
end

local function finishersOrSurvivor()
	if winnerPlayer then return {winnerPlayer} end
	local alive = survivors()
	if #alive == 1 and initialMatchCount >= 2 then return {alive[1]} end
	if #alive == 0 then return {} end
	return nil
end

-- Server-side stepped tile validation; the client never tells the server its position.
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < 0.09 then return end
	accumulator = 0
	if phase ~= "MOVE" and phase ~= "VOTE" and phase ~= "REVEAL" then return end
	for player, info in pairs(active) do
		if info.alive then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not root or not humanoid or humanoid.Health <= 0 then
				eliminate(player, "character missing", nil)
			else
				local pos = root.Position
				local lane = lanes[info.lane]
				local observed = math.floor(pos.Z / SETTINGS.TileSpacing + 0.5)
				local xGap = math.abs(pos.X - lane.x)
				if pos.Y < SETTINGS.BridgeY - 7 then
					eliminate(player, "fell into lava", nil)
				elseif xGap > SETTINGS.LaneSpacing * 0.60 then
					eliminate(player, "left the lane", nil)
				elseif observed > info.index + 1 then
					local badTile = lane.tiles[math.min(observed, SETTINGS.BridgeLength)]
					eliminate(player, "skipped a tile", badTile)
				elseif phase ~= "MOVE" and observed > info.index then
					eliminate(player, "stepped before the reveal", lane.tiles[math.min(observed, SETTINGS.BridgeLength)])
				elseif phase == "MOVE" then
					local limit = info.startIndex + info.allowed
					if observed > limit then
						eliminate(player, "stepped onto forbidden glass", lane.tiles[math.min(observed, SETTINGS.BridgeLength)])
					elseif observed < info.startIndex then
						eliminate(player, "went backwards", lane.tiles[math.max(0, observed)])
					elseif observed ~= info.index and observed >= 0 then
						info.index = observed
						if observed >= SETTINGS.BridgeLength and not winnerPlayer then
							winnerPlayer = player
							message = player.DisplayName .. " reached the finish!"
						end
					end
				end
			end
		end
	end
end)

local function beginMatch(participants)
	initialMatchCount = #participants
	active = {}
	unsafe = {}
	winnerPlayer = nil
	turnNumber = 0
	resetTiles()
	for lane, player in ipairs(participants) do
		if player.Parent == Players then
			local root = teleportToLane(player, lane)
			active[player] = {
				lane = lane,
				index = 0,
				startIndex = 0,
				allowed = 0,
				vote = nil,
				cracks = 0,
				alive = true,
				root = root,
			}
			local sign = textSign(lanes[lane].tiles[0], player.DisplayName, 5, 175)
			sign.Parent = labelFolder
			sign.Adornee = lanes[lane].tiles[0]
		end
	end
end

local function resolveVotes()
	local counts = {}
	local highest = 0
	for player, info in pairs(active) do
		if player.Parent == Players and info.alive and info.vote then
			counts[info.vote] = (counts[info.vote] or 0) + 1
			highest = math.max(highest, counts[info.vote])
		end
	end
	unsafe = {}
	if highest >= 2 then
		for choice, count in pairs(counts) do
			if count == highest then unsafe[choice] = true end
		end
	end
	for player, info in pairs(active) do
		if info.alive then
			info.startIndex = info.index
			if not info.vote or unsafe[info.vote] then
				crack(player)
			else
				info.allowed = info.vote
			end
		end
	end
end

local function finishMovePhase()
	for player, info in pairs(active) do
		if info.alive then
			setWalking(player, false)
			if info.allowed > 0 then
				if info.index <= info.startIndex then
					eliminate(player, "did not leave the old tile", lanes[info.lane].tiles[info.startIndex])
				else
					-- Old glass disappears as the next voting round begins.
					for i = 0, info.index - 1 do
						shatter(lanes[info.lane].tiles[i])
					end
				end
			end
			info.allowed = 0
		end
	end
end

local function scoreMatch(winners, participants)
	local awarded = {}
	for _, player in ipairs(winners) do awarded[player] = true end
	for _, player in ipairs(participants) do
		if player.Parent == Players then
			local stats = player:FindFirstChild("leaderstats")
			if stats then
				local wins = stats:FindFirstChild("Wins")
				local coins = stats:FindFirstChild("Coins")
				if coins then coins.Value += awarded[player] and 25 or 5 end
				if wins and awarded[player] then wins.Value += 1 end
			end
		end
	end
end

while true do
	phase = "JOIN"
	queue = {}
	active = {}
	unsafe = {}
	message = "Press JOIN to enter the next bridge race."
	countdown(SETTINGS.JoinSeconds, false)
	local participants = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if queue[player] and #participants < SETTINGS.MaxPlayers then
			table.insert(participants, player)
		end
	end
	local minimum = (RunService:IsStudio() and SETTINGS.StudioSoloPractice) and 1 or 2
	if #participants < minimum then
		phase = "RESULTS"
		message = "Need at least two ready players. Join next countdown!"
		secondsLeft = 2
		publish()
		task.wait(2)
		continue
	end

	beginMatch(participants)
	local winners = nil
	for turn = 1, SETTINGS.MaxTurns do
		turnNumber = turn
		phase = "VOTE"
		unsafe = {}
		message = "Secretly choose 1–5 steps. Most popular picks crack!"
		for _, info in pairs(active) do info.vote = nil end
		for player, info in pairs(active) do
			if info.alive then setWalking(player, false) end
		end
		countdown(SETTINGS.VoteSeconds, false)

		phase = "REVEAL"
		resolveVotes()
		message = "Unsafe: " .. (function()
			local s = {}
			for i = 1, 5 do if unsafe[i] then table.insert(s, tostring(i)) end end
			return #s > 0 and table.concat(s, ", ") or "none"
		end)() .. ". Watch your glass!"
		paintAllowedTiles()
		countdown(SETTINGS.RevealSeconds, false)

		winners = finishersOrSurvivor()
		if winners then break end

		phase = "MOVE"
		message = "GREEN = walk forward up to your number. RED = STAY!"
		for player, info in pairs(active) do
			if info.alive then
				-- Players who must STAY may still walk; stepping onto red glass is the joke.
				setWalking(player, true)
			end
		end
		paintAllowedTiles()
		countdown(SETTINGS.MoveSeconds, true)
		finishMovePhase()
		winners = finishersOrSurvivor()
		if winners then break end
	end

	if not winners then
		local best = -1
		winners = {}
		for player, info in pairs(active) do
			if info.alive then
				if info.index > best then best = info.index; winners = {player}
				elseif info.index == best then table.insert(winners, player) end
			end
		end
	end

	phase = "RESULTS"
	unsafe = {}
	if #winners == 0 then
		message = "DRAW — every bridge fell! Next race soon."
	elseif #winners == 1 then
		message = winners[1].DisplayName .. " WINS! +25 coins"
	else
		message = "TIE! " .. #winners .. " players share the win (+25 each)."
	end
	scoreMatch(winners, participants)
	countdown(SETTINGS.ResultsSeconds, false)
	for _, player in ipairs(participants) do
		if player.Parent == Players then player:LoadCharacter() end
	end
	task.wait(0.5)
end
]====]

local CLIENT_SOURCE = [====[
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

local phaseLabels = {
	JOIN = "JOINING",
	VOTE = "SECRET VOTE",
	REVEAL = "REVEAL",
	MOVE = "MOVE / STAY",
	RESULTS = "RESULT",
}

local function update(state)
	local phase = state.phase or "JOIN"
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
stateEvent.OnClientEvent:Connect(update)
command:FireServer("Sync")
]====]

local function install(where, kind, name, source)
	local existing = where:FindFirstChild(name)
	if existing then existing:Destroy() end
	local instance = Instance.new(kind)
	instance.Name = name
	instance.Enabled = false
	instance.Source = source
	instance.Parent = where
	instance.Enabled = true
	return instance
end

install(game:GetService("ServerScriptService"), "Script", "MythbloxGame", SERVER_SOURCE)
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "LocalScript", "MythbloxGame", CLIENT_SOURCE)
print("[Mythblox] Game 01 installed. Test with Play, or Test > Server & Clients (2 clients). The arena appears during Play.")
