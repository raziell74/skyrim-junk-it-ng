Scriptname JunkIt_MCM extends MCM_ConfigBase

;--- JunkIt Properties --------------------------------------------------------------

Actor Property PlayerRef Auto
Keyword Property IsJunkKYWD Auto
FormList Property JunkList Auto
FormList Property UnjunkedList Auto

GlobalVariable Property ConfirmTransfer Auto
GlobalVariable Property ConfirmSell Auto

GlobalVariable Property TransferPriority Auto
GlobalVariable Property SellPriority Auto

GlobalVariable Property ProtectEquipped Auto
GlobalVariable Property ProtectFavorites Auto

Message Property TransferConfirmationMsg Auto
Message Property RetrievalConfirmationMsg Auto
Message Property SellConfirmationMsg Auto

MiscObject Property Gold001 Auto

;--- JunkIt Non Property MCM Variables ----------------------------------------------

Int UserJunkKey = 50
Int TransferJunkKey = 49

;--- JunkIt Private Variables -------------------------------------------------------

Bool migrated = False
String plugin = "JunkIt.esp"

String ActiveMenu = ""

; --- JunkIt.dll Native Functions ---------------------------------------------------
Function RefreshDllSettings() global native

Int Function AddJunkKeyword(Form a_form) global native
Int Function RemoveJunkKeyword(Form a_form) global native
Function RefreshUIIcons() global native

Int Function GetContainerMode() global native
ObjectReference Function GetContainerMenuContainer() global native
ObjectReference Function GetBarterMenuContainer() global native
ObjectReference Function GetBarterMenuMerchantContainer() global native

FormList Function GetTransferFormList() global native
FormList Function GetSellFormList() global native

; --- MCM Helper Functions ----------------------------------------------------------

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

    LoadSettings()

    ; BugFix: Corrects false positive junk keywords on load
    JunkList = CorrectJunkListKeywords(JunkList, True)
    UnjunkedList = CorrectJunkListKeywords(UnjunkedList, False)
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

    ; Protection Settings
    ElseIf a_ID == "bProtectEquipped:Protection"
        ProtectEquipped.SetValue(GetModSettingBool(a_ID) as Float)
    ElseIf a_ID == "bProtectFavorites:Protection"
        ProtectFavorites.SetValue(GetModSettingBool(a_ID) as Float)
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

    ; Protection Settings
    SetModSettingBool("bProtectEquipped:Protection", True)
    SetModSettingBool("bProtectFavorites:Protection", True)

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

    ; Protection Settings
    ProtectEquipped.SetValue(GetModSettingBool("bProtectEquipped:Protection") as Float)
    ProtectFavorites.SetValue(GetModSettingBool("bProtectFavorites:Protection") as Float)

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

    ; Protection Settings
    SetModSettingBool("bProtectEquipped:Protection", ProtectEquipped.GetValue() as Bool)
    SetModSettingBool("bProtectFavorites:Protection", ProtectFavorites.GetValue() as Bool)
EndFunction

Function VerboseMessage(String m)
    If GetModSettingBool("bDebug:Maintenance")
        Debug.Trace("JunkIt - " + m)
        MiscUtil.PrintConsole("JunkIt - " + m)
    EndIf

    If GetModSettingBool("bVerbose:Maintenance")
        Debug.Notification("JunkIt - " + m)
    EndIf
EndFunction

; --- JunkIt Functionality ---------------------------------------------------

; OnMenuOpen
; Enables the hotkey when the player opens the Inventory Menu.
;
; @param MenuName String  the name of the menu
; @returns  None
Event OnMenuOpen(String MenuName)
    ActiveMenu = MenuName
    GotoState("")
EndEvent

; OnMenuClose
; Disables the hotkey when the player closes the Inventory Menu.
;
; @param MenuName String  the name of the menu
; @returns  None
Event OnMenuClose(String MenuName)
    ActiveMenu = ""
    GotoState("busy")
EndEvent

; OnKeyDown
; Listens for the hotkey and performs the appropriate action based on the active menu.
;
; @param KeyCode Int  the key code
; @param HoldTime Float  the hold time
; @returns  None
Event OnKeyDown(Int KeyCode)
    If ActiveMenu != "" && !UI.IsTextInputEnabled()
        GotoState("busy")
        If KeyCode == UserJunkKey
            ToggleIsJunk()
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
    ; OnKeyDown
    ; Disables event during busy state
    ;
    ; @param KeyCode Int  the key code
    ; @param HoldTime Float  the hold time
    ; @returns  None
    Event OnKeyDown(Int KeyCode)
    EndEvent
