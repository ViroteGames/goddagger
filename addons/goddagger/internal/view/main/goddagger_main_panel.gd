@tool
class_name GodDaggerMainPanel extends Node


var _object_graph_node_scene := \
	preload(GodDaggerViewConstants.OBJECT_GRAPH_NODE_SCENE_PATH)


@onready var _graph_relationships_side_panel := \
	$"HBoxContainer/GraphRelationshipsSidePanel/MarginContainer/VBoxContainer"
@onready var _graph_objects_side_panel := \
	$"HBoxContainer/GraphObjectsSidePanel/MarginContainer/VBoxContainer"
@onready var _dependency_graph_panel := $"DependencyGraphPanel"


func _ready() -> void:
	var parsing_result := GodDaggerComponentsParser.get_parsing_result()
	
	_on_parse_results_updated(
		parsing_result.get_components(),
	)


func _on_parse_results_updated(
	components: Array[GodDaggerParsingResult.CompiledResult.Component],
) -> void:
	
	for component in components:
		_graph_relationships_side_panel.add_child(SidePanelDetailsItem.Component.spawn(component))
