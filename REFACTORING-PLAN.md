# Songbook3 Refactoring Plan

## Goal

Make the UI easy to change.

Each visible area should be a reasonably self-contained component with a small, direct API. `SongbookWindow` should compose those components, connect their callbacks, and lay them out. Domain modules should own shared data and behavior.

Do not add abstraction for its own sake. Components may use domain modules directly when that keeps the code clear. If a domain-model change requires corresponding UI changes, that is acceptable and often preferable: compile failures and focused test failures make the dependency visible.

The result should be simple enough that a component can be replaced, heavily modified, or removed without tracing unrelated behavior through the entire window.

## Current State

Completed:

- `SettingsManager` owns settings defaults, loading, saving, and song-data reload.
- `SongLibrary` owns database validation, navigation, filtering, and most selection state.
- `SyncManager` owns chat parsing and synchronization state.
- `InstrumentManager` owns instrument names, aliases, matching, and equipped-instrument detection.
- Colors and localized strings live in `ColorTheme` and `Lang`.
- The visible song UI uses `SongFileBrowser`, `TrackDetailPanel`, `TrackListPanel`, and `DescriptionPanel`.
- `PlayerSyncPanel` and `ControlBar` have been extracted.
- Runtime song-library refresh is implemented and tested.

Still transitional:

- `SongbookWindow.lua` is about 3,000 lines and still owns filters, instrument slots, timer/header behavior, footer buttons, setup behavior, party-list coordination, and popup windows.
- Hidden `dirlistBox`, `songlistBox`, and `listboxSetups` controls still duplicate visible component state.
- Old and new song/setup selection paths coexist.
- Layout calculations remain mixed into `SongbookWindow:ReflowLayout()` and some event handlers.
- Extracted components still have uneven APIs and some rely on globals or window-owned behavior.
- `SongDB`, settings tables, and mutable `SongLibrary` fields are still accessed directly in many places.

## Remaining Work

### 1. Verify the Current UI

Before removing compatibility code, smoke-test:

- empty, populated, invalid, and refreshed song libraries
- directory browsing, search, song/track/setup selection, and auto-pick
- resizing and all visibility toggles
- instrument slots, readiness colors, and synchronization
- settings persistence and English, German, and French clients

Fix only regressions that make the next extraction unsafe.

### 2. Remove Hidden Listboxes and Duplicate Selection Paths

- Find every consumer of `dirlistBox`, `songlistBox`, and `listboxSetups`.
- Move those consumers to `SongLibrary`, `SongFileBrowser`, `TrackDetailPanel`, or `TrackListPanel`.
- Keep one song-selection path and one track/setup-selection path.
- Use song and track database indices directly where appropriate; do not preserve UI list indices as application state.
- Remove hidden controls and obsolete population/coloring methods as soon as their last consumers are gone.
- Update the sync payload if removing UI indices requires it, preserving compatibility only where it is actually needed.

Done when the visible components are the only song, track, and setup controls.

### 3. Finish the Main UI Components

Extract or consolidate:

- `FilterPanel`
- `InstrumentSlotsPanel`
- header/status and timer controls
- footer actions such as refresh, settings, and sync info

Review the existing browser, detail, track, sync, description, and control-bar components while doing this.

Component rules:

- A component owns its controls and their local event handling.
- Its public API should usually be a constructor, a few update/show methods, and semantic callbacks.
- Do not expose child controls unless another component genuinely needs them.
- Do not reach into sibling components or `songbookWindow`.
- Passing a domain module or settings table directly is fine when it is simpler than wrapping it.
- Prefer changing a small API over adding a generic event, state, or adapter framework.

Done when a component can be removed or replaced by changing its construction, callback wiring, and layout entry rather than unrelated window logic.

### 4. Extract Main-Window Layout

Create a Turbine-free `MainWindowLayout` module that takes the window size and relevant visibility/state flags and returns named rectangles for the components.

- `SongbookWindow:ReflowLayout()` should only apply those rectangles.
- Toggle, resize, and instrument-row handlers should update state and call `ReflowLayout()` rather than adjust other controls themselves.
- Include compact and regular arrangements if useful.
- Add table-driven Lua tests for representative sizes, visibility combinations, empty state, long localized labels, and different instrument-row counts.
- Test useful constraints such as minimum sizes and containment without locking every pixel unnecessarily.

Done when trying a different panel order or proportion mainly means editing `MainWindowLayout` and its tests.

### 5. Clean Up Ownership While Touching Each Area

Do this incrementally rather than as a separate architecture project:

- Replace direct `SongDB` access with a `SongLibrary` function when it clarifies ownership or avoids duplicated logic.
- Move mutable selection fields behind `SongLibrary` functions when their current use causes multiple update paths.
- Replace direct settings mutation where a focused settings function makes the lifecycle clearer.
- Give popup windows a clear owner instead of module-level globals.
- Remove callbacks when their owner is destroyed or unloaded.
- Delete unused `InstrumentSlots.lua`, or replace the inline implementation with a corrected version of it.

Do not create broad wrapper layers. Add the smallest API that makes the current component understandable.

### 6. Slim `SongbookWindow`

The final window should:

- create top-level components and auxiliary windows
- connect component callbacks to domain operations
- apply layout results
- own resize, drag, close, save, and unload behavior

Aim for roughly 300-600 lines, but favor clear code over a line-count target. Delete old paths immediately after migration rather than leaving compatibility code without a consumer.

## Verification

Automated checks:

1. `luajit tests/SongLibraryTest.lua`
2. `luajit tests/SettingsManagerTest.lua`
3. Compile every `src/*.lua` file with LuaJIT.
4. Run `MainWindowLayout` tests once that module exists.

After each component or selection change, load the plugin in-game and test the affected workflow. After layout changes, test minimum and large window sizes, visibility combinations, empty data, instrument rows, and localized clients.

## Known Cleanup

- `InstrumentSlots.lua` is unused and contains a `self.slots[i][i]` indexing bug.
- French and German localization coverage is incomplete.
- Auto-part selection across setups needs verification after selection paths are unified.
- The sync payload contains UI indices that may no longer be useful after hidden controls are removed.
