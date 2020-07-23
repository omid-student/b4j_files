Type=Class
Version=2.18
B4J=true
@EndOfDesignText@
#Event: ColorPicked(Color As Object)
'Class module
Sub Class_Globals
	Private fx As JFX
	Private CP As JavaObject
	Private mModule As Object
	Private mEventName As String
End Sub

'Initializes the object.
'Pass a Pane to load the Color Picker into, Color is the initial color when the Color Picker is displayed
Public Sub Initialize(Module As Object,EventName As String,Pane1 As Pane,Color As Paint)

	'Store the calling object
	mModule = Module
	mEventName = EventName
	
	'Create the ColorPicker Object
	CP.InitializeNewInstance("javafx.scene.control.ColorPicker",Null)
	'Set it's initial Value
	CP.RunMethod("setValue",Array(Color))
	
	'Create the Event Handler
	Dim E As Object = CP.CreateEventFromUI("javafx.event.EventHandler","CP",Null)
	CP.RunMethod("setOnAction",Array(E))

	'Add the colorPicker
	Pane1.AddNode(CP,0,0,-1,-1)

End Sub
Sub CP_Event(MethodName As String,Args() As Object)
	'Pass the value back to the calling module
	If SubExists(mModule,mEventName & "_ColorPicked") Then
		CallSub2(mModule,mEventName & "_ColorPicked",CP.RunMethod("getValue",Null))
	End If
End Sub
Sub setColor(Color As Paint)
	CP.RunMethod("setValue",Array(Color))
End Sub