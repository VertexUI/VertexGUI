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
- they do not only update during a specific render call, but whenever their dependencies change, depending on how transitions are implemented this could be quite frequently
  - in most cases, the updates should however be infrequent, for example: a theme change, a new style gets applied to a Widget and changes a color property, a layout pass updates the position of a Widget

<br>

### How would updating the rasterized output work with the property approach?<br>
Every render object would take in some kind of reactive property, probably a computed property and then assign onChanged handlers to it. Since all the render objects are defined by the framework, all the work is done by the framework developer and the user will not create bugs by forgetting to register the handlers.
Each render object sets a flag on itself to indicate that it needs to be rasterized again. And probably emit this information over a bus so that the rasterization logic and caching etc. can be handled at the root level.
Another approach would be to only set the flag and then on every frame go through the render graph and look for objects that need to be rasterized again. This would generate fewer calls between frames (because no bus) and probably remove the need for sharing a context between objects as well. However a context might become necessary for other logic and then a bus could be added as well.
A different benefit of iterating the tree and searching for render objects that need rerasterization could be that that in case many changes happened to render objects (e.g. a theme change, a large style change, many positions updated), only the topmost render object that needs rasterization needs to be found in order to invoke the rasterization.
The children will then be iterated by the rasterizer. In case they are chached, by have a flag that indicates a need for rerasterization set as well, they will be rasterized.
This saves work of handling a queue and either sorting it by depth or making inefficient small updates only to then make a larger update that includes all the smaller updates to the rasterized output again.
The question is, whether there would be few rasterization requests or a lot of them and what takes more time to process. If there are only a few calls, it might be efficient to have the queue. Otherwise the whole render tree needs to be searched on every frame.
This probably means that the queue approach is going to be taken. And that the queue must then be sorted by depth and rasterization only be invoked for parents and not again for their already rerasterized children.

<br>

A solution for transitions and frequent updates to properties needs to be found.<br>
Frequent updates to reactive properties would trigger a lots of calls to handlers and the requestRasterization function.
Actually for transitions this depends on how they are implemented.<br>
If transitions are implemented in such a way that the Widget is updating a property value used by the render object on every frame, this might be inefficient. But maybe transition definitions should be the values passed to render objects.
A transition definition would probably include a start and end time, maybe no end time if it is going on indefinitely and a function to calculate the current value based on the difference of the current time to the start time.
Such a transition definition would be set as a property value by the Widget managing the render object.
The transition might be defined by styles. In that case the Widget would probably register handlers on the resolved styles to find out whether any transition is going. And then transform this transition in a way that it can be passed to the render object.<br>
This means that render object properties need to accept multiple types of values. Either the value directly or a transition definition for the value.
If the render object notices that the value of a property changed and the new value is a transition it should signal that it needs to be rasterized on each frame until the transition ends.
The value that the rasterizer accesses on the render object on each frame should then always be the current transition value, given by the function and the current time.<br>
This could be implemented by either letting the rasterizer call a tick function on each render object before rasterizing it, providing a time delta. This could be beneficial to modify the perception of time for certain render objects but would include an additional function call.
The render object could as well provide the value with a get function that takes a time value.
Probably the most convenient solution would be to have property wrappers for render objects which calculate the current value when it's accessed based on the type of internal value that was provided to the wrapper.<br>
Stopping the transition and signaling that rasterization on every frame is not necessary any more could be achieved by using dispatch, checking the time in a tick method, or registering a timer through the context of the render object.<br>
Actually this is necessary for starting as well. Since the start time of a given transition might be in the future. The value before the start time is reached is then the value at time 0. Until the start time is reached, the render object should not be rasterized on every frame.<br>
The approach being used will probably be that each render object which notices that is has a transition value will register a handler by calling onTick on it's context and providing a value like executeAfter: absolute time value of start. The onTick handlers are processed by the rendering pipeline which receives it's ticks from the system.
All times that are specified should be in terms of times of the frameworks internal time. Probably measured from the initialization of the framework.
So the Widgets which provide the transition values also need to use that.

<br>

Go through it by example:

There is a Widget which outputs a render object that transforms all of it's children (e.g. applies a translation).
So this render object does not even output any content at rasterization. And if the transformation changes, the children's output may or may not change (translation will only change the location, scale will change the output).
Maybe the transform values should be forwarded to every child render object and then it needs to be decided in accordance with transforms lower in the tree whether a certain sub tree must be rasterized again or not (there might be transforms cancelling each other out).
However transforms cancelling each other out is probably not a very common scenario.
Also in most cases the children of the translation render object will probably not be cached because it's too small of a sub tree. But if there is something that is cached, it would be beneficial for performance to apply that transformation to the cached rasterization.

<br>

### How are the Render Objects Rasterized?
One possible approach to rasterization is creating a triangle mesh out of the render object tree which contains color and texture information. Each vertex can have color information as well as texture coordinates. A switch to decide between texture and color might be necessary as well. Alternatively, only textures could be used and the color per vertex ommited. The vertexe's texture coordinates would then be set in a way that they refer to a blank color in the texture. To update colors/images/anything color related, in many cases, only the texture would need to be updated. There could be multiple textures, one for pure color, which could be updated in an optimized way and one or multiple for images. The shader would then contain some if switches to avoid having to load different shader programs very often.

With this approach, updating the geometry would be done by updating vertices.

The vertices can be generated by going through the tree of render objects and invoking a vertex generator for each of them.
According to the order of render objects the vertices would overlap each other. The layering should be correct automatically.

To optimize this process and updates, it would be useful to divide the render object tree into smaller sub trees which are converted to a mesh and rasterized individually.
Doing this reduces the amount of vertex information that needs to be passed around to perform an update. 
However the number of draw calls might be increased.
It may be possible to add all the vertices which need to be drawn into one buffer.
During the first rasterization, all vertices are loaded into this one buffer, on subsequent updates, only the updated vertices are loaded into a buffer, still in a way that ensures the correct order / overlapping.

How would color information be handled when only parts of the render objects are in the drawing buffer at any given time?<br>
**add more information**

advantages:

- full control
- could be quite efficient, because of batch drawing instead of many small draw calls

disadvantages

- lots of work to implement

<br>

Another approach would be to use a Skia canvas like Flutter, Chrome and Firefox do. Probably a Swift wrapper would need to be created for this.

Rendering would then be performed without triangulation, but instead by going through the render object tree and performing draw calls on a skia canvas depending on which render object is to be drawn.

advantages:

- proven to work very well
- implementation for different backends (CPU only, GPU accelerated, SVG, ...) already available
- straightforward draw calls
- complex shape drawing logic already implemented (contour only path, intersections, text, ...)
- draw calls can be abstracted and forwarded by a Canvas render object or Widget to allow users to draw specific graphics themselves without needing to implement all of the complex drawing logic only for this function

disadvantages:

- kinda heavy
- written in other language (C++)

<br>

**how would a render pipeline look like?**

**how are sub trees divided**

**do subtrees know their vertex data?**

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

<br>

### Which Render Objects are Needed?
