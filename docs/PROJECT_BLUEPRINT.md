> **Status update (2026-11-21):** The first unnamed game is now an approved **glass-bridge voting race**. Source, Studio installer and test plan are in [games/game-01](../games/game-01/README.md). The original candidate archetypes and selection process below are retained as portfolio guidance; the first game needs local Studio playtesting before any release.

# Mythblox — Project Blueprint

**Version:** 0.1 (foundation)  
**Status:** Proposal / awaiting first game selection  
**Updated:** 2026-11-21  
**Umbrella project:** Mythblox. **Individual game titles:** not selected.

## 1. Mission

Build a portfolio of independent, small, fast, replayable multiplayer Roblox experiences using AI to create nearly all content and code, while keeping the owner's work focused on selecting ideas, operating Roblox Studio, reviewing AI outputs, playtesting, and approving releases.

**Not the objective:** a single giant Mythblox game, a shared story universe, complex systems, large maps, handcrafted level pipelines, or a promise of automatic income.

### Guiding rules

1. **One mechanic:** each game has one core action or survival rule.
2. **One small location:** the play space fits in a compact arena; a miniature waiting area can be part of it.
3. **Multiplayer competition:** best with friends, works with two participants, and handles empty servers gracefully.
4. **Fast rounds:** typically 45–120 seconds, with intermissions around 5–10 seconds.
5. **Instant understanding:** the objective can be explained in one sentence and grasped in approximately 10 seconds.
6. **Minimal controls:** movement and at most one game-specific action; mobile and desktop first.
7. **AI-created:** prefer generated Luau code, procedural geometry, generated UI, and AI-authored art prompts over manual modeling.
8. **Fair monetization:** cosmetics first; if temporary paid perks exist, they must be limited, transparent, and counterable. No purchased guaranteed wins.
9. **Reusable foundation:** shared gameplay infrastructure; each game remains individually publishable and brandable.
10. **Fun before store:** a free player gets a complete and enjoyable game.

These are design targets, not hard platform limits.

## 2. Portfolio architecture

- **Mythblox** = the development initiative, shared standards, and GitHub monorepo.
- **Individual games** = independently named Roblox *experiences* with their own place(s), Roblox experience IDs, titles, thumbnails, analytics, stores and release history.
- Every game should start with **one place**, **one arena**, and **one game mode**.
- Source code and design standards can be reused across games. **Passes and developer products should be configured per experience**, not presumed to provide cross-experience entitlements; in-game selling of another game's products is not the plan.
- Avoid any centralized Mythblox lobby/hub until several games demonstrate healthy independent audiences; a hub creates extra scope and fragments traffic.

### Recommended initial match format

| Dimension | Target |
|---|---|
| Server capacity | Start with up to 8, adjustable to 12 if testing supports it |
| Minimum competitive players | 2 |
| Solo experience | Practice / spectate / countdown demonstration so an empty server is not dead |
| Round duration | 45–120 seconds |
| Time to first action | Under 15 seconds |
| Intermission | Around 5–10 seconds |
| Map | Compact, readable, low-poly, visually distinctive |
| First release | One mechanic, one arena, one mode, one results screen |
| Supported controls | Keyboard/mouse and touch at launch; controller later if practical |

Do not require 4+ players for every match: small new games can have low concurrent player counts.

## 3. What we will and will not build

**In scope:** round countdown; core mechanic; clear winners/losers; rejoin/respawn; short rematches; simple scores/wins; intuitive UI; sound and visual feedback; a small relevant shop; analytics; safe persistence where necessary.

**Out of scope by default:** story, quests, multi-map campaigns, inventories of dozens of items, pets, crafting, skill trees, social feeds, trading, lootboxes, large multiplayer lobbies, open worlds, complex combat, or pay-to-win designs.

A feature is approved only if it improves fun, clarity, retention, fairness, or revenue enough to justify the added complexity. Every game must also pass a **scope test**: can its entire rule be summarized in a single sentence?

## 4. Candidate gameplay archetypes — concepts only, not final game names

These are ideas to discuss and score later. Do not create individual game names or production projects until one is chosen.

