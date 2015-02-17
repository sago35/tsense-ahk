tsense-ahk
================

Tsense-ahk is an ahk script to make your keyboard as mouse buttons.
You can use touchpad and mouse click with home position.

## Description

This is a clone of ThumbSense.

 * You can use touchpad and mouse click with home position
  * When press MODIFIER-KEY, some keys are modified as below.
   * key 'F' => click 'left mouse button'
   * key 'G' => click 'right mouse button'
   * ...



## Demo
![](https://raw.github.com/wiki/sago35/tsense-ahk/images/tsense-ahk-demo.gif)

 1. click left mouse button with 'F'
 2. key 'z' : move window without drag title bar
 3. key 'x' : resize window without drag window edge
 
## VS. Original version

[original](https://www.sonycsl.co.jp/person/rekimoto/tsense/indexj.html) (japanese only)

Pros.

 * not requirement : Synaptics touchpad driver
 * highly configurable

Cons.

 * Not intuitive

## Requirement

 * Windows 7 or later
 * AutoHotkey v1.0 or later

## Usage

When press MODIFIER-KEY, some keys are modified as below. See  tsense_conf.ahk.sample.

    ; key 'F' : click 'left mouse button'
    f::LButton

    ; key 'd' : click 'right mouse button'
    d::RButton

    ; key 'c' : click 'center mouse button'
    c::MButton

    ; key 'g' : click '4ch mouse button' (typically performs as Browser_Back)
    g::XButton1

    ; key 'b' : click '5ch mouse button' (typically performs as Browser_Forward)
    b::XButton2

    ; key 'v' : double click 'left mouse button'
    v::Send, {LButton}{LButton}

    ; key 'w' : close current window
    w::WinClose, A

    ; key 't' : copy window title to clipboard
    t::WinGetTitle, clipboard, A

    ; move cursor like vim
    j::Down
    k::Up
    h::Left
    l::Right

    ; key 'r' : toggle maximize
    r::ToggleMaximize(0)
    +r::ToggleMaximize(1)
    ^r::ToggleMaximize(2)

    ; key 'z' : move window without drag title bar
    z::StartEasyWindowDrag()
    z Up::EndEasyWindowDrag()

    ; key 'x' : resize window without drag window edge
    x::StartEasyWindowResize()
    x Up::EndEasyWindowResize()

## Install

Add below to your ahk script.
If you want to use sample config, rename tsense_conf.ahk.sample to tsense_conf.ahk.


    #include path_to_tsense_folder
    #include path_to_tsense_folder\tsense.ahk

    ; Left Alt key to enable tsense
    LAlt::ToggleTsenseMode(1)
    LAlt Up::ToggleTsenseMode(0)

    ; muhenkan(無変換) key to enable tsense
    ;vk1Dsc07B::ToggleTsenseMode(1)
    ;vk1Dsc07B Up::ToggleTsenseMode(0)

## Contribution

TBD.

## Licence

[MIT](http://opensource.org/licenses/mit-license.php)

## Author

[sago35](https://github.com/sago35)
