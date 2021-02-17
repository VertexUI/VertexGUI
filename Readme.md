# SwiftGUI

![build-ubuntu](https://github.com/ungast/swift-gui/workflows/build-ubuntu/badge.svg)
![build-macos](https://github.com/ungast/swift-gui/workflows/build-macos/badge.svg)

SwiftGUI is a Swift framework for writing cross-platform GUI applications.

## Demo

<img alt="screenshot of demo app" src="Docs/demo.png?raw=true"/>

Currently Linux and MacOS are supported. To run the demo application, you need a [Swift 5.3 toolchain](https://swift.org/download/#releases), [the SDL2 library](https://wiki.libsdl.org/Installation) and OpenGL 3 headers must be present on your system.

Installing SDL2 on Ubuntu:

    sudo apt-get install libsdl2-dev

Installing SDL2 on MacOS ([Homebrew](https://brew.sh/) required):

    brew install sdl2 

When the requirements are met, clone this repo and from it's root directory run:
 
    swift run TaskOrganizerDemo

<br>

## **NOTE**: I'm currently redesigning a large part of the framework and most examples are outdated, most widgets are not yet updated to the new api design

<br>

I estimate that around mid-March the framework will be in a more usable state.

<br>

## Use

I do not recommend using the library for applications that need to be useful for now. There is a lot to be improved and optimized which will lead to API changes breaking your application.

To get a sense for the syntax, here is a minimal example to create the following GUI:

<img alt="screenshot of minimal demo app" src="Docs/minimal_demo.png?raw=true" width="200"/>

    import SwiftGUI

    public class MainView: SingleChildWidget {
      @MutableProperty
      private var counter = 0

      override public func buildChild() -> Widget {
        Center { [unowned self] in
          Button {
            ObservingBuilder($counter) {
              Text("Hello world \(counter)")
            }
          } onClick: { _ in
            counter += 1
          }
        }
      }
    }

When the button is pressed, the counter after "hello world" should be incremented.
There is some more wrapper code involved in displaying the GUI. You can find all of it in [Sources/MinimalDemo](Sources/MinimalDemo)

A more detailed example in the form of a simple task organizer app can be found in [Sources/TaskOrganizerDemo](Sources/TaskOrganizerDemo)

## Why?

Swift is a great language I enjoy to write because it is quite concise and clear. It seems to facilitate getting work done. The use of libraries like SwiftUI is however limited to Apple platforms. Enabling GUI development on other platforms could be an important addition to the Swift ecosystem.

<br>

Additionally there could be some interesting applications of [Swift for Tensorflow](https://github.com/tensorflow/swift) in the future. Maybe deep learning techniques can be included in applications to automate workflows by learning from the user.

## Comparison with other frameworks

- SwiftGUI provides a declarative way for defining user interfaces like SwiftUI, Flutter, Qt's QML and VueJS do
- in comparison with SwiftUI, SwiftGUI's components are heavier and provide more flexibility to the developer to adjust the functionality, style and rendering output
- Qt uses two languages, C++ and QML (with Javascript), with Swift this is not necessary since there are ways to represent tree structures that define the UI in a concise way with [result builders](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md)

## Concepts

<br>

**OUTDATED**

<br>

- RenderObject
  - organized as a tree structure
  - leaf RenderObjects: e.g. Text, Rectangle, Path, describe a specific drawable thing
  - branch RenderObjects: e.g. Cachable, RenderStyle, Translation, provide information (also meta information) about multiple children
  - RenderObjects are rendered by a rendering backend, which can be swapped out to support different environments the application needs to run in, for example an OpenGL capable environment and an environment where the rendering needs to be done in software
- Widget
  - organized as a tree strucure
  - are UI components that handle layout, interaction and output a RenderObject tree
  - a Widget can ouput actually paintable RenderObjects or wrap it's children's RenderObjects and translate them or discard them or whatever

## Current state

- runs on Linux (tested on Ubuntu 20.04) and MacOS (tested on MacOS 10.15)
- depends on SDL2 for handling cross platform window management
- depends on NanoVG (specifically on the OpenGL 3.3 implementation of NanoVG) for rendering graphics primitives
- rendering happens when something in the application changes or a transition is active, the application is rendered as a whole which is not optimal for performance
- animations, transitions are not yet well supported
- state mangement was only taken as far as necessary to make the organizer demo app possible

## Roadmap

- might find a better name for the framework
- find better names for all the components of the framework
- platforms:
  - add windows support, SDL2 supports windows, so it should be possible with a managable amount of work
  - work on other platforms after the API is somewhat more stable
- Widgets:
  - styling, maybe in the form of selector based stylesheets, theming, different themes in different parts of application, switchable themes, reactive styles
  - support complex animations, moving widgets around, fading them in and out, find out which kinds of properties need to and can be animated and how to do it in a performant manner
  - improve performance by running build, layout, render first for top level parents and then go down the tree
  - reimplement retaining state
- rendering:
  - improve the rendering backend api, provide a clear and concise api for rendering graphics primitives by calling functions, similar to HTML canvas and NanoVG
  - improve the RenderObject api, which types of RenderObjects are necessary?
  - support different types of fills for RenderObjects, such as pure color, gradients, images, patterns
  - implement optimized rendering, only render if something changed and only the area that changed, need an algorithm to split the RenderObject tree into different chunks to balance the frequency of rerendering and the amount of rerendering that needs to be done
  - find some solution to support environments without OpenGL 3.3, maybe switch the rendering backend to something other than NanoVG in order to get software rendering
  - support loading fonts dynamically from the host system by their specified name
-misc:
  - replace the custom Vector types with Swift's SIMD types
  - write tests

## Contribute

You can contribute by suggesting features, implementing demo apps which show where improvements are necessary, reporting bugs and creating pull requests for the features you want to see.

## Dependencies

This package depends on:

[SDL2](https://www.libsdl.org/index.php)

[NanoVG: github.com/memononen/nanovg](https://github.com/memononen/nanovg)

[GL (OpenGL loader written in Swift): github.com/kelvin13/swift-opengl](https://github.com/kelvin13/swift-opengl)

[Path: github.com/mxcl/Path.swift.git](https://github.com/mxcl/Path.swift.git)

[Swim (Image handling): github.com/t-ae/swim.git](https://github.com/t-ae/swim.git)

[Cnanovg (NanoVG wrapper in Swift): github.com/UnGast/Cnanovg.git](https://github.com/UnGast/Cnanovg.git)
