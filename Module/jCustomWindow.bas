Type=Class
Version=1.5
B4J=true
@EndOfDesignText@
'Class module
Private Sub Class_Globals
	'Java:
	Private fx As JFX
	
	'Private CONSTANTS:
	Private NORESIZE As Int = -999999999
	Private RESIZE_NO_LIMIT As Int = 999999999
	Private CORNERDISTANCE As Int = 50

	'Public CONSTANTS:
	Public ACTION_EXIT As Int = 2
	Public ACTION_MAXIMIZE As Int = 4
	Public ACTION_MINIMIZE As Int = 8
	Public ACTION_FULLSCREEN As Int = 16

	'Class
	Private fFrm As Form
	Private sEventName As String = ""
	Private imgIcon As Image
	Private oModuleParent As Object
	Private iSpeedMultiplier As Float = 1
	Private bAnimationsOn As Boolean = True
	Private iBorderWidth As Double = 3.0
	Private sStyleBorder As String
	Private sStyleTopBar As String

	'Buttons:
	Private mapButtonsActions As Map

	'Animation:
	Private isAtFinalPos As Boolean = True
	
	'Resizing:
	Private isResizable As Boolean = True
	Private iMinWidth As Int = 0
	Private iMinHeight As Int = 0
	Private iMaxWidth As Int = RESIZE_NO_LIMIT
	Private iMaxHeight As Int = RESIZE_NO_LIMIT
	Private iMoveOriginPosX As Double
	Private iMoveOriginPosY As Double
	Private iResizeOriginPosX As Double
	Private iResizeOriginPosY As Double
	
	'Maximizing:
	Private isMaximized As Boolean = False
	Private timer_AnimMaximize As Timer
	Private iX_Current As Double
	Private iY_Current As Double
	Private iW_Current As Double
	Private iH_Current As Double
	Private iX_Target As Double
	Private iY_Target As Double
	Private iW_Target As Double
	Private iH_Target As Double
	
	'Layout:
	Private apWindowBottom As AnchorPane
	Private apWindowContent As AnchorPane
	Private apWindowLeft As AnchorPane
	Private apWindowRight As AnchorPane
	Private apWindowTop As AnchorPane
	Private lblTitle As Label
	Private ivIcon As ImageView
	Private hbWindowTopButtons As Node
End Sub

'Initializes the Custom Window Class.
'Parameters:
'moduleParent: The module that created this Custom Window instance.
'parentForm: The form that will hold the Custom Window.
'eventName: The event name.
Public Sub Initialize(moduleParent As Object, parentForm As Form, eventName As String)
	'save the variables:
	oModuleParent = moduleParent
	fFrm = parentForm
	sEventName = eventName
	
	'Initialize the map that contains the action binding
	'to the buttons:
	mapButtonsActions.Initialize
	
	'Load the Custom window layout:
	fFrm.RootPane.LoadLayout("jCustomWindow")
	   
	'Other tweaks:
	apWindowTop.MouseCursor = fx.Cursors.HAND
	setResizable(isResizable)
	setBorderWidth(iBorderWidth)

	'Initialize the timers:
	timer_AnimMaximize.Initialize("timer_AnimMaximize", 1)
	timer_AnimMaximize.Enabled = False

End Sub

#Region Methods

'Adds a button to the top bar.
'Parameters:
'Text: The button's text. Set to "" for no text.
'Index: The index of the button. Index are 0 based, and start from the left of the window.
'ImageDir and ImageFileName: the image's directory and file name. Set both to "" if you don't want to set an image.
Public Sub ButtonAdd(Text As String, index As Int) As Button
	'Create the button:
	Dim btn As Button
	btn.Initialize("TopBarButton")	
	btn.Text = Text
	btn.PrefHeight = 24
	
	'Set the button as non focus traversable:
	Dim btnJo As JavaObject = btn
	btnJo.RunMethod("setFocusTraversable", Array As Object(False))
	
	'Get the list of buttons and add the button to top bar:
	Dim Buttons As List = VBox_items(hbWindowTopButtons)	
	If index > Buttons.Size Then
		Buttons.Add(btn)
	Else
		Buttons.InsertAt(index, btn)
	End If
	
	'Add the button to the action map:
	mapButtonsActions.Put(btn, -1)
	
	Return btn
End Sub


