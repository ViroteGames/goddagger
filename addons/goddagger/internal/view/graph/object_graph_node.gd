@tool
class_name ObjectGraphNode extends GraphNode


var _object: GodDaggerParsingResult.CompiledResult.Dependency
var _link_nodes: Dictionary[String, Array] = {}


@onready var _scope_view := %Scope


func _get_link_node_name(dependency_name: String, index: int) -> String:
	return "%sTo%sPart%s" % [dependency_name, _object.get_name(), index]


func _establish_link_connections(graph_canvas: GraphEdit, dependency_name: String) -> void:
	graph_canvas.disconnect_node(dependency_name, 0, _object.get_name(), 0)
	
	for link_node_index in _link_nodes[dependency_name].size():
		var link_node: LinkGraphNode = _link_nodes[dependency_name][link_node_index]
		var link_node_name := _get_link_node_name(dependency_name, link_node_index)
		
		graph_canvas.disconnect_node(dependency_name, 0, link_node_name, 0)
		graph_canvas.disconnect_node(link_node_name, 0, _object.get_name(), 0)
		
		for next_link_index in range(link_node_index, _link_nodes[dependency_name].size() - 1):
			var next_link_node_name := _get_link_node_name(dependency_name, next_link_index)
			graph_canvas.disconnect_node(link_node_name, 0, next_link_node_name, 0)
		
		if link_node_index == 0:
			link_node.get_dependency_node().set_slot_enabled_right(0, true)
			graph_canvas.connect_node(dependency_name, 0, link_node_name, 0)
		
		if link_node_index == _link_nodes[dependency_name].size() - 1:
			set_slot_enabled_left(0, true)
			graph_canvas.connect_node(link_node_name, 0, _object.get_name(), 0)
			graph_canvas.connect_node(link_node_name, 0, link_node_name, 0)
		
		if link_node_index < _link_nodes[dependency_name].size() - 1:
			var next_link_node_name := _get_link_node_name(dependency_name, link_node_index + 1)
			graph_canvas.connect_node(link_node_name, 0, next_link_node_name, 0)
			graph_canvas.connect_node(link_node_name, 0, link_node_name, 0)


func populated_with(
	object: GodDaggerParsingResult.CompiledResult.Dependency,
) -> ObjectGraphNode:
	
	_object = object
	name = _object.get_name()
	title = _object.get_name()
	return self


func _ready() -> void:
	_scope_view.text = _object.get_scope().get_name() if _object.get_scope() else "<unscoped>"


func get_object_name() -> String:
	return _object.get_name()


func add_link_node(
	graph_canvas: GraphEdit,
	link_node: LinkGraphNode,
) -> void:
	
	var dependency_name: String = link_node.get_dependency_node().get_object_name()
	
	if not dependency_name in _link_nodes:
		_link_nodes[dependency_name] = []
	
	if _link_nodes[dependency_name].size() >= 2:
		var last_link_node: LinkGraphNode = _link_nodes[dependency_name][-1]
		var second_last_link_node: LinkGraphNode = _link_nodes[dependency_name][-2]
		
		if last_link_node.is_very_next_vertically(link_node) \
				and second_last_link_node.is_very_next_vertically(last_link_node):
			
			_link_nodes[dependency_name].pop_back()
			graph_canvas.remove_child(last_link_node)
			last_link_node.queue_free()
	
	link_node.name = _get_link_node_name(
		dependency_name,
		_link_nodes[dependency_name].size()
	)
	_link_nodes[dependency_name].append(link_node)
	graph_canvas.add_child(link_node)
	
	_establish_link_connections(graph_canvas, dependency_name)


func get_and_clear_link_nodes() -> Array[LinkGraphNode]:
	var link_nodes: Array[LinkGraphNode] = []
	
	for dependency_name in _link_nodes:
		while not _link_nodes[dependency_name].is_empty():
			var link_node := _link_nodes[dependency_name].pop_back()
			link_nodes.append(link_node)
	
	return link_nodes


static var _object_graph_node_scene := preload(GodDaggerViewConstants.OBJECT_GRAPH_NODE_SCENE_PATH)


static func spawn(
	object: GodDaggerParsingResult.CompiledResult.Dependency,
) -> ObjectGraphNode:
	
	return ObjectGraphNode \
		._object_graph_node_scene \
		.instantiate() \
		.populated_with(
			object,
		)