EndState

; ToggleIsJunk
; Toggles the selected item in an Item Menu as junk or not junk.
;
; @returns  None
Function ToggleIsJunk()
    ; Get the selected item in the Item Menu
    Int selectedFormId = UI.GetInt(ActiveMenu, "_root.Menu_mc.inventoryLists.itemList.selectedEntry.formId")
    Form selected_item = Game.GetFormEx(selectedFormId)

    If !selected_item.HasKeyword(IsJunkKYWD)
        MarkAsJunk(selected_item)
    Else
        UnmarkAsJunk(selected_item)
    EndIf
EndFunction

; MarkAsJunk
; Marks the selected item in an Item Menu as junk.
;
; @param item Form  the item to mark as junk
; @returns  None
Function MarkAsJunk(Form item)
    LockItemListUI()

    Bool success = AddJunkKeyword(item) as Bool
    
    If !success
        VerboseMessage("Failed to mark " + item.GetName() + " as junk")
        Debug.MessageBox("JunkIt - Failed to mark " + item.GetName() + " as junk")
        UnlockItemListUI()
        Return
    EndIf

    VerboseMessage("Form: " + item.GetName() + " has been marked as junk")
    Debug.Notification("JunkIt - " + item.GetName() + " has been marked as junk")

    UnlockItemListUI()

    ; Update Junk FormList
    If !JunkList.HasForm(item)
        JunkList.AddForm(item)
    EndIf

    ; Stop tracking this item for GameLoad keyword correction
    If UnjunkedList.HasForm(item)
        UnjunkedList.RemoveAddedForm(item)
    EndIf
EndFunction

; UnmarkAsJunk
; Unmarks the selected item in an Item Menu as junk.
;
; @param item Form  the item to unmark as junk
; @returns  None
Function UnmarkAsJunk(Form item)
    LockItemListUI()
    Bool success = RemoveJunkKeyword(item) as Bool
    
    If !success
        VerboseMessage("Failed to unmark " + item.GetName() + " as junk")
        Debug.MessageBox("JunkIt - Failed to unmark " + item.GetName() + " as junk")
        UnlockItemListUI()
        Return
    EndIf

    VerboseMessage("Form: " + item.GetName() + " is no longer marked as junk")
    Debug.Notification("JunkIt - " + item.GetName() + " is no longer marked as junk")

    UnlockItemListUI()
    
    ; Update Junk FormList
    If JunkList.HasForm(item)
        JunkList.RemoveAddedForm(item)
    EndIf

    ; Keep track of unjunked items for GameLoad keyword correction
    If !UnjunkedList.HasForm(item)
        UnjunkedList.AddForm(item)
    EndIf
EndFunction

