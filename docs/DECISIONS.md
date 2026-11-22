# Mythblox — Decision Log

Use this file to separate **confirmed project rules** from **ideas not yet approved**. Append dated entries when a decision is made.

## Confirmed — 2026-11-21

- **Mythblox is an umbrella project.** Individual games receive their own names only after discussion and approval.
- **Game format:** very small, short, simple, replayable, competitive multiplayer experiences; generally one arena and one primary mechanic.
- **AI-led implementation:** AI should write/create nearly everything technical and creative; owner remains responsible for accounts, final approval, real playtests and publishing.
- **Monetization intent:** game-relevant customization and possibly small power-ups.
- **Tooling available:** Roblox Studio and connected GitHub repository `Mythrow/Mythblox`.

## Proposed defaults — not yet locked

- Separate Roblox experience for each game; one monorepo for shared code/docs.
- 2-player minimum for competitive mode; begin around 8 maximum.
- 45–120-second matches; 5–10-second intermission.
- Cosmetic-first monetization; no paid random items, and no pay-to-win.
- Rojo/code-first version-controlled workflow with Studio Assistant; optional local Studio MCP integration.
- **First game concept APPROVED (2026-11-21):** an unnamed parallel glass-bridge voting race over lava. Fixed numbers 1–5, with a safe selection allowing **manual movement up to that many tiles**. The most-popular selected numbers (at least 2 votes) crack; all top-vote ties with 2+ selections are blocked. Three cracks eliminate. Illegal steps and failure to leave an eligible starting tile result in a fall. No spinner in MVP. See [Game 01 source](../games/game-01/README.md) and [concept memo](FIRST_GAME_GLASS_BRIDGE_CONCEPT.md).

## Testing updates

- **2026-11-21:** Owner confirmed **both solo and multiplayer v0.1 gameplay** worked across several tested conditions; detailed individual test cases were not enumerated.
- Owner identified four v0.1 problems: lobby/respawn lava deaths, eight FINISH signs, bridges built before player count finalized, and no visible post-vote results.
- **v0.2 code committed:** safe respawn target and guarded lobby, dynamic per-match lane creation, one shared FINISH banner, and a visible vote tally/individual results panel. **Owner subsequently confirmed v0.2 functionality works in Studio.** See [Game 01 test plan](../games/game-01/TEST_PLAN.md).

- **2026-11-21:** Owner accepted v0.2 as **functionally working**, while specifically deferring **UI improvements** to the later polish phase. This is a functional milestone, not full release QA.

- **2026-11-21:** Owner approved proceeding to the **visual-polish phase**. **v0.3** adds UI redesign, responsive voting/reveal/results, neon arena styling, and glass-crack/shatter effects. No rule changes intended; v0.3 **requires new Studio verification**. See [Game 01 test plan](../games/game-01/TEST_PLAN.md).

- **2026-11-21:** The user rejected the dark/neon v0.3 aesthetic and requested the usual **bright Roblox style**. **v0.4 code** switches to daylight, grass, sky-blue bridges, white UI and blue/green/yellow controls. Core mechanics remain unchanged; **Studio verification pending**. [Game 01](../games/game-01/README.md).

- **2026-11-21:** Owner supplied three reference screenshots showing the desired bright social-hub style. Approved direction: **free-roam island, spectator access during matches, reserved shop/leaderboard/rewards areas, more attractive finish, smaller player labels**. The [Game 01 world-layout blueprint](../games/game-01/WORLD_LAYOUT_BLUEPRINT.md) records this design. **Refinement approved:** JOIN/READY and FRONT SPECTATOR are a **single shared phase-aware platform**; the main path starts at spawn, leaderboard sits near spawn, and shop spaces line both sides of the path. **The layout is planned, not implemented**; the previous v0.4 arena remains the installed build.

- **2026-11-21:** **v0.5 island layout implemented in GitHub** with one phase-aware Join/Ready + spectator deck, spawn-first main path, two shop placeholders, near-spawn leaderboard, side viewing routes, new finish arch, and small lane markers. A shared in-world Join prompt uses existing server validation. **Studio verification pending**; underlying core game rules intentionally unchanged. See [v0.5 test plan](../games/game-01/TEST_PLAN.md).

- **2026-11-21:** Owner provided a v0.5 screenshot and reported **unwanted on-screen leaderboard and join-area/glitching visuals**. v0.6 revision committed: physical double-sided SurfaceGui world signs replace giant BillboardGui labels; spectator deck surfaces are vertically offset to reduce z-fighting; barriers visually shortened; HUD leaderboard removed and top match status compacted. **Requires Studio verification** before calling the issues resolved. Game rules unchanged.

- **2026-11-22:** Owner's v0.6 screenshot shows sign lettering distorted by `TextScaled`, plus an unwanted center-screen results popup. **v0.7 source/installer** switches to fixed-size world-sign fonts with separate small subtitles and removes the modal results card, retaining winner text in the compact top HUD. **Studio test pending; gameplay rules unchanged.**

- **2026-11-22:** Owner reports both sign-text distortion and centered results popup **still persist** after the v0.7 attempt. Inspected v0.7 GitHub code: the center results UI is already absent, so a stale/duplicate running Studio script is possible. **v0.8** adds cleanup of installed/stray older game scripts, exact Source checks, `BuildVersion` replicated marker, `v0.8` in the top HUD, and server/client runtime Output logs. Sign lettering is further reduced. **Studio verification pending**, no gameplay rules changed.

