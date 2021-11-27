/// representing keys on a standard american keyboard
/// which means: Key.y will represent the Key that gives the letter z on german keyboards
/// prefix _ for number keys, e.g. 0 --> _0
public enum Key: CaseIterable {

    /*case ArrowUp, ArrowRight, ArrowDown, ArrowLeft

    case Return, Enter, Backspace, Delete, Space, Escape

    case LeftShift, LeftCtrl, LeftAlt

    case Plus, Minus

    case N0, N1, N2, N3, N4, N5, N6, N7, N8, N9
    
    case A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z

    case F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12*/

    case arrowUp, arrowRight, arrowDown, arrowLeft
    case leftCtrl, rightCtrl, leftGui, rightGui
    case `return`, enter, backspace, delete, space, escape
    case _0, _1, _2, _3, _4, _5, _6, _7, _8, _9
    case plus, minus
    case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
    case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12
}