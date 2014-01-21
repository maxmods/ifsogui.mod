SuperStrict

Rem
	bbdoc: ifsoGUI Listbox
	about: Listbox Gadget
EndRem
Module ifsogui.listbox

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.scrollbar

GUI.Register(ifsoGUI_ListBox.SystemEvent)

Rem
	bbdoc: Listbox Type
End Rem
Type ifsoGUI_ListBox Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image 'Images to draw the button
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	Field Items:ifsoGUI_ListItem[]
	Field TopItem:Int 'Item at the visible top of the list
	Field VisibleItems:Int 'Number of items visible in the list
	Field Widest:Int 'Widest item in the list
	Field ItemHeight:Int 'Height of one item
	Field VScrollbar:Int = 2 'Show vertical scrollbar when list is to tall, 0-Never 1-Always 2-When needed
	Field HScrollBar:Int = 0 'Show horizontal scrollbar when list is too wide, 0-Never 1-Always 2-When needed
	Field VBarOn:Int 'Is the VBar on
	Field HBarOn:Int 'Is the hbar on
	Field HBar:ifsoGUI_ScrollBar, VBar:ifsoGUI_ScrollBar
	Field ScrollBarWidth:Int = 20 'Width of the scrollbars
	Field MultiSelect:Int = False 'Is the listbox multi select 
	Field LastSelected:Int = -1 'For Keyboard control
	Field Highlighted:Int = -1 'Currently highlighted item
	Field LastMouseClick:Int 'For Double click detection
	Field ShowBorder:Int = True
	Field BorderTop:Int, BorderBottom:Int, BorderLeft:Int, BorderRight:Int 'Border dimensions
	Field OriginX:Int 'Offset for the Horizontal Bar
	Field MouseHighlight:Int = True 'Does the highlight follow the mouse
	Field WasX:Int, WasY:Int 'So we can ignore the mouse if it doesn't move for MouseHighlight
	Field HighlightColor:Int[] = [220, 220, 255] 'Color of the gadget
	Field SelectColor:Int[] = [40, 40, 255] 'Color of the gadget
	Field HighlightTextColor:Int[] = [0, 0, 0] 'Color of the gadget
	Field SelectTextColor:Int[] = [0, 0, 0] 'Color of the gadget
	'Events
	'Mouse Enter/Mouse Exit/Change
	
	Rem
		bbdoc: Create and returns a Listbox gadget.
	End Rem
	Function Create:ifsoGUI_ListBox(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_ListBox = New ifsoGUI_ListBox
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.HBar = ifsoGUI_ScrollBar.Create(0, iH - (p.ScrollBarWidth + p.BorderBottom), iW, p.ScrollBarWidth, strName + "_hbar", False)
		p.HBar.SetVisible(False)
		p.HBar.Master = p
		p.HBar.SetMax(1)
		p.VBar = ifsoGUI_ScrollBar.Create(iW - (p.ScrollBarWidth + p.BorderRight), 0, p.ScrollBarWidth, iH, strName + "_vbar", True)
		p.VBar.SetVisible(False)
		p.VBar.Master = p
		p.VBar.SetMax(1)
		p.Slaves.AddLast(p.VBar)
		p.Slaves.AddLast(p.HBar)
		p.Name = strName
		p.SetShowBorder(True)
		p.SetWH(iW, iH)
		For Local i:Int = 0 To 2
			p.TextColor[i] = GUI.TextColor[i]
		Next
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
		'Draw the frame and back
		DrawBox2(lImage, rX, rY, w, h, ShowBorder, lTileSides, lTileCenter)
		Local width:Int = w - (BorderLeft + BorderRight)
		If VBarOn width:-ScrollBarWidth
		Local height:Int = h - (BorderTop + BorderBottom)
		If HBarOn height:-ScrollBarWidth
		ifsoGUI_VP.Add(rX + BorderLeft, rY + BorderTop, width, height)
		'Draw the highlighted and selected rows
		If (HasFocus Or VBar.HasFocus Or HBar.HasFocus) And Highlighted >= TopItem And HighLighted <= TopItem + VisibleItems
			SetColor(HighlightColor[0], HighlightColor[1], HighlightColor[2])
			ifsoGUI_VP.DrawRect(rX + BorderLeft, rY + BorderTop + ItemHeight * (Highlighted - TopItem), width, ItemHeight)
		End If
		SetColor(SelectColor[0], SelectColor[1], SelectColor[2])
		For Local i:Int = TopItem To Items.Length - 1
			If i > TopItem + VisibleItems Exit
			If Items[i].Selected
				If i = Highlighted And (HasFocus Or VBar.HasFocus Or HBar.HasFocus)
					ifsoGUI_VP.DrawRect(rX + BorderLeft + 1, rY + BorderTop + ItemHeight * (i - TopItem) + 1, width - 2, ItemHeight - 2)
				Else
					ifsoGUI_VP.DrawRect(rX + BorderLeft, rY + BorderTop + ItemHeight * (i - TopItem), width, ItemHeight)
				End If
			End If
		Next
		'Draw the lines of text
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		If fFont SetImageFont(fFont)
		For Local i:Int = TopItem To Items.Length - 1
			If i > TopItem + VisibleItems Exit
			If Items[i].Selected SetColor(SelectTextColor[0], SelectTextColor[1], SelectTextColor[2])
			ifsoGUI_VP.DrawTextArea(Items[i].Name, rX + BorderLeft - OriginX + 1, rY + BorderTop + ((i - TopItem) * ItemHeight), Self)
			If Items[i].Selected SetColor(TextColor[0], TextColor[1], TextColor[2])
			If ItemHeight * (i - TopItem) > H Exit
		Next
		If fFont SetImageFont(GUI.DefaultFont)
		ifsoGUI_VP.Pop()
		VBar.Draw(rX + BorderLeft, rY + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
		HBar.Draw(rX + BorderLeft, rY + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not (Visible And Enabled) Return False
		Local locX:Int = parX + x + BorderLeft, locY:Int = parY + y + BorderTop
		Local locW:Int = w - (BorderLeft + BorderRight), locH:Int = h - (BorderTop + BorderBottom)
		If (iMouseX > locX) And (iMouseX < locX + locW) And (iMouseY > locY) And (iMouseY < locY + locH)
			If HBar.IsMouseOver(locX, locY, locW, locH, iMouseX, iMouseY) Return True
			If VBar.IsMouseOver(locX, locY, locW, locH, iMouseX, iMouseY) Return True
			GUI.gMouseOverGadget = Self
			Return True
		End If
		Return False
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		VBar.LoadSkin(strSkin)
		HBar.LoadSkin(strSkin)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("listbox", strSkin).Split(",")
		Load9Image2("/graphics/listbox.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		Refresh()
	End Method
	Rem
	bbdoc: Called when the mouse is over this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base) 'Called when mouse is over the gadget, only topmost gadget
		Super.MouseOver(iMouseX, iMouseY, gWasOverGadget)
		If Not (Enabled And Visible) Return
		If iMouseX = WasX And iMouseY = WasY Return
		Tip = ""
		WasX = iMouseX
		WasY = iMouseY
		Local iX:Int, iY:Int
		GetAbsoluteXY(iX, iY)
		Local OverItem:Int = ((iMouseY - (iY + BorderTop)) / ItemHeight) 'Item mouse is over
		If VBarOn And iMouseX > iX + w - (BorderRight + ScrollBarWidth) OverItem = -1
		If HBarOn And iMouseY > iY + h - (BorderBottom + ScrollBarWidth) OverItem = -1
		If OverItem >= 0 OverItem:+TopItem
		If OverItem < Items.Length And OverItem >= 0
			If MouseHighlight And HasFocus Or VBar.HasFocus Or HBar.HasFocus Highlighted = OverItem
			Tip = Items[OverItem].Tip
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not (Visible And enabled) Return
		GUI.SetActiveGadget(Self)
		bPressed = iButton
		Local iX:Int, iY:Int
		GetAbsoluteXY(iX, iY)
		Local OverItem:Int = ((iMouseY - (iY + BorderTop)) / ItemHeight) 'Item mouse is over
		If OverItem >= 0 OverItem:+TopItem
		If OverItem >= Items.Length Or OverItem < 0
		 OverItem = -1
			Tip = ""
		Else
			If MouseHighlight Highlighted = OverItem
			Tip = Items[OverItem].Tip
		End If
		Local bShifted:Int, bControled:Int
		If MultiSelect 'Is shift or control pressed?
			If KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL) bControled = True
			If KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT) bShifted = True
		End If
		If bPressed = ifsoGUI_RIGHT_MOUSE_BUTTON Or bPressed = ifsoGUI_MIDDLE_MOUSE_BUTTON
			If OverItem > - 1
		 	If Not (bShifted Or bControled) 'Change the current selection
					If MultiSelect
						For Local i:Int = 0 To Items.Length - 1
							Items[i].Selected = False
						Next
					Else
						If LastSelected > - 1 Items[LastSelected].Selected = False 'Unselect last selected
					End If
					HighLighted = OverItem
					LastSelected = OverItem
					Items[OverItem].Selected = True
					SendEvent(ifsoGUI_EVENT_CHANGE, OverItem, iMouseX, iMouseY)
				End If
			End If
		Else
			Local bDoubleClick:Int = False
			If (MilliSecs() - LastMouseClick < ifsoGUI_DOUBLE_CLICK_DELAY) And OverItem = LastSelected
				SendEvent(ifsoGUI_EVENT_DOUBLE_CLICK, LastSelected, iMouseX, iMouseY)
				bDoubleClick = True
			Else
				If bShifted
					If OverItem > - 1
						If LastSelected > - 1
							Local iFrom:Int = LastSelected, iTo:Int = OverItem
							If LastSelected > OverItem
								iFrom = OverItem
								iTo = LastSelected
							End If
							For Local i:Int = 0 To Items.Length - 1
								If i < iFrom Or i > iTo
									Items[i].Selected = False
								Else
									Items[i].Selected = True
								End If
							Next
						End If
						Highlighted = OverItem
						LastSelected = OverItem
						SendEvent(ifsoGUI_EVENT_CHANGE, OverItem, iMouseX, iMouseY)
					End If
				ElseIf bControled
					If OverItem > - 1
						Highlighted = OverItem
						LastSelected = OverItem
						Items[OverItem].Selected = Not Items[OverItem].Selected
						SendEvent(ifsoGUI_EVENT_CHANGE, OverItem, iMouseX, iMouseY)
					End If
				Else
					If OverItem <> LastSelected
						If MultiSelect
							For Local i:Int = 0 To Items.Length - 1
								Items[i].Selected = False
							Next
						Else
							If LastSelected > - 1 Items[LastSelected].Selected = False
						End If
						HighLighted = OverItem
						LastSelected = OverItem
						If OverItem > - 1 Items[OverItem].Selected = True
						SendEvent(ifsoGUI_EVENT_CHANGE, OverItem, iMouseX, iMouseY)
					End If
				End If
			End If
			LastMouseClick = MilliSecs()
			If bDoubleClick LastMouseClick:-ifsoGUI_DOUBLE_CLICK_DELAY
		End If
		If Highlighted > TopItem + VisibleItems - 1
		 TopItem = Highlighted - (VisibleItems - 1)
			VBar.SetValue(TopItem)
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		bPressed = False
		If Not (Visible And enabled) Return
		'Send mouse click event Click, Right, Middle are equal to Mouse Left/Right/Middle.
		SendEvent(iButton, Highlighted, iMouseX, iMouseY)
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
		If Highlighted < 0 Return
	 If key = ifsoGUI_KEY_UP Or key = ifsoGUI_KEY_DOWN Or key = ifsoGUI_KEY_HOME Or key = ifsoGUI_KEY_END Or key = ifsoGUI_KEY_PAGEUP Or key = ifsoGUI_KEY_PAGEDOWN Or key = ifsoGUI_KEY_RIGHT Or key = ifsoGUI_KEY_LEFT
			If (key = ifsoGUI_KEY_UP) 'Cursor Up
				If Highlighted > 0 Highlighted:-1
			Else If (key = ifsoGUI_KEY_DOWN) 'Cursor Down
				If Highlighted < Items.Length - 1 Highlighted:+1
			Else If (key = ifsoGUI_KEY_RIGHT) 'Cursor Right
				If HBarOn HBar.SetValue(HBar.GetValue() + 1)
			Else If (key = ifsoGUI_KEY_LEFT) 'Cursor Left
				If HBarOn HBar.SetValue(HBar.GetValue() - 1)
			Else If (key = ifsoGUI_KEY_HOME) 'Home
				Highlighted = 0
			Else If (key = ifsoGUI_KEY_END) 'End
				Highlighted = Items.Length - 1
			Else If (key = ifsoGUI_KEY_PAGEUP) 'PageUp
				If Highlighted = TopItem
					Highlighted:-VisibleItems
					If Highlighted < 0 Highlighted = 0
				Else
					Highlighted = TopItem
				End If
			Else If (key = ifsoGUI_KEY_PAGEDOWN) 'PageDown
				If Highlighted = TopItem + VisibleItems - 1
					Highlighted:+VisibleItems
					If Highlighted > Items.Length - 1 Highlighted = Items.Length - 1
				Else
					Highlighted = TopItem + VisibleItems - 1
					If Highlighted > Items.Length - 1 Highlighted = Items.Length - 1
				End If
			End If
			If Highlighted < TopItem
				VBar.SetValue(Highlighted)
			Else If Highlighted > TopItem + VisibleItems - 1
				VBar.SetValue(Highlighted - (VisibleItems - 1))
			End If
			If MultiSelect And (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
				Local iFrom:Int = LastSelected, iTo:Int = Highlighted
				If LastSelected > highlighted
					iFrom = Highlighted
					iTo = LastSelected
				End If
				For Local i:Int = 0 To Items.Length - 1
					If i < iFrom Or i > iTo
						Items[i].Selected = False
					Else
						Items[i].Selected = True
					End If
				Next
				SendEvent(ifsoGUI_EVENT_CLICK, Highlighted, - 1, - 1)
			ElseIf Not (KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL))
				If MultiSelect
					For Local i:Int = 0 To Items.Length - 1
						Items[i].Selected = False
					Next
				Else
					If LastSelected > - 1 Items[LastSelected].Selected = False
				End If
				Items[Highlighted].Selected = True
				LastSelected = Highlighted
				SendEvent(ifsoGUI_EVENT_CLICK, LastSelected, - 1, - 1)
			End If
		Else If key = 13 Or key = 10 'CR
			If MultiSelect
				If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT) Or KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL))
					If Highlighted > - 1 Items[Highlighted].Selected = True
					LastSelected = Highlighted
					SendEvent(ifsoGUI_EVENT_DOUBLE_CLICK, LastSelected, - 1, - 1)
				Else
					If LastSelected >= 0 SendEvent(ifsoGUI_EVENT_DOUBLE_CLICK, LastSelected, - 1, - 1)
				End If
			Else
				If LastSelected > - 1 Items[LastSelected].Selected = False
				LastSelected = Highlighted
				If LastSelected > - 1
				 Items[LastSelected].Selected = True
					SendEvent(ifsoGUI_EVENT_DOUBLE_CLICK, LastSelected, - 1, - 1)
				End If
			End If
		Else If Key = ifsoGUI_MOUSE_WHEEL_UP
		 VBar.SetValue(VBar.Value - (GUI.iMouseZChange * VBar.Interval))
		Else If Key = ifsoGUI_MOUSE_WHEEL_DOWN
		 VBar.SetValue(VBar.Value - (GUI.iMouseZChange * VBar.Interval))
		Else If Key = KEY_SPACE 'Space
			If MultiSelect
				If KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT)
					Local iFrom:Int = LastSelected, iTo:Int = Highlighted
					If LastSelected > Highlighted
						iFrom = Highlighted
						iTo = LastSelected
					End If
					For Local i:Int = 0 To Items.Length - 1
						If i < iFrom Or i > iTo
							Items[i].Selected = False
						Else
							Items[i].Selected = True
						End If
					Next
				ElseIf KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL)
					Items[Highlighted].Selected = Not Items[Highlighted].Selected
					LastSelected = Highlighted
				Else
					For Local i:Int = 0 To Items.Length - 1
						Items[i].Selected = False
					Next
					Items[Highlighted].Selected = True
					LastSelected = Highlighted
				End If
				If LastSelected > - 1 SendEvent(ifsoGUI_EVENT_CLICK, HighLighted, -1, -1)
			Else
				If LastSelected > - 1 Items[LastSelected].Selected = False
				LastSelected = Highlighted
				If LastSelected > - 1
				 Items[LastSelected].Selected = True
					SendEvent(ifsoGUI_EVENT_CLICK, LastSelected, - 1, - 1)
				End If
			End If
		End If
	End Method
	Rem
	bbdoc: Called when the gadget becomes the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method GainFocus(LostFocus:ifsoGUI_Base)
		HasFocus = True
		If Items.Length > 0
			If Highlighted = -1 Highlighted = LastSelected
			If Highlighted = -1 Highlighted = Topitem
		Else
			Highlighted = -1
		End If
		If Not IsMySlave(LostFocus) SendEvent(ifsoGUI_EVENT_GAIN_FOCUS, 0, 0, 0)
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
		End If
		If ShowBorder
			BorderTop = lImage.h[1]
			BorderBottom = lImage.h[7]
			BorderLeft = lImage.w[3]
			BorderRight = lImage.w[5]
		Else
			BorderTop = 0
			BorderBottom = 0
			BorderLeft = 0
			BorderRight = 0
		End If
		Local wasFont:TImageFont = GetImageFont()
		If fFont
			SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		Widest = 0
		For Local i:ifsoGUI_ListItem = EachIn Items
			If ifsoGUI_VP.GetTextWidth(i.Name, Self) + 2 > Widest Widest = ifsoGUI_VP.GetTextWidth(i.Name, Self) + 2
		Next
		ItemHeight = ifsoGUI_VP.GetTextHeight(Self)
		SetImageFont(wasFont)
		HBar.SetXY(0, h - (ScrollBarWidth + BorderTop + BorderBottom))
		VBar.SetXY(w - (ScrollBarWidth + BorderLeft + BorderRight), 0)
		If Highlighted < 0 And Items.Length > 0 Highlighted = 0
		VBarOn = False
		HBarOn = False
		If VScrollbar = 1 VBarOn = True
		If HScrollbar = 1 HBarOn = True
		For Local i:Int = 0 To 1
			If Not VBarOn
				If VScrollbar = 2
					If HBarOn
						If Items.Length * ItemHeight > h - (BorderTop + BorderBottom + ScrollbarWidth) VBarOn = True
					Else
						If Items.Length * ItemHeight > h - (BorderTop + BorderBottom) VBarOn = True
					End If
				End If
			End If
			If Not HBarOn
				If HScrollbar = 2
					If VBarOn
						If Widest > w - (BorderLeft + BorderRight + ScrollbarWidth) HBarOn = True
					Else
						If Widest > w - (BorderLeft + BorderRight) HBarOn = True
					End If
				End If
			End If
		Next
		If HBarOn
			VisibleItems = (h - (ScrollBarWidth + BorderTop + BorderBottom)) / ItemHeight
		Else
			VisibleItems = (h - (BorderTop + BorderBottom)) / ItemHeight
		End If
		Local imax:Int = Items.Length
		If imax < 1 imax = 1
		Local iInt:Int = VisibleItems
		If iInt > imax iInt = imax
		VBar.SetBarInterval(iInt)
		VBar.SetMax(imax)
		HBar.SetVisible(HBarOn)
		VBar.SetVisible(VBarOn)
		If HBarOn And VBarOn
		 HBar.SetWH(w - (ScrollbarWidth + BorderLeft + BorderRight), ScrollbarWidth)
		 VBar.SetWH(ScrollBarWidth, h - (ScrollbarWidth + BorderTop + BorderBottom))
		Else
		 HBar.SetWH(w - (BorderLeft + BorderRight), ScrollbarWidth)
		 VBar.SetWH(ScrollBarWidth, h - (BorderTop + BorderBottom))
		End If
		If Widest = 0 Widest = w - (ScrollBarWidth + BorderLeft + BorderRight)
		If HBarOn 'Set the min max interval etc for the HBar
			HBar.SetMax(Widest)
			If VBarOn
				HBar.SetBarInterval(w - (ScrollBarWidth + BorderLeft + BorderRight))
			Else
				HBar.SetBarInterval(w - (BorderLeft + BorderRight))
			End If
			OriginX = HBar.Value
		Else
			OriginX = 0
		End If
	End Method
	Rem
	bbdoc: Called from a slave gadget.
	about: Slave gadgets do not generate GUI events.  They send events to their Master.
	The Master then uses it or can send a GUI event.
	Internal function should not be called by the user.
	End Rem
	Method SlaveEvent(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		Select id
			Case ifsoGUI_EVENT_CHANGE
				If gadget.Name = Name + "_hbar"
			 	OriginX = data
				ElseIf gadget.Name = Name + "_vbar"
			 	TopItem = data
				End If
			Case ifsoGUI_EVENT_MOUSE_UP
				GUI.gActiveGadget = Self
				HasFocus = True
			Case ifsoGUI_EVENT_MOUSE_ENTER
				MouseOver(iMouseX, iMouseY, GUI.gWasMouseOverGadget)
			Case ifsoGUI_EVENT_MOUSE_EXIT
				MouseOut(iMouseX, iMouseY, GUI.gMouseOverGadget)
			Case ifsoGUI_EVENT_GAIN_FOCUS
				If Not HasFocus GainFocus(Null)
			Case ifsoGUI_EVENT_LOST_FOCUS
				LostFocus(GUI.gActiveGadget)
		End Select
	End Method
	Rem
		bbdoc: Used to sort the list by the Name field
	End Rem
	Function FastQuickSort(array:ifsoGUI_ListItem[])
		QuickSort(array, 0, array.Length - 1)
		InsertionSort(array, 0, array.Length - 1)
	
		Function QuickSort(a:ifsoGUI_ListItem[], l:Int, r:Int)
			If (r - l) > 4
				Local tmp:ifsoGUI_ListItem
				Local i:Int, j:Int, v:String
				i = (r + l) / 2
				If (a[l].Name.ToUpper() > a[i].Name.ToUpper()) 'swap(a, l, i)
					tmp = a[l]
					a[l] = a[i]
					a[i] = tmp
				End If
				If (a[l].Name.ToUpper() > a[r].Name.ToUpper()) 'swap(a, l, r)
					tmp = a[l]
					a[l] = a[r]
					a[r] = tmp
				End If
				If (a[i].Name.ToUpper() > a[r].Name.ToUpper()) 'swap(a, i, r)
					tmp = a[i]
					a[i] = a[r]
					a[r] = tmp
				End If
				j = r - 1
				'swap(a, i, j)
				tmp = a[i]
				a[i] = a[j]
				a[j] = tmp
				i = l
				v = a[j].Name.ToUpper()
				Repeat
					i:+1
					While a[i].Name.ToUpper() < v ; i:+1; Wend
					j:-1
					While a[j].Name.ToUpper() > v ; j:-1;Wend
					If (j < i) Exit
					'swap (a, i, j)
					tmp = a[i]
					a[i] = a[j]
					a[j] = tmp
				Forever
				'swap(a, i, r - 1)
				tmp = a[i]
				a[i] = a[r - 1]
				a[r - 1] = tmp
				QuickSort(a, l, j)
				QuickSort(a, i + 1, r)
			End If
		End Function
	
		Function InsertionSort(a:ifsoGUI_ListItem[], lo0:Int, hi0:Int)
			Local i:Int, j:Int, v:ifsoGUI_ListItem
			For i = lo0 + 1 To hi0
				v = a[i]
				j = i
				While (j > lo0) And (a[j - 1].Name.ToUpper() > v.Name.ToUpper())
					a[j] = a[j - 1]
	    j:-1
				Wend
				a[j] = v
			Next
		End Function
	End Function
	Rem
		bbdoc: Used to sort the list by the Name field descending.
	End Rem
	Function FastQuickSortDesc(array:ifsoGUI_ListItem[])
		QuickSort(array, 0, array.Length - 1)
		InsertionSort(array, 0, array.Length - 1)
	
		Function QuickSort(a:ifsoGUI_ListItem[], l:Int, r:Int)
			If (r - l) > 4
				Local tmp:ifsoGUI_ListItem
				Local i:Int, j:Int, v:String
				i = (r + l) / 2
				If (a[l].Name.ToUpper() < a[i].Name.ToUpper()) 'swap(a, l, i)
					tmp = a[l]
					a[l] = a[i]
					a[i] = tmp
				End If
				If (a[l].Name.ToUpper() < a[r].Name.ToUpper()) 'swap(a, l, r)
					tmp = a[l]
					a[l] = a[r]
					a[r] = tmp
				End If
				If (a[i].Name.ToUpper() < a[r].Name.ToUpper()) 'swap(a, i, r)
					tmp = a[i]
					a[i] = a[r]
					a[r] = tmp
				End If
				j = r - 1
				'swap(a, i, j)
				tmp = a[i]
				a[i] = a[j]
				a[j] = tmp
				i = l
				v = a[j].Name.ToUpper()
				Repeat
					i:+1
					While a[i].Name.ToUpper() > v ; i:+1; Wend
					j:-1
					While a[j].Name.ToUpper() < v ; j:-1;Wend
					If (j < i) Exit
					'swap (a, i, j)
					tmp = a[i]
					a[i] = a[j]
					a[j] = tmp
				Forever
				'swap(a, i, r - 1)
				tmp = a[i]
				a[i] = a[r - 1]
				a[r - 1] = tmp
				QuickSort(a, l, j)
				QuickSort(a, i + 1, r)
			End If
		End Function
	
		Function InsertionSort(a:ifsoGUI_ListItem[], lo0:Int, hi0:Int)
			Local i:Int, j:Int, v:ifsoGUI_ListItem
			For i = lo0 + 1 To hi0
				v = a[i]
				j = i
				While (j > lo0) And (a[j - 1].Name.ToUpper() < v.Name.ToUpper())
					a[j] = a[j - 1]
	    j:-1
				Wend
				a[j] = v
			Next
		End Function
	End Function
	Rem
		bbdoc: Used to sort the list by the Name field but sorted as integers.
	End Rem
	Function FastQuickSortInt(array:ifsoGUI_ListItem[])
		QuickSort(array, 0, array.Length - 1)
		InsertionSort(array, 0, array.Length - 1)
	
		Function QuickSort(a:ifsoGUI_ListItem[], l:Int, r:Int)
			If (r - l) > 4
				Local tmp:ifsoGUI_ListItem
				Local i:Int, j:Int, v:Int
				i = (r + l) / 2
				If (Int(a[l].Name) > Int(a[i].Name)) 'swap(a, l, i)
					tmp = a[l]
					a[l] = a[i]
					a[i] = tmp
				End If
				If (Int(a[l].Name) > Int(a[r].Name)) 'swap(a, l, r)
					tmp = a[l]
					a[l] = a[r]
					a[r] = tmp
				End If
				If (Int(a[i].Name) > Int(a[r].Name)) 'swap(a, i, r)
					tmp = a[i]
					a[i] = a[r]
					a[r] = tmp
				End If
				j = r - 1
				'swap(a, i, j)
				tmp = a[i]
				a[i] = a[j]
				a[j] = tmp
				i = l
				v = Int(a[j].Name)
				Repeat
					i:+1
					While Int(a[i].Name) < v ; i:+1; Wend
					j:-1
					While Int(a[j].Name) > v ; j:-1;Wend
					If (j < i) Exit
					'swap (a, i, j)
					tmp = a[i]
					a[i] = a[j]
					a[j] = tmp
				Forever
				'swap(a, i, r - 1)
				tmp = a[i]
				a[i] = a[r - 1]
				a[r - 1] = tmp
				QuickSort(a, l, j)
				QuickSort(a, i + 1, r)
			End If
		End Function
	
		Function InsertionSort(a:ifsoGUI_ListItem[], lo0:Int, hi0:Int)
			Local i:Int, j:Int, v:ifsoGUI_ListItem
			For i = lo0 + 1 To hi0
				v = a[i]
				j = i
				While (j > lo0) And (Int(a[j - 1].Name) > Int(v.Name))
					a[j] = a[j - 1]
	    j:-1
				Wend
				a[j] = v
			Next
		End Function
	End Function
	Rem
		bbdoc: Used to sort the list by the Name field but sorted as integers descending.
	End Rem
	Function FastQuickSortIntDesc(array:ifsoGUI_ListItem[])
		QuickSort(array, 0, array.Length - 1)
		InsertionSort(array, 0, array.Length - 1)
	
		Function QuickSort(a:ifsoGUI_ListItem[], l:Int, r:Int)
			If (r - l) > 4
				Local tmp:ifsoGUI_ListItem
				Local i:Int, j:Int, v:Int
				i = (r + l) / 2
				If (Int(a[l].Name) < Int(a[i].Name)) 'swap(a, l, i)
					tmp = a[l]
					a[l] = a[i]
					a[i] = tmp
				End If
				If (Int(a[l].Name) < Int(a[r].Name)) 'swap(a, l, r)
					tmp = a[l]
					a[l] = a[r]
					a[r] = tmp
				End If
				If (Int(a[i].Name) < Int(a[r].Name)) 'swap(a, i, r)
					tmp = a[i]
					a[i] = a[r]
					a[r] = tmp
				End If
				j = r - 1
				'swap(a, i, j)
				tmp = a[i]
				a[i] = a[j]
				a[j] = tmp
				i = l
				v = Int(a[j].Name)
				Repeat
					i:+1
					While Int(a[i].Name) > v ; i:+1; Wend
					j:-1
					While Int(a[j].Name) < v ; j:-1;Wend
					If (j < i) Exit
					'swap (a, i, j)
					tmp = a[i]
					a[i] = a[j]
					a[j] = tmp
				Forever
				'swap(a, i, r - 1)
				tmp = a[i]
				a[i] = a[r - 1]
				a[r - 1] = tmp
				QuickSort(a, l, j)
				QuickSort(a, i + 1, r)
			End If
		End Function
	
		Function InsertionSort(a:ifsoGUI_ListItem[], lo0:Int, hi0:Int)
			Local i:Int, j:Int, v:ifsoGUI_ListItem
			For i = lo0 + 1 To hi0
				v = a[i]
				j = i
				While (j > lo0) And (Int(a[j - 1].Name) < Int(v.Name))
					a[j] = a[j - 1]
	    j:-1
				Wend
				a[j] = v
			Next
		End Function
	End Function
	Rem
		bbdoc: Used to sort the list by the Data field
	End Rem
	Function FastQuickSortData(array:ifsoGUI_ListItem[])
		QuickSort(array, 0, array.Length - 1)
		InsertionSort(array, 0, array.Length - 1)
	
		Function QuickSort(a:ifsoGUI_ListItem[], l:Int, r:Int)
			If (r - l) > 4
				Local tmp:ifsoGUI_ListItem
				Local i:Int, j:Int, v:Int
				i = (r + l) / 2
				If (a[l].Data > a[i].Data) 'swap(a, l, i)
					tmp = a[l]
					a[l] = a[i]
					a[i] = tmp
				End If
				If (a[l].Data > a[r].Data) 'swap(a, l, r)
					tmp = a[l]
					a[l] = a[r]
					a[r] = tmp
				End If
				If (a[i].Data > a[r].Data) 'swap(a, i, r)
					tmp = a[i]
					a[i] = a[r]
					a[r] = tmp
				End If
				j = r - 1
				'swap(a, i, j)
				tmp = a[i]
				a[i] = a[j]
				a[j] = tmp
				i = l
				v = a[j].Data
				Repeat
					i:+1
					While a[i].Data < v ; i:+1; Wend
					j:-1
					While a[j].Data > v ; j:-1;Wend
					If (j < i) Exit
					'swap (a, i, j)
					tmp = a[i]
					a[i] = a[j]
					a[j] = tmp
				Forever
				'swap(a, i, r - 1)
				tmp = a[i]
				a[i] = a[r - 1]
				a[r - 1] = tmp
				QuickSort(a, l, j)
				QuickSort(a, i + 1, r)
			End If
		End Function
	
		Function InsertionSort(a:ifsoGUI_ListItem[], lo0:Int, hi0:Int)
			Local i:Int, j:Int, v:ifsoGUI_ListItem
			For i = lo0 + 1 To hi0
				v = a[i]
				j = i
				While (j > lo0) And (a[j - 1].Data > v.Data)
					a[j] = a[j - 1]
	    j:-1
				Wend
				a[j] = v
			Next
		End Function
	End Function
	Rem
		bbdoc: Used to sort the list by the Data field descending.
	End Rem
	Function FastQuickSortDataDesc(array:ifsoGUI_ListItem[])
		QuickSort(array, 0, array.Length - 1)
		InsertionSort(array, 0, array.Length - 1)
	
		Function QuickSort(a:ifsoGUI_ListItem[], l:Int, r:Int)
			If (r - l) > 4
				Local tmp:ifsoGUI_ListItem
				Local i:Int, j:Int, v:Int
				i = (r + l) / 2
				If (a[l].Data < a[i].Data) 'swap(a, l, i)
					tmp = a[l]
					a[l] = a[i]
					a[i] = tmp
				End If
				If (a[l].Data < a[r].Data) 'swap(a, l, r)
					tmp = a[l]
					a[l] = a[r]
					a[r] = tmp
				End If
				If (a[i].Data < a[r].Data) 'swap(a, i, r)
					tmp = a[i]
					a[i] = a[r]
					a[r] = tmp
				End If
				j = r - 1
				'swap(a, i, j)
				tmp = a[i]
				a[i] = a[j]
				a[j] = tmp
				i = l
				v = a[j].Data
				Repeat
					i:+1
					While a[i].Data > v ; i:+1; Wend
					j:-1
					While a[j].Data < v ; j:-1;Wend
					If (j < i) Exit
					'swap (a, i, j)
					tmp = a[i]
					a[i] = a[j]
					a[j] = tmp
				Forever
				'swap(a, i, r - 1)
				tmp = a[i]
				a[i] = a[r - 1]
				a[r - 1] = tmp
				QuickSort(a, l, j)
				QuickSort(a, i + 1, r)
			End If
		End Function
	
		Function InsertionSort(a:ifsoGUI_ListItem[], lo0:Int, hi0:Int)
			Local i:Int, j:Int, v:ifsoGUI_ListItem
			For i = lo0 + 1 To hi0
				v = a[i]
				j = i
				While (j > lo0) And (a[j - 1].Data < v.Data)
					a[j] = a[j - 1]
	    j:-1
				Wend
				a[j] = v
			Next
		End Function
	End Function
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("listbox").Split(",")
		Load9Image2("/graphics/listbox.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
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
	bbdoc: Returns the number of items visible at a time in the listbox.
	End Rem
	Method GetVisibleItems:Int()
		Return VisibleItems
	End Method
	Rem
	bbdoc: Adds an item to the end of the listbox.
	End Rem
	Method AddItem(strName:String, intData:Int = 0, strTip:String = "")
	 Local itm:ifsoGUI_ListItem = New ifsoGUI_ListItem
		itm.Name = strName
		itm.Data = intData
		itm.Tip = strTip
		Items = Items[..Items.Length + 1]
		Items[Items.Length - 1] = itm
		Refresh()
	End Method
	Rem
	bbdoc: Inserts an item into the listbox at a particular position.
	End Rem
	Method InsertItem(intIndex:Int, strName:String, intData:Int, strTip:String)
		Local itm:ifsoGUI_ListItem = New ifsoGUI_ListItem
		itm.Name = strName
		itm.Data = intData
		itm.Tip = strTip
		Items = Items[..Items.Length + 1]
		For Local i:Int = Items.Length - 2 To intIndex Step - 1
			Items[i + 1] = Items[i]
		Next
		Items[intIndex] = itm
		If LastSelected >= intIndex LastSelected:+1
		If Highlighted >= intIndex Highlighted:+1
		Refresh()
	End Method
	Rem
	bbdoc: Removes an item from the listbox.
	End Rem
	Method RemoveItem(intIndex:Int)
		If Items.Length = 0 Return
		If intIndex - 1 > Items.Length Return
		For Local i:Int = intIndex To Items.Length - 2
			Items[i] = Items[i + 1]
		Next
		Items = Items[..Items.Length - 1]
		If LastSelected = intIndex LastSelected = -1
		If LastSelected > intIndex LastSelected:-1
		If Highlighted > intIndex Highlighted:-1
		If Highlighted > Items.Length - 1 Highlighted = Items.Length - 1
		If Topitem > 0 And TopItem + VisibleItems - 1 > Items.Length - 1 TopItem:-1
		Refresh()
	End Method
	Rem
	bbdoc: Removes all items from the listbox.
	End Rem
	Method RemoveAll()
		Items = Null
		Highlighted = -1
		LastSelected = -1
		TopItem = 0
		Refresh()
	End Method
	Rem
	bbdoc: Sets whether or not multiple items can be selected.
	End Rem
	Method SetMultiSelect(bMultiSelect:Int)
		MultiSelect = bMultiSelect
		If Not MultiSelect
			For Local i:Int = 0 To Items.Length - 1
				If i <> LastSelected Items[i].Selected = False
			Next
		End If
	End Method
	Rem
	bbdoc: Returns whether or not multiple items can be selected..
	End Rem
	Method GetMultiSelect:Int()
		Return MultiSelect
	End Method
	Rem
	bbdoc: Returns the name of the item.
	End Rem
	Method GetItemName:String(intIndex:Int)
		Return Items[intIndex].Name
	End Method
	Rem
	bbdoc: Returns the data of the item.
	End Rem
	Method GetItemData:Int(intIndex:Int)
		Return Items[intIndex].Data
	End Method
	Rem
	bbdoc: Returns the tip of the item.
	End Rem
	Method GetItemTip:String(intIndex:Int)
		Return Items[intIndex].Tip
	End Method
	Rem
	bbdoc: Returns whether the item is selected or not.
	End Rem
	Method GetItemSelected:Int(intIndex:Int)
		Return Items[intIndex].Selected
	End Method
	Rem
	bbdoc: Sets the name of the item.
	End Rem
	Method SetItemName(intIndex:Int, strName:String)
		If Items.Length = 0 Return
		If intIndex - 1 > Items.Length Return
		Items[intIndex].Name = strName
		Refresh()
	End Method
	Rem
	bbdoc: Sets the data of the item.
	End Rem
	Method SetItemData(intIndex:Int, intData:Int)
		If Items.Length = 0 Return
		If intIndex - 1 > Items.Length Return
		Items[intIndex].Data = intData
	End Method
	Rem
	bbdoc: Sets the tip of the item.
	End Rem
	Method SetItemTip(intIndex:Int, strTip:String)
		If Items.Length = 0 Return
		If intIndex - 1 > Items.Length Return
		Items[intIndex].Tip = strTip
	End Method
	Rem
	bbdoc: Sets the item selected/unselected.
	End Rem
	Method SetSelected(intIndex:Int, bSelected:Int)
		If Items.Length = 0 Return
		If intIndex - 1 > Items.Length Return
		If (Not MultiSelect) And bSelected
			For Local i:Int = 0 To Items.Length - 1
				Items[i].Selected = False
			Next
		End If
		Items[intIndex].Selected = bSelected
		LastSelected = intIndex
	End Method
	Rem
	bbdoc: Gets the selected item index.
	End Rem
	Method GetSelected:Int()
		Return LastSelected
	End Method
	Rem
	bbdoc: Gets the selected item.
	End Rem
	Method GetSelectedItem:ifsoGUI_ListItem()
		If LastSelected = -1 Return Null
		Return Items[LastSelected]
	End Method
	Rem
	bbdoc: Gets the item by index.
	End Rem
	Method GetItem:ifsoGUI_ListItem(intIndex:Int)
		Return Items[intIndex]
	End Method
	Rem
	bbdoc: Returns the number of items in the list.
	End Rem
	Method GetCount:Int()
		Return Items.Length
	End Method
	
	Rem
	bbdoc: Sets the width of the scrollbars.
	End Rem
	Method SetScrollBarWidth(iWidth:Int)
		ScrollBarWidth = iWidth
		Refresh()
	End Method
	Rem
	bbdoc: Returns the width of the scrollbars.
	End Rem
	Method GetScrollBarWidth:Int()
		Return ScrollBarWidth
	End Method
	Rem
	bbdoc: Sets the highlight color.
	End Rem
	Method SetHighlightColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of highlighted item
		HighlightColor[0] = iRed
		HighlightColor[1] = iGreen
		HighlightColor[2] = iBlue
	End Method
	Rem
	bbdoc: Sets the selection color.
	End Rem
	Method SetSelectColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of selected item
		SelectColor[0] = iRed
		SelectColor[1] = iGreen
		SelectColor[2] = iBlue
	End Method
	Rem
	bbdoc: Sets the highlight text color.
	End Rem
	Method SetHighlightTextColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of highlighted item text
		HighlightTextColor[0] = iRed
		HighlightTextColor[1] = iGreen
		HighlightTextColor[2] = iBlue
	End Method
	Rem
	bbdoc: Sets the select text color.
	End Rem
	Method SetSelectTextColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of selected item text
		SelectTextColor[0] = iRed
		SelectTextColor[1] = iGreen
		SelectTextColor[2] = iBlue
	End Method
	Rem
	bbdoc: Sets whether or not the border will show.
	End Rem
	Method SetShowBorder(bShowBorder:Int)
		ShowBorder = bShowBorder
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the border is showing.
	End Rem
	Method GetShowBorder:Int()
		Return ShowBorder
	End Method
	Rem
	bbdoc: Sets whether or not the Vertical Scrollbar will show.
	about: ifsoGUI_SCROLLBAR_ON, ifsoGUI_SCROLLBAR_OFF, ifsoGUI_SCROLLBAR_AUTO
	End Rem
	Method SetVScrollbar(iVScrollbar:Int)
		VScrollBar = iVScrollBar
		Refresh()
	End Method
	Rem
	bbdoc: Gets whether or not the Vertical Scrollbar will show.
	End Rem
	Method GetVScrollbar:Int()
		Return VScrollBar
	End Method
	Rem
	bbdoc: Sets whether or not the Horizontal Scrollbar will show.
	about: ifsoGUI_SCROLLBAR_ON, ifsoGUI_SCROLLBAR_OFF, ifsoGUI_SCROLLBAR_AUTO
	End Rem
	Method SetHScrollbar(iHScrollbar:Int)
		HScrollBar = iHScrollBar
		Refresh()
	End Method
	Rem
	bbdoc: Gets whether or not the Horizontal Scrollbar will show.
	End Rem
	Method GetHScrollbar:Int()
		Return HScrollBar
	End Method
	Rem
	bbdoc: Sets the top index of the listbox.
	End Rem
	Method SetTopItem(intTopItem:Int)
		TopItem = intTopItem
		If TopItem + VisibleItems > Items.Length - 1 TopItem = Items.Length - VisibleItems
		If TopItem < 0 TopItem = 0
		VBar.SetValue(TopItem)
	End Method
	Rem
	bbdoc: Returns the top index of the listbox.
	End Rem
	Method GetTopItem:Int()
		Return TopItem
	End Method
	Rem
	bbdoc: Sets whether or not the highlight follows the mouse.
	End Rem
	Method SetMouseHighlight(intMouseHighlight:Int)
		MouseHighlight = intMouseHighlight
	End Method
	Rem
	bbdoc: Returns whether or not the highlight follows the mouse.
	End Rem
	Method GetMouseHighlight:Int()
		Return MouseHighlight
	End Method
	Rem
	bbdoc: Sorts the list.  Will be sorted by the Name field by default, set bData=true to sort by the data field.
	End Rem
	Method SortList(bDesc:Int = False, bSortAsInt:Int = False, bData:Int = False)
		If bData
			If bDesc
				FastQuickSortDataDesc(Items)
			Else
				FastQuickSortData(Items)
			End If
		ElseIf bSortAsInt
			If bDesc
				FastQuickSortIntDesc(Items)
			Else
				FastQuickSortInt(Items)
			End If
		Else
			If bDesc
				FastQuickSortDesc(Items)
			Else
				FastQuickSort(Items)
			End If
		End If
	End Method
End Type

Rem
	bbdoc: Listbox Item Type
End Rem
Type ifsoGUI_ListItem
	Field Name:String
	Field Data:Int
	Field Tip:String
	Field Selected:Int
End Type
