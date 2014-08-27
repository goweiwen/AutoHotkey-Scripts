CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
SetWinDelay, -1
SetTitleMatchMode, RegEx

GoSub, IncludeConfig
GoSub, RemoveTrayIcon

IncludeConfig:
	#include config.ahk
Return

RemoveTrayIcon:
	if (NoTrayIcon)
		Menu, Tray, NoIcon
Return

Run(path, workingdir="") {
	Try {
		Run, % path, % workingdir
		Return True
	} Catch {
		Return False
	}
}

Send(Keys) {
	Send, % Keys
	Return True
}

Show(title) {
	WinGet, WinId, IDLast, % title
	WinTitle := "ahk_id " . WinId
	If (WinExist(title)) {
		DllCall("SwitchToThisWindow", "UInt", WinId, "UInt", 1)
		Return True
	}
	Return False
}

ShowNext(title) {
	WinGet, WinId, IDLast, % title
	WinTitle := "ahk_id " . WinId
	WinGet, ActiveTitle, ID, A
	If (WinExist(WinTitle) and (SubStr(WinTitle, 8) <> ActiveTitle)) {
		DllCall("SwitchToThisWindow", "UInt", WinId, "UInt", 1)
		Return True
	}
	Return False
}