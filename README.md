# Tenacity

Roblox client using the Tenacity UI renderer, Tenacity runtime/API naming, and bundled universal/game modules. Written in Luau.

## Runtime

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/amrho94/tenaaaaaauhhhohfuck/main/loader.lua', true))()
```

The loader uses the repository shown above. Set `shared.TenacityRepository` and `shared.TenacityBranch` before loading to use your own fork. The ZIP changes need to be uploaded there before the remote loader can use them.

For local use, put the contents of `Tenacity-client/` in your executor's `tenacity/` folder and run `launch-local.lua`. Profiles and cached files are stored under `tenacity/`.

## Files

- `loader.lua` — starts the client.
- `main.lua` — loads the UI and game modules.
- `guis/loading.lua` — loading screen.
- `guis/tenacity.lua` — UI, settings, profiles and module controls.
- `libraries/tenacity-api.lua` — public API v3.
- `libraries/krs-render.lua` — shared HUD styling.
- `libraries/runtime.lua` — downloads and caches files.
- `games/universal.lua` — modules shared across games.
- `games/<place>.lua` — game-specific modules.
- `libraries/additions.lua` — bundled extensions.

## Categories

`Offense`, `Motion`, `Player`, `World`, `Vision`, `Utility`, `Scripts`, `Developer`

Use these names when registering modules. See `API.md` for examples and `TENACITY-MIGRATION.md` for profile compatibility notes.

## Development flags

- `shared.TenacityRefresh = true` — force a source refresh.
- `shared.TenacityDeveloper = true` — use local cached files without forced refresh.
- `shared.TenacityIndependent = true` — load the shell without game modules.
- `shared.TenacityRepository = "owner/repo"` — override the remote repository.
- `shared.TenacityBranch = "branch"` — override the remote branch.
