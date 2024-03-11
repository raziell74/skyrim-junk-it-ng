# Release Version 1.2.0

- [x] Export/Import JunkList so it can be shared between game saves
- [x] Gamepad Support
- [-] View/Edit items currently in the JunkList through the MCM

## v1.2.0 Change Log

    - Implemented functionality for importing and exporting the JunkList to an external file
    - New setting to auto save the Junk List when ever the player saves their game
    - New setting to auto load the Junk List from the file when starting a new game
    - A "Replace JunkList On Import" option is available. If enabled the import will replace any current Junk markings with the imported list. If disabled the import will add to the current saves JunkList.
    - Moved JunkList Utilities import, export, and reset to the Maintenance page
    - Re-Added SKSE UI Pausing during item transfers and sales, but now will force thaw the UI after 5 seconds if the operation has timed out
    - If the UI is still frozen when the player presses one of the JunkIt keys it will force thaw the UI and refresh the item list
    - The forced UI Thaw in OnUpdate will also reset the busy state so you don't have to exit and re-enter the menu to continue using JunkIt keys
    - Overhauled the SKSE junk toggle to provide better error handling and notifications for protected items such as Quest, Protected Equipped, and Protected Favorites
    - There will now be a notification for when a transfer or sale starts processing
    - Bulk Sales will now also show the Large Inventory Warning
    - JunkIt now has Gamepad Support. The default hotkey for GamePads is the "Start" button as it doesn't conflict with any other default menu controls. Original hotkeys are still available for use for players using [Auto Input Switch](https://www.nexusmods.com/skyrimspecialedition/mods/54309)
    - Gamepad users can Hold their assigned JunkIt button to trigger a transfer or sale action without needing a second hotkey. Default is 1 second, but can be adjusted in the MCM under the Gamepad settings section.

## v1.2.0 Release Checklist

- [x] Update all translations files with newest version of the strings
- [x] Test edge cases with large transfers and sales to ensure the UI Thaw and Busy state reset are working as intended
- [x] Test the new Gamepad support with a variety of gamepads to ensure it's working as intended
- [x] Test the new Import/Export functionality to ensure it's working as intended
- [x] Test the new Auto Save/Load functionality to ensure it's working as intended
- [x] Test the new Replace JunkList On Import functionality to ensure it's working as intended
- [ ] Test MCM OnVersionUpdate on a save with an older version of the mod to ensure the Junk History and notifications of the update are working as intended
- [x] Test New Game with no junk list json file to import from while auto import is enabled. Expected behavior is that the JunkList will be empty and there is no CTD
- [x] Remove large quantities of MCM Junk List debug output to the console
- [x] ~~Test Export, Import and Rest colored MCM strings~~
- [ ] Final Code Review to ensure code quality and best practices
- [-] Write up all the changes in a change log for the Nexus page

# Release Version 1.2.1

- [ ] Refactor Import JunkList Feature to optimize load speed when replacing the current JunkList
- [ ] Refactor Junk List Reset functionality to better optimize processing speed
- [ ] SKSE speed and reliability optimizations for item transfers
- [ ] Add a search input to the JunkList MCM page to make it easier to find items in the list
- [ ] Add an item type filter to the JunkList MCM page to make it easier to find items in the list
- [ ] Add a Refresh button to the JunkList MCM page to force a refresh after Resetting or Importing
- [ ] Switch from a form id config string to using the EditorID when saving and loading the JunkList from JSON. Should make it a bit more human readable and easier to manually edit if it strikes your fancy.

# Release Version 1.3.0

- [ ] Decrease in save bloat by removing reliance on keywords to get i4 to work
- [ ] Better control over menu icons so that protected items (equipped/favorited/enchanted) won't use the Junk icon (better user experience)
