class_name GodDaggerComponentsParser extends RefCounted


static var _generated_components: GodDaggerGeneratedComponents


static func _get_components() -> GodDaggerGeneratedComponents:
	var script_name := GodDaggerFileUtils._get_components_file_name()
	var generated_components: GodDaggerGeneratedComponents = load(script_name).new()
	_generated_components = generated_components
	
	return _generated_components


static func _populate_component_objects_graph_by_parsing_arguments(
	component_objects_graph: GodDaggerGraph,
	object_class_name: String,
	arguments: Array[Dictionary],
) -> void:
	
	for argument_index in arguments.size():
		var argument: Dictionary = arguments[argument_index]
		var argument_class: String = argument[GodDaggerConstants.KEY_ARGUMENT_CLASS_NAME]
		
		var dependency_class := GodDaggerObjectResolver._resolve_object_class(argument_class)
		var dependency_file_path := dependency_class.get_resolved_file_path()
		
		var must_check_if_object_is_scoped := argument_index == 0
		
		if must_check_if_object_is_scoped:
			var is_argument_class_a_scope := GodDaggerBaseResolver._is_subclass_of_given_class(
				dependency_class, GodDaggerConstants.BASE_GODDAGGER_SCOPE_NAME,
			)
			
			if is_argument_class_a_scope:
				# TODO when adding support for qualifiers, include this in scoping info as well
				
				# Protect against this scope not matching the component's scope. And, if the
				#  component itself has no scope assigned, then it shall allow no scoped bindings.
				
				component_objects_graph.set_tag_to_vertex(
					object_class_name,
					GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG,
					argument_class,
				)
				continue
		
		# TODO also a good idea to protect from these instances being any GodDagger type
		#   accidentally, such as components, modules or extra scopes
		
		component_objects_graph.declare_graph_vertex(argument_class)
		component_objects_graph.declare_vertices_link(argument_class, object_class_name)
		
		if not GodDaggerFileUtils._is_file_an_interface(dependency_file_path):
			_populate_component_objects_graph_by_parsing_object_constructor(
				component_objects_graph, argument_class,
			)


static func _populate_component_objects_graph_by_parsing_object_constructor(
	component_objects_graph: GodDaggerGraph,
	object_class_name: String,
) -> void:
	
	var object_class := GodDaggerObjectResolver._resolve_object_class(object_class_name)
	
	if component_objects_graph.has_graph_vertex(object_class):
		# No need to populate again, this object_class' dependencies have already been processed.
		return
	
	var resolved_file_path := object_class.get_resolved_file_path()
	
	var error_message := "Could not parse object constructor for '%s'" % object_class_name
	
	assert(
		resolved_file_path != null and not resolved_file_path.is_empty(),
		"%s. (at resolve step)" % error_message,
	)
	
	if GodDaggerFileUtils._is_file_an_interface(resolved_file_path):
		return
	
	error_message = error_message + (" @%s." % resolved_file_path)
	
	var cloned_file_name := object_class_name.to_snake_case()
	
	var cloned_object_script := GodDaggerFileUtils \
		._clone_script_into_generated_directory_renaming_class_name_and_constructor(
			object_class_name,
			resolved_file_path,
			cloned_file_name,
		)
	
	assert(
		cloned_object_script,
		"%s (at clone + constructor rename step)" % error_message,
	)
	
	var cloned_file_path := GodDaggerFileUtils._get_path_for_generated_script(cloned_file_name)
	
	var loaded_script: Object = load(cloned_file_path).new()
	var methods := loaded_script.get_method_list()
	
	for method in methods:
		var method_name: String = method[GodDaggerConstants.KEY_METHOD_NAME]
		
		if method_name == GodDaggerConstants.RENAMED_CONSTRUCTOR_NAME:
			var constructor_arguments: Array[Dictionary] = \
				method[GodDaggerConstants.KEY_METHOD_ARGUMENTS]
			
			_populate_component_objects_graph_by_parsing_arguments(
				component_objects_graph, object_class_name, constructor_arguments,
			)


static func _populate_component_objects_graph_by_parsing_module_method(
	module_classes: Array[GodDaggerBaseResolver.ResolvedClass],
	component_objects_graph: GodDaggerGraph,
	method: Dictionary,
) -> void:
	
	var method_name: String = method[GodDaggerConstants.KEY_METHOD_NAME]
	
	if method_name.begins_with(GodDaggerConstants.DECLARED_PROVIDER_METHOD_PREFIX):
		var provider_method_object_class: String = \
			method[GodDaggerConstants.KEY_METHOD_RETURN] \
			[GodDaggerConstants.KEY_PROPERTY_CLASS_NAME]
		
		component_objects_graph.declare_graph_vertex(provider_method_object_class)
		
		var provider_method_arguments: Array[Dictionary] = \
			method[GodDaggerConstants.KEY_METHOD_ARGUMENTS]
		
		_populate_component_objects_graph_by_parsing_arguments(
			component_objects_graph, provider_method_object_class, provider_method_arguments,
		)


