GoSub Initialise

; Pixel Values
MarginWidth := 8                  ; Margin (px)
MarginWidthHalf := MarginWidth//2 ; Margin of edges (px)
SnapDistance := 16                ; Minimum distance from lines before snapping (px)
MinimumMovement := 10             ; Minimum distance before starting to move/resize window (px)

; Toggles
SnapToGrid := True                ; Snap to grid?
SnapToWindows := True             ; Snap to surrounding windows?
MoveToTopToMaximize := True       ; Maximize the window if it is moved to the top of the screen?
MoveToBottomToClose := True       ; Minimize the window if it is moved to the bottom of the screen?

; Grid and preview
VisibleGrid := False              ; Display the grid?
ColorGrid := 0xA2B2A1             ; Colour of the grid
TransparencyGrid := 128           ; Transparency of the grid
ColorPreview := 0xA2B2A1          ; Colour of the preview
TransparencyPreview := 128        ; Transparency of the preview
AnimationDuration := 150          ; How long the preview animation lasts (ms)

; The default config results in this grid:
; +----+----+
; |    |    |
; |    +----+
; |    |    |
; +----+----+
;
; You can bind your own hotkeys to certain positions using 
;   MoveWindowToTile(window-title, x0-index, x1-index, y0-index, y1-index)
; For example:
;   NumpadIns:: MoveWindowToTile("A", 1, 3, 1, 2)

; V[n]:= [ x-coord, y0-index, y1-index, corner?, resize-only?]
V := []
V[1] := [ ScreenX,                  1,  3,  1, 0 ]
V[2] := [ ScreenX+ScreenW/2,        1,  3,  0, 0 ]
V[3] := [ ScreenX+ScreenW,          1,  3,  1, 0 ]
 
; H[n]:= [ y-coord, x0-index, x1-index, corner?, resize-only?]
H := []
H[1] := [ ScreenY,                  1,  3,  1, 0 ]
H[2] := [ ScreenY+(ScreenH-32)/2,   2,  3,  0, 0 ]
H[3] := [ ScreenY+ScreenH-32,       1,  3,  1, 0 ]

HotkeyMove := "MButton"           ; Leave blank to disable
HotkeyResize := "RButton"         ; Leave blank to disable
HotkeyMoveResize := "LButton"     ; Leave blank to disable

HotkeyModifier := "!" ; HotkeyModifier is prefixed to each hotkey, but can be released once the hotkey has activated.

; END OF CONFIG

GoSub Finalise
return

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

	SysGet, ScreenX, 76 ; SM_XVIRTUALSCREEN
	SysGet, ScreenY, 77 ; SM_YVIRTUALSCREEN
	SysGet, ScreenW, 78 ; SM_CXVIRTUALSCREEN
	SysGet, ScreenH, 79 ; SM_CYVIRTUALSCREEN
return

Finalise:
	if (HotkeyMove)
		Hotkey, % HotkeyModifier . HotkeyMove, MoveWindow
	if (HotkeyResize)
		Hotkey, % HotkeyModifier . HotkeyResize, ResizeWindow
	PreviewID := CreatePreview()
	if (VisibleGrid) {
		CreateBitmap()
		CreateGrid()
	}
return

MoveWindow:
	MoveWindow()
return

MoveWindow() {
	MouseGetPos, X, Y, WinId, 
	OrigX := X, OrigY := Y
	WinTitle := "ahk_id " . WinId
	DrawWindow(WinTitle)
	WinGetPos, WinX, WinY, WinW, WinH, % WinTitle
	InitializePreviewAt(WinX, WinY, WinW, WinH)
	MoveWindowDo(OrigX, OrigY, WinTitle)
	HidePreviewAfterAnimation()
	GoSub, UpdatePreviewPosition
	UndrawWindow(WinTitle)
}

