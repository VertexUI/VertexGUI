//
// PlatformInitialization.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

protocol PlatformInitialization {
    static func initialize()
    static var version: String { get }
    static func quit()
}
