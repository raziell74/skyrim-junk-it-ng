Scriptname JunkIt_MCM extends MCM_ConfigBase

import PO3_SKSEFunctions
import PO3_Events_AME

; Form Properties ---------------------------------------------------------------------------------
Actor Property PlayerRef Auto
Keyword Property IsJunkKYWD Auto
FormList Property JunkList Auto

; Script Variables ---------------------------------------------------------------------------------
Int UserJunkKey = -1
Int TransferJunkKey = -1
String ActiveMenu = ""

String INVENTORY_ITEM_LIST = "_root.Menu_mc.inventoryLists.itemList"
String CONTAINER_INVENTORY_LISTS = "_root.Menu_mc.InventoryLists_mc"
String CONTAINER_ITEM_LIST = "_root.Menu_mc.InventoryLists_mc.itemList"
String ITEM_MENU_ITEM_LIST = "_root.ItemMenu.inventoryLists"

; Mod initilization. Sets hotkey from settings. This only runs once.
Event OnConfigInit()
    If GetModSettingInt("iJunkKey:General") != -1
        UserJunkKey = GetModSettingInt("iJunkKey:General")
    EndIf

    If GetModSettingInt("iTransferJunkKey:General") != -1
        TransferJunkKey = GetModSettingInt("iTransferJunkKey:General")
    EndIf

    RegisterForMenu("InventoryMenu")
    RegisterForMenu("ContainerMenu")
    RegisterForMenu("BarterMenu")
EndEvent

; Refreshes hotkey when toggled by the player.
Event OnSettingChange(String a_ID)
    If (a_ID == "iJunkKey:General")
        UserJunkKey = GetModSettingInt("iJunkKey:General")
        RefreshMenu()
    EndIf

    If (a_ID == "iTransferJunkKey:General")
        TransferJunkKey = GetModSettingInt("iTransferJunkKey:General")
        RefreshMenu()
    EndIf

    RegisterForMenu("InventoryMenu")
    RegisterForMenu("ContainerMenu")
    RegisterForMenu("BarterMenu")
EndEvent

Event OnInit()
	RegisterForMenu("InventoryMenu")
    RegisterForMenu("ContainerMenu")
    RegisterForMenu("BarterMenu")
EndEvent

; Starts watching for the Inventory Menu on game load.
Event OnPlayerLoadGame()
    RegisterForMenu("InventoryMenu")
    RegisterForMenu("ContainerMenu")
    RegisterForMenu("BarterMenu")
endEvent

; When the player opens the Inventory Menu, we start listening for the hotkey.
Event OnMenuOpen(String MenuName)
    MiscUtil.PrintConsole("MarkAsJunk - Menu Name: " + MenuName)
    If MenuName == "InventoryMenu" || MenuName == "ContainerMenu" || MenuName == "BarterMenu"
        If UserJunkKey != -1
            RegisterForKey(UserJunkKey)
        EndIf

        If TransferJunkKey != -1
            RegisterForKey(TransferJunkKey)
        EndIf

        ActiveMenu = MenuName
    EndIf
EndEvent

; When the player closes the Inventory Menu, we stop listening for the hotkey.
Event OnMenuClose(String MenuName)
    If MenuName == "InventoryMenu" || MenuName == "ContainerMenu" || MenuName == "BarterMenu"
        UnregisterForAllKeys()
        ActiveMenu = ""
    EndIf
EndEvent

