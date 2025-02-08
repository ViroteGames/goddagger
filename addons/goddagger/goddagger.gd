class_name GodDagger extends RefCounted


static func inject(target: Object) -> void:
	var generated_components: GodDaggerGeneratedComponents = GodDaggerComponentsParser._get_components()
	target["__injected_coffee_maker"] = generated_components.get_coffee_maker()
