Type=Class
Version=2.2
B4J=true
@EndOfDesignText@
' Popup menu class
' ###########################################################################################################################
' This class is a part of One Click Around application : 	http://oneclickaround.esy.es/
' One Click Around forum : 		http://oneclickaround.esy.es/Forum

' Copyright (C) 2014 by Didier Terrien, France
' ###########################################################################################################################

#Event: Left_click (Action As String, Clicked_button As String)
#Event: Right_click (Action As String, Clicked_button As String)
#Event: B_Go_to_parent_clicked (EventData As MouseEvent)
#Event: B_Add_clicked (EventData As MouseEvent)
#Event: B_Delete_clicked (Selected_file as string, EventData As MouseEvent)
#Event: B_Open_clicked (Selected_file as string, EventData As MouseEvent)

Sub Class_Globals
	Private fx As JFX
	' Widget type	
	Public C_Normal_type As Int = 0						' To display menus or lists
	Public C_File_type As Int = 1						' To display files only
	Public C_Folder_type As Int = 2						' To display folders only
	Public C_Folder_and_file_type As Int = 3			' To display folders and files
	Public C_Tree_type As Int = 4						' To display menus or lists as a tree
	Public Popup_type As Int
	' Settings
	Public Visibility_delay = 5000 As Int 
	Public Hide_on_click As Boolean = True
	Public Focus As Boolean 
	' File type settings
	Public Current_folder As String 					' Folder displayed in the menu
	Public With_navigation As Boolean = True			' Allow or prevent navigation through folders
	Public Navigation_root_folder As String = ""		' Navigation is not permited above this folder
	' Interface
	Public Panel As Pane 
	Public Tree_title As TextField 
	Public Tree As TreeView 
	Private Instructions_area As TextArea 
	Public B_Exit, B_Help, B_Go_to_parent, B_Add, B_Delete, B_Open As Button 
	Public B_Help_visible = False, B_Go_to_parent_visible = False, B_Add_visible = False, B_Delete_visible = False, B_Open_visible = False As Boolean
	Public Instructions As String 
	
	Public Menu_items() As String 
	Private Selected_value As String 
	Private Sub_owner As Object 
	Private Event_name As String 
	Private Popup_timer As Timer
	Private Visibility_timer As Timer
	Private Clicked_button As String 
	Private Current_item As TreeItem 
	
	Public File_icon As Image
	Public Folder_icon As Image
End Sub

#Region  == Methods ===================================================================================
'  Initializes the popup
'Sub_owner_v : module calling the popup and containing Event_name_v
'Event_name_v : the sub which will manage actions to be done when an item is selected
'Menu_items_v : menu items
Public Sub Initialize (Sub_owner_v As Object, Event_name_v As String, Menu_items_v() As String)
	Sub_owner = Sub_owner_v
	Event_name = Event_name_v
	Menu_items = Menu_items_v
	Panel.Initialize ("")
	Tree_title.Initialize ("")
	Tree.Initialize ("Tree")
	Current_item.Initialize ("", "")
	setVisible (False)
End Sub

' Clear memory
Public Sub Reset
	Visibility_timer.Enabled = False
	Visibility_timer.Initialize ("No_sub", 0)	' because Visibility_timer.Enabled = False doesn't work
	If getVisible = False Then
		If SubExists (Sub_owner ,Event_name & "_Reset_completed") Then
			CallSubDelayed (Sub_owner ,Event_name & "_Reset_completed")
		End If
	End If
End Sub

' Adds an item
Public Sub Add_item (Parent_item As TreeItem, List_item As TreeItem)
	If Parent_item.IsInitialized Then
		Parent_item.Children.Add (List_item)
	Else
		Tree.Root.Children.Add (List_item)
	End If
End Sub

Public Sub Add_list_item (Parent_item As TreeItem, Text As String, Item_image As Image) As TreeItem 
	Dim List_item As TreeItem
	List_item.Initialize("Tree_item", Text)
	If Item_image.IsInitialized Then List_item.Image = Item_image
	Add_item (Parent_item, List_item)
	Return List_item
