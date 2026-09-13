# Tenacity migration

This build is fully branded as Tenacity. Runtime globals, cache paths, UI names, logs, assets, API names and loader state use `Tenacity` / `tenacity/`.

## Runtime

- Core: `shared.Tenacity`
- API: `shared.TenacityAPI`
- Runtime: `shared.TenacityRuntime`
- Local cache root: `tenacity/`
- UI: `guis/tenacity.lua`
- API file: `libraries/tenacity-api.lua`

Re-executing in the same Roblox session hot-reloads the current build. The loader also detects the immediately previous in-session build and uninjects it during the one-time transition.

## Game modules

Universal and game-specific modules use Tenacity API v3. Shared Krs-style HUD helpers are shipped in `libraries/krs-render.lua`, so Universal no longer depends on a missing renderer file.
