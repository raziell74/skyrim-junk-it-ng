Scriptname JunkIt_MCM extends MCM_ConfigBase

import PO3_SKSEFunctions
import PO3_Events_AME

; Form Properties ---------------------------------------------------------------------------------
Actor Property PlayerRef Auto
Keyword Property IsJunkKYWD Auto
FormList Property JunkList Auto
FormList Property UnjunkedList Auto

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

Function RefreshDllSettings() global native

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

    LoadSettings()

    ; Loop through the UnjunkedList and remove the junk keyword from all items if they have it
    Int i = 0
    Int iTotal = UnjunkedList.GetSize()
    While i < iTotal
        Form item = UnjunkedList.GetAt(i)
        If item.HasKeyword(IsJunkKYWD)
            MiscUtil.PrintConsole("JunkIt - Correcting Junk Keyword on Form: " + item.GetName() + " [" + item.GetFormID() + "]")
            RemoveKeywordOnForm(item, IsJunkKYWD)
        Else
            ; If the item does not have the junk keyword it is not bugged and can be removed from the watch list
            UnjunkedList.RemoveAddedForm(item)
        EndIf
        i += 1
    EndWhile
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

    If UserJunkKey != -1
        RegisterForKey(UserJunkKey)
    EndIf

    If TransferJunkKey != -1
        RegisterForKey(TransferJunkKey)
    EndIf
EndEvent

; Refreshes hotkey when toggled by the player.
Event OnSettingChange(String a_ID)
    ; Hotkey Settings
    If a_ID == "iJunkKey:Hotkey"
        UnregisterForKey(UserJunkKey)
        UserJunkKey = GetModSettingInt(a_ID)
        RegisterForKey(UserJunkKey)
        RefreshMenu()
    ElseIf a_ID == "iTransferJunkKey:Hotkey"
        UnregisterForKey(TransferJunkKey)
        TransferJunkKey = GetModSettingInt(a_ID)
        RegisterForKey(TransferJunkKey)
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

    RefreshDllSettings()
EndEvent

Function Default()
    ; Hotkey Settings
    SetModSettingInt("iJunkKey:Hotkey", 50)
    SetModSettingInt("iTransferJunkKey:Hotkey", 49)
    RegisterForKey(UserJunkKey)
    RegisterForKey(TransferJunkKey)

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
    UnregisterForKey(UserJunkKey)
    UserJunkKey = GetModSettingInt("iJunkKey:Hotkey")
    RegisterForKey(UserJunkKey)

    UnregisterForKey(TransferJunkKey)
    TransferJunkKey = GetModSettingInt("iTransferJunkKey:Hotkey")
    RegisterForKey(TransferJunkKey)

    ; Confirmation Settings
    ConfirmTransfer.SetValue(GetModSettingBool("bConfirmTransfer:Confirmation") as Float)
    ConfirmSell.SetValue(GetModSettingBool("bConfirmSell:Confirmation") as Float)
    
    ; Bulk Action Priority Settings
    TransferPriority.SetValue(GetModSettingInt("iTransferPriority:Priority") as Float)
    SellPriority.SetValue(GetModSettingInt("iSellPriority:Priority") as Float)

    RefreshDllSettings()
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
    Debug.Trace("JunkIt - " + m)
    If GetModSettingBool("bVerbose:Maintenance")
        Debug.Notification("JunkIt - " + m)
    EndIf
EndFunction

; JunkIt.dll SKSE Native Functions ---------------------------------------------------------------------------------

Function RefreshUIIcons() global native

Function SellJunk() global native
FormList Function GetSellFormList() global native

Int Function GetContainerMode() global native
FormList Function GetTransferFormList() global native
FormList Function GetRetrievalFormList() global native

; --- JunkIt Logic Functions ---------------------------------------------------

Event OnInit()
	RegisterForMenu("InventoryMenu")
    RegisterForMenu("ContainerMenu")
    RegisterForMenu("BarterMenu")

    If UserJunkKey != -1
        RegisterForKey(UserJunkKey)
    EndIf

    If TransferJunkKey != -1
        RegisterForKey(TransferJunkKey)
    EndIf
EndEvent

