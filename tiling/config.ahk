; The default config results in this grid:
; +----+----+
; |    |    |
; |    +----+
; |    |    |
; +----+----+
; Enable VisibleGrid if you need to debug your grid

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



; Hide Tray Icon
NoTrayIcon := False



; Margin between windows (px)
MarginWidth := 0

; Margin between windows at edges (px)
MarginWidthHalf := MarginWidth//2

; Minimum distance from lines/windows before snapping (px)
SnapDistance := 16

; Minimum distance before starting to move/resize window (px)
MinimumMovement := 10



; Enable snapping to grid?
SnapToGrid := True

; Enable snapping to surrounding windows?
SnapToWindows := True

; Enable maximizing window if moved to top of screen?
MoveToTopToMaximize := True

; Minimize the window if it is moved to the bottom of the screen?
MoveToBottomToClose := True



; Enable display of grid? (useful for debugging)
VisibleGrid := False

; Colour of grid
ColorGrid := 0xA2B2A1

; Transparency of grid
TransparencyGrid := 128

; Colour of window preview
ColorPreview := 0xA2B2A1

; Transparency of window preview
TransparencyPreview := 128

; Preview animation duration (ms)
AnimationDuration := 150



; HotkeyModifier is prefixed to each hotkey, but can be released once the hotkey has activated.
HotkeyModifier := "!"

; Move window hotkey (leave blank to disable)
HotkeyMove := "MButton"

; Resize window hotkey (leave blank to disable)
HotkeyResize := "RButton"

; Move Resize window hotkey (leave blank to disable)
; When moving window, press this to switch to grid resize mode (different from normal resize)
HotkeyMoveResize := "LButton"
