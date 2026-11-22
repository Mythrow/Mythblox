-- Mythblox game-01: Soft Earth Coast v0.29 (server)
-- The server owns votes, movement permissions, cracks, results and rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local BUILD_VERSION = "v0.29"

local SETTINGS = {
	MaxPlayers = 8,
	JoinSeconds = 10,
	VoteSeconds = 5,
	RevealSeconds = 5,
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
	-- Live servers also allow a single player to PRACTICE the bridge.
	-- Solo practice is never eligible for competitive wins or coins.
	LiveSoloPractice = true,
	-- Change either ID to a different animation the experience may use.
	-- R15 and R6 animations are different assets/rig types.
	VictoryDanceR15 = "rbxassetid://507771019",
	VictoryDanceR6 = "rbxassetid://182435998",
}

-- SOFT EARTH COAST: cute, muted, matte earth tones in the whole lobby.
-- Exact visual palette; purchased glass skins and SAFE/BLOCKED result signals
-- are functional exceptions that must keep their existing behavior.
local THEME = {
	Ivory = Color3.fromRGB(239, 230, 214),       -- #EFE6D6 warm cream
	Limestone = Color3.fromRGB(217, 200, 174),   -- #D9C8AE oat beige, small accents
	Sandstone = Color3.fromRGB(201, 179, 148),   -- #C9B394 soft sand
	-- v0.29: richer matte colors specifically for large, light-catching
	-- floors, platforms and planters; not a dark filter over the game.
	PlazaStone = Color3.fromRGB(184, 173, 154),   -- weathered oat
	DeckStone = Color3.fromRGB(176, 167, 150),    -- shaded stone
	WalkStone = Color3.fromRGB(191, 178, 158),    -- sandy stone
	PlanterStone = Color3.fromRGB(175, 171, 157), -- muted stone gray
	Sage = Color3.fromRGB(168, 179, 157),        -- #A8B39D muted sage
	Terracotta = Color3.fromRGB(185, 137, 115), -- #B98973 soft clay
	Rose = Color3.fromRGB(199, 159, 154),        -- #C79F9A dusty rose
	Wood = Color3.fromRGB(181, 142, 108),        -- #B58E6C light wood
	Brown = Color3.fromRGB(110, 90, 75),         -- #6E5A4B soft brown
	Evergreen = Color3.fromRGB(128, 151, 123),
	Foam = Color3.fromRGB(202, 217, 202),
	Stone = Color3.fromRGB(153, 149, 137),
	Ocean = Color3.fromRGB(123, 157, 153),
}
local GLASS = Color3.fromRGB(142, 219, 238)
-- Existing purchased glass colors remain exactly as saved in the catalog.
local SKIN_CATALOG = {
	{ id = "classic", title = "Classic Blue", price = 0, color = GLASS },
	{ id = "rose", title = "Candy Pink", price = 20, color = Color3.fromRGB(252, 164, 220) },
	{ id = "mint", title = "Mint Pop", price = 40, color = Color3.fromRGB(149, 238, 201) },
	{ id = "violet", title = "Soft Violet", price = 60, color = Color3.fromRGB(193, 172, 250) },
}
local SKIN_BY_ID = {}
for _, item in ipairs(SKIN_CATALOG) do SKIN_BY_ID[item.id] = item end
local equippedSkins = {}
local function glassColorFor(player)
	local skin = SKIN_BY_ID[equippedSkins[player] or "classic"]
	return skin and skin.color or GLASS
end
local AMBER = Color3.fromRGB(255, 206, 75)
-- v0.29: neutral, soft coastal daylight. Let the deliberately warm
-- OAT/WOOD/TERRACOTTA materials carry the earth tones without a yellow
-- filter across the sky, character, greenery, water, or every surface.
-- Keep lighting gentle on mobile and preserve the matte material response.
Lighting.ClockTime = 13.1
Lighting.Brightness = 1.75
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.68
Lighting.EnvironmentDiffuseScale = 0.46
Lighting.EnvironmentSpecularScale = 0.20
Lighting.Ambient = Color3.fromRGB(158, 161, 163)
Lighting.OutdoorAmbient = Color3.fromRGB(188, 194, 196)
Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
Lighting.FogColor = Color3.fromRGB(204, 214, 220)
Lighting.FogEnd = 1500

local function getWorldLightingEffect(className, name)
	local effect = Lighting:FindFirstChild(name)
	if effect and not effect:IsA(className) then effect:Destroy(); effect = nil end
	if not effect then
		effect = Instance.new(className)
		effect.Name = name
		effect.Parent = Lighting
	end
	return effect
end

local atmosphere = getWorldLightingEffect("Atmosphere", "MythbloxCoastalAtmosphere")
atmosphere.Density = 0.20
atmosphere.Offset = 0.05
atmosphere.Color = Color3.fromRGB(215, 228, 234)
atmosphere.Decay = Color3.fromRGB(179, 194, 201)
atmosphere.Glare = 0
atmosphere.Haze = 0.38

-- Keep the existing named instance so reinstallation updates the effect
-- instead of stacking more ColorCorrectionEffects.
local grade = getWorldLightingEffect("ColorCorrectionEffect", "MythbloxWarmColorGrade")
grade.Brightness = -0.015
grade.Contrast = 0.015
grade.Saturation = -0.035
grade.TintColor = Color3.fromRGB(255, 255, 255)
grade.Enabled = true

local bloom = getWorldLightingEffect("BloomEffect", "MythbloxSoftBloom")
bloom.Intensity = 0
bloom.Size = 18
bloom.Threshold = 2
bloom.Enabled = false

local sunRays = getWorldLightingEffect("SunRaysEffect", "MythbloxSunRays")
sunRays.Intensity = 0.012
sunRays.Spread = 0.82
sunRays.Enabled = true

-- Dynamic clouds belong to Workspace.Terrain (not Lighting).
-- Reuse an existing Clouds instance instead of stacking cloud layers.
local terrain = workspace.Terrain
local clouds = terrain:FindFirstChildOfClass("Clouds")
if not clouds then
	clouds = Instance.new("Clouds")
	clouds.Parent = terrain
end
clouds.Name = "MythbloxAzureCoastClouds"
-- v0.29: visibly fuller soft coastal cloud cover, not a solid white sky.
clouds.Cover = 0.72
clouds.Density = 0.54
clouds.Color = Color3.fromRGB(238, 242, 242)
clouds.Enabled = true
terrain.WaterColor = THEME.Ocean
terrain.WaterTransparency = 0.36
terrain.WaterReflectance = 0.045
terrain.WaterWaveSize = 0.08
terrain.WaterWaveSpeed = 5

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

-- The template Baseplate is still visible beneath the noncolliding ocean in
-- earlier versions. Delete ONLY the large, low, named stock Baseplate.
local function removeTemplateBaseplate()
	local removed = 0
	for _, candidate in ipairs(workspace:GetChildren()) do
		if candidate:IsA("BasePart") and string.lower(candidate.Name) == "baseplate"
			and candidate.Size.X >= 150 and candidate.Size.Z >= 150
			and candidate.Position.Y + candidate.Size.Y * 0.5 < SETTINGS.BridgeY - 5 then
			candidate:Destroy()
			removed += 1
		end
	end
	if removed > 0 then
		print("[Mythblox WORLD] Removed " .. removed .. " template Baseplate part(s).")
	end
end
removeTemplateBaseplate()

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
local shopEvent = Instance.new("RemoteEvent")
shopEvent.Name = "Shop"
shopEvent.Parent = network
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
	if material == Enum.Material.Glass then
		p.Reflectance = 0.012
	elseif material == Enum.Material.Metal then
		p.Reflectance = 0.018
	end
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
	-- World signboards are physical fixtures; invisible labels/anchors stay noncolliding.
	board.CanCollide = true
	board.CanTouch = false
	board.Size = Vector3.new(math.clamp((width or 220) / 21, 8, 16), 2.35, 0.45)
	board.Position = parent.Position + Vector3.new(0, yOffset or 3, 0)
	board.Material = Enum.Material.Metal
	board.Color = THEME.Brown
	board.Reflectance = 0.012
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
		label.TextColor3 = THEME.Ivory
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
			subtitle.TextColor3 = THEME.Wood
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

local GRASS = THEME.Evergreen
local CREAM = THEME.Ivory
local WOOD = THEME.Wood
local ROOF_BLUE = THEME.Sage
local ROOF_PINK = THEME.Rose
local WHITE = THEME.Ivory
local METAL_TRIM = THEME.Wood
local DEEP_NAVY = THEME.Brown

local function decorative(name, size, position, color, material)
	return part(name, size, position, color, material or Enum.Material.SmoothPlastic, hub)
end

-- Visual-only architectural detail: non-solid, non-touching, non-queryable.
local function detail(name, size, position, color, material, parent)
	local item = part(name, size, position, color, material or Enum.Material.Metal, parent or hub)
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.CastShadow = false
	return item
end

-- Unlike little visual trim, walkable furniture and real architecture need
-- solid physics. Keep this explicit rather than making every decorative part
-- collidable (which would obstruct the bridge and spectator sightlines).
local function solidDetail(name, size, position, color, material, parent)
	local item = part(name, size, position, color, material or Enum.Material.Limestone, parent or hub)
	item.CanCollide = true
	item.CanTouch = false
	item.CanQuery = true
	return item
end