; When the player opens the Inventory Menu, we start listening for the hotkey.
Event OnMenuOpen(String MenuName)
    If MenuName == "InventoryMenu" || MenuName == "ContainerMenu" || MenuName == "BarterMenu"
        ActiveMenu = MenuName
    EndIf
EndEvent

; When the player closes the Inventory Menu, we stop listening for the hotkey.
Event OnMenuClose(String MenuName)
    If MenuName == "InventoryMenu" || MenuName == "ContainerMenu" || MenuName == "BarterMenu"
        ActiveMenu = ""
    EndIf
    GotoState("")
EndEvent

; When the player presses the hotkey, while in the Inventory Menu, the item they're highlighting is marked as junk.
Event OnKeyUp(Int KeyCode, Float HoldTime)
    If ActiveMenu != "" && !UI.IsTextInputEnabled()
        GotoState("busy")
        If KeyCode == UserJunkKey
            MarkAsJunk()
        EndIf

        If KeyCode == TransferJunkKey
            If ActiveMenu == "ContainerMenu"
                BulkTransfer()
            ElseIf ActiveMenu == "BarterMenu"
                BulkSell()
            EndIf
        EndIf
        GotoState("")
    EndIf
EndEvent

State busy
    ; Ignore key presses if already processing a command
    Event OnKeyUp(Int KeyCode, Float HoldTime)
        MiscUtil.PrintConsole("JunkIt - Is Busy")
    EndEvent
EndState

; Toggles the junk status of the selected item in an Item Menu.
Function MarkAsJunk()
    ; Get the selected item in the Item Menu
    Int selectedFormId = UI.GetInt(ActiveMenu, ITEM_LIST_ROOT + ".selectedEntry.formId")
    Form selected_item = Game.GetFormEx(selectedFormId)

    If selected_item.HasKeyword(IsJunkKYWD)
        ; Unmark as Junk
        RemoveKeywordOnForm(selected_item, IsJunkKYWD)
        RefreshUIIcons()
        
        ; Update Junk FormList
        If JunkList.HasForm(selected_item)
            JunkList.RemoveAddedForm(selected_item)
        EndIf

        ; Keep track of unjunked items for GameLoad keyword correction
        If !UnjunkedList.HasForm(selected_item)
            UnjunkedList.AddForm(selected_item)
        EndIf

        MiscUtil.PrintConsole("JunkIt - Form: " + selected_item.GetName() + " [" + selectedFormId + "] is no longer marked as junk")
        Debug.Notification("JunkIt - " + selected_item.GetName() + " is no longer marked as junk")
    Else
        ; Mark as Junk
        AddKeywordToForm(selected_item, IsJunkKYWD)
        RefreshUIIcons()
        
        ; Update Junk FormList
        If !JunkList.HasForm(selected_item)
            JunkList.AddForm(selected_item)
        EndIf

        ; Stop tracking this item for GameLoad keyword correction
        If UnjunkedList.HasForm(selected_item)
            UnjunkedList.RemoveAddedForm(selected_item)
        EndIf

        MiscUtil.PrintConsole("JunkIt - Form: " + selected_item.GetName() + " [" + selectedFormId + "] has been marked as junk")
        Debug.Notification("JunkIt - " + selected_item.GetName() + " has been marked as junk")
    EndIf
EndFunction

