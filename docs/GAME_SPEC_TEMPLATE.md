# Mythblox — Game Specification Template

> Copy this document to `games/<game-slug>/README.md` **only after a concept is approved**. A game name is not required until the selection discussion is complete.

## Identity

- **Working concept:** [descriptive placeholder]
- **Final game title:** [TBD]
- **Status:** idea / selected / prototype / testing / live / paused
- **Owner / date:**
- **Roblox experience ID:** [TBD]
- **Main place ID:** [TBD]
- **Source folder:** `games/<game-slug>/`

## One-sentence pitch

[Player does X to defeat / outlast others in Y-sized arena.]

## Design fit

- One mechanic:
- One arena:
- Learnable in under 10 seconds:
- Multiplayer with 2 players:
- Fun in under 2 minutes:
- Mobile with ≤1 action button:
- Compelling reason to replay:

## Core rules

- **Join + waiting/solo mode:**
- **Round start condition:**
- **Round duration:**
- **Player actions and controls:**
- **How to win:**
- **How to lose / eliminate:**
- **Tie handling:**
- **Late join / disconnect / respawn:**
- **Between-round flow:**

## Arena

- Approximate dimensions:
- Basic shapes/materials:
- Spawn points:
- Hazard/objective placement:
- Camera approach:
- Mobile visibility:
- Effects / sound cues:

## Minimal UI

- Objective message:
- Countdown + round timer:
- Score/winner:
- Shop button:
- Touch controls:
- Spectator behavior:

## Monetization (separate Roblox IDs for this game)

| Product | Type (pass/product/free) | Player benefit | Duration / ownership | ID | Fairness notes |
|---|---|---|---|---|---|
| [Cosmetic A] | Pass | [Appearance only] | Permanent while owned | TBD | Visual only |
| [Cosmetic B] | Pass | [Appearance only] | Permanent while owned | TBD | Visual only |
| [Optional perk] | Developer product | [Exact effect] | [Limited duration] | TBD | Test vs free players |

- Avoid paid random rewards and trading in first version.
- Define price and placement after gameplay is validated.
- Only grant paid products on valid server-side receipt/ownership validation.

## Tech implementation

- **Server-owned rules:** timer, elimination, score, winner, cooldown, paid grants
- **Client-owned presentation:** UI, camera, VFX, local input
- **Reusable components:** RoundService / PlayerState / Arena / Shop / Data / UI as needed
- **DataStore needs:** [none / cosmetics / wins / settings]
- **Analytics events:** join, round_start, round_end, replay, purchase (privacy-safe)
- **Security risks:** RemoteEvent inputs, movement/physics authority, purchase replay

## Prototype acceptance tests

- [ ] New join reaches action quickly
- [ ] 2 players can complete a full round
- [ ] Automatic next round works
- [ ] Solo server isn't broken
- [ ] Late join, player leave, respawn and ties are handled
- [ ] Mobile buttons, touch targets and UI are usable
- [ ] No critical errors in Studio's server/client test
- [ ] Server rejects fake win/score/purchase requests
- [ ] Store grants correctly and survives failed/cancelled/retried purchases
- [ ] Free players can win and enjoy the complete game

## Playtest report

- Testers / device mix:
- Confusing moments:
- Best moments:
- Rematches observed:
- Bugs:
- Balance concerns:
- **Decision:** iterate / release / pause / discard

## Releases

| Date | Version | Changes | Notes |
|---|---|---|---|
| TBD | 0.1.0 | First playable prototype | Private test |
