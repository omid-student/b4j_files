Type=Class
Version=1.5
B4J=true
@EndOfDesignText@
'Class module
Private Sub Class_Globals
	Private fx As JFX	
	Private frm As Form
	Private MainScreen As Screen
	
	'Constants:
	Private BOTTOM_RIGHT As String = "BOTTOM_RIGHT"
	
	'This class:
	Private bShow As Boolean = False
	Private mParent As Object
	Private sText As String = ""
	Private sTitle As String = ""
	Private sEvent As String
	Private imgImage As Image
	Private pBgColor As Paint
	Private oTitleColor As Object
	Private oMessageColor As Object
	Private xOffset As Int = 5
	Private yOffset As Int = 5

	'Duration:
	Private TimerDuration As Timer
	Private iDuration As Int = 0
	Private iStartDuration As Double
	
	'Animation:
	Private TimerAnim As Timer
	Private ANIM_TYPE As Int
	Private ANIM_SPEED As Float = 1.0
	Private ANIM_SHOWING As Int = 0
	Private ANIM_HIDING As Int = 1
	
	'Toast position:
	Private TOAST_AT_FINAL_POS As Boolean
	Private TOAST_IS_VISIBLE As Boolean
	Private TOAST_HIDE_THEN_SHOW As Boolean
	
	'UI:
	Private btnClose As Button
	Private imgIcon As ImageView
	Private lblText As Label
	Private lblTitle As Label
	Private apMain As AnchorPane
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Parent As Object, EventName As String, Owner As Form)
	frm.Initialize("frm", -1, -1)
	frm.RootPane.LoadLayout("jNotifications")
	frm.SetOwner(Owner)
	frm.Resizable = False
	frm.SetFormStyle("UNDECORATED")

	mParent = Parent
	sEvent = EventName
	MainScreen = fx.PrimaryScreen
	
	TimerDuration.Initialize("Duration", 1000)
	TimerDuration.Enabled = False
	
	TimerAnim.Initialize("Animation", 1)
	TimerAnim.Enabled = False
End Sub

Public Sub Show
	'Hide the toast first:
	If TOAST_IS_VISIBLE OR Not(TOAST_AT_FINAL_POS) Then
		TOAST_HIDE_THEN_SHOW = True
		Hide
		Return
	End If
	
	'Set the user's preferences:
	If imgImage.IsInitialized Then imgIcon.setImage(imgImage)
	If pBgColor.IsInitialized Then frm.BackColor = pBgColor
	lblTitle.TextColor = oTitleColor
	lblText.TextColor = oMessageColor
	lblTitle.Text = sTitle
	lblText.Text = sText

	'Reset the window position:
	If Not(bShow) Then
		frm.WindowLeft = MainScreen.MaxX
		frm.WindowTop = MainScreen.MaxY	
		frm.Show		
		bShow = True
	End If	
	frm.WindowLeft = MainScreen.MaxX - frm.Width - xOffset
	frm.WindowTop = MainScreen.MaxY
	
	'Start the duration:
	If iDuration > 0 Then
		TimerDuration.Enabled = True
		iStartDuration = DateTime.Now
	End If
	
	'Start the animation:
	TimerAnim.Enabled = True
	ANIM_TYPE = ANIM_SHOWING
	TOAST_AT_FINAL_POS = False
End Sub

Public Sub Hide
	'Start the animation:
	TimerAnim.Enabled = True
	ANIM_TYPE = ANIM_HIDING
	TOAST_AT_FINAL_POS = False
End Sub

Private Sub Duration_Tick
	If (DateTime.Now - iStartDuration) > (iDuration * 1000) Then
		TimerDuration.Enabled = False
		Hide
	End If	
End Sub

Private Sub Animation_Tick
	If ANIM_TYPE = ANIM_SHOWING AND Not(TOAST_AT_FINAL_POS) Then
		Dim Target As Float = MainScreen.MaxY - yOffset - frm.Height
		If frm.WindowTop > Target Then
			Dim Distance As Float = (frm.WindowTop - Target)
			frm.WindowTop = frm.WindowTop - ((Distance / 100) * ANIM_SPEED)
		Else
			TOAST_AT_FINAL_POS = True
			TOAST_IS_VISIBLE = True
			TimerAnim.Enabled = False
		End If	
	Else If ANIM_TYPE = ANIM_HIDING AND Not(TOAST_AT_FINAL_POS) Then
		Dim Target As Float = MainScreen.MaxY + 5
		If frm.WindowTop < Target Then
			Dim Distance As Float = (Target - frm.WindowTop)
			frm.WindowTop = frm.WindowTop + ((Distance / 100) * ANIM_SPEED * 2)
		Else
			TOAST_AT_FINAL_POS = True
			TOAST_IS_VISIBLE = False
			TimerAnim.Enabled = False
			TimerDuration.Enabled = False
			If TOAST_HIDE_THEN_SHOW Then
				TOAST_HIDE_THEN_SHOW = False
				Show
			End If	
		End If		
	End If
End Sub

#Region ////////////////////////Events///////////////////////////

Private Sub apMain_MouseClicked (EventData As MouseEvent)
	If sEvent <> "" Then CallSub2(mParent, sEvent & "_Action", EventData)
End Sub

Private Sub btnClose_Action
	If sEvent <> "" Then CallSub(mParent, sEvent & "_Closed")
	Hide
End Sub

#End Region

#Region ////////////////////////Methods///////////////////////////
Public Sub setBackColor(Color As Paint)
	pBgColor = Color
End Sub
Public Sub getBackColor As Paint
	Return pBgColor
End Sub

Public Sub setTitleColor(Color As Object)
	oTitleColor = Color
End Sub
Public Sub getTitleColor As Object
	Return oTitleColor
End Sub

Public Sub setMessageColor(Color As Object)
	oMessageColor = Color
End Sub
Public Sub getMessageColor As Object
	Return oMessageColor
End Sub

'Sets the duration of the toast message.
'0 For infinte (Default).
Public Sub setDuration(Seconds As Int)
	iDuration = Seconds
End Sub
Public Sub getDuration As Int
	Return iDuration
End Sub

Public Sub setImage(Img As Image)
	imgImage = Img
End Sub
Public Sub getImage As Image
	Return imgImage
End Sub

Public Sub Form As Form
	Return frm
End Sub

Public Sub setOffset(x As Int, y As Int)
	xOffset = x
	yOffset = y
End Sub

Public Sub setSpeedMultiplier(Multiplier As Float)
	ANIM_SPEED = Multiplier
End Sub
Public Sub getSpeedMultiplier As Float
	Return ANIM_SPEED
End Sub

Public Sub setMessage(Text As String)
	sText = Text
End Sub
Public Sub getMessage As String
	Return sText
End Sub

Public Sub setTitle(Title As String)
	sTitle = Title
End Sub
Public Sub getTitle As String
	Return sTitle
End Sub

#End Region