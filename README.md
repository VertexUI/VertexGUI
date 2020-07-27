# Swift cross-platform GUI Application demo

This demo application runs on Linux and MacOS. A Swift version of at least 5.3 is required.

[SDL2 needs to be installed](https://wiki.libsdl.org/Installation) on your system. On ubuntu you can install it with `sudo apt-get install libsdl2-dev` and on MacOS `brew install sdl2` (Homebrew required).

To run the app execute `swift run DemoApp` in the root directory of the package.

# Architecture

The target "VisualAppBase" defines a generic API for creating windows and rendering graphics primitives. 
To support a specific configuration of OS and graphics API (OpenGL, DirectX, Metal, ...) an implementation of the generic application API has to be written.

The target "VisualAppBaseImplSDL2OpenGL3NanoVG" provides an implementation that uses [SDL2](https://www.libsdl.org/index.php) for cross-platform window and event management, OpenGL 3 as the graphical backend and [NanoVG](https://github.com/memononen/nanovg) as a simplification layer over OpenGL that provides an API similar to the HTML canvas.

The target "WidgetGUI" defines a system for describing a graphical user interface, rendering the elements, propagating and handling events. The idea is similar to [Flutter](https://flutter.dev/). Everything is a Widget. They handle layouting, events and output RenderObjects. The RenderObjects form a tree structure which is then rendered with the generic rendering API in an (hopefully at a later point) optimized way.

Currently nothing is completed, everything is written very loosely, nothing is optimized and there are bugs all over the place.

# Dependencies

This package depends on:

[SDL2](https://www.libsdl.org/index.php)

[Path: github.com/mxcl/Path.swift.git](https://github.com/mxcl/Path.swift.git)

[GL (OpenGL loader written in Swift): github.com/kelvin13/swift-opengl](https://github.com/kelvin13/swift-opengl)

[Swim (Image handling): github.com/t-ae/swim.git](https://github.com/t-ae/swim.git)

[NanoVG: github.com/memononen/nanovg](https://github.com/memononen/nanovg)

[Cnanovg (NanoVG wrapper in Swift): github.com/UnGast/Cnanovg.git](https://github.com/UnGast/Cnanovg.git)