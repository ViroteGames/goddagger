class_name GodDaggerObjectResolver extends GodDaggerBaseResolver


static func _resolve_object_class(object_class_name: String) -> ResolvedClass:
	var object_classes: Array[ResolvedClass] = \
		_resolve_classes_of_type(object_class_name)
	
	assert(
		not object_classes.is_empty(),
		"Can't resolve object of class '%s', no script defines it." % object_class_name
	)
	
	assert(
		object_classes.size() == 1,
		"Can't resolve object of class '%s', too many scripts define it." % object_class_name
	)
	
	return object_classes[0]
