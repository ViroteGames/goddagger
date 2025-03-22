@tool
class_name GodDaggerMainPanel extends GraphEdit


var _property_list: Array[Dictionary] = []
var _default_values: Dictionary = {}
var _current_values: Dictionary = {}

var _dependency_graph_panel := DependencyGraphPanel.new(self)


func _react_to_main_screen_change(screen_name: String) -> void:
	if not screen_name == GodDaggerViewConstants.GODDAGGER_MAIN_PANEL_TITLE:
		return
	
	_update_visible_parsing_result(
		GodDaggerComponentsParser \
			._build_dependency_graph_by_parsing_project_files()
			._compile(),
	)
	
	var uno := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Uno", "file_path",
	)
	var dos := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Dos", "file_path",
	)
	var tres := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Tres", "file_path",
	)
	var cuatro := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Cuatro", "file_path",
	)
	var cinco := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Cinco", "file_path",
	)
	var seis := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Seis", "file_path",
	)
	var siete := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Siete", "file_path",
	)
	var ocho := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Ocho", "file_path",
	)
	var nueve := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Nueve", "file_path",
	)
	var diez := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Diez", "file_path",
	)
	var once := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Once", "file_path",
	)
	var doce := GodDaggerParsingResult.CompiledResult.Dependency.new(
		"Doce", "file_path",
	)
	
	uno.add_dependency(tres)
	uno.add_dependency(cuatro)
	dos.add_dependency(seis)
	tres.add_dependency(dos)
	tres.add_dependency(siete)
	tres.add_dependency(ocho)
	cuatro.add_dependency(cinco)
	cuatro.add_dependency(seis)
	cuatro.add_dependency(ocho)
	cuatro.add_dependency(nueve)
	seis.add_dependency(diez)
	siete.add_dependency(diez)
	siete.add_dependency(once)
	ocho.add_dependency(siete)
	nueve.add_dependency(once)
	diez.add_dependency(doce)
	once.add_dependency(doce)
	
	var component = GodDaggerParsingResult.CompiledResult.Component.new(
		"name", "file_path",
		[
			"12", "11", "10", "09", "07", "06", "08", "05", "02", "03", "04", "01",
		],
		{
			"01": uno,
			"02": dos,
			"03": tres,
			"04": cuatro,
			"05": cinco,
			"06": seis,
			"07": siete,
			"08": ocho,
			"09": nueve,
			"10": diez,
			"11": once,
			"12": doce,
		}
	)


func _update_visible_parsing_result(parsing_result: GodDaggerParsingResult.CompiledResult) -> void:
	_property_list.clear()
	_dependency_graph_panel.clear()
	
	for component in parsing_result.get_components():
		_populate_property_list_for_component(component)
		_dependency_graph_panel.draw_graph_for_component(component)
	
	for subcomponent in parsing_result.get_subcomponents():
		_populate_property_list_for_component(subcomponent)
		_dependency_graph_panel.draw_graph_for_component(subcomponent)
	
	_current_values = _default_values.duplicate()
	notify_property_list_changed()
	EditorInterface.get_inspector().edit(self)


