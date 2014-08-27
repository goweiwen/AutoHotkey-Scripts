CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
SetWinDelay, -1

#include config.ahk

if (NoTrayIcon)
	Menu, Tray, NoIcon

Loop, % Favorites.MaxIndex()
	Menu, Favorites, Add, % Favorites[A_Index][1], Favorites
Loop, % Workspace.MaxIndex()
	Menu, Workspace, Add, % Workspace[A_Index][1], Favorites
Loop, % Games.MaxIndex()
	Menu, Games, Add, % Games[A_Index][1], Favorites
Loop, % Program_Files.MaxIndex()
	Menu, Program_Files, Add, % Program_Files[A_Index][1], Favorites
Menu, Favorites, Add, Workspace, :Workspace
Menu, Favorites, Add, Games, :Games
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
