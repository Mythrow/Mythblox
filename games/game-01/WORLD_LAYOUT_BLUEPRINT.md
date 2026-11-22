# Game 01 — Mini-Game Island / Spectator Arena Blueprint

**Status (2026-11-22):** **v0.29** has a single whole-row front auto-join/spectator deck, no side viewing promenades, and continuous visible collidable fencing. Earlier v0.5/v0.11 layout notes remain below for history and must not be treated as current placement instructions. Studio/mobile QA pending.  
**Game title:** Unnamed (Game 01 is only the internal development label).  
**References:** Three Roblox game screenshots supplied by the owner in the conversation (2026-11-21), showing bright social hubs, green island terrain, colorful blocky scenery, decorative paths/fences, shop/leaderboard landmarks, and clear game-viewing areas. **Copy the design vocabulary, not their exact map, asset artwork, logos, or UI.**

## Current built layout supersedes early v0.5 plans — v0.29 (2026-11-22)

**The remainder of this file documents historical planning targets; use this section and the authoritative server source for the current geometry.** Earlier text below referring to a Join button, E prompt, small ready pad, side promenades or open side fence entrances is obsolete.

- The single front deck is **90 × 24 studs**, centered at **(0,24.05,-22)**. The entire row is a server-checked JOIN zone; enter and remain until the countdown reaches zero. No manual JOIN input is offered. It serves as a spectator deck during matches.
- Removed the former left/right **95-stud** viewing walks and all rail/connector structures that extended alongside the race to near the finish.
- Closed the front corners with translucent collidable glass panels matching the center race barrier. West, east and rear edges have additional visible collidable glass inside the invisible safety limits; major masonry rails and posts are solid.
- Both interactive shop kiosks and the main arrival plaza remain at their existing positions. A small independent **Coins/Wins** HUD appears on both desktop and mobile. 1-player published practice is reward-free; 2–8-player matches keep normal rewards.
- Actual Roblox Studio/mobile acceptance tests, particularly full-width joining, exit-before-zero, corner collision and glass-lane containment, remain outstanding.

## 1. One-sentence design goal

Build a **compact, cheerful Roblox mini-game island** with **one dual-purpose Join/Ready + front spectator deck**: the plaza and main path lead to it, shops flank that path, the leaderboard sits near the spawn plaza, and nonparticipants can safely watch each glass-bridge race.

This is **not** a dark/neon arena, an empty floating test baseplate, or a giant open-world lobby. The bridge is still the only playable minigame.

## 2. Player experience

1. Spawn in the **spawn plaza at the beginning of the main path**, near the leaderboard. Players can read standings, meet others, or walk straight toward the bridge-viewing area.
2. Follow the main path between **small shop/cosmetic/rewards placeholders on both sides**. Leave ample open space so walking through the island is easy.
3. Reach a **single wide Join/Ready + Front Spectator platform** at the end of the path. During the 10-second join countdown, this is where players gather and join using the existing on-screen JOIN button (future in-world interaction optional).
4. Once the countdown ends, **only joined players** teleport into the dynamically generated glass lanes.
5. **The same platform is now the front spectator area**: unqueued/late players stand there to watch. No second or separate front deck is constructed. Optional protected side promenades extend from this platform to improve viewing angles.
6. Eliminated contestants respawn safely at the spawn plaza and can walk back along the main path to the shared viewing area while the current match continues.
7. When the round ends, the area returns to **Join/Ready mode** for the next countdown. Its geometry remains in place; only the signs/queue and spectator messaging need to reflect the phase. A player standing on it is never automatically enrolled.
8. First finisher or last survivor wins; the finish animation and landmark should be clearly visible from the shared viewing area.

## 3. Top-down spatial arrangement

View from above: **+Z = forward toward FINISH**, -Z = toward spawn. X is left/right. Not to scale.

