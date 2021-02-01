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

<br><br>

## A Completely New Approach

<br>

Maybe a separate render object tree can be avoided by making Widgets renderable. This could be achieved by defining protocols for renderable objects which include things such as iterating over children.

One first question is whether all Widgets should conform to a renderable protocol.<br>
If not all children conform to such a protocol, then the Widget tree would need to be collapsed in order to allow rendering. This could be a time consuming operation, because it would need to be rerun when a Widget is added to the tree that is renderable.<br>
Maybe the renderer would accept a generic tree and then check on each node whether it is a renderable node.<br>
If all Widgets would conform to a renderable protocol, then the Widgets which should not output anything by themselves (e.g. a layout Widget) would use a protocol that simply does nothing.<br>

Widgets would need to access a rendering context in order to be able to request rasterization. This context could be provided through the Widget context. Alternatively it could be set on each renderable Widget by the rendering system, when going through the tree or maybe by the Widget Root.

<br>

### How would a rerasterization happen after a relevant property of a Widget has changed?

<br>

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

### How are things like translation handled in this approach?

<br>

The thing about translation is that it affects all the children of a Widget. This applies to other transforms as well. Opacity also shows this behavior.<br>
These values are provided by wrapping a tree of Widgets in a special Widget exposing these properties. For example the container Widget might expose them.<br>
The properties are accessed by the rasterizer. It should keep track of the cumulated value of these properties when going down a specific tree path.
This means that, if a sub tree is going to be rasterized, all parents of the first node of the subtree need to be checked for transforms, opacity and the like.<br>
Transform and opacity can also affect caching. Usually caching would done by caching certain root nodes of sub trees where it could have a beneficial effect on performance.
When rasterizing, it is assumed that every subtree has it's own area and doesn't overlap with other sub trees. So that only the sub tree that changed is rasterized.
Having transform and opacity set could change this. Since now one sub tree can be anywhere on the screen, and if it is rerasterized and opacity is smaller than 1, the visual output would change. Any subtree that is overlapped would first have to be rasterized or at least the current cache state applied again and the subtree in question would then be layered on top of it.

Opacity and transforms can affect mouse events. When the opacity is zero, it might make sense, sometimes, to disable mouse events for these areas and forward them to whatever is below.
Probably this behavior should be configurable by a property on whatever Widget handles the receiving of mouse events. To be able to make that decision, the rasterized output of the sub tree of the Widget receiving the mouse events needs to be known or the sub tree of the Widget has to be searched for the exact child Widget below the mouse and that Widget checked for it's opacity configuration.<br>
Translation and rotation change the position of the bounding rect in which a Widget can receive mouse events.
If scale is applied as well it is probably necessary to scale the mouse position on screen to a position in the Widget as if it had no scale applied.<br>
Probably a Widget mouse event should include a global position and a local position, relative to the Widget bounds with all transforms resolved.<br>
To be able to do these calculations, the transformation state of every Widget must be known. This can either be done by storing the state on every Widget when going through the tree, or by keeping track of the transformation state temporarily when resolving mouse events.

<br>

This means, that one open question is whether transformation, opacity and the like should be tracked on every Widget / made available as a property on every Widget.<br>
The answer to this depends on whether these values are required for any calculations outside of mouse input processing, since in that case the tracking can probably happen temporarily.<br>
For calculating large layout transitions, for example morphing one Widget into another, it might be useful to have direct access to the transformation state of every Widget to be able to calculate where points inside the Widget are located in the global space. However these values would probably only seldomly be accessed. It might be enough to calculate them as they are needed, by going up the tree.

<br>

Maybe transform, opacity etc. should even be settable on every renderable. Determine this in a dedicated section exploring the details of composing renderables.

<br>

### How would mouse input be handled with this approach?

<br>



<br>

**how would a lot of custom rendering look like? With the current render object system, one idea was to have something like an svg type drawable definition for each widget**

**would the rendering system be useful for a different system than the Widget system as well?**


<br>

### How would structural changes be handled, can children that don't change be reused?

<br>

Some Widgets take a builder function to generate children. This builder function is evaluated during the initialization of the Widget in most cases.
Such a Widget might wrap the provided children in some other Widgets, depending on which functionality should be added.
A container Widget might wrap the provided child inside a Padding and a Background Widget.
The container Widget does not change the structure of it's sub tree during it's lifetime. But there could be other Widgets which would do that.<br>
This would probably mostly happen somewhere inside a composed Widget which a user defined view. The developer might want to display certain data differently based on some other data or flags. One use case might be switching the orientation of the layout of certain Widgets. By wrapping them in a Column or a Row layout Widget and allowing the user to switch between those two.
The children inside these two layouts could be reused. However, since the children are build by the layout which invokes the provided build function, the children would be rebuilt after the layout is switched.<br>
One possible solution would be to not use two separate layout Widgets Row and Column, but instead a single layout Widget which allows for switching between those two by updating a property. This property could be given as a reactive property.
After it changes, the layout performs another layout pass, the children stay the same.<br>
Another solution could be to provide a functional Widget which takes in a build function, invokes it, stores the children and takes another build function which builds another subtree. The second build function receives the result of the first as a parameter. When some dynamic rebuilding logic is in the second subtree, every newly built version will still have access to the result of the first as it is retained by the closure.<br>
It could be necessary to be careful about not creating reference cycles with this approach. Generally, if possible, the solution of providing a single Widget which allows for switching instead of needing to rebuild the entire sub tree is better.<br>
Additionally, every developer can create another functional composed Widget which receives the build function for the children that are to be retained, and inserts them into a subtree defined by the Widget. This would add the overhead of needing to create a new Widget for a specific use case.

