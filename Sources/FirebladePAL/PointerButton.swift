//
// PointerButton.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

public enum PointerButton: Equatable {
    case left, middle, right
    case other(_ buttonNumber: Int)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .left:
            return rhs == .left
        case .middle:
            return rhs == .middle
        case .right:
            return rhs == .right
        case let .other(lhsButtonNumber):
            if case let .other(rhsButtonNumber) = rhs {
                return lhsButtonNumber == rhsButtonNumber
            }
            return false
        }
    }
}
