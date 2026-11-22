# Game 01 — Glass Bridge Voting Race (Prototype)

**Status (2026-11-22):** **v0.25** applies the owner-approved extra clouds and matte platform pass: noticeably fuller cloud coverage, deeper weathered-oat stone on the main plaza and spectator decks, subdued planters/stone supports, and a hidden bright spawn marker. The v0.24 neutral daylight, 49px mobile HUD, voting, free movement, glass shatter, shop, and v0.23 reward saving remain unchanged. **Roblox Studio and actual-phone visual QA still pending. Not launch-ready.**  
**Final game title:** Not chosen. `game-01` is an internal folder name only.  
**Umbrella project:** Mythblox.

## Play loop

Every player chooses a number from a fixed row of **1–5**. The most popular choice (if selected by at least two players) is blocked. If two choices are tied for the highest count of two or more, **both are blocked**. If everyone chooses different numbers, everyone is safe.

- **Safe number:** manually walk **1–N glass tiles** during the six-second movement window, where N is the selected number.
- **Blocked number:** gain one crack and **do not advance to another panel**. The glass stays its neutral cosmetic color; attempting a forbidden forward step still shatters glass and eliminates you.
- **No vote:** receive a crack and stay.
- **Failed to move:** if your choice was safe but you remain on your old tile when the movement window closes, that tile shatters and you fall.
- **Three cracks:** your glass shatters and you are eliminated.
- **Winner:** first player to reach tile 20, or last surviving player. If all are eliminated, draw. On a turn limit, the surviving player farthest ahead wins (shared win if tied).

**Movement is never automatic.** You may **walk and jump at all times**, including VOTE and REVEAL. Your next tiles **do not glow green/red**: infer your allowed distance from the number reveal and the compact GO/NO ADVANCE HUD. Advancing across bridge panels is still legal **only during MOVE** and must respect your safe chosen number. Glass behind advancing players disappears after MOVE.

## Initial settings

| Setting | Prototype value |
|---|---|
| Ready/join countdown | 10 seconds |
| Match player cap | 8 |
| Minimum live players | 2 (single-player practice allowed only in Studio) |
| Vote window | 5 seconds |
| Reveal | 5 seconds |
| Walk/stay window | 6 seconds |
| Number buttons | Always 1–5 |
| Length of each personal bridge | 20 advanceable panels |
| Strike threshold | 3 cracks |
| Server round safety cap | 22 votes |
| Reward | Win +25 coins, participation +5 coins |

**Progress storage:** Wins and coins were session-only through v0.12. **v0.13 introduces DataStore persistence**, pending Roblox Studio and published-server verification. v0.14 adds a coin-only cosmetics stall (no Robux or paid items). Do not publicly launch or monetize before testing data recovery and purchases.

## v0.25 — fuller sky and anti-glare stone platforms (Studio/phone QA pending)

Owner approved the next visual revision after reporting sparse clouds and large bright white/cream stone surfaces that still looked almost neon on screen. This is a **world-only art/material pass**, not a change to player movement, gameplay, cosmetics or saving.

- **More visible clouds:** The single native `Workspace.Terrain.Clouds` layer now uses **Cover 0.72** (was 0.39), **Density 0.54** (was 0.35) and the existing neutral-white tint. It remains one sky layer, rather than additional expensive parts or overlapping cloud objects.
- **Matte weathered-stone floors:** Main spawn plaza now uses lower-brightness weathered-oat `#B8AD9A` and built-in **Concrete** rather than pale Sandstone; the shared JOIN/spectator platform and both side viewing walks/connectors use shaded stone `#B0A796` and **Concrete** instead of light ivory Limestone. Narrow paths retain muted sandy paving.
- **White architectural surfaces subdued:** Store floors/countertops, stone planters, fountain approach/basin, pergola pillars, lamp pedestals, spectator edge piers and trophy pedestal now use muted stone colors and matte **Concrete/Pavement** where appropriate. Shop roofs, wooden furnishings and signage retain the existing earthy accent palette.
- **Bright spawn rectangle removed:** The functioning lobby SpawnLocation remains in its original position, but its visible pale rectangle is now fully transparent and does not cast a shadow. Collision and respawn logic are unchanged.
- **Preserved:** v0.24 neutral daylight, bloom disabled, low reflectance, 49px phone HUD, private 1–5 voting, glass shattering, free walking/jumping, social seating, two kiosks, cosmetics and v0.23 round-end DataStore saves.
- **Test:** Use the [latest raw Studio installer](INSTALL_STUDIO_COMMAND_BAR.luau) with Play stopped and verify `v0.25 VERIFIED` and the `v0.25` HUD. Compare the exact spawn-plaza angle and spectator bridge with prior images on desktop and a real phone: check abundant but natural clouds, no glaring white rectangles/stone slabs, readable shaded paths and appropriate contrast. **Roblox-engine appearance has not yet been verified.**

