class_name GodDaggerParsingResult extends RefCounted


var _component_relationships_graph: GodDaggerGraph
var _components_to_dependencies_graphs: Dictionary
var _parse_error: String


func _init(
	component_relationships_graph: GodDaggerGraph,
	components_to_dependencies_graphs: Dictionary,
	parse_error: String = "",
) -> void:
	
	self._component_relationships_graph = component_relationships_graph
	self._components_to_dependencies_graphs = components_to_dependencies_graphs
	self._parse_error = parse_error


func _compile() -> CompiledResult:
	return GodDaggerParsingResult._compile_results(
		self._component_relationships_graph,
		self._components_to_dependencies_graphs,
		self._parse_error,
	)


class CompiledResult extends RefCounted:
	
	var _components: Array[Component] = []
	var _subcomponents: Array[Subcomponent] = []
	var _modules: Array[Module] = []
	var _dependencies: Array[Dependency] = []
	var _parse_error: String
	
	func _init(
		components: Array[Component],
		subcomponents: Array[Subcomponent],
		modules: Array[Module],
		dependencies: Array[Dependency],
		parse_error: String,
	) -> void:
		
		self._components = components
		self._subcomponents = subcomponents
		self._modules = modules
		self._dependencies = dependencies
		self._parse_error = parse_error
	
	func get_components() -> Array[Component]:
		return self._components
	
	func get_subcomponents() -> Array[Subcomponent]:
		return self._subcomponents
	
	func get_modules() -> Array[Module]:
		return self._modules
	
	func get_dependencies() -> Array[Dependency]:
		return self._dependencies
	
	func get_parse_error() -> String:
		if not self._parse_error.is_empty():
			return self._parse_error
		
		for component in self._components:
			var component_parse_error := component.get_parse_error()
			
			if not component_parse_error.is_empty():
				return "%s: %s" % [component.get_name(), component_parse_error]
		
		for subcomponent in self._subcomponents:
			var subcomponent_parse_error := subcomponent.get_parse_error()
			
			if not subcomponent_parse_error.is_empty():
				return "%s: %s" % [subcomponent.get_name(), subcomponent_parse_error]
		
		for module in self._modules:
			var module_parse_error := module.get_parse_error()
			
			if not module_parse_error.is_empty():
				return "%s: %s" % [module.get_name(), module_parse_error]
		
		for dependency in self._dependencies:
			var dependency_parse_error := dependency.get_parse_error()
			
			if not dependency_parse_error.is_empty():
				return "%s: %s" % [dependency.get_name(), dependency_parse_error]
		
		return ""
	
	
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
	
	
	class CompiledElement extends ParsedElement:
		
		func _init(
			name: String,
			file_path: String,
			parse_error: String = "",
		) -> void:
			
			super._init(name, file_path, parse_error)
	
	
	class Scope extends CompiledElement:
		
		func _init(
			name: String,
			file_path: String,
		) -> void:
			
			super._init(name, file_path)
	
	
	class Precomponent extends ParsedElement:
		
		var _scope: Scope
		var _modules: Array[String]
		var _exposed_dependencies: Array[String]
		
		func get_scope() -> Scope:
			return self._scope
		
		func set_scope(scope: Scope) -> void:
			self._scope = scope
		
		func get_modules() -> Array[String]:
			return self._modules
		
		func add_module(module_name: String) -> void:
			self._modules.append(module_name)
		
		func get_exposed_dependencies() -> Array[String]:
			return self._exposed_dependencies
		
		func add_exposed_dependency(dependency_name: String) -> void:
			self._exposed_dependencies.append(dependency_name)
		
		func precompile(
			ordered_dependency_names: Array,
			dependencies_map: Dictionary[String, Dependency],
		) -> Component:
			var component := Component.new(
				self._name,
				self._file_path,
				ordered_dependency_names,
				dependencies_map,
				self._parse_error,
			)
			component.set_scope(self._scope)
			return component
	
	
	class Component extends CompiledElement:
		
		var _scope: Scope
		var _modules: Array[Module]
		var _exposed_dependencies: Array[Dependency]
		var _topologically_ordered_graph: Array[Dependency]
		
		func _init(
			name: String,
			file_path: String,
			ordered_dependency_names: Array,
			dependencies_map: Dictionary[String, Dependency],
			parse_error: String = "",
		) -> void:
			super._init(name, file_path, parse_error)
			
			for dependency_name in ordered_dependency_names:
				_topologically_ordered_graph.append(dependencies_map[dependency_name])
		
		func get_scope() -> Scope:
			return self._scope
		
		func set_scope(scope: Scope) -> void:
			self._scope = scope
		
		func get_modules() -> Array[Module]:
			return self._modules
		
		func add_module(module: Module) -> void:
			self._modules.append(module)
		
		func get_exposed_dependencies() -> Array[Dependency]:
			return self._exposed_dependencies
		
		func add_exposed_dependency(dependency: Dependency) -> void:
			self._exposed_dependencies.append(dependency)
		
		func get_topologically_ordered_graph() -> Array[Dependency]:
			return self._topologically_ordered_graph
		
		func set_topologically_ordered_graph(graph: Array[Dependency]) -> void:
			self._topologically_ordered_graph = graph
	
	
	class Presubcomponent extends Precomponent:
		
		var _linked_parent_components: Array[LinkedParentPrecomponent]
		
		func get_linked_parents() -> Array[LinkedParentPrecomponent]:
			return self._linked_parent_components
		
		func add_linked_parent(parent_component: LinkedParentPrecomponent) -> void:
			self._linked_parent_components.append(parent_component)
		
		func precompile(
			ordered_dependency_names: Array,
			dependencies_map: Dictionary[String, Dependency],
		) -> Subcomponent:
			var subcomponent := Subcomponent.new(
				self._name,
				self._file_path,
				ordered_dependency_names,
				dependencies_map,
				self._parse_error,
			)
			subcomponent.set_scope(self._scope)
			return subcomponent
		
		class LinkedParentPrecomponent extends RefCounted:
			
			var _component_name: String
			var _linking_module_name: String
			
			func _init(component_name: String, linking_module_name: String) -> void:
				self._component_name = component_name
				self._linking_module_name = linking_module_name
			
			func get_component() -> String:
				return self._component_name
			
			func get_linking_module() -> String:
				return self._linking_module_name
	
	
	class Subcomponent extends Component:
		
		var _linked_parent_components: Array[LinkedParentComponent]
		
		func get_linked_parents() -> Array[LinkedParentComponent]:
			return self._linked_parent_components
		
		func add_linked_parent(parent_component: LinkedParentComponent) -> void:
			self._linked_parent_components.append(parent_component)
		
		func is_dependency_inherited(dependency: Dependency) -> bool:
			for linked_parent in _linked_parent_components:
				var component = linked_parent.get_component()
				
				if component.get_topologically_ordered_graph().has(dependency):
					return true
				
				elif component is Subcomponent:
					if component.is_dependency_inherited(dependency):
						return true
			
			return false
		
		class LinkedParentComponent extends RefCounted:
			
			var _component: Component
			var _linking_module: Module
			
			func _init(component: Component, linking_module: Module) -> void:
				self._component = component
				self._linking_module = linking_module
			
			func get_component() -> Component:
				return self._component
			
			func get_linking_module() -> Module:
				return self._linking_module
	
	
	class Premodule extends ParsedElement:
		
		var _dependent_component_names: Array[String]
		var _linked_subcomponent_names: Array[String]
		var _provisions: Array[Preprovision]
		
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
		
		func get_provisions() -> Array[Preprovision]:
			return self._provisions
		
		func add_provision(provision: Preprovision) -> void:
			self._provisions.append(provision)
		
		func precompile() -> Module:
			var module := Module.new(
				self._name,
				self._file_path,
				self._parse_error,
			)
			return module
		
		class Preprovision extends RefCounted:
			
			var _name: String
			var _scope: Scope
			var _dependencies: Array[String]
			
			func _init(
				name: String,
			) -> void:
				
				self._name = name
			
			func get_name() -> String:
				return self._name
			
			func get_scope() -> Scope:
				return _scope
			
			func set_scope(scope: Scope) -> void:
				self._scope = scope
			
			func get_dependencies() -> Array[String]:
				return _dependencies
			
			func add_dependency(dependency: String) -> void:
				self._dependencies.append(dependency)
	
	
	class Module extends CompiledElement:
		
		var _dependent_components: Array[Component]
		var _linked_subcomponents: Array[Subcomponent]
		var _provisions: Array[Provision]
		
		func _init(
			name: String,
			file_path: String,
			parse_error: String = "",
		) -> void:
			
			super._init(name, file_path, parse_error)
		
		func get_dependent_components() -> Array[Component]:
			return self._dependent_components
		
		func add_dependent_component(component: Component) -> void:
			self._dependent_components.append(component)
		
		func get_linked_subcomponents() -> Array[Subcomponent]:
			return self._linked_subcomponents
		
		func add_linked_subcomponent(subcomponent: Subcomponent) -> void:
			self._linked_subcomponents.append(subcomponent)
		
		func get_provisions() -> Array[Provision]:
			return self._provisions
		
		func add_provision(provision: Provision) -> void:
			self._provisions.append(provision)
		
		
		class Provision extends RefCounted:
			
			var _dependent: Dependency
			var _scope: Scope
			var _dependencies: Array[Dependency]
			
			func _init(
				dependent: Dependency,
			) -> void:
				
				self._dependent = dependent
			
			func get_dependent() -> Dependency:
				return self._dependent
			
			func get_scope() -> Scope:
				return _scope
			
			func set_scope(scope: Scope) -> void:
				self._scope = scope
			
			func get_dependencies() -> Array[Dependency]:
				return _dependencies
			
			func add_dependency(dependency: Dependency) -> void:
				self._dependencies.append(dependency)
	
	
	class Predependency extends ParsedElement:
		
		var _provision_module: String
		var _dependencies: Array[String]
		var _scope: Scope
		
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
		
		func get_scope() -> Scope:
			return self._scope
		
		func set_scope(scope: Scope) -> void:
			self._scope = scope
		
		func precompile() -> Dependency:
			var dependency := Dependency.new(
				self._name,
				self._file_path,
				self._parse_error,
			)
			dependency.set_scope(self._scope)
			return dependency
	
	
	class Dependency extends CompiledElement:
		
		var _provision_module: Module
		var _dependencies: Array[Dependency]
		var _scope: Scope
		
		func _init(
			name: String,
			file_path: String,
			parse_error: String = "",
		) -> void:
			
			super._init(name, file_path, parse_error)
		
		func get_provision_module() -> Module:
			return self._provision_module
		
		func set_provision_module(provision_module: Module) -> void:
			self._provision_module = provision_module
		
		func get_dependencies() -> Array[Dependency]:
			return self._dependencies
		
		func add_dependency(dependency: Dependency) -> void:
			self._dependencies.append(dependency)
		
		func get_scope() -> Scope:
			return self._scope
		
		func set_scope(scope: Scope) -> void:
			self._scope = scope


