-- Mythblox game-01: glass bridge race prototype (server)
-- The server owns votes, movement permissions, cracks, results and rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

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
local VIOLET = Color3.fromRGB(145, 110, 255)

-- Visual-only lighting adjustments (these do not affect voting or movement).
Lighting.ClockTime = 18.7
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(71, 85, 128)
Lighting.OutdoorAmbient = Color3.fromRGB(85, 90, 125)
Lighting.FogColor = Color3.fromRGB(30, 32, 70)
Lighting.FogEnd = 500

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
lobby.Position = Vector3.new(0, SETTINGS.BridgeY, -70)
lobby.Material = Enum.Material.SmoothPlastic
lobby.Color = Color3.fromRGB(47, 61, 100)
lobby.Parent = world
textSign(lobby, "MYTHBLOX | GLASS RACE", 8, 350)
-- Subtle lobby lights and floor markings; no additional paths to the lava.
for _, side in ipairs({-1, 1}) do
	local stripe = part(
		"LobbyGlowStrip",
		Vector3.new(1, 0.15, 19),
		Vector3.new(side * 14, SETTINGS.BridgeY + 0.83, -70),
		VIOLET, Enum.Material.Neon
	)
	stripe.CanCollide = false
end
local instructionAnchor = part(
	"LobbyInstructionAnchor",
	Vector3.new(1, 1, 1),
	Vector3.new(0, SETTINGS.BridgeY + 7, -58),
	VIOLET, Enum.Material.Neon
)
instructionAnchor.Transparency = 1
instructionAnchor.CanCollide = false
textSign(instructionAnchor, "JOIN · PICK 1–5 · WALK ONLY ON GREEN", 2, 410)
-- Guard rails keep the waiting area safely away from the lava.
for _, rail in ipairs({
	{ "Back", Vector3.new(36, 5, 1), Vector3.new(0, SETTINGS.BridgeY + 3, -82) },
	{ "Front", Vector3.new(36, 5, 1), Vector3.new(0, SETTINGS.BridgeY + 3, -58) },
	{ "Left", Vector3.new(1, 5, 24), Vector3.new(-17, SETTINGS.BridgeY + 3, -70) },
	{ "Right", Vector3.new(1, 5, 24), Vector3.new(17, SETTINGS.BridgeY + 3, -70) },
}) do
	local wall = part(rail[1] .. "LobbyRail", rail[2], rail[3], Color3.fromRGB(91, 120, 164), Enum.Material.Glass)
	wall.Transparency = 0.35
end