'Adds a button to the top bar.
'Parameters:
'Text: The button's text. Set to "" for no text.
'Index: The index of the button. Index are 0 based, and start from the left of the window.
'ImageDir and ImageFileName: the image's directory and file name. Set both to "" if you don't want to set an image.
Public Sub ButtonSetImage(Btn As Button, ImageDir As String, ImageFileName As String)
	'Check that path and filename are valid:
	If ImageDir = "" OR ImageFileName = "" Then Return
	'Set the button image:
	Dim iv As ImageView
	Dim btnJo As JavaObject = Btn
	iv = btnJo.RunMethod("getGraphic", Null)
	If iv.IsInitialized Then
		iv.SetImage(fx.LoadImageSample(ImageDir, ImageFileName, 16, 16))
	Else
		iv.Initialize("")
		iv.SetImage(fx.LoadImageSample(ImageDir, ImageFileName, 16, 16))
		btnJo.RunMethod("setGraphic", Array As Object(iv))
	End If
End Sub


'Binds the given button to an Action.
'Parameters:
'Btn: A button
'ACTION: one of the ACTION_* constants.
Public Sub ButtonBindToAction(Btn As Button, ACTION As Int)
	mapButtonsActions.Put(Btn, ACTION)
End Sub


'Returns all the buttons in a list. Useful to skin them one by one for example.
Public Sub getButtons As List
	Dim lst As List : lst.Initialize
	For Each btn As Button In mapButtonsActions.Keys : lst.Add(btn) : Next	
	Return lst
End Sub


'Returns true if the window has the keyboard or mouse focus.
Public Sub Focused As Boolean
	Dim jo As JavaObject
	For Each obj As Object In fFrm.RootPane.GetAllViewsRecursive
		jo = obj
		If jo.RunMethod("isFocused", Null) = True Then
			Return True
		End If
	Next
	Return False
End Sub


'Set the window resizable or not.
Public Sub setResizable(Value As Boolean)
	isResizable = Value
	If isResizable Then
		apWindowBottom.MouseCursor = fx.Cursors.OPEN_HAND
		apWindowLeft.MouseCursor = fx.Cursors.DEFAULT
		apWindowRight.MouseCursor = fx.Cursors.OPEN_HAND
	Else
		apWindowBottom.MouseCursor = fx.Cursors.DEFAULT
		apWindowLeft.MouseCursor = fx.Cursors.DEFAULT
		apWindowRight.MouseCursor = fx.Cursors.DEFAULT	
	End If		
End Sub
Public Sub getResizable As Boolean
	Return isResizable
End Sub


'Set the css style for the top bar.
Public Sub setTopBarStyle(Style As String)
	sStyleTopBar = Style
	apWindowTop.Style = sStyleTopBar
End Sub
Public Sub getTopBarStyle As String
	Return sStyleTopBar
End Sub


'The css style for the left, right and bottom borders.
Public Sub setBorderStyle(Style As String)
	sStyleBorder = Style
	apWindowBottom.Style = sStyleBorder
	apWindowLeft.Style = sStyleBorder
	apWindowRight.Style = sStyleBorder
End Sub
Public Sub getBorderStyle As String
	Return sStyleBorder
End Sub


'The left, right and bottom border size.
Public Sub setBorderWidth(Width As Double)
	iBorderWidth = Width
	apWindowLeft.PrefWidth = iBorderWidth
	apWindowRight.PrefWidth = iBorderWidth
	apWindowBottom.PrefHeight = iBorderWidth
	Dim jo As JavaObject
	jo = apWindowLeft
	jo.RunMethod("setMinWidth", Array As Object(iBorderWidth))
	jo = apWindowRight
	jo.RunMethod("setMinWidth", Array As Object(iBorderWidth))
	jo = apWindowBottom
	jo.RunMethod("setMinHeight", Array As Object(iBorderWidth))
End Sub
Public Sub getBorderWidth As Double
	Return iBorderWidth
End Sub


'The icon that is displayed at the top left of the window.
Public Sub SetIcon(Dir As String, FileName As String)
	imgIcon = fx.LoadImageSample(Dir, FileName, 24, 24)
	ivIcon.SetImage(imgIcon)
End Sub	


'Multiplier for the animation speed. e.g: To multiply the maximize animation by 2, set Multiplier to 2.
Public Sub setAnimationSpeedMultiplier(Multiplier As Float)
	iSpeedMultiplier = Multiplier
