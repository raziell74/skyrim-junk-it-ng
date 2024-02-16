Scriptname JunkIt_MCM extends MCM_ConfigBase

import PO3_SKSEFunctions
import PO3_Events_AME

; Form Properties ---------------------------------------------------------------------------------
Actor Property PlayerRef Auto
Keyword Property IsJunkKYWD Auto
FormList Property JunkList Auto

GlobalVariable Property ConfirmTransfer Auto
GlobalVariable Property ConfirmSell Auto

GlobalVariable Property TransferPriority Auto
GlobalVariable Property SellPriority Auto

Message Property TransferConfirmationMsg Auto
Message Property RetrievalConfirmationMsg Auto
Message Property SellConfirmationMsg Auto

; Script Variables ---------------------------------------------------------------------------------
Int UserJunkKey = 50
Int TransferJunkKey = 49
String ActiveMenu = ""

String ITEM_LIST_ROOT = "_root.Menu_mc.inventoryLists.itemList"

;--- Private Variables ----------------------------------------------------
Bool migrated = False
String plugin = "JunkIt.esp"

; --- MCM Helper Functions ---------------------------------------------------

; Returns version of this script.
Int Function GetVersion()
    return 1 ;MCM Helper
EndFunction

Event OnVersionUpdate(int aVersion)
	parent.OnVersionUpdate(aVersion)
    MigrateToMCMHelper()
    VerboseMessage("OnVersionUpdate: MCM Updated")
    RefreshMenu()
EndEvent

; Event called periodically if the active magic effect/alias/form is registered for update events. This event will not be sent if the game is in menu mode. 
Event OnUpdate()
    parent.OnUpdate()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
        VerboseMessage("OnUpdate: Settings imported!")
    EndIf
EndEvent

; Called when game is reloaded.
Event OnGameReload()
    parent.OnGameReload()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
        VerboseMessage("OnGameReload: Settings imported!")
    EndIf
    If GetModSettingBool("bLoadSettingsonReload:Maintenance")
        LoadSettings()
        VerboseMessage("OnGameReload: Settings autoloaded!")
    EndIf

    RegisterForMenu("InventoryMenu")
    RegisterForMenu("ContainerMenu")
    RegisterForMenu("BarterMenu")
EndEvent

; Called when a new page is selected, including the initial empty page.
Event OnPageSelect(String a_page)
    parent.OnPageSelect(a_page)
    RefreshMenu()
EndEvent

; Called when this config menu is opened.
Event OnConfigOpen()
    parent.OnConfigOpen()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
        VerboseMessage("OnConfigOpen: Settings imported!")
    EndIf
EndEvent

; Called when this config menu is initialized.
Event OnConfigInit()
    parent.OnConfigInit()
    migrated = True
    LoadSettings()

    RegisterForMenu("InventoryMenu")
    RegisterForMenu("ContainerMenu")
    RegisterForMenu("BarterMenu")
EndEvent

; Refreshes hotkey when toggled by the player.
Event OnSettingChange(String a_ID)
    ; Hotkey Settings
    If a_ID == "iJunkKey:Hotkey"
        UserJunkKey = GetModSettingInt(a_ID)
        RefreshMenu()
    ElseIf a_ID == "iTransferJunkKey:Hotkey"
        TransferJunkKey = GetModSettingInt(a_ID)
        RefreshMenu()
    
    ; Confirmation Settings
    ElseIf a_ID == "bConfirmTransfer:Confirmation"
        ConfirmTransfer.SetValue(GetModSettingBool(a_ID) as Float)
    ElseIf a_ID == "bConfirmSell:Confirmation"
        ConfirmSell.SetValue(GetModSettingBool(a_ID) as Float)
    
    ; Bulk Action Priority Settings
    ElseIf a_ID == "iTransferPriority:Priority"
        TransferPriority.SetValue(GetModSettingInt(a_ID) as Float)
    ElseIf a_ID == "iSellPriority:Priority"
        SellPriority.SetValue(GetModSettingInt(a_ID) as Float)
    EndIf
