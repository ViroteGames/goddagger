@tool
class_name GodDaggerMainPanel extends Node


var _object_graph_node_scene := \
	preload(GodDaggerViewConstants.OBJECT_GRAPH_NODE_SCENE_PATH)
var _sidepanel_details_item_scene := \
	preload(GodDaggerViewConstants.SIDEPANEL_DETAILS_ITEM_SCENE_PATH)


@onready var _graph_relationships_side_panel_scene := \
	get_node(GodDaggerViewConstants.GRAPH_RELATIONSHIPS_SIDE_PANEL_NODE_PATH)
@onready var _graph_objects_side_panel_scene := \
	get_node(GodDaggerViewConstants.GRAPH_OBJECTS_SIDE_PANEL_NODE_PATH)
@onready var _dependency_graph_scene := \
	get_node(GodDaggerViewConstants.DEPENDENCY_GRAPH_PANEL_NODE_PATH)


func _ready() -> void:
	var generated_components := GodDaggerComponentsParser._get_components()
	
	_on_parse_results_updated(
		generated_components._get_component_relationships_graph(),
		generated_components._get_components_to_objects_graphs(),
	)


func _on_parse_results_updated(
	component_relationships_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary,
) -> void:
	for definition_name in component_relationships_graph.get_topological_order():
		print("'%s' definition exists in the component relationships graph." % definition_name)
	
	for component_name in components_to_objects_graphs.keys():
		print("'%s' has the following objects in topological order:" % component_name)
		
		var objects_graph: GodDaggerGraph = components_to_objects_graphs[component_name]
		
		for object in objects_graph.get_topological_order():
			if object == component_name:
				continue
			
			elif component_relationships_graph.has_graph_vertex(object):
				var subcomponent_scope = component_relationships_graph.get_vertex_tag(
					object, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG
				)
				
				var component_scope = component_relationships_graph.get_vertex_tag(
					component_name, GodDaggerConstants.GODDAGGER_GRAPH_VERTEX_SCOPE_TAG
				)
				
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