MoveWindowDo(OrigX, OrigY, WinTitle) {
	global MinimumMovement, MoveToTopToMaximize, MoveToBottomToClose, HotkeyMove, HotkeyMoveResize
	while 1 {
		Sleep 10 ; Sleep until movement exceeds threshold or button is released
		MouseGetPos, X, Y
		if (abs(OrigX - X) > MinimumMovement or abs(OrigY - Y) > MinimumMovement)
			Break
		if (!GetKeyState(HotkeyMove, "P")) {
			if (MoveToTopToMaximize and OrigY = GetTopPos(X, Y))
				WinMaximize, % WinTitle
			if (MoveToBottomToClose and OrigY = GetBottomPos(X, Y))
				WinClose, % WinTitle
			return
		}
	}

	Left := 0, Right = 0, Top = 0, Bottom = 0
	while (GetKeyState(HotkeyMove, "P")) {
		if (HotkeyMoveResize and GetKeyState(HotkeyMoveResize, "P")) {
			MoveResizeWindowDo(WinTitle)
			return
		}
		MouseGetPos, X, Y
		if (MoveToTopToMaximize and Y = GetTopPos(X, Y)) {
			MaximizePreview()
			MoveWindowDo(X, Y, WinTitle)
			return
		}
		if (MoveToBottomToClose and Y = GetBottomPos(X, Y)) {
			MinimizePreview()
			MoveWindowDo(X, Y, WinTitle)
			return
		}
		Left := 0, Right = 0, Top = 0, Bottom = 0
		if (GetBestTile(X, Y, Left, Right, Top, Bottom))
			MovePreviewToTile(Left, Right, Top, Bottom)
	}
	WinRestore, % WinTitle
	MoveWindowToTile(WinTitle, Left, Right, Top, Bottom)
	if (MoveToBottomToClose and Y = GetBottomPos(X, Y)) {
		WinClose, % WinTitle
	}
}

MoveResizeWindowDo(WinTitle) {
	global HotkeyMoveResize, HotkeyMove, HotkeyResize
	MouseGetPos, OrigX, OrigY
	Left := 0, Right = 0, Top = 0, Bottom = 0
	Released := False
	while (GetKeyState(HotkeyMove, "P") or GetKeyState(HotkeyResize, "P")) {
		MouseGetPos, X, Y
		if (GetKeyState(HotkeyMoveResize, "P")) {
			if (Released) {
				OrigX := X, OrigY := Y
				Released := False
			}
		} else {
			Released := True
		}
		Left := 0, Right = 0, Top = 0, Bottom = 0
		if (GetBoundingTile(OrigX, OrigY, X, Y, Left, Right, Top, Bottom))
			MovePreviewToTile(Left, Right, Top, Bottom)
	}
	WinRestore, % WinTitle
	MoveWindowToTile(WinTitle, Left, Right, Top, Bottom)
}

ResizeWindow:
	ResizeWindow()
return

ResizeWindow() {
	MouseGetPos, X, Y, WinId, startTime
	OrigX := X, OrigY := Y
	WinTitle := "ahk_id " . WinId
	DrawWindow(WinTitle)
	WinGetPos, WinX, WinY, WinW, WinH, % WinTitle
	InitializePreviewAt(WinX, WinY, WinW, WinH)
	ResizeWindowDo(OrigX, OrigY, WinTitle)
	HidePreview()
	UndrawWindow(WinTitle)
}

