class_name GodDaggerParsingResult extends RefCounted


func get_component_relationships_graph() -> GodDaggerGraph:
	assert(false, "This method should have been overriden!")
	return GodDaggerGraph.new("Void")


func get_components_to_objects_graphs() -> Dictionary:
	assert(false, "This method should have been overriden!")
	return {}


class CompiledResult extends RefCounted:
	
	var _components: Array[Component] = []
	var _subcomponents: Array[Subcomponent] = []
	var _modules: Array[Module] = []
	var _objects: Array[ObjectType] = []
	
	func _init(
		components: Array[Component],
		subcomponents: Array[Subcomponent],
		modules: Array[Module],
		objects: Array[ObjectType],
	) -> void:
		
		self._components = components
		self._subcomponents = subcomponents
		self._modules = modules
		self._objects = objects
	
	func get_components() -> Array[Component]:
		return self._components
	
	func get_subcomponents() -> Array[Subcomponent]:
		return self._subcomponents
	
	func get_modules() -> Array[Module]:
		return self._modules
	
	func get_objects() -> Array[ObjectType]:
		return self._objects
	
	
	class ParsedElement extends RefCounted:
		
		var _name: String
		var _file_path: String
		var _parse_error: String
		
		func _init(
			name: String,
			file_path: String,
			parse_error: String = ""
		) -> void:
			
			self._name = name
			self._file_path = file_path
			self._parse_error = parse_error
		
		func get_name() -> String:
			return self._name
		
		func get_file_path() -> String:
			return self._file_path
		
		func get_parse_error() -> String:
			return self._parse_error
	
	
	class Component extends ParsedElement:
		
		var _scope: String
		var _modules: Array[String]
		var _exposed_objects: Array[String]
		
		func _init(
			name: String,
			file_path: String,
			scope: String,
			parse_error: String = "",
		) -> void:
			
			super._init(name, file_path, parse_error)
			self._scope = scope
		
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
	
	
	class Subcomponent extends Component:
		
		var _linked_parent_components: Array[LinkedParentComponent]
		
		func _init(
			name: String,
			file_path: String,
			scope: String,
			parse_error: String = "",
		) -> void:
			
			super._init(name, file_path, scope, parse_error)
		
		func get_linked_parents() -> Array[LinkedParentComponent]:
			return self._linked_parent_components
		
		func add_linked_parent(parent_component: LinkedParentComponent) -> void:
			self._linked_parent_components.append(parent_component)
		
		
		class LinkedParentComponent extends RefCounted:
			
			var _component_name: String
			var _linking_module_name: String
			
			func _init(component_name: String, linking_module_name: String) -> void:
				self._component_name = component_name
				self._linking_module_name = linking_module_name
			
			func get_component() -> String:
				return self._component_name
			
			func get_linking_module() -> String:
				return self._linking_module_name
	
	
	class Module extends ParsedElement:
		
		var _dependent_component_names: Array[String]
		var _linked_subcomponent_names: Array[String]
		var _provisions: Array[Provision]
		
		func _init(
			name: String,
			file_path: String,
			parse_error: String = "",
		) -> void:
			
			super._init(name, file_path, parse_error)
		
		func get_dependent_components() -> Array[String]:
			return self._dependent_component_names
		
		func add_dependent_component(component_name: String) -> void:
			self._dependent_component_names.append(component_name)
		
		func get_linked_subcomponents() -> Array[String]:
			return self._linked_subcomponent_names
		
		func add_linked_subcomponent(subcomponent_name: String) -> void:
			self._linked_subcomponent_names.append(subcomponent_name)
		
		func get_provisions() -> Array[Provision]:
			return self._provisions
		
		func add_provision(provision: Provision) -> void:
			self._provisions.append(provision)
		
		
		class Provision extends RefCounted:
			
			var _name: String
			var _scope: String
			var _dependencies: Array[String]
			
			func _init(
				name: String,
			) -> void:
				
				self._name = name
			
			func get_name() -> String:
				return self._name
			
			func get_scope() -> String:
				return _scope
			
			func set_scope(scope: String) -> void:
				self._scope = scope
			
			func get_dependencies() -> Array[String]:
				return _dependencies
			
			func add_dependency(dependency: String) -> void:
				self._dependencies.append(dependency)
	
	
	class ObjectType extends ParsedElement:
		
		var _provision_module: String
		var _dependencies: Array[String]
		var _scope: String
		
		func _init(
			name: String,
			file_path: String,
			parse_error: String = "",
		) -> void:
			
			super._init(name, file_path, parse_error)
		
		func get_provision_module() -> String:
			return self._provision_module
		
		func set_provision_module(provision_module: String) -> void:
			self._provision_module = provision_module
		
		func get_dependencies() -> Array[String]:
			return self._dependencies
		
		func add_dependency(dependency: String) -> void:
			self._dependencies.append(dependency)
		
		func get_scope() -> String:
			return self._scope
		
		func set_scope(scope: String) -> void:
			self._scope = scope


func compile() -> CompiledResult:
	var component_relationships_graph: GodDaggerGraph = get_component_relationships_graph()
	var components_to_objects_graphs: Dictionary = get_components_to_objects_graphs()
	
	return GodDaggerParsingResult.compile_results(
		component_relationships_graph, components_to_objects_graphs,
	)