| Archetype | Core loop | Arena | Difficulty | Relevant cosmetics/perks |
|---|---|---|---|---|
| Safe-tile survival | Move to the indicated safe color before other tiles fall; last survivor wins | One tiled platform | Low | Trails, tile-step effects, victory emotes; avoid advantage perks |
| Push-out contest | Shove players toward the edge; last in the ring wins | One circular platform | Medium (physics/security) | Push visual effects, gloves, knockout effects; carefully bounded cooldown options |
| Crown chase | Hold a collectible for the most seconds while rivals try to tag you | One compact room | Medium (tag fairness) | Crown styles, footsteps, celebration effects; avoid pay-to-win speed |
| Shrinking-floor survival | Stay on the shrinking safe area until opponents fall | One platform | Low | Floor effects, aura, winner poses |
| Hot-object pass | Pass a ticking object to another player before its timer expires | One small arena | Medium (latency/targeting) | Object skins, pass effects, elimination effects |

**Preferred first prototype to evaluate:** safe-tile survival or shrinking-floor survival, because they have minimal controls, straightforward geometry, obvious spectator feedback, and low asset requirements. This is a recommendation, **not** a locked game decision.

### Idea selection rubric

Score each concept 0–2 on: 10-second comprehension; enjoyable with 2 players; mobile accessibility; one-arena scope; AI implementation simplicity; cosmetics fit. Maximum 12. Reject any concept with a 0 in safety/fairness or technical feasibility, even if it scores highly overall. Playtest the top concept before naming it.

## 5. The universal player loop

1. **Join:** spawn close to the game; no long intro.
2. **Understand:** a visible one-sentence instruction shows the goal.
3. **Compete:** play a short round; immediate audio/visual feedback.
4. **Result:** announce winner(s), with a short, readable result.
5. **Replay:** automatic countdown to the next round; spectators remain engaged.
6. **Optional purchase:** visit a clear, unobtrusive shop in intermission, not through forced repeated prompts.

Allow a player joining mid-round to spectate or enter the next round cleanly. Define tie and disconnect rules for each game.

### First-release UI

- Objective text + countdown/timer
- Live match state and a small score display
- Brief winner/results panel
- Minimal shop and cosmetic-equipping interface
- Touch-friendly buttons and scalable text

No complicated menu tree; the match itself is the home screen.

## 6. Monetization strategy

**Policy for Mythblox: free-to-play, cosmetic-led, gameplay-relevant purchases.** Monetization should add expression or small optional variety, not undermine the reason to compete.

### Purchases by Roblox product type

- **Passes** are one-time purchases for durable entitlements (e.g. a special trail, persistent elimination effect, nameplate style). Verify ownership via Roblox APIs, including on join; don't rely on a saved boolean as proof.
- **Developer products** are repeatable purchases (e.g. a single-round visual celebration, a temporary effect, a replenishable consumable). Grant via a server-side receipt handler with idempotent processing; never award on a purchase prompt-completed event alone.
- Optional soft currency is **not** required for the first MVP. Add it only if it serves a clear purpose and has safe saving logic.

### Initial store proposal (per game)

1. Two to four **free or earnable** customizations to demonstrate the system.
2. Two or three **paid cosmetics** visually related to the mechanic.
3. At most **one optional temporary perk** after playtesting proves it fair; alternatively launch cosmetics-only.
4. One optional bundled cosmetic pass only when there is enough content to warrant it.

No paid random rewards or trading in the initial portfolio. Paid random items carry special disclosure and per-player restrictions that add needless complexity. Do not promise cross-game ownership or shared currency: each experience has its own commerce and saved state.

### Power-up guardrails

If a game uses purchasable power-ups, define: duration, cooldown, per-round cap, exactly what it changes, limits on stacking, and how a nonpayer can win. Never sell invulnerability, unbounded speed, forced opponent elimination, or guaranteed victories. Test the win rate by purchasers versus nonpurchasers and remove unfair items.

Robux pricing is a separate decision after the game is fun, and platform policies/pricing must be checked at setup.

## 7. AI-first development model

