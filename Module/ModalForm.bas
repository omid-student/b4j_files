Type=Class
Version=1.05
B4J=true
@EndOfDesignText@
'Class module
Sub Class_Globals
	Private fx As JFX
	Private colorsMap As Map
	Dim lstColors As ListView
	Private frm As Form
End Sub

Public Sub Initialize (Parent As Form)
	frm.Initialize("frm", 300dip, 200dip)
	frm.Title = "Choose color"
	frm.SetFormStyle("UTILITY")
	frm.RootPane.LoadLayout("2")
	frm.SetOwner(Parent)
	FillList
	
End Sub

Private Sub FillList
	colorsMap.Initialize
	colorsMap.Put("Red", fx.Colors.Red)
	colorsMap.Put("Black", fx.Colors.Black)
	colorsMap.Put("Blue", fx.Colors.Blue)
	colorsMap.Put("Cyan", fx.Colors.Cyan)
	colorsMap.Put("DarkGray", fx.Colors.DarkGray)
	colorsMap.Put("Green", fx.Colors.Green)
	colorsMap.Put("Magenta", fx.Colors.Magenta)
	colorsMap.Put("Yellow", fx.Colors.Yellow)
	colorsMap.Put("White", fx.Colors.White)
	For Each color As String In colorsMap.Keys
		lstColors.Items.Add(color)
	Next
End Sub

Public Sub Show As Paint
	frm.ShowAndWait
	Return colorsMap.Get(lstColors.SelectedItem)
End Sub

Sub lstColors_SelectedIndexChanged(Index As Int)
	If Index > -1 Then frm.Close
End Sub
Sub frm_CloseRequest (EventData As Event)
	If lstColors.SelectedIndex = -1 Then EventData.Consume
End Sub