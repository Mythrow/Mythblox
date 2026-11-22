# Game 01 — Studio Test Plan (Prototype)

**Status (2026-11-22):** **v0.28** removes the redundant reveal legend and reclaims 16px of phone screen space. SAFE/BLOCKED labels, five card avatars and counts and the server's five-second reveal are unchanged. Real-phone and Studio verification is still needed.

## Playtest log

| Date | Environment | Result | Remaining validation |
|---|---|---|---|
| 2026-11-21 | Roblox Studio, 1 client (user-reported), v0.1 | Installer worked; solo gameplay matched expectations under several unspecified conditions | Specific checklist cases not enumerated |
| 2026-11-21 | Roblox Studio, multiple players (user-reported), v0.1 | Multiplayer worked across multiple unspecified conditions | Reported bugs: initial/respawn near lava, repeated FINISH signs, fixed 8 bridges during join, missing vote breakdown UI |
| 2026-11-21 | GitHub v0.2 (owner-confirmed functional) | Owner reports revised game functions work | Improve UI later; perform mobile, performance, exploit and release QA separately |
| 2026-11-22 | Roblox Studio v0.11 (owner-reported) | User says the updated environment works | Individual v0.11 visual checks not itemized; release QA, mobile and spectator stress testing still pending |
| 2026-11-22 | Roblox Studio v0.12 (owner-reported) | User confirms updated gameplay feedback works | Specific regressions not individually enumerated; deeper mobile, multiplayer and audio verification pending |
| 2026-11-22 | Roblox Studio v0.13 (owner-reported) | Coins remain after stopping and restarting Play, confirming a successful Studio persistence test | Win persistence and live/private published-server persistence not separately checked; Studio Game Settings 'Failed to parse secrets: Can't parse JSON' warning noted |
| 2026-11-22 | Roblox Studio v0.14 (owner-reported) | User says the cosmetics update works | Restarted cosmetic ownership and equipment, precise coin deductions, wins persistence, mobile UI, and multiple clients not individually reported |
| 2026-11-22 | Roblox Studio v0.15 (owner-reported partial) | Joining, movement and cosmetics confirmed working | Voting reveal design needed adjustment; deeper multiplayer, saved Wins/skins after restart and mobile reliability tests remain open |
| 2026-11-22 | Roblox Studio v0.18 (owner-reported regression) | User can continue running to finish and glass does not reliably break after invalid movement | v0.19 code fix committed, not yet verified in Studio; ensure eliminated character cannot traverse remaining tiles |
| 2026-11-22 | Roblox Studio v0.20 (owner-reported) | Lobby environment loads; user walks through trees and lamps, cannot sit on benches; shops are open, lack front desks and attendants | v0.21 colliders, Seats and kiosks committed; not yet tested with a friend |

### Previously addressed: v0.2 fix verification (owner reports functionality works)

1. **Stop** the old Play session; open latest [installer](INSTALL_STUDIO_COMMAND_BAR.luau), copy **Raw**, paste into **Command Bar** and Run again while in Edit mode.
2. Start single-player Play without joining. Confirm you spawn safely **inside the elevated lobby**, with no repeat lava deaths. Confirm **no glass lanes** exist before join closes.
3. Join a solo practice match; after 10 seconds confirm there is **exactly one** glass lane and **one shared FINISH banner**.
4. Repeat in Server & Clients with **2 clients**; join both. Confirm **exactly two** glass lanes and one FINISH sign.
5. Vote differently (e.g. A=5, B=3). During reveal and walking, confirm the board lists **vote totals 1–5**, each player's pick and **MOVE 5/MOVE 3**.
6. Vote the same number. Confirm counts reflect two votes for it, **BLOCKED** displays that number, both players show **CRACK** with their crack count.
7. Force a fall by stepping onto forbidden glass or receiving a third crack. Confirm the next character **respawns at the safe lobby** and does not get stuck dying in lava.
8. At match end, confirm bridges disappear before the next join period and reappear with the **new** participant count.

### Previous priority: two local clients

1. Choose **Test → Server & Clients** and set **2 clients** in Studio.
2. Press **JOIN NEXT MATCH** on both clients before the join countdown finishes.
3. Vote differently (e.g. A=5, B=3); both should be permitted to walk their respective distances.
4. In another turn, both vote the same number (e.g. 5); both should receive a crack and remain on their panels.
5. Test the forbidden step, eligible player standing still, and the third crack. Record any red errors in Output.
6. Repeat with 3–4 clients if the two-player flow works.



## v0.28 — no redundant vote-reveal legend

- [ ] Reinstall the v0.28 one-paste script in Edit mode. Confirm `v0.28 VERIFIED` and matching server/client versions.
- [ ] In Studio and the published Roblox app, enter VOTE then REVEAL. No `GREEN = SAFE / RED = BLOCKED` explanation should appear above the five result cards.
- [ ] All five number cards must still show voters' avatars, pick totals and explicit SAFE/BLOCKED text in their existing muted green/red colors.
- [ ] On short mobile portrait and landscape screens, the shorter **140–156px** reveal should not clip any avatar or card text; phone status still occupies its 43px top-right region.
- [ ] After five seconds the reveal disappears, normal MOVE begins, and forbidden-step elimination works. No vote data appears to other players before REVEAL.
- [ ] Recheck solo published-server practice and the unchanged two-player rewards separately.

## v0.27 — published mobile JOIN, safe-area card, grounded objects

**Studio alone is no longer sufficient for this acceptance test.** Republish the private place after installing the matching scripts.

- [ ] Stop Play, paste the current [installer](INSTALL_STUDIO_COMMAND_BAR.luau) into the Studio Command Bar in Edit mode; confirm `v0.27 VERIFIED`, server and client logs both `v0.27`.
- [ ] **Published one-player phone:** Open the private Roblox experience as its only player, press JOIN with at least a few seconds on the timer, and verify the server queue acknowledges the tap. After the JOIN countdown reaches zero, **one glass lane is built and the player enters VOTE → REVEAL → MOVE**. This is now SOLO PRACTICE; no other player is required.
- [ ] **No solo farming:** Complete solo practice in the published Roblox app, record Wins/Coins before and after and rejoin to confirm **zero new coins/wins**. Studio solo may retain its preexisting test rewards and uses a separate store.
- [ ] **Two-account published match:** Have two friends/accounts join the same private server and JOIN before the timer ends. Two lanes should spawn; verify blocked-majority/tied votes, illegal steps, first finisher and regular +25 winner/+5 participant awards are unchanged. Confirm no server error.
- [ ] **Late JOIN handling:** Tap JOIN near the countdown boundary or during intermittent lag. If the server did not accept it, the client must not permanently hide the Join button; it should be available next JOIN window. Check `[Mythblox QUEUE]` Output where available.
- [ ] **Mobile HUD:** Confirm the round card is a 43px-high right-aligned strip below Roblox's native top inset, not a wide centered obstruction. Check a narrow portrait phone and a short landscape phone, including vote/countdown, optional save warnings and Wins/Coins.
- [ ] **Floating-prop audit:** Walk beneath the join and rewards boards, around each bench, planter and lamp base, inside both pergolas, and around the fountain/trophy. Confirm no visible gaps to the ground or unattached lanterns, and no new collisions/blockages.
- [ ] **Regression:** Walking/jumping remain free, the forbidden glass attempt shatters and kills/respawns the racer, shops and two-person seats still work, v0.25 clouds and matte materials remain, and live persistence is not lost.
- [ ] Send phone screenshots for the HUD and a Studio screenshot of any remaining detached object. Roblox engine/mobile visual verification must be recorded separately from code checks.

## v0.26 — lobby display overlap and paving seam QA