static func _parse_component(
	component_relationships_graph: GodDaggerGraph,
	component_to_dependencies_graph: GodDaggerGraph,
	component_name: String,
	file_path: String,
) -> CompiledResult.Precomponent:
	
	var component := CompiledResult.Precomponent.new(component_name, file_path)
	
	var scope_name := component_relationships_graph.get_vertex_tag(
		component_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
	)
	
	if scope_name:
		var scope_file_path := component_relationships_graph.get_vertex_tag(
			component_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_FILE_PATH_TAG,
		)
		var scope := CompiledResult.Scope.new(scope_name, scope_file_path)
		component.set_scope(scope)
	
	for used_module in component_relationships_graph.get_incoming_vertices(component_name):
		component.add_module(used_module)
	
	for exposed_dependency in component_to_dependencies_graph.get_incoming_vertices(component_name):
		component.add_exposed_dependency(exposed_dependency)
	
	return component


static func _parse_subcomponent(
	component_relationships_graph: GodDaggerGraph,
	component_to_dependencies_graph: GodDaggerGraph,
	subcomponent_name: String,
	file_path: String,
) -> CompiledResult.Presubcomponent:
	
	var subcomponent := CompiledResult.Presubcomponent.new(subcomponent_name, file_path)
	
	var scope_name := component_relationships_graph.get_vertex_tag(
		subcomponent_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
	)
	
	if scope_name:
		var scope_file_path := component_relationships_graph.get_vertex_tag(
			subcomponent_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_FILE_PATH_TAG,
		)
		var scope := CompiledResult.Scope.new(scope_name, scope_file_path)
		subcomponent.set_scope(scope)
	
	for linking_module in component_relationships_graph.get_outgoing_vertices(subcomponent_name):
		for parent_component in component_relationships_graph.get_outgoing_vertices(linking_module):
			subcomponent.add_linked_parent(
				CompiledResult.Presubcomponent.LinkedParentPrecomponent \
					.new(parent_component, linking_module)
			)
	
	for used_module in component_relationships_graph.get_incoming_vertices(subcomponent_name):
		subcomponent.add_module(used_module)
	
	for exposed_dependency in component_to_dependencies_graph.get_incoming_vertices(subcomponent_name):
		subcomponent.add_exposed_dependency(exposed_dependency)
	
	return subcomponent