; Bulk Transfer of Junk Items
Function BulkTransfer()
    If JunkList.GetSize() <= 0
        Return
    EndIf

    ObjectReference transferContainer = GetMenuContainer()
    Int menuView = UI.GetInt("ContainerMenu", "_root.Menu_mc.inventoryLists.categoryList.activeSegment")

    FormList TransferList = GetTransferFormList()
    Bool canRetrieve = FALSE
    Bool canTransfer = FALSE

    if menuView == 0 ; VIEWING CONTAINER
        ; Retrieve from container
        If transferContainer.GetItemCount(TransferList) <= 0
            MiscUtil.PrintConsole("JunkIt - No Junk to retrieve!")
            Debug.MessageBox("No Junk to take!")
            Return
        EndIf

        If ConfirmTransfer.GetValue() >= 1
            Int iConfChoice = RetrievalConfirmationMsg.Show()
            If(iConfChoice == 0) ;Yes
                canRetrieve = TRUE
            ElseIf(iConfChoice == 1) ;No
                Return
            EndIf
        Else
            canRetrieve = TRUE
        EndIf
    Else  ; VIEWING PLAYER INVENTORY
        ; Transfer to container
        If PlayerREF.GetItemCount(TransferList) <= 0
            MiscUtil.PrintConsole("JunkIt - No Junk to transfer!")
            Debug.MessageBox("No Junk to transfer!")
            Return
        EndIf

        If ConfirmTransfer.GetValue() >= 1
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
        Debug.Notification("JunkIt - Taking Junk")
        transferContainer.RemoveItem(TransferList, 1000, false, PlayerREF)
        MiscUtil.PrintConsole("JunkIt - Retrieved all junk items")
        If ConfirmTransfer.GetValue() == 0
            Debug.MessageBox("Retrieved Junk!")
        Else
            Debug.Notification("JunkIt - Retrieved Junk!")
        EndIf
        Return
    EndIf

    If canTransfer == TRUE
        Debug.Notification("JunkIt - Transferring Junk")
        ; Find out if we're trading with an NPC and account for their carry weight
        If(GetContainerMode() == 3) ; NPC Mode
            Actor transferActor = transferContainer as Actor
            Int maxWeight = transferActor.GetActorValue("CarryWeight") as Int
            Int currentWeight = transferActor.GetActorValue("InventoryWeight") as Int
            MiscUtil.PrintConsole("JunkIt - [NPC Mode] CarryWeight " + currentWeight + "/" + maxWeight)

            Int iTotal = TransferList.GetSize()
            Int iCurrent = 0
            Int TotalTransferred = 0
            Int TotalPossibleTransferred = 0

            While iCurrent < iTotal
                Form item = TransferList.GetAt(iCurrent)	
    		    Int iCount = PlayerREF.GetItemCount(item)
                TotalPossibleTransferred += iCount
    		
                If iCount > 0
                    Int itemWeight = item.GetWeight() as Int
                    Int currentWeightWithItems = (itemWeight * iCount) + currentWeight
                    
                    While currentWeightWithItems > maxWeight
                        iCount -= 1
                        currentWeightWithItems = (itemWeight * iCount) + currentWeight
                    EndWhile

                    If iCount > 0
                        PlayerREF.RemoveItem(item, iCount, false, transferContainer)
                        currentWeight += (itemWeight * iCount)
                        MiscUtil.PrintConsole("JunkIt - Transferred " + iCount + " " + item.GetName() + " to " + transferActor.GetName() + " [" + currentWeight + "/" + maxWeight + "]" )
                        TotalTransferred += iCount
                    EndIf
                EndIf

                iCurrent += 1
            EndWhile

            If TotalTransferred >= TotalPossibleTransferred
                MiscUtil.PrintConsole("JunkIt - [NPC Mode] Transferred All Junk to " + transferActor.GetName() + " [" + currentWeight + "/" + maxWeight + "]")
                If ConfirmTransfer.GetValue() == 0
                    Debug.MessageBox("Transferred Junk!")
                Else
                    Debug.Notification("JunkIt - Transferred Junk!")
                EndIf
            Else
                MiscUtil.PrintConsole("JunkIt - [NPC Mode] Transferred " + TotalTransferred + " Junk Items to " + transferActor.GetName() + " [" + currentWeight + "/" + maxWeight + "]")
                Debug.MessageBox("Transferred " + TotalTransferred + " Junk Items!")
                If ConfirmTransfer.GetValue() == 0
                    Debug.MessageBox("Transferred " + TotalTransferred + " Junk Items!")
                Else
                    Debug.Notification("JunkIt - Transferred " + TotalTransferred + " Junk Items!")
                EndIf
            EndIf
        Else
            PlayerREF.RemoveItem(TransferList, 1000, false, transferContainer)
            If ConfirmTransfer.GetValue() == 0
                Debug.MessageBox("Transferred Junk!")
            Else
                Debug.Notification("JunkIt - Transferred Junk!")
            EndIf
        EndIf
    EndIf
EndFunction

; Bulk Sell junk items to a merchant
; @TODO implement SKSE native function for bulk selling
Function BulkSell()
    If JunkList.GetSize() <= 0
        Return
    EndIf
    ; @NOTE Bulk Selling is not implemented yet
EndFunction
