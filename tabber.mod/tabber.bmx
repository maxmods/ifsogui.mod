SuperStrict

Rem
	bbdoc: ifsoGUI Tabber
	about: Tabber Gadget
EndRem
Module ifsogui.tabber

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.panel

GUI.Register(ifsoGUI_Tabber.SystemEvent)

Rem
	bbdoc: Tabber Type
End Rem
Type ifsoGUI_Tabber Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageArrow:TImage[2] 'Image for the arrow graphic 0-right 1-left
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field gArrowTabWidth:Int 'Width of the Arrow Tab
	Field lImage:ifsoGUI_Image 'Images to draw the button
	Field lImageOver:ifsoGUI_Image 'Images to draw the button
	Field lImageDown:ifsoGUI_Image 'Images to draw the button
	Field lImageArrow:TImage[2] 'Image for the arrow graphic 0-right 1-left
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	Field Tabs:TabberTab[] 'The Tabs, includes the panel
	Field TabHeight:Int 'Height of the tab buttons
	Field CurrentTab:Int 'Currently selected page
	Field TabAutoHeight:Int = True 'If the height of the tabs is automatic
	Field TabAutoWidth:Int = True 'If the width of the tabs is automatic
	Field MouseOverTab:Int = -1 'Tab the mouse is over
	Field TabOverlap:Int = 0 'How many pixels the tabs overlap by.
	Field FirstTab:Int = 0 'First tab showing on the left
	Field MaxFirstTab:Int = 0 'Highest the first tab value can be
	Field TotalTabWidths:Int 'Width of all the tabs drawn size
	Field MaxTabWidth:Int 'Maximum width of tabs that can be shown
	Field TabArrowHeight:Int 'Height of the tab arrows
	Field EdgeOffset:Int = 4 'Distance from the edge to draw the tabs
	Field ShowBorder:Int = True 'Whether the borders should show on the panels.
	
	'Events
	'Mouse Enter/Mouse Exit/Click
		
	Rem
		bbdoc: Create and returns a tabber gadget.
	End Rem
	Function Create:ifsoGUI_Tabber(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, intNumTabs:Int)
		If intNumTabs < 1 intNumTabs = 1
		Local p:ifsoGUI_Tabber = New ifsoGUI_Tabber
		p.x = iX
		p.y = iY
		p.w = iW
		p.h = iH
		p.lImage = gImage
		p.lImageOver = gImageOver
		p.lImageDown = gImageDown
		p.lImageArrow = gImageArrow
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.gArrowTabWidth = gImage.w[3] + gImage.w[5] + gImageArrow[0].width * 2
		p.Name = strName
		p.Tabs = p.Tabs[..intNumTabs]
		For Local i:Int = 0 To intNumTabs - 1
			p.Tabs[i] = New TabberTab
			p.Tabs[i].Init(iW, iH, strName + "_panel")
			p.Tabs[i].panel.Master = p
			p.Slaves.AddLast(p.Tabs[i].panel)
		Next
		p.TabOverlap = gImage.w[3]
		p.EdgeOffset = 4
		p.Refresh()
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
		SetAlpha(fAlpha)
		SetColor(Color[0], Color[1], Color[2])
		'set up rendering locations
		Local rX:Int = parX + x
		Local rY:Int = parY + y
		'Draw The unselected buttons
		Local widths:Int
		Local curwidth:Int
		'Draw the unselected Tabs
		'Tabs start EdgeOffSet pixels from the edge
		If fFont SetImageFont(fFont)
		Local vpX:Int, vpY:Int, vpW:Int, vpH:Int
 	Local vpoff:Int = 0
		If TotalTabWidths > MaxTabWidth vpoff = gArrowTabWidth / 2
		ifsoGUI_VP.Add(rX, rY, w - (EdgeOffset + vpoff), TabHeight)
		vpH = TabHeight - (BorderTop + BorderBottom + 3)
		vpY = rY + BorderTop + 2
		For Local i:Int = FirstTab To Tabs.Length - 1
			If i <> CurrentTab
				If i = MouseOverTab And Tabs[i].Enabled
					DrawBox2(lImageOver, rX + EdgeOffset + widths, rY + 2, Tabs[i].Width, TabHeight, True, lTileSides, lTileCenter)
				Else
			 	DrawBox2(lImage, rX + EdgeOffset + widths, rY + 2, Tabs[i].Width, TabHeight, True, lTileSides, lTileCenter)
				End If
				vpX = rX + widths + EdgeOffset + 2 + BorderLeft
				vpW = Tabs[i].Width - (BorderLeft + BorderRight + EdgeOffset)
				ifsoGUI_VP.Add(vpX, vpY, vpW, vpH)
				SetColor(TextColor[0], TextColor[1], TextColor[2])
				ifsoGUI_VP.DrawTextArea(Tabs[i].Text, vpX + 2, vpY + 1, Self)
				SetColor(Color[0], Color[1], Color[2])
				ifsoGUI_VP.Pop()
			End If
			widths:+Tabs[i].Width - (TabOverlap)
			If i < CurrentTab curwidth:+Tabs[i].Width - (TabOverlap)
		Next
		'Draw the current panel
		ifsoGUI_VP.Pop()
		Tabs[CurrentTab].panel.Draw(rX, rY + TabHeight - (BorderBottom + 1), parW, parH)
		'Draw the selected button
		If CurrentTab >= FirstTab
			SetColor(Color[0], Color[1], Color[2])
			SetAlpha(fAlpha)
			ifsoGUI_VP.Add(rX, rY, w - (EdgeOffset + vpoff), TabHeight)
			DrawBox2(lImageDown, rX + curwidth + EdgeOffset, rY, Tabs[CurrentTab].Width, TabHeight, True, lTileSides, lTileCenter)
			vpX = rX + curwidth + EdgeOffset + 2 + BorderLeft
			vpW = Tabs[CurrentTab].Width - (BorderLeft + BorderRight + EdgeOffset)
			ifsoGUI_VP.Add(vpX, vpY, vpW, vpH)
			SetColor(TextColor[0], TextColor[1], TextColor[2])
			ifsoGUI_VP.DrawTextArea(Tabs[CurrentTab].Text, vpX + 2, vpY - 1, Self)
			ifsoGUI_VP.Pop()
			If HasFocus And ShowFocus DrawFocus(vpX, vpY, vpW - 1, vpH - 3)
			ifsoGUI_VP.Pop()
		End If
		If TotalTabWidths > MaxTabWidth
			SetColor(Color[0], Color[1], Color[2])
			DrawBox2(lImage, rX + w - (EdgeOffset + gArrowTabWidth), rY, gArrowTabWidth, TabHeight, True, lTileSides, lTileCenter)
			If FirstTab = 0 SetAlpha(fAlpha * 0.5)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[1], rX + w + BorderLeft - (gArrowTabWidth + EdgeOffset), rY + (TabHeight / 2) - TabArrowHeight / 2, lImageArrow[1].width, TabArrowHeight)
			If FirstTab = 0 SetAlpha(fAlpha)
			If FirstTab = MaxFirstTab SetAlpha(fAlpha * 0.5)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[0], rX + w + BorderLeft + lImageArrow[0].width - (gArrowTabWidth + EdgeOffset), rY + (TabHeight / 2) - TabArrowHeight / 2, lImageArrow[0].width, TabArrowHeight)
			If FirstTab = MaxFirstTab SetAlpha(fAlpha)
		End If
		If fFont SetImageFont(GUI.DefaultFont)
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		Tip = ""
		If Not Visible Return False
		MouseOverTab = -3
		Local rX:Int = parX + x
		Local rY:Int = parY + y
		If (iMouseX > rX) And (iMouseX < rX + w) And (iMouseY > rY) And (iMouseY < rY + h)
			'Check over the tab buttons
			If (iMouseY < rY + TabHeight)
				If TotalTabWidths > MaxTabWidth 'Check if over the tab arrows
					If iMouseX > rX + w - (EdgeOffset + gArrowTabWidth)
						Local TabMid:Int = gArrowTabWidth / 2 + EdgeOffset
						If (iMouseX > rX + w - (TabMid + gImageArrow[0].width)) And (iMouseX < rX + w - TabMid)
							MouseOverTab = -1
							GUI.gMouseOverGadget = Self
							Return True
						ElseIf (iMouseX > rX + w - TabMid) And (iMouseX < rX + w - EdgeOffset)
							MouseOverTab = -2
							GUI.gMouseOverGadget = Self
							Return True
						End If
						Return False
					End If
				End If
				Local widths:Int = 0
				For Local i:Int = FirstTab To Tabs.Length - 1
					If (iMouseX > rX + 4 + widths) And (iMouseX < rX + 4 + widths + Tabs[i].Width)
						If (i = CurrentTab) Or(iMouseY > rY + 2)
							MouseOverTab = i
							Tip = Tabs[i].Tip
							GUI.gMouseOverGadget = Self
							Return True
						End If
					End If
					widths:+Tabs[i].Width - BorderLeft
				Next
			Else 'Check the panels
