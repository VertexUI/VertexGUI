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

<br>

## New Design

A redesign of the rendering approach is necessary because the current one is limited in speed (all classes, unnecessary rerenders) and the types of RenderObjects were created as needed without a cohesive design.

<br>

### What's the Goal?
A render pipeline that can be used for multiple frontends and with multiple backends. With on demand rerendering (only rerender the objects which changed) / caching and support for real time effects (e.g. transitions).

<br>

### First Design Thoughts
The system which uses the render objects should decide how to handle and keep as well as reuse them. The render pipeline should only care about receiving a tree of render objects which is then rendered / rasterized.

Every Widget should know it's current render graph. This includes the objects that were created by the Widget itself as well as the objects created by the children of the Widget.

When some value inside a Widget is changed and the render graph needs to be updated, the first thing to try should be to modify the existing render objects.
By doing this unnecessary allocations, deallocations can be reduced and performance increased.

Although some Widgets only output the aggregated render graph of their children, every Widget can have custom render logic. This is useful to provide effects, such as opacity, translations of a whole sub tree etc.

<br>

### How to Update Values in Render Objects?
Implementing the updating of render objects could be done by using reactive properties for render object values. These could simply be defined as computed properties during the instantiation of a render object. They would get destroyed together with the render object.<br>
What are the advantages of using properties?
- they update automatically, always have the latest value
- they are specific to that render object instance, and are deleted when it is destroyed, so no special care needs to be taken by the Widget
- the logic for generating the values is close to the render object that needs it

Would there be any downsides to using properties?
- they do not only update during a specific render call, but whenever their dependencies change

<br>

### How would updating the rasterized output work with the property approach?<br>
Every render object would take in some kind of reactive property, probably a computed property and then assign onChanged handlers to it. Since all the render objects are defined by the framework, all the work is done by the framework developer and the user will not create bugs by forgetting to register the handlers.
Each render object sets a flag on itself to indicate that it needs to be rasterized again. And probably emit this information over a bus so that the rasterization logic and caching etc. can be handled at the root level.
Another approach would be to only set the flag and then on every frame go through the render graph and look for objects that need to be rasterized again. This would generate fewer calls between frames (because no bus) and probably remove the need for sharing a context between objects as well. However a context might become necessary for other logic and then a bus could be added as well.

If a render object is marked for rerasterization, do it's children need to be rasterized as well? Or can their rasterizations be used again?

Go through it by example:

There is a Widget which outputs a render object that transforms all of it's children (e.g. applies a translation).
So this render object does not even output any content at rasterization. And if the transformation changes, the children's output may or may not change (translation will only change the location, scale will change the output).
Maybe the transform values should be forwarded to every child render object and then it needs to be decided in accordance with transforms lower in the tree whether a certain sub tree must be rasterized again or not (there might be transforms cancelling each other out).
However transforms cancelling each other out is probably not a very common scenario.
Also in most cases the children of the translation render object will probably not be cached because it's too small of a sub tree. But if there is something that is cached, it would save performance to apply that transformation to the cached rasterization.
**to find out how to do this, it would be necessary to think about how each individual render object is rasterized**

**how could cached rasterizations be transformed if a transform somewhere up the tree is changed?**

**maybe the widget tree itself should be rendered, e.g. by applying certain properties to Widgets that indicate renderable-ness?**

**That would probably mean that children need to be rasterized as well again. This needs to be examined.**

**how to implement caching**

**should render objects receive their own fill values etc. or should they be inherited?**

**how to handle the checking of which relevant property changed and which render objects need to be changed use Reactive Properties?**
**how to access the render objects that need to be modified? scoping? references (like for Widgets?) or simply by making assumptions and using indexing of the children and casting?**
**how to handle transitions**

**how to handle input recording --> mouse and forwarding it to the correct widget?**

**how to handle mouse cursor updates?**

<br>

### Which Render Objects are Needed?
