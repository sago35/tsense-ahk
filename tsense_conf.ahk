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
