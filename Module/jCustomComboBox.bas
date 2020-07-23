Type=Class
Version=2.2
B4J=true
@EndOfDesignText@
#Event: SelectedIndexChanged(Index As Int, Tag As Object)

'Class module
Private Sub Class_Globals
	Private fx As JFX
	
	'Class
	Private frmParent As Form
	Private mdParent As Object
	Private apParent As AnchorPane
	Private sEventName As String
	Private isDropDownOpen As Boolean = False
	Private btnArrowDownWidth As Float = 32
	Private lvSelectedItem As Int = -1

	'drop down UI
	Private frmlv As Form
	Private lv As ListView
	Private lvVisibleRows As Int = 3
	
	'button text UI:
	Private btnArrowDown As Button
	Private apSelectedItem As AnchorPane
	Private hBoxSelectedItem As JavaObject
	Private imgSelectedItem As ImageView
	Private lblSelectedItem As Label
End Sub

'Initializes the object.
'FormParent = The form in which the Custom ComboBox is loaded
'AnchorPaneParent = An anchorpane in which the Custom ComboBox is loaded
Public Sub Initialize(ModuleParent As Object, FormParent As Form, AnchorPaneParent As AnchorPane, EventName As String)
	mdParent = ModuleParent
	frmParent = FormParent
	apParent = AnchorPaneParent
	sEventName = EventName
	
	
	'Text field selected item:
	imgSelectedItem.Initialize("")
	lblSelectedItem.Initialize("")
	
	hBoxSelectedItem.InitializeNewInstance("javafx.scene.layout.HBox", Null)	
	hBoxItems(hBoxSelectedItem).AddAll(Array(imgSelectedItem, lblSelectedItem))
	hBoxSetAligment(hBoxSelectedItem)
	hBoxSetSpacing(hBoxSelectedItem, 5)
	hBoxSetPreferedWidth(hBoxSelectedItem, apParent.Width)

	apSelectedItem.Initialize("apSelectedItem")
	apSelectedItem.AddNode(hBoxSelectedItem, 0, 0, apParent.Width - btnArrowDownWidth, apParent.Height)
	apSelectedItem.SetAnchors(hBoxSelectedItem, 4, 4, 4 + btnArrowDownWidth, 4)
	apSelectedItem.PrefWidth = apParent.Width
	apParent.AddNode(apSelectedItem, 0, 0, apParent.Width, apParent.Height)
	apParent.SetAnchors(apSelectedItem, 0, 0, 0, 0)
	apSelectedItem.StyleClasses.Add("combo-box-base")
	apSelectedItem.StyleClasses.Add("combo-box")

	'Button arrow down:
	btnArrowDown.Initialize("btnArrowDown")
	btnArrowDown.Text = "▼"
	btnArrowDown.Style = "-fx-background-color:transparent;"
	btnArrowDown.Enabled = False
	Dim joBtn As JavaObject = btnArrowDown
	joBtn.RunMethod("setFocusTraversable", Array(False))
	apParent.AddNode(btnArrowDown, apParent.Width - btnArrowDownWidth, 0, btnArrowDownWidth, apParent.Height)
	apParent.SetAnchors(btnArrowDown, -1, 0, 0, 0)

	'Drop down list view:
	frmlv.Initialize("frmlv", apParent.Width, lvVisibleRows * apParent.Height)
	frmlv.SetOwner(frmParent)
	frmlv.SetFormStyle("UNDECORATED")
	lv.Initialize("lv")
	frmlv.RootPane.AddNode(lv, 0, 0, frmlv.Width, frmlv.Height)
	frmlv.RootPane.SetAnchors(lv, 0, 0, 0, 0)
	setDropDownPosition
	
End Sub




#Region Methods
Public Sub getDropDown As Form
	Return frmlv
End Sub	

'Adds an image and text item to the combobox.
Public Sub AddItem(ImgDir As String, ImgFileName As String, Text As String, Tag As Object)
	Log("Add item: " & Text)
	
	Dim iv As ImageView
	iv.Initialize("")
	iv.SetImage(fx.LoadImageSample(ImgDir, ImgFileName, apParent.Height - 8, apParent.Height - 8))
	
	Dim lbl As Label
	lbl.Initialize("")
	lbl.Text = Text
	lbl.Tag = Tag

	Dim hBox As JavaObject
	hBox.InitializeNewInstance("javafx.scene.layout.HBox", Null)
	hBoxSetAligment(hBox)
	hBoxItems(hBox).AddAll(Array(iv, lbl))
	hBoxSetSpacing(hBox, 5)
	
	Dim ap As AnchorPane
	ap.Initialize("")	
	ap.AddNode(hBox, 0, 0, apParent.Width - btnArrowDownWidth, apParent.Height)
	
	lv.Items.Add(ap)	
End Sub	

Public Sub getSelectedItem As Int
	Return lvSelectedItem
End Sub	

Public Sub getSelectedValue As String
	If lvSelectedItem > -1 Then
		Return lblSelectedItem.Text
	Else
		Return ""
	End If	
End Sub	

'Returns null if not set
Public Sub getSelectedItemTag As Object
	If lvSelectedItem > -1 Then
		Return lblSelectedItem.Tag
	Else
		Return Null
	End If	
End Sub	

