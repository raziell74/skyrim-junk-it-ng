ScriptName JunkIt Hidden

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

        Debug.MessageBox("This item is now junk!")
    ElseIf selected_item.HasKeyword(IsJunkKYWD)
        RemoveKeywordOnForm(selected_item, IsJunkKYWD)
        JunkList.RemoveAddedForm(selected_item)

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
EndFunction