- **2026-11-22:** Owner's screenshot shows the **v0.8 build marker**, confirming script replacement, yet world signs still have flattened/tiny lettering. Root issue traced to Roblox `SurfaceGui.SizingMode` possibly defaulting to `FixedSize` (800×600 canvas) on wide Parts; the previous code only set `PixelsPerStud`, which has no effect in FixedSize mode. **v0.9** explicitly selects `PixelsPerStud` for signs, lane numbers and cracks, and restores sensible text size. **Studio visual acceptance pending.**

- **2026-11-22:** Owner's v0.9 screenshot identified a still-present **stock Baseplate SpawnLocation under lava**. **v0.10** adds narrowly scoped old-spawn removal in the Studio Edit-mode installer and at server startup, while keeping the raised custom lobby spawn. As the next small improvement, the existing near-spawn leaderboard displays **current-server-only Wins and Coins**, sorted by wins, without DataStore persistence. **Studio testing pending**, no game-rule changes.

- **2026-11-22:** User approved four corrections from v0.10 screenshots: cleaner finish gate, flush bridge/spectator glass, a smaller **single-face** leaderboard with only names/wins/coins, and a better-looking island edge from the course. **v0.11 scripts and installer committed**: simple finish posts/beam, precise rail extents, compact scoreboard, layered soil/stone and sea backdrop. **Studio visual verification pending**; voting, match duration and rewards unchanged.

- **2026-11-22:** Owner confirms **v0.11 works** in Roblox Studio. Environment changes are now the functional/visual baseline; further layout redesign deferred unless a specific issue appears. Proposed next development stage: **v0.12 gameplay presentation and feedback**, then permanent wins/coins, cosmetics, and release testing. This proposed sequence is a recommendation, **not yet approval to implement v0.12**.

- **2026-11-22:** Owner approved **v0.12 gameplay-feedback polish** after confirming v0.11 works. Source and installer updated with subtle built-in click/tick/reveal/crack/fall/win sounds, short personal safe/crack feedback, vote urgency, personal vote-row highlighting, small transient glass shards, and confetti for all win paths. No map, match time, voting, crack, movement or reward rule changes intended. **Studio verification pending**; source consistency is not engine testing.

- **2026-11-22:** Owner confirms **v0.12 gameplay polish works** in Roblox Studio, and requests to save progress and resume development tomorrow. The GitHub scripts/installer are committed, but the Roblox Studio place must also be saved separately by the owner. **Next candidate phase:** permanent wins/coins and data persistence; do not start until user resumes.

- **2026-11-22:** Development resumed after the v0.12 checkpoint. **v0.13 persistent Wins/Coins implemented** in the authoritative Game 01 server, using Roblox DataStoreService, guarded GetAsync loads, idempotent UpdateAsync increment saves, 150-second jittered autosaves, exit/shutdown final saves, and failure modes that refuse to overwrite real data with zeros. Studio uses a **separate test data store**. No spending, cosmetics purchase, map or game-rule changes. New [persistence guide](../games/game-01/PERSISTENCE_TEST_GUIDE.md) documents private publication and Studio API Services setup. **Persistence not yet tested in Roblox Studio; do not claim the saves are verified.**

- **2026-11-22:** Owner confirms **v0.13 Coins persist** after restarting Roblox Studio Play, providing a successful in-Studio persistence checkpoint. **Wins persistence and private published-server storage are not yet separately verified.** Studio Output included a `GameSettingsPlugin.SecurityController` 'Failed to parse secrets: Can't parse JSON' warning; the successful coins test suggests it is unrelated to Game 01 DataStore writes. No code change needed based on this warning alone.

- **2026-11-22:** Following owner-confirmed Studio coin persistence in v0.13, implementation proceeded to **v0.14 coin-only cosmetics**. The right-hand Cosmetics stall opens a compact shop with Classic Blue free and three earned-coin glass tints (20/40/60 coins). Ownership and equipped color persist in the existing DataStore, and purchases are validated by the server in one atomic UpdateAsync record. Neutral lane glass reflects skin selection; all safe/unsafe/crack colors and original gameplay rules are unchanged. **Still to test in Studio:** shop UI, purchases, equipment survival after restart; also saved Wins and private published-server persistence remain unverified. No Robux monetization.

- **2026-11-22:** Owner confirms the **v0.14 cosmetics shop works in Roblox Studio**. This is an overall report, not an itemized validation of transaction costs or ownership after restart. The next recommended focus is **v0.15 multiplayer/mobile/release QA**, specifically verifying saved Wins, skin ownership across restarts, secure purchases, and private published-server behavior. Not yet approved or implemented.

## Open decisions

| Question | Options | Status |
|---|---|---|
| First game mechanic | Glass-bridge voting race over lava | **Approved**; initial prototype committed |
| First game name | Choose name after testing | Not selected |
| Two-player rule and tie-handling | Fixed 1–5 choices grant up to N steps when safe; tied most-popular groups of 2+ are blocked; no spinner | **Approved for prototype** |
| Bridge race parameters | 20 tiles, 3 cracks, 5s vote / 6s move | **Implemented**, requires Studio playtesting |
| AI-to-Studio integration | Assistant/scripts, Rojo/code-first, local MCP-enabled client | To confirm |
| First-store balance | Cosmetics only vs one tightly bounded optional perk | To confirm |
| First target audience | Age-checked 16+ first vs expanded Kids/Select reach subject to eligibility | To confirm |

## Later decisions

- Reusable module extraction after the first playable game
- Pricing tests and whether any paid power-up should exist
- Portfolio expansion cadence based on measurable retention
- Promotion and advertising budget only after launch data
