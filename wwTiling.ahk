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
TopPos := ScreenY                 ; Y-Coord of the top of the screen
MoveToBottomToClose := True       ; Minimize the window if it is moved to the bottom of the screen?
BottomPos := ScreenH-1            ; Y-Coord of the bottom of the screen

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
Return

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
Return

Finalise:
	If (HotkeyMove)
		Hotkey, % HotkeyModifier . HotkeyMove, MoveWindow
	If (HotkeyResize)
		Hotkey, % HotkeyModifier . HotkeyResize, ResizeWindow
	PreviewID := CreatePreview()
	If (VisibleGrid) {
		CreateBitmap()
		CreateGrid()
	}
Return

MoveWindow:
	MoveWindow()
Return

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
	Global MinimumMovement, MoveToTopToMaximize, TopPos, MoveToBottomToClose, BottomPos, HotkeyMove, HotkeyMoveResize
	While 1 {
		Sleep 10 ; Sleep until movement exceeds threshold or button is released
		MouseGetPos, X, Y
		If (abs(OrigX - X) > MinimumMovement or abs(OrigY - Y) > MinimumMovement)
			Break
		If (!GetKeyState(HotkeyMove, "P")) {
			If (MoveToTopToMaximize and OrigY = TopPos)
				WinMaximize, % WinTitle
			Return
		}
	}

	Left := 0, Right = 0, Top = 0, Bottom = 0
	While (GetKeyState(HotkeyMove, "P")) {
		If (HotkeyMoveResize and GetKeyState(HotkeyMoveResize, "P")) {
			MoveResizeWindowDo(WinTitle)
			Return
		}
		MouseGetPos, X, Y
		If (MoveToTopToMaximize and Y = TopPos) {
			MaximizePreview()
			MoveWindowDo(X, Y, WinTitle)
			Return
		}
		If (MoveToBottomToClose and Y = BottomPos) {
			MinimizePreview()
			MoveWindowDo(X, Y, WinTitle)
			Return
		}
		Left := 0, Right = 0, Top = 0, Bottom = 0
		If (GetBestTile(X, Y, Left, Right, Top, Bottom))
			MovePreviewToTile(Left, Right, Top, Bottom)
	}
	WinRestore, % WinTitle
	MoveWindowToTile(WinTitle, Left, Right, Top, Bottom)
	If (MoveToBottomToClose and Y = BottomPos) {
		WinClose, % WinTitle
	}
}

MoveResizeWindowDo(WinTitle) {
	Global HotkeyMoveResize, HotkeyMove, HotkeyResize
	MouseGetPos, OrigX, OrigY
	Left := 0, Right = 0, Top = 0, Bottom = 0
	Released := False
	While (GetKeyState(HotkeyMove, "P") or GetKeyState(HotkeyResize, "P")) {
		MouseGetPos, X, Y
		If (GetKeyState(HotkeyMoveResize, "P")) {
			If (Released) {
				OrigX := X, OrigY := Y
				Released := False
			}
		} Else {
			Released := True
		}
		Left := 0, Right = 0, Top = 0, Bottom = 0
		If (GetBoundingTile(OrigX, OrigY, X, Y, Left, Right, Top, Bottom))
			MovePreviewToTile(Left, Right, Top, Bottom)
	}
	WinRestore, % WinTitle
	MoveWindowToTile(WinTitle, Left, Right, Top, Bottom)
}

ResizeWindow:
	ResizeWindow()
Return

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
	Global MinimumMovement, HotkeyResize, MoveToTopToMaximize, TopPos
	While 1 {
		Sleep 10 ; Sleep until movement exceeds threshold or button is released
		MouseGetPos, X, Y
		If (abs(OrigX - X) > MinimumMovement or abs(OrigY - Y) > MinimumMovement)
			Break
		If (!GetKeyState(HotkeyResize, "P")) {
			If (MoveToTopToMaximize and OrigY = TopPos)
				WinMaximize, % WinTitle
			Return
		}
	}

	WinGet, MinMax, MinMax, % WinTitle
	If (MoveToTopToMaximize and MinMax = 1) {
		WinGetPos, WinX, WinY, WinW, WinH, % WinTitle
		WinX := X - WinW/2
		WinY := Y - WinH/2
	} Else
		WinGetPos, WinX, WinY, WinW, WinH, % WinTitle

	If (IsMove) {
		HorizontalResize := 0
		VerticalResize := 0
	} Else {
		HorizontalResize := (X - WinX) * 3 // WinW - 1
		VerticalResize := (Y - WinY) * 3 // WinH - 1
	}
	If (not HorizontalResize and not VerticalResize) {
		ResizeMoveWindowDo(OrigX, OrigY, WinTitle)
	} Else {
		ResizeResizeWindowDo(OrigX, OrigY, WinTitle, HorizontalResize, VerticalResize, WinX, WinY, WinW, WinH)
	}
}