Public Sub setSelectedItem(Index As Int) 
	If Index < 0 Then
		lvSelectedItem = -1
		lblSelectedItem.Text = ""
		imgSelectedItem.SetImage(Null)		
	Else If Index > lv.Items.Size -1 Then
		Return
	Else
		lvSelectedItem = Index

		'Get the item:
		Dim lbl As Label
		Dim Text As String
		Dim Tag As Object
		Dim img As Image
		Dim iv As ImageView
		Dim ap As AnchorPane = lv.Items.get(lvSelectedItem)
		For Each item In ap.GetAllViewsRecursive
			If item Is Label Then
				lbl = item
				Text = lbl.Text
				Tag = lbl.Tag
			Else If item Is ImageView Then
				iv = item
				img = iv.GetImage
			End If
		Next
		
		lblSelectedItem.Text = Text
		lblSelectedItem.Tag = Tag
		imgSelectedItem.SetImage(img)
	End If	
End Sub	

Public Sub Clear
	setSelectedItem(-1)
	lv.Items.Clear
End Sub

Public Sub getItemCount As Int
	Return lv.Items.Size
End Sub	

Public Sub setVisible(Value As Boolean)
	apParent.Visible = Value
End Sub

Public Sub getVisible As Boolean
	Return apParent.Visible
End Sub

Public Sub setEnabled(Value As Boolean)
	apParent.Enabled = Value
End Sub

Public Sub getEnabled As Boolean
	Return apParent.Enabled
End Sub

'Sets the number of visible rows in the drop down.
Public Sub setVisibleRows(Number As Int)
	lvVisibleRows = Number
	frmlv.WindowHeight = Number * apParent.Height
End Sub

Public Sub getVisibleRows As Int
	Return lvVisibleRows
End Sub	

Private Sub ShowDropDown(Value As Boolean)
	isDropDownOpen = Value
	setDropDownPosition
	If Value Then
		frmlv.Show
	Else
		frmlv.Close
	End If
End Sub	

Private Sub setDropDownPosition
	Dim SceneX, SceneY As Double
	Dim joStage, joScene As JavaObject
	joStage = frmParent.RootPane	
	joScene = joStage.RunMethod("getScene",Null)
	SceneX = joScene.RunMethod("getX", Null)
	SceneY = joScene.RunMethod("getY", Null)

   Dim TopLeft() As Int = GetScreenPosition(apParent)
   frmlv.WindowLeft = frmParent.WindowLeft + TopLeft(1) + SceneX
   frmlv.WindowWidth = apParent.Width
   frmlv.WindowTop = frmParent.WindowTop + TopLeft(0) + SceneY + apParent.Height
End Sub

Private Sub GetScreenPosition(n As Node) As Int()
   Dim t, l As Int
   Dim jo As JavaObject = n
   Do While True
     t = t + n.Top
     l = l + n.Left
     jo = jo.RunMethod("getParent", Null)
     If jo.IsInitialized = False Then Exit
     n = jo
   Loop
   Return Array As Int(t, l)
End Sub

Public Sub setPanelStyle(Style As String)
	apSelectedItem.Style = Style
End Sub

Public Sub getPanelStyle As String
	Return apSelectedItem.Style
End Sub

Public Sub getPanelStyleClasses As List
	Return apSelectedItem.StyleClasses
End Sub

Public Sub setArrowStyle(Style As String)
	btnArrowDown.Style = Style
End Sub

Public Sub getArrowStyle As String
	Return btnArrowDown.Style
End Sub

Public Sub getArrowStyleClasses As List
	Return btnArrowDown.StyleClasses
End Sub

'You can set an icon to the drop down button.
'If not set, the character ">" is shown.
Public Sub ArrowSetImage(ImageDir As String, ImageFileName As String)
	'Check that path and filename are valid:
	If ImageDir = "" OR ImageFileName = "" Then Return
	btnArrowDown.Text = ""
	'Set the button image:
	Dim iv As ImageView
	Dim btnJo As JavaObject = btnArrowDown
	iv = btnJo.RunMethod("getGraphic", Null)
	If iv.IsInitialized Then
		iv.SetImage(fx.LoadImageSample(ImageDir, ImageFileName, 16, 16))
	Else
		iv.Initialize("")
		iv.SetImage(fx.LoadImageSample(ImageDir, ImageFileName, 16, 16))
		btnJo.RunMethod("setGraphic", Array As Object(iv))
	End If
End Sub

#End Region




#Region Events
Private Sub apSelectedItem_MouseClicked (EventData As MouseEvent)
	If lv.Items.Size > 0 Then
		ShowDropDown(Not(isDropDownOpen))
	End If	
End Sub

Private Sub btnArrowDown_Action
	If lv.Items.Size > 0 Then
		ShowDropDown(Not(isDropDownOpen))
	End If	
End Sub

Private Sub lv_SelectedIndexChanged(Index As Int)
	setSelectedItem(Index)
	ShowDropDown(False)
	If SubExists(mdParent, sEventName & "_SelectedIndexChanged") Then
		CallSubDelayed3(mdParent, sEventName & "_SelectedIndexChanged", Index, lblSelectedItem.Tag)
	End If	
End Sub


#End Region




#Region Others
Private Sub hBoxItems(obj As Object) As List
	Dim j As JavaObject = obj
	Return (j.RunMethod("getChildren", Null))	
End Sub
Private Sub hBoxSetSpacing(obj As Object, Spacing As Double) As List
	Dim j As JavaObject = obj
	Return (j.RunMethod("setSpacing", Array(Spacing)))	
End Sub
Private Sub hBoxSetPreferedWidth(obj As Object, Width As Double) As List
	Dim j As JavaObject = obj
	Return (j.RunMethod("setPrefWidth", Array(Width)))	
End Sub
Private Sub hBoxSetAligment(obj As Object)
	Dim pos As JavaObject
	pos.InitializeStatic("javafx.geometry.Pos")
	pos = pos.GetField("CENTER_LEFT")
	Dim j As JavaObject = obj
	j.RunMethod("setAlignment", Array(pos))	
End Sub
#End Region