ResizeWindowDo(OrigX, OrigY, WinTitle, IsMove=False) {
	global MinimumMovement, HotkeyResize, MoveToTopToMaximize
	while 1 {
		Sleep 10 ; Sleep until movement exceeds threshold or button is released
		MouseGetPos, X, Y
		if (abs(OrigX - X) > MinimumMovement or abs(OrigY - Y) > MinimumMovement)
			Break
		if (!GetKeyState(HotkeyResize, "P")) {
			if (MoveToTopToMaximize and OrigY = GetTopPos(X, Y))
				WinMaximize, % WinTitle
			return
		}
	}

	WinGet, MinMax, MinMax, % WinTitle
	if (MoveToTopToMaximize and MinMax = 1) {
		WinGetPos, WinX, WinY, WinW, WinH, % WinTitle
		WinX := X - WinW/2
		WinY := Y - WinH/2
	} else
		WinGetPos, WinX, WinY, WinW, WinH, % WinTitle

	if (IsMove) {
		HorizontalResize := 0
		VerticalResize := 0
	} else {
		HorizontalResize := (X - WinX) * 3 // WinW - 1
		VerticalResize := (Y - WinY) * 3 // WinH - 1
	}
	if (not HorizontalResize and not VerticalResize) {
		ResizeMoveWindowDo(OrigX, OrigY, WinTitle)
	} else {
		ResizeResizeWindowDo(OrigX, OrigY, WinTitle, HorizontalResize, VerticalResize, WinX, WinY, WinW, WinH)
	}
}

ResizeMoveWindowDo(OrigX, OrigY, WinTitle) {
	global HotkeyResize, HotkeyMoveResize, MoveToTopToMaximize, MarginWidth, MarginWidthHalf, SnapToWindows, SnapToGrid
	WinGetPos, WinX, WinY, WinW, WinH, % WinTitle
	NewX := WinX
	NewY := WinY
	while (GetKeyState(HotkeyResize, "P")) {
		if (HotkeyMoveResize and GetKeyState(HotkeyMoveResize, "P")) {
			MoveResizeWindowDo(WinTitle)
			return
		}
		MouseGetPos, X, Y
		NewX := X - OrigX + WinX
		NewY := Y - OrigY + WinY
		if (SnapToGrid) {
			Index := LoopVs(True, NewX, NewY, 0, 1)
			if (Index)
				NewX := GetX(Index) + (GetCornerV(Index) ? MarginWidth : MarginWidthHalf)
			else {
				Index := LoopVs(False, NewX + WinW, NewY, 0, 1)
				if (Index)
					NewX := GetX(Index) - WinW - (GetCornerV(Index) ? MarginWidth : MarginWidthHalf)
			}

			Index := LoopHs(True, NewX, NewY, 0, 1)
			if (Index)
				NewY := GetY(Index) + (GetCornerH(Index) ? MarginWidth : MarginWidthHalf)
			else {
				Index := LoopHs(False, NewX, NewY + WinH, 0, 1)
				if (Index)
					NewY := GetY(Index) - WinH - (GetCornerH(Index) ? MarginWidth : MarginWidthHalf)
			}
		} if (SnapToWindows) {
			OldX := NewX
			NewX := LoopWindows(True, True, NewX, NewY, WinTitle, WinW)
			if (OldX = NewX)
				NewX := LoopWindows(True, False, NewX + WinW, NewY, WinTitle, WinH) - WinW

			OldY := NewY
			NewY := LoopWindows(False, True, NewX, NewY, WinTitle, WinW)
			if (OldY = NewY)
				NewY := LoopWindows(False, False, NewX, NewY + WinH, WinTitle, WinH) - WinH
		}
		ShowPreviewAt(NewX, NewY, WinW, WinH)
	}
	if (MoveToTopToMaximize and Y = GetTopPos(X, Y))
		WinMaximize, % WinTitle
	else {
		WinRestore, % WinTitle
		WinMove, % WinTitle, , % NewX, % NewY, WinW, WinH
	}
}

