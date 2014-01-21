SuperStrict

Rem
	bbdoc: ifsoGUI Scrollbar
	about: Scrollbar Gadget
EndRem
Module ifsogui.scrollbar

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI

GUI.Register(ifsoGUI_ScrollBar.SystemEvent)

Const ifsoGUI_SCROLLBAR_ON:Int = 1
Const ifsoGUI_SCROLLBAR_OFF:Int = 0
Const ifsoGUI_SCROLLBAR_AUTO:Int = 2

Rem
	bbdoc: Scrollbar Type
End Rem
Type ifsoGUI_ScrollBar Extends ifsoGUI_Base
	Global gImageBar:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the bar
	Global gImageBarDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the bar down
	Global gImageBarOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the bar mouse over
	Global gTileBarSides:Int, gTileBarCenter:Int 'Should the graphics be tiled or stretched
	Global gImageButton:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the buttons
	Global gImageButtonDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the buttons down
	Global gImageButtonOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the buttons mouse over
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Global gImageBack:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the background
	Global gTileBackSides:Int, gTileBackCenter:Int 'Should the graphics be tiled or stretched
	Global gImageArrow:TImage[4] 'Images to draw the arrows on the buttons
	Field lImageBar:ifsoGUI_Image 'Images to draw the bar
	Field lImageBarDown:ifsoGUI_Image 'Images to draw the bar down
	Field lImageBarOver:ifsoGUI_Image 'Images to draw the bar mouse over
	Field lTileBarSides:Int, lTileBarCenter:Int 'Should the graphics be tiled or stretched
	Field lImageButton:ifsoGUI_Image 'Images to draw the buttons
	Field lImageButtonDown:ifsoGUI_Image 'Images to draw the buttons down
	Field lImageButtonOver:ifsoGUI_Image 'Images to draw the buttons mouse over
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImageBack:ifsoGUI_Image 'Images to draw the background
	Field lTileBackSides:Int, lTileBackCenter:Int 'Should the graphics be tiled or stretched
	Field lImageArrow:TImage[4] 'Images to draw the arrows on the buttons
	
	Field Interval:Int = 1 'Amount changed when pressing the buttons
	Field MinVal:Int = 0, MaxVal:Int = 100, Value:Int 'Values of the control
	Field Size:Int = 10 'Value size of the bar, amount moved when clicking background
	Field Vertical:Int	'Is the bar veretical or horizontal
	Field LastRepeat:Int 'For repeat delay.
	Field NextRepeat:Int 'To Delay the first time
	Field BarSize:Int 'Size of the bar
	Field BarPos:Int 'Position of the bar
	Field MouseOverPart:Int '1=Decrease button, 2=Increase Button, 3=Bar, 4=Dec Bar, 5=Inc Bar
