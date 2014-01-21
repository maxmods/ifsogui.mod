	Rem
	bbdoc: Base gadget type for all gadgets.
	End Rem
	
Type ifsoGUI_Base Abstract
	Field x:Int, y:Int 'Position
	Field w:Int, h:Int 'Width and Height
	Field Children:TList = New TList 'List of children to this gadget
	Field Slaves:TList = New TList 'List of Slaves to this gadget
	Field Enabled:Int = True 'Sets the gadget enabled or disabled to ignore input
	Field Visible:Int = True 'If this gadgets is visible or not
	Field Parent:ifsoGUI_Base 'This gadgets Parent
	Field Name:String 'Name of the gadget
	Field Color:Int[] = [255, 255, 255] 'Color of the gadget
	Field TextColor:Int[] = [0, 0, 0] 'Color of the text in the gadget
	Field fFont:TImageFont = GUI.DefaultFont
	Field fAlpha:Float = 1.0 ' Alpha value of the Gadget
	Field CallBack(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int) 'callback function for events.
	Field bPressed:Int 'Is the mouse button pressed on this gadget
	Field boolTransparent:Int 'Is the gadget invisible in some way
	Field Tip:String ' Tool Tip
	Field Tip_delay:Int = 500 'Tooltip Delay default 500ms Added by Zeke
	Field Tip_time:Int 'Added by Zeke	
	Field Tip_showing:Int 'added by Zeke
	Field Master:ifsoGUI_Base 'To build a complex gadget out of multiple gadgets
	Field HasFocus:Int = False 'Does this gadget have the focus?
	Field OnTop:Int 'If the gadget should stay on top.
	Field ShowFocus:Int = True 'Should the gadget show the focus box
	Field FocusColor:Int[] = [170, 170, 170] 'Color of the Focus Box
	Field AutoSize:Int = False 'Whether or not gadget shsould automatically adjust (text, borders, etc)
	Field Sounds:TSound[ifsoGUI_EVENT_COUNT] 'To hold gadget sounds
	Field customProperties:TMap = New TMap
	Field BorderTop:Int, BorderBottom:Int, BorderLeft:Int, BorderRight:Int 'Border dimensions
	Field bSkin:Int 'Is a skin instance loaded
	Field TabOrder:Int = -1 'Tab Order of the gadget
	
	'Function Create() 'All gadgets should have a create
	Rem
	bbdoc: Removes all references to children and slaves so that the gadget and its children/slaves are collected by the garbage collector.
	End Rem
	Method Destroy()
		Parent = Null
		Master = Null
		For Local p:ifsoGUI_Base = EachIn Slaves
			p.Destroy()
		Next
		Slaves.Clear()
		For Local p:ifsoGUI_Base = EachIn Children
			p.Destroy()
		Next
		Children.Clear()
	End Method
	Rem
	bbdoc: Draws the gadget and its children.
	about: Internal function should not be called by the user.
	End Rem
	Method Draw(parX:Int, parY:Int, parW:Int, parH:Int) ; End Method 'Draws the gadget; pass the parents x and y.
	Rem
	bbdoc: Draws the gadgets children.
	about: Normally called from the Draw Method.
	Internal function should not be called by the user.
	End Rem
	Method DrawChildren(parX:Int, parY:Int, parW:Int, parH:Int) 'Draw the children
		ifsoGUI_VP.Add(parX, parY, parW, parH)
		For Local c:ifsoGUI_Base = EachIn Children
			c.Draw(parX, parY, parW, parH)
		Next
		ifsoGUI_VP.Pop()
	End Method
	Rem
	bbdoc: Draws the gadgets tip.
	about: Internal function should not be called by the user.
	End Rem
	Method DrawTip(iMouseX:Int, iMouseY:Int)
		If Not Enabled Or Not Visible Return
		If Tip <> ""
			If GUI.TipFont
				SetImageFont(GUI.TipFont)
			Else
				SetImageFont(GUI.DefaultFont)
			End If
			Local drawx:Int = iMouseX
			Local drawy:Int = iMouseY
			Local th:Int = ifsoGUI_VP.GetTextHeight(Null)
			Local tw:Int = ifsoGUI_VP.GetTextWidth(Tip, Null)
			If drawx + tw + 4 > GUI.iWidth drawx = GUI.iWidth - (tw + 4)
			If drawy + th + 24 > GUI.iHeight drawy:-60
			SetColor(GUI.TipBorderR, GUI.TipBorderG, GUI.TipBorderB)
			SetAlpha(GUI.TipAlpha)
			ifsoGUI_VP.DrawRect(drawx, drawy + 20, tw + 4, th + 4)
			SetColor(GUI.TipR, GUI.TipG, GUI.TipB)
			ifsoGUI_VP.DrawRect(drawx + 1, drawy + 21, tw + 2, th + 2)
			SetColor(GUI.TipTextR, GUI.TipTextG, GUI.TipTextB)
			ifsoGUI_VP.DrawTextArea(Tip, drawx + 2, drawy + 22, Null)
		End If
	End Method
	Rem
	bbdoc: Called when the mouse is over this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOver(iMouseX:Int, iMouseY:Int, gWasOverGadget:ifsoGUI_Base) 'Called when mouse is over the gadget, only topmost gadget
		If Not (Enabled And Visible) Return
		If gWasOverGadget <> Self And Not (IsMySlave(gWasOverGadget)) SendEvent(ifsoGUI_EVENT_MOUSE_ENTER, 0, iMouseX, iMouseY)
	End Method
	Rem
	bbdoc: Called when the mouse leaves the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method MouseOut(iMouseX:Int, iMouseY:Int, gOverGadget:ifsoGUI_Base) 'Called when mouse no longer over gadget
		If Not (Enabled And Visible) Return
		If gOverGadget <> Self And Not (IsMySlave(gOverGadget))
			Tip_showing = False 'Added TooltipDelay fix by Zeke
			SendEvent(ifsoGUI_EVENT_MOUSE_EXIT, 0, iMouseX, iMouseY)
		EndIf
	End Method
	Rem
	bbdoc: Returns whether or not the mouse is over the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMouseOver:Int(parX:Int, parY:Int, parW:Int, parH:Int, iMouseX:Int, iMouseY:Int)
		If Not Visible Return False
		If (iMouseX >= parX + x) And (iMouseX < parX + x + w) And (iMouseY >= parY + y) And (iMouseY < parY + y + h)
			Local chkX:Int = x, chkY:Int = y
			If chkX < 0 chkX = 0
			If chkY < 0 chkY = 0
			Local chkW:Int = w, chkH:Int = h 'Check if the width is off the parent
			If x + w > parW chkW = parW - x
			If y + h > parH chkH = parH - y
			For Local c:ifsoGUI_Base = EachIn Children
				If c.IsMouseOver(parX + chkX, parY + chkY, chkW, chkH, iMouseX, iMouseY) Return True
			Next
			GUI.gMouseOverGadget = Self
			Return True
		End If
		Return False
	End Method
	Rem
	bbdoc: Called when the mouse button is pressed on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseDown(iButton:Int, iMouseX:Int, iMouseY:Int) ; End Method 'Called when the mouse is pressed over the gadget
	Rem
	bbdoc: Called when the mouse button is released on the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method gMouseUp(iButton:Int, iMouseX:Int, iMouseY:Int) ;End Method 'Called when the mouse is released over the gadget
	Rem
	bbdoc: Called to determine the mouse status from the gadget.
	about: Called to the active gadget if button is pressed, otherwise called to MouseOver gadget.
	Internal function should not be called by the user.
	End Rem
	Method MouseStatus:Int(iMouseX:Int, iMouseY:Int)
		If Enabled And Visible
			If bPressed Return ifsoGUI_MOUSE_DOWN
			If GUI.gMouseOverGadget = Self Return ifsoGUI_MOUSE_OVER
		End If
		Return ifsoGUI_MOUSE_NORMAL
	End Method
	Rem
	bbdoc: Sends and event from the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method SendEvent(id:Int, data:Int, iMouseX:Int, iMouseY:Int) 'Sends Gadget events. callback if defined or creates an event.
		'Play sound
		If Sounds[id - 1] PlaySound(Sounds[id - 1])
		If Master
		 Master.SlaveEvent(Self, id, data, iMouseX, iMouseY)
			Return
		End If
		If CallBack
			ifsoGUI_Settings.PushSettings()
		 CallBack(Self, id, data, iMouseX, iMouseY)
			ifsoGUI_Settings.PopSettings()
		End If
		If GUI.UseEvents
			Local e:ifsoGUI_Event = New ifsoGUI_Event
			e.gadget = Self
			e.id = id
			e.data = data
			e.x = iMouseX
			e.y = iMouseY
			GUI.AddEvent(e)
		End If
	End Method
	Rem
	bbdoc: Called from a slave gadget.
	about: Slave gadgets do not generate GUI events.  They send events to their Master.
	The Master then uses it or can send a GUI event.
	Internal function should not be called by the user.
	End Rem
	Method SlaveEvent(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int) ; End Method 'Event generated by a slave gadget
	Rem
	bbdoc: Loads a skin for one instance of the gadget.
	End Rem
	Method LoadSkin(strSkin:String) ; End Method
	Rem
	bbdoc: Called when the gadget is no longer the Active Gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method LostFocus(GainedFocus:ifsoGUI_Base) 'Gadget Lost focus
		bPressed = False
		If GainedFocus <> Self And Not IsMySlave(GainedFocus)
		 SendEvent(ifsoGUI_EVENT_LOST_FOCUS, 0, 0, 0)
			HasFocus = False
		End If
	End Method
	Rem
	bbdoc: Called when the gadget becomes the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method GainFocus(LostFocus:ifsoGUI_Base)  'Gadget Got focus
		HasFocus = True
		If LostFocus <> Self And Not IsMySlave(LostFocus) SendEvent(ifsoGUI_EVENT_GAIN_FOCUS, 0, 0, 0)
	End Method
	Rem
	bbdoc: Called when a key is pressed on the active gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method KeyPress(key:Int) ;End Method
	Rem
	bbdoc: Returns the next gadget after start in the child list.
	about: Internal function should not be called by the user.
	End Rem
	Method NextGadget:ifsoGUI_Base(start:ifsoGUI_Base, bForward:Int = True)
		Local bFlag:Int
		If (Not start) bFlag = True
		If bForward
			For Local c:ifsoGUI_Base = EachIn Slaves
				If bFlag Return c
				If c = start bFlag = True
			Next
			For Local c:ifsoGUI_Base = EachIn Children
				If bFlag Return c
				If c = start bFlag = True
			Next
		Else
			Local l:TLink = Slaves.LastLink()
			While l
				If bFlag Return ifsoGUI_Base(l.Value())
				If l.Value() = start bFlag = True
				l = l.PrevLink()
			Wend
			l = Children.LastLink()
			While l
				If bFlag Return ifsoGUI_Base(l.Value())
				If l.Value() = start bFlag = True
				l = l.PrevLink()
			Wend
		End If
		Return Null
	End Method
	Rem
	bbdoc: Returns the gadget with the name from the child list.
	about: Internal function should not be called by the user.
	End Rem
	Method GetChild:ifsoGUI_Base(name:String)
		Local g:ifsoGUI_Base
		For Local c:ifsoGUI_Base = EachIn Children
			If c.Name.ToLower() = name.ToLower() Return c
			g = c.GetChild(name)
			If g Return g
		Next
		Return Null
	End Method
	Rem
	bbdoc: Can this gadget be active.
	about: Internal function should not be called by the user.
	End Rem
	Method CanActive:Int()
		If Not (Enabled And Visible) Return False
		If Parent
			If Not (Parent.Visible And Parent.Enabled) Return False
		End If
		If Master
			If Not (Master.Visible And Master.Enabled) Return False
		End If
		If Not Parent 'If not parent and not in the GUI list, this tab can't be active.
			If GUI.Tabs.Contains(Self) Return True
			Return False
		End If
		Return True
	End Method
	Rem
	bbdoc: Is the gadget a child or slave of this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMyChild:Int(gadget:ifsoGUI_Base)
		If IsMySlave(gadget) Return True
		For Local c:ifsoGUI_Base = EachIn Children
			If gadget = c Return True
			If c.IsMyChild(gadget) Return True
		Next
		Return False
	End Method
	Rem
	bbdoc: Is the gadget a slave of this gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method IsMySlave:Int(gadget:ifsoGUI_Base)
		If Not gadget Return False
		If gadget.Master = Self Return True
		For Local c:ifsoGUI_Base = EachIn Slaves
			If c.IsMyChild(gadget) Return True
		Next
	End Method
	Rem
	bbdoc: Called when a child gadget is moved.
	about: Internal function should not be called by the user.
	End Rem
	Method ChildMoved(gadget:ifsoGUI_Base) ; End Method 'Let the parent know a child moved or changed size
	Rem
	bbdoc: Draws the focus box around the gadget.
	about: Internal function should not be called by the user.
	End Rem
	Method DrawFocus(iX:Int, iY:Int, iW:Int, iH:Int)
		SetLineWidth(1)
		If Color SetColor(FocusColor[0], FocusColor[1], FocusColor[2])
		ifsoGUI_VP.DrawLine(iX, iY, iX + iW, iY, False)
		ifsoGUI_VP.DrawLine(iX, iY, iX, iY + iH, False)
		ifsoGUI_VP.DrawLine(iX, iY + iH, iX + iW, iY + iH, False)
		ifsoGUI_VP.DrawLine(iX + iW, iY, iX + iW, iY + iH)
	End Method 'Draw the focus on the gadget
	Rem
	bbdoc: Gadget Level GUI system event occured.
	about: Informs all slaves and children, then refreshes self.
	Internal function should not be called by the user.
	End Rem
	Method GadgetSystemEvent(id:Int, data:Int) 'Systemwide event all gadgets must know about
		If id = ifsoGUI_EVENT_SYSTEM_NEW_GADGET_COLOR
			SetGadgetColor(data Shr 16, (data & $FF00) Shr 8, data & $FF)
		ElseIf id = ifsoGUI_EVENT_SYSTEM_NEW_GADGET_TEXTCOLOR
			SetTextColor(data Shr 16, (data & $FF00) Shr 8, data & $FF)
		End If
		For Local c:ifsoGUI_Base = EachIn Slaves
			c.GadgetSystemEvent(id, data)
		Next
		For Local c:ifsoGUI_Base = EachIn Children
			c.GadgetSystemEvent(id, data)
		Next
		If Not bSkin LoadSkin("")
		Refresh()
	End Method
	Rem
		bbdoc: Refreshes the gadget.
		about: Recalculates any geometry/font changes, etc.
		Internal function should not be called by the user.
	End Rem
	Method Refresh() ; End Method
	Rem
	bbdoc: Draws the graphics of a standard gadget box.
	about: Internal function should not be called by the user.
	End Rem
	Function DrawBox(images:TImage[], rX:Int, rY:Int, rW:Int, rH:Int, bDrawBorder:Int = True, bTileSides:Int = False, bTileCenter:Int = False)
		If bDrawBorder
