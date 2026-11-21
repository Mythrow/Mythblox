# Mythblox

**Mythblox** is an AI-led portfolio project for building **small, simple, replayable competitive multiplayer Roblox games**.

Each game will have **its own name and Roblox experience**. Mythblox is the umbrella project and shared code/documentation repository, **not** an in-game title.

## Design principles

- One compact arena, one main mechanic, no story or heavy progression.
- Short rounds, understandable controls, fast rematches.
- Fun with friends and viable with as few as two competing players.
- AI-generated code, maps, UI and content, supervised and playtested in Roblox Studio.
- Fair, game-relevant cosmetics first; optional small balanced power-ups.
- Reuse working systems from earlier games to keep future games small and quick to produce.

## Project documents

- [Project blueprint](docs/PROJECT_BLUEPRINT.md) — goals, gameplay rules, portfolio architecture, monetization, AI workflow, engineering, launch, and quality gates.
- [Game specification template](docs/GAME_SPEC_TEMPLATE.md) — copy for each approved game before implementation.
- [Decision log](docs/DECISIONS.md) — confirmed preferences, suggested defaults and open decisions.

## Current status

**Foundation stage (2026-11-21).** No individual game has been named or selected, and no Roblox game source files have been created in this repository yet.

**Next:** choose the first multiplayer mechanic, finalize the game spec, then create its `games/<game-slug>/` folder and AI-produced prototype.

## Stack

Roblox Studio + Luau, GitHub, Roblox Studio Assistant; likely Rojo for source-controlled scripts, with optional Studio MCP integration. Exact development workflow will be finalized during the first prototype.

## Notes

This public repository contains no account credentials or API secrets. Roblox passes, developer products, ownership and publication requirements apply separately to each experience. See the [blueprint](docs/PROJECT_BLUEPRINT.md) for platform references and limitations.
