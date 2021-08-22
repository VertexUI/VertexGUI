//
// SDLEvents.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL

@_implementationOnly import SDL2

final class SDLEvents: PlatformEvents {
    private var _event = SDL_Event()

    func pumpEvents() {
        SDL_PumpEvents()
    }

    func pollEvent(_ event: inout Event) -> Bool {
        let hasPending = SDL_PollEvent(&_event)
        Self.translate(from: _event, to: &event)
        return hasPending == 1
    }

    private static func translate(from sdlEvent: SDL_Event, to event: inout Event) {
        let sdlEventType = SDL_EventType(sdlEvent.type)
        event.variant = .none
        switch sdlEventType {
        case SDL_QUIT:
            event.variant = .userQuit

        case SDL_KEYDOWN,
             SDL_KEYUP:
            event.variant = .keyboard
            translateKeyboardEvent(from: sdlEvent.key, to: &event.keyboard)

        case SDL_MOUSEMOTION:
            event.variant = .pointerMotion
            translateMouseMotionEvent(from: sdlEvent.motion, to: &event.pointerMotion)

        case SDL_MOUSEBUTTONDOWN,
             SDL_MOUSEBUTTONUP:
            event.variant = .pointerButton
            translateMouseButtonEvent(from: sdlEvent.button, to: &event.pointerButton)

        case SDL_MOUSEWHEEL:
            event.variant = .pointerScroll
            translateMouseWheelEvent(from: sdlEvent.wheel, to: &event.pointerScroll)

        case SDL_WINDOWEVENT:
            if translateWindowEvent(from: sdlEvent.window, to: &event.window) {
                event.variant = .window
            }

        case SDL_APP_TERMINATING,
             SDL_APP_LOWMEMORY,
             SDL_APP_WILLENTERBACKGROUND,
             SDL_APP_DIDENTERBACKGROUND,
             SDL_APP_WILLENTERFOREGROUND,
             SDL_APP_DIDENTERFOREGROUND:
            break

        case // SDL_LOCALECHANGED,
            // SDL_DISPLAYEVENT,
            SDL_SYSWMEVENT:
            break

        case SDL_TEXTINPUT:
            event.variant = .textInput
            translateTextInputEvent(from: sdlEvent.text, to: &event.textInput)

        case SDL_TEXTEDITING:
            event.variant = .textEditing
            translateTextEditingEvent(from: sdlEvent.edit, to: &event.textEditing)

        case SDL_KEYMAPCHANGED:
            break

        case SDL_JOYAXISMOTION,
             SDL_JOYBALLMOTION,
             SDL_JOYHATMOTION,
             SDL_JOYBUTTONDOWN,
             SDL_JOYBUTTONUP,
             SDL_JOYDEVICEADDED,
             SDL_JOYDEVICEREMOVED:
            break

        case SDL_CONTROLLERAXISMOTION,
             SDL_CONTROLLERBUTTONDOWN,
             SDL_CONTROLLERBUTTONUP,
             SDL_CONTROLLERDEVICEADDED,
             SDL_CONTROLLERDEVICEREMOVED,
             SDL_CONTROLLERDEVICEREMAPPED:
            // SDL_CONTROLLERTOUCHPADDOWN
            // SDL_CONTROLLERTOUCHPADMOTION,
            // SDL_CONTROLLERTOUCHPADUP,
            // SDL_CONTROLLERSENSORUPDATE:
            break

        case SDL_FINGERDOWN,
             SDL_FINGERUP,
             SDL_FINGERMOTION:
            break

        case SDL_DOLLARGESTURE,
             SDL_DOLLARRECORD,
             SDL_MULTIGESTURE:
            break

        case SDL_CLIPBOARDUPDATE:
            break

        case SDL_DROPFILE,
             SDL_DROPTEXT,
             SDL_DROPBEGIN,
             SDL_DROPCOMPLETE:
            break

        case SDL_AUDIODEVICEADDED,
             SDL_AUDIODEVICEREMOVED:
            // SDL_SENSORUPDATE:
            break

        case SDL_RENDER_TARGETS_RESET,
             SDL_RENDER_DEVICE_RESET:
            break

        case SDL_USEREVENT,
             SDL_FIRSTEVENT,
             SDL_LASTEVENT:
            break

        default:
            assertionFailure("Unexpected event \(event)")
        }
    }

    private static func translateMouseMotionEvent(from sdlEvent: SDL_MouseMotionEvent, to event: inout PointerMotionEvent) {
        event.windowID = Int(sdlEvent.windowID)
        event.pointerID = Int(sdlEvent.which)
        event.x = Float(sdlEvent.x)
        event.y = Float(sdlEvent.y)
        event.deltaX = Float(sdlEvent.xrel)
        event.deltaY = Float(sdlEvent.yrel)
    }