End Sub
Public Sub getAnimationSpeedMultiplier As Float
	Return iSpeedMultiplier
End Sub


'Enable or disable the animations.
Public Sub setAnimationsActivated(Value As Boolean)
	bAnimationsOn = Value
End Sub	
Public Sub getAnimationsActivated As Boolean
	Return bAnimationsOn
End Sub	


'Returns the title as a label.
Public Sub Title As Label
	Return lblTitle
End Sub	


'Sets the window size limits.
'Note: This method should be called after the showing the mainform.
Public Sub SetWindowSizeLimits(minWidth As Int, minHeight As Int, maxWidth As Int, MaxHeight As Int)
	iMinWidth = minWidth
	iMinHeight = minHeight
	
	iMaxWidth = maxWidth	
	iMaxHeight = MaxHeight
	
	fFrm.WindowWidth = Max(fFrm.WindowWidth, iMinWidth)
	fFrm.WindowHeight = Max(fFrm.WindowHeight, iMinHeight)
	
	fFrm.WindowWidth = Min(fFrm.WindowWidth, iMaxWidth)
	fFrm.WindowHeight = Min(fFrm.WindowHeight, iMaxHeight)	
End Sub


'Returns the rootPane of the custom content area. You can load your layout there.
Public Sub getRootPane As AnchorPane
	Return apWindowContent
End Sub	

#End Region

#Region Events
Private Sub TopBarButton_MouseClicked (EventData As MouseEvent)	
	Dim Btn As Button = Sender
	If Not(mapButtonsActions.ContainsKey(Btn)) Then Return
	Dim Action As Int = mapButtonsActions.get(Btn)
	
	Select Action
		Case ACTION_EXIT
			'User has called an exit application:
			If sEventName <> "" Then CallSub(oModuleParent, sEventName & "_Exiting")
			ExitApplication
			
		Case ACTION_FULLSCREEN
			'User has called an Full screen:
			If sEventName <> "" Then CallSub(oModuleParent, sEventName & "_EnteringFullScreen")
			Dim jmf As JavaObject = fFrm
			Dim stage As JavaObject = jmf.GetField("stage")
			stage.RunMethod("setFullScreen", Array As Object(True))
			If sEventName <> "" Then CallSubDelayed(oModuleParent, sEventName & "_FullScreen")	
			
		Case ACTION_MAXIMIZE
			'User has called a window maximize:
			If Not(isAtFinalPos) Then Return
			If Not(isResizable) Then Return
			
			If sEventName <> "" Then CallSub(oModuleParent, sEventName & "_Maximizing")
			
			If isMaximized Then
				isAtFinalPos = False
				timer_AnimMaximize.Enabled = True
			Else
				iX_Current = fFrm.WindowLeft
				iY_Current = fFrm.WindowTop
				iW_Current = fFrm.WindowWidth
				iH_Current = fFrm.WindowHeight
				For Each scr As Screen In fx.Screens
					If iX_Current > scr.MinX AND iX_Current < scr.MaxX AND iY_Current > scr.MinY AND iY_Current < scr.MaxY Then
						iX_Target = scr.MinX
						iY_Target = scr.MinY
						iW_Target = scr.MaxX - scr.MinX
						iH_Target = scr.MaxY - scr.MinY
						
						isAtFinalPos = False
						timer_AnimMaximize.Enabled = True
					End If	
				Next
			End If
			If sEventName <> "" Then CallSubDelayed(oModuleParent, sEventName & "_Maximized")
			
		Case ACTION_MINIMIZE
			'User has called a window minimize:
			If sEventName <> "" Then CallSub(oModuleParent, sEventName & "_Minimizing")
			Dim jmf As JavaObject = fFrm
			Dim stage As JavaObject = jmf.GetField("stage")
			stage.RunMethod("setIconified", Array As Object(True))	
			If sEventName <> "" Then CallSubDelayed(oModuleParent, sEventName & "_Minimized")
		
		Case Else
			'a button with no ACTION has been called:
			If sEventName <> "" Then CallSub3(oModuleParent, sEventName & "_MouseClicked", Btn, EventData)
	End Select		
	
End Sub


