DetectHiddenWindows, On
CoordMode, Mouse, Screen

; TsenseModeの初期化
InitTsenseMode()

#IfWinExist, __tsense_mode_win
; ----------------------------------------------------------------------------
; TsenseMode内でのバインド設定
^h::MouseMove, -16,   0, 0, R
^j::MouseMove,   0,  16, 0, R
^k::MouseMove,   0, -16, 0, R
^l::MouseMove,  16,   0, 0, R
;+h::MouseMove,  -8,   0, 0, R
;+j::MouseMove,   0,   8, 0, R
;+k::MouseMove,   0,  -8, 0, R
;+l::MouseMove,   8,   0, 0, R
j::Down
k::Up
h::Left
l::Right
n::Send, {WheelDown}
p::Send, {WheelUp}
+n::Send, {PgDn}
+p::Send, {PgUp}
i::Tab
Space::WinActivate, ahk_class Shell_TrayWnd
.::
    Send, #^!{F9}
    WinGet, WID, LIST, ahk_class CLaunch_MemoWnd
    Loop, %WID% {
        this_id := WID%A_Index%
        WinRestore, ahk_id %this_id%
        WinActivate, ahk_id %this_id%
    }
    return

; vkBCsc033 => ,
vkBCsc033::Send, #^!{F10}

F1::
    Run, local\etc\AutoHotkey.chm
    return

; vkBAsc028 => :
;vkBAsc028::Run, ..\fenrir\fenrir.exe /t, ..\fenrir\
;vkBAsc028::Run, ..\fenrir\fenrir.exe /pathfile=%USERPROFILE%\fenrir.path, ..\fenrir\
vkBAsc028::Run, ..\fenrir\fenrir.exe, ..\fenrir\

f::LButton
d::RButton
c::MButton
g::XButton1
b::XButton2
w::WinClose, A
a::Send, {HOME}
e::Send, {END}
v::Send, {LButton}{LButton}
t::WinGetTitle, clipboard, A

+r::ToggleMaximize(1)
r::ToggleMaximize(0)
^r::ToggleMaximize(2)

z::StartEasyWindowDrag()
z Up::EndEasyWindowDrag()
x::StartEasyWindowResize()
x Up::EndEasyWindowResize()
s::GoTo, esmb_TriggerKeyDown
s Up::GoTo, esmb_TriggerKeyUp

Left::Home
Right::End
Up::PgUp
Down::PgDn

; ----------------------------------------------------------------------------
#IfWinExist

; TsenseModeを切り替える
; TsenseWindowの生成/廃棄により切り替え
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
        ;Menu, TRAY, Icon, AutoHotkey.exe, 4
    } else {
        DestroyTsenseWindow()
    }
}

CreateTsenseWindow() {
    global NowTime

    ; Old Version
    ;Gui, +ToolWindow
    ;TimedTrayTip("", "Tsense Mode On", 1000)

    __tsense_mode_font_size := 10
    __tsense_mode_gui_h := A_ScreenHeight - __tsense_mode_font_size - 8
    Gui, +ToolWindow +AlwaysOnTop -Caption +LastFound
    Gui, +E0x00080020 +0x02000000 -0x0CC00000
    Gui, Font, S%__tsense_mode_font_size%, MSゴシック
    Gui, Margin, 2, 2
    Gui, Add, Text, w%A_ScreenWidth% vNowTime
    Gui, Show, hide, __tsense_mode_win
    Gui, Show, x0 y%__tsense_mode_gui_h% NoActivate
    Gui, Color, FFFF99
    WinSet, Transparent, 210
    GoSub, TsenseClockLoop
    SetTimer, TsenseClockStop, 1000
}

; 50ms周期のTsenseWindow廃棄処理
DestroyTsenseWindow() {
    SetTimer, DestroyTsenseWindowWatch, 50
}

; TsenseWindow廃棄処理
DestroyTsenseWindowWatch:
    If (isTsenseModeQuitOK()) {
        Gui, Destroy
        ;TimedTrayTip("", "Tsense Mode Off", 1000)
        Menu, TRAY, Icon, AutoHotkey.exe, 2
        SetTimer, DestroyTsenseWindowWatch, Off
    }
    return

; TsenseModeの初期化
; 必ずコールする必要あり
InitTsenseMode() {
    TsenseModeQuitOK()
    InitMouseWheelEmu()
    InitEasyWindowDrag()
    InitEasyWindowResize()
}

; TsenseModeQuitNGでかけたロックを解除
TsenseModeQuitOK() {
    global tsense_mode_quit_ok
    tsense_mode_quit_ok := 1
}

; TsenseModeの終了を禁止する
TsenseModeQuitNG() {
    global tsense_mode_quit_ok
    tsense_mode_quit_ok := 0
}

; TsenseModeを終了していいか？
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
    ;MouseMove, origX, origY, 0
    origX := -1
    origY := -1
    return

esmb_CheckForScrollEventAndExecute:
    if esmb_KeyDown = n
        return

    MouseGetPos,, esmb_NewY
    ;MouseMove, esmb_OldX, esmb_OldY
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
; maximizeLevel = 0 : 普通の最大化
; maximizeLevel = 1 : Taskbarを残して最大化
; maximizeLevel = 2 : 完全に最大化
ToggleMaximize(maximizeLevel = 0) {
    WinGet, WID, ID, A
    WinGet, isMaximize, MinMax, ahk_id %WID%
    WinGet, myStyle, Style, ahk_id %WID%
    if (isMaximize == 1 && (maximizeLevel == 0 || myStyle & 0x00C40000 == 0)) {
        WinRestore, ahk_id %WID%
        ;PostMessage, 0x112, 0xF120,,, ahk_id %WID% ; WinRestore
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
                ; Taskbarを残して最大化
                SysGet, New, MonitorWorkArea
                WinMove, ahk_id %WID%, , 0, 0, %NewRight%, %NewBottom%
            } else {
                ; 完全に最大化
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
    WinGetTitle, now_active_window, A
    GuiControl, , NowTime, %now_time% | %now_active_window%
    return

TsenseClockStop:
    SetTimer, TsenseClockStop, Off
    Gui, Hide
    return
