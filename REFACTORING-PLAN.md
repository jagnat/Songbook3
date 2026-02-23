# Songbook3 Refactoring Plan

## Context

SongbookWindow.lua is a ~5,000-line monolith containing ~150 methods that handles UI layout, business logic, sync management, settings, filtering, instrument matching, and color theming all in one class. This makes it extremely difficult to modify without breaking things. The codebase has accumulated contributions from multiple authors (Chiran, Brandy Badgers, Almiyan, Elamond) without consistent conventions.

The goal is to decompose this into focused, composable modules. Bug fixes come after the skeleton is strong — fixing bugs in code that's about to be extracted is wasted effort, and bugs often resolve themselves once logic is properly isolated.

## Principles

- **Each step leaves the plugin fully functional.** No intermediate broken states.
- **Naming and style cleanup happens during extraction**, not as a separate pass. When code moves to a new module, it gets cleaned up as part of that move. This avoids context explosion and keeps git history meaningful.
- **Start with the hard stuff.** The domain logic extractions (SongLibrary, SyncManager) are the meatiest changes and make the codebase navigable. Do those first.
- **Defer bug fixes.** Known bugs are catalogued but not addressed until the refactoring provides a clean place to fix them.

## Completed

- **SettingsManager** (`src/SettingsManager.lua`) — centralized settings with typed defaults, load/save, legacy coercion. All string-based `"yes"`/`"no"`/`"true"`/`"false"` comparisons replaced with native booleans across the codebase.

## Work Order

### 1. Layout Utility (`src/Layout.lua`)

Do this early so extracted panels can use it from the start rather than carrying over pixel-math and being rewritten later.

- Helper functions for vertical/horizontal stacking, padding, sizing
- Something like: `Layout.stackVertical(parent, children, { gap = 4, padding = 8 })`
- Each child declares its preferred height (or `"fill"` for remaining space)
- Replaces the current approach of manually calculating pixel offsets everywhere
- `ReflowLayout()` was a good start — this formalizes the pattern
- **Declarative panel visibility**: panels register with the layout system; toggling visibility triggers automatic reflow

### 2. SongLibrary (`src/SongLibrary.lua`)

The core domain model. Extract song/directory/track data management out of SongbookWindow.

- Owns song loading, directory traversal, search, and filtering
- Holds the song list, selected song/track/directory state
- Filtering logic extracted here (`ApplyFilters`, `ParsePartsFilter`, `MatchStringList`)
- Emits events when selection or filter state changes
- SongDB is read-only (created by external filler applications)

### 3. SyncManager (`src/SyncManager.lua`)

The ~1,500 lines of sync logic are the second largest concern after UI.

- Chat message parsing, player state tracking, ready-state calculation
- Owns `aPlayers`, sync state, the `@SBL` protocol
- Replaces the current ChatHandler stub and the inline sync methods
- Emits events when player states change (so the UI can react)

### 4. InstrumentManager (`src/InstrumentManager.lua`)

Self-contained domain module.

- Instrument definitions, display names, and fuzzy matching consolidated here
- The two parallel arrays (`Instruments_List` + `Instruments_Names_inTrack`) unified into a single instrument registry: `{ id, displayName, aliases = {...} }`
- `FindInstrumentInTrack()`, `CheckInstrument()`, `CompareInstrument()` live here
- Makes adding new instruments trivial (just add a data entry)

### 5. ColorTheme (`src/ColorTheme.lua`)

Quick win — the 40+ color definitions from the constructor become a theme table.

- Functions like `GetColourForTrack()`, `GetBackColourForTrack()` live here
- Makes it possible to tweak the color scheme in one place

### 6. Language/Localization cleanup (`src/Lang.lua`)

- Fix French/German encoding issues (ensure consistent UTF-8)
- Complete missing translations
- Add instrument name translations
- Add fallback-to-English for any missing key
- Consider a simple `T("key")` function pattern instead of `Strings.key`

### 7. UI Component Extraction

With domain logic extracted, break SongbookWindow into composable panels:

| Component | File | Responsibility |
|-----------|------|----------------|
| `SongListPanel` | `src/ui/SongListPanel.lua` | Directory browser + song listbox + search bar |
| `TrackListPanel` | `src/ui/TrackListPanel.lua` | Track listbox + track details |
| `FilterPanel` | `src/ui/FilterPanel.lua` | Filter UI controls |
| `PlayerSyncPanel` | `src/ui/PlayerSyncPanel.lua` | Party member sync status display |
| `DescriptionPanel` | `src/ui/DescriptionPanel.lua` | Song description/metadata display |
| `ControlBar` | `src/ui/ControlBar.lua` | Play/stop buttons, timer controls |

Each panel:
- Is a `class(Turbine.UI.Control)` that can be parented to anything
- Receives its data source (SongLibrary, SyncManager, etc.) via constructor injection
- Handles its own internal layout using the Layout utility
- Communicates outward via events, not by reaching into globals

### 8. Final SongbookWindow Slimdown

SongbookWindow becomes the shell — it just:
- Creates the panels
- Wires them together (SongListPanel selection → TrackListPanel update, etc.)
- Manages the main window frame (resize, drag, close)
- Uses Layout to arrange panels
- Target: ~200-300 lines instead of 5,000+

## Architectural Ideas

**Event bus pattern**: A simple pub/sub module (`src/EventBus.lua`) where modules can `emit("songSelected", song)` and `on("songSelected", callback)`. Replaces modules directly calling each other's methods and eliminates most globals. Lightweight — ~30 lines of Lua.

**Instrument registry as data**: Instrument definitions as a pure data table (could be a separate `.lua` file that just returns a table). Adding new instruments (like Jaunty Hand-knells) becomes a data entry, not a code change.

## Known Bugs (deferred)

These will be addressed once the relevant code has been extracted to its proper module:

- **Filtering bugs**: address after SongLibrary extraction
- **Translation/encoding issues**: address during Lang cleanup
- **Auto-part-select not working on different setups**: address after InstrumentManager extraction
- **InstrumentSlots.lua line 77 bug**: `self.slots[i][i]` should be `self.slots[i][j]`
- ~~**Help window "don't show again"**: fixed~~

## Verification

After each extraction step:
1. Load the plugin in-game with `/plugins load Songbook3`
2. Verify song browsing, track selection, instrument equipping, sync all still work
3. Test with German/French client language settings
4. Check settings persist across plugin reload
