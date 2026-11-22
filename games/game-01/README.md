# Game 01 — Glass Bridge Voting Race (Prototype)

**Status (2026-11-22):** Owner confirms **v0.14 cosmetics shop works in Roblox Studio** and earlier v0.13 coins persisted. **v0.15 reliability hardening is committed, not yet tested in Studio**. The owner explicitly states the current prototype is **not pretty or feature-rich enough to launch**; a substantial feature expansion and major art overhaul must follow reliability testing, before any public release. The game is unnamed and private.  
**Final game title:** Not chosen. `game-01` is an internal folder name only.  
**Umbrella project:** Mythblox.

## Play loop

Every player chooses a number from a fixed row of **1–5**. The most popular choice (if selected by at least two players) is blocked. If two choices are tied for the highest count of two or more, **both are blocked**. If everyone chooses different numbers, everyone is safe.

- **Safe number:** manually walk **1–N glass tiles** during the six-second movement window, where N is the selected number.
- **Blocked number:** gain one crack and **stay on your current panel**. Your next panel is red; attempting to move onto it shatters it and makes you fall.
- **No vote:** receive a crack and stay.
- **Failed to move:** if your choice was safe but you remain on your old tile when the movement window closes, that tile shatters and you fall.
- **Three cracks:** your glass shatters and you are eliminated.
- **Winner:** first player to reach tile 20, or last surviving player. If all are eliminated, draw. On a turn limit, the surviving player farthest ahead wins (shared win if tied).

**Movement is never automatic.** The next eligible panels glow green. Glass behind an advancing player disappears after the movement window.

## Initial settings

| Setting | Prototype value |
|---|---|
| Ready/join countdown | 10 seconds |
| Match player cap | 8 |
| Minimum live players | 2 (single-player practice allowed only in Studio) |
| Vote window | 5 seconds |
| Reveal | 2 seconds |
| Walk/stay window | 6 seconds |
| Number buttons | Always 1–5 |
| Length of each personal bridge | 20 advanceable panels |
| Strike threshold | 3 cracks |
| Server round safety cap | 22 votes |
| Reward | Win +25 coins, participation +5 coins |

**Progress storage:** Wins and coins were session-only through v0.12. **v0.13 introduces DataStore persistence**, pending Roblox Studio and published-server verification. v0.14 adds a coin-only cosmetics stall (no Robux or paid items). Do not publicly launch or monetize before testing data recovery and purchases.

## v0.15 — reliability checkpoint, NOT a launch candidate

The owner approved a multiplayer/mobile/reliability pass, while explicitly requiring **a lot more features and significantly better visuals before public launch**. See the [pre-launch roadmap](PRELAUNCH_ROADMAP.md); technical QA alone does **not** make Game 01 ready to release.

- Implemented conservative per-player rate limiting for repeated `Sync`, `Join`, `Vote` and `Shop` remote commands, plus duplicate `Browse colors` proximity-prompt triggers. Normal clicking and changing a vote remain permitted; invalid/unknown remote actions are rejected immediately. Throttle state is cleared on player leave.
- No world, shop prices, cosmetic colors, gameplay phases, voting, movement, cracks, number of tiles or match rewards changed.
- One-paste installer now labels **v0.15** and correctly states that earned coins/wins and coin-only cosmetics use DataStore.
- Source/installer checks done; **real Studio multiplayer, mobile, private-server and save tests remain outstanding**.