EndEvent

Function Default()
    ; Hotkey Settings
    SetModSettingInt("iJunkKey:Hotkey", 50)
    SetModSettingInt("iTransferJunkKey:Hotkey", 49)

    ; Confirmation Settings
    SetModSettingBool("bConfirmTransfer:Confirmation", True)
    SetModSettingBool("bConfirmSell:Confirmation", True)
    
    ; Bulk Action Priority Settings
    SetModSettingInt("iTransferPriority:Priority", 0)
    SetModSettingInt("iSellPriority:Priority", 4)

    ; Maintenance Settings
    SetModSettingBool("bEnabled:Maintenance", True)
    SetModSettingInt("iLoadingDelay:Maintenance", 0)
    SetModSettingBool("bLoadSettingsonReload:Maintenance", False)
    SetModSettingBool("bVerbose:Maintenance", False)
    VerboseMessage("Settings reset!")
    Load()
EndFunction

Function Load()
    ; Hotkey Settings
    UserJunkKey = GetModSettingInt("iJunkKey:Hotkey")
    TransferJunkKey = GetModSettingInt("iTransferJunkKey:Hotkey")

    ; Confirmation Settings
    ConfirmTransfer.SetValue(GetModSettingBool("bConfirmTransfer:Confirmation") as Float)
    ConfirmSell.SetValue(GetModSettingBool("bConfirmSell:Confirmation") as Float)
    
    ; Bulk Action Priority Settings
    TransferPriority.SetValue(GetModSettingInt("iTransferPriority:Priority") as Float)
    SellPriority.SetValue(GetModSettingInt("iSellPriority:Priority") as Float)

    VerboseMessage("Settings applied!")
EndFunction

Function LoadSettings()
    If GetModSettingBool("bEnabled:Maintenance") == false
        return
    EndIf
    Utility.Wait(GetModSettingInt("iLoadingDelay:Maintenance"))
    VerboseMessage("Settings autoloaded!")
    Load()
EndFunction

; Migrating to MCM Helper
Function MigrateToMCMHelper()
    ; Hotkey Settings
    SetModSettingInt("iJunkKey:Hotkey", UserJunkKey)
    SetModSettingInt("iTransferJunkKey:Hotkey", TransferJunkKey)

    ; Confirmation Settings
    SetModSettingBool("bConfirmTransfer:Confirmation", ConfirmTransfer.GetValue() as Bool)
    SetModSettingBool("bConfirmSell:Confirmation", ConfirmSell.GetValue() as Bool)
    
    ; Bulk Action Priority Settings
    SetModSettingInt("iTransferPriority:Priority", TransferPriority.GetValue() as Int)
    SetModSettingInt("iSellPriority:Priority", SellPriority.GetValue() as Int)
EndFunction

Function VerboseMessage(String m)
    Debug.Trace("[JunkIt] " + m)
    If GetModSettingBool("bVerbose:Maintenance")
        Debug.Notification("[JunkIt] " + m)
    EndIf
EndFunction

; JunkIt.dll SKSE Native Functions ---------------------------------------------------------------------------------

Function RefreshUIIcons() global native
; Function TransferJunk() global native
; Function RetrieveJunk() global native
; Function SellJunk() global native

; --- JunkIt Logic Functions ---------------------------------------------------

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

; When the player presses the hotkey, while in the Inventory Menu, the item they're highlighting is marked as junk.
Event OnKeyUp(Int KeyCode, Float HoldTime)
    If ActiveMenu == "InventoryMenu" || ActiveMenu == "ContainerMenu" || ActiveMenu == "BarterMenu"
        If UI.IsTextInputEnabled() ; avoid marking/bulk actions during text input
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