-- Layered terrain gives the island a proper visible edge from the bridge.
-- These are behind the spectator rails and do not alter the match.
local islandSoil = decorative(
	"IslandSoil", Vector3.new(182, 12, 120),
	Vector3.new(0, 16, -71), THEME.Sandstone, Enum.Material.Ground
)
local islandStone = decorative(
	"IslandStoneBase", Vector3.new(179, 4, 117),
	Vector3.new(0, 8, -71), THEME.Stone, Enum.Material.Rock
)
local ground = decorative("HubGrassIsland", Vector3.new(186, 4, 124), Vector3.new(0, 22, -71), GRASS, Enum.Material.Grass)
-- Matte concrete absorbs visual glare better than pale limestone/sandstone
-- on broad, sun-facing surfaces. Narrow paths keep quiet paving texture.
local plaza = decorative("SpawnPlaza", Vector3.new(56, 0.4, 39), Vector3.new(0, 24.2, -83), THEME.PlazaStone, Enum.Material.Concrete)
local path = decorative("MainWalkPath", Vector3.new(13, 0.25, 39), Vector3.new(0, 24.14, -51.5), THEME.WalkStone, Enum.Material.Pavement)
-- Meet the 13-stud center path at x = +/-6.5 without laying duplicate
-- coplanar paving over it (a visible seam/flicker source).
local spurLeft = decorative("LeftShopPath", Vector3.new(26, 0.22, 7), Vector3.new(-19.5, 24.13, -48), THEME.WalkStone, Enum.Material.Pavement)
local spurRight = decorative("RightShopPath", Vector3.new(26, 0.22, 7), Vector3.new(19.5, 24.13, -48), THEME.WalkStone, Enum.Material.Pavement)
-- Additional social/gallery paths stay behind the original game-facing deck.
-- Each lounge connector joins at the path edge, not through another
-- coplanar textured slab. The horizontal segment ends at z=-85;
-- the return begins there and continues toward the spectator route.
for _, side in ipairs({-1, 1}) do
	decorative("WestEastLoungePath", Vector3.new(56.5, 0.20, 6),
		Vector3.new(side * 56.25, 24.1, -88), THEME.WalkStone, Enum.Material.Pavement)
	decorative("LoungeReturnPath", Vector3.new(7, 0.20, 22.5),
		Vector3.new(side * 67, 24.1, -73.75), THEME.WalkStone, Enum.Material.Pavement)
end
-- Pale ocean-stone inlays divide the oversized plaza into smaller elegant bays.
for _, x in ipairs({-27, 27}) do
	detail("PlazaEdgeChampagne", Vector3.new(0.17, 0.045, 38),
		Vector3.new(x, 24.42, -83), METAL_TRIM)
end
for _, z in ipairs({-101, -66}) do
	detail("PlazaBorderChampagne", Vector3.new(54, 0.045, 0.17),
		Vector3.new(0, 24.42, z), METAL_TRIM)
end

-- Inlaid gold guide strips are thin, noncolliding and stop at the join deck.
for _, x in ipairs({-6.0, 6.0}) do
	detail("PromenadeInlay", Vector3.new(0.13, 0.04, 38),
		Vector3.new(x, 24.3, -51.5), METAL_TRIM)
end
for _, z in ipairs({-97, -75}) do
	detail("SpawnPlazaInlay", Vector3.new(48, 0.035, 0.14),
		Vector3.new(0, 24.43, z), THEME.Sandstone, Enum.Material.Limestone)
end

-- v0.29: Fence the ENTIRE lobby perimeter. The previous opening for
-- long spectator paths is closed; the central deck remains the waiting area.
-- These tall safety limits remain behind VISIBLE, collidable fence panels.
-- They stop map escapes, but never change humanoid walking or jumping.
local function invisibleBoundary(name, size, position)
	local wall = part(name, size, position, DEEP_NAVY, Enum.Material.SmoothPlastic, hub)
	wall.Transparency = 1
	wall.CanCollide = true
	wall.CanTouch = false
	wall.CastShadow = false
	return wall
end
invisibleBoundary("HubWestSafetyLimit", Vector3.new(1.5, 19, 124), Vector3.new(-93.2, 33, -71))
invisibleBoundary("HubEastSafetyLimit", Vector3.new(1.5, 19, 124), Vector3.new(93.2, 33, -71))
invisibleBoundary("HubBackSafetyLimit", Vector3.new(186, 19, 1.5), Vector3.new(0, 33, -133.2))
for _, side in ipairs({-1, 1}) do
	-- Close the old +/-49 spectator promenade entrances at the front.
	invisibleBoundary("HubFrontSafetyLimit", Vector3.new(48, 19, 1.5),
		Vector3.new(side * 69, 33, -9.1))
end

local function fenceGlass(name, size, position)
	local pane = solidDetail(name, size, position, THEME.Foam, Enum.Material.Glass)
	pane.Transparency = 0.47
	pane.Reflectance = 0
	pane.CanTouch = false
	return pane
end
-- Side and rear panes visually explain where collision begins.
-- They overlap at the corners, with no ghost gap or walk-through fence.
for _, side in ipairs({-1, 1}) do
	fenceGlass("HubSideFenceGlass", Vector3.new(0.6, 8.5, 123),
		Vector3.new(side * 91.5, 28.4, -71))
	for _, z in ipairs({-122, -103, -84, -65, -46, -27, -11}) do
		solidDetail("CoastPerimeterPier", Vector3.new(1.15, 4.6, 1.15),
			Vector3.new(side * 90, 26.3, z), THEME.PlanterStone, Enum.Material.Concrete)
		detail("PerimeterPostCap", Vector3.new(1.5, 0.18, 1.5),
			Vector3.new(side * 90, 28.72, z), METAL_TRIM)
	end
	solidDetail("CoastPerimeterTealRail", Vector3.new(0.28, 0.25, 120),
		Vector3.new(side * 90, 27.6, -71), DEEP_NAVY)
end
fenceGlass("HubBackFenceGlass", Vector3.new(184, 8.5, 0.6),
	Vector3.new(0, 28.4, -131.5))
for x = -81, 81, 18 do
	solidDetail("BackPromenadePier", Vector3.new(1.15, 4.6, 1.15),
		Vector3.new(x, 26.3, -129.8), THEME.PlanterStone, Enum.Material.Concrete)
	detail("BackPierCap", Vector3.new(1.4, 0.18, 1.4),
		Vector3.new(x, 28.72, -129.8), METAL_TRIM)
end
solidDetail("BackPromenadeBrassRail", Vector3.new(180, 0.25, 0.28),
	Vector3.new(0, 27.6, -129.8), DEEP_NAVY)

-- The ENTIRE 90 x 24 stud front deck is the auto-join waiting zone,
-- not a single button/gold pad. It also serves as the spectator deck.
-- It persists for the whole server session, with no separate side runways.
local sharedDeck = decorative(
	"SharedReadyAndSpectatorDeck",
	Vector3.new(90, 1, 24),
	Vector3.new(0, 24.05, -22),
	THEME.DeckStone, Enum.Material.Concrete
)
-- Thin perimeter binding prevents the spectator stage looking like a slab.
for _, edge in ipairs({-1, 1}) do
	detail("DeckSideBrassTrim", Vector3.new(0.16, 0.14, 24),
		Vector3.new(edge * 44.85, 24.65, -22), METAL_TRIM)
end
detail("DeckFrontBrassTrim", Vector3.new(89.8, 0.14, 0.16),
	Vector3.new(0, 24.65, -9.97), METAL_TRIM)
-- Thin, low-profile trim outlines the full waiting row. No central gold
-- pad, ProximityPrompt, or client JOIN click is needed.
detail("JoinZoneBackEdge", Vector3.new(89.2, 0.055, 0.18),
	Vector3.new(0, 24.58, -33.9), THEME.Terracotta, Enum.Material.Wood)
for _, side in ipairs({-1, 1}) do
	detail("JoinZoneSideEdge", Vector3.new(0.18, 0.055, 23.6),
		Vector3.new(side * 44.9, 24.58, -22), THEME.Terracotta, Enum.Material.Wood)
end

-- Anchor the overhead join sign to the deck. The old floating panel
-- had no visible attachment; these slim posts do not block player movement.
for _, side in ipairs({-1, 1}) do
	solidDetail("JoinSignSupport", Vector3.new(0.55, 7.4, 0.55),
		Vector3.new(side * 6.25, 28.2, -25), THEME.Wood, Enum.Material.WoodPlanks)
end
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

-- The entire front edge now has a continuous, *visible* physical fence.
-- The short spectator platform ends at z=-10; there are no 95-stud side
-- runways out toward the bridge finish. Center and side panes meet at x=45.
local barrier = fenceGlass("FrontSpectatorGlassBarrier",
	Vector3.new(90, 8.5, 0.45), Vector3.new(0, 28.8, -10.25))
for _, side in ipairs({-1, 1}) do
	fenceGlass("FrontSideFenceGlass", Vector3.new(48.2, 8.5, 0.45),
		Vector3.new(side * 69.05, 28.8, -10.25))
	solidDetail("FrontFenceCornerPost", Vector3.new(1.0, 7.9, 1.0),
		Vector3.new(side * 45, 28.45, -10.25), THEME.Brown, Enum.Material.Wood)
	detail("FrontFenceCap", Vector3.new(48, 0.18, 0.65),
		Vector3.new(side * 69, 33.14, -10.25), METAL_TRIM, Enum.Material.Wood)
end
-- Only the physical fence separates the lobby and race. Keep jumps and
-- navigation unrestricted *inside* the deck and lobby.

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
lobby.Color = THEME.DeckStone
-- The stock-looking bright rectangular spawn pad was visually visible
-- above the plaza; preserve spawning/collision but hide only its rendering.
lobby.Transparency = 1
lobby.CastShadow = false
lobby.Parent = hub

