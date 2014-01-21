SuperStrict

Rem
	bbdoc: ifsoGUI Spinner
	about: Spinner Gadget
EndRem
Module ifsogui.spinner

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI

GUI.Register(ifsoGUI_Spinner.SystemEvent)

Rem
	bbdoc: Spinner Type
End Rem
Type ifsoGUI_Spinner Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button down
	Global gImageOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button over
	Global gImageArrow:TImage[4] 'Images for the arrow 0-Up 1-Right 2-Down 3-Left
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image 'Images to draw the button
	Field lImageDown:ifsoGUI_Image 'Images to draw the button down
	Field lImageOver:ifsoGUI_Image 'Images to draw the button over
	Field lImageArrow:TImage[4] 'Images for the arrow 0-Up 1-Right 2-Down 3-Left
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	Field MouseOverPart:Int ' 1 = top, Right -1 = bottom, Left
	Field Vertical:Int = 1
	Field LastRepeat:Int 'For repeat delay.
	Field NextRepeat:Int 'To Delay the first time
	Field RepeatDelay:Int = 400 'How long to delay when holding down the mousebutton
	
	'Events
	'Mouse Enter/Mouse Exit/Click
		
	Rem
		bbdoc: Create and returns a spinner gadget.
	End Rem
	Function Create:ifsoGUI_Spinner(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, bVertical:Int = True)
		Local p:ifsoGUI_Spinner = New ifsoGUI_Spinner
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lImageDown = gImageDown
		p.lImageOver = gImageOver
		p.lImageArrow = gImageArrow
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
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
		'Select the correct image
		Local dImage:ifsoGUI_Image
		If bPressed = -1
			dImage = lImageDown
		ElseIf GUI.gMouseOverGadget = Self And MouseOverPart = -1
			dImage = lImageOver
		Else
			dImage = lImage
		End If
		If Vertical
			DrawBox2(dImage, rX, rY + (h / 2), w, h / 2, True, lTileSides, lTileCenter)
		Else
			DrawBox2(dImage, rX, rY, w / 2, h, True, lTileSides, lTileCenter)
		End If
		If bPressed = 1
			dImage = lImageDown
		ElseIf GUI.gMouseOverGadget = Self And MouseOverPart = 1
			dImage = lImageOver
		Else
			dImage = lImage
		End If
		If Vertical
			DrawBox2(dImage, rX, rY, w, h / 2)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[0], rX, rY, W, H / 2)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[2], rX, rY + H / 2, W, H / 2)
		Else
			DrawBox2(dImage, rX + (W / 2), rY, W / 2, H)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[3], rX, rY, W / 2, H)
			ifsoGUI_VP.DrawImageAreaRect(lImageArrow[1], rX + W / 2, rY, W / 2, H)
		End If
		If HasFocus And ShowFocus DrawFocus(rX + BorderLeft + 1, rY + BorderTop + 1, w - (BorderLeft + BorderRight + 3), h - (BorderTop + BorderBottom + 3))
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not Visible Return False
		If (iMouseX > parX + x) And (iMouseX < parX + x + w) And (iMouseY > parY + y) And (iMouseY < parY + y + h)
			Local chkX:Int = x, chkY:Int = y
			If chkX < 0 chkX = 0
			If chkY < 0 chkY = 0
			Local chkW:Int = w, chkH:Int = h 'Check if the width is off the parent
			If x + w > parW chkW = parW - x
			If y + h > parH chkH = parH - y
			For Local c:ifsoGUI_Base = EachIn Children
				If c.IsMouseOver(parX + chkX, parY + chkY, chkW, chkH, iMouseX, iMouseY) Return True
			Next
			If Vertical
				If iMouseY > parY + y + (H / 2)
					MouseOverPart = -1
				Else
					MouseOverPart = 1
				End If
			Else
				If iMouseX > parX + x + (W / 2)
					MouseOverPart = 1
				Else
					MouseOverPart = -1
				End If
			End If
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
			LastRepeat = MilliSecs()
			NextRepeat = RepeatDelay
			SendEvent(ifsoGUI_EVENT_CLICK, bPressed, iMouseX, iMouseY)
		Else
			GUI.SetActiveGadget(Null)
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If Not bPressed Return
		bPressed = 0
		If Not (Enabled And Visible) Return
		If Not (GUI.gMouseOverGadget = Self) GUI.SetActiveGadget(Null)
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
			If Vertical SendEvent(ifsoGUI_EVENT_CLICK, 1, - 1, - 1)
		Else If (key = ifsoGUI_KEY_DOWN) 'Cursor Down
			If Vertical SendEvent(ifsoGUI_EVENT_CLICK, - 1, - 1, - 1)
		Else If (key = ifsoGUI_KEY_LEFT) 'Left
			If Not Vertical SendEvent(ifsoGUI_EVENT_CLICK, - 1, - 1, - 1)
		Else If (key = ifsoGUI_KEY_RIGHT) 'Right
			If Not Vertical SendEvent(ifsoGUI_EVENT_CLICK, 1, - 1, - 1)
		End If
	End Method
	Rem
	bbdoc: Returns the delay when holding the mouse button down in millisecs
	End Rem
	Method GetRepeatDelay:Int()
	 Return RepeatDelay
	End Method
	Rem
	bbdoc: Sets the delay when holding the mouse button down in millisecs
	End Rem
	Method SetRepeatDelay(iDelay:Int)
	 RepeatDelay = iDelay
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lImageDown = gImageDown
			lImageOver = gImageOver
			lImageArrow = gImageArrow
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("spinner", strSkin).Split(",")
		Load9Image2("/graphics/spinner.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		If GUI.FileExists(strSkin + "/graphics/spinnerover.png")
			Load9Image2("/graphics/spinnerover.png", dimensions, lImageOver, strSkin)
		Else
			lImageOver = lImage
		End If
		If GUI.FileExists(strSkin + "/graphics/spinnerdown.png")
			Load9Image2("/graphics/spinnerdown.png", dimensions, lImageDown, strSkin)
		Else
			lImageDown = lImage
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
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget only.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If bPressed
			If MilliSecs() - LastRepeat > NextRepeat
				SendEvent(ifsoGUI_EVENT_CLICK, bPressed, iMouseX, iMouseY)
				LastRepeat = MilliSecs()
				NextRepeat = RepeatDelay
			End If
		 Return ifsoGUI_MOUSE_DOWN
		End If
		If GUI.gMouseOverGadget = Self Return ifsoGUI_MOUSE_OVER
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
		BorderTop = lImage.h[1]
		BorderBottom = lImage.h[7]
		BorderLeft = lImage.w[3]
		BorderRight = lImage.w[5]
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("spinner").Split(",")
		Load9Image2("/graphics/spinner.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/spinnerover.png")
			Load9Image2("/graphics/spinnerover.png", dimensions, gImageOver)
		Else
			gImageOver = gImage
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/spinnerdown.png")
			Load9Image2("/graphics/spinnerdown.png", dimensions, gImageDown)
		Else
			gImageDown = gImage
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
	
	'User Functions/Properties
	
	End Type