; Toggles the junk status of the selected item in an Item Menu.
Function MarkAsJunk()
    ; Get the selected item in the Item Menu
    Int selectedFormId = UI.GetInt(ActiveMenu, ITEM_LIST_ROOT + ".selectedEntry.formId")
    Form selected_item = Game.GetFormEx(selectedFormId)

    If !selected_item.HasKeyword(IsJunkKYWD)
        ; Mark as Junk
        AddKeywordToForm(selected_item, IsJunkKYWD)
        
        ; Update Junk FormList
        If !JunkList.HasForm(selected_item)
            JunkList.AddForm(selected_item)
        EndIf

        MiscUtil.PrintConsole("JunkIt - FormId: " + selectedFormId + " has been marked as junk")
        ; Debug.MessageBox("This item is now junk!")
    ElseIf selected_item.HasKeyword(IsJunkKYWD)
        ; Unmark as Junk
        RemoveKeywordOnForm(selected_item, IsJunkKYWD)
        
        ; Update Junk FormList
        If JunkList.HasForm(selected_item)
            JunkList.RemoveAddedForm(selected_item)
        EndIf

        MiscUtil.PrintConsole("JunkIt - FormId: " + selectedFormId + " is no longer marked as junk")
        ; Debug.MessageBox("This item is no longer junk!")
    EndIf

    ; SKSE Native Function to refresh the UI Icons on the fly
    RefreshUIIcons()
EndFunction

; Bulk Transfer of Junk Items
; @TODO prevent transfer from going over container weight capacity, and figure out how to get the weight capacity
; @TODO move transfers/retreivals to SKSE native functions
Function TransferJunk()
    If JunkList.GetSize() <= 0
        Return
    EndIf

    Bool canRetrieve = FALSE
    Bool canTransfer = FALSE

    ObjectReference transferContainer = GetMenuContainer()
    Bool isViewingContainer = UI.GetBool("ContainerMenu", "_root.Menu_mc.isViewingContainer")

    if isViewingContainer == TRUE
        ; Retrieve from container
        MiscUtil.PrintConsole("JunkIt - Viewing Container Inventory")
        Debug.MessageBox("Viewing Container!")
        if ConfirmTransfer.GetValue() >= 1
            Int iConfChoice = RetrievalConfirmationMsg.Show()
            If(iConfChoice == 0) ;Yes
                canRetrieve = TRUE
            ElseIf(iConfChoice == 1) ;No
                Return
            EndIf
        Else
            canRetrieve = TRUE
        EndIf
    Else
        ; Transfer to container
        MiscUtil.PrintConsole("JunkIt - Viewing Player Inventory")
        Debug.MessageBox("Viewing Player Inventory!")
        if ConfirmTransfer.GetValue() >= 1
            Int iConfChoice = TransferConfirmationMsg.Show()
            If(iConfChoice == 0) ;Yes
                canTransfer = TRUE
            ElseIf(iConfChoice == 1) ;No
                Return
            EndIf
        Else
            canTransfer = TRUE
        EndIf
    EndIf

    If canRetrieve == TRUE
        If transferContainer.GetItemCount(JunkList) <= 0
            Debug.MessageBox("No Junk to retrieve!")
            Return
        EndIf
        transferContainer.RemoveItem(JunkList, 100, true, PlayerREF)
        Debug.MessageBox("Retrieved Junk!")
    EndIf

    If canTransfer == TRUE
        If PlayerREF.GetItemCount(JunkList) <= 0
            Debug.MessageBox("No Junk to transfer!")
            Return
        EndIf
        PlayerREF.RemoveItem(JunkList, 100, true, transferContainer)
        Debug.MessageBox("Transferred Junk!")
    EndIf
EndFunction

; Bulk Sell junk items to a merchant
; @TODO implement SKSE native function for bulk selling
Function SellJunk()
    If JunkList.GetSize() <= 0
        Return
    EndIf
    ; @NOTE Bulk Selling is not implemented yet
EndFunction