-- Azure Coast staffed service kiosks. The original stalls only had a
-- back wall and a ghost counter; players could walk straight through them.
-- Both shops now have genuine walls, a solid FRONT desk, and a visible clerk.
-- Right COSMETICS is the existing functional coin shop; left stays Coming Soon.
local function makeShopkeeper(group, x, z, isCosmetics)
	local staff = Instance.new("Model")
	staff.Name = isCosmetics and "CosmeticsShopkeeper" or "ResortShopkeeper"
	staff.Parent = group
	local uniform = isCosmetics and THEME.Rose or THEME.Sage
	local skin = Color3.fromRGB(232, 183, 140)
	local pants = THEME.Brown

	-- Familiar blocky Roblox character styling. No unlicensed character IDs,
	-- uploaded textures or marketplace assets are needed for these NPCs.
	local function limb(name, size, center, color, material)
		local piece = part(name, size, center, color,
			material or Enum.Material.SmoothPlastic, staff)
		piece.CanCollide = false
		piece.CanTouch = false
		piece.CanQuery = false
		return piece
	end
	local root = limb("HumanoidRootPart", Vector3.new(2, 2, 1),
		Vector3.new(x, 27.7, z), skin)
	root.Transparency = 1
	staff.PrimaryPart = root
	limb("Torso", Vector3.new(2.1, 2.2, 1.25),
		Vector3.new(x, 28.0, z), uniform)
	limb("Left Arm", Vector3.new(0.8, 2.0, 0.95),
		Vector3.new(x - 1.5, 28.1, z), skin)
	local wavingArm = limb("Right Arm", Vector3.new(0.8, 2.0, 0.95),
		Vector3.new(x + 1.5, 28.1, z), skin)
	limb("Left Leg", Vector3.new(0.85, 2.0, 0.96),
		Vector3.new(x - 0.6, 25.95, z), pants)
	limb("Right Leg", Vector3.new(0.85, 2.0, 0.96),
		Vector3.new(x + 0.6, 25.95, z), pants)
	local head = limb("Head", Vector3.new(2.0, 2.0, 2.0),
		Vector3.new(x, 30.0, z), skin)
	head.Shape = Enum.PartType.Ball
	local face = Instance.new("Decal")
	face.Name = "FriendlyFace"
	face.Face = Enum.NormalId.Front -- faces the service-window/front (-Z)
	face.Texture = "rbxasset://textures/face.png"
	face.Parent = head
	local hair = limb("CoastalHair", Vector3.new(2.05, 0.45, 1.9),
		Vector3.new(x, 30.9, z), isCosmetics
			and Color3.fromRGB(99, 65, 55) or Color3.fromRGB(74, 53, 46))
	hair.Shape = Enum.PartType.Ball
	local hat = limb("StaffCap", Vector3.new(2.4, 0.32, 2.1),
		Vector3.new(x, 31.25, z - 0.15), THEME.Brown)
	local brim = limb("StaffCapBrim", Vector3.new(2.6, 0.16, 1.2),
		Vector3.new(x, 31.1, z - 0.72), THEME.Wood, Enum.Material.Metal)
	local badge = limb("UniformBadge", Vector3.new(0.78, 0.45, 0.1),
		Vector3.new(x + 0.5, 28.6, z - 0.68), THEME.Wood,
		Enum.Material.Metal)

	-- Humanoid metadata marks this as a real named NPC, not an anonymous part
	-- collection, while invisible anchored limbs stay safely behind the desk.
	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.RequiresNeck = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.AutoRotate = false
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.Parent = staff

	-- A tiny repeated friendly wave while on duty. Only one decorative arm
	-- animates, with no movement authority, collision or network calls.
	local wave = TweenService:Create(wavingArm,
		TweenInfo.new(1.25, Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut, -1, true),
		{CFrame = wavingArm.CFrame * CFrame.Angles(0, 0, math.rad(22))})
	wave:Play()
	return staff
end

local function makeStall(name, x, z, roofColor, line1, line2)
	local group = Instance.new("Model")
	group.Name = name
	group.Parent = hub
	local cosmetics = name == "RightCosmeticsShop"
	local floor = part("DisplayFloor", Vector3.new(17, 0.6, 14),
		Vector3.new(x, 24.325, z), THEME.PlazaStone, Enum.Material.Concrete, group)
	local back = part("BackWall", Vector3.new(17, 8.0, 1),
		Vector3.new(x, 28.4, z + 6),
		THEME.Brown, Enum.Material.Metal, group)
	for _, side in ipairs({-1, 1}) do
		-- Solid lower side and window glass enclose the shop without making
		-- the kiosk opaque. Service remains through the FRONT counter only.
		part("EnclosedShopSideWall", Vector3.new(0.8, 3.5, 12.4),
			Vector3.new(x + side * 8.1, 26.4, z),
			THEME.PlanterStone, Enum.Material.Concrete, group)
		local window = part("ShopSideGlassWindow", Vector3.new(0.35, 4.4, 12.2),
			Vector3.new(x + side * 8.1, 30.1, z),
			THEME.Foam, Enum.Material.Glass, group)
		window.Transparency = 0.35
		part("FrontShopPost", Vector3.new(1.1, 7.7, 1.1),
			Vector3.new(x + side * 7.7, 28.5, z - 5.75),
			THEME.Brown, Enum.Material.Metal, group)
		detail("GlassSideWindowBrassFrame", Vector3.new(0.1, 0.18, 12.3),
			Vector3.new(x + side * 8.1, 28.0, z), THEME.Wood,
			Enum.Material.Metal, group)
	end

	-- The front is an actual counter with a waist-high solid barrier, not a
	-- decoration at the back of the booth. All shopping happens from outside.
	local deskBase = part("ServiceCounterBase", Vector3.new(15.9, 2.75, 1.25),
		Vector3.new(x, 26.0, z - 5.5),
		THEME.Brown, Enum.Material.Metal, group)
	local deskTop = part("ServiceCounterTop", Vector3.new(16.3, 0.46, 2.05),
		Vector3.new(x, 27.55, z - 5.5),
		THEME.PlanterStone, Enum.Material.Concrete, group)
	detail("CounterFrontGoldLip", Vector3.new(16.4, 0.2, 0.21),
		Vector3.new(x, 27.78, z - 6.48),
		THEME.Wood, Enum.Material.Metal, group)
	for _, dx in ipairs({-6.65, 6.65}) do
		detail("CounterInlaidPanel", Vector3.new(0.24, 1.7, 0.11),
			Vector3.new(x + dx, 26.0, z - 6.17),
			THEME.Wood, Enum.Material.Metal, group)
	end
	local register = detail("CounterRegister", Vector3.new(1.55, 0.65, 1.25),
		Vector3.new(x + 4.8, 28.15, z - 5.25), THEME.Brown,
		Enum.Material.Metal, group)
	register.Reflectance = 0.015

	local roof = part("ColorfulRoof", Vector3.new(19, 1.3, 17),
		Vector3.new(x, 33.2, z), roofColor, Enum.Material.SmoothPlastic, group)
	roof.Reflectance = 0
	detail("RoofFrontBrassCornice", Vector3.new(19.2, 0.21, 0.55),
		Vector3.new(x, 32.6, z - 8.45), THEME.Wood, Enum.Material.Metal, group)
	for _, side in ipairs({-1, 1}) do
		detail("RoofSideBrassCornice", Vector3.new(0.24, 0.18, 17),
			Vector3.new(x + side * 9.5, 32.62, z), THEME.Wood,
			Enum.Material.Metal, group)
	end
	detail("ServiceWindowHeader", Vector3.new(15.4, 0.38, 0.45),
		Vector3.new(x, 32.25, z - 5.9), THEME.Wood, Enum.Material.Metal, group)
	local light = Instance.new("PointLight")
	light.Name = "WarmCanopyLight"
	light.Color = Color3.fromRGB(236, 213, 180)
	light.Brightness = 0.12
	light.Range = 14
	light.Shadows = false
	light.Parent = roof

	-- Put signage ABOVE the vendor's face instead of hiding the attendant
	-- behind the previous front-facing signboard.
	local header = detail("StallSignAnchor", Vector3.new(1, 1, 1),
		Vector3.new(x, 31.82, z - 6.65), THEME.Ivory,
		Enum.Material.SmoothPlastic, group)
	header.Transparency = 1
	textSign(header, line1 .. " | " .. line2, 2.2, 210)

	-- Merchandise is visible behind the window, but no extra goods or coins
	-- are for sale: only the existing saved coin cosmetics shop is functional.
	local shelf = detail("RearDisplayShelf", Vector3.new(13.3, 0.35, 2.2),
		Vector3.new(x, 27.7, z + 4.7), THEME.Wood, Enum.Material.Metal, group)
	for i = 1, 4 do
		local swatch = detail(cosmetics and "GlassColorSample" or "ComingSoonDisplay",
			Vector3.new(1.2, 1.65, 1.05),
			Vector3.new(x - 4.75 + (i - 1) * 3.15, 28.7, z + 4.7),
			cosmetics and SKIN_CATALOG[i].color or
				(i % 2 == 0 and THEME.Ivory or THEME.Foam),
			cosmetics and Enum.Material.Glass or Enum.Material.Metal, group)
		swatch.Reflectance = 0.018
	end

	makeShopkeeper(group, x - 1.15, z - 1.65, cosmetics)
	return group
end

-- Existing positions and gameplay remain unchanged. Customers approach the
-- front counter from the spawn side via the additional store access paths.
-- Match both adjoining edges exactly: the main path ends at x=+/-6.5
-- and each kiosk's 14-stud display floor begins at z=-56.
-- Previously the path was separated from both by thin grass gaps.
for _, side in ipairs({-1, 1}) do
	decorative("ShopFrontAccessWalk", Vector3.new(28.9, 0.22, 7),
		Vector3.new(side * 20.95, 24.14, -59.5),
		THEME.WalkStone, Enum.Material.Pavement)
end
makeStall("LeftShopComingSoon", -25, -49, ROOF_BLUE, "SHOP", "COMING SOON")
local cosmeticsStall = makeStall("RightCosmeticsShop", 25, -49,
	ROOF_PINK, "COSMETICS", "GLASS COLORS")
local cosmeticsDesk = assert(cosmeticsStall:FindFirstChild("ServiceCounterTop"),
	"Cosmetics kiosk is missing its front service counter")
local cosmeticsPrompt = Instance.new("ProximityPrompt")
cosmeticsPrompt.Name = "BrowseGlassSkins"
cosmeticsPrompt.ActionText = "Browse colors"
cosmeticsPrompt.ObjectText = "Cosmetics"
cosmeticsPrompt.KeyboardKeyCode = Enum.KeyCode.E
cosmeticsPrompt.HoldDuration = 0
cosmeticsPrompt.RequiresLineOfSight = false
cosmeticsPrompt.MaxActivationDistance = 12
cosmeticsPrompt.Parent = cosmeticsDesk

-- v0.29: The giant blank BACK of the leaderboard and a nearby lamp
-- previously overlapped at the plaza edge. Keep the board completely
-- outside the main plaza and make BOTH faces readable at normal scale.
local boardPost = decorative(
	"LeaderboardPost",
	Vector3.new(1.3, 7.5, 1.2),
	Vector3.new(35, 27.0, -82.9),
	WOOD, Enum.Material.Wood
)
local board = decorative(
	"LeaderboardBoard",
	Vector3.new(10.8, 6.4, 0.8),
	Vector3.new(35, 31.15, -82),
	DEEP_NAVY, Enum.Material.Metal
)
board.Reflectance = 0.012
detail("LeaderboardWoodRim", Vector3.new(11.1, 0.19, 0.95),
	Vector3.new(35, 34.42, -82), METAL_TRIM)
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
	text.TextColor3 = THEME.Brown
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

-- Clone the finished scorecard onto the formerly blank outward face.
-- Both card faces update from the same server-owned values below.
local outerBoardGui = boardGui:Clone()
outerBoardGui.Name = "ServerLeaderboardOtherSide"
outerBoardGui.Face = Enum.NormalId.Front
outerBoardGui.Parent = board
local otherBoardRows = {}
local reverseCard = outerBoardGui:FindFirstChild("ScoreCard")
for n = 1, 4 do
	otherBoardRows[n] = assert(reverseCard:FindFirstChild("Player" .. n),
		"Missing mirrored leaderboard row " .. n)
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
		otherBoardRows[i].Text = rows[i]
	end