static func _populate_component_objects_graph_by_parsing_module_property(
	module_classes: Array[GodDaggerBaseResolver.ResolvedClass],
	subcomponent_classes: Array[GodDaggerBaseResolver.ResolvedClass],
	components_to_modules_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary,
	component_objects_graph: GodDaggerGraph,
	module_class_name: String,
	property: Dictionary,
) -> void:
	
	var property_name: String = property[GodDaggerConstants.KEY_PROPERTY_NAME]
	
	if property_name.begins_with(GodDaggerConstants.DECLARED_INJECTED_PROPERTY_PREFIX):
		var property_class: String = property[GodDaggerConstants.KEY_PROPERTY_CLASS_NAME]
		
		for subcomponent_class in subcomponent_classes:
			var subcomponent_class_name := subcomponent_class.get_resolved_class_name()
			
			if subcomponent_class_name == property_class:
				var resolved_file_path := subcomponent_class.get_resolved_file_path()
				
				components_to_modules_graph.declare_graph_vertex(subcomponent_class_name)
				components_to_modules_graph.declare_vertices_link(
					subcomponent_class_name, module_class_name,
				)
				components_to_objects_graphs[subcomponent_class_name] = \
					component_objects_graph.fork("%s's Object Graph" % subcomponent_class_name)
				
				var loaded_script: GodDaggerSubcomponent = load(resolved_file_path).new()
				var properties := loaded_script.get_property_list()
				
				component_objects_graph.declare_graph_vertex(subcomponent_class_name)
				
				# TODO parse this subcomponent's scope (if set) and pass this information down.
				# Any subcomponents bound to this subcomponent will be assigned this scope (if set).
				
				for subcomponent_property in properties:
					_populate_graphs_by_parsing_component_property(
						module_classes,
						subcomponent_classes,
						components_to_modules_graph,
						components_to_objects_graphs,
						subcomponent_class_name,
						subcomponent_property,
					)


static func _populate_component_objects_graph_by_parsing_module(
	module_classes: Array[GodDaggerBaseResolver.ResolvedClass],
	subcomponent_classes: Array[GodDaggerBaseResolver.ResolvedClass],
	components_to_modules_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary,
	component_objects_graph: GodDaggerGraph,
	module_class_name: String,
) -> void:
	
	for module_class in module_classes:
		if module_class.get_resolved_class_name() == module_class_name:
			var resolved_file_path := module_class.get_resolved_file_path()
			
			var loaded_script: Object = load(resolved_file_path).new()
			var methods := loaded_script.get_method_list()
			
			for method in methods:
				_populate_component_objects_graph_by_parsing_module_method(
					module_classes,
					component_objects_graph,
					method,
				)
			
			var properties := loaded_script.get_property_list()
			
			for property in properties:
				_populate_component_objects_graph_by_parsing_module_property(
					module_classes,
					subcomponent_classes,
					components_to_modules_graph,
					components_to_objects_graphs,
					component_objects_graph,
					module_class_name,
					property,
				)


static func _populate_graphs_by_parsing_component_property(
	module_classes: Array[GodDaggerBaseResolver.ResolvedClass],
	subcomponent_classes: Array[GodDaggerBaseResolver.ResolvedClass],
	components_to_modules_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary,
	component_class_name: String,
	property: Dictionary,
) -> void:
	
	var property_name: String = property[GodDaggerConstants.KEY_PROPERTY_NAME]
	var property_class: StringName = property[GodDaggerConstants.KEY_PROPERTY_CLASS_NAME]
	
	if property_name.begins_with(GodDaggerConstants.DECLARED_INJECTED_PROPERTY_PREFIX):
		var is_property_class_a_module := GodDaggerBaseResolver \
			._resolved_classes_contains_given_class(module_classes, property_class)
		
		if is_property_class_a_module:
			components_to_modules_graph.declare_vertices_link(
				property_class, component_class_name,
			)
			
			_populate_component_objects_graph_by_parsing_module(
				module_classes, subcomponent_classes, components_to_modules_graph,
				components_to_objects_graphs, components_to_objects_graphs[component_class_name],
				property_class,
			)
		else:
			# TODO good idea to protect against other GodDagger objects being passed here
			#   unintentionally e.g., components, subcomponents, scopes, etc.
			
			components_to_objects_graphs[component_class_name] \
				.declare_graph_vertex(property_class)
			
			_populate_component_objects_graph_by_parsing_object_constructor(
				components_to_objects_graphs[component_class_name], property_class,
			)


