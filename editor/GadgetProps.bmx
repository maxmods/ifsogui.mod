Const PROP_BUTTON:Int = 0
Const PROP_PANEL:Int = 1
Const PROP_WINDOW:Int = 2
Const PROP_LABEL:Int = 3
Const PROP_CHECKBOX:Int = 4
Const PROP_COMBOBOX:Int = 5
Const PROP_IMAGEBUTTON:Int = 6
Const PROP_LISTBOX:Int = 7
Const PROP_MCLISTBOX:Int = 8
Const PROP_MLTEXTBOX:Int = 9
Const PROP_PROGRESSBAR_HORZ:Int = 10
Const PROP_PROGRESSBAR_VERT:Int = 11
Const PROP_SCROLLBAR_HORZ:Int = 12
Const PROP_SCROLLBAR_VERT:Int = 13
Const PROP_SLIDER_HORZ:Int = 14
Const PROP_SLIDER_VERT:Int = 15
Const PROP_SPINNER_HORZ:Int = 16
Const PROP_SPINNER_VERT:Int = 17
Const PROP_TEXTBOX:Int = 18
Const PROP_TABBER:Int = 19

Const PROP_GADGET_COUNT:Int = 20

	Function EventCallback(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		ActiveProps.Event(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
	End Function

Type TProps
	Global AllProps:TList = New TList
	Global GadgetCounter:Int = 1

	Field pnlProps:ifsoGUI_Panel
	Field PropGadget:TPropGadget
	Field Data:Int 'Links props to combobox
	Field tbX:ifsoGUI_TextBox, tbY:ifsoGUI_TextBox
	Field tbW:ifsoGUI_TextBox, tbH:ifsoGUI_TextBox
	Field tbName:ifsoGUI_TextBox, tbValue:ifsoGUI_TextBox
	Field tbSkin:ifsoGUI_TextBox, tbFont:ifsoGUI_TextBox, tbFontSize:ifsoGUI_TextBox
	Field tbTextColor:ifsoGUI_TextBox[3]
	Field Font:TImageFont
	Global tab_combo_list:TList=New TList 'v1.18
	Global selected_gadget:TPropGadget=New TPropGadget
	
	Method Selected() Abstract
	Method UnSelected() Abstract
	Method Event(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int) Abstract
	
	Function SelectProps(active:TProps)
		If (KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL)) And ActiveProps <> AppProps
			If active = AppProps Return
			If active = ActiveProps Return
			'Don't allow selecting of multiple gadgets that do not have the same parent.
			If active.PropGadget.Parent = ActiveProps.PropGadget.Parent
				If SelectedProps.Contains(active) SelectedProps.Remove(active)
				SelectedProps.AddLast(ActiveProps) 'add the current to the list
			Else
				SelectedProps.Clear()
			End If
		Else
			'Clear the list
			SelectedProps.Clear()
		End If
		'Make the currently selected one the active one.
		ActiveProps.UnSelected()
		ActiveProps = active
		ActiveProps.Selected()
		For Local i:Int = 0 To cbGadgets.dropList.Items.Length
			If cbGadgets.dropList.Items[i].Data = active.Data
				cbGadgets.SetSelected(i)
				Exit
			End If
		Next
	End Function
	Function NewGadget(iIndex:Int)
		Local p:TGadgetProps = TGadgetProps.Create(iIndex)
		p.Data = GadgetCounter
		p.PropGadget.Props = p
		AllProps.AddLast(p)
		cbGadgets.AddItem(p.PropGadget.Name, GadgetCounter, "", False)
		cbGadgets.RemoveItem(0)
		cbGadgets.SortList()
		cbGadgets.InsertItem(0, "Application/Game", 0, "Appplication/Game Settings", False)
		GadgetCounter:+1
		If ActiveProps <> AppProps
			If ifsoGUI_Panel(ActiveProps.PropGadget.Gadget)
				ActiveProps.PropGadget.AddChild(p.PropGadget)
				ActiveProps.PropGadget.Gadget.AddChild(p.PropGadget.Gadget)
			ElseIf ifsoGUI_Tabber(ActiveProps.PropGadget.Gadget)
				ActiveProps.PropGadget.AddChild(p.PropGadget)
				ifsoGUI_Tabber(ActiveProps.PropGadget.Gadget).AddTabChild(p.PropGadget.Gadget, ifsoGUI_Tabber(ActiveProps.PropGadget.Gadget).GetCurrentTab())
			Else
				ClientArea.Screen.AddChild(p.PropGadget)
			End If
		Else
			ClientArea.Screen.AddChild(p.PropGadget)
		End If
		If AppProps.tbSkin.GetText() <> ""
			p.PropGadget.Gadget.LoadSkin(AppProps.tbSkin.GetText())
		End If
		p.PropGadget.Gadget.SetFont(AppProps.Font)
		p.PropGadget.Gadget.SetTextColor(AppProps.tbTextColor[0].GetText().ToInt(), AppProps.tbTextColor[1].GetText().ToInt(), AppProps.tbTextColor[2].GetText().ToInt())
		SelectProps(p)
	End Function
	Function GetPropsByData:TProps(iData:Int)
		For Local p:TProps = EachIn AllProps
			If p.Data = iData Return p
		Next
		Return AppProps
	End Function
End Type

Type TAppProps Extends TProps

	Method Selected()
		If Not pnlProps
			pnlProps = ifsoGUI_Panel.Create(0, 40, ClientArea.tabConfig.Tabs[0].panel.GetClientWidth(), ClientArea.tabConfig.Tabs[0].panel.GetClientHeight() - 40, "pnlProps")
			pnlProps.SetShowBorder(False)
			ClientArea.tabConfig.AddTabChild(pnlProps, 0)
			
			Local lbl:ifsoGUI_Label = ifsoGUI_Label.Create(0, 0, 180, 25, "lblRes", "Screen Resolution:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			lbl = ifsoGUI_Label.Create(0, 25, 20, 25, "lblResX", "X:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbX:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(25, 25, 50, 25, "tbResX", String(ClientArea.Screen.w))
			tbX.SetFilter(FilterNumbers)
			tbX.SetCallBack(EventCallback)
			pnlProps.AddChild(tbX)
			
			lbl = ifsoGUI_Label.Create(80, 25, 20, 25, "lblResY", "Y:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbY = ifsoGUI_TextBox.Create(105, 25, 50, 25, "tbResY", String(ClientArea.Screen.h))
			tbY.SetFilter(FilterNumbers)
			tbY.SetCallBack(EventCallback)
			pnlProps.AddChild(tbY)
			
			lbl = ifsoGUI_Label.Create(0, 55, 180, 25, "lblColor", "BackGround Color:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			lbl = ifsoGUI_Label.Create(0, 80, 18, 25, "lblR", "R")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			Local tb:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(18, 80, 35, 25, "tbScreenR", "0")
			tb.SetFilter(FilterNumbers)
			tb.SetCallBack(EventCallback)
			pnlProps.AddChild(tb)

			lbl = ifsoGUI_Label.Create(53, 80, 18, 25, "lblG", "G")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tb = ifsoGUI_TextBox.Create(71, 80, 35, 25, "tbScreenG", "0")
			tb.SetFilter(FilterNumbers)
			tb.SetCallBack(EventCallback)
			pnlProps.AddChild(tb)

			lbl = ifsoGUI_Label.Create(106, 80, 18, 25, "lblB", "B")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tb = ifsoGUI_TextBox.Create(124, 80, 35, 25, "tbScreenB", "0")
			tb.SetFilter(FilterNumbers)
			tb.SetCallBack(EventCallback)
			pnlProps.AddChild(tb)

			lbl = ifsoGUI_Label.Create(0, 110, 100, 25, "lblSkin", "Skin")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbSkin = ifsoGUI_TextBox.Create(5, 135, 150, 25, "tbSkin", "")
			tbSkin.SetCallBack(EventCallback)
			pnlProps.AddChild(tbSkin)

			lbl = ifsoGUI_Label.Create(0, 165, 100, 25, "lblFont", "Font")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbFont = ifsoGUI_TextBox.Create(5, 190, 150, 25, "tbFont", "")
			tbFont.SetCallBack(EventCallback)
			pnlProps.AddChild(tbFont)

			lbl = ifsoGUI_Label.Create(0, 220, 70, 25, "lblFontSize", "Font Size:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbFontSize = ifsoGUI_TextBox.Create(70, 220, 50, 25, "tbFontSize", "")
			tbFontSize.SetCallBack(EventCallback)
			tbFontSize.SetFilter(FilterNumbers)
			pnlProps.AddChild(tbFontSize)

			lbl = ifsoGUI_Label.Create(0, 250, 180, 25, "lblText0", "Text Color:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			lbl = ifsoGUI_Label.Create(0, 275, 18, 25, "lblTextR", "R")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbTextColor[0] = ifsoGUI_TextBox.Create(18, 275, 35, 25, "tbText0", "0")
			tbTextColor[0].SetFilter(FilterNumbers)
			tbTextColor[0].SetCallBack(EventCallback)
			pnlProps.AddChild(tbTextColor[0])

			lbl = ifsoGUI_Label.Create(53, 275, 18, 25, "lblTextG", "G")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbTextColor[1] = ifsoGUI_TextBox.Create(71, 275, 35, 25, "tbText1", "0")
			tbTextColor[1].SetFilter(FilterNumbers)
			tbTextColor[1].SetCallBack(EventCallback)
			pnlProps.AddChild(tbTextColor[1])

			lbl = ifsoGUI_Label.Create(106, 275, 18, 25, "lblTextB", "B")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbTextColor[2] = ifsoGUI_TextBox.Create(124, 275, 35, 25, "tbText2", "0")
			tbTextColor[2].SetFilter(FilterNumbers)
			tbTextColor[2].SetCallBack(EventCallback)
			pnlProps.AddChild(tbTextColor[2])
		Else
			pnlProps.SetVisible(True)
		End If
		
	End Method

	Method UnSelected()
		pnlProps.SetVisible(False)
	End Method

	Method Event(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		If gadget = tbX And id = ifsoGUI_EVENT_CHANGE
			Local w:Int = tbX.GetText().ToInt()
			Local h:Int = tbY.GetText().ToInt()
			If w > 0
				ClientArea.Screen.SetWH(w, h)
			Else
				tbX.SetText(String(ClientArea.Screen.w))
			End If
		ElseIf gadget = tbY And id = ifsoGUI_EVENT_CHANGE
			Local w:Int = tbX.GetText().ToInt()
			Local h:Int = tbY.GetText().ToInt()
			If h > 0
				ClientArea.Screen.SetWH(w, h)
			Else
				tbY.SetText(String(ClientArea.Screen.h))
			End If
		ElseIf gadget = tbSkin And id = ifsoGUI_EVENT_CHANGE
			If FileType(tbSkin.GetText()) = FILETYPE_DIR
				For Local p:TProps = EachIn TProps.AllProps
					If p.tbSkin.GetText() = ""
						p.PropGadget.Gadget.LoadSkin(tbSkin.GetText())
					End If
				Next
			Else
				tbSkin.SetText("")
				For Local p:TProps = EachIn TProps.AllProps
					If p.tbSkin.GetText() = ""
						p.PropGadget.Gadget.LoadSkin("")
					End If
				Next
			End If
		ElseIf (gadget = tbFont Or gadget = tbFontSize) And id = ifsoGUI_EVENT_CHANGE
			Font = Null
			If FileType(tbFont.GetText()) = FILETYPE_FILE
				If tbFontSize.GetText() = ""
					tbFontSize.SetText("10")
				End If
				Font = LoadImageFont(tbFont.GetText(), tbFontSize.GetText().ToInt())
			End If
			If Not Font
				tbFont.SetText("")
			End If
			For Local p:TProps = EachIn TProps.AllProps
				If p.tbFont.GetText() = ""
					p.PropGadget.Gadget.SetFont(Font)
				End If
			Next
		ElseIf (gadget = tbTextColor[0] Or gadget = tbTextColor[1] Or gadget = tbTextColor[2]) And id = ifsoGUI_EVENT_CHANGE
			For Local i:Int = 0 To 2
				If tbTextColor[i].GetText().ToInt() < 1 tbTextColor[i].SetText("0")
				If tbTextColor[i].GetText().ToInt() > 255 tbTextColor[i].SetText("255")
			Next
		End If
		
	End Method

End Type

Type TGadgetProps Extends TProps
	Field tbGadgetColor:ifsoGUI_TextBox[3]
	Field tbAlpha:ifsoGUI_TextBox, tbTip:ifsoGUI_TextBox
	Field chkOnTop:ifsoGUI_CheckBox, chkShowFocus:ifsoGUI_CheckBox
	Field tbFocusColor:ifsoGUI_TextBox[3]
	Field chkAutoSize:ifsoGUI_CheckBox
	
	Field iAlpha:Int = 100
	
	Function Create:TGadgetProps(iType:Int)
		Local g:TGadgetProps = New TGadgetProps
		g.PropGadget = TPropGadget.Create(iType)
		Return g
	End Function
	Method Selected()
		If Not pnlProps
			pnlProps = ifsoGUI_Panel.Create(0, 40, ClientArea.tabConfig.Tabs[0].panel.GetClientWidth() - 2, ClientArea.tabConfig.Tabs[0].panel.GetClientHeight() - 40, "pnlProps")
			pnlProps.SetShowBorder(False)
			ClientArea.tabConfig.AddTabChild(pnlProps, 0)

			Local lbl:ifsoGUI_Label = ifsoGUI_Label.Create(0, 0, 53, 24, "lblName", "Name:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)

			tbName = ifsoGUI_TextBox.Create(55, 0, 100, 24, "tbName", PropGadget.Name)
			tbName.SetCallBack(EventCallback)
			pnlProps.AddChild(tbName)
			Local beginY:Int = 30 'Where the standard parameters should begin.  Gadget specific parameters are at the top.
			If ifsoGUI_ImageButton(PropGadget.Gadget)
				beginY = 180
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Label:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", ifsoGUI_ImageButton(PropGadget.Gadget).Label)
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
				lbl = ifsoGUI_Label.Create(0, 60, 53, 24, "lblNormalImage", "Normal:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tb:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(55, 60, 100, 24, "tbNormalImage")
				tb.SetCallBack(EventCallback)
				pnlProps.AddChild(tb)
				lbl = ifsoGUI_Label.Create(0, 90, 53, 24, "lblOverImage", "Over:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tb = ifsoGUI_TextBox.Create(55, 90, 100, 24, "tbOverImage")
				tb.SetCallBack(EventCallback)
				pnlProps.AddChild(tb)
				lbl = ifsoGUI_Label.Create(0, 120, 53, 24, "lblDownImage", "Down:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tb = ifsoGUI_TextBox.Create(55, 120, 100, 24, "tbDownImage")
				tb.SetCallBack(EventCallback)
				pnlProps.AddChild(tb)
				Local chk:ifsoGUI_CheckBox = ifsoGUI_CheckBox.Create(5, 150, 120, 24, "chkShowLabel", "Show Label")
				chk.SetCallBack(EventCallback)
				pnlProps.AddChild(chk)
			ElseIf ifsoGUI_Button(PropGadget.Gadget)
				beginY = 60
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Label:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", ifsoGUI_Button(PropGadget.Gadget).Label)
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
			ElseIf ifsoGUI_Label(PropGadget.Gadget)
				beginY = 60
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Label:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", ifsoGUI_Label(PropGadget.Gadget).Label)
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
			ElseIf ifsoGUI_CheckBox(PropGadget.Gadget)
				beginY = 90
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Label:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", ifsoGUI_CheckBox(PropGadget.Gadget).Label)
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
				Local chk:ifsoGUI_CheckBox = ifsoGUI_CheckBox.Create(5, 60, 70, 24, "chkChecked", "Checked")
				chk.SetCallBack(EventCallback)
				pnlProps.AddChild(chk)
			ElseIf ifsoGUI_Combobox(PropGadget.Gadget)
				beginY = 30
			ElseIf ifsoGUI_Window(PropGadget.Gadget)
				beginY = 150
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Caption:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", ifsoGUI_Window(PropGadget.Gadget).Caption)
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
				lbl = ifsoGUI_Label.Create(0, 60, 100, 24, "lblScrollbars", "Scrollbars:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local cbScrollbars:ifsoGUI_Combobox = ifsoGUI_Combobox.Create(5, 85, 160, 24, "cbScrollbars")
				cbScrollbars.SetCallBack(EventCallback)
				cbScrollbars.AddItem("Automatic", ifsoGUI_SCROLLBAR_AUTO, "", True)
				cbScrollbars.AddItem("Always On", ifsoGUI_SCROLLBAR_ON, "", False)
				cbScrollbars.AddItem("Always Off", ifsoGUI_SCROLLBAR_OFF, "", False)
				pnlProps.AddChild(cbScrollbars)
				lbl = ifsoGUI_Label.Create(0, 115, 110, 24, "lblAlpha", "Scrollbar Width:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tbScrollWidth:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(110, 115, 40, 24, "tbScrollWidth", ifsoGUI_Window(PropGadget.Gadget).ScrollBarWidth)
				tbScrollWidth.SetCallBack(EventCallback)
				tbScrollWidth.SetFilter(FilterNumbers)
				pnlProps.AddChild(tbScrollWidth)
				Local spnScrollWidth:ifsoGUI_Spinner = ifsoGUI_Spinner.Create(150, 115, 13, 24, "spnScrollWidth")
				spnScrollWidth.SetCallBack(EventCallback)
				pnlProps.AddChild(spnScrollWidth)
			ElseIf ifsoGUI_Panel(PropGadget.Gadget)
				beginY = 120
				lbl = ifsoGUI_Label.Create(0, 30, 100, 24, "lblScrollbars", "Scrollbars:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local cbScrollbars:ifsoGUI_Combobox = ifsoGUI_Combobox.Create(5, 55, 160, 24, "cbScrollbars")
				cbScrollbars.SetCallBack(EventCallback)
				cbScrollbars.AddItem("Automatic", ifsoGUI_SCROLLBAR_AUTO, "", True)
				cbScrollbars.AddItem("Always On", ifsoGUI_SCROLLBAR_ON, "", False)
				cbScrollbars.AddItem("Always Off", ifsoGUI_SCROLLBAR_OFF, "", False)
				pnlProps.AddChild(cbScrollbars)
				lbl = ifsoGUI_Label.Create(0, 85, 110, 24, "lblAlpha", "Scrollbar Width:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tbScrollWidth:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(110, 85, 40, 24, "tbScrollWidth", ifsoGUI_Panel(PropGadget.Gadget).ScrollBarWidth)
				tbScrollWidth.SetCallBack(EventCallback)
				tbScrollWidth.SetFilter(FilterNumbers)
				pnlProps.AddChild(tbScrollWidth)
				Local spnScrollWidth:ifsoGUI_Spinner = ifsoGUI_Spinner.Create(150, 85, 13, 24, "spnScrollWidth")
				spnScrollWidth.SetCallBack(EventCallback)
				pnlProps.AddChild(spnScrollWidth)
			ElseIf ifsoGUI_ListBox(PropGadget.Gadget)
				beginY = 180
				lbl = ifsoGUI_Label.Create(0, 30, 160, 24, "lblVScrollbar", "Vertical Scrollbar:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local cbScrollbars:ifsoGUI_Combobox = ifsoGUI_Combobox.Create(5, 55, 160, 24, "cbVScrollbar")
				cbScrollbars.SetCallBack(EventCallback)
				cbScrollbars.AddItem("Automatic", ifsoGUI_SCROLLBAR_AUTO, "", True)
				cbScrollbars.AddItem("Always On", ifsoGUI_SCROLLBAR_ON, "", False)
				cbScrollbars.AddItem("Always Off", ifsoGUI_SCROLLBAR_OFF, "", False)
				pnlProps.AddChild(cbScrollbars)
				lbl = ifsoGUI_Label.Create(0, 90, 160, 24, "lblHScrollbar", "Horizontal Scrollbar:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				cbScrollbars = ifsoGUI_Combobox.Create(5, 115, 160, 24, "cbHScrollbar")
				cbScrollbars.SetCallBack(EventCallback)
				cbScrollbars.AddItem("Automatic", ifsoGUI_SCROLLBAR_AUTO, "", False)
				cbScrollbars.AddItem("Always On", ifsoGUI_SCROLLBAR_ON, "", False)
				cbScrollbars.AddItem("Always Off", ifsoGUI_SCROLLBAR_OFF, "", True)
				pnlProps.AddChild(cbScrollbars)
				lbl = ifsoGUI_Label.Create(0, 150, 110, 24, "lblAlpha", "Scrollbar Width:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tbScrollWidth:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(110, 145, 40, 24, "tbScrollWidth", ifsoGUI_ListBox(PropGadget.Gadget).ScrollBarWidth)
				tbScrollWidth.SetCallBack(EventCallback)
				tbScrollWidth.SetFilter(FilterNumbers)
				pnlProps.AddChild(tbScrollWidth)
				Local spnScrollWidth:ifsoGUI_Spinner = ifsoGUI_Spinner.Create(150, 145, 13, 24, "spnScrollWidth")
				spnScrollWidth.SetCallBack(EventCallback)
				pnlProps.AddChild(spnScrollWidth)
			ElseIf ifsoGUI_MCListBox(PropGadget.Gadget)
				beginY = 180
				lbl = ifsoGUI_Label.Create(0, 30, 160, 24, "lblVScrollbar", "Vertical Scrollbar:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local cbScrollbars:ifsoGUI_Combobox = ifsoGUI_Combobox.Create(5, 55, 160, 24, "cbVScrollbar")
				cbScrollbars.SetCallBack(EventCallback)
				cbScrollbars.AddItem("Automatic", ifsoGUI_SCROLLBAR_AUTO, "", True)
				cbScrollbars.AddItem("Always On", ifsoGUI_SCROLLBAR_ON, "", False)
				cbScrollbars.AddItem("Always Off", ifsoGUI_SCROLLBAR_OFF, "", False)
				pnlProps.AddChild(cbScrollbars)
				lbl = ifsoGUI_Label.Create(0, 90, 160, 24, "lblHScrollbar", "Horizontal Scrollbar:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				cbScrollbars = ifsoGUI_Combobox.Create(5, 115, 160, 24, "cbHScrollbar")
				cbScrollbars.SetCallBack(EventCallback)
				cbScrollbars.AddItem("Automatic", ifsoGUI_SCROLLBAR_AUTO, "", True)
				cbScrollbars.AddItem("Always On", ifsoGUI_SCROLLBAR_ON, "", False)
				cbScrollbars.AddItem("Always Off", ifsoGUI_SCROLLBAR_OFF, "", False)
				pnlProps.AddChild(cbScrollbars)
				lbl = ifsoGUI_Label.Create(0, 150, 110, 24, "lblAlpha", "Scrollbar Width:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tbScrollWidth:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(110, 145, 40, 24, "tbScrollWidth", ifsoGUI_MCListBox(PropGadget.Gadget).ScrollBarWidth)
				tbScrollWidth.SetCallBack(EventCallback)
				tbScrollWidth.SetFilter(FilterNumbers)
				pnlProps.AddChild(tbScrollWidth)
				Local spnScrollWidth:ifsoGUI_Spinner = ifsoGUI_Spinner.Create(150, 145, 13, 24, "spnScrollWidth")
				spnScrollWidth.SetCallBack(EventCallback)
				pnlProps.AddChild(spnScrollWidth)
			ElseIf ifsoGUI_MLTextBox(PropGadget.Gadget)
				beginY = 210
				lbl = ifsoGUI_Label.Create(0, 30, 160, 24, "lblVScrollbar", "Vertical Scrollbar:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local cbScrollbars:ifsoGUI_Combobox = ifsoGUI_Combobox.Create(5, 55, 160, 24, "cbVScrollbar")
				cbScrollbars.SetCallBack(EventCallback)
				cbScrollbars.AddItem("Automatic", ifsoGUI_SCROLLBAR_AUTO, "", True)
				cbScrollbars.AddItem("Always On", ifsoGUI_SCROLLBAR_ON, "", False)
				cbScrollbars.AddItem("Always Off", ifsoGUI_SCROLLBAR_OFF, "", False)
				pnlProps.AddChild(cbScrollbars)
				lbl = ifsoGUI_Label.Create(0, 90, 160, 24, "lblHScrollbar", "Horizontal Scrollbar:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				cbScrollbars = ifsoGUI_Combobox.Create(5, 115, 160, 24, "cbHScrollbar")
				cbScrollbars.SetCallBack(EventCallback)
				cbScrollbars.AddItem("Automatic", ifsoGUI_SCROLLBAR_AUTO, "", True)
				cbScrollbars.AddItem("Always On", ifsoGUI_SCROLLBAR_ON, "", False)
				cbScrollbars.AddItem("Always Off", ifsoGUI_SCROLLBAR_OFF, "", False)
				pnlProps.AddChild(cbScrollbars)
				lbl = ifsoGUI_Label.Create(0, 150, 110, 24, "lblAlpha", "Scrollbar Width:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tbScrollWidth:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(110, 145, 40, 24, "tbScrollWidth", ifsoGUI_MLTextBox(PropGadget.Gadget).ScrollBarWidth)
				tbScrollWidth.SetCallBack(EventCallback)
				tbScrollWidth.SetFilter(FilterNumbers)
				pnlProps.AddChild(tbScrollWidth)
				Local spnScrollWidth:ifsoGUI_Spinner = ifsoGUI_Spinner.Create(150, 145, 13, 24, "spnScrollWidth")
				spnScrollWidth.SetCallBack(EventCallback)
				pnlProps.AddChild(spnScrollWidth)
				Local chk:ifsoGUI_CheckBox = ifsoGUI_CheckBox.Create(5, 180, 100, 24, "chkWordWrap", "WordWrap")
				chk.SetValue(True)
				chk.SetCallBack(EventCallback)
				pnlProps.AddChild(chk)
			ElseIf ifsoGUI_ProgressBar(PropGadget.Gadget)
				beginY = 90
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Value:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", String(ifsoGUI_ProgressBar(PropGadget.Gadget).Value))
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
				lbl = ifsoGUI_Label.Create(0, 60, 30, 24, "lblMin", "Min:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tb:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(35, 60, 40, 24, "tbMin", String(ifsoGUI_ProgressBar(PropGadget.Gadget).iMin))
				tb.SetCallBack(EventCallback)
				tb.SetFilter(FilterNumbers)
				pnlProps.AddChild(tb)
				lbl = ifsoGUI_Label.Create(80, 60, 35, 24, "lblMax", "Max:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tb = ifsoGUI_TextBox.Create(120, 60, 40, 24, "tbMax", String(ifsoGUI_ProgressBar(PropGadget.Gadget).iMax))
				tb.SetCallBack(EventCallback)
				tb.SetFilter(FilterNumbers)
				pnlProps.AddChild(tb)
			ElseIf ifsoGUI_ScrollBar(Propgadget.Gadget)
				beginY = 150
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Value:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", String(ifsoGUI_ScrollBar(PropGadget.Gadget).Value))
				tbValue.SetFilter(FilterNumbers)
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
				lbl = ifsoGUI_Label.Create(0, 60, 30, 24, "lblMin", "Min:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tb:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(35, 60, 40, 24, "tbMin", String(ifsoGUI_ScrollBar(PropGadget.Gadget).MinVal))
				tb.SetCallBack(EventCallback)
				tb.SetFilter(FilterNumbers)
				pnlProps.AddChild(tb)
				lbl = ifsoGUI_Label.Create(80, 60, 35, 24, "lblMax", "Max:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tb = ifsoGUI_TextBox.Create(120, 60, 40, 24, "tbMax", String(ifsoGUI_ScrollBar(PropGadget.Gadget).MaxVal))
				tb.SetCallBack(EventCallback)
				tb.SetFilter(FilterNumbers)
				pnlProps.AddChild(tb)
				lbl = ifsoGUI_Label.Create(0, 90, 53, 24, "lblInterval", "Interval:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tb = ifsoGUI_TextBox.Create(55, 90, 50, 24, "tbInterval", String(ifsoGUI_ScrollBar(PropGadget.Gadget).Interval))
				tb.SetFilter(FilterNumbers)
				tb.SetCallBack(EventCallback)
				pnlProps.AddChild(tb)
				lbl = ifsoGUI_Label.Create(0, 120, 80, 24, "lblBarInterval", "Bar Interval:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tb = ifsoGUI_TextBox.Create(85, 120, 50, 24, "tbBarInterval", String(ifsoGUI_ScrollBar(PropGadget.Gadget).Size))
				tb.SetFilter(FilterNumbers)
				tb.SetCallBack(EventCallback)
				pnlProps.AddChild(tb)
			ElseIf ifsoGUI_Slider(Propgadget.Gadget)
				beginY = 180
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Value:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", String(ifsoGUI_Slider(PropGadget.Gadget).Value))
				tbValue.SetFilter(FilterNumbers)
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
				lbl = ifsoGUI_Label.Create(0, 60, 30, 24, "lblMin", "Min:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tb:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(35, 60, 40, 24, "tbMin", String(ifsoGUI_Slider(PropGadget.Gadget).MinVal))
				tb.SetCallBack(EventCallback)
				tb.SetFilter(FilterNumbers)
				pnlProps.AddChild(tb)
				lbl = ifsoGUI_Label.Create(80, 60, 35, 24, "lblMax", "Max:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tb = ifsoGUI_TextBox.Create(120, 60, 40, 24, "tbMax", String(ifsoGUI_Slider(PropGadget.Gadget).MaxVal))
				tb.SetCallBack(EventCallback)
				tb.SetFilter(FilterNumbers)
				pnlProps.AddChild(tb)
				lbl = ifsoGUI_Label.Create(0, 90, 53, 24, "lblInterval", "Interval:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tb = ifsoGUI_TextBox.Create(55, 90, 50, 24, "tbInterval", String(ifsoGUI_Slider(PropGadget.Gadget).Interval))
				tb.SetFilter(FilterNumbers)
				tb.SetCallBack(EventCallback)
				pnlProps.AddChild(tb)
				Local chk:ifsoGUI_CheckBox = ifsoGUI_CheckBox.Create(5, 120, 100, 24, "chkShowTicks", "Show Ticks")
				chk.SetCallBack(EventCallback)
				chk.SetValue(True)
				pnlProps.AddChild(chk)
				chk = ifsoGUI_CheckBox.Create(5, 150, 140, 24, "chkDirection", "Handle Reversed")
				chk.SetCallBack(EventCallback)
				pnlProps.AddChild(chk)
			ElseIf ifsoGUI_TextBox(PropGadget.Gadget)
				beginY = 60
				lbl = ifsoGUI_Label.Create(0, 30, 53, 24, "lblValue", "Text:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				tbValue = ifsoGUI_TextBox.Create(55, 30, 100, 24, "tbValue", ifsoGUI_TextBox(PropGadget.Gadget).Value)
				tbValue.SetCallBack(EventCallback)
				pnlProps.AddChild(tbValue)
			ElseIf ifsoGUI_Tabber(PropGadget.Gadget)
				beginY = 150
				lbl = ifsoGUI_Label.Create(0, 30, 130, 24, "lblCurrent", "Current Tab:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local cb:ifsoGUI_Combobox = ifsoGUI_Combobox.Create(5, 55, 160, 24, "cbCurrent")
				cb.SetCallBack(EventCallback)
				ListAddLast ActiveProps.tab_combo_list,cb 'v1.18
				cb.AddItem("Tab 1", 0, "", True)
				pnlProps.AddChild(cb)
				lbl = ifsoGUI_Label.Create(0, 90, 70, 24, "lblCurrent", "Tab Text:")
				lbl.SetShowBorder(False)
				pnlProps.AddChild(lbl)
				Local tb:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(70, 90, 100, 24, "tbTabText", "Tab 1")
				tb.SetCallBack(EventCallback)
				pnlProps.AddChild(tb)
				Local btn:ifsoGUI_Button = ifsoGUI_Button.Create(5, 120, 60, 24, "btnAddTab", "Add Tab")
				btn.SetCallBack(EventCallback)
				pnlProps.AddChild(btn)
				btn = ifsoGUI_Button.Create(70, 120, 100, 24, "btnRemoveTab", "Remove Tab")
				btn.SetCallBack(EventCallback)
				pnlProps.AddChild(btn)
			End If
			
			lbl = ifsoGUI_Label.Create(0, 0 + beginY, 20, 24, "lblPosX", "X:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
	
			tbX = ifsoGUI_TextBox.Create(25, 0 + beginY, 50, 24, "tbX", String(PropGadget.x))
			tbX.SetFilter(FilterNumbers)
			tbX.SetCallBack(EventCallback)
			pnlProps.AddChild(tbX)
	
			lbl = ifsoGUI_Label.Create(80, 0 + beginY, 20, 24, "lblPosY", "Y:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbY = ifsoGUI_TextBox.Create(105, 0 + beginY, 50, 24, "tbY", String(PropGadget.y))
			tbY.SetFilter(FilterNumbers)
			tbY.SetCallBack(EventCallback)
			pnlProps.AddChild(tbY)
			
			lbl = ifsoGUI_Label.Create(0, 30 + beginY, 20, 24, "lblW", "W:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
	
			tbW = ifsoGUI_TextBox.Create(25, 30 + beginY, 50, 24, "tbW", String(PropGadget.w))
			tbW.SetFilter(FilterNumbers)
			tbW.SetCallBack(EventCallback)
			pnlProps.AddChild(tbW)
	
			lbl = ifsoGUI_Label.Create(80, 30 + beginY, 20, 24, "lblH", "H:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbH = ifsoGUI_TextBox.Create(105, 30 + beginY, 50, 24, "tbH", String(PropGadget.h))
			tbH.SetFilter(FilterNumbers)
			tbH.SetCallBack(EventCallback)
			pnlProps.AddChild(tbH)

			lbl = ifsoGUI_Label.Create(0, 60 + beginY, 100, 24, "lblSkin", "Skin:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbSkin = ifsoGUI_TextBox.Create(5, 85 + beginY, 150, 24, "tbSkin", "")
			tbSkin.SetCallBack(EventCallback)
			pnlProps.AddChild(tbSkin)

			lbl = ifsoGUI_Label.Create(0, 115 + beginY, 100, 24, "lblFont", "Font:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbFont = ifsoGUI_TextBox.Create(5, 140 + beginY, 150, 24, "tbFont", "")
			tbFont.SetCallBack(EventCallback)
			pnlProps.AddChild(tbFont)

			lbl = ifsoGUI_Label.Create(0, 170 + beginY, 70, 24, "lblFontSize", "Font Size:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbFontSize = ifsoGUI_TextBox.Create(70, 170 + beginY, 50, 24, "tbFontSize", "")
			tbFontSize.SetCallBack(EventCallback)
			tbFontSize.SetFilter(FilterNumbers)
			pnlProps.AddChild(tbFontSize)

			lbl = ifsoGUI_Label.Create(0, 200 + beginY, 150, 24, "lblTextColor", "Text Color:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			lbl = ifsoGUI_Label.Create(0, 225 + beginY, 18, 24, "lblTextR", "R")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbTextColor[0] = ifsoGUI_TextBox.Create(18, 225 + beginY, 35, 24, "tbText0", String(Propgadget.Gadget.TextColor[0]))
			tbTextColor[0].SetFilter(FilterNumbers)
			tbTextColor[0].SetCallBack(EventCallback)
			pnlProps.AddChild(tbTextColor[0])

			lbl = ifsoGUI_Label.Create(53, 225 + beginY, 18, 24, "lblTextG", "G")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbTextColor[1] = ifsoGUI_TextBox.Create(71, 225 + beginY, 35, 24, "tbText1", String(Propgadget.Gadget.TextColor[1]))
			tbTextColor[1].SetFilter(FilterNumbers)
			tbTextColor[1].SetCallBack(EventCallback)
			pnlProps.AddChild(tbTextColor[1])

			lbl = ifsoGUI_Label.Create(106, 225 + beginY, 18, 24, "lblTextB", "B")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbTextColor[2] = ifsoGUI_TextBox.Create(124, 225 + beginY, 35, 24, "tbText2", String(Propgadget.Gadget.TextColor[2]))
			tbTextColor[2].SetFilter(FilterNumbers)
			tbTextColor[2].SetCallBack(EventCallback)
			pnlProps.AddChild(tbTextColor[2])

			lbl = ifsoGUI_Label.Create(0, 255 + beginY, 150, 24, "lblGadgetColor", "Gadget Color:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			lbl = ifsoGUI_Label.Create(0, 280 + beginY, 18, 24, "lblGadgetR", "R")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbGadgetColor[0] = ifsoGUI_TextBox.Create(18, 280 + beginY, 35, 24, "tbGadget0", "255")
			tbGadgetColor[0].SetFilter(FilterNumbers)
			tbGadgetColor[0].SetCallBack(EventCallback)
			pnlProps.AddChild(tbGadgetColor[0])

			lbl = ifsoGUI_Label.Create(53, 280 + beginY, 18, 24, "lblGadgetG", "G")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbGadgetColor[1] = ifsoGUI_TextBox.Create(71, 280 + beginY, 35, 24, "tbGadget1", "255")
			tbGadgetColor[1].SetFilter(FilterNumbers)
			tbGadgetColor[1].SetCallBack(EventCallback)
			pnlProps.AddChild(tbGadgetColor[1])

			lbl = ifsoGUI_Label.Create(106, 280 + beginY, 18, 24, "lblGadgetB", "B")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbGadgetColor[2] = ifsoGUI_TextBox.Create(124, 280 + beginY, 35, 24, "tbGadget2", "255")
			tbGadgetColor[2].SetFilter(FilterNumbers)
			tbGadgetColor[2].SetCallBack(EventCallback)
			pnlProps.AddChild(tbGadgetColor[2])

			lbl = ifsoGUI_Label.Create(0, 310 + beginY, 50, 24, "lblAlpha", "Alpha:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbAlpha = ifsoGUI_TextBox.Create(50, 310 + beginY, 50, 24, "tbAlpha", "1.0")
			tbAlpha.SetCallBack(EventCallback)
			pnlProps.AddChild(tbAlpha)

			Local spin:ifsoGUI_Spinner = ifsoGUI_Spinner.Create(100, 310 + beginY, 13, 24, "spinAlpha")
			spin.SetCallBack(EventCallback)
			pnlProps.AddChild(spin)

			lbl = ifsoGUI_Label.Create(0, 340 + beginY, 30, 24, "lblTip", "Tip:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbTip = ifsoGUI_TextBox.Create(30, 340 + beginY, 135, 24, "tbTip", "")
			tbTip.SetCallBack(EventCallback)
			pnlProps.AddChild(tbTip)
			
			chkOnTop = ifsoGUI_CheckBox.Create(5, 370 + beginY, 120, 24, "chkOnTop", "Always On Top")
			chkOnTop.SetCallBack(EventCallback)
			pnlProps.AddChild(chkOnTop)

			chkAutoSize = ifsoGUI_CheckBox.Create(5, 395 + beginY, 80, 24, "chkAutoSize", "Auto Size")
			chkAutoSize.SetCallBack(EventCallback)
			pnlProps.AddChild(chkAutoSize)

			chkShowFocus = ifsoGUI_CheckBox.Create(5, 420 + beginY, 100, 24, "chkShowFocus", "Show Focus")
			chkShowFocus.SetCallBack(EventCallback)
			chkShowFocus.SetValue(True)
			pnlProps.AddChild(chkShowFocus)

			lbl = ifsoGUI_Label.Create(0, 445 + beginY, 150, 24, "lblFocusColor", "Focus Color:")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			lbl = ifsoGUI_Label.Create(0, 470 + beginY, 18, 24, "lblFocusR", "R")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbFocusColor[0] = ifsoGUI_TextBox.Create(18, 470 + beginY, 35, 24, "tbFocus0", "255")
			tbFocusColor[0].SetFilter(FilterNumbers)
			tbFocusColor[0].SetCallBack(EventCallback)
			pnlProps.AddChild(tbFocusColor[0])

			lbl = ifsoGUI_Label.Create(53, 470 + beginY, 18, 24, "lblFocusG", "G")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbFocusColor[1] = ifsoGUI_TextBox.Create(71, 470 + beginY, 35, 24, "tbFocus1", "255")
			tbFocusColor[1].SetFilter(FilterNumbers)
			tbFocusColor[1].SetCallBack(EventCallback)
			pnlProps.AddChild(tbFocusColor[1])

			lbl = ifsoGUI_Label.Create(106, 470 + beginY, 18, 24, "lblFocusB", "B")
			lbl.SetShowBorder(False)
			pnlProps.AddChild(lbl)
			
			tbFocusColor[2] = ifsoGUI_TextBox.Create(124, 470 + beginY, 35, 24, "tbFocus2", "255")
			tbFocusColor[2].SetFilter(FilterNumbers)
			tbFocusColor[2].SetCallBack(EventCallback)
			pnlProps.AddChild(tbFocusColor[2])

		Else
			pnlProps.SetVisible(True)
		End If
	End Method
	Method UnSelected()
		pnlProps.SetVisible(False)
	End Method
	Method Event(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		If gadget = tbX And id = ifsoGUI_EVENT_CHANGE
			PropGadget.SetXY(tbX.GetText().ToInt(), tbY.GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.PropGadget.SetXY(tbX.GetText().ToInt(), p.PropGadget.y)
			Next
		ElseIf gadget = tbY And id = ifsoGUI_EVENT_CHANGE
			PropGadget.SetXY(tbX.GetText().ToInt(), tbY.GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.PropGadget.SetXY(p.PropGadget.x, tbY.GetText().ToInt())
			Next
		ElseIf gadget = tbH And id = ifsoGUI_EVENT_CHANGE
			PropGadget.SetWH(tbW.GetText().ToInt(), tbH.GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.PropGadget.SetWH(tbW.GetText().ToInt(), p.PropGadget.h)
			Next
		ElseIf gadget = tbW And id = ifsoGUI_EVENT_CHANGE
			PropGadget.SetWH(tbW.GetText().ToInt(), tbH.GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.PropGadget.SetWH(p.PropGadget.w, tbH.GetText().ToInt())
			Next
		ElseIf gadget = tbName And id = ifsoGUI_EVENT_CHANGE
			If tbName.GetText() = ""
				tbName.SetText(PropGadget.Name)
			Else
				For Local i:Int = 0 To cbGadgets.dropList.Items.Length - 1
					If ifsoGUI_ListItem(cbGadgets.dropList.Items[i]).Data = Self.Data
						ifsoGUI_ListItem(cbGadgets.dropList.Items[i]).Name = tbName.GetText()
						cbGadgets.RemoveItem(0)
						cbGadgets.SortList()
						cbGadgets.InsertItem(0, "Application/Game", 0, "Appplication/Game Settings", False)
						Exit
					End If
				Next
				PropGadget.Name = tbName.GetText()
				PropGadget.Gadget.Name = tbName.GetText()
				If ifsoGUI_MLTextBox(PropGadget.Gadget) ifsoGUI_MLTextBox(PropGadget.Gadget).SetValue(tbName.GetText())
			End If
		ElseIf gadget = tbValue And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_Button(PropGadget.Gadget) ifsoGUI_Button(PropGadget.Gadget).SetLabel(tbValue.GetText())
			If ifsoGUI_Label(PropGadget.Gadget) ifsoGUI_Label(PropGadget.Gadget).SetLabel(tbValue.GetText())
			If ifsoGUI_TextBox(PropGadget.Gadget) ifsoGUI_TextBox(PropGadget.Gadget).SetText(tbValue.GetText())
			If ifsoGUI_CheckBox(PropGadget.Gadget) ifsoGUI_CheckBox(PropGadget.Gadget).SetLabel(tbValue.GetText())
			If ifsoGUI_Window(PropGadget.Gadget) ifsoGUI_Window(PropGadget.Gadget).SetCaption(tbValue.GetText())
			If ifsoGUI_ProgressBar(PropGadget.Gadget) ifsoGUI_ProgressBar(PropGadget.Gadget).SetValue(Int(tbValue.GetText()))
			If ifsoGUI_ScrollBar(PropGadget.Gadget) ifsoGUI_ScrollBar(PropGadget.Gadget).SetValue(Int(tbValue.GetText()))
			If ifsoGUI_Slider(PropGadget.Gadget)
				ifsoGUI_Slider(PropGadget.Gadget).SetValue(Int(tbValue.GetText()))
				ifsoGUI_TextBox(gadget).SetText(ifsoGUI_Slider(PropGadget.Gadget).Value)
			End If
		ElseIf gadget = tbSkin And id = ifsoGUI_EVENT_CHANGE
			If Not FileType(tbSkin.GetText()) = FILETYPE_DIR
				tbSkin.SetText("")
			End If
			PropGadget.Gadget.LoadSkin(tbSkin.GetText())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.PropGadget.LoadSkin(tbSkin.GetText())
			Next
		ElseIf (gadget = tbFont Or gadget = tbFontSize) And id = ifsoGUI_EVENT_CHANGE
			Font = Null
			If FileType(tbFont.GetText()) = FILETYPE_FILE
				If tbFontSize.GetText() = ""
					tbFontSize.SetText("10")
				End If
				Font = LoadImageFont(tbFont.GetText(), tbFontSize.GetText().ToInt())
			End If
			If Not Font
				tbFont.SetText("")
			End If
			If Font
				PropGadget.Gadget.SetFont(Font)
			Else
				PropGadget.Gadget.SetFont(AppProps.Font)
			End If
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbFont.SetText(tbFont.GetText())
				p.tbFontSize.SetText(tbFontSize.GetText())
				p.PropGadget.Gadget.SetFont(PropGadget.Gadget.fFont)
			Next
		ElseIf gadget = tbTextColor[0] And id = ifsoGUI_EVENT_CHANGE
			If tbTextColor[0].GetText().ToInt() < 1 tbTextColor[0].SetText("0")
			If tbTextColor[0].GetText().ToInt() > 255 tbTextColor[0].SetText("255")
			PropGadget.Gadget.SetTextColor(tbTextColor[0].GetText().ToInt(), tbTextColor[1].GetText().ToInt(), tbTextColor[2].GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbTextColor[0].SetText(tbTextColor[0].GetText())
				p.PropGadget.Gadget.SetTextColor(p.tbTextColor[0].GetText().ToInt(), p.tbTextColor[1].GetText().ToInt(), p.tbTextColor[2].GetText().ToInt())
			Next
		ElseIf gadget = tbTextColor[1] And id = ifsoGUI_EVENT_CHANGE
			If tbTextColor[1].GetText().ToInt() < 1 tbTextColor[1].SetText("0")
			If tbTextColor[1].GetText().ToInt() > 255 tbTextColor[1].SetText("255")
			PropGadget.Gadget.SetTextColor(tbTextColor[0].GetText().ToInt(), tbTextColor[1].GetText().ToInt(), tbTextColor[2].GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbTextColor[1].SetText(tbTextColor[1].GetText())
				p.PropGadget.Gadget.SetTextColor(p.tbTextColor[0].GetText().ToInt(), p.tbTextColor[1].GetText().ToInt(), p.tbTextColor[2].GetText().ToInt())
			Next
		ElseIf gadget = tbTextColor[2] And id = ifsoGUI_EVENT_CHANGE
			If tbTextColor[2].GetText().ToInt() < 1 tbTextColor[2].SetText("0")
			If tbTextColor[2].GetText().ToInt() > 255 tbTextColor[2].SetText("255")
			PropGadget.Gadget.SetTextColor(tbTextColor[0].GetText().ToInt(), tbTextColor[1].GetText().ToInt(), tbTextColor[2].GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbTextColor[2].SetText(tbTextColor[2].GetText())
				p.PropGadget.Gadget.SetTextColor(p.tbTextColor[0].GetText().ToInt(), p.tbTextColor[1].GetText().ToInt(), p.tbTextColor[2].GetText().ToInt())
			Next
		ElseIf gadget = tbGadgetColor[0] And id = ifsoGUI_EVENT_CHANGE
			If tbGadgetColor[0].GetText().ToInt() < 1 tbGadgetColor[0].SetText("0")
			If tbGadgetColor[0].GetText().ToInt() > 255 tbGadgetColor[0].SetText("255")
			PropGadget.Gadget.SetGadgetColor(tbGadgetColor[0].GetText().ToInt(), tbGadgetColor[1].GetText().ToInt(), tbGadgetColor[2].GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbGadgetColor[0].SetText(tbGadgetColor[0].GetText())
				p.PropGadget.Gadget.SetGadgetColor(p.tbGadgetColor[0].GetText().ToInt(), p.tbGadgetColor[1].GetText().ToInt(), p.tbGadgetColor[2].GetText().ToInt())
			Next
		ElseIf gadget = tbGadgetColor[1] And id = ifsoGUI_EVENT_CHANGE
			If tbGadgetColor[1].GetText().ToInt() < 1 tbGadgetColor[1].SetText("0")
			If tbGadgetColor[1].GetText().ToInt() > 255 tbGadgetColor[1].SetText("255")
			PropGadget.Gadget.SetGadgetColor(tbGadgetColor[0].GetText().ToInt(), tbGadgetColor[1].GetText().ToInt(), tbGadgetColor[2].GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbGadgetColor[1].SetText(tbGadgetColor[1].GetText())
				p.PropGadget.Gadget.SetGadgetColor(p.tbGadgetColor[0].GetText().ToInt(), p.tbGadgetColor[1].GetText().ToInt(), p.tbGadgetColor[2].GetText().ToInt())
			Next
		ElseIf gadget = tbGadgetColor[2] And id = ifsoGUI_EVENT_CHANGE
			If tbGadgetColor[2].GetText().ToInt() < 1 tbGadgetColor[2].SetText("0")
			If tbGadgetColor[2].GetText().ToInt() > 255 tbGadgetColor[2].SetText("255")
			PropGadget.Gadget.SetGadgetColor(tbGadgetColor[0].GetText().ToInt(), tbGadgetColor[1].GetText().ToInt(), tbGadgetColor[2].GetText().ToInt())
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbGadgetColor[2].SetText(tbGadgetColor[2].GetText())
				p.PropGadget.Gadget.SetGadgetColor(p.tbGadgetColor[0].GetText().ToInt(), p.tbGadgetColor[1].GetText().ToInt(), p.tbGadgetColor[2].GetText().ToInt())
			Next
		ElseIf gadget = tbAlpha And id = ifsoGUI_EVENT_CHANGE
			iAlpha = Int(tbAlpha.GetText().ToFloat() * 100.0)
			If iAlpha > 100 iAlpha = 100
			If iAlpha < 0 iAlpha = 0
			If iAlpha = 100
				tbAlpha.SetText("1.00")
			ElseIf iAlpha < 10
				tbAlpha.SetText(".0" + String(iAlpha))
			Else
				tbAlpha.SetText("." + String(iAlpha))
			End If
			Propgadget.Gadget.SetGadgetAlpha(Float(iAlpha) *.01)
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbAlpha.SetText(tbAlpha.GetText())
				p.Propgadget.Gadget.SetGadgetAlpha(Float(iAlpha) *.01)
			Next
		ElseIf gadget.Name = "spinAlpha" And id = ifsoGUI_EVENT_CLICK
			iAlpha:+data
			If iAlpha > 100 iAlpha = 100
			If iAlpha < 0 iAlpha = 0
			If iAlpha = 100
				tbAlpha.SetText("1.00")
			ElseIf iAlpha < 10
				tbAlpha.SetText(".0" + String(iAlpha))
			Else
				tbAlpha.SetText("." + String(iAlpha))
			End If
			Propgadget.Gadget.SetGadgetAlpha(Float(iAlpha) *.01)
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbAlpha.SetText(tbAlpha.GetText())
				p.PropGadget.Gadget.SetGadgetAlpha(Float(iAlpha) *.01)
			Next
		ElseIf gadget = chkOnTop And id = ifsoGUI_EVENT_CHANGE
			PropGadget.OnTop = data
			Propgadget.BringToFront()
			For Local p:TGadgetProps = EachIn SelectedProps
				p.chkOnTop.SetValue(data)
				p.PropGadget.OnTop = data
				p.PropGadget.BringToFront()
			Next
		ElseIf gadget = tbFocusColor[0] And id = ifsoGUI_EVENT_CHANGE
			If tbFocusColor[0].GetText().ToInt() < 1 tbFocusColor[0].SetText("0")
			If tbFocusColor[0].GetText().ToInt() > 255 tbFocusColor[0].SetText("255")
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbFocusColor[0].SetText(tbFocusColor[0].GetText())
			Next
		ElseIf gadget = tbFocusColor[1] And id = ifsoGUI_EVENT_CHANGE
			If tbFocusColor[1].GetText().ToInt() < 1 tbFocusColor[1].SetText("0")
			If tbFocusColor[1].GetText().ToInt() > 255 tbFocusColor[1].SetText("255")
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbFocusColor[1].SetText(tbFocusColor[1].GetText())
			Next
		ElseIf gadget = tbFocusColor[2] And id = ifsoGUI_EVENT_CHANGE
			If tbFocusColor[2].GetText().ToInt() < 1 tbFocusColor[2].SetText("0")
			If tbFocusColor[2].GetText().ToInt() > 255 tbFocusColor[2].SetText("255")
			For Local p:TGadgetProps = EachIn SelectedProps
				p.tbFocusColor[2].SetText(tbFocusColor[2].GetText())
			Next
		ElseIf gadget = chkAutoSize And id = ifsoGUI_EVENT_CLICK
			PropGadget.Gadget.SetAutoSize(data)
			PropGadget.SetXY(PropGadget.Gadget.x, PropGadget.Gadget.y)
			PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
			For Local p:TGadgetProps = EachIn SelectedProps
				p.chkAutoSize.SetValue(data)
				p.PropGadget.Gadget.SetAutoSize(data)
				p.PropGadget.SetXY(p.PropGadget.Gadget.x, p.PropGadget.Gadget.y)
				p.PropGadget.SetWH(p.PropGadget.Gadget.w, p.PropGadget.Gadget.h)
			Next
		ElseIf Gadget.Name = "cbScrollbars" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_Panel(PropGadget.Gadget) ifsoGUI_Panel(PropGadget.Gadget).SetScrollbars(ifsoGUI_Combobox(Gadget).GetSelectedData())
		ElseIf Gadget.Name = "cbVScrollbar" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_ListBox(PropGadget.Gadget) ifsoGUI_ListBox(PropGadget.Gadget).SetVScrollbar(ifsoGUI_Combobox(Gadget).GetSelectedData())
			If ifsoGUI_MCListBox(PropGadget.Gadget) ifsoGUI_MCListBox(PropGadget.Gadget).SetVScrollbar(ifsoGUI_Combobox(Gadget).GetSelectedData())
			If ifsoGUI_MLTextBox(PropGadget.Gadget) ifsoGUI_MLTextBox(PropGadget.Gadget).SetVScrollbar(ifsoGUI_Combobox(Gadget).GetSelectedData())
		ElseIf Gadget.Name = "cbHScrollbar" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_ListBox(PropGadget.Gadget) ifsoGUI_ListBox(PropGadget.Gadget).SetHScrollbar(ifsoGUI_Combobox(Gadget).GetSelectedData())
			If ifsoGUI_MCListBox(PropGadget.Gadget) ifsoGUI_MCListBox(PropGadget.Gadget).SetHScrollbar(ifsoGUI_Combobox(Gadget).GetSelectedData())
			If ifsoGUI_MLTextBox(PropGadget.Gadget) ifsoGUI_MLTextBox(PropGadget.Gadget).SetHScrollbar(ifsoGUI_Combobox(Gadget).GetSelectedData())
		ElseIf Gadget.Name = "spnScrollWidth" And id = ifsoGUI_EVENT_CLICK
			If ifsoGUI_Panel(PropGadget.Gadget)
				Local g:ifsoGUI_Base = Gadget.Parent.GetChild("tbScrollWidth")
				If data < 0 And Int(ifsoGUI_TextBox(g).GetText()) < 4 Return
				ifsoGUI_Panel(PropGadget.Gadget).SetScrollBarWidth(ifsoGUI_Panel(PropGadget.Gadget).ScrollBarWidth + data)
				PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
				tbW.SetText(PropGadget.w)
				tbH.SetText(PropGadget.h)
				ifsoGUI_TextBox(g).SetText(ifsoGUI_Panel(PropGadget.Gadget).ScrollBarWidth)
			ElseIf ifsoGUI_ListBox(PropGadget.Gadget)
				Local g:ifsoGUI_Base = Gadget.Parent.GetChild("tbScrollWidth")
				If data < 0 And Int(ifsoGUI_TextBox(g).GetText()) < 4 Return
				ifsoGUI_ListBox(PropGadget.Gadget).SetScrollBarWidth(ifsoGUI_ListBox(PropGadget.Gadget).ScrollBarWidth + data)
				PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
				tbW.SetText(PropGadget.w)
				tbH.SetText(PropGadget.h)
				ifsoGUI_TextBox(g).SetText(ifsoGUI_ListBox(PropGadget.Gadget).ScrollBarWidth)
			ElseIf ifsoGUI_MCListBox(PropGadget.Gadget)
				Local g:ifsoGUI_Base = Gadget.Parent.GetChild("tbScrollWidth")
				If data < 0 And Int(ifsoGUI_TextBox(g).GetText()) < 4 Return
				ifsoGUI_MCListBox(PropGadget.Gadget).SetScrollBarWidth(ifsoGUI_MCListBox(PropGadget.Gadget).ScrollBarWidth + data)
				PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
				tbW.SetText(PropGadget.w)
				tbH.SetText(PropGadget.h)
				ifsoGUI_TextBox(g).SetText(ifsoGUI_MCListBox(PropGadget.Gadget).ScrollBarWidth)
			ElseIf ifsoGUI_MLTextBox(PropGadget.Gadget)
				Local g:ifsoGUI_Base = Gadget.Parent.GetChild("tbScrollWidth")
				If data < 0 And Int(ifsoGUI_TextBox(g).GetText()) < 4 Return
				ifsoGUI_MLTextBox(PropGadget.Gadget).SetScrollBarWidth(ifsoGUI_MLTextBox(PropGadget.Gadget).ScrollBarWidth + data)
				PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
				tbW.SetText(PropGadget.w)
				tbH.SetText(PropGadget.h)
				ifsoGUI_TextBox(g).SetText(ifsoGUI_MLTextBox(PropGadget.Gadget).ScrollBarWidth)
			End If
		ElseIf Gadget.Name = "tbScrollWidth" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_Panel(PropGadget.Gadget)
				If Int(ifsoGUI_TextBox(Gadget).GetText()) < 3 ifsoGUI_TextBox(Gadget).SetText("3")
				ifsoGUI_Panel(PropGadget.Gadget).SetScrollBarWidth(Int(ifsoGUI_TextBox(Gadget).GetText()))
				PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
				tbW.SetText(PropGadget.w)
				tbH.SetText(PropGadget.h)
			ElseIf ifsoGUI_ListBox(PropGadget.Gadget)
				If Int(ifsoGUI_TextBox(Gadget).GetText()) < 3 ifsoGUI_TextBox(Gadget).SetText("3")
				ifsoGUI_ListBox(PropGadget.Gadget).SetScrollBarWidth(Int(ifsoGUI_TextBox(Gadget).GetText()))
				PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
				tbW.SetText(PropGadget.w)
				tbH.SetText(PropGadget.h)
			ElseIf ifsoGUI_MCListBox(PropGadget.Gadget)
				If Int(ifsoGUI_TextBox(Gadget).GetText()) < 3 ifsoGUI_TextBox(Gadget).SetText("3")
				ifsoGUI_MCListBox(PropGadget.Gadget).SetScrollBarWidth(Int(ifsoGUI_TextBox(Gadget).GetText()))
				PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
				tbW.SetText(PropGadget.w)
				tbH.SetText(PropGadget.h)
			ElseIf ifsoGUI_MLTextBox(PropGadget.Gadget)
				If Int(ifsoGUI_TextBox(Gadget).GetText()) < 3 ifsoGUI_TextBox(Gadget).SetText("3")
				ifsoGUI_MLTextBox(PropGadget.Gadget).SetScrollBarWidth(Int(ifsoGUI_TextBox(Gadget).GetText()))
				PropGadget.SetWH(PropGadget.Gadget.w, PropGadget.Gadget.h)
				tbW.SetText(PropGadget.w)
				tbH.SetText(PropGadget.h)
			End If
		ElseIf Gadget.Name = "chkChecked" And id = ifsoGUI_EVENT_CHANGE
			ifsoGUI_CheckBox(PropGadget.Gadget).SetValue(data)
		ElseIf Gadget.Name = "chkShowLabel" And id = ifsoGUI_EVENT_CHANGE
			ifsoGUI_ImageButton(PropGadget.Gadget).SetShowLabel(data)
		ElseIf Gadget.Name = "tbNormalImage" And id = ifsoGUI_EVENT_CHANGE
			Local oimg:String, dimg:String
			oimg = ifsoGUI_TextBox(Gadget.Parent.GetChild("tbOverImage")).GetText()
			dimg = ifsoGUI_TextBox(Gadget.Parent.GetChild("tbDownImage")).GetText()
			ifsoGUI_ImageButton(PropGadget.Gadget).SetImages(LoadImage(ifsoGUI_TextBox(Gadget).GetText()), LoadImage(oimg), LoadImage(dimg))
		ElseIf Gadget.Name = "tbOverImage" And id = ifsoGUI_EVENT_CHANGE
			Local nimg:String, dimg:String
			nimg = ifsoGUI_TextBox(Gadget.Parent.GetChild("tbNormalImage")).GetText()
			dimg = ifsoGUI_TextBox(Gadget.Parent.GetChild("tbDownImage")).GetText()
			ifsoGUI_ImageButton(PropGadget.Gadget).SetImages(LoadImage(nimg), LoadImage(ifsoGUI_TextBox(Gadget).GetText()), LoadImage(dimg))
		ElseIf Gadget.Name = "tbDownImage" And id = ifsoGUI_EVENT_CHANGE
			Local nimg:String, oimg:String
			nimg = ifsoGUI_TextBox(Gadget.Parent.GetChild("tbNormalImage")).GetText()
			oimg = ifsoGUI_TextBox(Gadget.Parent.GetChild("tbOverImage")).GetText()
			ifsoGUI_ImageButton(PropGadget.Gadget).SetImages(LoadImage(nimg), LoadImage(oimg), LoadImage(ifsoGUI_TextBox(Gadget).GetText()))
		ElseIf Gadget.Name = "chkWordWrap" And id = ifsoGUI_EVENT_CHANGE
			ifsoGUI_MLTextBox(PropGadget.Gadget).SetWordWrap(data)
		ElseIf Gadget.Name = "tbMin" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_ProgressBar(PropGadget.Gadget) ifsoGUI_ProgressBar(PropGadget.Gadget).SetMin(Int(ifsoGUI_TextBox(Gadget).GetText()))
			If ifsoGUI_ScrollBar(PropGadget.Gadget) ifsoGUI_ScrollBar(PropGadget.Gadget).SetMin(Int(ifsoGUI_TextBox(Gadget).GetText()))
			If ifsoGUI_Slider(PropGadget.Gadget) ifsoGUI_Slider(PropGadget.Gadget).SetMin(Int(ifsoGUI_TextBox(Gadget).GetText()))
		ElseIf Gadget.Name = "tbMax" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_ProgressBar(PropGadget.Gadget) ifsoGUI_ProgressBar(PropGadget.Gadget).SetMax(Int(ifsoGUI_TextBox(Gadget).GetText()))
			If ifsoGUI_ScrollBar(PropGadget.Gadget) ifsoGUI_ScrollBar(PropGadget.Gadget).SetMax(Int(ifsoGUI_TextBox(Gadget).GetText()))
			If ifsoGUI_Slider(PropGadget.Gadget) ifsoGUI_Slider(PropGadget.Gadget).SetMax(Int(ifsoGUI_TextBox(Gadget).GetText()))
		ElseIf Gadget.Name = "tbInterval" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_ScrollBar(PropGadget.Gadget) ifsoGUI_ScrollBar(PropGadget.Gadget).SetInterval(Int(ifsoGUI_TextBox(Gadget).GetText()))
			If ifsoGUI_Slider(PropGadget.Gadget) ifsoGUI_Slider(PropGadget.Gadget).SetInterval(Int(ifsoGUI_TextBox(Gadget).GetText()))
		ElseIf Gadget.Name = "tbBarInterval" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_ScrollBar(PropGadget.Gadget) ifsoGUI_ScrollBar(PropGadget.Gadget).SetBarInterval(Int(ifsoGUI_TextBox(Gadget).GetText()))
		ElseIf Gadget.Name = "chkShowTicks" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_Slider(PropGadget.Gadget) ifsoGUI_Slider(PropGadget.Gadget).SetShowTicks(data)
		ElseIf Gadget.Name = "chkDirection" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_Slider(PropGadget.Gadget) ifsoGUI_Slider(PropGadget.Gadget).SetDirection(data)
		ElseIf Gadget.Name = "cbCurrent" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_Tabber(PropGadget.Gadget)
				ifsoGUI_Tabber(PropGadget.Gadget).SetCurrentTab(Data)
				ifsoGUI_TextBox(Gadget.Parent.GetChild("tbTabText")).SetText(ifsoGUI_Combobox(Gadget).GetSelectedName())
			End If
		ElseIf Gadget.Name = "tbTabText" And id = ifsoGUI_EVENT_CHANGE
			If ifsoGUI_Tabber(PropGadget.Gadget)
				ifsoGUI_Tabber(PropGadget.Gadget).SetTabText(ifsoGUI_Combobox(Gadget.Parent.GetChild("cbCurrent")).GetSelected(), ifsoGUI_TextBox(Gadget).GetText())
				ifsoGUI_Combobox(Gadget.Parent.GetChild("cbCurrent")).dropList.SetItemName(ifsoGUI_Combobox(Gadget.Parent.GetChild("cbCurrent")).GetSelected(), ifsoGUI_TextBox(Gadget).GetText())
			End If
		ElseIf Gadget.Name = "btnAddTab" And id = ifsoGUI_EVENT_CLICK
			If ifsoGUI_Tabber(PropGadget.Gadget)
				ifsoGUI_Tabber(PropGadget.Gadget).AddTab("New Tab")
				ifsoGUI_Combobox(Gadget.Parent.GetChild("cbCurrent")).AddItem("New Tab")
			End If
		ElseIf Gadget.Name = "btnRemoveTab" And id = ifsoGUI_EVENT_CLICK
			If ifsoGUI_Tabber(PropGadget.Gadget)
				Local iSelected:Int = ifsoGUI_Combobox(Gadget.Parent.GetChild("cbCurrent")).GetSelected()
				ifsoGUI_Tabber(PropGadget.Gadget).RemoveTab(iSelected)
				ifsoGUI_Combobox(Gadget.Parent.GetChild("cbCurrent")).RemoveItem(iSelected)
				ifsoGUI_Combobox(Gadget.Parent.GetChild("cbCurrent")).SetSelected(ifsoGUI_Tabber(PropGadget.Gadget).GetCurrentTab())
				ifsoGUI_TextBox(Gadget.Parent.GetChild("tbTabText")).SetText(ifsoGUI_Combobox(Gadget.Parent.GetChild("cbCurrent")).GetSelectedName())
			End If
		End If

	End Method
	
End Type

Type TPropGadget Extends ifsoGUI_Base
	Global MouseBorderCheck:Int = 5
	
	Field Gadget:ifsoGUI_Base
	Field Dragging:Int, Resizing:Int, ResizeSpot:Int
	Field MousePosX:Int, MousePosY:Int
	Field Props:TGadgetProps
	Field GadgetType:Int
	Field parent_type:Int 'v1.18
	Field tab_order:Int = -1
	
	Function Create:TPropGadget(iType:Int)
		Local g:TPropGadget = New TPropGadget, sName:String
		g.GadgetType = iType
		g.x = 10
		g.y = 10
		If ifsoGUI_Window(ActiveProps.selected_gadget.Gadget)<>Null 'v1.18
			g.parent_type = 2
		ElseIf ifsoGUI_Tabber(ActiveProps.selected_gadget.Gadget)<>Null 'tab selected
			g.parent_type = 19
			g.tab_order = ifsoGUI_Tabber(ActiveProps.selected_gadget.Gadget).GetCurrentTab()
		EndIf
		Select iType
			Case PROP_BUTTON
				g.w = 100
				g.h = 24
				sName = GetNextName("btnButton")
				g.Gadget = ifsoGUI_Button.Create(g.x, g.y, g.w, g.h, sName, sName)
			Case PROP_PANEL ' Panel
				g.w = 200
				g.h = 200
				sName = GetNextName("pnlPanel")
				g.Gadget = ifsoGUI_Panel.Create(g.x, g.y, g.w, g.h, sName)
			Case PROP_WINDOW ' Panel
				g.w = 200
				g.h = 200
				sName = GetNextName("wndWindow")
				g.Gadget = ifsoGUI_Window.Create(g.x, g.y, g.w, g.h, sName)
				ifsoGUI_Window(g.Gadget).SetCaption(sName)
			Case PROP_LABEL
				g.w = 100
				g.h = 24
				sName = GetNextName("lblLabel")
				g.Gadget = ifsoGUI_Label.Create(g.x, g.y, g.w, g.h, sName, sName)
			Case PROP_CHECKBOX
				g.w = 120
				g.h = 24
				sName = GetNextName("chkCheckbox")
				g.Gadget = ifsoGUI_CheckBox.Create(g.x, g.y, g.w, g.h, sName, sName)
			Case PROP_COMBOBOX
				g.w = 120
				g.h = 24
				sName = GetNextName("cmbCombobox")
				g.Gadget = ifsoGUI_Combobox.Create(g.x, g.y, g.w, g.h, sName)
			Case PROP_IMAGEBUTTON
				g.w = 50
				g.h = 50
				sName = GetNextName("imbImageButton")
				g.Gadget = ifsoGUI_ImageButton.Create(g.x, g.y, g.w, g.h, sName, sName)
				ifsoGUI_ImageButton(g.Gadget).SetShowButton(True)
			Case PROP_LISTBOX
				g.w = 120
				g.h = 300
				sName = GetNextName("lstListbox")
				g.Gadget = ifsoGUI_ListBox.Create(g.x, g.y, g.w, g.h, sName)
			Case PROP_MCLISTBOX
				g.w = 120
				g.h = 300
				sName = GetNextName("mclMCListbox")
				g.Gadget = ifsoGUI_MCListBox.Create(g.x, g.y, g.w, g.h, sName)
			Case PROP_MLTEXTBOX
				g.w = 200
				g.h = 200
				sName = GetNextName("mltMLTextbox")
				g.Gadget = ifsoGUI_MLTextBox.Create(g.x, g.y, g.w, g.h, sName)
				ifsoGUI_MLTextBox(g.Gadget).SetValue(sName)
			Case PROP_PROGRESSBAR_HORZ
				g.w = 200
				g.h = 20
				sName = GetNextName("prgProgressbar")
				g.Gadget = ifsoGUI_ProgressBar.Create(g.x, g.y, g.w, g.h, sName)
			Case PROP_PROGRESSBAR_VERT
				g.w = 20
				g.h = 200
				sName = GetNextName("prgProgressbar")
				g.Gadget = ifsoGUI_ProgressBar.Create(g.x, g.y, g.w, g.h, sName, False)
			Case PROP_SCROLLBAR_HORZ
				g.w = 200
				g.h = 20
				sName = GetNextName("scrScrollbar")
				g.Gadget = ifsoGUI_ScrollBar.Create(g.x, g.y, g.w, g.h, sName, False)
			Case PROP_SCROLLBAR_VERT
				g.w = 20
				g.h = 200
				sName = GetNextName("scrScrollbar")
				g.Gadget = ifsoGUI_ScrollBar.Create(g.x, g.y, g.w, g.h, sName)
			Case PROP_SLIDER_HORZ
				sName = GetNextName("sldSlider")
				g.Gadget = ifsoGUI_Slider.Create(g.x, g.y, 200, sName)
				g.w = g.Gadget.w
				g.h = g.Gadget.h
			Case PROP_SLIDER_VERT
				sName = GetNextName("sldSlider")
				g.Gadget = ifsoGUI_Slider.Create(g.x, g.y, 200, sName, True)
				g.w = g.Gadget.h
				g.h = g.Gadget.w
			Case PROP_SPINNER_HORZ
				g.w = 24
				g.h = 12
				sName = GetNextName("spnSpinner")
				g.Gadget = ifsoGUI_Spinner.Create(g.x, g.y, g.w, g.h, sName, False)
			Case PROP_SPINNER_VERT
				g.w = 12
				g.h = 24
				sName = GetNextName("spnSpinner")
				g.Gadget = ifsoGUI_Spinner.Create(g.x, g.y, g.w, g.h, sName)
			Case PROP_TEXTBOX
				g.w = 100
				g.h = 24
				sName = GetNextName("txtTextbox")
				g.Gadget = ifsoGUI_TextBox.Create(g.x, g.y, g.w, g.h, sName, sName)
			Case PROP_TABBER ' Panel
				g.w = 200
				g.h = 200
				sName = GetNextName("tabTabber")
				g.Gadget = ifsoGUI_Tabber.Create(g.x, g.y, g.w, g.h, sName, 1)
				ifsoGUI_Tabber(g.Gadget).SetTabText(0, "Tab 1")
		End Select
		g.Name = sName
		g.Gadget.SetCallBack(EventCallback)
		g.Gadget.SetEnabled(False)
		Return g
	End Function
	Function GetNextName:String(strName:String)
		Local sName:String
		Local counter:Int = 1, bFlag:Int
		Repeat
			sName = strName + String(counter)
			For Local p:TProps = EachIn TProps.AllProps
				If p.PropGadget.Name.ToUpper() = sName.ToUpper()
					bFlag = True
					Exit
				End If
			Next
			If Not bFlag Return sName
			bFlag = False
			counter:+1
		Forever
	End Function
	Method WriteCode()
		Local strOut:String = ""
		Local nl$="~r~n" 'v1.18
		Local nllocal$ = nl + "Local "
		If ifsoGUI_ImageButton(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_ImageButton = ifsoGUI_ImageButton.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, ~q" + ifsoGUI_ImageButton(Gadget).Label + "~q)" + nl
			Local nimg:String, oimg:String, dimg:String
			nimg = ifsoGUI_TextBox(Props.pnlProps.GetChild("tbNormalImage")).GetText()
			oimg = ifsoGUI_TextBox(Props.pnlProps.GetChild("tbOverImage")).GetText()
			dimg = ifsoGUI_TextBox(Props.pnlProps.GetChild("tbDownImage")).GetText()
			strOut:+Name + ".SetImages(LoadImage(~q" + nimg + "~q), LoadImage(~q" + oimg + "~q), LoadImage(~q" + dimg + "~q))" + nl
		ElseIf ifsoGUI_Button(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_Button = ifsoGUI_Button.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, ~q" + ifsoGUI_Button(Gadget).Label + "~q)" + nl
		ElseIf ifsoGUI_Label(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_Label = ifsoGUI_Label.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, ~q" + ifsoGUI_Label(Gadget).Label + "~q)" + nl
		ElseIf ifsoGUI_CheckBox(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_CheckBox = ifsoGUI_CheckBox.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, ~q" + ifsoGUI_CheckBox(Gadget).Label + "~q)" + nl
			If ifsoGUI_CheckBox(Gadget).bChecked strOut:+Name + "SetValue(True)" + nl
		ElseIf ifsoGUI_Combobox(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_ComboBox = ifsoGUI_ComboBox.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
		ElseIf ifsoGUI_Window(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_Window = ifsoGUI_Window.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
			strOut:+Name + ".SetCaption(~q" + ifsoGUI_Window(Gadget).GetCaption() + "~q)" + nl
			If ifsoGUI_Panel(Gadget).GetScrollbars() = 0
				strOut:+Name + ".SetScrollbars(ifsoGUI_SCROLLBARS_OFF)" + nl
			ElseIf ifsoGUI_Panel(Gadget).GetScrollbars() = 1
				strOut:+Name + ".SetScrollbars(ifsoGUI_SCROLLBARS_ON)" + nl
			End If
			If ifsoGUI_Window(Gadget).ScrollBarWidth <> 20 strOut:+Name + ".SetScrollBarWidth(" + ifsoGUI_Window(Gadget).ScrollBarWidth + ")" + nl
		ElseIf ifsoGUI_Panel(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_Panel = ifsoGUI_Panel.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
			If ifsoGUI_Panel(Gadget).GetScrollbars() = 0
				strOut:+Name + ".SetScrollbars(ifsoGUI_SCROLLBARS_OFF)" + nl
			ElseIf ifsoGUI_Panel(Gadget).GetScrollbars() = 1
				strOut:+Name + ".SetScrollbars(ifsoGUI_SCROLLBARS_ON)" + nl
			End If
			If ifsoGUI_Panel(Gadget).ScrollBarWidth <> 20 strOut:+Name + ".SetScrollBarWidth(" + ifsoGUI_Panel(Gadget).ScrollBarWidth + ")" + nl
		ElseIf ifsoGUI_ListBox(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_Listbox = ifsoGUI_Listbox.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
			If ifsoGUI_ListBox(Gadget).GetVScrollbar() = 0
				strOut:+Name + ".SetVScrollbar(ifsoGUI_SCROLLBARS_OFF)" + nl
			ElseIf ifsoGUI_ListBox(Gadget).GetVScrollbar() = 1
				strOut:+Name + ".SetVScrollbar(ifsoGUI_SCROLLBARS_ON)" + nl
			End If
			If ifsoGUI_ListBox(Gadget).GetHScrollbar() = 2
				strOut:+Name + ".SetHScrollbar(ifsoGUI_SCROLLBARS_AUTO)" + nl
			ElseIf ifsoGUI_ListBox(Gadget).GetHScrollbar() = 1
				strOut:+Name + ".SetHScrollbar(ifsoGUI_SCROLLBARS_ON)" + nl
			End If
			If ifsoGUI_ListBox(Gadget).ScrollBarWidth <> 20 strOut:+Name + ".SetScrollBarWidth(" + ifsoGUI_ListBox(Gadget).ScrollBarWidth + ")" + nl
		ElseIf ifsoGUI_MCListBox(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_MCListbox = ifsoGUI_MCListbox.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
			If ifsoGUI_MCListBox(Gadget).GetVScrollbar() = 0
				strOut:+Name + ".SetVScrollbar(ifsoGUI_SCROLLBARS_OFF)" + nl
			ElseIf ifsoGUI_MCListBox(Gadget).GetVScrollbar() = 1
				strOut:+Name + ".SetVScrollbar(ifsoGUI_SCROLLBARS_ON)" + nl
			End If
			If ifsoGUI_MCListBox(Gadget).GetHScrollbar() = 0
				strOut:+Name + ".SetHScrollbar(ifsoGUI_SCROLLBARS_OFF)" + nl
			ElseIf ifsoGUI_MCListBox(Gadget).GetHScrollbar() = 1
				strOut:+Name + ".SetHScrollbar(ifsoGUI_SCROLLBARS_ON)" + nl
			End If
			If ifsoGUI_MCListBox(Gadget).ScrollBarWidth <> 20 strOut:+Name + ".SetScrollBarWidth(" + ifsoGUI_MCListBox(Gadget).ScrollBarWidth + ")" + nl
		ElseIf ifsoGUI_MLTextBox(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_MLTextbox = ifsoGUI_MLTextbox.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
			If ifsoGUI_MLTextBox(Gadget).GetVScrollbar() = 0
				strOut:+Name + ".SetVScrollbar(ifsoGUI_SCROLLBARS_OFF)" + nl
			ElseIf ifsoGUI_MLTextBox(Gadget).GetVScrollbar() = 1
				strOut:+Name + ".SetVScrollbar(ifsoGUI_SCROLLBARS_ON)" + nl
			End If
			If ifsoGUI_MLTextBox(Gadget).GetHScrollbar() = 0
				strOut:+Name + ".SetHScrollbar(ifsoGUI_SCROLLBARS_OFF)" + nl
			ElseIf ifsoGUI_MLTextBox(Gadget).GetHScrollbar() = 1
				strOut:+Name + ".SetHScrollbar(ifsoGUI_SCROLLBARS_ON)" + nl
			End If
			If ifsoGUI_MLTextBox(Gadget).ScrollBarWidth <> 20 strOut:+Name + ".SetScrollBarWidth(" + ifsoGUI_MLTextBox(Gadget).ScrollBarWidth + ")" + nl
			If Not ifsoGUI_MLTextBox(Gadget).WordWrap strOut:+Name + ".SetWordWrap(False)" + nl
		ElseIf ifsoGUI_ProgressBar(Gadget)
			If ifsoGUI_ProgressBar(Gadget).Horizontal
				strOut = nllocal + Name + ":ifsoGUI_Progressbar = ifsoGUI_Progressbar.Create("
				strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
			Else
				strOut = nllocal + Name + ":ifsoGUI_Progressbar = ifsoGUI_Progressbar.Create("
				strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, False)" + nl
			EndIf
			If ifsoGUI_ProgressBar(Gadget).iMin <> 0 Or ifsoGUI_ProgressBar(Gadget).iMax <> 100 strOut:+Name + ".SetMinMax(" + ifsoGUI_ProgressBar(Gadget).iMin + ", " + ifsoGUI_ProgressBar(Gadget).iMax + ")" + nl
			If ifsoGUI_ProgressBar(Gadget).Value <> 0 strOut:+Name + ".SetValue(" + ifsoGUI_ProgressBar(Gadget).Value + ")" + nl
		ElseIf ifsoGUI_ScrollBar(Gadget)
			If ifsoGUI_ScrollBar(Gadget).Vertical
				strOut = nllocal + Name + ":ifsoGUI_Scrollbar = ifsoGUI_Scrollbar.Create("
				strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, False)" + nl
			Else
				strOut = nllocal + Name + ":ifsoGUI_Scrollbar = ifsoGUI_Scrollbar.Create("
				strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
			EndIf
			If ifsoGUI_ScrollBar(Gadget).MinVal <> 0 Or ifsoGUI_ScrollBar(Gadget).MaxVal <> 100 strOut:+Name + ".SetMinMax(" + ifsoGUI_ScrollBar(Gadget).MinVal + ", " + ifsoGUI_ScrollBar(Gadget).MaxVal + ")" + nl
			If ifsoGUI_ScrollBar(Gadget).Value <> 0 strOut:+Name + ".SetValue(" + ifsoGUI_ScrollBar(Gadget).Value + ")" + nl
			If ifsoGUI_ScrollBar(Gadget).Interval <> 1 strOut:+Name + ".SetInterval(" + ifsoGUI_ScrollBar(Gadget).Interval + ")" + nl
			If ifsoGUI_ScrollBar(Gadget).Size <> 10 strOut:+Name + ".SetBarInterval(" + ifsoGUI_ScrollBar(Gadget).Size + ")" + nl
		ElseIf ifsoGUI_Slider(Gadget)
			If ifsoGUI_Slider(Gadget).Vertical
				strOut = nllocal + Name + ":ifsoGUI_Slider = ifsoGUI_Slider.Create("
				strOut:+x + ", " + y + ", " + h + ", ~q" + Name + "~q, True)" + nl
			Else
				strOut = nllocal + Name + ":ifsoGUI_Slider = ifsoGUI_Slider.Create("
				strOut:+x + ", " + y + ", " + w + ", ~q" + Name + "~q)" + nl
			EndIf
			If ifsoGUI_Slider(Gadget).MinVal <> 0 Or ifsoGUI_Slider(Gadget).MaxVal <> 10 strOut:+Name + ".SetMinMax(" + ifsoGUI_Slider(Gadget).MinVal + ", " + ifsoGUI_Slider(Gadget).MaxVal + ")" + nl
			If ifsoGUI_Slider(Gadget).Value <> 0 strOut:+Name + ".SetValue(" + ifsoGUI_Slider(Gadget).Value + ")" + nl
			If ifsoGUI_Slider(Gadget).Interval <> 1 strOut:+Name + ".SetInterval(" + ifsoGUI_Slider(Gadget).Interval + ")" + nl
			If ifsoGUI_Slider(Gadget).Direction <> 0 strOut:+Name + ".SetDirection(ifsoGUI_SLIDER_DOWN_LEFT)" + nl
			If Not ifsoGUI_Slider(Gadget).ShowTicks strOut:+Name + ".SetShowTicks(False)" + nl
		ElseIf ifsoGUI_Spinner(Gadget)
			If ifsoGUI_Spinner(Gadget).Vertical
				strOut = nllocal + Name + ":ifsoGUI_Spinner = ifsoGUI_Spinner.Create("
				strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q)" + nl
			Else
				strOut = nllocal + Name + ":ifsoGUI_Spinner = ifsoGUI_Spinner.Create("
				strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, False)" + nl
			EndIf
		ElseIf ifsoGUI_TextBox(Gadget)
			strOut = nllocal + Name + ":ifsoGUI_Textbox = ifsoGUI_Textbox.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, ~q" + ifsoGUI_TextBox(Gadget).Value + "~q)" + nl
		ElseIf ifsoGUI_Tabber(Gadget) 'v1.18
			strOut = nllocal + Name + ":ifsoGUI_Tabber = ifsoGUI_Tabber.Create("
			strOut:+x + ", " + y + ", " + w + ", " + h + ", ~q" + Name + "~q, " + ifsoGUI_Tabber(Gadget).GetNumTabs() + ")" + nl
			For Local tbi%=0 To ifsoGUI_Tabber(Gadget).GetNumTabs()-1
				strOut:+ Name + ".SetTabText(" + tbi + ", ~q" + ifsoGUI_Tabber(Gadget).GetTabText(tbi) + "~q)" + nl
			Next
		End If
		If Props.tbSkin.GetText() <> "" strOut:+Name + ".LoadSkin(~q" + Props.tbSkin.GetText() + "~q)" + nl
		If Gadget.TextColor[0] <> 0 Or Gadget.TextColor[1] <> 0 Or Gadget.TextColor[2] <> 0 ..
			strOut:+Name + ".SetTextColor(" + Gadget.TextColor[0] + ", " + Gadget.TextColor[1] + ", " + Gadget.TextColor[2] + ")" + nl
		If Gadget.Color[0] <> 255 Or Gadget.Color[1] <> 255 Or Gadget.Color[2] <> 255 ..
			strOut:+Name + ".SetGadgetColor(" + Gadget.Color[0] + ", " + Gadget.Color[1] + ", " + Gadget.Color[2] + ")" + nl
		If Props.iAlpha < 100 strOut:+Name + ".SetAlpha(" + Props.tbAlpha.GetText() + ")" + nl
		If Props.tbTip.GetText() <> "" strOut:+Name + ".SetTip(~q" + Props.tbTip.GetText() + "~q)" + nl
		If Props.chkOnTop.GetValue() strOut:+Name + ".SetAlwaysOnTop(True)" + nl
		If Props.chkAutoSize.GetValue() strOut:+Name + ".SetAutoSize(True)" + nl
		If Not Props.chkShowFocus.GetValue() strOut:+Name + ".SetShowFocus(False)" + nl
		If Gadget.FocusColor[0] <> 170 Or Gadget.FocusColor[1] <> 170 Or Gadget.FocusColor[2] <> 170 ..
			strOut:+Name + ".SetFocusColor(" + Gadget.FocusColor[0] + ", " + Gadget.FocusColor[1] + ", " + Gadget.FocusColor[2] + ")" + nl
		ClientArea.mtbCode.AddText(strOut)
		If Parent = ClientArea.Screen
			ClientArea.mtbCode.AddText("GUI.AddGadget(" + Name + ")" + nl)
		Else
			If parent_type = 19
				ClientArea.mtbCode.AddText(Parent.Name + ".AddTabChild(" + Name + ", " + tab_order + ")" + nl)
			ElseIf parent_type > 0
				ClientArea.mtbCode.AddText(Parent.Name + ".AddChild(" + Name + ")" + nl)
			EndIf
		End If
		For Local g:TPropGadget = EachIn Children
			g.WriteCode()
		Next
	End Method
	Method WriteSelf(file:TStream)
		Local strOut:String = "~n" + Name + "~n"
		strOut:+String(GadgetType) + "~n"
		strOut:+Parent.Name + "~n"
		strOut:+String(x) + "~n"
		strOut:+String(y) + "~n"
		strOut:+String(w) + "~n"
		strOut:+String(h) + "~n"
		If ifsoGUI_ImageButton(Gadget)
			strOut:+ifsoGUI_ImageButton(Gadget).Label + "~n"
			strOut:+ifsoGUI_TextBox(Props.pnlProps.GetChild("tbNormalImage")).GetText() + "~n"
			strOut:+ifsoGUI_TextBox(Props.pnlProps.GetChild("tbOverImage")).GetText() + "~n"
			strOut:+ifsoGUI_TextBox(Props.pnlProps.GetChild("tbDownImage")).GetText() + "~n"
		ElseIf ifsoGUI_Button(Gadget)
			strOut:+ifsoGUI_Button(Gadget).Label + "~n"
		ElseIf ifsoGUI_Label(Gadget)
			strOut:+ifsoGUI_Label(Gadget).Label + "~n"
		ElseIf ifsoGUI_CheckBox(Gadget)
			strOut:+ifsoGUI_CheckBox(Gadget).Label + "~n"
			strOut:+String(ifsoGUI_CheckBox(Gadget).bChecked) + "~n"
		ElseIf ifsoGUI_Window(Gadget)
			strOut:+ifsoGUI_Window(Gadget).GetCaption() + "~n"
			strOut:+String(ifsoGUI_Panel(Gadget).GetScrollbars()) + "~n"
			strOut:+String(ifsoGUI_Window(Gadget).ScrollBarWidth) + "~n"
		ElseIf ifsoGUI_Panel(Gadget)
			strOut:+String(ifsoGUI_Panel(Gadget).GetScrollbars()) + "~n"
			strOut:+String(ifsoGUI_Panel(Gadget).ScrollBarWidth) + "~n"
		ElseIf ifsoGUI_ListBox(Gadget)
			strOut:+String(ifsoGUI_ListBox(Gadget).GetVScrollbar()) + "~n"
			strOut:+String(ifsoGUI_ListBox(Gadget).GetHScrollbar()) + "~n"
			strOut:+String(ifsoGUI_ListBox(Gadget).ScrollBarWidth) + "~n"
		ElseIf ifsoGUI_MCListBox(Gadget)
			strOut:+String(ifsoGUI_MCListBox(Gadget).GetVScrollbar()) + "~n"
			strOut:+String(ifsoGUI_MCListBox(Gadget).GetHScrollbar()) + "~n"
			strOut:+String(ifsoGUI_MCListBox(Gadget).ScrollBarWidth) + "~n"
		ElseIf ifsoGUI_MLTextBox(Gadget)
			strOut:+String(ifsoGUI_MLTextBox(Gadget).GetVScrollbar()) + "~n"
			strOut:+String(ifsoGUI_MLTextBox(Gadget).GetHScrollbar()) + "~n"
			strOut:+String(ifsoGUI_MLTextBox(Gadget).ScrollBarWidth) + "~n"
			strOut:+String(ifsoGUI_MLTextBox(Gadget).WordWrap) + "~n"
		ElseIf ifsoGUI_ProgressBar(Gadget)
			strOut:+String(ifsoGUI_ProgressBar(Gadget).iMin) + "~n"
			strOut:+String(ifsoGUI_ProgressBar(Gadget).iMax) + "~n"
			strOut:+String(ifsoGUI_ProgressBar(Gadget).Value) + "~n"
		ElseIf ifsoGUI_ScrollBar(Gadget)
			strOut:+String(ifsoGUI_ScrollBar(Gadget).MinVal) + "~n"
			strOut:+String(ifsoGUI_ScrollBar(Gadget).MaxVal) + "~n"
			strOut:+String(ifsoGUI_ScrollBar(Gadget).Value) + "~n"
			strOut:+String(ifsoGUI_ScrollBar(Gadget).Interval) + "~n"
			strOut:+String(ifsoGUI_ScrollBar(Gadget).Size) + "~n"
		ElseIf ifsoGUI_Slider(Gadget)
			strOut:+String(ifsoGUI_Slider(Gadget).MinVal) + "~n"
			strOut:+String(ifsoGUI_Slider(Gadget).MaxVal) + "~n"
			strOut:+String(ifsoGUI_Slider(Gadget).Value) + "~n"
			strOut:+String(ifsoGUI_Slider(Gadget).Interval) + "~n"
			strOut:+String(ifsoGUI_Slider(Gadget).Direction) + "~n"
			strOut:+String(ifsoGUI_Slider(Gadget).ShowTicks) + "~n"
		ElseIf ifsoGUI_TextBox(Gadget)
			strOut:+ifsoGUI_TextBox(Gadget).Value + "~n"
		ElseIf ifsoGUI_Tabber(Gadget) 'v1.18
			strOut:+ifsoGUI_Tabber(Gadget).GetNumTabs() + "~n"
			For Local tbi%=0 To ifsoGUI_Tabber(Gadget).GetNumTabs()-1
				strOut:+ifsoGUI_Tabber(Gadget).GetTabText(tbi) + "~n"
			Next
		End If
		strOut:+String(Gadget.Color[0]) + "~n"
		strOut:+String(Gadget.Color[1]) + "~n"
		strOut:+String(Gadget.Color[2]) + "~n"
		strOut:+Props.tbAlpha.GetText() + "~n"
		If parent_type > 0 'v1.18
			strOut:+String(parent_type) + "~n"
			strOut:+String(tab_order) + "~n"
		EndIf
		strOut:+Props.tbTip.GetText() + "~n"
		strOut:+String(Props.chkOnTop.GetValue()) + "~n"
		strOut:+String(Props.chkAutoSize.GetValue()) + "~n"
		strOut:+String(Props.chkShowFocus.GetValue()) + "~n"
		strOut:+String(Gadget.FocusColor[0]) + "~n"
		strOut:+String(Gadget.FocusColor[1]) + "~n"
		strOut:+String(Gadget.FocusColor[2]) + "~n"
		strOut:+Props.tbSkin.GetText() + "~n"
		strOut:+Props.tbFont.GetText() + "~n"
		strOut:+Props.tbFontSize.GetText() + "~n"
		strOut:+String(Gadget.TextColor[0]) + "~n"
		strOut:+String(Gadget.TextColor[1]) + "~n"
		strOut:+String(Gadget.TextColor[2])
		strOut:+ifsoGUI_TextBox(Props.pnlProps.GetChild("tbSkin")).GetText()
		file.WriteString(strOut)
		For Local g:TPropGadget = EachIn Children
			g.WriteSelf(file)
		Next
	End Method
	Method ReadSelf(file:TStream)
		Local str1:String, str2:String, str3:String
		str1 = file.ReadLine() 'x
		str2 = file.ReadLine() 'y
		SetXY(Int(str1), Int(str2))
		str1 = file.ReadLine() 'w
		str2 = file.ReadLine() 'h
		SetWH(Int(str1), Int(str2))
		If ifsoGUI_ImageButton(Gadget)
			str1 = file.ReadLine() 'Label
			ifsoGUI_ImageButton(Gadget).SetLabel(str1)
			Props.tbValue.SetText(str1)
			str1 = file.ReadLine() 'normal image
			str2 = file.ReadLine() 'over image
			str3 = file.ReadLine() 'down image
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbNormalImage")).SetText(str1)
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbOverImage")).SetText(str2)
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbDownImage")).SetText(str3)
			ifsoGUI_ImageButton(Gadget).SetImages(LoadImage(str1), LoadImage(str2), LoadImage(str3))
		ElseIf ifsoGUI_Button(Gadget)
			str1 = file.ReadLine() 'Label
			ifsoGUI_Button(Gadget).SetLabel(str1)
			Props.tbValue.SetText(str1)
		ElseIf ifsoGUI_Label(Gadget)
			str1 = file.ReadLine() 'Label
			ifsoGUI_Label(Gadget).SetLabel(str1)
			Props.tbValue.SetText(str1)
		ElseIf ifsoGUI_CheckBox(Gadget)
			str1 = file.ReadLine() 'Label
			ifsoGUI_CheckBox(Gadget).SetLabel(str1)
			Props.tbValue.SetText(str1)
			str1 = file.ReadLine() 'checked
			ifsoGUI_CheckBox(Gadget).SetValue(Int(str1))
			ifsoGUI_CheckBox(Props.pnlProps.GetChild("chkChecked")).SetValue(Int(str1))
		ElseIf ifsoGUI_Window(Gadget)
			str1 = file.ReadLine() 'Caption
			ifsoGUI_Window(Gadget).SetCaption(str1)
			Props.tbValue.SetText(str1)
			str1 = file.ReadLine() 'Scrollbars
			ifsoGUI_Window(Gadget).SetScrollbars(Int(str1))
			ifsoGUI_Combobox(Props.pnlProps.GetChild("cbScrollbars")).SetSelected(Int(str1))
			str1 = file.ReadLine() 'Scrollbar width
			ifsoGUI_Window(Gadget).SetScrollBarWidth(Int(str1))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbScrollWidth")).SetText(str1)
		ElseIf ifsoGUI_Panel(Gadget)
			str1 = file.ReadLine() 'Scrollbars
			ifsoGUI_Panel(Gadget).SetScrollbars(Int(str1))
			ifsoGUI_Combobox(Props.pnlProps.GetChild("cbScrollbars")).SetSelected(Int(str1))
			str1 = file.ReadLine() 'Scrollbar width
			ifsoGUI_Panel(Gadget).SetScrollBarWidth(Int(str1))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbScrollWidth")).SetText(str1)
		ElseIf ifsoGUI_ListBox(Gadget)
			str1 = file.ReadLine() 'VScrollbar
			ifsoGUI_ListBox(Gadget).SetVScrollbar(Int(str1))
			ifsoGUI_Combobox(Props.pnlProps.GetChild("cbVScrollbar")).SetSelected(Int(str1))
			str1 = file.ReadLine() 'HScrollbar
			ifsoGUI_ListBox(Gadget).SetHScrollbar(Int(str1))
			ifsoGUI_Combobox(Props.pnlProps.GetChild("cbHScrollbar")).SetSelected(Int(str1))
			str1 = file.ReadLine() 'Scrollbar width
			ifsoGUI_ListBox(Gadget).SetScrollBarWidth(Int(str1))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbScrollWidth")).SetText(str1)
		ElseIf ifsoGUI_MCListBox(Gadget)
			str1 = file.ReadLine() 'VScrollbar
			ifsoGUI_MCListBox(Gadget).SetVScrollbar(Int(str1))
			ifsoGUI_Combobox(Props.pnlProps.GetChild("cbVScrollbar")).SetSelected(Int(str1))
			str1 = file.ReadLine() 'HScrollbar
			ifsoGUI_MCListBox(Gadget).SetHScrollbar(Int(str1))
			ifsoGUI_Combobox(Props.pnlProps.GetChild("cbHScrollbar")).SetSelected(Int(str1))
			str1 = file.ReadLine() 'Scrollbar width
			ifsoGUI_MCListBox(Gadget).SetScrollBarWidth(Int(str1))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbScrollWidth")).SetText(str1)
		ElseIf ifsoGUI_MLTextBox(Gadget)
			str1 = file.ReadLine() 'VScrollbar
			ifsoGUI_MLTextBox(Gadget).SetVScrollbar(Int(str1))
			ifsoGUI_Combobox(Props.pnlProps.GetChild("cbVScrollbar")).SetSelected(Int(str1))
			str1 = file.ReadLine() 'HScrollbar
			ifsoGUI_MLTextBox(Gadget).SetHScrollbar(Int(str1))
			ifsoGUI_Combobox(Props.pnlProps.GetChild("cbHScrollbar")).SetSelected(Int(str1))
			str1 = file.ReadLine() 'Scrollbar width
			ifsoGUI_MLTextBox(Gadget).SetScrollBarWidth(Int(str1))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbScrollWidth")).SetText(str1)
			str1 = file.ReadLine() 'wordwrap
			ifsoGUI_MLTextBox(Gadget).SetWordWrap(Int(str1))
			ifsoGUI_CheckBox(Props.pnlProps.GetChild("chkWordWrap")).SetValue(Int(str1))
		ElseIf ifsoGUI_ProgressBar(Gadget)
			str1 = file.ReadLine() 'Min
			str2 = file.ReadLine() 'Max
			ifsoGUI_ProgressBar(Gadget).SetMinMax(Int(str1), Int(str2))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbMin")).SetText(str1)
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbMax")).SetText(str2)
			str1 = file.ReadLine() 'Value
			ifsoGUI_ProgressBar(Gadget).SetValue(Int(str1))
			Props.tbValue.SetText(str1)
		ElseIf ifsoGUI_ScrollBar(Gadget)
			str1 = file.ReadLine() 'Min
			str2 = file.ReadLine() 'Max
			ifsoGUI_ScrollBar(Gadget).SetMinMax(Int(str1), Int(str2))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbMin")).SetText(str1)
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbMax")).SetText(str2)
			str1 = file.ReadLine() 'Value
			ifsoGUI_ScrollBar(Gadget).SetValue(Int(str1))
			Props.tbValue.SetText(str1)
			str1 = file.ReadLine() 'Interval
			ifsoGUI_ScrollBar(Gadget).SetInterval(Int(str1))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbInterval")).SetText(str1)
			str1 = file.ReadLine() 'Bar Interval
			ifsoGUI_ScrollBar(Gadget).SetBarInterval(Int(str1))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbBarInterval")).SetText(str1)
		ElseIf ifsoGUI_Slider(Gadget)
			str1 = file.ReadLine() 'Min
			str2 = file.ReadLine() 'Max
			ifsoGUI_Slider(Gadget).SetMinMax(Int(str1), Int(str2))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbMin")).SetText(str1)
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbMax")).SetText(str2)
			str1 = file.ReadLine() 'Value
			ifsoGUI_Slider(Gadget).SetValue(Int(str1))
			Props.tbValue.SetText(str1)
			str1 = file.ReadLine() 'Interval
			ifsoGUI_Slider(Gadget).SetInterval(Int(str1))
			ifsoGUI_TextBox(Props.pnlProps.GetChild("tbInterval")).SetText(str1)
			str1 = file.ReadLine() 'Direction
			ifsoGUI_Slider(Gadget).SetDirection(Int(str1))
			ifsoGUI_CheckBox(Props.pnlProps.GetChild("chkDirection")).SetValue(Int(str1))
			str1 = file.ReadLine() 'Ticks
			ifsoGUI_Slider(Gadget).SetShowTicks(Int(str1))
			ifsoGUI_CheckBox(Props.pnlProps.GetChild("chkShowTicks")).SetValue(Int(str1))
		ElseIf ifsoGUI_TextBox(Gadget)
			str1 = file.ReadLine() 'Text
			ifsoGUI_TextBox(Gadget).SetText(str1)
			Props.tbValue.SetText(str1)
		ElseIf ifsoGUI_Tabber(Gadget) 'v1.18
			str1 = file.ReadLine()
			Local cb:ifsoGUI_Combobox
			For cb=EachIn ActiveProps.tab_combo_list 'get last
			Next
			cb.RemoveItem(0)
			For Local tbi%=0 To Int(str1)-1
				str2 = file.ReadLine()
				If tbi = 0 Then ifsoGUI_Tabber(Gadget).SetTabText(tbi, str2)
				If tbi > 0 Then ifsoGUI_Tabber(Gadget).AddTab(str2, "", 0, tbi)
				If cb
					If tbi = 0 Then cb.AddItem(ifsoGUI_Tabber(Gadget).GetTabText(tbi), tbi, "", True)
					If tbi > 0 Then cb.AddItem(ifsoGUI_Tabber(Gadget).GetTabText(tbi), tbi, "", False)
				EndIf
			Next
		End If
		str1 = file.ReadLine() 'GadgetColor R
		Gadget.Color[0] = Int(str1)
		Props.tbGadgetColor[0].SetText(str1)
		str1 = file.ReadLine() 'GadgetColor G
		Gadget.Color[1] = Int(str1)
		Props.tbGadgetColor[1].SetText(str1)
		str1 = file.ReadLine() 'GadgetColor B
		Gadget.Color[2] = Int(str1)
		Props.tbGadgetColor[2].SetText(str1)
		str1 = file.ReadLine() 'Alpha
		Gadget.fAlpha = Float(str1)
		Props.tbAlpha.SetText(str1)
		str1 = file.ReadLine() 'v1.18
		If Int(str1) > 0
			parent_type = Int(str1)
			str1 = file.ReadLine()
			tab_order = Int(str1)
			str1 = file.ReadLine() 'Tip
		EndIf
		Gadget.Tip = str1
		Props.tbTip.SetText(str1)
		str1 = file.ReadLine() 'OnTop
		Gadget.OnTop = Int(str1)
		Props.chkOnTop.SetValue(Int(str1))
		str1 = file.ReadLine() 'AutoSize
		Gadget.AutoSize = Int(str1)
		Props.chkAutoSize.SetValue(Int(str1))
		str1 = file.ReadLine() 'Show Focus
		Gadget.ShowFocus = Int(str1)
		Props.chkShowFocus.SetValue(Int(str1))
		str1 = file.ReadLine() 'Focus Color R
		Gadget.FocusColor[0] = Int(str1)
		Props.tbFocusColor[0].SetText(str1)
		str1 = file.ReadLine() 'Focus Color G
		Gadget.FocusColor[1] = Int(str1)
		Props.tbFocusColor[1].SetText(str1)
		str1 = file.ReadLine() 'Focus Color B
		Gadget.FocusColor[2] = Int(str1)
		Props.tbFocusColor[2].SetText(str1)
		str1 = file.ReadLine() 'Skin
		If str1 <> ""
			Gadget.LoadSkin(str1)
		ElseIf AppProps.tbSkin.Value <> ""
			Gadget.LoadSkin(AppProps.tbSkin.Value)
		End If
		Props.tbSkin.SetText(str1)
		str1 = file.ReadLine() 'Font
		str2 = file.ReadLine() 'Font Size
		If str1 <> ""
			Gadget.SetFont(LoadImageFont(str1, Int(str2)))
		ElseIf AppProps.tbFont.Value <> ""
			Gadget.SetFont(LoadImageFont(AppProps.tbFont.Value, Int(AppProps.tbFontSize.Value)))
		End If
		Props.tbFont.SetText(str1)
		Props.tbFontSize.SetText(str2)
		str1 = file.ReadLine() 'Text Color R
		Gadget.TextColor[0] = Int(str1)
		Props.tbTextColor[0].SetText(str1)
		str1 = file.ReadLine() 'Text Color G
		Gadget.TextColor[1] = Int(str1)
		Props.tbTextColor[1].SetText(str1)
		str1 = file.ReadLine() 'Text Color B
		Gadget.TextColor[2] = Int(str1)
		Props.tbTextColor[2].SetText(str1)
	End Method
	Method AddChild(g:ifsoGUI_Base)  'Add a child to the gadget
		g.Parent = Self
		If g.OnTop
			Children.AddLast(g)
		Else
			Local t:TLink = Children.LastLink()
			While t
				If Not ifsoGUI_Base(t.Value()).OnTop Exit
				t = t.PrevLink()
			Wend
			If Not t
				Children.AddFirst(g)
			Else
				Children.InsertAfterLink(g, t)
			End If
		End If
		ChildMoved(g)
	End Method
	Method RemoveChild(gadget:ifsoGUI_Base, bDestroy:Int = True)
		If gadget = GUI.gActiveGadget
			GUI.gActiveGadget = Null
		ElseIf gadget.IsMyChild(GUI.gActiveGadget)
		 GUI.gActiveGadget = Null
		End If
		If gadget = GUI.gMouseOverGadget
			GUI.gMouseOverGadget = Null
		ElseIf gadget.IsMyChild(GUI.gMouseOverGadget)
		 GUI.gMouseOverGadget = Null
		End If
		If GUI.Modal = gadget
			GUI.SetModal(Null)
		ElseIf gadget.IsMyChild(GUI.Modal)
			GUI.SetModal(Null)
		End If
		gadget.Parent = Null
		Children.Remove(gadget)
		If bDestroy gadget.Destroy()
		ChildMoved(Null)
	End Method

	Method Draw(parX:Int, parY:Int, parW:Int, parH:Int)
		Gadget.Draw(parX, parY, parW, parH)
	End Method
	Method DrawSelection()
		If ClientArea.wndCode.GetVisible() Return
		SetColor(SelectColor[0], SelectColor[1], SelectColor[2])
		ActiveProps.selected_gadget.Gadget=Gadget 'v1.18
		ActiveProps.selected_gadget.GadgetType=GadgetType
		SetLineWidth(2)
		ifsoGUI_VP.Add(ClientArea.pnlScreen.x + ClientArea.pnlScreen.BorderLeft, ClientArea.pnlScreen.y + ClientArea.pnlScreen.BorderTop, ClientArea.pnlScreen.w - (ClientArea.pnlScreen.BorderLeft + ClientArea.pnlScreen.BorderRight), ClientArea.pnlScreen.h - (ClientArea.pnlScreen.BorderTop + ClientArea.pnlScreen.BorderBottom))
		Local iX:Int, iY:Int
		Parent.GetAbsoluteXY(iX, iY)
		iX:+x
		iY:+y
		ifsoGUI_VP.DrawLine(iX, iY + 1, iX + w - 1, iY + 1)
		ifsoGUI_VP.DrawLine(iX + 1, iY, iX + 1, iY + h - 1)
		ifsoGUI_VP.DrawLine(iX + w - 1, iY, iX + w - 1, iY + h - 1)
		ifsoGUI_VP.DrawLine(iX, iY + h - 1, iX + w - 1, iY + h - 1)
		ifsoGUI_VP.Pop()
	End Method
	Method GetAbsoluteXY(iX:Int Var, iY:Int Var, caller:ifsoGUI_Base = Null)
		If Parent
			Parent.GetAbsoluteXY(iX, iY, Self)
		ElseIf Master
			Master.GetAbsoluteXY(iX, iY, Self)
		End If
		iX:+x
		iY:+y
		If ifsoGUI_Panel(Gadget)
			If caller <> Self And ifsoGUI_Panel(Gadget).ShowBorder
			 iX:+ifsoGUI_Panel(Gadget).BorderLeft
			 iY:+ifsoGUI_Panel(Gadget).BorderTop
			End If
		ElseIf ifsoGUI_Tabber(Gadget)
			If caller <> Self
				iY:+ifsoGUI_Tabber(Gadget).TabHeight
				iX:+ifsoGUI_Panel(ifsoGUI_Tabber(Gadget).Tabs[ifsoGUI_Tabber(Gadget).GetCurrentTab()].panel).borderleft
			End If
		End If
	End Method
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
	 GUI.SetActiveGadget(Self)
		If iButton = 1
			TProps.SelectProps(Props)
			If ResizeSpot > 0
				Resizing = True
				If ResizeSpot & ifsoGUI_RESIZE_LEFT
					MousePosX = iMouseX
				ElseIf ResizeSpot & ifsoGUI_RESIZE_RIGHT
					MousePosX = iMouseX - w
				End If
				If ResizeSpot & ifsoGUI_RESIZE_TOP
					MousePosY = iMouseY
				ElseIf ResizeSpot & ifsoGUI_RESIZE_BOTTOM
					MousePosY = iMouseY - h
				End If
			Else
			 Dragging = True
				MousePosX = iMouseX - x
				MousePosY = iMouseY - y
			End If
		End If
	End Method
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		Dragging = False
		Resizing = False
	End Method
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not Visible Return False
		If Dragging Or Resizing
			GUI.gMouseOverGadget = Self
			Return True
		Else
			ResizeSpot = 0
			If (iMouseX > parX + x) And (iMouseX < parX + x + w) And (iMouseY > parY + y) And (iMouseY < parY + y + h)
				If ifsoGUI_Panel(Gadget)
					Local chkX:Int = x, chkY:Int = y
					Local chkW:Int = w - (Gadget.BorderLeft + Gadget.BorderRight), chkH:Int = h - (Gadget.BorderTop + Gadget.BorderBottom)
					If (iMouseX > parX + x + Gadget.BorderLeft) And (iMouseX < parx + x + w - Gadget.BorderRight) And (iMouseY > parY + y + Gadget.BorderTop) And (iMouseY < parY + y + h - Gadget.BorderBottom)
							If x + w + Gadget.BorderRight > parW chkW:-(x + chkW - parW)
							If y + h + Gadget.BorderBottom > parH chkH:-(y + chkH - parH)
							chkX:+Gadget.BorderLeft
							chkY:+Gadget.BorderTop
							Local bFlag:Int
							For Local c:ifsoGUI_Base = EachIn Children
								If c.IsMouseOver(parX + chkX, parY + chkY, chkW, chkH, iMouseX, iMouseY) bFlag = True
							Next
							If bFlag Return True
					End If
				ElseIf ifsoGUI_Tabber(Gadget)
					Local bleft:Int = ifsoGUI_Tabber(Gadget).Tabs[ifsoGUI_Tabber(Gadget).GetCurrentTab()].panel.BorderLeft
					Local bright:Int = ifsoGUI_Tabber(Gadget).Tabs[ifsoGUI_Tabber(Gadget).GetCurrentTab()].panel.BorderRight
					Local bbottom:Int = ifsoGUI_Tabber(Gadget).Tabs[ifsoGUI_Tabber(Gadget).GetCurrentTab()].panel.BorderBottom
					Local btop:Int = ifsoGUI_Tabber(Gadget).TabHeight
					Local chkX:Int = x, chkY:Int = y
					Local chkW:Int = w - (bleft + bright), chkH:Int = h - (btop + bbottom)
					If (iMouseX > parX + x + bleft) And (iMouseX < parx + x + w - bright) And (iMouseY > parY + y + btop) And (iMouseY < parY + y + h - bbottom)
							If x + w + bright > parW chkW:-(x + chkW - parW)
							If y + h + bbottom > parH chkH:-(y + chkH - parH)
							chkX:+bleft
							chkY:+btop
							Local bFlag:Int
							Local curpanel:ifsoGUI_Panel = ifsoGUI_Tabber(Gadget).Tabs[ifsoGUI_Tabber(Gadget).CurrentTab].panel
							For Local c:ifsoGUI_Base = EachIn Children
								If TPropGadget(c).Gadget.Parent = curpanel
									If c.IsMouseOver(parX + chkX, parY + chkY, chkW, chkH, iMouseX, iMouseY) bFlag = True
								End If
							Next
							If bFlag Return True
					End If
				End If
				GUI.gMouseOverGadget = Self
				If ActiveProps = Props
					'Test Sides for resize spot
					If iMouseX <= parX + x + MouseBorderCheck 'Left
						ResizeSpot = ifsoGUI_RESIZE_LEFT
					ElseIf iMouseX >= parX + x + w - MouseBorderCheck 'Right
					 ResizeSpot = ifsoGUI_RESIZE_RIGHT
					End If
					If iMouseY <= parY + y + MouseBorderCheck 'Top
					 ResizeSpot:|ifsoGUI_RESIZE_TOP
					ElseIf iMouseY >= parY + y + h - MouseBorderCheck 'Bottom
					 ResizeSpot:|ifsoGUI_RESIZE_BOTTOM
					End If
				End If
				Return True
			End If
		End If
		Return False
	End Method
	Method KeyPress(key:Int)
		If key = ifsoGUI_KEY_DELETE
			DeleteSelf()
			For Local p:TGadgetProps = EachIn SelectedProps
				p.PropGadget.DeleteSelf()
			Next
			TProps.SelectProps(AppProps)
		ElseIf KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL)
		 If key = ifsoGUI_KEY_LEFT
				SetWH(w - 1, h)
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetWH(p.PropGadget.w - 1, p.PropGadget.h)
				Next
			ElseIf key = ifsoGUI_KEY_RIGHT
				SetWH(w + 1, h)
				For Local p:TProps = EachIn SelectedProps
				 p.PropGadget.SetWH(p.PropGadget.w + 1, p.PropGadget.h)
				Next
			ElseIf key = ifsoGUI_KEY_UP
				SetWH(w, h - 1)
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetWH(p.PropGadget.w, p.PropGadget.h - 1)
				Next
			ElseIf key = ifsoGUI_KEY_DOWN
				SetWH(w, h + 1)
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetWH(p.PropGadget.w, p.PropGadget.h + 1)
				Next
			End If
		Else
		 If key = ifsoGUI_KEY_LEFT
				SetXY(x - 1, y)
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(p.PropGadget.x - 1, p.PropGadget.y)
				Next
			ElseIf key = ifsoGUI_KEY_RIGHT
				SetXY(x + 1, y)
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(p.PropGadget.x + 1, p.PropGadget.y)
				Next
			ElseIf key = ifsoGUI_KEY_UP
				SetXY(x, y - 1)
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(p.PropGadget.x, p.PropGadget.y - 1)
				Next
			ElseIf key = ifsoGUI_KEY_DOWN
				SetXY(x, y + 1)
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(p.PropGadget.x, p.PropGadget.y + 1)
				Next
			End If
		End If
	End Method
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base)
		If ActiveProps <> Props
			If TGadgetProps(ActiveProps)
				If ActiveProps.PropGadget.Dragging Or ActiveProps.PropGadget.Resizing
					ActiveProps.PropGadget.MouseOver(iMouseX, iMouseY, Null)
					Return
				End If
			End If
		End If
		If Dragging
			Local iDistX:Int = x - (iMouseX - MousePosX)
			Local iDistY:Int = y - (iMouseY - MousePosY)
			SetXY(iMouseX - MousePosX, iMouseY - MousePosY)
			For Local p:TProps = EachIn SelectedProps
				p.PropGadget.SetXY(p.PropGadget.x - iDistX, p.PropGadget.y - iDisty)
			Next
		ElseIf Resizing
			Local newW:Int = w, newH:Int = h
			Local newX:Int = x, newY:Int = y
			Local iChangeW:Int, iChangeH:Int
			Local iDistX:Int, iDistY:Int
			If ResizeSpot & ifsoGUI_RESIZE_LEFT
				newW:-(iMouseX - MousePosX)
				newX:+iMouseX - MousePosX
				iChangeW = iMouseX - MousePosX
				iDistX = iMouseX - MousePosX
				MousePosX = iMouseX
			ElseIf ResizeSpot & ifsoGUI_RESIZE_RIGHT
			 newW = iMouseX - MousePosX
				iChangeW = w - (iMouseX - MousePosX)
			End If
			If ResizeSpot & ifsoGUI_RESIZE_TOP
				newH:-(iMouseY - MousePosY)
				newY:+iMouseY - MousePosY
				iChangeH = iMouseY - MousePosY
				iDistY = iMouseY - MousePosY
				MousePosY = iMouseY
			ElseIf ResizeSpot & ifsoGUI_RESIZE_BOTTOM
			 newH = iMouseY - MousePosY
				iChangeH = h - (iMouseY - MousePosY)
			End If
			If newX <> x Or newY <> y Or newW <> w Or newH <> h
				SetXY(newX, newY)
				SetWH(newW, newH)
				For Local p:TProps = EachIn SelectedProps
					p.PropGadget.SetXY(p.PropGadget.x + iDistX, p.PropGadget.y + iDistY)
					p.PropGadget.SetWH(p.PropGadget.w - iChangeW, p.PropGadget.h - iChangeH)
				Next
			End If
		End If
	End Method
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If ActiveProps <> Props
			If TGadgetProps(ActiveProps)
				If ActiveProps.PropGadget.Dragging Or ActiveProps.PropGadget.Resizing
					Return ActiveProps.PropGadget.MouseStatus(iMouseX, iMouseY)
				End If
			End If
		End If
		If Enabled And Visible
			If ResizeSpot
				GUI.iMouseDir = ResizeSpot
				Return ifsoGUI_MOUSE_RESIZE
			ElseIf bPressed Or Dragging
				Return ifsoGUI_MOUSE_DOWN
			ElseIf GUI.gMouseOverGadget = Self
				Return ifsoGUI_MOUSE_OVER
			End If
		End If
		Return ifsoGUI_MOUSE_NORMAL
	End Method
	Method DeleteSelf()
		If Parent <> ClientArea.Screen
			TPropGadget(Parent).Gadget.RemoveChild(Gadget)
		End If
		For Local g:TPropGadget = EachIn Children
			g.DeleteSelf()
		Next
		Parent.RemoveChild(Self)
		GUI.Tabs.Remove(Self)
		TProps.AllProps.Remove(Props)
		For Local i:Int = 0 To cbGadgets.dropList.Items.Length - 1
			If cbGadgets.dropList.Items[i].Data = Props.Data
				cbGadgets.RemoveItem(i)
				Exit
			End If
		Next
	End Method
	Method SetXY(iX:Int, iY:Int)
		Gadget.SetXY(iX, iY)
		Super.SetXY(Gadget.x, Gadget.y)
		Props.tbX.SetText(String(x))
		Props.tbY.SetText(String(y))
	End Method
	Method SetWH(iX:Int, iY:Int)
		Gadget.SetWH(iX, iY)
		If ifsoGUI_Slider(Gadget)
			If ifsoGUI_Slider(Gadget).Vertical
				Super.SetWH(Gadget.h, Gadget.w)
			Else
				Super.SetWH(Gadget.w, Gadget.h)
			End If
		Else
			Super.SetWH(Gadget.w, Gadget.h)
		End If
		Props.tbW.SetText(String(w))
		Props.tbH.SetText(String(h))
	End Method
	Method LoadSkin(strSkin:String)
		Gadget.LoadSkin(strSkin)
		Props.tbSkin.SetText(strSkin)
	End Method

End Type