- [ ] **Install current build:** Stop Play; run the [latest command-bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode. Verify `v0.26 VERIFIED` and matching server/client/HUD versions.
- [ ] **Compare screenshot angle:** The very large plain-brown board obstructing the plaza in the user's v0.25 image should now be a compact, readable leaderboard from **either side**.
- [ ] **Physical separation:** Walk between the leaderboard, its supporting wood post, and relocated lamp at x=47/z=-79; none should intersect. Check the rewards podium and relocated lamp at x=-47/z=-79 as well.
- [ ] **Shop path junctions:** Walk both left/right shop approaches and confirm the paving touches the center path without crossing textured surfaces or leaving gaps.
- [ ] **Lounge T-junctions:** Check both side-lounge cross paths and return paths; no flickering, duplicate pavement textures or narrow gaps where the pieces meet.
- [ ] **No new invisible obstacles:** Collision/physics of lamps and benches remain intentional; the revised scoreboard does not obstruct the arrival plaza, camera, rewards or passage to JOIN.
- [ ] **Gameplay regression:** Join, vote, freely move/jump, test forbidden glass shatter/elimination, shop/bench interactions and progress saving across rejoin.
- [ ] **Phone and desktop views:** Validate both closer side views and the wide plaza overview for neat shop displays, text legibility and no obstructive boards. Report additional exact locations/screenshots of intersections.

## v0.25 — fuller sky, matte floors, and invisible spawn marker (visual QA pending)

Check in the actual Roblox Studio engine before marking the appearance approved. A code consistency check cannot prove brightness or cloud rendering.

- [ ] Stop Play; run the updated [Studio installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode. Confirm `v0.25 VERIFIED` in Output and server/client `v0.25`.
- [ ] Match the original spawn screenshot camera framing. More natural clouds should be visible overhead compared with v0.24; the blue-gray sky should remain visible behind them rather than turning into a plain white overcast dome.
- [ ] Review the wide central plaza (`SpawnPlaza`): it should be weathered-oat matte **Concrete** with actual visible texture, not bright ivory/white or glossy Sandstone.
- [ ] Review JOIN/spectator deck and both front-connected side promenade surfaces: they should be darker, matte shaded stone, with no white/neon-like slab appearance.
- [ ] Look for the old rectangular pale spawn pad in the middle of the plaza. It should not be visible (fully transparent SpawnLocation), while both new joins and respawns still appear safely in the elevated lobby.
- [ ] Verify large white ceramic planters, fountain stone, shop floor/counters, lamp bases and pergola columns have muted weathered-stone finishes instead of bright ivory.
- [ ] Confirm the same showroom-quality aesthetic on actual phone screens, both higher and lower graphics settings. Native cloud visibility may depend on graphics level; do not falsely claim clouds always render identically.
- [ ] Check the preserved warm accents (sage shop roof, dusty-rose cosmetics roof, terracotta details, timber benches), legible shop signs, and appropriate contrast around the glass arena.
- [ ] Regression: join from the world pad and HUD, walk/jump at any time, sit in two-person benches, browse cosmetics, vote 1–5 privately, resolve five-number reveal and shatter/respawn on illegal glass steps.
- [ ] Confirm v0.23 round-end saving still works in a published private server, including reconnecting and validating persistent Wins/Coins and cosmetics.
- [ ] Send a screenshot from the original spawn angle and a phone view. Consider another material pass if any horizontal surface remains glaring.

## v0.24 — natural coastal daylight / no yellow screen tint (visual QA pending)

**Source-level lighting patch only.** Run the newest installer and validate the look in the actual Roblox renderer; a matching installer is not evidence of final appearance.

- [ ] Stop Play and run the [latest installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Studio Edit mode. Output must show `v0.24 VERIFIED` and server/client `v0.24`; the top HUD's version confirms the client update.
- [ ] Stand on the main plaza in the same framing as the owner's v0.23 reference screenshot. Compare sky, paths, shop roofs, tree canopies, character and water. All should be **free of a whole-screen beige/yellow cast**; warm oat/wood/terracotta **objects** should still be visibly warm.
- [ ] Inspect the distant horizon and sky. It should look like soft neutral blue-gray daylight, not beige fog or extreme cyan; clouds should appear gently white.
- [ ] Compare grass, evergreen trees and planters. They should be clearly green, not yellow-brown, while maintaining the original muted sage/evergreen palette.
- [ ] Inspect the cream/oat plaza on desktop and a real phone (low/high graphics settings if available). Texture remains visible, with no white-hot highlight or reflective/glossy glare. Bloom remains off.
- [ ] Check daytime lighting and shadows around both staffed kiosks, benches, pergolas, the fountain, join platform and glass course. Ensure legibility and good contrast; no excessive darkness or over-saturation.
- [ ] Confirm the unchanged 49px mobile top HUD, five avatar reveal cards, all five vote buttons, Wins/Coins warnings, and working player movement/jumping.
- [ ] Run two-player regression of illegal-step shattering and respawn, paid-with-coins cosmetic equip, independent bench seating and round-end data saving. Lighting changes must not alter these systems.
- [ ] Report a matching Studio screenshot plus actual phone screenshot before marking the visual issue resolved. Roblox Studio/device render remains **unverified until owner retest**.

## v0.23 — completed-round saving and status warnings (live QA required)

This is a code-level reliability update; it has **not been run in Roblox Studio or on a real phone**.

- [ ] Reinstall the latest one-paste installer in Studio Edit mode with Play stopped. Verify `v0.23 VERIFIED`, `SERVER RUNNING v0.23` and `CLIENT RUNNING v0.23`.
- [ ] With a published test place and Studio API Services enabled, play through a match and confirm the server logs `[Mythblox DATA] Saved` with `round-end` **before closing the server**. Verify winner +1 Win/+25 Coins and participant +5 Coins.
- [ ] Restart/rejoin, verify stats are unchanged except for the one earned award, then complete another round and repeat. Check that overlapping round-end, autosave, shop and shutdown saves never double-credit rewards.
- [ ] In a private published Roblox-app server, test with two accounts; verify Wins, Coins, owned colors and equipped colors after both leave and join a fresh server. Studio and published DataStores are separate.
- [ ] In a disposable Studio test with API Services disabled, check `SESSION ONLY · NO PROGRESS SAVED` appears within the **existing** top status line during JOIN/RESULTS, not during VOTE/MOVE. Do not expect this temporary progress to persist.
- [ ] If a genuine save error occurs, verify `SAVE ERROR · REJOIN TO VERIFY` and a corresponding Output error. Do not claim this failure-path test passed without an actual failure or controlled mock.
- [ ] On a narrow portrait and short landscape phone, verify the status panel remains 49px high with no overlay or overlap with Wins/Coins, thumb controls, secret vote buttons or reveal cards.
- [ ] Reconfirm the v0.19 forbidden-step glass shatter/respawn fix; v0.21 bench seating, solid trees/lamps and staffed counters; v0.22 low-glare earthy theme. Do not disable walking or jumping.

## v0.22 — actual-phone glare, earthy theme and small HUD

**GitHub code and installer prepared; Roblox phone/Studio owner QA pending.** This is a styling/responsiveness pass, not proof of release readiness.

- [ ] **Reinstall/publish:** Stop Studio Play, copy the latest [one-paste installer](INSTALL_STUDIO_COMMAND_BAR.luau) using Raw into Edit-mode Command Bar, run it, check `v0.22 VERIFIED` and HUD/server/client v0.22. **Publish to Roblox** afterward if testing with your friend on the regular app, without changing private tester access.
- [ ] **Actual portrait phone:** look at arrival plaza near spawn, SHOP and cosmetics, paths, fountain, benches, ocean, sky and bridge. No white-hot stone, mirror/glare, neon-blue architectural parts, harsh neon lighting or overexposed sun streaks.
- [ ] **Theme across props:** oat beige plaza, sand paths, sage SHOP roof, dusty-rose COSMETICS roof, muted brown signboards/metal framing, warm wood benches/counters and restrained evergreen plants; all should feel like one soft earthy style.
- [ ] **Matte textures:** verify textured Sandstone/Pavement/Limestone still show detail on high and low phone graphics modes without glittery reflections; built-in Bloom is off and ambient/sun glow does not wash out gameplay.
- [ ] **Mobile top bar:** on 320px- and 390px-class portrait viewports, the status panel occupies around **49px** (not 83px), sits beneath the Roblox native safe area, and leaves the character/bridge visible. Text must not clip or overlap the countdown/Wins/Coins.
- [ ] **Landscape phone:** rotate screen or use Device Emulator. HUD should still switch to compact based on short screen height, with no large desktop panel. On wide desktop displays, retain the fuller status and progress display.
- [ ] **Phone status contents:** verify phase/round + seconds on top, `READY`, `GO 1–N`, `WAIT`, elimination or spectator guidance underneath. Wins and Coins chip must reflect leaderboard stats; full verbose guidance is desktop-only.
- [ ] **Mobile voting:** all 1–5 buttons remain easily tappable and private during VOTE; vote tray fits above native thumb control area on short portrait and landscape screens. Changing a vote still works within server rules.
- [ ] **Five-number reveal:** for five seconds, five safe/blocked result cards show the actual avatars and pick totals. All five fit across a narrow phone without overlapping text; avatar grids show up to 8 players and do not hide counts. Muted green/red are distinguishable. The display disappears in MOVE.
- [ ] **Friend test:** load the updated private Roblox-app experience with a friend. Check that two players can sit on the same bench, collide with trees/lamps, browse the staffed COSMETICS counter, JOIN, secretly vote and finish a round.
- [ ] **Critical gameplay regression:** try stepping early, jumping over a panel or going beyond the safe allowance. Glass **must break** and the racer must be eliminated/respawn. This v0.19 fix has not yet been individually confirmed by the owner.
- [ ] **Data/performance:** test Coins/Wins/owned cosmetics after rejoining and inspect FPS on a lower-end phone. Report red Output errors, too-small avatar thumbnails, excessive UI overlays, over-darkened surfaces or path/collision obstructions.

**Do not treat code consistency checks as a Studio or phone rendering test.** Share a phone screenshot for the next visual iteration.

## v0.21 — physical interactions and two-player friend test

**Installer status:** GitHub scripts and one-paste installer updated, **not tested in Roblox Studio**. Perform this before assuming the environment is fixed.

- [ ] **v0.21 install:** Stop Play, reinstall latest [Raw Studio installer](INSTALL_STUDIO_COMMAND_BAR.luau) in **Edit mode**. Confirm Output shows `v0.21 VERIFIED` and both server/client show v0.21; top HUD shows `v0.21`.
- [ ] **Collision:** In the expanded lobby, physically approach a tree trunk, its low canopy, a lamp post/base, a planter/foliage sphere, and pergola column. Your character should be stopped by the object rather than passing through. High decorative lighting accents need not collide.
- [ ] **Path clearance:** Recheck that no new solid tree or lamp blocks the spawn → cosmetics, JOIN deck, either spectator promenade, photo spot or two lounge paths. Keep walking/jumping enabled everywhere.
- [ ] **Bench seating:** Approach a resort bench. It has two distinct `Seat` parts. Press E **Sit** on the left seat; avatar should sit naturally. Jump to stand. Re-sit after the normal Roblox seat cooldown.
- [ ] **Friend seating:** With two players, each sits on a different side of the **same bench simultaneously**. The occupied side should not advertise another Sit prompt. Either can get up without unseating the other. No accidental seat lock after leaving.
- [ ] **Both shops visibly built:** Each kiosk has enclosed sides, glass side windows, a front customer desk, register, merchandise displays and roof/sign. Both contain a **visible shopkeeper with face/uniform/hat and a gentle wave**. The NPC should remain behind the counter rather than running around or blocking the player.
- [ ] **Functional cosmetics:** Stand **outside the front counter** of the right COSMETICS kiosk, press E **Browse colors**, and check the existing four products/prices (Classic free, Pink 20, Mint 40, Violet 60), owned state, purchase/equip, closing UI. Do not need to step inside the kiosk. No double charge.
- [ ] **Left shop remains placeholder:** It has a shopkeeper and service desk but still reads **COMING SOON**. No fake purchasable items, coins, new economy remote or unapproved feature.
- [ ] **Two-player race:** In Studio choose **Test → Server & Clients (2 clients)**, or if testing remotely, publish/update a **private testing experience**, ensure your friend has play access, and have both join the same server. Both should be able to JOIN before countdown and get exactly two lanes.
- [ ] **Secret votes:** A and B choose different numbers during VOTE. During the five-second REVEAL, see five cards with both avatars, exact pick counts, SAFE/BLOCKED red-green result cards only. No other player's choice is disclosed early.
- [ ] **Illegal movement regression:** Try moving before MOVE, jumping over a tile, or advancing beyond a safe vote. The glass must visibly shatter; the racer must be eliminated and respawn at the lobby. **This important v0.19 fix has not been confirmed**; do not count the build as reliable if this fails.
- [ ] **Safe progress and results:** Legal 1–N steps, win detection, confetti/dance, coins/wins and next match still function; two players should remain free to move/jump while alive.
- [ ] **Exit/rejoin:** Both players can leave and join again without stuck seats or duplicated shop NPCs. Test stored Wins/Coins/owned/equipped skins separately in the published private experience; Studio uses a different test DataStore.
- [ ] **Mobile/performance:** Inspect close-range E/Touch prompts, NPC visibility, seating on touch devices and two-player frame rate. Capture Output errors such as missing NPC properties, bad Seat connections, duplicate world models or Lua runtime exceptions.

**Friend testing note:** A private published Roblox experience may require access to be explicitly granted to your friend. Studio's 2-client simulator is a useful local test, but it is **not** an actual online friend session. Don't make the game publicly discoverable merely to test.

## v0.20 — Azure Coast Resort lobby, clouds, no-template-floor and escape prevention

**Code committed; not yet executed in Roblox Studio.** Create a place backup first because the **Edit-mode installer intentionally removes a stock Baseplate part** when present.

- [ ] **Installer:** Stop Play, save a place backup, copy latest [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) from Raw, run in Edit mode. Output reports `v0.20 VERIFIED` and count of removed stock Baseplate part(s). Start Play and confirm `v0.20` in both runtime logs and HUD.
- [ ] **Original default part removed:** check Workspace at Edit mode/Play. There must be no large low `Baseplate` or orphan stock SpawnLocation visible beyond the arena. User-created unrelated map parts must remain untouched.
- [ ] **Lobby dimensions:** the new 186×124 island and 56×39 spawn plaza feel visibly bigger while spawn still lands at roughly x=0,z=-76. No floating or z-fighting floors, displaced shops or inaccessible deck.
- [ ] **Theme consistency:** ivory/limestone paths, teal/deep-teal metal roofs and fences, champagne brass accents, evergreen greenery, muted coral cosmetics-roof accent. The HUD and physical world signs use the matching theme. No returning rainbow/bright neon design.
- [ ] **Social spaces:** inspect/approach central sea-glass fountain near z=-118, both lounges at x=±68,z=-71, benches, planters, lamps, photo arch and trophy garden. Props do not trap players; movement and jumping remain normal.
- [ ] **Clouds and atmosphere:** native drift clouds are visible on supported graphics settings; no duplicate stacked cloud layers. Ocean horizon is longer and six noncolliding cliff islands appear at a distance. No intense glare, excessively fogged camera or invisible world sign labels.
- [ ] **Water escape:** jump off an island edge or a spectator walk (in a controlled test). Invisible perimeter should guard the island edges; a successful fall below the suspended world should automatically kill/respawn the character **before** they can walk on the ocean or beneath the island. Do not disable JumpPower.
- [ ] **Perimeter path access:** from spawn, walk freely to cosmetics/SHOP, original single JOIN deck and both left/right spectator promenades. Invisible edge walls must **not** close the walkway connector openings or prevent legitimate jumping.
- [ ] **Shop and board:** open the cosmetics E prompt at its original stall; purchase/equip if you have coins, then close the UI. The TOP RACERS board should show names/Wins/Coins without a giant overlay. Check the SHOP placeholder is still in its original location.
- [ ] **Bridge regression first:** repeat the complete v0.19 checklist below. Illegal forward advancement before MOVE or beyond selected N should visibly shatter glass, eliminate the player and respawn at the lobby. The increased environment decoration must not let eliminated players run to the finish.
- [ ] **No spoiler colors:** normal bridge panels retain classic/purchased neutral color. Red/green vote outcome colors stay on the results cards only.
- [ ] **2–8 player stress:** test several client counts, join, spectate, walk/jump, purchase, dances and respawns. Confirm no significant framerate/memory regressions caused by clouds, PointLights, distant scenery or decorative parts.
- [ ] **Mobile:** test narrow phone/tablet view, smaller decals/labels, thumb controls, readable signage and lobby navigation. Ensure no decorative props block movement.
- [ ] **Persistence:** verify Coins, Wins and owned cosmetics survive Play restarts, then test separate private published-server storage.

**Approval gate:** Owner must see the actual Roblox Studio environment and judge whether it meets the desired theme; a static code/installer check is not a visual test. This is not final art or launch readiness.

## v0.19 — critical crossing regression (test before anything else)

**v0.18 failed owner testing.** Reinstall the latest [Studio installer](INSTALL_STUDIO_COMMAND_BAR.luau) in **Edit mode with Play stopped** and check `v0.19 VERIFIED`, server/client `v0.19`, and Output free from script errors.

- [ ] **Early advance during VOTE**: walk forward from tile 0 to tile 1 before reveal. Attempted + supporting glass must **shatter and fade** (not a full-tile red highlight), the player must be **eliminated and return to the lobby**, and cannot continue running to tile 20 or win.
- [ ] **Advance during REVEAL**: step or jump onto tile 1 before MOVE. Same elimination, shatter and respawn.
- [ ] **Blocked pick**: with two clients choosing the same number, both get a crack and must not advance. Walking/jumping **on their existing tile** remains allowed. A forbidden forward step must break glass and end that player's run.
- [ ] **Safe pick overrun**: solo Studio or with two clients, choose a safe `1`, advance one tile normally, then attempt to advance to tile 2 in the same MOVE. Second tile and supporting glass must break, eliminating the racer.
- [ ] **Legal move and valid jump**: choose safe `3`, walk/jump normally on the current tile and advance 1–3 tiles during MOVE without elimination, then complete MOVE. Glass **behind** the successful advance shatters as the next turn starts.
- [ ] **No progress**: choose a safe number and stand still through MOVE. Your starting glass shatters; the character falls/dies and returns to the lobby.
- [ ] **Three cracks**: blocked or missing votes accumulate 3 strikes and break the current tile on the third, ending the run.
- [ ] **Jump across several tiles**: try to jump from tile 0 directly to tile 2. The server's position check must eliminate even if the contact check did not fire on an intervening tile.
- [ ] **No extra rewards**: a racer eliminated by illegal advancement must not become the finisher or collect a winner reward; other racers continue normally.
- [ ] **Spectators after respawn**: eliminated players return safely to lobby/deck, cannot interfere with lanes or acquire extra votes in the current round.
- [ ] **No spoilers**: intact bridge tiles stay their neutral/purchased tint. Only reveal cards mark safe/blocked with green/red; cracked/broken glass must be visibly damaged or absent.
- [ ] **Output**: confirm `[Mythblox RACE] ELIMINATED <name>: <reason>` appears when a racer breaks the rules. Capture any red errors or unexpected continued movement.

**Studio execution is not available to the assistant.** The commit fixes a specific source bug; the test is **not marked passed** until owner checks it.

## v0.18 — unrestricted avatar controls, fair no-spoiler glass and upgraded environment

**Latest version; owner Studio QA pending.** Stop Play, install the latest [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode and verify `v0.18 VERIFIED`, then v0.18 HUD and both server/client Output tags.

- [ ] During **JOIN**, move and jump freely around the lobby, join deck and cosmetics stall.
- [ ] During **VOTE** and **REVEAL**, you can **walk and jump normally on your current glass panel**. WalkSpeed and JumpPower must not drop to zero; jumping is not disabled.
- [ ] During **MOVE** and **RESULTS**, movement/jumping still work. Winners should dance during the 5-second RESULTS phase, then the character can naturally resume moving/respawn.
- [ ] Validate **advance gating remains authoritative**: walking across to the next panel before MOVE still causes the existing early-step failure; going beyond allowed N, skipping panels, leaving the lane or stepping backwards during MOVE still fails. This is separate from the freedom to walk/jump.
- [ ] With any safe selection, check that no entire future panel turns **green**. With a blocked selection, check that no entire next panel turns **red**. Neutral glass should retain classic or purchased tint; cracked glass has crack lines rather than whole-tile danger coloration.
- [ ] The **five number result cards** during 5-second REVEAL still mark SAFE **green** and BLOCKED **red**; the tiles themselves stay neutral. The small MOVE HUD says `GO · ADVANCE 1–N PANELS` or `NO ADVANCE · WAIT THIS TURN` without naming colored tiles.
- [ ] Finish gate gold tile and checkered stripes remain distinct; a shattered tile fades and no giant red panel flashes. The glass tile materials remain transparent enough to read their edges.
- [ ] Compare island/plaza/paths/stalls/spectator walks before/after: marble, stone, pavement, warm accent trims, metal roofs/rails and leafy foliage should be clearly visible and **not block traversal** or overlap the lobby/shop prompts.
- [ ] Check sunlight/atmosphere, bloom, CrackedLava/Basalt, ocean reflections and finish arch look cohesive at daytime without glare obscuring voting UI. No overexposed glass or unreadable signs.
- [ ] Confirm the cosmetics prompt still opens and can purchase/reequip saved skins; changing colors only affects neutral bridge glass, not the five result cards.
- [ ] Confirm **R15 and R6 default victory dances** in Studio. If testing a custom animation ID, validate rig compatibility, permissions, and that failures do not suppress scoring or confetti.
- [ ] Test phone and tablet viewport: lobby, five avatar groups, movement controls and cosmetics UI should remain clear.
- [ ] With **2, 4 and 8 players**, verify physical frame rate and server/client Output remain stable despite added decorative details and per-tile metal corner brackets.
- [ ] Recheck Wins, Coins, ownership and equipped skin after restarting Play; then test in a private published Roblox server with its separate DataStore.

**This is a graphics and controls revision, not public-launch signoff.** No Roblox Studio tests performed by the assistant.

## v0.17 — historical checklist (superseded by v0.18 tile/control changes)

**Not yet run in Roblox Studio.** Test with 2 clients so the reveal and winner dance are observable.

- [ ] In Edit mode, with all Play sessions stopped, reinstall [the Studio installer](INSTALL_STUDIO_COMMAND_BAR.luau). Output should show `v0.17 VERIFIED` and HUD should display v0.17.
- [ ] Confirm JOIN lasts 10 seconds, secret VOTE lasts **5 seconds**, REVEAL lasts **5 seconds**, MOVE lasts **6 seconds**, and RESULTS lasts **5 seconds**.
- [ ] During VOTE, no public avatars, choice counts or SAFE/BLOCKED result cards appear. Local number-selection controls still work normally.
- [ ] During REVEAL, all five green/red number cards appear with correct avatars and totals and stay visible for the full **5 seconds**. Results remain non-clickable. At MOVE start, they disappear for players and spectators.
- [ ] During MOVE, the **large bottom warning panel is absent**. The small top text should show `GO · WALK 1–N GREEN TILES` for safe votes or `STAY · THIS TURN` for blocked votes. The old "Your next tile is unsafe" text must not appear anywhere.
- [ ] **Historical v0.17 behavior only:** allowed tiles were painted GREEN and blocked RED. **v0.18 removes this**; use the current v0.18 no-spoiler tests above instead. Illegal forward steps and other rule checks remain valid.
- [ ] When a **solo Studio practice** player reaches the last tile, or a competitive player wins, confetti should appear and the winning avatar should **dance in place during RESULTS**.
- [ ] Test a R15 winner and a R6 winner, where available. Neither victory animation may prevent scoring, interfere with the next match or persist after results/respawn.
- [ ] Test **last-survivor** and **tied winners**: all eligible living winners should dance; eliminated players should not dance. Confetti should still be emitted once.
- [ ] If default dance animation fails to load, Output may show `[Mythblox] Victory dance unavailable ...`, but gameplay/results/rewards should continue.
- [ ] Confirm no excess screen overlays or animation problems on narrow mobile viewports. Continue separately testing 2–8-player reliability, saved Wins, saved cosmetic ownership, and published-server data.

### Results UI regression inherited from v0.16

The v0.16 checklist below remains applicable, except the old **2-second reveal** expectation is now **5 seconds** in v0.17. Do not assume v0.17 passed any Studio test solely because its source/installer matched.

## v0.16 — secret voting and avatar result cards

**Owner-approved scope:** Exactly five numbered **results** cards appear only during the two-second REVEAL, showing voter avatars above each number, count below, GREEN safe/RED blocked. Keep voting selection controls, game rules and phase timing unchanged. Complete these tests after installing v0.16:

- [ ] In Edit mode with Play stopped, reinstall the [one-paste installer](INSTALL_STUDIO_COMMAND_BAR.luau). Output prints `v0.16 VERIFIED`; client and server run v0.16 with no red errors.
- [ ] During **VOTE**, racers can select numbers privately using the 1–5 buttons, but **no reveal cards, other players' choices, their avatars, vote counts, or SAFE/BLOCKED result colors appear**. Observers see no vote details either.
- [ ] Exactly when **REVEAL** starts, the private vote buttons hide and exactly five non-interactive cards appear together. Attempting to tap a result card does **not** send another vote.
- [ ] Each card shows the **selected players' circular avatar headshots at the top, the number in the middle, and exact N PICK/PICKS below**, including `0 PICKS` for an unselected number. Your own avatar has a gold border.
- [ ] With **2 players choosing 4**, card 4 shows two avatars, `2 PICKS`, red and BLOCKED. Cards 1,2,3,5 are green and show `0 PICKS`; both players gain one crack.
- [ ] With **2 players choosing 2 and 5**, cards 2 and 5 show one avatar each, `1 PICK`, green and SAFE. The remaining zero-vote cards are also green.
- [ ] With **4 players choosing 2,2,3,3**, both cards 2 and 3 show `2 PICKS`, two avatars, and **RED**; the other three are GREEN.
- [ ] With **one player voting nothing**, no avatar should appear on their behalf; the total counts should reflect only actual votes and a missed vote still causes one crack.
- [ ] With **8 players all choosing the same number**, that result shows **eight distinct headshots** in a grid without covering its number or count; no avatars should be duplicated or dropped.
- [ ] The full reveal appears only during REVEAL (**5 seconds in current v0.17**, historically 2 seconds in v0.16). When MOVE starts, it disappears for both racers and spectators; the compact GO/STAY top HUD and movement controls remain usable.
- [ ] Restart the next vote; no stale avatars/tallies or unsafe colors from the prior turn are visible before the next REVEAL.
- [ ] Test narrow Studio Device Emulator phone and tablet screens. All five numbers, counts and green/red status must fit; thumbnails should remain recognizably circular. Report blank avatars, clipped text, or unreadably small cards.
- [ ] Check wins, coins and purchased skins continue saving, and complete the rest of the v0.15 multiplayer/mobile QA before any public release.

**Not yet verified in Studio.** No new gameplay rules, DataStore schema, pricing or reward changes.

## v0.15 — multiplayer, mobile and reliability checkpoint

**Not a release sign-off.** The owner explicitly requires significantly more content and a major visual overhaul before launching. See [PRELAUNCH_ROADMAP.md](PRELAUNCH_ROADMAP.md).

- [ ] **Installer/version:** Stop Play, reinstall latest [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode, confirm `v0.15 VERIFIED`, then `SERVER RUNNING v0.15` and `CLIENT RUNNING v0.15` in Output and `v0.15` in the top HUD.
- [ ] **Two players, unique votes:** Run **Test → Server & Clients**, choose 2 clients. Both queue; verify only 2 lanes, distinct valid votes, revealed totals, green eligible tiles and manual movement.
- [ ] **Two players, identical votes:** Both pick the same number. Both receive 1 crack and must stay; red tiles remain unsafe. Three cracks still eliminate.
- [ ] **Tied majority:** With 4+ clients, make two choices each receive 2 votes. Both tied top choices block, others safe.
- [ ] **No vote and illegal movement:** No vote causes a crack; moving without permission or more than N manually entered tiles causes a fall, not free progress.
- [ ] **Mid-round leave/reconnect:** A player leaves during a round; others continue, and departed player's lane doesn't rejoin the race. Rejoining does not permit jumping into another active lane.
- [ ] **Spectator:** Start a race with a late-arriving nonparticipant; they remain on shared ready/spectator deck or side walks, cannot occupy glass lanes or interfere with racers, and can see vote results only after reveal.
- [ ] **Remote load:** Rapidly click vote choices/Join/Shop/Sync in the ordinary UI. Valid deliberate clicks work; excessively repeated requests do not produce errors, duplicate charges or multiple UI copies. Do not modify game timing or reward rules.
- [ ] **Saved Wins:** Win a match, stop Play, restart, and confirm Wins increased exactly once. This is **not yet separately verified**.
- [ ] **Saved Coins and ownership:** Buy Candy Pink (20 coins), stop/restart Play, return to the stall. Balance should reflect one deduction, the skin must remain owned and equippable, and no second charge occurs.
- [ ] **Saved rewards after purchases:** Earn another 25/5 coins after a purchase, stop/restart. Confirm skins and currency both persist without duplicates or resets.
- [ ] **Different users:** Two real user accounts save separate coins, wins, cosmetics. Studio emulated player IDs may differ, so test a private published server before public launch.
- [ ] **Mobile narrow screen:** Test at least a narrow phone portrait viewport and tablet via Studio Device Emulator. Join, vote numbers 1–5, GO/STAY, shop scrolling/close, spectator camera and Roblox movement controls must not overlap.
- [ ] **8-player performance:** Start an 8-client Studio server if practical. Verify 8 lanes only, repeated crack fragments disappear, no significant framerate drops or large Output spikes.
- [ ] **Private published server:** Verify live DataStore is deliberately separate from Studio test data; saved Wins, Coins, purchased skins and equipment survive leaving and rejoining actual Roblox sessions.
- [ ] **Inspect Output:** Record any `[Mythblox DATA] LOAD FAILED`, `SAVE FAILED`, `SAVE_ERROR`, shop transaction warnings, UI version mismatches or new runtime errors. A Roblox Game Settings secrets-parsing warning can occur separately, but should not be treated as proof all DataStore writes succeed.

**Static source and installer consistency checks are not Roblox-engine testing.** Do not mark this QA pass complete until the above cases are independently verified. After v0.15, move into the **feature and visual-development roadmap**, not directly to release.

## v0.14 — cosmetics purchases, equipment and data regression

- [ ] Stop Play and install the latest [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode; confirm `v0.14 VERIFIED`, then check HUD shows v0.14.
- [ ] Approach the **COSMETICS / GLASS COLORS** stall on the right-hand path. The E / touch prompt should appear. Press it and confirm a compact shop opens and closes without adding an always-visible button.
- [ ] Shop options should show **Classic Blue (free), Candy Pink (20), Mint Pop (40), Soft Violet (60)**. Only four colors; no misleading Robux offer.
- [ ] With a saved balance of at least 20 coins, buy Candy Pink. Check exactly 20 coins are deducted and the owned/equipped state updates; repeat requests must not charge again.
- [ ] Start a match after equipping: neutral glass in **your lane** should be pink; allowed green tiles, unsafe red tiles, cracks, and gold finish still use gameplay colors.
- [ ] Equip Classic Blue and return to Candy Pink. Both should be free after Pink is unlocked; do not buy it a second time.
- [ ] Stop Play, start again and return to the stall. Confirm equipped/owned cosmetics and the lower coin balance persist in the same Studio test DataStore.
- [ ] Earn more coins in a match **after** buying a cosmetic. Restart Play and verify the new rewards are saved without erasing ownership.
- [ ] With too few coins to buy a color, the server should refuse the purchase without reducing balance or unlocking the color.
- [ ] With Studio API Services off or DataStore loads failing, opening the stall should show **UNAVAILABLE** actions; no purchase should succeed and saved progress should not be overwritten.
- [ ] Trigger the E prompt while walking away; remote purchases should be rejected when not near the cosmetics stall.
- [ ] Test 2–3 clients: separate account balances and separate purchased skins, no duplicate or stale UI; spectator and voting HUD remain unobstructed.
- [ ] Test a narrow/mobile viewport: item list scrolls and shop close button remains usable.
- [ ] Separately confirm **saved Wins** (still unchecked) and test private published-server persistence. Studio uses a different DataStore than published gameplay.

**Status:** Owner confirms v0.14 overall functionality in Studio. Individual purchase, cosmetic ownership persistence, and data-retention test cases remain unchecked until explicitly verified. Do not change the DataStore name or overwrite existing balances.

## v0.13 — persistent progress and safe failure handling

The [persistence test guide](PERSISTENCE_TEST_GUIDE.md) contains beginner-friendly Studio setup and restart instructions.

- [ ] Backup the Studio place, publish the experience **privately**, and enable **File → Experience Settings → Security → Enable Studio Access to API Services**.
- [ ] Stop Play; install the latest [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode. Confirm `v0.13 VERIFIED` in Output, and the top HUD displays v0.13 in Play.
- [ ] Check server Output for `[Mythblox DATA] Loaded ...`, or the Player attribute `MythbloxDataStatus = READY`.
- [ ] Complete one solo or two-player round. Confirm unchanged rewards: winners +1 Win/+25 Coins; other participants +5 Coins.
- [ ] Stop Play and confirm `[Mythblox DATA] Saved ...` was printed (no save failure), then start **another** Play session. Saved totals should reappear.
- [ ] Complete another round and restart again. The totals should **increase exactly once**—no duplicate wins or double coins from retried saves.
- [ ] Two-client test with different users: results remain isolated by user ID; an eliminated or unqueued spectator does not receive match rewards.
- [ ] Verify a failed Studio API configuration produces `SESSION_ONLY` and a clear warning **without stopping the gameplay**; do not assume temporary rewards saved.
- [ ] Confirm Studio test data is isolated from the live published experience's DataStore.
- [ ] Test rapid leave/rejoin and server shutdown, including an interrupted or failed save if possible. Investigate any `SAVE_ERROR`, `LOAD FAILED`, or `SAVE FAILED` messages.
- [ ] Reconfirm unchanged voting, 20 tiles, 3 cracks, spectator boundaries, sound cues, and no new gameplay HUD clutter.

**Not yet verified in Roblox Studio.** Source consistency and server-side guards are not substitutes for testing actual DataStore requests.

## v0.12 — gameplay feedback and sound regression

- [ ] Stop Play, run the latest [installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode, confirm `v0.12 VERIFIED` in Output, then start a fresh Play session showing `v0.12` in the top HUD.
- [ ] During vote, tap 1–5 repeatedly. Selection highlights correctly, switches remain server-approved, and each tap gives a **subtle sound**, not a loud repeating loop.
- [ ] During the final three voting seconds, hear a short gentle countdown cue; the last two seconds highlight the vote title/timer. No extra button covers mobile controls.
- [ ] Two-player case A=5, B=3: both are safe. Their personal feedback reads `SAFE PICK` and their own rows are highlighted green in the reveal panel; then they see WALK/GO.
- [ ] Two-player case A=5, B=5: both gain one crack, hear the crack cue, see blocked numbers and their own red-tinted results. Both must stay.
- [ ] Play a full match with a deliberate illegal move. The player hears a fall sound, sees a short red feedback strip (desktop), and the current glass spawns a few fragments that vanish quickly. No lasting physical debris remains.
- [ ] Get a third crack; check immediate fall, safe respawn, no duplicate audio, and no return to a broken glass tile.
- [ ] Walk 1–N eligible tiles manually; unchanged green/red rules and 6-second window.
- [ ] Win by **first reaching tile 20**: existing finish arch displays confetti and game result stays only in compact top HUD.
- [ ] Win by **last survivor**: finish confetti also appears. Confirm no double confetti when someone already crossed the finish first.
- [ ] Test a full match as an **unqueued spectator**, confirming votes remain secret until reveal and glass fragments do not obstruct walking on spectator decks.
- [ ] Test Studio **Device Emulator**/narrow viewport: top status, five-number buttons and GO/STAY warning are readable; the extra feedback chip must not cover movement controls.
- [ ] Check Audio Output for missing built-in sound paths, server/client Output for errors, and desktop/mobile performance when multiple players fall at once.

**Status:** Overall v0.12 functionality confirmed by owner in Studio. The individual items above are still unchecked because detailed results were not provided. All changes in this phase are visual/audio only.

## v0.11 — visual fix verification

- [ ] Stop Play, run the latest [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau), confirm `v0.11 VERIFIED` in Output and `v0.11` in the HUD during Play.
- [ ] Finish: from last glass tile, verify there are exactly two symmetrical blue posts, one white FINISH beam, and no extra flags, floating white label, or stacked blocks.
- [ ] Final tile: checker markings appear only on each player's last tile, not as a bridge across gaps. Winning still triggers on tile 20.
- [ ] Leaderboard: one **small board** near spawn, text on the face looking toward the main plaza; no text on the reverse, no central post showing through the sign.
- [ ] Leaderboard text contains only `TOP RACERS` and actual name/win/coin rows; no reset notices or scope disclaimers. Winning updates the rows.
- [ ] Bridge glass/decorative rails: ends align to tile 0/20 edges and do not stick past the sides.
- [ ] Shared ready deck: front transparent barrier aligns to deck edge; inward glass guards align to promenade ends without blocking the connection from the ready area.
- [ ] Look toward the hub from the bridge: visible soil/stone layers form a clearer island edge, with blue sea covering the former gray terrain background.
- [ ] Test three clients (two racers, one spectator). Spectators can reach side walks but cannot cross onto race lanes or shortcut.
- [ ] Recheck JOIN prompt, voting 1–5, 3 cracks, illegal stepping, falls, respawn, first finisher/last survivor, temporary coins and winning.
- [ ] Check both server and client Output for errors; compare before/after screenshots.

**Not yet passed:** code and installer are updated, but the owner has not tested v0.11 in Roblox Studio.

## v0.10 — remove default Baseplate spawn and verify session leaderboard

- [ ] Stop Play. Run the latest [installer](INSTALL_STUDIO_COMMAND_BAR.luau) in **Edit mode**, confirm `v0.10 VERIFIED` in Output and check the unused Baseplate SpawnLocation removal count.
- [ ] In Studio **Edit mode**, expand Workspace: the low, near-origin default object named `SpawnLocation` should be gone. The server-generated `MythbloxLobbySpawn` appears during Play.
- [ ] During **Play**, inspect the lava near (0,0,0). The unwanted white star-shaped baseplate spawn platform should no longer be visible.
- [ ] Spawn, join, deliberately fall, then respawn: the character must return to the **elevated island plaza**, not to lava or another player's bridge.
- [ ] From spawn, inspect the physical leaderboard: `TOP RACERS`, `THIS SERVER ONLY`, and up to four actual players with Wins/Coins. No `COMING SOON` leaderboard sign remains.
- [ ] Two-client test: player A wins a round. Verify A moves up to first place with 1 Win/25 Coins and B has 0 Wins/5 Coins, given a fresh server/session.
- [ ] Have a player leave the server. Leaderboard should update and exclude absent players on the next state publish.
- [ ] Stop and restart the test server: board should reset to fresh session values, **not claim persistent/global scores**.
- [ ] Full 2-client match: selection, cracks, movement permissions, spectator access, finish and round-end UI work as before.
- [ ] Check client/server Output for runtime errors, including any SurfaceGui, SpawnLocation or leaderboard updates.

**Status:** Source and installer checks complete; Studio test pending.

## v0.9 — sign aspect-ratio fix: targeted regression

- [ ] Stop Play. Install the latest [one-paste Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau), which should print **v0.9 VERIFIED**; restart Play.
- [ ] Top HUD must visibly say **v0.9**, and Output should print `SERVER RUNNING v0.9` and `CLIENT RUNNING v0.9`.
- [ ] Stand directly in front of the **COSMETICS** sign in the same position as the owner's v0.8 screenshot. The heading should occupy a meaningful part of the board and look normal, **not extremely wide and flat or tiny**; the subtitle should be legible.
- [ ] Check the other two-sided boards: SHOP, REWARDS, LEADERBOARD, JOIN/WATCH, and FINISH.
- [ ] Walk around to see the back of a world sign. The text should keep normal proportions and join-board phase changes should update both sides.
- [ ] Start a match and verify crack markings, lane numbers and colored tiles remain readable.
- [ ] Confirm round-end winner/draw result appears in the small top HUD, with no centered popup.
- [ ] Verify gameplay is unchanged. Check Output for GUI or runtime errors.

The failure mode was specifically a **SurfaceGui CanvasSize aspect ratio mismatch**; v0.9 now sets `SizingMode = PixelsPerStud` explicitly instead of relying on defaults. Studio verification remains outstanding.

## v0.8 — verify which code actually runs BEFORE checking appearance

- [ ] Stop all Play and multiplayer sessions. Reopen the latest [installer](INSTALL_STUDIO_COMMAND_BAR.luau) on GitHub via Raw (hard refresh if needed) and execute it in Studio Edit mode.
- [ ] Output contains **`[Mythblox INSTALL] v0.8 VERIFIED`**, the paths to server/client scripts, and the number of old script/UI objects cleaned.
- [ ] Check Output for a warning listing other old Mythblox game scripts; if present, inspect their paths. Installer should disable old copies whose source matches the game's UI/world signature.
- [ ] Start a *new* Play session. HUD heading visibly starts **`v0.8`** (including during JOIN). Output shows **`SERVER RUNNING v0.8`** and **`CLIENT RUNNING v0.8`**.
- [ ] If HUD does **not** say v0.8 or the runtime log lines are missing, the updated scripts did not run: record Output and Explorer script names rather than concluding the visual changes failed.
- [ ] If HUD **does** say v0.8, confirm storefront labels use compact headings with small subtitles and no stretched text.
- [ ] Complete at least one round; confirm no center-screen `ROUND COMPLETE` overlay, and winner/draw status remains in the compact HUD.
- [ ] Check for red Output errors and duplicate Mythblox scripts in StarterPlayerScripts, StarterGui or ServerScriptService.
- [ ] Reconfirm one active bridge per joined racer, three-crack elimination, normal respawn and spectator access.

**Not yet verified in Roblox Studio.** Persistent bugs with an observed v0.8 marker should be escalated with a screenshot and exact Output log.

## v0.7 — fixed board lettering and no centered results popup

- [ ] Stop Play; install newest [installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode. Output says **v0.7 sign/results UI fixes installed**.
- [ ] Inspect SHOP, COSMETICS, REWARDS, LEADERBOARD and FINISH signs from the path at varying distances. Headings must not fill the entire sign or be stretched into giant letters.
- [ ] Confirm signs with a `COMING SOON` suffix have a **separate, smaller second line**, readable without overlap.
- [ ] Look at the join/spectator sign during JOIN, VOTE and RESULTS. Its physical size should stay unchanged while both front/back labels update.
- [ ] Complete a match and verify there is **no centered ROUND COMPLETE card** obscuring the world. Winner/draw text should appear only in the small top status area.
- [ ] Repeat a second round, ensure five-number selection UI and vote-reveal panel still behave correctly, and check character movement is unobstructed.
- [ ] Observe world signs near corners, at angles and on mobile-size windows; report clipping or unreadably small text for further tuning.
- [ ] Check client/server Output for exceptions involving `SurfaceGui`, `TextTruncate`, or result UI objects.

**Unverified:** This is a source update awaiting the owner's Roblox Studio test, not a claimed visual pass.

## v0.6 — join platform and information-display regression tests

- [ ] Stop Play, run the latest [installer](INSTALL_STUDIO_COMMAND_BAR.luau) from GitHub Raw in Edit mode and confirm `v0.6 join/HUD fixes installed` in Output.
- [ ] From spawn, verify that SHOP, COSMETICS, REWARDS, LEADERBOARD and FINISH signs are **fixed in the world**, not billboard overlays that cover the screen or overlap each other.
- [ ] Move close to and far from the shared join/watching deck. Its sign should remain reasonably sized at all distances and show `JOIN ROUND` during join and `WATCH MATCH` while racing.
- [ ] Walk around the gold join pad and the transitions to side promenades. Look for **flickering, white streaks, torn floor surfaces, overlapping panels or disappearing deck areas**; report a screenshot if any remains.
- [ ] Confirm that a **physical leaderboard near spawn exists**, while **no duplicate leaderboard HUD** appears in the top-right.
- [ ] Confirm top UI is a compact phase/timer/progress bar, instead of an oversized join banner. The vote buttons remain usable and legible.
- [ ] During a race, contestants see vote UI when voting, voting outcomes when revealed, and a clear GO/STAY warning during movement; large results cards do **not** block movement.
- [ ] Test with 3 clients: two racing, one on the shared platform. Spectator still observes but cannot enter the glass lanes even with shorter physical barrier.
- [ ] Test initial spawn and respawn; confirm the new deck height and signage do not block walkway movement.
- [ ] Test a full 2-client match; voting, cracks, movement, falls and wins are unchanged.
- [ ] Check client/server Output for errors involving `SurfaceGui`, boards, or UI layout and report exact output lines.

This checklist is **not yet passed**; screenshot-based diagnosis is a working hypothesis until the v0.6 world is tested.

## v0.5 island environment and spectator regression tests — source implemented, NOT yet verified

- [ ] Stop Play; run the latest [installer](INSTALL_STUDIO_COMMAND_BAR.luau) in the Command Bar while in Edit mode; Output confirms **v0.5 island hub installed**.
- [ ] Solo Play: spawn on a safe grassy island with a paved spawn plaza **at the start of the main path**. No repeated lava deaths; walk to deck.
- [ ] Verify the **leaderboard is near spawn**, decorative shops/cosmetics stand on **both sides** of the main path, and rewards area is nearby.
- [ ] Visit the **one shared Join/Ready + Front Spectator deck**: JOIN countdown and queue status appear. Use the in-world **E / ProximityPrompt** once; confirm joined status in the HUD.
- [ ] Start a round (solo Studio fallback or two queued clients). Shared deck sign now says **WATCH THE MATCH**; the deck itself is the same physical platform and is still freely walkable by spectators.
- [ ] Start **three clients**, join with only two, and leave one unqueued. Confirm the third can spectate from the shared deck/side walkways but cannot enter or block glass lanes.
- [ ] Deliberately try to jump over the front barrier and inner side guardrails. Spectators should not get onto a competitor's glass; check the server-side return-to-deck fallback if necessary.
- [ ] Fall during the round; after respawning, walk from spawn back to the shared deck. Do not autojoin a running match.
- [ ] Two contestants: exactly two glass bridges generated, and **one big FINISH arch** spanning them. Run a subsequent match with a different queue count and verify arch/lane widths update.
- [ ] Small numbered markers on start tiles replace the large floating player name labels; no visual obstruction from labels.
- [ ] Finish a match: player wins at tile 20, confetti appears at the arch, and the bridge model disappears for the next JOIN phase; hub/shopping/leaderboard structures persist.
- [ ] Recheck identical/different voting selections, MOVE/STAY, 3 cracks, forbidden steps, timeout, lava death, and win awarding. Original round timings must match v0.2.
- [ ] Review desktop and phone-size views: choices and controls remain usable; decks, stalls, trees, and signs do not block the camera or bridge visibility.
- [ ] Inspect both server/client Output for syntax and runtime errors, especially during the first server startup, prompt interaction, and respawn.

**Important:** All items above are unchecked pending a Studio engine test. 'Source implemented' is not a claim that the design has already passed real gameplay testing.

## World-layout acceptance checklist (designed; check after actual playtest)

- [ ] Spawn plaza is **the beginning of the main path**, with the **leaderboard near spawn** and shops/cosmetic stalls **on both sides of the path**.
- [ ] Only **one combined Join/Ready + Front Spectator platform** exists; during joining it shows ready status/countdown, while during active play the same platform lets players watch.
- [ ] Unqueued, late, or eliminated players can walk from spawn along the main path to the **shared viewing/ready platform**, and optionally onto side promenades, to observe the match.
- [ ] Nonparticipants cannot access/interfere with race glass; participants cannot shortcut through the viewing promenade.
- [ ] Finish arch is visually prominent and generated once regardless of racer count.
- [ ] Overhead player-name tags no longer dominate the field of view; lane identity remains understandable.
- [ ] Two-person Studio test and multiplayer regression: all v0.2 core mechanics still pass.
- [ ] Mobile view: shop and spectator signage do not obstruct movement, selection, or vote reveal.

See the [world-layout blueprint](WORLD_LAYOUT_BLUEPRINT.md). These boxes remain unchecked until code is implemented and retested.

## Bright theme v0.4 — visual review and regression

- [ ] Stop Play; rerun the latest [installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode. Output should say **v0.4 bright style installed**.
- [ ] Observe daylight/blue sky, green grass around orange lava, bright glass, cheerful lobby colors and white signs.
- [ ] Confirm light UI panels and legible dark text on both desktop and mobile-sized screens.
- [ ] Confirm the five choice buttons are blue with white numbers; selected choice is yellow with dark numbers.
- [ ] Confirm green/red feedback is legible and the shared finish label remains readable.
- [ ] Run a two-client match. Voting, three cracks, manual movement, falling, finish and respawn must behave exactly as before.
- [ ] Check both client/server Output for errors introduced by visual-only changes.

## Visual polish v0.3 — earlier regression checks (mechanics retained)

- [ ] Stop Play, rerun the **latest** [installer](INSTALL_STUDIO_COMMAND_BAR.luau) in the Command Bar (Edit mode). Verify the Output says **v0.3 installed**.
- [ ] Play: safe lobby appears with accent lights; no unused bridges during join.
- [ ] Join with two clients: exactly two glass lanes and only one FINISH sign, with neon accent rails **not acting as walkable paths**.
- [ ] Select numbers 5 and 3: both walk the expected maximum distances. Selection highlight is clear.
- [ ] Select identical numbers: both crack; their individual glass shows crack strokes and a small particle effect.
- [ ] Deliberately step onto forbidden glass: elimination and lava respawn still work.
- [ ] During vote reveal, confirm 1–5 vote counts, blocked numbers, and every player's name, selected number and outcome appear.
- [ ] Begin a **second match**: the reveal board refreshes for turn 1, with no stale names or totals from the first match.
- [ ] Confirm green safe tiles, red unsafe tiles, progress/round indicators, standings, and winner banner.
- [ ] Use Studio **Device Emulator** or a narrow client viewport: check tappable five-number buttons, visible text, no UI clipped offscreen, no covering critical gameplay controls.
- [ ] Check **Output** in both server and client for red exceptions or warnings related to GUI, Lighting, particle, or SurfaceGui properties.

**Visual pass alone is not gameplay certification:** still test 2–8 players, late joins, crash/rejoin behavior, mobile controls, and performance before publication.

## Setup

- Open a clean Baseplate place.
- Install the prototype from [INSTALL_STUDIO_COMMAND_BAR.luau](INSTALL_STUDIO_COMMAND_BAR.luau).
- Open **Output** while testing.
- Test single-player first; then **Server & Clients** with two players, then four if possible.
- This prototype intentionally does not have durable coins or Robux purchases.

## Acceptance tests

| # | Action | Expected result |
|---|---|---|
| 1 | Press Play once in Studio | A safe elevated lobby and lava appear; **no glass lanes** until players finish joining; no startup errors |
| 2 | Solo Studio: press JOIN | A solo-practice match begins after 10 seconds |
| 3 | Test with 2 clients; both press JOIN | Both receive separate lanes |
| 4 | A chooses 5; B chooses 3 | Both may walk, A up to 5 tiles and B up to 3 |
| 5 | A and B choose 5 | Both stay; each receives 1 crack |
| 6 | Repeat collision 3 times | Their current panels break and players fall; draw if both eliminated |
| 7 | A chooses 5; B chooses 5; A steps forward | A's forbidden next tile shatters and A falls |
| 8 | A picks a safe number but does not move | Their starting/old tile breaks at the next vote phase and A falls |
| 9 | A picks 4 and manually steps 2 tiles | A keeps 2 tiles of progress, not 4, at round end |
| 10 | A picks 2 and attempts tile 3 | Unauthorized tile shatters and A falls |
| 11 | One player is eliminated and one remains | Remaining player wins; results display |
| 12 | A reaches tile 20 before B | A wins |
| 13 | Join late, after voting begins | Late player spectates/waits and can join next countdown |
| 14 | Join when all 8 slots are filled | Additional players wait for next match |
| 15 | Quit/disconnect while playing | Match safely continues; sole survivor wins where applicable |
| 16 | Reset character while playing | Player is eliminated, not granted free progress |
| 17 | On-screen buttons on a phone-sized viewport | All 5 choices and join button are readable/tappable |
| 18 | Valid participation/first-place | Session Coins/Wins update, with no Roblox purchases |
| 19 | Cross to another lane / try jumping | Cannot legitimately gain progress in another lane |
| 20 | End of test | No unhandled errors in Studio Output |

## Fix regression checklist (v0.2)

| # | Regression check | Expected |
|---|---|---|
| 21 | Join first time, then die and respawn | Alive in safe raised lobby; no repeated lava deaths |
| 22 | Join countdown with 0 or 1/2 queued players | No unused glass lanes visible during countdown |
| 23 | Start match with 2 queued players | Only 2 lanes are generated |
| 24 | Complete match / return to join | Lanes disappear until next match starts |
| 25 | View bridge end with 2–8 players | Only one shared FINISH banner |
| 26 | Vote 1–5 with differing selections | Reveal shows all vote totals, names, picks, and MOVE N |
| 27 | Most popular number gets 2+ picks | Reveal marks it BLOCKED and shows CRACK to affected players |
| 28 | All vote uniquely | No numbers blocked, everyone eligible to advance their chosen distance |
| 29 | Inspect small/mobile viewport | Reveal remains readable and doesn't prevent movement |
| 30 | Check Output, both client and server | No red runtime errors introduced by the new build |

## Visual polish — staged follow-ups (after v0.3 test)

- Evaluate v0.3 vote-result readability; refine based on real desktop/mobile screenshots.
- Verify touch/mobile screen layout, including default Roblox on-screen controls.
- Tune crack particles, glass contrast, optional ambient sounds, camera feel and finish celebration after testing.
- Do not modify gameplay rules solely for cosmetic redesign.

## Balance questions to answer in playtests

- Are most players repeatedly choosing 5?
- Is it fun to wait after an unsafe choice, or boring?
- Does the rule about *must move at least one step* feel fair?
- Are six seconds enough on mobile, including latency?
- Are three cracks too harsh when illegal steps already kill immediately?
- Does the first-to-finish rule produce readable race moments?
- Does a 20-tile bridge resolve too fast with 2 players or too slowly with 8?
- Do ties cause too many simultaneous eliminations?

## Reporting bugs

Record the **test #, player count, selected numbers, what happened, what should have happened, and the exact Output message**. Do not add a shop until basic 2-client tests pass.

## Security and release readiness

The MVP uses server-side voting and movement permission checks. It is **not a guarantee of anti-cheat robustness**. Production release requires testing extreme lag, movement exploits, character respawning, purchases, datastore error handling, and moderation/audience settings.
