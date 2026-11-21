# First Game — Glass Bridge Voting (Unnamed Concept)

**Status:** Concept discussion / candidate for Mythblox game 1; *not* a locked specification  
**Date:** 2026-11-21  
**Final name:** Not selected

## Elevator pitch

Each player races along their **own narrow glass bridge over lava**. Every turn, players secretly select from **five fixed choices**; the most popular choice is unsafe. A safe player must **walk forward exactly one glass tile** before the next round starts. An unsafe player must **stay on their current tile** or fall into lava. Repeated unsafe selections crack their bridge until they are eliminated.

The visual action is manual, not automatic.

## Confirmed design direction from current discussion

- 10-second join period; willing players enter the compact play area.
- Parallel, individual glass lanes over one lava pit.
- Same **five on-screen choice buttons** regardless of player count.
- Exactly **one tile of progress** for an allowed selection, never number-of-steps progress.
- Number labels are identifiers rather than step counts; static 1–5 is simplest and more learnable than randomized numbers.
- Players physically walk between glass tiles using Roblox movement controls; no automatic advancement.
- Crossing onto a forbidden next tile makes the glass shatter and the player fall.
- After a player is allowed to advance, their **previous** tile breaks when the next selection phase begins. If they failed to move, they fall.
- Players whose current tile remains locked must stay where they are; their current tile does *not* auto-break just because the next turn begins.
- Three unsafe-vote strikes are the current provisional threshold; on the third, the player's **current** glass tile breaks and they fall.
- First finisher or last surviving player wins; coins/points and cosmetics later.
- No final title, price, power-up catalog or fixed player cap agreed yet.

## Crucial two-player flaw in naive popularity voting

Rule A: 'Only a number selected at least twice is blocked; all others advance.'

With exactly 2 participants:
- Same number => **both** crack.
- Different numbers => **both** advance.

Therefore their vote outcomes are always identical: neither can gain progress by choosing a different number. Except for manual-movement mistakes, all 2-player races are ties. This is **not** a viable competitive default if 2-player lobbies matter.

There is also a terminology issue: mathematical **majority** means strictly more than half of players, whereas the intended mechanic is **most popular / highest vote count (plurality)**. Use 'most picked number' in the player-facing copy.

## Candidate voting rules

### A — All top-vote ties are blocked (original)
- Choices tied for the largest vote count with at least 2 selections all become unsafe.
- If everyone chooses differently, all advance.
- Minimal implementation, but fundamentally tied in 2-player matches.
- At 8 players a 2–2–2–1–1 vote distribution cracks 6 people simultaneously.

### B — Exactly one most-popular choice cracks (random among *picked* tied leaders)
- Choose the most popular number.
- If two+ options tie for highest votes, randomly select one **of those options** to crack.
- If all choices are unique, the wheel chooses one of the chosen options.
- Solves 2-player progress ties but heavily favors elimination rather than finishing; a 6-tile bridge is effectively not finishable with 2 players and 3 cracks because each selection turn includes at least one new crack.

### C — One danger number, wheel spins on ties (provisional recommendation)
- If a single number has the largest vote count, all who chose it crack; everyone else may walk one tile.
- If several numbers **tie** for highest vote count (including an all-unique vote), a wheel rolls **1–5** uniformly at random. Players choosing the wheel's number crack; all others may walk.
- If the wheel lands on an **unchosen** number, everyone is safe to advance.
- Works the same with 2, 4 or 8 players; creates some distinct outcomes with 2 players without forcing a victim every turn.
- Tradeoff: some outcomes are random, and players need a short visual explainer for tied votes.

**Provisional recommendation:** Test C first, but do not call the concept proven fun until human playtesting. A purely random choice policy does not model opponent psychology.

## Example with four players

Voted: A=4, B=4, C=2, D=5.  
Number **4** is most picked (2 votes), so A and B gain one crack; C and D may step forward one tile.

Example with two players:

- A=2, B=2: number 2 clearly has most votes, so both gain one crack.
- A=2, B=4: votes are tied at 1 each; wheel rolls 1–5.
  - 2 => A cracks, B can advance.
  - 4 => B cracks, A can advance.
  - 1, 3 or 5 => both may advance.

## Monte Carlo sanity checks (not player testing)

Simulated **25,000 matches per variant/player count**, fixed 5 numbers, uniform independent random votes, 6-tile finish, elimination on 3rd crack, no walking mistakes, match ends at first finish or when ≤1 player survives. The RNG-driven data is only for checking mechanical balance.