'Top Window:
Private Sub apWindowTop_Resize (Width As Double, Height As Double)
	Dim jmf As JavaObject = fFrm
	Dim stage As JavaObject = jmf.GetField("stage")
	If stage.RunMethod("isFullScreen", Null) Then
		setTopBarVisible(False)
		apWindowLeft.PrefWidth = 0
		apWindowRight.PrefWidth = 0
		apWindowBottom.PrefHeight = 0
	Else
		setTopBarVisible(True)
		setBorderWidth(iBorderWidth)
	End If
End Sub
Private Sub apWindowTop_MousePressed (EventData As MouseEvent)
	If Not(isAtFinalPos) Then Return
	apWindowTop.MouseCursor = fx.Cursors.MOVE
	iMoveOriginPosX = EventData.X
	iMoveOriginPosY = EventData.Y
End Sub
Private Sub apWindowTop_MouseDragged (EventData As MouseEvent)
	If isMaximized Then Return
	If Not(isAtFinalPos) Then Return
	Dim jo As JavaObject = EventData
	fFrm.WindowLeft = jo.RunMethod("getScreenX", Null) - iMoveOriginPosX
	fFrm.WindowTop = jo.RunMethod("getScreenY", Null) - iMoveOriginPosY
End Sub
Private Sub apWindowTop_MouseReleased (EventData As MouseEvent)
	apWindowTop.MouseCursor = fx.Cursors.HAND
End Sub


'Bottom window:
Private Sub apWindowBottom_MousePressed (EventData As MouseEvent)
	If Not(isAtFinalPos) Then Return
	If Not(isResizable) Then Return
	
	Dim jo As JavaObject = EventData
	If EventData.X > apWindowBottom.Width - CORNERDISTANCE Then
		iResizeOriginPosX = jo.RunMethod("getScreenX", Null)
	Else
		iResizeOriginPosX = NORESIZE
	End If	
	iResizeOriginPosY = jo.RunMethod("getScreenY", Null)
End Sub
Private Sub apWindowBottom_MouseDragged (EventData As MouseEvent)
	If isMaximized Then Return
	If Not(isAtFinalPos) Then Return
	If Not(isResizable) Then Return
	
	Dim jo As JavaObject = EventData
	Dim mouseX As Double = jo.RunMethod("getScreenX", Null)
	Dim mouseY As Double = jo.RunMethod("getScreenY", Null)
	Dim iWidth As Double = fFrm.WindowWidth + (mouseX - iResizeOriginPosX)
	Dim iHeight As Double = fFrm.WindowHeight + (mouseY - iResizeOriginPosY)
	If iResizeOriginPosX <> NORESIZE Then
		If iWidth > iMinWidth AND iWidth < iMaxWidth Then fFrm.WindowWidth = iWidth
		iResizeOriginPosX = mouseX
	End If	
	If iHeight > iMinHeight AND iHeight < iMaxHeight Then fFrm.WindowHeight = iHeight
	iResizeOriginPosY = mouseY
End Sub


'Right window:
Private Sub apWindowRight_MousePressed (EventData As MouseEvent)
	If Not(isAtFinalPos) Then Return
	If Not(isResizable) Then Return
	
	Dim jo As JavaObject = EventData
	iResizeOriginPosX = jo.RunMethod("getScreenX", Null)
	If EventData.Y > apWindowRight.Height - CORNERDISTANCE Then
		iResizeOriginPosY = jo.RunMethod("getScreenY", Null)
	Else
		iResizeOriginPosY = NORESIZE
	End If		
End Sub
Private Sub apWindowRight_MouseDragged (EventData As MouseEvent)
	If isMaximized Then Return
	If Not(isAtFinalPos) Then Return
	If Not(isResizable) Then Return
	
	Dim jo As JavaObject = EventData
	Dim mouseX As Double = jo.RunMethod("getScreenX", Null)
	Dim mouseY As Double = jo.RunMethod("getScreenY", Null)
	Dim iWidth As Double = fFrm.WindowWidth + (mouseX - iResizeOriginPosX)
	Dim iHeight As Double = fFrm.WindowHeight + (mouseY - iResizeOriginPosY)	
	If iWidth > iMinWidth AND iWidth < iMaxWidth Then fFrm.WindowWidth = iWidth
	iResizeOriginPosX = mouseX	
	If iResizeOriginPosY <> NORESIZE Then
		If iHeight > iMinHeight AND iHeight < iMaxHeight Then fFrm.WindowHeight = iHeight
		iResizeOriginPosY = mouseY
	End If	
