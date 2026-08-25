# Songbook3 Refactoring Plan

## Current State

`SongbookWindow.lua` has fallen from roughly 5,000 to about 3,500 lines, but it is still a transitional shell. Domain and service modules now exist, and the visible song browser uses two components. Several hidden legacy listboxes are still populated because sync and selection code reaches into their state. That compatibility bridge—not the visible panel count—is now the main architectural constraint.

The immediate goal is to make layout experiments safe and cheap. A UI variation should be expressible by changing a pure layout policy and component composition, without editing selection, sync, persistence, or instrument logic.

## Principles

- Every commit leaves the plugin loadable and preserves existing workflows.
- Extract around explicit contracts; do not merely move global coupling into another file.
- Keep one owner for each kind of state. Persistence loads data, domain modules validate and own it, and UI components render it.
- Prefer pure calculations and Lua-only tests for layout and domain behavior. Turbine integration still receives an in-game smoke test.
- Fix defects that block an extraction or make its boundary unsafe. Keep unrelated behavior changes separate.
- Delete a compatibility path as soon as its final consumer has migrated.

## Completed Foundation

- **SettingsManager** (`src/SettingsManager.lua`) — typed defaults, legacy coercion, load/save, and asynchronous runtime loading of `SongbookData`.
- **SongLibrary** (`src/SongLibrary.lua`) — database validation and atomic replacement, sorting, directory traversal, search/filtering, selection state, and database-change events. The global `SongDB` is retained temporarily as a compatibility bridge.
- **SyncManager** (`src/SyncManager.lua`) — chat parsing, player/readiness state, protocol handling, and UI callbacks.
- **InstrumentManager** (`src/InstrumentManager.lua`) — instrument registry, aliases, matching, and equipped-instrument detection.
- **ColorTheme** (`src/ColorTheme.lua`) — centralized colors and track-state color selection.
- **Lang** (`src/Lang.lua`) — English defaults with German/French overrides and fallback behavior.
- **Utils** (`src/Utils.lua`) — shared callback helpers.
- **Layout** (`src/Layout.lua`) — visibility-aware vertical/horizontal stacking used by the main lists and settings window.
- **SongFileBrowser** (`src/SongFileBrowser.lua`) — breadcrumb/flat directory and song browser.
- **TrackDetailPanel** (`src/TrackDetailPanel.lua`) — track and setup presentation.
- **Runtime song-library refresh** — manual button and shell command; invalid data cannot replace the active library.
- **Settings window reflow** — settings controls no longer depend on a mixture of absolute and relative positions.

## Ownership Model

| Concern | Owner | Transitional dependency to remove |
|---|---|---|
| PluginData I/O and settings persistence | `SettingsManager` | Global `Settings`/`CharSettings` access |
| Song database validity, sorting, navigation, and selection | `SongLibrary` | Global `SongDB` access from UI/sync code |
| Player readiness and sync protocol | `SyncManager` | Callbacks that still expect hidden listbox state |
| Instrument identity and matching | `InstrumentManager` | Inline slot construction in `SongbookWindow` |
| Geometry policy | future `MainWindowLayout` | Geometry mixed into event handlers and `ReflowLayout()` |
| Rendering and user input | UI components | Direct access to domain globals |

Runtime refresh follows one direction:

`SettingsManager.Load from disk → SongLibrary.Validate/Replace → SongbookWindow coordinates component refresh`

The persistence layer does not mutate the active database, and the window does not validate database structure.

## Remaining Work Order

### 1. Stabilize the Current Integration

- Exercise initial empty-library, empty-to-populated refresh, populated-to-empty refresh, invalid refresh, and repeated refresh flows in-game.
- Verify selection preservation when the same song still exists and deterministic fallback when it does not.
- Verify show/hide toggles, resizing, filters, setup selection, instrument rows, sync colors, and all three client languages.
- Remove any remaining geometry mutation from toggle and add/remove-row handlers; `ReflowLayout()` must be the only geometry applicator.

Exit condition: the current two-panel UI and runtime refresh pass the smoke-test matrix without relying on a plugin reload.

### 2. Add a Pure Main-Window Layout Model

Create `src/MainWindowLayout.lua` with no Turbine dependency. It accepts window size and UI state and returns named rectangles/visibility for:

- header/status area
- search row
- browser
- track detail
- filter/player overlay or future side panel
- instrument slots
- footer actions
- empty-library message

Include minimum sizes, clamping, and explicit compact/regular layout modes. `SongbookWindow:ReflowLayout()` should only apply these calculated regions to controls.

Add Lua-only table-driven tests for representative window sizes and combinations of search, tracks, filters, and instrument rows. These tests are the infrastructure that makes alternate layouts inexpensive to prototype.

