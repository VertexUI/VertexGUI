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

**explain on a Widget which has multiple children and adds them dynamically (e.g. List) and a Widget where there is only a render object where a color needs to be updated sometimes**

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

**are manual changes to render objects still possible with the property approach --> going through the render objects and assigning values on them, is this even necessary?**

<br>

How would the property system of render objects need to work to support transitions and static values?<br>
First of all: properties on render objects that are available for transitions need to be able to accept values of different types (probably). The static value and a transition value.<br>
It would be convenient to allow the render objects constructor to receive values which are not properties. Which means they will probably not change during the lifetime of the object.
To support this there would probably need to be multiple constructors. On the other hand, since the values are provided by Widgets which in turn have their own values defined as reactive properties since they can change based on the style and in most cases these properties will be forwarded to the render objects, it would be ok to only accept reactive properties as values.
The StaticProperty should be made efficient. It should probably discard all handlers registered/not even register them in the first place. Or the render object always checks whether a given property is static, but that would be kind of a lot of work and could lead to bugs.<br>
After a render object has received a reactive property it needs to register an onChange handler on it to be notified of new values and apply the current value of the property to wherever the value should be stored.
Since there are static values and timed values / transitioned values, the render object must accept properties which allow both of these types for their value.
Probably an enum should be added which wraps these types, like this:
    
    enum RenderObjectValue<T> {
      case static(T)
      case transition(RenderObjectValueTransition<T>)
    }

A nice target syntax would be to allow the rasterizer to simply access the current property value, either static, or the value of a transition at the current time, by the properties name.
However, to calculate the current value of a transition the framework time is necessary. The framework time could either come from the render objects context, or from a call on the render object which was menitioned earlier as well. Something like tick(Tick). The render object would need to store the time by itself.
This would add another call to be made.<br>
A simpler approach would be to access the framework time in the get function of the property. Access to the render objects instance is necessary for this. This could be realized with the subscript approach of property wrappers.
Another way to implement this would be to initialize computed properties which wrap the properties of the render object in the initializer. This would allow access to self as well as the reactive properties that were passed to the render object.
The computed property wrapper's job would only be to get a single value for the property, regardless of whether the value passed in was a static value or a transition.
The handlers that invoke a rasterization request should be registered directly on the properties that were passed in.
In the handlers, it is necessary to check whether the new value provided is a static value or a transition and the relevant signals to the rasterizer / render pipeline have to be published.<br>
Note that it is not necessary that the render object values be wrapped with reactive computed properties in this approach.
A special property wrapper for render objects could be added, which can either receive a reactive property to extract it's values and listen for changes or receive a RenderObjectValue directly to then always provide the current value through the value getter.
The adding of self access could be automated by letting the RenderObject class go through all properties that are available on the class and setting the instance on them. This would automatically be executed by the super.init() call in inherting RenderObjects.<br>
Updating the value for the property could be done manually by registering an onChange handler on the reactive property. The singnaling could be done manually as well, however it would be more convenient in most cases to let the render object property wrapper handle all of this, since it also has access to the render object instance this should be doable.

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

<br><br>

## A Completely New Approach

Maybe a separate render object tree can be avoided by making Widgets renderable. This could be achieved by defining protocols for renderable objects which include things such as iterating over children.

One first question is whether all Widgets should conform to a renderable protocol.<br>
If not all children conform to such a protocol, then the Widget tree would need to be collapsed in order to allow rendering. This could be a time consuming operation, because it would need to be rerun when a Widget is added to the tree that is renderable.<br>
Maybe the renderer would accept a generic tree and then check on each node whether it is a renderable node.<br>
If all Widgets would conform to a renderable protocol, then the Widgets which should not output anything by themselves (e.g. a layout Widget) would use a protocol that simply does nothing.<br>

Widgets would need to access a rendering context in order to be able to request rasterization. This context could be provided through the Widget context. Alternatively it could be set on each renderable Widget by the rendering system, when going through the tree or maybe by the Widget Root.

<br>

**How would a rerasterization happen after a relevant property of a Widget has changed?**

The properties relevant for rendering are probably given by the protocol the Widget conforms to. This would mean that for example a RectangleRenderable protocol could define a property size which the Widget must then provide. 
Note that this protocol would not automatically provide any logic to react to changes of this property, or even to determine the current value if the value is continuously updated by a transition.<br>
Such things would need to be implemented by whatever conforms to the protocol. This might actually be a benefit in terms of the breadth of tasks the rendering system can be used for since some tasks might not require any updates to property values and every renderable can be a simple struct with a static value.<br>
In the case of Widgets, if all Widgets conform to some renderable protocol, the root Widget class could provide common logic for handling updates to properties relevant for rendering.<br>
If a property wrapper is applied to the relevant properties, the root Widget class can find these properties and give them access to self or register handlers on them to e.g. be able to make a rasterization request if the property changes or to find out whether the new value is a transition type value and inform the rendering system of this, so that the Widget is rasterized on every frame.

Where would the values for the render properties come from?<br>
Since the Widgets use styles, the values will mostly come from styles. Style properties can be retrieved as reactive properties, so that if the property wrappers for render properties receive those, the property wrappers can automatically notify the rendering system of a necessary rerasterization.<br>
It would probably be possible to define convenience property wrappers, like StyleForwardedRenderValue or something like that which takes a key of a style property and gets assigned the instance of the Widget by some logic in the root Widget class.
Such a wrapper could automatically handle transitions defined by styles.<br>
Note that in this approach, all the transition handling is done by the implementers of the renderable protocols. It might be possible to define the render values as an enum type of either a static value or a transition, but this enforces a certain type of transition definition. On the other hand, on the side of the implementers the work necessary to manage transitions would be reduced.

<br>

**should the properties of renderable protocols should accept static and transition values or only static and the transition handling should be left to the implementing system?**

**how can things that every renderable widget does be automated e.g. by a superclass?**

**how are things like translation handled in this approach?**

**how would mouse input be handled with this approach?**

**how would a lot of custom rendering look like? With the current render object system, one idea was to have something like an svg type drawable definition for each widget**

**would the rendering system be useful for a different system than the Widget system as well?**

<br>

**how are structural changes handled-->changing a background? --> since the background Widget now wraps it's children, are the children destroyed and reinstantiated?**<br>
## **CONTINUE WITH THIS QUESTION**