static func _parse_module(
	component_relationships_graph: GodDaggerGraph,
	components_to_dependencies_graphs: Dictionary,
	module_name: String,
	file_path: String,
) -> CompiledResult.Premodule:
	
	var module := CompiledResult.Premodule.new(module_name, file_path)
	
	for linked_subcomponent in component_relationships_graph.get_incoming_vertices(module_name):
		module.add_linked_subcomponent(linked_subcomponent)
	
	for dependent_component in component_relationships_graph.get_outgoing_vertices(module_name):
		module.add_dependent_component(dependent_component)
		
		var component_to_dependencies_graph: GodDaggerGraph = \
			components_to_dependencies_graphs[dependent_component]
		
		for object in component_to_dependencies_graph.get_outgoing_vertices(module_name):
			var provision := CompiledResult.Premodule.Preprovision.new(object)
			
			var object_scope_name = component_to_dependencies_graph.get_vertex_tag(
				object, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
			)
			
			if object_scope_name:
				var object_scope_file_path := component_relationships_graph.get_vertex_tag(
					object, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_FILE_PATH_TAG,
				)
				var object_scope := CompiledResult.Scope.new(
					object_scope_name, object_scope_file_path
				)
				provision.set_scope(object_scope)
			
			for dependency in component_to_dependencies_graph.get_incoming_vertices(object):
				if dependency == module_name:
					continue
				
				provision.add_dependency(dependency)
			
			module.add_provision(provision)
	
	return module


