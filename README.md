## Overview

I'm experimenting with implementing a Dependency Injection plugin heavily influenced by design decisions made by the creators of Dagger 2.

Hopefully, this plugin will be performant enough and robust enough for real usage. My ambition is to have as much compile-time validation of the entire graph as possible, by attempting to build a direct acyclic graph from the user's dependencies and giving useful errors to users ahead of time if things are misconfigured so they can avoid common pitfalls.

This documentation will be further improved as the project is further developed.


## Usage

For now, this is the intented way this plugin should be used:


### Declare your GodDagger component

Declare your component with a standalone script (which can be placed anywhere in your project structure):

```gdscript
# example_component.gd

class_name ExampleComponent extends GodDaggerComponent


var __example_module: ExampleModule
var __coffee_maker: CoffeeMaker
```

By making your script inherit from `GodDaggerComponent`, you're informing the plugin that this is your component. You need to have at least one GodDagger component script, otherwise the plugin will not let you build your project (and it will inform you about this situation with an informative error message).

In your component(s), you must declare which objects you'd like to expose to consumers (regular `GDScript` files).

Those are declared directly by defining a variable with a name starting with the `__` prefix as well as its type (the script's `class_name`) e.g., `__coffee_maker: CoffeeMaker`.

By declaring an object, its dependencies are automatically declared as to be exposed to consumers as well, you don't have to add entries for every single object in your dependency graph.

You may also declare dependencies to be exposed to consumers indirectly by defining variables using the same aforementioned prefix, but whose declared type extends from `GodDaggerModule`. More about modules in the next section.

Note that the `__` prefix will perhaps be changed to `__injected_` to be more explicit as well as to avoid collision with files in existing projects that eventually decide to adopt this plugin). 


### Declare some GodDagger modules

You may optionally decide to declare some GodDagger modules. Those are useful for decoupling your objects from direct implementations of their dependencies, which will give you the flexibility to replace them e.g., in your unit tests.

```gdscript
# example_module.gd

class_name ExampleModule extends GodDaggerModule


func __provide_heater(electric_heater: ElectricHeater) -> Heater:
	return electric_heater


func __provide_pump(thermosiphon: Thermosiphon) -> Pump:
	return thermosiphon
```

For example, the module above declares that objects depending on `Heater` should be provided `ElectricHeater` instances, while if they depend on `Pump`, they will be provided with `Thermosiphon` instances.

In your provider methods or in your object constructors (regular `_init(...)` functions), you can optionally declare an instance with a subtype of `GodDaggerScope` e.g., `GodDaggerScope.SINGLETON` or your own defined scope, as *the first parameter*. That will apply the given scope to the return type (e.g., `Heater` or `Pump` above). If no scope is provided, then the return type will be unscoped.

### Let GodDagger work out its magic

GodDagger will parse your project files and generate all the Dependency Injection boilerplate on your behalf respecting your declared intent in terms of which objects you want to be part of your graph and their respective dependency relationships.

Since Godot doesn't have support for custom annotations, we can't conveniently declare which objects should participate in the dependency graph via `@Inject` annotations the same way Dagger 2 does. So GodDagger will determine which objects should be part of the graph by considering which objects are explicitly declared in your component, which are its constructor dependencies as well as which provider relationships were established in your declared modules.

This means that if your component has no entries, nothing will be considered as part of your dependency graph. A good rule of thumb is to declare at least the end objects that you intend to have injected in your project scripts. Remember, you only need to declare an object if no other object in your graph depends on it (and that's only necessary if you really use this object somewhere - if no other object in your graph depends on it and you don't inject it anywhere, it doesn't really need to be part of your graph in the first place)!


### Inject your objects!

Inject your objects into any GDScript scripts in your project! That's done in a very straightforward fashion: imagine you have some `Node` in which you'd like to inject a `CoffeeMaker` instance. All you have to do is declare a variable for the `CoffeeMaker` in your script using the special `__` prefix, and, in your object's `_init()` method, call `GodDagger.inject(self)`.

```gdscript
# example.gd

class_name Example extends Node


var __coffee_maker: CoffeeMaker


func _init() -> void:
	GodDagger.inject(self)


func _ready() -> void:
	print("CoffeeMaker was obtained properly: %s" % [__coffee_maker])
	print("CoffeeMaker can make coffee: %s" % [__coffee_maker.make_coffee()])
```

GodDagger will under the hood do all the boilerplate for providing your script an instance of `CoffeeMaker` without you ever having to worry about building its dependencies (`Heater` and `Pump`) and passing them along.


Note that the example above only has `RefCounted` instances belonging to the dependency graph but my ambition is to also allow `Node`s to participate in the dependency graph and so far I don't think there will be any reason to think that it won't be possible.
