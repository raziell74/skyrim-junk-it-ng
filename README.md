***Junk It*** is still a work in progress. The mod is currently in a beta state and may have bugs. Use it at your own risk.

# Junk It

This is a spiritual successor for the "Mark As Junk" mod. The author of mark as junk had a great idea but there has not been any updates to it since it's first release. 

It was easy to see where they were headed with the mod, though the original is simple and only marks items with a "Junk" keyword and only while viewing the Inventory menu. This mod is a bit more advanced and allows marking items in any Menu that has an item list. 

In addition to marking items as "Junk" there are several new utilities added to help with inventory management.

## Features

- Mark items as "Junk" in any menu that has an item list using the "Mark As Junk" configurable hotkey.
- Junk items will use a special icon and sub type to make them easier to identify.
- Transfer all Junk items to containers or followers using the "Transfer" configurable hotkey.
- Easy Junk retrieval from containers or followers using the "Transfer" configurable hotkey.
- Bulk sell junk items when bartering with NPCs using the "Transfer" configurable hotkey.
- Configurable priority sorting. Control which items are transferred or sold first, configurable in the MCM.
- Equipped and Favorited items are protected from being Transferred or Sold using the bulk actions.

## Known Issues

- [ ] Cannot Mark Ammo as "Junk".
- [x] ~~Bulk selling junk items does not calculate speech skill increases. I need to also figure out how to maximize compatibility so mods that affect speech skill increases will be compatible with JunkIt.~~
- [x] ~~Rarely the players carry weight will be set to a very large negative number when transferring loot. I believe this is due to the remove quantity on the form lists being set to a very large amount to ensure all items are transferred regardless of quantity.~~ <span style="color:darkgreen">***Resolved***</span>
- [x] <span style="color:darkgreen">***Resolved***</span> ~~Occasionally items that were unmarked as junk will revert to using the "Junk" icon on game reload.~~
- [x] <span style="color:darkgreen">***Resolved***</span> ~~Shouldn't be able to transfer Junk when pick pocketing~~
- [x] There is no indicator that equipped junk items are marked as junk or not. This is intended behavior. Unequip the item and the icon will update to reflect the items junk status.
- [x] <span style="color:darkgreen">***Resolved***</span> ~~Bulk actions take a long time to process on large inventories. I am working on optimizations to speed up the process.~~ 
- [x] ~~Bulk Junk transfer does not take NPC weight limits into account. Currently you can bulk transfer even if an NPC is over their weight limit.~~ <span style="color:darkgreen">***Resolved***</span>
- [ ] The game saves item keyword changes to the game save, but cannot reverse them. Marking items as "Junk" will add to the game save bloat. This is a game engine limitation. We're already keeping two formlists for items: marked as junk, and unmarked as junk. I need to limit the amount of save bloat by only have the same keep a single formlist for items marked as Junk. To accomplish this I need to implement my own version of junk tracking through the UI. The update should replace the I4 requirement as well as be compatible with I4. JunkIt would then no longer need to rely on keywords at all and only use the formlist to track junk items. This would also allow for the ability to mark ammo as junk.

## Immediate plans for new features and improvements

- [x] ~~Create a JunkIt logo to be used as a splash in the MCM.~~
- [x] ~~Needs a Debug mode togglable in the MCM.~~ <span style="color:darkgray">***Done***</span>
- [x] ~~Equipped/Favorited item protection MCM toggle.~~ <span style="color:darkgray">***Done***</span>
- [x] ~~"Reset Junk" button in MCM to clear all Junk items.~~ <span style="color:darkgray">***Done***</span>
- [x] ~~Speed optimizations for Bulk Transfer and Bulk Sell.~~ <span style="color:darkgray">***Done***</span>
- [x] ~~Speed optimizations for Marking items as Junk and icon updates.~~ <span style="color:darkgray">***Done***</span>
- [x] ~~UI Menu Lock/Fade during JunkIt actions. This provides a better user experience as it provides a visual cue of action processing as well as preventing any breaking actions from user input during processing.~~ <span style="color:darkgray">***Done***</span>

## Requirements

- [SKSE](https://skse.silverlock.org/)
- [SkyUI](https://www.nexusmods.com/skyrimspecialedition/mods/12604)
- [MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000)
- [Inventory Interface Information Injector](https://www.nexusmods.com/skyrimspecialedition/mods/85702)

### Optional

- [Inventory Interface Information Injector for Skyrim 1.5](https://www.nexusmods.com/skyrimspecialedition/mods/87002) - If using v1.5.97
- [PapyrusUtil SE - Modders Scripting Utility Functions](https://www.nexusmods.com/skyrimspecialedition/mods/13048) - Only required if enabling "Debug Mode" in the MCM.

## Installation

- Install using your favorite mod manager or manually extract the contents of the archive to your Skyrim Special Edition Data folder.

## Uninstallation

- Uninstall using your favorite mod manager or manually delete the files from your Skyrim Special Edition Data folder.

## Compatibility

- This mod should be compatible with most other mods.
- Built with CommonLibSSE NG, should work for all skyrim versions.

## Credits

- [Mark As Junk](https://www.nexusmods.com/skyrimspecialedition/mods/105245) by [Lilmetal](https://www.nexusmods.com/skyrimspecialedition/users/945068) - Both the inspiration and a solid starting point for me to jump off from, thank you for your work!

## License

- This mod is licensed under the [MIT License](https://opensource.org/licenses/MIT)

## Source Code

The Source code for the SKSE plugin can be found here: [JunkIt - SKSE](https://github.com/raziell74/skyrim-junk-it-ng-skse)
