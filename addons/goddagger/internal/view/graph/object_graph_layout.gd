class_name ObjectGraphLayout extends RefCounted


var _layers: Array[GraphLayoutLayer] = []


func _resolve_layering_for_component(
	component: GodDaggerParsingResult.CompiledResult.Component,
	layer_numbers: Dictionary[String, int],
	layers: Dictionary[int, GraphLayoutLayer],
) -> void:
	
	for object in component.get_topologically_ordered_graph():
		if object.get_dependencies().is_empty():
			if not object.get_name() in layer_numbers:
				var object_layer_number := 0
				if not object_layer_number in layers.keys():
					layers[object_layer_number] = GraphLayoutLayer.new()
				
				layer_numbers[object.get_name()] = object_layer_number
			
		else:
			var maximum_layer_of_dependencies = 0
			for dependency in object.get_dependencies():
				var dependency_layer = layer_numbers[dependency.get_name()]
				if dependency_layer > maximum_layer_of_dependencies:
					maximum_layer_of_dependencies = dependency_layer
			
			var object_layer_number := max(0, maximum_layer_of_dependencies + 1)
			if not object_layer_number in layers.keys():
				layers[object_layer_number] = GraphLayoutLayer.new()
			
			layer_numbers[object.get_name()] = object_layer_number


func _populate_layers_with_dependencies(
	component: GodDaggerParsingResult.CompiledResult.Component,
	layer_numbers: Dictionary[String, int],
	layers: Dictionary[int, GraphLayoutLayer],
) -> void:
	
	for object in component.get_topologically_ordered_graph():
		var object_layer = layer_numbers[object.get_name()]
		
		if component.is_dependency_inherited(object):
			layers[object_layer].add_hidden_dependency_if_not_present_yet(object)
		else:
			layers[object_layer].add_visible_dependency_if_not_present_yet(object)
		
		for dependency in object.get_dependencies():
			var dependency_layer = layer_numbers[dependency.get_name()]
			
			if component.is_dependency_inherited(dependency):
				layers[dependency_layer].add_hidden_dependency_if_not_present_yet(dependency)
			else:
				layers[dependency_layer].add_visible_dependency_if_not_present_yet(dependency)
			
			var in_between_layer = dependency_layer + 1
			while object_layer - in_between_layer > 0:
				if component.is_dependency_inherited(dependency):
					layers[in_between_layer].add_hidden_cross_layer_link(object, dependency)
				else:
					layers[in_between_layer].add_visible_cross_layer_link(object, dependency)
				in_between_layer += 1


func _init(
	component: GodDaggerParsingResult.CompiledResult.Component,
) -> void:
	
	var layer_numbers: Dictionary[String, int] = {}
	var layers: Dictionary[int, GraphLayoutLayer] = {}
	
	_resolve_layering_for_component(component, layer_numbers, layers)
	_populate_layers_with_dependencies(component, layer_numbers, layers)
	
	# TODO simply sort dependencies in each layer by:
	#  1. all dependencies that belong to the component first (maybe minimizing edge overlaps)
	#  2. then each subcomponent's dependencies (maybe minimizing edge overlaps?), with each subcomponent being sorted alphabetically
	
	for layer_number in range(layers.keys().size()):
		_layers.append(layers[layer_number])
	
	for index in _layers.size():
		_layers[index].print_contents(index)


func get_layers() -> Array[GraphLayoutLayer]:
	return _layers


