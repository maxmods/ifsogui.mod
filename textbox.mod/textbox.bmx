SuperStrict

Rem
	bbdoc: ifsoGUI Textbox
	about: Textbox Gadget
EndRem
Module ifsogui.textbox

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI

GUI.Register(ifsoGUI_TextBox.SystemEvent)

Rem
	bbdoc: Textbox Type
End Rem
Type ifsoGUI_TextBox Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image 'Images to draw the button
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	Field Value:String 'Text in the box
	Field WasValue:String 'Value before start editting
	Field CursorPos:Int
	Field ShowStart:Int = 0, ShowEnd:Int 'Start and end of characters visible in the control
	Field CursorWidth:Int = 1 'Width of the cursor
	Field CursorHeight:Int 'Height of the Cursor
	Field ReadOnly:Int = False
	Field ShowBorder:Int = True
	Field BorderTop:Int, BorderBottom:Int, BorderLeft:Int, BorderRight:Int 'Border dimensions
	Field BlinkRate:Int = 500 'Millisecs the cursor will be on or off.
	Field LastBlink:Int 'For blink timing
	Field Filter:Int(key:Int, gadget:ifsoGUI_Base) ' User Definable function that allows the user to control whether a keypress is accepted or not.
	Field SelectBegin:Int ' Char pos of the beginning of the selection.
	Field SelectColor:Int[] = [120, 120, 255]
	Field LastMouseClick:Int 'For Double click detection
	'Added by zeke
	Field IsPassword:Int
	Field PasswordChar:String = "*" 'default password character
	
	'Events
	'Mouse Enter/Mouse Exit/Change
	
	Rem
		bbdoc: Create and returns a textbox gadget.
	End Rem
	Function Create:ifsoGUI_TextBox(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, strText:String = "")
		Local p:ifsoGUI_TextBox = New ifsoGUI_TextBox
		p.LastMouseClick = MilliSecs() - ifsoGUI_DOUBLE_CLICK_DELAY
		p.x = iX
		p.y = iY
		p.w = iW
		p.h = iH
		p.lImage = gImage
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.Name = strName
		p.Value = strText
		p.ShowEnd = strText.Length
		p.SetFont(Null)
		For Local i:Int = 0 To 2
			p.TextColor[i] = GUI.TextColor[i]
		Next
		Return p
	End Function
	Rem
	bbdoc: Returns the selected text and removes it from the gadget.
	End Rem
	Method CutSelection:String()
		Local sTmp:String
		If SelectBegin > CursorPos
			sTmp = Value[CursorPos..SelectBegin]
		ElseIf SelectBegin < CursorPos
			sTmp = Value[SelectBegin..CursorPos]
		End If
		RemoveText()
		Return sTmp
	End Method
	Rem
		bbdoc: Draws the gadget.
		about: Internal function should not be called by the user.
	End Rem
	Method Draw(parX:Int, parY:Int, parW:Int, parH:Int)
		If Not Visible Return
		If x > parW Or y > parH Return
		'Added by Zeke
		Local Value:String = Self.Value
		If IsPassword Then
			Local pass:String
			For Local i:Int = 0 Until Value.Length
				pass:+PasswordChar
			Next
			Value = pass
		End If
		SetColor(Color[0], Color[1], Color[2])
		SetAlpha(fAlpha)
		'set up rendering locations
		Local rX:Int = parX + x
		Local rY:Int = parY + y
		'Draw the frame and back
		DrawBox2(lImage, rX, rY, w, h, ShowBorder, lTileSides, lTileCenter)
		ifsoGUI_VP.Add(rX + BorderLeft, rY + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
		'Draw the selection box
		If SelectBegin <> CursorPos
			SetColor(SelectColor[0], SelectColor[1], SelectColor[2])
			Local beginx:Int, selectw:Int
			If CursorPos > SelectBegin
				selectw = ifsoGUI_VP.GetTextWidth(Value[SelectBegin..CursorPos])
				If SelectBegin > ShowStart beginx = ifsoGUI_VP.GetTextWidth(Value[ShowStart..SelectBegin])
			Else
				selectw = ifsoGUI_VP.GetTextWidth(Value[CursorPos..SelectBegin])
				beginx = ifsoGUI_VP.GetTextWidth(Value[ShowStart..CursorPos])
			End If
			ifsoGUI_VP.DrawRect(rX + beginx + BorderLeft + 1, rY + BorderTop, selectw, h - (BorderTop + BorderBottom))
		End If
		'Draw the text
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		If fFont SetImageFont(fFont)
		Local offset:Int = (h - (BorderTop + BorderBottom + ifsoGUI_VP.GetTextHeight(Self))) / 2
		If ShowEnd > ShowStart ifsoGUI_VP.DrawTextArea(Value[ShowStart..], rX + BorderLeft + 1, rY + borderTop + offset, Self)
		'Draw the Cursor
		If HasFocus And (Not ReadOnly)
		 If BlinkRate = 0
				Local oldwidth:Int = GetLineWidth()
				SetLineWidth(CursorWidth)
				Local tw:Int = ifsoGUI_VP.GetTextWidth(Value[ShowStart..CursorPos], Self)
				ifsoGUI_VP.DrawLine(rX + BorderLeft + 1 + tw, ry + BorderTop + 1, rX + BorderLeft + 1 + tw, ry + BorderTop + 1 + CursorHeight)
				SetLineWidth(oldwidth)
			Else
				Local tmpBlink:Int = MilliSecs()
				If tmpBlink - LastBlink > (BlinkRate * 2) LastBlink = tmpBlink
				If tmpBlink - LastBlink < BlinkRate
					Local oldwidth:Int = GetLineWidth()
					SetLineWidth(CursorWidth)
					Local tw:Int = ifsoGUI_VP.GetTextWidth(Value[ShowStart..CursorPos], Self)
					ifsoGUI_VP.DrawLine(rX + BorderLeft + 1 + tw, ry + BorderTop + 1, rX + BorderLeft + 1 + tw, ry + BorderTop + 1 + CursorHeight)
					SetLineWidth(oldwidth)
				End If
			End If
		End If
		ifsoGUI_VP.Pop()
		If fFont SetImageFont(GUI.DefaultFont)
	End Method
	Rem
	bbdoc: Inserts text at the cursor position.
	End Rem
	Method InsertText(strText:String)
		RemoveText()
		Value = Value[..CursorPos] + strText + Value[CursorPos..]
		CursorPos:+strText.Length
		SelectBegin = CursorPos
		ShowChars()
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not (Visible And Enabled) Return
		bPressed = iButton
	 GUI.SetActiveGadget(Self)
		Local iX:Int, iY:Int
		GetAbsoluteXY(iX, iY)
		If iMouseX > iX + BorderLeft + 1
			If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
				If fFont SetImageFont(fFont)
				Local tw:Int = ifsoGUI_VP.GetTextWidth(Value[ShowStart..ShowEnd], Self)
				Local Count:Int = 0
				While iMouseX < (tw + iX + BorderLeft + 1)
					Count:+1
					tw = ifsoGUI_VP.GetTextWidth(Value[ShowStart..ShowEnd - Count], Self)
				Wend
				CursorPos = ShowEnd - Count
				Local cw:Int = ifsoGUI_VP.GetTextWidth(Value[CursorPos..CursorPos + 1], Self) / 2
				tw = ifsoGUI_VP.GetTextWidth(Value[..CursorPos], Self)
				If iMouseX > tw + iX + BorderLeft + 1 + cw CursorPos:+1
				If CursorPos > Value.Length CursorPos = Value.Length
				SelectBegin = CursorPos
				If fFont SetImageFont(GUI.DefaultFont)
			End If
		Else
			CursorPos = 0
			SelectBegin = 0
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		If Not (Enabled And Visible) Return
		If GUI.gMouseOverGadget = Self
			If bPressed = ifsoGUI_LEFT_MOUSE_BUTTON
				If MilliSecs() - LastMouseClick < ifsoGUI_DOUBLE_CLICK_DELAY
					Local i:Int
					For i = CursorPos To Value.Length - 1
						If (Value[i] < 48) Or (Value[i] > 57 And Value[i] < 65) Or (Value[i] > 90 And Value[i] < 97) Or (Value[i] > 122)							Exit
					Next
					CursorPos = i
					For i = CursorPos - 1 To 0 Step - 1
						If (Value[i] < 48) Or (Value[i] > 57 And Value[i] < 65) Or (Value[i] > 90 And Value[i] < 97) Or (Value[i] > 122) Exit
					Next
					SelectBegin = i + 1
					If SelectBegin = CursorPos
						If SelectBegin > 0
							SelectBegin:-1
						ElseIf CursorPos < Value.Length
							CursorPos:+1
						End If
					End If
				End If
			End If
			LastMouseClick = MilliSecs()
			bPressed = False
			SendEvent(iButton, CursorPos, iMouseX, iMouseY)
		End If
		bPressed = False
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
		If ReadOnly Return
		LastBlink = MilliSecs()
		If KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL)
			If key = 3
				SendEvent(ifsoGUI_EVENT_COPY, 0, 0, 0)
			ElseIf key = 24
				SendEvent(ifsoGUI_EVENT_CUT, 0, 0, 0)
			ElseIf key = 22
				SendEvent(ifsoGUI_EVENT_PASTE, 0, 0, 0)
			End If
		 Return
		End If
		If KeyDown(KEY_LALT) Or KeyDown(KEY_RALT) Return
		If key = 8 'BackSpace
			If Selectbegin <> CursorPos
				RemoveText()
			ElseIf CursorPos > 0
				Value = Value[..CursorPos - 1] + Value[CursorPos..]
				CursorPos:-1
				SelectBegin = CursorPos
			End If
		Else If key = 13 Or key = 27 'Carriage Return or Escape
			SelectBegin = CursorPos
			GUI.SetActiveGadget(Null)
		Else If (key = ifsoGUI_KEY_DELETE) 'Delete
			If SelectBegin <> CursorPos
				RemoveText()
			ElseIf CursorPos < Value.Length
				Value = Value[..CursorPos] + Value[CursorPos + 1..]
			End If
		Else If (key = ifsoGUI_KEY_LEFT) 'Cursor Left
			If CursorPos > 0 CursorPos:-1
			If (Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))) SelectBegin = CursorPos
		Else If (key = ifsoGUI_KEY_RIGHT) 'Cursor Right
			If CursorPos < Value.Length CursorPos:+1
			If (Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))) SelectBegin = CursorPos
		Else If (key = ifsoGUI_KEY_HOME) 'Home
			CursorPos = 0
			If (Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))) SelectBegin = CursorPos
		Else If (key = ifsoGUI_KEY_END) 'End
			CursorPos = Value.Length
			If (Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))) SelectBegin = CursorPos
		Else
			If Not ReadOnly
				If Filter
					If Not Filter(key, Self) Return
				End If
				If Selectbegin <> CursorPos
					RemoveText()
				End If
				Value = Value[..CursorPos] + Chr(key) + Value[CursorPos..]
				CursorPos:+1
				SelectBegin = CursorPos
			End If
		End If
		SendEvent(ifsoGUI_EVENT_KEYHIT, Key, 0, 0)
		ShowChars()
	End Method
	Rem
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget only.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If bPressed = ifsoGUI_LEFT_MOUSE_BUTTON
			Local iX:Int, iY:Int
			GetAbsoluteXY(iX, iY)
			Local tw:Int = ifsoGUI_VP.GetTextWidth(Value[ShowStart..ShowEnd], Self)
			Local Count:Int = 0
			While (iMouseX < (tw + iX + BorderLeft + 1)) And (ShowEnd - Count >= ShowStart)
				Count:+1
				tw = ifsoGUI_VP.GetTextWidth(Value[ShowStart..ShowEnd - Count], Self)
			Wend
			CursorPos = ShowEnd - Count
			If CursorPos < 0 CursorPos = 0
			Local cw:Int = ifsoGUI_VP.GetTextWidth(Value[CursorPos..CursorPos + 1], Self) / 2
			tw = ifsoGUI_VP.GetTextWidth(Value[..CursorPos], Self)
			If iMouseX > tw + iX + BorderLeft + 1 + cw CursorPos:+1
			If CursorPos > Value.Length CursorPos = Value.Length
		End If
		If Enabled And Visible And Not ReadOnly
			If bPressed Return ifsoGUI_MOUSE_IBAR
			If GUI.gMouseOverGadget = Self Return ifsoGUI_MOUSE_IBAR
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
		Local tfnt:TImageFont = GetImageFont()
		If fFont
			SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		CursorHeight = ifsoGUI_VP.GetTextHeight(Self)
		SetImageFont(tfnt)
		If w < BorderLeft + BorderRight w = BorderLeft + BorderRight
		If h < BorderTop + BorderBottom + CursorHeight + 2 h = BorderTop + BorderBottom + CursorHeight + 2
		ShowChars()
	End Method
	Rem
	bbdoc: Removes the selected text.
	about: Internal function should not be called by the user.
	End Rem
	Method RemoveText()
		If SelectBegin > CursorPos
			Value = Value[..CursorPos] + Value[SelectBegin..]
			SelectBegin = CursorPos
		ElseIf SelectBegin < CursorPos
			Value = Value[..SelectBegin] + Value[CursorPos..]
			CursorPos = SelectBegin
		End If
		ShowChars()
	End Method
	Rem
	bbdoc: Makes sure the correct characters and cursor are shown.
	about: Internal function should not be called by the user.
	End Rem
	Method ShowChars()
		If CursorPos < ShowStart ShowStart = CursorPos
		If ShowEnd > Value.Length ShowEnd = Value.Length
		If CursorPos > Value.Length CursorPos = Value.Length
		If SelectBegin > Value.Length SelectBegin = Value.Length
		If CursorPos > ShowEnd ShowEnd = CursorPos
		Local imax:Int = W - (BorderLeft + BorderRight + 2)
		If imax < 0 imax = 0
		Local wasFont:TImageFont = GetImageFont()
		If fFont
			SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		'Added by Zeke Password chars
		Local Value:String = Self.Value
		If IsPassword Then
			Local pass:String
			For Local i:Int = 0 Until Value.Length
				pass:+PasswordChar
			Next
			Value = pass
		End If
		Local i:Int = ifsoGUI_VP.GetTextWidth(Value[ShowStart..ShowEnd], Self)
		If i < imax
			Local WasEnd:Int = ShowEnd, WasStart:Int = ShowStart
			While i < imax
				ShowStart = WasStart
				ShowEnd = WasEnd
				If WasStart = 0 And WasEnd = Value.Length Exit
				If WasEnd < Value.Length
					WasEnd:+1
				Else
					WasStart:-1
				End If
				i = ifsoGUI_VP.GetTextWidth(Value[WasStart..WasEnd], Self)
			Wend
		ElseIf i > imax
			While i > imax
				If ShowEnd > CursorPos
					ShowEnd:-1
				Else
					ShowStart:+1
				End If
				If ShowStart = ShowEnd Exit
				i = ifsoGUI_VP.GetTextWidth(Value[ShowStart..ShowEnd], Self)
			WEnd
		End If
		If wasFont SetImageFont(wasFont)
	End Method
	Rem
	bbdoc: Called when the gadget becomes the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method GainFocus(LostFocus:ifsoGUI_Base)  'Gadget Got focus
		LastBlink = MilliSecs()
		HasFocus = True
		WasValue = Value
		SendEvent(ifsoGUI_EVENT_GAIN_FOCUS, 0, 0, 0)
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("textbox", strSkin).Split(",")
		Load9Image2("/graphics/textbox.png", dimensions, lImage, strSkin)
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
	Method LostFocus(GainedFocus:ifsoGUI_Base)
		If WasValue <> Value SendEvent(ifsoGUI_EVENT_CHANGE, 0, 0, 0)
		HasFocus = False
		bPressed = False
		SendEvent(ifsoGUI_EVENT_LOST_FOCUS, 0, 0, 0)
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("textbox").Split(",")
		Load9Image2("/graphics/textbox.png", dimensions, gImage)
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
	bbdoc: Sets the cursor blink rate in Millisecs.
	End Rem
	Method SetCursorBlinkRate(iBlinkRate:Int)
		BlinkRate = iBlinkRate
	End Method
	Rem
	bbdoc: Returns the cursor blink rate in millisecs.
	End Rem
	Method GetCursorBlinkRate:Int()
		Return BlinkRate
	End Method
	Rem
	bbdoc: Sets the cursor position within the text.
	End Rem
	Method SetCursorPosition(iPosition:Int)
		CursorPos = iPosition
		If CursorPos < ShowStart ShowStart = CursorPos
		ShowEnd = Value.length
		If CursorPos > Value.Length CursorPos = Value.Length
		SelectBegin = CursorPos
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the border is showing.
	End Rem
	Method GetCursorPosition:Int()
		Return CursorPos
	End Method
	Rem
	bbdoc: Returns the location of the selection beginning.
	End Rem
	Method GetSelectBegin:Int()
		Return SelectBegin
	End Method
	Rem
	bbdoc: Sets The Selection begining.
	End Rem
	Method SetSelectBegin(iBegin:Int)
		SelectBegin = iBegin
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
	bbdoc: Returns the selected text.
	End Rem
	Method GetSelection:String()
		If SelectBegin > CursorPos
			Return Value[CursorPos..SelectBegin]
		ElseIf SelectBegin < CursorPos
			Return Value[SelectBegin..CursorPos]
		End If
		Return ""
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
	bbdoc: Sets the text in the textbox.
	End Rem
	Method SetText(NewValue:String)
		Value = NewValue
		ShowStart = 0
		ShowEnd = Value.Length
		Refresh()
	End Method
	Rem
	bbdoc: Returns the text in the textbox.
	End Rem
	Method GetText:String()
		Return Value
	End Method
	Rem
	bbdoc: Sets the width of the cursor bar.
	End Rem
	Method SetCursorWidth(iCursorWidth:Int)
		CursorWidth = iCursorWidth
	End Method
	Rem
	bbdoc: Returns the width of the cursor bar.
	End Rem
	Method GetCursorWidth:Int()
		Return CursorWidth
	End Method
	Rem
	bbdoc: Sets a keypress filter.  This custom function should return True or False based on whether the key pressed should be allowed.
	End Rem
	Method SetFilter(funcFilter:Int(key:Int, gadget:ifsoGUI_Base))
		Filter = funcFilter
	End Method
	Rem
	bbdoc: Sets the gadget read only.
	End Rem
	Method SetReadOnly(bReadOnly:Int)
		ReadOnly = bReadOnly
	End Method
	Rem
	bbdoc: Returns whether the textbox is read only or not.
	End Rem
	Method GetReadOnly:Int()
		Return ReadOnly
	End Method
	'ADDED by Zeke
	Rem
	bbdoc: Set the textbox as a password textbox
	End Rem
	Method SetPassword(bPassword:Int)
		IsPassword = bPassword
	End Method
	Rem
	bbdoc: Get the textbox as a password textbox
	End Rem
	Method GetPassword:Int()
		Return IsPassword
	End Method
	Rem
	bbdoc: Set password character
	endrem
	Method SetPasswordChar(strChar:String)
		PasswordChar = strChar
	End Method
	Rem
	bbdoc: Get password character
	endrem
	Method GetPasswordChar:String()
		Return PasswordChar
	End Method

End Type