**Owner decisions:** approve game idea, control Roblox account, set up integrations, run or supervise tests, judge feel/fairness, configure products and publish.  
**AI responsibilities:** write specs and tasks, create Luau scripts, generate simple procedural arenas and interfaces, propose assets, write tests and checklists, diagnose logs, create thumbnails/copy where permitted, and maintain GitHub documentation.

### Recommended stack

- **Roblox Studio** for editing, playtests, device emulation and publishing; it is already installed.
- **Luau** for gameplay and Roblox services.
- **GitHub** as the source of truth for docs and versioned source code.
- **Rojo** as the preferred longer-term file-based workflow to sync AI-generated project code into Studio. Start with a small code-first prototype; use fully managed Rojo only if its build/export requirements suit the game.
- **Roblox Studio Assistant** for direct Studio edits, instances, and scripts.
- **Studio MCP server** optionally connects an MCP-capable local AI client to Studio for data-model changes and playtesting; this chat's GitHub access does **not** mean it is connected to the owner's open Studio application.
- Use generated primitive parts, beams, particles and basic materials for MVP worlds; adopt external/generated 3D assets only if needed and permitted.

**Important limitation:** "AI-only" means AI authors virtually all creative/technical implementation. Human authorization, account setup, testing, moderation decisions, and publishing may still require direct action. AI-generated scripts and assets must be reviewed and tested.

### Shared technical modules (to build only when game one needs them)

- **RoundService:** waiting, countdown, active round, result, restart
- **PlayerStateService:** alive/qualified/score/spectator lifecycle
- **ArenaService:** builds/initializes simple arena and handles cleanup
- **ShopService:** SKU mapping, purchase prompts, grants, ownership
- **DataService:** only durable player settings/owned items/statistics actually needed
- **UI kit:** timer, notifications, result, shop controls
- **Effects kit:** reusable confetti, sound cues, trails, screen feedback
- **Analytics events:** join, round_start, round_finish, replay, shop_open, purchase

Keep server authority for rounds, winners, damage/knockback validation, cooldowns, and purchase grants. Client input and RemoteEvent messages are untrusted. Separate per-game rules from shared modules; avoid building a generic framework before a real game validates it.

## 8. GitHub monorepo blueprint

One repository, with games separated by folder:

```text
Mythblox/
├── README.md
├── docs/
│   ├── PROJECT_BLUEPRINT.md
│   ├── GAME_SPEC_TEMPLATE.md
│   └── DECISIONS.md
├── shared/                  # Created when code is ready to reuse
│   ├── server/
│   ├── client/
│   └── common/
├── games/                   # Added when game ideas are approved
│   └── <game-slug>/
│       ├── README.md
│       ├── default.project.json
│       ├── src/
│       ├── tests/
│       └── assets/
└── .github/
    └── workflows/          # Optional checks/builds later
```

This tree describes the **target structure**, not files that currently exist. We will add game folders only after approving each concept; we will extract `shared/` from working code instead of designing a speculative framework.

### Documentation for each future game

- Working title and final title (when chosen)
- One-sentence gameplay pitch + first 10-second experience
- Arena sketch and core controls
- State machine and scoring/win conditions
- Game-specific monetization catalog
- Key edge cases, anti-exploit and mobile considerations
- Roblox experience/place IDs and SKU IDs (non-secret IDs only)
- QA checklist, release notes, analytics outcomes, and decisions

Store **no API keys, tokens, passwords, private user data, or secrets** in Git. Use provider/CI secret storage for credentials. Generated content should carry clear licenses/attribution when required.

## 9. Production pipeline for each game

**Gate 0 — Choose:** score an idea, outline one-sentence rules, identify one meaningful cosmetic product. Outcome: approved spec.

**Gate 1 — Prototype:** build tiny arena and round flow. No store, progression, or elaborate visuals. Outcome: two players can join, compete, finish, and replay without intervention.

**Gate 2 — Fun test:** run several real multiplayer rounds on mobile/desktop. Confirm fairness, clarity, pacing and willingness to rematch. Revise or stop if it is not fun.

**Gate 3 — Productize:** add readable UI, sound/effects, 2–3 cosmetics, basic shop, persistence only as needed, and defensive server logic.

