SuperStrict

Rem
	bbdoc: ifsoGUI File Select
	about: File Select Gadget
EndRem
Module ifsogui.fileselect

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.window
Import ifsogui.listbox
Import ifsogui.button
Import ifsogui.label
Import ifsogui.textbox

Const ifsoGUI_FILESELECT_OPENFILE:Int = 0
Const ifsoGUI_FILESELECT_OPENDIR:Int = 1
Const ifsoGUI_FILESELECT_SAVEFILE:Int = 2
Const ifsoGUI_FILESELECT_CANCELED:Int = 0 'Selection canceled
Const ifsoGUI_FILESELECT_SELECTED:Int = 1 'Selection has been made

Rem
	bbdoc: File Selecter Type
End Rem
Type ifsoGUI_FileSelect Extends ifsoGUI_Window
	Field lstFiles:ifsoGUI_ListBox 'Listbox for the file list
	Field lblDir:ifsoGUI_Label 'lbl for the current dir
	Field txtFile:ifsoGUI_TextBox 'textbox for the dir/filename
	Field btnSelect:ifsoGUI_Button 'btn for the Open/Save button
	Field btnCancel:ifsoGUI_Button 'btn for the Cancel btn
	Field MustExist:Int = False 'Does the selected file have to exist?
	Field Style:Int 'Style of the selector 0=openfile 1=opendir 2=savefile
	Field TopMidLine:Int 'For drawine Dir: stuff
	Field BotMidLine:Int 'For drawing file stuff
	Field Dir:String 'Current Dir
	Field Selected:String 'Selected file/dir name
	
	Rem
		bbdoc: Create and returns a FileSelect gadget.
	End Rem
	Function Create:ifsoGUI_FileSelect(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_FileSelect = New ifsoGUI_FileSelect
		p.TabOrder = -2
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lImageCap = gImageCap
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.lTileCapSides = gTileCapSides
		p.lTileCapCenter = gTileCapCenter
		p.Enabled = True
		p.Visible = False
		p.HBar = ifsoGUI_ScrollBar.Create(0, 0, iW, p.ScrollBarWidth, strName + "_hbar", False)
		p.VBar = ifsoGUI_ScrollBar.Create(0, 0, p.ScrollBarWidth, iH, strName + "_vbar", True)
		p.HBar.SetVisible(False)
		p.HBar.Master = p
		p.VBar.SetVisible(False)
		p.VBar.Master = p
		p.Scrollbars = ifsoGUI_SCROLLBAR_OFF
		p.DragTop = True
		p.Dragable = True
		p.lstFiles = ifsoGUI_ListBox.Create(0, 0, iW, iH, strName + "_lst")
		p.lstFiles.Master = p
		p.lblDir = ifsoGUI_Label.Create(0, 0, iW, iH, strName + "_lbl", "")
		p.lblDir.Master = p
		p.txtFile = ifsoGUI_TextBox.Create(0, 0, iW, iH, strName + "_txt", "")
		p.txtFile.Master = p
		p.Caption = "Open File"
		p.btnCancel = ifsoGUI_Button.Create(0, 0, iW, iH, strName + "_btnCancel", "Cancel")
		p.btnCancel.Master = p
		p.btnSelect = ifsoGUI_Button.Create(0, 0, iW, iH, strName + "_btnSelect", "Open")
		p.btnSelect.Master = p
		p.Slaves.AddLast(p.lstFiles)
		p.Slaves.AddLast(p.lblDir)
		p.Slaves.AddLast(p.txtFile)
		p.Slaves.AddLast(p.btnSelect)
		p.Slaves.AddLast(p.btnCancel)
		p.SetWH(iW, iH)
		p.SetShowBorder(True)
		p.Name = strName
		p.Dir = RealPath(CurrentDir())
		If Not p.Dir.EndsWith("/") p.Dir:+"/"
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
		If fFont SetImageFont(fFont)
			'set up rendering locations
		Local rX:Int = parX + x
		Local rY:Int = parY + y
		If ShowBorder
			'titlebar
			DrawBox2(lImageCap, rX, rY, w, BorderTop - lImage.h[1])
			'Window
			DrawBox2(lImage, rX, rY + BorderTop - lImage.h[1], w, (h - BorderTop) + lImage.h[1])
			If Caption <> "" And Not SmallTitleBar
				ifsoGUI_VP.Add(rX + lImageCap.w[0] + 2, rY + lImageCap.h[1], w - (lImageCap.w[0] + lImageCap.w[2]) + 4, BorderTop - (lImageCap.h[1] + lImageCap.h[7] + lImage.h[1]))
				SetColor(TextColor[0], TextColor[1], TextColor[2])
				ifsoGUI_VP.DrawTextArea(Caption, rX + lImageCap.w[0] + 2, rY + lImageCap.h[1], Self)
				ifsoGUI_VP.Pop()
			End If
		Else 'Draw just the middle
			ifsoGUI_VP.DrawImageAreaRect2(lImage, rX, rY, w, h, 4)
		End If
		Local chkW:Int = w - (BorderLeft + BorderRight)
		Local chkH:Int = h - (BorderTop + BorderBottom)
		rX:+BorderLeft
		rY:+BorderTop
		lblDir.Draw(rX, rY, chkW, chkH)
		lstFiles.Draw(rX, rY, chkW, chkH)
		txtFile.Draw(rX, rY, chkW, chkH)
		btnSelect.Draw(rX, rY, chkW, chkH)
		btnCancel.Draw(rX, rY, chkW, chkH)
		Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		ifsoGUI_VP.DrawTextArea("Dir:", rx + 2, ry + TopMidLine - (th / 2), Self)
		If Style = 1
			ifsoGUI_VP.DrawTextArea("Dir:", rx + 2, ry + BotMidLine - (th / 2), Self)
		Else
			ifsoGUI_VP.DrawTextArea("File:", rx + 2, ry + BotMidLine - (th / 2), Self)
		End If
		If fFont SetImageFont(GUI.DefaultFont)
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
			lTileCapSides = gTileCapSides
			lTileCapCenter = gTileCapCenter
		End If
		Local wasFont:TImageFont = GetImageFont()
		If fFont
			SetImageFont(fFont)
		Else
			SetImageFont(GUI.DefaultFont)
		End If
		If ShowBorder
			BorderBottom = lImage.h[7]
			BorderLeft = lImage.w[3]
			BorderRight = lImage.w[5]
			If SmallTitleBar
				BorderTop = lImageCap.h[1] + lImageCap.h[4] + lImageCap.h[7]
			Else
				BorderTop = ifsoGUI_VP.GetTextHeight(Self) + lImageCap.h[1] + lImageCap.h[7] + lImage.h[1]
			End If
		Else
			BorderTop = 0
			BorderBottom = 0
			BorderLeft = 0
			BorderRight = 0
		End If
		If MinW < BorderLeft + BorderRight MinW = BorderLeft + BorderRight
		If MinH < BorderTop + BorderBottom MinH = BorderTop + BorderBottom
		If w < MinW w = minw
		If h < MinH h = minh
		Local margin:Int = 5 + ifsoGUI_VP.GetTextWidth("File:", Self)
		TopMidLine = lblDir.h / 2 + 2
		Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
		Local cw:Int = GetClientWidth()
		Local ch:Int = GetClientHeight()
		lblDir.SetXY(margin, 2)
		lblDir.SetWH(cw - (margin + 2), th + 4)
		btnCancel.SetWH(ifsoGUI_VP.GetTextWidth(btnCancel.Label, Self) + btnCancel.BorderLeft + btnCancel.BorderRight + 4, th + btnCancel.BorderTop + btnCancel.BorderBottom)
		btnCancel.SetXY(cw - btnCancel.w - 2, ch - btnCancel.h - 2)
		btnSelect.SetWH(btnCancel.w, btnCancel.h)
		txtFile.SetWH(cw - (margin + 5 + btnCancel.w), th + 4)
		If btnSelect.h > txtFile.h
			BotMidLine = btnCancel.y - 2 - (btnSelect.h / 2)
			lstFiles.SetWH(cw - 4, ch - (10 + lblDir.h + btnSelect.h + btnCancel.h))
		Else
			BotMidLine = btnCancel.y - 2 - (txtFile.h / 2)
			lstFiles.SetWH(cw - 4, ch - (10 + lblDir.h + txtFile.h + btnCancel.h))
		End If
		btnSelect.SetXY(btnCancel.x, BotMidLine - btnSelect.h / 2)
		txtFile.SetXY(margin, BotMidLine - txtFile.h / 2)
		lstFiles.SetXY(2, lblDir.h + 4)
		SetImageFont(wasfont)
	End Method
	Rem
	bbdoc: Called from a slave gadget.
	about: Slave gadgets do not generate GUI events.  They send events to their Master.
	The Master then uses it or can send a GUI event.
	Internal function should not be called by the user.
	End Rem
	Method SlaveEvent(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		If gadget.Name = Name + "_btnSelect" And id = ifsoGUI_EVENT_CLICK
			SelectClick()
		ElseIf gadget.Name = Name + "_btnCancel" And id = ifsoGUI_EVENT_CLICK
			Selected = ""
			SendEvent(ifsoGUI_EVENT_CLICK, ifsoGUI_FILESELECT_CANCELED, 0, 0)
			Visible = False
			GUI.UnSetModal()
		ElseIf gadget.Name = Name + "_lst" And id = ifsoGUI_EVENT_CLICK
			ListClick()
		ElseIf gadget.Name = Name + "_lst" And id = ifsoGUI_EVENT_DOUBLE_CLICK
			ListDblClick()
		ElseIf gadget.Name = Name + "_txt" And id = ifsoGUI_EVENT_KEYHIT And data = 13
			SelectClick()
		End If
	End Method
	Rem
	bbdoc: Called when the select button is clicked.
	about: Internal function should not be called by the user.
	End Rem
	Method SelectClick()
		Selected = txtFile.Value
	 If Selected = "" Return
		If Selected = ".."
			BackupDir()
			Selected = ""
			txtFile.Value = ""
			Return
		ElseIf Selected = "\" Or Selected = "/"
			Local tmp:Int = Dir.Find("/")
			If tmp > 0 Dir = Dir[..tmp + 1]
			Selected = ""
			txtFile.Value = ""
			Populate()
			Return
		End If
		Select Style
			Case ifsoGUI_FILESELECT_OPENFILE, ifsoGUI_FILESELECT_SAVEFILE
				Local ft:Int = FileType(Dir + Selected)
				Select ft
					Case 0 'doesn't exist
						ft = FileType(Selected) 'Check if the text is an absolute file
						Select ft 'file
							Case 1
								Dir = ExtractDir(Selected)
								Selected = StripDir(Selected)
							Case 2
								Dir = Selected
								Populate()
								Return
						End Select
					Case 2 'dir
						Dir:+Selected
						Populate()
				End Select
			Case ifsoGUI_FILESELECT_OPENDIR
				Local ft:Int = FileType(Dir + Selected)
				If ft = 0
					'Check if absolute path entered
					ft = FileType(Selected)
					If ft = 2
						Dir = ExtractDir(Selected)
						Selected = StripDir(Selected)
					ElseIf ft = 1
						Return
					End If
				ElseIf ft = 1
					Return
				End If
		End Select
		Visible = False
		GUI.UnSetModal()
		SendEvent(ifsoGUI_EVENT_CLICK, ifsoGUI_FILESELECT_SELECTED, 0, 0)
	End Method
	Rem
	bbdoc: Called when an item is clicked in the list box.
	about: Internal function should not be called by the user.
	End Rem
	Method ListClick()
		If lstFiles.GetSelected() < 0 Return
		Selected = lstFiles.GetItemName(lstFiles.GetSelected())
		Local d:Int = False
		If Selected[..1] = "<"
		 d = True 'Selection is a dir
			Selected = Selected[1..Selected.Length - 1]
		End If
		Select Style
			Case ifsoGUI_FILESELECT_OPENFILE, ifsoGUI_FILESELECT_SAVEFILE
				If Not d txtFile.SetText(Selected)
			Case ifsoGUI_FILESELECT_OPENDIR
				If Selected <> ".."
					If d txtFile.Value = Selected
				End If
		End Select
	End Method
	Rem
	bbdoc: Called when an item is double clicked in the list box.
	about: Internal function should not be called by the user.
	End Rem
	Method ListDblClick()
		If lstFiles.GetSelected() < 0 Return
		Local tmp:String = lstFiles.GetItemName(lstFiles.GetSelected())
		Local d:Int = False
		If tmp[..1] = "<"
			d = True
			tmp = tmp[1..tmp.Length - 1]
		End If
		If Selected <> tmp ListClick()
		If Selected = ".."
		 BackupDir()
		Else
			Select Style
				Case ifsoGUI_FILESELECT_OPENFILE, ifsoGUI_FILESELECT_SAVEFILE
					If d
						Dir:+Selected + "/"
						Populate()
					Else
						SelectClick()
					End If
				Case ifsoGUI_FILESELECT_OPENDIR
						SendEvent(ifsoGUI_EVENT_CLICK, ifsoGUI_FILESELECT_SELECTED, 0, 0)
			End Select
		End If
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		HBar.LoadSkin(strSkin)
		VBar.LoadSkin(strSkin)
		lstFiles.LoadSkin(strSkin)
		lblDir.LoadSkin(strSkin)
		txtFile.LoadSkin(strSkin)
		btnSelect.LoadSkin(strSkin)
		btnCancel.LoadSkin(strSkin)
		Super.LoadSkin(strSkin)
		Refresh()
	End Method
	Rem
	bbdoc: Populates the list box from the directory.
	about: Internal function should not be called by the user.
	End Rem
	Method Populate()
		lblDir.SetLabel(Dir)
		lstFiles.RemoveAll()
		?bmxng
		Local d:Byte Ptr = ReadDir(Dir)
		?Not bmxng
		Local d:Int = ReadDir(Dir)
		?
		Local f:String
		Repeat
			f = NextFile(d)
			If f = "."
				'Do Nothing
			ElseIf f = ""
				Exit
			ElseIf FileType(Dir + f) = 2
				lstFiles.AddItem("<" + f + ">")
			End If
			PollSystem()
		Forever
		CloseDir(d)
		d = ReadDir(Dir)
		Repeat
			f = NextFile(d)
			If f = ""
				Exit
			ElseIf FileType(Dir + f) = 1
				lstFiles.AddItem(f)
			End If
			PollSystem()
		Forever
		CloseDir(d)
	End Method
	Rem
	bbdoc: Takes the list up one directory level.
	about: Internal function should not be called by the user.
	End Rem
	Method BackupDir()
		Local tmp:String = RealPath(Dir)
		Local a:Int = tmp.FindLast("/")
		If a = 0 Return
		Dir = Dir[..a + 1]
		Populate()
	End Method

	Rem
	bbdoc: Sets the style of the File Selecter.
	about: This should be called before the Selecter is shown.
	Styles: ifsoGUI_FILESELECT_OPENDIR, ifsoGUI_FILESELECT_SAVEFILE, ifsoGUI_FILESELECT_OPENFILE
	End Rem
	Method SetStyle(iStyle:Int)
		Style = iStyle
		Select iStyle
			Case ifsoGUI_FILESELECT_OPENDIR
				Caption = "Open Directory"
				btnSelect.SetLabel("Open")
			Case ifsoGUI_FILESELECT_SAVEFILE
				Caption = "Save File"
				btnSelect.SetLabel("Save")
			Default
				Caption = "Open File"
				btnSelect.SetLabel("Open")
		End Select
	End Method
	Rem
	bbdoc: Returns the style of the File Select gadget.
	End Rem
	Method GetStyle:Int()
		Return Style
	End Method
	Rem
	bbdoc: Shows the gadget.
	End Rem
	Method Show()
		SetVisible(True)
		txtFile.SetFocus()
	End Method
	Rem
	bbdoc: Sets the gadget Visible/Invisible.
	End Rem
	Method SetVisible(bVisible:Int)
		Visible = bVisible
		If bVisible
			GUI.SetModal(Self)
			BringToFront()
			Populate()
		Else
			GUI.UnSetModal()
			If GUI.gActiveGadget = Self GUI.SetActiveGadget(Null)
			If GUI.gMouseOverGadget = Self GUI.gMouseOverGadget = Null
			If IsMyChild(GUI.gActiveGadget) GUI.SetActiveGadget(Null)
			If IsMyChild(GUI.gMouseOverGadget) GUI.gMouseOverGadget = Null
		End If
	End Method
	Rem
	bbdoc: Sets the current directory of the File Select gadget.
	End Rem
	Method SetDir(strDir:String)
		Dir = RealPath(strDir)
		If Not Dir.Endswith("/") Dir:+"/"
		Populate()
	End Method
	Rem
	bbdoc: Returns the current directory of the gadget.
	End Rem
	Method GetDir:String()
		Return Dir
	End Method
	Rem
	bbdoc: Returns the user selection.  Full directory and file/dir name.
	End Rem
	Method GetSelection:String()
		Return Dir + Selected
	End Method
End Type