; TransferJunk
; Transfers Junk Items to the container/NPC or retrieves them 
; from the container if UI is showing the players inventory
;
; @returns  None
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
        VerboseMessage("Junk Transfer disabled while pickpocketing")
        Debug.MessageBox("Junk Transfer is disabled while pickpocketing")
        Return
    EndIf

    if menuView == 0 ; VIEWING CONTAINER
        ; Retrieve from container
        If transferContainer.GetItemCount(TransferList) <= 0
            VerboseMessage("No Junk to retrieve!")
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
            VerboseMessage("No Junk to transfer!")
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
        LockItemListUI()
        transferContainer.RemoveItem(TransferList, 9999, true, PlayerREF)
        VerboseMessage("Junk Retrieved!")
        Debug.Notification("JunkIt - Junk Retrieved!")
        UnlockItemListUI()
        Return
    EndIf

    If canTransfer == TRUE
        ; Find out if we're trading with an NPC and account for their carry weight
        If(containerMode == 3) ; NPC Mode
            Actor transferActor = transferContainer as Actor
            Float maxWeight = transferActor.GetActorValue("CarryWeight")
            Float currentWeight = transferContainer.GetTotalItemWeight()
            VerboseMessage("[NPC Mode] CarryWeight " + currentWeight + "/" + maxWeight)

            Int iTotal = TransferList.GetSize()
            Int iCurrent = 0
            Int TotalTransferred = 0
            Int TotalPossibleTransferred = 0

            FormList TransferAllList = TransferList

            LockItemListUI()

            While iCurrent < iTotal
                Form item = TransferList.GetAt(iCurrent)	
    		    Int iCount = PlayerREF.GetItemCount(item)
                Int iTotalCount = iCount
                TotalPossibleTransferred += iCount
    		
                If iCount > 0
                    Float itemWeight = item.GetWeight()
                    Float currentWeightWithItems = (itemWeight * iCount) + currentWeight
                    
                    While currentWeightWithItems > maxWeight
                        iCount -= 1
                        currentWeightWithItems = (itemWeight * iCount) + currentWeight
                    EndWhile

                    If iCount > 0 && iCount < iTotalCount
                        ; Transfer only a limited quantity of this item
                        PlayerREF.RemoveItem(item, iCount, true, transferContainer)
                        currentWeight += (itemWeight * iCount)
                        TotalTransferred += iCount

                        ; Ignore this item for the bulk transfer
                        TransferAllList.RemoveAddedForm(item)

                        VerboseMessage("Transferred limited quantity " + iCount + " " + item.GetName() + " to " + transferActor.GetName() + " [" + RoundNumber(currentWeight) + "/" + RoundNumber(maxWeight) + "]" )
                    ElseIf iCount <= 0
                        ; We cannot transfer any of this item so remove it from the bulk transfer list
                        TransferAllList.RemoveAddedForm(item)
                    Else
                        ; Can transfer the full quanity of this item, let it remain in the bulk transfer list
                        TotalTransferred += iCount
                        currentWeight += (itemWeight * iCount)
                        VerboseMessage("Listing " + iCount + " " + item.GetName() + " for full quantity transfer to " + transferActor.GetName() + " [" + RoundNumber(currentWeight) + "/" + RoundNumber(maxWeight) + "]" )
                    EndIf
                EndIf

                iCurrent += 1
            EndWhile

            ; Do Bulk Transfer of items that we can transfer all of
            If TransferAllList.GetSize() > 0
                PlayerREF.RemoveItem(TransferAllList, 9999, true, transferContainer)
            EndIf

            If TotalTransferred >= TotalPossibleTransferred
                VerboseMessage("[NPC Mode] Transferred All Junk to " + transferActor.GetName() + " [" + currentWeight + "/" + maxWeight + "]")
                Debug.Notification("JunkIt - Transferred All Junk!")
            Else
                VerboseMessage("[NPC Mode] Transferred " + TotalTransferred + " Junk Items to " + transferActor.GetName() + " [" + currentWeight + "/" + maxWeight + "]")
                Debug.Notification("JunkIt - Transferred " + TotalTransferred + " Junk Items!")
            EndIf

            UnlockItemListUI()
        Else
            LockItemListUI()
            PlayerREF.RemoveItem(TransferList, 9999, true, transferContainer)
            Debug.Notification("JunkIt - Transferred Junk!")
            UnlockItemListUI()
        EndIf
    EndIf
EndFunction

