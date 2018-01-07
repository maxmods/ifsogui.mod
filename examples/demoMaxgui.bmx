' Maxgui demo - maximized window

SuperStrict

Framework brl.glmax2d
?linux
Import bah.gtkmaxgui
?Not linux
Import maxgui.drivers
?Not bmxng
Import brl.timer
?bmxng
Import brl.timerdefault
?
Import brl.eventqueue
Import brl.freetypefont
Import brl.pngloader

Import ifsogui.GUI
Import ifsogui.panel
Import ifsogui.window
Import ifsogui.label
Import ifsogui.listbox
Import ifsogui.checkbox
Import ifsogui.button
Import ifsogui.textbox
Import ifsogui.progressbar
Import ifsogui.slider
Import ifsogui.combobox
Import ifsogui.spinner
Import ifsogui.imagebutton

'Include "../incbinSkin.bmx"
Incbin "player.png"

Local initW% = 320, initH% = 240
Global AppW% = initW, AppH% = initH
Local FLAGS:Int = WINDOW_TITLEBAR|WINDOW_RESIZABLE|WINDOW_CLIENTCOORDS
Local timer:TTimer = CreateTimer(60)
Local old_ms:Int=MilliSecs()

Global window:TGadget = CreateWindow(AppTitle, 100, 100, initW, initH, Null, FLAGS)
MaximizeWindow(window) ' find maximum window area by maximizing, then init canvas
Repeat
	WaitEvent()
	Select EventID()
		Case EVENT_WINDOWCLOSE
			Exit
		Case EVENT_TIMERTICK
			AppW = window.ClientWidth() ' finding client size takes a few ticks
			AppH = window.ClientHeight()
			If AppW<>initW And AppH<>initH Then Exit
			If MilliSecs()-old_ms>1000 Then Exit ' exit after 1 second
	End Select
Forever

Global canvas:TGadget = CreateCanvas(0,0, AppW, AppH ,window)
SetGadgetLayout canvas, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED
ActivateGadget(canvas)
EnablePolledInput(canvas)
SetGraphics CanvasGraphics(canvas) ' use canvas context not GLMax2DDriver() which uses Graphics()

GUI.SetResolution(AppW, AppH)
'GUI.SetUseIncBin(True) ' see example1
GUI.LoadTheme("../Skin2") ' loading skin directly, no stream
GUI.SetDefaultFont(LoadImageFont("../Skin2/fonts/arial.ttf", 12))
GUI.SetDrawMouse(True)

'Status Window
Local panel:ifsoGUI_Panel = ifsoGUI_Panel.Create(650, 480, 140, 110, "StatusPanel")
panel.SetDragable(True)
GUI.AddGadget(panel)
panel.AddChild(ifsoGUI_Label.Create(5, 5, 100, 20, "FPSLabel"))

'Control Window
Local guiwindow:ifsoGUI_Window = ifsoGUI_Window.Create(10, 10, 400, 400, "win")
guiwindow.SetDragable(True)
guiwindow.SetDragTop(True)
guiwindow.SetResizable(True)
guiwindow.SetCaption("Sample Controls Window")
GUI.AddGadget(guiwindow)
Local button:ifsoGUI_Button = ifsoGUI_Button.Create(5, 5, 50, 25, "button", "Button")
guiwindow.AddChild(button)
Local textbox:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(5, 35, 200, 25, "textbox", "Sample textbox")
guiwindow.AddChild(textbox)
Local imageButton:ifsoGUI_ImageButton = ifsoGUI_ImageButton.Create(24, 64, 32, 32, "imageButton", "Image Button")
imageButton.SetImages(LoadImage("../icons/load.png"), LoadImage("../icons/moveback.png"), LoadImage("../icons/moveforward.png"))
guiwindow.AddChild(imageButton)

Local dude:TImage=LoadImage( "incbin::player.png" ), dude_x%=AppW/2, dude_y%=AppH/2
Local iFPSCounter:Int, iFPSTime:Int, iFPS:Int ' for the FPS Counter
SetClsColor(200, 200, 200)

While Not KeyDown(KEY_ESCAPE)
	Select WaitEvent()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			End
		Default
			SetGraphics CanvasGraphics(canvas)
			'SetVirtualResolution ClientWidth(canvas), ClientHeight(canvas)
			SetViewport 0, 0, ClientWidth(canvas), ClientHeight(canvas)
			SetColor 255,255,255
			Cls()
			
			CheckEvents()
			If KeyDown(KEY_UP) Then dude_y:-5
			If KeyDown(KEY_DOWN) Then dude_y:+5
			If KeyDown(KEY_LEFT) Then dude_x:-5
			If KeyDown(KEY_RIGHT) Then dude_x:+5
			
			SetBlend MASKBLEND
			DrawImage dude,dude_x,dude_y
			SetColor(255, 0, 0)
			DrawText "Arrow keys: move ship, MemAlloced = " + GCMemAlloced(), 20, AppH-20
			
			iFPSCounter:+1
			If MilliSecs() - iFPSTime > 1000
				iFPS = iFPSCounter
				iFPSTime = MilliSecs()
				iFPSCounter = 0
				ifsoGUI_Label(GUI.GetGadget("FPSLabel")).SetLabel("FPS: " + iFPS)
			End If
			GUI.Refresh()
			Flip()
	EndSelect
Wend

FreeGadget window
FreeGadget canvas
End

Function CheckEvents()
	Local e:ifsoGUI_Event
	Repeat
		e = GUI.GetEvent()
		If Not e Exit
		If e.id = ifsoGUI_EVENT_CHANGE Or e.id = ifsoGUI_EVENT_CLICK
			DebugLog "NAME: " + e.gadget.Name + " EVENT: " + e.EventString(e.id) + " DATA: " + e.data
		End If
	Forever
End Function
