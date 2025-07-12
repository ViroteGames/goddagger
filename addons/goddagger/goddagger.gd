class_name GodDagger extends RefCounted


static func inject(component: String, target: Object) -> void:
	var generated_components := GodDaggerComponentsParser.get_generated_component(component)
	
	for property in target.get_property_list():
		var property_name: String = property[GodDaggerConstants.KEY_PROPERTY_NAME]
		
		if not property_name.begins_with(GodDaggerConstants.DECLARED_INJECTED_PROPERTY_PREFIX):
			continue
		
		var dependency_name = property_name \
			.replace(GodDaggerConstants.DECLARED_INJECTED_PROPERTY_PREFIX, "")
		
		var method_name: String = "%s%s" % [
			GodDaggerConstants.DEPENDENCY_ACCESS_METHOD_DECLARATION_PREFIX,
			dependency_name,
		]
		
		target[property_name] = generated_components.call(method_name)