end
local rewardsBase = decorative("FutureRewardsPodium", Vector3.new(12, 1.5, 10),
	Vector3.new(-33, 24.75, -82), METAL_TRIM, Enum.Material.Metal)
-- The rewards placard now visibly rests on the podium instead of floating.
for _, offset in ipairs({-4.3, 4.3}) do
	solidDetail("RewardSignSupport", Vector3.new(0.48, 3.0, 0.48),
		Vector3.new(-33 + offset, 26.95, -82), THEME.Wood, Enum.Material.WoodPlanks)
end
local rewardSign = decorative("FutureRewardsSignAnchor", Vector3.new(1, 1, 1), Vector3.new(-33, 27, -82), WHITE)
rewardSign.CanCollide = false
rewardSign.Transparency = 1
textSign(rewardSign, "REWARDS | COMING SOON", 2.5, 226)

-- Small cartoony trees and bushes around the EDGE, leaving sightlines open.
local function makeTree(x, z, height)
	local trunk = decorative("TreeTrunk", Vector3.new(3.1, height, 3.1),
		Vector3.new(x, 24 + height / 2, z), WOOD, Enum.Material.Wood)
	trunk.CanCollide = true
	trunk.CanQuery = true
	for dx = -1, 1 do
		for dz = -1, 1 do
			if dx == 0 or dz == 0 then
				local leaf = decorative(
					"TreeCanopy",
					Vector3.new(5.5, 5.5, 5.5),
					Vector3.new(x + dx * 3.0, 24 + height + (dx == 0 and 2.0 or 1), z + dz * 3),
					Color3.fromRGB(112 + (dx + 1) * 5, 142 + (dz + 1) * 4, 108),
					Enum.Material.LeafyGrass
				)
				leaf.Shape = Enum.PartType.Ball
				leaf.CanCollide = true
				leaf.CanTouch = false
				leaf.CanQuery = true
			end
		end
	end
end
-- Azure Coast greenery is organized around lounge edges, not across paths.
for _, spot in ipairs({
	{-84, -117, 9}, {-84, -55, 10}, {-79, -29, 8},
	{84, -117, 9}, {84, -55, 10}, {79, -29, 8},
	{-54, -116, 8}, {54, -116, 8},
}) do
	makeTree(spot[1], spot[2], spot[3])
end
for _, spot in ipairs({
	{-78, -106}, {-79, -40}, {-49, -108},
	{78, -106}, {79, -40}, {49, -108},
}) do
	local bush = decorative("CoastalFernCluster", Vector3.new(5, 3.4, 5),
		Vector3.new(spot[1], 25.65, spot[2]), THEME.Evergreen, Enum.Material.LeafyGrass)
	bush.Shape = Enum.PartType.Ball
	bush.CanCollide = true
	bush.CanTouch = false
	bush.CanQuery = true
end

-- A landscaped central arrival courtyard, behind the original spawn. Its
-- focal point is decorative and cannot obstruct the actual race path.
decorative("FountainApproach", Vector3.new(10, 0.17, 19),
	Vector3.new(0, 24.11, -109), THEME.WalkStone, Enum.Material.Concrete)
local function horizontalCylinder(item)
	item.Shape = Enum.PartType.Cylinder
	item.CFrame = CFrame.new(item.Position) * CFrame.Angles(0, 0, math.pi / 2)
	return item
end
local basin = horizontalCylinder(decorative("CentralResortFountainBasin",
	Vector3.new(0.95, 16, 16), Vector3.new(0, 24.5, -118),
	THEME.PlanterStone, Enum.Material.Concrete))
local waterMirror = horizontalCylinder(detail("FountainStillWater",
	Vector3.new(0.13, 13, 13), Vector3.new(0, 24.90, -118),
	THEME.Foam, Enum.Material.Glass))
waterMirror.Transparency = 0.22
waterMirror.Reflectance = 0.018
local pedestal = horizontalCylinder(solidDetail("FountainCrystalPedestal",
	Vector3.new(2.3, 4.5, 4.5), Vector3.new(0, 26.0, -118),
	THEME.Wood, Enum.Material.Metal))
local crystal = solidDetail("FountainSeaGlassSculpture", Vector3.new(3.5, 5.7, 3.5),
	Vector3.new(0, 29.3, -118), THEME.Foam, Enum.Material.Glass)
crystal.Shape = Enum.PartType.Ball
crystal.Transparency = 0.12
crystal.Reflectance = 0.018
local sparkle = Instance.new("PointLight")
sparkle.Name = "FountainGlow"
sparkle.Color = THEME.Foam
sparkle.Range = 13
sparkle.Brightness = 0.14
sparkle.Shadows = false
sparkle.Parent = crystal
for _, side in ipairs({-1, 1}) do
	detail("FountainStoneSideSeat", Vector3.new(5, 0.55, 2.2),
		Vector3.new(side * 13, 25.0, -118), THEME.PlanterStone, Enum.Material.Concrete)
end

-- Proper multiplayer-friendly Seats, rather than decorative slabs. Each
-- bench holds TWO separate players. Touching the Seat or pressing E will
-- attach a standard Roblox Sit weld; jumping gets you up normally.
local function coastBench(x, z)
	local bench = Instance.new("Model")
	bench.Name = "CoastTwoPersonBench"
	bench.Parent = hub

	solidDetail("ResortTeakBack", Vector3.new(8.4, 2.0, 0.5),
		Vector3.new(x, 26.75, z + 1.24),
		WOOD, Enum.Material.WoodPlanks, bench)
	for _, side in ipairs({-1, 1}) do
		solidDetail("ResortBenchLeg", Vector3.new(0.55, 1.72, 2.2),
			Vector3.new(x + side * 3.6, 24.86, z),
			THEME.Brown, Enum.Material.Metal, bench)
		local seat = Instance.new("Seat")
		seat.Name = side < 0 and "LeftSeat" or "RightSeat"
		seat.Size = Vector3.new(3.9, 0.46, 2.25)
		seat.Position = Vector3.new(x + side * 2.06, 25.72, z)
		seat.Anchored = true
		seat.CanCollide = true
		seat.Disabled = false
		seat.Material = Enum.Material.WoodPlanks
		seat.Color = WOOD
		seat.TopSurface = Enum.SurfaceType.Smooth
		seat.BottomSurface = Enum.SurfaceType.Smooth
		seat.Parent = bench

		local sit = Instance.new("ProximityPrompt")
		sit.Name = "SitOnBench"
		sit.ActionText = "Sit"
		sit.ObjectText = "Resort bench"
		sit.KeyboardKeyCode = Enum.KeyCode.E
		sit.HoldDuration = 0
		sit.MaxActivationDistance = 8
		sit.RequiresLineOfSight = false
		sit.Parent = seat
		seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			sit.Enabled = seat.Occupant == nil
		end)
		sit.Triggered:Connect(function(player)
			if seat.Occupant or player.Parent ~= Players then return end
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and root
				and (root.Position - seat.Position).Magnitude <= 9 then
				seat:Sit(humanoid)
			end
		end)
	end
end
for _, side in ipairs({-1, 1}) do
	coastBench(side * 42, -99)
	coastBench(side * 53, -71)
	coastBench(side * 75, -95)
end

local function planter(x, z)
	solidDetail("CoastCeramicPlanter", Vector3.new(4.5, 2.7, 4.5),
		Vector3.new(x, 25.35, z), THEME.PlanterStone, Enum.Material.Concrete)
	local foliage = solidDetail("CoastShrub", Vector3.new(5.1, 4.2, 5.1),
		Vector3.new(x, 28.15, z), THEME.Evergreen, Enum.Material.LeafyGrass)
	foliage.Shape = Enum.PartType.Ball
end
for _, pair in ipairs({
	{-32, -102}, {32, -102}, {-33, -65}, {33, -65},
	{-72, -113}, {72, -113}, {-74, -52}, {74, -52}
}) do planter(pair[1], pair[2]) end

-- Shaded lounges have physical columns and roofs, leaving entrances clear.
-- Upper hanging lanterns/slats remain decorative to avoid snagging avatars.
for _, side in ipairs({-1, 1}) do
	local x = side * 68
	local z = -71
	for _, dx in ipairs({-8, 8}) do
		for _, dz in ipairs({-7, 7}) do
			solidDetail("CoastPergolaColumn", Vector3.new(0.85, 8.1, 0.85),
				Vector3.new(x + dx, 28.05, z + dz), THEME.PlanterStone, Enum.Material.Concrete)
		end
	end
	solidDetail("CoastPergolaRoof", Vector3.new(18.3, 0.55, 16),
		Vector3.new(x, 31.95, z), THEME.Brown, Enum.Material.Metal)
	for _, slatX in ipairs({-6, -3, 0, 3, 6}) do
		detail("PergolaChampagneSlat", Vector3.new(0.2, 0.1, 15.5),
			Vector3.new(x + slatX, 32.27, z), THEME.Wood)
	end
	coastBench(x, -70)
	-- A visible short suspension stem connects each lantern to its roof.
	detail("PergolaLanternStem", Vector3.new(0.2, 0.48, 0.2),
		Vector3.new(x, 31.53, z - 4), THEME.Wood, Enum.Material.Wood)
	local lantern = detail("PergolaHangingLantern", Vector3.new(1.4, 1.4, 1.4),
		Vector3.new(x, 30.7, z - 4), THEME.Foam, Enum.Material.Glass)
	local light = Instance.new("PointLight")
	light.Name = "LoungeAmbientLight"
	light.Color = Color3.fromRGB(235, 214, 183)
	light.Brightness = 0.12
	light.Range = 12
	light.Shadows = false
	light.Parent = lantern
end

-- Lamps guide players naturally from the expanded plaza to JOIN without
-- screenspace arrows or intrusive floating titles.
local function resortLamp(x, z)
	solidDetail("ResortLampPedestal", Vector3.new(2.0, 0.7, 2.0),
		Vector3.new(x, 24.35, z), THEME.PlanterStone, Enum.Material.Concrete)
	solidDetail("ResortLampColumn", Vector3.new(0.75, 7.65, 0.75),
		Vector3.new(x, 28.23, z), THEME.Brown, Enum.Material.Metal)
	local lamp = detail("ResortLantern", Vector3.new(1.5, 1.6, 1.5),
		Vector3.new(x, 32.8, z), THEME.Foam, Enum.Material.Glass)
	detail("LanternChampagneCap", Vector3.new(1.8, 0.2, 1.8),
		Vector3.new(x, 33.67, z), THEME.Wood)
	local glow = Instance.new("PointLight")
	glow.Name = "AzureCoastLampLight"
	glow.Color = Color3.fromRGB(235, 213, 187)
	glow.Range = 13
	glow.Brightness = 0.11
	glow.Shadows = false
	glow.Parent = lamp
