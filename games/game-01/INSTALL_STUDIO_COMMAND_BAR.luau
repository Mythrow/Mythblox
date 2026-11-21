-- Mythblox Game 01 — one-paste installation into Roblox Studio's Command Bar.
-- IMPORTANT: Run in EDIT mode, not during Play/Test. This REPLACES the two MythbloxGame scripts.
-- This prototype intentionally has no permanent player-data storage or paid products.

assert(not game:GetService("RunService"):IsRunning(), "Stop the test session before installing.")

local SERVER_SOURCE = [====[
-- Mythblox game-01: glass bridge race v0.11 (server)
-- The server owns votes, movement permissions, cracks, results and rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local BUILD_VERSION = "v0.11"

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

-- Bright, classic Roblox palette. Visuals do not change gameplay permissions.
local GREEN = Color3.fromRGB(51, 220, 105)
local RED = Color3.fromRGB(255, 87, 87)
local GLASS = Color3.fromRGB(138, 222, 248)
local AMBER = Color3.fromRGB(255, 206, 75)
local VIOLET = Color3.fromRGB(65, 173, 253) -- sky-blue accent, variable kept for compat.

-- Sunny daytime instead of the previous dark neon/dusk atmosphere.
Lighting.ClockTime = 13.5
Lighting.Brightness = 3
Lighting.Ambient = Color3.fromRGB(194, 211, 235)
Lighting.OutdoorAmbient = Color3.fromRGB(216, 229, 247)
Lighting.FogColor = Color3.fromRGB(198, 230, 255)
Lighting.FogEnd = 1400

-- Remove only the stock Baseplate SpawnLocation: its star icon is visible
-- beneath the arena's lava even though our players use the elevated lobby.
-- Ignore custom spawns elsewhere in the place.
local function removeBaseplateSpawn()
	local removed = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("SpawnLocation") and obj.Name == "SpawnLocation"
			and math.abs(obj.Position.X) < 24
			and math.abs(obj.Position.Z) < 24
			and obj.Position.Y < SETTINGS.BridgeY - 10 then
			obj.Enabled = false
			obj:Destroy()
			removed += 1
		end
	end
	if removed > 0 then
		print("[Mythblox] Hidden old baseplate spawn(s): " .. removed)
	end
end
removeBaseplateSpawn()

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
local buildTag = Instance.new("StringValue")
buildTag.Name = "BuildVersion"
buildTag.Value = BUILD_VERSION
buildTag.Parent = network
print("[Mythblox] SERVER RUNNING " .. BUILD_VERSION .. " (bridge race)")

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

-- World-space signage: a fixed 3D board, NOT a BillboardGui overlay.
-- The old AlwaysOnTop Billboards made labels enormous at a distance and
-- overlapped one another in the shared ready/spectator area.
-- Fixed-size world boards: no TextScaled or automatic wrapping.
-- Billboard-style text scaling previously made labels fill the entire screen.
local function textSign(parent, message, yOffset, width)
	local heading, subheading = string.match(message, "^(.-)%s*|%s*(.+)$")
	heading = heading or message

	local board = Instance.new("Part")
	board.Name = "WorldSign_" .. parent.Name
	board.Anchored = true
	board.CanCollide = false
	board.CanTouch = false
	board.Size = Vector3.new(math.clamp((width or 220) / 21, 8, 16), 2.35, 0.45)
	board.Position = parent.Position + Vector3.new(0, yOffset or 3, 0)
	board.Material = Enum.Material.SmoothPlastic
	board.Color = Color3.fromRGB(250, 251, 255)
	board.Parent = parent.Parent or world

	local function face(side, name)
		local surface = Instance.new("SurfaceGui")
		surface.Name = name
		surface.Face = side
		-- Critical: 2026 Studio defaults can use FixedSize (800x600)
		-- and stretch this wide 3D board's text horizontally. Select
		-- PixelsPerStud explicitly so text preserves its real proportions.
		surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surface.PixelsPerStud = 48
		surface.AlwaysOnTop = false
		surface.LightInfluence = 0
		surface.Parent = board

		local label = Instance.new("TextLabel")
		label.Name = "Heading"
		label.Position = UDim2.fromScale(0.04, subheading and 0.12 or 0.08)
		label.Size = UDim2.fromScale(0.92, subheading and 0.51 or 0.84)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(33, 92, 150)
		label.TextScaled = false
		label.TextSize = subheading and 44 or (parent.Name == "SharedPlatformSign" and 37 or 54)
		label.TextWrapped = false
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Font = Enum.Font.GothamBold
		label.Text = heading
		label.Parent = surface

		if subheading then
			local subtitle = Instance.new("TextLabel")
			subtitle.Name = "Subtitle"
			subtitle.Position = UDim2.fromScale(0.04, 0.64)
			subtitle.Size = UDim2.fromScale(0.92, 0.25)
			subtitle.BackgroundTransparency = 1
			subtitle.TextColor3 = Color3.fromRGB(112, 137, 165)
			subtitle.TextScaled = false
			subtitle.TextSize = 26
			subtitle.TextWrapped = false
			subtitle.TextTruncate = Enum.TextTruncate.AtEnd
			subtitle.TextXAlignment = Enum.TextXAlignment.Center
			subtitle.Font = Enum.Font.GothamMedium
			subtitle.Text = subheading
			subtitle.Parent = surface
		end
		return surface, label
	end

	local front, frontLabel = face(Enum.NormalId.Front, "WorldText")
	local _, backLabel = face(Enum.NormalId.Back, "WorldTextBack")
	-- A single changing status label updates both sides of the join deck.
	frontLabel:GetPropertyChangedSignal("Text"):Connect(function()
		if backLabel.Parent then
			backLabel.Text = frontLabel.Text
		end
	end)
	return front
end

-- Persistent social island and phase-aware shared ready/spectator platform.
local hub = Instance.new("Model")
hub.Name = "HubIsland"
hub.Parent = world

local GRASS = Color3.fromRGB(101, 204, 91)
local CREAM = Color3.fromRGB(246, 226, 171)
local WOOD = Color3.fromRGB(170, 111, 58)
local ROOF_BLUE = Color3.fromRGB(52, 157, 244)
local ROOF_PINK = Color3.fromRGB(252, 107, 150)
local WHITE = Color3.fromRGB(253, 251, 238)

local function decorative(name, size, position, color, material)
	return part(name, size, position, color, material or Enum.Material.SmoothPlastic, hub)
end

-- Layered terrain gives the island a proper visible edge from the bridge.
-- These are behind the spectator rails and do not alter the match.
local islandSoil = decorative(
	"IslandSoil", Vector3.new(125, 12, 87),
	Vector3.new(0, 16, -59), Color3.fromRGB(153, 113, 72), Enum.Material.Ground
)
local islandStone = decorative(
	"IslandStoneBase", Vector3.new(120, 4, 83),
	Vector3.new(0, 8, -59), Color3.fromRGB(174, 163, 137), Enum.Material.Slate
)
local ground = decorative("HubGrassIsland", Vector3.new(130, 4, 91), Vector3.new(0, 22, -59), GRASS, Enum.Material.Grass)
local plaza = decorative("SpawnPlaza", Vector3.new(26, 0.4, 23), Vector3.new(0, 24.2, -76), CREAM)
local path = decorative("MainWalkPath", Vector3.new(11, 0.25, 36), Vector3.new(0, 24.14, -53), CREAM)
local spurLeft = decorative("LeftShopPath", Vector3.new(27, 0.22, 7), Vector3.new(-19, 24.13, -48), CREAM)
local spurRight = decorative("RightShopPath", Vector3.new(27, 0.22, 7), Vector3.new(19, 24.13, -48), CREAM)

-- The platform is BOTH ready and spectator space. It persists for the whole
-- server session; we change its message, never create a second front deck.
local sharedDeck = decorative(
	"SharedReadyAndSpectatorDeck",
	Vector3.new(90, 1, 24),
	Vector3.new(0, 24.05, -22),
	Color3.fromRGB(228, 245, 254)
)
local deckCenter = decorative(
	"JoinAndWatchFloorMarking",
	Vector3.new(19, 0.17, 9),
	Vector3.new(0, 24.7, -25),
	Color3.fromRGB(255, 207, 67)
)
deckCenter.CanCollide = false
local deckPrompt = Instance.new("ProximityPrompt")
deckPrompt.Name = "JoinRoundPrompt"
deckPrompt.ActionText = "Join next round"
deckPrompt.ObjectText = "Glass Bridge Race"
deckPrompt.KeyboardKeyCode = Enum.KeyCode.E
deckPrompt.HoldDuration = 0
deckPrompt.MaxActivationDistance = 15
deckPrompt.RequiresLineOfSight = false
deckPrompt.Parent = deckCenter

local sharedDeckSignAnchor = decorative(
	"SharedPlatformSign",
	Vector3.new(1, 1, 1),
	Vector3.new(0, 30, -25),
	CREAM
)
sharedDeckSignAnchor.Transparency = 1
sharedDeckSignAnchor.CanCollide = false
local deckSignGui = textSign(sharedDeckSignAnchor, "JOIN NEXT ROUND", 3, 310)
local deckSignText = deckSignGui:FindFirstChildOfClass("TextLabel")

-- One transparent front barrier lets spectators see the bridges but stops
-- jumping into an active lane. A spectator who bypasses it is also returned
-- to this deck by an additional server-side bounds check.
local barrier = decorative(
	"FrontSpectatorGlassBarrier",
	Vector3.new(90, 8.5, 0.45),
	Vector3.new(0, 28.8, -10.25),
	Color3.fromRGB(177, 238, 252),
	Enum.Material.Glass
)
barrier.Transparency = 0.79

local function makePromenade(side)
	local x = side * 49
	local walkway = decorative(
		side < 0 and "LeftSpectatorWalkway" or "RightSpectatorWalkway",
		Vector3.new(9, 1, 95),
		Vector3.new(x, 24.05, 22.5),
		Color3.fromRGB(226, 244, 252)
	)
	local connector = decorative(
		side < 0 and "LeftSpectatorConnector" or "RightSpectatorConnector",
		Vector3.new(12, 1, 15),
		Vector3.new(side * 44, 24.05, -17.5),
		Color3.fromRGB(226, 244, 252)
	)
	local inner = decorative(
		"InnerViewingSafetyGlass",
		Vector3.new(0.45, 8.5, 79.8),
		Vector3.new(side * 44.5, 28.8, 30.1),
		Color3.fromRGB(177, 238, 252),
		Enum.Material.Glass
	)
	inner.Transparency = 0.78
	local outer = decorative(
		"OuterViewingFence",
		Vector3.new(0.75, 7, 95),
		Vector3.new(side * 53.5, 28.05, 22.5),
		WOOD,
		Enum.Material.Wood
	)
	outer.Transparency = 0.05
	local endRail = decorative(
		"ViewingEndFence",
		Vector3.new(9, 7, 0.7),
		Vector3.new(x, 28.05, 69.65),
		WOOD,
		Enum.Material.Wood
	)
	return walkway
end
makePromenade(-1)
makePromenade(1)

-- Invisible, noninteractive spawn pad. Its parent location is deliberately
-- well clear of the lava. Existing respawn code still points here.
local lobby = Instance.new("SpawnLocation")
lobby.Name = "MythbloxLobbySpawn"
lobby.Neutral = true
lobby.Duration = 0
lobby.Anchored = true
lobby.Size = Vector3.new(18, 0.4, 13)
lobby.Position = Vector3.new(0, 24.5, -76)
lobby.Material = Enum.Material.SmoothPlastic
lobby.Color = CREAM
lobby.Transparency = 0.4
lobby.Parent = hub

-- Decorative low-poly store fronts: deliberately no paid products yet.
local function makeStall(name, x, z, roofColor, line1, line2)
	local group = Instance.new("Model")
	group.Name = name
	group.Parent = hub
	part("DisplayFloor", Vector3.new(17, 0.6, 14), Vector3.new(x, 24.4, z), WHITE, Enum.Material.WoodPlanks, group)
	part("BackWall", Vector3.new(17, 8, 1), Vector3.new(x, 28.4, z + 6), WOOD, Enum.Material.WoodPlanks, group)
	for _, side in ipairs({-1, 1}) do
		part("CornerPost", Vector3.new(1.2, 8.5, 1.2), Vector3.new(x + side * 7.2, 28.4, z - 4.5), WOOD, Enum.Material.Wood, group)
	end
	local roof = part("ColorfulRoof", Vector3.new(19, 1.3, 17), Vector3.new(x, 33.2, z), roofColor, Enum.Material.SmoothPlastic, group)
	local header = part("StallSignAnchor", Vector3.new(1, 1, 1), Vector3.new(x, 29, z - 6.5), WHITE, Enum.Material.SmoothPlastic, group)
	header.Transparency = 1
	header.CanCollide = false
	textSign(header, line1 .. " | " .. line2, 2, 210)
end
makeStall("LeftShopComingSoon", -25, -49, ROOF_BLUE, "SHOP", "COMING SOON")
makeStall("RightCosmeticsComingSoon", 25, -49, ROOF_PINK, "COSMETICS", "COMING SOON")

-- Compact single-face leaderboard. Its front for arriving lobby visitors
-- points toward +Z (Back face in Roblox part-local coordinates).
local boardPost = decorative(
	"LeaderboardPost",
	Vector3.new(1.4, 8.5, 1.2),
	Vector3.new(33, 26.25, -83.4),
	WOOD, Enum.Material.Wood
)
local board = decorative(
	"LeaderboardBoard",
	Vector3.new(13, 8, 1.1),
	Vector3.new(33, 32.2, -82),
	ROOF_BLUE
)
local boardGui = Instance.new("SurfaceGui")
boardGui.Name = "ServerLeaderboard"
boardGui.Face = Enum.NormalId.Back
boardGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
boardGui.PixelsPerStud = 34
boardGui.LightInfluence = 0
boardGui.AlwaysOnTop = false
boardGui.Parent = board

local card = Instance.new("Frame")
card.Name = "ScoreCard"
card.Position = UDim2.fromScale(0.04, 0.055)
card.Size = UDim2.fromScale(0.92, 0.89)
card.BackgroundColor3 = WHITE
card.BorderSizePixel = 0
card.Parent = boardGui
local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 10)
cardCorner.Parent = card

local function scoreLabel(name, message, position, height, size, isBold)
	local text = Instance.new("TextLabel")
	text.Name = name
	text.Position = UDim2.new(0.055, 0, position, 0)
	text.Size = UDim2.new(0.89, 0, height, 0)
	text.BackgroundTransparency = 1
	text.Text = message
	text.TextColor3 = Color3.fromRGB(41, 91, 147)
	text.TextSize = size
	text.TextScaled = false
	text.TextWrapped = false
	text.TextTruncate = Enum.TextTruncate.AtEnd
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Center
	text.Font = isBold and Enum.Font.GothamBold or Enum.Font.GothamMedium
	text.Parent = card
	return text
end

scoreLabel("Title", "TOP RACERS", 0.065, 0.18, 32, true)
local boardRows = {}
for i = 1, 4 do
	boardRows[i] = scoreLabel(
		"Player" .. i,
		"",
		0.29 + (i - 1) * 0.165,
		0.12,
		23,
		i == 1
	)
end

local lastLeaderboardText = ""
local function refreshSessionLeaderboard()
	local contestants = Players:GetPlayers()
	local function values(p)
		local stats = p:FindFirstChild("leaderstats")
		local wins = stats and stats:FindFirstChild("Wins")
		local coins = stats and stats:FindFirstChild("Coins")
		return wins and wins.Value or 0, coins and coins.Value or 0
	end
	table.sort(contestants, function(a, b)
		local aw, ac = values(a)
		local bw, bc = values(b)
		if aw ~= bw then return aw > bw end
		if ac ~= bc then return ac > bc end
		return a.UserId < b.UserId
	end)
	local rows = {}
	for i = 1, 4 do
		local player = contestants[i]
		if player then
			local wins, coins = values(player)
			rows[i] = string.format("%d. %s  ·  %dW  %dC", i, player.DisplayName, wins, coins)
		else
			rows[i] = ""
		end
	end
	local key = table.concat(rows, "\n")
	if key == lastLeaderboardText then return end
	lastLeaderboardText = key
	for i, textLabel in ipairs(boardRows) do
		textLabel.Text = rows[i]
	end
end
local rewardsBase = decorative("FutureRewardsPodium", Vector3.new(12, 1.5, 10), Vector3.new(-33, 24.75, -82), Color3.fromRGB(255, 195, 91))
local rewardSign = decorative("FutureRewardsSignAnchor", Vector3.new(1, 1, 1), Vector3.new(-33, 27, -82), WHITE)
rewardSign.CanCollide = false
rewardSign.Transparency = 1
textSign(rewardSign, "REWARDS | COMING SOON", 2.5, 226)

-- Small cartoony trees and bushes around the EDGE, leaving sightlines open.
local function makeTree(x, z, height)
	local trunk = decorative("BlockyTreeTrunk", Vector3.new(2, height, 2), Vector3.new(x, 24 + height / 2, z), WOOD, Enum.Material.Wood)
	for dx = -1, 1 do
		for dz = -1, 1 do
			if dx == 0 or dz == 0 then
				local leaf = decorative(
					"BlockyTreeLeaves",
					Vector3.new(5, 3, 5),
					Vector3.new(x + dx * 3.2, 24 + height + (dx == 0 and 2.5 or 1), z + dz * 3.2),
					Color3.fromRGB(65 + (dx + 1) * 10, 190 + (dz + 1) * 6, 80),
					Enum.Material.Grass
				)
				leaf.CanCollide = false
			end
		end
	end
end
for _, spot in ipairs({
	{-56, -88, 9}, {-56, -53, 10}, {-56, -24, 8},
	{56, -88, 9}, {56, -53, 10}, {56, -24, 8}
}) do
	makeTree(spot[1], spot[2], spot[3])
end
for _, spot in ipairs({{-49,-92},{-43,-92},{45,-92},{50,-93},{-50,-39},{50,-39}}) do
	local bush = decorative("HubBush", Vector3.new(5, 3, 5), Vector3.new(spot[1], 25.5, spot[2]), Color3.fromRGB(77, 198, 99), Enum.Material.Grass)
	bush.CanCollide = false
end
for _, side in ipairs({-1, 1}) do
	for _, z in ipairs({-89, -74, -59, -44}) do
		local post = decorative("IslandEdgeFencePost", Vector3.new(1.5, 5, 1.5), Vector3.new(side * 63, 26.5, z), WOOD, Enum.Material.Wood)
	end
end

-- Calm sea backdrop covers the template's empty gray baseplate when viewed
-- from the arena; unlike the grass island it has no collision.
local ocean = part(
	"OceanBackdrop", Vector3.new(820, 1.5, 820),
	Vector3.new(0, 0.6, 58), Color3.fromRGB(72, 185, 234), Enum.Material.SmoothPlastic
)
ocean.CanCollide = false
ocean.CanTouch = false
local lava = part("Lava", Vector3.new(105, 2, 235), Vector3.new(0, 7, 68), Color3.fromRGB(255, 105, 35), Enum.Material.Neon)
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
local finishCenter = nil
local function clearBridges()
	if bridgeModel then bridgeModel:Destroy() end
	bridgeModel = nil
	finishCenter = nil
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
		-- Pale-blue decorative rails sit below the glass and cannot be stood on.
		-- Only two rails per player, keeping the world small on mobile devices.
		for _, edge in ipairs({-1, 1}) do
			local rail = part(
				("Lane%02d_EdgeGlow"):format(lane),
				Vector3.new(0.35, 0.35, SETTINGS.TileSpacing * SETTINGS.BridgeLength + 6.7),
				Vector3.new(x + edge * (3.35 - 0.175), SETTINGS.BridgeY - 0.625, SETTINGS.BridgeLength * SETTINGS.TileSpacing / 2),
				VIOLET, Enum.Material.SmoothPlastic, bridgeModel
			)
			rail.CanCollide = false
			rail.CanTouch = false
			rail.Transparency = 0.12
		end
	end

	-- Clean two-post finish gate, with a single sign integrated into the beam.
	-- Keep all decorative parts noncolliding; winning still happens on tile 20.
	local finishZ = SETTINGS.BridgeLength * SETTINGS.TileSpacing
	local occupiedSpan = (count - 1) * SETTINGS.LaneSpacing + 6.7
	local postX = occupiedSpan / 2 + 1.9
	local beam = part(
		"FinishGateBeam",
		Vector3.new(occupiedSpan + 6.2, 3.0, 1.5),
		Vector3.new(0, SETTINGS.BridgeY + 11.6, finishZ),
		Color3.fromRGB(249, 252, 255), Enum.Material.SmoothPlastic, bridgeModel
	)
	beam.CanCollide = false
	beam.CanTouch = false
	finishCenter = beam

	local gateText = Instance.new("SurfaceGui")
	gateText.Name = "FinishWord"
	gateText.Face = Enum.NormalId.Front -- readable when approaching along +Z
	gateText.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gateText.PixelsPerStud = 35
	gateText.LightInfluence = 0
	gateText.AlwaysOnTop = false
	gateText.Parent = beam
	local name = Instance.new("TextLabel")
	name.Name = "FinishLabel"
	name.Size = UDim2.fromScale(1, 1)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBlack
	name.Text = "FINISH"
	name.TextColor3 = Color3.fromRGB(37, 116, 193)
	name.TextSize = 65
	name.TextScaled = false
	name.Parent = gateText

	for _, side in ipairs({-1, 1}) do
		local column = part(
			"FinishGatePillar",
			Vector3.new(2.0, 11.7, 2.5),
			Vector3.new(side * postX, SETTINGS.BridgeY + 5.85, finishZ),
			Color3.fromRGB(73, 171, 235), Enum.Material.SmoothPlastic, bridgeModel
		)
		column.CanCollide = false
		column.CanTouch = false
	end
	-- Checkered stripes belong only to the final glass tile, not across gaps
	-- between player lanes; they cannot be walked on independently.
	for lane = 1, count do
		local laneX = lanes[lane].x
		for i = 1, 6 do
			local mark = part(
				"FinishTileChecker",
				Vector3.new(6.7 / 6, 0.055, 1.15),
				Vector3.new(laneX - 3.35 + (i - 0.5) * (6.7 / 6), SETTINGS.BridgeY + 0.48, finishZ - 2.1),
				i % 2 == 0 and Color3.fromRGB(43, 75, 113) or WHITE,
				Enum.Material.SmoothPlastic, bridgeModel
			)
			mark.CanCollide = false
			mark.CanTouch = false
		end
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
		root.CFrame = CFrame.new(offset, SETTINGS.BridgeY + 4, -76)
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

-- Tiny number printed on the starting glass. No giant floating name tags.
local function markLane(tile, lane)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "LaneNumber"
	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 28
	gui.Parent = tile
	local number = Instance.new("TextLabel")
	number.Size = UDim2.fromScale(1, 1)
	number.BackgroundTransparency = 1
	number.Text = tostring(lane)
	number.TextColor3 = Color3.fromRGB(24, 87, 139)
	number.TextTransparency = 0.12
	number.Font = Enum.Font.GothamBold
	number.TextScaled = false
	number.TextSize = 48
	number.Parent = gui
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

local function finishConfetti()
	if not finishCenter or not finishCenter.Parent then return end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "WinnerConfetti"
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.7, 1.9)
	emitter.Speed = NumberRange.new(13, 23)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new(0.65)
	emitter.LightEmission = 0.25
	emitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 207, 52)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(81, 209, 132)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(74, 155, 251))
	})
	emitter.Parent = finishCenter
	emitter:Emit(60)
	Debris:AddItem(emitter, 3)
