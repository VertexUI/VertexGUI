//
// SDLVLKWindowSurface.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL && FRB_GRAPHICS_VULKAN

import FirebladeMath
import Vulkan

// keep this implementation only since we do NOT want to leak SDL implementation details out if the HID package
@_implementationOnly import SDL2
import Vulkan

open class SDLVLKWindowSurface: SDLWindowSurface, VLKWindowSurfaceBase {
    public enum Error: Swift.Error {
        case vkInstanceCreationFailed(VkResult)
    }

    public static let sdlFlags: UInt32 = SDL_WINDOW_VULKAN.rawValue

    public let surface: VkSurfaceKHR
    public let instance: VkInstance
    public unowned var window: SDLWindow

    public required init(in window: Window, instance: VkInstance) throws {
        var surfaceOpt: VkSurfaceKHR?
        guard SDL_Vulkan_CreateSurface(window._window, instance, &surfaceOpt) == SDL_TRUE, let surface = surfaceOpt else {
            throw SDLError()
        }
        self.surface = surface
        self.window = window
        self.instance = instance
    }

    public static func create(in window: Window) throws -> Self {
        let instance = try Self.createInstance()
        return try Self(in: window, instance: instance)
    }

    open func destroy() {
        vkDestroySurfaceKHR(instance, surface, nil)
    }

    open func getDrawableSize() -> Size<Int> {
        var width: Int32 = 0
        var height: Int32 = 0
        SDL_Vulkan_GetDrawableSize(window._window, &width, &height)
        return Size(width: Int(width),
                    height: Int(height))
    }

    public var enableVsync: Bool {
        get {
            #warning("TODO: implement vsync")
            return false
        }

        set {
            #warning("TODO: implement vsync")
            // <https://www.khronos.org/registry/vulkan/specs/1.2-extensions/man/html/VkPresentModeKHR.html>
            // vsync off
            // VK_PRESENT_MODE_IMMEDIATE_KHR

            // vsync on
            // VK_PRESENT_MODE_MAILBOX_KHR
            // VK_PRESENT_MODE_FIFO_KHR
            // VK_PRESENT_MODE_FIFO_RELAXED_KHR
        }
    }

    open class func loadLibrary(_ path: String? = nil) {
        SDL_Vulkan_LoadLibrary(path)
    }

    open class func getRequiredInstanceExtensionNames() -> [String] {
        var pCount = UInt32(0)
        SDL_Vulkan_GetInstanceExtensions(nil, &pCount, nil)

        let extNames = [String](unsafeUninitializedCapacity: pCount) { buffer, written in
            guard SDL_Vulkan_GetInstanceExtensions(nil, &pCount, buffer) == SDL_TRUE else {
                return
            }
            written = Int(pCount)
        }

        return extNames
    }

    open class func createInstance() throws -> VkInstance {
        let enabledLayerNames: [String] = {
            #if DEBUG
            return ["VK_LAYER_KHRONOS_validation"]
            #else
            return []
            #endif
        }()

        let enabledExtensionNames: [String] = VLKWindowSurface.getRequiredInstanceExtensionNames()

        return try enabledLayerNames.withUnsafeCStringBufferPointer { ppEnabledLayerNames in
            try enabledExtensionNames.withUnsafeCStringBufferPointer { ppEnabledExtensionNames in
                var createInfo = VkInstanceCreateInfo(
                    sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
                    pNext: nil,
                    flags: 0,
                    pApplicationInfo: nil,
                    enabledLayerCount: UInt32(enabledLayerNames.count),
                    ppEnabledLayerNames: ppEnabledLayerNames.baseAddress,
                    enabledExtensionCount: UInt32(enabledExtensionNames.count),
                    ppEnabledExtensionNames: ppEnabledExtensionNames.baseAddress
                )

                var _instance: VkInstance?
                let result = vkCreateInstance(&createInfo, nil, &_instance)

                guard result == VK_SUCCESS, let instance = _instance else {
                    throw Error.vkInstanceCreationFailed(result)
                }

                return instance
            } // extensions names
        } // layer names
    }
}

// MARK: - C Helper

extension Array where Element == String {
    fileprivate init<I: FixedWidthInteger>(unsafeUninitializedCapacity count: I,
                                           initializingWith closure: (_ buffer: UnsafeMutablePointer<UnsafePointer<CChar>?>, _ written: inout Int) throws -> Void) rethrows
    {
        let buffer = UnsafeMutablePointer<UnsafePointer<CChar>?>.allocate(capacity: Int(count))
        defer {
            buffer.deallocate()
        }
        var written: Int = 0
        try closure(buffer, &written)

        guard written > 0 else {
            self = []
            return
        }

        self = UnsafeBufferPointer(start: buffer, count: written)
            .compactMap {
                guard let ptr = $0 else {
                    return nil
                }
                return String(cString: ptr)
            }
    }

    fileprivate func withUnsafeCStringBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafePointer<CChar>?>) throws -> R) rethrows -> R {
        func translate(_ slice: inout Self.SubSequence,
                       _ offset: inout Int,
                       _ buffer: UnsafeMutableBufferPointer<UnsafePointer<CChar>?>,
                       _ body: (UnsafeBufferPointer<UnsafePointer<CChar>?>) throws -> R) rethrows -> R
        {
            guard let string = slice.popFirst() else {
                return try body(UnsafeBufferPointer(buffer))
            }

            return try string.withCString { cStringPtr in
                buffer.baseAddress!
                    .advanced(by: offset)
                    .initialize(to: cStringPtr)
                offset += 1
                return try translate(&slice, &offset, buffer, body)
            }
        }

        var slice = self[...]
        var offset: Int = 0
        let buffer = UnsafeMutableBufferPointer<UnsafePointer<CChar>?>.allocate(capacity: count)
        defer { buffer.deallocate() }
        return try translate(&slice, &offset, buffer, body)
    }
}

#endif