If render objects would form a separate tree, this wouldn't be different, since the render object's functionality is hidden behind Widgets.

<br>

### Some specific examples exploring which renderables would be needed:

<br>

- Buttons, Containers need a background. This background could be a color, a gradient, an image, a pattern
  - for design purposes the background can be an arbitrary shape.
  - some buttons might be stylized to have some edge beveled, be a circle or only slightly rounded
  - the background of a button/container can change, for example when the mouse is over the button
  - it would be useful if the background can consist of multiple independently colored shapes, which can be defined in terms of their path and colors, something similar to using svg backgrounds in css, the background would need to be scalable
  - the Widget can probably not switch which type of renderable it is during runtime, so all of these possible values should be supported by one renderable
- a design might be visually more interesting if there can be graphical elements which direct the viewers eye
  - should these be included in the definition of a renderable with a fill?
  - the graphical elements might be essentialy something drawable with multiple shapes, the drawables can stretch to whatever size is to be filled, so they are svgs, and include colors
  - such a graphical element could include transitions
  - e.g. a color inside the drawable could be transitioned or animated
  - this would mean that frequent updates would be necessary
  - if the drawable is only one value, which includes shapes, and colors, the amount of data being created and overwritten on every frame might be unnecessarily high
  - a path could be transitioned, morphed as well, in that case it would be necessary to either modify the existing path data or overwrite it with new data
  - when doing essentially svg values for properties of renderables, that would introduce a whole new tree with properties and so on, this should probably be avoided and renderables be used directly
- should images be handled by the same renderable that also does backgrounds etc.?
- maybe there could be a path renderable with a property that accepts points or segments, maybe with bezier handles, a contour property
- text which can break and span over multiple lines (although this might be handled by the Widget system)

<br>

### Types of fills

<br>

A shape can be filled with:

- solid color
- pattern
- image
- gradient
- vector graphic (image?)

<br>

### Types of renderables

<br>

The nested items are the Widgets which would use this renderable.

<br>

- Rectangle (size, fill, border radius, border width, border color, border style, border bevel?)
  - Background
  - Image (fill: type Image)
- Clip
  - Forwarded to c

<br>

### Can a Widget conform to multiple renderables?

<br>

It could make sense that a Widget can be a renderable which supports transform as well as a renderable which enables filling a shape. A container Widget could use those two properties and make them available by wrapping other Widgets. But the container Widget could just as well use two Widgets internally which provide this functionality.<br>
Since protocols allow conforming to multiple of them, how could it be prevented even if it would make sense to prevent it? Conflicting property types would throw an error, but it would not be clear that this means that renderables shouldn't be combined on one Widget.<br>
It's probably going to be allowed. So the render logic must take this into account.

<br>

### Can the new approach be developed next to the current approach?

<br>

A new implementation for the renderer is needed for this system. All the existing render object outputs could stay there while the new approach is being implemented. The Widget Root might become a renderable itself and can then be passed directly to the new renderer.<br>
The app containing the Widget Root can conditionally enable or disable the old renderer.<br>
Some protocols for renderables might conflict with existing property names in Widgets. These Widgets and their current render functions will need to be adjusted slightly.<br>
Any newly implemented Widget which should only support the new rendering approach can return nil in the old render function.

<br>

### Should everything be done with draw functions?

<br>

Why go with the dedicated renderables in the first place?<br>
The draw calls are still made, somewhere else, by a renderer, by they are made. Even if something is triangulated, it is essentially still a drawcall, and the backend for the draw calls made by Widgets could be implemented in such a way that triangles are generated.<br>
It would be simple to use only drawRect for backgrounds, but use more complex shapes wherever they are needed.<br>
There would anyway be the need for supporting custom drawings for certain edge cases.<br>
Essentially, the functions of a skia canvas need to be forwarded.

What about Widgets which have multiple children and draw something around or on top of them and need to handle the drawing order of the children?<br>
Drawing Widgets in a different order than they are defined in the tree might be problematic, since for caching it needs to be known in which order Widgets overlap in order to be able to determin whether any siblings, parents or whatever needs to be redrawn.

<br>