## v0.24 — remove yellow cast; keep the soft-earth materials (Studio/phone QA pending)

The owner approved correcting the yellow/washed-out appearance visible in the v0.23 Studio screenshot. This changes the **environment-wide lighting**, not the approved material colors or gameplay.

- **Neutral color correction:** the existing post-processing effect now has a white (255,255,255) tint, near-neutral saturation (-0.035), slight contrast (+0.015) and minimal brightness adjustment (-0.015). Retains the old effect instance to avoid stacking filters on reinstall.
- **Balanced natural daylight:** neutral gray ambient/outdoor light replaces yellow-biased ambient tones; the warm top light shift is removed (top/bottom shifts set to black neutral). Brightness gently reduces from 1.85 to 1.75; bloom stays disabled, low specular reflections remain.
- **Clearer coastal sky:** pale blue-gray atmospheric colors and reduced density/haze replace the old beige atmospheric wash; clouds become neutral off-white instead of yellow-cream. Ocean color, landscaping palette and terrain geometry stay unchanged.
- **Safeguards:** 1–5 voting, 20-panel glass lanes, crack/shatter logic, free walking/jumping, two-player social interactions, cosmetic ownership and v0.23 saving behavior are unchanged. No new mechanics, animations or purchases.
- **Install and test:** Stop Studio Play; run the updated [one-paste installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode and confirm `v0.24 VERIFIED` plus matching server/client versions. Review the lobby and course in Studio and on a real phone: no whole-scene yellow filter, sky remains natural, greens stay readable and oat paths stay matte without glare. This code has not yet been visually verified in the Roblox engine.

## v0.23 — round-end reward saving and unobtrusive persistence warnings (QA pending)

- After each completed match, the server promptly schedules a save for every participating player's earned rewards rather than waiting for the ~150-second autosave or player exit. Existing save locks, idempotent reward batch IDs, retries, autosave, leave and shutdown saves remain in place.
- During JOIN and RESULTS only, the existing second HUD line reports `SESSION ONLY · NO PROGRESS SAVED` or `SAVE ERROR · REJOIN TO VERIFY` when the server-owned profile status requires it. The 49px phone bar stays unchanged and GO/WAIT, votes and reveal remain unobstructed.
- All original rules, prices, DataStore names, free movement/jumping, safe/forbidden glass, graphics and the staffed social hub are unchanged.
- **Test:** Reinstall the [latest raw one-paste installer](INSTALL_STUDIO_COMMAND_BAR.luau) with Play stopped; confirm `v0.23 VERIFIED` and matching server/client version logs. Complete a match and verify `[Mythblox DATA] Saved` for `round-end`, then rejoin a new published private server and confirm Wins, Coins and equipped/owned cosmetics. Save attempts are not proof of persistence until independently reloaded.

## v0.22 — Soft Earth Coast mobile readability and matte materials (phone test pending)

The owner approved a warmer **cute earthy soft** visual direction after the v0.21 lobby appeared glaring and the large top HUD obscured the phone screen. **Soft Earth Coast is a look, not the game's final public name.** This visual direction supersedes Azure Coast's vivid teal/champagne emphasis; the [theme specification](AZURE_COAST_THEME.md) retains the historical filename to preserve links.

- **Palette locked:** warm cream `#EFE6D6`, oat beige `#D9C8AE`, sand `#C9B394`, muted sage `#A8B39D`, terracotta `#B98973`, dusty rose `#C79F9A`, light wood `#B58E6C` and brown text `#6E5A4B`. Architecture, shops, signage, foliage, UI and ocean hues follow this family. No neon-blue/teal facade, shiny gold, saturated pink or white-marble floors.
- **Matte environment:** the central plaza now uses the darker oat color with Roblox's built-in textured Sandstone; main and connecting paths use sandy Pavement/Sandstone. Floor/roof/metal/ocean reflectance is greatly reduced, bloom is disabled, sun/ambient brightness softened, harsh high contrast desaturated and all decorative lamps dimmed. The ocean is a muted coastal gray-green.
- **Phone HUD:** portrait **and landscape** phones display a **49px, two-row rounded status strip** instead of the 83px three-row panel. It shows phase and countdown on the first line, concise JOIN/GO/WAIT/progress guidance on the second, plus a small replicated Wins/Coins chip. Long descriptive text and the progress bar stay on desktop, not mobile. Roblox top safe-area inset is respected.
- **Smaller mobile REVEAL and VOTE:** all five existing numbered avatar/count/SAFE-or-BLOCKED result cards still appear **only for five seconds during REVEAL**, but fit a roughly **156–172px** mobile tray. Mobile 1–5 vote buttons remain large enough to tap while their panel wastes less vertical space. Green/red on result cards are muted but distinguishable; no safe-path coloring returns on bridge glass.
- **Original gameplay and social hub preserved:** no changes to 2–8 racers, secretly voting 1–5, five-second REVEAL, six-second MOVE, glass shatter/cracks, win rewards, saved cosmetics prices, bench Seats, NPC shopkeepers or world boundary code.

**Install:** Stop Play, use the latest [v0.22 one-paste Studio installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Edit mode, and confirm `v0.22 VERIFIED` plus HUD v0.22. To update a Roblox-app friend-test experience, **publish the updated place after installing**, keeping the experience private/restricted. **Test on an actual phone as well as Studio's device emulator**: background brightness, unclipped HUD, vote buttons, all five reveal cards, two-player shop/race flow and gameplay-regression checks. See [TEST_PLAN.md](TEST_PLAN.md).

**Status:** GitHub source and installer updated; real phone and Roblox Studio v0.22 execution has not yet been verified by the assistant.

## v0.21 — physical lobby, sit-able benches, staffed shop kiosks (friend test pending)

User-reported v0.20 regression: walk-through trees, lamp posts and garden props, decorative benches that did not seat players, and empty open shops. **v0.21 addresses these directly.**

- **Real world collision:** tree trunks/low canopies, shrubs, planters, pergola pillars/roofs, photo arch supports, lamp bases/poles and selected fountain/trophy pieces are now solid. Tiny gold accents, high lanterns, sky/ocean and bridge's purely decorative rail trim remain noncolliding so they do not block travel.
- **Real two-player benches:** each resort bench is now **two independent Roblox `Seat` instances** with normal automatic sitting and an E **Sit** proximity prompt. Each side holds one person; two friends can sit beside each other. Jump or stand to leave the seat, and occupied seats disable their prompt until vacated. Benches are in the same lounge spots.
- **Complete staffed kiosks:** left **SHOP / COMING SOON** and right **COSMETICS / GLASS COLORS** have physical side walls, glass side panels, a solid front desk, champagne-gold counter trim, merchandise displays, proper overhead signage and visible uniformed shopkeepers with subtle waving arms. Shopkeepers are in-world NPC models, not purchasable items or real users.
- **Shopping from the front:** the cosmetics **E Browse colors** prompt was moved to `ServiceCounterTop`, facing the customer access path. Server distance validation follows the counter's location. Existing catalog/coin pricing, profile ownership and earned-currency transactions are unchanged. The left shop remains a placeholder.
- **Multiplayer-safe:** two people can sit separately on the same bench, both browse the cosmetics counter, join the existing 2-player race and still see each other's votes only during REVEAL. No new coin items, map race mechanics or monetization systems were added.

**Install:** Stop Play and run the latest [Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Studio Edit mode. Verify `v0.21 VERIFIED` and HUD `v0.21`. Test with a friend using the [v0.21 multiplayer checklist](TEST_PLAN.md). **This code has not yet been executed by the assistant in Roblox Studio.**

## v0.20 — Azure Coast Resort: expanded lobby, world safety, cohesive theme (Studio test pending)

**Owner approved** cleaning up visible template Baseplate/water escapes, adding sky/clouds and broader scenery, making the social lobby larger, and using one premium material/color family. The **Azure Coast Resort** aesthetic is a **theme, not the final public game name**. The [Azure Coast Theme Guide](AZURE_COAST_THEME.md) locks exact colors, materials and area layout.

- **One visual language:** ivory and limestone architecture, ocean teal/deep teal storefronts and metal framing, champagne brass inlays, evergreen coastal foliage, soft seafoam glass, limited muted coral cosmetics accents. Client vote/shop/score HUD now uses the same palette. SAFE/BLOCKED voting-result cards still use green/red; the purchasable glass tints remain unchanged.
- **Expanded social island:** hub grass is now **186 × 124** studs (was 130 × 91), with a **56 × 39** stone arrival plaza (was 26 × 23). Original spawn, shop stalls, cosmetics prompt, JOIN platform, bridge lanes and spectator walkways keep their functional positions. A new back fountain approach and side-gallery paths lead to **two teal shade pergolas**, benches, planters, tall resort lamps, a photo arch and trophy-garden feature.
- **Sky and depth:** built-in Roblox `Clouds` under Terrain, calibrated Atmosphere/daylight, a larger noncolliding teal ocean, subtle shimmer strips and six far-away decorative islands. Built-in material textures include Limestone, Rock, LeafyGrass, Metal, WoodPlanks and Glass. No unlicensed external assets or paid texture packs were added.
- **No visible template floor:** the Edit-mode installer and server runtime remove **only a directly parented, large, low stock `Baseplate` part** and the already-targeted unused default spawn marker. Custom user map components are not broadly deleted.
- **No walking on water / under the map:** ocean and distant islands are noncolliding. The expanded island has matching resort edging and invisible perimeter barriers, with openings for the existing left/right spectator promenade. A large invisible fall plane plus independent root-height check causes an actual player death/respawn after falling beneath the platforms.
- **Gameplay stays the same:** players may walk/jump normally, but illegal bridge advancement must still shatter glass and eliminate them. The v0.19 fix was carried forward unchanged; bridge-tile colors do not reveal safe steps. No DataStore names, products, coins, wins, vote phases, match geometry or rewards were changed.
- **Not a finished custom-art package:** stronger stylized Roblox **built-in material textures and scripted detailing** are implemented. Imported bespoke meshes/PBR texture maps, final game title and a larger set of approved gameplay features remain future work.

**Install/test:** Use the [latest raw Command Bar installer](INSTALL_STUDIO_COMMAND_BAR.luau) in Studio **Edit mode**, with Play stopped. Check `v0.20 VERIFIED` and the `v0.20` HUD. First confirm **v0.19 elimination actually works**, then examine the social plaza, clouds, default-floor removal, sea escape prevention, shops and spectator paths. See [TEST_PLAN.md](TEST_PLAN.md).

**Status:** Committed to GitHub; no Roblox Studio v0.20 execution or screenshot has been verified.

## v0.19 — fix illegal bridge crossing / no-fall regression (Studio test pending)

**Owner-reported v0.18 bug:** A racer could continue along unbroken future glass after an illegal step. The root cause: elimination previously only changed the `alive` flag and removed one or two supports; with free walking/jumping enabled, a marked-out character could still run on remaining solid tiles.

**Fix:**
- The server immediately marks an illegal attempt eliminated, **shatters both the attempted and last supporting panels**, logs `[Mythblox RACE] ELIMINATED`, then causes the character to **die and respawn at the lobby** after a brief 0.2-second fall/shatter window. A player cannot keep sprinting to the finish after being eliminated.
- Each participant's bridge also has **per-tile `Touched` contact checks** for early, skipped and forbidden forward steps. The existing per-frame server root-position checks remain, including jumps that miss touch events.
- **Walking and jumping remain enabled** for alive contestants in all phases. Walking/jumping on the current panel is fine; **advancing** early or beyond allowed N is not. Full-tile red/green path painting remains disabled.
- Existing majority/tie rule, 3-crack elimination, 5s vote / 5s reveal / 6s MOVE, reward/coin store, cosmetics, premium materials and dance remain unchanged.

**To test:** Stop Play, paste the latest [one-paste v0.19 installer](INSTALL_STUDIO_COMMAND_BAR.luau) into Studio **Command Bar in Edit mode**, then Play. Confirm the top HUD says `v0.19` and the installer prints `v0.19 VERIFIED`. Test stepping ahead during VOTE and crossing beyond a safe vote during MOVE; the panel should disappear and your character return to the lobby. Test legal moves and ordinary in-place jumping separately. See [TEST_PLAN.md](TEST_PLAN.md).

**Status:** Source and installer static consistency checked; **not yet tested in Roblox Studio**.

## v0.18 — free movement, neutral glass and premium coastal materials (historical build: eliminated players could keep running)

**Latest owner-requested change**. All source code and the one-paste installer are committed, **not tested in Roblox Studio yet**.

- **Walking and jumping are never disabled as part of the match phases.** The old `WalkSpeed = 0`, `JumpPower = 0` and Jumping-disabled server code has been removed. Normal controls remain available in VOTE, REVEAL, MOVE and RESULTS. The server **still applies the existing illegal-advance rule**: you may roam your current tile, but proceeding to the next tile before MOVE or beyond your safe allowance still causes elimination. This keeps the voting race meaningful without freezing players.
- **No full-tile hint painting.** Glass always keeps its neutral/purchased color; previously entire next legal panels were painted green and forbidden panels red, which revealed exact routes. That code has been removed. Cracks appear as surface cracks and particles, and broken panels fade/shatter instead of flashing fully red. Five **result cards** still use green/red after the secret vote is revealed.
- **Premium art pass with built-in Roblox textured materials:** warm marble and paved paths, granite island base, polished-metal spectator fencing and bridge rails, subtle brass architectural trims, redesigned marble-and-metal stalls with warm canopy lights, organic foliage, gold-accented finish arch, gently reflective ocean glints and textured **CrackedLava/Basalt** around the hazard. Sunlight, atmospheric haze, soft bloom and color grading now make the environment look more cohesive. The UI uses a subtle pearl gradient.
- Built-in materials use Roblox engine textures. **Custom PBR texture maps, hand-made meshes, bespoke art and further approved features are still future work**, not claimed as finished. This pass adds decor without changing the underlying island/bridge play geometry or adding collision obstacles; check performance with 8 players.
- **The winner dance is configurable.** In `src/ServerScriptService/MythbloxGame.server.luau`, the `SETTINGS.VictoryDanceR15` and `SETTINGS.VictoryDanceR6` animation IDs replace the default dance. A custom animation must be compatible with its rig and accessible to the experience (right creator ownership/permissions). Send the desired IDs to update source and installer together. There is no in-game dance selection shop yet.
- **Timings:** 10s JOIN, 5s VOTE, **5s REVEAL**, 6s MOVE, 5s RESULTS. The 1–5 vote rules, three cracks, awards, DataStore names and cosmetics prices remain unchanged.

**Install:** Stop Studio Play, copy [the latest installer](INSTALL_STUDIO_COMMAND_BAR.luau) via GitHub **Raw**, run in Edit-mode Command Bar, and confirm `v0.18 VERIFIED` and HUD `v0.18`. Follow [TEST_PLAN.md](TEST_PLAN.md) before considering the new movement and graphics verified.

## v0.17 — longer reveal, cleaner screen and winner dance (Studio test pending)

A gameplay-presentation adjustment based on owner feedback; **the vote rules and shop are unchanged**.

- **REVEAL lasts 5 seconds** instead of 2. This gives everyone more time to inspect the five result cards, Roblox avatars and counts. VOTE remains 5 seconds and MOVE remains 6 seconds.
- **Removed the large bottom MOVE warning panel**, including the redundant "Your next tile is unsafe" instruction. During MOVE the top HUD now says only `GO · WALK 1–N GREEN TILES` or `STAY · THIS TURN`, with no large overlay blocking the arena or mobile controls. Actual green/red bridge coloring and server movement rules are unchanged.
- **During the 5-second RESULTS phase, surviving winner(s) automatically perform a short Roblox default dance**, using rig-appropriate R15/R6 animation IDs. They dance in place where they won. The existing confetti and win audio remain. The animation stops before players respawn. Any animation load failure is caught and logged; the match still completes and pays rewards normally.
- **No additional paid assets** or game passes are involved. Roblox animation playback and rig compatibility still need to be checked in Studio.
- Install the latest [one-paste installer](INSTALL_STUDIO_COMMAND_BAR.luau) in **Edit mode while Play is stopped**. Check `v0.17 VERIFIED` in Output and `v0.17` in the HUD.

**Owner playtest pending:** Verify the five-second reveal, clean MOVE layout and visible winner dance in a two-client session. See the [v0.17 tests](TEST_PLAN.md).

## v0.16 — reveal-only five-number avatar results (historical 2-second prototype)

**Explicit owner-approved UI behavior:** Voting stays secret. During the **5-second VOTE**, active racers use the existing private 1–5 selection buttons; **no public number-result cards, other players' selections, avatars or vote totals** are visible. At the start of the **2-second REVEAL**, the selection buttons disappear and five **non-clickable** result cards appear together, only for that phase.

- Each result card shows circular **Roblox avatar headshots of every player who selected that number at the top**, the selected number in the middle and a **1 PICK / N PICKS / 0 PICKS** tally underneath.
- **GREEN = safe**, **RED = blocked** (the tied-top-with-at-least-two rule is unchanged). Both a zero-vote number and a uniquely chosen number remain green because neither is blocked. Result cards also have a small SAFE/BLOCKED label for clarity.
- Supports up to 8 avatar headshots arranged in a compact grid per number; adapts tile sizes to phone/tablet/desktop viewport widths. The local player's avatar has a gold outline. Empty number groups show zero and no avatars.
- Uses the existing server-authoritative `voteCounts`, `unsafe` and `voteOutcomes` payload that already includes the selecting players' UserIds. Roblox's native `rbxthumb` headshots work without uploading new art or adding another data API.
- **MOVE (6 seconds):** All five result cards vanish immediately; the existing green/red bridge permissions and GO/STAY warning continue. Spectators also see the reveal **only** during REVEAL.
- The existing 10-second join, 5-second vote, 2-second reveal, 6-second move, 20 glass tiles, majority/tie rules, three cracks, rewards, purchases and map remain unchanged.

**Install:** Stop Play, run [INSTALL_STUDIO_COMMAND_BAR.luau](INSTALL_STUDIO_COMMAND_BAR.luau) from Raw GitHub content in Studio Edit-mode Command Bar, then confirm `v0.16 VERIFIED` and a `v0.16` HUD. **This UI change has not yet been tested in Roblox Studio.**

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

**Test v0.25 on a phone first:** verify the oat floor is comfortably matte, the 49px top strip no longer obscures play, all five reveal cards/avatars fit, and 1–5 voting remains tappable. Publish the updated private test experience to play with a friend; test bench seating, cosmetics and most importantly illegal-step glass shatter/elimination. Report a phone screenshot or any Output errors. Major additional features and independent multiplayer/data/security QA remain required before public launch.

See [the Mythblox game-design memo](../../docs/FIRST_GAME_GLASS_BRIDGE_CONCEPT.md) for earlier alternatives, including the spinner idea that was explicitly deferred.