End Sub


Private Sub timer_AnimMaximize_Tick
	If Not(isAtFinalPos) Then
		If isMaximized Then
			If bAnimationsOn AND (fFrm.WindowWidth - ((fFrm.WindowWidth - iW_Current) / (50 / iSpeedMultiplier)) - 0.5) > iW_Current Then
				fFrm.WindowLeft = fFrm.WindowLeft - ((fFrm.WindowLeft - iX_Current) / (50 / iSpeedMultiplier))
				fFrm.WindowTop = fFrm.WindowTop - ((fFrm.WindowTop - iY_Current) / (50 / iSpeedMultiplier))
				fFrm.WindowWidth = fFrm.WindowWidth - ((fFrm.WindowWidth - iW_Current) / (50 / iSpeedMultiplier))
				fFrm.WindowHeight = fFrm.WindowHeight - ((fFrm.WindowHeight - iH_Current) / (50 / iSpeedMultiplier))
				apWindowLeft.PrefWidth = apWindowLeft.PrefWidth - ((apWindowLeft.PrefWidth - iBorderWidth) / (50 / iSpeedMultiplier))
				apWindowRight.PrefWidth = apWindowRight.PrefWidth - ((apWindowRight.PrefWidth - iBorderWidth) / (50 / iSpeedMultiplier))
				apWindowBottom.PrefHeight = apWindowBottom.PrefWidth - ((apWindowBottom.PrefWidth - iBorderWidth) / (50 / iSpeedMultiplier))				
			Else
				fFrm.WindowLeft = iX_Current
				fFrm.WindowTop = iY_Current
				fFrm.WindowWidth = iW_Current
				fFrm.WindowHeight = iH_Current
				apWindowLeft.PrefWidth = iBorderWidth
				apWindowRight.PrefWidth = iBorderWidth
				apWindowBottom.PrefHeight = iBorderWidth
				
				isAtFinalPos = True
				isMaximized = False
				timer_AnimMaximize.Enabled = False
			End If
		Else
			If bAnimationsOn AND (fFrm.WindowWidth + ((iW_Target - fFrm.WindowWidth) / (50 / iSpeedMultiplier)) + 0.5) < iW_Target Then
				fFrm.WindowLeft = fFrm.WindowLeft + ((iX_Target - fFrm.WindowLeft) / (50 / iSpeedMultiplier))
				fFrm.WindowTop = fFrm.WindowTop + ((iY_Target - fFrm.WindowTop) / (50 / iSpeedMultiplier))
				fFrm.WindowWidth = fFrm.WindowWidth + ((iW_Target - fFrm.WindowWidth) / (50 / iSpeedMultiplier))
				fFrm.WindowHeight = fFrm.WindowHeight + ((iH_Target - fFrm.WindowHeight) / (50 / iSpeedMultiplier))
				apWindowLeft.PrefWidth = apWindowLeft.PrefWidth - (apWindowLeft.PrefWidth / (50 / iSpeedMultiplier))
				apWindowRight.PrefWidth = apWindowRight.PrefWidth - (apWindowRight.PrefWidth / (50 / iSpeedMultiplier))
				apWindowBottom.PrefHeight = apWindowBottom.PrefWidth - (apWindowBottom.PrefWidth / (50 / iSpeedMultiplier))				
				
			Else
				fFrm.WindowLeft = iX_Target
				fFrm.WindowTop = iY_Target
				fFrm.WindowWidth = iW_Target
				fFrm.WindowHeight = iH_Target
				apWindowLeft.PrefWidth = 0
				apWindowRight.PrefWidth = 0
				apWindowBottom.PrefHeight = 0
				
				isAtFinalPos = True
				isMaximized = True
				timer_AnimMaximize.Enabled = False
			End If			
		End If
	End If
End Sub


Private Sub setTopBarVisible(value As Boolean)
	If value = True Then
		apWindowTop.PrefHeight = 32
		apWindowTop.Visible = True
	Else
		apWindowTop.PrefHeight = 0
		apWindowTop.Visible = False
	End If
End Sub

#End Region

#Region Functions
Private Sub VBox_items(obj As Object) As List
	Dim j As JavaObject = obj
	Return (j.RunMethod("getChildren", Null))	
End Sub 
#End Region