end
-- Keep these fixtures out of the leaderboard and rewards podium footprints.
-- Earlier x=+/-34 at z=-83 interpenetrated both display structures.
for _, pair in ipairs({
	{-47, -79}, {47, -79},
	{-12, -64}, {12, -64},
	{-12, -34}, {12, -34},
	{-79, -91}, {79, -91},
}) do resortLamp(pair[1], pair[2]) end

-- Two small scenic attractions give the wider island a reason to explore:
-- a photo frame facing the ocean and a compact trophy-sculpture courtyard.
local photoX, photoZ = 70, -110
for _, side in ipairs({-1, 1}) do
	solidDetail("PhotoArchColumn", Vector3.new(1.5, 11, 1.5),
		Vector3.new(photoX + side * 6, 29.5, photoZ),
		THEME.Brown, Enum.Material.Metal)
end
solidDetail("PhotoArchHeader", Vector3.new(14.2, 1.25, 1.6),
	Vector3.new(photoX, 35.3, photoZ), THEME.Wood)
local photoAnchor = detail("CoastPhotoSpotSignAnchor", Vector3.new(0.5, 0.5, 0.5),
	Vector3.new(photoX, 32.4, photoZ - 1), THEME.Brown)
textSign(photoAnchor, "PHOTO SPOT | SOFT EARTH COAST", 1.0, 210)

local trophyX, trophyZ = -67, -110
local trophyStand = horizontalCylinder(solidDetail("AzureTrophyPedestal",
	Vector3.new(2.0, 7, 7), Vector3.new(trophyX, 25.0, trophyZ),
	THEME.PlanterStone, Enum.Material.Concrete))
local trophy = solidDetail("AzureTrophySculpture", Vector3.new(3.4, 6, 3.4),
	Vector3.new(trophyX, 29.0, trophyZ), THEME.Wood)
trophy.Shape = Enum.PartType.Ball
trophy.Reflectance = 0.01
local trophyAnchor = detail("TrophyCourtyardSignAnchor", Vector3.new(0.5, 0.5, 0.5),
	Vector3.new(trophyX, 33.3, trophyZ - 1.5), THEME.Brown)
textSign(trophyAnchor, "TROPHY GARDEN | SOCIAL PLAZA", 0.3, 230)

-- Calm sea backdrop covers the template's empty gray baseplate when viewed
-- from the arena; unlike the grass island it has no collision.
local ocean = part(
	"OceanBackdrop", Vector3.new(1800, 1.5, 1800),
	Vector3.new(0, 0.6, 58), THEME.Ocean, Enum.Material.SmoothPlastic
)
ocean.CanCollide = false
ocean.CanTouch = false
ocean.CanQuery = false
ocean.Reflectance = 0.014

-- Sparse ocean glints: reflective wave texture without huge moving models.
for i = 1, 32 do
	local column = i % 4
	local band = math.floor(i / 4)
	local x = -145 + column * 95 + (i % 3) * 7
	local z = -128 + band * 58
	local shimmer = detail("OceanSunGlint", Vector3.new(10 + i % 5, 0.025, 0.3),
		Vector3.new(x, 1.39, z), THEME.Foam, Enum.Material.SmoothPlastic, world)
	shimmer.Transparency = 0.65
end

-- Layered, low-poly destination silhouettes frame the horizon. These
-- noncolliding islands are visual-only and cannot become a second playfield.
for _, loc in ipairs({
	{-290, -120, 1.15}, {-245, 180, 0.8}, {-355, 235, 0.7},
	{290, -90, 1.1}, {255, 205, 0.85}, {365, 255, 0.65},
}) do
	local dx, dz, scale = loc[1], loc[2], loc[3]
	local rock = detail("AzureCoastDistantCliff",
		Vector3.new(62 * scale, 20 * scale, 50 * scale),
		Vector3.new(dx, 4 + 3 * scale, dz),
		THEME.Stone, Enum.Material.Rock, world)
	rock.Shape = Enum.PartType.Ball
	local cap = detail("DistantIslandEvergreen",
		Vector3.new(54 * scale, 8 * scale, 44 * scale),
		Vector3.new(dx, 13 * scale, dz), THEME.Evergreen,
		Enum.Material.Grass, world)
	cap.Shape = Enum.PartType.Ball
	for _, side in ipairs({-1, 1}) do
		local palm = detail("DistantTreeTrunk",
			Vector3.new(1.7 * scale, 11 * scale, 1.7 * scale),
			Vector3.new(dx + side * 12 * scale, 18 * scale, dz),
			WOOD, Enum.Material.Wood, world)
		local canopy = detail("DistantTreeCrown",
			Vector3.new(13 * scale, 8 * scale, 13 * scale),
			Vector3.new(dx + side * 12 * scale, 25 * scale, dz),
			THEME.Evergreen, Enum.Material.LeafyGrass, world)
		canopy.Shape = Enum.PartType.Ball
	end
end

-- Roblox's built-in CrackedLava has physically textured dark crust rather
-- than the previous solid glowing orange rectangle.
local lava = part("Lava", Vector3.new(105, 2, 235),
	Vector3.new(0, 7, 68), Color3.fromRGB(247, 105, 64), Enum.Material.CrackedLava)
lava.CanCollide = false
lava.Transparency = 0.03
for _, edge in ipairs({-1, 1}) do
	detail("VolcanicBasaltRim", Vector3.new(1.4, 1.1, 235),
		Vector3.new(edge * 52.9, 8.05, 68), Color3.fromRGB(56, 60, 70),
		Enum.Material.Basalt, world)
end
for i = 1, 16 do
	local x = ((i * 19) % 83) - 41
	local z = -40 + i * 13
	local flow = detail("MoltenHighlight", Vector3.new(1.2, 0.035, 6 + i % 5),
		Vector3.new(x, 8.02, z), Color3.fromRGB(254, 143, 76),
		Enum.Material.Neon, world)
	flow.Transparency = 0.28
end
lava.Touched:Connect(function(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.Health = 0 end
end)

-- Ocean and skyline are decorative. Anyone falling below the suspended
-- island/bridges is returned to the actual lobby spawn rather than being
-- allowed to roam on old template parts or below the map.
local fallReset = part("WorldFallReset", Vector3.new(1800, 1.5, 1800),
	Vector3.new(0, 10.5, 0), THEME.Brown, Enum.Material.SmoothPlastic, world)
fallReset.CanCollide = false
fallReset.CanTouch = true
fallReset.CanQuery = false
fallReset.Transparency = 1
fallReset.CastShadow = false
fallReset.Touched:Connect(function(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 and Players:GetPlayerFromCharacter(character) then
		humanoid.Health = 0
	end
end)
-- Touch events can be missed at high fall speeds or under lag. Independently
-- verify root height every quarter second across JOIN/VOTE/REVEAL/MOVE.
local fallCheckElapsed = 0
RunService.Heartbeat:Connect(function(dt)
	fallCheckElapsed += dt
	if fallCheckElapsed < 0.25 then return end
	fallCheckElapsed = 0
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0
			and root.Position.Y < SETTINGS.BridgeY - 13 then
			humanoid.Health = 0
		end
	end
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
			tile.Transparency = 0.25
			tile.Reflectance = 0.025
			lanes[lane].tiles[index] = tile
			-- Tiny, uniform brushed-metal corner brackets on every tile.
			-- All panels receive the same trim: no valid steps are disclosed.
			for _, corner in ipairs({-1, 1}) do
				detail("GlassCornerMetal", Vector3.new(0.58, 0.07, 0.58),
					Vector3.new(x + corner * 2.84, SETTINGS.BridgeY + 0.47,
						index * SETTINGS.TileSpacing + 2.83),
					THEME.Wood, Enum.Material.Metal, bridgeModel)
			end
		end
		-- Pale-blue decorative rails sit below the glass and cannot be stood on.
		-- Only two rails per player, keeping the world small on mobile devices.
		for _, edge in ipairs({-1, 1}) do
			local rail = part(
				("Lane%02d_EdgeGlow"):format(lane),
				Vector3.new(0.35, 0.35, SETTINGS.TileSpacing * SETTINGS.BridgeLength + 6.7),
				Vector3.new(x + edge * (3.35 - 0.175), SETTINGS.BridgeY - 0.625, SETTINGS.BridgeLength * SETTINGS.TileSpacing / 2),
				THEME.Brown, Enum.Material.Metal, bridgeModel
			)
			rail.CanCollide = false
			rail.CanTouch = false
			rail.Transparency = 0.23
			rail.Reflectance = 0.015
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
		THEME.Ivory, Enum.Material.Metal, bridgeModel
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
	name.TextColor3 = THEME.Brown
	name.TextSize = 65
	name.TextScaled = false
	name.Parent = gateText

	for _, side in ipairs({-1, 1}) do
		local column = part(
			"FinishGatePillar",
			Vector3.new(2.0, 11.7, 2.5),
			Vector3.new(side * postX, SETTINGS.BridgeY + 5.85, finishZ),
			THEME.Sage, Enum.Material.Metal, bridgeModel
		)
		column.CanCollide = false
		column.CanTouch = false
	end
	-- A gold cap and thin metallic vertical highlights frame the finish sign.
	detail("FinishGateBrassTop", Vector3.new(occupiedSpan + 6.4, 0.22, 1.55),
		Vector3.new(0, SETTINGS.BridgeY + 13.18, finishZ), METAL_TRIM,
		Enum.Material.Metal, bridgeModel)
	for _, side in ipairs({-1, 1}) do
		detail("FinishPillarAccent", Vector3.new(0.14, 10.8, 0.22),
			Vector3.new(side * postX, SETTINGS.BridgeY + 5.86, finishZ - 1.29),
			METAL_TRIM, Enum.Material.Metal, bridgeModel)
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
				i % 2 == 0 and THEME.Brown or WHITE,
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
local practiceWithoutRewards = false
-- Reject excessively repeated remote requests without changing normal inputs.
-- The server still owns every vote, purchase, movement and reward decision.
local COMMAND_COOLDOWN = { Sync = 1.0, Vote = 0.065, Shop = 0.35 }
local lastRemoteCommand = {}
local lastShopPrompt = {}
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

-- Never freeze or suppress player locomotion during JOIN/VOTE/REVEAL/MOVE.
-- The server still validates bridge advancement by tile, phase and range.
local function keepMovementEnabled(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = SETTINGS.WalkSpeed
		humanoid.JumpPower = 50
		humanoid.JumpHeight = 7.2
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
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
	number.TextColor3 = THEME.Brown
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
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.55, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	})
	particles.Color = ColorSequence.new(shade)
	particles.LightEmission = 0.3
	particles.EmissionDirection = Enum.NormalId.Top
	particles.Parent = tile
	particles:Emit(amount or 10)
	Debris:AddItem(particles, 1.5)
end

local finishCelebrated = false
local function finishConfetti()
	if finishCelebrated or not finishCenter or not finishCenter.Parent then return end
	finishCelebrated = true
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
		ColorSequenceKeypoint.new(0, THEME.Terracotta),
		ColorSequenceKeypoint.new(0.5, THEME.Sage),
		ColorSequenceKeypoint.new(1, THEME.Rose)
	})
	emitter.Parent = finishCenter
	emitter:Emit(60)
	Debris:AddItem(emitter, 3)
