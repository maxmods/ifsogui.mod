SuperStrict

Rem
	bbdoc: ifsoGUI Properties
	about: Properties Gadget
EndRem
Module ifsogui.properties

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.scrollbar
Import ifsogui.combobox
Import ifsogui.textbox
Import ifsogui.checkbox
Import ifsogui.label
Import ifsogui.spinbox

GUI.Register(ifsoGUI_Properties.SystemEvent)

Rem
	bbdoc: Properties Type
End Rem
Type ifsoGUI_Properties Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	'For Scrollbars
	Field Scrollbars:Int = 2 'Show scrollbars when control is off screen, 1-Always 2-When needed 0-Never
	Field VBar:ifsoGUI_ScrollBar
	Field VBarOn:Int = False
	Field ScrollBarWidth:Int = 20 'Width of the scrollbars

	Field Props:ifsoGUI_Property[]
	Field TopItem:Int 'Item at the visible top of the list
	Field VisibleItems:Int 'Number of items visible in the list
	Field Widest:Int 'Widest item in the list
	Field ItemHeight:Int = 1 'Height of one item
	Field ShowBorder:Int = True
	Field NameColWidth:Int 'Width of the first column
	Field SelectColor:Int[] = [40, 40, 255] 'Color of the gadget
	Field SelectTextColor:Int[] = [0, 0, 0] 'Color of the gadget
	Field CanResize:Int = True 'Can the column separator be resized
	Field Resizing:Int = False 'Is the user resizing it now
	Field ResizeWidth:Int = 2 'How many pixels from either side of the separator is the resize spot
	Field ResizeSpot:Int 'Is the mpouse over the resize spot
	Field MinWidth:Int = 0 'min max width of the divider
	Field MaxWidth:Int
	Field bShowGadgets:Int = True 'Should the gadgets show a;; the time, or only when selected
	
	'Events
	'Mouse Enter/Mouse Exit/Change
	
	Rem
		bbdoc: Create and returns a properties gadget.
	End Rem
	Function Create:ifsoGUI_Properties(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_Properties = New ifsoGUI_Properties
		p.TabOrder = -2
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.Name = strName
		p.Enabled = True
		p.VBar = ifsoGUI_ScrollBar.Create(iW - p.ScrollBarWidth, 0, p.ScrollBarWidth, iH, strName + "_vbar", True)
		p.VBar.SetVisible(False)
		p.VBar.Master = p
		p.Slaves.AddLast(p.VBar)
		p.SetShowBorder(True)
		p.SetWH(iW, iH)
		p.MaxWidth = p.w - (p.BorderLeft + p.BorderRight) - 50
		p.NameColWidth = (p.w - (p.BorderLeft + p.BorderRight)) / 2
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
		Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
		th = (ItemHeight - th) / 2
		'Draw the frame and back
		DrawBox2(lImage, rX, rY, w, h, ShowBorder, lTileSides, lTileCenter)
		Local width:Int = w - (BorderLeft + BorderRight)
		Local height:Int = h - (BorderTop + BorderBottom)
		If VBarOn width:-ScrollBarWidth
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		If fFont SetImageFont(fFont)
		ifsoGUI_VP.Add(rX + BorderLeft, rY + BorderTop, width, height)
		'Draw the grid
		Local drawheight:Int = rY + BorderTop
		If TopItem + VisibleItems < Props.Length
			drawheight:+((h - BorderBottom) * ItemHeight)
		Else
			drawheight:+((Props.Length - TopItem) * ItemHeight)
		End If
		ifsoGUI_VP.DrawLine(rX + BorderLeft + NameColWidth, rY + BorderTop, rX + BorderLeft + NameColWidth, drawheight)
		Local iNextX:Int = rX + BorderLeft
		Local iNextY:Int = rY + BorderTop + ItemHeight
		For Local i:Int = TopItem To Props.Length - 1
			ifsoGUI_VP.DrawLine(iNextX, iNextY, iNextX + width, iNextY)
			iNextY:+ItemHeight
		Next
		'Draw the Name Column
		iNextY = rY + BorderTop + th 'Y pos of the next line
		iNextX = rX + BorderLeft + 1
		ifsoGUI_VP.Add(rX + BorderLeft, rY + BorderTop, NameColWidth, height)
		For Local i:Int = TopItem To Props.Length - 1
			ifsoGUI_VP.DrawTextArea(Props[i].Name, iNextX, iNextY, Self)
			iNextY:+ItemHeight
		Next
		ifsoGUI_VP.Pop()
		'Draw the Value Column
		If Not bShowGadgets
			iNextY = rY + BorderTop + th 'Y pos of the next line
			iNextX:Int = rX + BorderLeft + NameColWidth + 2
			ifsoGUI_VP.Add(rX + BorderLeft + NameColWidth, rY + BorderTop, width - NameColWidth, height)
			For Local i:Int = TopItem To Props.Length - 1
				If Not Props[i].Gadget.Visible ifsoGUI_VP.DrawTextArea(Props[i].GetValueText(), iNextX, iNextY, Self)
				iNextY:+ItemHeight
			Next
			ifsoGUI_VP.Pop()
		End If
		If fFont SetImageFont(GUI.DefaultFont)
		For Local g:ifsoGUI_Base = EachIn Slaves
			g.Draw(rX + BorderLeft, rY + BorderTop - (TopItem * ItemHeight), width, height + (TopItem * ItemHeight))
		Next
		ifsoGUI_VP.Pop()
		VBar.Draw(rX + BorderLeft, rY + BorderTop, width, height)
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not (Visible And Enabled) Return False
		Local locX:Int = parX + x + BorderLeft, locY:Int = parY + y + BorderTop
		Local locW:Int = w - (BorderLeft + BorderRight), locH:Int = h - (BorderTop + BorderBottom)
		If Resizing
			GUI.gMouseOverGadget = Self
			Return True
		Else
			If (iMouseX > locX) And (iMouseX < locX + locW) And (iMouseY > locY) And (iMouseY < locY + locH)
				If VBar.IsMouseOver(locX, locY, locW, locH, iMouseX, iMouseY) Return True
				For Local g:ifsoGUI_Base = EachIn Slaves
					If g <> VBar
						If g.IsMouseOver(locX, locY, locW, locH, iMouseX, iMouseY + (TopItem * ItemHeight)) Return True
					End If
				Next
				GUI.gMouseOverGadget = Self
				ResizeSpot = False
				If CanResize And iMouseX >= parX + x + NameColWidth + BorderLeft - ResizeWidth And iMouseX < parX + x + NameColWidth + BorderLeft + ResizeWidth ResizeSpot = True
				GUI.gMouseOverGadget = Self
				Return True
			End If
		End If
		Return False
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		VBar.LoadSkin(strSkin)
		For Local i:Int = 0 To Props.Length - 1
			Props[i].Gadget.LoadSkin(strSkin)
		Next
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("properties", strSkin).Split(",")
		Load9Image2("/graphics/properties.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		Refresh()
	End Method
		Rem
	bbdoc: Called when the gadget is no longer the Active Gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method LostFocus(GainedFocus:ifsoGUI_Base) 'Gadget Lost focus
		bPressed = False
		Resizing = False
		If GainedFocus <> Self And Not IsMySlave(GainedFocus)
			DeSelect()
		 SendEvent(ifsoGUI_EVENT_LOST_FOCUS, 0, 0, 0)
			HasFocus = False
		End If
	End Method
Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not (Visible And Enabled) Return
		GUI.SetActiveGadget(Self)
		bPressed = iButton
		If bPressed <> ifsoGUI_LEFT_MOUSE_BUTTON Return
		If ResizeSpot And CanResize
			Resizing = True
		Else
			Local iX:Int, iY:Int
			GetAbsoluteXY(iX, iY)
			Local OverItem:Int = ((iMouseY - (iY + BorderTop)) / ItemHeight) 'Item mouse is over
			If OverItem >= 0 OverItem:+TopItem
			If OverItem >= Props.Length Or OverItem < 0 OverItem = -1
			If OverItem = TopItem + VisibleItems
			 Vbar.SetValue(VBar.Value + 1)
			End If
			'Activate Property
			If OverItem > - 1
				ActivateProp(OverItem)
			Else
				DeSelect()
			End If
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		bPressed = False
		Resizing = False
	End Method
	Rem
	bbdoc: Called when the gadget needs to be deactivated.
	about: Internal function should not be called by the user.
	End Rem
	Method DeSelect()
		If Not bShowGadgets
			For Local g:ifsoGUI_Base = EachIn Slaves
				If g <> VBar And g.Visible g.SetVisible(False)
			Next
		End If
	End Method
	Rem
	bbdoc: Called when the gadget becomes the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method GainFocus(LostFocus:ifsoGUI_Base)
		HasFocus = True
		If Not IsMySlave(LostFocus) SendEvent(ifsoGUI_EVENT_GAIN_FOCUS, 0, 0, 0)
	End Method
	Rem
	bbdoc: Called when the mouse is over this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base)
		If Resizing
			Local iX:Int, iY:Int
			GetAbsoluteXY(iX, iY)
			If iX + BorderLeft + NameColWidth <> iMouseX
				Local wasWidth:Int = NameColWidth
				SetDivider(iMouseX - (iX + BorderLeft))
				If wasWidth <> NameColWidth SendEvent(ifsoGUI_EVENT_RESIZE, NameColWidth, iMouseX, iMouseY)
			End If
		End If
		If gWasOverGadget <> Self And Not (IsMySlave(gWasOverGadget)) SendEvent(ifsoGUI_EVENT_MOUSE_ENTER, 0, iMouseX, iMouseY)
	End Method
	Rem
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget only.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If ResizeSpot
			GUI.iMouseDir = ifsoGUI_RESIZE_RIGHT
			Return ifsoGUI_MOUSE_RESIZE
		End If
		Return ifsoGUI_MOUSE_NORMAL
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
		If NameColWidth < MinWidth NameColWidth = MinWidth
		If VBarOn
			If NameColWidth > MaxWidth - ScrollBarWidth NameColWidth = MaxWidth - ScrollBarWidth
		Else
			If NameColWidth > MaxWidth NameColWidth = MaxWidth
		End If
		VisibleItems = (h - (BorderTop + BorderBottom)) / ItemHeight
		VBar.SetBounds(w - (ScrollBarWidth + BorderLeft + BorderRight), 0, ScrollBarWidth, h - (BorderTop + BorderBottom))
		VBarOn = False
		If Scrollbars = 1
			VBarOn = True
		Else
			If Scrollbars = 2
				If Props.Length > VisibleItems VBarOn = True
			End If
		End If
		Local imax:Int = Props.Length
		If imax < 1 imax = 1
		Local iInt:Int = VisibleItems
		If iInt > imax iInt = imax
		VBar.SetBarInterval(iInt)
		VBar.SetMax(imax)
		VBar.SetVisible(VBarOn)
		Local width:Int = w - (BorderLeft + BorderRight + NameColWidth)
		If VBarOn width:-ScrollBarWidth
		For Local i:Int = 0 To Props.Length - 1
			Props[i].SetBounds(NameColWidth, (i * ItemHeight) + ((ItemHeight - Props[i].ActiveHeight) / 2), width, ItemHeight)
		Next
	End Method
	Rem
	bbdoc: Called from a slave gadget.
	about: Slave gadgets do not generate GUI events.  They send events to their Master.
	The Master then uses it or can send a GUI event.
	Internal function should not be called by the user.
	End Rem
	Method SlaveEvent(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		If gadget = VBar
			Select id
				Case ifsoGUI_EVENT_MOUSE_ENTER
					MouseOver(iMouseX, iMouseY, GUI.gWasMouseOverGadget)
				Case ifsoGUI_EVENT_MOUSE_EXIT
					MouseOut(iMouseX, iMouseY, GUI.gMouseOverGadget)
				Case ifsoGUI_EVENT_GAIN_FOCUS
					DeSelect()
					If Not HasFocus GainFocus(Null)
				Case ifsoGUI_EVENT_LOST_FOCUS
					LostFocus(GUI.gActiveGadget)
				Case ifsoGUI_EVENT_CHANGE
					TopItem = data
			End Select
		ElseIf id = ifsoGUI_EVENT_LOST_FOCUS
			DeSelect()
			LostFocus(GUI.gActiveGadget)
		ElseIf id = ifsoGUI_EVENT_CHANGE
			For Local i:Int = 0 To Props.Length - 1
				If gadget = Props[i].gadget
					Props[i].Changed()
					SendEvent(ifsoGUI_EVENT_CHANGE, i, iMouseX, iMouseY)
					Exit
				End If
			Next
		ElseIf id = ifsoGUI_EVENT_MOUSE_EXIT
			MouseOut(iMouseX, iMouseY, GUI.gMouseOverGadget)
		ElseIf id = ifsoGUI_EVENT_MOUSE_ENTER
			MouseOver(iMouseX, iMouseY, GUI.gWasMouseOverGadget)
		End If
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("properties").Split(",")
		Load9Image2("/graphics/properties.png", dimensions, gImage)
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
	bbdoc: Returns the number of items visible at a time in the properties gadget.
	End Rem
	Method GetVisibleItems:Int()
		Return VisibleItems
	End Method
	Rem
	bbdoc: Adds an item to the end of the properties.
	End Rem
	Method AddProp(Prop:ifsoGUI_Property)
		InsertProp(Props.Length, Prop)
	End Method
	Rem
	bbdoc: Inserts an item into the properties at a particular position.
	End Rem
	Method InsertProp(intIndex:Int, Prop:ifsoGUI_Property)
		If intIndex > Props.Length intIndex = Props.Length
		Props = Props[..Props.Length + 1]
		For Local i:Int = Props.Length - 2 To intIndex Step - 1
			Props[i + 1] = Props[i]
		Next
		Props[intIndex] = Prop
		Prop.Gadget.Master = Self
		Slaves.AddLast(Prop.Gadget)
		If Prop.ActiveHeight > ItemHeight ItemHeight = Prop.ActiveHeight
		Prop.Gadget.SetVisible(bShowGadgets)
		Refresh()
	End Method
	Rem
	bbdoc: Removes an item from the properties.
	End Rem
	Method RemoveProp(intIndex:Int)
		If Props.Length = 0 Return
		If intIndex - 1 > Props.Length Return
		Slaves.Remove(Props[intIndex].Gadget)
		For Local i:Int = intIndex To Props.Length - 2
			Props[i] = Props[i + 1]
		Next
		Props = Props[..Props.Length - 1]
		If Topitem > 0 And TopItem + VisibleItems - 1 > Props.Length - 1 TopItem:-1
		ItemHeight = Props[0].ActiveHeight
		For Local i:Int = 1 To Props.Length - 1
			If Props[i].ActiveHeight > ItemHeight ItemHeight = Props[i].ActiveHeight
		Next
		Refresh()
	End Method
	Rem
	bbdoc: Removes all items from the properties.
	End Rem
	Method RemoveAll()
		Props = Null
		TopItem = 0
		VBar.SetValue(0)
		Slaves.Clear()
		Slaves.AddLast(VBar)
		Refresh()
	End Method
	Rem
	bbdoc: Returns the name of the item.
	End Rem
	Method GetPropName:String(intIndex:Int)
		Return Props[intIndex].Name
	End Method
	Rem
	bbdoc: Returns the value of the item.
	End Rem
	Method GetPropValue:String(intIndex:Int)
		Return Props[intIndex].GetValue()
	End Method
	Rem
	bbdoc: Returns the text value of the item.
	End Rem
	Method GetPropValueText:String(intIndex:Int)
		Return Props[intIndex].GetValueText()
	End Method
	Rem
	bbdoc: Sets the name of the item.
	End Rem
	Method SetPropName(intIndex:Int, strName:String)
		If Props.Length = 0 Return
		If intIndex - 1 > Props.Length Return
		Props[intIndex].Name = strName
	End Method
	Rem
	bbdoc: Sets the value of the item.
	End Rem
	Method SetPropValue(intIndex:Int, strValue:String)
		If Props.Length = 0 Return
		If intIndex - 1 > Props.Length Return
		Props[intIndex].SetValue(strValue)
	End Method
	Rem
	bbdoc: Activates the Property.
	End Rem
	Method ActivateProp(intIndex:Int)
		If Props.Length = 0 Return
		If intIndex - 1 > Props.Length Return
		If Not bShowGadgets
			DeSelect()
			Props[intIndex].Gadget.SetVisible(True)
		End If
		Props[intIndex].Gadget.SetFocus()
	End Method
	Rem
	bbdoc: Retrieves the gadgets Absolute x and y position.
	about: This returns true x and y values from the top left corner of the screen.
	End Rem
	Method GetAbsoluteXY(iX:Int Var, iY:Int Var, caller:ifsoGUI_Base = Null)
		If Parent
			Parent.GetAbsoluteXY(iX, iY, Self)
		ElseIf Master
			Master.GetAbsoluteXY(iX, iY, Self)
		End If
		If IsMySlave(caller) And caller <> VBar
			iY:-(ItemHeight * TopItem)
		End If
		iX:+x
		iY:+y
		If caller <> Self
			iX:+BorderLeft
			iY:+BorderTop
		End If
	End Method
	Rem
	bbdoc: Gets the X location of the divider.
	End Rem
	Method GetDivider:Int()
		Return NameColWidth
	End Method
	Rem
	bbdoc: Sets the X location of the divider.
	End Rem
	Method SetDivider(iLoc:Int)
		If iLoc = NameColWidth Return
		NameColWidth = iLoc
		Refresh()
	End Method
	Rem
	bbdoc: Gets the Minimum divider width.
	End Rem
	Method GetDividerMinWidth:Int()
		Return MinWidth
	End Method
	Rem
	bbdoc: Sets the Minimum divider width.
	End Rem
	Method SetDividerMinWidth(iMinWidth:Int)
		If iMinWidth < 0 Return
		If iMinWidth > w Return
		MinWidth = iMinWidth
		Refresh()
	End Method
	Rem
	bbdoc: Gets the Maximum divider width.
	End Rem
	Method GetDividerMaxWidth:Int()
		Return MaxWidth
	End Method
	Rem
	bbdoc: Sets the Maximum divider width.
	End Rem
	Method SetDividerMaxWidth(iMaxWidth:Int)
		If iMaxWidth < 0 Return
		If iMaxWidth > w Return
		MaxWidth = iMaxWidth
		Refresh()
	End Method
	Rem
	bbdoc: Gets the item by index.
	End Rem
	Method GetProp:ifsoGUI_Property(intIndex:Int)
		Return Props[intIndex]
	End Method
	Rem
	bbdoc: Returns the number of items in the list.
	End Rem
	Method GetPropCount:Int()
		Return Props.Length
	End Method
	
	Rem
	bbdoc: Sets the width of the scrollbars.
	End Rem
	Method SetScrollBarWidth(iWidth:Int)
		ScrollBarWidth = iWidth
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the gadget can be resized.
	End Rem
	Method GetResizable:Int()
		Return CanResize
	End Method
	Rem
	bbdoc: Sets whether the gadget can be resized using the mouse.
	End Rem
	Method SetResizable(bResize:Int)
		CanResize = bResize
		If Not bResize Resizing = 0
	End Method
	Rem
	bbdoc: Returns the width of the scrollbars.
	End Rem
	Method GetScrollBarWidth:Int()
		Return ScrollBarWidth
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
		ScrollBars = iVScrollBar
		Refresh()
	End Method
	Rem
	bbdoc: Gets whether or not the Vertical Scrollbar will show.
	End Rem
	Method GetVScrollbar:Int()
		Return ScrollBars
	End Method
	Rem
	bbdoc: Sets the top index of the properties.
	End Rem
	Method SetTopProperty(intTopIndex:Int)
		TopItem = intTopIndex
		If TopItem + VisibleItems > Props.Length - 1 TopItem = Props.Length - VisibleItems
		If TopItem < 0 TopItem = 0
		VBar.SetValue(TopItem)
	End Method
	Rem
	bbdoc: Returns whether or not the gadgets should always show.
	End Rem
	Method GetShowGadgets:Int()
		Return bShowGadgets
	End Method
	Rem
	bbdoc: Sets whether or not the gadgets should always show.
	End Rem
	Method SetShowGadgets(iShowGadgets:Int)
		bShowGadgets = iShowGadgets
		For Local g:ifsoGUI_Base = EachIn Slaves
			If g <> VBar g.SetVisible(iShowGadgets)
		Next
		Refresh()
	End Method
	Rem
	bbdoc: Returns the top index of the properties.
	End Rem
	Method GetTopIndex:Int()
		Return TopItem
	End Method
End Type

Rem
	bbdoc: Base Property Type
End Rem
Type ifsoGUI_Property Abstract
	Field Gadget:ifsoGUI_Base 'The gadget
	Field Name:String 'Name of the item
	Field Value:String 'Current Value
	Field ValueText:String ' Current Value Text String
	Field ActiveHeight:Int
	
'Function Create() 'Create the gadget
	Method GetValue:String()
		Return Value
	End Method
	Method GetValueText:String()
		Return ValueText
	End Method
	Method SetValue(strValue:String) Abstract
	Method Changed() Abstract
	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int) Abstract

	Method SetFont(fFont:TImageFont)
	End Method
End Type

Rem
	bbdoc: True/False Property Type
End Rem
Type ifsoGUI_Prop_True_False Extends ifsoGUI_Property
	Function Create:ifsoGUI_Prop_True_False(strName:String, strValue:String) 'Create the gadget
		Local p:ifsoGUI_Prop_True_False = New ifsoGUI_Prop_True_False
		p.Gadget = ifsoGUI_Combobox.Create(0, 0, 0, 0, "cbPropTrueFalse")
		ifsoGUI_Combobox(p.Gadget).AddItem("False")
		ifsoGUI_Combobox(p.Gadget).AddItem("True")
		p.Gadget.SetAutoSize(True)
		p.ActiveHeight = p.Gadget.h
		p.Name = strName
		p.SetValue(strValue)
		Return p
	End Function
	
	Method SetValue(strValue:String)
		ifsoGUI_Combobox(Gadget).SetSelected(Int(strValue))
		Changed()
	End Method
	
	Method Changed()
		Value = String(ifsoGUI_Combobox(Gadget).GetSelected())
		ValueText = ifsoGUI_Combobox(Gadget).GetSelectedName()
	End Method

	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		Gadget.SetBounds(iX, iY, iW, iH)
		ActiveHeight = Gadget.h
	End Method
End Type

Rem
	bbdoc: Yes/No Property Type
End Rem
Type ifsoGUI_Prop_Yes_No Extends ifsoGUI_Property
	Function Create:ifsoGUI_Prop_Yes_No(strName:String, strValue:String) 'Create the gadget
		Local p:ifsoGUI_Prop_Yes_No = New ifsoGUI_Prop_Yes_No
		p.Gadget = ifsoGUI_Combobox.Create(0, 0, 0, 0, "cbPropTrueFalse")
		ifsoGUI_Combobox(p.Gadget).AddItem("No")
		ifsoGUI_Combobox(p.Gadget).AddItem("Yes")
		p.Gadget.SetAutoSize(True)
		p.ActiveHeight = p.Gadget.h
		p.Name = strName
		p.SetValue(strValue)
		Return p
	End Function

	Method SetValue(strValue:String)
		ifsoGUI_Combobox(Gadget).SetSelected(Int(strValue))
		Changed()
	End Method

	Method Changed()
		Value = String(ifsoGUI_Combobox(Gadget).GetSelected())
		ValueText = ifsoGUI_Combobox(Gadget).GetSelectedName()
	End Method

	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		Gadget.SetBounds(iX, iY, iW, iH)
		ActiveHeight = Gadget.h
	End Method
End Type

Rem
	bbdoc: Text Property Type
End Rem
Type ifsoGUI_Prop_Text Extends ifsoGUI_Property
	Function Create:ifsoGUI_Prop_Text(strName:String, strValue:String) 'Create the gadget
		Local p:ifsoGUI_Prop_Text = New ifsoGUI_Prop_Text
		p.Gadget = ifsoGUI_TextBox.Create(0, 0, 0, 0, "tbPropText")
		p.Gadget.SetAutoSize(True)
		p.ActiveHeight = p.Gadget.h
		p.Name = strName
		p.SetValue(strValue)
		Return p
	End Function
	
	Method SetValue(strValue:String)
		ifsoGUI_TextBox(Gadget).SetText(strValue)
		Changed()
	End Method

	Method Changed()
		Value = ifsoGUI_TextBox(Gadget).GetText()
		ValueText = Value
	End Method
	
	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		Gadget.SetBounds(iX, iY, iW, iH)
		ActiveHeight = Gadget.h
	End Method
End Type

Rem
	bbdoc: Enabled/Disabled Property Type
End Rem
Type ifsoGUI_Prop_Enable_Disable Extends ifsoGUI_Property
	Function Create:ifsoGUI_Prop_Enable_Disable(strName:String, strValue:String) 'Create the gadget
		Local p:ifsoGUI_Prop_Enable_Disable = New ifsoGUI_Prop_Enable_Disable
		p.Gadget = ifsoGUI_CheckBox.Create(0, 0, 0, 0, "tbPropEnable", "Enabled")
		p.Gadget.SetAutoSize(True)
		p.ActiveHeight = p.Gadget.h
		p.Name = strName
		p.SetValue(strValue)
		Return p
	End Function
	
	Method SetValue(strValue:String)
		ifsoGUI_CheckBox(Gadget).SetValue(Int(strValue))
		Changed()
	End Method

	Method Changed()
		Value = String(ifsoGUI_CheckBox(Gadget).GetValue())
		If Int(Value) = 0
			ValueText = "Disabled"
		Else
			ValueText = "Enabled"
		End If
	End Method

	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		Gadget.SetBounds(iX + 2, iY, iW - 2, iH)
		ActiveHeight = Gadget.h
	End Method
End Type

Rem
	bbdoc: ComboBox Property Type
End Rem
Type ifsoGUI_Prop_ComboBox Extends ifsoGUI_Property
	Function Create:ifsoGUI_Prop_ComboBox(strName:String) 'Create the gadget
		Local p:ifsoGUI_Prop_ComboBox = New ifsoGUI_Prop_ComboBox
		p.Gadget = ifsoGUI_Combobox.Create(0, 0, 0, 0, "cbPropCombo")
		p.Gadget.SetAutoSize(True)
		p.ActiveHeight = p.Gadget.h
		p.Name = strName
		Return p
	End Function
	
	Method AddItem(strValue:String)
		ifsoGUI_Combobox(Gadget).AddItem(strValue)
	End Method
	
	Method SetValue(strValue:String)
		ifsoGUI_Combobox(Gadget).SetSelected(Int(strValue))
		Changed()
	End Method
	
	Method Changed()
		Value = String(ifsoGUI_Combobox(Gadget).GetSelected())
		ValueText = ifsoGUI_Combobox(Gadget).GetSelectedName()
	End Method

	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		Gadget.SetBounds(iX, iY, iW, iH)
		ActiveHeight = Gadget.h
	End Method
End Type

Rem
	bbdoc: Checkbox Property Type
End Rem
Type ifsoGUI_Prop_Checkbox Extends ifsoGUI_Property
	Field UnChecked:String
	
	Function Create:ifsoGUI_Prop_CheckBox(strName:String, strValue:String, strChecked:String, strUnchecked:String) 'Create the gadget
		Local p:ifsoGUI_Prop_Checkbox = New ifsoGUI_Prop_CheckBox
		p.Gadget = ifsoGUI_CheckBox.Create(0, 0, 0, 0, "tbPropCB", strChecked)
		p.Gadget.SetAutoSize(True)
		p.UnChecked = strUnchecked
		p.ActiveHeight = p.Gadget.h
		p.Name = strName
		p.SetValue(strValue)
		Return p
	End Function
	
	Method SetValue(strValue:String)
		ifsoGUI_CheckBox(Gadget).SetValue(Int(strValue))
		Changed()
	End Method

	Method Changed()
		Value = String(ifsoGUI_CheckBox(Gadget).GetValue())
		If Int(Value) = 0
			ValueText = UnChecked
		Else
			ValueText = ifsoGUI_CheckBox(Gadget).Label
		End If
	End Method

	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		Gadget.SetBounds(iX + 2, iY, iW - 2, iH)
		ActiveHeight = Gadget.h
	End Method
End Type

Rem
	bbdoc: Read Only Property Type
End Rem
Type ifsoGUI_Prop_ReadOnly Extends ifsoGUI_Property
	Function Create:ifsoGUI_Prop_ReadOnly(strName:String, strValue:String) 'Create the gadget
		Local p:ifsoGUI_Prop_ReadOnly = New ifsoGUI_Prop_ReadOnly
		p.Gadget = ifsoGUI_Label.Create(0, 0, 0, 0, "tbPropLabel", strValue)
		p.Gadget.SetAutoSize(True)
		p.Gadget.SetTransparent(True)
		ifsoGUI_Label(p.Gadget).SetShowBorder(False)
		p.ActiveHeight = p.Gadget.h
		p.Name = strName
		p.SetValue(strValue)
		Return p
	End Function
	
	Method SetValue(strValue:String)
		ifsoGUI_Label(Gadget).SetLabel(strValue)
		Changed()
	End Method

	Method Changed()
		Value = ifsoGUI_Label(Gadget).GetLabel()
		ValueText = Value
	End Method

	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		Gadget.SetBounds(iX, iY, iW, iH)
		ActiveHeight = Gadget.h
	End Method
End Type

Rem
	bbdoc: Spinbox Property Type
End Rem
Type ifsoGUI_Prop_SpinBox Extends ifsoGUI_Property
	Function Create:ifsoGUI_Prop_SpinBox(strName:String, strValue:String) 'Create the gadget
		Local p:ifsoGUI_Prop_SpinBox = New ifsoGUI_Prop_SpinBox
		p.Gadget = ifsoGUI_SpinBox.Create(0, 0, 0, 0, "tbPropSB")
		p.Gadget.SetAutoSize(True)
		p.ActiveHeight = p.Gadget.h
		p.Name = strName
		p.SetValue(strValue)
		Return p
	End Function
	
	Method SetValue(strValue:String)
		ifsoGUI_SpinBox(Gadget).SetValue(Int(strValue))
		Changed()
	End Method

	Method Changed()
		Value = String(ifsoGUI_SpinBox(Gadget).GetValue())
		ValueText = Value
	End Method

	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		Gadget.SetBounds(iX, iY, iW, iH)
		ActiveHeight = Gadget.h
	End Method
End Type

