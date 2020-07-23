Type=Class
Version=2.8
ModulesStructureVersion=1
B4J=true
@EndOfDesignText@

'Class module
Sub Class_Globals
	Private fx As JFX
	Private AP As AnchorPane
	Private hb As JavaObject
	Private btnUp,btnDown As Button
	Private tf As TextField
	Private EPos As ENumClass
	Private mMinInts,mMaxFracs,mMinFracs As Int
	Private mMaxVal,mMinVal As Double
	Private TickIncrement As Double
	Private Timer1 As Timer
	Private TimerStartInterval As Int = 2000
	Private mIncrement As Double
	Private AutoUpdate,ManualUpdate As Boolean
	Private mModule As Object
	Private mEventName As String
	Private ValidChars As String = "0123456789-."
	Private mGrouping As Boolean
	Private Initialized As Boolean
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Module As Object,EventName As String,MinimumIntegers As Int,MaximumFractions As Int,Increment As Double)

	'Set up the global variables
	mModule = Module
	mEventName = EventName
	mMinInts = MinimumIntegers
	mMaxFracs = MaximumFractions
	mGrouping = False
	mMinFracs = 0
	mIncrement = Increment
	
	'Initialize the Pos Enum
	EPos.Initialize("javafx.geometry.Pos")

	'Initialize the views
	AP.Initialize("AP")
	hb.InitializeNewInstance("javafx.scene.layout.HBox",Null)
	
	'Set the overall alignment of children within the hbox's width and height.
	hb.RunMethod("setAlignment",Array(EPos.ValueOf("CENTER")))
	
	'setMinWidth required a Double
	Dim DoubleValue As Double = 50
	Dim APJO As JavaObject = AP
	'Set the minimum width for the Anchorpane and HBox
	APJO.RunMethod("setMinWidth",Array(DoubleValue))
	hb.RunMethod("setMinWidth",Array(DoubleValue))
	
	'Add the HBox to the AnchorPane
	AP.AddNode(hb,0,0,0,0)
	
	'Initialize the internal views for the spinner
	btnDown.Initialize("btnDown")
	btnUp.Initialize("btnUp")
	tf.Initialize("tf")
	
	'Add the children to the HBox
	hb.RunMethodJO("getChildren",Null).RunMethod("addAll",Array(Array As Object(btnDown,tf,btnUp)))
	
	'Set the initial value
	setValue(0)
	
	'Text alignment for the buttons
	btnUp.Style = "-fx-alignment:Center;"
	btnDown.Style = "-fx-alignment:Center;"
	
	'Text for the buttons
	btnDown.Text = "-"
	btnUp.Text = "+"
	'Font for the buttons
	btnDown.Font = fx.DefaultFont(10)
	btnUp.Font = fx.DefaultFont(10)
	
	'Disable focus on the buttons, so it doesn't flash between the text field and buttons
	Dim JO As JavaObject = btnDown
	JO.RunMethod("setFocusTraversable",Array(False))
	JO = btnUp
	JO.RunMethod("setFocusTraversable",Array(False))
	
	'initialize the timer
	Timer1.Initialize("Timer1",TimerStartInterval)
	
	'Create Key pressed and released events so we can capture key presses
	Dim TFJO As JavaObject = tf
	Dim O As Object = TFJO.CreateEvent("javafx.event.EventHandler","TFKeyPressed",False)
	TFJO.RunMethod("setOnKeyPressed",Array(O))
	
	Dim O As Object = TFJO.CreateEvent("javafx.event.EventHandler","TFKeyReleased",False)
	TFJO.RunMethod("setOnKeyReleased",Array(O))
	
	Initialized = True
End Sub
#Region Layout Subs
'Set the Layout of the AnchorPane
Sub setLayout(Left As Double,Top As Double,Width As Double,Height As Double)
	AP.Left = Left
	AP.Top = Top
	AP.PrefWidth = Width
	AP.PrefHeight = Height
End Sub
'Get/Set the AnchorPane Left value
Sub setLeft(Left As Double)
	AP.Left = Left
End Sub
Sub getLeft As Double
	Return AP.Left
End Sub
'Get/Set the AnchorPane Top value
Sub setTop(Top As Double)
	AP.Top = Top
End Sub
Sub getTop As Double
	Return AP.Top
End Sub
'Get/Set the AnchorPane PrefWidth value
Sub setPrefWidth(PrefWidth As Double)
	AP.PrefWidth = PrefWidth
End Sub
Sub getPrefWidth As Double
	Return AP.PrefWidth
End Sub
'Get/Set the AnchorPane PrefHeight value
Sub setPrefHeight(PrefHeight As Double)
	AP.PrefHeight = PrefHeight
