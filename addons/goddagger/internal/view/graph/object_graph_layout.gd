class_name ObjectGraphLayout extends RefCounted


var _levels: Array[GraphLayoutLevel] = []


func _init(
	component: GodDaggerParsingResult.CompiledResult.Component,
) -> void:
	
	var level_numbers: Dictionary[String, int] = {}
	var levels: Dictionary[int, GraphLayoutLevel] = {}
	
	for object in component.get_topologically_ordered_graph():
		if object.get_dependencies().is_empty():
			if not object.get_name() in level_numbers:
				var object_level_number := 0
				if not object_level_number in levels.keys():
					levels[object_level_number] = GraphLayoutLevel.new()
				
				level_numbers[object.get_name()] = object_level_number
			
		else:
			var maximum_level_of_dependencies = 0
			for dependency in object.get_dependencies():
				var dependency_level = level_numbers[dependency.get_name()]
				if dependency_level > maximum_level_of_dependencies:
					maximum_level_of_dependencies = dependency_level
			
			var object_level_number := max(0, maximum_level_of_dependencies + 1)
			if not object_level_number in levels.keys():
				levels[object_level_number] = GraphLayoutLevel.new()
			
			level_numbers[object.get_name()] = object_level_number
	
	for object in component.get_topologically_ordered_graph():
		var object_level_number = level_numbers[object.get_name()]
		levels[object_level_number].add_dependency_if_not_present_yet(object)
		
		for dependency in object.get_dependencies():
			var dependency_level_number = level_numbers[dependency.get_name()]
			levels[dependency_level_number].add_dependency_if_not_present_yet(dependency)
			
			var in_between_level_number = dependency_level_number + 1
			while object_level_number - in_between_level_number > 0:
				levels[in_between_level_number].add_cross_level_link(object, dependency)
				in_between_level_number += 1
	
	# TODO simply sort dependencies in each layer by:
	#  1. all dependencies that belong to the component first (maybe minimizing edge overlaps)
	#  2. then each subcomponent's dependencies (maybe minimizing edge overlaps?), with each subcomponent being sorted alphabetically
	
	for level_number in range(levels.keys().size()):
		_levels.append(levels[level_number])
	
	for index in _levels.size():
		_levels[index].print_contents(index)


func get_levels() -> Array[GraphLayoutLevel]:
	return _levels


class GraphLayoutLevel extends RefCounted:
	
	var _dependencies := GodDaggerParsingResult.CompiledResult.DependencyArray.new()
	var _cross_level_links: Array[CrossLevelLink] = []
	
	func get_dependencies() -> GodDaggerParsingResult.CompiledResult.DependencyArray:
		return _dependencies
	
	func add_dependency_if_not_present_yet(
		dependency: GodDaggerParsingResult.CompiledResult.Dependency
	) -> void:
		for other_dependency in _dependencies:
			if dependency == other_dependency:
				return
		
		self._dependencies.add_dependency(dependency)
	
	func get_cross_level_links() -> Array[CrossLevelLink]:
		return _cross_level_links
	
	func add_cross_level_link(
		object: GodDaggerParsingResult.CompiledResult.Dependency,
		dependency: GodDaggerParsingResult.CompiledResult.Dependency,
	) -> void:
		
		self._cross_level_links.append(CrossLevelLink.new(object, dependency))
	
	func print_contents(level: int) -> void:
		print("Level %s has %s dependencies and %s cross links!" % [
			level, _dependencies.size(), _cross_level_links.size(),
		])
		print("At level %s: %s%s" % [
			level,
			", ".join(
				_dependencies.map(
					func (dependency: GodDaggerParsingResult.CompiledResult.Dependency) -> String: \
						return dependency.get_name()
					)
			),
			"" if _cross_level_links.is_empty() else " (With crossings: %s)" % [
				", ".join(
					_cross_level_links.map(
						func (cross_level_link: CrossLevelLink) -> String: \
							return "%s to %s" % [
								cross_level_link.get_dependency().get_name(),
								cross_level_link.get_object().get_name(),
							]
					)
				)
			]
		])


class CrossLevelLink extends RefCounted:
	
	var _object: GodDaggerParsingResult.CompiledResult.Dependency
	var _dependency: GodDaggerParsingResult.CompiledResult.Dependency
	
	func _init(
		object: GodDaggerParsingResult.CompiledResult.Dependency,
		dependency: GodDaggerParsingResult.CompiledResult.Dependency,
	) -> void:
		
		self._object = object
		self._dependency = dependency
	
	func get_object() -> GodDaggerParsingResult.CompiledResult.Dependency:
		return self._object
	
	func get_dependency() -> GodDaggerParsingResult.CompiledResult.Dependency:
		return self._dependency
	
