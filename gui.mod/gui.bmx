SuperStrict

Rem
	bbdoc: ifsoGUI
	about: BlitzMax graphic gui library.
EndRem
Module ifsogui.gui

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import brl.linkedlist
Import brl.max2d
Import brl.GLMax2D
Import brl.stream
Import brl.bmploader
Import brl.jpgloader
Import brl.pngloader
Import brl.audio
Import brl.ramstream
Import brl.map
?Win32
Import brl.D3D7Max2D
Import brl.D3D9Max2D
?

Import pub.zlib
Import brl.filesystem

Import koriolis.zipstream
'Import "zipstream/zip.c"
'Import "zipstream/unzip.c"
'Import "zipstream/ioapi.c"
'Import "zipstream/bmxsupport.c"
'Include "zipstream/bufferedstream.bmx"
'Include "zipstream/zipstream.bmx"

Include "events.bmx"
Include "basegadget.bmx"

Const ifsoGUI_MOUSE_NORMAL:Int = 0
Const ifsoGUI_MOUSE_OVER:Int = 1
Const ifsoGUI_MOUSE_DOWN:Int = 2
Const ifsoGUI_MOUSE_RESIZE:Int = 3
Const ifsoGUI_MOUSE_IBAR:Int = 4
Const ifsoGUI_MOUSE_COUNT:Int = 5

Const ifsoGUI_RESIZE_LEFT:Int = 1
Const ifsoGUI_RESIZE_RIGHT:Int = 2
Const ifsoGUI_RESIZE_TOP:Int = 4
Const ifsoGUI_RESIZE_BOTTOM:Int = 8

Const ifsoGUI_LEFT_MOUSE_BUTTON:Int = 1
Const ifsoGUI_RIGHT_MOUSE_BUTTON:Int = 2
Const ifsoGUI_MIDDLE_MOUSE_BUTTON:Int = 3
Const ifsoGUI_MOUSE_WHEEL_UP:Int = 4
Const ifsoGUI_MOUSE_WHEEL_DOWN:Int = 5

Const ifsoGUI_LEFT:Int = 1
Const ifsoGUI_RIGHT:Int = 2
Const ifsoGUI_TOP:Int = 3
Const ifsoGUI_BOTTOM:Int = 4

Const ifsoGUI_DOUBLE_CLICK_DELAY:Int = 500
Const ifsoGUI_KEY_DELAY:Int = 400
Const ifsoGUI_KEY_REPEAT:Int = 50
Const ifsoGUI_KEY_DELETE:Int = 1000
Const ifsoGUI_KEY_LEFT:Int = 1001
Const ifsoGUI_KEY_RIGHT:Int = 1002
Const ifsoGUI_KEY_UP:Int = 1003
Const ifsoGUI_KEY_DOWN:Int = 1004
Const ifsoGUI_KEY_HOME:Int = 1005
Const ifsoGUI_KEY_END:Int = 1006
Const ifsoGUI_KEY_INSERT:Int = 1007
Const ifsoGUI_KEY_PAGEUP:Int = 1008
Const ifsoGUI_KEY_PAGEDOWN:Int = 1009

Const ifsoGUI_JUSTIFY_LEFT:Int = 0
Const ifsoGUI_JUSTIFY_CENTER:Int = 1
Const ifsoGUI_JUSTIFY_RIGHT:Int = 2

Rem
	bbdoc: GUI Type
	about: All GUI work is through this interface.
