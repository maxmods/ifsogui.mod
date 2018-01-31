' Ifsogui Editor

' Version: 1.18 
' License: zlib
' Copyright: (c) 2009-2018 Marcus Trisdale, Mark Mcvittie

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
'Import pub.win32

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

'Include "../incbinSkin.bmx"
'Incbin "Skins.zip"
Incbin "../Skin2/fonts/arial.ttf"
Incbin "../icons/load.png"
Incbin "../icons/save.png"
Incbin "../icons/alignleft.png"
Incbin "../icons/aligncenter.png"
Incbin "../icons/alignright.png"
Incbin "../icons/aligntop.png"
Incbin "../icons/alignmiddle.png"
Incbin "../icons/alignbottom.png"
Incbin "../icons/moveforward.png"
Incbin "../icons/moveback.png"
Incbin "../icons/showcode.png"
Incbin "../icons/preview.png"

Local initW% = 320, initH% = 240 'v1.18
Global AppW% = initW, AppH% = initH
Local FLAGS:Int = WINDOW_TITLEBAR|WINDOW_RESIZABLE|WINDOW_CLIENTCOORDS
Local timer:TTimer = CreateTimer(60)
Local old_ms:Int=MilliSecs()

Global AppProps:TAppProps = New TAppProps
Global ActiveProps:TProps = AppProps
Global cbGadgets:ifsoGUI_Combobox
Global SelectColor:Int[] = [255, 0, 0]
Global SelectedProps:TList = New TList
Global bShowPreview:Int

Include "CheckEvents.bmx"
Include "ClientArea.bmx"
Include "GadgetProps.bmx"

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
'GUI.SetUseIncBin(True) ' Bug: SetUseIncBin crash at LoadTheme > GadgetCallbacks[]
'GUI.SetZipInfo("Skins.zip", "") ' Bug: zip files cause random crash at init
Local skinpath$="../" ' load skin2 from main mod folder
GUI.LoadTheme(skinpath + "Skin2")
Local font:TImageFont = LoadImageFont("incbin::" + skinpath + "Skin2/fonts/arial.ttf", 14)
GUI.SetDefaultFont(font)
GUI.SetDrawMouse(False)
HideMouse()

ClientArea.Init()

SetImageFont(font)
Local iFPSCounter:Int, iFPSTime:Int = MilliSecs(), iFPS:Int 'for the FPS Counter
SetClsColor(200, 200, 200)
SetBlend(ALPHABLEND)

Repeat
	Select WaitEvent()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			End
		Default
			SetGraphics CanvasGraphics(canvas)
			SetViewport 0, 0, ClientWidth(canvas), ClientHeight(canvas)
			
			If KeyHit(KEY_ESCAPE) 
				If Not bShowPreview Then Exit
				If bShowPreview Then Preview()
			EndIf
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
			End If
			
			GUI.DrawMouse()
			CheckEvents()
			SetColor(0, 0, 0)
			DrawText(iFPS, AppW-40, 1)
			
			iFPSCounter:+1
			If MilliSecs() - iFPSTime > 1000
				iFPS = iFPSCounter
				iFPSTime = MilliSecs()
				iFPSCounter = 0
			End If
			Flip 0
	EndSelect
Forever
End

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
			'Graphics(AppW, AppH)
			SetGraphics CanvasGraphics(canvas)
			SetViewport 0, 0, AppW, AppH
			
			SetClsColor(200, 200, 200)
			SetBlend(ALPHABLEND)
		End If
		ClientArea.pnlScreen.SetBounds(0, 25, AppW-200, AppH-25)
		ClientArea.pnlScreen.SetFocus()
	Else
		bShowPreview = True
		ClientArea.pnlToolbar.SetVisible(False)
		ClientArea.tabConfig.SetVisible(False)
		If ClientArea.Screen.w <> AppW And ClientArea.Screen.h <> AppH
			'Graphics(ClientArea.Screen.w, ClientArea.Screen.h)
			SetGraphics CanvasGraphics(canvas)
			SetViewport 0, 0, ClientArea.Screen.w, ClientArea.Screen.h
			
			SetBlend(ALPHABLEND)
		End If
		ClientArea.pnlScreen.SetBounds(0, 0, ClientArea.Screen.w, ClientArea.Screen.h)
	End If
End Function

Function CopyToClipBoard() 'for multiline textbox
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

