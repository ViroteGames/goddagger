@tool
class_name GodDaggerMainPanel extends HSplitContainer


var _object_graph_node_scene := \
	preload(GodDaggerViewConstants.OBJECT_GRAPH_NODE_SCENE_PATH)


@onready var _graph_relationships_side_panel := \
	$"GraphRelationshipsSidePanel/MarginContainer/VBoxContainer"
@onready var _dependency_graph_panel := $"DependencyGraphPanel"


func _react_to_main_screen_change(screen_name: String) -> void:
	if not screen_name == GodDaggerViewConstants.GODDAGGER_MAIN_PANEL_TITLE:
		return
	
	_update_visible_parsing_result(
		GodDaggerComponentsParser \
			._build_dependency_graph_by_parsing_project_files()
			.compile(),
	)


func _update_visible_parsing_result(parsing_result: GodDaggerParsingResult.CompiledResult) -> void:
	for child in _graph_relationships_side_panel.get_children():
		_graph_relationships_side_panel.remove_child(child)
		child.queue_free()
	
	for component in parsing_result.get_components():
		var component_item_view := SidePanelDetailsItem.Component.spawn(component)
		_graph_relationships_side_panel.add_child(component_item_view)
	
	for subcomponent in parsing_result.get_subcomponents():
		var subcomponent_item_view := SidePanelDetailsItem.Subcomponent.spawn(subcomponent)
		_graph_relationships_side_panel.add_child(subcomponent_item_view)
	
	for module in parsing_result.get_modules():
		var module_item_view := SidePanelDetailsItem.Module.spawn(module)
		_graph_relationships_side_panel.add_child(module_item_view)
	
	for object in parsing_result.get_objects():
		var object_item_view := SidePanelDetailsItem.ObjectType.spawn(object)
		_graph_relationships_side_panel.add_child(object_item_view)