local lava = part("Lava", Vector3.new(105, 2, 235), Vector3.new(0, 7, 68), Color3.fromRGB(255, 91, 30), Enum.Material.Neon)
lava.CanCollide = false
lava.Transparency = 0.12
lava.Touched:Connect(function(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.Health = 0 end
end)

-- Glass lanes do not exist in the lobby. We build exactly one per ready
-- participant after the join countdown has completed.
local lanes = {}
local bridgeModel = nil
local function clearBridges()
	if bridgeModel then bridgeModel:Destroy() end
	bridgeModel = nil
	lanes = {}
end

local function buildBridges(count)
	clearBridges()
	bridgeModel = Instance.new("Model")
	bridgeModel.Name = "CurrentMatchBridges"
	bridgeModel.Parent = world

	for lane = 1, count do
		local x = (lane - (count + 1) / 2) * SETTINGS.LaneSpacing
		lanes[lane] = { x = x, tiles = {} }
		for index = 0, SETTINGS.BridgeLength do
			local tile = part(
				("Lane%02d_Tile%02d"):format(lane, index),
				Vector3.new(6.7, 0.9, 6.7),
				Vector3.new(x, SETTINGS.BridgeY, index * SETTINGS.TileSpacing),
				index == SETTINGS.BridgeLength and AMBER or GLASS,
				Enum.Material.Glass,
				bridgeModel
			)
			tile.Transparency = 0.22
			lanes[lane].tiles[index] = tile
		end
		-- Decorative glowing rails sit below the glass and cannot be stood on.
		-- Only two rails per player, keeping the world small on mobile devices.
		for _, edge in ipairs({-1, 1}) do
			local rail = part(
				("Lane%02d_EdgeGlow"):format(lane),
				Vector3.new(0.35, 0.35, SETTINGS.TileSpacing * SETTINGS.BridgeLength + 7),
				Vector3.new(x + edge * 3.25, SETTINGS.BridgeY - 1.1, SETTINGS.BridgeLength * SETTINGS.TileSpacing / 2),
				VIOLET, Enum.Material.Neon, bridgeModel
			)
			rail.CanCollide = false
			rail.CanTouch = false
			rail.Transparency = 0.32
		end
	end

	-- One shared finish banner, rather than a floating FINISH label per lane.
	local bannerWidth = math.max(12, count * SETTINGS.LaneSpacing)
	local banner = part(
		"SharedFinishBanner",
		Vector3.new(bannerWidth, 1.5, 1.5),
		Vector3.new(0, SETTINGS.BridgeY + 11, SETTINGS.BridgeLength * SETTINGS.TileSpacing),
		AMBER, Enum.Material.Neon, bridgeModel
	)
	banner.CanCollide = false
	textSign(banner, "FINISH", 2, 180)
	for _, edge in ipairs({-1, 1}) do
		local post = part(
			"FinishGlowPost",
			Vector3.new(1.5, 13, 1.5),
			Vector3.new(edge * (bannerWidth / 2 - 1), SETTINGS.BridgeY + 6, SETTINGS.BridgeLength * SETTINGS.TileSpacing),
			AMBER, Enum.Material.Neon, bridgeModel
		)
		post.CanCollide = false
	end
end

local phase = "JOIN"
local secondsLeft = SETTINGS.JoinSeconds
local turnNumber = 0
local queue = {}
local active = {}
local unsafe = {}
local voteCounts = {0, 0, 0, 0, 0}
local voteOutcomes = {}
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
		root.CFrame = CFrame.new(offset, SETTINGS.BridgeY + 4, -70)
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

local function prepareMatchLabels()
	if labelFolder then labelFolder:Destroy() end
	labelFolder = Instance.new("Folder")
	labelFolder.Name = "PlayerLaneLabels"
	labelFolder.Parent = bridgeModel
end

-- Optional particles for important falls. Routine old-tile removal stays lightweight.
local function glassBurst(tile, shade, amount)
	if not tile then return end
	local particles = Instance.new("ParticleEmitter")
	particles.Name = "GlassBurst"
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Rate = 0
	particles.Lifetime = NumberRange.new(0.25, 0.65)
	particles.Speed = NumberRange.new(8, 16)
	particles.SpreadAngle = Vector2.new(160, 160)
	particles.Size = NumberSequence.new(0.35)
	particles.Color = ColorSequence.new(shade)
	particles.LightEmission = 0.8
	particles.EmissionDirection = Enum.NormalId.Top
	particles.Parent = tile
	particles:Emit(amount or 10)
	Debris:AddItem(particles, 1.5)
end

local function showCrackLines(tile, count)
	if not tile then return end
	local overlay = tile:FindFirstChild("DamageLines")
	if not overlay then
		overlay = Instance.new("SurfaceGui")
		overlay.Name = "DamageLines"
		overlay.Face = Enum.NormalId.Top
		overlay.PixelsPerStud = 40
		overlay.AlwaysOnTop = false
		overlay.Parent = tile
	end
	for _, child in ipairs(overlay:GetChildren()) do child:Destroy() end
	for index = 1, count do
		-- Flat UI crack stripes: lightweight and readable from above.
		local line = Instance.new("Frame")
		line.Name = "Crack" .. index
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.Position = UDim2.fromScale(0.5 + ((index % 2) * 0.13 - 0.06), 0.5)
		line.Size = UDim2.fromScale(0.012, 0.78)
		line.Rotation = ({33, -48, 73})[index] or 20
		line.BackgroundColor3 = Color3.fromRGB(30, 36, 56)
		line.BorderSizePixel = 0
		line.Parent = overlay
	end
end

local function shatter(tile, dramatic)
	if not tile or not tile.CanCollide then return end
	if dramatic then glassBurst(tile, RED, 16) end
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
	if tileToBreak then shatter(tileToBreak, true) end
	-- Remove their supporting panel too, so an invalid step always causes a visible fall.
	local standingTile = lanes[info.lane].tiles[info.index]
	if standingTile ~= tileToBreak then shatter(standingTile, true) end
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
		showCrackLines(currentTile, info.cracks)
		glassBurst(currentTile, AMBER, 6)
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
		voteCounts = phase == "VOTE" and {} or voteCounts,
		voteOutcomes = phase == "VOTE" and {} or voteOutcomes,
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
	-- Override any Baseplate SpawnLocation: spawning at (0,0,0) can land
	-- underneath the glass arena and inside its lava region.
	player.RespawnLocation = lobby
	if player.Character then
		task.defer(function()
			if player.Parent == Players then lobbyTeleport(player) end
		end)
	end
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		local info = active[player]
		if not info or not info.alive or phase == "JOIN" or phase == "RESULTS" then
			-- Results-phase respawns are expected; they must not overwrite the win message.
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
	buildBridges(#participants)
	prepareMatchLabels()
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
	local counts = {0, 0, 0, 0, 0}
	local highest = 0
	for player, info in pairs(active) do
		if player.Parent == Players and info.alive and info.vote then
			counts[info.vote] += 1
			highest = math.max(highest, counts[info.vote])
		end
	end
	voteCounts = counts
	unsafe = {}
	if highest >= 2 then
		for choice = 1, 5 do
			if counts[choice] == highest then unsafe[choice] = true end
		end
	end

	local outcomes = {}
	for player, info in pairs(active) do
		if info.alive then
			info.startIndex = info.index
			local status
			if not info.vote then
				status = "NO_VOTE"
				crack(player)
			elseif unsafe[info.vote] then
				status = "CRACK"
				crack(player)
			else
				info.allowed = info.vote
				status = "GO"
			end
			table.insert(outcomes, {
				name = player.DisplayName,
				number = info.vote,
				status = status,
				steps = info.allowed,
				cracks = info.cracks,
				out = not info.alive,
			})
		end
	end
	table.sort(outcomes, function(a, b) return a.name < b.name end)
	voteOutcomes = outcomes
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
	clearBridges()
	if labelFolder then labelFolder = nil end
	queue = {}
	active = {}
	unsafe = {}
	voteCounts = {0, 0, 0, 0, 0}
	voteOutcomes = {}
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
		voteCounts = {0, 0, 0, 0, 0}
		voteOutcomes = {}
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
