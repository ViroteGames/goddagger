class_name GodDaggerTemplates extends RefCounted


# TODO probably delete this later. keeping for now because parsing of serialized graphs might still come in handy.
const GODDAGGER_PARSING_RESULT_TEMPLATE := """## Auto-generated by GodDagger. Do not edit this file!
class_name __GodDagger__GeneratedParsingResult extends GodDaggerParsingResult


var _component_relationships_graph: GodDaggerGraph
var _components_to_objects_graphs: Dictionary


func _init() -> void:
	_component_relationships_graph = GodDaggerGraph.build_from_dictionary(%s)
	_components_to_objects_graphs = %s
	for component_name in _components_to_objects_graphs.keys():
		_components_to_objects_graphs[component_name] = GodDaggerGraph.build_from_dictionary(
			_components_to_objects_graphs[component_name]
		)


func get_component_relationships_graph() -> GodDaggerGraph:
	return _component_relationships_graph


func get_components_to_objects_graphs() -> Dictionary:
	return _components_to_objects_graphs
"""
