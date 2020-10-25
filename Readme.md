# Write cross platform GUI applications in Swift

With [NAME] I'm trying to build a framework for creating complex and stylable GUI applications that support all platforms Swift can be compiled for. For now, only MacOS and Linux are actually implemented and your system needs to be capable of OpenGL 3.3.

# Demo

To run a demo application, you need a Swift 5.3 toolchain and [SDL2 needs to be installed](https://wiki.libsdl.org/Installation) on your system. On Ubuntu you can install it with `sudo apt-get install libsdl2-dev` and on MacOS `brew install sdl2` (Homebrew required). 
When the requirements are met, clone this repo and from the root directory of the downloaded repo run:

  swift run DemoGUIApp

You should see something similar to this:

![screenshot of demo app](/Docs/demo.png?raw=true)

# Use

I do not recommend using the library for actual applications as of now. There is a lot to be improved and optimized which will lead to api changes breaking your application again and again.

To get a sense for the syntax, here is a minimal example to create the following GUI:

![screenshot of minimal demo app](/Docs/minimal_demo.png?raw=true)

    import WidgetGUI

    public class MainView: SingleChildWidget {
      @MutableProperty
      private var counter = 0

      override public func buildChild() -> Widget {
        ObservingBuilder($counter) { [unowned self] in
          Center {
            Button {
              Text("Hello world \(counter)")
            } onClick: { _ in
              counter += 1
            }
          }
        }
      }
    }

Press the button to increment the counter after the "Hello world".
There is some more wrapper code involved in displaying the GUI. You can find all of it in Sources/MinimalDemo

A more detailed example in the form of a simple task organizer app can be found in Sources/DemoGUIApp

# Why?

Swift is a great language I enjoy to write because it seems like I get work done. It is useful for creating GUIs as shown by it's use on Apple's systems. However Apple's UI frameworks like SwiftUI are proprietary and not available on other platforms. An open-source solution is needed. Additionally there seem to be some interesting opportunities with [Swift for Tensorflow](https://github.com/tensorflow/swift). Maybe deep learning techniques can be implemented into end user applications in an effective way with Swift.

# Comparison with other frameworks

- [NAME] provides a declarative way of defining the user interface like SwiftUI, Flutter, Qt's QML and VueJS do
- in comparison with SwiftUI, [Name]'s components are heavier and provide more flexibility to the developer to create custom components
- Qt uses two languages, C++ and QML (with Javascript), with Swift this is not necessary since there are ways to represent tree structures that define the UI in a concise way with function builders

# Concepts

- RenderObject: organized as a tree structure
  - leaf RenderObjects: e.g. Text, Rectangle, Path, describes a specific drawable thing
  - branch RenderObjects: e.g. Cachable, RenderStyle, Translation, provides information (also meta information) about multiple children
  - RenderObjects are rendered by a rendering backend, which can be swapped out to support different environments the application needs to run in, e.g. an OpenGL capable environment and an environment where the rendering needs to be done in software
- Widget: organized as a tree strucure, UI components that handle layout, interaction and output a RenderObject tree, a Widget can ouput actually paintable RenderObjects or wrap it's children's RenderObjects and e.g. Translate them or discard them or whatever

# Current state

- runs on Linux (tested on Ubuntu 20.04) and MacOS (tested on MacOS 10.15)
- depends on SDL2 for handling cross platform window management
- depends on NanoVG for rendering graphics primitives, specifically on the OpenGL 3.3 implementation of NanoVG
- rendering happens when something in the application changes or a transition is active, the application is rendered as a whole which is not optimal for performance

# Roadmap

- find better names for all the components of the framework
- platforms:
  - add windows support, SDL2 supports windows, so it should be possible with a managable amount of work
  - work on other platforms after the API is somewhat more stable
- Widgets:
  - styling, maybe in the form of selector based stylesheets, theming, different themes in different parts of application, switchable themes, styles must be reactive
  - support complex animations, moving widgets around, fading them in and out, find out which kinds of properties need to and can be animated and how to do it in a performant manner
- rendering:
  - improve the rendering backend api, provide a clear and concise api for rendering graphics primitives by calling functions, similar to HTML canvas and NanoVG
  - improve the RenderObject api, which types of RenderObjects are necessary
  - support different types of fills for RenderObjects, such as pure color, gradients, images, patterns
  - implement optimized rendering, only render if something changed and only the area that changed, need an algorithm to split the RenderObject tree into different chunks for balance between frequency of rerendering and amount of rerendering that needs to be done
  - find some solution to support environments without OpenGL 3.3, maybe switch the rendering backend to something other than NanoVG in order to get software rendering
  - support loading fonts dynamically from the host system by their specified name

# Contribute

You can contribute e.g. by suggesting features, api styles or implementing demo apps for specific use cases, reporting bugs and creating pull requests for the features you want to see.

# Dependencies

This package depends on:

[SDL2](https://www.libsdl.org/index.php)

[Path: github.com/mxcl/Path.swift.git](https://github.com/mxcl/Path.swift.git)

[GL (OpenGL loader written in Swift): github.com/kelvin13/swift-opengl](https://github.com/kelvin13/swift-opengl)

[Swim (Image handling): github.com/t-ae/swim.git](https://github.com/t-ae/swim.git)

[NanoVG: github.com/memononen/nanovg](https://github.com/memononen/nanovg)

[Cnanovg (NanoVG wrapper in Swift): github.com/UnGast/Cnanovg.git](https://github.com/UnGast/Cnanovg.git)