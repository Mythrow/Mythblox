# Game 01 — Mini-Game Island / Spectator Arena Blueprint

**Status:** World-layout design, **not yet implemented**. User approved the *design direction* on 2026-11-21; dimensions and decorative details below are proposed implementation coordinates for review.  
**Game title:** Unnamed (Game 01 is only the internal development label).  
**References:** Three Roblox game screenshots supplied by the owner in the conversation (2026-11-21), showing bright social hubs, green island terrain, colorful blocky scenery, decorative paths/fences, shop/leaderboard landmarks, and clear game-viewing areas. **Copy the design vocabulary, not their exact map, asset artwork, logos, or UI.**

## 1. One-sentence design goal

Build a **compact, cheerful Roblox mini-game island** where everyone can move freely between rounds, nonparticipants can safely **watch every active glass-bridge race**, and the world already has tidy places reserved for future cosmetics, shops, and leaderboard content.

This is **not** a dark/neon arena, an empty floating test baseplate, or a giant open-world lobby. The bridge is still the only playable minigame.

## 2. Player experience

1. Spawn on a bright grassy hub island, with paths and a central welcome sign.
2. See the **Join Next Round** pad and remaining countdown prominently. The current on-screen JOIN button remains available; a future in-world ProximityPrompt may offer an alternate join input.
3. Walk through the lobby to the spectator deck, leaderboard area, or cosmetic storefront placeholders. No purchases are functional in this phase.
4. After 10 seconds, only joined players teleport onto one glass lane each. The existing game rules remain unchanged.
5. Everyone else stays in the hub and can **physically walk to the front viewing deck or either side viewing promenade**, looking directly at votes, movement, cracks, falling avatars, and the finish.
6. Eliminated players respawn in the safe hub and may watch the ongoing round. The next round allows everyone to rejoin.
7. First finisher or last survivor wins; winner celebration should be visible to spectators.

## 3. Top-down spatial arrangement

View from above: **+Z = forward toward FINISH**, -Z = toward lobby spawn. X is left/right. Not to scale.

```text
                              FAR END (+Z)

                    +------------------------+
                    |    FINISH ARCH         | z = +140
                    +------------------------+
   left viewing     |  |  |  |  |  |  |  |  |   right viewing
   promenade        |  dynamic parallel      promenade
   (safe spectators)|  glass lanes over lava |(safe spectators)
   x ~ -49          |  2–8 players           x ~ +49
   z -20 to +70     |  z = 0 to +140         z -20 to +70
          [safe rail]  (no spectator entry) [safe rail]

                FRONT WATCHING DECK       z ~ -20
          =======================================
                  JOIN / READY PAD        z ~ -40

      COSMETIC STALL     MAIN PATH     LEADERBOARD BOARD
         x -42            x 0            x +42
         z -57            z -55          z -57

                   SPAWN PLAZA            z ~ -74
                                         REWARDS CORNER
                                            x +42
                                           z -83
                HUB ISLAND / FENCES / TREES

                              NEAR END (-Z)
```

### Proposed coordinate plan

All surfaces below should be compatible with the **existing bridge height, Y ≈ 24**. Sizes are Roblox studs; these are layout targets, not requirements for exact game balance.

| Zone / prop | Center (X, Y, Z) | Footprint / size | Function |
|---|---|---|---|
| Main grassy island | (0, 22, -57) | 130 × 4 × 86 | Top surface Y=24; safe lobby |
| Spawn plaza | (0, 24.2, -74) | About 22 × 0.4 × 22 | Bright paved start area; existing spawn stays near (0,24,-70) |
| Main path | (0, 24.1, -50) | 10 wide, running -75 to -20 | Direct spawn-to-watch route |
| Join pad | (0, 24.4, -40) | 16 × 0.5 × 10 | Visible join landmark and countdown |
| Front watch deck | (0, 24, -20) | 80 × 1 × 20 | Near bridge starts, with transparent protective front rail at Z=-10 |
| Left spectator promenade | (-49, 24, +25) | 9 × 1 × 90 | Safe viewing above lava, Z=-20 to +70 |
| Right spectator promenade | (+49, 24, +25) | 9 × 1 × 90 | Same from opposite side |
| Future cosmetics stall | (-42, 24, -57) | Approx. 22 × 16 | Noninteractive facade and sample display pedestals |
| Wins leaderboard area | (+42, 24, -57) | Approx. 18 × 16 | Clearly labeled leaderboard space, no invented persistent ranks |
| Future rewards kiosk | (+42, 24, -83) | Approx. 16 × 12 | Placeholder, labeled COMING SOON |
| Bridge starts | Z=0, Y=24 | 1 start tile per contestant | Built **after join closes** |
| Bridge finish | Z=140, Y=24 | 20th tile; width scales with joined count | One colorful shared finish arch and celebratory floor accents |
| Lava basin | centered near (0, 7, 68) | Existing 105 × 2 × 235 | Still lethal; visual improvements only |
| Outer sea/sky | Below hub and around lava | Noncolliding light-blue plane, if used | Bright floating-island look |