static func _build_dependency_graph_by_parsing_project_files() -> bool:
	if not GodDaggerFileUtils._clear_generated_files():
		return false
	
	var component_classes := GodDaggerComponentResolver._resolve_component_classes()
	var subcomponent_classes := GodDaggerComponentResolver._resolve_subcomponent_classes()
	var module_classes := GodDaggerModuleResolver._resolve_module_classes()
	
	var components_to_modules_graph := GodDaggerGraph.new("Boundaries Graph")
	var components_to_objects_graphs: Dictionary = {}
	
	for module_class in module_classes:
		var resolved_class_name := module_class.get_resolved_class_name()
		components_to_modules_graph.declare_graph_vertex(resolved_class_name)
	
	for component_class in component_classes:
		var resolved_class_name := component_class.get_resolved_class_name()
		var resolved_file_path := component_class.get_resolved_file_path()
		
		components_to_modules_graph.declare_graph_vertex(resolved_class_name)
		components_to_objects_graphs[resolved_class_name] = \
			GodDaggerGraph.new("%s's Object Graph" % resolved_class_name)
		
		var loaded_script: GodDaggerComponent = load(resolved_file_path).new()
		var properties := loaded_script.get_property_list()
		
		# TODO parse this component's scope (if set) and pass this information down.
		# Any subcomponents bound to this component will be assigned this scope (again, if set).
		
		for property in properties:
			_populate_graphs_by_parsing_component_property(
				module_classes,
				subcomponent_classes,
				components_to_modules_graph,
				components_to_objects_graphs,
				resolved_class_name,
				property,
			)
	
	for component_name in components_to_objects_graphs.keys():
		print("'%s' has the following objects in topological order:" % component_name)
		
		var objects_graph: GodDaggerGraph = components_to_objects_graphs[component_name]
		
		for object in objects_graph.get_topological_order():
			var tags = objects_graph.get_vertex_tags(object)
			
			if GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG in tags.keys():
				print("Object: %s (scoped to %s)" % [
					object, tags[GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG]
				])
			
			else:
				print("Object: %s (unscoped)" % object)
	
	return GodDaggerFileUtils._generate_script_with_contents(
		GodDaggerConstants.GODDAGGER_GENERATED_COMPONENTS_FILE_NAME,
	"""## Auto-generated by GodDagger. Do not edit this file!
class_name __GodDagger__ExampleComponent extends GodDaggerGeneratedComponents


class _GodDaggerProvider__ElectricHeater extends RefCounted:
	
	func _init() -> void:
		pass
	
	func _obtain() -> ElectricHeater:
		return ElectricHeater.new(null)


class _GodDaggerProvider__Heater extends RefCounted:
	
	var _example_module: ExampleModule
	var _electric_heater_provider: _GodDaggerProvider__ElectricHeater
	
	func _init(
		example_module: ExampleModule,
		electric_heater_provider: _GodDaggerProvider__ElectricHeater,
	) -> void:
		self._example_module = example_module
		self._electric_heater_provider = electric_heater_provider
	
	func _obtain() -> Heater:
		return _example_module.__provide_heater(_electric_heater_provider._obtain())


class _GodDaggerProvider__Thermosiphon extends RefCounted:
	
	var _heater_provider: _GodDaggerProvider__Heater
	
	func _init(
		heater_provider: _GodDaggerProvider__Heater,
	) -> void:
		self._heater_provider = heater_provider
	
	func _obtain() -> Thermosiphon:
		return Thermosiphon.new(_heater_provider._obtain())


class _GodDaggerProvider__Pump extends RefCounted:
	
	var _example_module: ExampleModule
	var _thermosiphon_provider: _GodDaggerProvider__Thermosiphon
	
	func _init(
		example_module: ExampleModule,
		thermosiphon_provider: _GodDaggerProvider__Thermosiphon,
	) -> void:
		self._example_module = example_module
		self._thermosiphon_provider = thermosiphon_provider
	
	func _obtain() -> Pump:
		return _example_module.__provide_pump(_thermosiphon_provider._obtain())


class _GodDaggerProvider__CoffeeMaker extends RefCounted:
	
	var _heater_provider: _GodDaggerProvider__Heater
	var _pump_provider: _GodDaggerProvider__Pump
	
	func _init(
		heater_provider: _GodDaggerProvider__Heater,
		pump_provider: _GodDaggerProvider__Pump,
	) -> void:
		self._heater_provider = heater_provider
		self._pump_provider = pump_provider
	
	func _obtain() -> CoffeeMaker:
		return CoffeeMaker.new(_heater_provider._obtain(), _pump_provider._obtain())


var _electric_heater_provider: _GodDaggerProvider__ElectricHeater
var _heater_provider: _GodDaggerProvider__Heater
var _thermosiphon_provider: _GodDaggerProvider__Thermosiphon
var _pump_provider: _GodDaggerProvider__Pump
var _coffee_maker_provider: _GodDaggerProvider__CoffeeMaker


func _init() -> void:
	var example_module := ExampleModule.new()
	_electric_heater_provider = _GodDaggerProvider__ElectricHeater.new()
	_heater_provider = _GodDaggerProvider__Heater.new(example_module, _electric_heater_provider)
	_thermosiphon_provider = _GodDaggerProvider__Thermosiphon.new(_heater_provider)
	_pump_provider = _GodDaggerProvider__Pump.new(example_module, _thermosiphon_provider)
	_coffee_maker_provider = _GodDaggerProvider__CoffeeMaker.new(_heater_provider, _pump_provider)


func get_coffee_maker() -> CoffeeMaker:
	return _coffee_maker_provider._obtain()
""",
	)
