SuperStrict

Rem
	bbdoc: ifsoGUI Progressbar
	about: Progressbar Gadget
EndRem
Module ifsogui.progressbar

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI

Const ifsoGUI_DRAWSTYLE_STRETCH:Int = 0
Const ifsoGUI_DRAWSTYLE_TILE:Int = 1

GUI.Register(ifsoGUI_ProgressBar.SystemEvent)

Rem
	bbdoc: Progressbar Type
End Rem
Type ifsoGUI_ProgressBar Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the label
	Global gImageStretch:TImage 'image for the stretch bar 
	Global gImageTile:TImage 'image for the tile bar 
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image 'Images to draw the label
	Field lImageStretch:TImage 'image for the stretch bar 
	Field lImageTile:TImage 'image for the tile bar 
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	Field Value:Int 'Current Value
	Field iMin:Int = 0, iMax:Int = 100 'Min/Max values of the control
	Field ShowBorder:Int = True
	Field Label:String 'Text Label on the bar
	Field DrawStyle:Int '0=Stretch 1=Tile 
	Field BarColor:Int[] = [0, 0, 255] 'Color of the text in the gadget
	Field Reversed:Int = False 'If the direction fo the bar should be reversed
																												'False = Left to Right or Bottom to Top
	Field Horizontal:Int = True 'Whether the bar is Horizontal or Vertical
	'Events
	'None
	
	Rem
		bbdoc: Create and returns a progressbar gadget.
	End Rem
	Function Create:ifsoGUI_ProgressBar(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, bHorizontal:Int = True)
		Local p:ifsoGUI_ProgressBar = New ifsoGUI_ProgressBar
		p.TabOrder = -2
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lImageStretch = gImageStretch
		p.lImageTile = gImageTile
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.Name = strName
		p.Horizontal = bHorizontal
		p.SetWH(iW, iH)
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
		Local iH:Int
		Local iW:Int
		If ShowBorder
			DrawBox2(lImage, rX, rY, w, h, True, lTileSides, lTileCenter)
			If Horizontal
				If Reversed
					rX:-BorderRight
				Else
					rX:+BorderLeft
				End If
				rY:+BorderTop
				iW = Int(Float(w - (BorderLeft + BorderRight)) * (Float(Value - iMin) / Float(iMax - iMin)))
				iH = h - (BorderTop + BorderBottom)
			Else
				If Reversed
					rY:-BorderBottom
				Else
					rY:+BorderTop
				End If
				rX:+BorderLeft
				iH = Int(Float(h - (BorderTop + BorderBottom)) * (Float(Value - iMin) / Float(iMax - iMin)))
				iW = w - (BorderLeft + BorderRight)
			End If
		Else
			If Horizontal
				iW = Int(Float(w) * (Float(Value - iMin) / Float(iMax - iMin)))
				iH = h
			Else
				iH = Int(Float(h) * (Float(Value - iMin) / Float(iMax - iMin)))
				iW = w
			End If
		End If
		SetColor(BarColor[0], BarColor[1], BarColor[2])
		If DrawStyle = ifsoGUI_DRAWSTYLE_STRETCH
			If Reversed
				If Horizontal
					ifsoGUI_VP.DrawImageAreaRect(lImageStretch, rX + w - iW, rY, iW, iH)
				Else
					ifsoGUI_VP.DrawImageAreaRect(lImageStretch, rX, rY + h - iH, iW, iH)
				End If
			Else
				ifsoGUI_VP.DrawImageAreaRect(lImageStretch, rX, rY, iW, iH)
			End If
		ElseIf DrawStyle = ifsoGUI_DRAWSTYLE_TILE
			If Reversed
				If Horizontal
					ifsoGUI_VP.Add(rX + w - iW, rY, iW, iH)
				Else
					ifsoGUI_VP.Add(rX, rY + h - iH, iW, iH)
				End If
			Else
				ifsoGUI_VP.Add(rX, rY, iW, iH)
			End If
			Local i:Int
			If Horizontal
				While i < iW
					If Reversed
						i:+lImageTile.width
						ifsoGUI_VP.DrawImageAreaRect(lImageTile, rX + w - i, rY, lImageTile.width, iH)
					Else
						ifsoGUI_VP.DrawImageAreaRect(lImageTile, rX + i, rY, lImageTile.width, iH)
						i:+lImageTile.width
					End If
				Wend
			Else
				While i < iH
					If Reversed
						i:+lImageTile.height
						DrawImageRect(lImageTile, rX, rY + h - i, iW, lImageTile.height)
					Else
						DrawImageRect(lImageTile, rX, rY + i, iW, lImageTile.height)
						i:+lImageTile.height
					End If
				Wend
			End If
			ifsoGUI_VP.Pop()
		End If
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		Return False
	End Method
	Rem
	bbdoc: Called when the mouse is over this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base) 'No enter events
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lImageStretch = gImageStretch
			lImageTile = gImageTile
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("progressbar", strSkin).Split(",")
		Load9Image2("/graphics/progressbar.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		lImageStretch = LoadImage(GUI.FileHeader + strSkin + "/graphics/progressbarstretch.png")
		SetImageHandle(lImageStretch, 0, 0)
		lImageTile = LoadImage(GUI.FileHeader + strSkin + "/graphics/progressbartile.png")
		SetImageHandle(lImageTile, 0, 0)
		Refresh()
	End Method
	Rem
	bbdoc: Called when the mouse leaves the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOut(iMouseX:Int, iMouseY:Int, gOverGadget:ifsoGUI_Base) 'No exit events
	End Method
	Rem
	bbdoc: Can this gadget be active.
	about: Internal function should not be called by the user.
	End Rem
	Method CanActive:Int()
		Return False
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("progressbar").Split(",")
		Load9Image2("/graphics/progressbar.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		gImageStretch = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/progressbarstretch.png")
		SetImageHandle(gImageStretch, 0, 0)
		gImageTile = LoadImage(GUI.FileHeader + GUI.ThemePath + "/graphics/progressbartile.png")
		SetImageHandle(gImageTile, 0, 0)
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
	bbdoc: Sets the gadget enabled/disabled.
	End Rem
	Method SetEnabled(bEnabled:Int = True) 'Sets the gadget enabled or not.
	End Method
	Rem
	bbdoc: Sets whether or not the border will show.
	End Rem
	Method SetShowBorder(bShowBorder:Int)
		ShowBorder = bShowBorder
	End Method
	Rem
	bbdoc: Sets the gadgets TabOrder. 0=Do not tab to this gadget -1=Last in the Tab Order
	End Rem
	Method SetTabOrder(iTabOrder:Int)
		TabOrder = 0
	End Method
	Rem
	bbdoc: Returns whether or not the border is showing.
	End Rem
	Method GetShowBorder:Int()
		Return ShowBorder
	End Method
	Rem
	bbdoc: Sets the minimum value of the progressbar.
	End Rem
	Method SetMin(intMin:Int)
		If intMin >= iMax Return
		iMin = intMin
		If Value < iMin Value = iMin
	End Method
	Rem
	bbdoc: Returns the minimum value of the progressbar.
	End Rem
	Method GetMin:Int()
		Return iMin
	End Method
	Rem
	bbdoc: Sets the maximum value of the progressbar.
	End Rem
	Method SetMax(intMax:Int)
		If intMax <= iMin Return
		iMax = intMax
		If Value > iMax Value = iMax
	End Method
	Rem
	bbdoc: Returns the maximum value of the progressbar.
	End Rem
	Method GetMax:Int()
		Return iMax
	End Method
	Rem
	bbdoc: Sets the minimum and maximum values of the progressbar in one call.
	End Rem
	Method SetMinMax(intMin:Int, intMax:Int)
		If intMin >= intMax Return
		iMin = intMin
		iMax = intMax
		If Value < iMin Value = iMin
		If Value > iMax Value = Imax
	End Method
	Rem
	bbdoc: Sets the current value of the progressbar.
	End Rem
	Method SetValue(intValue:Int)
		Value = intValue
		If Value < iMin Value = iMin
		If Value > iMax Value = iMax
	End Method
	Rem
	bbdoc: Returns the current value of the progressbar.
	End Rem
	Method GetValue:Int()
		Return Value
	End Method
	Rem
	bbdoc: Sets the draw style of the progressbar.
	about: ifsoGUI_DRAWSTYLE_STRETCH - The graphic is stretched.
								ifsoGUI_DRAWSTYLE_TILE    - The graphic is tiled.
	End Rem
	Method SetDrawStyle(intStyle:Int)
		DrawStyle = intStyle
	End Method
	Rem
	bbdoc: Returns the drawstyle.
	End Rem
	Method GetDrawStyle:Int()
		Return DrawStyle
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
	bbdoc: Sets the color of the bar.
	End Rem
	Method SetBarColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of the gadget
		BarColor[0] = iRed
		BarColor[1] = iGreen
		BarColor[2] = iBlue
	End Method
	Rem
	bbdoc: Sets if the bar is drawn reversed.
	about: Normal is Left to Right or Bottom to Top
								Reversed is Right to Left or Top to Bottom
	End Rem
	Method SetBarReversed(intReversed:Int) 'Set bar reversed
		Reversed = intReversed
	End Method
	Rem
	bbdoc: Gets if the bar is drawn reversed.
	about: Normal is Left to Right or Bottom to Top
								Reversed is Right to Left or Top to Bottom
	End Rem
	Method GetBarReversed:Int() 'Get if the bar is reversed
		Return Reversed
	End Method
End Type

