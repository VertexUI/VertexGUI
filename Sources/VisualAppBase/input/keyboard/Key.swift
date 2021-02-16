/// representing keys on a standard american keyboard
/// which means: Key.Y will represent the Key that gives the letter z on german keyboards
/// prefix N for number keys, e.g. N0 --> 0
public enum Key: CaseIterable {

    case ArrowUp, ArrowRight, ArrowDown, ArrowLeft

    case Return, Enter, Backspace, Delete, Space, Escape

    case LeftShift, LeftCtrl, LeftAlt

    case Plus, Minus

    case N0, N1, N2, N3, N4, N5, N6, N7, N8, N9
    
    case A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z

    case F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12
}