ResizeResizeWindowDo(OrigX, OrigY, WinTitle, HorizontalResize, VerticalResize, WinX, WinY, WinW, WinH) {
	global HotkeyResize, MarginWidth, MarginWidthHalf, SnapToWindows, SnapToGrid
	while (GetKeyState(HotkeyResize, "P")) {
		MouseGetPos, X, Y
		NewX0 := WinX
		NewY0 := WinY
		NewX1 := WinX + WinW
		NewY1 := WinY + WinH
		if (HorizontalResize == -1) {
			NewX0 += X - OrigX
			if (SnapToWindows)
				NewX0 := LoopWindows(True, True, NewX0, NewY0 + Y - OrigY, WinTitle)
			if (SnapToGrid) {
				Index := LoopVs(True, NewX0, Y, 0, 1)
				if (Index)
					NewX0 := GetX(Index) + (GetCornerV(Index) ? MarginWidth : MarginWidthHalf)
			}
		} else if (HorizontalResize == 1) {
			NewX1 += X - OrigX
			if (SnapToWindows)
				NewX1 := LoopWindows(True, False, NewX1, NewY1 + Y - OrigY, WinTitle)
			if (SnapToGrid) {
				Index := LoopVs(False, NewX1, Y, 0, 1)
				if (Index)
					NewX1 := GetX(Index) - (GetCornerV(Index) ? MarginWidth : MarginWidthHalf)
			}
		}
		if (VerticalResize == -1) {
			NewY0 += Y - OrigY
			if (SnapToWindows)
				NewY0 := LoopWindows(False, True, NewX0 + X - OrigX, NewY0, WinTitle)
			if (SnapToGrid) {
				Index := LoopHs(True, X, NewY0, 0, 1)
				if (Index)
					NewY0 := GetY(Index) + (GetCornerH(Index) ? MarginWidth : MarginWidthHalf)
			}
		} else if (VerticalResize == 1) {
			NewY1 += Y - OrigY
			if (SnapToWindows)
				NewY1 := LoopWindows(False, False, NewX1 + X - OrigX, NewY1, WinTitle)
			if (SnapToGrid) {
				Index := LoopHs(False, X, NewY1, 0, 1)
				if (Index)
					NewY1 := GetY(Index) - (GetCornerH(Index) ? MarginWidth : MarginWidthHalf)
			}
		}
		ShowPreviewAt(NewX0, NewY0, NewX1 - NewX0, NewY1 - NewY0)
	}
	WinMove, % WinTitle, , % NewX0, % NewY0, % NewX1 - NewX0, % NewY1 - NewY0
}

MoveWindowToTile(Title, Left, Right, Top, Bottom) {
	global MarginWidth, MarginWidthHalf
	X := GetX(Left) + (GetCornerV(Left) ? MarginWidth : MarginWidthHalf)
	Y := GetY(Top) + (GetCornerH(Top) ? MarginWidth : MarginWidthHalf)
	Width := GetX(Right) - X - (GetCornerV(Right) ? MarginWidth : MarginWidthHalf)
	Height := GetY(Bottom) - Y  - (GetCornerH(Bottom) ? MarginWidth : MarginWidthHalf)
	WinMove, % Title,, % X, % Y, % Width, % Height
}

MovePreviewToTile(Left, Right, Top, Bottom) {
	global MarginWidth, MarginWidthHalf
	X := GetX(Left) + (GetCornerV(Left) ? MarginWidth : MarginWidthHalf)
	Y := GetY(Top) + (GetCornerH(Top) ? MarginWidth : MarginWidthHalf)
	Width := GetX(Right) - X - (GetCornerV(Right) ? MarginWidth : MarginWidthHalf)
	Height := GetY(Bottom) - Y  - (GetCornerH(Bottom) ? MarginWidth : MarginWidthHalf)
	MovePreviewTo(X, Y, Width, Height)
}

MovePreviewTo(X, Y, W, H) {
	global startX, startY, startW, startH, nowX, nowY, nowW, nowH, targX, targY, targW, targH, startTime, hidePreview

	if (targX == X and targY == Y and targW == W and targH == H) {
		return
	}
	if (nowX == X and nowY == Y and nowW == W and nowH == H) {
		return
	}

	hidePreview := False

	startX := nowX
	startY := nowY
	startW := nowW
	startH := nowH

	targX := X
	targY := Y
	targW := W
	targH := H

	startTime := A_TickCount

	SetTimer, UpdatePreviewPosition, 10
}

