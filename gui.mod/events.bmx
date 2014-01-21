Const ifsoGUI_EVENT_COUNT:Int = 18
Const ifsoGUI_EVENT_CLICK:Int = 1
Const ifsoGUI_EVENT_RIGHT_CLICK:Int = 2
Const ifsoGUI_EVENT_MIDDLE_CLICK:Int = 3
Const ifsoGUI_EVENT_DOUBLE_CLICK:Int = 4
Const ifsoGUI_EVENT_MOUSE_ENTER:Int = 5
Const ifsoGUI_EVENT_MOUSE_EXIT:Int = 6
Const ifsoGUI_EVENT_MOUSE_DOWN:Int = 7
Const ifsoGUI_EVENT_MOUSE_UP:Int = 8
Const ifsoGUI_EVENT_MOUSE_MOVE:Int = 9
Const ifsoGUI_EVENT_CHANGE:Int = 10
Const ifsoGUI_EVENT_KEYHIT:Int = 11
Const ifsoGUI_EVENT_GAIN_FOCUS:Int = 12
Const ifsoGUI_EVENT_LOST_FOCUS:Int = 13
Const ifsoGUI_EVENT_RESIZE:Int = 14
Const ifsoGUI_EVENT_CELL_CHANGE:Int = 15
Const ifsoGUI_EVENT_COPY:Int = 16
Const ifsoGUI_EVENT_CUT:Int = 17
Const ifsoGUI_EVENT_PASTE:Int = 18

Const ifsoGUI_EVENT_SYSTEM_NEW_THEME:Int = 100
Const ifsoGUI_EVENT_SYSTEM_NEW_DEFAULT_FONT:Int = 101
Const ifsoGUI_EVENT_SYSTEM_NEW_GADGET_COLOR:Int = 102
Const ifsoGUI_EVENT_SYSTEM_NEW_GADGET_TEXTCOLOR:Int = 103

	Rem
	bbdoc: Event Type.
	End Rem
Type ifsoGUI_Event
	Field gadget:ifsoGUI_Base 'Gadget that fired the event
	Field id:Int	'Event ID
	Field x:Int, y:Int 'Mouse Position of the event
	Field data:Int 'Extra data of the event
	
	Rem
	bbdoc: Returns the string associated with an event id.
	End Rem
	Function EventString:String(id:Int)
		Select id
			Case ifsoGUI_EVENT_CLICK Return "ifsoGUI_EVENT_CLICK"
			Case ifsoGUI_EVENT_DOUBLE_CLICK Return "ifsoGUI_EVENT_DOUBLE_CLICK"
			Case ifsoGUI_EVENT_RIGHT_CLICK Return "ifsoGUI_EVENT_RIGHT_CLICK"
			Case ifsoGUI_EVENT_MIDDLE_CLICK Return "ifsoGUI_EVENT_MIDDLE_CLICK"
			Case ifsoGUI_EVENT_MOUSE_ENTER Return "ifsoGUI_EVENT_MOUSE_ENTER"
			Case ifsoGUI_EVENT_MOUSE_EXIT Return "ifsoGUI_EVENT_MOUSE_EXIT"
			Case ifsoGUI_EVENT_MOUSE_DOWN Return "ifsoGUI_EVENT_MOUSE_DOWN"
			Case ifsoGUI_EVENT_MOUSE_UP Return "ifsoGUI_EVENT_MOUSE_UP"
			Case ifsoGUI_EVENT_MOUSE_MOVE Return "ifsoGUI_EVENT_MOUSE_MOVE"
			Case ifsoGUI_EVENT_CHANGE Return "ifsoGUI_EVENT_CHANGE"
			Case ifsoGUI_EVENT_KEYHIT Return "ifsoGUI_EVENT_KEYHIT"
			Case ifsoGUI_EVENT_GAIN_FOCUS Return "ifsoGUI_EVENT_GAIN_FOCUS"
			Case ifsoGUI_EVENT_LOST_FOCUS Return "ifsoGUI_EVENT_LOST_FOCUS"
			Case ifsoGUI_EVENT_RESIZE Return "ifsoGUI_EVENT_RESIZE"
			Case ifsoGUI_EVENT_CELL_CHANGE Return "ifsoGUI_EVENT_CELL_CHANGE"
			Case ifsoGUI_EVENT_COPY Return "ifsoGUI_EVENT_COPY"
			Case ifsoGUI_EVENT_CUT Return "ifsoGUI_EVENT_CUT"
			Case ifsoGUI_EVENT_PASTE Return "ifsoGUI_EVENT_PASTE"
		End Select
		Return "UNKNOWN"
	End Function
End Type