End Rem
Type GUI Final
	Global iWidth:Int 'Screen/Window Width
	Global iHeight:Int 'Screen/Window Height
	Global Gadgets:TList = New TList 'List of all panels
	Global Tabs:TList = New TList 'List of tabbale gadgets in order
	Global MouseOverGadget:ifsoGUI_Base
	Global ThemePath:String 'path to the theme
	Global DefaultFont:TImageFont 'Default Font
	Global Events:TList = New TList	'Events to be processed
	Global UseEvents:Int = True 'Whether or not events are generated.  Or only using callbacks.
	Global Mouse:TImage[] 'Array of Cursor Images
	Global currentMouse:Int 'Index to the current Cursor
	Global bDrawMouse:Int = False 'Whether the GUI should draw the mouse
	Global gActiveGadget:ifsoGUI_Base ' The Gadget with focus operating on
	Global gMouseOverGadget:ifsoGUI_Base 'The gadget the mouse is over
	Global gWasMouseOverGadget:ifsoGUI_Base 'The gadget mouse was over last frame
	Global iMouseDown:Int = 0 'Was the mouse button down
	Global iMouseStatus:Int = 0 'Mouse cursor currently in use
	Global iMouseDir:Int 'For resize directional arrows
	Global iMouseX:Int, iMouseY:Int, iMouseZ:Int, iMouseZChange:Int, iMouseZWas:Int 'Position of the mouse this Update frame
	Global KeyDowns:Int[] = [KEY_DELETE, KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_HOME, KEY_END, KEY_INSERT, KEY_PAGEDOWN, KEY_PAGEUP]
	Global KeyCodes:Int[] = [ifsoGUI_KEY_DELETE, ifsoGUI_KEY_LEFT, ifsoGUI_KEY_RIGHT, ifsoGUI_KEY_UP, ifsoGUI_KEY_DOWN, ifsoGUI_KEY_HOME, ifsoGUI_KEY_END, ifsoGUI_KEY_INSERT, ifsoGUI_KEY_PAGEDOWN, ifsoGUI_KEY_PAGEUP]
	Global TabActive:Int 'Can the tab key move the Focus to the GUI
	Global Tabbing:Int = True 'Can the user tab from gadget to gadget.
	Global TipR:Int = 255 'Tip Default Color is Yellow
	Global TipG:Int = 255
	Global TipB:Int = 0
	Global TipTextR:Int = 0 'Tip Text Default Color is Black
	Global TipTextG:Int = 0
	Global TipTextB:Int = 0
	Global TipBorderR:Int = 0 'Tip Border Default Color is Black
	Global TipBorderG:Int = 0
	Global TipBorderB:Int = 0
	Global TipFont:TImageFont
	Global TipAlpha:Float = 1.0 'Alpha for tip
	Global GadgetCallbacks(id:Int, data:Int)[]
	Global MouseButtonDelay:Int = 400 ' Millisecs
	Global MouseButtonRepeat:Int = 80
	Global Modal:ifsoGUI_Base 'The gadget that is modal.
	Global bMouseShowing:Int 'So we don't needlessly call ShowMouse() or HideMouse()
	Global FileHeader:String 'Appended to all file loading
	Global IncbinHeader:String 'Appened to file loading for incbin
	Global ZipHeader:String 'Used for loading from zip files.
	Global ZipFile:String 'Used for loading from zip files.
	Global ZipPassword:String 'Used for loading from zip archives.
	Global TextColor:Int[3] ' Default Text Color
	Global bUseVR:Int = True 'Is ifsoGUI using the Virtual Resolution
	
	Rem
	bbdoc: Check if the file exists.  Works of the file is incbin or not.
	End Rem
	Function FileExists:Int(strFile:String)
		Local file:TStream = ReadFile(FileHeader + strFile)
		If file
			file.Close()
			Return True
		End If
		Return False
	End Function
	Rem
	bbdoc: Find which gadget the mouse is over.
	about: Starts at the topmost window and has each gadget check if the mouse is over any of its children.
	Internal function should not be called by the user.
	End Rem
	Function CheckMouseOver()
		gWasMouseOverGadget = gMouseOverGadget
		gMouseOverGadget = Null 'Set this to null, so it can be set by correct gadget
		MouseOverGadget = Null
		If Modal
			If Modal.IsMouseOver(0, 0, iWidth, iHeight, iMouseX, iMouseY)
			 MouseOverGadget = Modal 'Remember which panel the mouse is over, so we can bring to front if click a child
			End If
		Else
			For Local p:ifsoGUI_Base = EachIn Gadgets
				If p.IsMouseOver(0, 0, iWidth, iHeight, iMouseX, iMouseY)
				 MouseOverGadget = p 'Remember which panel the mouse is over, so we can bring to front if click a child
					Return
				End If
			Next
		End If
	End Function
	Rem
	bbdoc: Gets the mouse position and processes mouse clicks.
	Internal function should not be called by the user.
	End Rem
	Function ProcessMouse:Int()
		Global iWasX:Int, iWasY:Int
		Local bChanged:Int = False
		If gWasMouseOverGadget And (gWasMouseOverGadget <> gMouseOverGadget) 'Mouseout event for gadget
			gWasMouseOverGadget.MouseOut(iMouseX, iMouseY, gMouseOverGadget)
		End If
		If gMouseOverGadget gMouseOverGadget.MouseOver(iMouseX, iMouseY, gWasMouseOverGadget) 'MouseOver event for gadget
		If iMouseDown > 0 'Mouse button is down
			bChanged = True
			If Not (MouseDown(iMouseDown)) 'Released
				If gActiveGadget gActiveGadget.gMouseUp(iMouseDown, iMouseX, iMouseY)
				iMouseDown = 0
			End If
		Else
			For Local i:Int = ifsoGUI_LEFT_MOUSE_BUTTON To ifsoGUI_MIDDLE_MOUSE_BUTTON
				If MouseDown(i)
					bChanged = True
					iMouseDown = i
					If gMouseOverGadget
						gMouseOverGadget.gMouseDown(i, iMouseX, iMouseY)
					 MouseOverGadget.BringToFront()
					Else
						SetActiveGadget(Null)
					End If
					Exit
				End If
			Next
		End If
		If iMouseDown > 0 And gActiveGadget
			iMouseStatus = gActiveGadget.MouseStatus(iMouseX, iMouseY) 'Get Cursor status from active gadget if mouse down on it
		Else
			If gMouseOverGadget iMouseStatus = gMouseOverGadget.MouseStatus(iMouseX, iMouseY) 'Get status from mouse over gadget
		End If
		If (iWasX <> iMouseX) Or (iWasY <> iMouseY) bChanged = True
		iWasX = iMouseX
		iWasY = iMouseY
		Return bChanged
	End Function
	Rem
	bbdoc: Repositions the mouse cursor and emits a mouse move system event.
	about: This function exists because the MoveVirtualMouse function does not cause a MouseMove event to be emitted.
	End rem
	Function PositionMouse(X:Int, Y:Int)
		MoveVirtualMouse(X, Y)
		iMouseX = X
		iMouseY = Y
		Local e:TEvent = New TEvent
		e.id = EVENT_MOUSEMOVE
		e.x = X
		e.y = Y
		e.Emit()
	End Function
	Rem
	bbdoc: Processes keys and sends them to the active gadget.
	about: This function also handles the tab key moving from gadget to gadget, and the mouse wheel.
	Internal function should not be called by the user.
	End Rem
	Function ProcessKeyboard:Int()
		Global iLast:Int, isDown:Int, wasKey:Int, bFirst:Int
		Local bChanged:Int = False
		If iMouseDown = 0
			If gActiveGadget
			 'Check MouseWheel
				If iMouseZChange > 0
					gActiveGadget.KeyPress(ifsoGUI_MOUSE_WHEEL_UP)
					bChanged = True
				ElseIf iMouseZChange < 0
					gActiveGadget.KeyPress(ifsoGUI_MOUSE_WHEEL_DOWN)
					bChanged = True
				End If
				Local c:Int = GetChar()
				If c = KEY_TAB And Tabbing
					bChanged = True
					If KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT)
						MoveActive(False)
					Else
						MoveActive()
					End If
				ElseIf c
					gActiveGadget.KeyPress(c)
					bChanged = True
				End If
				Local i:Int
				For i = 0 To KeyDowns.Length - 1
					If KeyDown(KeyDowns[i])
						Local bSendit:Int
						If wasKey = KeyDowns[i]
							If bFirst
							 If MilliSecs() - iLast > ifsoGUI_KEY_DELAY
							 	bSendIt = True
									bFirst = False
								End If
							Else
								If MilliSecs() - iLast > ifsoGUI_KEY_REPEAT bSendIt = True
							End If
						Else
							bFirst = True
							bSendit = True
							wasKey = KeyDowns[i]
						End If
						If bSendIt
						 gActiveGadget.KeyPress(KeyCodes[i])
							iLast = MilliSecs()
							bChanged = True
						End If
						Exit
					End If
				Next
				If i >= KeyDowns.Length wasKey = 0
			Else
			 Local c:Int = GetChar()
				If (c = KEY_TAB) And TabActive And Tabbing
				 MoveActive()
					bChanged = True
				End If
			End If
		Else
			'If the mouse is down, clear the buffer
			Local c:Int = GetChar()
			While c
				c = GetChar()
			Wend
		End If
		Return bChanged
	End Function
	Rem
	bbdoc: Draws the gadgets.
	about: Internal function should not be called by the user.
	End Rem
	Function Draw()
		Local l:TLink = Gadgets.LastLink()
		While l
			ifsoGUI_Base(l.Value()).Draw(0, 0, iWidth, iHeight)
			l = l.PrevLink()
		Wend
	End Function
	Rem
	bbdoc: Draws the mouse pointer.
	about: Internal function should not be called by the user.
	End Rem
	Function DrawMouse()
		SetColor 255, 255, 255
		SetAlpha(1.0)
		'draw the mouse
		If iMouseStatus = ifsoGUI_MOUSE_RESIZE
			If Mouse[ifsoGUI_MOUSE_RESIZE]
				If iMouseDir = ifsoGUI_RESIZE_BOTTOM | ifsoGUI_RESIZE_RIGHT
					SetRotation(45)
				ElseIf iMouseDir = ifsoGUI_RESIZE_BOTTOM | ifsoGUI_RESIZE_LEFT
					SetRotation(135)
				ElseIf iMouseDir = ifsoGUI_RESIZE_TOP | ifsoGUI_RESIZE_RIGHT
					SetRotation(315)
				ElseIf iMouseDir = ifsoGUI_RESIZE_TOP | ifsoGUI_RESIZE_LEFT
					SetRotation(225)
				ElseIf iMouseDir = ifsoGUI_RESIZE_LEFT
					SetRotation(180)
				ElseIf iMouseDir = ifsoGUI_RESIZE_BOTTOM
					SetRotation(90)
				ElseIf iMouseDir = ifsoGUI_RESIZE_TOP
					SetRotation(270)
				End If
				If bMouseShowing
					HideMouse()
					bMouseShowing = False
				End If
				DrawImage(Mouse[ifsoGUI_MOUSE_RESIZE], iMouseX, iMouseY)
				SetRotation(0)
			ElseIf Mouse[ifsoGUI_MOUSE_NORMAL]
				If bMouseShowing
					HideMouse()
					bMouseShowing = False
				End If
				DrawImage(Mouse[ifsoGUI_MOUSE_NORMAL], iMouseX, iMouseY)
			Else
				If Not bMouseShowing
					ShowMouse()
					bMouseShowing = True
				End If
			End If
		Else
			If Mouse[iMouseStatus]
				If bMouseShowing
					HideMouse()
					bMouseShowing = False
				End If
				DrawImage(Mouse[iMouseStatus], iMouseX, iMouseY)
			ElseIf Mouse[ifsoGUI_MOUSE_NORMAL]
				If bMouseShowing
					HideMouse()
					bMouseShowing = False
				End If
				DrawImage(Mouse[ifsoGUI_MOUSE_NORMAL], iMouseX, iMouseY)
			Else
				If Not bMouseShowing
					ShowMouse()
					bMouseShowing = True
				End If
			End If
		End If
	End Function
	Rem
	bbdoc: Sets the Active gadget.
	about: Sends appropriate focus events.
	Internal function should not be called by the user.
	End Rem
	Function SetActiveGadget(gadget:ifsoGUI_Base)
		If Modal
			If gadget <> Modal And (Not Modal.IsMyChild(gadget)) Return
		End If
		If gActiveGadget = gadget Return
		Local wasgadget:ifsoGUI_Base = gActiveGadget
		gActiveGadget = gadget
		If wasgadget wasgadget.LostFocus(gActiveGadget)
		If gActiveGadget gActiveGadget.GainFocus(wasgadget)
	End Function
	Rem
	bbdoc: Adds an event to the GUI event queue.
	about: Internal function should not be called by the user.
	End Rem
	Function AddEvent(e:ifsoGUI_Event)
		Events.AddLast(e)
	End Function
	Rem
	bbdoc: Moves the focus to the next gadget.
	about: Internal function should not be called by the user.
	End Rem
	Function MoveActive(bForward:Int = True)
		Local g:ifsoGUI_Base
		If Tabs.IsEmpty() Return
		If Modal
			g = Modal.NextGadget(gActiveGadget, bForward)
			While g
				If g.CanActive() Exit
				g = Modal.NextGadget(g, bForward)
			Wend
			If Not g
				g = Modal.NextGadget(Null, bForward)
				While g
					If g.CanActive() Exit
					g = Modal.NextGadget(g, bForward)
				Wend
			End If
		Else
			Local bFlag:Int = False
			If bForward
				'Find first CanActive gadget after the current gadget
				For Local a:ifsoGUI_Base = EachIn Tabs
					If bFlag
						If a.CanActive()
							g = a
							Exit
						End If
					End If
					If a = gActiveGadget bFlag = True
				Next
				'If we didn't find one, then set the first gadget Active
				If Not g
					For Local a:ifsoGUI_Base = EachIn Tabs
						If a.CanActive()
							g = a
							Exit
						End If
					Next
				End If
			Else
				Local l:TLink = Tabs.LastLink()
				While l
					If bFlag
						If ifsoGUI_Base(l.Value()).CanActive()
							g = ifsoGUI_Base(l.Value())
							Exit
						End If
					End If
					If l.Value() = gActiveGadget bFlag = True
					l = l.PrevLink()
				Wend
				If Not g
					l = Tabs.LastLink()
					While l
						If ifsoGUI_Base(l.Value()).CanActive()
							g = ifsoGUI_Base(l.Value())
							Exit
						End If
						l = l.PrevLink()
					Wend
				End If
			End If
		End If
		If g SetActiveGadget(g)
	End Function
	Rem
	bbdoc: Returns the Next Top Level Gadget.
	about: Internal function should not be called by the user.
	End Rem
	Function NextGadget:ifsoGUI_Base(StartGadget:ifsoGUI_Base, bCheckChildren:Int = True, bForward:Int = True)
		If Gadgets.Count() = 0 Return Null ' No gadgets in top level list, then return null
		Local g:ifsoGUI_Base
		If Not StartGadget 'No Start Gadget, Return First Gadget without a Master
		 If bForward
				For Local p:ifsoGUI_Base = EachIn Gadgets
					If Not p.Master Return p
				Next
				Return Null
			Else
				Local t:TLink = Gadgets.LastLink()
				While t
					If Not ifsoGUI_Base(t.Value()).Master Return ifsoGUI_Base(t.Value())
				Wend
				Return Null
			End If
		End If
		'Check the Start Gadget for next gadget
		If bCheckChildren g = StartGadget.NextGadget(Null, bForward)
		If g Return g
		'Now climb out the parent tree checking for next gadgets
		g = StartGadget
		Local par:ifsoGUI_Base = g.Master
		If Not par par = g.Parent
		If par
			While par
				g = par.NextGadget(g, bForward)
				If g
				 Return g
				Else
					g = par
					If par.Parent
						par = par.Parent
					ElseIf par.Master
						par = par.Master
					Else
						Exit
					End If
				End If
			Wend
		Else
		 par = g
		End If
		'Return the next top level gadget
		Local bFlag:Int
		If bForward
			For Local top:ifsoGUI_Base = EachIn Gadgets
				If bFlag And Not top.Master Return top
				If top = par bFlag = True
			Next
			For Local top:ifsoGUI_Base = EachIn Gadgets
				If Not top.Master Return top
			Next
			Return Null
		Else
			Local p:TLink = Gadgets.LastLink()
			While p
				If bFlag And Not ifsoGUI_Base(p.Value()).Master Return ifsoGUI_Base(p.Value())
				If par = p.Value() bFlag = True
				p = p.PrevLink()
			Wend
			p = Gadgets.LastLink()
			While p
				If Not ifsoGUI_Base(p.Value()).Master Return ifsoGUI_Base(p.Value())
				p = p.PrevLink()
			Wend
			Return Null
		End If
	End Function
	Rem
	bbdoc: Registers an event handler for GUI wide events.
	about: Internal function should not be called by the user.
	End Rem
	Function Register(SystemEvent(id:Int, data:Int))
		'If already in the array, ignore
		For Local i:Int = 0 To GadgetCallbacks.Length - 1
			If GadgetCallbacks[i] = SystemEvent Return
		Next
		'Add Callback to the Array
		GadgetCallbacks = GadgetCallbacks[..GadgetCallbacks.Length + 1]
		GadgetCallbacks[GadgetCallbacks.Length - 1] = SystemEvent
	End Function
	Rem
	bbdoc: Sets a gadget Modal.
	about: Internal function should not be called by the user.
	End Rem
	Function SetModal(gadget:ifsoGUI_Base)
		SetActiveGadget(gadget)
		Modal = gadget
	End Function
	Rem
	bbdoc: Unsets Modal gadget.
	about: Internal function should not be called by the user.
	End Rem
	Function UnSetModal()
		Modal = Null
		If gActiveGadget = Modal gActiveGadget = Null
	End Function
	
	'User Functions/Properties
	Rem
	bbdoc: Refreshes the GUI.
	about: Either Refresh should be called, or "Logic" and "Render" should be called separately.
	This is so the user can have the Logic and Render separate in their program if desired.
	End Rem
	Function Refresh() 'Call "Refresh" or "Logic and Render"
		ClearEvents()
		ifsoGUI_Settings.PushSettings() 'Remember User Settings so we can change them
		ifsoGUI_Settings.InitSettings() 'Init settings for ifsoGUI
		iMouseX = VirtualMouseX() 'Get Mouse position
		iMouseY = VirtualMouseY()
		iMouseZWas = iMouseZ
		iMouseZ = MouseZ()
		iMouseZChange = iMouseZ - iMouseZWas
		iMouseStatus = ifsoGUI_MOUSE_NORMAL 'Set mouse to normal
		CheckMouseOver() 'Find which gadget the mouse is over
		ProcessMouse() 'process the mouse
		ProcessKeyBoard() 'process the keyboard
		Draw() 'draw the gadgets
		If bDrawMouse DrawMouse() 'draw the pointer if we are suppose to
		If gMouseOverGadget Then 'Added Tooltip Delay by Zeke
			If gMouseOverGadget.Tip_showing = False
				gMouseOverGadget.Tip_time = MilliSecs() + gMouseOverGadget.Tip_delay
				gMouseOverGadget.Tip_showing = True
			Else
				If MilliSecs() > gMouseOverGadget.Tip_time
					gMouseOverGadget.DrawTip(iMouseX, iMouseY) 'draw tip if over a gadget
				End If
			End If
		EndIf
		ifsoGUI_Settings.PopSettings() 'Reset the users settings
	End Function
	Rem
	bbdoc: Updates the logic of all of the gadgets. Returns True if any of the graphics have changed.
	about: Either Refresh should be called, or "Logic" and "Render" should be called separately.
	This is so the user can have the Logic and Render separate in their program if desired.
	End Rem
	Function Logic:Int()
		Local bChanged:Int = False
		If bDrawMouse bChanged = True
		ClearEvents()
		ifsoGUI_Settings.PushSettings() 'Remember User Settings so we can change them
		ifsoGUI_Settings.InitSettings() 'Init settings for ifsoGUI.
		iMouseX = VirtualMouseX() 'Get Mouse position
		iMouseY = VirtualMouseY()
		iMouseZ = MouseZ() - iMouseZ
		iMouseStatus = ifsoGUI_MOUSE_NORMAL 'Set mouse to normal
		CheckMouseOver() 'Find which gadget the mouse is over
		If ProcessMouse() bChanged = True 'process the mouse
		If ProcessKeyBoard() bChanged = True 'process the keyboard
		ifsoGUI_Settings.PopSettings() 'Reset the users settings
		Return bChanged
	End Function
	Rem
	bbdoc: Renders the GUI.
	about: Either Refresh should be called, or "Logic" and "Render" should be called separately.
	This is so the user can have the Logic and Render separate in their program if desired.
	End Rem
	Function Render()
		ifsoGUI_Settings.PushSettings() 'Remember User Settings so we can change them
		ifsoGUI_Settings.InitSettings() 'Init the settings for ifsoGUI.
		Draw() 'draw the gadgets
		If bDrawMouse DrawMouse() 'draw the pointer if we are suppose to
		If gMouseOverGadget Then 'Added Tooltip Delay by Zeke
			If gMouseOverGadget.Tip_showing = False
				gMouseOverGadget.Tip_time = MilliSecs() + gMouseOverGadget.Tip_delay
				gMouseOverGadget.Tip_showing = True
			Else
				If MilliSecs() > gMouseOverGadget.Tip_time
					gMouseOverGadget.DrawTip(iMouseX, iMouseY) 'draw tip if over a gadget
				End If
			End If
		EndIf
		ifsoGUI_Settings.PopSettings() 'Reset the users settings
	End Function
	Rem
	bbdoc:Sets the Custom DrawText Function.
	End rem
	Function SetCustomDrawText(funcDrawText(strText:String, x:Float, y:Float, gadget:ifsoGUI_Base))
		ifsoGUI_VP.CustDrawText = funcDrawText
	End Function
	Rem
	bbdoc:Sets the Custom TextHeight Function.
	End rem
	Function SetCustomTextHeight(funcTextHeight:Int(gadget:ifsoGUI_Base))
		ifsoGUI_VP.CustTextHeight = funcTextHeight
	End Function
	Rem
	bbdoc:Sets the Custom TextWidth Function.
	End rem
	Function SetCustomTextWidth(funcTextWidth:Int(strText:String, gadget:ifsoGUI_Base))
		ifsoGUI_VP.CustTextWidth = funcTextWidth
	End Function
	Rem
	bbdoc: Returns whether or not the custom font system can draw partial characters.
	End Rem
	Function GetCanDrawPartialChars:Int()
		Return ifsoGUI_VP.bCanDrawPartial
	End Function
	Rem
	bbdoc: Sets whether or not the custom font system can draw partial characters.
	End Rem
	Function SetCanDrawPartialChars(bPartialChars:Int)
		ifsoGUI_VP.bCanDrawPartial = bPartialChars
	End Function
	Rem
	bbdoc: Returns whether or not the user is using a custom font system.
	End Rem
	Function GetUseCustomFontSystem:Int()
		Return ifsoGUI_VP.bUseCustomFont
	End Function
	Rem
	bbdoc: Sets whether or not the user is using a custom font system.
	End Rem
	Function SetUseCustomFontSystem(bCustomFont:Int)
		ifsoGUI_VP.bUseCustomFont = bCustomFont
	End Function
	Rem
	bbdoc: Returns the Default Font of the GUI.
	End Rem
	Function GetDefaultFont:TImageFont()
		Return DefaultFont
	End Function
	Rem
	bbdoc: Sets the default font.
	End Rem
	Function SetDefaultFont(fntFont:TImageFont)
		DefaultFont = fntFont
		'All Controls now need to check their width and height
		For Local p:ifsoGUI_Base = EachIn Gadgets
			p.GadgetSystemEvent(ifsoGUI_EVENT_SYSTEM_NEW_DEFAULT_FONT, 0)
		Next
	End Function
	Rem
	bbdoc: Sets whether or not the Tab key can move focus from gadget to gadget.
	End Rem
	Function SetTabbing(bTabbing:Int = True)
		Tabbing = bTabbing
	End Function
	Rem
	bbdoc: Returns whether Tabbing between gadgets is on or off.
	End Rem
	Function GetTabbing:Int()
		Return Tabbing
	End Function
	Rem
	bbdoc: Sets whether or not the Tab key can move focus to the GUI if not gadgets have the focus.
	End Rem
	Function SetTabActive(bActive:Int = True)
		TabActive = bActive
	End Function
	Rem
	bbdoc: Returns whether the Tab key can move focus to the GUI when no gadgets have the focus.
	End Rem
	Function GetTabActive:Int()
		Return TabActive
	End Function
	Rem
	bbdoc: Sets the Font used for the Tips.
	End Rem
	Function SetTipFont(Font:TImageFont)
	 TipFont = Font
	End Function
	Rem
	bbdoc: Sets the default Text Color for all gadgets created after set.
	End Rem
	Function SetTextColor(R:Int, G:Int, B:Int) 'Sets the color of the Tip Box
		TextColor[0] = R
		TextColor[1] = G
		TextColor[2] = B
	End Function
	Rem
	bbdoc: Sets the Color used for the tip box.
	End Rem
	Function SetTipColor(R:Int, G:Int, B:Int) 'Sets the color of the Tip Box
		TipR = R
		TipG = G
		TipB = B
	End Function
	Rem
	bbdoc: Sets the alpha value for drawing the tip
	End Rem
	Function SetTipAlpha(fAlpha:Float)
		TipAlpha = fAlpha
	End Function
	Rem
	bbdoc: Returns the alpha value for drawing the tip
	End Rem
	Function GetTipAlpha:Float()
		Return TipAlpha
	End Function
	Rem
	bbdoc: Sets the color used for the border of the tip box.
	End Rem
	Function SetTipBorderColor(R:Int, G:Int, B:Int) 'Sets the color of the Tip Box Border
		TipBorderR = R
		TipBorderG = G
		TipBorderB = B
	End Function
	Rem
	bbdoc: Sets the color of the tip text.
	End Rem
	Function SetTipTextColor(R:Int, G:Int, B:Int) 'Sets the color of the Tip Box
		TipTextR = R
		TipTextG = G
		TipTextB = B
	End Function
	Rem
	bbdoc: Returns the next event from the queue and rmeoves it.
	End Rem
	Function GetEvent:ifsoGUI_Event()
		If Events.Count() < 1 Return Null
		Return ifsoGUI_Event(Events.RemoveFirst())
	End Function
	Rem
	bbdoc: Clears the event queue.
	End Rem
	Function ClearEvents()
		Events.Clear()
	End Function
	Rem
	bbdoc: Loads a theme.
	End Rem
	Function LoadTheme(path:String)
		ifsoGUI_Settings.PushSettings()
		ifsoGUI_Settings.InitSettings()
		ThemePath = path
		For Local i:Int = 0 To GadgetCallbacks.Length - 1
			GadgetCallbacks[i] (ifsoGUI_EVENT_SYSTEM_NEW_THEME, 0)
		Next
		Local f:TStream = ReadFile(FileHeader + path + "/graphics/cursors/dimensions.txt")
		Local i:Int = Int(f.ReadLine())
		If i < ifsoGUI_MOUSE_COUNT i = ifsoGUI_MOUSE_COUNT
		Mouse = New TImage[i]
		For Local i:Int = 0 To i - 1
			If f.Eof() Exit
			Local s:String[] = f.ReadLine().Split(",")
			If FileExists(path + "/graphics/cursors/" + s[0])
				Mouse[i] = LoadImage(FileHeader + path + "/graphics/cursors/" + s[0], MASKEDIMAGE | FILTEREDIMAGE)
				SetImageHandle(Mouse[i], Int(s[1]), Int(s[2]))
			End If
		Next
		f.Close()
		'All Controls now need to check their width and height
		For Local p:ifsoGUI_Base = EachIn Gadgets
			p.GadgetSystemEvent(ifsoGUI_EVENT_SYSTEM_NEW_THEME, 0)
		Next
		ifsoGUI_Settings.PopSettings()
	End Function
	Rem
	bbdoc: Adds a gadgets to the base GUI system.
	about: Normally this would be a panel, window, or other panel type gadget like a file selecter.
	But it can be any gadget, like a label, button, etc.
	End Rem
	Function AddGadget(p:ifsoGUI_Base)
		If p.OnTop
			Gadgets.AddFirst(p)
		Else
			Gadgets.AddLast(p)
		End If
		p.AddTabOrder()
	End Function
	Rem
	bbdoc: Removes a gadget from the base GUI system.
	End Rem
	Function RemoveGadget(p:ifsoGUI_Base, bDestroy:Int = True)
		If gActiveGadget = p
			gActiveGadget = Null
		ElseIf p.IsMyChild(gActiveGadget)
			gActiveGadget = Null
		End If
		If gMouseOverGadget = p
			gMouseOverGadget = Null
		Else
			If p.IsMyChild(gMouseOverGadget)
				gMouseOverGadget = Null
			End If
		End If
		p.RemoveTabOrder()
		Gadgets.Remove(p)
		If bDestroy p.Destroy()
	End Function
	Rem
	bbdoc: Gets a gadget by name.
	End Rem
	Function GetGadget:ifsoGUI_Base(name:String)
		Local g:ifsoGUI_Base
		For Local p:ifsoGUI_Base = EachIn Gadgets
			If p.name.ToLower() = name.ToLower() Return p
			g = p.GetChild(name)
			If g Return g
		Next
		Return Null
	End Function
	Rem
	bbdoc: Returns the ActiveGadget.
	End Rem
	Function GetActiveGadget:ifsoGUI_Base()
		Return gActiveGadget
	End Function
	Rem
	bbdoc: Informs the GUI system of the resolution of the graphics window.
	End Rem
	Function SetResolution(Width:Int, Height:Int)
		EnablePolledInput()
		iWidth = Width
		iHeight = Height
		If iWidth <> VirtualResolutionWidth() Or iHeight <> VirtualResolutionHeight() bUseVR = False
		ifsoGUI_VP.vpW = Width;ifsoGUI_VP.vpH = Height
	End Function
	Rem
	bbdoc: Sets whther or not the GUI system is reponsible for drawing the mouse.
	End Rem
	Function SetDrawMouse(bValue:Int)
		bDrawMouse = bValue
		If bValue
			HideMouse()
		Else
			ShowMouse()
		End If
	End Function
	Rem
	bbdoc: Returns whether the GUI system is drawing the mouse or not.
	End Rem
	Function GetDrawMouse:Int()
		Return bDrawMouse
	End Function
	Rem
	bbdoc: Sets whether the gadgets are generating events or not.
	about: One reason to turn this off is if you are using the gadget callbacks.
	But you may use both callbacks and the event system.
	End Rem
	Function SetUseEvents(bEvents:Int)
		UseEvents = bEvents
	End Function
	Rem
	bbdoc: Returns whether the event system is in use or not.
	End Rem
	Function GetUseEvents:Int()
		Return UseEvents
	End Function
	Rem
	bbdoc: Creates the header for file reading.
	End Rem
	Function CreateFileHeader()
		FileHeader = ZipHeader + IncbinHeader + ZipFile
	End Function
	Rem
	bbdoc: Sets whether or not we are loading files with incbin.
	But you may use both callbacks and the event system.
	End Rem
	Function SetUseIncBin(bIncBin:Int)
		If bIncBin
			IncbinHeader = "incbin::"
		Else
			IncbinHeader = ""
		End If
		If ZipPassword <> "" SetZipStreamPassword(IncbinHeader + ZipFile[..ZipFile.Length - 2], ZipPassword)
		CreateFileHeader()
	End Function
	Rem
	bbdoc: Returns whether or not files are loaded with incbin.
	End Rem
	Function GetUseIncBin:Int()
		If IncbinHeader = "incbin::" Return True
		Return False
	End Function
	Rem
	bbdoc: Sets whether or not we are loading files from a zip file.  If you use a password and incbin, you must call SetUseIncBin before calling SetZipInfo.
	But you may use both callbacks and the event system.
	End Rem
	Function SetZipInfo(strFileName:String, strPassword:String)
		If strFileName = ""
			ZipFile = ""
			ZipHeader = ""
			ZipPassword = ""
		Else
			ZipFile = strFileName + "//"
			ZipPassword = strPassword
			If ZipPassword <> "" SetZipStreamPassword(IncbinHeader + ZipFile[..ZipFile.Length - 2], ZipPassword)
			ZipHeader = "zip::"
		End If
		CreateFileHeader()
	End Function
	Rem
	bbdoc: Brings the gadget on the base GUI system to the front.
	End Rem
	Function BringToFront(gadget:ifsoGUI_Base)
		Gadgets.Remove(gadget)
		If gadget.OnTop
			Gadgets.AddFirst(gadget)
		Else
			Local lnk:TLink = Gadgets.FirstLink()
			Repeat
				If Not lnk
					Gadgets.AddLast(gadget)
					Exit
				ElseIf Not ifsoGUI_Base(lnk.Value()).OnTop
					Gadgets.InsertBeforeLink(gadget, lnk)
					Exit
				End If
				lnk = lnk.NextLink()
			Forever
		End If
	End Function
	Rem
	bbdoc: Sets the color for all gadgets.
	End Rem
	Function SetAllGadgetsColor(iRed:Int, iGreen:Int, iBlue:Int)
		Local NewColor:Int
		NewColor = iRed Shl 16 + iGreen Shl 8 + iBlue
		For Local p:ifsoGUI_Base = EachIn Gadgets
			p.GadgetSystemEvent(ifsoGUI_EVENT_SYSTEM_NEW_GADGET_COLOR, NewColor)
		Next
	End Function
	Rem
	bbdoc: Sets the text color for all gadgets.
	End Rem
	Function SetAllGadgetsTextColor(iRed:Int, iGreen:Int, iBlue:Int)
		Local NewColor:Int
		NewColor = iRed Shl 16 + iGreen Shl 8 + iBlue
		For Local p:ifsoGUI_Base = EachIn Gadgets
			p.GadgetSystemEvent(ifsoGUI_EVENT_SYSTEM_NEW_GADGET_TEXTCOLOR, NewColor)
		Next
	End Function
	Rem
	bbdoc: Changes a gadgets TabOrder
	End Rem
	Function ChangeTabOrder(g:ifsoGUI_Base)
		If g.TabOrder = -2 Return
		RemoveTabOrder(g)
		If g.TabOrder = -1
			If Tabs.IsEmpty()
				g.TabOrder = 1
			Else
				g.TabOrder = ifsoGUI_Base(Tabs.Last()).TabOrder + 1
			End If
			Tabs.AddLast(g)
			Return
		End If
		For Local gadget:ifsoGUI_Base = EachIn Tabs
			If gadget.TabOrder >= g.TabOrder gadget.TabOrder:+1
		Next
		Tabs.AddFirst(g)
		Tabs.Sort(True, CompareTabOrder)
	End Function
	Rem
	bbdoc: Removes a gadget from the TabOrder list
	End Rem
	Function RemoveTabOrder(g:ifsoGUI_Base)
		If Tabs.Contains(g)
			Local t:Int = g.TabOrder
			Tabs.Remove(g)
			If t < 1 Return
			For Local gadget:ifsoGUI_Base = EachIn Tabs
				If gadget.TabOrder > t gadget.TabOrder:-1
			Next
		End If
	End Function
	Rem
	bbdoc: Compares two gadgets by TabOrder.
	Internal function should not be called by the user.
	End Rem
	Function CompareTabOrder:Int(meObject:Object, withObject:Object)
		If ifsoGUI_Base(withObject).TabOrder = ifsoGUI_Base(meObject).TabOrder Return 0
		If ifsoGUI_Base(meObject).TabOrder >= ifsoGUI_Base(withObject).TabOrder Return 1
		Return - 1
	End Function