End Sub

Public Sub Refresh_items
	If Menu_items <> Null Then
		' Load items into the tree
		Tree.Root.Children.Clear 
		For Each Menu_item In Menu_items
			Create_main_menu_item (Menu_item)
		Next
	End If
	Current_item = Null
End Sub

' Shows the popup 
' Height : Popup height (-1 for automatic height)
Public Sub Show (Left As Double, Top As Double, Width As Double, Height As Double, Visibility_delay_v As Int) 
	If Popup_type = C_Normal_type Then 
		Refresh_items
	Else If Popup_type = C_File_type OR Popup_type = C_Folder_and_file_type OR Popup_type = C_Folder_type Then
		Load_folder (Current_folder)
	End If
	
	Visibility_delay = Visibility_delay_v
	If Height = -1 Then Height = Tree.Root.Children.Size * 25
	' Creates UI
	If B_Exit.IsInitialized = False Then
		B_Exit.Initialize ("B_Exit")
		B_Help.Initialize ("B_Help")
		B_Go_to_parent.Initialize ("B_Go_to_parent")
		B_Add.Initialize ("B_Add")
		B_Delete.Initialize ("B_Delete")
		B_Open.Initialize ("B_Open")
'		Tree.Style = Panel.Style 
		Panel.AddNode (Tree, 2, 0, -1, -1)
		If Popup_type = C_File_type OR Popup_type = C_Folder_and_file_type OR Popup_type = C_Folder_type Then
			Tree_title.Editable = False
			Panel.AddNode (Tree_title, 2, 2, -1, 20) 
			B_Exit.Text = "x"
			B_Exit.TooltipText = "Exit"
			Panel.AddNode (B_Exit, 0, 2, 30, 20) 
			If B_Help_visible Then
				B_Help.Text = "?"
				B_Help.TooltipText = "Help"
				Panel.AddNode (B_Help, 0, 0, 30, 20) 
			End If
			If B_Go_to_parent_visible Then
				B_Go_to_parent.Text = "↑"
				B_Go_to_parent.TooltipText = "Go to parent folder"
				Panel.AddNode (B_Go_to_parent, 0, 0, 30, 20) 
			End If
			If B_Add_visible Then
				B_Add.Text = "+"
				B_Add.TooltipText = "Add"
				Panel.AddNode (B_Add, 0, 0, 30, 20) 
			End If
			If B_Delete_visible Then
				B_Delete.Text = "-"
				B_Delete.TooltipText = "Delete"
				Panel.AddNode (B_Delete, 0, 0, 30, 20) 
			End If
			If B_Open_visible Then
				B_Open.Text = "O"
				B_Open.TooltipText = "Open"
				Panel.AddNode (B_Open, 0, 0, 30, 20) 
			End If
		End If
	End If

	Move (Left, Top, Width, Height)
	setVisible(True)
	Utils.Bring_to_front (Panel)
	Start_Visibility_timer
End Sub

Private Sub Create_main_menu_item (Item_text As String) 
	Dim Tree_item As TreeItem
	Tree_item.Initialize("", Item_text)
	Tree.Root.Children.Add (Tree_item)
End Sub

