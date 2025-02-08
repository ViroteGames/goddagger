class_name Example extends Node


var __coffee_maker: CoffeeMaker


func _init() -> void:
	GodDagger.inject(self)


func _ready() -> void:
	print("CoffeeMaker was obtained properly: %s" % [__coffee_maker])
	print("CoffeeMaker can make coffee: %s" % [__coffee_maker.make_coffee()])
