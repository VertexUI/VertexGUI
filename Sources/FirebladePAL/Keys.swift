//
// Keys.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

public enum KeyCode {
    case _0
    case _1
    case _2
    case _3
    case _4
    case _5
    case _6
    case _7
    case _8
    case _9
    case A
    case AC_BACK
    case AC_BOOKMARKS
    case AC_FORWARD
    case AC_HOME
    case AC_REFRESH
    case AC_SEARCH
    case AC_STOP
    case AGAIN
    case ALTERASE
    case AMPERSAND
    case APOSTROPHE
    case APP1
    case APP2
    case APPLICATION
    case ASTERISK
    case AT
    case AUDIOFASTFORWARD
    case AUDIOMUTE
    case AUDIONEXT
    case AUDIOPLAY
    case AUDIOPREV
    case AUDIOREWIND
    case AUDIOSTOP
    case B
    case BACKQUOTE
    case BACKSLASH
    case BACKSPACE
    case BRIGHTNESSDOWN
    case BRIGHTNESSUP
    case C
    case CALCULATOR
    case CANCEL
    case CAPSLOCK
    case CARET
    case CLEAR
    case CLEARAGAIN
    case COLON
    case COMMA
    case COMPUTER
    case COPY
    case CRSEL
    case CURRENCYSUBUNIT
    case CURRENCYUNIT
    case CUT
    case D
    case DECIMALSEPARATOR
    case DELETE
    case DISPLAYSWITCH
    case DOLLAR
    case DOWN
    case E
    case EJECT
    case END
    case EQUALS
    case ESCAPE
    case EXCLAIM
    case EXECUTE
    case EXSEL
    case F
    case F1
    case F10
    case F11
    case F12
    case F13
    case F14
    case F15
    case F16
    case F17
    case F18
    case F19
    case F2
    case F20
    case F21
    case F22
    case F23
    case F24
    case F3
    case F4
    case F5
    case F6
    case F7
    case F8
    case F9
    case FIND
    case G
    case GRAVE
    case GREATER
    case H
    case HASH
    case HELP
    case HOME
    case I
    case INSERT
    case INTERNATIONAL1
    case INTERNATIONAL2
    case INTERNATIONAL3
    case INTERNATIONAL4
    case INTERNATIONAL5
    case INTERNATIONAL6
    case INTERNATIONAL7
    case INTERNATIONAL8
    case INTERNATIONAL9
    case J
    case K
    case KBDILLUMDOWN
    case KBDILLUMTOGGLE
    case KBDILLUMUP
    case KP_0
    case KP_00
    case KP_000
    case KP_1
    case KP_2
    case KP_3
    case KP_4
    case KP_5
    case KP_6
    case KP_7
    case KP_8
    case KP_9
    case KP_A
    case KP_AMPERSAND
    case KP_AT
    case KP_B
    case KP_BACKSPACE
    case KP_BINARY
    case KP_C
    case KP_CLEAR
    case KP_CLEARENTRY
    case KP_COLON
    case KP_COMMA
    case KP_D
    case KP_DBLAMPERSAND
    case KP_DBLVERTICALBAR
    case KP_DECIMAL
    case KP_DIVIDE
    case KP_E
    case KP_ENTER
    case KP_EQUALS
    case KP_EQUALSAS400
    case KP_EXCLAM
    case KP_F
    case KP_GREATER
    case KP_HASH
    case KP_HEXADECIMAL
    case KP_LEFTBRACE
    case KP_LEFTPAREN
    case KP_LESS
    case KP_MEMADD
    case KP_MEMCLEAR
    case KP_MEMDIVIDE
    case KP_MEMMULTIPLY
    case KP_MEMRECALL
    case KP_MEMSTORE
    case KP_MEMSUBTRACT
    case KP_MINUS
    case KP_MULTIPLY
    case KP_OCTAL
    case KP_PERCENT
    case KP_PERIOD
    case KP_PLUS
    case KP_PLUSMINUS
    case KP_POWER
    case KP_RIGHTBRACE
    case KP_RIGHTPAREN
    case KP_SPACE
    case KP_TAB
    case KP_VERTICALBAR
    case KP_XOR
    case L
    case LALT
    case LANG1
    case LANG2
    case LANG3
    case LANG4
    case LANG5
    case LANG6
    case LANG7
    case LANG8
    case LANG9
    case LCTRL
    case LEFT
    case LEFTBRACKET
    case LEFTPAREN
    case LESS
    case LGUI
    case LSHIFT
    case M
    case MAIL
    case MEDIASELECT
    case MENU
    case MINUS
    case MODE
    case MUTE
    case N
    case NONUSBACKSLASH
    case NONUSHASH
    case NUMLOCKCLEAR
    case O
    case OPER
    case OUT
    case P
    case PAGEDOWN
    case PAGEUP
    case PASTE
    case PAUSE
    case PERCENT
    case PERIOD
    case PLUS
    case POWER
    case PRINTSCREEN
    case PRIOR
    case Q
    case QUESTION
    case QUOTE
    case QUOTEDBL
    case R
    case RALT
    case RCTRL
    case RETURN
    case RETURN2
    case RGUI
    case RIGHT
    case RIGHTBRACKET
    case RIGHTPAREN
    case RSHIFT
    case S
    case SCROLLLOCK
    case SELECT
    case SEMICOLON
    case SEPARATOR
    case SLASH
    case SLEEP
    case SPACE
    case STOP
    case SYSREQ
    case T
    case TAB
    case THOUSANDSSEPARATOR
    case U
    case UNDERSCORE
    case UNDO
    case UNKNOWN
    case UP
    case V
    case VOLUMEDOWN
    case VOLUMEUP
    case W
    case WWW
    case X
    case Y
    case Z
}

extension KeyCode: Equatable {}
extension KeyCode: Hashable {}

public struct KeyModifier: OptionSet {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    public static let none = KeyModifier([])

    public static let shiftLeft = KeyModifier(rawValue: 1 << 0)
    public static let shiftRight = KeyModifier(rawValue: 1 << 1)

    public static let controlLeft = KeyModifier(rawValue: 1 << 2)
    public static let controlRight = KeyModifier(rawValue: 1 << 3)

    public static let alternateLeft = KeyModifier(rawValue: 1 << 4)
    public static let alternateRight = KeyModifier(rawValue: 1 << 5)

    /// meta, win, command
    public static let metaLeft = KeyModifier(rawValue: 1 << 6)
    public static let metaRight = KeyModifier(rawValue: 1 << 7)

    /// AltGr
    public static let alternateGraphic = KeyModifier(rawValue: 1 << 8)

    /// Shift lock
    public static let capsLock = KeyModifier(rawValue: 1 << 9)

    /// Num lock on keypad
    public static let numLock = KeyModifier(rawValue: 1 << 10)
}

extension KeyModifier: Equatable {}
extension KeyModifier: Hashable {}

extension KeyModifier: CustomDebugStringConvertible {
    private static let namesMap: [KeyModifier: String] = [
        .shiftLeft: "shiftLeft",
        .shiftRight: "shiftRight",
        .controlLeft: "controlLeft",
        .controlRight: "controlRight",
        .alternateLeft: "alternateLeft",
        .alternateRight: "alternateRight",
        .metaLeft: "metaLeft",
        .metaRight: "metaRight",
        .alternateGraphic: "alternateGraphic",
        .capsLock: "capsLock",
        .numLock: "numLock",
    ]

    public var debugDescription: String {
        Self.namesMap
            .compactMap { self.contains($0.key) ? $0.value : nil }
            .joined(separator: ", ")
    }
}