Public Sub Move (Left As Double, Top As Double, Width As Double, Height As Double)
	Panel.Left = Left
	Panel.Top = Top
	Panel.PrefWidth = Width
	Panel.PrefHeight = Height

	Tree_title.PrefWidth = Max (100, Width - 2)

	If Popup_type = C_Normal_type OR Popup_type = C_Tree_type Then
		Tree.Top = 2 
		Tree.PrefWidth = Width - 4
		Tree.PrefHeight = Height - 4
	Else
		Tree.Top = Tree_title.PrefHeight + 2 
		Tree.PrefWidth = Tree_title.PrefWidth
		Tree.PrefHeight = Max (100, Height - Tree_title.PrefHeight - 4)
	End If
	
	Dim Next_button_top As Double = Tree.Top
	B_Exit.Left = Tree_title.PrefWidth + 6
	If B_Help_visible Then
		B_Help.Left = B_Exit.Left : B_Help.Top = Next_button_top
		Next_button_top = Next_button_top + B_Exit.PrefHeight + 2
	End If
	If B_Go_to_parent_visible Then
		B_Go_to_parent.Left = B_Exit.Left : B_Go_to_parent.Top = Next_button_top
		Next_button_top = Next_button_top + B_Exit.PrefHeight + 2
	End If
	If B_Add_visible Then
		B_Add.Left = B_Exit.Left : B_Add.Top = Next_button_top
		Next_button_top = Next_button_top + B_Exit.PrefHeight + 2
	End If
	If B_Delete_visible Then
		B_Delete.Left = B_Exit.Left : B_Delete.Top = Next_button_top
		Next_button_top = Next_button_top + B_Exit.PrefHeight + 2
	End If
	If B_Open_visible Then
		B_Open.Left = B_Exit.Left : B_Open.Top = Next_button_top
		Next_button_top = Next_button_top + B_Exit.PrefHeight + 2
	End If
End Sub

Public Sub Clear
	Tree.Root.Children.Clear
End Sub
#End Region 

#Region  == Events ====================================================================================
Private Sub B_Exit_MouseClicked (EventData As MouseEvent)
	setVisible (False)
	Reset
End Sub

