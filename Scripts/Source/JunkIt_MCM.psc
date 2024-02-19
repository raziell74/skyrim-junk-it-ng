Scriptname JunkIt_MCM extends MCM_ConfigBase

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

MiscObject Property Gold001 Auto

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
            MiscUtil.PrintConsole("JunkIt - Unjunking Correction for " + item.GetName() + " [" + item.GetFormID() + "] form")
            RemoveJunkKeyword(item)
        Else
            ; If the item does not have the junk keyword it is not bugged and can be removed from the watch list
            UnjunkedList.RemoveAddedForm(item)
        EndIf
        i += 1
    EndWhile

    ; Loop through the JunkList and ensure all items have the junk keyword
    i = 0
    iTotal = JunkList.GetSize()
    While i < iTotal
        Form item = JunkList.GetAt(i)
        If !item.HasKeyword(IsJunkKYWD)
            MiscUtil.PrintConsole("JunkIt - Junking Correction for " + item.GetName() + " [" + item.GetFormID() + "] form")
            AddJunkKeyword(item)
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

; --- JunkIt Native Functions ---------------------------------------------------------------------------------

Int Function AddJunkKeyword(Form a_form) global native
Int Function RemoveJunkKeyword(Form a_form) global native
Function RefreshUIIcons() global native

Int Function GetContainerMode() global native
ObjectReference Function GetContainerMenuContainer() global native
ObjectReference Function GetBarterMenuContainer() global native
ObjectReference Function GetBarterMenuMerchantContainer() global native
FormList Function GetTransferFormList() global native
FormList Function GetSellFormList() global native
Int Function GetFormUIEntryIndex(String menuName, Int formId) global native

; --- JunkIt Functionality ---------------------------------------------------

; When the player opens the Inventory Menu, we start listening for the hotkey.
Event OnMenuOpen(String MenuName)
    ActiveMenu = MenuName
    GotoState("")
EndEvent

; When the player closes the Inventory Menu, we stop listening for the hotkey.
Event OnMenuClose(String MenuName)
    ActiveMenu = ""
    GotoState("busy")
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
                TransferJunk()
            ElseIf ActiveMenu == "BarterMenu"
                SellJunk()
            EndIf
        EndIf
        GotoState("")
    EndIf
EndEvent

State busy
    ; Ignore key presses if already processing a command or not in a menu
    Event OnKeyUp(Int KeyCode, Float HoldTime)
    EndEvent
EndState

; Toggles the junk status of the selected item in an Item Menu.
Function MarkAsJunk()
    ; Get the selected item in the Item Menu
    Int selectedFormId = UI.GetInt(ActiveMenu, ITEM_LIST_ROOT + ".selectedEntry.formId")
    Form selected_item = Game.GetFormEx(selectedFormId)

    If selected_item.HasKeyword(IsJunkKYWD)
        ; Unmark as Junk
        Bool success = RemoveJunkKeyword(selected_item) as Bool
        RefreshUIIcons()

        If !success
            MiscUtil.PrintConsole("JunkIt - Failed to unmark " + selected_item.GetName() + " as junk")
            Debug.Notification("JunkIt - Failed to unmark " + selected_item.GetName() + " as junk")
            Return
        EndIf
        
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
        Bool success = AddJunkKeyword(selected_item) as Bool
        RefreshUIIcons()
        
        If !success
            MiscUtil.PrintConsole("JunkIt - Failed to mark " + selected_item.GetName() + " as junk")
            Debug.Notification("JunkIt - Failed to mark " + selected_item.GetName() + " as junk")
            Return
        EndIf

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

