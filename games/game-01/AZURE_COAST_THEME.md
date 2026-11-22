# Soft Earth Coast — Game 01 art direction (v0.22)

**Status:** The owner superseded the v0.20 vivid Azure Coast Resort palette after seeing overly bright floors and a mobile top bar that covered too much of the screen. **v0.22 Soft Earth Coast** retains the coastal social-lobby concept and v0.21 physical props but adopts a cute muted earthy style with matte lighting and a much smaller mobile HUD. **Soft Earth Coast is an art direction, not the unnamed game's final title.** Real phone and multiplayer QA pending. This file retains its older filename to keep existing GitHub links working.

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
- Environmental **BloomEffect is disabled**; warm light brightness is ~1.85, specular response lowered, color correction gently desaturated, glass/metal/roof/ocean reflection minimized, cloud color softened and lamps dimmed. Preserve daylight and readable glass silhouettes without mobile glare.
- Do not add additional floating HUD blocks or neon highlights to 'improve' quality. Favor actual textured surfaces, coherent materials, delicate furnishings and space for the player to see the world.

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
| Side promenade | `x=±49, z≈-25..70` | Preserved spectator viewing walks |

**v0.21 physical interaction rule:** Players must encounter tangible tree trunks/low canopies, planter bodies and foliage, lamp bases/posts, pergola columns/roofs, fountain/trophy structure and storefront walls/counters. Do **not** apply collision to tiny gold strips, decorative elevated lanterns, non-walkable ocean/islands or other objects that would impede the race. Each bench uses **two real Roblox Seats** with Sit prompts, and shops use solid counters with customer access from the front.

## Sky, water and safety

- Native Roblox **Clouds** under `Workspace.Terrain` with soft daylight cover. Atmosphere, bloom, color correction and sun rays reinforce the same ocean/ivory palette.
- Decorative ocean and distant cliff islets are **noncollidable**; there is no playable sea floor.
- Edit-mode installer and runtime both delete **only** the stock large, low-altitude part explicitly named `Baseplate`, when present. Existing user-authored custom scenery is not blanket-deleted.
- A tall, invisible safety perimeter covers the back and outer side of the enlarged hub, with openings for both original side promenades. It never sets a player's speed or disables jumping.
- An invisible fall reset and independent server root-height check cause players who fall below the island/bridge to die/respawn rather than wander underneath the map.
- Active glass-race advancement, spectator separation, server validation and 2–8-player rules remain authoritative.

## Quality bar and next checks

- [ ] Screenshots from front and side: coherent stone/teal/brass/evergreen color family, rich enough but not cluttered.
- [ ] Spawn has good sightline toward JOIN. Cosmetics E prompt, SHOP placeholder and session leaderboard remain easy to find and operate.
- [ ] No visible stock baseplate, floating stock spawn, walkable water, under-map routes or unwanted default terrain.
- [ ] Dynamic clouds visible on supported graphics settings; horizon has distant islands and ocean depth.
- [ ] No invisible wall blocks the left/right spectator connections.
- [ ] Collision is present on meaningful props (trees, lamp poles, planters, kiosks, roofs), without blocking intended footpaths. Both players can sit on a bench, and each shopkeeper appears behind a front counter.
- [ ] Movement/jumping and **v0.19's forbidden-tile shatter/elimination fix** still work.
- [ ] Cosmetics ownership/Wins/Coins unchanged; private-server and mobile tests still pending.
- [ ] 2–8 client performance acceptable and no excessive lighting/postprocessing glare.
- [ ] Owner approves quality of the actual Studio screenshot **before** considering this art stage complete.

**Release status:** Not ready to launch. The owner explicitly requires an expanded approved feature set and further premium custom-art work after the reliability foundation.
