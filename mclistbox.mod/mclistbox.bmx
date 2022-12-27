SuperStrict

Rem
	bbdoc: ifsoGUI Multi-Column Listbox
	about: Multi-Column Listbox Gadget
EndRem
Module ifsogui.mclistbox

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.scrollbar
Import ifsogui.button
Import ifsogui.textbox
Import ifsogui.checkbox
Import ifsogui.combobox
Import ifsogui.progressbar
Import ifsogui.slider

GUI.Register(ifsoGUI_MCListBox.SystemEvent)
GUI.Register(ifsoGUI_MCLColumn.SystemEvent)

Const ifsoGUI_COLUMNTYPE_LABEL:Int = 0
Const ifsoGUI_COLUMNTYPE_TEXTBOX:Int = 1
Const ifsoGUI_COLUMNTYPE_CHECKBOX:Int = 2
Const ifsoGUI_COLUMNTYPE_COMBOBOX:Int = 3
Const ifsoGUI_COLUMNTYPE_PROGRESSBAR:Int = 4
Const ifsoGUI_COLUMNTYPE_SLIDER:Int = 5

Const ifsoGUI_COMBOBOX_NAME:Int = 0
Const ifsoGUI_COMBOBOX_INDEX:Int = 1
Const ifsoGUI_COMBOBOX_DATA:Int = 2
Const ifsoGUI_COMBOBOX_TIP:Int = 3

Rem
	bbdoc: Listbox Type
