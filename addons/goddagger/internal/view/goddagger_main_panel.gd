@tool
class_name GodDaggerMainPanel extends HSplitContainer


var _property_list: Array[Dictionary] = []
var _default_values: Dictionary[String, GodDaggerParsingResult.CompiledResult.ParsedElement] = {}


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
				GodDaggerConstants.RENAMED_GODDAGGER_TOKEN_PREFIX,
				component.get_name().to_pascal_case(),
			],
		})
		_property_list.append({
			"name":			"Component Properties",
			"type":			TYPE_NIL,
			"usage":		PROPERTY_USAGE_GROUP,
			"hint_string":	"%s%s" % [
				GodDaggerConstants.RENAMED_GODDAGGER_TOKEN_PREFIX,
				component.get_name().to_pascal_case(),
			],
		})
		_property_list.append({
			"name":			"%s%s%s" % [
				GodDaggerConstants.RENAMED_GODDAGGER_TOKEN_PREFIX,
				component.get_name().to_pascal_case(),
				"Scope",
			],
			"type":			TYPE_STRING,
			"usage":		PROPERTY_USAGE_DEFAULT,
		})
		set(
			"%s%s%s" % [
				GodDaggerConstants.RENAMED_GODDAGGER_TOKEN_PREFIX,
				component.get_name().to_pascal_case(),
				"Scope",
			],
			component.get_scope(),
		)
		_property_list.append({
			"name":			"%s%s%s" % [
				GodDaggerConstants.RENAMED_GODDAGGER_TOKEN_PREFIX,
				component.get_name().to_pascal_case(),
				"Modules",
			],
			"type":			TYPE_STRING,
			"usage":		PROPERTY_USAGE_DEFAULT,
		})
		_property_list.append({
			"name":			"%s%s%s" % [
				GodDaggerConstants.RENAMED_GODDAGGER_TOKEN_PREFIX,
				component.get_name().to_pascal_case(),
				"ExposedObjects",
			],
			"type":			TYPE_STRING,
			"usage":		PROPERTY_USAGE_DEFAULT,
		})
	
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
	
	notify_property_list_changed()
	EditorInterface.get_inspector().edit(self)


func _get_property_list() -> Array[Dictionary]:
	return _property_list


func _property_can_revert(property_name: StringName) -> bool:
	return property_name.begins_with(GodDaggerConstants.RENAMED_GODDAGGER_TOKEN_PREFIX)


#func _property_get_revert(property: StringName) -> Variant:
#	