End Sub
Sub getPrefHeight As Double
	Return AP.PrefHeight
End Sub
Private Sub AP_Resize (Width As Double, Height As Double)
	'Resize the HBox in line with the Parent AnchorPane
	hb.RunMethod("setPrefWidth",Array(Width))
	hb.RunMethod("setPrefHeight",Array(Height))
	btnDown.PrefWidth = Width/100 * 20
	btnUp.PrefWidth = Width/100 * 20
	tf.PrefWidth = Width/100 * 60
End Sub
#End Region Layout Subs

#Region Object Specific Subs
'Get the Initialized state of this Object
Sub IsInitialized As Boolean
	Return Initialized
End Sub
'Get the AnchorPane that holds the NumberSpinner
Sub AsNode As Node
	Return AP
End Sub
'Get / Set the current Value. Should be between MinVal and MaxVal inclusive (if set)
Sub setValue(Val As Double)
	Dim Text As String
	Dim LastVal As Double = 0
	If Initialized Then LastVal = getValue
	If mMaxVal = mMinVal Then
		Text = NumberFormat2(Val,mMinInts,mMaxFracs,mMinFracs,mGrouping)
	Else
		Text = NumberFormat2(Min(mMaxVal,Max(mMinVal,Val)),mMinInts,mMinFracs,mMaxFracs,mGrouping)
	End If
	If tf.Text = "-0" Then Text = "0"
	tf.Text = Text
	tf.SetSelection(tf.Text.Length,tf.Text.Length)
	If SubExists(mModule, mEventName & "_ValueChanged") AND getValue <> LastVal Then CallSub3(mModule, mEventName & "_ValueChanged",getValue,AutoUpdate)
	AutoUpdate = False
End Sub
Sub getValue As Double
	Return tf.Text.Replace(",","")
End Sub
Private Sub TF_TextChanged (Old As String, New As String)
	If ManualUpdate Then
		ManualUpdate = False
		Return
	End If
	If Not(ValidateText(New.Replace(",",""))) Then 
		ManualUpdate = True
		setValue(Old.Replace(",",""))
	End If
End Sub
Private Sub TF_Action
	'Validate and Format the entered value
	setValue(getValue)
End Sub
'Get / Set the Maximum values
Sub getMaxValue As Double
	Return mMaxVal
End Sub
Sub setMaxValue(MaxVal As Double)
	mMaxVal = MaxVal
	setValue(Min(getValue,mMaxVal))
End Sub
'Get / Set the Minimum values
Sub getMinValue As Double
	Return mMinVal
End Sub
Sub setMinValue(MaxVal As Double)
	mMinVal = MaxVal
	setValue(Max(getValue,mMinVal))
End Sub
'Get / set the Increment
Sub setIncrement(Increment As Double)
	mIncrement = Increment
End Sub
Sub getIncrement As Double
	Return mIncrement
End Sub
'Set whether grouping should be displayed
Sub setGrouping(Grouping As Boolean)
	mGrouping = Grouping
	setValue(getValue)
End Sub
Sub getGrouping As Boolean
	Return mGrouping
End Sub
'Get / Set the maximum number of decimal places to display
Sub setMaxFractions(MaxFracs As Int)
	mMaxFracs = MaxFracs
	setValue(getValue)
End Sub
Sub getMaxFractions As Int
	Return mMaxFracs
End Sub
'Get / Set the minimum number of decimal places to display
Sub setMinFractions(MinFracs As Int)
	mMinFracs = MinFracs
	setValue(getValue)
End Sub
Sub getMinFractions As Int
	Return mMinFracs
End Sub
'Get / Set the minimum number of Integers to display
Sub setMinIntegers(MinInts As Int)
	mMinInts= MinInts
	setValue(getValue)
End Sub
Sub getMinIntegers As Int
	Return mMinInts
End Sub
Private Sub ValidateText(Text As String) As Boolean
	Dim Valid As Boolean = True
	'Check that all characters are in the ValidChars String
	For i = 0 To Text.Length - 1
		If Not(ValidChars.Contains(Text.CharAt(i))) Then
			'Otherwise return false (Validation failed)
			Valid = False
			Exit
		End If
		'If the text is a '-' then is should only be in position 0
		If Text.CharAt(i) = "-" AND i <> 0 Then
			Valid = False
			Exit
		End If
	Next
	'Return the result
	Return Valid
End Sub
Private Sub Timer1_Tick
	'Flag that this is not a manual input
	AutoUpdate = True
	setValue(getValue + TickIncrement)
	'Reduce the timer interval so the scrolling speeds up
	Timer1.Interval = Max(100,Timer1.Interval * 0.5)
End Sub
#End Region Object Specific Subs

