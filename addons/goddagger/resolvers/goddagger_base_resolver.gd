class_name GodDaggerBaseResolver extends RefCounted


static func _resolve_classes_of_type(type_name: String) -> Array[String]:
	var resolved_classes: Array[String] = []
	var corresponding_prefix: String
	
	match type_name:
		GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME:
			corresponding_prefix = GodDaggerConstants.GENERATED_GODDAGGER_COMPONENT_PREFIX
		_:
			assert(
				false,
				"GodDagger BUG @GodDaggerBaseResolver._resolve_classes_of_type(). " + 
				"This function received an invalid type: '%s'!" % type_name
			)
			return resolved_classes
	
	var resolve_component_class_script := func (absolute_file_path: String) -> void:
		if not absolute_file_path.ends_with(".gd"):
			return
		
		var file := FileAccess.open(absolute_file_path, FileAccess.READ)
		var file_contents := file.get_as_text().strip_edges().split("\n", false)
		var first_line := file_contents[0]
		
		var is_component_class := first_line.begins_with(GodDaggerConstants.KEYWORD_CLASS_NAME) \
			and first_line.ends_with(type_name) \
			and not first_line.contains(corresponding_prefix)
		
		if is_component_class:
			var suffix_to_trim := "%s %s" % [
				GodDaggerConstants.KEYWORD_EXTENDS,
				type_name,
			]
			resolved_classes.append(
				first_line.trim_prefix(GodDaggerConstants.KEYWORD_CLASS_NAME) \
					.trim_suffix(suffix_to_trim).strip_edges()
			)
	
	GodDaggerFileUtils._iterate_through_directory_recursively_and_do(resolve_component_class_script)
	
	return resolved_classes
