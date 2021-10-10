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
        UInt32(SDLK_0.rawValue): ._0,
        UInt32(SDLK_1.rawValue): ._1,
        UInt32(SDLK_2.rawValue): ._2,
        UInt32(SDLK_3.rawValue): ._3,
        UInt32(SDLK_4.rawValue): ._4,
        UInt32(SDLK_5.rawValue): ._5,
        UInt32(SDLK_6.rawValue): ._6,
        UInt32(SDLK_7.rawValue): ._7,
        UInt32(SDLK_8.rawValue): ._8,
        UInt32(SDLK_9.rawValue): ._9,
        UInt32(SDLK_AC_BACK.rawValue): .AC_BACK,
        UInt32(SDLK_AC_BOOKMARKS.rawValue): .AC_BOOKMARKS,
        UInt32(SDLK_AC_FORWARD.rawValue): .AC_FORWARD,
        UInt32(SDLK_AC_HOME.rawValue): .AC_HOME,
        UInt32(SDLK_AC_REFRESH.rawValue): .AC_REFRESH,
        UInt32(SDLK_AC_SEARCH.rawValue): .AC_SEARCH,
        UInt32(SDLK_AC_STOP.rawValue): .AC_STOP,
        UInt32(SDLK_AGAIN.rawValue): .AGAIN,
        UInt32(SDLK_ALTERASE.rawValue): .ALTERASE,
        UInt32(SDLK_AMPERSAND.rawValue): .AMPERSAND,
        UInt32(SDLK_APP1.rawValue): .APP1,
        UInt32(SDLK_APP2.rawValue): .APP2,
        UInt32(SDLK_APPLICATION.rawValue): .APPLICATION,
        UInt32(SDLK_ASTERISK.rawValue): .ASTERISK,
        UInt32(SDLK_AT.rawValue): .AT,
        UInt32(SDLK_AUDIOFASTFORWARD.rawValue): .AUDIOFASTFORWARD,
        UInt32(SDLK_AUDIOMUTE.rawValue): .AUDIOMUTE,
        UInt32(SDLK_AUDIONEXT.rawValue): .AUDIONEXT,
        UInt32(SDLK_AUDIOPLAY.rawValue): .AUDIOPLAY,
        UInt32(SDLK_AUDIOPREV.rawValue): .AUDIOPREV,
        UInt32(SDLK_AUDIOREWIND.rawValue): .AUDIOREWIND,
        UInt32(SDLK_AUDIOSTOP.rawValue): .AUDIOSTOP,
        UInt32(SDLK_BACKQUOTE.rawValue): .BACKQUOTE,
        UInt32(SDLK_BACKSLASH.rawValue): .BACKSLASH,
        UInt32(SDLK_BACKSPACE.rawValue): .BACKSPACE,
        UInt32(SDLK_BRIGHTNESSDOWN.rawValue): .BRIGHTNESSDOWN,
        UInt32(SDLK_BRIGHTNESSUP.rawValue): .BRIGHTNESSUP,
        UInt32(SDLK_CALCULATOR.rawValue): .CALCULATOR,
        UInt32(SDLK_CANCEL.rawValue): .CANCEL,
        UInt32(SDLK_CAPSLOCK.rawValue): .CAPSLOCK,
        UInt32(SDLK_CARET.rawValue): .CARET,
        UInt32(SDLK_CLEAR.rawValue): .CLEAR,
        UInt32(SDLK_CLEARAGAIN.rawValue): .CLEARAGAIN,
        UInt32(SDLK_COLON.rawValue): .COLON,
        UInt32(SDLK_COMMA.rawValue): .COMMA,
        UInt32(SDLK_COMPUTER.rawValue): .COMPUTER,
        UInt32(SDLK_COPY.rawValue): .COPY,
        UInt32(SDLK_CRSEL.rawValue): .CRSEL,
        UInt32(SDLK_CURRENCYSUBUNIT.rawValue): .CURRENCYSUBUNIT,
        UInt32(SDLK_CURRENCYUNIT.rawValue): .CURRENCYUNIT,
        UInt32(SDLK_CUT.rawValue): .CUT,
        UInt32(SDLK_DECIMALSEPARATOR.rawValue): .DECIMALSEPARATOR,
        UInt32(SDLK_DELETE.rawValue): .DELETE,
        UInt32(SDLK_DISPLAYSWITCH.rawValue): .DISPLAYSWITCH,
        UInt32(SDLK_DOLLAR.rawValue): .DOLLAR,
        UInt32(SDLK_DOWN.rawValue): .DOWN,
        UInt32(SDLK_EJECT.rawValue): .EJECT,
        UInt32(SDLK_END.rawValue): .END,
        UInt32(SDLK_EQUALS.rawValue): .EQUALS,
        UInt32(SDLK_ESCAPE.rawValue): .ESCAPE,
        UInt32(SDLK_EXCLAIM.rawValue): .EXCLAIM,
        UInt32(SDLK_EXECUTE.rawValue): .EXECUTE,
        UInt32(SDLK_EXSEL.rawValue): .EXSEL,
        UInt32(SDLK_F10.rawValue): .F10,
        UInt32(SDLK_F11.rawValue): .F11,
        UInt32(SDLK_F12.rawValue): .F12,
        UInt32(SDLK_F13.rawValue): .F13,
        UInt32(SDLK_F14.rawValue): .F14,
        UInt32(SDLK_F15.rawValue): .F15,
        UInt32(SDLK_F16.rawValue): .F16,
        UInt32(SDLK_F17.rawValue): .F17,
        UInt32(SDLK_F18.rawValue): .F18,
        UInt32(SDLK_F19.rawValue): .F19,
        UInt32(SDLK_F1.rawValue): .F1,
        UInt32(SDLK_F20.rawValue): .F20,
        UInt32(SDLK_F21.rawValue): .F21,
        UInt32(SDLK_F22.rawValue): .F22,
        UInt32(SDLK_F23.rawValue): .F23,
        UInt32(SDLK_F24.rawValue): .F24,
        UInt32(SDLK_F2.rawValue): .F2,
        UInt32(SDLK_F3.rawValue): .F3,
        UInt32(SDLK_F4.rawValue): .F4,
        UInt32(SDLK_F5.rawValue): .F5,
        UInt32(SDLK_F6.rawValue): .F6,
        UInt32(SDLK_F7.rawValue): .F7,
        UInt32(SDLK_F8.rawValue): .F8,
        UInt32(SDLK_F9.rawValue): .F9,
        UInt32(SDLK_FIND.rawValue): .FIND,
        UInt32(SDLK_GREATER.rawValue): .GREATER,
        UInt32(SDLK_HASH.rawValue): .HASH,
        UInt32(SDLK_HELP.rawValue): .HELP,
        UInt32(SDLK_HOME.rawValue): .HOME,
        UInt32(SDLK_INSERT.rawValue): .INSERT,
        UInt32(SDLK_KBDILLUMDOWN.rawValue): .KBDILLUMDOWN,
        UInt32(SDLK_KBDILLUMTOGGLE.rawValue): .KBDILLUMTOGGLE,
        UInt32(SDLK_KBDILLUMUP.rawValue): .KBDILLUMUP,
        UInt32(SDLK_KP_000.rawValue): .KP_000,
        UInt32(SDLK_KP_00.rawValue): .KP_00,
        UInt32(SDLK_KP_0.rawValue): .KP_0,
        UInt32(SDLK_KP_1.rawValue): .KP_1,
        UInt32(SDLK_KP_2.rawValue): .KP_2,
        UInt32(SDLK_KP_3.rawValue): .KP_3,
        UInt32(SDLK_KP_4.rawValue): .KP_4,
        UInt32(SDLK_KP_5.rawValue): .KP_5,
        UInt32(SDLK_KP_6.rawValue): .KP_6,
        UInt32(SDLK_KP_7.rawValue): .KP_7,
        UInt32(SDLK_KP_8.rawValue): .KP_8,
        UInt32(SDLK_KP_9.rawValue): .KP_9,
        UInt32(SDLK_KP_A.rawValue): .KP_A,
        UInt32(SDLK_KP_AMPERSAND.rawValue): .KP_AMPERSAND,
        UInt32(SDLK_KP_AT.rawValue): .KP_AT,
        UInt32(SDLK_KP_B.rawValue): .KP_B,
        UInt32(SDLK_KP_BACKSPACE.rawValue): .KP_BACKSPACE,
        UInt32(SDLK_KP_BINARY.rawValue): .KP_BINARY,
        UInt32(SDLK_KP_C.rawValue): .KP_C,
        UInt32(SDLK_KP_CLEAR.rawValue): .KP_CLEAR,
        UInt32(SDLK_KP_CLEARENTRY.rawValue): .KP_CLEARENTRY,
        UInt32(SDLK_KP_COLON.rawValue): .KP_COLON,
        UInt32(SDLK_KP_COMMA.rawValue): .KP_COMMA,
        UInt32(SDLK_KP_D.rawValue): .KP_D,
        UInt32(SDLK_KP_DBLAMPERSAND.rawValue): .KP_DBLAMPERSAND,
        UInt32(SDLK_KP_DBLVERTICALBAR.rawValue): .KP_DBLVERTICALBAR,
        UInt32(SDLK_KP_DECIMAL.rawValue): .KP_DECIMAL,
        UInt32(SDLK_KP_DIVIDE.rawValue): .KP_DIVIDE,
        UInt32(SDLK_KP_E.rawValue): .KP_E,
        UInt32(SDLK_KP_ENTER.rawValue): .KP_ENTER,
        UInt32(SDLK_KP_EQUALS.rawValue): .KP_EQUALS,
        UInt32(SDLK_KP_EQUALSAS400.rawValue): .KP_EQUALSAS400,
        UInt32(SDLK_KP_EXCLAM.rawValue): .KP_EXCLAM,
        UInt32(SDLK_KP_F.rawValue): .KP_F,
        UInt32(SDLK_KP_GREATER.rawValue): .KP_GREATER,
        UInt32(SDLK_KP_HASH.rawValue): .KP_HASH,
        UInt32(SDLK_KP_HEXADECIMAL.rawValue): .KP_HEXADECIMAL,
        UInt32(SDLK_KP_LEFTBRACE.rawValue): .KP_LEFTBRACE,
        UInt32(SDLK_KP_LEFTPAREN.rawValue): .KP_LEFTPAREN,
        UInt32(SDLK_KP_LESS.rawValue): .KP_LESS,
        UInt32(SDLK_KP_MEMADD.rawValue): .KP_MEMADD,
        UInt32(SDLK_KP_MEMCLEAR.rawValue): .KP_MEMCLEAR,
        UInt32(SDLK_KP_MEMDIVIDE.rawValue): .KP_MEMDIVIDE,
        UInt32(SDLK_KP_MEMMULTIPLY.rawValue): .KP_MEMMULTIPLY,
        UInt32(SDLK_KP_MEMRECALL.rawValue): .KP_MEMRECALL,
        UInt32(SDLK_KP_MEMSTORE.rawValue): .KP_MEMSTORE,
        UInt32(SDLK_KP_MEMSUBTRACT.rawValue): .KP_MEMSUBTRACT,
        UInt32(SDLK_KP_MINUS.rawValue): .KP_MINUS,
        UInt32(SDLK_KP_MULTIPLY.rawValue): .KP_MULTIPLY,
        UInt32(SDLK_KP_OCTAL.rawValue): .KP_OCTAL,
        UInt32(SDLK_KP_PERCENT.rawValue): .KP_PERCENT,
        UInt32(SDLK_KP_PERIOD.rawValue): .KP_PERIOD,
        UInt32(SDLK_KP_PLUS.rawValue): .KP_PLUS,
        UInt32(SDLK_KP_PLUSMINUS.rawValue): .KP_PLUSMINUS,
        UInt32(SDLK_KP_POWER.rawValue): .KP_POWER,
        UInt32(SDLK_KP_RIGHTBRACE.rawValue): .KP_RIGHTBRACE,
        UInt32(SDLK_KP_RIGHTPAREN.rawValue): .KP_RIGHTPAREN,
        UInt32(SDLK_KP_SPACE.rawValue): .KP_SPACE,
        UInt32(SDLK_KP_TAB.rawValue): .KP_TAB,
        UInt32(SDLK_KP_VERTICALBAR.rawValue): .KP_VERTICALBAR,
        UInt32(SDLK_KP_XOR.rawValue): .KP_XOR,
        UInt32(SDLK_LALT.rawValue): .LALT,
        UInt32(SDLK_LCTRL.rawValue): .LCTRL,
        UInt32(SDLK_LEFT.rawValue): .LEFT,
        UInt32(SDLK_LEFTBRACKET.rawValue): .LEFTBRACKET,
        UInt32(SDLK_LEFTPAREN.rawValue): .LEFTPAREN,
        UInt32(SDLK_LESS.rawValue): .LESS,
        UInt32(SDLK_LGUI.rawValue): .LGUI,
        UInt32(SDLK_LSHIFT.rawValue): .LSHIFT,
        UInt32(SDLK_MAIL.rawValue): .MAIL,
        UInt32(SDLK_MEDIASELECT.rawValue): .MEDIASELECT,
        UInt32(SDLK_MENU.rawValue): .MENU,
        UInt32(SDLK_MINUS.rawValue): .MINUS,
        UInt32(SDLK_MODE.rawValue): .MODE,
        UInt32(SDLK_MUTE.rawValue): .MUTE,
        UInt32(SDLK_NUMLOCKCLEAR.rawValue): .NUMLOCKCLEAR,
        UInt32(SDLK_OPER.rawValue): .OPER,
        UInt32(SDLK_OUT.rawValue): .OUT,
        UInt32(SDLK_PAGEDOWN.rawValue): .PAGEDOWN,
        UInt32(SDLK_PAGEUP.rawValue): .PAGEUP,
        UInt32(SDLK_PASTE.rawValue): .PASTE,
        UInt32(SDLK_PAUSE.rawValue): .PAUSE,
        UInt32(SDLK_PERCENT.rawValue): .PERCENT,
        UInt32(SDLK_PERIOD.rawValue): .PERIOD,
        UInt32(SDLK_PLUS.rawValue): .PLUS,
        UInt32(SDLK_POWER.rawValue): .POWER,
        UInt32(SDLK_PRINTSCREEN.rawValue): .PRINTSCREEN,
        UInt32(SDLK_PRIOR.rawValue): .PRIOR,
        UInt32(SDLK_QUESTION.rawValue): .QUESTION,
        UInt32(SDLK_QUOTE.rawValue): .QUOTE,
        UInt32(SDLK_QUOTEDBL.rawValue): .QUOTEDBL,
        UInt32(SDLK_RALT.rawValue): .RALT,
        UInt32(SDLK_RCTRL.rawValue): .RCTRL,
        UInt32(SDLK_RETURN2.rawValue): .RETURN2,
        UInt32(SDLK_RETURN.rawValue): .RETURN,
        UInt32(SDLK_RGUI.rawValue): .RGUI,
        UInt32(SDLK_RIGHT.rawValue): .RIGHT,
        UInt32(SDLK_RIGHTBRACKET.rawValue): .RIGHTBRACKET,
        UInt32(SDLK_RIGHTPAREN.rawValue): .RIGHTPAREN,
        UInt32(SDLK_RSHIFT.rawValue): .RSHIFT,
        UInt32(SDLK_SCROLLLOCK.rawValue): .SCROLLLOCK,
        UInt32(SDLK_SELECT.rawValue): .SELECT,
        UInt32(SDLK_SEMICOLON.rawValue): .SEMICOLON,
        UInt32(SDLK_SEPARATOR.rawValue): .SEPARATOR,
        UInt32(SDLK_SLASH.rawValue): .SLASH,
        UInt32(SDLK_SLEEP.rawValue): .SLEEP,
        UInt32(SDLK_SPACE.rawValue): .SPACE,
        UInt32(SDLK_STOP.rawValue): .STOP,
        UInt32(SDLK_SYSREQ.rawValue): .SYSREQ,
        UInt32(SDLK_TAB.rawValue): .TAB,
        UInt32(SDLK_THOUSANDSSEPARATOR.rawValue): .THOUSANDSSEPARATOR,
        UInt32(SDLK_UNDERSCORE.rawValue): .UNDERSCORE,
        UInt32(SDLK_UNDO.rawValue): .UNDO,
        UInt32(SDLK_UNKNOWN.rawValue): .UNKNOWN,
        UInt32(SDLK_UP.rawValue): .UP,
        UInt32(SDLK_VOLUMEDOWN.rawValue): .VOLUMEDOWN,
        UInt32(SDLK_VOLUMEUP.rawValue): .VOLUMEUP,
        UInt32(SDLK_WWW.rawValue): .WWW,
        UInt32(SDLK_a.rawValue): .A,
        UInt32(SDLK_b.rawValue): .B,
        UInt32(SDLK_c.rawValue): .C,
        UInt32(SDLK_d.rawValue): .D,
        UInt32(SDLK_e.rawValue): .E,
        UInt32(SDLK_f.rawValue): .F,
        UInt32(SDLK_g.rawValue): .G,
        UInt32(SDLK_h.rawValue): .H,
        UInt32(SDLK_i.rawValue): .I,
        UInt32(SDLK_j.rawValue): .J,
        UInt32(SDLK_k.rawValue): .K,
        UInt32(SDLK_l.rawValue): .L,
        UInt32(SDLK_m.rawValue): .M,
        UInt32(SDLK_n.rawValue): .N,
        UInt32(SDLK_o.rawValue): .O,
        UInt32(SDLK_p.rawValue): .P,
        UInt32(SDLK_q.rawValue): .Q,
        UInt32(SDLK_r.rawValue): .R,
        UInt32(SDLK_s.rawValue): .S,
        UInt32(SDLK_t.rawValue): .T,
        UInt32(SDLK_u.rawValue): .U,
        UInt32(SDLK_v.rawValue): .V,
        UInt32(SDLK_w.rawValue): .W,
        UInt32(SDLK_x.rawValue): .X,
        UInt32(SDLK_y.rawValue): .Y,
        UInt32(SDLK_z.rawValue): .Z,
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