'Variables for Dragging the scrollbar 
	Field DragSpot:Int 'offset from top of button to mouse
	
	'Events
	'Mouse Enter/Mouse Exit/Click
	
	Rem
		bbdoc: Create and returns a scrollbar gadget.
	End Rem
	Function Create:ifsoGUI_ScrollBar(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, bVertical:Int = True)
		Local p:ifsoGUI_ScrollBar = New ifsoGUI_ScrollBar
		p.x = iX
		p.y = iY
		p.lImageBar = gImageBar
		p.lImageBarDown = gImageBarDown
		p.lImageBarOver = gImageBarOver
		p.lTileBarSides = gTileSides
		p.lTileBarCenter = gTileBarCenter
		p.lImageButton = gImageButton
		p.lImageButtonDown = gImageButtonDown
		p.lImageButtonOver = gIMageButtonOver
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.lImageBack = gImageBack
		p.lTileBackSides = gTileSides
		p.lTileBackCenter = gTileBackCenter
		p.lImageArrow = gImageArrow
		p.Vertical = bVertical
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
		SetColor(Color[0], Color[1], Color[2])
		SetAlpha(fAlpha)
		'set up rendering locations
		Local rX:Int = parX + x
		Local rY:Int = parY + y
		'Select correct images
		Local barimage:ifsoGUI_Image, btnimage1:ifsoGUI_Image, btnimage2:ifsoGUI_Image
		If bPressed = 3 'Dragging
			barimage = lImageBarDown
			btnimage1 = lImageButtonOver
			btnimage2 = lImageButtonOver
		ElseIf bPressed = 1 'Dec Button
			barimage = lImageBarOver
			btnimage1 = lImageButtonDown
			btnimage2 = lImageButtonOver
		ElseIf bPressed = 2 'Inc Button
			barimage = lImageBarOver
			btnimage1 = lImageButtonOver
			btnimage2 = lImageButtonDown
		ElseIf GUI.gMouseOverGadget = Self
			barimage = lImageBarOver
			btnimage1 = lImageButtonOver
			btnimage2 = lImageButtonOver
		Else
			barimage = lImageBar
			btnimage1 = lImageButton
			btnimage2 = lImageButton
		End If
		If Vertical
			'Draw the back
			DrawBox2(lImageBack, rX, rY, w, h, True, lTileBackSides, lTileBackCenter)
			DrawBox2(btnimage1, rX, rY, w, w, True, lTileSides, lTileCenter)
			DrawBox2(btnimage2, rX, rY + h - w, w, w, True, lTileSides, lTileCenter)
			DrawBox2(barimage, rX, rY + w + BarPos, w, BarSize, True, lTileBarSides, lTileBarCenter)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[0], rX, rY, W, W)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[2], rX, rY + H - W, W, W)
		Else
			DrawBox2(lImageBack, rX, rY, w, h, True, lTileBackSides, lTileBackCenter)
			DrawBox2(btnimage1, rX, rY, h, h, True, lTileSides, lTileCenter)
			DrawBox2(btnimage2, rX + w - h, rY, h, h, True, lTileSides, lTileCenter)
			DrawBox2(barimage, rX + h + BarPos, rY, BarSize, h, True, lTileBarSides, lTileBarCenter)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[3], rX, rY, H, H)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[1], rX + W - H, rY, H, H)
		End If
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not (Enabled And Visible) Return False
		If bPressed = 3
			GUI.gMouseOverGadget = Self
			Return True
		End If
		MouseOverPart = 0
		If Vertical And (iMouseX >= parX + x) And (iMouseX <= parX + x + w)
			If (iMouseY > parY + y) And (iMouseY <= parY + y + w) 'Over Dec button
				MouseOverPart = 1
			ElseIf (iMouseY >= parY + y + h - w) And (iMouseY <= parY + y + h + 1) 'Over Inc Button
				MouseOverPart = 2
			ElseIf (iMouseY >= parY + y + w + BarPos) And (iMouseY <= parY + y + w + BarPos + BarSize)
				'Bar
				MouseOverPart = 3
			ElseIf (iMouseY > parY + y + w) And (iMouseY < parY + y + w + BarPos)
				'Dec Bar
				MouseOverPart = 4
			ElseIf (iMouseY > parY + y + BarPos + BarSize) And (iMouseY < parY + y + h - w)
				'Inc Bar
				MouseOverPart = 5
			End If
		ElseIf (Not Vertical) And (iMouseY > parY + y) And (iMouseY < parY + y + h) 'Horizontal
			If (iMouseX > parX + x) And (iMouseX < parX + x + h) 'Over Dec button
				MouseOverPart = 1
			ElseIf (iMouseX > parX + x + w - (h + 1)) And (iMouseX < parX + x + w) 'Over Inc Button
				MouseOverPart = 2
			ElseIf (iMouseX >= parX + x + h + BarPos) And (iMouseX <= parX + x + h + BarPos + BarSize)
				'Over the Bar
				MouseOverPart = 3
			ElseIf (iMouseX > parX + x + h - 1) And (iMouseX < parX + x + h + BarPos)
				'Dec Bar
				MouseOverPart = 4
			ElseIf (iMouseX > parX + x + BarPos + BarSize) And (iMouseX < parX + x + w - h)
				'Inc Bar
				MouseOverPart = 5
			End If
		End If
		If MouseOverPart
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
		If Not Enabled Return
		If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
			GUI.SetActiveGadget(Self)
			bPressed = MouseOverPart
			Select bPressed
				Case 1
					SetValue(Value - Interval)
				Case 2
					SetValue(Value + Interval)
				Case 3
					Local iX:Int, iY:Int
					GetAbsoluteXY(iX, iY)
					If Vertical
						DragSpot = iMouseY - (iY + w + BarPos)
					Else
						DragSpot = iMouseX - (iX + h + BarPos)
					End If
				Case 4
					SetValue(Value - Size)
				Case 5
					SetValue(Value + Size)
			End Select
			LastRepeat = MilliSecs()
			NextRepeat = GUI.MouseButtonDelay
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		bPressed = 0
	End Method
	Rem
	bbdoc: Load a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		If strSkin = ""
			bSkin = False
			lImageBar = gImageBar
			lImageBarDown = gImageBarDown
			lImageBarOver = gImageBarOver
			lTileBarSides = gTileSides
			lTileBarCenter = gTileBarCenter
			lImageButton = gImageButton
			lImageButtonDown = gImageButtonDown
			lImageButtonOver = gIMageButtonOver
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			lImageBack = gImageBack
			lTileBackSides = gTileSides
			lTileBackCenter = gTileBackCenter
			lImageArrow = gImageArrow
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("scrollbar", strSkin).Split(",")
		Load9Image2("/graphics/scrollbar.png", dimensions, lImageBar, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileBarSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileBarCenter = True
		End If
		If GUI.FileExists(strSkin + "/graphics/scrollbarover.png")
			Load9Image2("/graphics/scrollbarover.png", dimensions, lImageBarOver, strSkin)
		Else
			lImageBarOver = lImageBar
		End If
		If GUI.FileExists(strSkin + "/graphics/scrollbardown.png")
			Load9Image2("/graphics/scrollbardown.png", dimensions, lImageBarDown, strSkin)
		Else
			lImageBarDown = lImageBar
		End If
		dimensions = GetDimensions("scrollbar button", strSkin).Split(",")
		Load9Image2("/graphics/scrollbutton.png", dimensions, lImageButton, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		If GUI.FileExists(strSkin + "/graphics/scrollbuttonover.png")
			Load9Image2("/graphics/scrollbuttonover.png", dimensions, lImageButtonOver, strSkin)
		Else
			lImageButtonOver = lImageButton
		End If
		If GUI.FileExists(strSkin + "/graphics/scrollbuttondown.png")
			Load9Image2("/graphics/scrollbuttondown.png", dimensions, lImageButtonDown, strSkin)
		Else
			lImageButtonDown = lImageButton
		End If
		dimensions = GetDimensions("scrollbar background", strSkin).Split(",")
		Load9Image2("/graphics/scrollback.png", dimensions, lImageBack, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileBackSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileBackCenter = True
		End If
		lImageArrow = New TImage[4]
		lImageArrow[1] = LoadImage(GUI.FileHeader + strSkin + "/graphics/arrow.png")
		lImageArrow[2] = RotateImage(lImageArrow[1])
		lImageArrow[3] = RotateImage(lImageArrow[2])
		lImageArrow[0] = RotateImage(lImageArrow[3])
		For Local i:Int = 0 To 3
			SetImageHandle(lImageArrow[i], 0, 0)
		Next
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
			If bPressed = 3
				Local iX:Int, iY:Int, fNewValue:Float
				GetAbsoluteXY(iX, iY)
				If Vertical
					If iMouseY < iY + w + DragSpot ' too high
						BarPos = 0
						fNewValue = 0
					ElseIf iMouseY > iY + h - (w + (BarSize - DragSpot)) 'Too low
						BarPos = h - (2 * w + BarSize)
						fNewValue = MaxVal - Size
					Else 'Over the bar
						If BarPos = iMouseY - (iY + w + DragSpot)
							fNewValue = Value
						Else
							BarPos = iMouseY - (iY + w + DragSpot)
							fNewValue = BarPos / (Float(h) - (2.0 * Float(w) + BarSize - 1.0))
							fNewValue = fNewValue * ((MaxVal - Size) - MinVal) + MinVal
						End If
					End If
				Else
					If iMouseX < iX + h + DragSpot ' too high
						BarPos = 0
						fNewValue = 0
					ElseIf iMouseX > iX + w - (h + (BarSize - DragSpot)) 'Too low
						BarPos = w - (2 * h + BarSize)
						fNewValue = MaxVal - Size
					Else 'Over the bar
						If BarPos = iMouseX - (iX + h + DragSpot)
							fNewValue = Value
						Else
							BarPos = iMouseX - (iX + h + DragSpot)
							fNewValue = BarPos / (Float(w) - (2.0 * Float(h) + BarSize - 1.0))
							fNewValue = fNewValue * ((MaxVal - Size) - MinVal) + MinVal
						End If
					End If
				End If
				SetValue(Int(fNewValue))
			Else
				If MilliSecs() - LastRepeat > NextRepeat
					Select bPressed
						Case 1 'Dec Btn
							SetValue(Value - Interval)
						Case 2 'Inc Btn
							SetValue(Value + Interval)
						Case 4 'Dec Back
							Local iX:Int, iY:Int
							GetAbsoluteXY(iX, iY)
							If Vertical And iMouseX >= iX And iMouseX <= iX + w
								If (iMouseY < iY + w + BarPos) SetValue(Value - Size)
							ElseIf Not Vertical And iMouseY >= iY And iMouseY <= iY + h
								If (iMouseX < iX + h + BarPos) SetValue(Value - Size)
							End If
						Case 5 'Inc Back
							Local iX:Int, iY:Int
							GetAbsoluteXY(iX, iY)
							If Vertical And iMouseX >= iX And iMouseX <= iX + w
								If (iMouseY > iY + w + BarPos + BarSize) SetValue(Value + Size)
							ElseIf Not Vertical And iMouseY >= iY And iMouseY <= iY + h
								If (iMouseX > iX + h + BarPos + BarSize) SetValue(Value + Size)
							End If
					End Select
					LastRepeat = MilliSecs()
					NextRepeat = GUI.MouseButtonRepeat
				End If
			End If
		 Return ifsoGUI_MOUSE_DOWN
		End if
		If GUI.gMouseOverGadget = Self Return ifsoGUI_MOUSE_OVER
		Return ifsoGUI_MOUSE_NORMAL
	End Method
	Rem
	bbdoc: Can this gadget be active.
	about: Internal function should not be called by the user.
	End Rem
	Method CanActive:Int()
		Return False
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
		If Master
			Master.KeyPress(key)
			Return
		End If
	 If (key = ifsoGUI_KEY_UP) 'Cursor Up
			SetValue(Value - Interval)
		Else If (key = ifsoGUI_KEY_DOWN) 'Cursor Down
			SetValue(Value + Interval)
		Else If (key = ifsoGUI_KEY_HOME) 'Home
			SetValue(MinVal)
		Else If (key = ifsoGUI_KEY_END) 'End
			SetValue(MaxVal - Size)
		Else If (key = ifsoGUI_KEY_PAGEUP) 'PageUp
			SetValue(Value - Size)
		Else If (key = ifsoGUI_KEY_PAGEDOWN) 'PageDown
			SetValue(Value + Size)
		ElseIf (key = ifsoGUI_MOUSE_WHEEL_UP) 'Mouse Wheel Up
			SetValue(Value - Interval)
		ElseIf (key = ifsoGUI_MOUSE_WHEEL_DOWN) 'Mouse Wheel Up
			SetValue(Value + Interval)
		End If
	End Method
	Rem
		bbdoc: Refreshes the gadget.
		about: Recalculates any geometry/font changes, etc.
		Internal function should not be called by the user.
	End Rem
	Method Refresh() 'Refresh the size/pos/value of the bar
		If lImageBar = gImageBar
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			lTileBarSides = gTileBarSides
			lTileBarCenter = gTileBarCenter
			lTileBackSides = gTileBackSides
			lTileBackCenter = gTileBackCenter
		End If
		'Set the Bar Size
		Local pix:Int ' Number of pixels in the bar area
		If Vertical
			pix = h - (w * 2)
		Else
			pix = w - (h * 2)
		End If
		BarSize = Float(pix) * Float(Size) / Float(MaxVal - MinVal)
		If BarSize > pix BarSize = pix 'Bar cannot be larger than the bar area
		If Vertical 'Check minimum bar size
			If BarSize < lImageBar.h[0] + lImageBar.h[6] + 2 BarSize = lImageBar.h[0] + lImageBar.h[6] + 2
		Else
		 If BarSize < lImageBar.w[0] + lImageBar.w[2] + 2 BarSize = lImageBar.w[0] + lImageBar.w[2] + 2
		End If
		'Set the Bar Position
		CalcBarPos()
	End Method
	Rem
		bbdoc: Calculates the position of the progressbar.
		about: Internal function should not be called by the user.
	End Rem
	Method CalcBarPos()
		'Check the Value
		If Value > MaxVal - Size Value = MaxVal - Size
		If Value < MinVal Value = MinVal
		Local pix:Int
		'amount of space not taken up by the Bar
		If Vertical
			pix = h - (w * 2 + BarSize)
		Else
			pix = w - (h * 2 + BarSize)
		End If
		If MaxVal = MinVal + Size
			BarPos = 0
		Else
			Local perpix:Float = Float(pix) / Float(MaxVal - (MinVal + Size))
			BarPos = Ceil(Float(Value - MinVal) * perpix)
			If BarPos > pix BarPos = pix
		End If
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("scrollbar").Split(",")
		Load9Image2("/graphics/scrollbar.png", dimensions, gImageBar)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileBarSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileBarCenter = True
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/scrollbarover.png")
			Load9Image2("/graphics/scrollbarover.png", dimensions, gImageBarOver)
		Else
			gImageBarOver = gImageBar
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/scrollbardown.png")
			Load9Image2("/graphics/scrollbardown.png", dimensions, gImageBarDown)
		Else
			gImageBarDown = gImageBar
		End If
		dimensions = GetDimensions("scrollbar button").Split(",")
		Load9Image2("/graphics/scrollbutton.png", dimensions, gImageButton)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/scrollbuttonover.png")
			Load9Image2("/graphics/scrollbuttonover.png", dimensions, gImageButtonOver)
		Else
			gImageButtonOver = gImageButton
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/scrollbuttondown.png")
			Load9Image2("/graphics/scrollbuttondown.png", dimensions, gImageButtonDown)
		Else
			gImageButtonDown = gImageButton
		End If
		dimensions = GetDimensions("scrollbar background").Split(",")
		Load9Image2("/graphics/scrollback.png", dimensions, gImageBack)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileBackSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileBackCenter = True
		End If
		gImageArrow = New TImage[4]
		gImageArrow[1] = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/arrow.png")
		gImageArrow[2] = RotateImage(gImageArrow[1])
		gImageArrow[3] = RotateImage(gImageArrow[2])
		gImageArrow[0] = RotateImage(gImageArrow[3])
		For Local i:Int = 0 To 3
			SetImageHandle(gImageArrow[i], 0, 0)
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
	
	Rem
	bbdoc: Sets the gadgets TabOrder. 0=Do not tab to this gadget -1=Last in the Tab Order
	End Rem
	Method SetTabOrder(iTabOrder:Int)
		TabOrder = 0
	End Method
	'User Functions/Properties
	Rem
	bbdoc: Sets the value of the gadget.
	End Rem
	Method SetValue(iNewValue:Int)
		If iNewValue > MaxVal - Size iNewValue = MaxVal - Size
		If iNewValue < MinVal iNewValue = MinVal
		If iNewValue <> Value
			Value = iNewValue
		 SendEvent(ifsoGUI_EVENT_CHANGE, Value, -1, -1)
		End If
		Refresh()
	End Method
	Rem
	bbdoc: Returns the value of the gadget.
	End Rem
	Method GetValue:Int()
		Return Value
	End Method
	Rem
	bbdoc: Sets the minimum value of the gadget.
	End Rem
	Method SetMin(iMin:Int)
		If iMin >= MaxVal Return
		MinVal = iMin
		SetValue(Value)
	End Method
	Rem
	bbdoc: Returns the minimum value of the gadget.
	End Rem
	Method GetMin:Int()
		Return MinVal
	End Method
	Rem
	bbdoc: Returns the minimum length of the gadget to be drawn correctly.
	End Rem
	Method GetMinLength:Int()
		If Vertical
			Return w * 2 + gImageButton.h[1] + gImageButton.h[4] + gImageButton.h[7]
		Else
			Return h * 2 + gImageButton.w[3] + gImageButton.w[4] + gImageButton.w[5]
		EndIf
	End Method
	Rem
	bbdoc: Sets the maximum value of the gadget..
	End Rem
	Method SetMax(iMax:Int)
		If iMax <= MinVal Return
		MaxVal = iMax
		SetValue(Value)
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
		SetValue(Value)
	End Method
	Rem
	bbdoc: Sets the interval the value changes when the arrow buttons are pressed.
	End Rem
	Method SetInterval(iInterval:Int)
		Interval = iInterval
	End Method
	Rem
	bbdoc: Returns the interval value.
	End Rem
	Method GetInterval:Int()
		Return Interval
	End Method
	Rem
	bbdoc: Sets the amount the value changes when the bar area is clicked.
	End Rem
	Method SetBarInterval(iBarInterval:Int)
		Size = iBarInterval
		If Size > (MaxVal - MinVal) Size = (MaxVal - MinVal)
		Refresh()
	End Method
	Rem
	bbdoc: Returns the change in value when the bar area is clicked.
	End Rem
	Method GetBarInterval:Int()
		Return Size
	End Method
	Rem
	bbdoc: Returns whether the gadget is vertical or not.
	End Rem
	Method GetVertical:Int()
		Return Vertical
	End Method
End Type