class GraphLayoutLayer extends RefCounted:
	
	var _visible_dependencies := GodDaggerParsingResult.CompiledResult.DependencyArray.new()
	var _hidden_dependencies := GodDaggerParsingResult.CompiledResult.DependencyArray.new()
	var _visible_cross_layer_links: Array[CrossLayerLink] = []
	var _hidden_cross_layer_links: Array[CrossLayerLink] = []
	
	func get_visible_dependencies() -> GodDaggerParsingResult.CompiledResult.DependencyArray:
		return _visible_dependencies
	
	func add_visible_dependency_if_not_present_yet(
		dependency: GodDaggerParsingResult.CompiledResult.Dependency
	) -> void:
		for other_dependency in _visible_dependencies:
			if dependency == other_dependency:
				return
		
		_visible_dependencies.add_dependency(dependency)
	
	func get_hidden_dependencies() -> GodDaggerParsingResult.CompiledResult.DependencyArray:
		return _hidden_dependencies
	
	func add_hidden_dependency_if_not_present_yet(
		dependency: GodDaggerParsingResult.CompiledResult.Dependency
	) -> void:
		for other_dependency in _hidden_dependencies:
			if dependency == other_dependency:
				return
		
		_hidden_dependencies.add_dependency(dependency)
	
	func get_total_dependencies_amount() -> int:
		return _visible_dependencies.size() + _hidden_dependencies.size()
	
	func get_visible_cross_layer_links() -> Array[CrossLayerLink]:
		return _visible_cross_layer_links
	
	func add_visible_cross_layer_link(
		object: GodDaggerParsingResult.CompiledResult.Dependency,
		dependency: GodDaggerParsingResult.CompiledResult.Dependency,
	) -> void:
		
		_visible_cross_layer_links.append(CrossLayerLink.new(object, dependency))
	
	func get_hidden_cross_layer_links() -> Array[CrossLayerLink]:
		return _hidden_cross_layer_links
	
	func add_hidden_cross_layer_link(
		object: GodDaggerParsingResult.CompiledResult.Dependency,
		dependency: GodDaggerParsingResult.CompiledResult.Dependency,
	) -> void:
		
		_hidden_cross_layer_links.append(CrossLayerLink.new(object, dependency))
	
	func get_total_cross_layer_links_amount() -> int:
		return _visible_cross_layer_links.size() + _hidden_cross_layer_links.size()
	
	func print_contents(layer: int) -> void:
		print("At layer %s%s%s%s%s" % [
			layer,
			"" if _visible_dependencies.size() == 0 else ", visible: %s" % [
				", ".join(
					_visible_dependencies.map(
						func (dependency: GodDaggerParsingResult.CompiledResult.Dependency) -> String: \
							return dependency.get_name()
						)
				)
			],
			"" if _hidden_dependencies.size() == 0 else ", hidden: %s" % [
				", ".join(
					_hidden_dependencies.map(
						func (dependency: GodDaggerParsingResult.CompiledResult.Dependency) -> String: \
							return dependency.get_name()
						)
				)
			],
			"" if _visible_cross_layer_links.is_empty() else " (Visible crossings: %s)" % [
				", ".join(
					_visible_cross_layer_links.map(
						func (cross_layer_link: CrossLayerLink) -> String: \
							return "%s to %s" % [
								cross_layer_link.get_dependency().get_name(),
								cross_layer_link.get_object().get_name(),
							]
					)
				)
			],
			"" if _hidden_cross_layer_links.is_empty() else " (Hidden crossings: %s)" % [
				", ".join(
					_hidden_cross_layer_links.map(
						func (cross_layer_link: CrossLayerLink) -> String: \
							return "%s to %s" % [
								cross_layer_link.get_dependency().get_name(),
								cross_layer_link.get_object().get_name(),
							]
					)
				)
			]
		])


class CrossLayerLink extends RefCounted:
	
	var _object: GodDaggerParsingResult.CompiledResult.Dependency
	var _dependency: GodDaggerParsingResult.CompiledResult.Dependency
	
	func _init(
		object: GodDaggerParsingResult.CompiledResult.Dependency,
		dependency: GodDaggerParsingResult.CompiledResult.Dependency,
	) -> void:
		
		_object = object
		_dependency = dependency
	
	func get_object() -> GodDaggerParsingResult.CompiledResult.Dependency:
		return _object
	
	func get_dependency() -> GodDaggerParsingResult.CompiledResult.Dependency:
		return _dependency
	
