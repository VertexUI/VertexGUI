# configs

- use function builders to create deeply nested and constrained (receiver constrained) widget configs (--> like css)

- deeply nested configs somwhere near the root level could take up a lot of memory if copied into all kinds of children with computed derived configs

- make configs reactive / observable values

- for MouseInteraction Widget: change an observable value during mouse interaction / provide different configs that are passed down for different states

- introduce ConfigCaches which combine all the configs of higher level ConfigProviders (if makes sense performance wise)

- maybe instead of Observable for configs, use simple didSet and if ConfigProvider changes trigger Config update on all children --> which is more performant / developer friendly

- maybe need only PartialConfig and no Config --> each Widget can define the defaults as it likes / use conditional access with defaults

# fills

- use Protocols to mark types as acceptable for fill properties --> Colors, Gradients, TransitionedValues, AnimatedValues

# properties 

- add Binding which can set values and remove set capability from Observable

# widget identification

- make Widgets equatable by id?

# keeping everything together

- e.g. for Widget class, may add context / tag information to each function, property as well as side effects and when it is valid to use them in the lifecycle