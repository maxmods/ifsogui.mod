SuperStrict

Rem
	bbdoc: ifsoGUI Slider
	about: Slider Gadget
EndRem
Module ifsogui.slider

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI

GUI.Register(ifsoGUI_Slider.SystemEvent)

Const ifsoGUI_SLIDER_UP_RIGHT:Int = 0
Const ifsoGUI_SLIDER_DOWN_LEFT:Int = 1

Rem
	bbdoc: Slider Type
End Rem
Type ifsoGUI_Slider Extends ifsoGUI_Base
	Global gImageBar:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the bar
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Global gImageButton:TImage[4] 'Imags to draw the button
	Global gImageButtonOver:TImage[4] 'Imags to draw the button
	Global gImageButtonDown:TImage[4] 'Imags to draw the button
	Global gImageTick:TImage[4] 'Image to draw the ticks
	Field lImageBar:ifsoGUI_Image 'Images to draw the bar
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImageButton:TImage[4] 'Imags to draw the button
	Field lImageButtonOver:TImage[4] 'Imags to draw the button
	Field lImageButtonDown:TImage[4] 'Imags to draw the button
	Field lImageTick:TImage[2] 'Image to draw the ticks

	Field ButtonOffSide:Int	'half the buttons width
	Field BarOffset:Int 'offset loc of the bar
	Field Tick1Loc:Int 'y or x of top or left tick row
	Field Tick2Loc:Int 'y or x of bottom or right tick row
	Field BarH:Int 'height of the bar portion

	Field Interval:Int = 1 'Amount changed when pressing the buttons
	Field MinVal:Int = 0, MaxVal:Int = 10, Value:Int 'Values of the control
	Field Vertical:Int	'Is the bar veretical or horizontal
	Field Direction:Int 'Arrow Direction 0=Up or Right 1=Down or Left
	Field ShowTicks:Int = 1 'Show ticks, on/off
	Field Dragging:Int 'Is the button being dragged
	Field Ticks:Int[] 'x or y pos of each tick
	Field Values:Int[] 'value of each tick
	Field CurrentTick:Int
	Field BarW:Int 'width of the bar portion
	Field MouseOverPart:Int 'true over button False over slide bar
	Field LastRepeat:Int 'For repeat delay.
	Field NextRepeat:Int 'To Delay the first time
	Field HalfTickSpace:Float 'Half the space between ticks
	
	'w = length of the control
	'h = height of the control
			