static func _parse_dependency(
	component_relationships_graph: GodDaggerGraph,
	component_to_dependencies_graph: GodDaggerGraph,
	module_names: Array[String],
	object_name: String,
) -> CompiledResult.Predependency:
	
	var file_path := component_to_dependencies_graph.get_vertex_tag(
		object_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_FILE_PATH_TAG,
	)
	
	var object := CompiledResult.Predependency.new(object_name, file_path)
	
	for dependency in component_to_dependencies_graph.get_incoming_vertices(object_name):
		if module_names.has(dependency):
			object.set_provision_module(dependency)
		
		else:
			object.add_dependency(dependency)
	
	var scope_name := component_to_dependencies_graph.get_vertex_tag(
		object_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
	)
	
	if scope_name:
		var scope_file_path := component_to_dependencies_graph.get_vertex_tag(
			object_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_FILE_PATH_TAG,
		)
		
		var scope := CompiledResult.Scope.new(scope_name, scope_file_path)
		object.set_scope(scope)
	
	return object


static func _parse_elements(
	component_relationships_graph: GodDaggerGraph,
	components_to_dependencies_graphs: Dictionary,
	ordered_component_names: Array[String],
	precomponents_map: Dictionary[String, CompiledResult.Precomponent],
	ordered_subcomponent_names: Array[String],
	presubcomponents_map: Dictionary[String, CompiledResult.Presubcomponent],
	ordered_module_names: Array[String],
	premodules_map: Dictionary[String, CompiledResult.Premodule],
	ordered_dependency_names: Dictionary[String, Array],
	predependencies_map: Dictionary[String, CompiledResult.Predependency],
) -> void:
	
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
				ordered_component_names.append(definition_name)
				precomponents_map[definition_name] = _parse_component(
					component_relationships_graph,
					components_to_dependencies_graphs[definition_name],
					definition_name,
					file_path,
				)
			
			GodDaggerConstants.BASE_GODDAGGER_SUBCOMPONENT_NAME:
				ordered_subcomponent_names.append(definition_name)
				presubcomponents_map[definition_name] = _parse_subcomponent(
					component_relationships_graph,
					components_to_dependencies_graphs[definition_name],
					definition_name,
					file_path,
				)
			
			GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME:
				ordered_module_names.append(definition_name)
				premodules_map[definition_name] = _parse_module(
					component_relationships_graph,
					components_to_dependencies_graphs,
					definition_name,
					file_path,
				)
	
	for component_name in components_to_dependencies_graphs.keys():
		var dependencies_graph: GodDaggerGraph = components_to_dependencies_graphs[component_name]
		
		ordered_dependency_names[component_name] = []
		
		for dependency_name in dependencies_graph.get_topological_order():
			if component_relationships_graph.has_graph_vertex(dependency_name):
				continue
			
			ordered_dependency_names[component_name].append(dependency_name)
			
			# TODO if dependency has different qualifier, let it be processed here!
			if predependencies_map.has(dependency_name):
				continue
			
			predependencies_map[dependency_name] = _parse_dependency(
				component_relationships_graph,
				components_to_dependencies_graphs[component_name],
				premodules_map.keys(),
				dependency_name,
			)