end

local function showCrackLines(tile, count)
	if not tile then return end
	local overlay = tile:FindFirstChild("DamageLines")
	if not overlay then
		overlay = Instance.new("SurfaceGui")
		overlay.Name = "DamageLines"
		overlay.Face = Enum.NormalId.Top
		overlay.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
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
		line.BackgroundColor3 = Color3.fromRGB(40, 102, 149)
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
	refreshSessionLeaderboard()
	-- The single physical platform changes role by phase, without moving.
	if phase == "JOIN" then
		deckSignText.Text = ("JOIN ROUND  ·  %ds  ·  %d READY"):format(secondsLeft, numberReady())
		deckPrompt.Enabled = true
	elseif phase == "RESULTS" then
		deckSignText.Text = "ROUND FINISHED  |  NEXT MATCH SOON"
		deckPrompt.Enabled = false
	else
		deckSignText.Text = ("WATCH MATCH  ·  %d LEFT"):format(#survivors())
		deckPrompt.Enabled = false
	end
	for _, player in ipairs(Players:GetPlayers()) do
		stateEvent:FireClient(player, snapshot(player))
	end
end

local function joinQueue(player)
	if player.Parent ~= Players or phase ~= "JOIN" or queue[player] or numberReady() >= SETTINGS.MaxPlayers then
		return
	end
	queue[player] = true
	publish()
end

-- Physical join pad and existing UI button call the SAME validated server path.
deckPrompt.Triggered:Connect(joinQueue)

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
		joinQueue(player)
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
	-- Spectators can roam the deck and protected side walks, but are
	-- returned if they reach the actual glass-lane area by jumping past a rail.
	for _, observer in ipairs(Players:GetPlayers()) do
		local info = active[observer]
		local character = observer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local isSpectator = not info or (not info.alive and info.root ~= root)
		if isSpectator and root and humanoid and humanoid.Health > 0 then
			local position = root.Position
			if position.Z >= -3.5 and position.Z <= SETTINGS.BridgeLength * SETTINGS.TileSpacing + 4
				and math.abs(position.X) < 42.5
				and position.Y > SETTINGS.BridgeY - 9 and position.Y < SETTINGS.BridgeY + 18 then
				root.CFrame = CFrame.new(0, SETTINGS.BridgeY + 4, -23)
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end
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
							finishConfetti()
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
			markLane(lanes[lane].tiles[0], lane)
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
]====]