static func compile_component(
	component_relationships_graph: GodDaggerGraph,
	component_to_objects_graph: GodDaggerGraph,
	component_name: String,
	file_path: String,
) -> CompiledResult.Component:
	
	var scope := component_relationships_graph.get_vertex_tag(
		component_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
	)
	
	var component := CompiledResult.Component.new(component_name, file_path, scope)
	
	for used_module in component_relationships_graph.get_incoming_vertices(component_name):
		component.add_module(used_module)
	
	for exposed_object in component_to_objects_graph.get_incoming_vertices(component_name):
		component.add_exposed_object(exposed_object)
	
	return component


static func compile_subcomponent(
	component_relationships_graph: GodDaggerGraph,
	component_to_objects_graph: GodDaggerGraph,
	subcomponent_name: String,
	file_path: String,
) -> CompiledResult.Subcomponent:
	
	var scope := component_relationships_graph.get_vertex_tag(
		subcomponent_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
	)
	
	var subcomponent := CompiledResult.Subcomponent.new(subcomponent_name, file_path, scope)
	
	for linking_module in component_relationships_graph.get_outgoing_vertices(subcomponent_name):
		for parent_component in component_relationships_graph.get_outgoing_vertices(linking_module):
			subcomponent.add_linked_parent(
				CompiledResult.Subcomponent.LinkedParentComponent \
					.new(parent_component, linking_module)
			)
	
	for used_module in component_relationships_graph.get_incoming_vertices(subcomponent_name):
		subcomponent.add_module(used_module)
	
	for exposed_object in component_to_objects_graph.get_incoming_vertices(subcomponent_name):
		subcomponent.add_exposed_object(exposed_object)
	
	return subcomponent


static func compile_module(
	component_relationships_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary,
	module_name: String,
	file_path: String,
) -> CompiledResult.Module:
	
	var module := CompiledResult.Module.new(module_name, file_path)
	
	for linked_subcomponent in component_relationships_graph.get_incoming_vertices(module_name):
		module.add_linked_subcomponent(linked_subcomponent)
	
	for dependent_component in component_relationships_graph.get_outgoing_vertices(module_name):
		module.add_dependent_component(dependent_component)
		
		var component_to_objects_graph: GodDaggerGraph = \
			components_to_objects_graphs[dependent_component]
		
		for provided_object in component_to_objects_graph.get_outgoing_vertices(module_name):
			var provision := CompiledResult.Module.Provision.new(provided_object)
			
			var provided_object_scope = component_to_objects_graph.get_vertex_tag(
				provided_object, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
			)
			
			if provided_object_scope:
				provision.set_scope(provided_object_scope)
			
			for dependency in component_to_objects_graph.get_incoming_vertices(provided_object):
				if dependency == module_name:
					continue
				
				provision.add_dependency(dependency)
			
			module.add_provision(provision)
	
	return module


static func compile_object(
	component_relationships_graph: GodDaggerGraph,
	component_to_objects_graph: GodDaggerGraph,
	module_names: Array[String],
	object_name: String,
) -> CompiledResult.ObjectType:
	
	var file_path := component_to_objects_graph.get_vertex_tag(
		object_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_FILE_PATH_TAG,
	)
	
	var object := CompiledResult.ObjectType.new(object_name, file_path)
	
	for dependency in component_to_objects_graph.get_incoming_vertices(object_name):
		if module_names.has(dependency):
			object.set_provision_module(dependency)
		
		else:
			object.add_dependency(dependency)
	
	var scope := component_to_objects_graph.get_vertex_tag(
		object_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
	)
	
	if scope:
		object.set_scope(scope)
	
	return object


static func compile_results(
	component_relationships_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary,
) -> CompiledResult:
	
	var components: Array[CompiledResult.Component] = []
	var subcomponents: Array[CompiledResult.Subcomponent] = []
	var modules: Array[CompiledResult.Module] = []
	var objects: Array[CompiledResult.ObjectType] = []
	
	var relationship_definitions := component_relationships_graph.get_topological_order()
	relationship_definitions.reverse()
	
	for definition_name in relationship_definitions:
		var definition := component_relationships_graph.get_vertex_tag(
			definition_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_DEFINITION_TAG,
		)
		var file_path := component_relationships_graph.get_vertex_tag(
			definition_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_FILE_PATH_TAG,
		)
		
		match definition:
			GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME:
				components.append(
					compile_component(
						component_relationships_graph,
						components_to_objects_graphs[definition_name],
						definition_name,
						file_path,
					)
				)
			
			GodDaggerConstants.BASE_GODDAGGER_SUBCOMPONENT_NAME:
				subcomponents.append(
					compile_subcomponent(
						component_relationships_graph,
						components_to_objects_graphs[definition_name],
						definition_name,
						file_path,
					)
				)
			
			GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME:
				modules.append(
					compile_module(
						component_relationships_graph,
						components_to_objects_graphs,
						definition_name,
						file_path,
					)
				)
	
	var objects_map: Dictionary = {}
	
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
			
			var module_names: Array[String] = []
			modules.map(
				func (module: CompiledResult.Module) -> void:
					module_names.append(module.get_name())
			)
			
			objects_map[object] = compile_object(
				component_relationships_graph,
				components_to_objects_graphs[component_name],
				module_names,
				object,
			)
	
	for object in objects_map.keys():
		objects.append(objects_map[object])
	
	return CompiledResult.new(
		components, subcomponents, modules, objects,
	)