'				For Local i:Int = 0 To Tabs.Length - 1
					If Tabs[CurrentTab].panel.IsMouseOver(rX, rY + TabHeight - (BorderBottom + 1), parW, parH, iMouseX, iMouseY) Return True
'				Next
			End If
		End If
		Return False
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not Enabled Return
		If MouseOverTab >= 0
			If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
				If Tabs[MouseOverTab].Enabled
					bPressed = True
					GUI.SetActiveGadget(Self)
					If MouseOverTab <> CurrentTab SetCurrentTab(MouseOverTab)
				End If
			Else
				bPressed = True
			End If
		ElseIf MouseOverTab = -1
			If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
		 	GUI.SetActiveGadget(Self)
				SetFirstTab(FirstTab - 1)
			End If
		ElseIf MouseOverTab = -2
			If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
		 	GUI.SetActiveGadget(Self)
				SetFirstTab(FirstTab + 1)
			End If
		Else
			GUI.SetActiveGadget(Null)
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		bPressed = False
		If Not Enabled Return
		If Not (GUI.gMouseOverGadget = Self) GUI.SetActiveGadget(Null)
		If MouseOverTab >= 0
			If iButton = ifsoGUI_RIGHT_MOUSE_BUTTON
				SendEvent(ifsoGUI_EVENT_RIGHT_CLICK, MouseOverTab, iMouseX, iMouseY)
			ElseIf iButton = ifsoGUI_MIDDLE_MOUSE_BUTTON
				SendEvent(ifsoGUI_EVENT_MIDDLE_CLICK, MouseOverTab, iMouseX, iMouseY)
			End If
		ElseIf MouseOverTab < - 2
			GUI.SetActiveGadget(Null)
		End If
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
		If Master
			Master.KeyPress(key)
			Return
		End If
		If (key = ifsoGUI_KEY_LEFT) 'Left
			For Local i:Int = CurrentTab - 1 To 0 Step - 1
				If Tabs[i].Enabled
					SetCurrentTab(i)
					Exit
				End If
			Next
		Else If (key = ifsoGUI_KEY_RIGHT) 'Right
			For Local i:Int = CurrentTab + 1 To Tabs.Length - 1
				If Tabs[i].Enabled
					SetCurrentTab(i)
					Exit
				End If
			Next
		End If
	End Method
	Rem
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget only.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If bPressed
			Return ifsoGUI_MOUSE_DOWN
		ElseIf MouseOverTab > 0
			If Tabs[MouseOverTab].Enabled Return ifsoGUI_MOUSE_OVER
		ElseIf MouseOverTab >= - 2
			Return ifsoGUI_MOUSE_OVER
		End If
		Return ifsoGUI_MOUSE_NORMAL
	End Method
	Rem
	bbdoc: Loads a skin for one insance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lImageOver = gImageOver
			lImageDown = gImageDown
			lImageArrow = gImageArrow
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			gArrowTabWidth = gImage.w[3] + gImage.w[5] + gImageArrow[0].width * 2
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("tabber", strSkin).Split(",")
		Load9Image2("/graphics/tabber.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		If GUI.FileExists(strSkin + "/graphics/tabberover.png")
			Load9Image2("/graphics/tabberover.png", dimensions, lImageOver, strSkin)
		Else
			lImageOver = lImage
		End If
		If GUI.FileExists(strSkin + "/graphics/tabberdown.png")
			Load9Image2("/graphics/tabberdown.png", dimensions, lImageDown, strSkin)
		Else
			lImageDown = lImage
		End If
		lImageArrow = New TImage[2]
		lImageArrow[0] = LoadImage(GUI.FileHeader + strSkin + "/graphics/arrow.png")
		lImageArrow[1] = RotateImage(lImageArrow[0])
		lImageArrow[1] = RotateImage(lImageArrow[1])
		For Local i:Int = 0 To 1
			SetImageHandle(lImageArrow[i], 0, 0)
		Next
		gArrowTabWidth = lImage.w[3] + lImage.w[5] + lImageArrow[0].width * 2
		Refresh()
	End Method
	Rem
	bbdoc: Called when the gadget is no longer the Active Gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method LostFocus(GainedFocus:ifsoGUI_Base)	 'Gadget Lost focus
		bPressed = False
		If GainedFocus <> Self
		 SendEvent(ifsoGUI_EVENT_LOST_FOCUS, 0, 0, 0)
			HasFocus = False
		End If
	End Method
	Rem
	bbdoc: Called when the gadget becomes the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method GainFocus(LostFocus:ifsoGUI_Base)  'Gadget Got focus
		HasFocus = True
		If LostFocus <> Self SendEvent(ifsoGUI_EVENT_GAIN_FOCUS, 0, 0, 0)
	End Method
	Rem
	bbdoc: Called from a slave gadget.
	about: Slave gadgets do not generate GUI events.  They send events to their Master.
	The Master then uses it or can send a GUI event.
	Internal function should not be called by the user.
	End Rem
	Method SlaveEvent(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		If id = ifsoGUI_EVENT_MOUSE_ENTER
			MouseOver(iMouseX, iMouseY, GUI.gWasMouseOverGadget)
		ElseIf id = ifsoGUI_EVENT_MOUSE_EXIT
			MouseOut(iMouseX, iMouseY, GUI.gMouseOverGadget)
		ElseIf id = ifsoGUI_EVENT_MOUSE_MOVE Or ifsoGUI_EVENT_MOUSE_DOWN Or ifsoGUI_EVENT_MOUSE_UP
			SendEvent(id, data, iMouseX, iMouseY)
		End If
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
		BorderTop = lImage.h[1]
		BorderBottom = lImage.h[7]
		BorderLeft = lImage.w[3]
		BorderRight = lImage.w[5]
		MaxTabWidth = w - EdgeOffset * 2
		Local wasFont:TImageFont = GetImageFont()
		If fFont
		 SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
		If th > lImageArrow[0].height
			TabArrowHeight = lImageArrow[0].height
		Else
			TabArrowHeight = th
		End If
		If TabAutoHeight
			TabHeight = th + BorderTop + BorderBottom + 6
		Else
			If TabHeight < th + BorderTop + BorderBottom + 6 TabHeight = th + BorderTop + BorderBottom + 6
		End If
		If TabAutoWidth
			For Local i:Int = 0 To Tabs.Length - 1
				Tabs[i].Width = ifsoGUI_VP.GetTextWidth(Tabs[i].Text, Self) + BorderLeft + BorderRight + 8
			Next
		End If
		TotalTabWidths = 0
		For Local i:Int = 0 To Tabs.Length - 1
			TotalTabWidths:+Tabs[i].Width - TabOverLap
		Next
		If TotalTabWidths < MaxTabWidth
		 FirstTab = 0
		Else
			Local tot:Int = 0
			For Local i:Int = 0 To Tabs.Length - 1
				tot:+Tabs[i].Width
				If TotalTabWidths - tot < MaxTabWidth - (gArrowTabWidth - TabOverLap)
					MaxFirstTab = i + 1
					If MaxFirstTab < 0 MaxFirstTab = 0
					If MaxFirstTab > Tabs.Length - 1 MaxFirstTab = Tabs.Length - 1
					Exit
				End If
			Next
			If FirstTab > MaxFirstTab FirstTab = MaxFirstTab
		End If
		SetImageFont(wasFont)
		For Local i:Int = 0 To Tabs.Length - 1
			Tabs[i].panel.SetWH(w, h + 2 - (TabHeight))
			Tabs[i].panel.SetVisible(False)
		Next
		Tabs[CurrentTab].panel.SetVisible(True)
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("tabber").Split(",")
		Load9Image2("/graphics/tabber.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/tabberover.png")
			Load9Image2("/graphics/tabberover.png", dimensions, gImageOver)
		Else
			gImageOver = gImage
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/tabberdown.png")
			Load9Image2("/graphics/tabberdown.png", dimensions, gImageDown)
		Else
			gImageDown = gImage
		End If
		gImageArrow = New TImage[2]
		gImageArrow[0] = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/arrow.png")
		gImageArrow[1] = RotateImage(gImageArrow[0])
		gImageArrow[1] = RotateImage(gImageArrow[1])
		For Local i:Int = 0 To 1
			SetImageHandle(gImageArrow[i], 0, 0)
		Next
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
	bbdoc: Sets the text on the tab.
	End Rem
	Method SetTabText(intTab:Int, strText:String)
		If intTab > Tabs.Length - 1 Return
		Tabs[intTab].Text = strText
		If TabAutoWidth Refresh()
	End Method
	Rem
	bbdoc: Returns the text on the tab.
	End Rem
	Method GetTabText:String(intTab:Int)
		If intTab > Tabs.Length - 1 Return ""
		Return Tabs[intTab].Text
	End Method
	Rem
	bbdoc: Sets Tab Auto Width on or off.
	End Rem
	Method SetTabAutoWidth(intAutoWidth:Int)
		TabAutoWidth = intAutoWidth
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether tab auto width is on or off.
	End Rem
	Method GetTabAutoWidth:Int()
		Return TabAutoWidth
	End Method
	Rem
	bbdoc: Sets whether or not the border will show.
	End Rem
	Method SetShowBorder(bShowBorder:Int)
		ShowBorder = bShowBorder
		For Local i:Int = 0 To Tabs.Length - 1
			Tabs[i].panel.SetShowBorder(bShowBorder)
		Next
	End Method
	Rem
	bbdoc: Sets Tab Auto Height on or off.
	End Rem
	Method SetTabAutoHeight(intTabAutoHeight:Int)
		TabAutoHeight = intTabAutoHeight
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the border is showing.
	End Rem
	Method GetShowBorder:Int()
		Return ShowBorder
	End Method
	Rem
	bbdoc: Returns whether tab auto height is on or off.
	End Rem
	Method GetTabAutoHeight:Int()
		Return TabAutoHeight
	End Method
	Rem
	bbdoc: Sets the tip of the tab.
	End Rem
	Method SetTabTip(intTab:Int, strTip:String)
		If intTab > Tabs.Length - 1 Return
		Tabs[intTab].Tip = strTip
		If intTab = CurrentTab Tip = strTip
	End Method
	Rem
	bbdoc: Returns the tip of the tab.
	End Rem
	Method GetTabTip:String(intTab:Int)
		If intTab > Tabs.Length - 1 Return ""
		Return Tabs[intTab].Tip
	End Method
	Rem
	bbdoc: Sets the current tab.
	End Rem
	Method SetCurrentTab(intTab:Int)
		If intTab > Tabs.Length - 1 Or intTab < 0 Return
		If intTab = CurrentTab Return
		Tabs[CurrentTab].panel.SetVisible(False)
		CurrentTab = intTab
		If TotalTabWidths > MaxTabWidth
			If CurrentTab < FirstTab
			 FirstTab = CurrentTab
			Else
				Local tmpWidth:Int
				Repeat
					tmpWidth = 0
					For Local i:Int = FirstTab To CurrentTab
						tmpWidth:+Tabs[i].Width
					Next
					If FirstTab = CurrentTab Exit 'exit if reaches the current tab
					If tmpWidth > MaxTabWidth - (gArrowTabWidth - EdgeOffset) FirstTab:+1
				Until tmpWidth <= MaxTabWidth - (gArrowTabWidth - EdgeOffset)
			End If
		End If
		Tabs[CurrentTab].panel.SetVisible(True)
		SendEvent(ifsoGUI_EVENT_CHANGE, CurrentTab, -1, -1)
	End Method
	Rem
	bbdoc: Returns the absolute X and Y screen position of the gadget.
	End Rem
	Method GetAbsoluteXY(iX:Int Var, iY:Int Var, caller:ifsoGUI_Base = Null)
		If Parent
			Parent.GetAbsoluteXY(iX, iY, Self)
		ElseIf Master
			Master.GetAbsoluteXY(iX, iY, Self)
		End If
		iX:+x
		iY:+y
		If caller.Master = Self iY:+TabHeight - (BorderBottom + 1)
	End Method
	Rem
	bbdoc: Returns the gadget with the name from the child list.
	about: Internal function should not be called by the user.
	End Rem
	Method GetChild:ifsoGUI_Base(name:String)
		Local g:ifsoGUI_Base
		For Local c:Int = 0 To Tabs.Length - 1
			g = Tabs[c].panel.GetChild(name)
			If g Return g
		Next
		Return Null
	End Method
	Rem
	bbdoc: Returns the current tab.
	End Rem
	Method GetCurrentTab:Int()
		Return CurrentTab
	End Method
	Rem
	bbdoc: Sets the amount th etabs will overlap.
	End Rem
	Method SetTabOverlap(intTabOverlap:Int)
		TabOverlap = intTabOverlap
	End Method
	Rem
	bbdoc: Returns the amount the tabs will overlap.
	End Rem
	Method GetTabOverlap:Int()
		Return TabOverlap
	End Method
	Rem
	bbdoc: Sets the width of the tab.
	End Rem
	Method SetTabWidth(intTab:Int, intWidth:Int)
		If TabAutoWidth Return
		If intTab >= Tabs.Length Return
		Tabs[intTab].Width = intWidth
		Refresh()
	End Method
	Rem
	bbdoc: Returns the width of the tab.
	End Rem
	Method GetTabWidth:Int(intTab:Int)
		If intTab >= Tabs.Length Or intTab < 0 Return 0
		Return Tabs[intTab].Width
	End Method
	Rem
	bbdoc: Sets the height of the tab.
	End Rem
	Method SetTabHeight(intHeight:Int)
		TabHeight = intHeight
		Refresh()
	End Method
	Rem
	bbdoc: Returns the height of the tab.
	End Rem
	Method GetTabHeight:Int()
		Return TabHeight
	End Method
	Rem
	bbdoc: Sets the distance from the edge of the gadget to the first/last tabs.
	End Rem
	Method SetEdgeOffset(intEdgeOffset:Int)
		If intEdgeOffset = EdgeOffset Return
		EdgeOffset = intEdgeOffset
		Refresh()
	End Method
	Rem
	bbdoc: Returns the distance from the edge of the gadget to the first/last tabs.
	End Rem
	Method GetEdgeOffset:Int()
		Return EdgeOffset
	End Method
	Rem
	bbdoc: Sets the first visible tab.
	about: Only useful if more tabs than are visible at a time are in use.
	End Rem
	Method SetFirstTab(intFirstTab:Int)
		If TotalTabWidths <= MaxTabWidth Return
		FirstTab = intFirstTab
		If FirstTab < 0 FirstTab = 0
		If FirstTab > MaxFirstTab FirstTab = MaxFirstTab
	End Method
	Rem
	bbdoc: Returns the first visible tab.
	End Rem
	Method GetFirstTab:Int()
		Return FirstTab
	End Method
	Rem
	bbdoc: Sets the tab enabled/disabled.
	End Rem
	Method SetTabEnabled(intTab:Int, intEnabled:Int)
		If intTab > Tabs.Length - 1 Or intTab < 0 Return
		Tabs[intTab].Enabled = intEnabled
		If (Not intEnabled) And (CurrentTab = intTab)
			For Local i:Int = CurrentTab + 1 To Tabs.Length - 1
				If Tabs[i].Enabled
				 SetCurrentTab(i)
					Return
				End If
			Next
			For Local i:Int = CurrentTab - 1 To 0 Step - 1
			 If Tabs[i].Enabled
				 SetCurrentTab(i)
					Return
				End If
			Next
			Tabs[intTab].Enabled = True
		End If
	End Method
	Rem
	bbdoc: Returns whether the tab is enabled or not.
	End Rem
	Method GetTabEnabled:Int(intTab:Int)
		If intTab < 0 Or intTab > Tabs.Length - 1 Return 0
		Return Tabs[intTab].Enabled
	End Method
	Rem
	bbdoc: Returns the number of tabs.
	End Rem
	Method GetNumTabs:Int()
		Return Tabs.Length
	End Method
	Rem
	bbdoc: Sets the font of the gadget.
	about: Set to Null to use the default GUI font.
	End Rem
	Method SetFont(Font:TImageFont)
		fFont = Font
		Refresh()
	End Method
	Rem
	bbdoc: Adds a tab.
	End Rem
	Method AddTab(strText:String, strTip:String = "", intWidth:Int = 0, intIndex:Int = -1)
		Local numtabs:Int = Tabs.Length
		If intIndex > numTabs intIndex = numtabs
		If intIndex < 0 intIndex = numtabs
		Tabs = Tabs[..numtabs + 1]
		Local NewTab:TabberTab = New TabberTab
		For Local i:Int = numtabs - 1 To intIndex Step - 1
			Tabs[i + 1] = Tabs[i]
		Next
		Tabs[intIndex] = NewTab
		Tabs[intIndex].Init(w, h, Name + "_panel")
		Tabs[intIndex].panel.Master = Self
		Slaves.AddLast(Tabs[intIndex].panel)
		Tabs[intIndex].Text = strText
		Tabs[intIndex].Tip = strTip
		Tabs[intIndex].Width = intWidth
		If intIndex <= CurrentTab CurrentTab:+1
		Refresh()
	End Method
	Rem
	bbdoc: Removes a tab.
	End Rem
	Method RemoveTab(intTab:Int)
		Local numtabs:Int = Tabs.Length
		If numtabs = 1 Return
		If intTab >= numTabs Or intTab < 0 Return
		Slaves.Remove(Tabs[intTab].panel)
		For Local i:Int = intTab To numtabs - 2
			Tabs[i] = Tabs[i + 1]
		Next
		Tabs = Tabs[..numtabs - 1]
		If intTab <= CurrentTab CurrentTab:-1
		If CurrentTab < 0 CurrentTab = 0
		Refresh()
	End Method
	Rem
	bbdoc: Adds a child to a tab.
	End Rem
	Method AddTabChild(gadget:ifsoGUI_Base, intTab:Int)
		If intTab < 0 Or intTab >= Tabs.Length Return
		Tabs[intTab].panel.AddChild(gadget)
	End Method
	Rem
	bbdoc: Removes a child from a tab.
	End Rem
	Method RemoveTabChild(gadget:ifsoGUI_Base, intTab:Int, bDestroy:Int = True)
		If intTab < 0 Or intTab >= Tabs.Length Return
		Tabs[intTab].panel.RemoveChild(gadget, bDestroy)
	End Method

End Type

Type TabberTab
	Field Text:String
	Field Width:Int
	Field Tip:String
	Field Enabled:Int = True
	Field panel:ifsoGUI_Panel
	
	Method Init(iW:Int, iH:Int, strName:String)
		panel = ifsoGUI_Panel.Create(0, 0, iW, iH, strName)
	End Method
End Type