End Type

Rem
bbdoc:
End Rem
Type ifsoGUI_Settings
	Global Sets:TList = New TList 'History of settings

	'Settings to remember and reset
	Field iColor:Int[3]
	Field iAlpha:Float
	Field fRotation:Float
	Field fOrigin:Float[2]
	Field iBlend:Int
	Field iViewport:Int[4]
	Field Font:TImageFont
	Field fScale:Float[2]
	Field iLineWidth:Int
	Field fHandle:Float[2]
	Field VRWidth:Int, VRHeight:Int

	Rem
	bbdoc: Saves all of the graphics settings so they can be recalled.
	about: Internal function should not be called by the user.
	End Rem
	Function PushSettings()
		Local set:ifsoGUI_Settings = New ifsoGUI_Settings
		GetColor(set.iColor[0], set.iColor[1], set.iColor[2])
		set.iAlpha = GetAlpha()
		set.fRotation = GetRotation()
		GetOrigin(set.fOrigin[0], set.fOrigin[1])
		set.iBlend = GetBlend()
		set.Font = GetImageFont()
		GetScale(set.fScale[0], set.fScale[1])
		set.iLineWidth = GetLineWidth()
'		GetViewport(set.iViewport[0], set.iViewport[1], set.iViewport[2], set.iViewport[3])
'		If Not GUI.bUseVR
'			set.VRWidth = VirtualResolutionWidth()
'			set.VRHeight = VirtualResolutionHeight()
'		End If
		GetHandle(set.fHandle[0], set.fHandle[1])
		ifsoGUI_VP.Push()
		Sets.AddFirst(set)
	End Function
	Rem
	bbdoc: Recalls the graphics settings.
	about: Internal function should not be called by the user.
	End Rem
	Function PopSettings()
		Local set:ifsoGUI_Settings = ifsoGUI_Settings(Sets.RemoveFirst())
		SetColor(set.iColor[0], set.iColor[1], set.iColor[2])
		SetAlpha(set.iAlpha)
		SetRotation(set.fRotation)
		SetOrigin(set.fOrigin[0], set.fOrigin[1])
		SetBlend(set.iBlend)
		SetImageFont(set.Font)
		SetScale(set.fScale[0], set.fScale[1])
		SetLineWidth(set.iLineWidth)
		SetHandle(set.fHandle[0], set.fHandle[1])
