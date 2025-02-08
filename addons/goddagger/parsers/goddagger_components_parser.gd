class_name GodDaggerComponentsParser extends RefCounted


static var _generated_components: GodDaggerGeneratedComponents


static func _get_components() -> GodDaggerGeneratedComponents:
	var script_name := GodDaggerFileUtils._get_components_file_name()
	var generated_components: GodDaggerGeneratedComponents = load(script_name).new()
	_generated_components = generated_components
	
	return _generated_components


static func _populate_graph_by_parsing_object_constructor_arguments(
	components_to_objects_graphs: Dictionary,
	component_class_name: String,
	object_class_name: String,
	constructor_arguments: Array[Dictionary],
) -> void:
	
	for constructor_argument_index in constructor_arguments.size():
		var constructor_argument: Dictionary = \
			constructor_arguments[constructor_argument_index]
		
		var constructor_argument_class: String = \
			constructor_argument[GodDaggerConstants.KEY_ARGUMENT_CLASS_NAME]
		
		var must_check_if_object_is_scoped := constructor_argument_index == 0
		
		if must_check_if_object_is_scoped:
			var is_constructor_argument_class_a_scope := GodDaggerBaseResolver \
				._is_subclass_of_given_class(
					constructor_argument_class,
					GodDaggerConstants.BASE_GODDAGGER_SCOPE_NAME,
				)
			
			if is_constructor_argument_class_a_scope:
				# TODO this object is scoped! handle this
				continue
		
		# TODO also a good idea to protect from these instances being any GodDagger type
		#   accidentally, such as components, modules or extra scopes
		
		components_to_objects_graphs[component_class_name] \
			.declare_graph_vertex(constructor_argument_class)
		components_to_objects_graphs[component_class_name] \
			.declare_vertices_link(object_class_name, constructor_argument_class)
		
		var dependency_class := GodDaggerObjectResolver \
			._resolve_object_class(constructor_argument_class)
		var dependency_file_path := dependency_class.get_resolved_file_path()
		
		if not GodDaggerFileUtils._is_file_an_interface(dependency_file_path):
			_populate_graph_by_parsing_object_constructor(
				components_to_objects_graphs,
				component_class_name,
				constructor_argument_class,
			)


static func _populate_graph_by_parsing_object_constructor(
	components_to_objects_graphs: Dictionary,
	component_class_name: String,
	object_class_name: String,
) -> void:
	
	var object_class := GodDaggerObjectResolver._resolve_object_class(object_class_name)
	
	if components_to_objects_graphs[component_class_name].has_graph_vertex(object_class):
		# No need to populate again, this object_class' dependencies have already been processed.
		return
	
	var resolved_file_path := object_class.get_resolved_file_path()
	
	var error_message := "Could not parse object constructor for '%s'" % [
		object_class_name, resolved_file_path,
	]
	
	assert(
		resolved_file_path != null and not resolved_file_path.is_empty(),
		"%s. (at resolve step)" % error_message,
	)
	
	if GodDaggerFileUtils._is_file_an_interface(resolved_file_path):
		return
	
	error_message += " @%s." % resolved_file_path
	
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
			
			_populate_graph_by_parsing_object_constructor_arguments(
				components_to_objects_graphs,
				component_class_name,
				object_class_name,
				constructor_arguments,
			)


static func _populate_graphs_by_parsing_component_property(
	module_classes: Array[GodDaggerBaseResolver.ResolvedClass],
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
				component_class_name, property_class,
			)
			
			# TODO parse objects from this module into `components_to_objects_graphs`!
		else:
			# TODO good idea to protect against other GodDagger objects being passed here
			#   unintentionally e.g., components, scopes, etc.
			
			components_to_objects_graphs[component_class_name] \
				.declare_graph_vertex(property_class)
			
			_populate_graph_by_parsing_object_constructor(
				components_to_objects_graphs,
				component_class_name,
				property_class,
			)


static func _build_dependency_graph_by_parsing_project_files() -> bool:
	if not GodDaggerFileUtils._clear_generated_files():
		return false
	
	var component_classes := GodDaggerComponentResolver._resolve_component_classes()
	var module_classes := GodDaggerModuleResolver._resolve_module_classes()
	
	var components_to_modules_graph := GodDaggerGraph.new()
	var components_to_objects_graphs: Dictionary = {}
	
	for module_class in module_classes:
		var resolved_class_name := module_class.get_resolved_class_name()
		var resolved_file_path := module_class.get_resolved_file_path()
		
		components_to_modules_graph.declare_graph_vertex(resolved_class_name)
	
	for component_class in component_classes:
		var resolved_class_name := component_class.get_resolved_class_name()
		var resolved_file_path := component_class.get_resolved_file_path()
		
		components_to_modules_graph.declare_graph_vertex(resolved_class_name)
		components_to_objects_graphs[resolved_class_name] = GodDaggerGraph.new()
		
		var loaded_script: GodDaggerComponent = load(resolved_file_path).new()
		var properties := loaded_script.get_property_list()
		
		for property in properties:
			_populate_graphs_by_parsing_component_property(
				module_classes,
				components_to_modules_graph,
				components_to_objects_graphs,
				resolved_class_name,
				property,
			)
	
	
	return GodDaggerFileUtils._generate_script_with_contents(
		"_goddagger_components",
	"""## Auto-generated by GodDagger. Do not edit this file!
class_name __GodDagger__ExampleComponent extends GodDaggerGeneratedComponents


class _GodDaggerProvider__ElectricHeater extends RefCounted:
	
	func _init() -> void:
		pass
	
	func _obtain() -> ElectricHeater:
		return ElectricHeater.new()


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
