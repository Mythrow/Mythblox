# Game 01 — Development roadmap (not launch-ready)

**Owner direction, 2026-11-22:** The current game is a functional prototype, but **not visually attractive or feature-rich enough to release**. A **substantial set of approved features and a major visual overhaul are mandatory before any public launch**. Continue foundation, reliability, multiplayer and mobile work now; do not treat passing the technical tests as permission to launch.

**Project name:** Mythblox is the umbrella brand. Game 01's final public name, icon, description and artwork are still undecided. A temporary Roblox experience name is fine.

## Current checkpoint

- **v0.14** — Owner confirms the cosmetics stall works in Studio. v0.13 saved coins across restarting Studio Play. **Individual win persistence, purchased cosmetic retention, private published-server DataStore persistence, 2–8-client stress testing and mobile usability are not all confirmed.**
- **v0.15** — Reliability source pass and detailed QA checklist. Owner reports joining, movement and cosmetics working; broader multiplayer/mobile and saving tests still pending.
- **v0.16** — Owner-approved five-number avatar reveal; owner noted the original two-second display was too brief and bottom MOVE instructions redundant.
- **v0.17** — Five-second reveal, no big bottom MOVE warning, and a winner dance (historical checkpoint).
- **v0.18** — Introduced free walking/jumping and visual upgrades but owner **found a severe bridge regression**: eliminated racers could continue across remaining glass.
- **v0.19** — Corrective source and installer committed to break glass and respawn eliminated illegal crossers. **Owner retest still required; not yet confirmed.**
- **v0.20** — Azure Coast theme and enlarged lobby; owner found ghost props, benches that cannot seat players, and open unstaffed kiosks.
- **v0.21** — Solid lobby architecture/trees, paired Roblox Seats, and enclosed staffed kiosks; existing COSMETICS E prompt remains at the front desk. Friend QA still pending.
- **v0.22** — Owner-approved **Soft Earth Coast** instead of bright/glossy Azure Coast visuals: matte oat/sand floors, sage/dusty-rose roofs, warm brown/wood accents, bloom off and softened daylight; **49px two-row mobile HUD** in portrait/landscape with Wins/Coins and short GO/WAIT status, plus a compact five-number REVEAL tray. **Code and installer ready; real-phone confirmation pending.** The updated [art palette](AZURE_COAST_THEME.md) supersedes previous vivid colors.
- **v0.23** — Reliability-only patch: each completed round triggers a prompt save attempt for participants' earned rewards (with existing autosave/exit/shutdown backups and idempotent transactions unchanged); JOIN/RESULTS now show a compact warning when DataStore reads/writes are unavailable. **Studio, private-server saving and actual-phone QA pending.** No unapproved gameplay features added.
- **v0.24** — Owner-approved neutral coastal lighting correction after a v0.23 screenshot showed a yellowish full-scene tint: white color grading, neutral ambient/daylight shift, less beige atmospheric haze and neutral clouds. The v0.22 muted-earth material palette, 49px mobile HUD, game rules, shops and v0.23 saving logic stay unchanged. **Source and installer committed; actual Roblox Studio/phone verification pending.**
- **v0.25** — Owner-approved richer sky/anti-glare materials: single Terrain.Clouds layer increased to Cover 0.72 and Density 0.54; weathered-oat matte Concrete for central plaza/shared spectator deck/side promenades; toned-down shop floors, stone support props, planters and fountain; fully invisible existing lobby spawn marker. **Studio and phone screenshot comparison pending.** v0.24 neutral daylight and gameplay/saving/interaction remain unchanged.
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

## Current v0.25 test task

Install v0.25, **publish the updated private test place**, and check on an actual phone in portrait and landscape: visibly fuller natural clouds, neutral daylight (no global yellow haze), no glaring white spectator platforms/planters/spawn pad, readable green foliage, matte weathered-oat plaza, new **49px** top strip, legible Wins/Coins, compact 1–5 vote controls and five-card REVEAL. Run a match with a friend to verify v0.21 bench seating, staffed shop E prompt and especially the **v0.19 illegal-step shatter/elimination fix**, not yet separately confirmed. Capture a phone screenshot/Output errors and use [TEST_PLAN.md](TEST_PLAN.md). Major additional gameplay features and custom art remain launch blockers.

The GitHub scripts and one-paste installer are authoritative for code. Publishing/saving a Roblox Studio place is a separate owner-controlled step.
