SuperStrict

Rem
	bbdoc: ifsoGUI Spinner Box
	about: SpinBox Gadget
EndRem
Module ifsogui.spinbox

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.spinner
Import ifsogui.textbox

Rem
	bbdoc: SpinBox Type
End Rem
Type ifsoGUI_SpinBox Extends ifsoGUI_Base
	Field gadgetTextBox:ifsoGUI_TextBox
	Field gadgetSpinner:ifsoGUI_Spinner
	
	Field MinVal:Int = 0
	Field MaxVal:Int = 100
	Field Interval:Int = 1
	Field Value:Int

	Rem
		bbdoc: Create and returns a SpinBox gadget.
	End Rem
	Function Create:ifsoGUI_SpinBox(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_SpinBox = New ifsoGUI_SpinBox
		p.x = iX
		p.y = iY
		p.Enabled = True
		p.gadgetTextBox = ifsoGUI_TextBox.Create(0, 0, iW - (iH / 2), iH, strName + "_textbox")
		p.gadgetTextBox.Master = p
		p.gadgetTextBox.SetFilter(FilterNumbers)
		p.Slaves.AddLast(p.gadgetTextBox)
		p.gadgetSpinner = ifsoGUI_Spinner.Create(iW - (iH / 2), 0, iH / 2, iH, strName + "_spinner")
		p.gadgetSpinner.Master = p
		p.gadgetTextBox.Value = "0"
		p.Slaves.AddLast(p.gadgetSpinner)
		p.SetWH(iW, iH)
		p.Name = strName
		Return p
	End Function
	Rem
		bbdoc: Draws the gadget.
		about: Internal function should not be called by the user.
	End Rem
	Method Draw(parX:Int, parY:Int, parW:Int, parH:Int)
		If Not Visible Return
		If x > parW Or y > parH Return
		ifsoGUI_VP.Add(parX + x, parY + y, w, h)
		gadgetTextBox.Draw(parX + x, parY + y, w, h)
		gadgetSpinner.Draw(parX + x, parY + y, w, h)
		ifsoGUI_VP.Pop()
	End Method
	Rem
		bbdoc: Refreshes the gadget.
		about: Recalculates any geometry/font changes, etc.
		Internal function should not be called by the user.
	End Rem
	Method Refresh()
		gadgetTextBox.Refresh()
		gadgetSpinner.Refresh()
	End Method
	Rem
	bbdoc: Sets whether or not to the gadget will autosize or be manually controlled by the user.
	End Rem
	Method SetAutoSize(intAutoSize:Int)
		AutoSize = intAutoSize
		gadgetTextBox.SetAutoSize(intAutoSize)
		h = gadgetTextBox.h
		gadgetSpinner.SetWH(h / 2, h)
		Refresh()
	End Method
	Rem
	bbdoc: Sets the x, y, width, and height all in one call.
	End Rem
	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		x = iX
		y = iY
		SetWH(iW, iH)
	End Method
	Rem
	bbdoc: Gives the gadget the focus.
	about: This sets this gadget as the Active Gadget.
	End Rem
	Method SetFocus()
		If Not (Visible And Enabled) Return
		gadgetTextBox.SetFocus()
	End Method
	Rem
	bbdoc: Sets the gadgets focus box color.
	End Rem
	Method SetFocusColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of gadgets focus box
		FocusColor[0] = iRed
		FocusColor[1] = iGreen
		FocusColor[2] = iBlue
		gadgetTextBox.SetFocusColor(iRed, iGreen, iBlue)
		gadgetSpinner.SetFocusColor(iRed, iGreen, iBlue)
	End Method
	Rem
	bbdoc: Sets the font of the gadget.
	about: Set to Null to use the default GUI font.
	End Rem
	Method SetFont(Font:TImageFont) 'Set the font of the gadget
	 fFont = Font
		gadgetTextBox.SetFont(Font)
	End Method
	Rem
	bbdoc: Sets the gadgets alpha value.
	End Rem
	Method SetGadgetAlpha(fltAlpha:Float)
		fAlpha = fltAlpha
		gadgetTextBox.SetGadgetAlpha(fltAlpha)
		gadgetSpinner.SetGadgetAlpha(fltAlpha)
	End Method
	Rem
	bbdoc: Sets the gadget color of the gadget.
	End Rem
	Method SetGadgetColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of the gadget
		Color[0] = iRed
		Color[1] = iGreen
		Color[2] = iBlue
		gadgetTextBox.SetGadgetColor(iRed, iGreen, iBlue)
		gadgetSpinner.SetGadgetColor(iRed, iGreen, iBlue)
	End Method
	Rem
	bbdoc: Sets whether or not to show the focus box for this gadget.
	End Rem
	Method SetShowFocus(intShowFocus:Int)
		ShowFocus = intShowFocus
		gadgetTextBox.SetShowFocus(intShowFocus)
		gadgetSpinner.SetShowFocus(intShowFocus)
	End Method
	Rem
	bbdoc: Sets the gadget tip text.
	End Rem
	Method SetTip(strTip:String) 'Sets the Tip Text
		Tip = strTip
		gadgetTextBox.SetTip(strTip)
	End Method
	Rem
	bbdoc: Sets whether the gadget is transparent.
	End Rem
	Method SetTransparent(bTransparent:Int)
		boolTransparent = bTransparent
		gadgetTextBox.SetTransparent(bTransparent)
		gadgetSpinner.SetTransparent(bTransparent)
		If Parent Parent.ChildMoved(Self)
	End Method
	Rem
	bbdoc: Sets the gadgets width and height.
	End Rem
	Method SetWH(width:Int, height:Int)
		w = width
		gadgetTextBox.SetWH(w - (height / 2), height)
		h = gadgetTextBox.h
		gadgetTextBox.SetWH(w - (h / 2), h)
		gadgetSpinner.SetWH(h / 2, h)
		gadgetSpinner.SetXY(w - (h / 2), 0)
		Refresh()
		If Parent Parent.ChildMoved(Self)
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
				SetValue(Int(gadgetTextBox.GetText()))
			Case ifsoGUI_EVENT_CLICK
				If gadget = gadgetSpinner SetValue(Value + (data * Interval))
			Case ifsoGUI_EVENT_MOUSE_ENTER
				MouseOver(iMouseX, iMouseY, GUI.gWasMouseOverGadget)
			Case ifsoGUI_EVENT_MOUSE_EXIT
				MouseOut(iMouseX, iMouseY, GUI.gMouseOverGadget)
			Case ifsoGUI_EVENT_GAIN_FOCUS
				If Not HasFocus GainFocus(Null)
			Case ifsoGUI_EVENT_LOST_FOCUS
				LostFocus(GUI.gActiveGadget)
		End Select
	End Method
	Rem
	bbdoc: Can this gadget be active.
	about: Internal function should not be called by the user.
	End Rem
	Method CanActive:Int() 'Spinbox cannot be the Active Gadget
		Return False
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not Visible Return False
		If (iMouseX >= parX + x) And (iMouseX < parX + x + w) And (iMouseY >= parY + y) And (iMouseY < parY + y + h)
			If gadgetTextBox.IsMouseOver(parX + x, parY + y, w, h, iMouseX, iMouseY) Return True
			If gadgetSpinner.IsMouseOver(parX + x, parY + y, w, h, iMouseX, iMouseY) Return True
			GUI.gMouseOverGadget = Self
			Return True
		End If
		Return False
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		gadgetTextBox.LoadSkin(strSkin)
		gadgetSpinner.LoadSkin(strSkin)
	End Method
	Rem
	bbdoc: Returns the value of the gadget.
	End Rem
	Method GetValue:Int()
		Return Value
	End Method
	Rem
	bbdoc: Sets the value of the gadget.
	End Rem
	Method SetValue(intValue:Int)
		If intValue < MinVal intValue = MinVal
		If intValue > MaxVal intValue = MaxVal
		Value = intValue
		gadgetTextBox.SetText(String(Value))
		SendEvent(ifsoGUI_EVENT_CHANGE, Value, 0, 0)
	End Method
	Rem
	bbdoc: Sets the min/max value of the gadget.
	End Rem
	Method SetMinMax(intMin:Int, intMax:Int)
		MinVal = intMin
		MaxVal = intMax
		SetValue(Value)
	End Method
	Rem
	bbdoc: Makes sure only numbers and minus sugn are entered intot he text box.
	End Rem
	Function FilterNumbers:Int(key:Int, gadget:ifsoGUI_Base)
		'negative sign
		If key = 45 And (ifsoGUI_TextBox(gadget).CursorPos = 0 Or ifsoGUI_TextBox(gadget).SelectBegin = 0) Return True
		If key >= 48 And key <= 57 Return True
		Return False
	End Function

End Type
