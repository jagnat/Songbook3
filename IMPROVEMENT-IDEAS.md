# Songbook3 Improvement Ideas

Post-refactoring feature and UX improvements. These should be tackled after the core refactoring plan is complete.

## Priority Order

### 1. Dynamic SongDB Reload
**Effort: Low | Impact: High**

`PluginData.Load()` is async after startup (takes a callback), so a refresh button is trivial:
```lua
Turbine.PluginData.Load(Turbine.DataScope.Account, "SongbookData", function(loadedData)
    SongDB = loadedData
    SongLibrary.Init()
    -- refresh UI
end)
```
Periodic background refresh via the `Update` callback with a timer interval also works. Currently the plugin must be fully reloaded to pick up new songs.

### 2. Collapse Directory/Song/Track Into Fewer Panels
**Effort: Moderate–High | Impact: High**

The three-panel split (directories → songs → tracks) is the biggest source of UI bloat. Options:
- **Tree view**: Directories expand inline to show songs, songs expand to show tracks. Single listbox, hierarchical. LOTRO's listbox API doesn't have native tree support — fake it with indentation and expand/collapse icons per row.
- **Breadcrumb + flat list**: Breadcrumb path at top, flat list shows current level contents. Click a song to expand tracks inline.
- **Two panels max**: Directory browser on left, song+tracks on right (tracks inline under selected song).

Tree view is probably the best approach despite requiring the most work.

### 3. Move Instrument Slots Closer to Sync Buttons
**Effort: Low | Impact: Medium**

Currently slots are anchored to window bottom (`height - 75`), sync buttons are near the top (`y=100`). Moving them just below the button row (~`y=135`) reduces click distance for part queueing. Trade-off: eats into listbox area, but slots already toggle via `CharSettings.InstrSlots[1]["visible"]`.

Note: `InstrumentSlots.lua` is dead code (never instantiated, has the `[i][i]` bug). Either delete it or fix and use it as the extracted component. Real slot code lives inline in SongbookWindow lines 1196–1298.

### 4. Rework Filter UI
**Effort: Medium | Impact: Medium**

Currently five filter rows (Parts/Artist/Genre/Mood/Author) are crammed into the left column alongside the directory listbox. They're mutually exclusive with track list visibility and progressively hide based on available height.

Options:
- **Dropdown/popover panel**: Click a filter icon → floating panel with all filter fields. Keeps main layout clean.
- **Structured search bar**: Single input accepting `artist:Beatles genre:rock` syntax. Compact, power-user friendly.
- Separate window is overkill for five text filters.

### 5. Remove Toggle Button / Rework Timer Window
**Effort: Low | Impact: Low–Medium**

`TimerWindow` (150×94px) already toggles songbook visibility on click. Remove `ToggleWindow.lua` entirely. For compactness: make the timer collapse to ~35×35 when idle (no song playing) and expand during playback. Best of both worlds — unobtrusive when idle, informative when playing.

### 6. Sync Message Format Versioning
**Effort: Low | Impact: Medium (long-term)**

Current `@SBL` message has 12 pipe-delimited fields, some redundant (`SongIndexListBox` is meaningless across different players' sessions). Options:
- **Version field**: `@SBL|v3|...` — receivers that don't know `v3` ignore it, future-proofs changes. Best approach.
- **New marker** (`@SB3`): Clean break from Songbook 2. Simplest but loses cross-version sync.
- **Compress but stay compatible**: Drop unused fields, keep `@SBL` marker.

Lean toward version field — minimal cost, maximum flexibility. Do whenever sync code is next touched.

### 7. Instrument Config Sharing Between Characters
**Effort: Medium | Impact: Medium**

API limitation: **cannot programmatically set Quickslot contents** — only player drag-and-drop works. So "auto fill" isn't possible.

What IS possible: save instrument slot assignments as data (`PluginData.Save` with `Account` or `Server` scope), then display visual indicators showing which slot should hold which instrument. Player fills manually on new characters guided by the template. Essentially a "setup guide" rather than auto-fill.

### 8. Part Setup UI Improvements
**Effort: Medium | Impact: Medium**

Related to the filter UI problem — too many controls in the main window. A popover or expandable section works. Compact inline dropdown per track row for instrument assignment could reduce clicks. Depends on whether the tree view (idea #2) is implemented first.

## Additional Ideas

### Favorites / Recent Songs
Pin songs to a favorites list at top of the browser. Store in `CharSettings` or `Account` scope. Very common request.

### Set Lists
Pre-ordered lists of songs to play in sequence. "Next" button advances through the list. Good for concerts.

### Better Party Readiness Overview
Compact grid showing player × instrument status at a glance instead of text-heavy display.

### Search-as-you-type
The search input exists but could filter the listbox live while typing rather than requiring a button click.

## API Constraints to Keep in Mind

- **No filesystem access**: Sandboxed Lua, no `io.open`/`dofile`/`os.*`. SongDB only via `PluginData.Load()`.
- **No programmatic game actions**: All actions (equip, play, chat) go through Alias shortcuts on Quickslots that the player must click.
- **No direct chat sending**: Can only listen via `Turbine.Chat.Received` and construct Alias shortcuts.
- **Async PluginData after startup**: `Load()`/`Save()` are synchronous only during plugin load, async with callbacks after.
- **Quickslot self-drop bug**: Even with `SetAllowDrop(false)`, slots can self-drop. Current workaround: `DragDrop` handlers restore the shortcut.
- **`SetWantsUpdates` has real cost**: Only enable the Update callback when actively needed (timer running).