**Existing protected gameplay geometry:** `BridgeLength = 20`, `TileSpacing = 7`, `LaneSpacing = 9`, `BridgeY = 24`. Match lanes are centered at `X = (lane - (count+1)/2) * 9`; at 8 participants their outermost centers are ±31.5 and each tile is 6.7 wide. The viewing promenades at ±49 thus remain **outside** the glass lanes.

**No accidental bridge access:** Front deck stops at Z=-10; the first start panel begins near Z=-3.35. Transparent collision railing and the gap separate the spectator deck from the race; side promenades require similarly reliable inward railings. Make spectator barrier high enough to prevent jumping/vaulting across into live lanes. Do **not** rely only on appearances: validate with two players and an unqueued spectator, and if necessary implement server-side spectator zone enforcement. Lobby and promenade walkways must have their own safe, collidable ground while decorations and visual rails below the arena do not provide shortcuts.

## 4. Individual areas

### A. Spawn / social plaza

- Bright lawn plus light beige paved circle or square; limited, recognizable Roblox toy-scale terrain.
- Small welcome board: **GLASS BRIDGE RACE** only as descriptive signage, **not** a permanent experience title.
- Center path has enough room for 8 player avatars to pass without knocking each other off.
- Trees, bushes, flowers, pastel rocks, wooden fences and a few benches around the *edges*, not on the path.
- Keep existing safe respawn logic. Never spawn players at the height of the lava or on a spectator walkway over the lava.

### B. Join zone

- Colorful floor pad/sign reading **JOIN ROUND** and current queue / countdown. A clear distinction between "joined" and "spectating".
- Keep existing server-validated `Join` RemoteEvent and on-screen button for v0.5.
- A physical ProximityPrompt can be added later **if** it sends the same server-validated action, never a second, independent joining system.
- Unjoined users aren't teleported to bridges; late joiners wait for the next round.

### C. Spectators — essential, not optional

- **Central deck:** wide, slightly elevated or directly above island surface; open panoramic view from the bridge starts toward the finish.
- **Side promenades:** safe parallel walkways from the island toward the halfway point. Use transparent inner guards, low solid outer fences, and clear sightlines.
- **Camera:** normal Roblox free camera is sufficient for first implementation; later a voluntary "Watch Match" camera button may improve visibility of far-away progress. Never force nonparticipants into a match.
- **Spectator UI:** status text like "MATCH IN PROGRESS", number of live racers, and progress standings. The current vote results remain hidden until reveal; spectators should see the same server-published outcomes when a reveal occurs.
- **Safety:** nonplayers should not be able to stand on glass race tiles, block contestants, or be affected by a participant's glass destruction. Test spectator-to-bridge jumping and walking across guardrails.

### D. Cosmetic/store, leaderboard and rewards placeholders

- **Cosmetic corner (left):** a colorful compact stall or three display pedestals for future glass skins/trails; show `COMING SOON`; nothing purchasable yet.
- **Leaderboard (right):** a clean in-world board large enough for future Wins and Coins; don't fabricate global wins or imply DataStore persistence exists. May show simple descriptive text until the backend is added.
- **Rewards corner:** optional small nonfunctional gift kiosk/podium, no false "claim" action.
- Preserve walking space around all landmarks; avoid oversized floating menu labels covering the center of the screen.

### E. Bridge arena

- Existing dynamic lane generation stays exactly **one lane per participating player**, not eight empty bridges.
- Manual move 1–N tiles, green/red permissions, cracks, fall, survivor and first-finish logic all unchanged.
- Bridges should be visible from all viewing decks. Keep material light-blue glass and the readable crack markings.
- No new game mechanics, camera lockdown, auto-movement, teleports, paid advantages, etc.

### F. Finish landmark

Replace the minimalist shared banner with **one proper finish arch**:

- Two big, bright colored posts or blocky towers framing the dynamic lane width; one crossbeam labeled **FINISH**.
- Yellow/white checkerboard detailing on the beam or final panels; a few flag pennants or celebratory block accents.
- Decorative winner podium behind or beside the arch, **not** extending the walkable finish target past tile 20.
- One sign total, scaled to match lane count; readable from spectator decks. Keep its visual parts noncolliding where they might interrupt player movement.
- On victory, optional small confetti particles; no purchased effect needed yet.

### G. Player tags

- Remove the existing billboard created above each lane's start tile (currently **175×55 screen pixels**, plus a 5-stud offset). These tags are too large and crowd the view.
- Prefer **small lane numbers printed on the start tile surface** (e.g., `1`, `2`), or a short in-world start-side plaque, with no big persistent floating nameboards.
- Roblox avatar name display + the existing UI standings are sufficient for player identity during the first redesign. Avoid duplicated, oversized names.

## 5. Visual direction