; Transfer/Retrieve junk items
Function TransferJunk()
    If JunkList.GetSize() <= 0
        Return
    EndIf

    ObjectReference transferContainer = GetContainerMenuContainer()
    Int menuView = UI.GetInt("ContainerMenu", "_root.Menu_mc.inventoryLists.categoryList.activeSegment")

    FormList TransferList = GetTransferFormList()
    Bool canRetrieve = FALSE
    Bool canTransfer = FALSE

    Int containerMode = GetContainerMode()

    ; disable if pickpocketing
    If containerMode == 2
        MiscUtil.PrintConsole("JunkIt - Junk Transfer disabled while pickpocketing")
        Debug.Notification("JunkIt - Junk Transfer disabled while pickpocketing")
        Return
    EndIf

    if menuView == 0 ; VIEWING CONTAINER
        ; Retrieve from container
        If transferContainer.GetItemCount(TransferList) <= 0
            MiscUtil.PrintConsole("JunkIt - No Junk to retrieve!")
            Debug.Notification("JunkIt - No Junk to take!")
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
            Debug.Notification("JunkIt - No Junk to transfer!")
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
        transferContainer.RemoveItem(TransferList, 1000, false, PlayerREF)
        MiscUtil.PrintConsole("JunkIt - Junk Retrieved!")
        Debug.Notification("JunkIt - Junk Retrieved!")
        Return
    EndIf

    If canTransfer == TRUE
        ; Find out if we're trading with an NPC and account for their carry weight
        If(containerMode == 3) ; NPC Mode
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
                Debug.Notification("JunkIt - Transferred Junk!")
            Else
                MiscUtil.PrintConsole("JunkIt - [NPC Mode] Transferred " + TotalTransferred + " Junk Items to " + transferActor.GetName() + " [" + currentWeight + "/" + maxWeight + "]")
                Debug.Notification("JunkIt - Transferred " + TotalTransferred + " Junk Items!")
            EndIf
        Else
            PlayerREF.RemoveItem(TransferList, 1000, false, transferContainer)
            Debug.Notification("JunkIt - Transferred Junk!")
        EndIf
    EndIf
EndFunction

