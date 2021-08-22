//
// PlatformEvents.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

protocol PlatformEvents {
    /// Pump the event loop, gathering events from the input devices.
    func pumpEvents()

    func pollEvent(_ event: inout Event) -> Bool

    // func pushEvent(_ event: Event)
}