Private Sub B_Exit_MouseMoved (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

Private Sub B_Go_to_parent_MouseClicked (EventData As MouseEvent)
	Navigate_to_parent
	If SubExists (Sub_owner ,Event_name & "_B_Go_to_parent_clicked") Then
		CallSubDelayed2 (Sub_owner ,Event_name & "_B_Go_to_parent_clicked", EventData)
	End If
End Sub

Private Sub B_Go_to_parent_MouseMoved (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

Private Sub B_Add_MouseClicked (EventData As MouseEvent)
	If SubExists (Sub_owner ,Event_name & "_B_Add_clicked") Then
		CallSubDelayed2 (Sub_owner ,Event_name & "_B_Add_clicked", EventData)
	End If
End Sub

Private Sub B_Add_MouseMoved (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

Private Sub B_Delete_MouseClicked (EventData As MouseEvent)
	Dim Selected_file As String = File.Combine (Current_folder, Current_item.Text)
	If SubExists (Sub_owner ,Event_name & "_B_Delete_clicked") Then
		CallSubDelayed3 (Sub_owner ,Event_name & "_B_Delete_clicked", Selected_file, EventData)
	End If
End Sub

Private Sub B_Delete_MouseMoved (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

Private Sub B_Open_MouseClicked (EventData As MouseEvent)
	Dim Selected_file As String = File.Combine (Current_folder, Current_item.Text)
	If SubExists (Sub_owner ,Event_name & "_B_Delete_clicked") Then
		CallSubDelayed3 (Sub_owner ,Event_name & "_B_Open_clicked", Selected_file, EventData)
	End If
End Sub

Private Sub B_Open_MouseMoved (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

Private Sub B_Help_MouseClicked (EventData As MouseEvent)
	Instructions_area.Initialize("Instructions_area")
	Panel.AddNode (Instructions_area, 0, 0, 40, 20) 
	Instructions_area.Editable = False
	Instructions_area.Left = 0
	Instructions_area.Top = 0
	Instructions_area.PrefWidth = Panel.Width + 100
	Instructions_area.PrefHeight = Panel.Height + 3

	Instructions_area.Text = "Instructions : (click here to close instructions)" & CRLF & CRLF & Instructions 
End Sub

Private Sub B_Help_MouseMoved (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

Private Sub Instructions_area_MouseClicked (EventData As MouseEvent)		
	Instructions_area.RemoveNodeFromParent 
End Sub

Private Sub Tree_MouseMoved (EventData As MouseEvent)
	Start_Visibility_timer
End Sub

'Private Sub Tree_MouseClicked (EventData As MouseEvent)		'For test 
''Log("Tree_MouseClicked")
'End Sub

Private Sub Tree_FocusChanged (HasFocus As Boolean)
	Focus = HasFocus 
End Sub

Private Sub Tree_MousePressed (EventData As MouseEvent)
'Log("Tree_MousePressed")
	Clicked_button = Utils.Get_mouse_button (EventData)
End Sub

Private Sub Tree_MouseReleased (EventData As MouseEvent)
'Log("Tree_MouseReleased")
	If Current_item.IsInitialized  Then
		If Clicked_button <> "PRIMARY" Then 
		Else If Hide_on_click = False Then 
		Else If With_navigation AND Popup_type = C_Folder_and_file_type Then
			If File.IsDirectory (Current_folder, Current_item.Text) = False Then
				setVisible (False)
			End If
		Else If With_navigation AND Popup_type = C_Folder_type Then
		Else
			setVisible (False)
		End If
		Selected_value = Current_item.Text  
		Popup_timer.Enabled = False
		Popup_timer.Initialize("Popup_timer", 500)
		Popup_timer.Enabled = True
	End If
End Sub

Private Sub Tree_SelectedItemChanged (SelectedItem As TreeItem)
	If SelectedItem.IsInitialized Then
'Log("Tree_SelectedItemChanged : " & SelectedItem.text)
		Current_item = SelectedItem
	End If
End Sub

Private Sub Start_Visibility_timer
	If Visibility_delay > 1000 Then
		Visibility_timer.Enabled = False
		Visibility_timer.Initialize("Visibility_timer", Visibility_delay)
		Visibility_timer.Enabled = True
	End If
End Sub

Private Sub Visibility_timer_Tick
	setVisible (False)
	Reset
End Sub

Private Sub Popup_timer_Tick
	' This timer is used to allow the popup to close before Action had begun
	If 	Popup_timer.Enabled Then
		Popup_timer.Enabled = False
		If Clicked_button = "PRIMARY" Then				' Left button
			If With_navigation = False Then
				CallSubDelayed3 (Sub_owner ,Event_name & "_Left_click", Selected_value, Clicked_button)
			Else If Popup_type <> C_Folder_and_file_type AND Popup_type <> C_Folder_type Then
				CallSubDelayed3 (Sub_owner ,Event_name & "_Left_click", Selected_value, Clicked_button)
			Else If Navigate_to_folder (Selected_value) Then
			Else
				CallSubDelayed3 (Sub_owner ,Event_name & "_Left_click", Selected_value, Clicked_button)
			End If
		Else											' Right button
			Context_menu 
			If SubExists (Sub_owner ,Event_name & "_Right_click") Then
				CallSubDelayed3 (Sub_owner ,Event_name & "_Right_click", Selected_value, Clicked_button)
			End If
		End If
		Reset
	End If
End Sub

Private Sub Context_menu 
	Dim Right_click_menu As Popup_menu 
	Right_click_menu.Initialize (Me, "Right_click_menu" , Null)
	' Images
	Private Add_folder_icon As Image : Add_folder_icon.Initialize (File.DirAssets, "Small add folder.png")
	Private Delete_icon As Image : Delete_icon.Initialize (File.DirAssets, "Small delete.png")
	Private Rename_icon As Image : Rename_icon.Initialize (File.DirAssets, "Small rename.png")
	' Menu items
	Right_click_menu.Add_list_item (Null, "Add folder", Add_folder_icon)
	Right_click_menu.Add_list_item (Null, "Delete", Delete_icon)
	Right_click_menu.Add_list_item (Null, "Rename", Rename_icon)
	
	Right_click_menu.Popup_type = Right_click_menu.C_Tree_type
	Right_click_menu.Hide_on_click = True 
	Panel.AddNode(Right_click_menu.Panel, 0, 0, 100, 100)
	Right_click_menu.Show (B_Exit.Left - 80, B_Exit.Top + 50, 120, -1, 5000)
End Sub

Private Sub Right_click_menu_Left_click (Action As String, Mouse_button As String)
	If Popup_type = C_File_type OR Popup_type = C_Folder_and_file_type OR Popup_type = C_Folder_type Then
		If Action = "Add folder" Then
			Create_folder_interactively 
		Else If Action = "Delete" Then
			Delete_folder_or_file_interactively
		Else If Action = "Rename" Then
			Rename_folder_or_file_interactively
		End If
	End If
End Sub
#End Region 

#Region  == Navigation ================================================================================
Public Sub Load_folder (Folder As String)
	If File.Exists (Folder, "") = False Then File.MakeDir (Folder, "")
	If Navigation_root_folder.Trim = "" Then 
	Else If Utils.Get_long_file_name (Folder).ToLowerCase.Contains (Utils.Get_long_file_name (Navigation_root_folder).ToLowerCase) Then 
	Else
		Return
	End If
	Dim i,l As Int
	Dim Sorted As Boolean = True, Ascending As Boolean = True, WildCards As String = "" 
	Current_folder = Utils.Get_long_file_name (Folder)
	Tree_title.Text = Current_folder
	Tree_title.TooltipText = Current_folder
	If Size <> 0 Then Clear 
    If File.IsDirectory(Folder, "") Then
        Dim FilesFound As List = File.ListFiles(Folder)
        Dim GetCards() As String = Regex.Split(",", WildCards)
        Dim Filtered_files As List : Filtered_files.Initialize
        Dim Filtered_folders As List : Filtered_folders.Initialize
        For i = 0 To FilesFound.Size -1
            For l = 0 To GetCards.Length -1
                Dim TestItem As String = FilesFound.Get(i)
                If TestItem.EndsWith(GetCards(l).Trim) Then
					If File.IsDirectory(Folder, TestItem.Trim) Then
            	        Filtered_folders.Add(TestItem.Trim)
					Else
            	        Filtered_files.Add(TestItem.Trim)
					End If
				End If
            Next
        Next
        If Sorted Then
            Filtered_folders.SortCaseInsensitive(Ascending)
            Filtered_files.SortCaseInsensitive(Ascending)
        End If
		If Popup_type = C_Folder_type OR Popup_type = C_Folder_and_file_type  Then
			For Each Text As String In Filtered_folders
				Add_list_item (Null, Text, Folder_icon)
			Next
		End If
		If Popup_type = C_File_type OR Popup_type = C_Folder_and_file_type  Then
			For Each Text As String In Filtered_files
				Add_list_item (Null, Text, File_icon)
			Next
		End If
	End If
	Refresh_items
End Sub

Public Sub Refresh_folder 
	Load_folder (Current_folder)
End Sub

Private Sub Navigate_to_folder (Folder As String) As Boolean 
	If File.Exists (Current_folder, Folder) = False Then
		Return False
	Else If File.IsDirectory (Current_folder, Folder) Then
		Load_folder (Current_folder & "\" & Folder)
		setVisible (True)
		Return True
	Else
		Return False
	End If
End Sub

Private Sub Navigate_to_parent 
	If Popup_type <> C_Folder_type AND Popup_type <> C_Folder_and_file_type Then
	Else If File.Exists (File.GetFileParent (Current_folder), "") = False Then
	Else If File.IsDirectory (File.GetFileParent (Current_folder), "") Then
		Load_folder (File.GetFileParent (Current_folder))
	End If
End Sub

' Ask for a folder name and create it inside the current folder
Public Sub Create_folder_interactively
	Utils.Create_folder_interactively (Current_folder)
	Refresh_folder
End Sub

' Ask for confirmation and delete selected folder or file
Public Sub Delete_folder_or_file_interactively
	Utils.Delete_folder_or_file_interactively (Current_folder, Current_item.Text)
	Refresh_folder
End Sub

' Ask for a new folder or file name and rename the current folder or file
Public Sub Rename_folder_or_file_interactively
	Utils.Rename_folder_or_file_interactively (Current_folder, Current_item.Text)
	Refresh_folder
End Sub
#End Region 

#Region  == Properties ================================================================================
Sub setVisible (Value As Boolean)
	Panel.Visible = Value
End Sub

Sub getVisible As Boolean
	Return Panel.Visible
End Sub

Public Sub Size As Int 
	Return Tree.Root.Children.Size
End Sub
#End Region 

