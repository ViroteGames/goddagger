class_name GodDaggerComponentResolver extends GodDaggerBaseResolver


static func _resolve_component_names() -> Array[String]:
	var component_name_candidates: Array[String] = \
		_resolve_classes_of_type(GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME)
	
	assert(
		not component_name_candidates.is_empty(),
		"Please define your GodDaggerComponent or disable this plugin."
	)
	
	return component_name_candidates
