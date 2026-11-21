# Game 01 — Glass Bridge Voting Race (Prototype)

**Status (2026-11-21):** Owner confirmed v0.2 gameplay works in Roblox Studio. **v0.5 social-island environment** is implemented in source and Studio installer, but **has not been run in Roblox Studio yet**. The game remains unnamed and unpublished.  
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

**Rewards are session-only in v0.1.** There is no DataStore persistence, no purchasable items, and no paid power-ups. Do not publish this as a monetized finished game without playtests and a reviewed commerce implementation.

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

## What is deliberately missing

- Final game name, branding and polished map art
- Session-to-session data saving
- Shop, cosmetics, passes or developer products
- Sound design and advanced glass-fragment visual effects
- Robust production-level anti-exploit/movement validation
- Real mobile playtests and server/load measurements

## Next step

Functional prototype v0.2 was confirmed by the owner. **Next: retest v0.5 island, join/spectator deck, side viewing, shops, finish arch, and unchanged game mechanics** using [TEST_PLAN.md](TEST_PLAN.md). Review mobile controls and map sightlines before considering persistence and cosmetics. Validate whether **5-second selection / 6-second walking / 20 tiles / 3 cracks** is enjoyable before adding features.

See [the Mythblox game-design memo](../../docs/FIRST_GAME_GLASS_BRIDGE_CONCEPT.md) for earlier alternatives, including the spinner idea that was explicitly deferred.
