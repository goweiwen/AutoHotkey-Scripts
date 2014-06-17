wwTiling
======
Purpose
------
Adds mouse controls to move and resize windows, while snapping to a preset grid or nearby windows.

Usage
------
If you wish to use a grid, create one.
```AutoHotkey
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
```
Vertical lines (V[n]) have a y0-index and y1-index, which point to the index of the horizontal line that their top and bottom points touch, respectively.  
For example, in this case, V[1] is a line that is located at ScreenX (which is the left edge of your screens), which starts from the y-coord of H[1] (ScreenY) and ends at the y-coord of H[3] (ScreenY + ScreenH - 32).

The same is true for horizontal lines, except the x and y coordinates are inverted.

Corner means that the line is at an edge and windows snapped against this edge will have a margin of MarginWidth instead of MarginWidthHalf.

Resize-only means that windows will not be snapped against this edge unless it is in resize mode.

Next, the settings should be tweaked.
```AutoHotkey
; Pixel Values
MarginWidth := 8                  ; Margin (px)
MarginWidthHalf := MarginWidth//2 ; Margin of edges (px)
SnapDistance := 16                ; Minimum distance from lines before snapping (px)
MinimumMovement := 10             ; Minimum distance before starting to move/resize window (px)

; Toggles
SnapToGrid := True                ; Snap to grid?
SnapToWindows := True             ; Snap to surrounding windows?
MoveToTopToMaximize := True       ; Maximize the window if it is moved to the top of the screen?
TopPos := 0                       ; Y-Coord of the top of the screen
MoveToBottomToClose := True       ; Minimize the window if it is moved to the bottom of the screen?
BottomPos := 1079                 ; Y-Coord of the bottom of the screen

; Grid and preview
VisibleGrid := False              ; Display the grid?
ColorGrid := 0x8B998A             ; Colour of the grid
TransparencyGrid := 128           ; Transparency of the grid
ColorPreview := 0xA2B2A1          ; Colour of the preview
TransparencyPreview := 128        ; Transparency of the preview
```

The hotkeys can also be changed
```AutoHotkey
HotkeyMove := "MButton"           ; Leave blank to disable
HotkeyResize := "RButton"         ; Leave blank to disable
HotkeyMoveResize := "LButton"     ; Leave blank to disable

HotkeyModifier := ">!" ; HotkeyModifier is prefixed to each hotkey, but can be released once the hotkey has activated.
```

wwMenu
======
Purpose
------
Adds a menu that open paths in Windows explorer.

The menu opens when you press the "menu" key (usually beside the right Win button) with your mouse over certain windows.  
If your mouse is over the desktop, a new explorer window is launched.  
If your mouse is over an explorer window, it is directed to the path.  
If your mouse is over an open file dialog, it will try to direct it to the path (you need to put your mouse over the file name input box).

wwBorder
======
Purpose
------
Automatically style windows based on rules.

Usage
------
Conditions (all must be met for the rule to apply):
```
class: Matches window with this class
process: Matches window from this process
Title: Matches window with this title
```
Rules:
```
Unless otherwise specified, 0 is  to disable, 1 is to enable, any other value will toggle it.
border: border?
sizebox: resize border?
caption: titlebar?
all: everything?
always_on_top: always on top?
top: any value will move the window to top
bottom: any value will move the window to bottom
alt_tab: hide from alt-tab menu?
transparent: value of transparency (0-255, or OFF)
transcolor: hex-value of transparent colour (without the #)
close: any value will close the window
maximize: any value will maximize the window
redraw: any value will cause the window to redraw (by resizing it)
x: value of x-pos to move window to
y: value of y-pos to move window to
w: width of window to set to
h: height of window to set to
rx: relative value of x-pos to move window to
ry: relative value of y-pos to move window to
rw: relative width of window to set to
rh: relative height of window to set to
```

Examples
------
```AutoHotkey
programRules := [   { class: "MozillaWindowClass" ; Firefox
                        , sizebox: 0 }
                ,   { class: "{E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}" ; Foobar2000
                        , all: 0
                        , redraw: 1 }
                ,   { class: "CabinetWClass" ; Explorer
                        , caption: 0
                        , border: 0 }
                ,   { title: "Steam - Update News" ; Steam Update News
                        , close: 1 } ]
```

wwRunner
======
Purpose
------
Makes it easier to create hotkeys to switch to or run programs.  

Usage
------
Window titles accept regex.  
Functions:
```AutoHotkey
Run(path, workingdir) ; Returns false if file not found.
Send(key)             ; Returns true always.
Show(title)           ; Returns true if switch successful or already active, false otherwise (if window not found).
ShowNext(title)       ; Returns true if switch successful, false otherwise (if window not found or already active).
```

Examples
------
```AutoHotkey
; Switch to firefox if it exists and is not already active, otherwise run firefox.
!f::  ShowNext("ahk_class MozillaWindowClass") or Run("C:\Program Files (x86)\Aurora\firefox.exe")

; Switch to foobar2000 if it exists, otherwise run foobar2000.
!a::  Show("ahk_class {E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}") or Run("C:\Program Files (x86)\foobar2000\foobar2000.exe")
```

wwInfo
======
Purpose
------
Adds an eyedropper and pixel-ruler.


wwInput
======
Purpose
------
Adds hotstrings for easier unicode input.  
All hotkeys are in the form of "`\<text\>"

Example
------
```
`alpha -> α
`mult -> ×
`:a -> ä
`$Y -> ¥
```