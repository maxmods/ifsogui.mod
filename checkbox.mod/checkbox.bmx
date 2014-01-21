SuperStrict

Rem
	bbdoc: ifsoGUI Checkbox
	about: Checkbox Gadget
EndRem
Module ifsogui.checkbox

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI

GUI.Register(ifsoGUI_Checkbox.SystemEvent)

Rem
	bbdoc: CheckBox Type
End Rem
Type ifsoGUI_CheckBox Extends ifsoGUI_Base
	Global gImageOff:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the checkbox off
	Global gImageOn:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the checkbox on
	Field lImageOff:ifsoGUI_Image 'Images to draw the checkbox off
	Field lImageOn:ifsoGUI_Image 'Images to draw the checkbox on
	
	Field Label:String 'Label on the checkbox
	Field bChecked:Int 'Is it checked
	Field bLabelClick:Int = True 'Can the label be clicked
	Field CheckBoxW:Int, CheckBoxH:Int 'Size of the checkbox

	'Events
	'Click
	
	Rem
		bbdoc: Create and returns a chechkbox gadget.  Set iW=-1 And/Or iH to turn on AutoSize at gadget creation.
	End Rem
	Function Create:ifsoGUI_Checkbox(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, strLabel:String)
		Local p:ifsoGUI_CheckBox = New ifsoGUI_CheckBox
		p.x = iX
		p.y = iY
		p.lImageOff = gImageOff
		p.lImageOn = gImageOn
		p.Name = strName
		p.Label = strLabel
		If iW = -1 Or iH = -1 p.AutoSize = True
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
		'Select the correct image
		Local offset:Int = (h - CheckBoxH) / 2
		If bChecked
			DrawBox2(lImageOn, rX, rY + offset, CheckBoxW, CheckBoxH)
		Else
			DrawBox2(lImageOff, rX, rY + offset, CheckBoxW, CheckBoxH)
		End If
		If Label <> ""
			offset = (h - ifsoGUI_VP.GetTextHeight(Self)) / 2
			Local vpX:Int = rX + CheckBoxW + 2
			If vpX < parX vpX = parX
			Local vpY:Int = rY
			If vpY < parY vpY = parY
			Local vpW:Int = w - (CheckBoxW + 2)
			If vpX + vpW > parX + parW vpW = parX + parW - vpX
			Local vpH:Int = h
			If vpY + vpH > parY + parH vpH = parY + parH - vpY
			ifsoGUI_VP.Add(vpX, vpY, vpW, vpH)
			SetColor(TextColor[0], TextColor[1], TextColor[2])
			If fFont SetImageFont(fFont)
			ifsoGUI_VP.DrawTextArea(Label, rX + CheckBoxW + 2, rY + offset, Self)
			If ShowFocus And HasFocus DrawFocus(vpX, vpY, vpW - 1, vpH - 1)
			If fFont SetImageFont(GUI.DefaultFont)
			ifsoGUI_VP.Pop()
		End If
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
Global Last:Int
	If Not Visible Return False
		Local offset:Int = (h - CheckBoxH) / 2
		If (iMouseX > parX + x) And (iMouseX < parX + x + CheckBoxW) And (iMouseY > parY + y + offset) And (iMouseY < parY + y + offset + CheckBoxH)
			'Over the Checkbox
			GUI.gMouseOverGadget = Self
			Return True
		ElseIf bLabelClick
			If (iMouseX >= parX + x + CheckBoxW) And (iMouseX < parX + x + w) And (iMouseY > parY + y) And (iMouseY < parY + y + h)
				GUI.gMouseOverGadget = Self
				Return True
			End If
		End If
		Return False
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
		If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
		 GUI.SetActiveGadget(Self)
			bPressed = True
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		If GUI.gMouseOverGadget = Self
		 If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
				bChecked = Not bChecked
			 SendEvent(ifsoGUI_EVENT_CHANGE, bChecked, iMouseX, iMouseY)
			End If
		Else
			GUI.SetActiveGadget(Null)
		End If
		bPressed = False
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		If strSkin = ""
			bSkin = False
			lImageOff = gImageOff
			lImageOn = gImageOn
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("checkbox", strSkin).Split(",")
		Load9Image2("/graphics/checkboxoff.png", dimensions, lImageOff, strSkin)
		Load9Image2("/graphics/checkboxon.png", dimensions, lImageOn, strSkin)
		Refresh()
	End Method
	Rem
		bbdoc: Refreshes the gadget.
		about: Recalculates any geometry/font changes, etc.
		Internal function should not be called by the user.
	End Rem
	Method Refresh()
		BorderTop = lImageOn.h[1]
		BorderBottom = lImageOn.h[7]
		BorderLeft = lImageOn.w[3]
		BorderRight = lImageOn.w[5]
		CheckBoxW = lImageOn.w[3] + lImageOn.w[4] + lImageOn.w[5]
		CheckBoxH = lImageOn.h[1] + lImageOn.h[4] + lImageOn.h[7]
		If AutoSize 'Size of the box and text
			Local wasFont:TImageFont = GetImageFont()
			If fFont
				SetImageFont(fFont)
			Else
				SetImageFont(GUI.DefaultFont)
			End If
			w = CheckBoxW + 4 + ifsoGUI_VP.GetTextWidth(Label, Self)
			h = ifsoGUI_VP.GetTextHeight(Self)
			SetImageFont(wasFont)
		End If
		If h < CheckBoxH h = CheckBoxH
		If w < CheckBoxW w = CheckBoxW
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
	 If key = 13 Or Key = 32 'Carriage Return or Space
			bChecked = Not bChecked
			SendEvent(ifsoGUI_EVENT_CHANGE, bChecked, -1, -1)
		End If
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("checkbox").Split(",")
		Load9Image2("/graphics/checkboxoff.png", dimensions, gImageOff)
		Load9Image2("/graphics/checkboxon.png", dimensions, gImageOn)
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
	bbdoc: Sets the value of the gadget.
	End Rem
	Method SetValue(Checked:Int)
		bChecked = Checked
	End Method
	Rem
	bbdoc: Returns the value of the gadget.
	End Rem
	Method GetValue:Int()
		Return bChecked
	End Method
	Rem
	bbdoc: Sets the gadgets label.
	End Rem
	Method SetLabel(strLabel:String)
		Label = strLabel
		Refresh()
	End Method
	Rem
	bbdoc: Returns the gadgets label.
	End Rem
	Method GetLabel:String()
		Return Label
	End Method
	Rem
	bbdoc: Sets whether or not the gadget will respond when the label has been clicked.
	End Rem
	Method SetLabelClick(bClick:Int)
		bLabelClick = bClick
	End Method
	Rem
	bbdoc: Returns whether or not the gadgets label can be clicked.
	End Rem
	Method GetLabelClick:Int()
		Return bLabelClick
	End Method
	Rem
	bbdoc: Sets the gadgets checkbox width and height.
	End Rem
	Method SetCheckBoxWH(iW:Int, iH:Int)
		CheckBoxH = iH
		CheckBoxW = iW
		Refresh()
	End Method
	Rem
	bbdoc: Retrieves the gadgets checkbox width and height.
	End Rem
	Method GetCheckBoxWH(iW:Int Var, iH:Int Var)
		iW = CheckBoxW
		iH = CheckBoxH
	End Method
End Type
