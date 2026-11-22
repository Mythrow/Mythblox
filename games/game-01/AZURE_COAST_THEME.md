# Soft Earth Coast — Game 01 art direction (palette v0.22; daylight v0.24; matte sky/world v0.25)

**Status:** **v0.31** retains Soft Earth Coast matte stone, natural light, cloud cover, mobile UI and whole-row auto-JOIN, while cleaning visual construction. The REWARDS board is mounted straight into the grass, lamps have clear placement, side/rear/front-end island fencing uses open wood rails and stone posts backed by invisible jump barriers (not reflective glass), the central spectator window stays glass, and edge inlays/shop window joints are simplified. Real Studio/mobile QA pending.

## v0.31 fine-construction rules

- Build furniture and signage from **grounded supports**, not large unrelated metal blocks; REWARDS uses timber posts directly on the ground.
- The hub perimeter and front **ends** use open two-level wood rails plus matte stone uprights, **not full-height glass sheets**. A 22-stud-high invisible physical wall just outside these rails prevents jumping out. Central front spectator glass is intentional and retained.
- No duplicated coplanar strips around plaza and join deck. Keep simple embedded matte inlays that do not run below adjoining slabs. Do not paint very bright bands or neon accents on large floor surfaces.
- Align wood kiosk back walls from floor to roof, stone side walls to upper windows, and roof cornice only on front (avoid multiple competing roof-corner parts).
- Leave the 90×24 whole-row zone, join detection, gameplay, mobile HUD, saved profiles and cosmetics unchanged. Verify all four close-up screenshot viewpoints with actual Roblox rendering.

## Creative direction

A cozy sunlit **coastal garden resort** above a calm ocean and a dangerous glass course. Friendly, cute earthy Roblox materials: warm oat stone, cream, sandy paths, soft sage foliage, terracotta, dusty rose, muted wood and soft brown. Matte, textured and pleasantly bright—not glossy white, harsh teal, neon or overly saturated. Keep existing social-lobby geometry and believable seating, trees, shops and staff.

**Theme rule:** Reuse muted earth tones across **world, signage, paths, shop roofs, seating, fences, finish gate and HUD**. No glaring white floors, vivid blue-teal dominance, shiny metallic gold, neon yellow/green or electric purple architecture. **Exceptions:** player-purchased glass colors, green SAFE/red BLOCKED number-result cards (only during REVEAL), orange lava and finish checkerboard are functional and stay distinguishable.

## Locked v0.22 soft earthy palette

| Role | Color | RGB / Hex | Primary application |
|---|---|---|---|
| Warm cream | Cream | 239, 230, 214 · `#EFE6D6` | Cards, soft signage, restrained accents |
| Main floor | Oat beige | 217, 200, 174 · `#D9C8AE` | **Matte textured spawn plaza**, shop floors, walls |
| Walkways | Soft sand | 201, 179, 148 · `#C9B394` | **Pavement/Sandstone paths** and masonry |
| Main soft accent | Sage | 168, 179, 157 · `#A8B39D` | SHOP roof, gentle foliage details |
| Warm accent | Terracotta | 185, 137, 115 · `#B98973` | Selection highlights and warm touches |
| Cute accent | Dusty rose | 199, 159, 154 · `#C79F9A` | Cosmetics stall roof, small trim |
| Furniture and trim | Light wood | 181, 142, 108 · `#B58E6C` | Benches, wooden frames and matte trim |
| Legible dark | Soft brown | 110, 90, 75 · `#6E5A4B` | Titles, shop signboards, dark posts |
| Vegetation | Gentle evergreen | 128, 151, 123 | Trees, planters and landscaping |
| Ocean | Muted coastal gray-green | 123, 157, 153 | Calm non-walkable sea |
| Foundation | Soft gray stone | 153, 149, 137 | Island base and distant cliffs |

**Functional exceptions:** four existing glass shop colors, SAFE/BLOCKED green/red reveal cards, orange hazard and finish checkers; none is a signal to paint the next bridge tile green/red.

## Material and texture system

Use built-in Roblox material textures before adding imported art:

- **Sandstone / Limestone / Pavement:** gently textured **oat-beige plaza**, sandy paths, fountain, shop floors and social deck—never glossy white marble.
- **SmoothPlastic / Metal:** low-reflectance sage/dusty-rose shop roofs, soft brown posts and tan architectural accents instead of vivid teal/gold.
- **Glass:** neutral purchasable bridge glass, fountain pool, lightweight accent lanterns and guard panels. Do **not** paint safe/unsafe bridge panels red or green.
- **Rock / Ground / Grass / LeafyGrass:** island mass, weathered cliffs, tree canopy, hedges and distant vegetation.
- **Wood / WoodPlanks:** restrained warm teak for benches and structural detail.
- **Basalt / CrackedLava:** course hazard only, not general lobby materials.

