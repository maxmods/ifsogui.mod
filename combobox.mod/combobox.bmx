SuperStrict

Rem
	bbdoc: ifsoGUI Combobox
	about: Combobox Gadget
EndRem
Module ifsogui.combobox

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.panel
Import ifsogui.listbox

GUI.Register(ifsoGUI_ComboBox.SystemEvent)
GUI.Register(ifsoGUI_ComboBoxDrop.SystemEvent)

Rem
	bbdoc: ComboBox Type
End Rem
Type ifsoGUI_Combobox Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button down
	Global gImageOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button over
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Global gImageButton:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageButtonDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button down
	Global gImageButtonOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button over
	Global gTileButtonSides:Int, gTileButtonCenter:Int 'Should the graphics be tiled or stretched
	Global gImageArrow:TImage 'Images to draw the arrows on the buttons
	Field lImage:ifsoGUI_Image 'Images to draw the button
	Field lImageDown:ifsoGUI_Image 'Images to draw the button down
	Field lImageOver:ifsoGUI_Image 'Images to draw the button over
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImageButton:ifsoGUI_Image 'Images to draw the button
	Field lImageButtonDown:ifsoGUI_Image 'Images to draw the button down
	Field lImageButtonOver:ifsoGUI_Image 'Images to draw the button over
	Field lTileButtonSides:Int, lTileButtonCenter:Int 'Should the graphics be tiled or stretched
	Field lImageArrow:TImage 'Images to draw the arrows on the buttons
	
	Field ImageButtonLeft:Int, ImageButtonRight:Int 'width of the imagebuttons sides
	Field ButtonWidth:Int 'Width of the button
	Field dropPanel:ifsoGUI_ComboBoxDrop 'Use a panel for always on top
	Field dropList:ifsoGUI_ListBox 'Listbox shows choices
	Field Dropped:Int = False 'If the droplist is showing
	Field Selected:ifsoGUI_ListItem
	Field ShowItems:Int = 5
	Field Closed:Int = False 'If drop box closed but combo button has focus, dont send gain focus event
	Field NoMouseUp:Int = False 'Special case, when drop is closed byt he mouse, combo gets the mouse up event this keeps form losingt focus
	
	Rem
		bbdoc: Create and returns a combobox gadget.
	End Rem
	Function Create:ifsoGUI_ComboBox(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_Combobox = New ifsoGUI_Combobox
		p.dropList = ifsoGUI_ListBox.Create(0, 0, iW, iH, strName + "_listbox")
		p.dropList.SetShowBorder(False)
		p.dropList.SetHScrollbar(0)
		p.dropList.SetVScrollBar(2)
		p.dropList.SetMultiSelect(False)
		p.dropList.Master = p
		p.Slaves.AddLast(p.dropList)
		p.dropPanel = ifsoGUI_ComboBoxDrop.Create(iX, iY, iW, iH, strName + "_panel")
		p.dropPanel.Master = p
		p.dropPanel.AddChild(p.dropList)
		p.Slaves.AddLast(p.dropPanel)
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lImageDown = gimageDown
		p.lImageOver = gImageOver
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.lImageButton = gImageButton
		p.lImageButtonDown = gImageButtonDown
		p.lImageButtonOver = gImageButtonOver
		p.lTileButtonSides = gTileButtonSides
		p.lTileButtonCenter = gTileButtonCenter
		p.lImageArrow = gImageArrow
		p.SetWH(iW, iH)
		p.Name = strName
		p.CalcBox()
		For Local i:Int = 0 To 2
			p.TextColor[i] = GUI.TextColor[i]
		Next
		GUI.AddGadget(p.dropPanel)
		Return p
	End Function
	Rem
		bbdoc: Draws the gadget.
		about: Internal function should not be called by the user.
	End Rem
	Method Draw(parX:Int, parY:Int, parW:Int, parH:Int)
		If Not Visible Return
		If x > parW Or y > parH Return
		SetColor(Color[0], Color[1], Color[2])
		SetAlpha(fAlpha)
		'set up rendering locations
		Local rX:Int = parX + x
		Local rY:Int = parY + y
		'Select the correct image
		Local dImage:ifsoGUI_Image
		Local dButtonImage:ifsoGUI_Image
		If bPressed
			dImage = lImageDown
			dButtonImage = lImageButtonDown
		ElseIf GUI.gMouseOverGadget = Self
			dImage = lImageOver
			dButtonImage = lImageButtonOver
		Else
			dImage = lImage
			dButtonImage = lImageButton
		End If
		DrawBox2(dImage, rX, rY, w - ButtonWidth, h, True, lTileSides, lTileCenter)
		DrawBox2(dButtonImage, rX + w - ButtonWidth, rY, ButtonWidth, h, True, lTileSides, lTileCenter)
		ifsoGUI_VP.DrawImageArea(lImageArrow, rX + w - ImageButtonRight - lImageArrow.width, rY + h / 2 - lImageArrow.height / 2)
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		Local vpX:Int, vpY:Int, vpW:Int, vpH:Int
		vpX = rX + BorderLeft
		vpY = ry + BorderTop
		vpW = w - (BorderLeft + BorderRight + ButtonWidth)
		vpH = h - (BorderTop + BorderBottom)
		ifsoGUI_VP.Add(vpX, vpY, vpW, vpH)
		If Selected
			If fFont SetImageFont(fFont)
			Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
			ifsoGUI_VP.DrawTextArea(Selected.Name, vpX + 2, ((h - th) / 2) + rY, Self)
			If fFont SetImageFont(GUI.DefaultFont)
		End If
		If ShowFocus And HasFocus DrawFocus(vpX + 1, vpY + 1, vpW - 2, vpH - 2)
		ifsoGUI_VP.Pop()
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not Visible Return False
		If dropPanel.IsMouseOver(0, 0, GUI.iWidth, GUI.iHeight, iMouseX, iMouseY)
		 DebugLog "here"
			Return True
		End If
		If (iMouseX >= parX + x) And (iMouseX < parX + x + w) And (iMouseY >= parY + y) And (iMouseY < parY + y + h)
			Local chkX:Int = x, chkY:Int = y
			If chkX < 0 chkX = 0
			If chkY < 0 chkY = 0
			Local chkW:Int = w, chkH:Int = h 'Check if the width is off the parent
			If x + w > parW chkW = parW - x
			If y + h > parH chkH = parH - y
			For Local c:ifsoGUI_Base = EachIn Children
				If c.IsMouseOver(parX + chkX, parY + chkY, chkW, chkH, iMouseX, iMouseY) Return True
			Next
			GUI.gMouseOverGadget = Self
			Return True
		End If
		Return False
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not (Enabled And Visible) Return
		If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
			bPressed = True
			GUI.SetActiveGadget(Self)
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		bPressed = False
		If Not (Enabled And Visible) Return
		If GUI.gMouseOverGadget = Self
			If Dropped
				HideDropBox()
			Else
			 ShowDropBox()
			End If
		Else
			If NoMouseUp
				NoMouseUp = False
			Else
			 GUI.SetActiveGadget(Null)
			End If
 		If Dropped HideDropBox()
		End If
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
	 If key = 13 Or Key = 32 'Carriage Return or Space
			ShowDropBox()
		End If
	End Method
	Rem
	bbdoc: Called from a slave gadget.
	about: Slave gadgets do not generate GUI events.  They send events to their Master.
	The Master then uses it or can send a GUI event.
	Internal function should not be called by the user.
	End Rem
	Method SlaveEvent(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		If (data > - 1) And (id = ifsoGUI_EVENT_CLICK Or id = ifsoGUI_EVENT_DOUBLE_CLICK)
			If iMouseX > - 1 Or id = ifsoGUI_EVENT_DOUBLE_CLICK
				If iMouseX > - 1 NoMouseUp = True 'If mouse click closed the dropbox
				Closed = True
				HideDropBox()
				GUI.SetActiveGadget(Self)
			End If
			If dropList.GetSelected() <> data dropList.SetSelected(data, True)
			If Selected <> dropList.GetItem(data)
				Selected = dropList.GetItem(data)
				SendEvent(ifsoGUI_EVENT_CHANGE, data, 0, 0)
			End If
		ElseIf gadget.name = Name + "_panel" And id = ifsoGUI_EVENT_MOUSE_ENTER
			MouseOver(iMouseX, iMouseY, GUI.gWasMouseOverGadget)
		ElseIf gadget.name = Name + "_panel" And id = ifsoGUI_EVENT_MOUSE_EXIT
			MouseOut(iMouseX, iMouseY, GUI.gMouseOverGadget)
		ElseIf id = ifsoGUI_EVENT_LOST_FOCUS
			LostFocus(GUI.gActiveGadget)
		End If
	End Method
	Rem
	bbdoc: Sorts the list.  Will be sorted by the Name field by default, set bData=true to sort byt he data field.
	End Rem
	Method SortList(bDesc:Int = False, bSortAsInt:Int = False, bData:Int = False)
		If bData
			If bDesc
				dropList.FastQuickSortDataDesc(dropList.Items)
			Else
				dropList.FastQuickSortData(dropList.Items)
			End If
		ElseIf bSortAsInt
			If bDesc
				dropList.FastQuickSortIntDesc(dropList.Items)
			Else
				dropList.FastQuickSortInt(dropList.Items)
			End If
		Else
			If bDesc
				dropList.FastQuickSortDesc(dropList.Items)
			Else
				dropList.FastQuickSort(dropList.Items)
			End If
		End If
	End Method
	Rem
	bbdoc:Loads a skin for one instance of the gadget
	End Rem
	Method LoadSkin(strSkin:String)
		dropPanel.LoadSkin(strSkin)
		dropList.LoadSkin(strSkin)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lImageDown = gimageDown
			lImageOver = gImageOver
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			lImageButton = gImageButton
			lImageButtonDown = gImageButtonDown
			lImageButtonOver = gImageButtonOver
			lTileButtonSides = gTileButtonSides
			lTileButtonCenter = gTileButtonCenter
			lImageArrow = gImageArrow
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("combobox", strSkin).Split(",")
		Load9Image2("/graphics/combobox.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		If GUI.FileExists(strSkin + "/graphics/comboboxover.png")
			Load9Image2("/graphics/comboboxover.png", dimensions, lImageOver, strSkin)
		Else
			lImageOver = lImage
		End If
		If GUI.FileExists(strSkin + "/graphics/comboboxdown.png")
			Load9Image2("/graphics/comboboxdown.png", dimensions, lImageDown, strSkin)
		Else
			lImageDown = lImage
		End If
		lImageArrow = LoadImage(GUI.FileHeader + strSkin + "/graphics/arrow.png")
		lImageArrow = RotateImage(lImageArrow)
		dimensions = GetDimensions("combobox button", strSkin).Split(",")
		Load9Image2("/graphics/combobutton.png", dimensions, lImageButton, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileButtonSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileButtonCenter = True
		End If
		If GUI.FileExists(strSkin + "/graphics/combobuttonover.png")
			Load9Image2("/graphics/combobuttonover.png", dimensions, lImageButtonOver, strSkin)
		Else
			lImageButtonOver = lImageButton
		End If
		If GUI.FileExists(strSkin + "/graphics/combobuttondown.png")
			Load9Image2("/graphics/combobuttondown.png", dimensions, lImageButtonDown, strSkin)
		Else
			lImageButtonDown = lImageButton
		End If
		dimensions = GetDimensions("combobox drop", strSkin).Split(",")
		Load9Image2("/graphics/combodrop.png", dimensions, dropPanel.lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" dropPanel.lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" dropPanel.lTileCenter = True
		End If
		Refresh()
	End Method
	Rem
	bbdoc: Called when the gadget is no longer the Active Gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method LostFocus(GainedFocus:ifsoGUI_Base) 'Gadget Lost focus
		If IsMySlave(GainedFocus)
			bPressed = False
		Else
			If GainedFocus <> Self
				bPressed = False
				HasFocus = False
				SendEvent(ifsoGUI_EVENT_LOST_FOCUS, 0, 0, 0)
			 If Dropped HideDropBox()
			End If
		End If
	End Method
	Rem
	bbdoc: Called when the gadget becomes the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method GainFocus(LostFocus:ifsoGUI_Base)  'Gadget Got focus
		HasFocus = True
		If Closed
			Closed = False
		Else
			If Not IsMySlave(LostFocus) SendEvent(ifsoGUI_EVENT_GAIN_FOCUS, 0, 0, 0)
		End If
	End Method
	Rem
	bbdoc: Shows the dropdown portion of the combobox.
	about: Internal function should not be called by the user.
	End Rem
	Method ShowDropBox()
		Local iX:Int, iY:Int
		dropPanel.Visible = True
		dropPanel.BringToFront()
		GetAbsoluteXY(iX, iY)
		dropPanel.SetXY(iX, iY + h - 1)
		GUI.SetActiveGadget(dropList)
		Dropped = True
		SendEvent(ifsoGUI_EVENT_CLICK, 0, 0, 0)
	End Method
	Rem
	bbdoc: Hides the dropdown portion of the combobox.
	about: Internal function should not be called by the user.
	End Rem
	Method HideDropBox()
		dropPanel.Visible = False
		Dropped = False
	End Method
	Rem
	bbdoc: Calculates the location and size of the dropdown box.
	about: Internal function should not be called by the user.
	End Rem
	Method CalcBox()
		Local Widest:Int = 0
		If dropList.fFont SetImageFont(dropList.fFont)
		For Local item:ifsoGUI_ListItem = EachIn dropList.Items
			If ifsoGUI_VP.GetTextWidth(item.Name, Self) > Widest Widest = ifsoGUI_VP.GetTextWidth(item.Name, Self) + 2
		Next
		Widest:+dropPanel.BorderLeft + dropPanel.BorderRight + dropList.ScrollBarWidth + 2
		If Widest < W Widest = W
		Local Height:Int
		If dropList.Items.Length < ShowItems
			Height = dropList.ItemHeight * dropList.Items.Length
		Else
			Height = dropList.ItemHeight * ShowItems
		End If
		If dropList.fFont SetImageFont(GUI.DefaultFont)
		dropPanel.SetWH(Widest, Height + dropPanel.BorderTop + dropPanel.BorderBottom)
		dropList.SetWH(Widest - (dropPanel.BorderLeft + dropPanel.BorderRight), Height)
	End Method
	Rem
	bbdoc: Returns the next gadget after start in the child list.
	about: Internal function should not be called by the user.
	End Rem
	Method NextGadget:ifsoGUI_Base(start:ifsoGUI_Base, bForward:Int = True)
		Local bFlag:Int
		If (Not start) bFlag = True
		If bForward
			If Dropped
				For Local c:ifsoGUI_Base = EachIn Slaves
					If bFlag Return c
					If c = start bFlag = True
				Next
			End If
			For Local c:ifsoGUI_Base = EachIn Children
				If bFlag Return c
				If c = start bFlag = True
			Next
		Else
			Local l:TLink = Slaves.LastLink()
			If Dropped
				While l
					If bFlag Return ifsoGUI_Base(l.Value())
					If l.Value() = start bFlag = True
					l = l.PrevLink()
				Wend
			End If
			l = Children.LastLink()
			While l
				If bFlag Return ifsoGUI_Base(l.Value())
				If l.Value() = start bFlag = True
				l = l.PrevLink()
			Wend
		End If
		Return Null
	End Method
	Rem
		bbdoc: Refreshes the gadget.
		about: Recalculates any geometry/font changes, etc.
		Internal function should not be called by the user.
	End Rem
	Method Refresh()
		If lImage = gImage
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			lTileButtonSides = gTileButtonSides
			lTileButtonCenter = gTileButtonCenter
		End If
		BorderTop = lImage.h[1]
		BorderBottom = lImage.h[7]
		BorderLeft = lImage.w[3]
		BorderRight = lImage.w[5]
		ImageButtonLeft = lImageButton.w[3]
		ImageButtonRight = lImageButton.w[5]
		ButtonWidth = ImageButtonLeft + ImageButtonRight + lImageArrow.width
		If AutoSize
			Local wasFont:TImageFont = GetImageFont()
			If fFont
				SetImageFont(fFont)
			Else
				SetImageFont(GUI.DefaultFont)
			End If
			Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
			SetImageFont(wasFont)
			h = th + BorderTop + BorderBottom
		End If
		CalcBox()
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("combobox").Split(",")
		Load9Image2("/graphics/combobox.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/comboboxover.png")
			Load9Image2("/graphics/comboboxover.png", dimensions, gImageOver)
		Else
			gImageOver = gImage
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/comboboxdown.png")
			Load9Image2("/graphics/comboboxdown.png", dimensions, gImageDown)
		Else
			gImageDown = gImage
		End If
		gImageArrow = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/arrow.png")
		gImageArrow = RotateImage(gImageArrow)
		dimensions = GetDimensions("combobox button").Split(",")
		Load9Image2("/graphics/combobutton.png", dimensions, gImageButton)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileButtonSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileButtonCenter = True
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/combobuttonover.png")
			Load9Image2("/graphics/combobuttonover.png", dimensions, gImageButtonOver)
		Else
			gImageButtonOver = gImageButton
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/combobuttondown.png")
			Load9Image2("/graphics/combobuttondown.png", dimensions, gImageButtonDown)
		Else
			gImageButtonDown = gImageButton
		End If
		dimensions = GetDimensions("combobox drop").Split(",")
		Load9Image2("/graphics/combodrop.png", dimensions, ifsoGUI_ComboBoxDrop.gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" ifsoGUI_ComboBoxDrop.gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" ifsoGUI_ComboBoxDrop.gTileCenter = True
		End If
	End Function
	Rem
	bbdoc: GUI system event occured.
	about: Internal function should not be called by the user.
	End Rem
	Function SystemEvent(id:Int, data:Int)
		If id = ifsoGUI_EVENT_SYSTEM_NEW_THEME
			LoadTheme()
		End If
	End Function

	'User Functions/Properties
	Rem
	bbdoc: Sets the number of items to show in the dropdown box.
	End Rem
	Method SetShowItems(iNumItems:Int)
		ShowItems = iNumItems
		Refresh()
	End Method
	Rem
	bbdoc: Returns the number of items shown in the dropdown box.
	End Rem
	Method GetShowItems:Int()
		Return ShowItems
	End Method
	Rem
	bbdoc: Adds an item to the combo box.
	End Rem
	Method AddItem(strName:String, intData:Int = 0, strTip:String = "", bSelected:Int = False)
		dropList.AddItem(strName, intData, strTip)
		If bSelected
		 Selected = dropList.Items[dropList.Items.Length - 1]
			dropList.SetSelected(dropList.Items.Length - 1, True)
		End If
	 Refresh()
	End Method
	Rem
	bbdoc: Inserts an item into the combo box.
	End Rem
	Method InsertItem(intIndex:Int, strName:String, intData:Int = 0, strTip:String = "", bSelected:Int = False)
		dropList.InsertItem(intIndex, strName, intData, strTip)
		If bSelected
		 Selected = dropList.Items[intIndex]
			dropList.SetSelected(intIndex, True)
		End If
		Refresh()
	End Method
	Rem
	bbdoc: Removes an item from the combo box.
	End Rem
	Method RemoveItem(intIndex:Int)
		If Selected = dropList.Items[intIndex] Selected = Null
		dropList.RemoveItem(intIndex)
		Refresh()
	End Method
	Rem
	bbdoc: Removes all items from the combo box.
	End Rem
	Method RemoveAll()
		dropList.RemoveAll()
		Selected = Null
		Refresh()
	End Method
	Rem
	bbdoc: Returns the selected item.
	End Rem
	Method GetSelectedItem:ifsoGUI_ListItem()
		Return Selected
	End Method
	Rem
	bbdoc: Returns the name of the selected item.
	End Rem
	Method GetSelectedName:String()
		If Not Selected Return ""
		Return Selected.Name
	End Method
	Rem
	bbdoc: Returns the data of the selected item.
	End Rem
	Method GetSelectedData:Int()
		If Not Selected Return 0
		Return Selected.Data
	End Method
	Rem
	bbdoc: Returns the tip of the selected item.
	End Rem
	Method GetSelectedTip:String()
		If Not Selected Return ""
		Return Selected.Tip
	End Method
	Rem
	bbdoc: Sets the selected index.
	End Rem
	Method SetSelected(intIndex:Int)
		If intIndex > dropList.Items.Length - 1 Return
		If intIndex = -1
			Selected = Null
			Return
		End If
		If intIndex < 0 Return
		Selected = dropList.Items[intIndex]
		dropList.SetSelected(intIndex, True)
	End Method
	Rem
	bbdoc: Returns the selected index.
	End Rem
	Method GetSelected:Int()
		For Local i:Int = 0 To dropList.Items.Length - 1
			If dropList.Items[i].Selected Return i
		Next
		Return - 1
	End Method
	Rem
	bbdoc: Sets the font of the drop list.
	End Rem
	Method SetDropListFont(Font:TImageFont)
		dropList.SetFont(Font)
	End Method
End Type

Rem
	bbdoc: ComboBox DropDown Box
	about: For internal use only.
End Rem
Type ifsoGUI_ComboBoxDrop Extends ifsoGUI_Panel
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the panel
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched

	Rem
		bbdoc: Creates and returns the dropdown box.
	End Rem
	Function Create:ifsoGUI_ComboBoxDrop(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_ComboBoxDrop = New ifsoGUI_ComboBoxDrop
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.HBar = ifsoGUI_ScrollBar.Create(0, 0, 0, 0, strName + "_hbar", False)
		p.VBar = ifsoGUI_ScrollBar.Create(0, 0, 0, 0, strName + "_vbar", True)
		p.HBar.SetVisible(False)
		p.HBar.Master = p
		p.VBar.SetVisible(False)
		p.VBar.Master = p
		p.Slaves.AddLast(p.HBar)
		p.Slaves.AddLast(p.VBar)
		p.SetScrollbars(0)
		p.Name = strName
		p.Enabled = False
		p.SetShowBorder(True)
		p.SetTransparent(True)
		p.SetAlwaysOnTop(True)
		p.SetVisible(False)
		p.SetWH(iW, iH)
		Return p
	End Function
	Rem
		bbdoc: Draws the dropdown box.
	End Rem
	Method Draw(parX:Int, parY:Int, parW:Int, parH:Int)
		If Not Visible Return
		SetColor(Color[0], Color[1], Color[2])
		DrawBox2(lImage, X, Y, W, H, True, lTileSides, lTileCenter)
		DrawChildren(X + BorderLeft, Y + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
	End Method
	Rem
		bbdoc: Retrieves the absolute position of the dropdown box.
	End Rem
	Method GetAbsoluteXY(iX:Int Var, iY:Int Var, caller:ifsoGUI_Base = Null)
		iX:+x + BorderLeft
		iY:+y + BorderTop
	End Method
	
End Type
