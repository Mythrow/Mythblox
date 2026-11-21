# Game 01 — Studio Test Plan (Prototype)

**Status (2026-11-21):** Owner reports **solo AND multiplayer v0.1 testing succeeded** across multiple gameplay conditions. Exact numbered cases were not individually recorded. Owner also reported four issues; changes for these are in **v0.2**, but this new build has **NOT YET BEEN TESTED IN STUDIO**.

## Playtest log

| Date | Environment | Result | Remaining validation |
|---|---|---|---|
| 2026-11-21 | Roblox Studio, 1 client (user-reported), v0.1 | Installer worked; solo gameplay matched expectations under several unspecified conditions | Specific checklist cases not enumerated |
| 2026-11-21 | Roblox Studio, multiple players (user-reported), v0.1 | Multiplayer worked across multiple unspecified conditions | Reported bugs: initial/respawn near lava, repeated FINISH signs, fixed 8 bridges during join, missing vote breakdown UI |
| 2026-11-21 | GitHub v0.2 (not tested) | Applied fixes to server/client/one-paste installer | Retest all four reported bugs on two clients, especially rejoining after death |

### Priority next test: re-install v0.2 and verify the four reported fixes

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