local CLIENT_SOURCE = [====[
-- Mythblox Game 01 · clean verified client v0.11
-- Presentation only. The server still owns votes, movement, cracks, winners and coins.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BUILD_VERSION = "v0.11"
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local network = ReplicatedStorage:WaitForChild("MythbloxGame01")
local command = network:WaitForChild("Command")
local stateEvent = network:WaitForChild("State")
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

local function update(state)
	local phase = state.phase or "JOIN"
	-- Turn numbers restart every match; never reuse a previous match's vote rows.
	if phase == "JOIN" or phase == "VOTE" then
		lastTurnRendered = -1
	end
	local mine = state.mine
	phaseText.Text = ("v0.11 · ROUND %d · %s"):format(state.turn or 0, phaseNames[phase] or phase)
	clockText.Text = tostring(state.time or 0) .. "s"
	description.Text = state.message or ""

	join.Visible = phase == "JOIN" and state.queued ~= true and (state.ready or 0) < (state.capacity or 8)
	voting.Visible = phase == "VOTE" and mine ~= nil and mine.alive == true
	movement.Visible = phase == "MOVE" and mine ~= nil and mine.alive == true

	if phase == "JOIN" then
		phaseText.Text = "v0.11 · NEXT MATCH"
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
		phaseText.Text = "v0.11 · ROUND OVER"
		ownStats.Text = "NEXT MATCH STARTS SOON"
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

	-- Make the full breakdown visible on desktop during walking. On mobile,
	-- display it during REVEAL only, so controls/gameplay remain unobstructed.
	-- Keep racers' walking camera clear, show extended results to observers.
	local observing = mine == nil or mine.alive ~= true
	reveal.Visible = phase == "REVEAL" or (phase == "MOVE" and observing and not isCompact)
	if reveal.Visible then drawOutcomes(state) end


end

join.Visible = false
voting.Visible = false
movement.Visible = false
reveal.Visible = false
stateEvent.OnClientEvent:Connect(update)
command:FireServer("Sync")
]====]

