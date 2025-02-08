class_name GodDaggerModuleResolver extends GodDaggerBaseResolver


static func _resolve_module_classes() -> Array[ResolvedClass]:
	var module_classes: Array[ResolvedClass] = \
		_resolve_classes_of_type(GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME)
	
	return module_classes