'		SetViewport(set.iViewport[0], set.iViewport[1], set.iViewport[2], set.iViewport[3])
'		If Not GUI.bUseVR SetVirtualResolution(set.VRWidth, set.VRHeight)
		ifsoGUI_VP.Pop()
	End Function
	Rem
	bbdoc: Inits the settings to what ifsoGUI needs.
	about: Internal function should not be called by the user.
	End Rem
	Function InitSettings()
		SetRotation(0)
		SetOrigin(0, 0)
		SetBlend(ALPHABLEND)
		SetImageFont(GUI.DefaultFont)
		SetScale(1, 1)
		SetHandle(0, 0)
'		SetViewport(0, 0, GUI.iWidth, GUI.iHeight)
'		If Not GUI.bUseVR SetVirtualResolution(GUI.iWidth, GUI.iHeight)
	End Function
End Type
Rem
	bbdoc: ViewPort system to create more and more restrictive viewports as gadgets are recursivley accessed.<br>
								And a set of drawing routines that are restricted by the viewport.
End Rem
Type ifsoGUI_VP
	Field x:Int, y:Int, w:Int, h:Int 'This individual viewport
	Global VPs:TList = New TList 'History of viewports
	Global vpX:Int, vpY:Int, vpW:Int, vpH:Int 'Current ViewPort
	Global bUseCustomFont:Int 'Using a custom font system
	Global bCanDrawPartial:Int 'Can the custom font draw partial characters?
	Global CustDrawText(strText:String, x:Float, y:Float, gadget:ifsoGUI_Base) 'callback function for DrawText.
	Global CustTextWidth:Int(strText:String, gadget:ifsoGUI_Base) 'callback function for TextWidth
	Global CustTextHeight:Int(gadget:ifsoGUI_Base) 'callback function for TextHeight
	
	Rem
	bbdoc: Pushes a viewport onto the queue.
	End Rem
	Function Push()
		Local vp:ifsoGUI_VP = New ifsoGUI_VP
		vp.x = vpX;vp.y = vpY;vp.w = vpW;vp.h = vpH
		VPs.AddFirst(vp)
	End Function
	Rem
	bbdoc: Pops a viewport off of the queue.
	End Rem
	Function Pop()
		Local vp:ifsoGUI_VP = ifsoGUI_VP(VPs.RemoveFirst())
		vpX = vp.x;vpY = vp.y;vpW = vp.w;vpH = vp.h
	End Function
	Rem
	bbdoc: Pushes a viewport onto the queue in add mode.
	about: The viewport being pushed onto the queue cannot be less restrictive than the current viewport.
	End Rem
	Function Add(iX:Int, iY:Int, iW:Int, iH:Int)
		Local vp:ifsoGUI_VP = New ifsoGUI_VP
		vp.x = vpX;vp.y = vpY;vp.w = vpW;vp.h = vpH
		VPs.AddFirst(vp)
		If iX < vp.x
		 iW:-(vp.x - iX)
			iX = vp.X
		End If
		If iY < vp.y
			iH:-(vp.y - iY)
		 iY = vp.y
		End If
		If iX + iW > vp.x + vp.w iW:-((iX + iW) - (vp.x + vp.w))
		If iY + iH > vp.y + vp.h iH:-((iy + iH) - (vp.y + vp.h))
		vpX = iX;vpY = iY;vpW = iW;vpH = iH
	End Function
	
