SuperStrict

Rem
	bbdoc: ifsoGUI Splitter
	about: Splitter Gadget
EndRem
Module ifsogui.splitter

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2013 Marcus Trisdale"

Import ifsogui.GUI

Rem
	bbdoc: Button Type
End Rem
Type ifsoGUI_Splitter Extends ifsoGUI_Base
	Field bVertical:Int 'Vertical bar or Horizontal bar
	Field iOffSet:Int 'Distance from X (Vertical) or Y (Horizontal) when the mouse was pressed.
	Field iMinPos:Int, iMaxPos:Int 'Min and Max position the splitter can be moved to.
	'Events
	'Change/Mouse Enter/Mouse Exit
	
	Rem
		bbdoc: Create and returns a splitter gadget.
	End Rem
	Function Create:ifsoGUI_Splitter(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, Vertical:Int = False)
		Local p:ifsoGUI_Splitter = New ifsoGUI_Splitter
		p.x = iX
		p.y = iY
		p.SetWH(iW, iH)
		p.Name = strName
		p.bVertical = Vertical
		If Vertical
			p.iMinPos = iX
			p.iMaxPos = iX
		Else
			p.iMinPos = iY
			p.iMaxPos = iY
		End If
		p.Color[0] = 0
		p.Color[1] = 0
		p.Color[2] = 0
		p.SetGadgetAlpha(.5)
		Return p
	End Function
	Rem
		bbdoc: Draws the button gadget.
		about: Internal function should not be called by the user.
	End Rem
	Method Draw(parX:Int, parY:Int, parW:Int, parH:Int)
		If Not Visible Return
		If Not bPressed Return
		If x > parW Or y > parH Return
		SetColor(Color[0], Color[1], Color[2])
		SetAlpha(fAlpha)
		SetLineWidth(4)
		'set up rendering locations
		Local rX:Int = parX + x
		Local rY:Int = parY + y
		If bVertical
			ifsoGUI_VP.DrawLine(rX, rY, rX, rY + h)
		Else
			ifsoGUI_VP.DrawLine(rX, rY, rX + w, rY)
		End If
		
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
			If bVertical
				iOffSet = iMouseX - X
			Else
				iOffSet = iMouseY - Y
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
		If GUI.gMouseOverGadget <> Self
			GUI.SetActiveGadget(Null)
		End If
	End Method
	Rem
	bbdoc: Called when the mouse is over this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base) 'Called when mouse is over the gadget, only topmost gadget
		If Not (Enabled And Visible) Return
		If gWasOverGadget <> Self SendEvent(ifsoGUI_EVENT_MOUSE_ENTER, 0, iMouseX, iMouseY)
	End Method
	Rem
	bbdoc: Called when the mouse leaves the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOut(iMouseX:Int, iMouseY:Int, gOverGadget:ifsoGUI_Base) 'Called when mouse no longer over gadget
		If Not (Enabled And Visible) Return
		If gOverGadget <> Self
			SendEvent(ifsoGUI_EVENT_MOUSE_EXIT, 0, iMouseX, iMouseY)
		EndIf
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	This gadget lies, if the mousebutton has been pressed, then it responds true.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not Visible Return False
		If bPressed
			GUI.gMouseOverGadget = Self
		 Return True
		End If
		If (iMouseX >= parX + x) And (iMouseX < parX + x + w) And (iMouseY >= parY + y) And (iMouseY < parY + y + h)
			Local chkX:Int = x, chkY:Int = y
			If chkX < 0 chkX = 0
			If chkY < 0 chkY = 0
			Local chkW:Int = w, chkH:Int = h 'Check if the width is off the parent
			GUI.gMouseOverGadget = Self
			Return True
		End If
		Return False
	End Method
	Rem
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget if button is pressed, otherwise called to MouseOver gadget.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If Not (Enabled And Visible) Return ifsoGUI_MOUSE_NORMAL
		If bVertical
			GUI.iMouseDir = ifsoGUI_RESIZE_LEFT
		Else
			GUI.iMouseDir = ifsoGUI_RESIZE_TOP
		End If
		If bPressed
			Local Moved:Int
			If bVertical
				Local NewPos:Int = iMouseX - iOffSet
				If NewPos < iMinPos
					NewPos = iMinPos
				ElseIf NewPos > iMaxPos
					NewPos = iMaxPos
				End If
				Moved = NewPos - x
				X = NewPos
			Else
				Local NewPos:Int = iMouseY - iOffSet
				If NewPos < iMinPos
					NewPos = iMinPos
				ElseIf NewPos > iMaxPos
					NewPos = iMaxPos
				End If
				Moved = NewPos - y
				Y = NewPos
			End If
			DebugLog MilliSecs() + "NewPos"
			If Moved <> 0 SendEvent(ifsoGUI_EVENT_CHANGE, Moved, iMouseX, iMouseY)
		End If
		Return ifsoGUI_MOUSE_RESIZE
	End Method
	
	'User Functions/Properties
	Rem
	bbdoc: Sets the minimum and maximum positions of the splitter
	about: Affects X pos for Vertical Splitter and Y pos for Horizontal Splitter
	End Rem
	Method SetMinMaxPos(MinPos:Int, MaxPos:Int)
		iMinPos = MinPos
		iMaxPos = MaxPos
		If bVertical
			If X < iMinPos
				SendEvent(ifsoGUI_EVENT_CHANGE, iMinPos - X, 0, 0)
				X = iMinPos
			ElseIf X > iMaxPos
				SendEvent(ifsoGUI_EVENT_CHANGE, iMaxPos - X, 0, 0)
				X = iMaxPos
			End If
		Else
			If Y < iMinPos
				SendEvent(ifsoGUI_EVENT_CHANGE, iMinPos - Y, 0, 0)
				Y = iMinPos
			ElseIf Y > iMaxPos
				SendEvent(ifsoGUI_EVENT_CHANGE, iMaxPos - Y, 0, 0)
				Y = iMaxPos
			End If
		End If
	End Method
	Rem
	bbdoc: Gets the minimum positions of the splitter
	about: Affects X pos for Vertical Splitter and Y pos for Horizontal Splitter
	End Rem
	Method GetMinPos:Int()
		Return iMinPos
	End Method
	Rem
	bbdoc: Gets the maximum positions of the splitter
	about: Affects X pos for Vertical Splitter and Y pos for Horizontal Splitter
	End Rem
	Method GetMaxPos:Int()
		Return iMaxPos
	End Method

	Rem
	bbdoc: Gets the style of the splitter
	about: True for Vertical, False for Horizontal
	End Rem
	Method GetStyle:Int()
		Return bVertical
	End Method

	Rem
	bbdoc: Sets the style of the splitter
	about: True for Vertical, False for Horizontal
	End Rem
	Method SetStyle(Vertical:Int)
		bVertical = Vertical
	End Method

	End Type
