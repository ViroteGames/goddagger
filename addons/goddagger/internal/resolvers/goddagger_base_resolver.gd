class_name GodDaggerBaseResolver extends RefCounted


static func _parsed_line_resolves_to_expected_class(
	resolution_type: ResolutionType,
	expected_class_name: String,
	parsed_line: String,
) -> bool:
	
	parsed_line = parsed_line.strip_edges()
	
	var is_of_expected_class := parsed_line.begins_with(GodDaggerConstants.KEYWORD_CLASS_NAME) \
		and not parsed_line.contains(GodDaggerConstants.GENERATED_GODDAGGER_TOKEN_PREFIX)
	
	match resolution_type:
		ResolutionType.CLASSES:
			is_of_expected_class = is_of_expected_class and parsed_line \
				.trim_prefix("%s " % GodDaggerConstants.KEYWORD_CLASS_NAME) \
				.begins_with(expected_class_name)
		ResolutionType.SUBCLASSES:
			is_of_expected_class = is_of_expected_class and \
				parsed_line.ends_with(expected_class_name)
	
	return is_of_expected_class


static func _resolve_classes_of_type(type_name: String) -> Array[ResolvedClass]:
	return _do_resolve_classes(type_name, ResolutionType.CLASSES)


static func _resolve_subclasses_of_type(type_name: String) -> Array[ResolvedClass]:
	return _do_resolve_classes(type_name, ResolutionType.SUBCLASSES)


static func _do_resolve_classes(
	type_name: String,
	resolution_type: ResolutionType,
) -> Array[ResolvedClass]:
	
	var resolved_classes: Array[ResolvedClass] = []
	
	var resolve_class_script := func (absolute_file_path: String) -> void:
		if not absolute_file_path.ends_with(".gd"):
			return
		
		var file_lines := GodDaggerFileUtils._read_file_lines(absolute_file_path)
		
		for parsed_line in file_lines:
			var is_of_expected_class := _parsed_line_resolves_to_expected_class(
				resolution_type, type_name, parsed_line,
			)
			
			if is_of_expected_class:
				match resolution_type:
					ResolutionType.CLASSES:
						resolved_classes.append(ResolvedClass.new(type_name, absolute_file_path))
					ResolutionType.SUBCLASSES:
						resolved_classes.append(
							ResolvedClass.new(
								parsed_line
									.trim_prefix("%s " % GodDaggerConstants.KEYWORD_CLASS_NAME)
									.trim_suffix( "%s %s" % [
										GodDaggerConstants.KEYWORD_EXTENDS, type_name
									])
									.strip_edges(),
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


static func _is_subclass_of_given_class(
	subclass: GodDaggerBaseResolver.ResolvedClass,
	given_class_name: String,
) -> bool:
	
	var absolute_file_path := subclass.get_resolved_file_path()
	var file_lines := GodDaggerFileUtils._read_file_lines(absolute_file_path)
	var first_line := file_lines[0]
	
	return _parsed_line_resolves_to_expected_class(
		ResolutionType.SUBCLASSES, given_class_name, first_line,
	)


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
