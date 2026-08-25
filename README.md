# Songbook 3 Legendary Edition Alpha
Forked from [Almiyan's Songbook2 LE](https://www.lotrointerface.com/downloads/info1096-Songbook2LegendaryEdition.html). Please see songbook_readme.txt for instructions on how to use.

After regenerating `SongbookData.plugindata` with a Songbook filler, reload the library without unloading the plugin by clicking **Refresh** or entering `/songbook refresh` (`/songbook3 refresh` also works).

Task list:
- [x] Add auto-part picking feature
- [x] Fix summer celebration instruments not registering as the correct instruments
- [x] Fix bug with path links being broken if same folder was clicked multiple times
- [x] Add option to disable the popup window when multiple songs match
- [x] Refactor folder structure to separate code from resources
- [x] Refresh the generated song library without unloading the plugin
- [ ] Complete French/German localization coverage in `Lang.lua` and convert the remaining hard-coded UI text
- [ ] Refactor main window architecture, break out filters into a separate window
- [x] Fix settings window using a mix of relative and hardcoded positions for components
- [ ] Remove songbook button and update texture of the songbook song timer scroll
- [ ] Add support for exporting/importing instrument shortcut templates, to help with onboarding new toons/accounts
- [ ] Smarter part name / instrument detection
- [ ] Make "squiggly sync" button optional, handle mixed songbook versions and warnings more elegantly
- [ ] Move instrument panel to the top of the UI so it's closer to the sync buttons
- [ ] Add auto-select song feature, so that all clients automatically select the correct song after the first queue
