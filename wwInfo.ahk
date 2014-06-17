CopyColour := True
DoubleClick := True
HotkeyInfo := "~>!LButton"

; END OF CONFIG

GoSub Initialise
Return

Initialise:
	CoordMode, Mouse, Screen
	CoordMode, Pixel, Screen
	#SingleInstance, Force
	SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
	SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	SetBatchLines, -1
	SetWinDelay, -1
	SetTitleMatchMode, RegEx
	If (HotkeyInfo)
		Hotkey, % "~" . HotkeyInfo, InfoWindow
Return

InfoWindow:
	InfoWindow()
Return

InfoWindow() {
	Global CopyColour, DoubleClick
	If (DoubleClick and (A_PriorHotKey <> A_ThisHotKey or A_TimeSincePriorHotkey > DllCall("GetDoubleClickTime")))
		Return
	MouseGetPos, X, Y
	Static OldX, OldY
	If (!OldX)
	{
		OldX := X, OldY := Y
	}
	Length := X - OldX
	Height := Y - OldY
	D := round(sqrt(Length*Length + Height*Height), 1)
	OldX := X, OldY := Y

	PixelGetColor, Color, X, Y, Slow|RGB
	Color := SubStr(Color, 3)
	If (CopyColour)
		Clipboard := Color
	R := "0x" . SubStr(Color, 1, 2)
	R := R / 255
	G := "0x" . SubStr(Color, 3, 2)
	G := G / 255
	B := "0x" . SubStr(Color, 5, 2)
	B := B / 255
	RGBMin := R < G ? (R < B ? R : B) : (G < B ? G : B)
	RGBMax := R > G ? (R > B ? R : B) : (G > B ? G : B)
	Hue := 0
	Saturation := 0
	Lightness := (RGBMax + RGBMin) / 2
	If (RGBMax <> RGBMin) {
		Saturation := Lightness > 0.5 ? (RGBMax - RGBMin) / (2 - RGBMax - RGBMin) : (RGBMax - RGBMin) / (RGBMax + RGBMin)
		If (RGBMax = R)
			Hue := (G - B) / (RGBMax - RGBMin) + (G < B ? 6 : 0)
		Else If (RGBMax = G)
			Hue := (B - R) / (RGBMax - RGBMin) + 2
		Else
			Hue := (R - G) / (RGBMax - RGBMin) + 4
		Hue /= 6
	}
	Hue := Round(Hue * 255, 0)
	Saturation := Round(Saturation * 255, 0)
	Lightness := Round(Lightness * 255, 0)
	ToolTip, % Color . "`tX: " . X . "`nH: " . Hue . "`tY: " . Y . "`nS: " . Saturation . "`tW: " . Length . "`nL: " . Lightness . "`tH: " . Height . "`n`tD: " . D
	SetTimer, RemoveToolTip, 5000
}

RemoveToolTip: 
	ToolTip
Return