Rem
	bbdoc: Draws an image restricted to the area of the viewport.<br>
	image: handle of the image you want to draw<br>
	x , y: Position at which you want to draw the imagerect<br>
End Rem
	Function DrawImageArea(image:TImage, x:Float, y:Float)
		If vpW <= 0 Or vpH <= 0 Return
		If x + image.width < vpX Return
		If y + image.height < vpY Return
		If x > vpX + vpW Return
		If y > vpY + vpH Return
		Local sw:Float = image.width, sh:Float = image.height, sx:Float, sy:Float
		If x + sw > vpX + vpW
			sw = (vpX + vpW) - x
		End If
		If y + sh > vpY + vpH
			sh = (vpY + vpH) - y
		End If
		If x < vpX
			sw = sw - (vpX - x)
			sx = vpX - x
			x = vpX
		End If
		If y < vpY
			sh = sh - (vpY - y)
			sy = vpY - y
			y = vpY
		End If
		DrawSubImageRect(image, x, y, sw, sh, sx, sy, sw, sh)
	End Function

	Function DrawImageArea2(image:ifsoGUI_Image, x:Float, y:Float, imgIndex:Int)
		If vpW <= 0 Or vpH <= 0 Return
		Local imgW:Int = image.w[imgIndex], imgH:Int = image.h[imgIndex], imgX:Int = image.x[imgIndex], imgY:Int = image.y[imgIndex]
		If x + imgW < vpX Return
		If y + imgH < vpY Return
		If x > vpX + vpW Return
		If y > vpY + vpH Return
		Local sw:Float = imgW, sh:Float = imgH, sx:Float, sy:Float
		If x + imgW > vpX + vpW
			sw = (vpX + vpW) - x
		End If
		If y + imgH > vpY + vpH
			sh = (vpY + vpH) - y
		End If
		If x < vpX
			sw = sw - (vpX - x)
			sx = vpX - x
			x = vpX
		End If
		If y < vpY
			sh = sh - (vpY - y)
			sy = vpY - y
			y = vpY
		End If
		DrawSubImageRect(image.img, x, y, sw, sh, sx + imgX, sy + imgY, sw, sh)
	End Function