```text
                           FAR END (+Z)

                        [ FINISH ARCH ]      z +140
                     +-------------------+
  Left side viewing  | | | | | | | | | |   | Right side viewing
  (optional/guarded) | dynamic glass lanes| (optional/guarded)
      x -49          | over lava (2–8)   |      x +49
                     +-------------------+
                       BRIDGE STARTS         z 0
                [safe barrier / viewing rail]
            +--------------------------------+
            | JOIN / READY + FRONT SPECTATOR |   z -22
            |       SAME SHARED PLATFORM     |
            +--------------+-----------------+
                           |
            [SHOP]         |         [SHOP / COSMETICS]
            [SKINS]        |         [TRAILS / EFFECTS]
              x -24        |              x +24
              z -47        |              z -47
                      MAIN PATH                z -72 to -34
                           |
               +-----------+------------+
               |       SPAWN PLAZA      |   z -74
               +-----------+------------+
                 [REWARDS]   [LEADERBOARD]
                  x -31         x +31
                  z -80         z -80

                           NEAR END (-Z)
```

### Proposed coordinate plan

All playable horizontal surfaces remain near **Y ≈ 24**, compatible with the existing bridge elevation. Positions are Roblox studs and may be fine-tuned when implementing.

| Zone / prop | Center (X, Y, Z) | Footprint / size | Function |
|---|---|---|---|
| Main grassy island | (0, 22, -57) | About 130 × 4 × 86 | Top surface Y=24; persistent shared hub |
| **Spawn plaza / path beginning** | (0, 24.2, -74) | About 22 × 0.4 × 22 | First area the player encounters; safe respawn near existing (0,24,-70) |
| **Main path** | (0, 24.1, -53) | 10 wide, Z from -74 to -34 | Direct, uncluttered walk from spawn to shared platform |
| **Shared Join/Ready + Front Spectator deck** | (0, 24, -22) | **80 × 1 × 24**, Z -34 to -10 | **One permanent structure**; joins/countdown before game, protected viewing during game |
| Join landmark **within shared deck** | (0, 24.6, -25) | Colored floor marking/sign, no separate platform | Shows JOIN/COUNTDOWN in waiting phase; WATCH MATCH in ongoing phase |
| Left spectator promenade (optional) | (-49, 24, +25) | 9 × 1 × 90 | Safe side viewing, connects to shared deck |
| Right spectator promenade (optional) | (+49, 24, +25) | 9 × 1 × 90 | Safe side viewing, connects to shared deck |
| **Shop/cosmetic stall — left of path** | (-24, 24, -47) | About 17 × 16 | Cosmetic shop placeholder, no real purchases |
| **Shop/cosmetic stall — right of path** | (+24, 24, -47) | About 17 × 16 | Future glass skin/trail/effect showcases, no real purchases |
| **Leaderboard beside spawn plaza** | (+31, 24, -80) | About 16 × 12 | Visible near arrival; no invented global standings |
| Future rewards kiosk near spawn | (-31, 24, -80) | About 14 × 12 | Nonfunctional reserved landmark |
| Bridge starts | Z=0, Y=24 | One start tile per contestant | Generated **only after queue closes** |
| Bridge finish | Z=140, Y=24 | Tile 20; width scales with participant count | One prominent shared arch and celebratory floor accents |
| Lava basin | Center near (0, 7, 68) | Existing 105 × 2 × 235 | Still lethal; visual changes only |
| Outer sea/sky | Below hub and around lava | Optional noncolliding light-blue backdrop | Friendly floating island atmosphere |

**Existing protected gameplay geometry:** `BridgeLength = 20`, `TileSpacing = 7`, `LaneSpacing = 9`, `BridgeY = 24`. Lane centers are `X = (lane - (count+1)/2) * 9`; for eight contestants the outermost centers are ±31.5 and each glass tile is 6.7 wide. Side promenades at X≈±49 remain outside race lanes.

