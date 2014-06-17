GoSub Initialise
GoSub InitFavorites

Initialise:
	CoordMode, Mouse, Screen
	CoordMode, Pixel, Screen
	#SingleInstance, Force
	#KeyHistory 500
	SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
	SetBatchLines, -1
	SetWinDelay, -1
	SetTitleMatchMode, RegEx
Return

InitFavorites:
	Favorites := []
	Favorites.insert(["Computer", "Computer", "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"])
	Favorites.insert(["Desktop", "%USERPROFILE%\Desktop"])
	Favorites.insert(["Downloads", "%USERPROFILE%\Downloads"])
	Favorites.insert(["Dropbox", "%USERPROFILE%\Dropbox"])
	Favorites.insert(["Documents", "%USERPROFILE%\My Documents"])
	Favorites.insert(["Videos", "%USERPROFILE%\My Videos"])
	Favorites.insert(["Music", "%USERPROFILE%\Music"])
	Favorites.insert(["Recycle Bin", "Recycle Bin"])
	Loop, % Favorites.MaxIndex()
		Menu, Favorites, Add, % Favorites[A_Index][1], Favorites

	Workspace := []
	Workspace.insert(["Local", "D:\Workspace"])
	Workspace.insert(["Dropbox", "%USERPROFILE%\Dropbox\workspace"])
	Loop, % Workspace.MaxIndex()
		Menu, Workspace, Add, % Workspace[A_Index][1], Favorites
	Menu, Favorites, Add, Workspace, :Workspace

	Games := []
	Games.insert(["SSD", "C:\Games"])
	Games.insert(["HDD", "D:\Games"])
	Loop, % Games.MaxIndex()
		Menu, Games, Add, % Games[A_Index][1], Favorites
	Menu, Favorites, Add, Games, :Games

	Program_Files := []
	Program_Files.insert(["SSD (x86)", "C:\Program Files (x86)"])
	Program_Files.insert(["HDD (x86)", "D:\Program Files (x86)"])
	Program_Files.insert(["SSD", "D:\Program Files"])
	Program_Files.insert(["HDD", "D:\Program Files"])
	Program_Files.insert(["Dropbox", "%USERPROFILE%\Dropbox\Programs"])
	Loop, % Program_Files.MaxIndex()
		Menu, Program_Files, Add, % Program_Files[A_Index][1], Favorites
	Menu, Favorites, Add, Program Files, :Program_Files
Return

Favorites:
	WinGetClass, WinClass, A
	If (WinClass = "#32770") {
		Click, %X%, %Y%
		Send, ^a{Backspace}
		Send, % %A_ThisMenu%[A_ThisMenuItemPos][2]
		Sleep, 10
		Send, {Enter}
	} Else If (WinClass = "CabinetWClass") {
		Send, !d
		Send, % %A_ThisMenu%[A_ThisMenuItemPos][2]
		Send, {Enter}
	} Else {
		Run, % "explorer.exe " (%A_ThisMenu%[A_ThisMenuItemPos][3] ? %A_ThisMenu%[A_ThisMenuItemPos][3] : %A_ThisMenu%[A_ThisMenuItemPos][2])
	}
Return

~AppsKey::
	If (GetKeyState("XButton1", "P") = "D")
		Return
	MouseGetPos, X, Y, WinId
	WinTitle := "ahk_id " . WinId
	WinGetClass, WinClass, % WinTitle
	WinGetTitle, WinFullTitle, % WinTitle
	WinGet, WinStyle, Style, % WinTitle
	If (WinClass = "CabinetWClass" or WinClass = "#32770" or (WinFullTitle = "Program Manager" and WinStyle = 0x96000000)) {
		WinActivate, % WinTitle
		Menu, Favorites, Show
		Return
	}
Return
