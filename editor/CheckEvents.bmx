Function CheckEvents()
	Local e:ifsoGUI_Event
	Repeat
		e = GUI.GetEvent()
		If Not e Exit
		If e.gadget.Name = "lbGadgets" And e.id = ifsoGUI_EVENT_DOUBLE_CLICK
			TProps.NewGadget(ClientArea.lbGadgets.GetSelectedItem().Data)
		ElseIf e.gadget.Name = "btnAddGadget" And e.id = ifsoGUI_EVENT_CLICK
			If ClientArea.lbGadgets.GetSelected() >= 0
				TProps.NewGadget(ClientArea.lbGadgets.GetSelectedItem().Data)
			End If
		ElseIf e.gadget.Name = "cmbGadgets" And e.id = ifsoGUI_EVENT_CHANGE
			TProps.SelectProps(TProps.GetPropsByData(ifsoGUI_ListItem(cbGadgets.dropList.GetItem(e.data)).Data))
			If TGadgetProps(ActiveProps) ActiveProps.PropGadget.SetFocus()
		ElseIf e.gadget.Name = "Screen" And e.id = ifsoGUI_EVENT_MOUSE_UP
			TProps.SelectProps(AppProps)
		ElseIf (e.gadget.Name = "tbScreenR" Or e.gadget.Name = "tbScreenG" Or e.gadget.Name = "tbScreenB") And e.id = ifsoGUI_EVENT_CHANGE
			UpdateBackColor()
		ElseIf e.gadget.name = "ibtnLeft" And e.id = ifsoGUI_EVENT_CLICK
			If Not SelectedProps.IsEmpty()
				Local ix:Int = ActiveProps.PropGadget.x
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(ix, p.PropGadget.y)
				Next
			End If
		ElseIf e.gadget.name = "ibtnCenter" And e.id = ifsoGUI_EVENT_CLICK
			If Not SelectedProps.IsEmpty()
				Local ix:Int = ActiveProps.PropGadget.x + ActiveProps.PropGadget.w / 2
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(ix - (p.PropGadget.w / 2), p.PropGadget.y)
				Next
			End If
		ElseIf e.gadget.name = "ibtnRight" And e.id = ifsoGUI_EVENT_CLICK
			If Not SelectedProps.IsEmpty()
				Local ix:Int = ActiveProps.PropGadget.x + ActiveProps.PropGadget.w
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(ix - p.PropGadget.w, p.PropGadget.y)
				Next
			End If
		ElseIf e.gadget.name = "ibtnTop" And e.id = ifsoGUI_EVENT_CLICK
			If Not SelectedProps.IsEmpty()
				Local iy:Int = ActiveProps.PropGadget.y
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(p.PropGadget.x, iy)
				Next
			End If
		ElseIf e.gadget.name = "ibtnMiddle" And e.id = ifsoGUI_EVENT_CLICK
			If Not SelectedProps.IsEmpty()
				Local iy:Int = ActiveProps.PropGadget.y + ActiveProps.PropGadget.h / 2
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(p.PropGadget.x, iy - (p.PropGadget.h / 2))
				Next
			End If
		ElseIf e.gadget.name = "ibtnBottom" And e.id = ifsoGUI_EVENT_CLICK
			If Not SelectedProps.IsEmpty()
				Local iy:Int = ActiveProps.PropGadget.y + ActiveProps.PropGadget.h
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(p.PropGadget.x, iy - p.PropGadget.h)
				Next
			End If
		ElseIf e.gadget.Name = "ibtnFront" And e.id = ifsoGUI_EVENT_CLICK
			If Not SelectedProps.IsEmpty()
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.BringToFront()
				Next
			End If
			ActiveProps.PropGadget.BringToFront()
		ElseIf e.gadget.Name = "ibtnBack" And e.id = ifsoGUI_EVENT_CLICK
			If Not SelectedProps.IsEmpty()
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SendToBack()
				Next
			End If
			ActiveProps.PropGadget.SendToBack()
		ElseIf e.gadget.Name = "ibtnCode" And e.id = ifsoGUI_EVENT_CLICK
			ClientArea.wndCode.SetVisible(True)
			ClientArea.wndCode.BringToFront()
			GUI.SetModal(ClientArea.wndCode)
			WriteSource()
		ElseIf e.gadget.Name = "btnCancel" And e.id = ifsoGUI_EVENT_CLICK
			GUI.UnSetModal()
			ClientArea.wndCode.SetVisible(False)
		ElseIf e.gadget.name = "ibtnSave" And e.id = ifsoGUI_EVENT_CLICK
			TProps.SelectProps(AppProps)
			Local fs:ifsoGUI_FileSelect = ifsoGUI_FileSelect.Create(30, 30, 400, 400, "fsSaveProject")
			fs.SetStyle(ifsoGUI_FILESELECT_SAVEFILE)
			GUI.AddGadget(fs)
			fs.Show()
		ElseIf e.gadget.name = "ibtnLoad" And e.id = ifsoGUI_EVENT_CLICK
			TProps.SelectProps(AppProps)
			Local fs:ifsoGUI_FileSelect = ifsoGUI_FileSelect.Create(30, 30, 400, 400, "fsLoadProject")
			fs.SetStyle(ifsoGUI_FILESELECT_OPENFILE)
			GUI.AddGadget(fs)
			fs.Show()
		ElseIf e.gadget.name = "ibtnPreview" And e.id = ifsoGUI_EVENT_CLICK
		 Preview()
		ElseIf e.gadget.Name = "mtbCode" And (e.id = ifsoGUI_EVENT_COPY Or e.id = ifsoGUI_EVENT_CUT)
			CopyToClipBoard()
		ElseIf e.gadget.Name = "btnSave" And e.id = ifsoGUI_EVENT_CLICK
			Local fs:ifsoGUI_FileSelect = ifsoGUI_FileSelect.Create(30, 30, 400, 400, "fsSaveCode")
			fs.SetStyle(ifsoGUI_FILESELECT_SAVEFILE)
			GUI.AddGadget(fs)
			fs.Show()
		ElseIf e.gadget.Name = "fsSaveCode" And e.id = ifsoGUI_EVENT_CLICK And e.data = ifsoGUI_FILESELECT_SELECTED
			ClientArea.wndCode.SetVisible(False)
			Local tmp:String = ""
			Local nl$="~r~n" 'v1.18
			tmp:+ "' " + StripDir(ifsoGUI_FileSelect(e.gadget).GetSelection()) + nl + nl
			tmp:+ "SuperStrict" + nl + nl
			tmp:+ "' Import" + nl
			tmp:+ "Framework brl.glmax2d" + nl
			tmp:+ "Import brl.freetypefont" + nl
			tmp:+ "Import brl.pngloader" + nl + nl
			tmp:+ "Import ifsogui.GUI" + nl
			tmp:+ "Import ifsogui.panel" + nl
			tmp:+ "Import ifsogui.window" + nl
			tmp:+ "Import ifsogui.label" + nl
			tmp:+ "Import ifsogui.listbox" + nl
			tmp:+ "Import ifsogui.mclistbox" + nl
			tmp:+ "Import ifsogui.checkbox" + nl
			tmp:+ "Import ifsogui.button" + nl
			tmp:+ "Import ifsogui.textbox" + nl
			tmp:+ "Import ifsogui.progressbar" + nl
			tmp:+ "Import ifsogui.slider" + nl
			tmp:+ "Import ifsogui.combobox" + nl
			tmp:+ "Import ifsogui.spinner" + nl
			tmp:+ "Import ifsogui.imagebutton" + nl
			tmp:+ "Import ifsogui.tabber" + nl
			tmp:+ "Import ifsogui.mltextbox" + nl
			tmp:+ "Import ifsogui.fileselect" + nl + nl
			tmp:+ "Include ~q../editor/incbinSkin.bmx~q" + nl + nl
			tmp:+ "' Init" + nl
			tmp:+ "SetGraphicsDriver GLMax2DDriver()" + nl
			tmp:+ "Graphics("+AppProps.tbX.GetText()+", "+AppProps.tbY.GetText()+")" + nl
			tmp:+ "GUI.SetResolution("+AppProps.tbX.GetText()+", "+AppProps.tbY.GetText()+")" + nl
			tmp:+ "GUI.SetUseIncBin(True)" + nl
			tmp:+ "GUI.LoadTheme(~qSkin2~q)" + nl
			tmp:+ "GUI.SetDefaultFont(LoadImageFont(~qincbin::Skin2/fonts/arial.ttf~q, 12))" + nl
			tmp:+ "GUI.SetDrawMouse(True)" + nl + nl
			tmp:+ "'Init GUI"
			tmp:+ ClientArea.mtbCode.GetValue() + nl
			tmp:+ "' Main" + nl
			tmp:+ "SetClsColor(200, 200, 200)" + nl
			tmp:+ "While Not AppTerminate()" + nl
			tmp:+ "	Cls" + nl
			tmp:+ "	GUI.Refresh()" + nl
			tmp:+ "	Flip 0" + nl
			tmp:+ "Wend" + nl
			tmp:+ "End" + nl
			Local file:TStream = WriteFile(ifsoGUI_FileSelect(e.gadget).GetSelection())
			WriteString(file, tmp)
			file.Close()
		ElseIf e.gadget.Name = "fsSaveProject" And e.id = ifsoGUI_EVENT_CLICK And e.data = ifsoGUI_FILESELECT_SELECTED
			WriteGadgets(ifsoGUI_FileSelect(e.gadget).GetSelection())
		ElseIf e.gadget.Name = "fsLoadProject" And e.id = ifsoGUI_EVENT_CLICK And e.data = ifsoGUI_FILESELECT_SELECTED
			ReadGadgets(ifsoGUI_FileSelect(e.gadget).GetSelection())
		End If
	Forever