ResizeMoveWindowDo(OrigX, OrigY, WinTitle) {
	Global HotkeyResize, HotkeyMoveResize, MoveToTopToMaximize, TopPos, MarginWidth, MarginWidthHalf, SnapToWindows, SnapToGrid
	WinGetPos, WinX, WinY, WinW, WinH, % WinTitle
	NewX := WinX
	NewY := WinY
	While (GetKeyState(HotkeyResize, "P")) {
		If (HotkeyMoveResize and GetKeyState(HotkeyMoveResize, "P")) {
			MoveResizeWindowDo(WinTitle)
			Return
		}
		MouseGetPos, X, Y
		NewX := X - OrigX + WinX
		NewY := Y - OrigY + WinY
		If (SnapToGrid) {
			Index := LoopVs(True, NewX, NewY, 0, 1)
			If (Index)
				NewX := GetX(Index) + (GetCornerV(Index) ? MarginWidth : MarginWidthHalf)
			Else {
				Index := LoopVs(False, NewX + WinW, NewY, 0, 1)
				If (Index)
					NewX := GetX(Index) - WinW - (GetCornerV(Index) ? MarginWidth : MarginWidthHalf)
			}

			Index := LoopHs(True, NewX, NewY, 0, 1)
			If (Index)
				NewY := GetY(Index) + (GetCornerH(Index) ? MarginWidth : MarginWidthHalf)
			Else {
				Index := LoopHs(False, NewX, NewY + WinH, 0, 1)
				If (Index)
					NewY := GetY(Index) - WinH - (GetCornerH(Index) ? MarginWidth : MarginWidthHalf)
			}
		} If (SnapToWindows) {
			OldX := NewX
			NewX := LoopWindows(True, True, NewX, NewY, WinTitle, WinW)
			If (OldX = NewX)
				NewX := LoopWindows(True, False, NewX + WinW, NewY, WinTitle, WinH) - WinW

			OldY := NewY
			NewY := LoopWindows(False, True, NewX, NewY, WinTitle, WinW)
			If (OldY = NewY)
				NewY := LoopWindows(False, False, NewX, NewY + WinH, WinTitle, WinH) - WinH
		}
		ShowPreviewAt(NewX, NewY, WinW, WinH)
	}
	If (MoveToTopToMaximize and Y = TopPos)
		WinMaximize, % WinTitle
	Else {
		WinRestore, % WinTitle
		WinMove, % WinTitle, , % NewX, % NewY, WinW, WinH
	}
}

ResizeResizeWindowDo(OrigX, OrigY, WinTitle, HorizontalResize, VerticalResize, WinX, WinY, WinW, WinH) {
	Global HotkeyResize, MarginWidth, MarginWidthHalf, SnapToWindows, SnapToGrid
	While (GetKeyState(HotkeyResize, "P")) {
		MouseGetPos, X, Y
		NewX0 := WinX
		NewY0 := WinY
		NewX1 := WinX + WinW
		NewY1 := WinY + WinH
		If (HorizontalResize == -1) {
			NewX0 += X - OrigX
			If (SnapToWindows)
				NewX0 := LoopWindows(True, True, NewX0, Y, WinTitle)
			If (SnapToGrid) {
				Index := LoopVs(True, NewX0, Y, 0, 1)
				If (Index)
					NewX0 := GetX(Index) + (GetCornerV(Index) ? MarginWidth : MarginWidthHalf)
			}
		} Else If (HorizontalResize == 1) {
			NewX1 += X - OrigX
			If (SnapToWindows)
				NewX1 := LoopWindows(True, False, NewX1, Y, WinTitle)
			If (SnapToGrid) {
				Index := LoopVs(False, NewX1, Y, 0, 1)
				If (Index)
					NewX1 := GetX(Index) - (GetCornerV(Index) ? MarginWidth : MarginWidthHalf)
			}
		}
		If (VerticalResize == -1) {
			NewY0 += Y - OrigY
			If (SnapToWindows)
				NewY0 := LoopWindows(False, True, X, NewY0, WinTitle)
			If (SnapToGrid) {
				Index := LoopHs(True, X, NewY0, 0, 1)
				If (Index)
					NewY0 := GetY(Index) + (GetCornerH(Index) ? MarginWidth : MarginWidthHalf)
			}
		} Else If (VerticalResize == 1) {
			NewY1 += Y - OrigY
			If (SnapToWindows)
				NewY1 := LoopWindows(False, False, X, NewY1, WinTitle)
			If (SnapToGrid) {
				Index := LoopHs(False, X, NewY1, 0, 1)
				If (Index)
					NewY1 := GetY(Index) - (GetCornerH(Index) ? MarginWidth : MarginWidthHalf)
			}
		}
		ShowPreviewAt(NewX0, NewY0, NewX1 - NewX0, NewY1 - NewY0)
	}
	WinMove, % WinTitle, , % NewX0, % NewY0, % NewX1 - NewX0, % NewY1 - NewY0
}