; Bulk Sell junk items to a merchant
Function SellJunk()
    If JunkList.GetSize() <= 0
        Return
    EndIf
    
    Actor vendorActor = GetBarterMenuContainer() as Actor
    ObjectReference vendorContainer = GetBarterMenuMerchantContainer()

    MiscUtil.PrintConsole("JunkIt - Vendor Actor FormId: " + vendorActor.GetFormID())
    MiscUtil.PrintConsole("JunkIt - Vendor Container FormId: " + vendorContainer.GetFormID())
    
    Int menuView = UI.GetInt("BarterMenu", "_root.Menu_mc.inventoryLists.categoryList.activeSegment")
    FormList SellList = GetSellFormList()

    ; Check if the player has any junk to sell
    If PlayerREF.GetItemCount(SellList) <= 0
        MiscUtil.PrintConsole("JunkIt - No Junk to sell!")
        Debug.Notification("JunkIt - No Junk to sell!")
        Return
    EndIf

    Debug.Notification("JunkIt - Selling junk please wait...")
    Float vendorGoldDisplay = UI.GetFloat("BarterMenu", "_root.Menu_mc._vendorGold")
    Float buyMult = UI.GetFloat("BarterMenu", "_root.Menu_mc._buyMult")
    Float sellMult = UI.GetFloat("BarterMenu", "_root.Menu_mc._sellMult")

    MiscUtil.PrintConsole("JunkIt - Vendor Gold: " + vendorGoldDisplay)
    MiscUtil.PrintConsole("JunkIt - Vendor Buy Mult: " + buyMult)
    MiscUtil.PrintConsole("JunkIt - Vendor Sell Mult: " + sellMult)

    FormList FinalizedSellList = SellList
    Int[] SellListCounts = Utility.CreateIntArray(SellList.GetSize())
    Float[] SellListValues = Utility.CreateFloatArray(SellList.GetSize())
    Int iTotal = SellList.GetSize()
    Int iCurrent = 0
    Int TotalToSell = 0
    Int TotalPossibleToSell = 0
    Float calculatedVendorGold = vendorGoldDisplay
    Float totalSellValue = 0

    While iCurrent < iTotal
        Form item = SellList.GetAt(iCurrent)	
        Int iCount = PlayerREF.GetItemCount(item)
        TotalPossibleToSell += iCount

        ; Calculate how many junk items we can sell based on the vendors gold
        If iCount > 0
            Float sellValue = (item.GetGoldValue() * sellMult)
            Float goldDifferential = calculatedVendorGold - (sellValue * iCount)
            
            While Math.Ceiling(goldDifferential) <= 0 && iCount > 0
                iCount -= 1
                goldDifferential = calculatedVendorGold - (sellValue * iCount)
            EndWhile

            If iCount > 0
                calculatedVendorGold -= sellValue * iCount
                totalSellValue += sellValue * iCount
                SellListCounts[iCurrent] = iCount
                SellListValues[iCurrent] = sellValue
                MiscUtil.PrintConsole("JunkIt - Caclulated Sell " + iCount + " " + item.GetName() + " for " + (sellValue * iCount) + " gold. Current calculated VendorGold total " + calculatedVendorGold + " gold")
                TotalToSell += iCount
            Else
                ; Remove the item from the list if we can't sell any of it
                SellListCounts[iCurrent] = 0
                SellListValues[iCurrent] = 0
            EndIf
        EndIf

        iCurrent += 1
    EndWhile

    If TotalToSell <= 0
        MiscUtil.PrintConsole("JunkIt - Vendor cannot afford to buy any junk!")
        Debug.Notification("JunkIt - Vendor cannot afford to buy any junk!")
        Return
    EndIf

    ; Confirm the sale
    If ConfirmSell.GetValue() >= 1
        Int iConfChoice = SellConfirmationMsg.Show(RoundNumber(totalSellValue))
        If(iConfChoice == 1) ;No
            Return
        EndIf
    EndIf

    ; Move any gold the vendor has to the vendorContainer so we only have to deal with a single source of gold
    Int vendorActorGold = vendorActor.GetItemCount(Gold001)
    If vendorActorGold > 0
        vendorActor.RemoveItem(Gold001, vendorActorGold, false, vendorContainer)
    Endif

    ; Gold payout - Needs to be down before item exchange for a proper UI update on vendor gold
    vendorContainer.RemoveItem(Gold001, RoundNumber(totalSellValue), false, PlayerREF)

    ; Ensure the UI is correctly updated
    UI.SetFloat("BarterMenu", "_root.Menu_mc._vendorGold", RoundNumber(vendorGoldDisplay - totalSellValue))

    ; Sell the junk items
    iCurrent = 0
    While iCurrent < iTotal
        Form item = SellList.GetAt(iCurrent)
        Int iCount = SellListCounts[iCurrent]
        Float iSaleValue = SellListValues[iCurrent] * iCount
        
        ; Double check item sale count
        If iCount > 0           
            ; Do the item exchange
            PlayerREF.RemoveItem(item, iCount, false, vendorContainer)
            MiscUtil.PrintConsole("JunkIt - Sold " + iCount + " " + item.GetName() + " for " + iSaleValue + " gold")
        EndIf
        iCurrent += 1
    EndWhile

    ; @TODO - Include speech skill increase calculations from transactions

    If TotalToSell >= TotalPossibleToSell
        MiscUtil.PrintConsole("JunkIt - Sold All Junk Items for " + totalSellValue + " Gold")
        Debug.Notification("JunkIt - Sold Junk Items!")
    Else
        MiscUtil.PrintConsole("JunkIt - Sold " + TotalToSell + " Junk Items for " + totalSellValue + " Gold")
        Debug.Notification("JunkIt - Sold " + TotalToSell + " Junk Items!")
    EndIf
EndFunction

Int Function RoundNumber (Float number)
    Float ceilingNumber = Math.Ceiling(number) as Float

    If ((ceilingNumber - number) > 0.5)
        Return Math.Floor(number)
    Else
        Return Math.Ceiling(number)
    EndIf
EndFunction