'			'Corners
			ifsoGUI_VP.DrawImageArea(images[0], rX, rY)
			ifsoGUI_VP.DrawImageArea(images[2], (rX + rW) - images[2].width, rY)
			ifsoGUI_VP.DrawImageArea(images[6], rX, (rY + rH) - images[6].height)
			ifsoGUI_VP.DrawImageArea(images[8], (rX + rW) - images[8].width, (rY + rH) - images[8].height)
			'sides
			If bTileSides
				'Top
				ifsoGUI_VP.Add(rX + images[0].width, rY, rW - (images[0].width + images[2].width), images[1].height)
				For Local iX:Int = rX + images[0].width To rX + rW - images[2].width
					ifsoGUI_VP.DrawImageArea(images[1], iX, rY)
					iX:+images[1].width - 1
				Next
				ifsoGUI_VP.Pop()
			'Bottom
				ifsoGUI_VP.Add(rX + images[6].width, rY + rH - images[7].height, rW - (images[6].width + images[8].width), images[7].height)
				For Local iX:Int = rX + images[6].width To rX + rW - images[8].width
					ifsoGUI_VP.DrawImageArea(images[7], iX, rY + rH - images[7].height)
					iX:+images[7].width - 1
				Next
				ifsoGUI_VP.Pop()
				'Left
				ifsoGUI_VP.Add(rX, rY + images[0].height, images[3].width, rH - (images[0].height + images[6].height))
				For Local iY:Int = rY + images[0].height To rY + rH - images[6].height
					ifsoGUI_VP.DrawImageArea(images[3], rX, iY)
					iY:+images[3].height - 1
				Next
				ifsoGUI_VP.Pop()
				'Right
				ifsoGUI_VP.Add(rX + rW - images[5].width, rY + images[0].height, images[5].width, rH - (images[2].height + images[8].height))
				For Local iY:Int = rY + images[2].height To rY + rH - images[8].height
					ifsoGUI_VP.DrawImageArea(images[5], rX + rW - images[5].width, iY)
					iY:+images[5].height - 1
				Next
				ifsoGUI_VP.Pop()
			Else
				ifsoGUI_VP.DrawImageAreaRect(images[1], rX + images[0].width, rY, rW - (images[0].width + images[2].width), images[1].height)
				ifsoGUI_VP.DrawImageAreaRect(images[7], rX + images[6].width, (rY + rH) - images[7].height, rW - (images[6].width + images[8].width), images[7].height)
				ifsoGUI_VP.DrawImageAreaRect(images[3], rX, rY + images[0].height, images[3].width, rH - (images[0].height + images[6].height))
				ifsoGUI_VP.DrawImageAreaRect(images[5], (rX + rW) - images[5].width, rY + images[2].height, images[5].width, rH - (images[2].height + images[8].height))
			End If
			'DrawCenter
			If bTileCenter
				ifsoGUI_VP.Add(rX, rY, rW, rH)
				For Local iY:Int = rY + images[0].height To rY + rH - images[7].height
					For Local iX:Int = rX + images[3].width To rX + rW - images[5].width
						ifsoGUI_VP.DrawImageArea(images[4], iX, iY)
						iX:+images[4].width - 1
					Next
					iY:+images[4].height - 1
				Next
				ifsoGUI_VP.Pop()
			Else
				ifsoGUI_VP.DrawImageAreaRect(images[4], rX + images[3].width, rY + images[1].height, rW - (images[3].width + images[5].width), rH - (images[1].height + images[7].height))
			End If
		Else
			'Draw Center
			If bTileCenter
				ifsoGUI_VP.Add(rX, rY, rW, rH)
				For Local iY:Int = rY To rY + rH
					For Local iX:Int = rX To rX + rW
						ifsoGUI_VP.DrawImageArea(images[4], iX, iY)
						iX:+images[4].width - 1
					Next
					iY:+images[4].height - 1
				Next
				ifsoGUI_VP.Pop()
			Else
				ifsoGUI_VP.DrawImageAreaRect(images[4], rX, rY, rW, rH)
			End If
		End If
	End Function
	
	Function DrawBox2(img:ifsoGUI_Image, rX:Int, rY:Int, rW:Int, rH:Int, bDrawBorder:Int = True, bTileSides:Int = False, bTileCenter:Int = False)
		If bDrawBorder