**Gate 4 — QA:** test solo, 2 players, near-capacity server, late join, disconnect, respawn, ties, touch controls, purchase success/cancel/retries, data-store errors, and exploit attempts.

**Gate 5 — Release:** select final title/thumbnail, complete Roblox publishing and content-rating settings, confirm audience eligibility, publish one experience, observe analytics.

**Gate 6 — Measure:** use the first sessions to assess comprehension, completed rounds, rematches, session length, return visits, shop interest, and error rates. Improve a promising game before expanding the portfolio.

Do not begin game two merely because game one is technically complete. Establish whether the loop is enjoyable and whether any shared systems are worth generalizing.

### Definition of done for a first game

- A new player reaches play rapidly and knows the goal.
- A complete round and automatic rematch run without admin intervention.
- Two-player experience is valid; empty server has clear behavior.
- Winner and scoring cannot be set directly by the client.
- The game works on a phone-sized display.
- No critical console errors or unstable player-state transitions in multiplayer tests.
- Purchases grant correctly and do not affect free fairness.
- The owner can reproduce the build from source and document release settings.
- Publishing/compliance checks completed.

## 10. Distribution, costs and growth

- Each game should have its own descriptive title, appealing icon, thumbnail, and clear onboarding; **Mythblox** can remain a subtle creator/portfolio identity.
- Do not assume a new experience gets players automatically. Account for low concurrency, invite friends for tests, and prioritize first-minute satisfaction.
- Check Roblox's current **audience/age verification, 2FA and content-rating** requirements before release. As documented November 2026, access for Roblox Kids/Select can require an eligible subscription history or an optional **1,000 Robux refundable publishing fee per game**, along with other conditions. This is not a blanket fee for every release; confirm requirements for the chosen audience and account.
- Establish an advertising budget only **after** metrics show a game retains players; paid discovery cannot fix a bad game.
- Keep product IDs, transactions and analytics **per experience**.
- Never imply earning Robux or money is guaranteed; review acquisition costs and earnings separately for each game.

## 11. Key risks and responses

| Risk | Mitigation |
|---|---|
| Too many games with no players | Prototype one, validate it, launch the next only with a repeatable process |
| Nobody in a match | Allow 2-player starts, solo practice or waiting interaction, friend invites |
| AI-generated broken code | Keep small modules, review diffs, use Studio server/client tests, fix errors |
| AI tool cannot edit open Studio | Use Studio Assistant or a properly connected local MCP client; fall back to generated code + Rojo |
| Paid perks feel unfair | Cosmetics-led shop, strict caps, test purchaser/nonpurchaser outcomes |
| Purchase/data bugs | Server-side receipts, idempotent grants, safe DataStore failure behavior |
| Asset/IP/compliance issues | Use licensed/generated assets; review Roblox content and commerce policies |
| Scope creep | One mechanic, one arena, one mode, one-week-style prototype discipline without a rigid launch date |

## 12. Next decisions

1. Pick the **first gameplay archetype** (no name until approved).
2. Choose initial **technical integration**: Studio Assistant + generated scripts, or a Rojo/code-first setup (MCP optional).
3. Confirm whether the **first release is cosmetics-only**, or a deliberately limited, fair perk is required.
4. Choose release audience and check account-specific Roblox publishing requirements.

## Reference documentation

- Studio AI + MCP: https://create.roblox.com/docs/ai/accelerated-workflows
- Studio Assistant: https://create.roblox.com/docs/assistant/guide
- Rojo: https://create.roblox.com/docs/projects/rojo
- File-based workflows: https://create.roblox.com/docs/projects/file-based-workflows
- Passes: https://create.roblox.com/docs/production/monetization/passes
- Developer products: https://create.roblox.com/docs/production/monetization/developer-products
- Paid random item policy: https://create.roblox.com/docs/production/monetization/paid-random-items
- Client/server security: https://create.roblox.com/docs/scripting/security/client-server-boundary
- Playtest modes: https://create.roblox.com/docs/studio/testing-modes
- Release and audience requirements: https://create.roblox.com/docs/production/publishing/publish-games-and-places
- Discovery: https://create.roblox.com/docs/discovery