Bezier(t, p0, p1, p2, p3) {
	ti := (1-t)
	return ti*ti*ti*p0 + 3*ti*ti*t*p1 + 3*ti*t*t*p2 + t*t*t*p3
}

SearchBezier(target, x1, y1, x2, y2) {
	tolerance := 0.0001

	min := 0
	max := 1
	percent := 0.5

	x := Bezier(percent, 0, x1, x2, 1)

	while (Abs(target - x) > tolerance) {
		if (target > x)
			min := percent
		else
			max := percent
		percent := (min + max) / 2
		x := Bezier(percent, 0, x1, x2, 1)
	}
	return Bezier(percent, 0, y1, y2, 1)
}

Ease(start, targ, startTime) {
	global AnimationDuration
	nowTime := A_TickCount - startTime
	if (nowTime >= AnimationDuration) {
		return targ
	} else {
		return start + SearchBezier(nowTime/AnimationDuration, 0.4, 0, 0.2, 1)*(targ-start)
	}
}

UpdatePreviewPosition:
	nowX := Ease(startX, targX, startTime)
	nowY := Ease(startY, targY, startTime)
	nowW := Ease(startW, targW, startTime)
	nowH := Ease(startH, targH, startTime)

	if (A_TickCount - startTime >= AnimationDuration) {
		SetTimer, UpdatePreviewPosition, Off
		if (hidePreview) {
			HidePreview()
		} else {
			ShowPreviewAt(nowX, nowY, nowW, nowH)
		}
	} else {
		ShowPreviewAt(nowX, nowY, nowW, nowH)
	}
return

InitializePreviewAt(WinX, WinY, WinW, WinH) {
	global targX, targY, targW, targH, nowX, nowY, nowW, nowH, startTime

	targX := WinX
	targY := WinY
	targW := WinW
	targH := WinH

	nowX := WinX
	nowY := WinY
	nowW := WinW
	nowH := WinH

	startTime := 0
	
	ShowPreviewAt(WinX, WinY, WinW, WinH)
	MovePreviewTo(WinX, WinY, WinW, WinH)
}

MaximizePreview() {
	Sysget, MonitorCount, 80
	loop % MonitorCount {
		Sysget, Monitor, Monitor, % A_Index
		if (MonitorLeft <= x and x < MonitorRight and MonitorTop <= y and y < MonitorBottom)
			MovePreviewTo(MonitorLeft, MonitorTop, MonitorRight - MonitorLeft, MonitorBottom - MonitorTop)
			return
	}
}

MinimizePreview() {
	global nowX, nowY, nowW, nowH
	MovePreviewTo(nowX+nowW/2, nowY+nowH/2, 0, 0)
}

ShowPreviewAt(X, Y, W, H) {
	global nowX, nowY, nowW, nowH, startTime, AnimationDuration
	Gui, 2:Show, % "x" . X . " y" . Y . " w" . W . " h" . H
}

HidePreviewAfterAnimation() {
	global hidePreview
	hidePreview := True
}

HidePreview() {
	global hidePreview
	Gui, 2:Hide
	hidePreview := False
}