Rem
	bbdoc:Draws an image stretched and restricted to the area of the viewport.<br>
	image: handle of the image you want to draw<br>
	x , y: Position at which you want to draw the imagerect<br>
	w , h: Width and Height the image will be drawn.<br>
End Rem
	Function DrawImageAreaRect(image:TImage, x:Float, y:Float, w:Float, h:Float)
		If vpW <= 0 Or vpH <= 0 Return
		If x + w < vpX Return
		If y + h < vpY Return
		If x > vpX + vpW Return
		If y > vpY + vpH Return
		Local sx:Float, sy:Float, sw:Float = image.width, sh:Float = image.height
		Local ew:Float = w, eh:Float = h
		If x + w > vpX + vpW
			ew = (vpX + vpW) - x
			sw = (ew / w) * image.width
		End If
		If y + h > vpY + vpH
			eh = (vpY + vpH) - y
			sh = (eh / h) * image.height
		End If
		If x < vpX
			ew = ew - (vpX - x)
			sx = ((vpX - x) / w) * image.width
			sw = sw - sx
			x = vpX
		End If
		If y < vpY
			eh = eh - (vpY - y)
			sy = ((vpY - y) / h) * image.height
			sh = sh - sy
			y = vpY
		End If
		DrawSubImageRect(image, x, y, ew, eh, sx, sy, sw, sh)
	End Function

	Function DrawImageAreaRect2(image:ifsoGUI_Image, x:Float, y:Float, w:Float, h:Float, imgIndex:Int)
		If vpW <= 0 Or vpH <= 0 Return
		If x + w < vpX Return
		If y + h < vpY Return
		If x > vpX + vpW Return
		If y > vpY + vpH Return
		Local imgW:Int = image.w[imgIndex], imgH:Int = image.h[imgIndex], imgX:Int = image.x[imgIndex], imgY:Int = image.y[imgIndex]
		Local sx:Int, sy:Int
		Local sw:Float = imgW, sh:Float = imgH
		Local ew:Float = w, eh:Float = h
		If x + w > vpX + vpW
			ew = (vpX + vpW) - x
			sw = (ew / w) * imgW
		End If
		If y + h > vpY + vpH
			eh = (vpY + vpH) - y
			sh = (eh / h) * imgH
		End If
		If x < vpX
			ew = ew - (vpX - x)
			sx = ((vpX - x) / w) * imgW
			sw = sw - sx
			x = vpX
		End If
		If y < vpY
			eh = eh - (vpY - y)
			sy = ((vpY - y) / h) * imgH
			sh = sh - sy
			y = vpY
		End If
		DrawSubImageRect(image.img, x, y, ew, eh, sx + imgX, sy + imgY, sw, sh)
	End Function

