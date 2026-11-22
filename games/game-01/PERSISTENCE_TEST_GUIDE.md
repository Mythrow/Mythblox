# Game 01 v0.13 — test persistent wins and coins

**Status:** Source and Command Bar installer committed on 2026-11-22. Owner has not yet tested DataStore persistence in Roblox Studio or a published Roblox server.

## What is saved

- The authoritative **Wins** and **Coins** values earned from completed matches.
- Winners earn **1 win and 25 coins**; other participants earn **5 coins**. The existing game rules are unchanged.
- Rewards are accumulated on the server, autosaved approximately every **150 seconds** (with jitter), and saved again on player exit or server shutdown.
- This version **does not** save cosmetics, glass colors, purchases, or settings. No game shop or monetization has been added.
- **Older v0.12 coin/win totals were session-only**, so they cannot be restored retroactively. A player with no v0.13 stored profile starts at zero.

**Technical stores:** `MythbloxGame01_Progress_Studio_v1` in Roblox Studio and `MythbloxGame01_Progress_v1` in actual published servers. These stores are intentionally distinct so Studio tests cannot change live player data. Per-user keys use the Roblox user ID.

## Enable persistence testing in Studio

1. First, **save a local backup** of the current place (`.rbxl`), and stop Play.
2. Make sure this Roblox experience has been **published to Roblox**. You can keep it **private** while developing; publishing a place is not the same as opening the game to the public.
3. In Roblox Studio, open **File → Experience Settings → Security**, enable **Enable Studio Access to API Services**, and save. Studio blocks online DataStore requests until this setting is enabled. ([Roblox documentation](https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/save-player-data))
4. Open [the v0.13 one-paste installer](INSTALL_STUDIO_COMMAND_BAR.luau), choose **Raw**, copy all of the code, and run it in the Studio **Command Bar** in **Edit mode**. Check Output for `v0.13 VERIFIED`.
5. Start Play and check that the top HUD says **v0.13**. The server Output should include `[Mythblox DATA] Loaded ...`.

## Test that rewards survive a restart

1. Enter a solo practice match in Studio (or use multiple test clients).
2. Finish one match and confirm the **Wins/Coins** values and world leaderboard change.
3. **Stop Play**. The server will attempt a final save. Look for `[Mythblox DATA] Saved ...` in Output; if you see `SAVE FAILED`, **do not** count this test as passed.
4. Start another **new Play session** in the same published experience. Confirm the loaded values match those from the last session.
5. Finish a second match, stop Play, then start again. Confirm stats accumulate instead of resetting or double-counting.
6. Test two clients if possible: only participants receive rewards and each player's progress stays separate. Studio mock-player user IDs may differ from a normal published Roblox account, so verify actual live persistence in a private published-server test before release.

## If data doesn't save

- `[Mythblox DATA] LOAD FAILED` means the data could not be read safely. **The game stays playable, but that session's rewards will not be written**. This deliberately avoids erasing real saves with fallback zeros.
- `[Mythblox DATA] SAVE FAILED` means the write didn't complete successfully; rewards remain pending on that server and an autosave/exit save may retry. Do not assume data persisted until a successful save and fresh load confirm it.
- Select a Player in Explorer and inspect the `MythbloxDataStatus` attribute:
  - `LOADING` — initial DataStore request in progress.
  - `READY` — profile loaded and saving is available; not a guarantee every recent reward was already written.
  - `SESSION_ONLY` — storage unavailable; match rewards are temporary.
  - `SAVE_ERROR` — the most recent write failed.
- Confirm the game is published and the Studio API Services toggle is enabled. If it still fails, copy the relevant **Output errors**, not just a screenshot of the leaderboard.
- Remember: the **Studio test store is separate from the live published store**, so live coins may initially be zero even after successful Studio tests.

## Safeguards and known scope

- All reads/writes run **only on the server**, never from a player's vote UI.
- `GetAsync` and `UpdateAsync` are wrapped with guarded retries. If loading fails, the save path is disabled for that session.
- `UpdateAsync` atomically adds earned rewards to the latest stored totals, with recently applied save IDs to avoid double-awarding a retry with an unknown outcome.
- Pending rewards are saved together, not after every small action. Exit and server-shutdown handlers attempt a final save; a Roblox/cloud outage can still prevent a final write.
- The data model currently supports **earned positive coins and wins only**. Future cosmetic purchases must use **server-validated, atomic spending transactions** before any coins can be deducted.
- This is a prototype save system: test rapid reconnects, failures, simultaneous joins and live-server behavior before public release.

Further reading: [Roblox DataStore best practices](https://create.roblox.com/docs/cloud-services/data-stores/best-practices) and [standard data store tutorial](https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/save-player-data).