The first version is constructed in Luau from Roblox primitives with textured built-in materials. It does **not** include imported custom PBR SurfaceAppearance maps, bespoke mesh models, premium external texture packs or authored clouds/skybox image assets. Those are possible later art-production stages if approved and licensed.

## Mobile UI and lighting rules

- Phone top status is **49px** in both portrait (width < 760px) and short landscape (height < 540px), excluding the native Roblox safe-area inset. Two rows show phase/countdown and brief personal guidance plus Wins/Coins; long details and progress bar remain desktop-only.
- Five REVEAL result cards retain avatars, counts and red/green SAFE/BLOCKED indicators for the **full five-second reveal**. The mobile tray is roughly **156–172px tall** rather than a 228px desktop-height card. Private 1–5 vote buttons remain large and tappable.
- Environmental **BloomEffect is disabled** and specular response remains low. **v0.24 uses neutral daylight brightness 1.75** with balanced gray ambient/outdoor light, no yellow sun color shift, white color-correction tint, near-neutral saturation and gently clearer blue-gray coastal atmosphere. Materials remain matte and the game avoids phone glare. Do not reintroduce beige post-processing to simulate an earthy palette.
- Do not add additional floating HUD blocks or neon highlights to 'improve' quality. Favor actual textured surfaces, coherent materials, delicate furnishings and space for the player to see the world.

## v0.24 neutral-daylight lighting parameters

The following are set by the authoritative **server** script at runtime; these do not recolor the world assets.

| Setting | v0.24 value | Why |
|---|---|---|
| Global light | Brightness 1.75; ClockTime 13.1 | Natural daylight, slightly lower glare |
| Ambient / OutdoorAmbient | (158,161,163) / (188,194,196) | Neutral illumination instead of yellow |
| ColorShift_Top / Bottom | (0,0,0) / (0,0,0) | No warm sunlight tint |
| Color correction | Tint (255,255,255), Saturation -0.035, Contrast +0.015 | Remove all-scene beige cast without vivid/neon saturation |
| Atmosphere | Density 0.20, Haze 0.38; Color (215,228,234) | More natural blue-gray coastal haze and visible colors |
| Clouds | (238,242,242) | Soft, neutral-white clouds |
| Reflections / bloom | EnvironmentSpecularScale 0.20; bloom disabled | Preserve soft matte feel |

**Verification:** Still pending on actual Roblox Studio rendering and mobile devices. Preserve this palette while further refining the look, and never globally yellow-tint the scene to make individual materials appear warm.

## v0.27 grounded detail and clearer mobile view

- Keep join and rewards signboards attached to physical timber supports; avoid hovering plaques in the path's sightlines.
- Bench legs, ceramic planter bases, lamp pedestals and pergola columns must reach the hub grass or stone without a floating air gap. Pergola lanterns need visible roof suspension stems.
- Keep water inside the fountain basin and the crystal pedestal visibly seated on it; seat the trophy pedestal on its ground surface.
- Mobile status uses **43px** (down from 49px), max **270px** width, right-aligned inside the Roblox safe inset to keep the central view open. Do not push content into the native Roblox buttons or hide vote/reveal controls.
- Validate the revised heights and HUD from normal player camera height on both PC and phone. Supporting signposts are noncolliding so free walking/jumping never become restricted.

## v0.25 clouds and non-glare stone surfaces

Large bright horizontal surfaces should be weathered oat or soft neutral stone, **not** near-white ivory. Keep cream for small, intentional signage/detail only. The brighter source palette values remain available for small features, not as an excuse to lighten entire paths or platforms.

| World role | Color | Material | Intended effect |
|---|---|---|---|
| Main spawn plaza | Weathered oat `#B8AD9A` | Concrete | Large matte textured plaza rather than light sandstone glare |
| Join/spectator deck and side walks | Shaded oat stone `#B0A796` | Concrete | Reduce large bright slabs along the glass course |
| Narrow shop/social paths | Sandy stone `#BFB29E` | Pavement | Legible path navigation with muted color |
| Planters, masonry, kiosk counter, fountain stone | Neutral weathered stone `#AFAB9D` | Concrete | Eliminate ivory-white blocks and avoid glossy highlights |
| Sky | Native cloud Cover **0.72**, Density **0.54** | Terrain.Clouds | Fuller soft-neutral cloud field, without stacking fake sky objects |

The main Lobby SpawnLocation is now **completely transparent**, not a visible light rectangle on the center plaza. Its world location/collision/spawning logic is preserved. This material pass does not change the original world layout, bridge tiles, physical seats, shop functionality, player movement, or coin persistence.

