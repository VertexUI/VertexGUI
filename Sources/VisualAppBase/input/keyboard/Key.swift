/// representing keys on a standard american keyboard
/// which means: Key.LY will represent the Key that gives the letter z on german keyboards
/// prefix N for number keys, e.g. N0 --> 0
/// prefix L for letter keys, e.g. LB --> B
public enum Key: CaseIterable {
    case ArrowTop,ArrowRight, ArrowDown, ArrowLeft
    case N0, N1, N2, N3, N4, N5, N6, N7, N8, N9
    case LA, LB, LC, LD, LE, LF, LG, LH, LI, LJ, LK, LL, LM, LN, LO, LP, LQ, LR, LS, LT, LU, LV, LW, LX, LY, LZ
    case Esc
}