Function MarkAsJunk()
    String ItemListRoot = INVENTORY_ITEM_LIST
    
    If ActiveMenu == "ContainerMenu"
        ItemListRoot = CONTAINER_ITEM_LIST
        Int test = UI.GetInt(ActiveMenu, CONTAINER_ITEM_LIST + ".selectedEntry.formId")
        Debug.MessageBox("ContainerMenu: Selected FormId: " + test)

        ; ItemListRoot = ITEM_MENU_ITEM_LIST
        Int test2 = UI.GetInt(ActiveMenu, ITEM_MENU_ITEM_LIST + ".selectedEntry.formId")
        Debug.MessageBox("ItemMenu: Selected FormId: " + test2)
    EndIf

    Int selectedIndex = UI.GetInt(ActiveMenu, ItemListRoot + ".selectedIndex")
    Int selectedFormId = UI.GetInt(ActiveMenu, ItemListRoot + ".selectedEntry.formId")
    Form selected_item = Game.GetFormEx(selectedFormId)
    
    If !selected_item.HasKeyword(IsJunkKYWD)
        AddKeywordToForm(selected_item, IsJunkKYWD)
        JunkList.AddForm(selected_item)

        ; Live Update to the Entries Icon
        ;UI.SetString(ActiveMenu, ItemListRoot + ".selectedEntry.iconSource", "MarkAsJunk/icons.swf")
        ;UI.SetString(ActiveMenu, ItemListRoot + ".selectedEntry.iconLabel", "trash")
        ;UI.SetInt(ActiveMenu, ItemListRoot + ".selectedEntry.iconColor", 7434609)
        ;UI.Invoke(ActiveMenu, ItemListRoot + "commitUpdate")

        ; Unselecting and reselecting the item to refresh the icon
        ;int[] params = new int[2]
        ;params[0] = selectedIndex - 1
        ;params[1] = 0
        ;If selectedIndex == 0
        ;    params[0] = selectedIndex + 1
        ;EndIf
        ;UI.InvokeIntA(ActiveMenu, ItemListRoot + ".doSetSelectedIndex", params)
        ;Utility.WaitMenuMode(0.1)
        ;params[0] = selectedIndex
        ;UI.InvokeIntA(ActiveMenu, ItemListRoot + ".doSetSelectedIndex", params)
        Debug.MessageBox("This item is now junk!")
    ElseIf selected_item.HasKeyword(IsJunkKYWD)
        RemoveKeywordOnForm(selected_item, IsJunkKYWD)
        JunkList.RemoveAddedForm(selected_item)

        ; Live Update to the Entries Icon
        ;UI.SetString(ActiveMenu, ItemListRoot + ".selectedEntry.iconSource", "")
        ;UI.SetString(ActiveMenu, ItemListRoot + ".selectedEntry.iconLabel", "")
        ;UI.SetInt(ActiveMenu, ItemListRoot + ".selectedEntry.iconColor", -1)
        ;UI.Invoke(ActiveMenu, ItemListRoot + "commitUpdate")

        ; Unselecting and reselecting the item to refresh the icon
        ;int[] params = new int[2]
        ;params[0] = selectedIndex - 1
        ;params[1] = 0
        ;If selectedIndex == 0
        ;    params[0] = selectedIndex + 1
        ;EndIf
        ;UI.InvokeIntA(ActiveMenu, ItemListRoot + ".doSetSelectedIndex", params)
        ;Utility.WaitMenuMode(0.1)
        ;params[0] = selectedIndex
        ;UI.InvokeIntA(ActiveMenu, ItemListRoot + ".doSetSelectedIndex", params)
        Debug.MessageBox("This item is no longer junk!")
    EndIf
EndFunction

Function TransferJunk()
    If JunkList.GetSize() <= 0
        Return
    EndIf
    ObjectReference transferContainer = GetMenuContainer()
    Int activeSegment = UI.GetInt(ActiveMenu, CONTAINER_INVENTORY_LISTS + ".CategoriesList.dividerIndex")
    Bool isViewingContainer = activeSegment == 0
    
    ; If isViewingContainer ; @TODO Fix segment detection
    If Input.IsKeyPressed(42) ; Left Shift
        If transferContainer.GetItemCount(JunkList) <= 0
            Debug.MessageBox("No Junk to retrieve!")
            Return
        EndIf
        transferContainer.RemoveItem(JunkList, 900, true, PlayerREF)
        Debug.MessageBox("Retrieved Junk!")
    Else
        If PlayerREF.GetItemCount(JunkList) <= 0
            Debug.MessageBox("No Junk to transfer!")
            Return
        EndIf
        PlayerREF.RemoveItem(JunkList, 900, true, transferContainer)
        Debug.MessageBox("Transferred Junk!")
    EndIf
EndFunction

Function SellJunk()
    If JunkList.GetSize() <= 0
        Return
    EndIf
    ; GetMenuContainer() ; Not sure if GetMenuContainer() works in BarterMenu
EndFunction

; When the player presses the hotkey, while in the Inventory Menu, the item they're highlighting is marked as junk.
Event OnKeyUp(Int KeyCode, Float HoldTime)
    If ActiveMenu == "InventoryMenu" || ActiveMenu == "ContainerMenu" || ActiveMenu == "BarterMenu"
        If UI.IsTextInputEnabled()
            Return
        EndIf

        If KeyCode == UserJunkKey
            MarkAsJunk()
        EndIf

        If KeyCode == TransferJunkKey 
            If ActiveMenu == "ContainerMenu"
                TransferJunk()
            ElseIf ActiveMenu == "BarterMenu"
                SellJunk()
            EndIf
        EndIf
    EndIf
EndEvent