'Variables for Dragging the scrollbar 
	Field DragSpot:Int 'offset from top of button to mouse
	
	'Events
	'Mouse Enter/Mouse Exit/Click
	
	Rem
		bbdoc: Create and returns a slider gadget.
	End Rem
	Function Create:ifsoGUI_Slider(iX:Int, iY:Int, iSize:Int, strName:String, bVertical:Int = False)
		Local p:ifsoGUI_Slider = New ifsoGUI_Slider
		p.x = iX
		p.y = iY
		p.Vertical = bVertical
		p.lImageBar = gImageBar
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.lImageButton = gImageButton
		p.lImageButtonOver = gImageButtonOver
		p.lImageButtonDown = gImageButtonDown
		p.lImageTick = gImageTick
		p.h = p.lImageButton[0].height + 2
		p.BarH = p.lImageBar.h[0] + p.lImageBar.h[3] + p.lImageBar.h[6]
		p.ButtonOffSide = p.lImageButton[0].width / 2
		p.BarOffSet = (p.h - (p.BarH)) / 2
		p.Tick1Loc = p.BarOffSet - p.lImageTick[0].height
		p.Tick2Loc = p.BarOffSet + p.BarH
		p.SetSize(iSize)
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
		SetColor(Color[0], Color[1], Color[2])
		SetAlpha(fAlpha)
		'set up rendering locations
		Local rX:Int = parX + x
		Local rY:Int = parY + y
		Local dImage:TImage[]
		If Dragging
			dImage = lImageButtonDown
		ElseIf GUI.gMouseOverGadget = Self
			dImage = lImageButtonOver
		Else
			dImage = lImageButton
		End If
		If Vertical
			DrawBox2(lImageBar, rX + BarOffset, rY + ButtonOffSide, BarH, BarW, True, lTileSides, lTileCenter)
			If ShowTicks
				For Local i:Int = 0 To Ticks.Length - 1
					ifsoGUI_VP.DrawImageArea(lImageTick[3], rX + Tick1Loc, rY + Ticks[i])
				Next
				For Local i:Int = 0 To Ticks.Length - 1
					ifsoGUI_VP.DrawImageArea(lImageTick[1], rX + Tick2Loc, rY + Ticks[i])
				Next
			End If
			If Direction = ifsoGUI_SLIDER_UP_RIGHT
				ifsoGUI_VP.DrawImageArea(dImage[1], rX + 1, rY + Ticks[CurrentTick] - ButtonOffSide)
			Else
				ifsoGUI_VP.DrawImageArea(dImage[3], rX + 1, rY + Ticks[CurrentTick] - ButtonOffSide)
			End If
			If ShowFocus And GUI.gActiveGadget = Self DrawFocus(rX, rY - 1, H, W + 1)
		Else 'Horizontal
			DrawBox2(lImageBar, rX + ButtonOffSide, rY + BarOffset, BarW, BarH, True, lTileSides, lTileCenter)
			If ShowTicks
				For Local i:Int = 0 To Ticks.Length - 1
					ifsoGUI_VP.DrawImageArea(lImageTick[0], rX + Ticks[i], rY + Tick1Loc)
				Next
				For Local i:Int = 0 To Ticks.Length - 1
					ifsoGUI_VP.DrawImageArea(lImageTick[2], rX + Ticks[i], rY + Tick2Loc)
				Next
			End If
			If Direction = ifsoGUI_SLIDER_UP_RIGHT
				ifsoGUI_VP.DrawImageArea(dImage[0], rX + Ticks[CurrentTick] - ButtonOffSide, rY + 1)
			Else
				ifsoGUI_VP.DrawImageArea(dImage[2], rX + Ticks[CurrentTick] - ButtonOffSide, rY + 1)
			End If
			If ShowFocus And GUI.gActiveGadget = Self DrawFocus(rX - 1, rY, W + 1, H)
		End If
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not (Enabled And Visible) Return False
		If bPressed
			GUI.gMouseOverGadget = Self
			Return True
		End If
		MouseOverPart = 0
		If Vertical
			If (iMouseX >= parX + x) And (iMouseX <= parX + x + h) And (iMouseY >= parY + y) And (iMouseY <= parY + y + w)
				If (iMouseY >= parY + y + Ticks[CurrentTick] - ButtonOffSide) And (iMouseY <= parY + y + Ticks[CurrentTick] + ButtonOffSide)
					MouseOverPart = True 'Over the button
				EndIf
				GUI.gMouseOverGadget = Self
				Return True
			End If
		Else
			If (iMouseX >= parX + x) And (iMouseX <= parX + x + w) And (iMouseY >= parY + y) And (iMouseY <= parY + y + h)
				If (iMouseX >= parX + x + Ticks[CurrentTick] - ButtonOffSide) And (iMouseX <= parX + x + Ticks[CurrentTick] + ButtonOffSide)
					MouseOverPart = True 'Over the button
				EndIf
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
		If Not Enabled Return
		If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
			GUI.SetActiveGadget(Self)
			bPressed = True
			If MouseOverPart
				Dragging = True
				Local iX:Int, iY:Int
				GetAbsoluteXY(iX, iY)
				If Vertical
					DragSpot = iMouseY - (iY + Ticks[CurrentTick])
				Else
					DragSpot = iMouseX - (iX + Ticks[CurrentTick])
				End If
			Else
				Local iX:Int, iY:Int
				GetAbsoluteXY(iX, iY)
				If Vertical
					If iMouseY < iY + Ticks[CurrentTick] - HalfTickSpace
						SetValue(Value + Interval)
					ElseIf iMouseY > iY + Ticks[CurrentTick] + HalfTickSpace
						SetValue(Value - Interval)
					End If
				Else
					If iMouseX < iX + Ticks[CurrentTick] - HalfTickSpace
						SetValue(Value - Interval)
					ElseIf iMouseX > iX + Ticks[CurrentTick] + HalfTickSpace
						SetValue(Value + Interval)
					End If
				End If
				LastRepeat = MilliSecs()
				NextRepeat = GUI.MouseButtonDelay
			End If
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		bPressed = False
		MouseOverPart = False
		Dragging = False
		If Not Enabled Return
		If Not (GUI.gMouseOverGadget = Self) GUI.SetActiveGadget(Null)
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		If strSkin = ""
			bSkin = False
			lImageBar = gImageBar
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			lImageButton = gImageButton
			lImageButtonOver = gImageButtonOver
			lImageButtonDown = gImageButtonDown
			lImageTick = gImageTick
			h = lImageButton[0].height + 2
			BarH = lImageBar.h[0] + lImageBar.h[3] + lImageBar.h[6]
			ButtonOffSide = lImageButton[0].width / 2
			BarOffSet = (h - (BarH)) / 2
			Tick1Loc = BarOffSet - lImageTick[0].height
			Tick2Loc = BarOffSet + BarH
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("slider", strSkin).Split(",")
		Load9Image2("/graphics/sliderback.png", dimensions, lImageBar, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		lImageButton = New TImage[4]
		lImageButton[0] = LoadImage(GUI.FileHeader + strSkin + "/graphics/slider.png")
		lImageButton[1] = RotateImage(lImageButton[0])
		lImageButton[2] = RotateImage(lImageButton[1])
		lImageButton[3] = RotateImage(lImageButton[2])
		For Local i:Int = 0 To 3
			SetImageHandle(lImageButton[i], 0, 0)
		Next
		If GUI.FileExists(strSkin + "/graphics/sliderover.png")
			lImageButtonOver = New TImage[4]
			lImageButtonOver[0] = LoadImage(GUI.FileHeader + strSkin + "/graphics/sliderover.png")
			lImageButtonOver[1] = RotateImage(lImageButtonOver[0])
			lImageButtonOver[2] = RotateImage(lImageButtonOver[1])
			lImageButtonOver[3] = RotateImage(lImageButtonOver[2])
			For Local i:Int = 0 To 3
				SetImageHandle(lImageButtonOver[i], 0, 0)
			Next
		Else
			lImageButtonOver = lImageButton
		End If
		If GUI.FileExists(strSkin + "/graphics/sliderdown.png")
			lImageButtonDown = New TImage[4]
			lImageButtonDown[0] = LoadImage(GUI.FileHeader + strSkin + "/graphics/sliderdown.png")
			lImageButtonDown[1] = RotateImage(lImageButtonDown[0])
			lImageButtonDown[2] = RotateImage(lImageButtonDown[1])
			lImageButtonDown[3] = RotateImage(lImageButtonDown[2])
			For Local i:Int = 0 To 3
				SetImageHandle(lImageButtonDown[i], 0, 0)
			Next
		Else
			lImageButtonDown = lImageButton
		End If
		lImageTick = New TImage[4]
		lImageTick[0] = LoadImage(GUI.FileHeader + strSkin + "/graphics/slidertick.png")
		lImageTick[1] = RotateImage(lImageTick[0])
		lImageTick[2] = RotateImage(lImageTick[1])
		lImageTick[3] = RotateImage(lImageTick[2])
		For Local i:Int = 0 To 3
			SetImageHandle(lImageTick[i], 0, 0)
		Next
		h = lImageButton[0].height + 2
		BarH = lImageBar.h[0] + lImageBar.h[3] + lImageBar.h[6]
		ButtonOffSide = lImageButton[0].width / 2
		BarOffSet = (h - (BarH)) / 2
		Tick1Loc = BarOffSet - lImageTick[0].height
		Tick2Loc = BarOffSet + BarH
		Refresh()
	End Method
	Rem
	bbdoc: Called when the mouse leaves the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOut(iMouseX:Int, iMouseY:Int, gOverGadget:ifsoGUI_Base) 'Called when mouse no longer over gadget
		MouseOverPart = 0
		Super.MouseOut(iMouseX, iMouseY, gOverGadget)
	End Method
	Rem
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget only.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If bPressed
			If Dragging
				Local iX:Int, iY:Int
				GetAbsoluteXY(iX, iY)
				If Vertical
					Local i:Int
					For i = 0 To Ticks.Length - 2
						If iMouseY - DragSpot <= iY + Ticks[i] + HalfTickSpace
							SetValue(Values[i])
							Exit
						End If
					Next
					If i = Ticks.Length - 1 SetValue(Values[Ticks.Length - 1])
				Else
					Local i:Int
					For i = 0 To Ticks.Length - 2
						If iMouseX - DragSpot < iX + Ticks[i] + HalfTickSpace
							SetValue(Values[i])
							Exit
						End If
					Next
					If i = Ticks.Length - 1 SetValue(Values[Ticks.Length - 1])
				End If
			Else
				If MilliSecs() - LastRepeat > NextRepeat
					Local iX:Int, iY:Int
					GetAbsoluteXY(iX, iY)
					If Vertical
						If iMouseY < iY + Ticks[CurrentTick] - HalfTickSpace
							SetValue(Value + Interval)
						ElseIf iMouseY > iY + Ticks[CurrentTick] + HalfTickSpace
							SetValue(Value - Interval)
						End If
					Else
						If iMouseX < iX + Ticks[CurrentTick] - HalfTickSpace
							SetValue(Value - Interval)
						ElseIf iMouseX > iX + Ticks[CurrentTick] + HalfTickSpace
							SetValue(Value + Interval)
						End If
					End If
					LastRepeat = MilliSecs()
					NextRepeat = GUI.MouseButtonRepeat
				End If
			End If
		 Return ifsoGUI_MOUSE_DOWN
		End If
		If GUI.gMouseOverGadget = Self Return ifsoGUI_MOUSE_OVER
		Return ifsoGUI_MOUSE_NORMAL
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
	 If (key = ifsoGUI_KEY_UP) 'Cursor Up
			If Vertical SetValue(Value + Interval)
		Else If (key = ifsoGUI_KEY_DOWN) 'Cursor Down
			If Vertical SetValue(Value - Interval)
		Else If (key = ifsoGUI_KEY_LEFT) 'Left
			If Not Vertical SetValue(Value - Interval)
		Else If (key = ifsoGUI_KEY_RIGHT) 'Right
			If Not Vertical SetValue(Value + Interval)
		End If
	End Method
	Rem
		bbdoc: Refreshes the gadget.
		about: Recalculates any geometry/font changes, etc.
		Internal function should not be called by the user.
	End Rem
	Method Refresh()
		If lImageBar = gImageBar
			lTileSides = gTileSides
			lTileCenter = gTileCenter
		End If
		BarW = w - (ButtonOffSide * 2)
		Local numticks:Int
		If Interval > 0
			numticks = (MaxVal - MinVal) / Interval
		End If
		If numticks = 0 numticks = 1
		Ticks = Ticks[..numticks + 1]
		Values = Values[..numticks + 1]
		Local tickspacing:Float = Float(BarW - 1) / Float(numticks)
		HalfTickSpace = tickspacing / 2
		For Local i:Int = 0 To numticks
			If Vertical
				Ticks[i] = (i * tickspacing) + ButtonOffSide
				Values[i] = MinVal + ((numticks - i) * Interval)
			Else
				Ticks[i] = (i * tickspacing) + ButtonOffSide
				Values[i] = MinVal + (i * Interval)
			End If
		Next
		Local i:Int
		For i = 0 To Ticks.Length - 1
			If Value = Values[i]
				CurrentTick = i
				Exit
			End If
		Next
		If i > Ticks.Length - 1
			If Vertical
				CurrentTick = Ticks.Length - 1
			Else
				CurrentTick = 0
			End If
			Value = Values[CurrentTick]
		End If
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("slider").Split(",")
		Load9Image2("/graphics/sliderback.png", dimensions, gImageBar)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		gImageButton = New TImage[4]
		gImageButton[0] = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/slider.png")
		gImageButton[1] = RotateImage(gImageButton[0])
		gImageButton[2] = RotateImage(gImageButton[1])
		gImageButton[3] = RotateImage(gImageButton[2])
		For Local i:Int = 0 To 3
			SetImageHandle(gImageButton[i], 0, 0)
		Next
		If GUI.FileExists(GUI.ThemePath + "/graphics/sliderover.png")
			gImageButtonOver = New TImage[4]
			gImageButtonOver[0] = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/sliderover.png")
			gImageButtonOver[1] = RotateImage(gImageButtonOver[0])
			gImageButtonOver[2] = RotateImage(gImageButtonOver[1])
			gImageButtonOver[3] = RotateImage(gImageButtonOver[2])
			For Local i:Int = 0 To 3
				SetImageHandle(gImageButtonOver[i], 0, 0)
			Next
		Else
			gImageButtonOver = gImageButton
		End If
		If GUI.FileExists(GUI.ThemePath + "/Graphics/sliderdown.png")
			gImageButtonDown = New TImage[4]
			gImageButtonDown[0] = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/sliderdown.png")
			gImageButtonDown[1] = RotateImage(gImageButtonDown[0])
			gImageButtonDown[2] = RotateImage(gImageButtonDown[1])
			gImageButtonDown[3] = RotateImage(gImageButtonDown[2])
			For Local i:Int = 0 To 3
				SetImageHandle(gImageButtonDown[i], 0, 0)
			Next
		Else
			gImageButtonDown = gImageButton
		End If
		gImageTick = New TImage[4]
		gImageTick[0] = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/slidertick.png")
		gImageTick[1] = RotateImage(gImageTick[0])
		gImageTick[2] = RotateImage(gImageTick[1])
		gImageTick[3] = RotateImage(gImageTick[2])
		For Local i:Int = 0 To 3
			SetImageHandle(gImageTick[i], 0, 0)
		Next
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
	bbdoc: Sets the gadgets length.  Width when horizontal and height when vertical.
	The other parameter is then ignored.
	End Rem
	Method SetWH(intWidth:Int, intHeight:Int)
		If Vertical
			SetSize(intHeight)
		Else
			SetSize(intWidth)
		End If
		Refresh()
	End Method
	Rem
	bbdoc: Sets the gadgets length.  Width when horizontal and height when vertical.
	End Rem
	Method SetSize(intSize:Int)
		If intSize < lImageButton[0].width intSize = lImageButton[0].width
		w = intSize 'Entire width
		Refresh()
		If Parent Parent.ChildMoved(Self)
	End Method
	Rem
	bbdoc: Returns the gadgets length.  Width when horizontal and height when vertical.
	End Rem
	Method GetSize:Int()
		Return w
	End Method
	Rem
	bbdoc: Sets the current value.
	End Rem
	Method SetValue(iNewValue:Int)
		If iNewValue > MaxVal iNewValue = MaxVal
		If iNewValue < MinVal iNewValue = MinVal
		If iNewValue = Value Return
		For Local i:Int = 0 To Ticks.Length - 1
			If iNewValue = Values[i]
				CurrentTick = i
				Value = iNewValue
				SendEvent(ifsoGUI_EVENT_CHANGE, Value, - 1, - 1)
				Exit
			End If
		Next
	End Method
	Rem
	bbdoc: Returns the current value.
	End Rem
	Method GetValue:Int()
		Return Value
	End Method
	Rem
	bbdoc: Sets the minimum value of the gadget.
	End Rem
	Method SetMin(intMin:Int)
		If intMin >= MaxVal Return
		MinVal = intMin
		If Value < MinVal Value = MinVal
		SetInterval(Interval)
	End Method
	Rem
	bbdoc: Returns the minimum value of the gadget.
	End Rem
	Method GetMin:Int()
		Return MinVal
	End Method
	Rem
	bbdoc: Sets the maximum value of the gadget..
	End Rem
	Method SetMax(intMax:Int)
		If intMax < MinVal Return
		MaxVal = intMax
		If Value > MaxVal Value = MaxVal
		SetInterval(Interval)
	End Method
	Rem
	bbdoc: Returns the maximum value of the gadget.
	End Rem
	Method GetMax:Int()
		Return MaxVal
	End Method
	Rem
	bbdoc: Sets the minimum and maximum values of the gadget in one call.
	End Rem
	Method SetMinMax(intMin:Int, intMax:Int)
		If intMin >= intMax Return
		MinVal = intMin
		MaxVal = intMax
		If Value < MinVal Value = MinVal
		If Value > MaxVal Value = MaxVal
		SetInterval(Interval)
	End Method
	Rem
	bbdoc: Sets the amount the value changes per tick.
	End Rem
	Method SetInterval(intInterval:Int)
		If intInterval > MaxVal - MinVal intInterval = MaxVal - MinVal
		Interval = intInterval
		Refresh()
	End Method
	Rem
	bbdoc: Returns the amount the value changes per tick.
	End Rem
	Method GetInterval:Int()
		Return Interval
	End Method
	Rem
	bbdoc: Returns whether or not the gadget is vertical.
	End Rem
	Method GetVertical:Int()
		Return Vertical
	End Method
	Rem
	bbdoc: Sets the x, y, width, and height all in one call.
	End Rem
	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		x = iX
		y = iY
		SetWH(iW, iH)
		Refresh()
		If Parent Parent.ChildMoved(Self)
	End Method
	Rem
	bbdoc: Sets the direction the graphic is facing.
	about: ifsoGUI_SLIDER_UP_RIGHT or ifsoGUI_SLIDER_DOWN_LEFT
	End Rem
	Method SetDirection(intDirection:Int)
		Direction = intDirection
	End Method
	Rem
	bbdoc: Returns the direction the graphic is facing.
	about: ifsoGUI_SLIDER_UP_RIGHT or ifsoGUI_SLIDER_DOWN_LEFT
	End Rem
	Method GetDirection:Int()
		Return Direction
	End Method
	Rem
	bbdoc: Sets whether or not the tick marks are shown.
	End Rem
	Method SetShowTicks(intShowTicks:Int)
		ShowTicks = intShowTicks
	End Method
	Rem
	bbdoc: Returns whether or not the tick marks are shown.
	End Rem
	Method GetShowTicks:Int()
			Return ShowTicks
	End Method
End Type