End Rem
Type ifsoGUI_MCListBox Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the frame
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image 'Images to draw the frame
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched

	'For column skins
	Field colImage:ifsoGUI_Image
	Field colImageDown:ifsoGUI_Image
	Field colImageOver:ifsoGUI_Image
	Field colTileSides:Int, colTileCenter:Int

	Field Columns:ifsoGUI_MCLColumn[] 'The columns
	Field NumRows:Int 'Number of Rows in the listbox
	Field TopItem:Int 'Item at the visible top of the list
	Field VisibleRows:Int 'Number of complete rows visible in the list
	Field Widest:Int 'Widest item in the list
	Field ItemHeight:Int 'Height of one item
	Field VScrollbar:Int = 2 'Show vertical scrollbar when list is to tall, 0-Never 1-Always 2-When needed
	Field HScrollBar:Int = 2 'Show horizontal scrollbar when list is too wide, 0-Never 1-Always 2-When needed
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
	Field HighlightColor:Int[] = [220, 220, 255] 'Color of the highlight
	Field SelectColor:Int[] = [40, 40, 255] 'Color of the selected item background
	Field HighlightTextColor:Int[] = [0, 0, 0] 'Color of the highlighted item text
	Field SelectTextColor:Int[] = [255, 255, 255] 'Color of the selected item text
	Field HeaderTextColor:Int[] = [0, 0, 0] 'Color of the text in the Header buttons
	Field HeaderFont:TImageFont 'Font of the text in the Header Buttons
	Field ShowGrid:Int = False
	Field GridColor:Int[] = [128, 128, 128] 'Color of the grid
	Field ShowColumnHeader:Int = False, ShowRowHeader:Int = False 'Should the row/column header show
	Field ColHeadHeight:Int, RowHeadWidth:Int 'Height/Width of the col/row headers
	Field ActiveCellRow:Int = -1, ActiveCellCol:Int = -1 'Current Active Cell
	Field OverCol:Int = -1, OverRow:Int = -1 'Cell the mouse is over
	Field UserRowHeight:Int 'Height the user asks for
	Field UserHeadHeight:Int, UserHeadWidth:Int 'Header Height/Width User asks for
	Field MouseCellCol:Int, MouseCellRow:Int 'Cell the mouse button was pressed on.
	Field ColumnsResizable:Int 'Can the columns be resized
	Field RowHeadDown:Int = -1 'If a Row Header is pressed.
	
	'Events
	'Mouse Enter/Mouse Exit/Change
	
	Rem
		bbdoc: Create and returns a Listbox gadget.
	End Rem
	Function Create:ifsoGUI_MCListBox(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_MCListBox = New ifsoGUI_MCListBox
		p.x = iX
		p.y = iY
		p.colImage = ifsoGUI_MCLColumn.gImage
		p.colImageDown = ifsoGUI_MCLColumn.gImageDown
		p.colImageOver = ifsoGUI_MCLColumn.gImageOver
		p.colTileSides = ifsoGUI_MCLColumn.gTileSides
		p.colTileCenter = ifsoGUI_MCLColumn.gTileCenter
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
		If Columns.Length > 0
			Local width:Int = w - (BorderLeft + BorderRight)
			If VBarOn width:-ScrollBarWidth
			Local height:Int = h - (BorderTop + BorderBottom)
			If HBarOn height:-ScrollBarWidth
			Local HeadHeight:Int, HeadWidth:Int
			If ShowColumnHeader HeadHeight = ColHeadHeight
			If ShowRowHeader HeadWidth = RowHeadWidth
			'Draw the highlighted and selected rows
			ifsoGUI_VP.Add(rX + BorderLeft + HeadWidth, rY + BorderTop + HeadHeight, width - HeadWidth, height - HeadHeight)
			Local locX:Int, locY:Int
			locX = rX + BorderLeft
			locY = rY + BorderTop + HeadHeight
			'Highlighted Row
			If (HasFocus Or VBar.HasFocus Or HBar.HasFocus) And Highlighted >= TopItem And HighLighted <= TopItem + VisibleRows
				SetColor(HighlightColor[0], HighlightColor[1], HighlightColor[2])
				ifsoGUI_VP.DrawRect(locX + HeadWidth, locY + (ItemHeight * (Highlighted - TopItem)), width - HeadWidth, ItemHeight)
			End If
			'Selected Row
			SetColor(SelectColor[0], SelectColor[1], SelectColor[2])
			For Local i:Int = TopItem To NumRows - 1
				If i > TopItem + VisibleRows Exit
				If Columns[0].Rows[i].Selected
					If i = Highlighted And (HasFocus Or VBar.HasFocus Or HBar.HasFocus)
						If ShowGrid
							ifsoGUI_VP.DrawRect(locX + 1 + HeadWidth, locY + ItemHeight * (i - TopItem) + 1, width - 2 - HeadWidth, ItemHeight - 3)
						Else
							ifsoGUI_VP.DrawRect(locX + 1 + HeadWidth, locY + ItemHeight * (i - TopItem) + 1, width - 2 - HeadWidth, ItemHeight - 2)
						End If
					Else
						ifsoGUI_VP.DrawRect(locX + HeadWidth, locY + ItemHeight * (i - TopItem), width - HeadWidth, ItemHeight)
					End If
				End If
			Next
			ifsoGUI_VP.Pop()
			'Draw the Column headers
			If ShowColumnHeader
				locY:-HeadHeight
				ifsoGUI_VP.Add(locX + HeadWidth, locY, width - HeadWidth, HeadHeight)
				For Local i:Int = 0 To Columns.Length - 1
					Columns[i].Draw(locX - OriginX, locY, width + OriginX, height)
				Next
				ifsoGUI_VP.Pop()
			End If
			'Draw the Row headers
			If ShowRowHeader
				locY = rY + BorderTop + HeadHeight
				ifsoGUI_VP.Add(locX, locY, HeadWidth, height - Headheight)
				If HeaderFont SetImageFont(HeaderFont)
				For Local i:Int = TopItem To NumRows - 1
					If i > TopItem + VisibleRows + 1 Exit
					SetColor(Color[0], Color[1], Color[2])
					If MouseCellCol = -2 And MouseCellRow = i And OverRow = i And OverCol = -2
						Columns[0].DrawRowButton(locX, locY, HeadWidth, ItemHeight, HeaderTextColor, String(i + 1), 2, Self)
					ElseIf OverCol = -2 And OverRow = i
						Columns[0].DrawRowButton(locX, locY, HeadWidth, ItemHeight, HeaderTextColor, String(i + 1), 1, Self)
					Else
						Columns[0].DrawRowButton(locX, locY, HeadWidth, ItemHeight, HeaderTextColor, String(i + 1), 0, Self)
					End If
					locY:+ItemHeight
				Next
				If HeaderFont SetImageFont(GUI.DefaultFont)
				ifsoGUI_VP.Pop()
			End If
			'Draw the grid
			If ShowGrid
				locX = rX + BorderLeft
				locY = rY + BorderTop
				Local maxX:Int = locX + width
				If maxX > locX + Columns[Columns.Length - 1].x + Columns[Columns.Length - 1].w maxX = locX + Columns[Columns.Length - 1].x + Columns[Columns.Length - 1].w + OriginX
				SetColor(GridColor[0], GridColor[1], GridColor[2])
				SetLineWidth(1)
				'Rows
				If Not ShowBorder And Not ShowColumnHeader 'Draw the first line
					ifsoGUI_VP.DrawLine(locX + HeadWidth, locY, maxX, locY, False)
				End If
				For Local i:Int = 1 To VisibleRows
					If i - 1 >= NumRows Exit
					ifsoGUI_VP.DrawLine(locX + HeadWidth, locY + HeadHeight + i * ItemHeight - 1, maxX, locY + HeadHeight + i * ItemHeight - 1, False)
				Next
				'Columns
				Local botY:Int = locY + HeadHeight
				If TopItem + VisibleRows >= NumRows
					botY = locY + HeadHeight + (NumRows - TopItem) * ItemHeight
				Else
					botY:+height - HeadHeight
				End If
				If Not ShowBorder And Not ShowRowHeader And OriginX = 0 'Draw the first line
					ifsoGUI_VP.DrawLine(locX, locY + HeadHeight, locX, botY, False)
				End If
				locX:+HeadWidth - OriginX
				For Local i:Int = 0 To Columns.Length - 1
					locX:+Columns[i].w
					If locX > rX + width Exit
					If locX <= rX + HeadWidth + 1 Continue
					If i = Columns.Length - 1 locX:-1
					ifsoGUI_VP.DrawLine(locX, locY + HeadHeight, locX, botY, False)
				Next
			End If
			'Draw the lines of text or the gadgets
			SetColor(TextColor[0], TextColor[1], TextColor[2])
			ifsoGUI_VP.Add(rX + BorderLeft + HeadWidth, rY + BorderTop + HeadHeight, width - HeadWidth, height - HeadHeight)
			If fFont SetImageFont(fFont)
			Local diff:Int = (ItemHeight - ifsoGUI_VP.GetTextHeight(Self)) / 2 - 1
			locY = rY + BorderTop + HeadHeight
			Local tmpVal:String
			For Local i:Int = TopItem To NumRows - 1
				If i > TopItem + VisibleRows Exit
				locX = rX + BorderLeft + HeadWidth + 1
				For Local j:Int = 0 To Columns.Length - 1
					If locX - OriginX + Columns[j].w > rX + BorderLeft
						If locX - OriginX > rX + w Exit
						ifsoGUI_VP.Add(locX - OriginX, locY, Columns[j].w - 1, ItemHeight)
						If Columns[j].bShowgadget
							Columns[j].GadgetList[i - TopItem].Draw(rX + BorderLeft - OriginX, rY + BorderTop, w - (BorderLeft + BorderRight) + OriginX, h - (BorderTop + BorderBottom))
							SetColor(TextColor[0], TextColor[1], TextColor[2])
						Else
							If Columns[0].Rows[i].Selected
								SetColor(SelectTextColor[0], SelectTextColor[1], SelectTextColor[2])
							ElseIf (HasFocus Or IsMyChild(GUI.gActiveGadget)) And Highlighted = i
								SetColor(HighlightTextColor[0], HighlightTextColor[1], HighlightTextColor[2])
							Else
								SetColor(TextColor[0], TextColor[1], TextColor[2])
							End If
							If Columns[j].CType = ifsoGUI_COLUMNTYPE_COMBOBOX
								Select Columns[j].ShowComboData
									Case ifsoGUI_COMBOBOX_DATA
										If Columns[j].Rows[i].Value = "-1"
											tmpVal = ""
										Else
											tmpVal = ifsoGUI_Combobox(Columns[j].Gadget).dropList.Items[Int(Columns[j].Rows[i].Value)].Data
										End If
									Case ifsoGUI_COMBOBOX_INDEX
										If Columns[j].Rows[i].Value = "-1"
											tmpVal = "-1"
										Else
											tmpVal = Columns[j].Rows[i].Value
										End If
									Case ifsoGUI_COMBOBOX_TIP
										If Columns[j].Rows[i].Value = "-1"
											tmpVal = ""
										Else
											tmpVal = ifsoGUI_Combobox(Columns[j].Gadget).dropList.Items[Int(Columns[j].Rows[i].Value)].Tip
										End If
									Default
										If Columns[j].Rows[i].Value = "-1"
											tmpVal = ""
										Else
											tmpVal = ifsoGUI_Combobox(Columns[j].Gadget).dropList.Items[Int(Columns[j].Rows[i].Value)].Name
										End If
								End Select
							Else
								tmpVal = Columns[j].Rows[i].Value
							End If
							Select Columns[j].CellAlign
								Case ifsoGUI_JUSTIFY_CENTER
									ifsoGUI_VP.DrawTextArea(tmpVal, ((Columns[j].w - ifsoGUI_VP.GetTextWidth(tmpVal, Self)) / 2) + locX - OriginX, locY + diff, Self)
								Case ifsoGUI_JUSTIFY_RIGHT
									ifsoGUI_VP.DrawTextArea(tmpVal, locX - OriginX + Columns[j].w - ifsoGUI_VP.GetTextWidth(tmpVal, Self) - (BorderRight + 1) , locY + diff, Self)
								Default
									ifsoGUI_VP.DrawTextArea(tmpVal, locX - OriginX, locY + diff, Self)
							End Select
						End If
						ifsoGUI_VP.Pop()
					End If
					locX:+Columns[j].w
				Next
				locY:+ItemHeight
			Next
			If fFont SetImageFont(GUI.DefaultFont)
			'Draw the Active Cell Gadget
			If ActiveCellCol > - 1 And ActiveCellRow > - 1
				Columns[ActiveCellCol].Gadget.Draw(rX + BorderLeft - OriginX, rY + BorderTop, w - (BorderLeft + BorderRight) + OriginX, h - (BorderTop + BorderBottom))
			End If
			ifsoGUI_VP.Pop()
		End If
		'Draw the scrollbars
		VBar.Draw(rX + BorderLeft, rY + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
		HBar.Draw(rX + BorderLeft, rY + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not (Visible And Enabled)			Return False
		Local locX:Int = parX + x + BorderLeft, locY:Int = parY + y + BorderTop
		Local locW:Int = w - (BorderLeft + BorderRight), locH:Int = h - (BorderTop + BorderBottom)
		If (iMouseX >= locX) And (iMouseX <= locX + locW) And (iMouseY >= locY) And (iMouseY <= locY + locH)
			OverCell(iMouseX, iMouseY, True)
			If OverCol <> - 2
				If OverRow = -2
					If ShowColumnHeader
						'For Local i:Int = 0 To Columns.Length - 1
							If OverCol >= 0
								If Columns[OverCol].IsMouseOver(locX - OriginX, locY, locW, locH, iMouseX, iMouseY) Return True
							End If
						'Next
					End If
				Else
					If VBar.IsMouseOver(locX, locY, locW, locH, iMouseX, iMouseY) Return True
					If HBar.IsMouseOver(locX, locY, locW, locH, iMouseX, iMouseY) Return True
					If Not (ShowRowHeader And iMouseX <= locX + RowHeadWidth) And Not(ShowColumnHeader And iMouseY <= locY + ColHeadHeight)
						If Not (HBar.Visible And VBar.Visible And (iMouseX > parX + x + w - (BorderRight + ScrollBarWidth + 1)) And (iMouseY > parY + y + h - (BorderBottom + ScrollBarWidth + 1)))
							For Local g:ifsoGUI_Base = EachIn Slaves
								If g <> HBar And g <> VBar And Not (ifsoGUI_MCLColumn(g))
									If g.IsMouseOver(locX - OriginX, locY, locW, locH, iMouseX, iMouseY)
										Return True
									EndIf
								End If
							Next
						End If
					End If
				End If
			End If
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
			colImage = ifsoGUI_MCLColumn.gImage
			colImageDown = ifsoGUI_MCLColumn.gImageDown
			colImageOver = ifsoGUI_MCLColumn.gImageOver
			colTileSides = ifsoGUI_MCLColumn.gTileSides
			colTileCenter = ifsoGUI_MCLColumn.gTileCenter
			For Local i:Int = 0 To Columns.Length - 1
				Columns[i].lImage = colImage
				Columns[i].lImageDown = colImageDown
				Columns[i].lImageOver = colImageOver
				Columns[i].lTileSides = colTileSides
				Columns[i].lTileCenter = colTileCenter
				Columns[i].Refresh()
			Next
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("mclistbox", strSkin).Split(",")
		Load9Image2("/graphics/mclistbox.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		'Load for column buttons
		dimensions = GetDimensions("button", strSkin).Split(",")
		Load9Image2("/graphics/button.png", dimensions, colImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" colTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" colTileCenter = True
		End If
		If GUI.FileExists(strSkin + "/graphics/buttonover.png")
			Load9Image2("/graphics/buttonover.png", dimensions, colImageOver, strSkin)
		Else
			colImageOver = colImage
		End If
		If GUI.FileExists(strSkin + "/graphics/buttondown.png")
			Load9Image2("/graphics/buttondown.png", dimensions, colImageDown, strSkin)
		Else
			colImageDown = colImage
		End If
		For Local i:Int = 0 To Columns.Length - 1
			Columns[i].lImage = colImage
			Columns[i].lImageDown = colImageDown
			Columns[i].lImageOver = colImageOver
			Columns[i].lTileSides = colTileSides
			Columns[i].lTileCenter = colTileCenter
		Next
		Refresh()
	End Method
	Rem
	bbdoc: Called when the mouse is over this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base) 'Called when mouse is over the gadget, only topmost gadget
		Super.MouseOver(iMouseX, iMouseY, gWasOverGadget)
		If Not (Enabled And Visible) Return
		OverCell(iMouseX, iMouseY)
	End Method
	Rem
	bbdoc: Determines which cell the mouse is over.
	about: Internal function should not be called byt he user.
	End Rem
	Method OverCell(iMouseX:Int, iMouseY:Int, iHighlightIt:Int = False)
		Global wasX:Int, wasY:Int
		If wasX = iMouseX And wasY = iMouseY Return
		Local iX:Int, iY:Int
		GetAbsoluteXY(iX, iY)
		iX:+OriginX
		'If over either of the scrollbars, then not over a cell
		OverRow = -1
		OverCol = -1
		If Columns.Length < 1 Return
		If HBarOn And iMouseY > iY + h - (BorderBottom + ScrollBarWidth) Return
		If VBarOn And iMouseX > iX + w - (BorderRight + ScrollBarWidth) Return
		Local HeadHeight:Int
		If ShowColumnHeader HeadHeight = ColHeadheight
		If ShowColumnHeader And iMouseY > iY + BorderTop And iMouseY < iY + BorderTop + ColHeadHeight
			OverRow = -2
		Else
			If NumRows > 0
				OverRow = ((iMouseY - (iY + BorderTop + HeadHeight)) / ItemHeight) 'Item mouse is over
				If OverRow < 0
					OverRow = -1
				Else
					OverRow:+TopItem
				End If
				If OverRow >= NumRows OverRow = -1
				If OverRow >= 0
					If MouseHighlight And (HasFocus Or VBar.HasFocus Or HBar.HasFocus) And (iMouseX <> wasX Or iMouseY <> wasY Or iHighlightIt) Highlighted = OverRow
				End If
			End If
		End If
		Local chkX:Int = iX + BorderLeft
		If ShowRowHeader
		 If iMouseX >= chkX And iMouseX <= chkX + RowHeadWidth OverCol = -2
			chkX:+RowHeadWidth
		End If
		If OverCol = -1
			chkX:-OriginX
			For Local i:Int = 0 To Columns.Length - 1
				If iMouseX > chkX And iMouseX <= chkX + Columns[i].w
					OverCol = i
					Exit
				End If
				chkX:+Columns[i].w
			Next
		End If
		If OverRow >= 0 And OverCol >= 0
			Tip = Columns[OverCol].Rows[OverRow].Tip
		End If
		wasX = iMouseX
		wasY = iMouseY
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not (Visible And enabled) Return
		GUI.SetActiveGadget(Self)
		bPressed = iButton
		OverCell(iMouseX, iMouseY, True)
		MouseCellCol = OverCol
		MouseCellRow = OverRow
		If Columns.Length < 1 Return
		Local bShifted:Int, bControled:Int
		If MultiSelect 'Is shift or control pressed?
			If KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL) bControled = True
			If KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT) bShifted = True
		End If
		If bPressed = ifsoGUI_RIGHT_MOUSE_BUTTON Or bPressed = ifsoGUI_MIDDLE_MOUSE_BUTTON
			If OverRow > - 1
		 	If Not (bShifted Or bControled) 'Change the current selection
					If MultiSelect
						For Local i:Int = 0 To Columns[0].Rows.Length - 1
							Columns[0].Rows[i].Selected = False
						Next
					Else
						If LastSelected > - 1 Columns[0].Rows[LastSelected].Selected = False 'Unselect last selected
					End If
					LastSelected = OverRow
					Columns[0].Rows[OverRow].Selected = True
					SendEvent(ifsoGUI_EVENT_CHANGE, OverRow, iMouseX, iMouseY)
				End If
			End If
		Else
			If (MilliSecs() - LastMouseClick < ifsoGUI_DOUBLE_CLICK_DELAY) And OverRow = LastSelected
				SendEvent(ifsoGUI_EVENT_DOUBLE_CLICK, LastSelected, iMouseX, iMouseY)
			Else
				If bShifted
					If OverRow > - 1
						If LastSelected > - 1
							Local iFrom:Int = LastSelected, iTo:Int = OverRow
							If LastSelected > OverRow
								iFrom = OverRow
								iTo = LastSelected
							End If
							For Local i:Int = 0 To Columns[0].Rows.Length - 1
								If i < iFrom Or i > iTo
									Columns[0].Rows[i].Selected = False
								Else
									Columns[0].Rows[i].Selected = True
								End If
							Next
						End If
						LastSelected = OverRow
						SendEvent(ifsoGUI_EVENT_CHANGE, OverRow, iMouseX, iMouseY)
					End If
				ElseIf bControled
					If OverRow > - 1
						LastSelected = OverRow
						Columns[0].Rows[OverRow].Selected = Not Columns[0].Rows[OverRow].Selected
						SendEvent(ifsoGUI_EVENT_CHANGE, OverRow, iMouseX, iMouseY)
					End If
				Else
					If OverRow <> LastSelected
						If MultiSelect
							For Local i:Int = 0 To Columns[0].Rows.Length - 1
								Columns[0].Rows[i].Selected = False
							Next
						Else
							If LastSelected > - 1 Columns[0].Rows[LastSelected].Selected = False
						End If
						LastSelected = OverRow
						If OverRow > - 1 Columns[0].Rows[OverRow].Selected = True
						SendEvent(ifsoGUI_EVENT_CHANGE, OverRow, iMouseX, iMouseY)
					End If
				End If
			End If
			LastMouseClick = MilliSecs()
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		If Visible And Enabled And GUI.gMouseOverGadget = Self
			'Send mouse click event. Click, Right, Middle are equal to Mouse Left/Right/Middle.
			If MouseCellCol = OverCol And MouseCellRow = OverRow
				If OverCol >= 0 And OverRow >= 0
					SetActiveCell(MouseCellCol, MouseCellRow)
				End If
				SendEvent(ifsoGUI_EVENT_CLICK, iButton, OverCol, OverRow)
			End If
		Else
			GUI.SetActiveGadget(Null)
		End If
		bPressed = False
		MouseCellCol = -1
		MouseCellRow = -1
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
		If Highlighted < 0 Return
		If Columns.Length < 1 Return
		If NumRows < 1 Return
	 If key = ifsoGUI_KEY_UP Or key = ifsoGUI_KEY_DOWN Or key = ifsoGUI_KEY_HOME Or key = ifsoGUI_KEY_END Or key = ifsoGUI_KEY_PAGEUP Or key = ifsoGUI_KEY_PAGEDOWN Or key = ifsoGUI_KEY_RIGHT Or key = ifsoGUI_KEY_LEFT
			If (key = ifsoGUI_KEY_UP) 'Cursor Up
				If Highlighted > 0 Highlighted:-1
			Else If (key = ifsoGUI_KEY_DOWN) 'Cursor Down
				If Highlighted < NumRows - 1 Highlighted:+1
			Else If (key = ifsoGUI_KEY_RIGHT) 'Cursor Right
				If HBarOn HBar.SetValue(HBar.GetValue() + 1)
			Else If (key = ifsoGUI_KEY_LEFT) 'Cursor Left
				If HBarOn HBar.SetValue(HBar.GetValue() - 1)
			Else If (key = ifsoGUI_KEY_HOME) 'Home
				Highlighted = 0
			Else If (key = ifsoGUI_KEY_END) 'End
				Highlighted = NumRows - 1
			Else If (key = ifsoGUI_KEY_PAGEUP) 'PageUp
				If Highlighted = TopItem
					Highlighted:-VisibleRows
					If Highlighted < 0 Highlighted = 0
				Else
					Highlighted = TopItem
				End If
			Else If (key = ifsoGUI_KEY_PAGEDOWN) 'PageDown
				If Highlighted = TopItem + VisibleRows - 1
					Highlighted:+VisibleRows
					If Highlighted > NumRows - 1 Highlighted = NumRows - 1
				Else
					Highlighted = TopItem + VisibleRows - 1
					If Highlighted > NumRows - 1 Highlighted = NumRows - 1
				End If
			End If
			If Highlighted < TopItem
				VBar.SetValue(Highlighted)
			Else If Highlighted > TopItem + VisibleRows - 1
				VBar.SetValue(Highlighted - (VisibleRows - 1))
			End If
			If MultiSelect And (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT))
				Local iFrom:Int = LastSelected, iTo:Int = Highlighted
				If LastSelected > Highlighted
					iFrom = Highlighted
					iTo = LastSelected
				End If
				For Local i:Int = 0 To NumRows - 1
					If i < iFrom Or i > iTo
						Columns[0].Rows[i].Selected = False
					Else
						Columns[0].Rows[i].Selected = True
					End If
				Next
				SendEvent(ifsoGUI_EVENT_CHANGE, Highlighted, -1, -1)
			ElseIf Not (KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL))
				If MultiSelect
					For Local i:Int = 0 To NumRows - 1
						Columns[0].Rows[i].Selected = False
					Next
				Else
					If LastSelected > - 1 Columns[0].Rows[LastSelected].Selected = False
				End If
				Columns[0].Rows[Highlighted].Selected = True
				LastSelected = Highlighted
				SendEvent(ifsoGUI_EVENT_CHANGE, LastSelected, -1, -1)
			End If
		Else If key = 13 Or key = 10 'CR
			If MultiSelect
				If Not (KeyDown(KEY_LSHIFT) Or KeyDown(KEY_RSHIFT) Or KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL))
					If Highlighted > - 1 Columns[0].Rows[Highlighted].Selected = True
					LastSelected = Highlighted
					SendEvent(ifsoGUI_EVENT_DOUBLE_CLICK, LastSelected, -1, -1)
				Else
					If LastSelected >= 0 SendEvent(ifsoGUI_EVENT_DOUBLE_CLICK, LastSelected, - 1, - 1)
				End If
			Else
				If LastSelected > - 1 Columns[0].Rows[LastSelected].Selected = False
				LastSelected = Highlighted
				If LastSelected > - 1
				 Columns[0].Rows[LastSelected].Selected = True
					SendEvent(ifsoGUI_EVENT_DOUBLE_CLICK, LastSelected, -1, -1)
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
					For Local i:Int = 0 To NumRows - 1
						If i < iFrom Or i > iTo
							Columns[0].Rows[i].Selected = False
						Else
							Columns[0].Rows[i].Selected = True
						End If
					Next
				ElseIf KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL)
					Columns[0].Rows[Highlighted].Selected = Not Columns[0].Rows[Highlighted].Selected
					LastSelected = Highlighted
				Else
					For Local i:Int = 0 To NumRows - 1
						Columns[0].Rows[i].Selected = False
					Next
					Columns[0].Rows[Highlighted].Selected = True
					LastSelected = Highlighted
				End If
				If LastSelected > - 1 SendEvent(ifsoGUI_EVENT_CHANGE, HighLighted, -1, -1)
			Else
				If LastSelected > - 1 Columns[0].Rows[LastSelected].Selected = False
				LastSelected = Highlighted
				If LastSelected > - 1
				 Columns[0].Rows[LastSelected].Selected = True
					SendEvent(ifsoGUI_EVENT_CHANGE, LastSelected, -1, -1)
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
		If NumRows > 0
			If Highlighted = -1 Highlighted = LastSelected
			If Highlighted = -1 Highlighted = Topitem
		Else
			Highlighted = -1
		End If
		If Not IsMySlave(LostFocus) SendEvent(ifsoGUI_EVENT_GAIN_FOCUS, 0, 0, 0)
	End Method
	Rem
		bbdoc: Rebuilds the column gadgets array.  Called whenever a column is created, or the listbox is resized, or
									a columns ShowGadgets property is changed.  Set the iColumn parameter to -1 to do all columns.
		Internal function should not be called by the user.
	End Rem
	Method RebuildGadgets(iColumn:Int)
		If iColumn >= Columns.Length Return
		If iColumn >= 0
			Columns[iColumn].RebuildGadgets()
			Columns[iColumn].RefreshGadgets(True)
		Else
			For Local i:Int = 0 To Columns.Length - 1
				Columns[i].RebuildGadgets()
			Next
			For Local i:Int = 0 To Columns.Length - 1
				Columns[i].RefreshGadgets(True)
			Next
		End If
	End Method
	Rem
		bbdoc:Refreshes the values shown in the column gadgets.
								If iGeo is set to true, gadgets size and position are refreshed, if false, then just values are updated.
		about:internal function, should not be called by the user.
	End Rem
	Method RefreshGadgets(iColumn:Int, iGeo:Int)
		If iColumn >= Columns.Length Return
		If iColumn >= 0
			Columns[iColumn].RefreshGadgets(iGeo)
		Else
			For Local i:Int = 0 To Columns.Length - 1
				Columns[i].RefreshGadgets(iGeo)
			Next
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
		If ShowRowHeader
			Widest = RowHeadWidth
		Else
			Widest = 0
		End If
		For Local i:Int = 0 To Columns.Length - 1
			Widest:+Columns[i].w
		Next
		Local wasFont:TImageFont = GetImageFont()
		If fFont
			SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		ItemHeight = ifsoGUI_VP.GetTextHeight(Self) + 1
		If UserRowHeight > ItemHeight ItemHeight = UserRowHeight
		If HeaderFont
			SetImageFont(HeaderFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		ColHeadHeight = ifsoGUI_MCLColumn.gImage.h[1] + ifsoGUI_MCLColumn.gImage.h[7] + ifsoGUI_VP.GetTextHeight(Self)
		If ColHeadHeight < UserHeadHeight ColHeadHeight = UserHeadHeight
		If ShowRowHeader
			If ItemHeight < ColHeadHeight ItemHeight = ColHeadHeight
		End If
		For Local i:Int = 0 To Columns.Length - 1
			If ItemHeight < Columns[i].MinHeight ItemHeight = Columns[i].MinHeight
		Next
		RowHeadWidth = ifsoGUI_MCLColumn.gImage.w[3] + ifsoGUI_MCLColumn.gImage.w[5] + (ifsoGUI_VP.GetTextWidth("0", Self) * String(NumRows).Length)
		If UserHeadWidth > RowHeadWidth RowHeadWidth = UserHeadWidth
		SetImageFont(wasFont)
		If Columns.Length > 0
			Columns[0].h = ColHeadHeight
			If ShowRowHeader
				Columns[0].x = RowHeadWidth
			Else
				Columns[0].x = 0
			End If
			For Local i:Int = 1 To Columns.Length - 1
				Columns[i].x = Columns[i - 1].x + Columns[i - 1].w
				Columns[i].h = ColHeadHeight
			Next
		End If
		If Columns.Length > 0
			NumRows = Columns[0].Rows.Length
		Else
			NumRows = 0
		End If
		HBar.SetXY(0, h - (ScrollBarWidth + BorderTop + BorderBottom))
		VBar.SetXY(w - (ScrollBarWidth + BorderLeft + BorderRight), 0)
		If Highlighted < 0 And NumRows > 0 Highlighted = 0
		VBarOn = False
		HBarOn = False
		If VScrollbar = 1 VBarOn = True
		If HScrollbar = 1 HBarOn = True
		For Local i:Int = 0 To 1
			If Not VBarOn
				If VScrollbar = 2
					If HBarOn
						If NumRows * ItemHeight > h - (BorderTop + BorderBottom + ScrollbarWidth) VBarOn = True
					Else
						If NumRows * ItemHeight > h - (BorderTop + BorderBottom) VBarOn = True
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
		Local tmp:Int = h - (BorderTop + BorderBottom)
		If HBarOn tmp:-ScrollBarWidth
		If ShowColumnHeader tmp:-ColHeadHeight
		Local wasVis:Int = VisibleRows 'Remember this, if it changes, have to call RebuildGadgets
		VisibleRows = tmp / ItemHeight
		Local imax:Int = NumRows
		If imax < 1 imax = 1
		Local iInt:Int = VisibleRows
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
		If TopItem + VisibleRows >= NumRows TopItem = NumRows - VisibleRows
		If TopItem < 0 TopItem = 0
		If wasVis <> VisibleRows
		 RebuildGadgets(-1)
		Else
			RefreshGadgets(-1, True)
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
			 	If TopItem <> data
						TopItem = data
						RefreshGadgets(-1, False)
					End If
				Else
					Local s:String[] = gadget.Name.Split("_")
					Local col:Int = Int(s[s.Length - 2])
					Local row:Int = Int(s[s.Length - 1])
					If row = -1
						row = ActiveCellRow
					Else
					 row:+TopItem
					End If
					Select Columns[col].CType
						Case ifsoGUI_COLUMNTYPE_CHECKBOX
							Columns[col].Rows[row].Value = String(data)
						Case ifsoGUI_COLUMNTYPE_TEXTBOX
							Columns[col].Rows[row].Value = ifsoGUI_TextBox(gadget).GetText()
							ifsoGUI_TextBox(gadget).SetCursorPosition(0)
						Case ifsoGUI_COLUMNTYPE_SLIDER
							Columns[col].Rows[row].Value = String(data)
						Case ifsoGUI_COLUMNTYPE_COMBOBOX
							Columns[col].Rows[row].Value = String(data)
					End Select
					SendEvent(ifsoGUI_EVENT_CELL_CHANGE, data, col, row)
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
				If ActiveCellCol >= 0 And ActiveCellRow >= 0
					If Not Columns[ActiveCellCol].bShowGadget Slaves.Remove(gadget)
				End If
				ActiveCellCol = -1
				ActiveCellRow = -1
			Case ifsoGUI_EVENT_RESIZE
				For Local i:Int = 0 To Columns.Length - 1
					If Columns[i] = gadget
						Refresh()
						SendEvent(ifsoGUI_EVENT_RESIZE, i, iMouseX, iMouseY)
						Exit
					End If
				Next
			Case ifsoGUI_EVENT_CLICK
				For Local i:Int = 0 To Columns.Length - 1
					If Columns[i] = gadget
						SendEvent(ifsoGUI_EVENT_CLICK, 0, i, -2)
					End If
				Next
		End Select
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("mclistbox").Split(",")
		Load9Image2("/graphics/mclistbox.png", dimensions, gImage)
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
		bbdoc: Adds a column to the ListBox.  Set iIndex to -1 to add a column at the end (default=-1).
	End Rem
	Method AddColumn(strTitle:String, iWidth:Int = 80, iType:Int = ifsoGUI_COLUMNTYPE_LABEL, strDefault:String = "", iIndex:Int = -1)
		If iIndex = -1 iIndex = Columns.Length
		If iIndex > Columns.Length iIndex = Columns.Length
		Local col:ifsoGUI_MCLColumn = New ifsoGUI_MCLColumn
		col.Label = strTitle
		col.CType = iType
		Select iType
			Case ifsoGUI_COLUMNTYPE_CHECKBOX
				col.Gadget = ifsoGUI_CheckBox.Create(0, 0, 0, 0, Name + "_" + iIndex + "_-1", "")
				col.Gadget.SetFont(fFont)
				col.Gadget.SetWH(0, 0)
				col.MinHeight = col.Gadget.h
				col.bShowgadget = True
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				col.Gadget = ifsoGUI_ProgressBar.Create(0, 0, 0, 0, Name + "_" + iIndex + "_-1")
				col.Gadget.SetWH(0, 0)
				col.MinHeight = col.Gadget.h
				col.bShowgadget = True
			Case ifsoGUI_COLUMNTYPE_SLIDER
				col.Gadget = ifsoGUI_Slider.Create(0, 0, 0, Name + "_" + iIndex + "_-1")
				col.Gadget.ShowFocus = False
				col.Gadget.SetFont(fFont)
				col.Gadget.SetWH(0, 0)
				col.MinHeight = col.Gadget.h + 3
				col.bShowgadget = True
			Case ifsoGUI_COLUMNTYPE_COMBOBOX
				col.Gadget = ifsoGUI_Combobox.Create(0, 0, 0, 0, Name + "_" + iIndex + "_-1")
				col.Gadget.SetFont(fFont)
				col.Gadget.SetWH(0, 0)
				col.MinHeight = col.Gadget.h
			Case ifsoGUI_COLUMNTYPE_TEXTBOX
				col.Gadget = ifsoGUI_TextBox.Create(0, 0, 0, 0, Name + "_" + iIndex + "_-1")
				col.Gadget.SetFont(fFont)
				col.Gadget.SetWH(0, 0)
				col.MinHeight = col.Gadget.h
			Default
				col.CType = ifsoGUI_COLUMNTYPE_LABEL
				col.IsReadOnly = True
		End Select
		col.DefaultValue = strDefault
		col.w = iWidth
		Columns = Columns[..Columns.Length + 1]
		For Local i:Int = Columns.Length - 2 To iIndex Step - 1
			Columns[i + 1] = Columns[i]
		Next
		Columns[iIndex] = col
		For Local i:Int = 0 To NumRows - 1
			Columns[iIndex].Rows[i].Tip = ""
			Columns[iIndex].Rows[i].Value = Columns[iIndex].DefaultValue
			If iIndex = 0 And Columns.Length >= 2
				Columns[iIndex].Rows[i].Selected = Columns[1].Rows[i].Selected
			Else
				Columns[iIndex].Rows[i].Selected = False
			End If
		Next
		For Local i:Int = 0 To Columns.Length - 1
			Columns[i].Name = Name + "_-1_" + i
		Next
		col.Master = Self
		col.lImage = colImage
		col.lImageDown = colImageDown
		col.lImageOver = colImageOver
		col.lTileSides = colTileSides
		col.lTileCenter = colTileCenter
		col.Refresh()
		Slaves.AddLast(col)
		Refresh()
		RebuildGadgets(-1)
	End Method
	Rem
		bbdoc: Adds a Row to the listbox. Set iIndex=-1 to add a row at the end.
	End Rem
	Method AddRow(iIndex:Int = -1)
		Local row:ifsoGUI_MCLCell
		If Columns.Length <= 0 Return
		If iIndex = -1 iIndex = NumRows
		For Local i:Int = 0 To Columns.Length - 1
			Columns[i].Rows = Columns[i].Rows[..NumRows + 1]
			For Local j:Int = NumRows - 2 To iIndex Step - 1
				Columns[i].Rows[j + 1] = Columns[i].Rows[j]
			Next
			row = New ifsoGUI_MCLCell
			row.Tip = ""
			row.Selected = False
			row.Value = Columns[i].DefaultValue
			row.IsReadOnly = Columns[i].IsReadOnly
			Columns[i].Rows[iIndex] = row
		Next
		NumRows:+1
		Refresh()
	End Method
	Rem
	bbdoc: Adds a combobox item to a combobox column.
	End Rem
	Method AddComboboxItem(iColumn:Int, strName:String, intData:Int, strTip:String)
		If iColumn >= Columns.Length Return
		Columns[iColumn].AddItem(strName, intData, strTip)
	End Method
	Rem
	bbdoc: Inserts a combobox item to a combobox column.
	End Rem
	Method InsertComboboxItem(iColumn:Int, intIndex:Int, strName:String, intData:Int, strTip:String)
		If iColumn >= Columns.Length Return
		Columns[iColumn].InsertItem(intIndex, strName, intData, strTip)
	End Method
	Rem
	bbdoc: Removes a combobox item from a combobox column.
	End Rem
	Method RemoveComboboxItem(iColumn:Int, intIndex:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].RemoveItem(intIndex:Int)
	End Method
	Rem
	bbdoc: Removes all items from a combobox column.
	End Rem
	Method RemoveAllComboboxItems(iColumn:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].RemoveAll()
	End Method
	Rem
	bbdoc: Sets the number of items that appear in the combobox dropdown of a combobox column.
	End Rem
	Method SetComboboxShowItems(iColumn:Int, iNumItems:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetShowItems(iNumItems)
	End Method
	Rem
	bbdoc: Returns the number of items that appear in the combobox dropdown of a combobox column.
	End Rem
	Method GetComboboxShowItems:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetShowItems()
	End Method
	Rem
	bbdoc: Returns the number of items visible at a time in the listbox.
	End Rem
	Method GetVisibleRows:Int()
		Return VisibleRows
	End Method
	Rem
	bbdoc: Removes a row from the listbox.
	End Rem
	Method RemoveRow(iRow:Int)
		If Columns.Length <= 0 Return
		If NumRows <= iRow Return
		For Local i:Int = 0 To Columns.Length - 1
			For Local j:Int = iRow To NumRows - 2
				Columns[i].Rows[j] = Columns[i].Rows[j + 1]
			Next
			Columns[i].Rows = Columns[i].Rows[..numRows - 1]
		Next
		NumRows:-1
		If LastSelected = iRow LastSelected = -1
		If LastSelected > iRow LastSelected:-1
		If Highlighted > iRow Highlighted:-1
		If Highlighted > NumRows - 2 Highlighted = NumRows - 2
		If Topitem > 0 And TopItem + VisibleRows - 1 > NumRows - 2 TopItem:-1
		Refresh()
	End Method
	Rem
	bbdoc: Removes a column from the listbox.
	End Rem
	Method RemoveColumn(iColumn:Int)
		If iColumn >= Columns.Length Return
		If iColumn = 0 And Columns.Length > 1
			For Local j:Int = 0 To NumRows - 1
				Columns[1].Rows[j].Selected = Columns[0].Rows[j].Selected
			Next
		End If
		Slaves.Remove(Columns[iColumn])
		For Local i:Int = iColumn To NumRows - 2
			Columns[i] = Columns[i + 1]
		Next
		Columns = Columns[..Columns.Length - 1]
		For Local i:Int = 0 To Columns.Length - 1
			Columns[i].Name = Name + "_COL_" + i
		Next
		If Columns.Length <= 0 NumRows = 0
	End Method
	Rem
	bbdoc: Removes all Rows from the listbox.
	End Rem
	Method RemoveAllRows()
		For Local i:Int = 0 To Columns.Length - 1
			Columns[i].Rows = Null
		Next
		Highlighted = -1
		LastSelected = -1
		TopItem = 0
		NumRows = 0
		Refresh()
	End Method
	Rem
	bbdoc: Removes all Columns from the listbox.
	End Rem
	Method RemoveAllColumns()
		Columns = Null
		Slaves.Clear()
		Highlighted = -1
		LastSelected = -1
		TopItem = 0
		NumRows = 0
		Refresh()
	End Method
	Rem
	bbdoc: Sets whether or not multiple items can be selected.
	End Rem
	Method SetMultiSelect(bMultiSelect:Int)
		MultiSelect = bMultiSelect
		If Not MultiSelect
			For Local i:Int = 0 To NumRows - 1
				If i <> LastSelected Columns[0].Rows[i].Selected = False
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
	bbdoc: Returns whether the row is selected or not.
	End Rem
	Method GetRowSelected:Int(iRow:Int)
		If iRow >= NumRows Return False
		Return Columns[0].Rows[iRow].Selected
	End Method
	Rem
	bbdoc: Sets the active cell.  Returns True or False whether the cell was activated.
	End Rem
	Method SetActiveCell:Int(iColumn:Int, iRow:Int)
		If iColumn >= 0 And iColumn < Columns.Length And iRow >= 0 And iRow < NumRows
			If Columns[iColumn].ActivateCell(iRow)
				Columns[iColumn].Gadget.SetFocus()
				ActiveCellCol = iColumn
				ActiveCellRow = iRow
				Columns[iColumn].Gadget.Master = Self
				Slaves.AddLast(Columns[iColumn].Gadget)
				Return True
			End If
		End If
		ActiveCellCol = -1
		ActiveCellRow = -1
		Return False
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
		If caller <> Self And caller <> VBar And caller <> HBar
			iX:-OriginX
		End If
		If caller <> Self And ShowBorder
		 iX:+BorderLeft
		 iY:+BorderTop
		End If
	End Method
	Rem
	bbdoc: Returns the active cell.
	End Rem
	Method GetActiveCell(iColumn:Int Var, iRow:Int Var)
		iColumn = ActiveCellCol
		iRow = ActiveCellRow
	End Method
	Rem
	bbdoc: Sets the Readonly property of the cell.
	End Rem
	Method SetCellReadOnly(iColumn:Int, iRow:Int, bReadOnly:Int)
		If iColumn >= Columns.Length Return
		If iRow >= NumRows Return
		Columns[iColumn].Rows[iRow].IsReadOnly = bReadOnly
	End Method
	Rem
	bbdoc: Returns the ReadOnly property of the cell.
	End Rem
	Method GetCellReadOnly:Int(iColumn:Int, iRow:Int)
		If iColumn >= Columns.Length Return Null
		If iRow >= NumRows Return Null
		Return Columns[iColumn].Rows[iRow].IsReadOnly
	End Method
	Rem
	bbdoc: Sets the Data of the cell.
	End Rem
	Method SetCellData(iColumn:Int, iRow:Int, iData:Int)
		If iColumn >= Columns.Length Return
		If iRow >= NumRows Return
		Columns[iColumn].Rows[iRow].Data = iData
	End Method
	Rem
	bbdoc: Returns the data of the cell.
	End Rem
	Method GetCellData:Int(iColumn:Int, iRow:Int)
		If iColumn >= Columns.Length Return Null
		If iRow >= NumRows Return Null
		Return Columns[iColumn].Rows[iRow].Data
	End Method
	Rem
	bbdoc: Sets the tip of the cell.
	End Rem
	Method SetCellTip(iColumn:Int, iRow:Int, strTip:String)
		If iColumn >= Columns.Length Return
		If iRow >= NumRows Return
		Columns[iColumn].Rows[iRow].Tip = strTip
	End Method
	Rem
	bbdoc: Returns the tip of the cell.
	End Rem
	Method GetCellTip:String(iColumn:Int, iRow:Int)
		If iColumn >= Columns.Length Return Null
		If iRow >= NumRows Return Null
		Return Columns[iColumn].Rows[iRow].Tip
	End Method
	Rem
	bbdoc: Sets the Readonly property of all cells in the column.
	End Rem
	Method SetColumnReadOnly(iColumn:Int, bReadOnly:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].IsReadOnly = bReadOnly
		For Local i:Int = 0 To NumRows - 1
			Columns[iColumn].Rows[i].IsReadOnly = bReadOnly
		Next
		RefreshGadgets(iColumn, True)
	End Method
	Rem
	bbdoc: Returns the ReadOnly property of the column.
	End Rem
	Method GetColumnReadOnly:Int(iColumn:Int)
		If iColumn >= Columns.Length Return Null
		Return Columns[iColumn].IsReadOnly
	End Method
	Rem
	bbdoc: Sets the Readonly property of all cells in the row.
	End Rem
	Method SetRowReadOnly(iRow:Int, bReadOnly:Int)
		If iRow >= NumRows Return
		For Local i:Int = 0 To Columns.Length - 1
			Columns[i].Rows[iRow].IsReadOnly = bReadOnly
		Next
	End Method
	Rem
	bbdoc: Sets the row selected/unselected.
	End Rem
	Method SetSelected(iRow:Int, bSelected:Int)
		If iRow >= NumRows Return
		If (Not MultiSelect) And bSelected
			For Local i:Int = 0 To NumRows - 1
				Columns[0].Rows[i].Selected = False
			Next
		End If
		Columns[0].Rows[iRow].Selected = bSelected
		LastSelected = iRow
	End Method
	Rem
	bbdoc: Gets the last selected row.
	End Rem
	Method GetSelectedRow:Int()
		Return LastSelected
	End Method
	Rem
	bbdoc: Gets the cells value (string).
	End Rem
	Method GetCellValueString:String(iColumn:Int, iRow:Int)
		If iColumn >= Columns.Length Return Null
		If iRow >= NumRows Return Null
		Return Columns[iColumn].Rows[iRow].Value
	End Method
	Rem
	bbdoc: Gets the cells value (int).
	End Rem
	Method GetCellValueInt:Int(iColumn:Int, iRow:Int)
		If iColumn >= Columns.Length Return 0
		If iRow >= NumRows Return 0
		Return Int(Columns[iColumn].Rows[iRow].Value)
	End Method
	Rem
	bbdoc: Sets the cells value (string).
	End Rem
	Method SetCellValueString(iColumn:Int, iRow:Int, strValue:String)
		If iColumn >= Columns.Length Return
		If iRow >= NumRows Return
		Columns[iColumn].Rows[iRow].Value = strValue
		If Columns[iColumn].bShowGadget RefreshGadgets(iColumn, False)
	End Method
	Rem
	bbdoc: Sets the cells value (int).
	End Rem
	Method SetCellValueInt(iColumn:Int, iRow:Int, iValue:Int)
		If iColumn >= Columns.Length Return
		If iRow >= NumRows Return
		If Columns[iColumn].Rows[iRow].IsReadOnly Return
		Columns[iColumn].Rows[iRow].Value = String(iValue)
		If Columns[iColumn].bShowGadget RefreshGadgets(iColumn, False)
	End Method
	Rem
	bbdoc: Returns if the Columns can be resized.
	End Rem
	Method GetColumnsResizable:Int()
		Return ColumnsResizable
	End Method
	Rem
	bbdoc: Sets if the columns can be resized.
	End Rem
	Method SetColumnsResizable(bResize:Int)
		ColumnsResizable = bResize
	End Method
	Rem
	bbdoc: Returns the Columns Min Width.
	End Rem
	Method GetColumnMinWidth:Int(iColumn:Int)
		If iColumn >= Columns.Length Return - 1
		Return Columns[iColumn].MinWidth
	End Method
	Rem
	bbdoc: Sets a progressbar columns bar color.
	End Rem
	Method SetColumnBarColor(iColumn:Int, iRed:Int, iGreen:Int, iBlue:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetBarColor(iRed, iGreen, iBlue)
	End Method
	Rem
	bbdoc: Sets a progressbar columns bar direction.
	End Rem
	Method SetColumnBarReversed(iColumn:Int, iReversed:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetBarReversed(iReversed)
	End Method
	Rem
	bbdoc: Returns a progressbar columns bar direction.
	End Rem
	Method GetColumnBarReversed:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetBarReversed()
	End Method
	Rem
	bbdoc: Returns the Alignment of the column cell text.
	End Rem
	Method GetColumnCellAlign:Int(iColumn:Int)
		If iColumn >= Columns.Length Return - 1
		Return Columns[iColumn].CellAlign
	End Method
	Rem
	bbdoc: Sets the Columns cell text alignment.
	End Rem
	Method SetColumnCellAlign(iColumn:Int, iAlign:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].CellAlign = iAlign
	End Method
	Rem
	bbdoc: Sets a slider columns direction value.
	End Rem
	Method SetColumnDirection(iColumn:Int, iDirection:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetDirection(iDirection)
	End Method
	Rem
	bbdoc: Returns a slider columns direction value.
	End Rem
	Method GetColumnDirection:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetDirection()
	End Method
	Rem
	bbdoc: Sets a progressbar columns drawstyle.
	End Rem
	Method SetColumnDrawStyle(iColumn:Int, iDrawStyle:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetDrawStyle(iDrawStyle)
	End Method
	Rem
	bbdoc: Returns a progressbar columns drawstyle.
	End Rem
	Method GetColumnDrawStyle:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetDrawStyle()
	End Method
	Rem
	bbdoc: Returns the Alignment of the column header text.
	End Rem
	Method GetColumnHeaderAlign:Int(iColumn:Int)
		If iColumn >= Columns.Length Return - 1
		Return Columns[iColumn].HeaderAlign
	End Method
	Rem
	bbdoc: Sets the Columns header text alignment.
	End Rem
	Method SetColumnHeaderAlign(iColumn:Int, iAlign:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].HeaderAlign = iAlign
	End Method
	Rem
	bbdoc: Sets a slider columns interval value.
	End Rem
	Method SetColumnInterval(iColumn:Int, iInterval:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetInterval(iInterval)
	End Method
	Rem
	bbdoc: Returns a slider columns interval value.
	End Rem
	Method GetColumnInterval:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetInterval()
	End Method
	Rem
	bbdoc: Returns the Columns Max Width.
	End Rem
	Method GetColumnMaxWidth:Int(iColumn:Int)
		If iColumn >= Columns.Length Return - 1
		Return Columns[iColumn].MaxWidth
	End Method
	Rem
	bbdoc: Sets the columns maximum value.
	End Rem
	Method SetColumnMax(iColumn:Int, iMax:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetMax(iMax)
	End Method
	Rem
	bbdoc: Returns the columns maximum value.
	End Rem
	Method GetColumnMax:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetMax()
	End Method
	Rem
	bbdoc: Sets the columns minimum value.
	End Rem
	Method SetColumnMin(iColumn:Int, iMin:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetMin(iMin)
	End Method
	Rem
	bbdoc: Returns the columns minimum value.
	End Rem
	Method GetColumnMin:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetMin()
	End Method
	Rem
	bbdoc: Sets the columns minimum and maximum values.
	End Rem
	Method SetColumnMinMax(iColumn:Int, iMin:Int, iMax:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetMinMax(iMin, iMax)
	End Method
	Rem
	bbdoc: Sets the Columns Min and Max Width.
	End Rem
	Method SetColumnMinMaxWidth(iColumn:Int, iMin:Int, iMax:Int)
		If iColumn >= Columns.Length Return
		If iMin > BorderLeft + BorderRight Columns[iColumn].MinWidth = iMin
		Columns[iColumn].MaxWidth = iMax
		If Columns[iColumn].MaxWidth < Columns[iColumn].MinWidth = iMin Columns[iColumn].MaxWidth = Columns[iColumn].MinWidth
		If Columns[iColumn].w < Columns[iColumn].MinWidth
			Columns[iColumn].w = Columns[iColumn].MinWidth
			RefreshGadgets(-1, True)
		ElseIf Columns[iColumn].w > Columns[iColumn].MaxWidth
			Columns[iColumn].w = Columns[iColumn].MaxWidth
			RefreshGadgets(-1, True)
		End If
	End Method
	Rem
	bbdoc: Gets the columns default value.
	End Rem
	Method GetColumnDefaultValue:String(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].DefaultValue
	End Method
	Rem
	bbdoc: Sets the columns default value.
	End Rem
	Method SetColumnDefaultValue(iColumn:Int, strValue:String)
		If iColumn >= Columns.Length Return
		Columns[iColumn].DefaultValue = strValue
	End Method
	Rem
	bbdoc: Sets a slider columns ShowTicks value.
	End Rem
	Method SetColumnShowTicks(iColumn:Int, bShowTicks:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetShowTicks(bShowTicks)
	End Method
	Rem
	bbdoc: Returns a slider columns ShowTicks value.
	End Rem
	Method GetColumnShowTicks:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetShowTicks()
	End Method
	Rem
	bbdoc: Returns the number of rows in the list.
	End Rem
	Method GetRowCount:Int()
		Return NumRows
	End Method
	Rem
	bbdoc: Returns the number of columns in the list.
	End Rem
	Method GetColumnCount:Int()
		Return Columns.Length
	End Method
	Rem
	bbdoc: Returns the cell the mouse is over.
	End Rem
	Method GetOverCell(iColumn:Int Var, iRow:Int Var)
		iColumn = OverCol
		iRow = OverRow
	End Method
	Rem
	bbdoc: Sets the row height.  If requested height is less than the minimum, minimum is set.
	End Rem
	Method SetRowHeight(iRowHeight:Int)
		UserRowHeight = iRowHeight
		Refresh()
	End Method
	Rem
	bbdoc: Returns the requested row height.
	End Rem
	Method GetRowHeight:Int()
		Return UserRowHeight
	End Method
	Rem
	bbdoc: Returns the actual row height.
	End Rem
	Method GetActualRowHeight:Int()
		Return ItemHeight
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
	bbdoc: Sets the Column Header Height.
	End Rem
	Method SetHeaderColumnHeight(iHeight:Int)
		UserHeadHeight = iHeight
		Refresh()
	End Method
	Rem
	bbdoc: Returns the requested column header height
	End Rem
	Method GetHeaderColumnHeight:Int()
		Return UserHeadHeight
	End Method
	Rem
	bbdoc: Returns the actual column header height
	End Rem
	Method GetHeaderActualColumnHeight:Int()
		Return ColHeadHeight
	End Method
	Rem
	bbdoc: Sets the Row Header Width.
	End Rem
	Method SetHeaderRowWidth(iWidth:Int)
		UserHeadWidth = iWidth
		Refresh()
	End Method
	Rem
	bbdoc: Returns the requested row header width
	End Rem
	Method GetHeaderRowWidth:Int()
		Return UserHeadWidth
	End Method
	Rem
	bbdoc: Returns the actual row header width
	End Rem
	Method GetHeaderActualRowWidth:Int()
		Return RowHeadWidth
	End Method
	Rem
	bbdoc: Sets the gadget enabled/disabled.
	End Rem
	Method SetEnabled(bEnabled:Int = True) 'Sets the gadget enabled or not.
		Super.SetEnabled(bEnabled)
		If Not bEnabled
			OverCol = -1
			OverRow = -1
		End If
	End Method
	Rem
	bbdoc: Sets the font of the gadget.
	about: Set to Null to use the default GUI font.
	End Rem
	Method SetFont(Font:TImageFont) 'Set the font of the gadget
	 fFont = Font
		RebuildGadgets(-1)
		Refresh()
	End Method
	Rem
	bbdoc: Sets the grid color.
	End Rem
	Method SetGridColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of highlighted item
		GridColor[0] = iRed
		GridColor[1] = iGreen
		GridColor[2] = iBlue
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
	Method SetColumnShowBorder(iColumn:Int, bShowBorder:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetShowBorder(bShowBorder)
	End Method
	Rem
	bbdoc: Returns whether or not the border is showing.
	End Rem
	Method GetColumnShowBorder:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].GetShowBorder()
	End Method
	Rem
	bbdoc: Returns whether or not the grid is showing.
	End Rem
	Method GetShowGrid:Int()
		Return ShowGrid
	End Method
	Rem
	bbdoc: Sets whether or not the column head buttons will show.
	End Rem
	Method SetShowGrid(bShowGrid:Int)
		ShowGrid = bShowGrid
	End Method
	Rem
	bbdoc: Sets what data from the combobox appears in the column.  Only applies to Combobox columns.
	End Rem
	Method SetColumnShowComboboxData(iColumn:Int, iData:Int)
		If iColumn >= Columns.Length Return
		Columns[iColumn].SetShowComboboxData(iData)
	End Method
	Rem
	bbdoc: Returns what data from the combobox appears in the column. Only applies to Combobox columns.
	End Rem
	Method GetColumnShowComboboxData:Int(iColumn:Int)
		If iColumn >= Columns.Length Return 0
		Return Columns[iColumn].ShowComboData
	End Method
	Rem
	bbdoc: Sets whether or not the columns gadgets will show.
	End Rem
	Method SetColumnShowGadgets(iColumn:Int, bShowColumnGadgets:Int)
		If iColumn >= Columns.Length Return
		If bShowColumnGadgets = Columns[iColumn].bShowGadget Return
		Columns[iColumn].bShowGadget = bShowColumnGadgets
		RebuildGadgets(iColumn)
	End Method
	Rem
	bbdoc: Returns whether or not the columns gadgets are showing.
	End Rem
	Method GetColumnShowGadgets:Int(iColumn:Int)
		If iColumn >= Columns.Length Return False
		Return Columns[iColumn].bShowGadget
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
	Method GetShowBorder:Int(iColumn:Int)
		Return ShowBorder
	End Method
	Rem
	bbdoc: Sets whether or not the column head buttons will show.
	End Rem
	Method SetShowColumnHeaders(bShowColumnHeaders:Int)
		If ShowColumnHeader = bShowColumnHeaders Return
		ShowColumnHeader = bShowColumnHeaders
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the column head buttons are showing.
	End Rem
	Method GetShowColumnHeaders:Int()
		Return ShowColumnHeader
	End Method
	Rem
	bbdoc: Sets whether or not the row head buttons will show.
	End Rem
	Method SetShowRowHeaders(bShowRowHeaders:Int)
		If ShowRowHeader = bShowRowHeaders Return
		ShowRowHeader = bShowRowHeaders
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the row head buttons are showing.
	End Rem
	Method GetShowRowHeaders:Int()
		Return ShowRowHeader
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
		HBar.SetValue(0)
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
		bbdoc: Used to sort the list by the Value field
	End Rem
	Method FastQuickSort(iCol:Int)
		QuickSort(iCol, 0, NumRows - 1, Self)
		InsertionSort(iCol, 0, NumRows - 1, Self)
	
		Function QuickSort(iCol:Int, l:Int, r:Int, mclb:ifsoGUI_MCListBox)
			If (r - l) > 4
				Local i:Int, j:Int, v:String
				i = (r + l) / 2
				If (mclb.Columns[iCol].Rows[l].Value > mclb.Columns[iCol].Rows[i].Value) mclb.Swap(l, i)
				If (mclb.Columns[iCol].Rows[l].Value > mclb.Columns[iCol].Rows[r].Value) mclb.Swap(l, r)
				If (mclb.Columns[iCol].Rows[i].Value > mclb.Columns[iCol].Rows[r].Value) mclb.Swap(i, r)
				j = r - 1
				mclb.Swap(i, j)
				i = l
				v = mclb.Columns[iCol].Rows[j].Value
				Repeat
					i:+1
					While mclb.Columns[iCol].Rows[i].Value < v ; i:+1; Wend
					j:-1
					While mclb.Columns[iCol].Rows[j].Value > v ; j:-1;Wend
					If (j < i) Exit
					mclb.Swap (i, j)
				Forever
				mclb.Swap(i, r - 1)
				QuickSort(iCol, l, j, mclb)
				QuickSort(iCol, i + 1, r, mclb)
			End If
		End Function
	
		Function InsertionSort(iCol:Int, lo0:Int, hi0:Int, mclb:ifsoGUI_MCListBox)
			Local length:Int = mclb.Columns.Length
			Local i:Int, j:Int, v:ifsoGUI_MCLCell[]
			v = v[..length]
			For Local z:Int = 0 To length - 1
				v[z] = New ifsoGUI_MCLCell
			Next
			For i = lo0 + 1 To hi0
				For Local z:Int = 0 To length - 1
					v[z] = mclb.Columns[z].Rows[i]
				Next
				j = i
				While (j > lo0) And (mclb.Columns[iCol].Rows[j - 1].Value > v[iCol].Value)
					For Local z:Int = 0 To mclb.Columns.Length - 1
						mclb.Columns[z].Rows[j] = mclb.Columns[z].Rows[j - 1]
					Next
	    j:-1
				Wend
				For Local z:Int = 0 To length - 1
					mclb.Columns[z].Rows[j] = v[z]
				Next
			Next
		End Function
	End Method
	Rem
		bbdoc: Used to sort the list by the Value field but treated as an integer.
	End Rem
	Method FastQuickSortInt(iCol:Int)
		QuickSort(iCol, 0, NumRows - 1, Self)
		InsertionSort(iCol, 0, NumRows - 1, Self)
	
		Function QuickSort(iCol:Int, l:Int, r:Int, mclb:ifsoGUI_MCListBox)
			If (r - l) > 4
				Local i:Int, j:Int, v:Int
				i = (r + l) / 2
				If (Int(mclb.Columns[iCol].Rows[l].Value) > Int(mclb.Columns[iCol].Rows[i].Value)) mclb.Swap(l, i)
				If (Int(mclb.Columns[iCol].Rows[l].Value) > Int(mclb.Columns[iCol].Rows[r].Value)) mclb.Swap(l, r)
				If (Int(mclb.Columns[iCol].Rows[i].Value) > Int(mclb.Columns[iCol].Rows[r].Value)) mclb.Swap(i, r)
				j = r - 1
				mclb.Swap(i, j)
				i = l
				v = Int(mclb.Columns[iCol].Rows[j].Value)
				Repeat
					i:+1
					While Int(mclb.Columns[iCol].Rows[i].Value) < v ; i:+1; Wend
					j:-1
					While Int(mclb.Columns[iCol].Rows[j].Value) > v ; j:-1;Wend
					If (j < i) Exit
					mclb.Swap (i, j)
				Forever
				mclb.Swap(i, r - 1)
				QuickSort(iCol, l, j, mclb)
				QuickSort(iCol, i + 1, r, mclb)
			End If
		End Function
	
		Function InsertionSort(iCol:Int, lo0:Int, hi0:Int, mclb:ifsoGUI_MCListBox)
			Local length:Int = mclb.Columns.Length
			Local i:Int, j:Int, v:ifsoGUI_MCLCell[]
			v = v[..length]
			For Local z:Int = 0 To length - 1
				v[z] = New ifsoGUI_MCLCell
			Next
			For i = lo0 + 1 To hi0
				For Local z:Int = 0 To length - 1
					v[z] = mclb.Columns[z].Rows[i]
				Next
				j = i
				While (j > lo0) And (Int(mclb.Columns[iCol].Rows[j - 1].Value) > Int(v[iCol].Value))
					For Local z:Int = 0 To mclb.Columns.Length - 1
						mclb.Columns[z].Rows[j] = mclb.Columns[z].Rows[j - 1]
					Next
	    j:-1
				Wend
				For Local z:Int = 0 To length - 1
					mclb.Columns[z].Rows[j] = v[z]
				Next
			Next
		End Function
	End Method
	Rem
		bbdoc: Used to sort the list by the Data field.
	End Rem
	Method FastQuickSortData(iCol:Int)
		QuickSort(iCol, 0, NumRows - 1, Self)
		InsertionSort(iCol, 0, NumRows - 1, Self)
	
		Function QuickSort(iCol:Int, l:Int, r:Int, mclb:ifsoGUI_MCListBox)
			If (r - l) > 4
				Local i:Int, j:Int, v:Int
				i = (r + l) / 2
				If (mclb.Columns[iCol].Rows[l].Data > mclb.Columns[iCol].Rows[i].Data) mclb.Swap(l, i)
				If (mclb.Columns[iCol].Rows[l].Data > mclb.Columns[iCol].Rows[r].Data) mclb.Swap(l, r)
				If (mclb.Columns[iCol].Rows[i].Data > mclb.Columns[iCol].Rows[r].Data) mclb.Swap(i, r)
				j = r - 1
				mclb.Swap(i, j)
				i = l
				v = mclb.Columns[iCol].Rows[j].Data
				Repeat
					i:+1
					While mclb.Columns[iCol].Rows[i].Data < v ; i:+1; Wend
					j:-1
					While mclb.Columns[iCol].Rows[j].Data > v ; j:-1;Wend
					If (j < i) Exit
					mclb.Swap (i, j)
				Forever
				mclb.Swap(i, r - 1)
				QuickSort(iCol, l, j, mclb)
				QuickSort(iCol, i + 1, r, mclb)
			End If
		End Function
	
		Function InsertionSort(iCol:Int, lo0:Int, hi0:Int, mclb:ifsoGUI_MCListBox)
			Local length:Int = mclb.Columns.Length
			Local i:Int, j:Int, v:ifsoGUI_MCLCell[]
			v = v[..length]
			For Local z:Int = 0 To length - 1
				v[z] = New ifsoGUI_MCLCell
			Next
			For i = lo0 + 1 To hi0
				For Local z:Int = 0 To length - 1
					v[z] = mclb.Columns[z].Rows[i]
				Next
				j = i
				While (j > lo0) And (mclb.Columns[iCol].Rows[j - 1].Data > v[iCol].Data)
					For Local z:Int = 0 To mclb.Columns.Length - 1
						mclb.Columns[z].Rows[j] = mclb.Columns[z].Rows[j - 1]
					Next
	    j:-1
				Wend
				For Local z:Int = 0 To length - 1
					mclb.Columns[z].Rows[j] = v[z]
				Next
			Next
		End Function
	End Method
	Rem
		bbdoc: Used to sort the list by the Value field descending.
	End Rem
	Method FastQuickSortDesc(iCol:Int)
		QuickSort(iCol, 0, NumRows - 1, Self)
		InsertionSort(iCol, 0, NumRows - 1, Self)
	
		Function QuickSort(iCol:Int, l:Int, r:Int, mclb:ifsoGUI_MCListBox)
			If (r - l) > 4
				Local i:Int, j:Int, v:String
				i = (r + l) / 2
				If (mclb.Columns[iCol].Rows[l].Value < mclb.Columns[iCol].Rows[i].Value) mclb.Swap(l, i)
				If (mclb.Columns[iCol].Rows[l].Value < mclb.Columns[iCol].Rows[r].Value) mclb.Swap(l, r)
				If (mclb.Columns[iCol].Rows[i].Value < mclb.Columns[iCol].Rows[r].Value) mclb.Swap(i, r)
				j = r - 1
				mclb.Swap(i, j)
				i = l
				v = mclb.Columns[iCol].Rows[j].Value
				Repeat
					i:+1
					While mclb.Columns[iCol].Rows[i].Value > v ; i:+1; Wend
					j:-1
					While mclb.Columns[iCol].Rows[j].Value < v ; j:-1;Wend
					If (j < i) Exit
					mclb.Swap (i, j)
				Forever
				mclb.Swap(i, r - 1)
				QuickSort(iCol, l, j, mclb)
				QuickSort(iCol, i + 1, r, mclb)
			End If
		End Function
	
		Function InsertionSort(iCol:Int, lo0:Int, hi0:Int, mclb:ifsoGUI_MCListBox)
			Local length:Int = mclb.Columns.Length
			Local i:Int, j:Int, v:ifsoGUI_MCLCell[]
			v = v[..length]
			For Local z:Int = 0 To length - 1
				v[z] = New ifsoGUI_MCLCell
			Next
			For i = lo0 + 1 To hi0
				For Local z:Int = 0 To length - 1
					v[z] = mclb.Columns[z].Rows[i]
				Next
				j = i
				While (j > lo0) And (mclb.Columns[iCol].Rows[j - 1].Value < v[iCol].Value)
					For Local z:Int = 0 To mclb.Columns.Length - 1
						mclb.Columns[z].Rows[j] = mclb.Columns[z].Rows[j - 1]
					Next
	    j:-1
				Wend
				For Local z:Int = 0 To length - 1
					mclb.Columns[z].Rows[j] = v[z]
				Next
			Next
		End Function
	End Method
	Rem
		bbdoc: Used to sort the list by the Value field descending but treated as an integer.
	End Rem
	Method FastQuickSortIntDesc(iCol:Int)
		QuickSort(iCol, 0, NumRows - 1, Self)
		InsertionSort(iCol, 0, NumRows - 1, Self)
	
		Function QuickSort(iCol:Int, l:Int, r:Int, mclb:ifsoGUI_MCListBox)
			If (r - l) > 4
				Local i:Int, j:Int, v:Int
				i = (r + l) / 2
				If (Int(mclb.Columns[iCol].Rows[l].Value) < Int(mclb.Columns[iCol].Rows[i].Value)) mclb.Swap(l, i)
				If (Int(mclb.Columns[iCol].Rows[l].Value) < Int(mclb.Columns[iCol].Rows[r].Value)) mclb.Swap(l, r)
				If (Int(mclb.Columns[iCol].Rows[i].Value) < Int(mclb.Columns[iCol].Rows[r].Value)) mclb.Swap(i, r)
				j = r - 1
				mclb.Swap(i, j)
				i = l
				v = Int(mclb.Columns[iCol].Rows[j].Value)
				Repeat
					i:+1
					While Int(mclb.Columns[iCol].Rows[i].Value) > v ; i:+1; Wend
					j:-1
					While Int(mclb.Columns[iCol].Rows[j].Value) < v ; j:-1;Wend
					If (j < i) Exit
					mclb.Swap (i, j)
				Forever
				mclb.Swap(i, r - 1)
				QuickSort(iCol, l, j, mclb)
				QuickSort(iCol, i + 1, r, mclb)
			End If
		End Function
	
		Function InsertionSort(iCol:Int, lo0:Int, hi0:Int, mclb:ifsoGUI_MCListBox)
			Local length:Int = mclb.Columns.Length
			Local i:Int, j:Int, v:ifsoGUI_MCLCell[]
			v = v[..length]
			For Local z:Int = 0 To length - 1
				v[z] = New ifsoGUI_MCLCell
			Next
			For i = lo0 + 1 To hi0
				For Local z:Int = 0 To length - 1
					v[z] = mclb.Columns[z].Rows[i]
				Next
				j = i
				While (j > lo0) And (Int(mclb.Columns[iCol].Rows[j - 1].Value) < Int(v[iCol].Value))
					For Local z:Int = 0 To mclb.Columns.Length - 1
						mclb.Columns[z].Rows[j] = mclb.Columns[z].Rows[j - 1]
					Next
	    j:-1
				Wend
				For Local z:Int = 0 To length - 1
					mclb.Columns[z].Rows[j] = v[z]
				Next
			Next
		End Function
	End Method
	Rem
		bbdoc: Used to sort the list by the Data field descending.
	End Rem
	Method FastQuickSortDataDesc(iCol:Int)
		QuickSort(iCol, 0, NumRows - 1, Self)
		InsertionSort(iCol, 0, NumRows - 1, Self)
	
		Function QuickSort(iCol:Int, l:Int, r:Int, mclb:ifsoGUI_MCListBox)
			If (r - l) > 4
				Local i:Int, j:Int, v:Int
				i = (r + l) / 2
				If (mclb.Columns[iCol].Rows[l].Data < mclb.Columns[iCol].Rows[i].Data) mclb.Swap(l, i)
				If (mclb.Columns[iCol].Rows[l].Data < mclb.Columns[iCol].Rows[r].Data) mclb.Swap(l, r)
				If (mclb.Columns[iCol].Rows[i].Data < mclb.Columns[iCol].Rows[r].Data) mclb.Swap(i, r)
				j = r - 1
				mclb.Swap(i, j)
				i = l
				v = mclb.Columns[iCol].Rows[j].Data
				Repeat
					i:+1
					While mclb.Columns[iCol].Rows[i].Data > v ; i:+1; Wend
					j:-1
					While mclb.Columns[iCol].Rows[j].Data < v ; j:-1;Wend
					If (j < i) Exit
					mclb.Swap (i, j)
				Forever
				mclb.Swap(i, r - 1)
				QuickSort(iCol, l, j, mclb)
				QuickSort(iCol, i + 1, r, mclb)
			End If
		End Function
	
		Function InsertionSort(iCol:Int, lo0:Int, hi0:Int, mclb:ifsoGUI_MCListBox)
			Local length:Int = mclb.Columns.Length
			Local i:Int, j:Int, v:ifsoGUI_MCLCell[]
			v = v[..length]
			For Local z:Int = 0 To length - 1
				v[z] = New ifsoGUI_MCLCell
			Next
			For i = lo0 + 1 To hi0
				For Local z:Int = 0 To length - 1
					v[z] = mclb.Columns[z].Rows[i]
				Next
				j = i
				While (j > lo0) And (mclb.Columns[iCol].Rows[j - 1].Data < v[iCol].Data)
					For Local z:Int = 0 To mclb.Columns.Length - 1
						mclb.Columns[z].Rows[j] = mclb.Columns[z].Rows[j - 1]
					Next
	    j:-1
				Wend
				For Local z:Int = 0 To length - 1
					mclb.Columns[z].Rows[j] = v[z]
				Next
			Next
		End Function
	End Method
	Rem
		bbdoc: Swap row iFrom with Row iTo.
	End Rem
	Method Swap(iFrom:Int, iTo:Int)
		Local v:ifsoGUI_MCLCell = New ifsoGUI_MCLCell
		For Local i:Int = 0 To Columns.Length - 1
			v = Columns[i].Rows[iFrom]
			Columns[i].Rows[iFrom] = Columns[i].Rows[iTo]
			Columns[i].Rows[iTo] = v
		Next
	End Method
	Rem
	bbdoc: Sets the top index of the listbox.
	End Rem
	Method SetTopItem(intTopItem:Int)
		If intTopItem = TopItem Return
		If intTopItem + VisibleRows >= NumRows intTopItem = NumRows - VisibleRows
		If intTopItem < 0 intTopItem = 0
		VBar.SetValue(intTopItem)
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
	bbdoc: Sorts the list.  Will be sorted by the Value field by default, set bData=true to sort by the data field.
	End Rem
	Method SortList(iColumn:Int, bDesc:Int = False, bSortAsInt:Int = False, bData:Int = False)
		If iColumn >= Columns.Length Return
		If bData
			If bDesc
				FastQuickSortDataDesc(iColumn)
			Else
				FastQuickSortData(iColumn)
			End If
		ElseIf bSortAsInt
			If bDesc
				FastQuickSortIntDesc(iColumn)
			Else
				FastQuickSortInt(iColumn)
			End If
		Else
			If bDesc
				FastQuickSortDesc(iColumn)
			Else
				FastQuickSort(iColumn)
			End If
		End If
		RefreshGadgets(-1, False)
	End Method
End Type

Type ifsoGUI_MCLColumn Extends ifsoGUI_Button
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button down
	Global gImageOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button over
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched

	Field CType:Int 'Column Type
	Field MinWidth:Int = 10 'Minimum Width
	Field MaxWidth:Int = 10 'Maximum Width
	Field Rows:ifsoGUI_MCLCell[] 'All of the rows that get added
	Field DefaultValue:String 'Value entered into a newly added row
	Field GadgetList:ifsoGUI_Base[] 'The gadget list for when bShowgadget is on.
	Field Gadget:ifsoGUI_Base 'All columns have this one gadget except labels
	Field HeaderAlign:Int 'Text alignment for Headers
	Field CellAlign:Int 'Text Alignment for Cells
	Field Dragging:Int 'Is the mouse dragging the edge.
	Field DragX:Int 'The X offset of the mouse when dragging.
	Field OrgX:Int 'Remember the Origin in case the Origin Changes so we can change the DragX
	Field IsReadOnly:Int = False 'Are newly added rows set ReadOnly for this column.
	Field bShowGadget:Int = False 'Does this column show its gadget all the time.
	Field MinHeight:Int ' Each column has a minimum height based on the type of gadget.
	Field ShowComboData:Int 'What info from a combo box to display
	
	Rem
		bbdoc: Create and returns a Multi Column List gadget.
	End Rem
	Function Create:ifsoGUI_MCLColumn(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, strLabel:String)
		Local p:ifsoGUI_MCLColumn = New ifsoGUI_MCLColumn
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lImageDown = gImageDown
		p.lImageOver = gImageOver
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.SetWH(iW, iH)
		p.Name = strName
		p.Label = strLabel
		For Local i:Int = 0 To 2
			p.TextColor[i] = GUI.TextColor[i]
		Next
		Return p
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
	Rem
	bbdoc: Gadget Level GUI system event occured.
	about: Informs all slaves and children, then refreshes self.
	Internal function should not be called by the user.
	End Rem
	Method GadgetSystemEvent(id:Int, data:Int) 'Systemwide event all gadgets must know about
		If id = ifsoGUI_EVENT_SYSTEM_NEW_GADGET_COLOR
			SetGadgetColor(data Shr 16, (data & $FF00) Shr 8, data & $FF)
		ElseIf id = ifsoGUI_EVENT_SYSTEM_NEW_GADGET_TEXTCOLOR
			SetTextColor(data Shr 16, (data & $FF00) Shr 8, data & $FF)
		End If
		If Gadget Gadget.GadgetSystemEvent(id, data)
		Refresh()
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("mclistbox button").Split(",")
		Load9Image2("/graphics/mclistboxbutton.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/mclistboxbuttonover.png")
			Load9Image2("/graphics/mclistboxbuttonover.png", dimensions, gImageOver)
		Else
			For Local i:Int = 0 To 8
				gImageOver = gImage
			Next
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/mclistboxbuttondown.png")
			Load9Image2("/graphics/mclistboxbuttondown.png", dimensions, gImageDown)
		Else
			For Local i:Int = 0 To 8
				gImageDown = gImage
			Next
		End If
	End Function
	Rem
		bbdoc: Draws the head button.
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
		If bPressed
			dImage = lImageDown
		ElseIf GUI.gMouseOverGadget = Self
			dImage = lImageOver
		Else
			dImage = lImage
		End If
		DrawBox2(lImage, rX, rY, w, h, True, lTileSides, lTileCenter)
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		Local vpX:Int, vpY:Int, vpW:Int, vpH:Int
		vpX = rX + BorderLeft
		vpY = ry + BorderTop
		vpW = w - (BorderLeft + BorderRight)
		vpH = h - (BorderTop + BorderBottom)
		ifsoGUI_VP.Add(vpX, vpY, vpW, vpH)

		Select HeaderAlign
			Case ifsoGUI_JUSTIFY_CENTER
				ifsoGUI_VP.DrawTextArea(Label, ((w - ifsoGUI_VP.GetTextWidth(Label, Self)) / 2) + rX, ((h - ifsoGUI_VP.GetTextHeight(Self)) / 2) + rY, Self)
			Case ifsoGUI_JUSTIFY_RIGHT
				ifsoGUI_VP.DrawTextArea(Label, rX + w - ifsoGUI_VP.GetTextWidth(Label, Self) - (BorderRight + 1), ((h - ifsoGUI_VP.GetTextHeight(Self)) / 2) + rY, Self)
			Default
				ifsoGUI_VP.DrawTextArea(Label, rX + BorderLeft + 1, ((h - ifsoGUI_VP.GetTextHeight(Self)) / 2) + rY, Self)
		End Select
		If GUI.gActiveGadget = Self And ShowFocus DrawFocus(vpX + 1, vpY + 1, vpW - 3, vpH - 3)
		ifsoGUI_VP.Pop()
	End Method
	Rem
	 bbdoc: Prepares the rows gadget for viewing.
	End Rem
	Method ActivateCell:Int(iRow:Int)
		If bShowGadget Or IsReadOnly Or CType = ifsoGUI_COLUMNTYPE_LABEL Or CType = ifsoGUI_COLUMNTYPE_PROGRESSBAR Return False
		Local TopItem:Int = ifsoGUI_MCListBox(Master).TopItem
		Local ItemHeight:Int = ifsoGUI_MCListBox(Master).ItemHeight
		Local iY:Int = ItemHeight * (iRow - TopItem)
		If ifsoGUI_MCListBox(Master).ShowColumnHeader iY:+ifsoGUI_MCListBox(Master).ColHeadHeight
		Select CType
			Case ifsoGUI_COLUMNTYPE_CHECKBOX
				Select CellAlign
					Case ifsoGUI_JUSTIFY_CENTER
						Gadget.x = x + (w - Gadget.w) / 2
					Case ifsoGUI_JUSTIFY_RIGHT
						Gadget.x = x + w - Gadget.w
					Default
						Gadget.x = x
				End Select
				Gadget.y = iY + (ItemHeight - Gadget.h) / 2
			Case ifsoGUI_COLUMNTYPE_TEXTBOX
				If ifsoGUI_TextBox(Gadget).ShowBorder
					Gadget.SetWH(w, ItemHeight)
					Gadget.x = x
					Gadget.y = iY
				Else
					Gadget.SetWH(w - 2, ItemHeight - 2)
					Gadget.x = x + 1
					Gadget.y = iY + 1
				End If
			Case ifsoGUI_COLUMNTYPE_SLIDER
				Gadget.SetWH(w - 2, ItemHeight)
				Gadget.x = x + 1
				Gadget.y = iY
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				Gadget.SetWH(w, ItemHeight - 1)
				Gadget.x = x
				Gadget.y = iY
			Case ifsoGUI_COLUMNTYPE_COMBOBOX
				Gadget.SetWH(w - 1, ItemHeight - 1)
				Gadget.x = x + 1
				Gadget.y = iY
			Default
				Gadget.SetWH(w, ItemHeight)
				Gadget.x = x
				Gadget.y = iY
		End Select
		Select CType
			Case ifsoGUI_COLUMNTYPE_CHECKBOX
				ifsoGUI_CheckBox(Gadget).bChecked = Int(Rows[iRow].Value)
			Case ifsoGUI_COLUMNTYPE_COMBOBOX
				ifsoGUI_Combobox(Gadget).SetSelected (Int(Rows[iRow].Value))
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				ifsoGUI_ProgressBar(Gadget).Value = Int(Rows[iRow].Value)
			Case ifsoGUI_COLUMNTYPE_SLIDER
				If ifsoGUI_Slider(Gadget).Value <> Int(Rows[iRow].Value)
					ifsoGUI_Slider(Gadget).Value = Int(Rows[iRow].Value)
					ifsoGUI_Slider(Gadget).Refresh()
				EndIf
			Case ifsoGUI_COLUMNTYPE_TEXTBOX
				ifsoGUI_TextBox(Gadget).SetText(Rows[iRow].Value)
		End Select
		Return True
	End Method
	Rem
		bbdoc: Draw a Row Header buttons.
		about: Internal function should not be called by the user.
	End Rem
	Method DrawRowButton(iX:Int, iY:Int, iW:Int, iH:Int, iTColor:Int[], strLabel:String = "", iStyle:Int = 0, caller:ifsoGUI_Base = Null)
		If iStyle = 1
			DrawBox2(lImageOver, iX, iY, iW, iH, True, lTileSides, lTileCenter)
		ElseIf iStyle = 2
			DrawBox2(lImageDown, iX, iY, iW, iH, True, lTileSides, lTileCenter)
		Else
			DrawBox2(lImage, iX, iY, iW, iH, True, lTileSides, lTileCenter)
		End If
		SetColor(iTColor[0], iTColor[1], iTColor[2])
		ifsoGUI_VP.Add(iX + BorderLeft, iY + BorderTop, iW - (BorderLeft + BorderRight), iH - (BorderTop + BorderTop))
		ifsoGUI_VP.DrawTextArea(strLabel, iX + BorderRight, ((iH - ifsoGUI_VP.GetTextHeight(caller)) / 2) + iY, caller)
		ifsoGUI_VP.Pop()
	End Method
	Rem
	bbdoc: Sets the Correct Value in the Columns gadgets for drawing
	about: Internal function should not be called by the user.
	End Rem
	Method GadgetValue(iRow:Int)
		If iRow >= Rows.Length Return
		Select CType
			Case ifsoGUI_COLUMNTYPE_TEXTBOX
				ifsoGUI_TextBox(Gadget).SetText(Rows[iRow].Value)
			Case ifsoGUI_COLUMNTYPE_CHECKBOX
				ifsoGUI_CheckBox(Gadget).SetValue(Int(Rows[iRow].Value))
			Case ifsoGUI_COLUMNTYPE_COMBOBOX
				ifsoGUI_Combobox(Gadget).SetSelected(Int(Rows[iRow].Value))
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				ifsoGUI_ProgressBar(Gadget).SetValue(Int(Rows[iRow].Value))
			Case ifsoGUI_COLUMNTYPE_SLIDER
				ifsoGUI_Slider(Gadget).SetValue(Int(Rows[iRow].Value))
		End Select
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not (Enabled And Visible) Return
		If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
		 GUI.SetActiveGadget(Self)
			bPressed = True
			Local iX:Int, iY:Int
			OrgX = ifsoGUI_MCListBox(Master).OriginX
			GetAbsoluteXY(iX, iY)
			If iMouseX >= iX + w - 3 And (MaxWidth <> MinWidth) And ifsoGUI_MCListBox(Master).ColumnsResizable
				Dragging = True
				DragX = iX + w - iMouseX
			End If
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		bPressed = False
		If Not (Enabled And Visible) Return
		If GUI.gMouseOverGadget = Self
		 If iButton = ifsoGUI_LEFT_MOUSE_BUTTON And Not Dragging SendEvent(ifsoGUI_EVENT_CLICK, iButton, iMouseX, iMouseY)
		Else
			GUI.SetActiveGadget(Null)
		End If
		Dragging = False
	End Method
	Rem
	bbdoc: Returns whether the Column is being resized or not.
	End Rem
	Method IsResizing:Int()
		Return Dragging
	End Method
	Rem
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget only.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If bPressed
			If Dragging
				Local iX:Int, iY:Int, NewWidth:Int, org:Int = ifsoGUI_MCListBox(Master).OriginX
				If OrgX <> org
					iMouseX:-(org - OrgX)
					GUI.PositionMouse(iMouseX, iMouseY)
					OrgX = org
				End If
				GetAbsoluteXY(iX, iY)
				If iMouseX + DragX >= iX + MinWidth And iMouseX + DragX <= iX + MaxWidth
					NewWidth = iMouseX + DragX - iX
					If NewWidth <> w
						w = NewWidth
						SendEvent(ifsoGUI_EVENT_RESIZE, 0, iMouseX, iMouseY)
					End If
				End If
				Return ifsoGUI_MOUSE_RESIZE
			End If
			Return ifsoGUI_MOUSE_DOWN
		End If
		Local iX:Int, iY:Int
		GetAbsoluteXY(iX, iY)
		If iMouseX >= iX + w - 3 And (MaxWidth <> MinWidth) And ifsoGUI_MCListBox(Master).ColumnsResizable
			GUI.iMouseDir = ifsoGUI_RESIZE_RIGHT
			Return ifsoGUI_MOUSE_RESIZE
		End If
	 Return ifsoGUI_MOUSE_OVER
	End Method
	Rem
		bbdoc: Rebuilds the column gadgets array.  Called whenever a column is created, or the listbox is resized, or
									a columns ShowGadgets property is changed.  Set the iColumn parameter to -1 to do all columns.
		Internal function should not be called by the user.
	End Rem
	Method RebuildGadgets()
		Local VisibleRows:Int = ifsoGUI_MCListBox(Master).VisibleRows, MasterName:String = Master.Name
		Local i:Int 'this gets the column number
		For i = 0 To ifsoGUI_MCListBox(Master).Columns.Length - 1
			If ifsoGUI_MCListBox(Master).Columns[i] = Self Exit
		Next
		If CType <> ifsoGUI_COLUMNTYPE_LABEL
			If Gadget.fFont <> Master.fFont
				Gadget.SetFont(Master.fFont)
				If CType = ifsoGUI_COLUMNTYPE_SLIDER
					Gadget.SetWH(0, 0)
					MinHeight = Gadget.h + 3
				ElseIf CType = ifsoGUI_COLUMNTYPE_PROGRESSBAR
					Gadget.SetWH(0, 0)
					MinHeight = Gadget.h + 1
				Else
					Gadget.SetWH(0, 0)
					MinHeight = Gadget.h
				End If
			End If
		End If
		For Local j:Int = 0 To GadgetList.Length - 1
			Master.Slaves.Remove(GadgetList[j])
		Next
		GadgetList = Null
		If bShowGadget And CType <> ifsoGUI_COLUMNTYPE_LABEL
			GadgetList = GadgetList[..VisibleRows + 1]
			Select CType
				Case ifsoGUI_COLUMNTYPE_CHECKBOX
					For Local j:Int = 0 To VisibleRows
						GadgetList[j] = ifsoGUI_CheckBox.Create(0, 0, 0, 0, MasterName + "_" + i + "_" + j, "")
						GadgetList[j].SetFont(Master.fFont)
						GadgetList[j].Master = Master
						Master.Slaves.AddLast(GadgetList[j])
					Next
				Case ifsoGUI_COLUMNTYPE_COMBOBOX
					For Local j:Int = 0 To VisibleRows
						GadgetList[j] = ifsoGUI_Combobox.Create(0, 0, 0, 0, MasterName + "_" + i + "_" + j)
						GadgetList[j].SetFont(Master.fFont)
						For Local itm:Int = 0 To ifsoGUI_Combobox(Gadget).dropList.Items.Length - 1
							ifsoGUI_Combobox(GadgetList[j]).AddItem(ifsoGUI_Combobox(Gadget).dropList.Items[itm].Name, ifsoGUI_Combobox(Gadget).dropList.Items[itm].Data, ifsoGUI_Combobox(Gadget).dropList.Items[itm].Tip)
						Next
						ifsoGUI_Combobox(GadgetList[j]).SetShowItems(ifsoGUI_Combobox(Gadget).ShowItems)
						GadgetList[j].Master = Master
						Master.Slaves.AddLast(GadgetList[j])
					Next
				Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
					For Local j:Int = 0 To VisibleRows
						GadgetList[j] = ifsoGUI_ProgressBar.Create(0, 0, 0, 0, MasterName + "_" + i + "_" + j)
						GadgetList[j].SetFont(Master.fFont)
						ifsoGUI_ProgressBar(GadgetList[j]).iMin = ifsoGUI_ProgressBar(Gadget).iMin
						ifsoGUI_ProgressBar(GadgetList[j]).iMax = ifsoGUI_ProgressBar(Gadget).iMax
						ifsoGUI_ProgressBar(GadgetList[j]).ShowBorder = ifsoGUI_ProgressBar(Gadget).ShowBorder
						ifsoGUI_ProgressBar(GadgetList[j]).DrawStyle = ifsoGUI_ProgressBar(Gadget).DrawStyle
						ifsoGUI_ProgressBar(GadgetList[j]).BarColor[0] = ifsoGUI_ProgressBar(Gadget).BarColor[0]
						ifsoGUI_ProgressBar(GadgetList[j]).BarColor[1] = ifsoGUI_ProgressBar(Gadget).BarColor[1]
						ifsoGUI_ProgressBar(GadgetList[j]).BarColor[2] = ifsoGUI_ProgressBar(Gadget).BarColor[2]
						ifsoGUI_ProgressBar(GadgetList[j]).Reversed = ifsoGUI_ProgressBar(Gadget).Reversed
						GadgetList[j].Master = Master
						Master.Slaves.AddLast(GadgetList[j])
					Next
				Case ifsoGUI_COLUMNTYPE_SLIDER
					For Local j:Int = 0 To VisibleRows
						GadgetList[j] = ifsoGUI_Slider.Create(0, 0, 0, MasterName + "_" + i + "_" + j)
						GadgetList[j].SetFont(Master.fFont)
						GadgetList[j].ShowFocus = False
						ifsoGUI_Slider(GadgetList[j]).MinVal = ifsoGUI_Slider(Gadget).MinVal
						ifsoGUI_Slider(GadgetList[j]).MaxVal = ifsoGUI_Slider(Gadget).MaxVal
						GadgetList[j].Master = Master
						Master.Slaves.AddLast(GadgetList[j])
					Next
				Case ifsoGUI_COLUMNTYPE_TEXTBOX
					For Local j:Int = 0 To VisibleRows
						GadgetList[j] = ifsoGUI_TextBox.Create(0, 0, 0, 0, MasterName + "_" + i + "_" + j)
						GadgetList[j].SetFont(Master.fFont)
						GadgetList[j].Master = Master
						ifsoGUI_TextBox(GadgetList[j]).CursorWidth = ifsoGUI_TextBox(Gadget).CursorWidth
						ifsoGUI_TextBox(GadgetList[j]).ShowBorder = ifsoGUI_TextBox(Gadget).ShowBorder
						Master.Slaves.AddLast(GadgetList[j])
					Next
			End Select
		End If
	End Method
	Rem
		bbdoc:Refreshes the values shown in the column gadgets.
								If iGeo is set to true, gadgets size and position are refreshed, if false, then just values are updated.
		about:internal function, should not be called by the user.
	End Rem
	Method RefreshGadgets(iGeo:Int)
		Local TopItem:Int = ifsoGUI_MCListBox(Master).TopItem, NumRows:Int = ifsoGUI_MCListBox(Master).NumRows
		If iGeo
			Local iY:Int, ItemHeight:Int = ifsoGUI_MCListBox(Master).ItemHeight
			If ifsoGUI_MCListBox(Master).ShowColumnHeader iY = ifsoGUI_MCListBox(Master).ColHeadHeight
			For Local j:Int = 0 To GadgetList.Length - 1
				If j + TopItem < NumRows GadgetList[j].SetEnabled(Not Rows[j + TopItem].IsReadOnly)
				Select CType
					Case ifsoGUI_COLUMNTYPE_CHECKBOX
						Select CellAlign
							Case ifsoGUI_JUSTIFY_CENTER
								GadgetList[j].x = x + (w - GadgetList[j].w) / 2
							Case ifsoGUI_JUSTIFY_RIGHT
								GadgetList[j].x = x + w - GadgetList[j].w
							Default
							GadgetList[j].x = x
						End Select
						GadgetList[j].y = iY + (ItemHeight - GadgetList[j].h) / 2
					Case ifsoGUI_COLUMNTYPE_TEXTBOX
						If ifsoGUI_TextBox(Gadget).ShowBorder
							GadgetList[j].SetWH(w, ItemHeight)
							GadgetList[j].x = x
							GadgetList[j].y = iY
						Else
							GadgetList[j].SetWH(w - 2, ItemHeight - 2)
							GadgetList[j].x = x + 1
							GadgetList[j].y = iY + 1
						End If
					Case ifsoGUI_COLUMNTYPE_SLIDER
						GadgetList[j].SetWH(w - 2, ItemHeight)
						GadgetList[j].x = x + 1
						GadgetList[j].y = iY
					Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
						GadgetList[j].SetWH(w, ItemHeight - 5)
						GadgetList[j].x = x
						GadgetList[j].y = iY + 2
					Case ifsoGUI_COLUMNTYPE_COMBOBOX
						GadgetList[j].SetWH(w - 1, ItemHeight - 1)
						GadgetList[j].x = x + 1
						GadgetList[j].y = iY
					Default
						GadgetList[j].SetWH(w, ItemHeight)
						GadgetList[j].x = x
						GadgetList[j].y = iY
				End Select
				iY:+ItemHeight
			Next
		End If
		If NumRows > 0
			Select CType
				Case ifsoGUI_COLUMNTYPE_CHECKBOX
					For Local j:Int = 0 To GadgetList.Length - 1
						If j + TopItem >= NumRows Exit
						ifsoGUI_CheckBox(GadgetList[j]).bChecked = Int(Rows[j + TopItem].Value)
					Next
				Case ifsoGUI_COLUMNTYPE_COMBOBOX
					For Local j:Int = 0 To GadgetList.Length - 1
						If j + TopItem >= NumRows Exit
						ifsoGUI_Combobox(GadgetList[j]).SetSelected (Int(Rows[j + TopItem].Value))
					Next
				Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
					For Local j:Int = 0 To GadgetList.Length - 1
						If j + TopItem >= NumRows Exit
						ifsoGUI_ProgressBar(GadgetList[j]).Value = Int(Rows[j + TopItem].Value)
					Next
				Case ifsoGUI_COLUMNTYPE_SLIDER
					For Local j:Int = 0 To GadgetList.Length - 1
						If j + TopItem >= NumRows Exit
						If ifsoGUI_Slider(GadgetList[j]).Value <> Int(Rows[j + TopItem].Value)
							ifsoGUI_Slider(GadgetList[j]).Value = Int(Rows[j + TopItem].Value)
							ifsoGUI_Slider(GadgetList[j]).Refresh()
						End If
					Next
				Case ifsoGUI_COLUMNTYPE_TEXTBOX
					For Local j:Int = 0 To GadgetList.Length - 1
						If j + TopItem >= NumRows Exit
						ifsoGUI_TextBox(GadgetList[j]).SetText(Rows[j + TopItem].Value)
					Next
			End Select
		End If
	End Method
	Rem
	bbdoc: Adds an item to a combobox column.
	End Rem
	Method AddItem(strName:String, intData:Int, strTip:String)
		If CType = ifsoGUI_COLUMNTYPE_COMBOBOX
			ifsoGUI_Combobox(Gadget).AddItem(strName, intData, strTip)
			For Local i:Int = 0 To GadgetList.Length - 1
				ifsoGUI_Combobox(GadgetList[i]).AddItem(strName, intData, strTip)
			Next
		End If
	End Method
	Rem
	bbdoc: Inserts an item into a combobox column.
	End Rem
	Method InsertItem(intIndex:Int, strName:String, intData:Int, strTip:String)
		If CType = ifsoGUI_COLUMNTYPE_COMBOBOX
			ifsoGUI_Combobox(Gadget).InsertItem(intIndex, strName, intData, strTip)
			For Local i:Int = 0 To GadgetList.Length - 1
				ifsoGUI_Combobox(GadgetList[i]).InsertItem(intIndex, strName, intData, strTip)
			Next
		End If
	End Method
	Rem
	bbdoc: Removes all items from a combobox column.
	End Rem
	Method RemoveAll()
		If CType = ifsoGUI_COLUMNTYPE_COMBOBOX
			ifsoGUI_Combobox(Gadget).RemoveAll()
			For Local i:Int = 0 To GadgetList.Length - 1
				ifsoGUI_Combobox(GadgetList[i]).RemoveAll()
			Next
			For Local i:Int = 0 To Rows.Length - 1
				Rows[i].Value = "-1"
			Next
			RefreshGadgets(False)
		End If
	End Method
	Rem
	bbdoc: Removes an item from a combobox column.
	End Rem
	Method RemoveItem(intIndex:Int)
		If CType = ifsoGUI_COLUMNTYPE_COMBOBOX
			ifsoGUI_Combobox(Gadget).RemoveItem(intIndex)
			For Local i:Int = 0 To GadgetList.Length - 1
				ifsoGUI_Combobox(GadgetList[i]).RemoveItem(intIndex)
			Next
			For Local i:Int = 0 To Rows.Length - 1
				If Rows[i].Value = String(intIndex) Rows[i].Value = "-1"
			Next
		End If
	End Method
	Rem
	bbdoc: Sets the color of the bar.
	End Rem
	Method SetBarColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of the gadget
		If CType = ifsoGUI_COLUMNTYPE_PROGRESSBAR
			ifsoGUI_ProgressBar(Gadget).BarColor[0] = iRed
			ifsoGUI_ProgressBar(Gadget).BarColor[1] = iGreen
			ifsoGUI_ProgressBar(Gadget).BarColor[2] = iBlue
			For Local i:Int = 0 To GadgetList.Length - 1
				ifsoGUI_ProgressBar(GadgetList[i]).BarColor[0] = iRed
				ifsoGUI_ProgressBar(GadgetList[i]).BarColor[1] = iGreen
				ifsoGUI_ProgressBar(GadgetList[i]).BarColor[2] = iBlue
			Next
		End If
	End Method
	Rem
	bbdoc: Sets if the bar is drawn reversed.
	about: Normal is Left to Right or Bottom to Top
								Reversed is Right to Left or Top to Bottom
	End Rem
	Method SetBarReversed(intReversed:Int) 'Set bar reversed
		If CType = ifsoGUI_COLUMNTYPE_PROGRESSBAR
			ifsoGUI_ProgressBar(Gadget).Reversed = intReversed
			For Local i:Int = 0 To GadgetList.Length - 1
				ifsoGUI_ProgressBar(GadgetList[i]).Reversed = intReversed
			Next
		End If
	End Method
	Rem
	bbdoc: Gets if the bar is drawn reversed.
	about: Normal is Left to Right or Bottom to Top
								Reversed is Right to Left or Top to Bottom
	End Rem
	Method GetBarReversed:Int() 'Get if the bar is reversed
		If CType = ifsoGUI_COLUMNTYPE_PROGRESSBAR
			Return ifsoGUI_ProgressBar(Gadget).Reversed
		End If
		Return 0
	End Method
	Rem
	bbdoc: Sets the width of the cursor bar.
	End Rem
	Method SetCursorWidth(iCursorWidth:Int)
		If CType = ifsoGUI_COLUMNTYPE_TEXTBOX
			ifsoGUI_TextBox(Gadget).CursorWidth = iCursorWidth
			For Local i:Int = 0 To Gadgetlist.Length - 1
				ifsoGUI_TextBox(GadgetList[i]).CursorWidth = iCursorWidth
			Next
		End If
	End Method
	Rem
	bbdoc: Returns the width of the cursor bar.
	End Rem
	Method GetCursorWidth:Int()
		If CTYpe - ifsoGUI_COLUMNTYPE_TEXTBOX
			Return ifsoGUI_TextBox(Gadget).CursorWidth
		End If
		Return 0
	End Method
	Rem
	bbdoc: Sets the direction the graphic is facing.
	about: ifsoGUI_SLIDER_UP_RIGHT or ifsoGUI_SLIDER_DOWN_LEFT
	End Rem
	Method SetDirection(intDirection:Int)
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				ifsoGUI_Slider(Gadget).Direction = intDirection
				For Local i:Int = 0 To GadgetList.Length - 1
					ifsoGUI_Slider(GadgetList[i]).Direction = intDirection
				Next
		End Select
	End Method
	Rem
	bbdoc: Returns the direction the graphic is facing.
	about: ifsoGUI_SLIDER_UP_RIGHT or ifsoGUI_SLIDER_DOWN_LEFT
	End Rem
	Method GetDirection:Int()
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				Return ifsoGUI_Slider(Gadget).Direction
		End Select
		Return 0
	End Method
	Rem
	bbdoc: Sets the draw style of the progressbar.
	about: ifsoGUI_DRAWSTYLE_STRETCH - The graphic is stretched.
								ifsoGUI_DRAWSTYLE_TILE    - The graphic is tiled.
	End Rem
	Method SetDrawStyle(intStyle:Int)
		If CType = ifsoGUI_COLUMNTYPE_PROGRESSBAR
			ifsoGUI_ProgressBar(Gadget).DrawStyle = intStyle
			For Local i:Int = 0 To GadgetList.Length - 1
				ifsoGUI_ProgressBar(GadgetList[i]).DrawStyle = intStyle
			Next
		End If
	End Method
	Rem
	bbdoc: Returns the drawstyle.
	End Rem
	Method GetDrawStyle:Int()
		If CType = ifsoGUI_COLUMNTYPE_PROGRESSBAR
			Return ifsoGUI_ProgressBar(Gadget).DrawStyle
		End If
		Return 0
	End Method
	Rem
	bbdoc: Sets the amount the value changes per tick.
	End Rem
	Method SetInterval(intInterval:Int)
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				ifsoGUI_Slider(Gadget).SetInterval(intInterval)
			 For Local i:Int = 0 To GadgetList.Length - 1
					ifsoGUI_Slider(GadgetList[i]).SetInterval(intInterval)
				Next
		End Select
	End Method
	Rem
	bbdoc: Returns the amount the value changes per tick.
	End Rem
	Method GetInterval:Int()
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				Return ifsoGUI_Slider(Gadget).Interval
		End Select
		Return 0
	End Method
	Rem
	bbdoc: Sets the maximum value of the gadget..
	End Rem
	Method SetMax(intMax:Int)
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				If intMax < ifsoGUI_Slider(Gadget).MinVal Return
				Local Interval:Int = ifsoGUI_Slider(Gadget).Interval
				ifsoGUI_Slider(Gadget).MaxVal = intMax
				ifsoGUI_Slider(Gadget).SetInterval(Interval)
				For Local i:Int = 0 To Rows.Length - 1
					If Int(Rows[i].Value) > intMax Rows[i].Value = String(intMax)
				Next
				RefreshGadgets(False)
				For Local i:Int = 0 To GadgetList.Length - 1
					ifsoGUI_Slider(GadgetList[i]).SetInterval(Interval)
				Next
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				If intMax < ifsoGUI_ProgressBar(Gadget).iMin Return
				ifsoGUI_ProgressBar(Gadget).iMax = intMax
				For Local i:Int = 0 To Rows.Length - 1
					If Int(Rows[i].Value) > intMax Rows[i].Value = String(intMax)
				Next
				RefreshGadgets(False)
		End Select
	End Method
	Rem
	bbdoc: Returns the maximum value of the gadget.
	End Rem
	Method GetMax:Int()
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				Return ifsoGUI_Slider(Gadget).MaxVal
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				Return ifsoGUI_ProgressBar(Gadget).iMax
		End Select
		Return 0
	End Method
	Rem
	bbdoc: Sets the minimum value of the gadget.
	End Rem
	Method SetMin(intMin:Int)
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				If intMin >= ifsoGUI_Slider(gadget).MaxVal Return
				Local Interval:Int = ifsoGUI_Slider(Gadget).Interval
				ifsoGUI_Slider(gadget).MinVal = intMin
				ifsoGUI_Slider(Gadget).SetInterval(Interval)
				For Local i:Int = 0 To Rows.Length - 1
					If Int(Rows[i].Value) < intMin Rows[i].Value = String(intMin)
				Next
				RefreshGadgets(False)
				For Local i:Int = 0 To GadgetList.Length - 1
					ifsoGUI_Slider(GadgetList[i]).SetInterval(Interval)
				Next
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				If intMin >= ifsoGUI_ProgressBar(gadget).iMax Return
				ifsoGUI_ProgressBar(gadget).iMin = intMin
				For Local i:Int = 0 To Rows.Length - 1
					If Int(Rows[i].Value) < intMin Rows[i].Value = String(intMin)
				Next
				RefreshGadgets(False)
		End Select
	End Method
	Rem
	bbdoc: Returns the minimum value of the gadget.
	End Rem
	Method GetMin:Int()
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				Return ifsoGUI_Slider(Gadget).MinVal
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				Return ifsoGUI_ProgressBar(Gadget).iMin
		End Select
		Return 0
	End Method
	Rem
	bbdoc: Sets the minimum and maximum values of the gadget in one call.
	End Rem
	Method SetMinMax(intMin:Int, intMax:Int)
		If intMin >= intMax Return
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				ifsoGUI_Slider(gadget).MinVal = intMin
				ifsoGUI_Slider(gadget).MaxVal = intMax
				Local Interval:Int = ifsoGUI_Slider(Gadget).Interval
				For Local i:Int = 0 To Rows.Length - 1
					If Int(Rows[i].Value) < intMin Rows[i].Value = String(intMin)
					If Int(Rows[i].Value) > intMax Rows[i].Value = String(intMax)
				Next
				RefreshGadgets(False)
				For Local i:Int = 0 To GadgetList.Length - 1
					ifsoGUI_Slider(GadgetList[i]).SetInterval(Interval)
				Next
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				ifsoGUI_ProgressBar(gadget).iMin = intMin
				ifsoGUI_ProgressBar(gadget).iMax = intMax
				For Local i:Int = 0 To Rows.Length - 1
					If Int(Rows[i].Value) < intMin Rows[i].Value = String(intMin)
					If Int(Rows[i].Value) > intMax Rows[i].Value = String(intMax)
				Next
				RefreshGadgets(False)
		End Select
	End Method
	Rem
	bbdoc: Sets whether or not the border will show.
	End Rem
	Method SetShowBorder(bShowBorder:Int)
		Select CType
			Case ifsoGUI_COLUMNTYPE_TEXTBOX
				ifsoGUI_TextBox(Gadget).SetShowBorder(bShowBorder)
				For Local i:Int = 0 To GadgetList.Length - 1
					ifsoGUI_TextBox(GadgetList[i]).SetShowBorder(bShowBorder)
				Next
				Refresh()
			Case ifsoGUI_COLUMNTYPE_PROGRESSBAR
				ifsoGUI_ProgressBar(Gadget).SetShowBorder(bShowBorder)
				For Local i:Int = 0 To GadgetList.Length - 1
					ifsoGUI_ProgressBar(GadgetList[i]).SetShowBorder(bShowBorder)
				Next
				Refresh()
		End Select
	End Method
	Rem
	bbdoc: Returns whether or not the border is showing.
	End Rem
	Method GetShowBorder:Int()
		If CType = ifsoGUI_COLUMNTYPE_TEXTBOX
			Return ifsoGUI_TextBox(Gadget).ShowBorder
		End If
		Return 0
	End Method
	Rem
	bbdoc: Sets what data from the combobox appears in the column.  Only applies to Combobox columns.
	End Rem
	Method SetShowComboboxData(iData:Int)
		ShowComboData = iData
	End Method
	Rem
	bbdoc: Returns what data from the combobox appears in the column. Only applies to Combobox columns.
	End Rem
	Method GetShowComboboxData:Int()
		Return ShowComboData
	End Method
	Rem
	bbdoc: Sets the number of items to show in a combobox column dropdown box.
	End Rem
	Method SetShowItems(iNumItems:Int)
		If CType = ifsoGUI_COLUMNTYPE_COMBOBOX
			ifsoGUI_Combobox(Gadget).SetShowItems(iNumItems)
			For Local i:Int = 0 To GadgetList.Length - 1
				ifsoGUI_Combobox(GadgetList[i]).SetShowItems(iNumItems)
			Next
		End If
	End Method
	Rem
	bbdoc: Returns the number of items to show in a combobox column dropdown box.
	End Rem
	Method GetShowItems:Int()
		If CType = ifsoGUI_COLUMNTYPE_COMBOBOX
			Return ifsoGUI_Combobox(Gadget).ShowItems
		End If
		Return 0
	End Method
	Rem
	bbdoc: Sets the direction the graphic is facing.
	about: ifsoGUI_SLIDER_UP_RIGHT or ifsoGUI_SLIDER_DOWN_LEFT
	End Rem
	Method SetShowTicks(intShowTicks:Int)
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				ifsoGUI_Slider(Gadget).ShowTicks = intShowTicks
				For Local i:Int = 0 To GadgetList.Length - 1
					ifsoGUI_Slider(GadgetList[i]).ShowTicks = intShowTicks
				Next
		End Select
	End Method
	Rem
	bbdoc: Returns the direction the graphic is facing.
	about: ifsoGUI_SLIDER_UP_RIGHT or ifsoGUI_SLIDER_DOWN_LEFT
	End Rem
	Method GetShowTicks:Int()
		Select CType
			Case ifsoGUI_COLUMNTYPE_SLIDER
				Return ifsoGUI_Slider(Gadget).ShowTicks
		End Select
		Return 0
	End Method

End Type

Type ifsoGUI_MCLCell
	Field Value:String 'Value in the gadget
	Field Selected:Int 'Is this row selected
	Field Tip:String 'Tip for this cell
	Field IsReadOnly:Int = False 'Can this cell be edited
	Field Data:Int 'User data for this cell
	'Field Gadget:ifsoGUI_Base 'Gadget for each cell if ShowGadgets is on
End Type
