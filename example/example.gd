class_name Example extends Node


var __injected_coffee_maker: CoffeeMaker


func _init() -> void:
	GodDagger.inject(self)


func _ready() -> void:
	print("CoffeeMaker was obtained properly: %s" % [__injected_coffee_maker])
	print("CoffeeMaker can make coffee: %s" % [__injected_coffee_maker.make_coffee()])