'			'Corners
			ifsoGUI_VP.DrawImageArea2(img, rX, rY, 0)
			ifsoGUI_VP.DrawImageArea2(img, (rX + rW) - img.w[2], rY, 2)
			ifsoGUI_VP.DrawImageArea2(img, rX, (rY + rH) - img.h[6], 6)
			ifsoGUI_VP.DrawImageArea2(img, (rX + rW) - img.w[8], (rY + rH) - img.h[8], 8)
			'sides
			If bTileSides
				'Top
				ifsoGUI_VP.Add(rX + img.w[0], rY, rW - (img.w[0] + img.w[2]), img.h[1])
				For Local iX:Int = rX + img.w[0] To rX + rW - img.w[2]
					ifsoGUI_VP.DrawImageArea2(img, iX, rY, 1)
					iX:+img.w[1] - 1
				Next
				ifsoGUI_VP.Pop()
			'Bottom
				ifsoGUI_VP.Add(rX + img.w[6], rY + rH - img.h[7], rW - (img.w[6] + img.w[8]), img.h[7])
				For Local iX:Int = rX + img.w[6] To rX + rW - img.w[8]
					ifsoGUI_VP.DrawImageArea2(img, iX, rY + rH - img.h[7], 7)
					iX:+img.w[7] - 1
				Next
				ifsoGUI_VP.Pop()
				'Left
				ifsoGUI_VP.Add(rX, rY + img.h[0], img.w[3], rH - (img.h[0] + img.h[6]))
				For Local iY:Int = rY + img.h[0] To rY + rH - img.h[6]
					ifsoGUI_VP.DrawImageArea2(img, rX, iY, 3)
					iY:+img.h[3] - 1
				Next
				ifsoGUI_VP.Pop()
				'Right
				ifsoGUI_VP.Add(rX + rW - img.w[5], rY + img.h[0], img.w[5], rH - (img.h[2] + img.h[8]))
				For Local iY:Int = rY + img.h[2] To rY + rH - img.h[8]
					ifsoGUI_VP.DrawImageArea2(img, rX + rW - img.w[5], iY, 5)
					iY:+img.h[5] - 1
				Next
				ifsoGUI_VP.Pop()
			Else
				ifsoGUI_VP.DrawImageAreaRect2(img, rX + img.w[0], rY, rW - (img.w[0] + img.w[2]), img.h[1], 1)
				ifsoGUI_VP.DrawImageAreaRect2(img, rX + img.w[6], (rY + rH) - img.h[7], rW - (img.w[6] + img.w[8]), img.h[7], 7)
				ifsoGUI_VP.DrawImageAreaRect2(img, rX, rY + img.h[0], img.w[3], rH - (img.h[0] + img.h[6]), 3)
				ifsoGUI_VP.DrawImageAreaRect2(img, (rX + rW) - img.w[5], rY + img.h[2], img.w[5], rH - (img.h[2] + img.h[8]), 5)
			End If
			'DrawCenter
			If bTileCenter
				ifsoGUI_VP.Add(rX, rY, rW, rH)
				For Local iY:Int = rY + img.h[0] To rY + rH - img.h[7]
					For Local iX:Int = rX + img.w[3] To rX + rW - img.w[5]
						ifsoGUI_VP.DrawImageArea2(img, iX, iY, 4)
						iX:+img.w[4] - 1
					Next
					iY:+img.h[4] - 1
				Next
				ifsoGUI_VP.Pop()
			Else
				ifsoGUI_VP.DrawImageAreaRect2(img, rX + img.w[3], rY + img.h[1], rW - (img.w[3] + img.w[5]), rH - (img.h[1] + img.h[7]), 4)
			End If
		Else
			'Draw Center
			If bTileCenter
				ifsoGUI_VP.Add(rX, rY, rW, rH)
				For Local iY:Int = rY To rY + rH
					For Local iX:Int = rX To rX + rW
						ifsoGUI_VP.DrawImageArea2(img, iX, iY, 4)
						iX:+img.w[4] - 1
					Next
					iY:+img.h[4] - 1
				Next
				ifsoGUI_VP.Pop()
			Else
				ifsoGUI_VP.DrawImageAreaRect2(img, rX, rY, rW, rH, 4)
			End If
		End If
	End Function
	
	Rem
	bbdoc: Gets the dimensions from the dimension file for the gadgets graphics.
	about: Internal function should not be called by the user.
	End Rem
	Function GetDimensions:String(strName:String, strSkin:String = "")
		Local skinpath:String
		If strSkin = ""
			skinpath = GUI.ThemePath
		Else
			skinpath = strSkin
		End If
		Local f:TStream = ReadFile(GUI.FileHeader + skinpath + "/graphics/dimensions.txt")
		Repeat
			If f.Eof() Exit
			Local tmpLine:String = f.ReadLine()
			Local dimensions:String[] = tmpLine.Split(",")
			If dimensions[0] = strName
				f.Close()
			 Return tmpLine
			End If
		Forever
		f.Close
		Return ""
	End Function
	Rem
	bbdoc: Loads the graphics for an image in 9 standard parts.
	about: Internal function should not be called by the user.
	End Rem
	Function Load9Image(srcpath:String, dimensions:String[], gImage:TImage[] Var, strSkin:String = "")
