﻿programRules := [   { class: "MozillaWindowClass" ; Firefox
                        , sizebox: 0 }
                ,   { class: "{E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}" ; Foobar2000
                        , all: 0
                        , redraw: 1 }
                ,   { class: "CabinetWClass" ; Explorer
                        , caption: 0
                        , border: 0 }
                ,   { class: "µTorrent4823DF041B09" ; uTorrent
                        , caption: 0
                        , border: 0 }
                ,   { class: "PX_WINDOW_CLASS" ; Sublime Text 3
                        , caption: 0
                        , border: 0 }
                ,   { class: "Screen Magnifier Window" ; Magnifier
                        , all: 0 }
                ,   { class: "IrfanView" ; Irfanview
                        , caption: 0    
                        , border: 0 }
                ,   { class: "classFoxitReader" ; Foxit Reader
                        , caption: 0
                        , border: 0 }
                ,   { class: "SunAwtFrame" ; Minecraft
                        , caption: 0
                        , border: 0
                        , sizebox: 0 }
                ,   { title: "Steam - Update News" ; Steam Update News
                        , close: 1 } ]

AdjustOnRedraw := 0

adjustAllWindows()
GoSub, HookWindow
Sleep,10000
adjustAllWindows()
Return

adjustWindow(_id)
{
    global programRules
    id := _id = "A" ? "A" : "ahk_id " . _id

    for _, program in programRules
    {
        if program.class
        {
            WinGetClass, class, % id
            if (class <> program.class)
            {
                continue
            }
        }
        if program.process
        {
            WinGet, process, ProcessName, % id
            if (process <> program.process)
            {
                continue
            }
        }
        if program.title
        {
            WinGetTitle, title, % id
            if (!InStr(title, program.title))
            {
                continue
            }
        }

        for rule, value in program
        {
            if (rule = "class" or rule = "process" or rule = "title")
                continue
            else if (rule = "border")
                WinSet, Style, % (value = 0 ? "-" : value = 1 ? "+" : "^") . 0x800000, % id
            else if (rule = "sizebox")
                WinSet, Style, % (value = 0 ? "-" : value = 1 ? "+" : "^") . 0x40000, % id
            else if (rule = "caption")
                WinSet, Style, % (value = 0 ? "-" : value = 1 ? "+" : "^") . 0x80000, % id
            else if (rule = "all")
                WinSet, Style, % (value = 0 ? "-" : value = 1 ? "+" : "^") . 0xCF0000, % id
            else if (rule = "always_on_top")
                WinSet, AlwaysOnTop, % (value = 0 ? "OFF" : value = 1 ? "ON" : "TOGGLE"), % id
            else if (rule = "top")
                WinSet, Top,, % id
            else if (rule = "bottom")
                WinSet, Top,, % id
            else if (rule = "alt_tab")
                WinSet, ExStyle, % (value = 0 ? "-" : value = 1 ? "+" : "^") . 0x80, % id
            else if (rule = "transparent")
                WinSet, Transparent, % value, % id
            else if (rule = "transcolor")
                WinSet, TransColor, % value, % id
            else if (rule = "close")
                WinClose, % id
            else if (rule = "maximize")
                WinMaximize, % id
            else if (rule = "redraw")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % X, % Y, % W, % H + 1
                WinMove, % id,, % X, % Y, % W, % H
            }
            else if (rule = "x")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % value, % Y, % W, % H
            }
            else if (rule = "y")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % X, % value, % W, % H
            }
            else if (rule = "w")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % X, % Y, % value, % H
            }
            else if (rule = "h")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % X, % Y, % W, % value
            }
            else if (rule = "rx")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % X + value, % Y, % W, % H
            }
            else if (rule = "ry")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % X, % Y + value, % W, % H
            }
            else if (rule = "rw")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % X, % Y, % W + value, % H
            }
            else if (rule = "rh")
            {
                WinGetPos, X, Y, W, H, % id
                WinMove, % id,, % X, % Y, % W, % H + value
            }
            else
                OutputDebug, "Invalid rule: " . rule
        }
    }
}

adjustAllWindows()
{
    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        AdjustWindow(id%A_Index%)
    }
}

HookWindow:
    ; New Window Hook
    Gui +LastFound
    hWnd := WinExist()

    DllCall( "RegisterShellHookWindow", UInt,hWnd )
    MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
    OnMessage( MsgNum, "ShellMessage" )

    ShellMessage(wParam,lParam) {
        Global AdjustOnRedraw
        Sleep, 10
        If (AdjustOnRedraw)
        {
            If wParam in 1,6
                adjustWindow(lParam)
        }
        Else
            If (wParam = 1)
                adjustWindow(lParam)
    }
Return