GetBestTile(MouseX, MouseY, ByRef Left, ByRef Right, ByRef Top, ByRef Bottom) {
	Left := GetLeftLine(MouseX, MouseY, 1)
	Right := GetRightLine(MouseX, MouseY, 1)
	Top := GetTopLine(MouseX, MouseY, 1)
	Bottom := GetBottomLine(MouseX, MouseY, 1)

	if (Left and Right and Top and Bottom)
		return 1
	else
		return 0
}
GetBoundingTile(MouseX0, MouseY0, MouseX1, MouseY1, ByRef Left, ByRef Right, ByRef Top, ByRef Bottom) {
	if (MouseX0 > MouseX1)
	{
		Temp := MouseX0
		MouseX0 := MouseX1
		MouseX1 := Temp
	}
	if (MouseY0 > MouseY1)
	{
		Temp := MouseY0
		MouseY0 := MouseY1
		MouseY1 := Temp
	}
	Left := GetLeftLine(MouseX0, MouseY0)
	Right := GetRightLine(MouseX1, MouseY1)
	Top := GetTopLine(MouseX0, MouseY0)
	Bottom := GetBottomLine(MouseX1, MouseY1)
 
	if (Left and Right and Top and Bottom)
		return 1
	else
		return 0
}
GetLeftLine(MouseX, MouseY, Best=0) {
	return LoopVs(False, MouseX, MouseY, Best)
}
GetRightLine(MouseX, MouseY, Best=0) {
	return LoopVs(True, MouseX, MouseY, Best)
}
GetTopLine(MouseX, MouseY, Best=0) {
	return LoopHs(False, MouseX, MouseY, Best)
} 
GetBottomLine(MouseX, MouseY, Best=0) {
	return LoopHs(True, MouseX, MouseY, Best)
} 
LoopVs(LeftToRight, MouseX, MouseY, Best=0, Nearest=0) {
	global V, SnapDistance
	loop % V.MaxIndex() {
		Index := LeftToRight ? A_Index : (V.MaxIndex() - A_Index + 1)
		if (Best and GetResizeV(Index))
			Continue
		if (GetY1(Index) > MouseY and MouseY >= GetY0(Index))
		{
			if (Nearest ? (abs(MouseX - GetX(Index)) < SnapDistance) : (LeftToRight ? (GetX(Index) > MouseX) : (MouseX >= GetX(Index))))
			{
				return Index
			}
		}
	}
	return 0
}
LoopHs(TopToBottom, MouseX, MouseY, Best=0, Nearest=0) {
	global H, SnapDistance
	loop % H.MaxIndex() {
		Index := TopToBottom ? A_Index : (H.MaxIndex() - A_Index + 1)
		if (Best and GetResizeH(Index))
			Continue
		if (GetX1(Index) > MouseX and MouseX >= GetX0(Index))
		{
			if (Nearest ? (abs(MouseY - GetY(Index)) < SnapDistance) : (TopToBottom ? (GetY(Index) > MouseY) : (MouseY >= GetY(Index))))
			{
				return Index
			}
		}
	}
	return 0
}
LoopWindows(IsHorizontal, IsReversed, X, Y, WinTitle, Length=0) {
	global SnapDistance, MarginWidth, PreviewID

	WinGetPos, CurrWinX, CurrWinY, CurrWinW, CurrWinH, % WinTitle
	BestDistance := SnapDistance
	NewPos := IsHorizontal ? X : Y
	WinGet, id, list,,, Program Manager
	loop, % id
	{
		if ("ahk_id " . id%A_Index% = WinTitle or id%A_Index% = PreviewID)
			Continue
		WinGet, WinExStyle, ExStyle, % WinTitle
		if (WinExStyle & 0x80)
			Continue
		WinGet, WinMinMax, MinMax, % WinTitle
		if (WinMinMax != 0)
			Continue
		WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id" . id%A_Index%
		if (IsHorizontal ? (WinY - MarginWidth - Length < Y and Y < WinY + WinH + MarginWidth + Length) : (WinX - MarginWidth - Length < X and X < WinX + WinW + MarginWidth + Length)) {
			NewDistance := IsHorizontal ? abs(WinX - X) : abs(WinY - Y)
			if (NewDistance < BestDistance) {
				NewPos := (IsHorizontal ? WinX : WinY) + MarginWidth * (IsReversed ? 0 : -1)
				BestDistance := NewDistance
			}
			NewDistance := IsHorizontal ? abs(WinX + WinW - X) : abs(WinY + WinH - Y)
			if (NewDistance < BestDistance) {
				NewPos := (IsHorizontal ? WinX + WinW : WinY + WinH) + MarginWidth * (IsReversed ? 1 : 0)
				BestDistance := NewDistance
			}
		}
	}
	return NewPos
}
GetEdgeV(IsReversed, X, Y, WinTitle) {
	global MarginWidth, MarginWidthHalf
	Index := LoopVs(IsReversed, X, Y, 0, 1)
	if (Index)
		return GetX(Index) + (GetCornerV(Index) ? MarginWidth : MarginWidthHalf) * (IsReversed ? 1 : -1)
	return LoopWindows(True, IsReversed, X, Y, WinTitle)
}
GetEdgeH(IsReversed, X, Y, WinTitle) {
	global MarginWidth, MarginWidthHalf
	Index := LoopHs(IsReversed, X, Y, 0, 1)
	if (Index)
		return GetY(Index) + (GetCornerH(Index) ? MarginWidth : MarginWidthHalf) * (IsReversed ? 1 : -1)
	return LoopWindows(False, IsReversed, X, Y, WinTitle)
}
GetX(index) {
	global V
	return V[index][1]
}
GetY0(index) {
	global V, H
	return H[V[index][2]][1]
}
GetY1(index) {
	global V, H
	return H[V[index][3]][1]
}
GetY(index) {
	global H
	return H[index][1]
}
GetX0(index) {
	global V, H
	return V[H[index][2]][1]
}
GetX1(index) {
	global V, H
	return V[H[index][3]][1]
}
GetCornerV(index) {
	global V
	return V[index][4]
}
GetCornerH(index) {
	global H
	return H[index][4]
}
GetResizeV(index) {
	global V
	return V[index][5]
}
GetResizeH(index) {
	global H
	return H[index][5]
}
DrawWindow(title) {
	global VisibleGrid
	WinActivate, % title
	if (VisibleGrid)
		ShowGrid()
}
UndrawWindow(title) {
	global VisibleGrid
	if (VisibleGrid)
		HideGrid()
}
GetBottomPos(x, y) {
	Sysget, MonitorCount, 80
	loop % MonitorCount {
		Sysget, Monitor, Monitor, % A_Index
		if (MonitorLeft <= x and x < MonitorRight and MonitorTop <= y and y < MonitorBottom)
			return MonitorBottom - 1
	}
}
GetTopPos(x, y) {
	Sysget, MonitorCount, 80
	loop % MonitorCount {
		Sysget, Monitor, Monitor, % A_Index
		if (MonitorLeft <= x and x <= MonitorRight and MonitorTop <= y and y <= MonitorBottom)
			return MonitorTop
	}
}