The complexity can probably be reduced by only allowing certain leaf Widgets to actually draw something. So a background Widget would not make a draw call and then invoke draw on it's children.
Instead there should be another Widget which the Background Widget adds to itself as a child before the other children.
This Widget could be an internal class which only the background Widget can see or it can be something like a Rectangle Widget which essentially exposes the same properties as Background or more.<br>
This would mean that the background Widget becomes a kind of layout Widget because it stacks two other Widgets.<br>
A button could use the background Widget for it's own background. But sometimes a user might want to have a totally customized background.
The background might consist of different Shape Widgets which allow drawing of arbitrary colored shapes.
Either the user creates a custom Button Widget, which probably wouldn't be very complicated. Or the background property takes a complex graphic definition for which transitioning must be implemented by finding similarities and differences or by transitioning raw pixel values.
Probably the approach with the graphic will be taken. The graphic will be inside a rectangular area and stretch or not stretch as defined.<br>
This would probably the implementation that covers most use cases. Custom buttons with custom drawings can still be implemented.

<br>

Where should caching be handled?
- by the Widget system
- or by the drawing system?

Probably the most stuff should happen should be done by the Widget system to keep unnecessary abstraction low. 
The drawing system only needs to provide the mechanisms necessary for caching, such as being able to draw to a virtual buffer instead of directly to the screen.

<br>

What about reusability?

The drawing functions can be used with anything else. It is even more flexible than having to conform to specific protocols in order to be able to draw something.

<br>

How should the draw functions work?

A question is, whether the Widget needs to calculate transformations by itself or whether the drawing api knows the transformation state (as well as opacity and the like) and handles it automatically.
Since the opacity and transformations add up (or multiply up), each Widget would need to not only know it's own opacity and transform values, but also how they are changed by the values of parent Widgets.
Since the drawing backend should be as light as possible and the Widget Root should probably only receive a bare drawing context, something like a canvas, an area in which it can draw which is provided by the backend, all the handling of transformation and opacity should probably be done in the drawing logic of the Widget system.
This would mean, that any calls to drawing functions which are made by the Widget have to be intercepted and points transformed, the opacity of colors adjusted to reflected the opacity of the Widget.<br>
If this isn't done it would be easy for a Widget author who implements custom drawing to forget to apply some transformations.<br>
In case a new property that behaves similar to transform or opacity would be introduced at a later point, it would have to be implemented in every Widget draw function, if such things are not handled automatically by proxying calls.<br>

<br>

Should the Widget root have a draw function?

The Widget root needs to redraw parts of itself whenever a Widget needs to be redrawn. That may mean replacing parts of the existing output or replacing everything.

It should be possible to transform the whole gui, set opacity etc. for effects. This could be done by letting the gui draw itself into a buffer and then transforming that buffer before outputting it to the screen.<br>
This might be useful if the gui is sometimes partially drawn over by something which is not controlled by the gui.
For example something in a game flying over the gui would require the gui to be drawn on every frame and whatever is on top after it.
When drawing the gui to a buffer this would be easy.
If the gui is standalone, drawing to a buffer first would probably unnecessarily lower the performance. It should be possible to draw to the screen directly.<br>
Skia has the canvas object which hides the drawing target from whatever uses it.<br>
This could be given to the gui directly. It can then create proxies for it.<br>
The drawing context provided by the backend could just as well offer the capability to apply an opacity and transform to every input.
That way the gui as a whole could be transformed as well.<br>
Handling mouse events on the app level and distributing them between different contents such as a gui and a game can be done later. The gui only needs to receive mouse events with positions in it's own coordinate space.
And then forward everything to it's Widgets.

What could draw calls look like?

    // outside logic which calls draw on the gui
    DrawingContext drawCtx = DrawingContext(for: window, transform: .translate(...), opacity: 0.2)
    widgetGUIRoot.draw(with: drawCtx)

    class WidgetGUIRoot {
      func draw(with initialContext: DrawingContext) {
        var derivedContext = initialContext.derive()
        for widget in widgets {
          if widget.transform != derivedContext.transform || widget.opacity != derivedContext.opacity {
            derivedContext = initialContext.derive(transform: widget.transform, opacity: widget.opacity)
            widget.draw(with: derivedContext)
          }
        }
      }
    }

It should be impossible for anyone using a drawing context to remove the transform and opacity set by the logic that provided the drawing context. A solution to this is to only allow changing the transform and opacity by deriving a context.

Another property that would behave like transform and opacity is the clip state. If this is set on the initial context, it is prevented that the gui draws anything outside of where it's allowed to draw by applying a translation that brings some drawcalls out of the bounds.

<br>

**Wow to iterate through the tree and find the Widgets that can be drawn?**

**note: the following algorithm will probably not work**

When redrawing everything / this is the first drawing pass:

1. go through the tree, find all of the Widgets which have a draw function
2. sort the Widgets into the order in which they are drawn by considering layer indices / z indices and the position in the tree (if manual setting of z is going to be implemented at all)
3. call all draw functions in sequence
4. display

When a Widget changed and needs to be redrawn:

- get the order in which Widgets are drawn (maybe from first pass)

- if the Widget has an opacity that is lower than 1
  
  - find out what what is drawn before the Widget and is overlapped by the Widget

  - draw these things by calling redraw recursively (this should lead to the smallest possible amount of Widgets being redrawn)

  - the Widget should have been redrawn by the recursive call

- if the Widget has not yet been drawn and if the Widget has an opacity is greater than 0
  
  - call draw on the Widget

- find out everything drawn after the Widget

  - if it has not yet been drawn, call draw on it