**Visual acceptance:** Compare a Studio screenshot from the former spawn camera angle; the sky should contain substantially more natural clouds, large paving surfaces should no longer appear glaring white/neon, and the organic/wood/sage/terracotta palette should still be recognizably Soft Earth Coast. Verify on a phone too; native Clouds rendering can vary with device graphics settings.

## World zoning (coordinates, in studs)

The island's enlarged grass top is **186 × 124** studs, centered at `(0, 22, -71)`, expanding the historical 130 × 91 island. The active bridge and original lobby-to-bridge flow are intentionally preserved.

| Area | Center | Purpose |
|---|---|---|
| Arrival plaza | `(0, 24, -83)` | 56 × 39-stud stone courtyard, original spawn near `z=-76` |
| Fountain terrace | `(0, 25, -118)` | Sea-glass fountain and approach from rear of arrival plaza |
| West social lounge | `(-68, 24, -71)` | Teal-roof pergola, benches, lantern and coastal path |
| East social lounge | `(68, 24, -71)` | Mirrored pergola, benches, lantern and coastal path |
| Photo arch | `(70, 30, -110)` | Visual landmark, photo spot |
| Trophy courtyard | `(-67, 28, -110)` | Visual sculpture, not a new progression mechanic |
| Existing SHOP placeholder | `(-25, 24, -49)` | Same role and location, recolored in theme |
| Existing COSMETICS shop | `(25, 24, -49)` | **Functional** existing earned-coin shop, unchanged access and prices |
| JOIN/spectator deck | `(0, 24, -22)` | Preserved shared platform with unchanged join interaction |
| Side promenades | Removed in v0.29 | No spectator runways parallel to the race |

**v0.21 physical interaction rule:** Players must encounter tangible tree trunks/low canopies, planter bodies and foliage, lamp bases/posts, pergola columns/roofs, fountain/trophy structure and storefront walls/counters. Do **not** apply collision to tiny gold strips, decorative elevated lanterns, non-walkable ocean/islands or other objects that would impede the race. Each bench uses **two real Roblox Seats** with Sit prompts, and shops use solid counters with customer access from the front.

## Sky, water and safety

- Native Roblox **Clouds** under `Workspace.Terrain` now use fuller soft neutral-white cloud cover (0.72 Cover / 0.54 Density); only one Clouds instance is used. Atmosphere favors a pale blue-gray horizon (not beige); color correction is neutral white; bloom remains disabled and sun rays stay restrained. Earth colors are properties of materials and assets, not a full-screen filter.
- Decorative ocean and distant cliff islets are **noncollidable**; there is no playable sea floor.
- Edit-mode installer and runtime both delete **only** the stock large, low-altitude part explicitly named `Baseplate`, when present. Existing user-authored custom scenery is not blanket-deleted.
- A continuous visible solid-glass perimeter fence encloses the back, west/east and front edges; tall invisible safety limits are tucked behind the visible fence. There are no openings for former side promenades. Neither speed nor jumping is disabled.
- An invisible fall reset and independent server root-height check cause players who fall below the island/bridge to die/respawn rather than wander underneath the map.
- Active glass-race advancement, spectator separation, server validation and 2–8-player rules remain authoritative.

## Quality bar and next checks

- [ ] Front and side screenshots: oat/sand/sage/terracotta/rose/wood materials remain coherent, foliage is green, cloud coverage is visibly fuller, the sky is natural blue-gray and neither a global yellow wash nor giant near-white stone slabs/glowing planters dominate the frame.
- [ ] Spawn has good sightline toward JOIN. Cosmetics E prompt, SHOP placeholder and session leaderboard remain easy to find and operate.
- [ ] No visible stock baseplate, floating stock spawn, walkable water, under-map routes or unwanted default terrain.
- [ ] Dynamic clouds visible on supported graphics settings; horizon has distant islands and ocean depth.
- [ ] No former left/right spectator walkway remains; all island fence corners physically and visually connect.
- [ ] Collision is present on meaningful props (trees, lamp poles, planters, kiosks, roofs), without blocking intended footpaths. Both players can sit on a bench, and each shopkeeper appears behind a front counter.
- [ ] Movement/jumping and **v0.19's forbidden-tile shatter/elimination fix** still work.
- [ ] Cosmetics ownership/Wins/Coins unchanged; private-server and mobile tests still pending.
- [ ] 2–8 client performance acceptable and no excessive lighting/postprocessing glare.
- [ ] Owner approves quality of the actual Studio screenshot **before** considering this art stage complete.

**Release status:** Not ready to launch. The owner explicitly requires an expanded approved feature set and further premium custom-art work after the reliability foundation.
