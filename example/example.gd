class_name Example extends GodDaggerEntryPoint


@export_storage var _coffee_maker: CoffeeMaker


func _declared_component_name() -> String:
	return "ExampleComponent"


func _init() -> void:
	super._init()
	_coffee_maker = _get_component().get_coffee_maker()


func _ready() -> void:
	print("CoffeeMaker was obtained properly: %s" % [_coffee_maker])
	print("CoffeeMaker can make coffee: %s" % [_coffee_maker.make_coffee()])