CreateBitmap() {
	global ColorGrid
	; Create bitmap
	VarSetCapacity( BMP, 64 )
	NumPut( 19778, BMP, 0, "UShort" ) ; bfType - must always be set to 'BM' to declare that this is a .bmp-file.
	NumPut(    62, BMP, 2, "UShort" ) ; bfSize - specifies the size of the file in bytes.
	NumPut(     0, BMP, 6, "UInt"   ) ; reserved
	NumPut(    54, BMP,10, "UInt"   ) ; bfOffBits - specifies the offset from the beginning of the file to the bitmap data.
	NumPut(    40, BMP,14, "UInt"   ) ; biSize - 40 specifies the size of the BITMAPINFOHEADER structure, in bytes.
	NumPut(     1, BMP,18, "UInt"   ) ; biWidth - specifies the width of the image, in pixels. 
	NumPut(     1, BMP,22, "UInt"   ) ; biHeight - specifies the height of the image, in pixels.  
	NumPut(     1, BMP,26, "UShort" ) ; biPlanes - specifies the number of planes of the target device, must be set to zero. 
	NumPut(    24, BMP,28, "UShort" ) ; biBitCount - specifies the number of bits per pixel. 
	NumPut(     0, BMP,30, "UInt"   ) ; biCompression - Specifies the type of compression, usually set to zero (no compression). 
	NumPut(     8, BMP,34, "UInt"   ) ; biSizeImage - specifies the size of the image data, in bytes. 
	NumPut(     0, BMP,38, "UInt"   ) ; biXPelsPerMeter - specifies the the horizontal pixels per meter on the designated target device, usually set to zero.
	NumPut(     0, BMP,42, "UInt"   ) ; biYPelsPerMeter - specifies the the horizontal pixels per meter on the designated target device, usually set to zero.
	NumPut(     0, BMP,46, "UInt"   ) ; biClrUsed - specifies the number of colors used in the bitmap, if set to zero the number of colors is calculated using the biBitCount member.
	NumPut(     0, BMP,50, "UInt"   ) ; biClrImportant - specifies the number of color that are 'important' for the bitmap, if set to zero, all colors are important

	; RGBQUAD - Data area
	NumPut( ColorGrid, BMP, 54, "UInt" ) ; Pixel Color - Black in BGR  

	GENERIC_WRITE = 0x40000000  ; Open the file for writing rather than reading.
	CREATE_ALWAYS = 2  ; Create new file (overwriting any existing file).
	hFile := DllCall( "CreateFile", Str, "pixel.bmp", Uint, GENERIC_WRITE, Uint, 0, UInt, 0, UInt, CREATE_ALWAYS, Uint, 0, UInt, 0)
	DllCall("WriteFile", UInt, hFile, Str, BMP, UInt, 62, UIntP, BytesActuallyWritten, UInt, 0)
	DllCall("CloseHandle", UInt, hFile)
}
	
