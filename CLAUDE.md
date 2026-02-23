# Songbook3 — LOTRO Lua Plugin

## Project

A music performance management plugin for The Lord of the Rings Online. See `REFACTORING-PLAN.md` for the current refactoring roadmap.

## LOTRO Lua Plugin API

Reference documentation is in `LOTRO-LUA-PLUGIN-API.md`.

## Conventions

### Naming
- `PascalCase` for classes and modules (e.g. `SongLibrary`, `SyncManager`)
- `camelCase` for local variables and function parameters
- Apply these conventions as code is refactored — don't do bulk renames across untouched code

### Settings
- All settings use native Lua types (booleans, numbers, strings) — never store `"yes"`/`"no"` or `"true"`/`"false"` strings
- Settings are managed by `src/SettingsManager.lua`. Use `SettingsManager.Save()` to persist
- SongDB is read-only from the plugin's perspective (created by external filler applications)

### Code style
- When removing old code, just remove it. Don't leave comments explaining what was removed or why — that's what git history is for
- Don't add comments restating what the code does. Only comment when the *why* isn't obvious
- Semicolons are optional in Lua but the existing codebase uses them inconsistently. Don't add them to new code, don't bulk-remove them from old code

### Module pattern
- Extracted modules are global tables with functions: `ModuleName = {}` then `function ModuleName.DoThing()`. See `src/SettingsManager.lua` as the reference example
- UI components use the `class(Turbine.UI.Control)` pattern and receive dependencies via constructor injection
- Modules communicate outward via callbacks/events, not by reaching into globals like `songbookWindow`

### Import order
- `import` in LOTRO Lua executes all module-level code immediately. Any code at the top level of a file runs at import time, not when you first call a function
- This means: if a module references a global (like `Settings`) at module level, that global must already exist when the file is imported
- `src/Main.lua` controls import order. New modules that depend on `Settings` must be imported after `SettingsManager.Load()`
- When creating a new module, prefer deferring global access to function bodies rather than module-level code

### Refactoring approach
- Each change must leave the plugin fully functional
- Clean up naming and style as code is moved to new modules, not as a separate pass
- Bug fixes are deferred until the relevant code has been extracted to its proper module (see known bugs in `REFACTORING-PLAN.md`)
- Before extracting a module, identify the exact methods to move and map their dependencies on other parts of SongbookWindow. Don't start extracting until the boundary is clear

## Testing

No automated tests. Verify changes by loading the plugin in-game:
1. `/plugins load Songbook3`
2. Check song browsing, track selection, instrument equipping, sync
3. Check settings persist across plugin reload
4. Test with German/French client if touching localization
