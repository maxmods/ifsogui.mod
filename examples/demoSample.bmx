' demo - button, textbox, image button - also panel, label

SuperStrict

Framework brl.glmax2d
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

SetGraphicsDriver GLMax2DDriver()
Graphics(800, 600)
GUI.SetResolution(800, 600)
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
Local window:ifsoGUI_Window = ifsoGUI_Window.Create(10, 10, 400, 400, "win")
window.SetDragable(True)
window.SetDragTop(True)
window.SetResizable(True)
window.SetCaption("Sample Controls Window")
GUI.AddGadget(window)
Local button:ifsoGUI_Button = ifsoGUI_Button.Create(5, 5, 50, 25, "button", "Button")
window.AddChild(button)
Local textbox:ifsoGUI_TextBox = ifsoGUI_TextBox.Create(5, 35, 200, 25, "textbox", "Sample textbox")
window.AddChild(textbox)
Local imageButton:ifsoGUI_ImageButton = ifsoGUI_ImageButton.Create(24, 64, 32, 32, "imageButton", "Image Button")
imageButton.SetImages(LoadImage("../icons/load.png"), LoadImage("../icons/moveback.png"), LoadImage("../icons/moveforward.png"))
window.AddChild(imageButton)

Local iFPSCounter:Int, iFPSTime:Int, iFPS:Int 'For the FPS Counter

SetClsColor(200, 200, 200)
While Not AppTerminate()
	Cls
	CheckEvents()
	iFPSCounter:+1
	If MilliSecs() - iFPSTime > 1000
		iFPS = iFPSCounter
		iFPSTime = MilliSecs()
		iFPSCounter = 0
		ifsoGUI_Label(GUI.GetGadget("FPSLabel")).SetLabel("FPS: " + iFPS)
	End If
	GUI.Refresh()
	Flip 0
Wend

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