-- Diagnostic/cleanup installer: v0.11
-- Remove known legacy copies from services used by previous Mythblox builds.
-- This intentionally does NOT remove scripts belonging to other games.
-- Permanently remove the UNUSED default Roblox Baseplate spawn while in
-- Studio Edit mode. Only the stock near-origin, low-altitude SpawnLocation
-- is targeted; leave any user-created custom spawns elsewhere alone.
local defaultSpawnsRemoved = 0
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("SpawnLocation") and obj.Name == "SpawnLocation"
		and math.abs(obj.Position.X) < 24
		and math.abs(obj.Position.Z) < 24
		and obj.Position.Y < 14 then
		obj.Enabled = false
		obj:Destroy()
		defaultSpawnsRemoved += 1
	end
end
print("[Mythblox INSTALL] Removed " .. defaultSpawnsRemoved .. " unused Baseplate spawn(s).")

local SERVER_FOLDER = game:GetService("ServerScriptService")
local STARTER_PLAYER_SCRIPTS = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local STARTER_GUI = game:GetService("StarterGui")

local removed = {}
for _, service in ipairs({SERVER_FOLDER, STARTER_PLAYER_SCRIPTS, STARTER_GUI}) do
	for _, child in ipairs(service:GetDescendants()) do
		if child:IsA("LuaSourceContainer") and child.Name == "MythbloxGame" then
			table.insert(removed, child:GetFullName())
			child:Destroy()
		end
	end
