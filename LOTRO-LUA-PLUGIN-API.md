# LOTRO Lua Plugin Scripting API Reference

> Synthesized from the official SSG Update 25 documentation, the community LotroDocs project, Garan's "Writing LotRO Lua Plugins for Noobs" tutorial, and recent patch notes. Use this as context when developing LOTRO Lua plugins.

## Table of Contents

- [Overview](#overview)
- [Plugin Structure](#plugin-structure)
- [Lua Environment](#lua-environment)
- [Plugin Lifecycle](#plugin-lifecycle)
- [The Turbine Class System](#the-turbine-class-system)
- [API Reference: Turbine (Core)](#api-reference-turbine-core)
- [API Reference: Turbine.Gameplay](#api-reference-turbinegameplay)
- [API Reference: Turbine.Gameplay.Attributes](#api-reference-turbinegameplayattributes)
- [API Reference: Turbine.UI](#api-reference-turbineui)
- [API Reference: Turbine.UI.Lotro](#api-reference-turbineuilotro)
- [Enumerations](#enumerations)
- [Event Handling](#event-handling)
- [Data Persistence](#data-persistence)
- [Shell Commands](#shell-commands)
- [Internationalization](#internationalization)
- [Undocumented Features](#undocumented-features)
- [UI Scaling (Recent Patch)](#ui-scaling-recent-patch)
- [Common Patterns](#common-patterns)
- [Gotchas and Best Practices](#gotchas-and-best-practices)

---

## Overview

LOTRO plugins are written in **Lua 5.1** and use the **Turbine API** to interact with the game client. Plugins can create UI windows, read game state (player stats, effects, inventory, party), respond to events, register chat commands, and persist data.

The API is organized into four main packages, each requiring a separate `import` statement:

| Package | Import | Purpose |
|---------|--------|---------|
| `Turbine` | `import "Turbine"` | Core: Engine, Chat, Shell, Plugin, PluginData, PluginManager |
| `Turbine.Gameplay` | `import "Turbine.Gameplay"` | Game state: LocalPlayer, Actor, Party, Effects, Items, Skills |
| `Turbine.UI` | `import "Turbine.UI"` | Base UI: Control, Label, Button, ListBox, Window, ScrollBar, etc. |
| `Turbine.UI.Lotro` | `import "Turbine.UI.Lotro"` | LOTRO-skinned UI: Window, Button, CheckBox, Quickslot, etc. |

**Key constraints:**
- Plugins are **read-only** -- they can read game state but cannot perform actions (equip items, cast skills, etc.) except via Quickslot shortcuts
- Supported image formats: `.jpg` and `.tga` only
- Files must be **UTF-8 without BOM** (pre-Win11 Notepad adds BOM -- use a different editor)
- Almost everything is **case-sensitive**

---

## Plugin Structure

### File Organization

```
Documents\The Lord of the Rings\Plugins\
  AuthorName\
    PluginName.plugin          -- XML plugin descriptor
    PluginName.plugincompendium -- optional, for Plugin Compendium
    PluginName\
      __init__.lua             -- optional, auto-loaded before other files in folder
      Main.lua                 -- main entry point (referenced by .plugin Package)
      OtherModule.lua          -- additional modules
      Resources\
        icon.tga               -- image assets
        background.jpg
```

### The .plugin File (XML)

```xml
<?xml version="1.0"?>
<Plugin>
    <Information>
        <Name>PluginName</Name>
        <Author>AuthorName</Author>
        <Version>1.00</Version>
        <Description>Plugin description text</Description>
        <Image>AuthorName/PluginName/Resources/icon.jpg</Image>
    </Information>
    <Package>AuthorName.PluginName.Main</Package>
    <Configuration Apartment="PluginName" />
</Plugin>
```

| Element | Description |
|---------|-------------|
| `<Name>` | Used in `/plugins load`, `/plugins list`, and `Plugins["Name"]` table |
| `<Author>` | Organizational/documentary |
| `<Version>` | Shown in `/plugins list`, accessible via `Plugin:GetVersion()` |
| `<Description>` | Shown in Plugin Manager UI |
| `<Image>` | Path to icon (.jpg/.tga), cropped to 32x32 if larger, tiled if smaller |
| `<Package>` | Dot-separated path to main .lua file (e.g., `Author.Plugin.Main` -> `Author/Plugin/Main.lua`) |
| `<Configuration>` | Optional. `Apartment` name defines a separate script state (address space). Omit to use the shared default apartment. Using a separate apartment increases memory but allows independent unloading. |

### The `__init__.lua` File

If present in a folder, it is executed **before** any other files in that folder. Used to import dependencies in the correct order:

```lua
import "AuthorName.PluginName.Utilities"
import "AuthorName.PluginName.MyWindow"
```

Files are processed in the order they are imported -- dependent files must be loaded after the ones that define their dependencies.

### The .plugincompendium File (for Plugin Compendium)

```xml
<?xml version="1.0" encoding="utf-8"?>
<PluginConfig xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Id>532</Id>
  <Name>PluginName</Name>
  <Version>1.00</Version>
  <Author>AuthorName</Author>
  <InfoUrl>http://www.lotrointerface.com/downloads/info532</InfoUrl>
  <DownloadUrl>http://www.lotrointerface.com/downloads/download532</DownloadUrl>
  <Descriptors>
    <descriptor>AuthorName\PluginName.plugin</descriptor>
  </Descriptors>
  <Dependencies />
</PluginConfig>
```

The `<Id>` is assigned by lotrointerface.com after the first upload.

---

## Lua Environment

- **Lua version:** 5.1
- **`import` statement:** LOTRO-specific, loads Turbine API packages and user modules. Uses dot-notation path (e.g., `import "Turbine.UI.Lotro"`).
- **`class()` function:** LOTRO-specific (from Turbine samples). Creates classes with inheritance. Must be imported from your own copy of `Class.lua`.
- **Global `Plugins` table:** All loaded plugins are registered as `Plugins["PluginName"]`.
- **Global `__plugins` table:** Alternative name for the plugins table.
- **Semicolons:** Optional but commonly used. Multiple statements per line separated by `;`.

---

## Plugin Lifecycle

### Loading

1. `/plugins load PluginName` (not case-sensitive for the load command)
2. `.plugin` file is parsed
3. If `Apartment` specified and doesn't exist, a new script state is created
4. `__init__.lua` in the package folder is executed (if present)
5. The file specified in `<Package>` is loaded and executed sequentially

### During Loading

- The temporary variable **`plugin`** (lowercase) references the current plugin instance
- `PluginData.Load()` is **synchronous** (returns data immediately)
- After loading completes, `plugin` becomes nil -- use `Plugins["PluginName"]` instead
- After loading, `PluginData.Load()` becomes **asynchronous** (uses callbacks)

### Unloading

Plugins are **not** unloaded individually -- **Apartments (script states) are unloaded**. `/plugins unload ApartmentName` unloads ALL plugins sharing that apartment. A plugin **cannot unload its own apartment**.

Register an Unload handler to clean up:

```lua
-- During loading (using the temporary plugin variable):
plugin.Unload = function()
    -- Save data, remove commands, deactivate event handlers
end

-- After loading (using the Plugins table):
Plugins["PluginName"].Unload = function(self, sender, args)
    -- Save data, remove commands, deactivate event handlers
end
```

**CRITICAL:** Never assign directly to `Turbine.Plugin.Unload` -- this overwrites ALL other plugins' unload handlers in the apartment. Always use `plugin.Unload` or `Plugins["Name"].Unload`.

**Three things to handle in Unload:**
1. Save persistent data
2. Remove registered shell commands
3. Deactivate/unregister event handlers (especially on shared objects like Chat)

---

## The Turbine Class System

Lua is not OOP, but the Turbine `class()` function provides class-like behavior with inheritance.

### Creating a Class

```lua
import "AuthorName.PluginName.Class" -- import the class() function

MyWindow = class(Turbine.UI.Lotro.Window)

function MyWindow:Constructor()
    Turbine.UI.Lotro.Window.Constructor(self) -- MUST call parent constructor
    self:SetSize(300, 200)
    self:SetText("My Window")
    self:SetVisible(true)
end
```

### Instantiation

```lua
local win = MyWindow()
```

### The `.` vs `:` Syntax

| Declaration | Call | `self` | First arg |
|------------|------|--------|-----------|
| `function obj:Method(arg)` | `obj:Method("hi")` | obj reference | "hi" |
| `function obj:Method(arg)` | `obj.Method("hi")` | "hi" | nil |
| `obj.Method = function(arg)` | `obj.Method("hi")` | nil | "hi" |
| `obj.Method = function(arg)` | `obj:Method("hi")` | nil | obj reference |

**Best practice:** Use `:` for both declaration and calling. This ensures `self` always refers to the instance.

---

## API Reference: Turbine (Core)

### Turbine.Engine (static)

| Method | Returns | Description |
|--------|---------|-------------|
| `GetCallStack([thread,][msg[,level]])` | string | Current callstack (equivalent to `debug.traceback`) |
| `GetDate()` | table | `{Year, Month, Day, Hour, Minute, Second, DayOfWeek, DayOfYear, IsDST}` |
| `GetGameTime()` | number | Seconds since servers went live (fractional, ~4 decimal precision). Use for in-game timers. |
| `GetLanguage()` | number | Client language (see `Turbine.Language` enum) |
| `GetLocale()` | string | OS locale string (NOT client language -- use GetLanguage instead) |
| `GetLocalTime()` | number | Seconds since Jan 1 1970 UTC (integer only) |
| `GetScriptVersion()` | number, number | Major and minor Lua API version (independent from client version) |
| `ScriptLog(message)` | nil | Write to the shared script log |

### Turbine.Chat

| Member | Type | Description |
|--------|------|-------------|
| `Received` | static event | Fired on every chat message. Args: `{Sender, ChatType, Message}` |

### Turbine.Plugin

| Method | Returns | Description |
|--------|---------|-------------|
| `GetAuthor()` | string | Author from .plugin file |
| `GetConfiguration()` | string | Configuration element from .plugin file |
| `GetName()` | string | Plugin name |
| `GetVersion()` | string | Plugin version |

| Event | Description |
|-------|-------------|
| `Load` | Fired when main package has finished loading |
| `Unload` | Fired before plugin is unloaded |

### Turbine.PluginData (static)

| Method | Description |
|--------|-------------|
| `Load(scope, key [, callback])` | Load data. Synchronous during plugin loading (returns data directly). Asynchronous after loading (returns nil, invokes callback). |
| `Save(scope, key, data [, callback])` | Save data. Callback signature: `function(succeeded, message)` |

Data is stored in `.plugindata` files. Scopes: `Turbine.DataScope.Account`, `.Character`, `.Server`.

### Turbine.PluginManager / Turbine.LotroPluginManager (static)

| Method | Description |
|--------|-------------|
| `GetAvailablePlugins()` | Table of available plugins |
| `GetLoadedPlugins()` | Table of loaded plugins |
| `LoadPlugin(name)` | Load a plugin by name |
| `RefreshAvailablePlugins()` | Refresh from disk |
| `UnloadScriptState(state)` | Unload a script state (cannot unload own state) |
| `ShowOptions(plugin)` | Display plugin options panel (LotroPluginManager only) |

### Turbine.Shell (static)

| Method | Description |
|--------|-------------|
| `AddCommand(name, command)` | Register a shell command |
| `GetCommands()` | Get list of available commands |
| `IsCommand(name)` | Test if a command name is registered |
| `RemoveCommand(command)` | Remove a registered command |
| `WriteLine(text)` | Write to Standard chat channel (great for debugging) |

### Turbine.ShellCommand

| Method | Description |
|--------|-------------|
| `Execute(cmd, args)` | Called when the command is executed |
| `GetHelp()` | Return help text |
| `GetShortHelp()` | Return short help text |

---

## API Reference: Turbine.Gameplay

### Class Hierarchy

```
Turbine.Object
  +-- EntityReference
  |     +-- PropertyHandler
  |     |     +-- Attributes / ClassAttributes (see Attributes section)
  |     |     +-- Entity
  |     |           +-- Item
  |     |           +-- Mount -> BasicMount, CombatMount
  |     |           +-- Actor
  |     |                 +-- Pet
  |     |                 +-- Player
  |     |                       +-- LocalPlayer
  |     |                       +-- PartyMember
  +-- Backpack
  +-- Bank -> Vault, SharedStorage
  +-- Effect
  +-- EffectList
  +-- Equipment
  +-- ItemInfo
  +-- Party
  +-- ProfessionInfo
  +-- Recipe
  +-- RecipeIngredient
  +-- Skill -> ActiveSkill, GambitSkill, UntrainedSkill
  +-- SkillInfo -> GambitSkillInfo
  +-- SkillList
  +-- Wallet
  +-- WalletItem
```

### LocalPlayer

**Singleton access:** `Turbine.Gameplay.LocalPlayer:GetInstance()`

Must create the instance before accessing any player methods.

**Own Methods (inherited from Entity, Actor, Player, and own):**

| Method | Description |
|--------|-------------|
| `GetInstance()` (static) | Get the local player singleton |
| `GetName()` | Character name |
| `GetLevel()` | Character level |
| `GetAlignment()` | FreePeople or MonsterPlayer |
| `GetClass()` | Character class (see Class enum) |
| `GetRace()` | Character race (see Race enum) |
| `GetMorale()` / `GetMaxMorale()` / `GetBaseMaxMorale()` | Current/max/base morale |
| `GetPower()` / `GetMaxPower()` / `GetBaseMaxPower()` | Current/max/base power |
| `GetTemporaryMorale()` / `GetMaxTemporaryMorale()` | Temporary morale |
| `GetTemporaryPower()` / `GetMaxTemporaryPower()` | Temporary power |
| `GetTarget()` | Current target (Actor or nil) |
| `GetEffects()` | EffectList of active effects |
| `GetParty()` | Party the player belongs to |
| `GetPet()` | Player's pet |
| `GetBackpack()` | Player's backpack (inventory) |
| `GetEquipment()` | Player's equipped items |
| `GetVault()` | Player's vault |
| `GetSharedStorage()` | Player's shared storage |
| `GetWallet()` | Player's wallet |
| `GetMount()` | Player's active mount |
| `GetAttributes()` | Race attributes |
| `GetClassAttributes()` | Class-specific attributes |
| `GetRaceAttributes()` | Race-specific attributes |
| `GetTrainedSkills()` | SkillList of trained skills |
| `GetUntrainedSkills()` | SkillList of untrained skills |
| `GetReadyState()` | Ready state (enum) |
| `IsInCombat()` | True if in combat |
| `IsLinkDead()` | True if disconnected |
| `IsVoiceEnabled()` | True if voice enabled |

**Key Events (all fire with sender, args):**

| Event | Description |
|-------|-------------|
| `NameChanged` | Name changes |
| `LevelChanged` | Level changes |
| `MoraleChanged` / `MaxMoraleChanged` / `BaseMaxMoraleChanged` | Morale changes |
| `PowerChanged` / `MaxPowerChanged` / `BaseMaxPowerChanged` | Power changes |
| `TargetChanged` | Target changes |
| `InCombatChanged` | Combat state changes |
| `MountChanged` | Mount changes |
| `PartyChanged` / `RaidChanged` | Party/raid changes |
| `PetChanged` | Pet changes |
| `ReadyStateChanged` | Ready state changes |

### Party

| Method | Description |
|--------|-------------|
| `GetLeader()` | Party leader |
| `GetMember(index)` | Member at index |
| `GetMemberCount()` | Number of members |
| `IsMember(player)` | Check membership |
| `GetAssistTarget(index)` | Assist target at index |
| `GetAssistTargetCount()` | Number of assist targets |
| `IsAssistTarget(player)` | Check if assist target |

| Event | Description |
|-------|-------------|
| `MemberAdded` / `MemberRemoved` | Party membership changes |
| `LeaderChanged` | Leader changes |
| `AssistTargetAdded` / `AssistTargetRemoved` | Assist targets change |

### Effect

| Method | Description |
|--------|-------------|
| `GetName()` | Effect name |
| `GetDescription()` | Effect description |
| `GetID()` | Unique ID |
| `GetIcon()` | Icon resource |
| `GetCategory()` | Effect category (see EffectCategory enum) |
| `GetDuration()` | Duration in seconds |
| `GetStartTime()` | When the effect started |
| `IsCurable()` / `IsDebuff()` / `IsDispellable()` | Effect properties |

### EffectList

| Method | Description |
|--------|-------------|
| `Get(index)` | Get effect at index |
| `GetCount()` | Number of effects |
| `Contains(effect)` / `IndexOf(effect)` | Search |

| Event | Description |
|-------|-------------|
| `EffectAdded` / `EffectRemoved` / `EffectsCleared` | Effect list changes |

### Backpack

| Method | Description |
|--------|-------------|
| `GetItem(index)` | Item at index |
| `GetSize()` | Backpack size |
| `PerformItemDrop(srcIdx, dstIdx)` | Move/swap item in inventory |
| `PerformShortcutDrop(dstIdx, shortcut)` | Drop item into backpack |

| Event | Description |
|-------|-------------|
| `ItemAdded` / `ItemRemoved` / `ItemMoved` / `SizeChanged` | Inventory changes |

### Equipment

| Method | Description |
|--------|-------------|
| `GetItem(slot)` | Item at slot (uses EquipmentSlot enum) |
| `GetSize()` | Number of equipment slots |

| Event | Description |
|-------|-------------|
| `ItemEquipped` / `ItemUnequipped` | Equipment changes |

**Note:** The API docs list `Turbine.Gameplay.EquipmentSlot` for the enum but the correct reference is `Turbine.Gameplay.Equipment` (e.g., `Turbine.Gameplay.Equipment.Back`). Use `Turbine.Gameplay.EquipmentSlot` for enum values in `GetItem()`.

### Item (extends Entity)

| Method | Description |
|--------|-------------|
| `GetName()` | Item name |
| `GetItemInfo()` | ItemInfo object with detailed information |

### ItemInfo

| Method | Description |
|--------|-------------|
| `GetName()` / `GetDescription()` | Name and description |
| `GetCategory()` | ItemCategory enum |
| `GetQuality()` | ItemQuality enum |
| `GetDurability()` | ItemDurability enum |
| `GetMaxQuantity()` / `GetMaxStackSize()` | Stack limits |
| `GetIconImageID()` / `GetBackgroundImageID()` / `GetQualityImageID()` / `GetShadowImageID()` / `GetUnderlayImageID()` | Image resource IDs |
| `GetNameWithQuantity()` | Name with quantity string |
| `IsMagic()` / `IsUnique()` | Item flags |

### Skill / ActiveSkill / UntrainedSkill

| Method | Class | Description |
|--------|-------|-------------|
| `GetSkillInfo()` | Skill | Get SkillInfo |
| `GetBaseCooldown()` | ActiveSkill | Base cooldown |
| `GetCooldown()` | ActiveSkill | Current cooldown |
| `GetResetTime()` | ActiveSkill | When skill comes off cooldown |
| `IsUsable()` | ActiveSkill | Currently usable |
| `GetPrice()` | UntrainedSkill | Cost to purchase |
| `GetRequiredLevel()` / `GetRequiredRank()` | UntrainedSkill | Requirements |

### SkillInfo

| Method | Description |
|--------|-------------|
| `GetName()` / `GetDescription()` | Skill name and description |
| `GetIconImageID()` | Icon resource ID |
| `GetType()` | SkillType enum |

### SkillList

| Method | Description |
|--------|-------------|
| `GetCount()` | Number of skills |
| `GetItem(index)` | Skill at index |

### Bank / Vault / SharedStorage

| Method | Description |
|--------|-------------|
| `GetCapacity()` / `GetCount()` | Capacity and current count |
| `GetItem(index)` | Item at index |
| `GetChestCount()` / `GetChestName(index)` | Chest information |
| `IsAvailable()` | Is bank currently accessible |

| Event | Description |
|-------|-------------|
| `ItemAdded` / `ItemRemoved` / `ItemMoved` / `ItemsRefreshed` | Item changes |
| `CountChanged` / `CapacityChanged` / `IsAvailableChanged` | State changes |

### Wallet / WalletItem

| Method | Class | Description |
|--------|-------|-------------|
| `GetItem(index)` / `GetSize()` | Wallet | Access wallet items |
| `GetName()` / `GetDescription()` | WalletItem | Item info |
| `GetQuantity()` / `GetMaxQuantity()` | WalletItem | Amounts |
| `GetImage()` / `GetSmallImage()` | WalletItem | Icons |
| `IsAccountItem()` | WalletItem | Shared across characters |

### ProfessionInfo

| Method | Description |
|--------|-------------|
| `GetName()` | Profession name |
| `GetProficiencyLevel()` / `GetProficiencyExperience()` / `GetProficiencyExperienceTarget()` / `GetProficiencyTitle()` | Proficiency info |
| `GetMasteryLevel()` / `GetMasteryExperience()` / `GetMasteryExperienceTarget()` / `GetMasteryTitle()` | Mastery info |
| `GetRecipeCount()` / `GetRecipe(index)` | Recipes |

### Recipe

| Method | Description |
|--------|-------------|
| `GetName()` / `GetCategory()` / `GetCategoryName()` | Recipe info |
| `GetTier()` / `GetProfession()` | Tier and profession |
| `GetIngredientCount()` / `GetIngredient(index)` | Ingredients |
| `GetOptionalIngredientCount()` / `GetOptionalIngredient(index)` | Optional ingredients |
| `GetResultItemInfo()` / `GetResultItemQuantity()` | Result |
| `GetCriticalResultItemInfo()` / `GetCriticalResultItemQuantity()` / `HasCriticalResultItem()` | Critical result |
| `GetBaseCriticalSuccessChance()` / `GetCooldown()` / `GetExperienceReward()` | Other |
| `IsSingleUse()` | Single use flag |

### Mount / BasicMount / CombatMount

| Method | Class | Description |
|--------|-------|-------------|
| `GetName()` | Mount | Mount name |
| `GetMorale()` / `GetMaxMorale()` | BasicMount | Morale |
| `GetMorale()` / `GetMaxMorale()` / `GetPower()` / `GetMaxPower()` | CombatMount | Stats |
| `GetFury()` / `GetMaxFury()` | CombatMount | War-steed fury |
| `GetStrength()` / `GetAgility()` / `GetArmor()` | CombatMount | War-steed stats |

---

## API Reference: Turbine.Gameplay.Attributes

### FreePeopleAttributes

| Method | Description |
|--------|-------------|
| `GetVitality()` / `GetBaseVitality()` | Vitality |
| `GetMight()` / `GetBaseMight()` | Might |
| `GetAgility()` / `GetBaseAgility()` | Agility |
| `GetFate()` / `GetBaseFate()` | Fate |
| `GetWill()` / `GetBaseWill()` | Will |
| `GetArmor()` / `GetBaseArmor()` / `GetBaseResistance()` | Defense |
| `GetWoundResistance()` / `GetFearResistance()` / `GetDiseaseResistance()` / `GetPoisonResistance()` | Resistances |
| `GetMoney()` | Money in copper |
| `GetMoneyComponents()` | Returns gold, silver, copper |
| `GetDestinyPoints()` | Destiny points |
| `GetVocation()` | Current vocation |
| `GetProfessionInfo(profession)` | ProfessionInfo for a profession |

### Class-Specific Attributes

| Class | Methods | Events |
|-------|---------|--------|
| Beorning | `GetWrath()`, `IsInBearForm()` | `WrathChanged`, `FormChanged` |
| Burglar | `GetStance()`, `IsCriticalTier1Available()`, `IsCriticalTier2Available()` | `StanceChanged`, `IsCriticalTier1Changed`, `IsCriticalTier2Changed` |
| Captain | `IsInEnemyDefeatResponse()`, `IsInFellowDefeatResponse()`, `IsReadiedTier1Available()`, `IsReadiedTier2Available()` | `IsInEnemyDefeatResponseChanged`, `IsInFellowDefeatResponseChanged`, `IsReadiedTier1Changed`, `IsReadiedTier2Changed` |
| Champion | `GetFervor()`, `GetStance()` | `FervorChanged`, `StanceChanged` |
| Guardian | `GetStance()`, `IsBlockTier1-3Available()`, `IsParryTier1-3Available()` | `StanceChanged`, `IsBlockTier1-3AvailableChanged`, `IsParryTier1-3AvailableChanged` |
| Hunter | `GetFocus()`, `GetStance()` | `FocusChanged`, `StanceChanged` |
| Minstrel | `GetStance()`, `IsSerenadeTier1-3Available()` | `StanceChanged`, `IsSerenadeTier1-3Changed` |
| RuneKeeper | `GetAttunement()`, `IsCharged()` | `AttunementChanged`, `IsChargedChanged` |
| Warden | `GetStance()`, `GetGambit(idx)`, `GetGambitCount()`, `GetMaxGambitCount()`, `GetTrainedGambits()`, `GetUntrainedGambits()` | `StanceChanged`, `GambitChanged`, `MaxGambitCountChanged` |

Empty attribute classes (no unique members): Chicken, LoreMaster, and all race-specific attributes (Dwarf, Elf, HighElf, Hobbit, Man, StoutAxe).

---

## API Reference: Turbine.UI

### Class Hierarchy

```
Turbine.UI.Control
  +-- ScrollableControl
  |     +-- Label
  |     |     +-- Button -> Lotro.Button, Lotro.GoldButton
  |     |     +-- CheckBox -> Lotro.CheckBox
  |     |     +-- TextBox -> Lotro.TextBox
  |     +-- ListBox
  +-- ScrollBar -> Lotro.ScrollBar
  +-- TreeNode
  +-- TreeView
  +-- Window -> Lotro.Window, Lotro.GoldWindow
  +-- Lotro.BaseItemControl -> ItemControl, ItemInfoControl
  +-- Lotro.EffectDisplay
  +-- Lotro.EntityControl
  +-- Lotro.EquipmentSlot
  +-- Lotro.Quickslot
```

### Control (base class for all UI elements)

**Methods:**

| Method | Description |
|--------|-------------|
| `Focus()` | Request focus |
| `GetAllowDrop()` / `SetAllowDrop(value)` | Drag-drop permission |
| `GetBackColor()` / `SetBackColor(color)` | Background color |
| `GetBackColorBlendMode()` / `SetBackColorBlendMode(mode)` | Color blend mode |
| `GetBackground()` / `SetBackground(resID_or_path)` | Background image (resource ID or file path) |
| `GetBlendMode()` / `SetBlendMode(mode)` | Image blend mode |
| `GetControls()` | Child ControlList |
| `GetHeight()` / `SetHeight(h)` | Height |
| `GetWidth()` / `SetWidth(w)` | Width |
| `GetSize()` / `SetSize(w, h)` | Size |
| `GetLeft()` / `SetLeft(x)` | X position |
| `GetTop()` / `SetTop(y)` | Y position |
| `GetPosition()` / `SetPosition(x, y)` | Position |
| `GetMousePosition()` | Mouse position relative to control |
| `GetOpacity()` / `SetOpacity(value)` | Opacity (0-1) |
| `GetParent()` / `SetParent(control)` | Parent control |
| `GetWantsKeyEvents()` / `SetWantsKeyEvents(value)` | Key event reception |
| `GetWantsUpdates()` / `SetWantsUpdates(value)` | Frame update notifications |
| `GetZOrder()` / `SetZOrder(value)` | Z-order layering |
| `HasFocus()` | Check if focused |
| `IsAltKeyDown()` (static) | Alt key state |
| `IsControlKeyDown()` (static) | Ctrl key state |
| `IsShiftKeyDown()` (static) | Shift key state |
| `IsDisplayed()` | Is on screen |
| `IsEnabled()` / `SetEnabled(value)` | Enabled state |
| `IsMouseVisible()` / `SetMouseVisible(value)` | Mouse interaction (false = click-through) |
| `IsVisible()` / `SetVisible(value)` | Visibility |
| `PointToClient(x, y)` | Screen -> control coordinates |
| `PointToScreen(x, y)` | Control -> screen coordinates |

**Events:**

| Event | Args | Description |
|-------|------|-------------|
| `MouseClick` | `{X, Y, Button}` | Mouse button clicked |
| `MouseDoubleClick` | `{X, Y, Button}` | Double-clicked |
| `MouseDown` / `MouseUp` | `{X, Y, Button}` | Button pressed/released |
| `MouseEnter` / `MouseLeave` | | Mouse enters/leaves control |
| `MouseHover` / `MouseMove` | | Mouse hovering/moving |
| `MouseWheel` | | Scroll wheel |
| `KeyDown` / `KeyUp` | `{Action, Alt, Control, Shift}` | Action events (NOT raw keys -- see Actions section) |
| `DragStart` / `DragEnter` / `DragLeave` / `DragDrop` | | Drag operations |
| `FocusGained` / `FocusLost` | | Focus changes |
| `Update` | | Fires every frame when `SetWantsUpdates(true)` |
| `SizeChanged` / `PositionChanged` | | Geometry changes |
| `VisibleChanged` / `EnabledChanged` | | State changes |

### Display (static)

| Method | Description |
|--------|-------------|
| `GetWidth()` / `GetHeight()` / `GetSize()` | Screen dimensions |
| `GetMouseX()` / `GetMouseY()` / `GetMousePosition()` | Mouse position |

### Label (extends ScrollableControl -> Control)

Adds text display capabilities.

| Method | Description |
|--------|-------------|
| `GetText()` / `SetText(text)` | Text content |
| `AppendText(text)` / `InsertText(text)` | Add text |
| `GetFont()` / `SetFont(font)` | Font (see Font enum) |
| `GetFontStyle()` / `SetFontStyle(style)` | Font style |
| `GetForeColor()` / `SetForeColor(color)` | Text color |
| `GetOutlineColor()` / `SetOutlineColor(color)` | Text outline color |
| `GetTextAlignment()` / `SetTextAlignment(align)` | Alignment (ContentAlignment enum) |
| `GetTextLength()` | Text length |
| `IsMultiline()` / `SetMultiline(value)` | Multiline mode |
| `IsMarkupEnabled()` / `SetMarkupEnabled(value)` | Markup support |
| `IsSelectable()` / `SetSelectable(value)` | Text selectable |
| `SelectAll()` / `DeselectAll()` | Selection |
| `GetSelectedText()` / `SetSelectedText(text)` | Selected text |
| `GetSelectionStart()` / `SetSelectionStart(pos)` | Selection start |
| `GetSelectionLength()` / `SetSelectionLength(len)` | Selection length |
| `SetSelection(start, length)` | Set selection range |

ScrollableControl adds: `GetHorizontalScrollBar()` / `SetHorizontalScrollBar()` / `GetVerticalScrollBar()` / `SetVerticalScrollBar()`

### Button (extends Label)

| Event | Description |
|-------|-------------|
| `Click` | Button clicked |
| `EnabledChanged` | Enabled state changes |

### CheckBox (extends Label)

| Method | Description |
|--------|-------------|
| `IsChecked()` / `SetChecked(value)` | Checked state |
| `GetCheckAlignment()` / `SetCheckAlignment(align)` | Check position |

| Event | Description |
|-------|-------------|
| `CheckedChanged` | Checked state changes |

### TextBox (extends Label)

| Method | Description |
|--------|-------------|
| `IsReadOnly()` / `SetReadOnly(value)` | Read-only mode |

| Event | Description |
|-------|-------------|
| `TextChanged` | Text changes |

### ListBox (extends ScrollableControl)

| Method | Description |
|--------|-------------|
| `AddItem(control)` | Add item |
| `InsertItem(index, control)` | Insert at index |
| `RemoveItem(control)` / `RemoveItemAt(index)` | Remove item |
| `ClearItems()` | Clear all |
| `GetItem(index)` / `SetItem(index, control)` | Get/set item |
| `GetItemAt(x, y)` | Item at coordinates |
| `GetItemCount()` | Count |
| `ContainsItem(control)` / `IndexOfItem(control)` | Search |
| `GetSelectedIndex()` / `SetSelectedIndex(index)` | Selected index |
| `GetSelectedItem()` / `SetSelectedItem(control)` | Selected item |
| `EnsureVisible(index)` | Scroll to item |
| `GetOrientation()` / `SetOrientation(orient)` | Horizontal/Vertical layout |
| `GetMaxColumns()` / `SetMaxColumns(value)` | Max columns |
| `GetMaxRows()` / `SetMaxRows(value)` | Max rows |
| `GetFlippedLayout()` / `SetFlippedLayout(value)` | Flipped draw order |
| `GetReverseFill()` / `SetReverseFill(value)` | Reverse fill |
| `Sort(compareFunc)` | Sort items |

| Event | Description |
|-------|-------------|
| `SelectedIndexChanged` | Selection changes |
| `ItemAdded` / `ItemRemoved` | Items change |

### ScrollBar (extends Control)

| Method | Description |
|--------|-------------|
| `GetMinimum()` / `SetMinimum(value)` | Min value |
| `GetMaximum()` / `SetMaximum(value)` | Max value |
| `GetValue()` / `SetValue(value)` | Current value |
| `GetSmallChange()` / `SetSmallChange(value)` | Arrow click change |
| `GetLargeChange()` / `SetLargeChange(value)` | Page click change |
| `GetOrientation()` / `SetOrientation(orient)` | Orientation |
| `GetDecrementButton()` / `SetDecrementButton(btn)` | Dec button |
| `GetIncrementButton()` / `SetIncrementButton(btn)` | Inc button |
| `GetThumbButton()` / `SetThumbButton(btn)` | Thumb button |

| Event | Description |
|-------|-------------|
| `ValueChanged` | Value changes |

### Window (extends Control)

| Method | Description |
|--------|-------------|
| `Activate()` | Bring to front |
| `Close()` | Close window |
| `GetText()` / `SetText(text)` | Title bar text |
| `GetMinimumSize()` / `SetMinimumSize(w, h)` | Min size |
| `GetMaximumSize()` / `SetMaximumSize(w, h)` | Max size |
| `IsResizable()` / `SetResizable(value)` | Resizable |

| Event | Description |
|-------|-------------|
| `Activated` / `Deactivated` | Focus changes |
| `Closing` / `Closed` | Close events |

### TreeView / TreeNode

| Method | Class | Description |
|--------|-------|-------------|
| `GetNodes()` | TreeView | Root TreeNodeList |
| `GetSelectedNode()` / `SetSelectedNode(node)` | TreeView | Selection |
| `ExpandAll()` / `CollapseAll()` | TreeView | Expand/collapse all |
| `GetIndentation()` / `SetIndentation(value)` | TreeView | Indent pixels |
| `GetChildNodes()` | TreeNode | Child TreeNodeList |
| `GetParentNode()` | TreeNode | Parent node |
| `Expand()` / `Collapse()` | TreeNode | Expand/collapse |
| `ExpandAll()` / `CollapseAll()` | TreeNode | Recursive expand/collapse |
| `IsExpanded()` / `SetExpanded(value)` | TreeNode | Expanded state |
| `IsSelected()` | TreeNode | Selected state |
| `EnsureVisible()` | TreeNode | Scroll into view |

### ContextMenu / MenuItem

```lua
local menu = Turbine.UI.ContextMenu()
local items = menu:GetItems()
local item1 = Turbine.UI.MenuItem("Option 1", false, true) -- text, checked, enabled
items:Add(item1)
item1.Click = function(sender, args) ... end
menu:ShowMenu()
-- or: menu:ShowMenuAt(x, y)
```

### Color

```lua
Turbine.UI.Color(r, g, b)       -- Alpha defaults to 1
Turbine.UI.Color(a, r, g, b)    -- Explicit alpha
```

Fields: `A`, `R`, `G`, `B` (all 0.0 to 1.0). Preset: `Turbine.UI.Color.Black`.

### Graphic

```lua
Turbine.UI.Graphic(imageID)     -- Resource ID (hex number)
Turbine.UI.Graphic("path.tga")  -- File path
```

### ControlList / MenuItemList / TreeNodeList

All share the same interface:

| Method | Description |
|--------|-------------|
| `Add(item)` / `Insert(index, item)` | Add items |
| `Remove(item)` / `RemoveAt(index)` / `Clear()` | Remove items |
| `Get(index)` / `Set(index, item)` | Get/set by index |
| `GetCount()` | Count |
| `Contains(item)` / `IndexOf(item)` | Search |

---

## API Reference: Turbine.UI.Lotro

LOTRO-skinned versions of UI controls that automatically respect the player's chosen UI skin. **Prefer these over `Turbine.UI` base classes.**

### Lotro.Window / Lotro.GoldWindow

Silver/gold-themed windows with title bar, borders, and close button. Inherit all `Turbine.UI.Window` methods.

### Lotro.Button / Lotro.GoldButton

Silver/gold-themed buttons. Inherit all Button methods including `Click` event.

### Lotro.CheckBox

LOTRO-themed checkbox. Inherits all CheckBox methods including `CheckedChanged` event.

### Lotro.TextBox

LOTRO-themed text input. Inherits all TextBox methods including `TextChanged` event.

### Lotro.ScrollBar

LOTRO-themed scrollbar. Inherits all ScrollBar methods.

### Lotro.Quickslot

Multi-purpose interactive shortcut slot. Can hold Alias, Hobby, Item, Pet, or Skill shortcuts.

| Method | Description |
|--------|-------------|
| `GetShortcut()` / `SetShortcut(shortcut)` | The shortcut on the slot |
| `IsUseOnRightClick()` / `SetUseOnRightClick(value)` | Right-click activation |

| Event | Description |
|-------|-------------|
| `DragDrop` | Drag-drop completed |
| `ShortcutChanged` | Shortcut changes |

### Lotro.Shortcut

```lua
local sc = Turbine.UI.Lotro.Shortcut(type, data)
-- type: ShortcutType enum (Alias, Hobby, Item, Pet, Skill)
-- data: hex string for Item/Skill, or command string for Alias
```

| Method | Description |
|--------|-------------|
| `GetData()` / `SetData(data)` | Shortcut data |
| `GetType()` / `SetType(type)` | ShortcutType |
| `GetItem()` | Convert to Item (for Item shortcuts) |

### Lotro.EffectDisplay

| Method | Description |
|--------|-------------|
| `GetEffect()` / `SetEffect(effect)` | Displayed effect |

### Lotro.EquipmentSlot

| Method | Description |
|--------|-------------|
| `GetEquipmentSlot()` / `SetEquipmentSlot(slot)` | Equipment slot |

### Lotro.ItemControl / Lotro.ItemInfoControl

| Method | Class | Description |
|--------|-------|-------------|
| `GetItem()` / `SetItem(item)` | ItemControl | Displayed item |
| `GetItemInfo()` / `SetItemInfo(info)` | ItemInfoControl | Displayed item info |
| `GetQuantity()` / `SetQuantity(qty)` | ItemInfoControl | Displayed quantity |

### Lotro.LotroUI (static)

Control built-in game UI elements from Lua:

```lua
Turbine.UI.Lotro.LotroUI.SetEnabled(element, false) -- hide built-in UI element
Turbine.UI.Lotro.LotroUI.IsEnabled(element)         -- check state
Turbine.UI.Lotro.LotroUI.Reset(element)              -- reset position
```

Available elements: `Backpack1`-`Backpack6`, `Party`, `PluginsManager`, `Target`, `Vitals`

### Lotro.DragDropInfo

| Method | Description |
|--------|-------------|
| `GetShortcut()` | Get shortcut from drag-drop event args |
| `IsSuccessful()` / `SetSuccessful(value)` | Success state |

---

## Enumerations

### Turbine.DataScope

| Value | Description |
|-------|-------------|
| `Account` | Shared across all characters on the account |
| `Character` | Per-character |
| `Server` | Per-server |

### Turbine.Language

| Value | Numeric | Description |
|-------|---------|-------------|
| `Invalid` | 0 | Invalid |
| `English` | 2 | English |
| `EnglishGB` | 268435457 (0x10000001) | British English |
| `French` | 268435459 (0x10000003) | French |
| `German` | 268435460 (0x10000004) | German |
| `Russian` | 268435463 (0x10000007) | Russian (deprecated) |

### Turbine.ChatType

`Admin`, `Advancement`, `Death`, `Emote`, `EnemyCombat`, `Error`, `FellowLoot`, `Fellowship`, `Kinship`, `LFF`, `Localized1`, `Localized2`, `Narration`, `Officer`, `OOC`, `PlayerCombat`, `Quest`, `Raid`, `Regional`, `Roleplay`, `Say`, `SelfLoot`, `Standard`, `Tell`, `Trade`, `Tribe`, `Undef`, `Unfiltered`, `UserChat1`-`UserChat8`, `World`

### Turbine.Gameplay.Class

`Beorning`, `BlackArrow`, `Burglar`, `Captain`, `Champion`, `Chicken`, `Defiler`, `Guardian`, `Hunter`, `LoreMaster`, `Minstrel`, `Ranger`, `Reaver`, `RuneKeeper`, `Stalker`, `Troll`, `Undefined`, `Warden`, `WarLeader`, `Weaver`

### Turbine.Gameplay.Race

`Beorning`, `Dwarf`, `Elf`, `HighElf`, `Hobbit`, `Man`, `StoutAxe`, `Undefined`

### Turbine.Gameplay.Alignment

`FreePeople`, `MonsterPlayer`, `Undefined`

### Turbine.Gameplay.ReadyState

`NotReady`, `Ready`, `Unset`

### Turbine.Gameplay.EquipmentSlot

`Back`, `Boots`, `Bracelet1`, `Bracelet2`, `Chest`, `Class`, `CraftTool`, `Earring1`, `Earring2`, `Gloves`, `Head`, `Instrument`, `Legs`, `Necklace`, `Pocket`, `PrimaryWeapon`, `RangedWeapon`, `Ring1`, `Ring2`, `SecondaryWeapon`, `Shield`, `Shoulder`, `Undefined`

### Turbine.Gameplay.EffectCategory

`Corruption`, `Cry`, `Disease`, `Dispellable`, `Elemental`, `Fear`, `Physical`, `Poison`, `Song`, `Undefined`, `Wound`

### Turbine.Gameplay.ItemQuality

`Common`, `Incomparable`, `Legendary`, `Rare`, `Uncommon`, `Undefined`

### Turbine.Gameplay.ItemDurability

`Brittle`, `Flimsy`, `Indestructible`, `Normal`, `Substantial`, `Tough`, `Undefined`, `Weak`

### Turbine.Gameplay.ItemWearState

`Broken`, `Damaged`, `Pristine`, `Undefined`, `Worn`

### Turbine.Gameplay.Profession

`Cook`, `Farmer`, `Forester`, `Jeweller`, `Metalsmith`, `Prospector`, `Scholar`, `Tailor`, `Undefined`, `Weaponsmith`, `Woodworker`

### Turbine.Gameplay.Vocation

`Armorer`, `Armsman`, `Explorer`, `Historian`, `None`, `Tinker`, `Woodsman`, `Yeoman`

### Turbine.Gameplay.CraftTier

`Apprentice`, `Artisan`, `Eastemnet`, `Expert`, `Journeyman`, `Master`, `Supreme`, `Undefined`, `Westemnet`, `Westfold`

### Turbine.Gameplay.SkillType

`Gambit`, `Mount`, `Normal`

### Turbine.UI.ContentAlignment

`TopLeft`, `TopCenter`, `TopRight`, `MiddleLeft`, `MiddleCenter`, `MiddleRight`, `BottomLeft`, `BottomCenter`, `BottomRight`, `Undefined`

### Turbine.UI.BlendMode

`AlphaBlend`, `Color`, `Grayscale`, `Multiply`, `None`, `Normal`, `Overlay`, `Screen`, `Undefined`

### Turbine.UI.FontStyle

`None`, `Outline`

### Turbine.UI.MouseButton

`Left`, `Middle`, `None`, `Right`

### Turbine.UI.Orientation

`Horizontal`, `Vertical`

### Turbine.UI.HorizontalLayout / VerticalLayout

`LeftToRight`, `RightToLeft` / `TopToBottom`, `BottomToTop`

### Turbine.UI.Lotro.ShortcutType

`Alias`, `Hobby`, `Item`, `Pet`, `Skill`, `Undefined`

### Turbine.UI.Lotro.Font

Font families available: `Arial`, `BookAntiqua`, `BookAntiquaBold`, `FixedSys`, `LucidaConsole`, `TrajanPro`, `TrajanProBold`, `Verdana`, `VerdanaBold`

Format: `{Family}{Size}` (e.g., `Verdana20`, `BookAntiqua14`, `TrajanProBold22`)

Sizes vary by family. Common: `Verdana10`-`Verdana23`, `BookAntiqua12`-`BookAntiqua36`.

**Note:** `TrajanPro25` is broken -- avoid it.

### Turbine.UI.Lotro.LotroUIElement

`Backpack1`-`Backpack6`, `Party`, `PluginsManager`, `Target`, `Vitals`

### Turbine.UI.Lotro.Action (Partial -- Most Important Values)

Actions represent game key bindings. `KeyDown`/`KeyUp` events fire with Action values, not raw keycodes.

| Action | Value | Description |
|--------|-------|-------------|
| `EscapeKey` | 145 | Escape |
| `ToggleBags` | 268435604 | Toggle all bags |
| `ToggleBag1`-`ToggleBag6` | varies | Individual bags |
| `Undefined` | 0 | No action |

Quickslot actions: 1-72 (bars 1-5, 12 slots each + extras). Selection actions, panel toggles, chat, music notes (C2-C5), fellowship manoeuvres, target marks, cosmetic outfits, camera, and debug actions are all defined.

**"Safe" debug actions** (do nothing in live client, usable for custom keybindings):
- `ToggleDebugConsole` (43) -- Ctrl+`
- `ToggleStringTokenDebugger` (17) -- Alt+`
- `ToggleMemoryGraph` (184) -- Shift+Alt+Ctrl+F8
- `ToggleBlockUI` (173) -- Shift+Alt+Ctrl+F9
- `TogglePerfGraph` (139) -- Shift+Alt+Ctrl+F10
- `ToggleProfiler` (140) -- Shift+Alt+Ctrl+F11
- `ToggleEntityNodeLabels` (174) -- Shift+Alt+Ctrl+F12

---

## Event Handling

### Basic Pattern

Events are handled by assigning functions. Two arguments: `sender` (the object) and `args` (event-specific table).

```lua
myControl.MouseClick = function(sender, args)
    -- args.X, args.Y, args.Button
end
```

### Discovering Event Arguments

```lua
myControl.MouseClick = function(sender, args)
    for k, v in pairs(args) do
        Turbine.Shell.WriteLine(tostring(k) .. ": " .. tostring(v))
    end
end
```

### Private vs Shared Objects

**Private objects** (ones you created): assign directly to the event.

**Shared objects** (Backpack, EffectList, Chat, etc.): use AddCallback/RemoveCallback to avoid overwriting other plugins' handlers.

```lua
-- AddCallback / RemoveCallback utility functions (include in your plugin)
function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback)
        else
            object[event] = {object[event], callback}
        end
    end
    return callback
end

function RemoveCallback(object, event, callback)
    if (object[event] == callback) then
        object[event] = nil
    else
        if (type(object[event]) == "table") then
            local size = table.getn(object[event])
            for i = 1, size do
                if (object[event][i] == callback) then
                    table.remove(object[event], i)
                    break
                end
            end
        end
    end
end
```

**Usage:**

```lua
local player = Turbine.Gameplay.LocalPlayer:GetInstance()
local effects = player:GetEffects()
local handler = function(sender, args) ... end
AddCallback(effects, "EffectAdded", handler)

-- In Unload:
RemoveCallback(effects, "EffectAdded", handler)
```

### KeyDown / KeyUp Events

These fire on **Actions**, not raw key presses. Actions map to game functions (open bags, use quickslot, etc.) and respect user keybinding changes.

```lua
myControl:SetWantsKeyEvents(true)
myControl.KeyDown = function(sender, args)
    -- args.Action (number), args.Alt (bool), args.Control (bool), args.Shift (bool)
    if args.Action == Turbine.UI.Lotro.Action.EscapeKey then
        myWindow:SetVisible(false)
    end
end
```

**Important:** Enable key events only when needed (performance impact). Use `FocusGained`/`FocusLost` to toggle.

### Update Event (Frame Tick)

Fires once per frame (~100 FPS). Useful for timers and animations.

```lua
myControl:SetWantsUpdates(true)
myControl.Update = function(sender, args)
    -- runs every frame
end
myControl:SetWantsUpdates(false) -- disable when not needed (critical for performance)
```

---

## Data Persistence

Data is stored in `.plugindata` files using `Turbine.PluginData`.

### During Plugin Loading (Synchronous)

```lua
local settings = Turbine.PluginData.Load(Turbine.DataScope.Character, "MySettings")
if settings ~= nil then
    -- use settings
end
```

### After Loading (Asynchronous)

```lua
Turbine.PluginData.Load(Turbine.DataScope.Character, "MySettings", function(scope, key, data)
    if data ~= nil then
        -- use data
    end
end)
```

### Saving

```lua
local settings = { x = 100, y = 200, opacity = 0.8 }
Turbine.PluginData.Save(Turbine.DataScope.Account, "MySettings", settings, function(succeeded, message)
    if not succeeded then
        Turbine.Shell.WriteLine("Save failed: " .. tostring(message))
    end
end)
```

### Scopes

| Scope | File Location |
|-------|--------------|
| `Turbine.DataScope.Account` | Shared across all characters |
| `Turbine.DataScope.Character` | Per character |
| `Turbine.DataScope.Server` | Per server |

---

## Shell Commands

### Registering a Command

```lua
local cmd = Turbine.ShellCommand()
function cmd:Execute(command, args)
    Turbine.Shell.WriteLine("Command executed with: " .. tostring(args))
end
function cmd:GetHelp()
    return "Detailed help text"
end
function cmd:GetShortHelp()
    return "Short description"
end
Turbine.Shell.AddCommand("mycommand", cmd)
```

Players type `/mycommand args` in chat to invoke.

### Removing a Command (in Unload handler)

```lua
Turbine.Shell.RemoveCommand(cmd)
```

---

## Internationalization

LOTRO supports English, German, and French clients.

### Detecting Client Language

```lua
-- Method 1: Test for language-specific commands
local locale = "en"
if Turbine.Shell.IsCommand("hilfe") then
    locale = "de"
elseif Turbine.Shell.IsCommand("aide") then
    locale = "fr"
end

-- Method 2: Use Engine.GetLanguage()
local lang = Turbine.Engine:GetLanguage()
-- Returns Turbine.Language enum value
```

### Euro Format Numbers

German/French clients use comma for decimals. Handle saved data:

```lua
local euroFormat = (tonumber("1,000") == 1)
if euroFormat then
    function euroNormalize(value)
        return tonumber((string.gsub(value, "%.", ",")))
    end
else
    function euroNormalize(value)
        return tonumber((string.gsub(value, ",", ".")))
    end
end
```

### Special Characters

Use Lua escape sequences for non-ASCII: `\195\167` for cedilla, `\195\170` for e-circumflex, etc. These are UTF-8 byte values.

---

## Undocumented Features

### SetStretchMode(mode)

Controls background image scaling on any Control. **Set control to image's original size BEFORE assigning mode 1, then resize after.**

| Mode | Behavior |
|------|----------|
| 0 | No scaling. Image cropped/tiled. Properly bounded by parent. |
| 1 | Scales based on size when mode assigned vs current size. Can exceed parent bounds. Mouse events work. |
| 2 | Scales control to background image size. Useful for determining image dimensions. **No mouse events.** |
| 3 | Like mode 0 but not properly bounded by parent. |
| 4 | Like mode 1 but **no mouse events**. |

**Getting image dimensions:**
```lua
local ctrl = Turbine.UI.Control()
ctrl:SetBackground(0x410f83cc) -- resource ID
ctrl:SetStretchMode(2) -- sizes to image
local width, height = ctrl:GetSize() -- now has image dimensions
```

**Side effects:** Can display outside parent bounds; may interfere with `SetBlendMode()`; prevents proper `SetRotation()` behavior.

### SetRotation(degrees)

Rotates a window. Arguments in **degrees** (not radians). Quirks:
- Mouse events respond at original unrotated coordinates
- **Rotation resets to zero when window is hidden** -- reapply in `VisibleChanged` handler
- Size window large enough to capture mouse events at rotated positions

### Resource IDs

Built-in game assets can be referenced by hex IDs in `SetBackground()`:

```lua
control:SetBackground(0x41000196) -- close button normal
control:SetBackground(0x41000197) -- close button pressed
control:SetBackground(0x41000198) -- close button highlighted
```

Use the IRV (Image Resource Viewer) plugin to find resource IDs. No official documentation exists for resource IDs.

---

## UI Scaling (Recent Patch)

Lua Plugins now support UI Scaling. By default, plugins scale with the Global scaling option.

### New Window Methods

| Method | Description |
|--------|-------------|
| `Window:SetScalingOriginPoint(left, top)` | Set the point the window scales around. Default: 0,0. |
| `Window:GetScalingOriginPoint()` | Get the scaling origin point. Returns: left, top. |
| `Window:RegisterForGlobalScaling()` | Enable Global scaling multiplier for the window's scale. |
| `Window:UnregisterForGlobalScaling()` | Disable Global scaling multiplier for the window's scale. |
| `Window:SetScale(scale)` | Set the window's scale. If registered for Global scaling, this value is multiplied by the Global scale factor. |

**Known issue:** The first tooltip in a session will be unscaled.

---

## Common Patterns

### Minimal Plugin

```lua
import "Turbine.UI"
import "Turbine.UI.Lotro"

local window = Turbine.UI.Lotro.Window()
window:SetSize(300, 200)
window:SetPosition(Turbine.UI.Display:GetWidth() / 2 - 150,
                   Turbine.UI.Display:GetHeight() / 2 - 100)
window:SetText("My Plugin")
window:SetVisible(true)

plugin.Unload = function()
    -- cleanup
end
```

### Timer Using Update Handler

```lua
Timer = class(Turbine.UI.Control)
function Timer:Constructor()
    Turbine.UI.Control.Constructor(self)
    self.SetTime = function(sender, seconds, shouldRepeat)
        self.EndTime = Turbine.Engine.GetGameTime() + seconds
        self.NumSeconds = seconds
        self.Repeat = shouldRepeat or false
        self:SetWantsUpdates(true)
    end
    self.Update = function()
        if self.EndTime and Turbine.Engine.GetGameTime() >= self.EndTime then
            self:SetWantsUpdates(false)
            if self.TimeReached then
                if type(self.TimeReached) == "function" then
                    self.TimeReached()
                elseif type(self.TimeReached) == "table" then
                    for _, v in pairs(self.TimeReached) do
                        if type(v) == "function" then v() end
                    end
                end
            end
            if self.Repeat then
                self.EndTime = Turbine.Engine.GetGameTime() + self.NumSeconds
                self:SetWantsUpdates(true)
            end
        end
    end
end
```

### Quickslot as Custom Button

Overlay a Control on a Quickslot with `SetMouseVisible(false)` to let clicks pass through:

```lua
local qs = Turbine.UI.Lotro.Quickslot()
qs:SetParent(parent)
qs:SetSize(36, 36)
qs:SetShortcut(Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Alias, "/emote dance"))
qs:SetAllowDrop(false)

-- Transparent backdrop to hide default quickslot appearance
local backdrop = Turbine.UI.Control()
backdrop:SetParent(parent)
backdrop:SetSize(36, 36)
backdrop:SetPosition(qs:GetLeft(), qs:GetTop())
backdrop:SetZOrder(qs:GetZOrder() + 1)
backdrop:SetBackColor(Turbine.UI.Color(1, 0, 0, 0))
backdrop:SetMouseVisible(false)

-- Custom icon overlay
local icon = Turbine.UI.Control()
icon:SetParent(parent)
icon:SetSize(36, 36)
icon:SetPosition(qs:GetLeft(), qs:GetTop())
icon:SetZOrder(qs:GetZOrder() + 2)
icon:SetBackground(0x410001c8) -- custom icon
icon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
icon:SetMouseVisible(false)
```

### Chat Listener

```lua
import "Turbine"

local function onChat(sender, args)
    if args.ChatType == Turbine.ChatType.Tell then
        Turbine.Shell.WriteLine("Tell from " .. args.Sender .. ": " .. args.Message)
    end
end
AddCallback(Turbine.Chat, "Received", onChat)
```

### Save/Restore Window Position

```lua
-- Load
local settings = Turbine.PluginData.Load(Turbine.DataScope.Account, "MyPlugin")
if settings then
    window:SetPosition(settings.left or 100, settings.top or 100)
end

-- Save (in Unload handler)
plugin.Unload = function()
    local settings = {
        left = window:GetLeft(),
        top = window:GetTop()
    }
    Turbine.PluginData.Save(Turbine.DataScope.Account, "MyPlugin", settings)
end
```

### Font Metrics Workaround

LOTRO has no text measurement API. Use a scrollbar-visibility trick:

```lua
-- Create a hidden label with a bound scrollbar
local label = Turbine.UI.Label()
local hscroll = Turbine.UI.Lotro.ScrollBar()
hscroll:SetOrientation(Turbine.UI.Orientation.Horizontal)
label:SetHorizontalScrollBar(hscroll)
label:SetMultiline(false)
label:SetText(text)
label:SetFont(font)
label:SetHeight(fontSize)
-- Expand width until scrollbar disappears
local width = 0
while hscroll:IsVisible() do
    width = width + 1
    label:SetWidth(width)
end
-- width now contains the text width
```

---

## Gotchas and Best Practices

1. **Case sensitivity** -- Almost everything in Lua and the Turbine API is case-sensitive. Check case first when debugging nil values.
2. **Plugin load command** -- `/plugins load name` is one of the few things that is NOT case-sensitive.
3. **UTF-8 without BOM** -- LOTRO's Lua parser requires UTF-8 without BOM. Pre-Windows 11 Notepad adds BOM.
4. **Image formats** -- Only `.jpg` and `.tga` are supported.
5. **Windows invisible by default** -- Always call `:SetVisible(true)`.
6. **`plugin` is temporary** -- Only available during loading. After loading, use `Plugins["Name"]`.
7. **PluginData sync/async** -- Synchronous during load, asynchronous after. Plan accordingly.
8. **Never assign `Turbine.Plugin.Unload`** -- Overwrites all other plugins' handlers in the apartment.
9. **Apartments, not plugins, are unloaded** -- `/plugins unload` targets the apartment name.
10. **A plugin cannot unload its own apartment.**
11. **Use AddCallback/RemoveCallback for shared objects** -- Direct assignment overwrites other plugins.
12. **Always RemoveCallback in Unload** -- Prevent leaks and maintain integrity.
13. **SetWantsUpdates(false)** when not needed -- Critical for performance.
14. **SetWantsKeyEvents** -- Enable only when focused. Significant performance impact.
15. **Background cannot be unset** -- Once set, it cannot be reverted to "no background".
16. **EquipmentSlot enum** -- Docs say `Turbine.Gameplay.EquipmentSlot` but the correct path is `Turbine.Gameplay.Equipment`.
17. **Do NOT instantiate ScrollableControl directly** -- Will crash the client.
18. **SetStretchMode + SetBlendMode** -- May interfere with each other.
19. **SetRotation resets on hide** -- Reapply in `VisibleChanged` handler.
20. **SetRotation uses degrees** -- Not radians.
21. **Quickslot DragDrop bug** -- Even with `SetAllowDrop(false)`, quickslot can self-drop. Fix by reassigning shortcut in DragDrop handler.
22. **Use `Turbine.Shell.WriteLine()` for debugging** -- Outputs to Standard chat.
23. **Use `tostring()` for safety** -- Prevents nil concatenation errors.
24. **String concatenation uses `..`** -- Not `+`.
25. **Prefer `Turbine.UI.Lotro.*` classes** -- They auto-support UI skins.
26. **All servers use US Eastern time** -- Relevant for timer/reset calculations.
27. **`TrajanPro25` font is broken** -- Avoid it.
28. **Use `pcall()` for error handling** -- Prevents plugin crashes from propagating.
29. **`GetLocale()` returns OS locale, not game language** -- Use `GetLanguage()` instead.
