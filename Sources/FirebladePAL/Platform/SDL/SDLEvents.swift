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
        let sdlEventType = SDL_EventType(SDL_EventType.RawValue(sdlEvent.type))
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
        switch SDL_MouseWheelDirection(SDL_MouseWheelDirection.RawValue(sdlEvent.direction)) {
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

        switch SDL_WindowEventID(SDL_WindowEventID.RawValue(sdlEvent.event)) {
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

        event.virtualKey = Self.virtualKeyMap[UInt32(sdlEvent.keysym.sym)]

        // SDL physical key code; see SDL_Scancode for details
        event.physicalKey = Self.physicalKeyMap[sdlEvent.keysym.scancode]!

        // current key modifiers; see SDL_Keymod for details
        translateKeyboardModifiers(sdlModifiers: SDL_Keymod(SDL_Keymod.RawValue(sdlEvent.keysym.mod)), modifiers: &event.modifiers)
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

    private static let virtualKeyMap: [UInt32: KeyCode] = [
        convertKey(SDLK_0): ._0,
        convertKey(SDLK_1): ._1,
        convertKey(SDLK_2): ._2,
        convertKey(SDLK_3): ._3,
        convertKey(SDLK_4): ._4,
        convertKey(SDLK_5): ._5,
        convertKey(SDLK_6): ._6,
        convertKey(SDLK_7): ._7,
        convertKey(SDLK_8): ._8,
        convertKey(SDLK_9): ._9,
        convertKey(SDLK_AC_BACK): .AC_BACK,
        convertKey(SDLK_AC_BOOKMARKS): .AC_BOOKMARKS,
        convertKey(SDLK_AC_FORWARD): .AC_FORWARD,
        convertKey(SDLK_AC_HOME): .AC_HOME,
        convertKey(SDLK_AC_REFRESH): .AC_REFRESH,
        convertKey(SDLK_AC_SEARCH): .AC_SEARCH,
        convertKey(SDLK_AC_STOP): .AC_STOP,
        convertKey(SDLK_AGAIN): .AGAIN,
        convertKey(SDLK_ALTERASE): .ALTERASE,
        convertKey(SDLK_AMPERSAND): .AMPERSAND,
        convertKey(SDLK_APP1): .APP1,
        convertKey(SDLK_APP2): .APP2,
        convertKey(SDLK_APPLICATION): .APPLICATION,
        convertKey(SDLK_ASTERISK): .ASTERISK,
        convertKey(SDLK_AT): .AT,
        convertKey(SDLK_AUDIOFASTFORWARD): .AUDIOFASTFORWARD,
        convertKey(SDLK_AUDIOMUTE): .AUDIOMUTE,
        convertKey(SDLK_AUDIONEXT): .AUDIONEXT,
        convertKey(SDLK_AUDIOPLAY): .AUDIOPLAY,
        convertKey(SDLK_AUDIOPREV): .AUDIOPREV,
        convertKey(SDLK_AUDIOREWIND): .AUDIOREWIND,
        convertKey(SDLK_AUDIOSTOP): .AUDIOSTOP,
        convertKey(SDLK_BACKQUOTE): .BACKQUOTE,
        convertKey(SDLK_BACKSLASH): .BACKSLASH,
        convertKey(SDLK_BACKSPACE): .BACKSPACE,
        convertKey(SDLK_BRIGHTNESSDOWN): .BRIGHTNESSDOWN,
        convertKey(SDLK_BRIGHTNESSUP): .BRIGHTNESSUP,
        convertKey(SDLK_CALCULATOR): .CALCULATOR,
        convertKey(SDLK_CANCEL): .CANCEL,
        convertKey(SDLK_CAPSLOCK): .CAPSLOCK,
        convertKey(SDLK_CARET): .CARET,
        convertKey(SDLK_CLEAR): .CLEAR,
        convertKey(SDLK_CLEARAGAIN): .CLEARAGAIN,
        convertKey(SDLK_COLON): .COLON,
        convertKey(SDLK_COMMA): .COMMA,
        convertKey(SDLK_COMPUTER): .COMPUTER,
        convertKey(SDLK_COPY): .COPY,
        convertKey(SDLK_CRSEL): .CRSEL,
        convertKey(SDLK_CURRENCYSUBUNIT): .CURRENCYSUBUNIT,
        convertKey(SDLK_CURRENCYUNIT): .CURRENCYUNIT,
        convertKey(SDLK_CUT): .CUT,
        convertKey(SDLK_DECIMALSEPARATOR): .DECIMALSEPARATOR,
        convertKey(SDLK_DELETE): .DELETE,
        convertKey(SDLK_DISPLAYSWITCH): .DISPLAYSWITCH,
        convertKey(SDLK_DOLLAR): .DOLLAR,
        convertKey(SDLK_DOWN): .DOWN,
        convertKey(SDLK_EJECT): .EJECT,
        convertKey(SDLK_END): .END,
        convertKey(SDLK_EQUALS): .EQUALS,
        convertKey(SDLK_ESCAPE): .ESCAPE,
        convertKey(SDLK_EXCLAIM): .EXCLAIM,
        convertKey(SDLK_EXECUTE): .EXECUTE,
        convertKey(SDLK_EXSEL): .EXSEL,
        convertKey(SDLK_F10): .F10,
        convertKey(SDLK_F11): .F11,
        convertKey(SDLK_F12): .F12,
        convertKey(SDLK_F13): .F13,
        convertKey(SDLK_F14): .F14,
        convertKey(SDLK_F15): .F15,
        convertKey(SDLK_F16): .F16,
        convertKey(SDLK_F17): .F17,
        convertKey(SDLK_F18): .F18,
        convertKey(SDLK_F19): .F19,
        convertKey(SDLK_F1): .F1,
        convertKey(SDLK_F20): .F20,
        convertKey(SDLK_F21): .F21,
        convertKey(SDLK_F22): .F22,
        convertKey(SDLK_F23): .F23,
        convertKey(SDLK_F24): .F24,
        convertKey(SDLK_F2): .F2,
        convertKey(SDLK_F3): .F3,
        convertKey(SDLK_F4): .F4,
        convertKey(SDLK_F5): .F5,
        convertKey(SDLK_F6): .F6,
        convertKey(SDLK_F7): .F7,
        convertKey(SDLK_F8): .F8,
        convertKey(SDLK_F9): .F9,
        convertKey(SDLK_FIND): .FIND,
        convertKey(SDLK_GREATER): .GREATER,
        convertKey(SDLK_HASH): .HASH,
        convertKey(SDLK_HELP): .HELP,
        convertKey(SDLK_HOME): .HOME,
        convertKey(SDLK_INSERT): .INSERT,
        convertKey(SDLK_KBDILLUMDOWN): .KBDILLUMDOWN,
        convertKey(SDLK_KBDILLUMTOGGLE): .KBDILLUMTOGGLE,
        convertKey(SDLK_KBDILLUMUP): .KBDILLUMUP,
        convertKey(SDLK_KP_000): .KP_000,
        convertKey(SDLK_KP_00): .KP_00,
        convertKey(SDLK_KP_0): .KP_0,
        convertKey(SDLK_KP_1): .KP_1,
        convertKey(SDLK_KP_2): .KP_2,
        convertKey(SDLK_KP_3): .KP_3,
        convertKey(SDLK_KP_4): .KP_4,
        convertKey(SDLK_KP_5): .KP_5,
        convertKey(SDLK_KP_6): .KP_6,
        convertKey(SDLK_KP_7): .KP_7,
        convertKey(SDLK_KP_8): .KP_8,
        convertKey(SDLK_KP_9): .KP_9,
        convertKey(SDLK_KP_A): .KP_A,
        convertKey(SDLK_KP_AMPERSAND): .KP_AMPERSAND,
        convertKey(SDLK_KP_AT): .KP_AT,
        convertKey(SDLK_KP_B): .KP_B,
        convertKey(SDLK_KP_BACKSPACE): .KP_BACKSPACE,
        convertKey(SDLK_KP_BINARY): .KP_BINARY,
        convertKey(SDLK_KP_C): .KP_C,
        convertKey(SDLK_KP_CLEAR): .KP_CLEAR,
        convertKey(SDLK_KP_CLEARENTRY): .KP_CLEARENTRY,
        convertKey(SDLK_KP_COLON): .KP_COLON,
        convertKey(SDLK_KP_COMMA): .KP_COMMA,
        convertKey(SDLK_KP_D): .KP_D,
        convertKey(SDLK_KP_DBLAMPERSAND): .KP_DBLAMPERSAND,
        convertKey(SDLK_KP_DBLVERTICALBAR): .KP_DBLVERTICALBAR,
        convertKey(SDLK_KP_DECIMAL): .KP_DECIMAL,
        convertKey(SDLK_KP_DIVIDE): .KP_DIVIDE,
        convertKey(SDLK_KP_E): .KP_E,
        convertKey(SDLK_KP_ENTER): .KP_ENTER,
        convertKey(SDLK_KP_EQUALS): .KP_EQUALS,
        convertKey(SDLK_KP_EQUALSAS400): .KP_EQUALSAS400,
        convertKey(SDLK_KP_EXCLAM): .KP_EXCLAM,
        convertKey(SDLK_KP_F): .KP_F,
        convertKey(SDLK_KP_GREATER): .KP_GREATER,
        convertKey(SDLK_KP_HASH): .KP_HASH,
        convertKey(SDLK_KP_HEXADECIMAL): .KP_HEXADECIMAL,
        convertKey(SDLK_KP_LEFTBRACE): .KP_LEFTBRACE,
        convertKey(SDLK_KP_LEFTPAREN): .KP_LEFTPAREN,
        convertKey(SDLK_KP_LESS): .KP_LESS,
        convertKey(SDLK_KP_MEMADD): .KP_MEMADD,
        convertKey(SDLK_KP_MEMCLEAR): .KP_MEMCLEAR,
        convertKey(SDLK_KP_MEMDIVIDE): .KP_MEMDIVIDE,
        convertKey(SDLK_KP_MEMMULTIPLY): .KP_MEMMULTIPLY,
        convertKey(SDLK_KP_MEMRECALL): .KP_MEMRECALL,
        convertKey(SDLK_KP_MEMSTORE): .KP_MEMSTORE,
        convertKey(SDLK_KP_MEMSUBTRACT): .KP_MEMSUBTRACT,
        convertKey(SDLK_KP_MINUS): .KP_MINUS,
        convertKey(SDLK_KP_MULTIPLY): .KP_MULTIPLY,
        convertKey(SDLK_KP_OCTAL): .KP_OCTAL,
        convertKey(SDLK_KP_PERCENT): .KP_PERCENT,
        convertKey(SDLK_KP_PERIOD): .KP_PERIOD,
        convertKey(SDLK_KP_PLUS): .KP_PLUS,
        convertKey(SDLK_KP_PLUSMINUS): .KP_PLUSMINUS,
        convertKey(SDLK_KP_POWER): .KP_POWER,
        convertKey(SDLK_KP_RIGHTBRACE): .KP_RIGHTBRACE,
        convertKey(SDLK_KP_RIGHTPAREN): .KP_RIGHTPAREN,
        convertKey(SDLK_KP_SPACE): .KP_SPACE,
        convertKey(SDLK_KP_TAB): .KP_TAB,
        convertKey(SDLK_KP_VERTICALBAR): .KP_VERTICALBAR,
        convertKey(SDLK_KP_XOR): .KP_XOR,
        convertKey(SDLK_LALT): .LALT,
        convertKey(SDLK_LCTRL): .LCTRL,
        convertKey(SDLK_LEFT): .LEFT,
        convertKey(SDLK_LEFTBRACKET): .LEFTBRACKET,
        convertKey(SDLK_LEFTPAREN): .LEFTPAREN,
        convertKey(SDLK_LESS): .LESS,
        convertKey(SDLK_LGUI): .LGUI,
        convertKey(SDLK_LSHIFT): .LSHIFT,
        convertKey(SDLK_MAIL): .MAIL,
        convertKey(SDLK_MEDIASELECT): .MEDIASELECT,
        convertKey(SDLK_MENU): .MENU,
        convertKey(SDLK_MINUS): .MINUS,
        convertKey(SDLK_MODE): .MODE,
        convertKey(SDLK_MUTE): .MUTE,
        convertKey(SDLK_NUMLOCKCLEAR): .NUMLOCKCLEAR,
        convertKey(SDLK_OPER): .OPER,
        convertKey(SDLK_OUT): .OUT,
        convertKey(SDLK_PAGEDOWN): .PAGEDOWN,
        convertKey(SDLK_PAGEUP): .PAGEUP,
        convertKey(SDLK_PASTE): .PASTE,
        convertKey(SDLK_PAUSE): .PAUSE,
        convertKey(SDLK_PERCENT): .PERCENT,
        convertKey(SDLK_PERIOD): .PERIOD,
        convertKey(SDLK_PLUS): .PLUS,
        convertKey(SDLK_POWER): .POWER,
        convertKey(SDLK_PRINTSCREEN): .PRINTSCREEN,
        convertKey(SDLK_PRIOR): .PRIOR,
        convertKey(SDLK_QUESTION): .QUESTION,
        convertKey(SDLK_QUOTE): .QUOTE,
        convertKey(SDLK_QUOTEDBL): .QUOTEDBL,
        convertKey(SDLK_RALT): .RALT,
        convertKey(SDLK_RCTRL): .RCTRL,
        convertKey(SDLK_RETURN2): .RETURN2,
        convertKey(SDLK_RETURN): .RETURN,
        convertKey(SDLK_RGUI): .RGUI,
        convertKey(SDLK_RIGHT): .RIGHT,
        convertKey(SDLK_RIGHTBRACKET): .RIGHTBRACKET,
        convertKey(SDLK_RIGHTPAREN): .RIGHTPAREN,
        convertKey(SDLK_RSHIFT): .RSHIFT,
        convertKey(SDLK_SCROLLLOCK): .SCROLLLOCK,
        convertKey(SDLK_SELECT): .SELECT,
        convertKey(SDLK_SEMICOLON): .SEMICOLON,
        convertKey(SDLK_SEPARATOR): .SEPARATOR,
        convertKey(SDLK_SLASH): .SLASH,
        convertKey(SDLK_SLEEP): .SLEEP,
        convertKey(SDLK_SPACE): .SPACE,
        convertKey(SDLK_STOP): .STOP,
        convertKey(SDLK_SYSREQ): .SYSREQ,
        convertKey(SDLK_TAB): .TAB,
        convertKey(SDLK_THOUSANDSSEPARATOR): .THOUSANDSSEPARATOR,
        convertKey(SDLK_UNDERSCORE): .UNDERSCORE,
        convertKey(SDLK_UNDO): .UNDO,
        convertKey(SDLK_UNKNOWN): .UNKNOWN,
        convertKey(SDLK_UP): .UP,
        convertKey(SDLK_VOLUMEDOWN): .VOLUMEDOWN,
        convertKey(SDLK_VOLUMEUP): .VOLUMEUP,
        convertKey(SDLK_WWW): .WWW,
        convertKey(SDLK_a): .A,
        convertKey(SDLK_b): .B,
        convertKey(SDLK_c): .C,
        convertKey(SDLK_d): .D,
        convertKey(SDLK_e): .E,
        convertKey(SDLK_f): .F,
        convertKey(SDLK_g): .G,
        convertKey(SDLK_h): .H,
        convertKey(SDLK_i): .I,
        convertKey(SDLK_j): .J,
        convertKey(SDLK_k): .K,
        convertKey(SDLK_l): .L,
        convertKey(SDLK_m): .M,
        convertKey(SDLK_n): .N,
        convertKey(SDLK_o): .O,
        convertKey(SDLK_p): .P,
        convertKey(SDLK_q): .Q,
        convertKey(SDLK_r): .R,
        convertKey(SDLK_s): .S,
        convertKey(SDLK_t): .T,
        convertKey(SDLK_u): .U,
        convertKey(SDLK_v): .V,
        convertKey(SDLK_w): .W,
        convertKey(SDLK_x): .X,
        convertKey(SDLK_y): .Y,
        convertKey(SDLK_z): .Z,
    ] as [UInt32: KeyCode]

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

private func convertKey<T: RawRepresentable>(_ sdlKey: T) -> UInt32 where T.RawValue == UInt32 {
    UInt32(sdlKey.rawValue)
}

private func convertKey(_ sdlKey: Int) -> UInt32 {
    UInt32(sdlKey)
}

#endif
