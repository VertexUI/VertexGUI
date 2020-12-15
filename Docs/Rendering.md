# Rendering

This document serves as a reference for implementing rendering logic. It will later serve as documentation.

## Pipeline

    some high level api

            =>

    tree of render objects

            =>

    render object tree renderer

            =>

    (optional) abstraction over a graphics api

            =>

    some graphics api



- no matter what the high level api is: Widgets, a game with manually layouted labels, a really basic UI System, ..., they all output RenderObjects 
- these RenderObjects form a tree structure
- an implementation of a RenderObjectTreeRenderer (for a specific system, backend ...), renders the whole tree
- this can be done with an abstraction layer over a graphics api (e.g. NanoVG is an abstraction over OpenGL and others) or by calling a graphics api directly

## Graphics API Abstraction Options

### OpenGL and NanoVG

- advantages:
  - basic shapes and pretty advanced text handling
  - cross-platform
  - can write new backends for NanoVG (some already exist, e.g. DirectX)
  - probably quite fast, written in C
- disadvantages
  - not optimized for the specific RenderObjects
  => can't send a RenderObject into an OpenGL buffer directly
  - lacks some functions, e.g. displaying video efficiently
  - need to manually extend it (written in C => relatively much effort) or catch these cases in Swift and provide a Swift implementation => reduces the effect of having different backends available for NanoVG

### Cairo, Skia, etc.
- need to look into those, Flutter uses Skia, so this might be a good option

### Custom Rendering Abstraction
- advantages:
  - optimization for specific RenderObjects in combination with an underlying graphics API is possible
  - all in Swift => easily extensible
- disadvantages:
  - A LOT of work to support all kinds of systems and graphics apis
  - requires a lot of manual testing, because can't assume that the abstraction has been field tested already
  - could be slower than the popular choices, because a lot of engineering has probably gone into those already