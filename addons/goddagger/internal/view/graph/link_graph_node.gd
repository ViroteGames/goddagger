@tool
class_name LinkGraphNode extends GraphNode


var _dependency_node: ObjectGraphNode
var _layer_number: int
var _layer_vertical_index: int


func populated_with(
	dependency_node: ObjectGraphNode,
	layer_number: int,
	layer_vertical_index: int,
) -> LinkGraphNode:
	
	_dependency_node = dependency_node
	_layer_number = layer_number
	_layer_vertical_index = layer_vertical_index
	return self


func get_dependency_node() -> ObjectGraphNode:
	return _dependency_node


func get_layer_number() -> int:
	return _layer_number


func get_layer_vertical_index() -> int:
	return _layer_vertical_index


func is_very_next_vertically(link_node: LinkGraphNode) -> bool:
	return _layer_number + 1 == link_node.get_layer_number() \
		and _layer_vertical_index == link_node.get_layer_vertical_index()


static var _link_graph_node_scene := preload(GodDaggerViewConstants.LINK_GRAPH_NODE_SCENE_PATH)


static func spawn(
	dependency_node: ObjectGraphNode,
	layer_number: int,
	layer_vertical_index: int,
) -> LinkGraphNode:
	return LinkGraphNode \
		._link_graph_node_scene \
		.instantiate() \
		.populated_with(
			dependency_node,
			layer_number,
			layer_vertical_index,
		)