'load in theme image
		Local skinpath:String
		If strSkin = ""
			skinpath = GUI.ThemePath
		Else
			skinpath = strSkin
		End If
		Local image:TImage = LoadImage(GUI.FileHeader + skinpath + srcpath)
		Local mainmap:TPixmap = LockImage(image)
		Local imagew:Int[9], imageh:Int[9]
		
		Local a:Int = 1
		For Local i:Int = 0 To 8
			imagew[i] = Int(dimensions[a])
			a:+1
			imageh[i] = Int(dimensions[a])
			a:+1
		Next
		
		'create the nine images
		Local pixmap:TPixmap[9]
		gImage = New TImage[9]

		For Local count:Int = 0 To 8
			gImage[count] = CreateImage(imagew[count], imageh[count])
			pixmap[count] = LockImage(gImage[count])
		Next
		
		'copy the pixels
		Local srcx:Int, srcy:Int, destx:Int, desty:Int
		'Top Left Corner
		For srcy = 0 To imageh[0] - 1
			For srcx = 0 To imagew[0] - 1
				WritePixel(pixmap[0], srcx, srcy, ReadPixel(mainmap, srcx, srcy))
			Next
		Next
'Top Center
		For srcy = 0 To imageh[0] - 1
			destx = 0
			For srcx = imagew[0] To imagew[0] + imagew[1] - 1
				WritePixel(pixmap[1], destx, srcy, ReadPixel(mainmap, srcx, srcy))
				destx:+1
			Next
		Next
		'Top Right Corner
		For srcy = 0 To imageh[0] - 1
			destx = 0
			For srcx = imagew[0] + imagew[1] To imagew[0] + imagew[1] + imagew[2] - 1
				WritePixel(pixmap[2], destx, srcy, ReadPixel(mainmap, srcx, srcy))
				destx:+1
			Next
		Next
		'Left Side
		For srcy = imageh[0] To imageh[0] + imageh[3] - 1
			destx = 0
			For srcx = 0 To imagew[3] - 1
				WritePixel(pixmap[3], destx, desty, ReadPixel(mainmap, srcx, srcy))
				destx:+1
			Next
			desty:+1
		Next
		'Middle
		desty = 0
		For srcy = imageh[0] To imageh[0] + imageh[3] - 1
			destx = 0
			For srcx = imagew[3] To imagew[3] + imagew[4] - 1
				WritePixel(pixmap[4], destx, desty, ReadPixel(mainmap, srcx, srcy))
				destx:+1
			Next
			desty:+1
		Next
		'Right Side
		desty = 0
		For srcy = imageh[0] To imageh[0] + imageh[3] - 1
			destx = 0
			For srcx = imagew[3] + imagew[4] To imagew[3] + imagew[4] + imagew[5] - 1
				WritePixel(pixmap[5], destx, desty, ReadPixel(mainmap, srcx, srcy))
				destx:+1
			Next
			desty:+1
		Next
		'Bottom Left Corner
		desty = 0
		For srcy = imageh[0] + imageh[3] To imageh[0] + imageh[3] + imageh[6] - 1
			destx = 0
			For srcx = 0 To imagew[6] - 1
				WritePixel(pixmap[6], destx, desty, ReadPixel(mainmap, srcx, srcy))
				destx:+1
			Next
			desty:+1
		Next
		'Bottom Center
		desty = 0
		For srcy = imageh[0] + imageh[3] To imageh[0] + imageh[3] + imageh[6] - 1
			destx = 0
			For srcx = imagew[6] To imagew[6] + imagew[7] - 1
				WritePixel(pixmap[7], destx, desty, ReadPixel(mainmap, srcx, srcy))
				destx:+1
			Next
			desty:+1
		Next
		'Bottom Right Corner
		desty = 0
		For srcy = imageh[0] + imageh[3] To imageh[0] + imageh[3] + imageh[6] - 1
			destx = 0
			For srcx = imagew[6] + imagew[7] To imagew[6] + imagew[7] + imagew[8] - 1
				WritePixel(pixmap[8], destx, desty, ReadPixel(mainmap, srcx, srcy))
				destx:+1
			Next
			desty:+1
		Next
		
		'unlock images
		For Local count:Int = 0 To 8
			UnlockImage(gImage[count])
			SetImageHandle(gImage[count], 0, 0)
		Next
		UnlockImage(image)
		image = Null
	End Function

		Function Load9Image2(srcpath:String, dimensions:String[], gImage:ifsoGUI_Image Var, strSkin:String = "")
