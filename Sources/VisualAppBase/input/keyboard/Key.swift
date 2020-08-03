/// representing keys on a standard american keyboard
/// which means: Key.LY will represent the Key that gives the letter z on german keyboards
/// prefix N for number keys, e.g. N0 --> 0
/// prefix L for letter keys, e.g. LB --> B
public enum Key: CaseIterable {
    case ArrowUp,ArrowRight, ArrowDown, ArrowLeft
    case N0, N1, N2, N3, N4, N5, N6, N7, N8, N9
    case LA, LB, LC, LD, LE, LF, LG, LH, LI, LJ, LK, LL, LM, LN, LO, LP, LQ, LR, LS, LT, LU, LV, LW, LX, LY, LZ
    case F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12
    case Esc
}