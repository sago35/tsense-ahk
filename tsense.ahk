DetectHiddenWindows, On
CoordMode, Mouse, Screen

InitTsenseMode()

#include tsense_conf.ahk

ToggleTsenseMode(i = -1) {
    global NowTime
    static now := 0
    If (WinExist("__tsense_mode_win") and (i = 1)) {
        return
    }
    if (i = 1) {
        now := 1
    } else if (i = 0) {
        now := 0
    } else {
        now := !now
    }
    if (now) {
        CreateTsenseWindow()
    } else {
        DestroyTsenseWindow()
    }
}

CreateTsenseWindow() {
    global NowTime
    global tsense_bgcolor, tsense_transeparent

    __tsense_mode_font_size := 10
    __tsense_mode_gui_h := A_ScreenHeight - __tsense_mode_font_size - 8
    Gui, +ToolWindow +AlwaysOnTop -Caption +LastFound
    Gui, +E0x00080020 +0x02000000 -0x0CC00000
    Gui, Font, S%__tsense_mode_font_size%, MSÉSÉVÉbÉN
    Gui, Margin, 2, 2
    Gui, Add, Text, w%A_ScreenWidth% vNowTime
    Gui, Show, hide, __tsense_mode_win
    Gui, Show, x0 y%__tsense_mode_gui_h% NoActivate
    Gui, Color, %tsense_bgcolor%
    WinSet, Transparent, %tsense_transeparent%
    GoSub, TsenseClockLoop
    SetTimer, TsenseClockStop, 1000
}

DestroyTsenseWindow() {
    SetTimer, DestroyTsenseWindowWatch, 50
}

DestroyTsenseWindowWatch:
    If (isTsenseModeQuitOK()) {
        Gui, Destroy
        Menu, TRAY, Icon, AutoHotkey.exe, 2
        SetTimer, DestroyTsenseWindowWatch, Off
    }
    return

InitTsenseMode() {
    TsenseModeQuitOK()
    InitMouseWheelEmu()
    InitEasyWindowDrag()
    InitEasyWindowResize()
}

TsenseModeQuitOK() {
    global tsense_mode_quit_ok
    tsense_mode_quit_ok := 1
}

TsenseModeQuitNG() {
    global tsense_mode_quit_ok
    tsense_mode_quit_ok := 0
}

isTsenseModeQuitOK() {
    global tsense_mode_quit_ok
    return tsense_mode_quit_ok
}


; ----------------------------------------------------------------------------
; MWheel Emu
; ----------------------------------------------------------------------------
InitMouseWheelEmu() {
    global esmb_Threshold, esmb_KeyDown
    esmb_Threshold = 1
    esmb_KeyDown = n
    origX := -1
    origY := -1
    SetTimer, esmb_CheckForScrollEventAndExecute, 40
}

esmb_TriggerKeyDown:
    TsenseModeQuitNG()
    esmb_KeyDown = y
    MouseGetPos, esmb_OldX, esmb_OldY
    if (origX < 0 && origY < 0) {
        origX := esmb_OldX
        origY := esmb_OldY
    }
    return

esmb_TriggerKeyUp:
    TsenseModeQuitOK()
    esmb_KeyDown = n
    origX := -1
    origY := -1
    return

esmb_CheckForScrollEventAndExecute:
    if esmb_KeyDown = n
        return

    MouseGetPos,, esmb_NewY
    esmb_Distance := esmb_NewY - esmb_OldY

    ;; Do not send clicks on the first iteration
    if esmb_Distance > %esmb_Threshold%
    {
        esmb_OldY := esmb_OldY + esmb_Threshold
        Send, {WheelDown}
    }
    else if esmb_Distance < -%esmb_Threshold%
    {
        esmb_OldY := esmb_OldY - esmb_Threshold
        Send, {WheelUp}
    }

    return


; ----------------------------------------------------------------------------
; EasyWindowResize
; ----------------------------------------------------------------------------
InitEasyWindowResize() {
    global EWR_Enable
    EWR_Enable := 0
}

StartEasyWindowResize() {
    global EWR_WID, EWR_Enable, EWR_OrigWinX, EWR_OrigWinY, EWR_OrigWinW, EWR_OrigWinH, EWR_OrigMouseX, EWR_OrigMouseY
    if (EWR_Enable == 0) {
        TsenseModeQuitNG()
        WinGet, EWR_WID, ID, A
        WinGetPos, EWR_OrigWinX, EWR_OrigWinY, EWR_OrigWinW, EWR_OrigWinH, ahk_id %EWR_WID%
        MouseGetPos, EWR_OrigMouseX, EWR_OrigMouseY
        EWR_Enable := 1
        SetTimer, EWR_WatchMouse, 50 ; Track the mouse as the user drags it.
    }
}