**Install:** Stop Play and run the latest [Studio Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode, then confirm `v0.15 VERIFIED` in Output and `v0.15` in the Play HUD. Follow the [v0.15 test checklist](TEST_PLAN.md).

## v0.14 — glass-color cosmetics stall (owner-confirmed working in Studio)

The already-built **COSMETICS** stall on the right side of the hub is now a small interactive shop. No new always-on shop HUD button or unrelated gameplay mechanic was added.

- Approach the **COSMETICS / GLASS COLORS** stall, then press **E** or use the mobile proximity prompt. A compact, closable, scrollable panel displays four choices.
- **Classic Blue:** free, available to everyone. **Candy Pink:** 20 earned coins. **Mint Pop:** 40 coins. **Soft Violet:** 60 coins. Purchases permanently unlock a color; owned colors can be equipped again without paying.
- A skin tints only a player's **neutral personal bridge glass**. GREEN still means movement is permitted, RED still means blocked/danger, cracks still show amber/red, and the winning tile remains gold. No advantage or new player movement rules.
- Spending, ownership, equipped choice, and earned rewards share the **same existing v0.13 DataStore profile**—no wipe or new database. The server alone chooses prices and checks balance, player proximity, ownership, and storage readiness. A single atomic `UpdateAsync` deducts coins and records an item. Retry tokens and per-player locks guard duplicate requests.
- When DataStore loads fail, purchasing is unavailable instead of silently granting items or overwriting saved progress. If a shop write cannot be confirmed, players must rejoin to refresh before another purchase is permitted.
- **Test in Studio:** Install the new [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode, start Play, look for **v0.14**, buy a color, stop Play and start again. Confirm the color stays owned/equipped and coins are deducted **exactly once**. Check the guide in [TEST_PLAN.md](TEST_PLAN.md).
- **Owner test:** v0.14 was reported working in Roblox Studio. Individual checks of coin deductions, owned skins after restart, mobile layout, saved Wins, and private published-server persistence were not separately reported. No Robux products or game passes have been added.

## v0.13 — persistent wins and coins (coins tested in Studio)

Wins and coins now have a dedicated server-side DataStore persistence layer, **without changing the gameplay or adding an unnecessary HUD indicator**.

- On join, the server loads the player's saved Wins and Coins. Missing profiles start at zero. Historical session-only v0.12 stats cannot be recovered.
- Every earned reward is tracked as a server-side **increment**, not as a replacement for the saved balance. `UpdateAsync` merges it with the latest stored totals to handle rapid reconnects and overlapping servers; recently applied save IDs prevent retry double-counting.
- A player's stats autosave about every 150 seconds (jittered), on exit, and at server shutdown. Requests have bounded retries. If loading fails, **nothing is written for that session**, avoiding destructive zero-value overwrites.
- Studio and published servers intentionally use **different stores**; testing won't modify live saved totals. The client never chooses reward amounts or accesses DataStore APIs.
- No coins can be spent yet; adding the cosmetic shop will require server-validated **atomic deductions**.
- **Studio setup required:** Privately publish the Roblox experience (if not already) and enable **File → Experience Settings → Security → Enable Studio Access to API Services**. A local `.rbxl` backup alone does not activate online data saving.
- **Installation:** Run [the latest Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode and check Output for `v0.13 VERIFIED`; Play should show `v0.13`. **Saving has not yet been verified in Studio.**

See the [step-by-step persistence test guide](PERSISTENCE_TEST_GUIDE.md) before judging whether stats actually survive restarting a test server.

## v0.12 — gameplay feedback and sound cues (owner-confirmed working)

Approved after v0.11 was confirmed working. Focus: make the existing game rules feel responsive and entertaining, **without a new mechanic or redesigned world**.

**What's implemented:**
- Subtle built-in Roblox sound cues for choosing a number, the last three seconds of secret voting, a safe pick, a cracked pick, falling, and winning. Sounds use `rbxasset://sounds/...` paths, no purchased or third-party audio. **Roblox Studio playback of these files is not yet verified.**
- Quick blue/yellow selection emphasis and a red-tinged countdown panel during the last two voting seconds.
- A brief **nonmodal** green/red feedback chip **below the top HUD** when your selected number is safe, blocked, when walking begins, or when you fall. It hides automatically after about a second; on narrow/mobile-size displays it is hidden entirely. **No centered round-complete popup** was reintroduced.
- Vote-reveal rows highlight **your own** selection by Roblox UserId, so duplicate display names do not confuse the result. The server still hides all choices during the vote.
- During movement, the compact top HUD lists blocked number(s) in addition to the existing green GO/red STAY warning.
- More visible but short-lived glass-break particles and a handful of small noncolliding glass fragments on dramatic falls; routine tile cleanup remains lightweight.
- The finish confetti now triggers for any legitimate match win (including **last-survivor and furthest-ahead** wins), not just when someone reaches the final tile.

**Not changed:** five fixed choices, most-popular collision logic, 3 cracks, manual 1–N tile movement, 20-tile bridge, 10-second join, 5-second vote, 2-second reveal, 6-second movement, round result timing, cosmetics placeholders and temporary rewards.

**Install:** Stop Play in Roblox Studio and run the latest [Studio Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) while in Edit mode. It will replace the existing Mythblox scripts. Confirm Output prints **v0.12 VERIFIED** and the game HUD shows **v0.12**.

**Checkpoint:** Owner reports v0.12 gameplay works after Studio testing. Individual regression cases were not enumerated; deeper multiplayer, mobile, audio and release QA remain outstanding. **Next planned phase:** persistent coins and wins, subject to reconfirmation when development resumes.

## v0.11 — four environment fixes (awaiting Studio test)

Owner approved four targeted changes after reviewing v0.10 screenshots. **No game rules were changed.**

- **Finish:** Replaced the bulky, multicolored, stacked arch with a simple two-blue-pillar white FINISH beam and a compact checker strip on each last glass tile. One integrated sign, no floating sign above the gate, no side flags.
- **Glass edges:** Recalculated decorative bridge rails to end exactly at tile edges. Aligned the front spectator barrier to the ready deck and shortened/repositioned the inner/outer promenade barriers to meet their walkway ends without protrusions. Maintained server-side spectator boundary checks.
- **Leaderboard:** Reduced physical size, moved support post behind the board, and put the data on **one face only**, facing arrivals from the spawn plaza. Only `TOP RACERS` and player wins/coins rows remain. Removed `THIS SERVER ONLY` and `Resets when server closes` from the display. Scores **remain current-server-only and temporary**, regardless of the stripped-down presentation.
- **Island edge:** Added brown soil and stone layers beneath the grassy hub to avoid a flat grass slab from bridge views. Replaced the low gray/green backdrop with a blue, noncolliding sea plane. Neither changes player progress or lane geometry.

Install the newest [Studio Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in **Edit mode**, then start Play and confirm the HUD shows **v0.11**. Check the finish from the last tile, the leaderboard from spawn, barrier ends from both promenades, and the island silhouette looking back from the bridge. A new Studio test is required before visual signoff.

## v0.10 — clean spawning and current-server leaderboard (Studio test pending)

Owner's v0.9 screenshot revealed the **original default Baseplate SpawnLocation**, still visible beneath the lava. This isn't the raised Mythblox spawn the gameplay uses; the old default remains in the source place from creating a Baseplate template.

**Changes in v0.10:**
- The Studio **Command Bar installer removes the default low-altitude `SpawnLocation`** near world origin (only if its name is exactly `SpawnLocation` and it is close to (0,0,0)); it preserves custom spawns away from that location. This removes the unused marker **from Edit mode** as well as future Play sessions.
- The server also cleans that same leftover spawn at runtime if a place is initialized through Rojo/manual script installs rather than the Command Bar. New participants and respawned players still use `MythbloxLobbySpawn` on the elevated island.
- The existing physical leaderboard near spawn is now **functional for the current server only**. It shows up to four players sorted by Wins then Coins, on both sides of a readable light board. It refreshes with the server's match-state updates.
- The leaderboard explicitly says **THIS SERVER ONLY** and **Resets when server closes**. It does **not** save to a DataStore or show cross-server/global rankings. Cosmetic shops/rewards remain placeholders.
- No core gameplay, match timing, voting rules, damage, movement, spectating, or winner reward amounts were changed.

**Install:** Stop Play, open [the latest installer](INSTALL_STUDIO_COMMAND_BAR.luau) in GitHub, choose Raw, copy the **entire** file and run it via the **Command Bar in Studio Edit mode**. Confirm Output shows `v0.10 VERIFIED` and the count of unused Baseplate spawns removed. The top HUD should show `v0.10` when Play starts.

**Test:** Confirm the white Roblox default spawn star/platform is gone from beneath the lava in both Edit and Play; join/die/respawn twice and verify the island spawn; earn wins/coins in a two-client match and verify the leaderboard reflects real current-server totals. **Unverified in Studio so far.**

## v0.9 — correct SurfaceGui canvas proportions (needs Studio confirmation)

The owner supplied a v0.8 screenshot showing the game **really was running v0.8**, but board labels were still squashed into tiny, horizontally distorted text. After checking Roblox's API/reference history, the root problem was identified: **SurfaceGui's default sizing can be `FixedSize` (an 800×600 virtual canvas)**. Our sign creator set `PixelsPerStud` but **never set `SizingMode`**, so its wide, shallow 3D Parts inherited an incorrect canvas aspect ratio and stretched the labels. Font-only adjustments in v0.6–v0.8 could not solve that.

**v0.9 fixes:**
- Explicit `surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud` for **both faces** of every dynamically created shop, leaderboard, join, reward and finish sign.
- Sets larger but bounded `TextSize` values now that text maps to the real surface dimensions (headings 44 or 54; dynamic join sign 37; subtitle 26 at 48 pixels/stud).
- Uses explicit PixelsPerStud mode for the start-lane markers and crack overlays too.
- Keeps no centered results popup, and retains the compact top match status strip; visible build marker now says **v0.9**.
- All rules, shops, layout, wins, join and rewards unchanged.

**Test:** Reinstall [the current installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Studio Edit mode, verify `v0.9` appears in HUD, and look at COSMETICS / SHOP from the same location as the previous screenshot. The text should no longer be horizontally stretched or postage-stamp small. Please report if any sign still looks wrong; we have not executed this build in Studio.

## v0.8 — verified clean install and runtime version indicator (Studio test pending)

**Why:** After v0.7, the owner still sees both giant/distorted signs and a centered `ROUND COMPLETE` popup. GitHub v0.7 client code already omits that popup, so the first step is to **prove Studio actually runs the updated scripts**, not just edit them again.

**Changes:**
- The Command Bar installer now removes **all scripts named `MythbloxGame`** in the relevant Studio services, not only the first matching child. It also removes a stale `MythbloxGame01UI` object from StarterGui.
- Installer additionally scans for **other Script/LocalScript copies** containing old Mythblox UI/world source signatures and **disables** those duplicates (preserves their contents). This is targeted at our own previous game scripts and will not disable unrelated scripts.
- The installer performs **exact `Source` verification**, prints cleaned/disabled counts and the installed script paths, then instructs the owner to start a fresh Play session.
- Server creates `ReplicatedStorage.MythbloxGame01.BuildVersion` and prints `SERVER RUNNING v0.8`; client checks the version and prints `CLIENT RUNNING v0.8`.
- The top HUD now visibly starts with **`v0.8`** on JOIN, VOTE, MOVE and RESULTS. If the marker is absent, the new LocalScript did not run.
- The game client clears duplicate `MythbloxGame01UI` screens at startup. World signs and lane numbers have **no `TextScaled = true`**, and shop fonts/boards were reduced further.
- Center-screen results popup remains absent; winner/draw message is only in the **top status strip**. All approved game rules and geometry stay unchanged.

**Upgrade instructions:**
1. Stop **all** Play/Server & Clients sessions (Edit mode).
2. Open the latest [installer](INSTALL_STUDIO_COMMAND_BAR.luau) in GitHub, refresh the page, click **Raw**, copy the **entire** script (not a previous Command Bar copy), paste into Command Bar and run.
3. In Output, look for **`[Mythblox INSTALL] v0.8 VERIFIED`**, cleaned duplicate counts and both installed paths.
4. Start a **new** Play session. The top status strip must visibly say **`v0.8`**; Output should contain **`SERVER RUNNING v0.8`** and **`CLIENT RUNNING v0.8`**. If not, do not assess the visuals yet: the new code was not loaded.
5. Once the build is confirmed, inspect a shop sign and complete a round. If a centered popup still appears or shop text remains distorted, capture the running `v0.8` marker and Output for further diagnosis.

**Safety:** The installer replaces/cleans previous Mythblox scripts and disables other scripts containing its old UI/world signatures; if you've manually customized those prior versions, save them first. The v0.8 engine behavior is **not yet verified**.

## v0.7 — properly sized signs and nonblocking results (Studio retest pending)

Owner screenshot of v0.6 showed that `TextScaled = true` enlarged storefront lettering to fill its `SurfaceGui` signboard, producing distorted, oversized text. The center-screen `ROUND COMPLETE` overlay also blocked the view at the end of every match.

**Changes made:**
- World signs now use **fixed font sizes**, no TextScaled and no automatic wrapping. Dimensions are reduced slightly; text can truncate instead of becoming huge.
- Storefronts and leaderboards use **two levels**: `COSMETICS` / `COMING SOON`, etc., with a smaller secondary line.
- Shop, finish, deck and reward signs retain **two-sided** readable world boards; the deck's live status still updates both faces.
- Removed the centered `ROUND COMPLETE` result card entirely. During `RESULTS`, the compact top HUD shows **ROUND OVER** and the existing server-sent winner/draw message.
- No change to selected-number rules, movement permissions, cracks, lava, spawn, shop placeholders, dynamic bridge counts, or winning/rewards.

**Installation:** Stop Play, open the latest [Studio Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau), choose Raw, copy everything and Run while in Edit mode. Output should say **v0.7 sign/results UI fixes installed**.

**Engine verification:** v0.7 is not tested in Studio yet; inspect boards from close and far away, complete one round to see the result without a centered popup, and check Output.

## v0.6 — join-area readability and streamlined HUD (Studio test pending)

Owner screenshot of v0.5 highlighted unnecessary overlay clutter and what appears to be visual flicker/overlap near the shared join/spectator platform.

**v0.6 changes:**
- Replaced `BillboardGui` / `AlwaysOnTop` floating signs with fixed-size **physical two-sided signboards**, using `SurfaceGui` attached to real Parts. Join, shop, leaderboard, rewards and finish signage remains in the world and can be read from either side.
- Reduced excessive white overlays and sign overlap; shortens the phase-driven shared-deck sign messages.
- Raised the shared spectator deck and side walkways slightly above the grass to eliminate **coplanar overlapping surfaces** (a likely cause of visual flicker, pending Studio confirmation).
- Reduced the large front and side spectator glass barriers to shorter, less intrusive translucent safety railings. Server spectator isolation and the race/glass boundaries remain intact.
- Removed the extra on-screen HUD leaderboard; the designated world leaderboard remains near the spawn plaza.
- Replaced the tall screen HUD with a **small top match-status strip** for phase, timer and personal progress. The JOIN screen says **NEXT MATCH**, not a duplicate large "JOIN THE ROUND" message.
- During walking, active contestants see their movement warning and unobstructed course, while spectator clients can still view the voting breakdown.
- All five selection buttons, voting/three-crack rules, match times, manual movement, dynamic lanes, join prompt, rewards and winning remain unchanged.

**Test:** Reinstall [the latest Studio Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode (Output reports **v0.6 join/HUD fixes installed**). Verify from both spawn and spectator-view angles, including when walking near the gold ready pad. v0.6 code has not been tested in the Roblox engine.

## v0.5 — social island and spectator hub (source implemented; Studio retest pending)

The owner supplied three bright Roblox lobby/mini-game screenshots and approved a **compact social island** with a combined Join/Ready + Front Spectator platform, shops beside the main path, leaderboard by spawn, and a more appealing finish arch.

**Implemented in v0.5:**
- Permanent, walkable grass hub island and spawn plaza at the start of a cream-colored central path.
- **One shared Join/Ready / front spectator deck**. Its message shows the queue/countdown during JOIN, and changes to **WATCH THE MATCH** during active turns. The deck itself never disappears.
- **Two optional side viewing promenades** with solid walkways and safety railings; a server-side bounds check returns unauthorized spectators to the shared deck if they reach live race glass.
- A clickable in-world **ProximityPrompt join pad**, using the same server-validated queue as the existing on-screen JOIN button.
- **Two future shops** flanking the central path, plus a nearby leaderboard placeholder and a rewards corner beside the spawn plaza. These are decorative and **do not sell anything or display invented global rankings**.
- Small procedural blocky trees and bushes around the edges.
- **One colorful FINISH arch** spanning the generated bridge count, checker accents, flags and a brief finish particle burst.
- Removed oversized floating player-name tags in favor of small lane numbers printed on the start tiles.
- Existing bridge generation still creates exactly one lane for each joined player **after** the join countdown.

**Unchanged:** five-choice voting, popularity collisions, three-crack elimination, 20-tile length, manual 1–N movement, timer windows, winning rules, and temporary session-only rewards.

**Install/test:** Stop Play, open [the current Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) on GitHub, copy the **Raw** contents, and execute in Roblox Studio Edit mode. Output should say **v0.5 island hub installed**. The two existing `MythbloxGame` scripts are replaced. This code **has not been verified in Studio**; test with one, two, and three clients (one spectating) before considering the environment complete.

[Approved spatial blueprint](WORLD_LAYOUT_BLUEPRINT.md) · [v0.5 test checklist](TEST_PLAN.md)

## v0.4 — bright Roblox-style visual revision (requires fresh install)

User feedback on v0.3: the neon/dusk appearance was too dark and did not match the familiar bright Roblox aesthetic.

**v0.4 changes (visual-only):**
- Sunny daytime with bright blue sky/fog and a grassy green area around the orange lava.
- Light-blue transparent glass bridges, cheerful blue rails, bright yellow finish accents, a blue lobby, and clean white in-world signs.
- White UI cards with dark text, bright blue number buttons, green JOIN button, yellow selection highlight, and light green/red movement notices.
- Preserves the v0.3 vote-tally, player results, progress, responsive layout, and crack effects.
- Leaves all v0.2 tested gameplay rules, timings, movement logic, and purchasing behavior unchanged.

**Retest needed:** Install the latest [one-paste Studio installer](INSTALL_STUDIO_COMMAND_BAR.luau) while not playing, then verify the brighter look in Play and with two clients. The installer replaces both scripts named `MythbloxGame`.

## v0.3 — earlier visual polish pass (superseded dark theme)

These changes are **presentation only**: no voting, crack, movement, winning, or reward rules were intentionally changed.

- **Arena atmosphere:** darker dusk lighting, glowing side rails under the glass, subtle lobby accent stripes, and glowing finish posts. Rails and decorations have collision disabled.
- **Cracks and breakage:** glass now displays procedural crack strokes and particles for important eliminations, with simple fading for routine old-tile removal.
- **Responsive HUD:** improved typography, high-contrast status/turn countdown, distance progress indicator, and desktop leaderboard. A compact layout applies to narrower windows.
- **Voting tray:** five large consistent buttons with a visible selected number.
- **Reveal/results:** five vote-count tiles, clear blocked numbers, individual player picks and MOVE/CRACK/OUT results, plus a larger winner card.
- **Mobile considerations:** smaller layout hides the full breakdown during the walking phase to keep room for controls; it remains visible during the reveal. Further mobile testing is required.

**Installation:** Stop Play; run the latest [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode. It replaces the two `MythbloxGame` scripts, but **does not delete or overwrite other custom scripts**. If you modified either script by hand, make a copy first.

**Verification:** all source files and generated installer should match, but no Roblox Studio engine test has been run for v0.3. Recheck a 2-client match before building more features.

## v0.2 — feedback fixes (already tested)

- **Spawning/respawning:** sets `Player.RespawnLocation` to the elevated Mythblox lobby, moves the lobby away from the lava, and adds guard rails so players do not spawn/die in the lava under the Baseplate's original spawn point.
- **Correct lane count:** the glass lanes are generated **only after the 10-second ready window closes**. Exactly one lane is built for each match participant (1 for Studio solo practice, 2–8 for multiplayer). The old lanes are removed before the next join period.
- **Shared FINISH:** there is just **one shared finish banner** at the end of the bridges, not one text sign per player.
- **Vote reveal:** after the secret vote, a compact overlay shows the total number of votes for **1–5**, the blocked number(s), and **each player's chosen number and outcome** (move up to N, crack, no vote, or out) during reveal, walking and results.

The underlying selection, crack, walking and winner rules are unchanged. **Owner subsequently confirmed v0.2 functionality works.** UI improvements remain deferred.

## Quick start — easiest, no extra tools

1. Open Roblox Studio and create/open a **new Baseplate place**, in **Edit mode** (not Play).
2. Open **Script → Command Bar** (or **Window → Script → Command Bar**, depending on Studio layout).
3. Open the **latest** [INSTALL_STUDIO_COMMAND_BAR.luau](INSTALL_STUDIO_COMMAND_BAR.luau) on GitHub, choose **Raw**, copy the entire file, paste it into Studio's **Command Bar**, and execute it once. **Stop Play first.** If v0.1 is already installed, the installer safely replaces the two scripts named `MythbloxGame` (custom edits to those scripts will be overwritten).
4. Check that a `MythbloxGame` server Script exists under `ServerScriptService`, and a `MythbloxGame` LocalScript exists under `StarterPlayer > StarterPlayerScripts`.
5. Click **Play**. The script generates the safe lobby and lava initially, then creates **only as many lanes as there are joined players** after the countdown. For multiplayer testing, use **Test → Server & Clients**, choose **2 clients** and start the test.
6. On each client, press **JOIN NEXT MATCH** before the 10-second join countdown ends. Secretly choose a number from 1–5, then physically walk on green glass (or remain still if your number is blocked).

The installer installs **scripts**; the arena is generated when a test session starts, so it is normal not to see all glass in Studio Edit mode. It also replaces existing scripts **named `MythbloxGame`** in those two specific services; save or rename prior customizations before rerunning.

> **Important:** This chat can write code to GitHub, but it cannot control your currently open Roblox Studio app. You need to run the installer and test locally. The code has not been executed by Roblox yet.

### Test single-player

Normal live games require two willing players. Studio has a **solo practice fallback** so Play can confirm the UI, walking and finish behavior without a second client. That solo fallback does not change the live multiplayer minimum.

### If the installer errors

- Make sure you are running it in the Studio **Command Bar**, not a normal Script during Play.
- Confirm the full file was copied and no part was truncated.
- Open **Window/Script → Output** to capture the exact error and its line number.
- If you prefer not to use the installer, copy the two source files manually into the corresponding Script and LocalScript containers.

## Source-control structure

```text
games/game-01/
├── README.md
├── TEST_PLAN.md
├── INSTALL_STUDIO_COMMAND_BAR.luau  # Paste into Studio Command Bar
├── default.project.json            # Optional Rojo sync
└── src/
    ├── ServerScriptService/
    │   └── MythbloxGame.server.luau
    └── StarterPlayer/
        └── StarterPlayerScripts/
            └── MythbloxGame.client.luau
```

The two `src/` files are authoritative for editing. The installer is a snapshot embedding both scripts and must be **regenerated when the source changes**.

## Optional future workflow: Rojo

For repeat development, clone `Mythrow/Mythblox`, install [Rojo](https://rojo.space/docs/v7/), and run Rojo from `games/game-01/` with `default.project.json`. Connect Rojo's Studio plugin to sync the server and client scripts. Rojo is **optional** for the first test because the one-paste Command Bar installer is simpler. Never use the installer and Rojo sync simultaneously without understanding which version wins.

## What remains before public launch

- **Mandatory expanded features** and a **major visual/art-quality overhaul**, with the exact feature scope and art direction to be approved by the owner.
- Final game name, distinctive branding, icon, thumbnails, description and attractive public screenshots.
- Robust 2–8-player multiplayer, mobile/tablet layout, security, performance and data-loss regression verification.
- Verified persistent Wins, owned cosmetics, equipment and purchase deductions in private published-server tests, not just Studio.
- More complete production-level exploit, moderation, accessibility/audience and release checks.

See the [pre-launch roadmap](PRELAUNCH_ROADMAP.md). Cosmetic stall, sound effects, glass fragments and basic DataStore saving **already exist**; these are not missing features.

## Next step

**Test v0.15's reliability fixes in Roblox Studio** using [TEST_PLAN.md](TEST_PLAN.md), then agree on the next expanded feature set and visual direction. The current prototype is **not launch-ready** and is not to be released merely because tests pass. The baseline 1–5 glass-bridge voting game rules remain unchanged.

See [the Mythblox game-design memo](../../docs/FIRST_GAME_GLASS_BRIDGE_CONCEPT.md) for earlier alternatives, including the spinner idea that was explicitly deferred.
