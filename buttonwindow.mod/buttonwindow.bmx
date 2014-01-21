SuperStrict

Rem
	bbdoc: ifsoGUI Window
	about: Window Gadget
EndRem
Module ifsogui.buttonwindow

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.window
Import ifsogui.imagebutton

GUI.Register(ifsoGUI_ButtonWindow.SystemEvent)


Rem
	bbdoc: Window Type
End Rem
Type ifsoGUI_ButtonWindow Extends ifsoGUI_Window
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image
	Global gImageCap:ifsoGUI_Image = New ifsoGUI_Image
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Global gTileCapSides:Int, gTileCapCenter:Int 'Should the graphics be tiled or stretched

	Field CloseButton:ifsoGUI_ImageButton
	
	'Events
	'Mouse Enter/Mouse Exit/Mouse Move
	
	Rem
		bbdoc: Create and returns a window gadget.
	End Rem
	Function Create:ifsoGUI_ButtonWindow(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_ButtonWindow = New ifsoGUI_ButtonWindow
		p.TabOrder = -2
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lImageCap = gImageCap
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.lTileCapSides = gTileCapSides
		p.lTileCapCenter = gTileCapCenter
		p.Name = strName
		p.Enabled = True
		p.HBar = ifsoGUI_ScrollBar.Create(0, iH - p.ScrollBarWidth, iW, p.ScrollBarWidth, strName + "_hbar", False)
		p.VBar = ifsoGUI_ScrollBar.Create(iW - p.ScrollBarWidth, 0, p.ScrollBarWidth, iH, strName + "_vbar", True)
		p.HBar.SetVisible(False)
		p.HBar.Master = p
		p.VBar.SetVisible(False)
		p.VBar.Master = p
		p.CloseButton = ifsoGUI_ImageButton.Create(2, 2, 2, 2, strName + "_closebutton", "")
		p.CloseButton.Master = p
		p.Slaves.AddLast(p.HBar)
		p.Slaves.AddLast(p.VBar)
		p.Slaves.AddLast(p.CloseButton)
		p.SetShowBorder(True)
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
		If Not boolTransparent
			If ShowBorder
				'titlebar
				DrawBox2(lImageCap, rX, rY, w, BorderTop - WinTop, True, lTileCapSides, lTileCapCenter)
			End If
			DrawBox2(lImage, rX, rY + BorderTop - WinTop, w, (h - BorderTop) + WinTop, ShowBorder, lTileSides, lTileCenter)
			If Caption <> "" And Not SmallTitleBar And ShowBorder
				ifsoGUI_VP.Add(rX + CapLeft + 2, rY + CapTop, w - (CapLeft + CapRight) + 4, BorderTop - (CapTop + CapBottom + WinTop))
				SetColor(TextColor[0], TextColor[1], TextColor[2])
				If fFont SetImageFont(fFont)
				ifsoGUI_VP.DrawTextArea(Caption, rX + CapLeft + 2, rY + CapTop, Self)
				If fFont SetImageFont(GUI.DefaultFont)
				ifsoGUI_VP.Pop()
			End If
			If BackImage
				SetColor(255, 255, 255)
			 ifsoGUI_VP.Add(rX + BorderLeft, rY + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
				If AutoSize = ifsoGUI_IMAGE_SCALETOPANEL Or AutoSize = ifsoGUI_IMAGE_SCALETOPANEL_MAINTAINASPECTRATIO
					ifsoGUI_VP.DrawImageAreaRect(BackImage, rX + BorderLeft, rY + BorderTop, w - (BorderLeft + BorderRight), h - (BorderTop + BorderBottom))
				ElseIf AutoSize = ifsoGUI_IMAGE_CENTER
					Local sX:Int, sY:Int
					If VBar.Visible sX = ScrollBarWidth
					If HBar.Visible sY = ScrollBarWidth
					ifsoGUI_VP.DrawImageArea(BackImage, rX + BorderLeft + (w - (BorderLeft + BorderRight + sX) - BackImage.width) / 2, rY + BorderTop + (h - (BorderTop + BorderBottom + sY) - BackImage.height) / 2)
				ElseIf AutoSize = ifsoGUI_IMAGE_TILE
					For Local iY:Int = rY + BorderTop To rY + H - BorderBottom
						For Local iX:Int = rX + BorderLeft To rX + w - BorderRight
							ifsoGUI_VP.DrawImageArea(BackImage, iX, iY)
							iX:+BackImage.width - 1
						Next
						iY:+BackImage.height - 1
					Next
				Else
					ifsoGUI_VP.DrawImageArea(BackImage, rX + BorderLeft, rY + BorderTop)
				End If
				ifsoGUI_VP.Pop()
			End If
		End If
		Local chkW:Int = w - (BorderLeft + BorderRight)
		If VBar.Visible chkW:-ScrollBarWidth
		Local chkH:Int = h - (BorderTop + BorderBottom)
		If HBar.Visible chkH:-ScrollBarWidth
		DrawChildren(rX + BorderLeft, rY + BorderTop, chkW, chkH)
		VBar.Draw(rX + BorderLeft, rY + BorderTop, w, h)
		HBar.Draw(rX + BorderLeft, rY + BorderTop, w, h)
		CloseButton.Draw(rX, rY, w, h)
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int)
	 GUI.SetActiveGadget(Self)
		SendEvent(ifsoGUI_EVENT_MOUSE_DOWN, iButton, iMouseX, iMouseY)
		If iButton = 1
		 If ResizeSpot > 0 And Not (BackImage And AutoSize = ifsoGUI_IMAGE_RESIZETOIMAGE)
				Resizing = True
				If ResizeSpot & ifsoGUI_RESIZE_LEFT
					ResizePosX = iMouseX
				ElseIf ResizeSpot & ifsoGUI_RESIZE_RIGHT
					ResizePosX = iMouseX - w
				End If
				If ResizeSpot & ifsoGUI_RESIZE_TOP
					ResizePosY = iMouseY
				ElseIf ResizeSpot & ifsoGUI_RESIZE_BOTTOM
					ResizePosY = iMouseY - h
				End If
			ElseIf Dragable
				If DragTop
				 If ShowBorder
						If (iMouseX > ParentX + x) And (iMouseX < ParentX + x + w) And (iMouseY > ParentY + y) And (iMouseY < ParentY + y + BorderTop)
						 Dragging = True
							GrabMouseX = iMouseX - x
							GrabMouseY = iMouseY - y
						End If
					End If
				Else
				 Dragging = True
					GrabMouseX = iMouseX - x
					GrabMouseY = iMouseY - y
				End If
			End If
		End If
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not Visible Return False
		If Dragable
			ParentX = parX
			ParentY = parY
		End If
		If Dragging Or Resizing
			GUI.gMouseOverGadget = Self
			Return True
		Else
			ResizeSpot = 0
			If (iMouseX > parX + x) And (iMouseX < parX + x + w) And (iMouseY > parY + y) And (iMouseY < parY + y + h)
				Local chkX:Int = x, chkY:Int = y
				Local chkW:Int = w - (BorderLeft + BorderRight), chkH:Int = h - (BorderTop + BorderBottom)
				If (iMouseX > parX + x + BorderLeft) And (iMouseX < parx + x + w - BorderRight) And (iMouseY > parY + y + BorderTop) And (iMouseY < parY + y + h - BorderBottom)
					If HBar.IsMouseOver(parX + x + BorderLeft, parY + y + BorderTop, chkW, chkH, iMouseX, iMouseY) Return True
					If VBar.IsMouseOver(parX + x + BorderLeft, parY + y + BorderTop, chkW, chkH, iMouseX, iMouseY) Return True
					'Check for that space at the corner between the scrollbars.
					If Not (HBar.Visible And VBar.Visible And (iMouseX > parX + x + w - (BorderRight + ScrollBarWidth + 1)) And (iMouseY > parY + y + h - (BorderBottom + ScrollBarWidth + 1)))
						If x + w + BorderRight > parW chkW:-(x + chkW - parW)
						If y + h + BorderBottom > parH chkH:-(y + chkH - parH)
						chkX:+BorderLeft
						chkY:+BorderTop
						Local bFlag:Int
						For Local c:ifsoGUI_Base = EachIn Slaves
							If c.IsMouseOver(parX + chkX, parY + chkY, chkW, chkH, iMouseX, iMouseY) bFlag = True
						Next
						For Local c:ifsoGUI_Base = EachIn Children
							If c.IsMouseOver(parX + chkX - OriginX, parY + chkY - OriginY, chkW, chkH, iMouseX, iMouseY) bFlag = True
						Next
						If bFlag Return True
					End If
				Else 'Must be in the caption or border area
					If CloseButton.IsMouseOver(parX + x + BorderLeft, parY + y, chkW, chkH, iMouseX, iMouseY) Return True
				End If
				GUI.gMouseOverGadget = Self
				'Test Sides for resize spot
				If ShowBorder And CanResize And Not (BackImage And AutoSize = ifsoGUI_IMAGE_RESIZETOIMAGE)
					If iMouseX >= parX + x And iMouseX <= parX + x + MouseBorderCheck 'Left
					 ResizeSpot = ifsoGUI_RESIZE_LEFT
					ElseIf iMouseX >= parX + x + w - MouseBorderCheck And iMouseX <= parX + x + w 'Right
					 ResizeSpot = ifsoGUI_RESIZE_RIGHT
					End If
					If iMouseY >= parY + y And iMouseY <= parY + y + MouseBorderCheck 'Top
					 ResizeSpot:|ifsoGUI_RESIZE_TOP
					ElseIf iMouseY >= parY + y + h - MouseBorderCheck And iMouseY <= parY + y + h 'Bottom
					 ResizeSpot:|ifsoGUI_RESIZE_BOTTOM
					End If
				End If
				Return True
			End If
		End If
		Return False
	End Method
	Rem
	bbdoc: Called from a slave gadget.
	about: Slave gadgets do not generate GUI events.  They send events to their Master.
	The Master then uses it or can send a GUI event.
	Internal function should not be called by the user.
	End Rem
	Method SlaveEvent(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int)
		If gadget.Name = Name + "_closebutton"
			If id = ifsoGUI_EVENT_MOUSE_ENTER
				DebugLog "Closebutton Mouse Enter"
			ElseIf id = ifsoGUI_EVENT_CLICK
				DebugLog "Closebutton Click"
			End If
		ElseIf gadget.Name = Name + "_hbar"
			If id = ifsoGUI_EVENT_CHANGE OriginX = data
		ElseIf gadget.Name = Name + "_vbar"
			If id = ifsoGUI_EVENT_CHANGE OriginY = data
		End If
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method InitCloseButton(strImage:String, iWidth:Int, iHeight:Int)
		CloseButton.SetImages(LoadImage(strImage))
'		CloseButton.w = CloseButton.imgImages[0].width
'		CloseButton.h = CloseButton.imgImages[0].Height
		CloseButton.w = 20
		CloseButton.h = 20
		CloseButton.SetShowButton(True)
		RefreshCloseButton()
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		HBar.LoadSkin(strSkin)
		VBar.LoadSkin(strSkin)
		CloseButton.LoadSkin(strSkin)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lImageCap = gImageCap
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			lTileCapSides = gTileCapSides
			lTileCapCenter = gTileCapCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("window", strSkin).Split(",")
		Load9Image2("/graphics/window.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		dimensions = GetDimensions("window caption", strSkin).Split(",")
		Load9Image2("/graphics/windowcaption.png", dimensions, lImageCap, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileCapSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCapCenter = True
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
			lTileCapSides = gTileCapSides
			lTileCapCenter = gTileCapCenter
		End If
		If ShowBorder
			BorderBottom = lImage.h[7]
			BorderLeft = lImage.w[3]
			BorderRight = lImage.w[5]
			WinTop = lImage.h[1]
			CapTop = lImageCap.h[1]
			CapBottom = lImageCap.h[7]
			CapLeft = lImageCap.w[3]
			CapRight = lImageCap.w[5]
			If SmallTitleBar
				BorderTop = CapTop + lImageCap.h[4] + CapBottom + lImage.h[1]
			Else
				Local wasFont:TImageFont = GetImageFont()
				If fFont
			 	SetImageFont(fFont)
				Else
					SetImageFont(GUI.DefaultFont)
				End If
				BorderTop = ifsoGUI_VP.GetTextHeight(Self) + CapTop + CapBottom + lImage.h[1]
				SetImageFont(wasFont)
			End If
		Else
			BorderTop = 0
			BorderBottom = 0
			BorderLeft = 0
			BorderRight = 0
			WinTop = 0
		End If
		ComputeMinWH()
		If BackImage And AutoSize = ifsoGUI_IMAGE_RESIZETOIMAGE
			w = BackImage.width + BorderLeft + BorderRight
			h = BackImage.height + BorderTop + BorderBottom
		End If
		If w < minw w = minw
		If h < minh h = minh
		RefreshCloseButton()
		If ScrollBars = 0
		 VBar.SetVisible(False)
			HBar.SetVisible(False)
			Return
		End If
		Local chkW:Int = w, chkH:Int = h
		If ShowBorder
			chkW:-(BorderLeft + BorderRight)
			chkH:-(BorderTop + BorderBottom)
		End If
		If ScrollBars = 1
			HBar.Visible = True
			VBar.Visible = True
			chkW:-ScrollBarWidth
			chkH:-ScrollBarWidth
		Else
			HBar.Visible = False
			VBar.Visible = False
			For Local i:Int = 0 To 1
				If (Not HBar.Visible) And MaxChildW > chkW
					HBar.Visible = True
					chkH:-ScrollBarWidth
				End If
				If (Not VBar.Visible) And MaxChildH > chkH
					VBar.Visible = True
					chkW:-ScrollBarWidth
				End If
			Next
			If (Not HBar.Visible) And (Not VBar.Visible)
				OriginX = 0
				OriginY = 0
				HBar.SetValue(0)
				VBar.SetValue(0)
			 Return
			End If
		End If
		If chkW + OriginX >= MaxChildW And OriginX > 0
			Local diff:Int = chkW + OriginX - MaxChildW
			OriginX:-diff
			If OriginX < 0 OriginX = 0
		End If
		If chkH + OriginY >= MaxChildH And OriginY > 0
			Local diff:Int = chkH + OriginY - MaxChildH
			OriginY:-diff
			If OriginY < 0 OriginY = 0
		End If
		HBar.SetXY(0, chkH)
		HBar.SetWH(chkW, ScrollBarWidth)
		VBar.SetXY(chkW, 0)
		VBar.SetWH(ScrollBarWidth, chkH)
		If MaxChildW > chkW
		 HBar.SetMax(MaxChildW)
		Else
			HBar.SetMax(chkW)
			OriginX = 0
		End If
		If MaxChildH > chkH
			VBar.SetMax(MaxChildH)
		Else
			VBar.SetMax(chkH)
			OriginY = 0
		End If
		HBar.SetBarInterval(chkW)
		VBar.SetBarInterval(chkH)
		HBar.SetValue(OriginX)
		VBar.SetValue(OriginY)
	End Method
	Rem
		bbdoc: Refreshes the CloseButton.
		Internal function should not be called by the user.
	End Rem
	Method RefreshCloseButton()
		If ShowBorder And Not SmallTitleBar
			CloseButton.SetXY(w - (BorderRight + CloseButton.w + 4), (BorderTop - CloseButton.h) / 2)
			CloseButton.SetShowButton(True)
			CloseButton.SetVisible(True)
		Else
			CloseButton.SetVisible(False)
		End If
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("window").Split(",")
		Load9Image2("/graphics/window.png", dimensions, gImage)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCenter = True
		End If
		dimensions = GetDimensions("window caption").Split(",")
		Load9Image2("/graphics/windowcaption.png", dimensions, gImageCap)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" gTileCapSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" gTileCapCenter = True
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
	bbdoc: Sets whether or not the window is dragable only by the caption area.
	End Rem
	Method SetDragTop(bDragTop:Int)
		DragTop = bDragTop
		Dragable = bDragTop
	End Method
	Rem
	bbdoc: Returns whether or not the window is dragable only by the caption area.
	End Rem
	Method GetDragTop:Int()
		If Dragable Return DragTop
		Return False
	End Method
	Rem
	bbdoc: Sets the caption text.
	End Rem
	Method SetCaption(strCaption:String)
		Caption = strCaption
	End Method
	Rem
	bbdoc: Returns the caption text.
	End Rem
	Method GetCaption:String()
		Return Caption
	End Method
	Rem
	bbdoc: Sets the caption bar to a minimum size.
	End Rem
	Method SetSmallTitleBar(bSmall:Int)
		SmallTitleBar = bSmall
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether smalltitlebar is on or off.
	End Rem
	Method GetSmallTitleBar:Int()
		Return SmallTitleBar
	End Method
	Rem
	bbdoc: Sets whether or not the border will show.
	End Rem
	Method SetShowBorder(bShowBorder:Int)
		ShowBorder = bShowBorder
		Refresh()
	End Method

End Type
