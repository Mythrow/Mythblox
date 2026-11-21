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