End Function

Function FilterNumbers:Int(key:Int, gadget:ifsoGUI_Base)
	'negative sign
	If key = 45
		If ifsoGUI_TextBox(gadget).CursorPos = 0 Or ifsoGUI_TextBox(gadget).SelectBegin = 0 Return True
	End If
	If key >= 48 And Key <= 57 Return True
	Return False
End Function

Function UpdateBackColor()
	Local BackColor:Int[3]
	Local r:ifsoGUI_Base = GUI.GetGadget("tbScreenR")
	If ifsoGUI_TextBox(r).GetText().ToInt() > 255
		ifsoGUI_TextBox(r).SetText("255")
	ElseIf ifsoGUI_TextBox(r).GetText().ToInt() < 1
		ifsoGUI_TextBox(r).SetText("0")
	End If
	Local g:ifsoGUI_Base = GUI.GetGadget("tbScreenG")
	If ifsoGUI_TextBox(g).GetText().ToInt() > 255
		ifsoGUI_TextBox(g).SetText("255")
	ElseIf ifsoGUI_TextBox(g).GetText().ToInt() < 1
		ifsoGUI_TextBox(g).SetText("0")
	End If
	Local b:ifsoGUI_Base = GUI.GetGadget("tbScreenB")
	If ifsoGUI_TextBox(b).GetText().ToInt() > 255
		ifsoGUI_TextBox(b).SetText("255")
	ElseIf ifsoGUI_TextBox(b).GetText().ToInt() < 1
		ifsoGUI_TextBox(b).SetText("0")
	End If
	BackColor[0] = ifsoGUI_TextBox(r).GetText().ToInt()
	BackColor[1] = ifsoGUI_TextBox(g).GetText().ToInt()
	BackColor[2] = ifsoGUI_TextBox(b).GetText().ToInt()
	'Back Image for Screen
	Local BackImage:TImage
	BackImage = CreateImage(2, 2)
	Local pixmap:TPixmap = LockImage(BackImage)
	For Local x:Int = 0 To 1
		For Local y:Int = 0 To 1
			WritePixel(pixmap, x, y, (255 Shl 24) + (BackColor[0] Shl 16) + (BackColor[1] Shl 8) + BackColor[2])
		Next
	Next
	UnlockImage(BackImage)
	SetImageHandle(BackImage, 0, 0)
	ClientArea.Screen.SetBackgroundImage(BackImage)
	ClientArea.Screen.SetAutoSize(ifsoGUI_IMAGE_SCALETOPANEL)