end

-- v0.17: winners dance during RESULTS only, visible to all players.
-- The IDs are Roblox's built-in character dance animations, selected by rig.
-- This is presentation only; no teleport, extra reward or new match outcome.
local function startWinnerDances(winners)
	local tracks = {}
	for _, winner in ipairs(winners) do
		if winner.Parent == Players then
			local character = winner.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local animator = humanoid:FindFirstChildOfClass("Animator")
				if not animator then
					animator = Instance.new("Animator")
					animator.Parent = humanoid
				end
				local animation = Instance.new("Animation")
				animation.Name = "MythbloxVictoryDance"
				animation.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15
					and SETTINGS.VictoryDanceR15 or SETTINGS.VictoryDanceR6
				local ok, trackOrError = pcall(function()
					local track = animator:LoadAnimation(animation)
					track.Priority = Enum.AnimationPriority.Action
					track.Looped = true
					track:Play(0.2)
					return track
				end)
				if ok then
					table.insert(tracks, {track = trackOrError, animation = animation})
				else
					warn("[Mythblox] Victory dance unavailable for "
						.. winner.Name .. ": " .. tostring(trackOrError))
					animation:Destroy() -- Confetti and winner text still work.
				end
			end
		end
	end
	return tracks
end

local function stopWinnerDances(tracks)
	for _, entry in ipairs(tracks) do
		pcall(function()
			entry.track:Stop(0.2)
			entry.track:Destroy()
			entry.animation:Destroy()
		end)
	end
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
		line.BackgroundColor3 = THEME.Brown
		line.BorderSizePixel = 0
		line.Parent = overlay
	end
end

local function shatter(tile, dramatic)
	if not tile or not tile.CanCollide then return end
	if dramatic then
		glassBurst(tile, Color3.fromRGB(180, 237, 255), 23)
		-- A few temporary, harmless glass fragments make the fall visible
		-- to spectators without changing any collision or movement rules.
		for index = 1, 7 do
			local shard = Instance.new("Part")
			shard.Name = "GlassFragment"
			shard.Size = Vector3.new(0.45, 0.18, 0.75)
			shard.Color = tile.Color
			shard.Material = Enum.Material.Glass
			shard.Transparency = 0.18
			shard.CanCollide = false
			shard.CanTouch = false
			shard.CanQuery = false
			shard.Position = tile.Position + Vector3.new(
				math.cos(index * 2.4) * 1.2, 0.5, math.sin(index * 2.4) * 1.2
			)
			shard.Parent = world
			shard.AssemblyLinearVelocity = Vector3.new(
				math.cos(index * 2.4) * 11, math.random(11, 18),
				math.sin(index * 2.4) * 11
			)
			Debris:AddItem(shard, 1.3)
		end
	end
	tile.CanCollide = false
	tile.CanTouch = false
	-- Never flash a whole tile red: glass fades/shatters in its current tint.
	TweenService:Create(tile, TweenInfo.new(0.3), {Transparency = 1}):Play()
end

local function eliminate(player, reason, tileToBreak)
	local info = active[player]
	if not info or not info.alive then return end
	info.alive = false
	info.elimination = reason
	info.allowed = 0
	-- The attempted step and the last supporting glass must actually break.
	-- Do not recolor intact glass or reveal which other panels are safe.
	if tileToBreak then shatter(tileToBreak, true) end
	local lane = lanes[info.lane]
	local standingTile = lane and lane.tiles[info.index]
	if standingTile and standingTile ~= tileToBreak then
		shatter(standingTile, true)
	end
	message = player.DisplayName .. " fell! (" .. reason .. ")"
	print(("[Mythblox RACE] ELIMINATED %s: %s"):format(player.Name, reason))
	if publish then publish() end

	-- v0.18 regression fix: simply setting alive=false was not enough once
	-- free walking/jumping was allowed. The character could keep running on
	-- untouched panels because only alive racers are validated. Let the
	-- shatter play briefly, then trigger the ordinary lobby respawn.
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		task.delay(0.2, function()
			if player.Character == character and humanoid.Parent and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end)
	end
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
		-- Damage is indicated by crack geometry and particles, not a red/green
		-- repaint of the entire panel.
		showCrackLines(currentTile, info.cracks)
		glassBurst(currentTile, AMBER, 6)
	end
end

