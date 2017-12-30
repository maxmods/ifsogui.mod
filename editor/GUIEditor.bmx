SuperStrict

Framework brl.glmax2d
Import brl.FreeTypeFont
Import pub.Win32

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

?win32 ' not 64-bit compatible?
Extern "Win32"
	'Function SetClipboardData:Int(uFormat:Int, hMem:Byte Ptr)
	'Function EmptyClipboard:Int()
	'Function OpenClipboard(hWnd:Int)
	'Function CloseClipboard:Int()
	'Function GlobalAlloc:Byte Ptr(Flags:Int, Bytes:Int)
	'Function GlobalFree(Mem:Byte Ptr)
End Extern
?

'Incbin "Skins.zip"
Incbin "Skin2/fonts/arial.ttf"
Incbin "icons/load.png"
Incbin "icons/save.png"
Incbin "icons/alignleft.png"
Incbin "icons/aligncenter.png"
Incbin "icons/alignright.png"
Incbin "icons/aligntop.png"
Incbin "icons/alignmiddle.png"
Incbin "icons/alignbottom.png"
Incbin "icons/moveforward.png"
Incbin "icons/moveback.png"
Incbin "icons/showcode.png"
Incbin "icons/preview.png"

Const AppW:Int = 800, AppH:Int = 600
Global AppProps:TAppProps = New TAppProps
Global ActiveProps:TProps = AppProps
Global cbGadgets:ifsoGUI_Combobox
Global SelectColor:Int[] = [255, 0, 0]
Global SelectedProps:TList = New TList
Global bShowPreview:Int

Include "CheckEvents.bmx"
Include "ClientArea.bmx"
Include "GadgetProps.bmx"

SetGraphicsDriver GLMax2DDriver()
Graphics(AppW, AppH)
GUI.SetResolution(AppW, AppH)
'GUI.SetUseIncBin(True) ' this doesn't work
'GUI.SetZipInfo("Skins.zip", "")
GUI.LoadTheme("Skin2")
Local font:TImageFont = LoadImageFont("incbin::Skin2/fonts/arial.ttf", 14)
GUI.SetDefaultFont(font)
GUI.SetDrawMouse(False)
HideMouse()

ClientArea.Init()

SetImageFont(font)
Local iFPSCounter:Int, iFPSTime:Int = MilliSecs(), iFPS:Int 'For the FPS Counter

SetClsColor(200, 200, 200)
SetBlend(ALPHABLEND)
While Not AppTerminate()
	If KeyHit(KEY_ESCAPE) And bShowPreview Preview()
	Cls
	GUI.Refresh()
	If Not bShowPreview
		If ActiveProps <> AppProps
			ifsoGUI_VP.Push()
			ifsoGUI_VP.vpX = ClientArea.pnlScreen.x
			ifsoGUI_VP.vpY = ClientArea.pnlScreen.y
			ifsoGUI_VP.vpW = ClientArea.pnlScreen.GetClientWidth()
			ifsoGUI_VP.vpH = ClientArea.pnlScreen.GetClientHeight()
			ActiveProps.PropGadget.DrawSelection()
			If Not SelectedProps.IsEmpty()
				For Local p:TGadgetProps = EachIn SelectedProps
					p.PropGadget.DrawSelection()
				Next
			End If
			ifsoGUI_VP.Pop()
		End If
		GUI.DrawMouse()
		CheckEvents()
		SetColor(0, 0, 0)
		DrawText(iFPS, 760, 1)
	End If
	iFPSCounter:+1
	If MilliSecs() - iFPSTime > 1000
		iFPS = iFPSCounter
		iFPSTime = MilliSecs()
		iFPSCounter = 0
	End If
	Flip 0
Wend

Function WriteSource()
	ClientArea.mtbCode.SetValue("")
	For Local g:TPropGadget = EachIn ClientArea.Screen.Children
		g.WriteCode()
	Next
End Function

Function SaveProject(strProject:String)
	
End Function

Function LoadProject(strProject:String)
	
End Function

Function Preview()
	If bShowPreview
		bShowPreview = False
		ClientArea.pnlToolbar.SetVisible(True)
		ClientArea.tabConfig.SetVisible(True)
		If ClientArea.Screen.w <> AppW And ClientArea.Screen.h <> AppH
			Graphics(AppW, AppH)
			SetClsColor(200, 200, 200)
			SetBlend(ALPHABLEND)
		End If
		ClientArea.pnlScreen.SetBounds(0, 25, 600, 575)
		ClientArea.pnlScreen.SetFocus()
	Else
		bShowPreview = True
		ClientArea.pnlToolbar.SetVisible(False)
		ClientArea.tabConfig.SetVisible(False)
		If ClientArea.Screen.w <> AppW And ClientArea.Screen.h <> AppH
			Graphics(ClientArea.Screen.w, ClientArea.Screen.h)
			SetBlend(ALPHABLEND)
		End If
		ClientArea.pnlScreen.SetBounds(0, 0, ClientArea.Screen.w, ClientArea.Screen.h)
	End If
End Function

Function CopyToClipBoard()
?win32
Rem
	Const CF_TEXT:Int = 1
	Local s:String = ClientArea.mtbCode.GetSelection()
 If s <> ""
  Local CPTR:Byte Ptr = GlobalAlloc(GMEM_FIXED, Len(s) + 1)
  For Local i:Int = 0 Until Len(s)
   CPTR[i] = s[i]
  Next
  CPTR[Len(s) + 1] = 0
  If OpenClipboard(0)
   EmptyClipboard()
   SetClipboardData (CF_TEXT, CPTR)
   CloseClipboard()
  EndIf
  If CPTR Then GlobalFree (CPTR)
 EndIf
EndRem
?
End Function

