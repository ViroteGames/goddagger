class_name ExampleComponent extends GodDaggerComponent


func _declare_modules() -> Array[GodDaggerModule]:
	return [ExampleModule.new()]


@export_storage var coffee_maker: CoffeeMaker