'load in theme image
		Local skinpath:String
		If strSkin = ""
			skinpath = GUI.ThemePath
		Else
			skinpath = strSkin
		End If
		gImage.img = LoadImage(GUI.FileHeader + skinpath + srcpath, 0)
		Local a:Int = 1
		For Local i:Int = 0 To 8
			gImage.w[i] = Int(dimensions[a])
			a:+1
			gImage.h[i] = Int(dimensions[a])
			a:+1
		Next
		gImage.x[1] = gImage.w[0]
		gImage.x[2] = gImage.w[0] + gImage.w[1]
		gImage.x[4] = gImage.w[3]
		gImage.x[5] = gImage.w[3] + gImage.w[4]
		gImage.x[7] = gImage.w[6]
		gImage.x[8] = gImage.w[6] + gImage.w[7]
		gImage.y[3] = gImage.h[0]
		gImage.y[4] = gImage.h[0]
		gImage.y[5] = gImage.h[0]
		gImage.y[6] = gImage.h[0] + gImage.h[3]
		gImage.y[7] = gImage.h[0] + gImage.h[3]
		gImage.y[8] = gImage.h[0] + gImage.h[3]
	End Function

'User Functions/Properties
	Rem
	bbdoc: Adds a child gadget to the gadget.
	End Rem
	Method AddChild(gadget:ifsoGUI_Base) ;End Method  'Add a child to the gadget
	Method AddSound(iSoundEvent:Int, sndSound:TSound)
		Sounds[iSoundEvent - 1] = sndSound
	End Method
	Rem
	bbdoc: Removes a child gadget from the gadget.
	End Rem
	Method RemoveChild(gadget:ifsoGUI_Base, bDestroy:Int = True) ; End Method 'Removes a child from the gadget
	Rem
	bbdoc: Sets the tesxt color of the gadget.
	End Rem
	Method SetTextColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of gadgets text
		TextColor[0] = iRed
		TextColor[1] = iGreen
		TextColor[2] = iBlue
	End Method
	Rem
	bbdoc: Sets the gadget color of the gadget.
	End Rem
	Method SetGadgetColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of the gadget
		Color[0] = iRed
		Color[1] = iGreen
		Color[2] = iBlue
	End Method
	Rem
	bbdoc: Sets the font of the gadget.
	about: Set to Null to use the default GUI font.
	End Rem
	Method SetFont(Font:TImageFont) 'Set the font of the gadget
	 fFont = Font
		Refresh()
	End Method
	Rem
	bbdoc: Returns the font the gadget is using.
	End Rem
	Method GetFont:TImageFont()
		Return fFont
	End Method
	Rem
	bbdoc: Brings the gadget to the front of its parents child list. 
	End Rem
	Method BringToFront()
		If Parent = Null
			GUI.BringToFront(Self)
		Else
			Parent.Children.Remove(Self)
			If OnTop
				Parent.Children.AddLast(Self)
			Else
				Local t:TLink = Parent.Children.LastLink()
				While t
					If Not ifsoGUI_Base(t.Value()).OnTop Exit
					t = t.PrevLink()
				Wend
				If Not t
					Parent.Children.AddFirst(Self)
				Else
					Parent.Children.InsertAfterLink(Self, t)
				End If
			End If
		End If
	End Method
	Rem
	bbdoc: Send sthe gadget to the back of its parent child list.
	End Rem
	Method SendToBack()
		If OnTop Return
		If Parent = Null
			GUI.Gadgets.Remove(Self)
			GUI.Gadgets.AddLast(Self)
		Else
			Parent.Children.Remove(Self)
			Parent.Children.AddFirst(Self)
		End If
	End Method
	Rem
	bbdoc: Sets the gadget enabled/disabled.
	End Rem
	Method SetEnabled(bEnabled:Int = True) 'Sets the gadget enabled or not.
		If Enabled = bEnabled Return
		Enabled = bEnabled
		If Not bEnabled
			If GUI.gActiveGadget = Self GUI.SetActiveGadget(Null)
			If GUI.gMouseOverGadget = Self GUI.gMouseOverGadget = Null
		End If
	End Method
	Rem
	bbdoc: Returns whether the gadget is enabled.
	End Rem
	Method GetEnabled:Int()
		Return Enabled
	End Method
	Rem
	bbdoc: Set a custom property.
	End Rem
	Method SetProperty(key:String, value:Object)
	 customProperties.Insert(key, value)
	EndMethod
	Rem
	bbdoc: Returns a custom property
	End Rem
	Method GetProperty:Object(key:String)
	 Return customProperties.ValueForKey(key)
	EndMethod
	Rem
	bbdoc: Clears the custom properties.
	End Rem
	Method ClearProperties()
	 customProperties.Clear()
	EndMethod
	Rem
	bbdoc: Sets whether the gadget is visible.
	End Rem
	Method SetVisible(bVisible:Int)
		If Visible = bVisible Return
		Visible = bVisible
		If Not bVisible
			If GUI.gActiveGadget = Self GUI.SetActiveGadget(Null)
			If GUI.gMouseOverGadget = Self GUI.gMouseOverGadget = Null
			If IsMyChild(GUI.gActiveGadget) GUI.SetActiveGadget(Null)
			If IsMyChild(GUI.gMouseOverGadget) GUI.gMouseOverGadget = Null
		End If
		If Parent Parent.ChildMoved(Self)
	End Method
	Rem
	bbdoc: Returns whether the gadget is visible.
	End Rem
	Method GetVisible:Int()
		Return Visible
	End Method
	Rem
	bbdoc: Sets the gadget tip text.
	End Rem
	Method SetTip(strTip:String) 'Sets the Tip Text
		Tip = strTip
	End Method
	Rem
	bbdoc: Returns the gadgets tip text.
	End Rem
	Method GetTip:String()
		Return Tip
	End Method
	Rem
	bbdoc: Set the gadget tip delay.
	endrem
	Method SetTipDelay(iTime:Int) 'Set the Tip Delay
		Tip_delay = iTime
	End Method
	Rem
	bbdoc: Get the gadget tip delay.
	endrem
	Method GetTipDelay:Int() 'Get the Tip Delay
		Return Tip_delay
	End Method
	Rem
	bbdoc: Sets whether the gadget is transparent.
	End Rem
	Method SetTransparent(bTransparent:Int)
		boolTransparent = bTransparent
		If Parent Parent.ChildMoved(Self)
	End Method
	Rem
	bbdoc: Returns whether the gadget is transparent.
	End Rem
	Method GetTransparent:Int()
		Return boolTransparent
	End Method
	Rem
	bbdoc: Sets the gadgets width and height.
	End Rem
	Method SetWH(width:Int, height:Int)
 	w = width
		h = height
		Refresh()
		If Parent Parent.ChildMoved(Self)
	End Method
	Rem
	bbdoc: Retrieves the gadgets width and height.
	End Rem
	Method GetWH(width:Int Var, height:Int Var)
		width = w
		height = h
	End Method
	Rem
	bbdoc: Returns the gadgets width.
	End Rem
	Method GetW:Int()
		Return w
	End Method
	Rem
	bbdoc: Returns the gadgets height.
	End Rem
	Method GetH:Int()
		Return h
	End Method
	Rem
	bbdoc: Sets the gadgets x and y position.
	End Rem
	Method SetXY(iX:Int, iY:Int)
		x = iX
		y = iY
		If Parent Parent.ChildMoved(Self)
	End Method
	Rem
	bbdoc: Retreives the gadgets x and y positions.
	End Rem
	Method GetXY(iX:Int Var, iY:Int Var)
		iX = x
		iY = y
	End Method
	Rem
	bbdoc: Retrieves the gadgets Aobsolute x and y position.
	about: This returns true x and y values from the top left corner of the screen.
	End Rem
	Method GetAbsoluteXY(iX:Int Var, iY:Int Var, caller:ifsoGUI_Base = Null)
		If Parent
			Parent.GetAbsoluteXY(iX, iY, Self)
		ElseIf Master
			Master.GetAbsoluteXY(iX, iY, Self)
		End If
		iX:+x
		iY:+y
	End Method
	Rem
	bbdoc: Sets the x, y, width, and height all in one call.
	End Rem
	Method SetBounds(iX:Int, iY:Int, iW:Int, iH:Int)
		x = iX
		y = iY
 	w = iW
		h = iH
		Refresh()
		If Parent Parent.ChildMoved(Self)
	End Method
	Rem
	bbdoc: Sets the event callback function for the gadget.
	End Rem
	Method SetCallBack(func(gadget:ifsoGUI_Base, id:Int, data:Int, iMouseX:Int, iMouseY:Int))
		CallBack = func
	End Method
	Rem
	bbdoc: Sets the gadgets alpha value.
	End Rem
	Method SetGadgetAlpha(fltAlpha:Float)
		fAlpha = fltAlpha
	End Method
	Rem
	bbdoc: Returns the gadgets alpha value.
	End Rem
	Method GetGadgetAlpha:Float()
		Return fAlpha
	End Method
	Rem
	bbdoc: Gives the gadget the focus.
	about: This sets this gadget as the Active Gadget.
	End Rem
	Method SetFocus()
		GUI.SetActiveGadget(Self)
	End Method
	Rem
	bbdoc: Sets the gadgets focus box color.
	End Rem
	Method SetFocusColor(iRed:Int, iGreen:Int, iBlue:Int) 'Set color of gadgets focus box
		FocusColor[0] = iRed
		FocusColor[1] = iGreen
		FocusColor[2] = iBlue
	End Method
	Rem
	bbdoc: Sets whether or not to show the focus box for this gadget.
	End Rem
	Method SetShowFocus(intShowFocus:Int)
		ShowFocus = intShowFocus
	End Method
	Rem
	bbdoc: Returns whether or not the gadget will show the focus box.
	End Rem
	Method GetShowFocus:Int()
		Return ShowFocus
	End Method
	Rem
	bbdoc: Sets the gadget to always be on top of other gadgets.
	End Rem
	Method SetAlwaysOnTop(iOnTop:Int)
		OnTop = iOnTop
		If OnTop BringToFront()
	End Method
	Rem
	bbdoc: Returns whether or not the gadget is always on top.
	End Rem
	Method GetAlwaysOnTop:Int()
		Return OnTop
	End Method
	Rem
	bbdoc: Sets whether or not to the gadget will autosize or be manually controlled by the user.
	End Rem
	Method SetAutoSize(intAutoSize:Int)
		AutoSize = intAutoSize
		Refresh()
	End Method
	Rem
	bbdoc: Returns whether or not to the gadget will autosize or be manually controlled by the user.
	End Rem
	Method GetAutoSize:Int()
		Return AutoSize
	End Method
	Rem
	bbdoc: Sets the gadgets TabOrder. 0=Do not tab to this gadget -1=Last in the Tab Order
	End Rem
	Method SetTabOrder(iTabOrder:Int)
		If TabOrder = -2 Return
		If Master Return
		TabOrder = iTabOrder
		GUI.ChangeTabOrder(Self)
	End Method
	Rem
	bbdoc: Returns the gadgets TabOrder
	End Rem
	Method GetTabOrder:Int()
		Return TabOrder
	End Method
	Rem
	bbdoc: Adds itself and its children to the GUI TabOrder List
	End Rem
	Method AddTabOrder()
		If TabOrder <> - 2 GUI.ChangeTabOrder(Self)
		For Local g:ifsoGUI_Base = EachIn Children
			g.AddTabOrder()
		Next
	End Method
	Rem
	bbdoc: Removes itself and its children from the GUI TabOrder List
	End Rem
	Method RemoveTabOrder()
		If TabOrder <> - 2 GUI.RemoveTabOrder(Self)
		For Local g:ifsoGUI_Base = EachIn Children
			g.RemoveTabOrder()
		Next
	End Method

	'Method SetValue(Value:Type) 'Each gadget with a value should have a set value.
	'Method GetValue:Type 'Each gadget with a value should have a get value.

End Type
