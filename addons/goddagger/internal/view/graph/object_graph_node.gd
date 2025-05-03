@tool
class_name ObjectGraphNode extends GraphNode


func populated_with(
	class_name_text: String,
) -> ObjectGraphNode:
	
	title = class_name_text
	return self


static var _object_graph_node_scene := preload(GodDaggerViewConstants.OBJECT_GRAPH_NODE_SCENE_PATH)


static func spawn(
	class_name_text: String,
) -> ObjectGraphNode:
	
	return ObjectGraphNode \
		._object_graph_node_scene \
		.instantiate() \
		.populated_with(
			class_name_text,
		)