; SellJunk
; Sells all junk items to the vendor
;
; @returns  None
Function SellJunk()
    If JunkList.GetSize() <= 0
        VerboseMessage("No Junk to sell!")
        Debug.MessageBox("No Junk to sell!")
        Return
    EndIf

    ; JunkIt.dll Native function gets a filtered 
    ; version of the junk list that is 
    ; sorted by priority, equip and favorite filtered, 
    ; and limited to only items in this barter session
    FormList SellList = GetSellFormList()

    ; Check if the players inventory has any junk to sell
    If PlayerREF.GetItemCount(SellList) <= 0
        VerboseMessage("No Junk to sell!")
        Debug.Notification("JunkIt - No Junk to sell!")
        Return
    EndIf
    
    ; Get the actors and containers involved in the barter
    Actor vendorActor = GetBarterMenuContainer() as Actor
    ObjectReference vendorContainer = GetBarterMenuMerchantContainer()

    VerboseMessage("Vendor Actor FormId: " + vendorActor.GetFormID())
    VerboseMessage("Vendor Container FormId: " + vendorContainer.GetFormID())

    Debug.Notification("JunkIt - Selling junk please wait...")
    LockItemListUI()

    Float vendorGoldDisplay = UI.GetFloat("BarterMenu", "_root.Menu_mc._vendorGold")
    Float buyMult = UI.GetFloat("BarterMenu", "_root.Menu_mc._buyMult")
    Float sellMult = UI.GetFloat("BarterMenu", "_root.Menu_mc._sellMult")

    VerboseMessage("Vendor Gold: " + vendorGoldDisplay)
    VerboseMessage("Vendor Buy Mult: " + buyMult)
    VerboseMessage("Vendor Sell Mult: " + sellMult)

    Int iTotal = SellList.GetSize()
    Int iCurrent = 0
    Int TotalToSell = 0
    Int TotalPossibleToSell = 0
    Float calculatedVendorGold = vendorGoldDisplay
    Float totalSellValue = 0

    ; These represent the final items to be sold
    FormList SellAllList = SellList
    Form[] SellPartialList = new Form[125]
    Int[] SellPartialCounts = new Int[125]
    Int PartialSellItemCount = 0

    VerboseMessage("Sell List Size: " + SellList.GetSize())
    
    While iCurrent < iTotal
        Form item = SellList.GetAt(iCurrent)	
        Int iCount = PlayerREF.GetItemCount(item)
        Int iTotalCount = iCount
        TotalPossibleToSell += iCount

        ; Calculate how many junk items we can sell based on the vendors gold
        If iCount > 0
            Float sellValue = (item.GetGoldValue() * sellMult)
            Float goldDifferential = calculatedVendorGold - (sellValue * iCount)
            
            While RoundNumber(goldDifferential) <= 0 && iCount > 0
                iCount -= 1
                goldDifferential = calculatedVendorGold - (sellValue * iCount)
            EndWhile

            If iCount > 0 && iCount < iTotalCount
                ; We can only sell a limited amount of this item
                SellAllList.RemoveAddedForm(item)

                ; Add this item as a listing for partial sale and track the quantity to be sold
                SellPartialCounts[PartialSellItemCount] = iCount
                SellPartialList[PartialSellItemCount] = item
                VerboseMessage("Creating partial listing for " + iCount + " " + item.GetName() + " at index " + PartialSellItemCount + " for " + (sellValue * iCount) + " gold. Post sale VendorGold is " + RoundNumber(vendorGoldDisplay - totalSellValue) + " gold")
                PartialSellItemCount += 1

                ; Update our totals for the confirmation message
                calculatedVendorGold -= sellValue * iCount
                totalSellValue += sellValue * iCount
                TotalToSell += iCount
            ElseIf iCount <= 0
                ; We cannot sell any of this item so remove it from the bulk sell list
                SellAllList.RemoveAddedForm(item)
            Else
                ; We can sell the full quanity of this item
                calculatedVendorGold -= sellValue * iCount
                totalSellValue += sellValue * iCount
                TotalToSell += iCount

                VerboseMessage("Calculated Full Quantity Sell " + iCount + " " + item.GetName() + " for " + (sellValue * iCount) + " gold. Post sale VendorGold is " + RoundNumber(vendorGoldDisplay - totalSellValue) + " gold")
            EndIf
        EndIf

        iCurrent += 1
    EndWhile

    ; After calculations check if the vendor could afford any of the junk
    If TotalToSell <= 0
        VerboseMessage("Vendor cannot afford to buy any junk!")
        Debug.MessageBox("Vendor cannot afford to buy any junk!")
        UnlockItemListUI()
        Return
    EndIf

    ; Confirm the sale
    If ConfirmSell.GetValue() >= 1
        Int iConfChoice = SellConfirmationMsg.Show(RoundNumber(totalSellValue))
        If(iConfChoice == 1) ;No
            UnlockItemListUI()
            Return
        EndIf
    EndIf

    ; Move any gold the vendor has on them to the vendorContainer so we only have to deal with a single source of gold
    Int vendorActorGold = vendorActor.GetItemCount(Gold001)
    If vendorActorGold > 0
        vendorActor.RemoveItem(Gold001, vendorActorGold, true, vendorContainer)
    Endif

    ; Handle the Gold payout for the junk sale
    vendorContainer.RemoveItem(Gold001, RoundNumber(totalSellValue), false, PlayerREF)

    ; Update UI with the new vendor gold total, the itemlist update can not be trusted
    UI.SetFloat("BarterMenu", "_root.Menu_mc._vendorGold", RoundNumber(vendorGoldDisplay - totalSellValue))

    ; Transfer partial quantity item listings
    Int PartialIndex = 0
    VerboseMessage("SellPartialList Size: " + PartialSellItemCount)
    While PartialIndex < PartialSellItemCount
        Form item = SellPartialList[PartialIndex]
        Int iCount = SellPartialCounts[PartialIndex]
        
        ; Double check item sale count
        If iCount > 0
            ; Do the item exchange
            PlayerREF.RemoveItem(item, iCount, true, vendorContainer)
            VerboseMessage("Transaction for partial quantity listing " + iCount + " " + item.GetName() + " at index " + PartialIndex + " complete")
        EndIf
        PartialIndex += 1
    EndWhile

    ; Transfer all the items that we didn't have to individually sell
    If SellAllList.GetSize() > 0
        PlayerREF.RemoveItem(SellAllList, 9999, true, vendorContainer)
        VerboseMessage("Transaction of full quantity item sales complete")
    EndIf

    ; @TODO - Include speech skill increase calculations from transactions

    If TotalToSell >= TotalPossibleToSell
        VerboseMessage("Sold All Junk Items for " + totalSellValue + " Gold")
        Debug.Notification("JunkIt - Sold Junk Items!")
    Else
        VerboseMessage("Sold " + TotalToSell + " Junk Items for " + totalSellValue + " Gold")
        Debug.Notification("JunkIt - Sold " + TotalToSell + " Junk Items!")
    EndIf

    UnlockItemListUI()
