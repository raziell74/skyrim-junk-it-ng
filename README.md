***Junk It*** is still a work in progress. The mod is currently in a beta state and may have bugs. Use it at your own risk.

# Junk It

This is a spiritual successor for the "Mark As Junk" mod. The author of mark as junk had a great idea but there has not been any updates to it since it's first release. 

It was easy to see where they were headed with the mod, though the original is simple and only marks items with a "Junk" keyword and only while viewing the Inventory menu. This mod is a bit more advanced and allows marking items in any Menu that has an item list. 

In addition to marking items as "Junk" there are several new utilities added to help with inventory management.

## Features

- Mark items as "Junk" in any menu that has an item list using the "Mark As Junk" configurable hotkey.
- I4 integration to get items marked as "Junk" to switch to a trash icon on the item list menu in real time.
- I4 integration will also change the "subTypeDisplay" to "Junk" so it is easier to identify and sort your Junk.
- Bulk transfer junk items when trading with NPCs or accessing containers using the "Transfer" configurable hotkey.
- Easy Junk retrieval from containers or followers using the "Transfer" configurable hotkey.
- Bulk sell junk items when trading with NPCs using the "Transfer" configurable hotkey.
- Priority settings are available for both Bulk Sell and Transfer functions so you can control which items are transferred or sold first.
- Bulk Sell and Transfer functions are limited to Gold Amount/Weight Capacity.
- Equipped and Favorited items are protected from being Transferred or Sold using the bulk actions. This is configurable in the MCM.

## Known Issues

- Attempting to mark enchanted arrows as "Junk" will cause the game to crash. This is a known issue and is being worked on. I've added a catch for items that do not allow keywords to be added to them, so these items won't be marked as "Junk" and will not crash the game.

## Requirements

- [SKSE](https://skse.silverlock.org/)
- [SkyUI](https://www.nexusmods.com/skyrimspecialedition/mods/12604)
- [MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)
- [Inventory Interface Information Injector](https://www.nexusmods.com/skyrimspecialedition/mods/85702)

### Optional

- [Inventory Interface Information Injector for Skyrim 1.5](https://www.nexusmods.com/skyrimspecialedition/mods/87002) - If using v1.5.97

## Installation

- Install using your favorite mod manager or manually extract the contents of the archive to your Skyrim Special Edition Data folder.

## Uninstallation

- Uninstall using your favorite mod manager or manually delete the files from your Skyrim Special Edition Data folder.

## Compatibility

- This mod should be compatible with most other mods.
- Built with CommonLibSSE NG, should work for all skyrim versions.

## To Do

- [ ] Create a JunkIt logo
- [ ] Utilize JunkIt logo as a splash in the MCM
- [ ] Add Bulk Sell
- [ ] Auto switch Barter menu to "Sell" tab when Bulk Selling
- [x] Disable Bulk Transfer if while pick pocketing
- [ ] Possibly add a "Buy Back" hotkey for the "Barter" menu
- [ ] Freeze menu controls during Bulk Transfer/Bulk Sell/Marking
- [ ] Add Debug mode to MCM to toggle console logging with papyrus utils
- [x] Add keyword control to dll to replace dependency on [PO3's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)
- [ ] Add functionality to control icons to get rid of dependency on [I4](https://www.nexusmods.com/skyrimspecialedition/mods/85702)
    - Not sure this will be completely possible, but at the very least I might be able to prevent favorited items from being affected by the "Junk" i4 rule
- [ ] Optimize UI Icon refresh speed by only refreshing entries that match the selected formId
- [ ] Code Clean up and optimization refactor
- [ ] First Release!

## Credits

- [Mark As Junk](https://www.nexusmods.com/skyrimspecialedition/mods/105245) by [Lilmetal](https://www.nexusmods.com/skyrimspecialedition/users/945068) - Both the inspiration and a solid starting point for me to jump off from, thank you for your work!

## License

- This mod is licensed under the [MIT License](https://opensource.org/licenses/MIT)

## Source Code

The Source code for the SKSE plugin can be found here: [JunkIt - SKSE](https://github.com/raziell74/skyrim-junk-it-ng-skse)
