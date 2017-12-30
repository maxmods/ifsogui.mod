SuperStrict

Framework brl.glmax2d
Import brl.FreeTypeFont
Import brl.PNGLoader

'Import ifsoguidemo.GUI
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

Include "../editor/incbinSkin.bmx"

SetGraphicsDriver GLMax2DDriver()
Graphics(800, 600)
GUI.SetResolution(800, 600)
GUI.SetUseIncBin(True)
GUI.LoadTheme("Skin2")
GUI.SetDefaultFont(LoadImageFont("../editor/Skin2/fonts/arial.ttf", 12))
GUI.SetDrawMouse(True)

'Status Window
Local window:ifsoGUI_Window = ifsoGUI_Window.Create(650, 480, 140, 110, "StatusPanel")
window.SetDragable(True)
window.SetCaption("Status Window")
GUI.AddGadget(window)
window.AddChild(ifsoGUI_Label.Create(5, 5, 100, 20, "FPSLabel"))

'Control Window
window = ifsoGUI_Window.Create(10, 10, 400, 400, "win")
window.SetDragable(True)
window.SetDragTop(True)
window.SetResizable(True)
window.SetCaption("Sample Controls Window")
window.AddChild(ifsoGUI_Button.Create(5, 5, 50, 25, "button", "Button"))
window.AddChild(ifsoGUI_TextBox.Create(5, 35, 200, 25, "textbox", "Sample textbox"))
GUI.AddGadget(window)

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