Rem
	bbdoc: Draws text restricted to the area of the viewport.
End Rem
	Function DrawTextArea(Text:String, x:Float, y:Float, gadget:ifsoGUI_Base = Null)
		If vpW <= 0 Or vpH <= 0 Return
		If y > vpY + vpH Return
		'Check if using CustomFonts
		If bUseCustomFont
			If Not bCanDrawPartial 'Can they draw partial characters
				If CustTextHeight(gadget) + y > vpY + vpH Return 'Is the text to tall for the viewport?
				'Check for too far left
				Local tmpX:Float = x
				Repeat
					If tmpX < vpX
						tmpX:+CustTextWidth(Chr(Text[0]), gadget)
						If Text.Length <= 1 Return
						Text = Text[1..]
					Else
						x = tmpX
						Exit
					End If
				Forever
				'Check for too long
				For Local i:Int = Text.Length - 1 To 0 Step - 1
					If CustTextWidth(Text, gadget) + x < vpX + vpW Exit 'Will the text fit
					Text = Text[..Text.length - 1] 'if not, remove a character
				Next
				If Text.Length < 1 Return 'no charactres left, return.
			End If
			CustDrawText(Text, x, y, gadget) 'Call the users DrawText function
			Return
		End If
		Local font:TImageFont = GetImageFont()
		Local tx:Float, ty:Float
		For Local i:Int = 0 Until Text.length
			Local n:Int = font.CharToGlyph(Text[i])
			If n < 0 Continue
			Local glyph:TImageGlyph = font.LoadGlyph(n)
			Local image:TImage=glyph._image
			If image
				tx = glyph._x
				ty = glyph._y
				If x + tx > vpX + vpW Return 'Char is to the right of the VP
				If x + tx + image.width < vpX 'Char is to the left of the VP
					x:+glyph._advance
				 Continue
				End If
				If y + ty + image.height < vpY 'Char is above the VP
					x:+glyph._advance
				 Continue
				End If
				DrawImageArea(image, x + tx, y + ty)
			End If
			x:+glyph._advance
		Next
	End Function
	Rem
	bbdoc:Returns the width of the text.
	End Rem
	Function GetTextWidth:Int(strText:String, gadget:ifsoGUI_Base = Null)
		If bUseCustomFont
			Return CustTextWidth(strText, gadget)
		Else
			Return TextWidth(strText)
		End If
	End Function
	Rem
	bbdoc:Returns the height of the text.
	End Rem
	Function GetTextHeight:Int(gadget:ifsoGUI_Base = Null)
		If bUseCustomFont
			Return CustTextHeight(gadget)
		Else
			Return TextHeight("")
		End If
	End Function
