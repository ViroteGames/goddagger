class_name GodDaggerParsingResult extends RefCounted


func get_component_relationships_graph() -> GodDaggerGraph:
	assert(false, "This method should have been overriden!")
	return GodDaggerGraph.new("Void")


func get_components_to_objects_graphs() -> Dictionary:
	assert(false, "This method should have been overriden!")
	return {}


class CompiledResult extends RefCounted:
	
	var _components: Array[Component] = []
	
	func _init(components: Array[Component]) -> void:
		for component in components:
			self._components.append(component)
	
	func get_components() -> Array[Component]:
		return _components
	
	
	class Component extends RefCounted:
		
		var _name: String
		var _file_path: String
		var _scope: String
		var _modules: Array[String]
		var _exposed_objects: Array[String]
		
		func _init(name: String, file_path: String, scope: String) -> void:
			self._name = name
			self._file_path = file_path
			self._scope = scope
		
		func get_name() -> String:
			return self._name
		
		func get_file_path() -> String:
			return self._file_path
		
		func get_scope() -> String:
			return self._scope
		
		func get_modules() -> Array[String]:
			return self._modules
		
		func add_module(module_name: String) -> void:
			self._modules.append(module_name)
		
		func get_exposed_objects() -> Array[String]:
			return self._exposed_objects
		
		func add_exposed_object(object_name: String) -> void:
			self._exposed_objects.append(object_name)


func compile() -> CompiledResult:
	var component_relationships_graph: GodDaggerGraph = get_component_relationships_graph()
	var components_to_objects_graphs: Dictionary = get_components_to_objects_graphs()
	
	return GodDaggerParsingResult.compile_results(
		component_relationships_graph, components_to_objects_graphs,
	)


static func compile_results(
	component_relationships_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary,
) -> CompiledResult:
	
	var components: Array[CompiledResult.Component] = []
	
	for definition_name in component_relationships_graph.get_topological_order():
		var scope := component_relationships_graph.get_vertex_tag(
			definition_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
		)
		var definition := component_relationships_graph.get_vertex_tag(
			definition_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_DEFINITION_TAG,
		)
		var file_path := component_relationships_graph.get_vertex_tag(
			definition_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_FILE_PATH_TAG,
		)
		
		match definition:
			GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME:
				var component := CompiledResult.Component.new(definition_name, file_path, scope)
				
				var component_modules := component_relationships_graph \
					.get_incoming_vertices(definition_name)
				
				for module in component_modules:
					component.add_module(module)
				
				var component_exposed_objects: Array[Variant] = \
					components_to_objects_graphs[definition_name] \
						.get_incoming_vertices(definition_name)
				
				for exposed_object in component_exposed_objects:
					component.add_exposed_object(exposed_object)
				
				components.append(component)
			
			GodDaggerConstants.BASE_GODDAGGER_SUBCOMPONENT_NAME:
				print("'%s' definition is a <Subcomponent>!" % [definition_name])
			
			GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME:
				print("'%s' definition is a <Module>!" % [definition_name])
	
	for component_name in components_to_objects_graphs.keys():
		print("'%s' has the following objects in topological order:" % component_name)
		
		var objects_graph: GodDaggerGraph = components_to_objects_graphs[component_name]
		
		for object in objects_graph.get_topological_order():
			if component_relationships_graph.has_graph_vertex(object):
				var subcomponent_scope = component_relationships_graph.get_vertex_tag(
					object, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG
				)
				
				var component_scope = component_relationships_graph.get_vertex_tag(
					component_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG
				)
				
				if object == component_name:
					print("Component: %s (defines %s scope)" % [
						component_name, component_scope
					])
					continue
				
				var scoped_to: String
				if component_scope:
					scoped_to = "scoped to %s:%s" % [component_name, component_scope]
				else:
					scoped_to = "scoped to %s" % component_name
				
				if subcomponent_scope:
					print(
						"Subcomponent: %s (defines %s scope, %s)" % [
							object, subcomponent_scope, scoped_to
						]
					)
				else:
					print("Subcomponent: %s (%s)" % [object, scoped_to])
				
				continue
			
			var object_scope = objects_graph.get_vertex_tag(
				object, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG
			)
			
			if object_scope:
				print("Object: %s (scoped to %s)" % [object, object_scope])
			
			else:
				print("Object: %s (unscoped)" % object)
	
	return CompiledResult.new(components)
