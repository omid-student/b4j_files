Type=Class
Version=2.2
B4J=true
@EndOfDesignText@
' Messages class
' ###########################################################################################################################
' This class is a part of One Click Around application : 	http://oneclickaround.esy.es/
' One Click Around forum : 		http://oneclickaround.esy.es/Forum

' Copyright (C) 2014 by Didier Terrien, France
' ###########################################################################################################################

Sub Class_Globals
	Private fx As JFX
	Private Message_text As StringBuilder
	' Message type
	Public C_Message_box As Int = 0			' To display message with several buttons
	Public C_Toast_message As Int = 1		' To display a toast message
	Public C_Input_box As Int = 2			' To display intut text field with several buttons
	Public Message_type As Int
	' Settings
	Public Visibility_delay = 5000 As Int 
	' Interface
	Private Message_form As Form 
	Private Panel As Pane 
	Private Title As Label
	Private Text As WebView
	Public Input_field As TextField 
	Private Buttons_list As List
	Private Buttons_texts () As String
	Public Button_clicked_index As Int
	Public Buttons_spacing As Int = 8
	Public Buttons_height As Int = 25
	Public Opacity As Double = 1
	
	Private Sub_owner As Object 
	Private Event_name As String 
	Private Visibility_timer As Timer
	
	Public File_icon As Image
	Public Folder_icon As Image
End Sub

#Region  == Methods ===================================================================================
'  Initializes the message
'Sub_owner_v : module calling the popup and containing Event_name_v
'Event_name_v : the sub which will manage actions to be done when an item is selected
Public Sub Initialize (Sub_owner_v As Object, Event_name_v As String)
	Sub_owner = Sub_owner_v
	Event_name = Event_name_v
	Message_text.Initialize 
	Panel.Initialize ("")
	Panel.Style = Utils.Init_default_style (Panel.Style)
	Message_form.Initialize ("", -1, -1)
	Message_form.SetFormStyle("TRANSPARENT")
	Message_form.BackColor = fx.Colors.Transparent 
	Message_form.RootPane.AddNode (Panel, 10, 10, -1, -1)
	Title.Initialize ("")
	Text.Initialize ("")
	Input_field.Initialize ("Input_field")
	setVisible (False)
End Sub

' Show a message with as many buttons as strings in Buttons_texts_v array
' If Buttons_texts_v is empty, it will display a toast message 
' Return the index of selected button
Public Sub Show (Title_v As String, Text_v As String, Buttons_texts_v () As String) As Int
	Buttons_texts = Buttons_texts_v
	' Creates UI
	Title.Text = Title_v 
	Message_text.Initialize
	Message_text.Append ("<table style=""width: %WIDTH%px; height: %HEIGHT%px;"" border=""0"" cellpadding=""2"" cellspacing=""2""><tbody><tr><td><span style=""font-family: Calibri;"">")
	Message_text.Append (Text_v)
	Message_text.Append ("</span></td></tr></tbody></table>")
	If Buttons_list.IsInitialized = False Then
		Buttons_list.Initialize 
		Panel.AddNode (Title, 8, 0, -1, 25)
		Text.Style = Panel.Style
		Panel.AddNode (Text, 2, 0, -1, -1)
		Panel.AddNode (Input_field, 10, 0, -1, -1)
	End If
	If Buttons_texts.Length > 0 Then				' With buttons
		Buttons_list.Clear 
		For i = 0 To Buttons_texts.Length - 1
			Add_button
		Next
	End If
	Move (0, 0, 700, 230)
	' Show form
	setVisible(True)
	If Buttons_texts.Length > 0 Then				' With buttons
		Message_form.ShowAndWait 
	Else											' Without buttons
		Start_Visibility_timer
		Message_form.Show 
	End If
	Return Button_clicked_index
End Sub

Private Sub Add_button
	Dim Added_button As Button
	Added_button.Initialize ("Button")
	Added_button.Style = Panel.Style
	Panel.AddNode (Added_button, 10, 0, -1, Buttons_height)
	Buttons_list.Add (Added_button)
End Sub

Private Sub Move (Left As Double, Top As Double, Width As Double, Height As Double)
	Panel.Left = Left
	Panel.Top = Top
	Panel.PrefWidth = Width
	Panel.PrefHeight = Height

	Title.PrefWidth = Max (100, Width - 4)
	
	Dim Input_area As Double
	If Message_type = C_Message_box Then 
		Input_area = Panel.PrefHeight - ((Buttons_texts.Length) * (Buttons_height + Buttons_spacing)) 
	Else If Message_type = C_Toast_message Then 
		Input_area = Panel.PrefHeight 
	Else If Message_type = C_Input_box Then 
		Input_area = Panel.PrefHeight - ((Buttons_texts.Length + 1) * (Buttons_height + Buttons_spacing)) 
	End If
	
	Text.Top = Title.PrefHeight + 4 
	Text.PrefWidth = Title.PrefWidth
	Text.PrefHeight = Height - (Height - Input_area) - Text.Top - 4
	Dim HTML_text As String = Message_text.ToString.Replace ("%WIDTH%", Text.PrefWidth - 30)
	HTML_text= HTML_text.Replace ("%HEIGHT%", Text.PrefHeight - 30)
	Text.LoadHtml (HTML_text)

	If Message_type = C_Message_box Then 
		Input_field.Visible = False
	Else If Message_type = C_Toast_message Then 
		Input_field.Visible = False
	Else If Message_type = C_Input_box Then 
		Input_field.Visible = True
		Input_field.Top = Input_area
		Input_area = Input_area + (Buttons_height + Buttons_spacing)
		Input_field.PrefWidth = Width - 20
		Input_field.PrefHeight = Buttons_height
	End If
	
	For i = 0 To Buttons_texts.Length - 1
		Dim This_button As Button = Buttons_list.Get (i)
		This_button.Top = Input_area
		Input_area = Input_area + (Buttons_height + Buttons_spacing)
		This_button.PrefWidth = Width - 20
		This_button.Text = Buttons_texts (i)
		This_button.Tag = i 
	Next
End Sub

Private Sub setOpacity (Value As Double)
	Utils.Set_panel_opacity (Panel, Value)
	Opacity = Value
End Sub
#End Region 

#Region  == Events ====================================================================================
Private Sub Button_MouseClicked (EventData As MouseEvent)
	Dim Button_clicked As Button = Sender
	Button_clicked_index = Button_clicked.Tag
	Message_form.Close
End Sub

Sub Text_MouseClicked (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

Sub Text_MouseMoved (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

Private Sub Start_Visibility_timer
	If Visibility_delay > 1000 Then
		Visibility_timer.Enabled = False
		Visibility_timer.Initialize("Visibility_timer", Visibility_delay)
		Visibility_timer.Enabled = True
		setOpacity (1)
	End If
End Sub

Private Sub Visibility_timer_Tick
	If Opacity >= 0.1 Then
		Visibility_timer.Enabled = False
		setOpacity (Opacity - 0.1)
		Visibility_timer.Initialize("Visibility_timer", 200)
		Visibility_timer.Enabled = True
	Else											' Other items with partial visibility
		Visibility_timer.Enabled = False
		setVisible (False)
		Message_form.Close 
	End If
End Sub
#End Region 

#Region  == Properties ================================================================================
Sub setVisible (Value As Boolean)
	Panel.Visible = Value
End Sub

Sub getVisible As Boolean
	Return Panel.Visible
End Sub
#End Region 