MoveWindowToTile(Title, Left, Right, Top, Bottom) {
	Global MarginWidth, MarginWidthHalf
	X := GetX(Left) + (GetCornerV(Left) ? MarginWidth : MarginWidthHalf)
	Y := GetY(Top) + (GetCornerH(Top) ? MarginWidth : MarginWidthHalf)
	Width := GetX(Right) - X - (GetCornerV(Right) ? MarginWidth : MarginWidthHalf)
	Height := GetY(Bottom) - Y  - (GetCornerH(Bottom) ? MarginWidth : MarginWidthHalf)
	WinMove, % Title,, % X, % Y, % Width, % Height
}

MovePreviewToTile(Left, Right, Top, Bottom) {
	Global MarginWidth, MarginWidthHalf
	X := GetX(Left) + (GetCornerV(Left) ? MarginWidth : MarginWidthHalf)
	Y := GetY(Top) + (GetCornerH(Top) ? MarginWidth : MarginWidthHalf)
	Width := GetX(Right) - X - (GetCornerV(Right) ? MarginWidth : MarginWidthHalf)
	Height := GetY(Bottom) - Y  - (GetCornerH(Bottom) ? MarginWidth : MarginWidthHalf)
	MovePreviewTo(X, Y, Width, Height)
}

MovePreviewTo(X, Y, W, H) {
	Global startX, startY, startW, startH, nowX, nowY, nowW, nowH, targX, targY, targW, targH, startTime, hidePreview

	if (targX == X and targY == Y and targW == W and targH == H) {
		Return
	}
	if (nowX == X and nowY == Y and nowW == W and nowH == H) {
		Return
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
	Global AnimationDuration
	nowTime := A_TickCount - startTime
	if (nowTime >= AnimationDuration) {
		Return targ
	} else {
		Return start + SearchBezier(nowTime/AnimationDuration, 0.4, 0, 0.2, 1)*(targ-start)
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
Return

InitializePreviewAt(WinX, WinY, WinW, WinH) {
	Global targX, targY, targW, targH, nowX, nowY, nowW, nowH, startTime
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
	Global ScreenX, ScreenY, ScreenW, ScreenH
	MovePreviewTo(ScreenX, ScreenY, ScreenW, ScreenH)
}

MinimizePreview() {
	Global nowX, nowY, nowW, nowH
	MovePreviewTo(nowX+nowW/2, nowY+nowH/2, 0, 0)
}

ShowPreviewAt(X, Y, W, H) {
	Global nowX, nowY, nowW, nowH, startTime, AnimationDuration
	Gui, 2:Show, % "x" . X . " y" . Y . " w" . W . " h" . H
}

HidePreviewAfterAnimation() {
	Global hidePreview
	hidePreview := True
}

HidePreview() {
	Global hidePreview
	Gui, 2:Hide
	hidePreview := False
}

GetBestTile(MouseX, MouseY, ByRef Left, ByRef Right, ByRef Top, ByRef Bottom) {
	Left := GetLeftLine(MouseX, MouseY, 1)
	Right := GetRightLine(MouseX, MouseY, 1)
	Top := GetTopLine(MouseX, MouseY, 1)
	Bottom := GetBottomLine(MouseX, MouseY, 1)

	If (Left and Right and Top and Bottom)
		Return 1
	Else
		Return 0
}
GetBoundingTile(MouseX0, MouseY0, MouseX1, MouseY1, ByRef Left, ByRef Right, ByRef Top, ByRef Bottom) {
	If (MouseX0 > MouseX1)
	{
		Temp := MouseX0
		MouseX0 := MouseX1
		MouseX1 := Temp
	}
	If (MouseY0 > MouseY1)
	{
		Temp := MouseY0
		MouseY0 := MouseY1
		MouseY1 := Temp
	}
	Left := GetLeftLine(MouseX0, MouseY0)
	Right := GetRightLine(MouseX1, MouseY1)
	Top := GetTopLine(MouseX0, MouseY0)
	Bottom := GetBottomLine(MouseX1, MouseY1)
 
	If (Left and Right and Top and Bottom)
		Return 1
	Else
		Return 0
}
GetLeftLine(MouseX, MouseY, Best=0) {
	Return LoopVs(False, MouseX, MouseY, Best)
}
GetRightLine(MouseX, MouseY, Best=0) {
	Return LoopVs(True, MouseX, MouseY, Best)
}
GetTopLine(MouseX, MouseY, Best=0) {
	Return LoopHs(False, MouseX, MouseY, Best)
} 
GetBottomLine(MouseX, MouseY, Best=0) {
	Return LoopHs(True, MouseX, MouseY, Best)
} 
LoopVs(LeftToRight, MouseX, MouseY, Best=0, Nearest=0) {
	Global V, SnapDistance
	Loop % V.MaxIndex() {
		Index := LeftToRight ? A_Index : (V.MaxIndex() - A_Index + 1)
		If (Best and GetResizeV(Index))
			Continue
		If (GetY1(Index) > MouseY and MouseY >= GetY0(Index))
		{
			If (Nearest ? (abs(MouseX - GetX(Index)) < SnapDistance) : (LeftToRight ? (GetX(Index) > MouseX) : (MouseX >= GetX(Index))))
			{
				Return Index
			}
		}
	}
	Return 0
}
LoopHs(TopToBottom, MouseX, MouseY, Best=0, Nearest=0) {
	Global H, SnapDistance
	Loop % H.MaxIndex() {
		Index := TopToBottom ? A_Index : (H.MaxIndex() - A_Index + 1)
		If (Best and GetResizeH(Index))
			Continue
		If (GetX1(Index) > MouseX and MouseX >= GetX0(Index))
		{
			If (Nearest ? (abs(MouseY - GetY(Index)) < SnapDistance) : (TopToBottom ? (GetY(Index) > MouseY) : (MouseY >= GetY(Index))))
			{
				Return Index
			}
		}
	}
	Return 0
}
LoopWindows(IsHorizontal, IsReversed, X, Y, WinTitle, Length=0) {
	Global SnapDistance, MarginWidth, PreviewID

	WinGetPos, CurrWinX, CurrWinY, CurrWinW, CurrWinH, % WinTitle
	BestDistance := SnapDistance
	NewPos := IsHorizontal ? X : Y
	WinGet, id, list,,, Program Manager
	Loop, % id
	{
		WinGet, WinExStyle, ExStyle, % WinTitle
		If (WinExStyle & 0x80 or id%A_Index% = CurrentWindow)
			Continue
		If ("ahk_id " . id%A_Index% = WinTitle or id%A_Index% = PreviewID)
			Continue
		WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id" . id%A_Index%
		If (IsHorizontal ? (WinY - MarginWidth - Length < Y and Y < WinY + WinH + MarginWidth + Length) : (WinX - MarginWidth - Length < X and X < WinX + WinW + MarginWidth + Length)) {
			NewDistance := IsHorizontal ? abs(WinX - X) : abs(WinY - Y)
			If (NewDistance < BestDistance) {
				NewPos := (IsHorizontal ? WinX : WinY) + MarginWidth * (IsReversed ? 0 : -1)
				BestDistance := NewDistance
			}
			NewDistance := IsHorizontal ? abs(WinX + WinW - X) : abs(WinY + WinH - Y)
			If (NewDistance < BestDistance) {
				NewPos := (IsHorizontal ? WinX + WinW : WinY + WinH) + MarginWidth * (IsReversed ? 1 : 0)
				BestDistance := NewDistance
			}
		}
	}
	Return NewPos
}
GetEdgeV(IsReversed, X, Y, WinTitle) {
	Global MarginWidth, MarginWidthHalf
	Index := LoopVs(IsReversed, X, Y, 0, 1)
	If (Index)
		Return GetX(Index) + (GetCornerV(Index) ? MarginWidth : MarginWidthHalf) * (IsReversed ? 1 : -1)
	Return LoopWindows(True, IsReversed, X, Y, WinTitle)
}
GetEdgeH(IsReversed, X, Y, WinTitle) {
	Global MarginWidth, MarginWidthHalf
	Index := LoopHs(IsReversed, X, Y, 0, 1)
	If (Index)
		Return GetY(Index) + (GetCornerH(Index) ? MarginWidth : MarginWidthHalf) * (IsReversed ? 1 : -1)
	Return LoopWindows(False, IsReversed, X, Y, WinTitle)
}
GetX(index) {
	Global V
	Return V[index][1]
}
GetY0(index) {
	Global V, H
	Return H[V[index][2]][1]
}
GetY1(index) {
	Global V, H
	Return H[V[index][3]][1]
}
GetY(index) {
	Global H
	Return H[index][1]
}
GetX0(index) {
	Global V, H
	Return V[H[index][2]][1]
}
GetX1(index) {
	Global V, H
	Return V[H[index][3]][1]
}
GetCornerV(index) {
	Global V
	Return V[index][4]
}
GetCornerH(index) {
	Global H
	Return H[index][4]
}
GetResizeV(index) {
	Global V
	Return V[index][5]
}
GetResizeH(index) {
	Global H
	Return H[index][5]
}
DrawWindow(title) {
	Global VisibleGrid
	WinActivate, % title
	WinSet, AlwaysOnTop, On, % title
	; WinSet, Transparent, 212, % title
	If (VisibleGrid)
		ShowGrid()
}
UndrawWindow(title) {
	Global VisibleGrid
	WinSet, AlwaysOnTop, Off, % title
	; WinSet, Transparent, Off, % title
	If (VisibleGrid)
		HideGrid()
}

CreateBitmap() {
	Global ColorGrid
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
	Global ColorPreview, TransparencyPreview
	Gui, 2:Default
	Gui, Color, % ColorPreview
	Gui, +LastFound
	WinSet, Transparent, % TransparencyPreview
	Gui, +Owner +AlwaysOnTop -Resize -SysMenu -MinimizeBox -MaximizeBox -Disabled -Caption -Border -ToolWindow
	Return WinExist()
} 
CreateGrid() {
	Global V, H, MarginWidth, ScreenX, ScreenY, TransparencyGrid

	LineWidth := MarginWidth = 0 ? 2 : MarginWidth
	Gui, 1:Default
	Gui, Color, 0xFF00FF
	Gui, +LastFound
	WinSet, TransColor, 0xFF00FF %TransparencyGrid%
	Gui, +Owner +AlwaysOnTop -Resize -SysMenu -MinimizeBox -MaximizeBox -Disabled -Caption -Border -ToolWindow
	Loop, % V.MaxIndex() {
		X := GetX(A_Index) - ScreenX   ; to convert the position to positive
		Y := GetY0(A_Index) - ScreenY                         ; to convert the position to positive
		Height := GetY1(A_Index) - GetY0(A_Index)
		If (GetCornerV(A_Index))
			Gui, Add, Picture, % "x" . X-LineWidth . " y" . Y . " w" . LineWidth*2 . " h" . Height, pixel.bmp
		Else
			Gui, Add, Picture, % "x" . X-LineWidth//2 . " y" . Y . " w" . LineWidth . " h" . Height, pixel.bmp
	}
	Loop, % H.MaxIndex() {
		Y := GetY(A_Index) - ScreenY   ; to convert the position to positive
		X := GetX0(A_Index) - ScreenX                         ; to convert the position to positive
		Width := GetX1(A_Index) - GetX0(A_Index)
		If (GetCornerH(A_Index))
			Gui, Add, Picture, % "x" . X . " y" . Y-LineWidth . " w" . Width . " h" . LineWidth*2, pixel.bmp
		Else
			Gui, Add, Picture, % "x" . X . " y" . Y-LineWidth//2 . " w" . Width . " h" . LineWidth, pixel.bmp
	}
}
ShowGrid() {
	Global ScreenX, ScreenY, ScreenW, ScreenH
	Gui, 1:Show, % "x" . ScreenX . " y" . ScreenY . " w" . ScreenW . " h" . ScreenH
}
HideGrid() {
	Gui, 1:Hide
}
#If VisibleGrid
NumpadDiv::ShowGrid()
NumpadDiv Up::HideGrid()
#If