**Access and spectator safety:** The shared deck ends at Z=-10 and is separated by a gap and **transparent physical guardrail** from the start tiles near Z=0. Keep the deck **walkable in all phases**. A queued player is teleported to a game lane by the match controller; an unqueued player can remain on the shared deck and watch. Side promenades require safe bridges/connections from the deck, inward barriers, and fall-resistant outer rails. The proposed coordinate plan alone does not prevent jumping into the arena: test it in Studio with at least one unqueued spectator, and use server-side boundary enforcement if the guardrails are insufficient. Never put barriers or shop displays in the middle of the main path.

## 4. Individual areas

### A. Spawn plaza and the main path

- **Start the main path at the spawn plaza**; it is not a separate destination beyond the path. The central walk should lead directly to the combined Join/Ready + spectator platform.
- Put the **leaderboard alongside the spawn plaza** so players see it when they arrive, rather than halfway down the path.
- Bright lawn, light beige paving, decorative trees/bushes and a small welcome sign; **GLASS BRIDGE RACE** is descriptive signage, not a permanent experience title.
- Keep a path at least about 10 studs wide and clear of stands, large props and sales pop-ups. The left and right shop areas branch off the sides.
- Keep the safe respawn location and unobstructed route back to watching the match. Do not spawn on spectator catwalks or near lava.

### B. One shared Join/Ready + Front Spectator platform

- **One physical platform serves both roles**. Do not build separate 'Join' and 'front spectator' decks.
- **JOIN phase:** show a bright Join Round pad/area, countdown and count of ready players. Retain the existing server-validated Join RemoteEvent and JOIN button; a physical prompt can reuse that behavior later.
- **VOTE/REVEAL/MOVE phase:** switch the platform's messaging to **WATCH MATCH** / **MATCH IN PROGRESS** and optional live standings. It remains accessible to spectators; no duplicate waiting deck is added.
- **RESULTS phase:** display winner/results briefly, then return to Join mode when the next countdown starts.
- An unqueued or late player remains free to walk here and watch. Standing here must **not** automatically register them for the game. Joined players are teleported to their individual glass lanes when the join countdown ends.
- The forward edge has a transparent guardrail and direct view of the glass lanes. There must be no easy spectator jump from the platform into a live lane.

### C. Optional protected side viewing promenades

- Promenades connect **from the same shared platform**, giving side-on views of the middle of a race. They are not a second front spectator location.
- Provide collidable safe floors, inward transparent guardrails and outer safety fences; nothing should provide a shortcut or alternate walkable route to bridge tiles.
- Preserve the default Roblox camera for the first implementation. A voluntary camera-switch button may be considered later.
- Spectators see vote results only after reveal, never secret choices before voting closes.
- Test eliminated players walking from spawn along the main path to the shared platform without leaving spectator boundaries.

### D. Shop/cosmetic spaces along the path; leaderboard near spawn

- **Left side of the main path:** compact shop stall / cosmetic glass-skin displays, clearly labeled `COMING SOON`.
- **Right side of the main path:** another storefront for potential trails, effects or other cosmetics; these are **physical placeholders only**, with no invented live purchase menus.
- **Leaderboard near the spawn plaza:** an actual current-server-only Wins/Coins board (up to four players, ranked by wins). It makes no claims of DataStore persistence or global rankings.
- **Rewards placeholder near spawn**, opposite the leaderboard, if the space remains uncluttered.
- Place signs, benches and decorative props off the central path. Keep plenty of room for people walking between spawn and the shared viewing/ready area.

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
    │   ├── SafeSpawn + SpawnPlaza (main-path origin)
    │   ├── MainPath
    │   ├── SharedJoinAndFrontSpectatorDeck
    │   ├── LeftViewingWalkway (optional)
    │   ├── RightViewingWalkway (optional)
    │   ├── LeftPathShopComingSoon
    │   ├── RightPathShopComingSoon
    │   ├── LeaderboardBesideSpawn
    │   ├── RewardsBesideSpawnComingSoon
    │   └── Decoration
    ├── LavaAndEnvironment (persistent)
    └── CurrentMatchBridges (created at match start, removed at end)
        ├── Lane1 ... LaneN
        └── SingleFinishArch
