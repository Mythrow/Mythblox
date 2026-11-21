# Game 01 — Studio Test Plan (Prototype)

**Status:** Tests specified, not yet run on a Roblox Studio server.

## Setup

- Open a clean Baseplate place.
- Install the prototype from [INSTALL_STUDIO_COMMAND_BAR.luau](INSTALL_STUDIO_COMMAND_BAR.luau).
- Open **Output** while testing.
- Test single-player first; then **Server & Clients** with two players, then four if possible.
- This prototype intentionally does not have durable coins or Robux purchases.

## Acceptance tests

| # | Action | Expected result |
|---|---|---|
| 1 | Press Play once in Studio | An elevated lobby, 8 glass lanes, and lava appear; no startup errors |
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
