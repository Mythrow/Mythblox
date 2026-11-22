# Game 01 — Development roadmap (not launch-ready)

**Owner direction, 2026-11-22:** The current game is a functional prototype, but **not visually attractive or feature-rich enough to release**. A **substantial set of approved features and a major visual overhaul are mandatory before any public launch**. Continue foundation, reliability, multiplayer and mobile work now; do not treat passing the technical tests as permission to launch.

**Project name:** Mythblox is the umbrella brand. Game 01's final public name, icon, description and artwork are still undecided. A temporary Roblox experience name is fine.

## Current checkpoint

- **v0.14** — Owner confirms the cosmetics stall works in Studio. v0.13 saved coins across restarting Studio Play. **Individual win persistence, purchased cosmetic retention, private published-server DataStore persistence, 2–8-client stress testing and mobile usability are not all confirmed.**
- **v0.15** — Reliability source pass and detailed QA checklist. Throttle abusive repeated client remote requests and repeated cosmetics prompt opens; preserve current match timing and game design. **Code prepared in GitHub; Studio test remains pending.**
- No Robux purchases, paid power-ups or public launch are authorized.

## Ordered future stages — versions and features are not yet approved

| Stage | Focus | Outcome / acceptance criteria |
|---|---|---|
| **Now: v0.15 quality foundation** | Multiplayer testing, mobile inputs, persistence, security, performance and connection/rejoin edge cases | A reliable base that does not lose coins or purchases, leak private votes, or let spectators interfere |
| **Next: expanded game-content planning** | Decide and approve a genuinely larger feature backlog | Product decisions on player goals, variety, progression, party features, player personalization and future cosmetics, **without silently changing the core 1–5 voting rules** |
| **Main feature-development phase** | Implement the approved features in small playable versions | Enough depth and replayability to justify returning regularly, with each feature tested against existing gameplay |
| **Major visual/experience overhaul** | Redesign environment quality, materials, lighting, terrain silhouette, props, bridges, animation, sound, lobby/shop presentation, UI polish, finish and player onboarding | Substantially stronger art direction and cohesive screenshots on PC and mobile; not merely a few recolors |
| **Content and presentation completion** | Finish additional approved cosmetic/content sets, consistent visual language and map details; develop the game name, branding, logo/icon and thumbnails | Owner approves the full gameplay and visual presentation |
| **Final regression and launch gate** | Retest all gameplay, saving, purchases, 2–8 players, devices and network failure behavior **after** feature and visual work | Only then decide whether to release; no automatic launch and no invented release date |

**Important sequencing:** Don't cram many brand-new features into the final release day. Build and test the expanded feature set and visual overhaul **before** a fresh final QA pass. This still satisfies the requirement that the current prototype must be significantly expanded prior to public launch.

## Feature ideas — discussion only, not approved

Potential additions to evaluate with the owner: better onboarding/tutorial and lobby activities; varied race presentation or maps; quests/achievements; deeper cosmetic collections; social/party tools; round-to-round progression, statistics and celebrations. These are **candidates**, not authorized mechanics. The core fixed five-number majority voting, blocked picks, three-crack elimination, manual movement and reward rules must stay in place unless changed explicitly.

## Launch blockers

- [ ] Owner explicitly approves the final feature scope and visual direction.
- [ ] Approved feature set is implemented and tested.
- [ ] Owner confirms the world is genuinely attractive enough to publish on desktop and mobile.
- [ ] Persistent Wins, Coins, owned cosmetics and equipment survive Play/server restarts; no double charging or double awarding.
- [ ] Private published-server saving is verified (Studio's separate test store does not prove this).
- [ ] Multiplayer 2–8, join/rejoin, votes and spectators pass without exploitable shortcuts.
- [ ] Mobile/tablet controls, responsive UI and performance pass.
- [ ] No significant client/server errors, persistent-data loss scenarios or purchase integrity problems remain.
- [ ] Final name, icon, thumbnails, description, accessibility/audience settings and moderation/release checks reviewed.
- [ ] Owner independently approves the public launch.

## Current v0.15 test task

Use [TEST_PLAN.md](TEST_PLAN.md), especially the v0.15 section. First run a **two-client Studio test** for voting/spectating, then **restart Play** after a win and a cosmetic purchase. Move to the Studio Device Emulator and finally a **private published Roblox server**. Report any Output errors before starting the main feature and art phases.

The GitHub scripts and one-paste installer are authoritative for code. Publishing/saving a Roblox Studio place is a separate owner-controlled step.
