class_name GodDaggerComponentResolver extends GodDaggerBaseResolver


static func _resolve_component_name() -> String:
	var component_name_candidates: Array[String] = \
		_resolve_classes_of_type(GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME)
	
	assert(
		not component_name_candidates.is_empty(),
		"Please define your GodDaggerComponent or disable this plugin."
	)
	assert(
		component_name_candidates.size() == 1,
		"Please define just a single GodDaggerComponent for your project."
	)
	
	return component_name_candidates[0]