#Region Mouse Access Subs
Private Sub btnDown_MousePressed (EventData As MouseEvent)
	'Set the Textfield non editable so the text cursor is not displayed while scrolling through the values
	Dim JO As JavaObject = tf
	JO.RunMethod("setEditable",Array(False))
	'Set the tick increment with the appropriate sign
	TickIncrement = -mIncrement
	'Start the timer
	Timer1.Enabled = True
	'Call the tick sub so the first update is now
	Timer1_Tick
End Sub
Private Sub btnDown_MouseReleased (EventData As MouseEvent)
	'Disable the timer
	Timer1.Enabled = False
	'Reset the initial interval
	Timer1.Interval = TimerStartInterval
	'Re-enable editing so the text cursor shows
	Dim JO As JavaObject = tf
	JO.RunMethod("setEditable",Array(True))
	'Do Callbacks if needed
	If SubExists(mModule, mEventName & "_EntryReleased") Then 
		CallSub2(mModule, mEventName & "_EntryReleased",getValue)
	End If
	'Send the focus to the textfield
	tf.RequestFocus
End Sub
Private Sub btnUp_MousePressed (EventData As MouseEvent)
	'Set the Textfield non editable so the text cursor is not displayed while scrolling through the values
	Dim JO As JavaObject = tf
	JO.RunMethod("setEditable",Array(False))
	'Set the tick increment with the appropriate sign
	TickIncrement = mIncrement
	'Start the timer
	Timer1.Enabled = True
	'Call the tick sub so the first update is now
	Timer1_Tick
End Sub
Private Sub btnUp_MouseReleased (EventData As MouseEvent)
	'Disable the timer
	Timer1.Enabled = False
	'Reset the initial interval
	Timer1.Interval = TimerStartInterval
	'Re-enable editing so the text cursor shows
	Dim JO As JavaObject = tf
	JO.RunMethod("setEditable",Array(True))
	'Do Callbacks if needed
	If SubExists(mModule, mEventName & "_EntryReleased") Then 
		CallSub2(mModule, mEventName & "_EntryReleased",getValue)
	End If
	'Send the focus to the textfield
	tf.RequestFocus
End Sub
#End Region Mouse Access Subs

#Region Keyboard Access Subs
'Enable keyboard access
Private Sub TFKeyPressed_Event(EventName As String,Args() As Object) As Object
	Dim KEvent As Event = Args(0)
	Dim KEventJO As JavaObject = Args(0)
	Dim KeyCode As JavaObject = KEventJO.RunMethod("getCode",Null)
	Dim KeyName As String = KeyCode.RunMethod("getName",Null)

	'For the Up and Down Keys
	Select KeyName
		Case "Up"
			'Set the Textfield non editable so the text cursor is not displayed while scrolling through the values
			Dim JO As JavaObject = tf
			JO.RunMethod("setEditable",Array(False))
			'Set the tick increment with the appropriate sign
			TickIncrement = mIncrement
			'Start the timer
			Timer1.Enabled = True
			'Call the tick sub so the first update is now
			Timer1_Tick
			'Consume the event
			KEvent.Consume
		Case "Down"
			'Set the Textfield non editable so the text cursor is not displayed while scrolling through the values
			Dim JO As JavaObject = tf
			JO.RunMethod("setEditable",Array(False))
			'Set the tick increment with the appropriate sign
			TickIncrement = -mIncrement
			'Start the timer
			Timer1.Enabled = True
			'Call the tick sub so the first update is now
			Timer1_Tick
			'Consume the event
			KEvent.Consume
	End Select
	
	Return False
End Sub
Private Sub TFKeyReleased_Event(EventName As String,Args() As Object) As Object
	Dim KEvent As Event = Args(0)
	Dim KEventJO As JavaObject = Args(0)
	Dim KeyCode As JavaObject = KEventJO.RunMethod("getCode",Null)
	Dim KeyName As String = KeyCode.RunMethod("getName",Null)
	Log(KeyName)
	
	Select KeyName
		Case "Up", "Down"
			'Disable the timer
			Timer1.Enabled = False
			'Reset the initial interval
			Timer1.Interval = TimerStartInterval
			'Re-enable editing so the text cursor shows
			Dim JO As JavaObject = tf
			JO.RunMethod("setEditable",Array(True))
			'Do Callbacks if needed		
			If SubExists(mModule, mEventName & "_EntryReleased") Then 
				Dim Val As Double = tf.Text.Replace(",","")
				CallSub2(mModule, mEventName & "_EntryReleased",Val)
			End If
			'Send the focus to the textfield
			tf.RequestFocus
			'Consume the event
			KEvent.Consume
	End Select
	Return False
End Sub
#End Region Keyboard Access Subs