EndFunction

; --- JunkIt Utilities --------------------------------------------------------------

; CorrectJunkListKeywords 
; Iterates through a formlist to add or remove the junk keyword
;
; @param List   FormList  the formlist to iterate through
; @param IsJunk Bool  whether to add or remove the junk keyword
; @returns  FormList  the modified formlist
FormList Function CorrectJunkListKeywords(FormList List, Bool IsJunk = True)
    Int i = 0
    Int iTotal = List.GetSize()
    
    While i < iTotal
        Form item = List.GetAt(i)

        If IsJunk && !item.HasKeyword(IsJunkKYWD)
            VerboseMessage("Item Correction: Marking " + item.GetName() + " as junk")
            AddJunkKeyword(item)
        ElseIf !IsJunk && item.HasKeyword(IsJunkKYWD)
            VerboseMessage("Item Correction: Removing junk keyword from " + item.GetName())
            RemoveJunkKeyword(item)
        EndIf

        i += 1
    EndWhile

    Return List
EndFunction

; RoundNumber
; Rounds a float to the nearest integer
;
; @param number Float  the number to round
; @returns  Int  the rounded number
Int Function RoundNumber (Float number)
    Float ceilingNumber = Math.Ceiling(number) as Float

    If ((ceilingNumber - number) > 0.5)
        Return Math.Floor(number)
    Else
        Return Math.Ceiling(number)
    EndIf
EndFunction

; LockItemListUI
; Disables the UI for the ItemList in the InventoryMenu
;
; @returns  None
Function LockItemListUI()
    UI.SetBool("ContainerMenu", "_root.Menu_mc.inventoryLists.itemList.disableInput", true)
    UI.SetBool("ContainerMenu", "_root.Menu_mc.inventoryLists.itemList.disableSelection", true)
    UI.SetBool("ContainerMenu", "_root.Menu_mc.inventoryLists.itemList.canSelectDisabled", true)
    UI.SetBool("ContainerMenu", "_root.Menu_mc.inventoryLists.itemList.suspended", true)
EndFunction

; UnlockItemListUI
; Enables the UI for the ItemList in the InventoryMenu
;
; @param bUpdateUI Bool  whether to update the UI icons
; @returns  None
Function UnlockItemListUI(bool bUpdateUI = true)
    UI.SetBool("ContainerMenu", "_root.Menu_mc.inventoryLists.itemList.disableInput", false)
    UI.SetBool("ContainerMenu", "_root.Menu_mc.inventoryLists.itemList.disableSelection", false)
    UI.SetBool("ContainerMenu", "_root.Menu_mc.inventoryLists.itemList.canSelectDisabled", false)
    UI.SetBool("ContainerMenu", "_root.Menu_mc.inventoryLists.itemList.suspended", false)

    If bUpdateUI
        RefreshUIIcons()
    EndIf
EndFunction