Exit condition: experimenting with panel order, ratios, or compact mode requires changing the layout model and tests, not event handlers.

### 3. Retire the Hidden Browser/Listbox Compatibility Path

Map every consumer of `dirlistBox`, `songlistBox`, `tracklistBox`, and `listboxSetups`. Move each consumer to one of:

- `SongLibrary` query/selection methods
- `SongFileBrowser` display APIs
- `TrackDetailPanel` display/readiness APIs
- an explicit callback between a component and the shell

Then delete the four hidden controls and the duplicate `SelectSong`/`SelectSongByIndex`, `ListTracks`, and setup-population paths. Preserve a single selection representation: database song index plus actual track index.

Exit condition: the visible browser/detail components are the only song-list UI, and sync behavior does not depend on invisible controls.

### 4. Complete UI Component Boundaries

Extract components in dependency order:

| Component | Responsibility |
|---|---|
| `FilterPanel` | Filter values, visibility, and change events |
| `InstrumentSlotsPanel` | Row/slot construction and drag/drop persistence |
| `PlayerSyncPanel` | Party members and readiness presentation |
| `HeaderStatusPanel` | Current song/track, timer, and sync status messages |
| `ControlBar` | Music/play/ready/sync/share actions |
| `FooterBar` | Refresh, settings, and sync-info actions |

Each component receives dependencies or data in its constructor/method calls and exposes callbacks. It must not reach into `songbookWindow` or sibling controls.

Move popup/window ownership (`MatchedSongsWindow`, sync-start confirmation, help, timer, player sync info) out of module-level globals and give each a clear lifecycle owner.

Exit condition: components can be reordered or omitted without changing their internal behavior.

### 5. Tighten Domain Contracts

- Replace direct `SongDB` reads with `SongLibrary` query methods, then make the database private to the module.
- Replace mutable public selection fields with selection methods/events.
- Define one callback/event convention and unsubscribe during teardown where necessary.
- Replace direct global settings mutation with explicit settings APIs or injected settings tables.
- Version the `@SBL` sync payload before removing or reordering protocol fields.

Exit condition: domain modules can be tested without creating UI controls, and UI components do not mutate domain tables directly.

### 6. Slim the Window Shell

`SongbookWindow` should ultimately:

- create top-level components and auxiliary windows
- wire component callbacks to domain operations
- request and apply the main-window layout
- own resize, drag, close, save, and unload lifecycle

Target roughly 300–600 lines. The exact count matters less than eliminating duplicated behavior and cross-component reach-through.

## Infrastructure Missing From the Original Plan

These items are required even though the earlier roadmap did not name them:

- **A pure, named-region layout policy with table-driven tests.** The generic stacking helper alone cannot make multi-layout experiments safe.
- **An explicit migration seam and deletion criteria for legacy hidden controls.** Extracting new panels without retiring the old state path leaves two UI models to maintain.
- **A single ownership/transaction model for runtime database replacement.** Validation must occur before mutation, and failed refreshes must roll back by doing nothing.
- **Component contracts and dependency direction.** File extraction is insufficient if components continue to share globals and manipulate siblings.
- **Lifecycle ownership for callbacks, popup windows, and unload behavior.** Module-level windows and never-removed callbacks make future composition brittle.
- **Automated tests at domain and layout boundaries.** In-game testing remains essential, but it is too slow to support rapid ergonomic iteration by itself.
- **A verification matrix for empty, refreshed, localized, compact, and sync states.** Layouts must be tested across state combinations, not only at one default size.

## Known Issues and Cleanup

- `InstrumentSlots.lua` is currently unused and contains the `self.slots[i][i]` indexing bug. Either replace inline slot code with a corrected component or delete the file.
- French/German coverage is incomplete and some strings still use escaped byte sequences; remaining hard-coded UI strings must move into `Lang.lua`.
- Auto-part selection across different setups still needs focused verification after the selection paths are unified.
- Sync payload fields include UI indices that are not meaningful between clients; address this with protocol versioning.

## Verification

Automated checks:

1. `luajit tests/SongLibraryTest.lua`
2. `luajit tests/SettingsManagerTest.lua`
3. Compile every `src/*.lua` file with LuaJIT bytecode compilation.
4. Run future `MainWindowLayout` table-driven tests for all supported modes.

In-game smoke test after each architectural step:

1. Load with `/plugins load Songbook3` using populated and empty libraries.
2. Browse directories, search/filter, choose setups/tracks, and resize at minimum and large sizes.
3. Toggle search, tracks, filters, instrument rows, timer, and sync controls.
4. Regenerate the filler output and refresh using both the button and shell command.
5. Confirm invalid refresh data leaves the active library untouched.
6. Verify instrument equipping, party readiness, sync matching, and settings persistence.
7. Repeat localization-sensitive changes on English, German, and French clients.