CreatePreview() {
	global ColorPreview, TransparencyPreview
	Gui, 2:Default
	Gui, Color, % ColorPreview
	Gui, +LastFound
	WinSet, Transparent, % TransparencyPreview
	Gui, +Owner +AlwaysOnTop -Resize -SysMenu -MinimizeBox -MaximizeBox -Disabled -Caption -Border -ToolWindow
	return WinExist()
} 
CreateGrid() {
	global V, H, MarginWidth, ScreenX, ScreenY, TransparencyGrid

	LineWidth := MarginWidth = 0 ? 2 : MarginWidth
	Gui, 1:Default
	Gui, Color, 0xFF00FF
	Gui, +LastFound
	WinSet, TransColor, 0xFF00FF %TransparencyGrid%
	Gui, +Owner +AlwaysOnTop -Resize -SysMenu -MinimizeBox -MaximizeBox -Disabled -Caption -Border -ToolWindow
	loop, % V.MaxIndex() {
		X := GetX(A_Index) - ScreenX   ; to convert the position to positive
		Y := GetY0(A_Index) - ScreenY                         ; to convert the position to positive
		Height := GetY1(A_Index) - GetY0(A_Index)
		if (GetCornerV(A_Index))
			Gui, Add, Picture, % "x" . X-LineWidth . " y" . Y . " w" . LineWidth*2 . " h" . Height, pixel.bmp
		else
			Gui, Add, Picture, % "x" . X-LineWidth//2 . " y" . Y . " w" . LineWidth . " h" . Height, pixel.bmp
	}
	loop, % H.MaxIndex() {
		Y := GetY(A_Index) - ScreenY   ; to convert the position to positive
		X := GetX0(A_Index) - ScreenX                         ; to convert the position to positive
		Width := GetX1(A_Index) - GetX0(A_Index)
		if (GetCornerH(A_Index))
			Gui, Add, Picture, % "x" . X . " y" . Y-LineWidth . " w" . Width . " h" . LineWidth*2, pixel.bmp
		else
			Gui, Add, Picture, % "x" . X . " y" . Y-LineWidth//2 . " w" . Width . " h" . LineWidth, pixel.bmp
	}
}
ShowGrid() {
	global ScreenX, ScreenY, ScreenW, ScreenH
	Gui, 1:Show, % "x" . ScreenX . " y" . ScreenY . " w" . ScreenW . " h" . ScreenH
}
HideGrid() {
	Gui, 1:Hide
}
#if VisibleGrid
NumpadDiv::ShowGrid()
NumpadDiv Up::HideGrid()
#if