end
for _, child in ipairs(STARTER_GUI:GetChildren()) do
	if child:IsA("ScreenGui") and child.Name == "MythbloxGame01UI" then
		table.insert(removed, child:GetFullName())
		child:Destroy()
	end
end

local function install(where, kind, name, source)
	local instance = Instance.new(kind)
	instance.Name = name
	instance.Enabled = false
	instance.Source = source
	instance.Parent = where
	assert(instance.Source == source, "Studio did not store the expected source for " .. instance:GetFullName())
	instance.Enabled = true
	return instance
end

local liveServer = install(SERVER_FOLDER, "Script", "MythbloxGame", SERVER_SOURCE)
local liveClient = install(STARTER_PLAYER_SCRIPTS, "LocalScript", "MythbloxGame", CLIENT_SOURCE)

-- Older test scripts sometimes get copied under a different name; remove
-- their effect too, without touching unrelated Roblox scripts.
local disabledLegacy = {}
for _, other in ipairs(game:GetDescendants()) do
	if other ~= liveServer and other ~= liveClient
		and (other:IsA("Script") or other:IsA("LocalScript")) then
		local ok, source = pcall(function()
			return other.Source
		end)
		if ok and type(source) == "string" then
			local previousUi = string.find(source, "MythbloxGame01UI", 1, true)
			local previousWorld = string.find(source, 'world.Name = "MythbloxGame01"', 1, true)
			if previousUi or previousWorld then
				other.Enabled = false
				table.insert(disabledLegacy, other:GetFullName())
			end
		end
	end