    private static func translateMouseButtonEvent(from sdlEvent: SDL_MouseButtonEvent, to event: inout PointerButtonEvent) {
        event.windowID = Int(sdlEvent.windowID)
        event.pointerID = Int(sdlEvent.which)
        if let mappedButton = pointerButtonMap[Int32(sdlEvent.button)] {
            event.button = mappedButton
        } else {
            print("warning: could not map sdl mouse button \(sdlEvent.button)")
            return
        }
        event.numTaps = Int(sdlEvent.clicks)

        switch Int32(sdlEvent.state) {
        case SDL_PRESSED:
            event.state = .pressed
        case SDL_RELEASED:
            event.state = .released
        default:
            assertionFailure("Unexpected state \(sdlEvent.state)")
        }

        event.x = Float(sdlEvent.x)
        event.y = Float(sdlEvent.y)
    }

    private static func translateMouseWheelEvent(from sdlEvent: SDL_MouseWheelEvent, to event: inout PointerScrollEvent) {
        event.windowID = Int(sdlEvent.windowID)
        event.pointerID = Int(sdlEvent.which)

        let sign: Int
        switch SDL_MouseWheelDirection(sdlEvent.direction) {
        case SDL_MOUSEWHEEL_NORMAL:
            sign = 1
        case SDL_MOUSEWHEEL_FLIPPED:
            sign = -1
        default:
            assertionFailure("Unexpected mouse wheel direction \(sdlEvent.direction)")
            sign = 0
        }

        //  left  == negative x values;  right ==  positive x values
        event.horizontal = sign * Int(sdlEvent.x)

        // down/backward == negative y values; up/forward == positive y values
        event.vertical = sign * Int(sdlEvent.y)

        event.x = Float(sdlEvent.x)
        event.y = Float(sdlEvent.y)
    }

    private static func translateWindowEvent(from sdlEvent: SDL_WindowEvent, to event: inout WindowEvent) -> Bool {
        event.windowID = Int(sdlEvent.windowID)

        switch SDL_WindowEventID(UInt32(sdlEvent.event)) {
        case SDL_WINDOWEVENT_RESIZED:
            event.action = .resizedTo(size: .init(Int(sdlEvent.data1), Int(sdlEvent.data1)))
            return true

        case SDL_WINDOWEVENT_CLOSE:
            event.action = .closeRequested
            return true

        default:
            #warning("❗TODO: translate all window events")
            return false
        }
    }

    private static func translateKeyboardEvent(from sdlEvent: SDL_KeyboardEvent, to event: inout KeyboardEvent) {
        event.windowID = Int(sdlEvent.windowID)

        switch Int32(sdlEvent.state) {
        case SDL_PRESSED:
            event.state = .pressed
        case SDL_RELEASED:
            event.state = .released
        default:
            assertionFailure("Unexpected state \(sdlEvent.state)")
        }

        event.isRepeat = (sdlEvent.repeat != 0)

        // SDL virtual key code; see SDL_Keycode for details
        event.virtualKey = Self.virtualKeyMap[SDL_KeyCode(UInt32(sdlEvent.keysym.sym))]

        // SDL physical key code; see SDL_Scancode for details
        event.physicalKey = Self.physicalKeyMap[sdlEvent.keysym.scancode]!

        // current key modifiers; see SDL_Keymod for details
        translateKeyboardModifiers(sdlModifiers: SDL_Keymod(UInt32(sdlEvent.keysym.mod)), modifiers: &event.modifiers)
    }

    private static func translateKeyboardModifiers(sdlModifiers: SDL_Keymod, modifiers: inout KeyModifier) {
        modifiers = .none

        if sdlModifiers.contains(KMOD_LSHIFT) {
            modifiers.insert(.shiftLeft)
        }
        if sdlModifiers.contains(KMOD_RSHIFT) {
            modifiers.insert(.shiftRight)
        }
        if sdlModifiers.contains(KMOD_LCTRL) {
            modifiers.insert(.controlLeft)
        }
        if sdlModifiers.contains(KMOD_RCTRL) {
            modifiers.insert(.controlRight)
        }
        if sdlModifiers.contains(KMOD_LALT) {
            modifiers.insert(.alternateLeft)
        }
        if sdlModifiers.contains(KMOD_RALT) {
            modifiers.insert(.alternateRight)
        }
        if sdlModifiers.contains(KMOD_LGUI) {
            modifiers.insert(.metaLeft)
        }
        if sdlModifiers.contains(KMOD_RGUI) {
            modifiers.insert(.metaRight)
        }
        if sdlModifiers.contains(KMOD_MODE) {
            modifiers.insert(.alternateGraphic)
        }
        if sdlModifiers.contains(KMOD_CAPS) {
            modifiers.insert(.capsLock)
        }
        if sdlModifiers.contains(KMOD_NUM) {
            modifiers.insert(.numLock)
        }
    }