func _populate_property_list_for_component(
	component: GodDaggerParsingResult.CompiledResult.Component,
) -> void:
	
	_property_list.append({
		"name": 		component.get_name().capitalize(),
		"type": 		TYPE_NIL,
		"usage": 		PROPERTY_USAGE_CATEGORY,
		"hint_string":	"%s%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
		],
	})
	_property_list.append({
		"name":			GodDaggerConstants.GODDAGGER_INSPECTOR_TITLE_PROPERTIES,
		"type":			TYPE_NIL,
		"usage":		PROPERTY_USAGE_GROUP,
		"hint_string":	"%s%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
		],
	})
	
	var scope_property_name = "%s%s%s" % [
		GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
		component.get_name().to_pascal_case(),
		GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SCOPE_SUFFIX,
	]
	_property_list.append({
		"name":			scope_property_name,
		"type":			TYPE_OBJECT,
		"usage":		PROPERTY_USAGE_DEFAULT,
		"hint_string":	GodDaggerConstants.BASE_GODDAGGER_SCOPE_NAME,
	})
	_default_values[scope_property_name] = component.get_scope()
	
	var modules_property_name = "%s%s%s" % [
		GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
		component.get_name().to_pascal_case(),
		GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_MODULES_SUFFIX,
	]
	_property_list.append({
		"name":			modules_property_name,
		"type":			TYPE_ARRAY,
		"usage":		PROPERTY_USAGE_DEFAULT,
		"hint_string":	GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME,
	})
	_default_values[modules_property_name] = component.get_modules()
	
	for module in component.get_modules():
		_property_list.append({
			"name":			module.get_name().capitalize(),
			"type":			TYPE_NIL,
			"usage":		PROPERTY_USAGE_SUBGROUP,
			"hint_string":	"%s%s/%s" % [
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
				component.get_name().to_pascal_case(),
				module.get_name().to_pascal_case(),
			],
		})
		
		# TODO see how can this property be reused across multiple components with same module!
		var subcomponent_links_property_name = "%s%s/%s%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
			module.get_name().to_pascal_case(),
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SUBCOMPONENT_LINKS_SUFFIX,
		]
		_property_list.append({
			"name":			subcomponent_links_property_name,
			"type":			TYPE_ARRAY,
			"usage":		PROPERTY_USAGE_DEFAULT,
			"hint_string":	GodDaggerConstants.BASE_GODDAGGER_SUBCOMPONENT_NAME,
		})
		_default_values[subcomponent_links_property_name] = module.get_linked_subcomponents()
		
		var provisions_property_name = "%s%s/%s%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
			module.get_name().to_pascal_case(),
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PROVISIONS_SUFFIX,
		]
		_property_list.append({
			"name":			provisions_property_name,
			"type":			TYPE_ARRAY,
			"usage":		PROPERTY_USAGE_DEFAULT,
		})
		var provision_dependents: Array[GodDaggerParsingResult.CompiledResult.Dependency] = []
		module.get_provisions().map(
			func(provision): provision_dependents.append(provision.get_dependent())
		)
		_default_values[provisions_property_name] = provision_dependents
		
		for provision in module.get_provisions():
			var provision_scope_property_name = "%s%s/%s%s/%s" % [
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
				component.get_name().to_pascal_case(),
				module.get_name().to_pascal_case(),
				provision.get_dependent().get_name().to_pascal_case(),
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SCOPE_SUFFIX,
			]
			_property_list.append({
				"name":			provision_scope_property_name,
				"type":			TYPE_OBJECT,
				"usage":		PROPERTY_USAGE_DEFAULT,
				"hint_string":	GodDaggerConstants.BASE_GODDAGGER_SCOPE_NAME,
			})
			_default_values[provision_scope_property_name] = provision.get_scope()
			
			var provision_dependencies_property_name = "%s%s/%s%s/%s" % [
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
				component.get_name().to_pascal_case(),
				module.get_name().to_pascal_case(),
				provision.get_dependent().get_name().to_pascal_case(),
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_DEPENDENCIES_SUFFIX,
			]
			_property_list.append({
				"name":			provision_dependencies_property_name,
				"type":			TYPE_ARRAY,
				"usage":		PROPERTY_USAGE_DEFAULT,
			})
			_default_values[provision_dependencies_property_name] = provision.get_dependencies()
	
		var module_summary_property_name = "%s%s/%s%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
			module.get_name().to_pascal_case(),
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SUMMARY_SUFFIX,
		]
		_property_list.append({
			"name":			module_summary_property_name,
			"type":			TYPE_OBJECT,
			"usage":		PROPERTY_USAGE_DEFAULT,
			"hint_string":	GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME,
		})
		_default_values[module_summary_property_name] = module
	
	var exposed_dependencies_property_name = "%s%s%s" % [
		GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
		component.get_name().to_pascal_case(),
		GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_EXPOSED_DEPENDENCIES_SUFFIX,
	]
	_property_list.append({
		"name":			exposed_dependencies_property_name,
		"type":			TYPE_ARRAY,
		"usage":		PROPERTY_USAGE_DEFAULT,
	})
	_default_values[exposed_dependencies_property_name] = component.get_exposed_dependencies()
	
	if component is GodDaggerParsingResult.CompiledResult.Subcomponent:
		var linking_modules_property_name = "%s%s%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SUBCOMPONENT_LINKING_MODULES_SUFFIX,
		]
		_property_list.append({
			"name":			linking_modules_property_name,
			"type":			TYPE_ARRAY,
			"usage":		PROPERTY_USAGE_DEFAULT,
			"hint_string":	GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME,
		})
		var linking_modules: Array[GodDaggerParsingResult.CompiledResult.Module] = []
		component.get_linked_parents().map(
			func(linked_parent): linking_modules.append(linked_parent.get_linking_module())
		)
		_default_values[linking_modules_property_name] = linking_modules
	
	var summary_property_name = "%s%s%s" % [
		GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
		component.get_name().to_pascal_case(),
		GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SUMMARY_SUFFIX,
	]
	_property_list.append({
		"name":			summary_property_name,
		"type":			TYPE_OBJECT,
		"usage":		PROPERTY_USAGE_DEFAULT,
		"hint_string":	GodDaggerConstants.BASE_GODDAGGER_SUBCOMPONENT_NAME \
			if component is GodDaggerParsingResult.CompiledResult.Subcomponent \
			else GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME,
	})
	_default_values[summary_property_name] = component
	
	if component is GodDaggerParsingResult.CompiledResult.Subcomponent:
		_property_list.append({
			"name":			GodDaggerConstants.GODDAGGER_INSPECTOR_TITLE_INHERITED_GRAPH,
			"type":			TYPE_NIL,
			"usage":		PROPERTY_USAGE_GROUP,
			"hint_string":	"%s%s" % [
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
				component.get_name().to_pascal_case(),
			],
		})
		
		for object in component.get_topologically_ordered_graph():
			if not component.is_dependency_inherited(object):
				continue
			
			var object_scope_property_name = "%s%s%s/%s" % [
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
				component.get_name().to_pascal_case(),
				object.get_name().to_pascal_case(),
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SCOPE_SUFFIX,
			]
			_property_list.append({
				"name":			object_scope_property_name,
				"type":			TYPE_OBJECT,
				"usage":		PROPERTY_USAGE_DEFAULT,
				"hint_string":	GodDaggerConstants.BASE_GODDAGGER_SCOPE_NAME,
			})
			_default_values[object_scope_property_name] = object.get_scope()
			
			var dependencies_property_name = "%s%s%s/%s" % [
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
				component.get_name().to_pascal_case(),
				object.get_name().to_pascal_case(),
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_DEPENDENCIES_SUFFIX,
			]
			_property_list.append({
				"name":			dependencies_property_name,
				"type":			TYPE_ARRAY,
				"usage":		PROPERTY_USAGE_DEFAULT,
			})
			_default_values[dependencies_property_name] = object.get_dependencies()
			
			var object_summary_property_name = "%s%s%s/%s" % [
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
				component.get_name().to_pascal_case(),
				object.get_name().to_pascal_case(),
				GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SUMMARY_SUFFIX,
			]
			_property_list.append({
				"name":			object_summary_property_name,
				"type":			TYPE_OBJECT,
				"usage":		PROPERTY_USAGE_DEFAULT,
			})
			_default_values[object_summary_property_name] = object
	
	_property_list.append({
		"name":			GodDaggerConstants.GODDAGGER_INSPECTOR_TITLE_GRAPH,
		"type":			TYPE_NIL,
		"usage":		PROPERTY_USAGE_GROUP,
		"hint_string":	"%s%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
		],
	})
	
	for object in component.get_topologically_ordered_graph():
		if component.is_dependency_inherited(object):
			continue
		
		var object_scope_property_name = "%s%s%s/%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
			object.get_name().to_pascal_case(),
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SCOPE_SUFFIX,
		]
		_property_list.append({
			"name":			object_scope_property_name,
			"type":			TYPE_OBJECT,
			"usage":		PROPERTY_USAGE_DEFAULT,
			"hint_string":	GodDaggerConstants.BASE_GODDAGGER_SCOPE_NAME,
		})
		_default_values[object_scope_property_name] = object.get_scope()
		
		var dependencies_property_name = "%s%s%s/%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
			object.get_name().to_pascal_case(),
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_DEPENDENCIES_SUFFIX,
		]
		_property_list.append({
			"name":			dependencies_property_name,
			"type":			TYPE_ARRAY,
			"usage":		PROPERTY_USAGE_DEFAULT,
		})
		_default_values[dependencies_property_name] = object.get_dependencies()
		
		var object_summary_property_name = "%s%s%s/%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
			object.get_name().to_pascal_case(),
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SUMMARY_SUFFIX,
		]
		_property_list.append({
			"name":			object_summary_property_name,
			"type":			TYPE_OBJECT,
			"usage":		PROPERTY_USAGE_DEFAULT,
		})
		_default_values[object_summary_property_name] = object


func _is_relevant_property(property_name: StringName) -> bool:
	return property_name.begins_with(GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX)


func _get(property_name: StringName) -> Variant:
	if _is_relevant_property(property_name):
		return _current_values[property_name]
	
	return null


func _set(property_name: StringName, value: Variant) -> bool:
	var is_relevant_property := _is_relevant_property(property_name)
	
	if is_relevant_property:
		_current_values[property_name] = value
		# TODO alter the object stored at the summary property accordingly
	
	return is_relevant_property


func _get_property_list() -> Array[Dictionary]:
	return _property_list


func _property_can_revert(property_name: StringName) -> bool:
	# TODO do not allow revert of summary properties
	return _is_relevant_property(property_name)


func _property_get_revert(property_name: StringName) -> Variant:
	if _is_relevant_property(property_name) and _default_values.has(property_name):
		return _default_values[property_name]
	
	return null


func _validate_property(property: Dictionary) -> void:
	if property.name.contains(GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX):
		return
	elif property.hint_string.contains(GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX):
		return
	
	#property.usage = PROPERTY_USAGE_NO_EDITOR
