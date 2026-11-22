# Azure Coast Resort — Game 01 art direction (v0.21)

**Status:** Azure Coast Resort is an approved **environment theme, not the final public title**. v0.20 was visually tested by the owner, who identified non-solid nature/lights, benches that couldn't be sat on, and incomplete unstaffed kiosks. **v0.21 adds real props, functional two-player benches and staffed storefronts; owner/friend Studio QA pending.**

## Creative direction

A sunlit, elevated **coastal resort island** above an ocean and a dangerous glass course. Refined stylized Roblox materials, softened architecture, resort furniture, shade, natural greenery and warm metal details. Bright, polished and readable rather than dark neon, rainbow toy colors or photorealistic mismatched textures.

**Theme rule:** Reuse these colors across **world, signage, lobby props, shops, fences, finish gate and HUD**; do not introduce arbitrary purple, electric blue or saturated pink into the architecture. The player's **purchased glass skins** remain personal colors, and voting **green SAFE / red BLOCKED** remain functional indicators in result cards, not bridge-tile spoilers. Lava stays orange as an obvious hazard.

## Locked visual palette

| Role | Color | RGB / Hex | Primary application |
|---|---|---|---|
| Main light | Ivory | 243, 235, 216 · `#F3EBD8` | Plaza, UI backgrounds, sign type |
| Architecture | Limestone | 221, 209, 182 · `#DDD1B6` | Fountain, borders, planters, pavilion columns |
| Soft masonry | Sandstone | 193, 177, 146 · `#C1B192` | Island soil, path transitions |
| Primary accent | Ocean teal | 33, 116, 125 · `#21747D` | Shop roofs, select controls, ocean accents |
| Dark neutral | Deep teal | 20, 65, 79 · `#14414F` | Metal fences, posts, signboards, text |
| Metal detail | Champagne brass | 198, 160, 92 · `#C6A05C` | Inlays, architectural trim, lanterns, winner details |
| Nature | Evergreen | 66, 130, 98 · `#428262` | Trees, planters and island vegetation |
| Glass/sky | Seafoam | 199, 235, 232 · `#C7EBE8` | Water highlights, lantern glass, fountain |
| Secondary accent | Soft coral | 207, 129, 109 · `#CF816D` | Cosmetics stall roof and limited decorative highlights |
| Foundation | Coastal stone | 123, 134, 139 · `#7B868B` | Rock faces, distant cliffs, foundation |

**Color exceptions:** The four existing purchasable glass tints, SAFE/BLOCKED green/red results, hazard orange/lava and finish checkerboard are functional features and are not recolored simply to match the lobby.

## Material and texture system

Use built-in Roblox material textures before adding imported art:

- **Limestone / Marble / Pavement:** polished walkable plaza, fountain, shop floors, paths, gallery and spectator deck.
- **Metal:** matte deep-teal structural posts, teal storefront roofs and satin brass details.
- **Glass:** neutral purchasable bridge glass, fountain pool, lightweight accent lanterns and guard panels. Do **not** paint safe/unsafe bridge panels red or green.
- **Rock / Ground / Grass / LeafyGrass:** island mass, weathered cliffs, tree canopy, hedges and distant vegetation.
- **Wood / WoodPlanks:** restrained warm teak for benches and structural detail.
- **Basalt / CrackedLava:** course hazard only, not general lobby materials.

The first version is constructed in Luau from Roblox primitives with textured built-in materials. It does **not** include imported custom PBR SurfaceAppearance maps, bespoke mesh models, premium external texture packs or authored clouds/skybox image assets. Those are possible later art-production stages if approved and licensed.

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
