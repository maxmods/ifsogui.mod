' save.bmx

SuperStrict

' Import
Framework brl.glmax2d
Import brl.freetypefont
Import brl.pngloader

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

Include "../incbinSkin.bmx"

' Init
SetGraphicsDriver GLMax2DDriver()
Graphics(1223, 779)
GUI.SetResolution(1223, 779)
GUI.SetUseIncBin(True)
GUI.LoadTheme("Skin2")
GUI.SetDefaultFont(LoadImageFont("incbin::Skin2/fonts/arial.ttf", ))
GUI.SetDrawMouse(True)

'Init GUI
Local wndWindow1:ifsoGUI_Window = ifsoGUI_Window.Create(10, 10, 624, 591, "wndWindow1")
wndWindow1.SetCaption("wndWindow1")
GUI.AddGadget(wndWindow1)

Local cmbCombobox1:ifsoGUI_ComboBox = ifsoGUI_ComboBox.Create(10, 10, 120, 24, "cmbCombobox1")
cmbCombobox1.AddItem("Item 1", 0, "", False)
cmbCombobox1.AddItem("Item 2", 0, "", False)
cmbCombobox1.SetSelected(0)
wndWindow1.AddChild(cmbCombobox1)

Local lstListbox1:ifsoGUI_Listbox = ifsoGUI_Listbox.Create(44, 71, 120, 100, "lstListbox1")
lstListbox1.AddItem("Item 1", 0, "")
lstListbox1.AddItem("Item 2", 0, "")
lstListbox1.AddItem("Item 3", 0, "")
lstListbox1.AddItem("Item 4", 0, "")
lstListbox1.AddItem("Item 5", 0, "")
lstListbox1.AddItem("Item 6", 0, "")
lstListbox1.AddItem("Item 7", 0, "")
lstListbox1.SetSelected(0, True)
wndWindow1.AddChild(lstListbox1)

Local mltMLTextbox1:ifsoGUI_MLTextbox = ifsoGUI_MLTextbox.Create(50, 204, 240, 200, "mltMLTextbox1")
mltMLTextbox1.SetValue("Textbox")
wndWindow1.AddChild(mltMLTextbox1)

Local tabTabber1:ifsoGUI_Tabber = ifsoGUI_Tabber.Create(351, 61, 200, 200, "tabTabber1", 2)
tabTabber1.SetTabText(0, "Tab 1")
tabTabber1.SetTabText(1, "Tab 2")
tabTabber1.SetCurrentTab(0)
wndWindow1.AddChild(tabTabber1)

Local btnButton1:ifsoGUI_Button = ifsoGUI_Button.Create(10, 10, 100, 24, "btnButton1", "btnButton1")
tabTabber1.AddTabChild(btnButton1, 1)

Local txtTextbox1:ifsoGUI_Textbox = ifsoGUI_Textbox.Create(10, 10, 100, 24, "txtTextbox1", "txtTextbox1")
tabTabber1.AddTabChild(txtTextbox1, 0)

' Main
SetClsColor(200, 200, 200)
While Not AppTerminate()
	Cls
	GUI.Refresh()
	Flip 0
Wend
End