Rem
	bbdoc: Draws a rectangle restricted to the area of the view port.
End Rem
	Function DrawRect(x:Float, y:Float, width:Float, height:Float)
		If vpW <= 0 Or vpH <= 0 Return
		If x + width < vpX Return
		If y + height < vpY Return
		If x < vpX
			width:-(vpX - x)
			x = vpX
		End If
		If y < vpY
			height:-(vpY - y)
			y = vpY
		End If
		If x + width > vpW + vpX
			width = ((vpX + vpW) - x)
		End If
		If y + height > vpY + vpH
			height = ((vpY + vpH) - y)
		End If
		_max2dDriver.DrawRect (0, 0, width, height, x, y)
	End Function

Rem
	bbdoc: Draws a line restricted to the area of the viewport. Line should be horizontal or vertical.
End Rem
	Function DrawLine(x:Float, y:Float, x2:Float, y2:Float, LastPixel:Int = True)
		If vpW <= 0 Or vpH <= 0 Return
		If x2 < vpX Return
		If y2 < vpY Return
		If x > vpX + vpW Return
		If y > vpY + vpH Return
		If x < vpX x = vpX
		If y < vpY y = vpY
		If x2 > vpX + vpW x2 = vpX + vpW
		If y2 > vpY + vpH y2 = vpY + vpH
	_max2dDriver.DrawLine (0, 0, x2 - x, y2 - y, x, y)
	If Not LastPixel Return
	_max2dDriver.Plot (x2, y2)
End Function

End Type

Rem
	bbdoc: Rotates the input image 90 degrees clockwise and returns the new image.
End Rem
Function RotateImage:TImage(image:TImage)
	'Need a pixmap of the image
	Local mainmap:TPixmap = LockImage(image)
	'The output image
	Local gImage:TImage
	
	'create the image
	gImage = CreateImage(image.height, image.width)
	Local pixmap:TPixmap = LockImage(gImage)
		
	'copy the pixels
	Local srcx:Int, srcy:Int, destx:Int, desty:Int
	For srcy = image.height - 1 To 0 Step - 1
		For srcx = 0 To image.width - 1
			WritePixel(pixmap, destx, desty, ReadPixel(mainmap, srcx, srcy))
			desty:+1
			If desty = image.width desty = 0
		Next
		destx:+1
		If destx = image.height destx = 0
	Next

	'unlock image
	UnlockImage(gImage)
	SetImageHandle(gImage, 0, 0)
	UnlockImage(image)
	Return gImage
End Function

Type ifsoGUI_Image
	Field img:TImage
	Field x:Int[9], y:Int[9], h:Int[9], w:Int[9]
End Type
