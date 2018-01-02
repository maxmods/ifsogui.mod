SuperStrict

' Import
Framework brl.glmax2d
Import brl.FreeTypeFont

Import ifsogui.GUI
Import ifsogui.panel
Import ifsogui.window
Import ifsogui.label
Import ifsogui.listbox
Import ifsogui.mclistbox
Import ifsogui.checkbox
Import ifsogui.button
Import ifsogui.textbox
Import ifsogui.progressbar
Import ifsogui.slider
Import ifsogui.combobox
Import ifsogui.spinner
Import ifsogui.imagebutton
Import ifsogui.tabber
Import ifsogui.mltextbox
Import ifsogui.fileselect

Include "../editor/incbinSkin.bmx"

' Init
SetGraphicsDriver GLMax2DDriver()
Graphics(800, 600)
GUI.SetResolution(800, 600)
GUI.SetUseIncBin(True) ' add incbin:: to path
'GUI.SetZipInfo("Skins.zip", "") ' add zip:: to path
GUI.LoadTheme("Skin2") ' add Skin name to path
GUI.SetDefaultFont(LoadImageFont(GUI.FileHeader + "Skin2/fonts/arial.ttf", 12))
GUI.SetDrawMouse(True)

' Test Editor Code Here
Local wndWindow1:ifsoGUI_Window = ifsoGUI_Window.Create(10, 10, 511, 360, "wndWindow1")
wndWindow1.SetCaption("wndWindow1")
GUI.AddGadget(wndWindow1)

Local tabTabber1:ifsoGUI_Tabber = ifsoGUI_Tabber.Create(10, 10, 200, 200, "tabTabber1", 2)
tabTabber1.SetTabText(0, "Tab 1")
tabTabber1.SetTabText(1, "New Tab1")
wndWindow1.AddChild(tabTabber1)

Local chkCheckbox1:ifsoGUI_CheckBox = ifsoGUI_CheckBox.Create(10, 10, 120, 24, "chkCheckbox1", "chkCheckbox1")
tabTabber1.AddTabChild(chkCheckbox1, 0)

Local chkCheckbox2:ifsoGUI_CheckBox = ifsoGUI_CheckBox.Create(10, 10, 120, 24, "chkCheckbox2", "chkCheckbox2")
tabTabber1.AddTabChild(chkCheckbox2, 1)

Local tabTabber2:ifsoGUI_Tabber = ifsoGUI_Tabber.Create(249, 13, 200, 200, "tabTabber2", 2)
tabTabber2.SetTabText(0, "Tab 2")
tabTabber2.SetTabText(1, "New Tab2")
wndWindow1.AddChild(tabTabber2)

Local btnButton1:ifsoGUI_Button = ifsoGUI_Button.Create(10, 10, 100, 24, "btnButton1", "btnButton1")
tabTabber2.AddTabChild(btnButton1, 0)

Local btnButton2:ifsoGUI_Button = ifsoGUI_Button.Create(10, 10, 100, 24, "btnButton2", "btnButton2")
tabTabber2.AddTabChild(btnButton2, 1)

' Main
Local iFPSCounter:Int, iFPSTime:Int, iFPS:Int 'For the FPS Counter
SetClsColor(200, 200, 200)
While Not AppTerminate()
	Cls
	GUI.Refresh()
	iFPSCounter:+1
	If MilliSecs() - iFPSTime > 1000
		iFPS = iFPSCounter
		iFPSTime = MilliSecs()
		iFPSCounter = 0
	End If
	Flip 0
Wend
End
