SuperStrict

Rem
	bbdoc: ifsoGUI Panel
	about: Panel Gadget
EndRem
Module ifsogui.panel

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Marcus Trisdale"
ModuleInfo "Copyright: (c) 2009 Marcus Trisdale"

Import ifsogui.GUI
Import ifsogui.scrollbar

Const ifsoGUI_IMAGE_NONE:Int = 0
Const ifsoGUI_IMAGE_CENTER:Int = 1
Const ifsoGUI_IMAGE_SCALETOPANEL:Int = 2
Const ifsoGUI_IMAGE_RESIZETOIMAGE:Int = 3
Const ifsoGUI_IMAGE_SCALETOPANEL_MAINTAINASPECTRATIO:Int = 4
Const ifsoGUI_IMAGE_TILE:Int = 5

GUI.Register(ifsoGUI_Panel.SystemEvent)

Rem
	bbdoc: Panel Type
End Rem
Type ifsoGUI_Panel Extends ifsoGUI_Base
	Global gImage:ifsoGUI_Image = New ifsoGUI_Image
	Global gTileSides:Int, gTileCenter:Int 'Should the graphics be tiled or stretched
	Global MouseBorderCheck:Int = 5
	Field lImage:ifsoGUI_Image
	Field lTileSides:Int, lTileCenter:Int 'Should the graphics be tiled or stretched
	
	Field WasX:Int, WasY:Int 'To track MouseMove Event
	Field Dragable:Int, Dragging:Int 'For Window dragging
	Field GrabMouseX:Int, GrabMouseY:Int 'Last mouse position, for dragging
	Field ParentX:Int, ParentY:Int 'Need to remember these for dragging.
	Field ShowBorder:Int = True ' Whether the border should be drawn.
	Field MinW:Int, MinH:Int 'Minimum width/height of panel
	Field CanResize:Int 'Panel can be resized
	Field Resizing:Int 'Current status of being resized
	Field ResizeSpot:Int 'The spot being grabbed
	Field ResizePosX:Int, ResizePosY:Int 'Remember where gadget is when dragging starts
	Field BackImage:TImage 'Background image
	
	'For Scrollbars
	Field Scrollbars:Int = 2 'Show scrollbars when control is off screen, 1-Always 2-When needed 0-Never
	Field HBar:ifsoGUI_ScrollBar, VBar:ifsoGUI_ScrollBar
	Field ScrollBarWidth:Int = 20 'Width of the scrollbars
	Field MaxChildW:Int, MaxChildH:Int 'Width/height of the farthest control
	Field OriginX:Int, OriginY:Int 'Top Left Panel Corner

	'Events
	'Mouse Enter/Mouse Exit/Mouse Move
	
	Rem
		bbdoc: Create and returns a panel gadget.
	End Rem
	Function Create:ifsoGUI_Panel(iX:Int, iY:Int, iW:Int, iH:Int, strName:String)
		Local p:ifsoGUI_Panel = New ifsoGUI_Panel
		p.TabOrder = -2
		p.x = iX
		p.y = iY
		p.lImage = gImage
		p.lTileSides = gTileSides
		p.lTileCenter = gTileCenter
		p.Name = strName
		p.Enabled = True
		p.HBar = ifsoGUI_ScrollBar.Create(0, iH - p.ScrollBarWidth, iW, p.ScrollBarWidth, strName + "_hbar", False)
		p.VBar = ifsoGUI_ScrollBar.Create(iW - p.ScrollBarWidth, 0, p.ScrollBarWidth, iH, strName + "_vbar", True)
		p.HBar.SetVisible(False)
		p.HBar.Master = p
		p.VBar.SetVisible(False)
		p.VBar.Master = p
		p.Slaves.AddLast(p.VBar)
		p.Slaves.AddLast(p.HBar)
		p.SetShowBorder(True)
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
		'draw center
		If Not boolTransparent
			DrawBox2(lImage, rX, rY, w, h, ShowBorder, lTileSides, lTileCenter)
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
	End Method
	Rem
	bbdoc: Figures minimum width and height
	End Rem
	Method ComputeMinWH()
		If ScrollBars
			If MinW < BorderLeft + BorderRight + HBar.GetMinLength() + ScrollBarWidth MinW = BorderLeft + BorderRight + HBar.GetMinLength() + ScrollBarWidth
			If MinH < BorderTop + BorderBottom + VBar.GetMinLength() + ScrollBarWidth MinH = BorderTop + BorderBottom + VBar.GetMinLength() + ScrollBarWidth
		Else
			If MinW < BorderLeft + BorderRight MinW = BorderLeft + BorderRight
			If MinH < BorderTop + BorderBottom MinH = BorderTop + BorderBottom
		End If
		If BackImage And AutoSize = ifsoGUI_IMAGE_SCALETOPANEL_MAINTAINASPECTRATIO
			Local fAspect:Float = Float(BackImage.height) / Float(BackImage.width)
			If (MinW * fAspect) < MinH
				fAspect = Float(BackImage.width) / Float(BackImage.height)
				MinW = fAspect * MinH
			Else
				fAspect = Float(BackImage.width) / Float(BackImage.height)
				If (MinH * fAspect) < MinW
					fAspect = Float(BackImage.height) / Float(BackImage.width)
					MinH = MinW * fAspect
				End If
			End If
		End If
	End Method
	Rem
	bbdoc: Draws the gadgets children.
	about: Normally called from the Draw Method.
	Internal function should not be called by the user.
	End Rem
	Method DrawChildren(parX:Int, parY:Int, parW:Int, parH:Int) 'Draw the children
		ifsoGUI_VP.Add(parX, parY, parW, parH)
		For Local c:ifsoGUI_Base = EachIn Children
			c.Draw(parX - OriginX, parY - OriginY, parW + OriginX, parH + OriginY)
		Next
		ifsoGUI_VP.Pop()
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
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int)
		If (key = ifsoGUI_KEY_UP) 'Cursor Up
			If VBar.Visible VBar.SetValue(VBar.Value - VBar.Interval)
		Else If (key = ifsoGUI_KEY_DOWN) 'Cursor Down
		 If VBar.Visible VBar.SetValue(VBar.Value + VBar.Interval)
		Else If (key = ifsoGUI_KEY_RIGHT) 'Cursor Right
		 If HBar.Visible HBar.SetValue(HBar.Value + HBar.Interval)
		Else If (key = ifsoGUI_KEY_LEFT) 'Cursor Left
		 If HBar.Visible HBar.SetValue(HBar.Value - HBar.Interval)
		Else If (key = ifsoGUI_KEY_HOME) 'Home
			If VBar.Visible VBar.SetValue(VBar.GetMin())
		Else If (key = ifsoGUI_KEY_END) 'End
			If VBar.Visible VBar.SetValue(VBar.GetMax())
		Else If (key = ifsoGUI_KEY_PAGEUP) 'PageUp
			If VBar.Visible VBar.SetValue(VBar.GetValue() - VBar.GetBarInterval())
		Else If (key = ifsoGUI_KEY_PAGEDOWN) 'PageDown
			If VBar.Visible VBar.SetValue(VBar.GetValue() + VBar.GetBarInterval())
		Else If Key = ifsoGUI_MOUSE_WHEEL_UP
		 If VBar.Visible VBar.SetValue(VBar.Value - (GUI.iMouseZChange * VBar.Interval))
		Else If Key = ifsoGUI_MOUSE_WHEEL_DOWN
		 If VBar.Visible VBar.SetValue(VBar.Value - (GUI.iMouseZChange * VBar.Interval))
		End If
	End Method
	Rem
	bbdoc: Called when the mouse is over this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base)
		If Dragging
			SetXY(iMouseX - GrabMouseX, iMouseY - GrabMouseY)
		ElseIf Resizing
			Local newW:Int = w, newH:Int = h
			Local newX:Int = x, newY:Int = y
			If ResizeSpot & ifsoGUI_RESIZE_LEFT
				If newW - (iMouseX - ResizePosX) >= MinW
					newW:-(iMouseX - ResizePosX)
					newX:+iMouseX - ResizePosX
					ResizePosX = iMouseX
				Else
					newW = MinW
					newX:+w - MinW
					ResizePosX = newX
				End If
			ElseIf ResizeSpot & ifsoGUI_RESIZE_RIGHT
				If iMouseX >= ResizePosX + MinW
				 newW = iMouseX - ResizePosX
				Else
					newW = minW
				End If
			End If
			If ResizeSpot & ifsoGUI_RESIZE_TOP
				If newH - (iMouseY - ResizePosY) >= MinH
					newH:-(iMouseY - ResizePosY)
					newY:+iMouseY - ResizePosY
					ResizePosY = iMouseY
				Else
					newH = MinH
					newY:+h - MinH
					ResizePosY = newY
				End If
			ElseIf ResizeSpot & ifsoGUI_RESIZE_BOTTOM
				If iMouseY >= ResizePosY + MinH
				 newH = iMouseY - ResizePosY
				Else
					newH = MinH
				End If
			End If
			If newX <> x Or newY <> y Or newW <> w Or newH <> h
				SetXY(newX, newY)
				SetWH(newW, newH)
				SendEvent(ifsoGUI_EVENT_RESIZE, 0, 0, 0)
			End If
		Else
			'Do MouseMove Event
			If gWasOverGadget = Self
				If iMouseX <> WasX Or iMouseY <> WasY
					Local i:Int
					For i = 1 To 3
						If MouseDown(i) Exit
					Next
					SendEvent(ifsoGUI_EVENT_MOUSE_MOVE, 0, iMouseX, iMouseY)
				End If
			Else
				If Not IsMyChild(gWasOverGadget) SendEvent(ifsoGUI_EVENT_MOUSE_ENTER, 0, iMouseX, iMouseY)
			End If
			WasX = iMouseX;WasY = iMouseY
		End If
	End Method
	Rem
	bbdoc: Called when the mouse leaves the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOut(iMouseX:Int, iMouseY:Int, gOverGadget:ifsoGUI_Base)
		If IsMyChild(gOverGadget) Return
		SendEvent(ifsoGUI_EVENT_MOUSE_EXIT, 0, iMouseX, iMouseY)
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
			 Dragging = True
				GrabMouseX = iMouseX - x
				GrabMouseY = iMouseY - y
			End If
		End If
	End Method
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int)
		If GUI.gMouseOverGadget = Self
		 SendEvent(ifsoGUI_EVENT_MOUSE_UP, iButton, iMouseX, iMouseY)
		Else
			GUI.SetActiveGadget(Null)
		End If
		Dragging = False
		Resizing = False
	End Method
	Rem
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget only.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If ResizeSpot
			GUI.iMouseDir = ResizeSpot
			Return ifsoGUI_MOUSE_RESIZE
		End If
		Return ifsoGUI_MOUSE_NORMAL
	End Method
	Rem
	bbdoc: Can this gadget be active.
	about: Internal function should not be called by the user.
	End Rem
	Method CanActive:Int() 'Panels cannot be the Active Gadget
		Return False
	End Method
	Rem
	bbdoc: Called when the gadget becomes the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method GainFocus(GainedFocus:ifsoGUI_Base)  'Gadget Got focus
		'Panels don't gain or lose focus
	End Method
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String)
		VBar.LoadSkin(strSkin)
		HBar.LoadSkin(strSkin)
		If strSkin = ""
			bSkin = False
			lImage = gImage
			lTileSides = gTileSides
			lTileCenter = gTileCenter
			Refresh()
			Return
		End If
		bSkin = True
		Local dimensions:String[] = GetDimensions("panel", strSkin).Split(",")
		Load9Image2("/graphics/panel.png", dimensions, lImage, strSkin)
		If dimensions.Length > 19
			If dimensions[19].ToLower() = "t" lTileSides = True
		End If
		If dimensions.Length > 20
			If dimensions[20].ToLower() = "t" lTileCenter = True
		End If
		Refresh()
	End Method
	Rem
	bbdoc: Called when the gadget is no longer the Active Gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method LostFocus(LostFocus:ifsoGUI_Base)	 'Gadget Lost fcucs
		'Panels don't gain or lose focus
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
		If ShowBorder
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
		ComputeMinWH()
		If BackImage And AutoSize = ifsoGUI_IMAGE_RESIZETOIMAGE
			w = BackImage.width + BorderLeft + BorderRight
			h = BackImage.height + BorderTop + BorderBottom
		End If
		If w < MinW w = MinW
		If h < MinH h = MinH
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
	bbdoc: Called when a child gadget is moved.
	about: Internal function should not be called by the user.
	End Rem
	Method ChildMoved(gadget:ifsoGUI_Base)
		MaxChildW = 0
		MaxChildH = 0
		For Local c:ifsoGUI_Base = EachIn Children
			If c.Visible
				If c.x + c.w > MaxChildW MaxChildW = c.x + c.w
				If c.y + c.h > MaxChildH MaxChildH = c.y + c.h
			End If
		Next
		Refresh()
	End Method
	Rem
	bbdoc: Sets the gadgets TabOrder. 0=Do not tab to this gadget -1=Last in the Tab Order
	End Rem
	Method SetTabOrder(iTabOrder:Int)
		TabOrder = 0
	End Method
	Rem
	bbdoc: Sets the gadgets width and height.
	End Rem
	Method SetWH(width:Int, height:Int)
		If BackImage
		 If AutoSize = ifsoGUI_IMAGE_RESIZETOIMAGE
				w = BackImage.width + BorderLeft + BorderRight
				h = BackImage.height + BorderTop + BorderBottom
			ElseIf AutoSize = ifsoGUI_IMAGE_SCALETOPANEL_MAINTAINASPECTRATIO
				Local diffh:Int, diffw:Int
				If Abs(width - w) > Abs(height - h)
					Local aspect:Float = Float(BackImage.height) / Float(BackImage.width)
					diffh = height - Int(width * aspect)
					height:-diffh
				Else
					Local aspect:Float = Float(BackImage.width) / Float(BackImage.height)
					diffw = width - Int(height * aspect)
					width:-diffw
				End If
				If Resizing And ResizeSpot <> 1 And ResizeSpot <> 2 And ResizeSpot <> 4 And ResizeSpot <> 8 ' two directions
					If diffw <> 0
						If (ResizeSpot & ifsoGUI_RESIZE_LEFT)
							x:+diffw
							GUI.PositionMouse(GUI.iMouseX + diffw, GUI.iMouseY)
							ResizePosX:+diffw
						Else
							GUI.PositionMouse(GUI.iMouseX - diffw, GUI.iMouseY)
						End If
					Else
						If (ResizeSpot & ifsoGUI_RESIZE_TOP)
							y:+diffh
							GUI.PositionMouse(GUI.iMouseX, GUI.iMouseY + diffh)
							ResizePosY:+diffh
						Else
							GUI.PositionMouse(GUI.iMouseX + diffw, GUI.iMouseY - diffh)
						End If
					End If
				End If
			End If
		End If
		w = width
		h = height
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
		If gadget.Name = Name + "_hbar"
			If id = ifsoGUI_EVENT_CHANGE OriginX = data
		ElseIf gadget.Name = Name + "_vbar"
			If id = ifsoGUI_EVENT_CHANGE OriginY = data
		End If
	End Method
	Rem
	bbdoc: Called to load the graphics when a new theme is loaded.
	about: A GadgetSystemEvent is then sent out to all gadgets.
	Internal function should not be called by the user.
	End Rem
	Function LoadTheme()
		Local dimensions:String[] = GetDimensions("panel").Split(",")
		Load9Image2("/graphics/panel.png", dimensions, gImage)
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

	Rem
	bbdoc: Adds a child gadget to the gadget.
	End Rem
	Method AddChild(gadget:ifsoGUI_Base)  'Add a child to the gadget
		gadget.Parent = Self
		If gadget.OnTop
			Children.AddLast(gadget)
		Else
			Local t:TLink = Children.LastLink()
			While t
				If Not ifsoGUI_Base(t.Value()).OnTop Exit
				t = t.PrevLink()
			Wend
			If Not t
				Children.AddFirst(gadget)
			Else
				Children.InsertAfterLink(gadget, t)
			End If
		End If
		Local p:ifsoGUI_Base = gadget
		While p.Parent
			p = p.Parent
		Wend
		If GUI.Gadgets.Contains(p) gadget.AddTabOrder()
		ChildMoved(gadget)
	End Method
	Rem
	bbdoc: Removes a child gadget from the gadget.
	End Rem
	Method RemoveChild(gadget:ifsoGUI_Base, bDestroy:Int = True)
		If gadget = GUI.gActiveGadget
			GUI.gActiveGadget = Null
		ElseIf gadget.IsMyChild(GUI.gActiveGadget)
			GUI.gActiveGadget = Null
		End If
		If gadget = GUI.gMouseOverGadget
			GUI.gMouseOverGadget = Null
		ElseIf gadget.IsMyChild(GUI.gMouseOverGadget)
			GUI.gMouseOverGadget = Null
		End If
		If GUI.Modal = gadget
			GUI.SetModal(Null)
		ElseIf gadget.IsMyChild(GUI.Modal)
			GUI.SetModal(Null)
		End If
		gadget.Parent = Null
		gadget.RemoveTabOrder()
		Children.Remove(gadget)
		If bDestroy gadget.Destroy()
		ChildMoved(Null)
	End Method
	Rem
	bbdoc: Sets whether or not to the gadget will autosize or be manually controlled by the user.
	End Rem
	Method SetAutoSize(intAutoSize:Int)
		AutoSize = intAutoSize
		SetWH(w, h)
	End Method
	Rem
	bbdoc: Sets a background image for the panel.
	End Rem
	Method SetBackgroundImage(imgImage:TImage)
		BackImage = imgImage
	End Method
	Rem
	bbdoc: Returns the background image of the panel.
	End Rem
	Method GetBackgroundImage:TImage()
		Return BackImage
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
	bbdoc: Sets whether or not the gadget can be dragged with the mouse.
	End Rem
	Method SetDragable(bDragable:Int)
		Dragable = bDragable
	End Method
	Rem
	bbdoc: Returns whether or not the gadget can be dragged with the mouse.
	End Rem
	Method GetDragable:Int()
		Return Dragable
	End Method
	Rem
	bbdoc: Sets whether or not the border will show.
	End Rem
	Method SetShowBorder(bShowBorder:Int)
		ShowBorder = bShowBorder
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not the border is showing.
	End Rem
	Method GetShowBorder:Int()
		Return ShowBorder
	End Method
	Rem
	bbdoc: Returns the thickness of the border edge.
	about: Edge can be ifsoGUI_LEFT, ifsoGUI_RIGHT, ifsoGUI_TOP, ifsoGUI_BOTTOM
	End Rem
	Method GetBorderSize:Int(Edge:Int)
		Select Edge
			Case ifsoGUI_LEFT
				Return BorderLeft
			Case ifsoGUI_RIGHT
				Return BorderRight
			Case ifsoGUI_TOP
				Return BorderTop
			Case ifsoGUI_BOTTOM
				Return BorderBottom
		End Select
		Return 0
	End Method
	Rem
	bbdoc: Sets the minimum width and height of the gadget.
	End Rem
	Method SetMinWH(width:Int, height:Int)
		MinW = width
		MinH = height
		Refresh()
	End Method
	Rem
	bbdoc: Retrieves the minimum width and height of the gadget.
	End Rem
	Method GetMinWH(width:Int Var, height:Int Var)
		width = MinW
		height = MinH
	End Method
	Rem
	bbdoc: Sets whether the gadget can be resized using the mouse.
	End Rem
	Method SetResizable(bResize:Int)
		CanResize = bResize
		If Not bResize Resizing = 0
	End Method
	Rem
	bbdoc: Returns whether or not the gadget can be resized.
	End Rem
	Method GetResizable:Int()
		Return CanResize
	End Method
	Rem
	bbdoc: Sets whether or not the Scrollbars will show.
	about: ifsoGUI_SCROLLBAR_ON, ifsoGUI_SCROLLBAR_OFF, ifsoGUI_SCROLLBAR_AUTO
	End Rem
	Method SetScrollbars(bScrollbars:Int)
		If Scrollbars = bScrollbars Return
		Scrollbars = bScrollbars
		Refresh()
	End Method
	Rem
	bbdoc: Return whether or not scrollbars will show.
	End Rem
	Method GetScrollbars:Int()
		Return Scrollbars
	End Method
	Rem
	bbdoc: Sets the width of the scrollbars.
	End Rem
	Method SetScrollBarWidth(iWidth:Int)
		ScrollBarWidth = iWidth
		Refresh()
	End Method
	Rem
	bbdoc: Returns the width of the scrollbars.
	End Rem
	Method GetScrollBarWidth:Int()
		Return ScrollBarWidth
	End Method
	Rem
	bbdoc: Returns the absolute X and Y screen position of the gadget.
	End Rem
	Method GetAbsoluteXY(iX:Int Var, iY:Int Var, caller:ifsoGUI_Base = Null)
		If Parent
			Parent.GetAbsoluteXY(iX, iY, Self)
		ElseIf Master
			Master.GetAbsoluteXY(iX, iY, Self)
		End If
		iX:+x
		iY:+y
		If caller <> Self And caller <> VBar And caller <> HBar
			 iX:-OriginX
			 iY:-OriginY
		End If
		If caller <> Self And ShowBorder
		 iX:+BorderLeft
		 iY:+BorderTop
		End If
	End Method
	Rem
	bbdoc: Returns client width of the gadget.
	about: Client Width is the usable area inside the gadget.
	Basically, the width of the gadget, minus the size of the borders.
	End Rem
	Method GetClientWidth:Int()
		If VBar.Visible
			Return w - (BorderLeft + BorderRight + ScrollBarWidth)
		Else
			Return w - (BorderLeft + BorderRight)
		End If
	End Method
	Rem
	bbdoc: Returns client height of the gadget.
	about: Client Height is the usable area inside the gadget.
	Basically, the height of the gadget, minus the size of the borders.
	End Rem
	Method GetClientHeight:Int()
		If HBar.Visible
			Return h - (BorderTop + BorderBottom + ScrollBarWidth)
		Else
			Return h - (BorderTop + BorderBottom)
		End If
	End Method
End Type
