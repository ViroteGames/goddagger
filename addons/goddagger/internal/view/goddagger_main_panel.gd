@tool
class_name GodDaggerMainPanel extends Control


var _property_list: Array[Dictionary] = []
var _default_values: Dictionary = {}
var _current_values: Dictionary = {}


@onready var _graph_relationships_side_panel: VBoxContainer = %GraphRelationshipsSidePanel
@onready var _dependency_graph_panel: GridContainer = %DependencyGraphPanel


func _react_to_main_screen_change(screen_name: String) -> void:
	if not screen_name == GodDaggerViewConstants.GODDAGGER_MAIN_PANEL_TITLE:
		return
	
	_update_visible_parsing_result(
		GodDaggerComponentsParser \
			._build_dependency_graph_by_parsing_project_files()
			._compile(),
	)


func _update_visible_parsing_result(parsing_result: GodDaggerParsingResult.CompiledResult) -> void:
	
	_property_list.clear()
	
	for child in _graph_relationships_side_panel.get_children():
		_graph_relationships_side_panel.remove_child(child)
		child.queue_free()
	
	for child in _dependency_graph_panel.get_children():
		_dependency_graph_panel.remove_child(child)
		child.queue_free()
	
	for component in parsing_result.get_components():
		var component_item_view := SidePanelDetailsItem.Component.spawn(component)
		_graph_relationships_side_panel.add_child(component_item_view)
		
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
			"name":			"Component Properties",
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
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SCOPE_SUFIX,
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
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_MODULES_SUFIX,
		]
		_property_list.append({
			"name":			modules_property_name,
			"type":			TYPE_ARRAY,
			"usage":		PROPERTY_USAGE_DEFAULT,
			"hint_string":	GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME,
		})
		_default_values[modules_property_name] = component.get_modules()
		
		var exposed_dependencies_property_name = "%s%s%s" % [
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX,
			component.get_name().to_pascal_case(),
			GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_EXPOSED_DEPENDENCIES_SUFIX,
		]
		_property_list.append({
			"name":			exposed_dependencies_property_name,
			"type":			TYPE_ARRAY,
			"usage":		PROPERTY_USAGE_DEFAULT,
		})
		_default_values[exposed_dependencies_property_name] = component.get_exposed_dependencies()
	
	for subcomponent in parsing_result.get_subcomponents():
		var subcomponent_item_view := SidePanelDetailsItem.Subcomponent.spawn(subcomponent)
		_graph_relationships_side_panel.add_child(subcomponent_item_view)
	
	for module in parsing_result.get_modules():
		var module_item_view := SidePanelDetailsItem.Module.spawn(module)
		_graph_relationships_side_panel.add_child(module_item_view)
	
	for object in parsing_result.get_dependencies():
		var object_item_view := SidePanelDetailsItem.Dependency.spawn(object)
		_graph_relationships_side_panel.add_child(object_item_view)
	
	var objects_in_reverse_order: Array[GodDaggerParsingResult.CompiledResult.Dependency] = \
		parsing_result.get_dependencies().duplicate()
	objects_in_reverse_order.reverse()
	
	for object in objects_in_reverse_order:
		var object_node_view := ObjectGraphNode.spawn(object.get_name())
		_dependency_graph_panel.add_child(object_node_view)
		_dependency_graph_panel.move_child(object_node_view, 0)
	
	_current_values = _default_values.duplicate()
	notify_property_list_changed()
	EditorInterface.get_inspector().edit(self)


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
	
	return is_relevant_property


func _get_property_list() -> Array[Dictionary]:
	return _property_list


func _property_can_revert(property_name: StringName) -> bool:
	return _is_relevant_property(property_name)


func _property_get_revert(property_name: StringName) -> Variant:
	if _is_relevant_property(property_name) and _default_values.has(property_name):
		return _default_values[property_name]
	
	return null
