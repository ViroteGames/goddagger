class_name GodDaggerBaseResolver extends RefCounted


static func _resolve_classes_of_type(type_name: String) -> Array[ResolvedClass]:
	return _do_resolve_classes(type_name, ResolutionType.CLASSES)


static func _resolve_subclasses_of_type(type_name: String) -> Array[ResolvedClass]:
	return _do_resolve_classes(type_name, ResolutionType.SUBCLASSES)


static func _do_resolve_classes(
	type_name: String,
	resolution_type: ResolutionType,
) -> Array[ResolvedClass]:
	var resolved_classes: Array[ResolvedClass] = []
	var corresponding_prefix_to_avoid: String
	
	if type_name == GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME:
		corresponding_prefix_to_avoid = GodDaggerConstants.GENERATED_GODDAGGER_COMPONENT_PREFIX
	
	var resolve_class_script := func (absolute_file_path: String) -> void:
		if not absolute_file_path.ends_with(".gd"):
			return
		
		var file := FileAccess.open(absolute_file_path, FileAccess.READ)
		var file_contents := file.get_as_text().strip_edges().split("\n", false)
		var first_line := file_contents[0]
		
		var is_of_expected_class := first_line.begins_with(GodDaggerConstants.KEYWORD_CLASS_NAME)
		
		match resolution_type:
			ResolutionType.CLASSES:
				is_of_expected_class = is_of_expected_class and first_line \
					.trim_prefix("%s " % GodDaggerConstants.KEYWORD_CLASS_NAME) \
					.begins_with(type_name)
			ResolutionType.SUBCLASSES:
				is_of_expected_class = is_of_expected_class and first_line.ends_with(type_name)
		
		if corresponding_prefix_to_avoid != null:
			is_of_expected_class = is_of_expected_class \
				and not first_line.contains(corresponding_prefix_to_avoid)
		
		if is_of_expected_class:
			match resolution_type:
				ResolutionType.CLASSES:
					resolved_classes.append(ResolvedClass.new(type_name, absolute_file_path))
				ResolutionType.SUBCLASSES:
					var suffix_to_trim := "%s %s" % [
						GodDaggerConstants.KEYWORD_EXTENDS,
						type_name,
					]
					resolved_classes.append(
						ResolvedClass.new(
							first_line.trim_prefix(GodDaggerConstants.KEYWORD_CLASS_NAME) \
								.trim_suffix(suffix_to_trim).strip_edges(),
							absolute_file_path,
						)
					)
	
	GodDaggerFileUtils._iterate_through_directory_recursively_and_do(resolve_class_script)
	
	return resolved_classes


static func _resolved_classes_contains_given_class(
	resolved_classes: Array[ResolvedClass],
	given_class_name: String,
) -> bool:
	
	for resolved_class in resolved_classes:
		var resolved_class_name := resolved_class.get_resolved_class_name()
		
		if given_class_name == resolved_class_name:
			return true
	
	return false


enum ResolutionType {
	CLASSES,
	SUBCLASSES,
}


class ResolvedClass extends RefCounted:
	
	var _resolved_class_name: String
	var _resolved_file_path: String
	
	func _init(resolved_class_name: String, resolved_file_path: String) -> void:
		self._resolved_class_name = resolved_class_name
		self._resolved_file_path = resolved_file_path
	
	func get_resolved_class_name() -> String:
		return _resolved_class_name
	
	func get_resolved_file_path() -> String:
		return _resolved_file_path