End Function

Function WriteGadgets(filename:String)
	Local file:TStream = WriteFile(filename)
	file.WriteString(AppProps.tbX.GetText() + "~n")
	file.WriteString(AppProps.tbY.GetText() + "~n")
	file.WriteString(ifsoGUI_TextBox(AppProps.pnlProps.GetChild("tbScreenR")).GetText() + "~n")
	file.WriteString(ifsoGUI_TextBox(AppProps.pnlProps.GetChild("tbScreenG")).GetText() + "~n")
	file.WriteString(ifsoGUI_TextBox(AppProps.pnlProps.GetChild("tbScreenB")).GetText() + "~n")
	file.WriteString(AppProps.tbSkin.GetText() + "~n")
	file.WriteString(AppProps.tbFont.GetText() + "~n")
	file.WriteString(AppProps.tbFontSize.GetText() + "~n")
	file.WriteString(AppProps.tbTextColor[0].GetText() + "~n")
	file.WriteString(AppProps.tbTextColor[1].GetText() + "~n")
	file.WriteString(AppProps.tbTextColor[2].GetText())
	For Local g:TPropGadget = EachIn ClientArea.Screen.Children
		g.WriteSelf(file)
	Next
	file.Close()
End Function

Function ReadGadgets(filename:String)
	TProps.SelectProps(AppProps)
	cbGadgets.RemoveAll()
	For Local g:ifsoGUI_Base = EachIn ClientArea.Screen.Children
		ClientArea.Screen.RemoveChild(g)
	Next
	Local file:TStream = ReadFile(filename)
	Local str1:String, str2:String
	str1 = file.ReadLine() 'App X
	str2 = file.ReadLine() ' App Y
	AppProps.tbX.SetText(str1)
	AppProps.tbY.SetText(str2)
	ClientArea.Screen.SetWH(Int(str1), Int(str2))
	str1 = file.ReadLine()
	ifsoGUI_TextBox(AppProps.pnlProps.GetChild("tbScreenR")).SetText(str1)
	str1 = file.ReadLine()
	ifsoGUI_TextBox(AppProps.pnlProps.GetChild("tbScreenG")).SetText(str1)
	str1 = file.ReadLine()
	ifsoGUI_TextBox(AppProps.pnlProps.GetChild("tbScreenB")).SetText(str1)
	UpdateBackColor()
	str1 = file.ReadLine()
	AppProps.tbSkin.SetText(str1)
	str1 = file.ReadLine()
	AppProps.tbFont.SetText(str1)
	str1 = file.ReadLine()
	AppProps.tbFontSize.SetText(str1)
	str1 = file.ReadLine()
	AppProps.tbTextColor[0].SetText(str1)
	str1 = file.ReadLine()
	AppProps.tbTextColor[1].SetText(str1)
	str1 = file.ReadLine()
	AppProps.tbTextColor[2].SetText(str1)
	While Not(file.Eof())
		Local sName:String = file.ReadLine()
		Local sType:String = file.ReadLine()
		Local sParent:String = file.ReadLine()
		Local p:TGadgetProps = TGadgetProps.Create(Int(sType))
		p.Data = TProps.GadgetCounter
		p.PropGadget.Props = p
		TProps.AllProps.AddLast(p)
		p.Selected()
		p.UnSelected()
		p.tbName.SetText(sName)
		p.PropGadget.Name = sName
		p.PropGadget.Gadget.Name = sName
		cbGadgets.AddItem(p.PropGadget.Name, TProps.GadgetCounter, "", False)
		TProps.GadgetCounter:+1
		p.PropGadget.ReadSelf(file)
		If sParent = "Screen"
			ClientArea.Screen.AddChild(p.PropGadget)
		Else
			Local g:ifsoGUI_Base = ClientArea.Screen.GetChild(sParent)
			If ifsoGUI_Panel(TPropGadget(g).Gadget)
				TPropGadget(g).AddChild(p.PropGadget)
				TPropGadget(g).Gadget.AddChild(p.PropGadget.Gadget)
			ElseIf ifsoGUI_Tabber(TPropGadget(g).Gadget)
				TPropGadget(g).AddChild(p.PropGadget)				
				ifsoGUI_Tabber(TPropGadget(g).Gadget).AddTabChild(p.PropGadget.Gadget, p.PropGadget.tab_order) 'v1.18
				'ifsoGUI_Tabber(TPropGadget(g).Gadget).AddTabChild(p.PropGadget.Gadget, ifsoGUI_Tabber(TPropGadget(g).Gadget).GetCurrentTab())
			End If
			
		End If
	Wend
	file.Close()
	cbGadgets.SortList()
	cbGadgets.InsertItem(0, "Application/Game", 0, "Appplication/Game Settings", True)
End Function