SuperStrict

Rem
	bbdoc: ifsoGUI Image Button
	about: Image Button Gadget
EndRem
Module ifsogui.imagebutton

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.button

GUI.Register(ifsoGUI_ImageButton.SystemEvent)

Rem
	bbdoc: Button Type
End Rem
Type ifsoGUI_ImageButton Extends ifsoGUI_Button
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button
	Global gImageDown:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button down
	Global gImageOver:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the button over
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
		Field imgImages:TImage[3] 'images to show on the button
		Field ShowButton:Int 'whether to show the button under the image
		Field ShowLabel:Int 'Show the Label under the image

	'Events
	'Mouse Enter/Mouse Exit/Click
	
	Rem
		bbdoc: Create and returns a button gadget.
	End Rem
	Function Create:ifsoGUI_ImageButton(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, strLabel:String)
		Local p:ifsoGUI_ImageButton = New ifsoGUI_ImageButton
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
		ifsoGUI_VP.Add(rX, rY, w, h)
		If ShowButton
			Local dImage:ifsoGUI_Image
			If bPressed
				dImage = lImageDown
			ElseIf GUI.gMouseOverGadget = Self
				dImage = lImageOver
			Else
				dImage = lImage
			End If
			DrawBox2(dImage, rX, rY, w, h, True, lTileSides, lTileCenter)
		End If
		Local eImage:TImage
		If bPressed
			eImage = imgImages[ifsoGUI_MOUSE_DOWN]
		ElseIf GUI.gMouseOverGadget = Self
			eImage = imgImages[ifsoGUI_MOUSE_OVER]
		Else
			eImage = imgImages[ifsoGUI_MOUSE_NORMAL]
		End If
		Local iX:Int, iY:Int
		Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
		If eImage
			iX = (W - eImage.width) / 2
			If ShowLabel
				iY = (H - eImage.Height - th) / 2 - 1
			Else
				iY = (H - eImage.Height) / 2
			End If
			SetColor(255, 255, 255)
			ifsoGUI_VP.DrawImageArea(eImage, rX + iX, rY + iY)
		End If
		If ShowLabel
			SetColor(TextColor[0], TextColor[1], TextColor[2])
			If fFont SetImageFont(fFont)
			Local tw:Int = ifsoGUI_VP.GetTextWidth(Label, Self)
			If eImage
				ifsoGUI_VP.DrawTextArea(Label, ((w - tw) / 2) + rX, iY + rY + eImage.height + 1, Self)
				If tw > eImage.width
					If GUI.gActiveGadget = Self And ShowFocus DrawFocus(((w - tw) / 2) + rX - 2, iY + rY - 2, tw + 2, th + eImage.height + 3)
				Else
					If GUI.gActiveGadget = Self And ShowFocus DrawFocus(rX + iX - 2, iY + rY - 2, eImage.width + 3, th + eImage.height + 3)
				End If
			Else
				ifsoGUI_VP.DrawTextArea(Label, ((w - tw) / 2) + rX, iY + rY + 1, Self)
				If GUI.gActiveGadget = Self And ShowFocus DrawFocus(((w - tw) / 2) + rX - 2, iY + rY - 2, tw + 2, th + 2)
			End If
		Else
			If eImage
				If GUI.gActiveGadget = Self And ShowFocus DrawFocus(rX + iX - 2, iY + rY - 2, eImage.width + 3, eImage.height + 4)
			Else
				If GUI.gActiveGadget = Self And ShowFocus DrawFocus(rX + iX - 2, iY + rY - 2, 3, 4)
			End If
		End If
		ifsoGUI_VP.Pop()
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
		End If
		If ShowButton
			BorderTop = lImage.h[1]
			BorderBottom = lImage.h[7]
			BorderLeft = lImage.w[3]
			BorderRight = lImage.w[5]
		Else
			BorderTop = 0
			BorderBottom = 0
			BorderLeft = 0
			BorderRight = 0
		End If
		If AutoSize
			Local saveFont:TImageFont = GetImageFont()
			If fFont
				SetImageFont(fFont)
			Else
				SetImageFont(GUI.DefaultFont)
			End If
			If ShowLabel
				Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
				Local tw:Int = ifsoGUI_VP.GetTextWidth(Label, Self)
				If tw > imgImages[0].width
					'Set the width to the text width + minw
					w = BorderLeft + BorderRight + 2 + tw
				Else
					'Set the width to the image width + minw
					w = BorderLeft + BorderRight + 2 + imgImages[0].width
				End If
				'Set the height to text height plus minh + image height
				h = BorderTop + BorderBottom + imgImages[0].height + th + 3
			Else
				w = BorderLeft + BorderRight + 2 + imgImages[0].width
				h = BorderTop + BorderBottom + imgImages[0].height + 2
			End If
			SetImageFont(saveFont)
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
	bbdoc: Sets whether or not the button label will show.
	End Rem
	Method SetShowLabel(bShowLabel:Int)
		ShowLabel = bShowLabel
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the button label will show.
	End Rem
	Method GetShowLabel:Int()
		Return ShowLabel
	End Method
	Rem
	bbdoc: Sets whether or not the button will show.
	End Rem
	Method SetShowButton(bShowButton:Int)
		ShowButton = bShowButton
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the button will show.
	End Rem
	Method GetShowButton:Int()
		Return ShowButton
	End Method
	Rem
	bbdoc: Sets the images that will appear.
	End Rem
	Method SetImages(imgNormal:TImage, imgOver:TImage = Null, imgDown:TImage = Null)
		imgImages[ifsoGUI_MOUSE_NORMAL] = imgNormal
		If imgOver
			imgImages[ifsoGUI_MOUSE_OVER] = imgOver
		Else
			imgImages[ifsoGUI_MOUSE_OVER] = imgImages[ifsoGUI_MOUSE_NORMAL]
		End If
		If imgDown
			imgImages[ifsoGUI_MOUSE_DOWN] = imgDown
		Else
			imgImages[ifsoGUI_MOUSE_DOWN] = imgImages[ifsoGUI_MOUSE_NORMAL]
		End If
	End Method
End Type
