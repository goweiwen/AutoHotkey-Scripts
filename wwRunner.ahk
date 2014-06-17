GoSub, Initialise
Return

; Launch Hotkeys
; 	Firefox
!f::  ShowNext("ahk_class MozillaWindowClass") or Run("C:\Program Files (x86)\Aurora\firefox.exe")
!+f:: Run("C:\Program Files (x86)\Aurora\firefox.exe")
; 	Sublime Text
!t::  Show("ahk_class PX_WINDOW_CLASS") or Run("C:\Program Files\Sublime Text 3\sublime_text.exe")
; 	Explorer
!e::  ShowNext("ahk_class CabinetWClass") or Run("explorer.exe ,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
!+e:: Run("explorer.exe ,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
; 	foobar2000
!w:: WinExist("ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}") ? (WinActive("ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}") ? Send("!w") : Show("ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}")) : Run("C:\Program Files (x86)\foobar2000\foobar2000.exe")
; 	Skype/Steam Chat
!a::  ShowNext("ahk_class (TConversationForm|USurface_154434)")
; utorrent
!b::  Show("ahk_class µTorrent4823DF041B09") or Run("C:\Program Files (x86)\uTorrent\uTorrent.exe")
; console
#Enter::  ShowNext("ahk_class ConsoleWindowClass") or Run("cmd", "C:\")
+#Enter:: Run("cmd", "C:\")

; END OF CONFIG

Initialise:
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