-- Neutral glass never changes color to disclose the permitted step path.
-- The compact HUD and the private result determine GO/STAY, while the
-- server enforces legal forward movement after vote reveal.

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
		liveSoloPractice = SETTINGS.LiveSoloPractice and not RunService:IsStudio(),
		practiceNoRewards = practiceWithoutRewards,
		participating = mine ~= nil,
		mine = mine and {
			position = mine.index,
			cracks = mine.cracks,
			alive = mine.alive,
			vote = mine.vote,
			allowed = mine.allowed,
			start = mine.startIndex,
			elimination = mine.elimination,
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
		deckSignText.Text = ("STAND IN ZONE  ·  %ds  ·  %d READY"):format(secondsLeft, numberReady())
	elseif phase == "RESULTS" then
		deckSignText.Text = "ROUND FINISHED  |  NEXT MATCH SOON"
	else
		deckSignText.Text = ("WATCH MATCH  ·  %d LEFT"):format(#survivors())
	end
	for _, player in ipairs(Players:GetPlayers()) do
		stateEvent:FireClient(player, snapshot(player))
	end
end

-- Server-owned continuous zone membership: a player joins by occupying
-- ANY part of the front deck during JOIN and only stays queued while present.
-- This uses character positions, not Touch events or a client claim, so
-- standing still, walking, respawning and jumping all work reliably.
local function insideJoinZone(player)
	if player.Parent ~= Players then return false end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then return false end
	local pos = root.Position
	return math.abs(pos.X - sharedDeck.Position.X) <= sharedDeck.Size.X / 2 - 0.75
		and math.abs(pos.Z - sharedDeck.Position.Z) <= sharedDeck.Size.Z / 2 - 0.75
		and pos.Y >= sharedDeck.Position.Y - 0.5
		and pos.Y <= sharedDeck.Position.Y + 16
end

local function refreshJoinZoneQueue()
	if phase ~= "JOIN" then return end
	local updated = false
	local ready = 0
	for _, player in ipairs(Players:GetPlayers()) do
		local inZone = insideJoinZone(player)
		-- Server capacity still limits each race to eight participants.
		local shouldQueue = inZone and ready < SETTINGS.MaxPlayers
		if shouldQueue then ready += 1 end
		if queue[player] ~= (shouldQueue or nil) then
			queue[player] = shouldQueue or nil
			updated = true
			print(("[Mythblox ZONE] %s %s (%d ready)"):format(
				player.Name, shouldQueue and "entered" or "left", ready))
		end
	end
	if updated then publish() end
end

local joinZoneElapsed = 0
RunService.Heartbeat:Connect(function(dt)
	joinZoneElapsed += dt
	if joinZoneElapsed < 0.2 then return end
	joinZoneElapsed = 0
	refreshJoinZoneQueue()
end)

-- v0.13: Server-owned progress, saved as one per-user DataStore record.
-- Studio and published experiences NEVER share a store. Studio requires its
-- own API Services permission; when unavailable, play remains session-only.
-- Increment-based UpdateAsync prevents lost rewards on overlapping servers.
local DATA_STORE_NAME = RunService:IsStudio()
	and "MythbloxGame01_Progress_Studio_v1"
	or "MythbloxGame01_Progress_v1"
local dataStore = nil
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(DATA_STORE_NAME)
	end)
	if ok then
		dataStore = result
	else
		warn("[Mythblox DATA] Could not open data store: " .. tostring(result))
	end
end
local profiles = {}
local MAX_STAT = 2000000000

local function safeStat(value)
	if type(value) ~= "number" or value ~= value or value < 0 then return 0 end
	return math.clamp(math.floor(value), 0, MAX_STAT)
end

local function validRecord(value)
	if value == nil then return true end
	if type(value) ~= "table" then return false end
	if value.schema ~= nil and value.schema ~= 1 then return false end
	for _, field in ipairs({"wins", "coins"}) do
		local amount = value[field]
		if amount ~= nil and (type(amount) ~= "number" or amount ~= amount or amount < 0) then
			return false
		end
	end
	if value.ownedSkins ~= nil and type(value.ownedSkins) ~= "table" then return false end
	if value.equippedSkin ~= nil and type(value.equippedSkin) ~= "string" then return false end
	return true
end

local function sanitizedOwned(saved)
	local owned = {}
	if type(saved) == "table" then
		for id, value in pairs(saved) do
			if id ~= "classic" and SKIN_BY_ID[id] and value == true then
				owned[id] = true
			end
		end
	end
	return owned
end

local function sanitizedEquipped(saved, owned)
	if saved == "classic" then return "classic" end
	if type(saved) == "string" and owned[saved] and SKIN_BY_ID[saved] then
		return saved
	end
	return "classic"
end

local function shopSnapshot(player)
	local profile = profiles[player]
	local coins = player:FindFirstChild("leaderstats")
	coins = coins and coins:FindFirstChild("Coins")
	local items = {}
	for _, item in ipairs(SKIN_CATALOG) do
		table.insert(items, {
			id = item.id, title = item.title, price = item.price,
			color = item.color,
		})
	end
	return {
		items = items,
		owned = profile and sanitizedOwned(profile.ownedSkins) or {},
		equipped = profile and profile.equippedSkin or "classic",
		coins = coins and coins.Value or 0,
		ready = profile ~= nil and profile.status == "ready",
	}
end

local function sendShop(player, kind, message)
	if player.Parent ~= Players then return end
	shopEvent:FireClient(player, kind, shopSnapshot(player), message)
end

local function nearCosmetics(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return root ~= nil and (root.Position - cosmeticsDesk.Position).Magnitude <= 18
end

local function updateProfileView(player, profile)
	local stats = player:FindFirstChild("leaderstats")
	if not stats or player.Parent ~= Players then return end
	local wins = stats:FindFirstChild("Wins")
	local coins = stats:FindFirstChild("Coins")
	if wins then wins.Value = safeStat(profile.baseWins + profile.pendingWins) end
	if coins then coins.Value = safeStat(profile.baseCoins + profile.pendingCoins) end
	refreshSessionLeaderboard()
end

local function loadProfile(player)
	local profile = profiles[player]
	if not profile then return end
	if not dataStore then
		profile.status = "unavailable"
		if player.Parent == Players then player:SetAttribute("MythbloxDataStatus", "SESSION_ONLY") end
		return
	end

	local lastError
	for attempt = 1, 3 do
		local ok, stored = pcall(function()
			return dataStore:GetAsync(profile.key)
		end)
		if profiles[player] ~= profile then return end
		if ok and validRecord(stored) then
			profile.baseWins = stored and safeStat(stored.wins) or 0
			profile.baseCoins = stored and safeStat(stored.coins) or 0
			profile.ownedSkins = sanitizedOwned(stored and stored.ownedSkins)
			profile.equippedSkin = sanitizedEquipped(stored and stored.equippedSkin, profile.ownedSkins)
			equippedSkins[player] = profile.equippedSkin
			profile.status = "ready"
			if player.Parent == Players then
				updateProfileView(player, profile)
				player:SetAttribute("MythbloxDataStatus", "READY")
				sendShop(player, "Update", "")
			end
			print(("[Mythblox DATA] Loaded %s: %d wins, %d coins (%s)"):format(
				player.Name, profile.baseWins, profile.baseCoins, DATA_STORE_NAME
			))
			return
		end
		lastError = ok and "invalid stored data format" or tostring(stored)
		if ok then break end -- Do not overwrite malformed saved data.
		if attempt < 3 then task.wait(2 ^ (attempt - 1) + math.random() * 0.5) end
	end

	-- Critical: NEVER overwrite persistent data with defaults after a failed load.
	profile.status = "unavailable"
	if player.Parent == Players then player:SetAttribute("MythbloxDataStatus", "SESSION_ONLY") end
	warn("[Mythblox DATA] LOAD FAILED for " .. player.Name .. ": " ..
		tostring(lastError) .. ". This session's rewards will NOT be saved.")
end

local function awardProgress(player, addedWins, addedCoins)
	local profile = profiles[player]
	if not profile then
		warn("[Mythblox DATA] No profile exists for " .. player.Name)
		return
	end
	profile.pendingWins += safeStat(addedWins)
	profile.pendingCoins += safeStat(addedCoins)
	updateProfileView(player, profile)
end

local function saveProfile(player, reason)
	local profile = profiles[player]
	if not profile or profile.status ~= "ready" or not dataStore then return false end

	-- One save at a time per user, including overlapping autosave and shutdown.
	local waitUntil = os.clock() + 12
	while profile.saving and os.clock() < waitUntil do task.wait(0.1) end
	if profile.saving then
		warn("[Mythblox DATA] Save still busy for " .. player.Name .. " (" .. reason .. ")")
		return false
	end

	-- Keep the same reward batch ID after a failed/uncertain cloud response;
	-- a later autosave must not treat those same rewards as a new transaction.
	local batch = profile.rewardBatch
	if not batch then
		if profile.pendingWins == 0 and profile.pendingCoins == 0 then return true end
		batch = {
			id = HttpService:GenerateGUID(false),
			wins = profile.pendingWins,
			coins = profile.pendingCoins,
		}
		profile.rewardBatch = batch
	end
	local winsDelta = batch.wins
	local coinsDelta = batch.coins
	local operationId = batch.id
	profile.saving = true

	local lastError
	for attempt = 1, 3 do
		local ok, result = pcall(function()
			return dataStore:UpdateAsync(profile.key, function(stored)
				-- Callback may be rerun by Roblox: no yields, no side effects.
				if not validRecord(stored) then return nil end
				local recent = {}
				if stored and type(stored.recentSaves) == "table" then
					for _, token in ipairs(stored.recentSaves) do
						if type(token) == "string" then
							if token == operationId then return stored end
							table.insert(recent, token)
						end
					end
				end
				-- Bound storage size; 20 recent transaction IDs suffice for
				-- retry protection without unbounded profile growth.
				while #recent >= 20 do table.remove(recent, 1) end
				table.insert(recent, operationId)
				local oldWins = stored and safeStat(stored.wins) or 0
				local oldCoins = stored and safeStat(stored.coins) or 0
				return {
					schema = 1,
					wins = safeStat(oldWins + winsDelta),
					coins = safeStat(oldCoins + coinsDelta),
					-- Preserve shop fields written by another live server.
					ownedSkins = sanitizedOwned(stored and stored.ownedSkins),
					equippedSkin = stored and stored.equippedSkin or "classic",
					recentSaves = recent,
				}
			end)
		end)
		if ok and type(result) == "table" then
			-- Rewards granted while the save was in flight remain pending.
			profile.pendingWins = math.max(0, profile.pendingWins - winsDelta)
			profile.pendingCoins = math.max(0, profile.pendingCoins - coinsDelta)
			profile.rewardBatch = nil
			profile.baseWins = safeStat(result.wins)
			profile.baseCoins = safeStat(result.coins)
			profile.ownedSkins = sanitizedOwned(result.ownedSkins)
			profile.equippedSkin = sanitizedEquipped(result.equippedSkin, profile.ownedSkins)
			equippedSkins[player] = profile.equippedSkin
			profile.saving = false
			updateProfileView(player, profile)
			if player.Parent == Players then player:SetAttribute("MythbloxDataStatus", "READY") end
			print(("[Mythblox DATA] Saved %s (+%dW +%dC; %s)"):format(
				player.Name, winsDelta, coinsDelta, reason
			))
			return true
		end
		lastError = ok and "update was cancelled by invalid stored data" or tostring(result)
		if ok then break end
		if attempt < 3 then task.wait(2 ^ (attempt - 1) + math.random() * 0.5) end
	end
	profile.saving = false
	if player.Parent == Players then player:SetAttribute("MythbloxDataStatus", "SAVE_ERROR") end
	warn("[Mythblox DATA] SAVE FAILED for " .. player.Name ..
		" (" .. reason .. "): " .. tostring(lastError) ..
		". Rewards remain pending in this server.")
	return false
end

-- A cosmetic purchase/equip transaction uses the SAME stored record as earned
-- coins. UpdateAsync checks ownership and balance atomically; no client prices.
-- It also commits any pending match rewards in the same write.
local function transactSkin(player, skinId)
	if player.Parent ~= Players then return end
	if not nearCosmetics(player) then
		sendShop(player, "Update", "Return to the cosmetics stall.")
		return
	end
	local item = SKIN_BY_ID[skinId]
	if not item then return end
	local profile = profiles[player]
	if not profile or profile.status ~= "ready" or not dataStore then
		sendShop(player, "Update", "Saving is unavailable. Please try again later.")
		return
	end
	if profile.saving then
		sendShop(player, "Update", "Saving in progress. Try again.")
		return
	end
	if profile.rewardBatch then
		sendShop(player, "Update", "Saving recent winnings. Try again shortly.")
		task.spawn(saveProfile, player, "pre-purchase")
		return
	end
	if os.clock() - (profile.lastShopAction or 0) < 0.65 then
		sendShop(player, "Update", "Try again in a moment.")
		return
	end
	profile.lastShopAction = os.clock()
	local alreadyOwned = skinId == "classic" or profile.ownedSkins[skinId] == true
	if not alreadyOwned and profile.baseCoins + profile.pendingCoins < item.price then
		sendShop(player, "Update", "Not enough coins.")
		return
	end
	if alreadyOwned and profile.equippedSkin == skinId then
		sendShop(player, "Update", "Already equipped.")
		return
	end

	profile.saving = true -- lock with autosave, leave and shutdown
	local winsDelta = profile.pendingWins
	local coinsDelta = profile.pendingCoins
	local operationId = HttpService:GenerateGUID(false)
	local lastError
	local insufficient = false

	for attempt = 1, 3 do
		insufficient = false
		local ok, saved = pcall(function()
			return dataStore:UpdateAsync(profile.key, function(stored)
				if not validRecord(stored) then return nil end
				local recent = {}
				if stored and type(stored.recentSaves) == "table" then
					for _, token in ipairs(stored.recentSaves) do
						if type(token) == "string" then
							if token == operationId then return stored end
							table.insert(recent, token)
						end
					end
				end
				while #recent >= 20 do table.remove(recent, 1) end
				table.insert(recent, operationId)

				local owned = sanitizedOwned(stored and stored.ownedSkins)
				local hasSkin = skinId == "classic" or owned[skinId] == true
				local cost = hasSkin and 0 or item.price
				local wallet = safeStat(stored and stored.coins) + coinsDelta
				if wallet < cost then
					insufficient = true
					return nil -- atomic rejection: no accidental negative balance
				end
				if skinId ~= "classic" then owned[skinId] = true end
				return {
					schema = 1,
					wins = safeStat((stored and stored.wins or 0) + winsDelta),
					coins = safeStat(wallet - cost),
					ownedSkins = owned,
					equippedSkin = skinId,
					recentSaves = recent,
				}
			end)
		end)
		if ok and type(saved) == "table" then
			profile.pendingWins = math.max(0, profile.pendingWins - winsDelta)
			profile.pendingCoins = math.max(0, profile.pendingCoins - coinsDelta)
			profile.baseWins = safeStat(saved.wins)
			profile.baseCoins = safeStat(saved.coins)
			profile.ownedSkins = sanitizedOwned(saved.ownedSkins)
			profile.equippedSkin = sanitizedEquipped(saved.equippedSkin, profile.ownedSkins)
			equippedSkins[player] = profile.equippedSkin
			profile.saving = false
			updateProfileView(player, profile)
			if player.Parent == Players then
				player:SetAttribute("MythbloxDataStatus", "READY")
				sendShop(player, "Update", item.title .. " equipped.")
			end
			print("[Mythblox SHOP] " .. player.Name .. " equipped " .. skinId)
			return
		end
		lastError = ok and (insufficient and "Not enough coins." or "Shop purchase rejected.") or tostring(saved)
		if ok then break end
		if attempt < 3 then task.wait(2 ^ (attempt - 1) + math.random() * 0.5) end
	end
	profile.saving = false
	if not insufficient then
		-- The transaction could have reached Roblox even without a response.
		-- Do not spend or save another pending batch in this session; a fresh
		-- login will recover the real stored balance/ownership.
		profile.status = "unavailable"
	end
	if player.Parent == Players then
		if insufficient then
			sendShop(player, "Update", "Not enough coins.")
		else
			player:SetAttribute("MythbloxDataStatus", "SAVE_ERROR")
			sendShop(player, "Update", "Shop save unconfirmed. Rejoin to refresh your progress.")
		end
	end
	warn("[Mythblox SHOP] Transaction failed for " .. player.Name .. ": " .. tostring(lastError))
end

cosmeticsPrompt.Triggered:Connect(function(player)
	if player.Parent ~= Players or not nearCosmetics(player) then return end
	local now = os.clock()
	if now - (lastShopPrompt[player] or -10) < 0.4 then return end
	lastShopPrompt[player] = now
	sendShop(player, "Open", "")
end)

-- Incremental autosaves avoid excessive requests on every vote/round.
task.spawn(function()
	while true do
		task.wait(150 + math.random(-15, 15))
		for player, profile in pairs(profiles) do
			if player.Parent == Players and profile.status == "ready" then
				task.spawn(saveProfile, player, "autosave")
			end
		end
	end
end)

-- PlayerRemoving and BindToClose cooperate through the per-profile save lock.
game:BindToClose(function()
	local remaining = 0
	for player, profile in pairs(profiles) do
		remaining += 1
		task.spawn(function()
			local deadline = os.clock() + 15
			while profile.status == "loading" and os.clock() < deadline do
				task.wait(0.15)
			end
			saveProfile(player, "shutdown")
			remaining -= 1
		end)
	end
	local deadline = os.clock() + 27
	while remaining > 0 and os.clock() < deadline do task.wait(0.15) end
end)

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
	profiles[player] = {
		key = "Player_" .. tostring(player.UserId),
		baseWins = 0,
		baseCoins = 0,
		pendingWins = 0,
		pendingCoins = 0,
		ownedSkins = {},
		equippedSkin = "classic",
		status = "loading",
		saving = false,
	}
	player:SetAttribute("MythbloxDataStatus", "LOADING")
	task.spawn(loadProfile, player)
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
	equippedSkins[player] = nil
	lastRemoteCommand[player] = nil
	lastShopPrompt[player] = nil
	if active[player] and active[player].alive then
		eliminate(player, "left the server", nil)
	end
	local profile = profiles[player]
	if profile then
		-- Load may still be in flight if the player leaves immediately.
		task.spawn(function()
			local deadline = os.clock() + 15
			while profile.status == "loading" and os.clock() < deadline do
				task.wait(0.15)
			end
			saveProfile(player, "leave")
			if profiles[player] == profile then profiles[player] = nil end
		end)
	end
end)

command.OnServerEvent:Connect(function(player, action, payload)
	if player.Parent ~= Players or typeof(action) ~= "string" then return end
	local cooldown = COMMAND_COOLDOWN[action]
	if not cooldown then return end -- reject unknown remote commands immediately
	local now = os.clock()
	local timestamps = lastRemoteCommand[player]
	if not timestamps then
		timestamps = {}
		lastRemoteCommand[player] = timestamps
	end
	if now - (timestamps[action] or -10) < cooldown then return end
	timestamps[action] = now
	if action == "Sync" then
		stateEvent:FireClient(player, snapshot(player))
	elseif action == "Shop" then
		if typeof(payload) ~= "string" or #payload > 24 or not SKIN_BY_ID[payload] then return end
		if not nearCosmetics(player) then
			sendShop(player, "Update", "Return to the cosmetics stall.")
			return
		end
		task.spawn(transactSkin, player, payload)
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
	keepMovementEnabled(player)
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

-- Collision safety net for normal walking and jumping. The 0.09-second
-- Heartbeat sweep below remains authoritative even when a leap skips a tile
-- without touching it; this catches actual contact independently.
local function validateGlassContact(player, laneNumber, tileIndex, hit)
	if tileIndex == 0 or phase == "JOIN" or phase == "RESULTS" then return end
	local character = player.Character
	if not character or hit:FindFirstAncestorOfClass("Model") ~= character then return end
	local info = active[player]
	if not info or not info.alive or info.lane ~= laneNumber then return end
	if tileIndex <= info.index then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	-- Limbs can brush the edge of the next tile before the avatar actually
	-- steps onto it. Require the root to enter the panel, preventing false
	-- elimination while walking or jumping in place on the current glass.
	if root.Position.Z < tileIndex * SETTINGS.TileSpacing - 2.55 then return end
	local lane = lanes[laneNumber]
	if not lane or not lane.tiles[tileIndex] then return end
	if tileIndex > info.index + 1 then
		eliminate(player, "skipped a tile", lane.tiles[tileIndex])
	elseif phase ~= "MOVE" then
		eliminate(player, "stepped before movement", lane.tiles[tileIndex])
	elseif tileIndex > info.startIndex + info.allowed then
		eliminate(player, "stepped onto forbidden glass", lane.tiles[tileIndex])
	end
end

local function beginMatch(participants)
	initialMatchCount = #participants
	active = {}
	unsafe = {}
	winnerPlayer = nil
	turnNumber = 0
	buildBridges(#participants)
	-- Every lane keeps its chosen neutral cosmetic tint; no entire panel
	-- turns red/green to disclose which exact steps are permitted.
	for lane, player in ipairs(participants) do
		for index = 0, SETTINGS.BridgeLength - 1 do
			lanes[lane].tiles[index].Color = glassColorFor(player)
		end
	end
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
			-- Each lane only tests its assigned racer's body against its
			-- panels; touching a spectator/other lane cannot award progress.
			for index = 1, SETTINGS.BridgeLength do
				local tileIndex = index
				local assignedLane = lane
				local assignedPlayer = player
				local tile = lanes[assignedLane].tiles[tileIndex]
				tile.Touched:Connect(function(hit)
					validateGlassContact(assignedPlayer, assignedLane, tileIndex, hit)
				end)
			end
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
				userId = player.UserId,
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
			keepMovementEnabled(player)
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
			awardProgress(player, awarded[player] and 1 or 0, awarded[player] and 25 or 5)
		end
	end
	-- v0.29: Save match rewards immediately after a round finishes, while
	-- retaining autosave, exit and shutdown fallback attempts.
	-- saveProfile uses stable reward-batch IDs and per-player write locks
	-- so overlapping attempts do not double-award a completed round.
	for _, player in ipairs(participants) do
		if player.Parent == Players then
			task.spawn(saveProfile, player, "round-end")
		end
	end
end

while true do
	phase = "JOIN"
	practiceWithoutRewards = false
	clearBridges()
	queue = {}
	active = {}
	unsafe = {}
	voteCounts = {0, 0, 0, 0, 0}
	voteOutcomes = {}
	message = "Stand anywhere on the front JOIN ZONE until the countdown ends."
	countdown(SETTINGS.JoinSeconds, false)
	-- Evaluate the server's final positions again at the exact cutoff:
	-- entering in the last second counts; leaving before zero disqualifies.
	refreshJoinZoneQueue()
	local participants = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if queue[player] and #participants < SETTINGS.MaxPlayers then
			table.insert(participants, player)
		end
	end
	-- Studio has always supported one-player practice. In published servers
	-- the same bridge can now be played alone without granting farmable Wins
	-- or Coins. Two or more ready players continue the original competitive
	-- mode, vote/tie rules and rewards.
	local soloAllowed = (RunService:IsStudio() and SETTINGS.StudioSoloPractice)
		or (not RunService:IsStudio() and SETTINGS.LiveSoloPractice)
	if #participants < (soloAllowed and 1 or 2) then
		phase = "RESULTS"
		message = #participants == 0
			and "No players in JOIN ZONE at zero. Stand on the front deck!"
			or "Need two ready players. Join next countdown!"
		secondsLeft = 2
		publish()
		task.wait(2)
		continue
	end
	practiceWithoutRewards = #participants == 1 and not RunService:IsStudio()
	if practiceWithoutRewards then
		print("[Mythblox MATCH] Live solo practice starting: no Wins or Coins awarded.")
	end

	beginMatch(participants)
	finishCelebrated = false
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
			if info.alive then keepMovementEnabled(player) end
		end
		countdown(SETTINGS.VoteSeconds, false)

		phase = "REVEAL"
		resolveVotes()
		message = "Unsafe: " .. (function()
			local s = {}
			for i = 1, 5 do if unsafe[i] then table.insert(s, tostring(i)) end end
			return #s > 0 and table.concat(s, ", ") or "none"
		end)() .. ". Watch your glass!"
		countdown(SETTINGS.RevealSeconds, false)

		winners = finishersOrSurvivor()
		if winners then break end

		phase = "MOVE"
		message = "MOVE · USE YOUR OWN GO / NO ADVANCE RESULT"
		for player, info in pairs(active) do
			if info.alive then
				-- Walking/jumping are unrestricted; illegal forward panel advances
				-- remain server-validated even for a blocked pick.
				keepMovementEnabled(player)
			end
		end
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
	if #winners > 0 then finishConfetti() end
	if practiceWithoutRewards then
		message = #winners > 0
			and "PRACTICE COMPLETE! No Wins or Coins. Join again!"
			or "PRACTICE OVER — no rewards. Try again!"
	elseif #winners == 0 then
		message = "DRAW — every bridge fell! Next race soon."
	elseif #winners == 1 then
		message = winners[1].DisplayName .. " WINS! +25 coins"
	else
		message = "TIE! " .. #winners .. " players share the win (+25 each)."
	end
	if not practiceWithoutRewards then
		scoreMatch(winners, participants)
	end
	local winnerDances = startWinnerDances(winners)
	countdown(SETTINGS.ResultsSeconds, false)
	stopWinnerDances(winnerDances)
	for _, player in ipairs(participants) do
		if player.Parent == Players then player:LoadCharacter() end
	end
	task.wait(0.5)
end