EndEasyWindowResize() {
    global EWR_Enable
    EWR_Enable := 0
    TsenseModeQuitOK()
    SetTimer, EWR_WatchMouse, Off
}

EWR_WatchMouse:
    MouseGetPos, EWR_TmpMouseX, EWR_TmpMouseY
    EWR_WinX := EWR_OrigWinX
    EWR_WinY := EWR_OrigWinY
    EWR_WinW := EWR_OrigWinW + EWR_TmpMouseX - EWR_OrigMouseX
    EWR_WinH := EWR_OrigWinH + EWR_TmpMouseY - EWR_OrigMouseY
    WinMove, ahk_id %EWR_WID%, , %EWR_WinX%, %EWR_WinY%, %EWR_WinW%, %EWR_WinH%
    return


; ----------------------------------------------------------------------------
; EasyWindowDrag
; ----------------------------------------------------------------------------
InitEasyWindowDrag() {
    global EWD_Enable
    EWD_Enable := 0
}

StartEasyWindowDrag() {
    global EWD_WID, EWD_Enable, EWD_OrigWinX, EWD_OrigWinY, EWD_OrigMouseX, EWD_OrigMouseY
    if (EWD_Enable == 0) {
        TsenseModeQuitNG()
        WinGet, EWD_WID, ID, A
        WinGetPos, EWD_OrigWinX, EWD_OrigWinY, , , ahk_id %EWD_WID%
        MouseGetPos, EWD_OrigMouseX, EWD_OrigMouseY
        EWD_Enable := 1
        SetTimer, EWD_WatchMouse, 50 ; Track the mouse as the user drags it.
    }
}

EndEasyWindowDrag() {
    global EWD_Enable
    EWD_Enable := 0
    TsenseModeQuitOK()
    SetTimer, EWD_WatchMouse, Off
}

EWD_WatchMouse:
    MouseGetPos, EWD_TmpMouseX, EWD_TmpMouseY
    EWD_WinX := EWD_OrigWinX + EWD_TmpMouseX - EWD_OrigMouseX
    EWD_WinY := EWD_OrigWinY + EWD_TmpMouseY - EWD_OrigMouseY
    WinMove, ahk_id %EWD_WID%, , %EWD_WinX%, %EWD_WinY%
    return


; ----------------------------------------------------------------------------
; ToggleMaximize
; ----------------------------------------------------------------------------
; maximizeLevel = 0 : normal maximize
; maximizeLevel = 1 : maximize without title bar
; maximizeLevel = 2 : maximize without title bar and task bar
ToggleMaximize(maximizeLevel = 0) {
    WinGet, WID, ID, A
    WinGet, isMaximize, MinMax, ahk_id %WID%
    WinGet, myStyle, Style, ahk_id %WID%
    if (isMaximize == 1 && (maximizeLevel == 0 || myStyle & 0x00C40000 == 0)) {
        WinRestore, ahk_id %WID%
        if (maximizeLevel) {
            WinSet, Style, +0x00C40000, ahk_id %WID%
        }
    }
    else
    {
        WinMaximize, ahk_id %WID%
        if (maximizeLevel) {
            WinSet, Style, -0x00C40000, ahk_id %WID%

            if (maximizeLevel == 1) {
                ; maximize without title bar
                SysGet, New, MonitorWorkArea
                WinMove, ahk_id %WID%, , 0, 0, %NewRight%, %NewBottom%
            } else {
                ; maximize without title bar and task bar
                WinMove, ahk_id %WID%, , 0, 0, %A_ScreenWidth%, %A_ScreenHeight%
            }
        }
    }
}
; ----------------------------------------------------------------------------
; TsenseClock
; ----------------------------------------------------------------------------
TsenseClockLoop:
    FormatTime, now_time, , yy/MM/dd ddd HH:mm:ss
    WinGet, WID, ID, A
    WinGetPos, X, Y, W, H, ahk_id %WID%
    if (X >= 0) {
        X = +%X%
    }
    if (Y >= 0) {
        Y = +%Y%
    }
    WinGetTitle, now_active_window, ahk_id %WID%
    GuiControl, , NowTime, %now_time% | (%W%x%H%%X%%Y%) %now_active_window%
    return

TsenseClockStop:
    SetTimer, TsenseClockStop, Off
    Gui, Hide
    return
