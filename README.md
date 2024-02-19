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
- [ ] Crashes or bugs occur if user does not have Papyrus Utils installed. I need to detect if Papyrus Utils is installed and not crash the game if it's not.
- [x] ~~Occasionally items that were unmarked as junk will revert to using the "Junk" icon on game reload.~~
- [x] ~~Shouldn't be able to transfer Junk when pick pocketing~~
- [ ] Bulk selling junk items does not calculate speech skill increases. I need to also figure out how to maximize compatibility so mods that affect speech skill increases will be compatible with JunkIt.
- [ ] Switching the selected entry while item marking is processing can sometimes mark the wrong item as Junk.
- [ ] There is no indicator that equipped junk items are marked as junk or not. This is intended behavior, but I may add an MCM option to show equipped junk with the junk icon. 
- [ ] Marking as junk will sometimes move the entry in the list due to the change in subTypeDisplay. I believe it's a better user experience for the entry to not change it's sort order until the menu is closed and reopened.
- [ ] Bulk actions take a long time to process on large inventories. I am working on optimizations to speed up the process.
- [ ] Marking items as junk can sometimes take a long time to process on large inventories. I am working on optimizations to speed up the process.
- [ ] Bulk Junk transfer does not take NPC weight limits into account. Currently you can bulk transfer even if an NPC is over their weight limit.

## Immediate plans for new features and improvements

- [ ] Needs a Debug mode togglable in the MCM.
- [ ] Equipped/Favorited item protection MCM toggle.
- [ ] Create a JunkIt logo to be used as a splash in the MCM.
- [ ] "Reset Junk" button in MCM to clear all Junk items.
- [ ] Global Enable/Disable JunkIt mod toggle in MCM.
- [ ] Speed optimizations for Bulk Transfer and Bulk Sell.
- [ ] Speed optimizations for Marking items as Junk and icon updates.
- [ ] UI Menu Lock/Fade during JunkIt actions. This provides a better user experience as it provides a visual cue of action processing as well as preventing any breaking actions from user input during processing.

## Stretch goals

- [ ] Add new Junk type "Rubbish" for items that are not even worth selling
- [ ] Configurable option to prevent the "Take All" action in container menus from taking items marked as "Rubbish"
- [ ] MCM button to save and load a list of Junk items to be shared between saves
- [ ] Favorited items should not show as "junk" but I4 has no way of filtering on "Favorited", so I am trying to figure out a way to supersede I4's rule set for favorited items. This may come with my own implementation of inventory icon control since the author of I4 probably has no plans on adding favorited as a filter option.
- [ ] Barter "Buy Back". Items sold to a vendor will have a special buy back icon and SubTypeDisplay to indicate this is a buy back item. The value price of to buy the item will be hard set to what ever the item was sold for. *This is a **Super Stretch** goal as it gets pretty complex. Rolling it into JunkIt may also not make sense as it's a pretty big feature and could be it's a standalone mod in its own right.*

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

## Credits

- [Mark As Junk](https://www.nexusmods.com/skyrimspecialedition/mods/105245) by [Lilmetal](https://www.nexusmods.com/skyrimspecialedition/users/945068) - Both the inspiration and a solid starting point for me to jump off from, thank you for your work!

## License

- This mod is licensed under the [MIT License](https://opensource.org/licenses/MIT)

## Source Code

The Source code for the SKSE plugin can be found here: [JunkIt - SKSE](https://github.com/raziell74/skyrim-junk-it-ng-skse)
