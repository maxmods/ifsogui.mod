SuperStrict

Rem
	bbdoc: ifsoGUI Label
	about: Label Gadget
EndRem
Module ifsogui.label

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI

GUI.Register(ifsoGUI_Label.SystemEvent)

Const ifsoGUI_LABEL_JUSTIFY_LEFT:Int = 0
Const ifsoGUI_LABEL_JUSTIFY_CENTER:Int = 1
Const ifsoGUI_LABEL_JUSTIFY_RIGHT:Int = 2

Rem
	bbdoc: Label Type
End Rem
Type ifsoGUI_Label Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image 'Images to draw the label
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Field lImage:ifsoGUI_Image 'Images to draw the label
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	Field Label:String 'Text in the box
	Field Justify:Int '0=Left 1=Center 2=Right
	Field ShowBorder:Int = False
	Field TextX:Int, TextY:Int
	
	'Events
	'None
	
	Rem
		bbdoc: Create and returns a Label gadget.
	End Rem
	Function Create:ifsoGUI_Label(iX:Int, iY:Int, iW:Int, iH:Int, strName:String, strText:String = "")
		Local p:ifsoGUI_Label = New ifsoGUI_Label
		p.TabOrder = -2
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.Name = strName
		p.Label = strText
		p.Enabled = False
		For Local i:Int = 0 To 2
			p.TextColor[i] = GUI.TextColor[i]
		Next
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
		If Not boolTransparent DrawBox2(lImage, rX, rY, w, h, ShowBorder, lTileSides, lTileCenter)
		SetColor(TextColor[0], TextColor[1], TextColor[2])
		If fFont SetImageFont(fFont)
		If ShowBorder
			ifsoGUI_VP.Add(rX + BorderLeft, rY + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
		Else
			ifsoGUI_VP.Add(rX, rY, w, h)
		End If
		ifsoGUI_VP.DrawTextArea(Label, rX + TextX, rY + TextY, Self)
		ifsoGUI_VP.Pop()
		If fFont SetImageFont(GUI.DefaultFont)
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		Return False
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
		If fFont SetImageFont(fFont)
		If AutoSize
			w = ifsoGUI_VP.GetTextWidth(Label, Self) + 4
			h = ifsoGUI_VP.GetTextHeight(Self) + 4
			TextY = 2
			TextX = 2
			If ShowBorder
				w:+BorderLeft + BorderRight
				h:+BorderTop + BorderBottom
				TextX:+BorderLeft
				TextY:+BorderTop
			End If
		Else
			Local th:Int = ifsoGUI_VP.GetTextHeight(Self)
			Local tw:Int = ifsoGUI_VP.GetTextWidth(Label, Self)
			TextY = (h - th) / 2
			If Justify = ifsoGUI_JUSTIFY_LEFT
				TextX = BorderLeft + 2
			ElseIf Justify = ifsoGUI_JUSTIFY_CENTER
				TextX = (w - tw) / 2
			Else
				TextX = w - (tw + 2)
				If ShowBorder TextX:-BorderRight
			End If
		End If
		If fFont SetImageFont(GUI.DefaultFont)
	End Method
	Rem
	bbdoc: Called when the mouse is over this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base) 'No mouse enter events for label
	End Method
	Rem
	bbdoc: Called to load a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("label", strSkin).Split(",")
		Load9Image2("/graphics/label.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		Refresh()
	End Method
	Rem
	bbdoc: Called when the mouse leaves the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOut(iMouseX:Int, iMouseY:Int, gOverGadget:ifsoGUI_Base) 'No mouse exit events for label
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
		Local dimensions:String[] = GetDimensions("label").Split(",")
		Load9Image2("/graphics/label.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
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
	bbdoc: Sets the labels text.
	End Rem
	Method SetLabel(strLabel:String)
		Label = strLabel
		Refresh()
	End Method
	Rem
	bbdoc: Returns the labels text.
	End Rem
	Method GetLabel:String()
		Return Label
	End Method
	Rem
	bbdoc: Gives the gadget the focus.
	about: This sets this gadget as the Active Gadget.
	End Rem
	Method SetFocus()
	End Method
	Rem
	bbdoc: Sets the text justification.
	about: ifsoGUI_LABEL_JUSTIFY_LEFT, ifsoGUI_LABEL_JUSTIFY_CENTER, ifsoGUI_LABEL_JUSTIFY_RIGHT
	End Rem
	Method SetJustify(iJustify:Int)
		Justify = iJustify
		If Justify < 0 Or Justify > 2 Justify = 0
		Refresh()
	End Method
	Rem
	bbdoc: Returns the text justification.
	End Rem
	Method GetJustify:Int()
		Return Justify
	End Method
	Rem
	bbdoc: Sets the gadget enabled/disabled.
	End Rem
	Method SetEnabled(bEnabled:Int = True) 'Sets the gadget enabled or not.
	End Method
	Rem
	bbdoc: Sets whether the labels border will show.
	End Rem
	Method SetShowBorder(bShowBorder:Int)
		ShowBorder = bShowBorder
		Refresh()
	End Method
	Rem
	bbdoc: Sets the gadgets TabOrder. 0=Do not tab to this gadget -1=Last in the Tab Order
	End Rem
	Method SetTabOrder(iTabOrder:Int)
		TabOrder = 0
	End Method
	Rem
	bbdoc: Returns whether or not the labels border is showing.
	End Rem
	Method GetShowBorder:Int()
		Return ShowBorder
	End Method
End Type