| Players | Rule | Average turns | ≥1 finisher | Decided by sole survivor | All fall / no winner |
|---|---|---:|---:|---:|---:|
| 2 | A (original) | 6.8 | 79.9% (always joint) | 0.0% | 20.1% |
| 2 | B (random picked tie leader) | 3.7 | 0.0% | 92.4% | 7.6% |
| 2 | C (five-number tie wheel) | 5.7 | 34.7% (including joint finishes) | 53.7% | 11.6% |
| 4 | A | 6.6 | 55.5% | 28.9% | 15.7% |
| 4 | B | 6.2 | 14.8% | 75.8% | 9.4% |
| 4 | C | 6.6 | 48.6% | 41.3% | 10.0% |
| 8 | A | 6.9 | 61.7% | 25.8% | 12.5% |
| 8 | B | 6.9 | 95.9% | 2.3% | 1.8% |
| 8 | C | 6.7 | 97.5% | 1.5% | 1.0% |

Percentages rounded; totals can differ slightly from 100%. Rule A two-player finish percentage is always a **joint finish**, not a competitive winner. Rule C still produces joint finishes, especially at 8 players; an MVP should allow tied winners when they finish on the same reveal.

Some 2-player races are decided by survival before reaching the finish. This may be good for short sessions but should be observed in testing.

## Suggested first prototype timing and size (not final)

- 10-second join window when at least two players are ready.
- Five static buttons numbered **1–5**.
- Vote: 5 seconds; reveal/spin: about 1–2 seconds; walk-or-stay: 4 seconds.
- Bridge: start with **6 advanceable glass panels per lane**.
- 3 strike icons always visible; wrong-time movement can lead to immediate elimination.
- Aim roughly **50–90 seconds** per match, including join period, before longer animation/polish.

### Manual-movement state machine

`JOIN (10s) -> SECRET VOTE (5s) -> REVEAL (1–2s) -> MOVE / STAY (4s) -> NEXT VOTE or WIN / RESET`

- The **server** owns voting, vote counts, tie wheel result, crack counters, eligibility to advance, platform destruction, and winner logic.
- A player's next platform is visible but **not safe to step on** until allowed by the reveal.
- An unsafe player who steps on it breaks the unauthorized platform and falls. Current standing tile remains intact unless it is their third crack.
- An eligible player must move to the next tile before the next vote. At the next vote start, their previous tile shatters; if they haven't crossed, they fall.
- Use clear green/red highlights, a path arrow, and an audio cue. Do not hide a lethal boundary from players.
- Prevent jumping between lanes, skipping tiles, invalid touches and teleporting through unearned progress; validate on the server.
- Roblox `Touched` signals can fire repeatedly; use per-player, per-tile event debouncing and server checks.
- A little movement grace period will likely be needed for mobile players and variable network latency.
- Do not confuse damage cracks from popularity with an instantly fatal illegal step: the former are three-strikes, the latter is a fall.

## Winning and rewards (proposal)

- First to the finish wins; simultaneous eligible finishers share the win for MVP.
- If one survivor remains, they win immediately.
- If everyone falls in the same resolution frame, call it a draw and restart.
- Coins rewarded for participation, progress, and victory (avoid rewarding intentional repeated falls).
- Cosmetic shop later: lane glass styles, footsteps, crack visual FX, lava splash, winner pose.
- Avoid paid crack repair, automatic step or invulnerability until fairness is demonstrably solved.

## Test cases for gameplay validity

1. Two players choose the same/different numbers.
2. A tie exists among multiple most-popular groups (e.g. 2/2/1).
3. All choices are unique, wheel lands on chosen / unchosen number.
4. Unauthorized player attempts to step forward.
5. Eligible player fails to step before the old tile expires.
6. Disconnected player, late join, changing player count, or elimination during a voting window.
7. Simultaneous finish, simultaneous elimination, insufficient players.
8. Jumps, lag, touches firing twice, sliding across several tiles.
9. Mobile users can cross within the move window.
10. Nobody can claim a result, step, coin, purchase or crack state from the client.

## Open questions

- Should the **tie wheel** be used, or is adding randomness unacceptable?
- Should the bridge be six tiles and the vote/movement windows be 5/4 seconds?
- Should third-crack elimination be retained, or is that too harsh given accidental falls?
- Are ties shared victories or should the game use a final sudden-death round?
- What is the smallest set of visuals that makes movement and danger obvious?

This is a **discussion memo**, not implementation approval or the final game spec.
