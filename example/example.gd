class_name Example extends Node


var _coffee_maker: CoffeeMaker


func _init() -> void:
	_coffee_maker = GodDagger__ExampleComponent.create().get_coffee_maker()


func _ready() -> void:
	print("CoffeeMaker was obtained properly: %s" % [_coffee_maker])
	print("CoffeeMaker can make coffee: %s" % [_coffee_maker.make_coffee()])