```

**v0.5 implementation:** The server script now creates a persistent `HubIsland` containing the island, safe spawn, path, dual-purpose deck, side promenades, shops/leaderboard/rewards placeholders and decoration. `CurrentMatchBridges` remains dynamic. The match rules and anti-skip checks are preserved. The latest installer must be run in Studio before these additions are visible; engine behavior and exact geometry are unverified.

### Performance / build scope

- Target **roughly ≤180 static decorative Parts** and only one active set of 21 glass tiles per contestant. (8 racers = up to 168 glass tiles.)
- Limit particles to break/crack events. Keep spectator props anchored and decoration collision off unless a fence/ground is meant to block or support the player.
- Create everything through reusable Luau constructors so the Studio one-paste installer remains usable.
- Shop screens and global leaderboards are *placeholders* and not hooked up to Roblox purchases or DataStores in this phase.

## 7. Implementation worklist — initial v0.5 code committed, playtests pending

1. Refactor world creation into persistent `HubIsland` and persistent `LavaAndEnvironment`, keeping `CurrentMatchBridges` dynamic.
2. Build the safe spawn plaza as the **beginning of the main path**; place leaderboard and optional rewards zone beside spawn. Verify respawns and a clear path forward.
3. Build **one shared Join/Ready + Front Spectator deck** at the path's end. Show queue/countdown during JOIN and spectator information during an active match. Test unqueued observation without access to race lanes.
4. Add shop/cosmetic placeholders on **both sides of the main path**, plus optional protected side promenades connected to the shared deck.
5. Create a single proper finish arch spanning `count` lanes and reduce player markers to tiny lane indicators.
6. Finish with a small set of bushes, low-poly trees, benches, rocks, flags and lighting adjustments.
7. Rebuild the Studio Command Bar installer from the exact current server/client sources and run 1-, 2-, 4- and 8-client Studio verification.

No production shop, coins persistence, publishing, or title selection is part of the environment redesign.

## 8. Acceptance criteria for approving the built world

- [ ] New player spawns at the **beginning of the main path**, with a nearby leaderboard; can reach a shop on either side and the combined ready/viewing platform.
- [ ] The round join flow still works, and the bridge count matches actual joined players.
- [ ] **Only one front platform** is present: it works as JOIN/READY during the countdown and as FRONT SPECTATOR during play; late joiners, unqueued players and eliminated players can safely watch from it.
- [ ] Two-client test: a spectator cannot enter a competitor's lane; a participating player cannot shortcut from an outside walkway.
- [ ] At any participant count, exactly one visible finish arch marks tile 20; no big repeated FINISH billboards.
- [ ] No enormous floating player-name tags block gameplay; identity remains understandable from the roster/avatars.
- [ ] Safe/blocked colors, vote numbers, cracks, lava and walk/stay warnings remain legible against the more detailed scene.
- [ ] Spawn plaza flows directly into the main path; the leaderboard is near spawn, and two shop spaces flank the path. The combined ready/viewing platform has enough room for queued and unqueued players.
- [ ] Cosmetic/shop/leaderboard/rewards placeholders are visibly reserved but **not represented as live purchases or global records**.
- [ ] No regressions in spawn, lava elimination, third-crack falling, advancement permissions or match win logic.
- [ ] Mobile/narrow viewport renders enough field-of-view to play; high-detail props do not cause obvious performance degradation.

## 9. Sign-off status

- **Approved by owner:** colorful social hub, **one dual-use Join/Ready + Front Spectator platform**, main path starting at spawn plaza, leaderboard near spawn, shops/features on both sides of the path, optional side viewing promenades, clearer finish and smaller player-name tags.
- **Blueprint proposal for implementation:** coordinates, specific zones, materials and acceptance checks above.
- **Implemented in GitHub v0.5:** initial world redesign, prompt, spectator checks, arch, lane markers and synced installer.
- **Not completed yet:** in-Studio visual review, actual spectator isolation testing and gameplay regression checks.
