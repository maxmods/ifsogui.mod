SuperStrict

Rem
	bbdoc: ifsoGUI Multi-Line Textbox
	about: Multi-Line Textbox Gadget
EndRem
Module ifsogui.mltextbox

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.scrollbar

GUI.Register(ifsoGUI_MLTextBox.SystemEvent)

Rem
	bbdoc: Multiline textbox Type
End Rem
Type ifsoGUI_MLTextBox Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the box
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image 'Images to draw the box
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	Field Lines:String[1] 'Start with one line
	Field TopLine:Int 'Line at the visible top of the list
	Field VisibleLines:Int 'Number of Lines visible in the list
	Field ClientWidth:Int 'Width of the drawable inside area
	Field LineHeight:Int 'Height of one item
	Field VScrollbar:Int = 2 'Show vertical scrollbar when list is to tall, 0-Never 1-Always 2-When needed
	Field VBarOn:Int 'Is the VBar on
	Field VBar:ifsoGUI_ScrollBar
	Field HScrollbar:Int = 2 'Show horizontal scrollbar when list is to wide, 0-Never 1-Always 2-When needed
	Field HBarOn:Int 'Is the HBar on
	Field HBar:ifsoGUI_ScrollBar
	Field ScrollBarWidth:Int = 20 'Width of the scrollbars
	Field CurrentLine:Int = 0 'Current line with the cursor
	Field CurPos:Int 'Current character position on the current line
	Field ShowBorder:Int = True
	Field BorderTop:Int, BorderBottom:Int, BorderLeft:Int, BorderRight:Int 'Border dimensions
	Field CursorWidth:Int = 1 'Width of the cursor
	Field CursorHeight:Int 'Height of the Cursor
	Field Changed:Int 'Set to true when the user makes a change
	Field WordWrap:Int = True 'Wordwrap on/off
	Field LongestLine:Int	'Track the longest line for scrollbars
	Field LongestValue:Int 'How long is the longest line
	Field ReadOnly:Int = False
	Field OriginX:Int 'Offset for the Horizontal Bar
	Field BlinkRate:Int = 500 'Cursor blink rate in millisecs
	Field LastBlink:Int 'For blink timing
	Field Filter:Int(key:Int, gadget:ifsoGUI_Base) ' User Definable function that allows the user to control whether a keypress is accepted or not.
	Field SelectBegin:Int
	Field SelectLine:Int
	Field SelectColor:Int[] = [120, 120, 255]
	Field LastMouseClick:Int 'For Double click detection

	'Events
	'Mouse Enter/Mouse Exit/Change
	
	Rem
		bbdoc: Create and returns a multiline textbox gadget.
	End Rem
	Function Create:ifsoGUI_MLTextBox(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_MLTextBox = New ifsoGUI_MLTextBox
		p.LastMouseClick = MilliSecs() - ifsoGUI_DOUBLE_CLICK_DELAY
		p.x = iX
		p.y = iY
		p.w = iW
		p.h = iH
		p.lImage = gImage
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.VBar = ifsoGUI_ScrollBar.Create(0, 0, p.ScrollBarWidth, iH, strName + "_vbar", True)
		p.VBar.SetVisible(False)
		p.VBar.Master = p
		p.VBar.SetMax(1)
		p.HBar = ifsoGUI_ScrollBar.Create(0, 0, iW, p.ScrollBarWidth, strName + "_hbar", False)
		p.HBar.SetVisible(False)
		p.HBar.Master = p
		p.HBar.SetMax(1)
		p.Slaves.AddLast(p.VBar)
		p.Slaves.AddLast(p.HBar)
		p.Name = strName
		p.SetFont(Null)
		For Local i:Int = 0 To 2
			p.TextColor[i] = GUI.TextColor[i]
		Next
		p.Refresh()
		Return p
	End Function
	Rem
	bbdoc: Returns the selected text and removes it.
	End Rem
	Method CutSelection:String()
		Local sTemp:String
		If SelectLine = CurrentLine And SelectBegin = CurPos Return ""
		If SelectLine > CurrentLine
			sTemp = Lines[CurrentLine][CurPos..]
			For Local i:Int = CurrentLine + 1 To SelectLine - 1
				sTemp:+Lines[i]
			Next
			sTemp:+Lines[SelectLine][..SelectBegin]
		ElseIf SelectLine < CurrentLine
			sTemp = Lines[SelectLine][SelectBegin..]
			For Local i:Int = SelectLine + 1 To CurrentLine - 1
				sTemp:+Lines[i]
			Next
			sTemp:+Lines[CurrentLine][..CurPos]
		Else
		 If CurPos > SelectBegin
				sTemp = Lines[CurrentLine][SelectBegin..CurPos]
			Else
				sTemp = Lines[CurrentLine][CurPos..SelectBegin]
			End If
		End If
		RemoveText()
		Return sTemp
	End Method
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
		
		'Set Viewport Added by Zeke
		Local height:Int = h - (BorderTop + BorderBottom)
		Local width:Int = w - (BorderLeft + BorderRight)
		ifsoGUI_VP.Add(rX + BorderLeft, rY + BorderTop, width, height)
		'Draw the selection box
		If SelectBegin <> CurPos Or SelectLine <> CurrentLine
			SetColor(SelectColor[0], SelectColor[1], SelectColor[2])
			If SelectLine > CurrentLine
				Local beginx:Int = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..CurPos])
				
				If CurrentLine >= TopLine And CurrentLine - 1 <= TopLine + VisibleLines
					ifsoGUI_VP.DrawRect(rX + BorderLeft + 1 + beginx - OriginX, rY + BorderTop + ((CurrentLine - TopLine) * LineHeight), w - (beginx + BorderLeft + BorderRight + 2), LineHeight)
				EndIf
				
				Local numlines:Int = (SelectLine - CurrentLine) - 1
				
				If numlines > 0 And CurrentLine - 1 < TopLine + VisibleLines
					ifsoGUI_VP.DrawRect(rX + BorderLeft + 1, rY + BorderTop + ((CurrentLine + 1 - TopLine) * LineHeight), w - (BorderLeft + BorderRight) - 2, numlines * LineHeight)
				End If
				beginx = ifsoGUI_VP.GetTextWidth(Lines[SelectLine][..SelectBegin])
				If SelectLine >= TopLine And SelectLine <= TopLine + VisibleLines + 1
					ifsoGUI_VP.DrawRect(rX + BorderLeft + 1 - OriginX, rY + BorderTop + ((SelectLine - TopLine) * LineHeight), beginx, LineHeight)
				EndIf
			ElseIf CurrentLine > SelectLine
				Local beginx:Int = ifsoGUI_VP.GetTextWidth(Lines[SelectLine][..SelectBegin])
				If SelectLine >= TopLine And SelectLine - 1 <= TopLine + VisibleLines
					ifsoGUI_VP.DrawRect(rX + BorderLeft + 1 + beginx - OriginX, rY + BorderTop + ((SelectLine - TopLine) * LineHeight), w - (beginx + BorderLeft + BorderRight + 2), LineHeight)
				EndIf
				Local numlines:Int = (CurrentLine - SelectLine) - 1
				If numlines > 0 And SelectLine - 1 < TopLine + VisibleLines
					ifsoGUI_VP.DrawRect(rX + BorderLeft + 1, rY + BorderTop + ((SelectLine + 1 - TopLine) * LineHeight), w - (BorderLeft + BorderRight) - 2, numLines * LineHeight)
				End If
				beginx = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..CurPos])
				If CurrentLine >= TopLine And CurrentLine <= TopLine + VisibleLines + 1
					ifsoGUI_VP.DrawRect(rX + BorderLeft + 1 - OriginX, rY + BorderTop + ((CurrentLine - TopLine) * LineHeight), beginx, LineHeight)
				EndIf
			Else
				Local beginx:Int, selectw:Int
				If CurrentLine >= TopLine And CurrentLine - 1 <= TopLine + VisibleLines
					If CurPos > SelectBegin
						selectw = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][SelectBegin..CurPos])
						beginx = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..SelectBegin])
					Else
						selectw = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][CurPos..SelectBegin])
						beginx = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..CurPos])
					End If
					ifsoGUI_VP.DrawRect(rX + beginx + BorderLeft + 1 - OriginX, rY + BorderTop + ((CurrentLine - TopLine) * LineHeight), selectw, LineHeight)
				EndIf
			End If
		End If
		'Local height:Int = h - (BorderTop + BorderBottom) 'commented by Zeke
		'Local width:Int = w - (BorderLeft + BorderRight)
		If VBarOn
			VBar.Draw(rX + BorderLeft, rY + BorderTop, w, h)
		 width:-ScrollBarWidth
		End If
		If HBarOn
			HBar.Draw(rX + BorderLeft, rY + BorderTop, w, h)
		 height:-ScrollBarWidth
		End If
		
		'ifsoGUI_VP.Add(rX + BorderLeft, rY + BorderTop, width, height) 
		
		'Draw the lines of text
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		If fFont SetImageFont(fFont)
		For Local i:Int = TopLine To Lines.Length - 1
			If i > TopLine + VisibleLines + 1 Exit
			ifsoGUI_VP.DrawTextArea(Lines[i], rX + BorderLeft + 1 - OriginX, rY + BorderTop + ((i - TopLine) * LineHeight), Self)
		Next
		'Draw the cursor
		If HasFocus And (Not ReadOnly)
			If BlinkRate = 0
				Local oldwidth:Int = GetLineWidth()
				SetLineWidth(CursorWidth)
				Local tw:Int = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..CurPos], Self)
				ifsoGUI_VP.DrawLine(rX + BorderLeft + 1 + tw - OriginX, ry + BorderTop + 1 + LineHeight * (CurrentLine - TopLine), rX + BorderLeft + 1 + tw - OriginX, ry + BorderTop + 1 + CursorHeight + LineHeight * (CurrentLine - TopLine))
				SetLineWidth(oldwidth)
			Else
				Local tmpBlink:Int = MilliSecs()
				If tmpBlink - LastBlink > (BlinkRate * 2) LastBlink = tmpBlink
				If tmpBlink - LastBlink < BlinkRate
					Local oldwidth:Int = GetLineWidth()
					SetLineWidth(CursorWidth)
					Local tw:Int = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..CurPos], Self)
					ifsoGUI_VP.DrawLine(rX + BorderLeft + 1 + tw - OriginX, ry + BorderTop + 1 + LineHeight * (CurrentLine - TopLine), rX + BorderLeft + 1 + tw - OriginX, ry + BorderTop + 1 + CursorHeight + LineHeight * (CurrentLine - TopLine))
					SetLineWidth(oldwidth)
				End If
			End If
		End If
		If fFont SetImageFont(GUI.DefaultFont)
		ifsoGUI_VP.Pop()
	End Method
	Rem
	bbdoc: Inserts text at the cursor position.
	End Rem
	Method InsertText(strText:String)
		RemoveText()
		Lines[CurrentLine] = Lines[CurrentLine][..CurPos] + strText + Lines[CurrentLine][CurPos..]
		CurPos:+strText.Length
		SelectBegin = CurPos
		CheckLines()
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
			If VBar.IsMouseOver(locX, locY, locW, locH, iMouseX, iMouseY) Return True
			If HBar.IsMouseOver(locX, locY, locW, locH, iMouseX, iMouseY) Return True
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
		If Not (Visible And Enabled) Return
		GUI.SetActiveGadget(Self)
		bPressed = iButton
		If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
			Local iX:Int, iY:Int
			GetAbsoluteXY(iX, iY)
			CurrentLine = ((iMouseY - (iY + BorderTop)) / LineHeight) + TopLine
			
			If CurrentLine < 0 CurrentLine = 0
			'Added by Zeke
			If CurrentLine < TopLine Then
				TopLine = CurrentLine - 1
				If TopLine < 0 TopLine = 0
				VBar.SetValue(TopLine)
			End If	
			
			If CurrentLine > Lines.Length - 1 CurrentLine = Lines.Length - 1
			If CurrentLine > TopLine + VisibleLines - 1
		 	TopLine = CurrentLine - (VisibleLines)
				VBar.SetValue(TopLine)
			End If
			SelectLine = CurrentLine
			If fFont SetImageFont(fFont)
			Local tw:Int = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine], Self)
			Local Count:Int
			While iMouseX < tw + iX + BorderLeft + 1 - OriginX
				Count:+1
				tw = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..(Lines[CurrentLine].Length - 1) - Count], Self)
			Wend
			CurPos = (Lines[CurrentLine].Length - 1) - Count
			Local cw:Int = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][CurPos..CurPos + 1], Self) / 2
			tw = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..CurPos], Self)
			If iMouseX > tw + iX + BorderLeft + 1 + cw - OriginX CurPos:+1
			If CurPos = Lines[CurrentLine].Length And Lines[CurrentLine].EndsWith(Chr(13)) CurPos:-1
			SelectBegin = CurPos
			If fFont SetImageFont(GUI.DefaultFont)
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
					For i = CurPos To Lines[CurrentLine].Length - 1
						If (Lines[CurrentLine][i] < 48) Or (Lines[CurrentLine][i] > 57 And Lines[CurrentLine][i] < 65) Or (Lines[CurrentLine][i] > 90 And Lines[CurrentLine][i] < 97) Or (Lines[CurrentLine][i] > 122) Exit
					Next
					CurPos = i
					For i = CurPos - 1 To 0 Step - 1
						If (Lines[CurrentLine][i] < 48) Or (Lines[CurrentLine][i] > 57 And Lines[CurrentLine][i] < 65) Or (Lines[CurrentLine][i] > 90 And Lines[CurrentLine][i] < 97) Or (Lines[CurrentLine][i] > 122) Exit
					Next
					SelectBegin = i + 1
					If SelectBegin = CurPos
						If SelectBegin > 0
							SelectBegin:-1
						ElseIf CurPos < Lines[CurrentLine].Length
							CurPos:+1
						End If
					End If
				End If
			End If
			LastMouseClick = MilliSecs()
			bPressed = False
			SendEvent(iButton, CurPos, iMouseX, iMouseY)
		End If
		bPressed = False
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
		If Not Enabled Return
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
			If Not ReadOnly
				If SelectLine <> CurrentLine Or SelectBegin <> CurPos
					RemoveText()
				Else
					If CurPos > 0 'backup one character
						Lines[CurrentLine] = Lines[CurrentLine][..CurPos - 1] + Lines[CurrentLine][CurPos..]
						CurPos:-1
						Changed = True
						CheckLines()
					ElseIf CurrentLine > 0
						'Take character off end of previous line.
						Lines[CurrentLine - 1] = Lines[CurrentLine - 1][..Lines[CurrentLine - 1].Length - 1] 'remove the last char
						CurrentLine:-1
						CurPos = Lines[CurrentLine].Length
						Changed = True
						CheckLines()
					End If
				End If
			End If
		Else If key = 27 'Escape
			SelectBegin = CurPos
			SelectLine = CurrentLine
			GUI.SetActiveGadget(Null)
		ElseIf (key = ifsoGUI_KEY_DELETE) 'Delete
			If Not ReadOnly
				If SelectLine <> CurrentLine Or SelectBegin <> CurPos
					RemoveText()
				Else
					If (CurPos = Lines[CurrentLine].Length)
						'Remove first char next line
						If CurrentLine < Lines.Length - 1
						 Lines[CurrentLine + 1] = Lines[CurrentLine + 1][1..]
							Changed = True
							CheckLines()
						End If
					Else
						'Just remove a char
						Lines[CurrentLine] = Lines[CurrentLine][..CurPos] + Lines[CurrentLine][CurPos + 1..]
						Changed = True
						CheckLines()
					End If
				End If
			End If
		ElseIf (key = ifsoGUI_KEY_LEFT) 'Cursor Left
			If ReadOnly
			 If HBarOn HBar.SetValue(HBar.Value - 1)
			Else
				If CurPos > 0
					CurPos:-1
				ElseIf CurrentLine > 0
					CurrentLine:-1
					CurPos = Lines[CurrentLine].Length
					If Lines[CurrentLine].EndsWith(Chr(13)) CurPos:-1
				End If
				If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
					SelectLine = CurrentLine
					SelectBegin = CurPos
				End If
			End If
			CheckLineVis()
		ElseIf (key = ifsoGUI_KEY_RIGHT) 'Cursor Right
			If ReadOnly
			 If HBarOn HBar.SetValue(HBar.Value + 1)
			Else
				If CurPos < Lines[CurrentLine].Length
					CurPos:+1
					If CurPos = Lines[CurrentLine].Length And Lines[CurrentLine].EndsWith(Chr(13))
						CurPos = 0
						CurrentLine:+1
					End If
				ElseIf CurrentLine < Lines.Length - 1
					CurrentLine:+1
					CurPos = 0
				End If
				If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
					SelectLine = CurrentLine
					SelectBegin = CurPos
				End If
			End If
			CheckLineVis()
		ElseIf (key = ifsoGUI_KEY_HOME) 'Home
			If ReadOnly
				If VBarOn
					VBar.SetValue(0)
				Else
					TopLine = 0
				End If
			Else
				CurPos = 0
				If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
					SelectLine = CurrentLine
					SelectBegin = CurPos
				End If
			End If
			CheckLineVis()
		ElseIf (key = ifsoGUI_KEY_END) 'End
			If ReadOnly
				If VBarOn
					VBar.SetValue(0)
				Else
					TopLine = 0
				End If
			Else
				If Lines[CurrentLine].EndsWith(Chr(13))
					CurPos = Lines[CurrentLine].Length - 1
				Else
					CurPos = Lines[CurrentLine].Length
				End If
				If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
					SelectLine = CurrentLine
					SelectBegin = CurPos
				End If
			End If
			CheckLineVis()
		ElseIf (key = ifsoGUI_KEY_UP) 'Up
			If ReadOnly
				CurrentLine = TopLine - 1
				If CurrentLine < 0 CurrentLine = 0
			Else
				If CurrentLine > 0
					CurrentLine:-1
					If CurPos > Lines[CurrentLine].Length CurPos = Lines[CurrentLine].Length
					If (CurPos = Lines[CurrentLine].Length) And (Lines[CurrentLine].EndsWith(Chr(13))) CurPos = Lines[CurrentLine].Length - 1
				End If
				If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
					SelectLine = CurrentLine
					SelectBegin = CurPos
				End If
			End If
			CheckLineVis()
		ElseIf (key = ifsoGUI_KEY_DOWN) 'Down
			If ReadOnly
				CurrentLine = TopLine + VisibleLines + 1
				If CurrentLine > Lines.Length - 1 CurrentLine = Lines.Length - 1
			Else
				If CurrentLine < Lines.Length - 1
					CurrentLine:+1
					If CurPos > Lines[CurrentLine].Length CurPos = Lines[CurrentLine].Length
					If (CurPos = Lines[CurrentLine].Length) And (Lines[CurrentLine].EndsWith(Chr(13))) CurPos = Lines[CurrentLine].Length - 1
				End If
				If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
					SelectLine = CurrentLine
					SelectBegin = CurPos
				End If
			End If
			CheckLineVis()
		ElseIf (key = ifsoGUI_KEY_PAGEUP) 'Page Up
			CurrentLine:-VisibleLines
			TopLine:-VisibleLines
			If CurrentLine < 0 CurrentLine = 0
			If TopLine < 0 TopLine = 0
			If CurPos > Lines[CurrentLine].Length CurPos = Lines[CurrentLine].Length
			If (CurPos = Lines[CurrentLine].Length) And (Lines[CurrentLine].EndsWith(Chr(13))) CurPos = Lines[CurrentLine].Length - 1
			If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
				SelectLine = CurrentLine
				SelectBegin = CurPos
			End If
			CheckLineVis()
		ElseIf (key = ifsoGUI_KEY_PAGEDOWN) 'Page Down
			CurrentLine:+VisibleLines
			TopLine:+VisibleLines
			If CurrentLine > Lines.Length - 1 CurrentLine = Lines.Length - 1
			If TopLine > Lines.Length - 1 - VisibleLines TopLine = Lines.Length - 1 - VisibleLines
			If CurPos > Lines[CurrentLine].Length CurPos = Lines[CurrentLine].Length
			If (CurPos = Lines[CurrentLine].Length) And (Lines[CurrentLine].EndsWith(Chr(13))) CurPos = Lines[CurrentLine].Length - 1
			If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
				SelectLine = CurrentLine
				SelectBegin = CurPos
			End If
			CheckLineVis()
		ElseIf (key = ifsoGUI_MOUSE_WHEEL_UP)
			VBar.SetValue(VBar.Value - (GUI.iMouseZChange * VBar.Interval))
		ElseIf (key = ifsoGUI_MOUSE_WHEEL_DOWN)
			VBar.SetValue(VBar.Value - (GUI.iMouseZChange * VBar.Interval))
		Else
			If Not ReadOnly
				If Filter
					If Not Filter(key, Self) Return
				End If
				If SelectLine <> CurrentLine Or SelectBegin <> CurPos
					RemoveText()
				End If
				Lines[CurrentLine] = Lines[CurrentLine][..CurPos] + Chr(key) + Lines[CurrentLine][CurPos..]
				CurPos:+1
				Changed = True
				CheckLines()
			End If
		End If
		SendEvent(ifsoGUI_EVENT_KEYHIT, Key, 0, 0)
	End Method
	Rem
	bbdoc: Checks the lines of the gadget to see if they should be wrapped or clipped.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckLines(CheckLine:Int = -1)
		'-1=Currentline-1, -2=All, anything else is that line
		'Check for word wrapping
		Local wasFont:TImageFont = GetImageFont()
		If fFont
		 SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		Local LineToCheck:Int
		Local LinesToCheck:Int = 3
		If Checkline = -2
			LineToCheck = 0
			LinesToCheck = Lines.Length
		ElseIf CheckLine = -1
			LineToCheck = CurrentLine - 2
		Else
			LineToCheck = CheckLine
		End If
		If LineToCheck < 0 LineToCheck = 0
		If WordWrap
			While (LinesToCheck > 0)
				If LineToCheck >= Lines.Length Exit
				If CheckEmptyLine(LineToCheck) Continue
				If CheckCR(LineToCheck)
					LinesToCheck:+1
					Continue
				End If
				If CheckLong(LineToCheck)
					LinesToCheck:+1
					Continue
				End If
				If CheckShortSpace(LineToCheck)
					LinesToCheck:+1
					Continue
				End If
				If CheckShortChar(LineToCheck)
					LinesToCheck:+1
					Continue
				End If
			 LineToCheck:+1
				LinesToCheck:-1
			Wend
		Else 'Word Wrap Off
			While (LinesToCheck > 0)
				If LineToCheck >= Lines.Length Exit
				If CheckCR(LineToCheck)
					LinesToCheck:+1
					Continue
				End If
				If (Not Lines[LineToCheck].EndsWith(Chr(13)))
					'Append next line
					If (LineToCheck < Lines.Length - 1)
						If CurrentLine = LinesToCheck + 1
						 CurPos:+Lines[LineToCheck].Length
							CurrentLine:-1
						ElseIf CurrentLine > LineToCheck + 1
							CurrentLine:-1
						End If
						Lines[LineToCheck]:+Lines[LineToCheck + 1]
						For Local i:Int = LineToCheck + 1 To Lines.Length - 2 'Move lines up in the array
							Lines[i] = Lines[i + 1]
						Next
						Lines = Lines[..Lines.Length - 1] 'Remove the last line
						Continue
					End If
				End If
				If LineToCheck = LongestLine
					If ifsoGUI_VP.GetTextWidth(Lines[LongestLine], Self) < LongestValue
					 CheckLongestLine()
					Else
						LongestValue = ifsoGUI_VP.GetTextWidth(Lines[LongestLine], Self)
					End If
				Else
					If ifsoGUI_VP.GetTextWidth(Lines[LineToCheck], Self) > LongestValue
						LongestValue = ifsoGUI_VP.GetTextWidth(Lines[LineToCheck], Self)
						LongestLine = LineToCheck
					End If
				End If
				LineToCheck:+1
				LinesToCheck:-1
			Wend
		End If
		'Check scrollbars
		If VScrollBar = 2
			If Lines.Length - 1 > VisibleLines
				If Not VBarOn
					'If this just came on and WordWrap is on, we need to check all the lines again.
					VBarOn = True
					ClientWidth:-VBar.w
					If WordWrap
					 CheckLines(- 2)
						Return
					End If
					HBar.SetWH(w - (ScrollBarWidth + BorderLeft + BorderRight), ScrollBarWidth)
				End If
			Else
				If VBarOn
					VBarOn = False
					ClientWidth:+VBar.w
					'If this just went off and WordWrap is on, we need to check all the lines again.
					If WordWrap
					 CheckLines(- 2)
						Return
					End If
					HBar.SetWH(w - (BorderLeft + BorderRight), ScrollBarWidth)
				End If
			End If
		End If
		If HScrollBar = 2
			If Not WordWrap 'Wordwrap never has HBar
				If LongestValue > ClientWidth
				 If Not HBarOn
						HBarOn = True
						VisibleLines = ((h - (BorderTop + BorderBottom + ScrollBarWidth)) / LineHeight) - 1
						VBar.SetWH(ScrollBarWidth, h - (ScrollBarWidth + BorderTop + BorderBottom))
					End If
				Else
					If HBarOn
						HBarOn = False
						VisibleLines = ((h - (BorderTop + BorderBottom)) / LineHeight) - 1
						VBar.SetWH(ScrollBarWidth, h - (BorderTop + BorderBottom))
					End If
				End If
			End If
		End If
		If VBarOn
		 VBar.SetMax(Lines.Length - 1)
			VBar.SetBarInterval(VisibleLines)
		End If
		VBar.SetVisible(VBarOn)
		If HBarOn
		 HBar.SetMax(LongestValue)
			If VBarOn
				HBar.SetBarInterval(ClientWidth)
			Else
				HBar.SetBarInterval(ClientWidth)
			End If
		End If
		VBar.SetVisible(VBarOn)
		HBar.SetVisible(HBarOn)
		If fFont SetImageFont(GUI.DefaultFont)
		SetImageFont(wasFont)
		SelectLine = CurrentLine
		SelectBegin = CurPos
		CheckLineVis()
	End Method
	Rem
	bbdoc: Is the line short ending with a character.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckShortChar:Int(LineToCheck:Int)
		If Lines[LineToCheck].EndsWith(Chr(13)) Return False
		If Lines[LineToCheck].Length = 0 Return False
		If LineToCheck = Lines.Length - 1 Return False
		If Lines[LineToCheck].EndsWith(" ") Return False
		'Try to pull from next line
		'First check if whole line fits
		If ifsoGUI_VP.GetTextWidth(Lines[LineToCheck] + Lines[LineToCheck + 1], Self) <= ClientWidth
			If CurrentLine = LineToCheck + 1
				CurPos:+Lines[LineToCheck].Length
				CurrentLine:-1
			ElseIf CurrentLine > LineToCheck + 1
				CurrentLine:-1
			End If
			Lines[LineToCheck]:+Lines[LineToCheck + 1]
			For Local i:Int = LineToCheck + 1 To Lines.Length - 2
				Lines[i] = Lines[i + 1]
			Next
			Lines = Lines[..Lines.Length - 1]
			Return True
		End If
		'Try to pull from next line at space
		Local pos:Int = Lines[LineToCheck + 1].Find(" ")
		If pos > - 1
			If ifsoGUI_VP.GetTextWidth(Lines[LineToCheck] + Lines[LineToCheck + 1][..pos + 1], Self) < ClientWidth
				If CurrentLine = LineToCheck + 1
				 If CurPos < Pos
						CurPos:+Lines[LineToCheck].Length
						CurrentLine:-1
					Else
						CurPos:-(pos)
					End If
				End If
				Lines[LineToCheck]:+Lines[LineToCheck + 1][..pos + 1]
				Lines[LineToCheck + 1] = Lines[LineToCheck + 1][pos + 1..]
				Return True
			End If
		End If
		'Try to push from current line at a space
		pos = Lines[LineToCheck].FindLast(" ")
		If pos > - 1
			If CurrentLine = LineToCheck
				If CurPos > pos
					CurPos:-(pos + 1)
					CurrentLine:+1
				End If
			ElseIf CurrentLine = LineToCheck + 1
				Curpos:+pos
			End If
			Lines[LineToCheck + 1] = Lines[LineToCheck][pos + 1..] + Lines[LineToCheck + 1]
			Lines[LineToCheck] = Lines[LineToCheck][..pos + 1]
			Return True
		End If
		'Try to pull a character from next line
		If ifsoGUI_VP.GetTextWidth(Lines[LineToCheck] + Lines[LineToCheck + 1][..1], Self) < ClientWidth
			If CurrentLine = LineToCheck + 1
				If CurPos = 0
					CurPos = Lines[LineToCheck].Length + 1
					CurrentLine:-1
				Else
					CurPos:-1
				End If
			End If
			Lines[LineToCheck]:+Lines[LineToCheck + 1][..1]
			Lines[LineToCheck + 1] = Lines[LineToCheck + 1][1..]
			Return True
		End If
		Return False
	End Method
	Rem
	bbdoc: Is the line short ending with a space.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckShortSpace:Int(LineToCheck:Int)
		If Lines[LineToCheck].EndsWith(Chr(13)) Return False
		If LineToCheck = Lines.Length - 1 Return False
		'Does the line have a space at the end
		If Lines[LineToCheck].EndsWith(" ")
			'First check if whole line fits
			If ifsoGUI_VP.GetTextWidth(Lines[LineToCheck] + Lines[LineToCheck + 1], Self) < ClientWidth
				If CurrentLine = LineToCheck + 1
					CurrentLine:-1
				 CurPos:+Lines[LineToCheck].Length
				ElseIf CurrentLine > LineToCheck + 1
					CurrentLine:-1
				End If
				Lines[LineToCheck]:+Lines[LineToCheck + 1]
				For Local i:Int = LineToCheck + 1 To Lines.Length - 2
					Lines[i] = Lines[i + 1]
				Next
				Lines = Lines[..Lines.Length - 1]
				Return True
			Else
				'check at space
				Local pos:Int = Lines[LineToCheck + 1].Find(" ")
				If pos > - 1
					If ifsoGUI_VP.GetTextWidth(Lines[LineToCheck] + Lines[LineToCheck + 1][..pos + 1], Self) < ClientWidth
						If CurrentLine = LineToCheck + 1
						 If CurPos < Pos
								CurPos:+Lines[LineToCheck].Length
								CurrentLine:-1
							Else
								CurPos:-(pos)
							End If
						End If
						Lines[LineToCheck]:+Lines[LineToCheck + 1][..pos + 1]
						Lines[LineToCheck + 1] = Lines[LineToCheck + 1][pos + 1..]
						Return True
					End If
				End If
			End If
		End If
		Return False
	End Method
	Rem
	bbdoc: Line is long.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckLong:Int(LineToCheck:Int)
		If ifsoGUI_VP.GetTextWidth(Lines[LineToCheck], Self) <= ClientWidth Return False
		'Where is the last space
		Local sTmp:String = Lines[LineToCheck][..Lines[LineToCheck].Length - 1]
		Local pos:Int = sTmp.FindLast(" ")
		'Checking on a space or a char.
		If pos = -1
			If Lines[LineToCheck].Length = 1 Return False
			pos = Lines[LineToCheck].Length - 1
		Else
			pos:+1
		End If
		'If last line, we will need a new one
		If Lines.Length - 1 = LineToCheck Lines = Lines[..Lines.Length + 1]
		If CurrentLine = LineToCheck + 1
		 CurPos:+(Lines[LineToCheck].Length - pos)
		ElseIf CurrentLine = LineToCheck
			If CurPos > pos
				CurrentLine:+1
				CurPos:-pos
			End If
		End If
		Lines[LineToCheck + 1] = Lines[LineToCheck][pos..] + Lines[LineToCheck + 1]
		Lines[LineToCheck] = Lines[LineToCheck][..pos]
		Return True
	End Method
	Rem
	bbdoc: Line is empty.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckEmptyLine:Int(LineToCheck:Int)
		'Only the last line can be empty and only if the line before it has a CR
		If Lines[LineToCheck].Length = 0 And Lines.Length > 1
			If LineToCheck = Lines.Length - 1
			 If Lines[LineToCheck - 1].EndsWith(Chr(13)) Return False
			End If
			For Local i:Int = LineToCheck To Lines.Length - 2
				Lines[i] = Lines[i + 1]
			Next
			Lines = Lines[..Lines.Length - 1]
			If CurrentLine > LineToCheck
				CurrentLine:-1
			ElseIf CurrentLine = LineToCheck
				If CurrentLine >= Lines.Length CurrentLine:-1
				CurPos = 0
			End If
			Return True
		End If
		Return False
	End Method
	Rem
	bbdoc: Check for a CR.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckCR:Int(iLine:Int)
		Local loc:Int = Lines[iLine].Find(Chr(13))
		If loc > - 1 And loc < Lines[iLine].Length - 1
			If CurrentLine = iLine
				If CurPos > loc
					CurPos:-(loc + 1)
					CurrentLine:+1
				End If
			ElseIf CurrentLine = iLine + 1
				CurPos:+(Lines[CurrentLine].Length - loc)
			End If
			If iLine = Lines.Length - 1 Lines = Lines[..Lines.Length + 1] ' Add a line if last line
			Lines[iLine + 1] = Lines[iLine][loc + 1..] + Lines[iLine + 1]
			Lines[iLine] = Lines[iLine][..loc + 1]
			Return True
		'if CR at end and last line, add a line
		ElseIf Lines[iLine].EndsWith(Chr(13)) And iLine = Lines.Length - 1
			Lines = Lines[..Lines.Length + 1]
			If CurrentLine = iLine And CurPos >= Lines[iLine].Length - 1
				CurPos = 0
				CurrentLine:+1
			End If
		End If
		Return False
	End Method
	Rem
	bbdoc: Check the cursor position is correct.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckCursorPos(WasPrevLength:Int, WasCurLength:Int)
		If CurrentLine > Lines.Length - 1
			CurrentLine = Lines.Length - 1
			CurPos = Lines[CurrentLine].Length + CurPos
			Return
		End If
		If CurPos < 0
		 If CurrentLine > 0
				CurrentLine:-1
				CurPos = Lines[CurrentLine].Length + CurPos + 1
			End If
		ElseIf CurPos > Lines[CurrentLine].Length
			If CurrentLine < Lines.Length - 1
				CurPos = CurPos - Lines[CurrentLine].Length
				CurrentLine:+1
			Else
				CurPos = Lines[CurrentLine].Length
			End If
		ElseIf CurPos = Lines[CurrentLine].Length And Lines[CurrentLine].EndsWith(Chr(13))
			If CurrentLine < Lines.Length - 1
				CurPos = CurPos - Lines[CurrentLine].Length
				CurrentLine:+1
			Else
				CurPos = Lines[CurrentLine].Length
			End If
		End If
		If CurPos < 0 CurPos = 0
	End Method
	Rem
	bbdoc: Check the visibility of the lines.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckLineVis()
		'Check if lines are visible	
		Local wasFont:TImageFont = GetImageFont()
		If fFont
			SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		If Lines.Length - 1 <= TopLine + VisibleLines TopLine = (Lines.Length - 1) - VisibleLines
		If TopLine < 0 TopLine = 0
		If CurrentLine < TopLine TopLine = CurrentLine
		If CurrentLine >= TopLine + VisibleLines TopLine = CurrentLine - VisibleLines
		VBar.SetValue(TopLine)
		If HBarOn
			If Not ReadOnly
				Local tw:Int
				tw = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..CurPos], Self)
				If OriginX > tw
					OriginX = tw - ifsoGUI_VP.GetTextWidth("abcd", Self)
					If OriginX < 0 OriginX = 0
				ElseIf tw - OriginX > ClientWidth
					OriginX = tw - ClientWidth + ifsoGUI_VP.GetTextWidth("abcd", Self)
					If OriginX > ifsoGUI_VP.GetTextWidth(Lines[CurrentLine], Self) OriginX = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine], Self)
				End If
				HBar.SetValue(OriginX)
			End If
		Else
			OriginX = 0
		End If
		SetImageFont(wasFont)
	End Method
	Rem
	bbdoc: Find the longest line.
	about: Internal function should not be called by the user.
	End Rem
	Method CheckLongestLine()
		LongestValue = 0
		If fFont SetImageFont(fFont)
		For Local i:Int = 0 To Lines.Length - 1
			If ifsoGUI_VP.GetTextWidth(Lines[i], Self) > LongestValue
				LongestValue = ifsoGUI_VP.GetTextWidth(Lines[i], Self)
				LongestLine = i
			End If
		Next
		If fFont SetImageFont(GUI.DefaultFont)
	End Method
	Rem
	bbdoc: Called when the gadget becomes the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method GainFocus(LostFocus:ifsoGUI_Base)
		If LostFocus <> HBar And LostFocus <> VBar
			HasFocus = True
			Changed = False
			SendEvent(ifsoGUI_EVENT_GAIN_FOCUS, 0, 0, 0)
		End If
	End Method
	Rem
	bbdoc: Loads a skin for one instance of a gadget.
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
		Local dimensions:String[] = GetDimensions("mltextbox", strSkin).Split(",")
		Load9Image2("/graphics/mltextbox.png", dimensions, lImage, strSkin)
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
		If GainedFocus <> HBar And GainedFocus <> VBar
			If Changed SendEvent(ifsoGUI_EVENT_CHANGE, 0, 0, 0)
			bPressed = False
			HasFocus = False
			SendEvent(ifsoGUI_EVENT_LOST_FOCUS, 0, 0, 0)
		End If
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
			CurrentLine = ((iMouseY - (iY + BorderTop)) / LineHeight) + TopLine
			If CurrentLine < 0 CurrentLine = 0
			'Added by Zeke (auto scroll up when selecting text with mouse)
			If CurrentLine < TopLine Then
				TopLine = CurrentLine
				VBar.SetValue(TopLine)
			End If
			
			If CurrentLine > Lines.Length - 1 CurrentLine = Lines.Length - 1
			If CurrentLine > TopLine + VisibleLines - 1
		 	TopLine = CurrentLine - (VisibleLines)
				VBar.SetValue(TopLine)
			End If
			If fFont SetImageFont(fFont)
			Local tw:Int = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine], Self)
			Local Count:Int
			While (iMouseX < tw + iX + BorderLeft + 1 - OriginX) And Count < Lines[CurrentLine].Length - 1
				Count:+1
				tw = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..(Lines[CurrentLine].Length - 1) - Count], Self)
			Wend
			CurPos = (Lines[CurrentLine].Length - 1) - Count
			Local cw:Int = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][CurPos..CurPos + 1], Self) / 2
			tw = ifsoGUI_VP.GetTextWidth(Lines[CurrentLine][..CurPos], Self)
			If iMouseX > tw + iX + BorderLeft + 1 + cw - OriginX CurPos:+1
			If CurPos = Lines[CurrentLine].Length And Lines[CurrentLine].EndsWith(Chr(13)) CurPos:-1
			If fFont SetImageFont(GUI.DefaultFont)
		End If
		If Visible And Enabled
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
		Local wasFont:TImageFont = GetImageFont()
		If fFont
			SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		LineHeight = ifsoGUI_VP.GetTextHeight(Self)
		CursorHeight = LineHeight
		ClientWidth = w - (BorderLeft + BorderRight + 1 + CursorWidth)
		If VScrollBar = 1 VBarOn = True
		If VScrollBar = 0 VBarOn = False
		LineHeight = ifsoGUI_VP.GetTextHeight(Self)
		If HScrollBar = 1 HBarOn = True
		If WordWrap HBarOn = False
		If HScrollBar = 0 HBarOn = False
		If HBarOn
			VisibleLines = ((h - (BorderTop + BorderBottom + ScrollBarWidth)) / LineHeight) - 1
			VBar.SetWH(ScrollBarWidth, h - (BorderTop + BorderBottom + ScrollBarWidth))
		Else
			VisibleLines = ((h - (BorderTop + BorderBottom)) / LineHeight) - 1
			VBar.SetWH(ScrollBarWidth, h - (BorderTop + BorderBottom))
		End If
		VBar.SetXY(w - (ScrollBarWidth + BorderLeft + BorderRight), 0)
		HBar.SetXY(0, h - (ScrollBarWidth + BorderTop + BorderBottom))
		If VBarOn
			HBar.SetWH(w - (BorderLeft + BorderRight + ScrollBarWidth), ScrollBarWidth)
			ClientWidth:-ScrollBarWidth
		Else
			HBar.SetWH(w - (BorderLeft + BorderRight), ScrollBarWidth)
		End If
		SetImageFont(wasFont)
		CheckLines(- 2)
	End Method
	Rem
	bbdoc: Removes the selected text.
	about:	Internal function should not be called by the user.
	End Rem
	Method RemoveText()
		If SelectLine <> CurrentLine Or SelectBegin <> CurPos
			If SelectLine > CurrentLine
				For Local i:Int = CurrentLine + 1 To SelectLine - 1
					Lines[i] = ""
				Next
				Lines[CurrentLine] = Lines[CurrentLine][..CurPos]
				Lines[SelectLine] = Lines[SelectLine][SelectBegin..]
				SelectLine = CurrentLine
				SelectBegin = CurPos
				CheckLines(-2)
			ElseIf CurrentLine > SelectLine
				For Local i:Int = SelectLine + 1 To CurrentLine - 1
					Lines[i] = ""
				Next
				Lines[CurrentLine] = Lines[CurrentLine][CurPos..]
				Lines[SelectLine] = Lines[SelectLine][..SelectBegin]
				CurrentLine = SelectLine
				CurPos = SelectBegin
				CheckLines(-2)
			Else 'Same Line
				If CurPos > SelectBegin
					Lines[CurrentLine] = Lines[CurrentLine][..SelectBegin] + Lines[CurrentLine][CurPos..]
					CurPos = SelectBegin
				Else
					Lines[CurrentLine] = Lines[CurrentLine][..CurPos] + Lines[CurrentLine][SelectBegin..]
					SelectBegin = CurPos
				End If
				CheckLines()
			End If
			Changed = True
		End If
	End Method
	Rem
	bbdoc: Called from a slave gadget.
	about: Slave gadgets do not generate GUI events.  They send events to their Master.
	The Master then uses it or can send a GUI event.
	Internal function should not be called by the user.
	End Rem
	Method SlaveEvent(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		If gadget.Name = Name + "_vbar"
			If id = ifsoGUI_EVENT_CHANGE
			 TopLine = data
			End If
		Else
			If id = ifsoGUI_EVENT_CHANGE
			 OriginX = data
			End If
		End If
		If id = ifsoGUI_EVENT_LOST_FOCUS
			If GUI.gActiveGadget <> Self LostFocus(Null)
		ElseIf id = ifsoGUI_EVENT_GAIN_FOCUS
			If Not HasFocus GainFocus(Null)
		ElseIf id = ifsoGUI_EVENT_MOUSE_ENTER
			MouseOver(iMouseX, iMouseY, gadget)
		ElseIf id = ifsoGUI_EVENT_MOUSE_EXIT
			MouseOut(iMouseX, iMouseY, gadget)
		End If
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("mltextbox").Split(",")
		Load9Image2("/graphics/mltextbox.png", dimensions, gImage)
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
	bbdoc: Returns the number of visible lines.
	End Rem
	Method GetVisibleLines:Int()
		Return VisibleLines
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
	bbdoc: Sets the selection color.
	End Rem
	Method SetSelectColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of selected item
		SelectColor[0] = iRed
		SelectColor[1] = iGreen
		SelectColor[2] = iBlue
	End Method
	Rem
	bbdoc: Returns the location of the selection beginning cursor position.
	End Rem
	Method GetSelectCursorBegin:Int()
		Return SelectBegin
	End Method
	Rem
	bbdoc: Sets The Selection begining.
	End Rem
	Method SetSelectCursorBegin(iBegin:Int)
		SelectBegin = iBegin
	End Method
	Rem
	bbdoc: Returns the selected text.
	End Rem
	Method GetSelection:String()
		Local sTemp:String
		If SelectLine = CurrentLine And SelectBegin = CurPos Return ""
		If SelectLine > CurrentLine
			sTemp = Lines[CurrentLine][CurPos..]
			For Local i:Int = CurrentLine + 1 To SelectLine - 1
				sTemp:+Lines[i]
			Next
			sTemp:+Lines[SelectLine][..SelectBegin]
		ElseIf SelectLine < CurrentLine
			sTemp = Lines[SelectLine][SelectBegin..]
			For Local i:Int = SelectLine + 1 To CurrentLine - 1
				sTemp:+Lines[i]
			Next
			sTemp:+Lines[CurrentLine][..CurPos]
		Else
		 If CurPos > SelectBegin
				sTemp = Lines[CurrentLine][SelectBegin..CurPos]
			Else
				sTemp = Lines[CurrentLine][CurPos..SelectBegin]
			End If
		End If
		Return sTemp
	End Method
	Rem
	bbdoc: Returns the location of the selection beginning line.
	End Rem
	Method GetSelectLineBegin:Int()
		Return SelectLine
	End Method
	Rem
	bbdoc: Sets The Selection begining.
	End Rem
	Method SetSelectLineBegin(iBegin:Int)
		SelectLine = iBegin
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
		If VScrollBar = 0 VBarOn = False
		If VScrollBar = 1 VBarOn = True
		Refresh()
	End Method
	Rem
	bbdoc: Gets whether or not the Vertical Scrollbar will show.
	End Rem
	Method GetVScrollbar:Int()
		Return VScrollBar
	End Method
	Rem
	bbdoc: Sets a keypress filter.  This custom function should return True or False based on whether the key pressed should be allowed.
	End Rem
	Method SetFilter(funcFilter:Int(key:Int, gadget:ifsoGUI_Base))
		Filter = funcFilter
	End Method
	Rem
	bbdoc: Sets whether or not the Horizontal Scrollbar will show.
	about: ifsoGUI_SCROLLBAR_ON, ifsoGUI_SCROLLBAR_OFF, ifsoGUI_SCROLLBAR_AUTO
	End Rem
	Method SetHScrollbar(iHScrollbar:Int)
		HScrollBar = iHScrollBar
		If HScrollBar = 0 HBarOn = False
		If HScrollBar = 1 HBarOn = True
		Refresh()
	End Method
	Rem
	bbdoc: Gets whether or not the Horizontal Scrollbar will show.
	End Rem
	Method GetHScrollbar:Int()
		Return HScrollBar
	End Method
	Rem
	bbdoc: Returns the index of the top visible line.
	End Rem
	Method GetTopLine:Int()
		Return TopLine
	End Method
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
	bbdoc: Sets the current cursor line.
	End Rem
	Method SetCurrentLine(intCurrentLine:Int)
		If intCurrentLine < 0 Return
		If intCurrentLine > Lines.Length - 1 Return
		CurrentLine = intCurrentLine
		SetLinePos(CurPos)
	End Method
	Rem
	bbdoc: Returns the current cursor line.
	End Rem
	Method GetCurrentLine:Int()
		Return CurrentLine
	End Method
	Rem
	bbdoc: Sets the cursor line position.
	End Rem
	Method SetLinePos(intLinePos:Int)
		If intLinePos < 0 Return
		CurPos = intLinePos
		If CurPos > Lines[CurrentLine].Length CurPos = Lines[CurrentLine].Length
		If CurPos = Lines[CurrentLine].Length And Lines[CurrentLine].EndsWith(Chr(13)) CurPos = Lines[CurrentLine].Length - 1
		CheckLineVis()
	End Method
	Rem
	bbdoc: Returns the current cursor position on the line.
	End Rem
	Method GetLinePos:Int()
		Return CurPos
	End Method
	Rem
	bbdoc: Sets word wrap on or off.
	End Rem
	Method SetWordWrap(intWordWrap:Int)
		If intWordWrap = WordWrap Return
		WordWrap = intWordWrap
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether word wrap is on or off.
	End Rem
	Method GetWordWrap:Int()
		Return WordWrap
	End Method
	Rem
	bbdoc: Returns all of the text in the textbox.
	End Rem
	Method GetValue:String()
		Local tmp:String
		For Local i:Int = 0 To Lines.Length - 1
			tmp:+Lines[i]
		Next
		Return tmp
	End Method
	Rem
	bbdoc: Sets the text in the textbox.
	End Rem
	Method SetValue(strValue:String)
		Lines = Lines[..1]
		Lines[0] = strValue
		CheckLines(- 2)
	End Method
	Rem
	bbdoc: Returns the current number of lines.
	End Rem
	Method GetNumLines:Int()
		Return Lines.Length
	End Method
	Rem
	bbdoc: Appends text to the textbox.
	End Rem
	Method AddText(strText:String)
		Lines[Lines.Length - 1]:+strText
		CheckLines(Lines.Length - 1)
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
End Type
