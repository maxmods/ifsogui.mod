SuperStrict

Rem
	bbdoc: ifsoGUI Button
	about: Button Gadget
EndRem
Module ifsogui.button

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI

GUI.Register(ifsoGUI_Button.SystemEvent)

Rem
	bbdoc: Button Type
End Rem
Type ifsoGUI_Button Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button down
	Global gImageOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button over
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image 'Images to draw the button
	Field lImageDown:ifsoGUI_Image 'Images to draw the button down
	Field lImageOver:ifsoGUI_Image 'Images to draw the button over
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched

	Field Label:String 'Label on the button

	'Events
	'Mouse Enter/Mouse Exit/Click
	
	Rem
		bbdoc: Create and returns a button gadget.
	End Rem
	Function Create:ifsoGUI_Button(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, strLabel:String)
		Local p:ifsoGUI_Button = New ifsoGUI_Button
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
		bbdoc: Draws the button gadget.
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
		DrawBox2(dImage, rX, rY, w, h, True, lTileSides, lTileCenter)
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		If fFont SetImageFont(fFont)
		Local tw:Int = ifsoGUI_VP.GetTextWidth(Label, Self)
		Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
		ifsoGUI_VP.Add(rX, rY, w, h)
		ifsoGUI_VP.DrawTextArea(Label, ((w - tw) / 2) + rX, ((h - th) / 2) + rY, Self)
		If GUI.gActiveGadget = Self And ShowFocus DrawFocus(((w - tw) / 2) + rX - 1, ((h - th) / 2) + rY - 1, tw + 2, th + 2)
		ifsoGUI_VP.Pop()
		If fFont SetImageFont(GUI.DefaultFont)
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
		End If
		SendEvent(ifsoGUI_EVENT_MOUSE_DOWN, iButton, iMouseX, iMouseY)
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		bPressed = False
		If Not (Enabled And Visible) Return
		If GUI.gMouseOverGadget = Self
			SendEvent(ifsoGUI_EVENT_MOUSE_UP, iButton, iMouseX, iMouseY)
		 If iButton = ifsoGUI_LEFT_MOUSE_BUTTON
				SendEvent(ifsoGUI_EVENT_CLICK, iButton, iMouseX, iMouseY)
			End If
		Else
			GUI.SetActiveGadget(Null)
		End If
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
	 If key = 13 Or Key = 32 'Carriage Return or Space
			SendEvent(ifsoGUI_EVENT_CLICK, 0, - 1, - 1)
		End If
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
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("button", strSkin).Split(",")
		Load9Image2("/graphics/button.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		If GUI.FileExists(strSkin + "/graphics/buttonover.png")
			Load9Image2("/graphics/buttonover.png", dimensions, lImageOver, strSkin)
		Else
			lImageOver = lImage
		End If
		If GUI.FileExists(strSkin + "/graphics/buttondown.png")
			Load9Image2("/graphics/buttondown.png", dimensions, lImageDown, strSkin)
		Else
			lImageDown = lImage
		End If
		Refresh()
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
		Local minw:Int, minh:Int
		minw:+BorderLeft + BorderRight + 2
		minh:+BorderTop + BorderBottom + 2
		If AutoSize
			Local saveFont:TImageFont = GetImageFont()
			If fFont
				SetImageFont(fFont)
			Else
				SetImageFont(GUI.DefaultFont)
			End If
			'Set the width to the text width + minw
			w = minw + ifsoGUI_VP.GetTextWidth(Label, Self)
			'Set the height to text height plus minh
			h = minh + ifsoGUI_VP.GetTextHeight(Self)
			SetImageFont(saveFont)
		Else
			If w < minw w = minw
			If h < minh h = minh
		End If
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("button").Split(",")
		Load9Image2("/graphics/button.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/buttonover.png")
			Load9Image2("/graphics/buttonover.png", dimensions, gImageOver)
		Else
			gImageOver = gImage
		End If
		If GUI.FileExists(GUI.ThemePath + "/graphics/buttondown.png")
			Load9Image2("/graphics/buttondown.png", dimensions, gImageDown)
		Else
			gImageDown = gImage
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
	bbdoc: Sets the buttons label.
	End Rem
	Method SetLabel(strLabel:String)
		Label = strLabel
		Refresh()
	End Method
	Rem
	bbdoc: Returns the buttons label.
	End Rem
	Method GetLabel:String()
		Return Label
	End Method

	End Type