static func _compile_dependencies_and_modules(
	ordered_dependency_names: Dictionary[String, Array],
	predependencies_map: Dictionary[String, CompiledResult.Predependency],
	dependencies_map: Dictionary[String, CompiledResult.Dependency],
	premodules_map: Dictionary[String, CompiledResult.Premodule],
	modules_map: Dictionary[String, CompiledResult.Module],
) -> void:
	
	for component_name in ordered_dependency_names.keys():
		for object_name in ordered_dependency_names[component_name]:
			# TODO if dependency has different qualifier, let it be processed here!
			if dependencies_map.has(object_name):
				continue
			
			var preobject: CompiledResult.Predependency = predependencies_map[object_name]
			var object: CompiledResult.Dependency = preobject.precompile()
			
			dependencies_map[object_name] = object
			
			for dependency_name in preobject.get_dependencies():
				object.add_dependency(dependencies_map[dependency_name])
			
			var provision_module_name: String = preobject.get_provision_module()
			
			if provision_module_name:
				var premodule: CompiledResult.Premodule = premodules_map[provision_module_name]
				
				if not modules_map.has(provision_module_name):
					modules_map[provision_module_name] = premodule.precompile()
				
				var module: CompiledResult.Module = modules_map[provision_module_name]
				
				for preprovision in premodule.get_provisions():
					if preprovision.get_name() == object_name:
						var provision := CompiledResult.Module.Provision.new(object)
						provision.set_scope(preprovision.get_scope())
						
						for dependency_name in preprovision.get_dependencies():
							provision.add_dependency(dependencies_map[dependency_name])
						
						module.add_provision(provision)
						object.set_provision_module(module)


