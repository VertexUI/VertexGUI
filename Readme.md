# Write cross platform GUI applications in Swift

With [NAME] I'm trying to build a framework for creating complex and stylable GUI applications that support all platforms Swift can be compiled for. For now, only MacOS and Linux are actually implemented and your system needs to be capable of OpenGL 3.3.

# Demo

To run a demo application, you need a Swift 5.3 toolchain and [SDL2 needs to be installed](https://wiki.libsdl.org/Installation) on your system. On Ubuntu you can install it with `sudo apt-get install libsdl2-dev` and on MacOS `brew install sdl2` (Homebrew required). 
When the requirements are met, clone this repo and from the root directory of the downloaded repo run:

  swift run DemoGUIApp

You should see something similar to this:

![screenshot of demo app](https://github.com/UnGast/swift-cross-platform-gui-example/tree/master/docs/demo.png)

# Concepts

- RenderObject: organized as a tree structure
  - leaf RenderObjects: e.g. Text, Rectangle, Path, describes a specific drawable thing
  - branch RenderObjects: e.g. Cachable, RenderStyle, Translation, provides information (also meta information) about multiple children
- Widget: organized as a tree strucure, UI components that handle layout, interaction and output a RenderObject tree, a Widget can ouput actually paintable RenderObjects or wrap it's children's RenderObjects and e.g. Translate them or discard them or whatever

# Current capabilities

# Roadmap

- styling, maybe in the form of selector based stylesheets, theming, different themes in different parts of application, switchable themes, styles must be reactive

# Use

I do not recommend using the library for actual applications as of now. There is a lot to be improved and optimized which will lead to api changes breaking your application again and again.

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