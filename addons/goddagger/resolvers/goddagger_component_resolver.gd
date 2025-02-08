class_name GodDaggerComponentResolver extends GodDaggerBaseResolver


static func _resolve_component_classes() -> Array[ResolvedClass]:
	var component_classes: Array[ResolvedClass] = \
		_resolve_classes_of_type(GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME)
	
	assert(
		not component_classes.is_empty(),
		"Please define your GodDaggerComponent or disable this plugin."
	)
	
	return component_classes