    private static func translateTextInputEvent(from sdlEvent: SDL_TextInputEvent, to event: inout TextInputEvent) {
        event.windowID = Int(sdlEvent.windowID)
        event.text = withUnsafePointer(to: sdlEvent.text) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 32) {
                String(cString: $0)
            }
        }
    }

    private static func translateTextEditingEvent(from sdlEvent: SDL_TextEditingEvent, to event: inout TextEditingEvent) {
        event.windowID = Int(sdlEvent.windowID)
        event.text = withUnsafePointer(to: sdlEvent.text) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 32) {
                String(cString: $0)
            }
        }
        event.start = Int(sdlEvent.start)
        event.length = Int(sdlEvent.length)
    }

    private static let virtualKeyMap: [AnyHashable: KeyCode] = [
        SDLK_0: ._0,
        SDLK_1: ._1,
        SDLK_2: ._2,
        SDLK_3: ._3,
        SDLK_4: ._4,
        SDLK_5: ._5,
        SDLK_6: ._6,
        SDLK_7: ._7,
        SDLK_8: ._8,
        SDLK_9: ._9,
        SDLK_AC_BACK: .AC_BACK,
        SDLK_AC_BOOKMARKS: .AC_BOOKMARKS,
        SDLK_AC_FORWARD: .AC_FORWARD,
        SDLK_AC_HOME: .AC_HOME,
        SDLK_AC_REFRESH: .AC_REFRESH,
        SDLK_AC_SEARCH: .AC_SEARCH,
        SDLK_AC_STOP: .AC_STOP,
        SDLK_AGAIN: .AGAIN,
        SDLK_ALTERASE: .ALTERASE,
        SDLK_AMPERSAND: .AMPERSAND,
        SDLK_APP1: .APP1,
        SDLK_APP2: .APP2,
        SDLK_APPLICATION: .APPLICATION,
        SDLK_ASTERISK: .ASTERISK,
        SDLK_AT: .AT,
        SDLK_AUDIOFASTFORWARD: .AUDIOFASTFORWARD,
        SDLK_AUDIOMUTE: .AUDIOMUTE,
        SDLK_AUDIONEXT: .AUDIONEXT,
        SDLK_AUDIOPLAY: .AUDIOPLAY,
        SDLK_AUDIOPREV: .AUDIOPREV,
        SDLK_AUDIOREWIND: .AUDIOREWIND,
        SDLK_AUDIOSTOP: .AUDIOSTOP,
        SDLK_BACKQUOTE: .BACKQUOTE,
        SDLK_BACKSLASH: .BACKSLASH,
        SDLK_BACKSPACE: .BACKSPACE,
        SDLK_BRIGHTNESSDOWN: .BRIGHTNESSDOWN,
        SDLK_BRIGHTNESSUP: .BRIGHTNESSUP,
        SDLK_CALCULATOR: .CALCULATOR,
        SDLK_CANCEL: .CANCEL,
        SDLK_CAPSLOCK: .CAPSLOCK,
        SDLK_CARET: .CARET,
        SDLK_CLEAR: .CLEAR,
        SDLK_CLEARAGAIN: .CLEARAGAIN,
        SDLK_COLON: .COLON,
        SDLK_COMMA: .COMMA,
        SDLK_COMPUTER: .COMPUTER,
        SDLK_COPY: .COPY,
        SDLK_CRSEL: .CRSEL,
        SDLK_CURRENCYSUBUNIT: .CURRENCYSUBUNIT,
        SDLK_CURRENCYUNIT: .CURRENCYUNIT,
        SDLK_CUT: .CUT,
        SDLK_DECIMALSEPARATOR: .DECIMALSEPARATOR,
        SDLK_DELETE: .DELETE,
        SDLK_DISPLAYSWITCH: .DISPLAYSWITCH,
        SDLK_DOLLAR: .DOLLAR,
        SDLK_DOWN: .DOWN,
        SDLK_EJECT: .EJECT,
        SDLK_END: .END,
        SDLK_EQUALS: .EQUALS,
        SDLK_ESCAPE: .ESCAPE,
        SDLK_EXCLAIM: .EXCLAIM,
        SDLK_EXECUTE: .EXECUTE,
        SDLK_EXSEL: .EXSEL,
        SDLK_F10: .F10,
        SDLK_F11: .F11,
        SDLK_F12: .F12,
        SDLK_F13: .F13,
        SDLK_F14: .F14,
        SDLK_F15: .F15,
        SDLK_F16: .F16,
        SDLK_F17: .F17,
        SDLK_F18: .F18,
        SDLK_F19: .F19,
        SDLK_F1: .F1,
        SDLK_F20: .F20,
        SDLK_F21: .F21,
        SDLK_F22: .F22,
        SDLK_F23: .F23,
        SDLK_F24: .F24,
        SDLK_F2: .F2,
        SDLK_F3: .F3,
        SDLK_F4: .F4,
        SDLK_F5: .F5,
        SDLK_F6: .F6,
        SDLK_F7: .F7,
        SDLK_F8: .F8,
        SDLK_F9: .F9,
        SDLK_FIND: .FIND,
        SDLK_GREATER: .GREATER,
        SDLK_HASH: .HASH,
        SDLK_HELP: .HELP,
        SDLK_HOME: .HOME,
        SDLK_INSERT: .INSERT,
        SDLK_KBDILLUMDOWN: .KBDILLUMDOWN,
        SDLK_KBDILLUMTOGGLE: .KBDILLUMTOGGLE,
        SDLK_KBDILLUMUP: .KBDILLUMUP,
        SDLK_KP_000: .KP_000,
        SDLK_KP_00: .KP_00,
        SDLK_KP_0: .KP_0,
        SDLK_KP_1: .KP_1,
        SDLK_KP_2: .KP_2,
        SDLK_KP_3: .KP_3,
        SDLK_KP_4: .KP_4,
        SDLK_KP_5: .KP_5,
        SDLK_KP_6: .KP_6,
        SDLK_KP_7: .KP_7,
        SDLK_KP_8: .KP_8,
        SDLK_KP_9: .KP_9,
        SDLK_KP_A: .KP_A,
        SDLK_KP_AMPERSAND: .KP_AMPERSAND,
        SDLK_KP_AT: .KP_AT,
        SDLK_KP_B: .KP_B,
        SDLK_KP_BACKSPACE: .KP_BACKSPACE,
        SDLK_KP_BINARY: .KP_BINARY,
        SDLK_KP_C: .KP_C,
        SDLK_KP_CLEAR: .KP_CLEAR,
        SDLK_KP_CLEARENTRY: .KP_CLEARENTRY,
        SDLK_KP_COLON: .KP_COLON,
        SDLK_KP_COMMA: .KP_COMMA,
        SDLK_KP_D: .KP_D,
        SDLK_KP_DBLAMPERSAND: .KP_DBLAMPERSAND,
        SDLK_KP_DBLVERTICALBAR: .KP_DBLVERTICALBAR,
        SDLK_KP_DECIMAL: .KP_DECIMAL,
        SDLK_KP_DIVIDE: .KP_DIVIDE,
        SDLK_KP_E: .KP_E,
        SDLK_KP_ENTER: .KP_ENTER,
        SDLK_KP_EQUALS: .KP_EQUALS,
        SDLK_KP_EQUALSAS400: .KP_EQUALSAS400,
        SDLK_KP_EXCLAM: .KP_EXCLAM,
        SDLK_KP_F: .KP_F,
        SDLK_KP_GREATER: .KP_GREATER,
        SDLK_KP_HASH: .KP_HASH,
        SDLK_KP_HEXADECIMAL: .KP_HEXADECIMAL,
        SDLK_KP_LEFTBRACE: .KP_LEFTBRACE,
        SDLK_KP_LEFTPAREN: .KP_LEFTPAREN,
        SDLK_KP_LESS: .KP_LESS,
        SDLK_KP_MEMADD: .KP_MEMADD,
        SDLK_KP_MEMCLEAR: .KP_MEMCLEAR,
        SDLK_KP_MEMDIVIDE: .KP_MEMDIVIDE,
        SDLK_KP_MEMMULTIPLY: .KP_MEMMULTIPLY,
        SDLK_KP_MEMRECALL: .KP_MEMRECALL,
        SDLK_KP_MEMSTORE: .KP_MEMSTORE,
        SDLK_KP_MEMSUBTRACT: .KP_MEMSUBTRACT,
        SDLK_KP_MINUS: .KP_MINUS,
        SDLK_KP_MULTIPLY: .KP_MULTIPLY,
        SDLK_KP_OCTAL: .KP_OCTAL,
        SDLK_KP_PERCENT: .KP_PERCENT,
        SDLK_KP_PERIOD: .KP_PERIOD,
        SDLK_KP_PLUS: .KP_PLUS,
        SDLK_KP_PLUSMINUS: .KP_PLUSMINUS,
        SDLK_KP_POWER: .KP_POWER,
        SDLK_KP_RIGHTBRACE: .KP_RIGHTBRACE,
        SDLK_KP_RIGHTPAREN: .KP_RIGHTPAREN,
        SDLK_KP_SPACE: .KP_SPACE,
        SDLK_KP_TAB: .KP_TAB,
        SDLK_KP_VERTICALBAR: .KP_VERTICALBAR,
        SDLK_KP_XOR: .KP_XOR,
        SDLK_LALT: .LALT,
        SDLK_LCTRL: .LCTRL,
        SDLK_LEFT: .LEFT,
        SDLK_LEFTBRACKET: .LEFTBRACKET,
        SDLK_LEFTPAREN: .LEFTPAREN,
        SDLK_LESS: .LESS,
        SDLK_LGUI: .LGUI,
        SDLK_LSHIFT: .LSHIFT,
        SDLK_MAIL: .MAIL,
        SDLK_MEDIASELECT: .MEDIASELECT,
        SDLK_MENU: .MENU,
        SDLK_MINUS: .MINUS,
        SDLK_MODE: .MODE,
        SDLK_MUTE: .MUTE,
        SDLK_NUMLOCKCLEAR: .NUMLOCKCLEAR,
        SDLK_OPER: .OPER,
        SDLK_OUT: .OUT,
        SDLK_PAGEDOWN: .PAGEDOWN,
        SDLK_PAGEUP: .PAGEUP,
        SDLK_PASTE: .PASTE,
        SDLK_PAUSE: .PAUSE,
        SDLK_PERCENT: .PERCENT,
        SDLK_PERIOD: .PERIOD,
        SDLK_PLUS: .PLUS,
        SDLK_POWER: .POWER,
        SDLK_PRINTSCREEN: .PRINTSCREEN,
        SDLK_PRIOR: .PRIOR,
        SDLK_QUESTION: .QUESTION,
        SDLK_QUOTE: .QUOTE,
        SDLK_QUOTEDBL: .QUOTEDBL,
        SDLK_RALT: .RALT,
        SDLK_RCTRL: .RCTRL,
        SDLK_RETURN2: .RETURN2,
        SDLK_RETURN: .RETURN,
        SDLK_RGUI: .RGUI,
        SDLK_RIGHT: .RIGHT,
        SDLK_RIGHTBRACKET: .RIGHTBRACKET,
        SDLK_RIGHTPAREN: .RIGHTPAREN,
        SDLK_RSHIFT: .RSHIFT,
        SDLK_SCROLLLOCK: .SCROLLLOCK,
        SDLK_SELECT: .SELECT,
        SDLK_SEMICOLON: .SEMICOLON,
        SDLK_SEPARATOR: .SEPARATOR,
        SDLK_SLASH: .SLASH,
        SDLK_SLEEP: .SLEEP,
        SDLK_SPACE: .SPACE,
        SDLK_STOP: .STOP,
        SDLK_SYSREQ: .SYSREQ,
        SDLK_TAB: .TAB,
        SDLK_THOUSANDSSEPARATOR: .THOUSANDSSEPARATOR,
        SDLK_UNDERSCORE: .UNDERSCORE,
        SDLK_UNDO: .UNDO,
        SDLK_UNKNOWN: .UNKNOWN,
        SDLK_UP: .UP,
        SDLK_VOLUMEDOWN: .VOLUMEDOWN,
        SDLK_VOLUMEUP: .VOLUMEUP,
        SDLK_WWW: .WWW,
        SDLK_a: .A,
        SDLK_b: .B,
        SDLK_c: .C,
        SDLK_d: .D,
        SDLK_e: .E,
        SDLK_f: .F,
        SDLK_g: .G,
        SDLK_h: .H,
        SDLK_i: .I,
        SDLK_j: .J,
        SDLK_k: .K,
        SDLK_l: .L,
        SDLK_m: .M,
        SDLK_n: .N,
        SDLK_o: .O,
        SDLK_p: .P,
        SDLK_q: .Q,
        SDLK_r: .R,
        SDLK_s: .S,
        SDLK_t: .T,
        SDLK_u: .U,
        SDLK_v: .V,
        SDLK_w: .W,
        SDLK_x: .X,
        SDLK_y: .Y,
        SDLK_z: .Z,
    ]

    private static let physicalKeyMap: [SDL_Scancode: KeyCode] = [
        SDL_SCANCODE_0: ._0,
        SDL_SCANCODE_1: ._1,
        SDL_SCANCODE_2: ._2,
        SDL_SCANCODE_3: ._3,
        SDL_SCANCODE_4: ._4,
        SDL_SCANCODE_5: ._5,
        SDL_SCANCODE_6: ._6,
        SDL_SCANCODE_7: ._7,
        SDL_SCANCODE_8: ._8,
        SDL_SCANCODE_9: ._9,
        SDL_SCANCODE_A: .A,
        SDL_SCANCODE_AC_BACK: .AC_BACK,
        SDL_SCANCODE_AC_BOOKMARKS: .AC_BOOKMARKS,
        SDL_SCANCODE_AC_FORWARD: .AC_FORWARD,
        SDL_SCANCODE_AC_HOME: .AC_HOME,
        SDL_SCANCODE_AC_REFRESH: .AC_REFRESH,
        SDL_SCANCODE_AC_SEARCH: .AC_SEARCH,
        SDL_SCANCODE_AC_STOP: .AC_STOP,
        SDL_SCANCODE_AGAIN: .AGAIN,
        SDL_SCANCODE_ALTERASE: .ALTERASE,
        SDL_SCANCODE_APOSTROPHE: .APOSTROPHE,
        SDL_SCANCODE_APP1: .APP1,
        SDL_SCANCODE_APP2: .APP2,
        SDL_SCANCODE_APPLICATION: .APPLICATION,
        SDL_SCANCODE_AUDIOFASTFORWARD: .AUDIOFASTFORWARD,
        SDL_SCANCODE_AUDIOMUTE: .AUDIOMUTE,
        SDL_SCANCODE_AUDIONEXT: .AUDIONEXT,
        SDL_SCANCODE_AUDIOPLAY: .AUDIOPLAY,
        SDL_SCANCODE_AUDIOPREV: .AUDIOPREV,
        SDL_SCANCODE_AUDIOREWIND: .AUDIOREWIND,
        SDL_SCANCODE_AUDIOSTOP: .AUDIOSTOP,
        SDL_SCANCODE_B: .B,
        SDL_SCANCODE_BACKSLASH: .BACKSLASH,
        SDL_SCANCODE_BACKSPACE: .BACKSPACE,
        SDL_SCANCODE_BRIGHTNESSDOWN: .BRIGHTNESSDOWN,
        SDL_SCANCODE_BRIGHTNESSUP: .BRIGHTNESSUP,
        SDL_SCANCODE_C: .C,
        SDL_SCANCODE_CALCULATOR: .CALCULATOR,
        SDL_SCANCODE_CANCEL: .CANCEL,
        SDL_SCANCODE_CAPSLOCK: .CAPSLOCK,
        SDL_SCANCODE_CLEAR: .CLEAR,
        SDL_SCANCODE_CLEARAGAIN: .CLEARAGAIN,
        SDL_SCANCODE_COMMA: .COMMA,
        SDL_SCANCODE_COMPUTER: .COMPUTER,
        SDL_SCANCODE_COPY: .COPY,
        SDL_SCANCODE_CRSEL: .CRSEL,
        SDL_SCANCODE_CURRENCYSUBUNIT: .CURRENCYSUBUNIT,
        SDL_SCANCODE_CURRENCYUNIT: .CURRENCYUNIT,
        SDL_SCANCODE_CUT: .CUT,
        SDL_SCANCODE_D: .D,
        SDL_SCANCODE_DECIMALSEPARATOR: .DECIMALSEPARATOR,
        SDL_SCANCODE_DELETE: .DELETE,
        SDL_SCANCODE_DISPLAYSWITCH: .DISPLAYSWITCH,
        SDL_SCANCODE_DOWN: .DOWN,
        SDL_SCANCODE_E: .E,
        SDL_SCANCODE_EJECT: .EJECT,
        SDL_SCANCODE_END: .END,
        SDL_SCANCODE_EQUALS: .EQUALS,
        SDL_SCANCODE_ESCAPE: .ESCAPE,
        SDL_SCANCODE_EXECUTE: .EXECUTE,
        SDL_SCANCODE_EXSEL: .EXSEL,
        SDL_SCANCODE_F: .F,
        SDL_SCANCODE_F1: .F1,
        SDL_SCANCODE_F10: .F10,
        SDL_SCANCODE_F11: .F11,
        SDL_SCANCODE_F12: .F12,
        SDL_SCANCODE_F13: .F13,
        SDL_SCANCODE_F14: .F14,
        SDL_SCANCODE_F15: .F15,
        SDL_SCANCODE_F16: .F16,
        SDL_SCANCODE_F17: .F17,
        SDL_SCANCODE_F18: .F18,
        SDL_SCANCODE_F19: .F19,
        SDL_SCANCODE_F2: .F2,
        SDL_SCANCODE_F20: .F20,
        SDL_SCANCODE_F21: .F21,
        SDL_SCANCODE_F22: .F22,
        SDL_SCANCODE_F23: .F23,
        SDL_SCANCODE_F24: .F24,
        SDL_SCANCODE_F3: .F3,
        SDL_SCANCODE_F4: .F4,
        SDL_SCANCODE_F5: .F5,
        SDL_SCANCODE_F6: .F6,
        SDL_SCANCODE_F7: .F7,
        SDL_SCANCODE_F8: .F8,
        SDL_SCANCODE_F9: .F9,
        SDL_SCANCODE_FIND: .FIND,
        SDL_SCANCODE_G: .G,
        SDL_SCANCODE_GRAVE: .GRAVE,
        SDL_SCANCODE_H: .H,
        SDL_SCANCODE_HELP: .HELP,
        SDL_SCANCODE_HOME: .HOME,
        SDL_SCANCODE_I: .I,
        SDL_SCANCODE_INSERT: .INSERT,
        SDL_SCANCODE_INTERNATIONAL1: .INTERNATIONAL1,
        SDL_SCANCODE_INTERNATIONAL2: .INTERNATIONAL2,
        SDL_SCANCODE_INTERNATIONAL3: .INTERNATIONAL3,
        SDL_SCANCODE_INTERNATIONAL4: .INTERNATIONAL4,
        SDL_SCANCODE_INTERNATIONAL5: .INTERNATIONAL5,
        SDL_SCANCODE_INTERNATIONAL6: .INTERNATIONAL6,
        SDL_SCANCODE_INTERNATIONAL7: .INTERNATIONAL7,
        SDL_SCANCODE_INTERNATIONAL8: .INTERNATIONAL8,
        SDL_SCANCODE_INTERNATIONAL9: .INTERNATIONAL9,
        SDL_SCANCODE_J: .J,
        SDL_SCANCODE_K: .K,
        SDL_SCANCODE_KBDILLUMDOWN: .KBDILLUMDOWN,
        SDL_SCANCODE_KBDILLUMTOGGLE: .KBDILLUMTOGGLE,
        SDL_SCANCODE_KBDILLUMUP: .KBDILLUMUP,
        SDL_SCANCODE_KP_0: .KP_0,
        SDL_SCANCODE_KP_00: .KP_00,
        SDL_SCANCODE_KP_000: .KP_000,
        SDL_SCANCODE_KP_1: .KP_1,
        SDL_SCANCODE_KP_2: .KP_2,
        SDL_SCANCODE_KP_3: .KP_3,
        SDL_SCANCODE_KP_4: .KP_4,
        SDL_SCANCODE_KP_5: .KP_5,
        SDL_SCANCODE_KP_6: .KP_6,
        SDL_SCANCODE_KP_7: .KP_7,
        SDL_SCANCODE_KP_8: .KP_8,
        SDL_SCANCODE_KP_9: .KP_9,
        SDL_SCANCODE_KP_A: .KP_A,
        SDL_SCANCODE_KP_AMPERSAND: .KP_AMPERSAND,
        SDL_SCANCODE_KP_AT: .KP_AT,
        SDL_SCANCODE_KP_B: .KP_B,
        SDL_SCANCODE_KP_BACKSPACE: .KP_BACKSPACE,
        SDL_SCANCODE_KP_BINARY: .KP_BINARY,
        SDL_SCANCODE_KP_C: .KP_C,
        SDL_SCANCODE_KP_CLEAR: .KP_CLEAR,
        SDL_SCANCODE_KP_CLEARENTRY: .KP_CLEARENTRY,
        SDL_SCANCODE_KP_COLON: .KP_COLON,
        SDL_SCANCODE_KP_COMMA: .KP_COMMA,
        SDL_SCANCODE_KP_D: .KP_D,
        SDL_SCANCODE_KP_DBLAMPERSAND: .KP_DBLAMPERSAND,
        SDL_SCANCODE_KP_DBLVERTICALBAR: .KP_DBLVERTICALBAR,
        SDL_SCANCODE_KP_DECIMAL: .KP_DECIMAL,
        SDL_SCANCODE_KP_DIVIDE: .KP_DIVIDE,
        SDL_SCANCODE_KP_E: .KP_E,
        SDL_SCANCODE_KP_ENTER: .KP_ENTER,
        SDL_SCANCODE_KP_EQUALS: .KP_EQUALS,
        SDL_SCANCODE_KP_EQUALSAS400: .KP_EQUALSAS400,
        SDL_SCANCODE_KP_EXCLAM: .KP_EXCLAM,
        SDL_SCANCODE_KP_F: .KP_F,
        SDL_SCANCODE_KP_GREATER: .KP_GREATER,
        SDL_SCANCODE_KP_HASH: .KP_HASH,
        SDL_SCANCODE_KP_HEXADECIMAL: .KP_HEXADECIMAL,
        SDL_SCANCODE_KP_LEFTBRACE: .KP_LEFTBRACE,
        SDL_SCANCODE_KP_LEFTPAREN: .KP_LEFTPAREN,
        SDL_SCANCODE_KP_LESS: .KP_LESS,
        SDL_SCANCODE_KP_MEMADD: .KP_MEMADD,
        SDL_SCANCODE_KP_MEMCLEAR: .KP_MEMCLEAR,
        SDL_SCANCODE_KP_MEMDIVIDE: .KP_MEMDIVIDE,
        SDL_SCANCODE_KP_MEMMULTIPLY: .KP_MEMMULTIPLY,
        SDL_SCANCODE_KP_MEMRECALL: .KP_MEMRECALL,
        SDL_SCANCODE_KP_MEMSTORE: .KP_MEMSTORE,
        SDL_SCANCODE_KP_MEMSUBTRACT: .KP_MEMSUBTRACT,
        SDL_SCANCODE_KP_MINUS: .KP_MINUS,
        SDL_SCANCODE_KP_MULTIPLY: .KP_MULTIPLY,
        SDL_SCANCODE_KP_OCTAL: .KP_OCTAL,
        SDL_SCANCODE_KP_PERCENT: .KP_PERCENT,
        SDL_SCANCODE_KP_PERIOD: .KP_PERIOD,
        SDL_SCANCODE_KP_PLUS: .KP_PLUS,
        SDL_SCANCODE_KP_PLUSMINUS: .KP_PLUSMINUS,
        SDL_SCANCODE_KP_POWER: .KP_POWER,
        SDL_SCANCODE_KP_RIGHTBRACE: .KP_RIGHTBRACE,
        SDL_SCANCODE_KP_RIGHTPAREN: .KP_RIGHTPAREN,
        SDL_SCANCODE_KP_SPACE: .KP_SPACE,
        SDL_SCANCODE_KP_TAB: .KP_TAB,
        SDL_SCANCODE_KP_VERTICALBAR: .KP_VERTICALBAR,
        SDL_SCANCODE_KP_XOR: .KP_XOR,
        SDL_SCANCODE_L: .L,
        SDL_SCANCODE_LALT: .LALT,
        SDL_SCANCODE_LANG1: .LANG1,
        SDL_SCANCODE_LANG2: .LANG2,
        SDL_SCANCODE_LANG3: .LANG3,
        SDL_SCANCODE_LANG4: .LANG4,
        SDL_SCANCODE_LANG5: .LANG5,
        SDL_SCANCODE_LANG6: .LANG6,
        SDL_SCANCODE_LANG7: .LANG7,
        SDL_SCANCODE_LANG8: .LANG8,
        SDL_SCANCODE_LANG9: .LANG9,
        SDL_SCANCODE_LCTRL: .LCTRL,
        SDL_SCANCODE_LEFT: .LEFT,
        SDL_SCANCODE_LEFTBRACKET: .LEFTBRACKET,
        SDL_SCANCODE_LGUI: .LGUI,
        SDL_SCANCODE_LSHIFT: .LSHIFT,
        SDL_SCANCODE_M: .M,
        SDL_SCANCODE_MAIL: .MAIL,
        SDL_SCANCODE_MEDIASELECT: .MEDIASELECT,
        SDL_SCANCODE_MENU: .MENU,
        SDL_SCANCODE_MINUS: .MINUS,
        SDL_SCANCODE_MODE: .MODE,
        SDL_SCANCODE_MUTE: .MUTE,
        SDL_SCANCODE_N: .N,
        SDL_SCANCODE_NONUSBACKSLASH: .NONUSBACKSLASH,
        SDL_SCANCODE_NONUSHASH: .NONUSHASH,
        SDL_SCANCODE_NUMLOCKCLEAR: .NUMLOCKCLEAR,
        SDL_SCANCODE_O: .O,
        SDL_SCANCODE_OPER: .OPER,
        SDL_SCANCODE_OUT: .OUT,
        SDL_SCANCODE_P: .P,
        SDL_SCANCODE_PAGEDOWN: .PAGEDOWN,
        SDL_SCANCODE_PAGEUP: .PAGEUP,
        SDL_SCANCODE_PASTE: .PASTE,
        SDL_SCANCODE_PAUSE: .PAUSE,
        SDL_SCANCODE_PERIOD: .PERIOD,
        SDL_SCANCODE_POWER: .POWER,
        SDL_SCANCODE_PRINTSCREEN: .PRINTSCREEN,
        SDL_SCANCODE_PRIOR: .PRIOR,
        SDL_SCANCODE_Q: .Q,
        SDL_SCANCODE_R: .R,
        SDL_SCANCODE_RALT: .RALT,
        SDL_SCANCODE_RCTRL: .RCTRL,
        SDL_SCANCODE_RETURN: .RETURN,
        SDL_SCANCODE_RETURN2: .RETURN2,
        SDL_SCANCODE_RGUI: .RGUI,
        SDL_SCANCODE_RIGHT: .RIGHT,
        SDL_SCANCODE_RIGHTBRACKET: .RIGHTBRACKET,
        SDL_SCANCODE_RSHIFT: .RSHIFT,
        SDL_SCANCODE_S: .S,
        SDL_SCANCODE_SCROLLLOCK: .SCROLLLOCK,
        SDL_SCANCODE_SELECT: .SELECT,
        SDL_SCANCODE_SEMICOLON: .SEMICOLON,
        SDL_SCANCODE_SEPARATOR: .SEPARATOR,
        SDL_SCANCODE_SLASH: .SLASH,
        SDL_SCANCODE_SLEEP: .SLEEP,
        SDL_SCANCODE_SPACE: .SPACE,
        SDL_SCANCODE_STOP: .STOP,
        SDL_SCANCODE_SYSREQ: .SYSREQ,
        SDL_SCANCODE_T: .T,
        SDL_SCANCODE_TAB: .TAB,
        SDL_SCANCODE_THOUSANDSSEPARATOR: .THOUSANDSSEPARATOR,
        SDL_SCANCODE_U: .U,
        SDL_SCANCODE_UNDO: .UNDO,
        SDL_SCANCODE_UP: .UP,
        SDL_SCANCODE_V: .V,
        SDL_SCANCODE_VOLUMEDOWN: .VOLUMEDOWN,
        SDL_SCANCODE_VOLUMEUP: .VOLUMEUP,
        SDL_SCANCODE_W: .W,
        SDL_SCANCODE_WWW: .WWW,
        SDL_SCANCODE_X: .X,
        SDL_SCANCODE_Y: .Y,
        SDL_SCANCODE_Z: .Z,
    ]

    static let pointerButtonMap: [Int32: PointerButton] = [
        SDL_BUTTON_LEFT: .left,
        SDL_BUTTON_MIDDLE: .middle,
        SDL_BUTTON_RIGHT: .right,
        SDL_BUTTON_X1: .other(4), // extra button 1 is mouse button 4
        SDL_BUTTON_X2: .other(5), // extra button 2 is mouse button 5
    ]
}

extension SDL_Scancode: Equatable {}
extension SDL_Scancode: Hashable {}

extension SDL_Keymod {
    func contains(_ mod: SDL_Keymod) -> Bool {
        rawValue & mod.rawValue != 0
    }
}
#endif