Emulate the *general bright, friendly Roblox mini-game aesthetic* from the user's screenshots:

| Element | Palette / material direction |
|---|---|
| Daylight / sky | Blue sky with soft clouds, high visibility |
| Grass / island | Lush medium-bright green (#70CD5C) |
| Walk paths | Pale sand / cream (#F3E5B5) |
| Fences / shop | Warm wood brown (#AE7C4B) |
| Bridges | Clear pastel cyan glass (#A8E7F6) |
| Safe / blocked tiles | Saturated readable green / red |
| Lava | Bright orange-red, clearly distinct from island |
| Join / navigation signs | Bright blue, yellow accent, clean bold text |
| UI | White/light cards, clear contrast, concise labels; no giant walls of text |

Use primarily primitive Parts and simple low-poly props. No need for large meshes, expensive textures, elaborate skyscrapers, large permanent stores, or copied assets from the reference games.

## 6. Model architecture for the implementation

Keep static social content independent of dynamic round content:

```text
Workspace
└── MythbloxGame01
    ├── HubIsland (persistent)
    │   ├── SafeSpawn
    │   ├── SpawnPlaza + Paths
    │   ├── JoinZone
    │   ├── SpectatorDeck
    │   ├── LeftViewingWalkway
    │   ├── RightViewingWalkway
    │   ├── ShopsComingSoon
    │   ├── LeaderboardArea
    │   ├── RewardsComingSoon
    │   └── Decoration
    ├── LavaAndEnvironment (persistent)
    └── CurrentMatchBridges (created at match start, removed at end)
        ├── Lane1 ... LaneN
        └── SingleFinishArch
```

**Important:** Current v0.4 world source builds a small fenced spawn platform and a decorative grass floor, then generates dynamic bridges. The environment redesign must replace or rearrange those **static** objects, not change the dynamic voting, cracks, finish, death, respawn or anti-skip validation. Keep `player.RespawnLocation` pointing to the safe lobby spawn. Glass and arch generation occurs only after the queue closes and removes content between matches.

### Performance / build scope

- Target **roughly ≤180 static decorative Parts** and only one active set of 21 glass tiles per contestant. (8 racers = up to 168 glass tiles.)
- Limit particles to break/crack events. Keep spectator props anchored and decoration collision off unless a fence/ground is meant to block or support the player.
- Create everything through reusable Luau constructors so the Studio one-paste installer remains usable.
- Shop screens and global leaderboards are *placeholders* and not hooked up to Roblox purchases or DataStores in this phase.

## 7. Recommended implementation sequence — **not yet authorized code changes**

1. Refactor world creation into persistent `HubIsland` and persistent `LavaAndEnvironment`, keeping `CurrentMatchBridges` dynamic.
2. Build grass island, safe spawn plaza and natural paths; verify all respawns.
3. Create front viewing deck and protected left/right viewing promenades; test nonparticipants observing a match without entering race lanes.
4. Add the JOIN area plus clearly marked (nonfunctional) store, leaderboard, and rewards spaces.
5. Create a single proper finish arch spanning `count` lanes and reduce player markers to tiny lane indicators.
6. Finish with a small set of bushes, low-poly trees, benches, rocks, flags and lighting adjustments.
7. Rebuild the Studio Command Bar installer from the exact current server/client sources and run 1-, 2-, 4- and 8-client Studio verification.

No production shop, coins persistence, publishing, or title selection is part of the environment redesign.

## 8. Acceptance criteria for approving the built world

- [ ] New player spawns safely in an attractive, free-roam island and can walk to at least three marked landmark areas.
- [ ] The round join flow still works, and the bridge count matches actual joined players.
- [ ] Late joiners and unqueued players can watch glass destruction and player motion from a protected spectator platform.
- [ ] Two-client test: a spectator cannot enter a competitor's lane; a participating player cannot shortcut from an outside walkway.
- [ ] At any participant count, exactly one visible finish arch marks tile 20; no big repeated FINISH billboards.
- [ ] No enormous floating player-name tags block gameplay; identity remains understandable from the roster/avatars.
- [ ] Safe/blocked colors, vote numbers, cracks, lava and walk/stay warnings remain legible against the more detailed scene.
- [ ] Main plaza and join pad leave room for multiple avatars; no path obstructions or permanent interaction clutter.
- [ ] Cosmetic/shop/leaderboard/rewards placeholders are visibly reserved but **not represented as live purchases or global records**.
- [ ] No regressions in spawn, lava elimination, third-crack falling, advancement permissions or match win logic.
- [ ] Mobile/narrow viewport renders enough field-of-view to play; high-detail props do not cause obvious performance degradation.

## 9. Sign-off status

- **Approved by owner:** general world direction — colorful social hub, spectator access, reserved shop/leaderboard areas, clearer finish, smaller names.
- **Blueprint proposal for implementation:** coordinates, specific zones, materials and acceptance checks above.
- **Not completed yet:** implementation of this world redesign or in-Studio testing.