static func _compile_components(
	ordered_component_names: Array[String],
	precomponents_map: Dictionary[String, CompiledResult.Precomponent],
	components_map: Dictionary[String, CompiledResult.Component],
	premodules_map: Dictionary[String, CompiledResult.Premodule],
	modules_map: Dictionary[String, CompiledResult.Module],
	ordered_dependency_names: Dictionary[String, Array],
	dependencies_map: Dictionary[String, CompiledResult.Dependency],
) -> void:
	
	for component_name in ordered_component_names:
		var precomponent: CompiledResult.Precomponent = precomponents_map[component_name]
		var component: CompiledResult.Component = precomponent.precompile(
			ordered_dependency_names[component_name], dependencies_map,
		)
		
		for module_name in precomponent.get_modules():
			if not modules_map.has(module_name):
				modules_map[module_name] = premodules_map[module_name].precompile()
			
			var module: CompiledResult.Module = modules_map[module_name]
			module.add_dependent_component(component)
			component.add_module(module)
		
		for exposed_dependency_name in precomponent.get_exposed_dependencies():
			component.add_exposed_dependency(dependencies_map[exposed_dependency_name])
		
		components_map[component_name] = component


static func _compile_subcomponents(
	ordered_subcomponent_names: Array[String],
	presubcomponents_map: Dictionary[String, CompiledResult.Presubcomponent],
	subcomponents_map: Dictionary[String, CompiledResult.Subcomponent],
	components_map: Dictionary[String, CompiledResult.Component],
	premodules_map: Dictionary[String, CompiledResult.Premodule],
	modules_map: Dictionary[String, CompiledResult.Module],
	ordered_dependency_names: Dictionary[String, Array],
	dependencies_map: Dictionary[String, CompiledResult.Dependency],
) -> void:
	
	for subcomponent_name in ordered_subcomponent_names:
		var presubcomponent: CompiledResult.Presubcomponent = \
			presubcomponents_map[subcomponent_name]
		var subcomponent: CompiledResult.Subcomponent = presubcomponent.precompile(
			ordered_dependency_names[subcomponent_name], dependencies_map,
		)
		
		for module_name in presubcomponent.get_modules():
			if not modules_map.has(module_name):
				modules_map[module_name] = premodules_map[module_name].precompile()
			
			var module: CompiledResult.Module = modules_map[module_name]
			module.add_dependent_component(subcomponent)
			subcomponent.add_module(module)
		
		for linked_parent_precomponent in presubcomponent.get_linked_parents():
			var component_name = linked_parent_precomponent.get_component()
			var module_name = linked_parent_precomponent.get_linking_module()
			
			var component: CompiledResult.Component = components_map[component_name]
			
			if not modules_map.has(module_name):
				modules_map[module_name] = premodules_map[module_name].precompile()
			
			var module: CompiledResult.Module = modules_map[module_name]
			module.add_linked_subcomponent(subcomponent)
			
			var linked_parent_component := CompiledResult.Subcomponent \
				.LinkedParentComponent.new(component, module)
			subcomponent.add_linked_parent(linked_parent_component)
		
		for exposed_dependency_name in presubcomponent.get_exposed_dependencies():
			subcomponent.add_exposed_dependency(dependencies_map[exposed_dependency_name])
		
		subcomponents_map[subcomponent_name] = subcomponent


