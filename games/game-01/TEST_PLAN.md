# Game 01 — Studio Test Plan (Prototype)

**Status (2026-11-22):** Owner reports **both bugs persist** despite prior code changes. Since v0.7 GitHub code no longer has a centered result card, a stale/duplicate running Studio script is a credible possibility, not yet proven. **v0.8 adds verified clean installation, server/client version logs and a visible build marker. Studio test pending.**

## Playtest log

| Date | Environment | Result | Remaining validation |
|---|---|---|---|
| 2026-11-21 | Roblox Studio, 1 client (user-reported), v0.1 | Installer worked; solo gameplay matched expectations under several unspecified conditions | Specific checklist cases not enumerated |
| 2026-11-21 | Roblox Studio, multiple players (user-reported), v0.1 | Multiplayer worked across multiple unspecified conditions | Reported bugs: initial/respawn near lava, repeated FINISH signs, fixed 8 bridges during join, missing vote breakdown UI |
| 2026-11-21 | GitHub v0.2 (owner-confirmed functional) | Owner reports revised game functions work | Improve UI later; perform mobile, performance, exploit and release QA separately |

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