end
if #disabledLegacy > 0 then
	warn("[Mythblox INSTALL] Disabled " .. #disabledLegacy .. " extra older game scripts: " .. table.concat(disabledLegacy, "; "))
end

-- Warn about other Mythblox-named scripts that may run an old UI.
local suspicious = {}
for _, child in ipairs(game:GetDescendants()) do
	if child:IsA("LuaSourceContainer") and child ~= liveServer and child ~= liveClient then
		if string.find(string.lower(child.Name), "mythblox", 1, true) then
			table.insert(suspicious, child:GetFullName())
		end
	end
end

print("[Mythblox INSTALL] v0.11 VERIFIED: 2 scripts installed and Source checked.")
print("[Mythblox INSTALL] Server: " .. liveServer:GetFullName() .. " | Build v0.11")
print("[Mythblox INSTALL] Client: " .. liveClient:GetFullName() .. " | Build v0.11")
print("[Mythblox INSTALL] Cleaned " .. #removed .. " previous Mythblox script/UI objects.")
print("[Mythblox INSTALL] Disabled " .. #disabledLegacy .. " other old game scripts found by source signature.")
if #suspicious > 0 then
	warn("[Mythblox INSTALL] Other Mythblox scripts still exist: " .. table.concat(suspicious, "; "))
end
print("[Mythblox INSTALL] NOW START A FRESH PLAY SESSION. Confirm the top HUD visibly says v0.11, and check Output for SERVER RUNNING v0.11 and CLIENT RUNNING v0.11.")