static func _compile_elements(
	ordered_component_names: Array[String],
	precomponents_map: Dictionary[String, CompiledResult.Precomponent],
	components_map: Dictionary[String, CompiledResult.Component],
	ordered_subcomponent_names: Array[String],
	presubcomponents_map: Dictionary[String, CompiledResult.Presubcomponent],
	subcomponents_map: Dictionary[String, CompiledResult.Subcomponent],
	ordered_module_names: Array[String],
	premodules_map: Dictionary[String, CompiledResult.Premodule],
	modules_map: Dictionary[String, CompiledResult.Module],
	ordered_dependency_names: Dictionary[String, Array],
	predependencies_map: Dictionary[String, CompiledResult.Predependency],
	dependencies_map: Dictionary[String, CompiledResult.Dependency],
) -> void:
	
	_compile_dependencies_and_modules(
		ordered_dependency_names, predependencies_map, dependencies_map,
		premodules_map, modules_map,
	)
	
	_compile_components(
		ordered_component_names, precomponents_map, components_map,
		premodules_map, modules_map, ordered_dependency_names, dependencies_map,
	)
	
	_compile_subcomponents(
		ordered_subcomponent_names, presubcomponents_map, subcomponents_map,
		components_map, premodules_map, modules_map, ordered_dependency_names, dependencies_map,
	)


static func _compile_results(
	component_relationships_graph: GodDaggerGraph,
	components_to_dependencies_graphs: Dictionary,
	parse_error: String,
) -> CompiledResult:
	
	var ordered_component_names: Array[String] = []
	var ordered_subcomponent_names: Array[String] = []
	var ordered_module_names: Array[String] = []
	var ordered_dependency_names: Dictionary[String, Array] = {}
	
	var precomponents_map: Dictionary[String, CompiledResult.Precomponent] = {}
	var presubcomponents_map: Dictionary[String, CompiledResult.Presubcomponent] = {}
	var premodules_map: Dictionary[String, CompiledResult.Premodule] = {}
	var predependencies_map: Dictionary[String, CompiledResult.Predependency] = {}
	
	_parse_elements(
		component_relationships_graph,
		components_to_dependencies_graphs,
		ordered_component_names, precomponents_map,
		ordered_subcomponent_names, presubcomponents_map,
		ordered_module_names, premodules_map,
		ordered_dependency_names, predependencies_map,
	)
	
	var components_map: Dictionary[String, CompiledResult.Component] = {}
	var subcomponents_map: Dictionary[String, CompiledResult.Subcomponent] = {}
	var modules_map: Dictionary[String, CompiledResult.Module] = {}
	var dependencies_map: Dictionary[String, CompiledResult.Dependency] = {}
	
	_compile_elements(
		ordered_component_names, precomponents_map, components_map,
		ordered_subcomponent_names, presubcomponents_map, subcomponents_map,
		ordered_module_names, premodules_map, modules_map,
		ordered_dependency_names, predependencies_map, dependencies_map,
	)
	
	var ordered_components: Array[CompiledResult.Component] = []
	ordered_component_names.map(
		func(name): ordered_components.append(components_map[name])
	)
	var ordered_subcomponents: Array[CompiledResult.Subcomponent] = []
	ordered_subcomponent_names.map(
		func(name): ordered_subcomponents.append(subcomponents_map[name])
	)
	var ordered_modules: Array[CompiledResult.Module] = []
	ordered_module_names.map(
		func(name): ordered_modules.append(modules_map[name])
	)
	var all_dependencies: Array[CompiledResult.Dependency] = []
	for component_name in ordered_dependency_names.keys():
		ordered_dependency_names[component_name].map(
			func(name):
				var dependency := dependencies_map[name]
				if not all_dependencies.has(dependency):
					all_dependencies.append(dependency)
		)
	
	return CompiledResult.new(
		ordered_components,
		ordered_subcomponents,
		ordered_modules,
		all_dependencies,
		parse_error,
	)
