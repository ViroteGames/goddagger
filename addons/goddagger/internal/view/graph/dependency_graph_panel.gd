class_name DependencyGraphPanel extends RefCounted


var _graph_canvas: GraphEdit
var _graph_nodes: Dictionary[String, ObjectGraphNode] = {}


func _init(graph_canvas: GraphEdit) -> void:
	self._graph_canvas = graph_canvas


func draw_graph_for_component(
	component: GodDaggerParsingResult.CompiledResult.Component,
) -> void:
	
	if not component is GodDaggerParsingResult.CompiledResult.Subcomponent:
		return
	
	var object_graph_layout := ObjectGraphLayout.new(component)
	
	var committed_width := 0
	var committed_height := 0
	var computing_width := 0
	var computing_height := 0
	
	for level in object_graph_layout.get_levels():
		computing_width = 124 + 60
		
		for object in level.get_dependencies():
			computing_height += 164 + 60
			
			var object_node_view := ObjectGraphNode.spawn(object.get_name())
			_graph_nodes[object.get_name()] = object_node_view
		
		committed_width += computing_width
		committed_height = max(computing_height, committed_height)
		
		computing_width = 0
		computing_height = 0
	
	for level_number in object_graph_layout.get_levels().size():
		var level := object_graph_layout.get_levels()[level_number]
		
		for object_index in level.get_dependencies().size():
			var object := level.get_dependencies().get_dependency_at(object_index)
			var object_node_view := _graph_nodes[object.get_name()]
			
			var position: Vector2 = object_node_view.position_offset - Vector2(
				committed_width / 2, committed_height / 2
			) + Vector2(
				level_number * (committed_width / object_graph_layout.get_levels().size()),
				object_index * (committed_height / level.get_dependencies().size()),
			) + Vector2(
				(committed_width / object_graph_layout.get_levels().size()) / 2,
				((committed_height / level.get_dependencies().size()) / 2) - ((committed_height / 4)),
			)
			object_node_view.position_offset = position
			_graph_canvas.add_child(object_node_view)


func clear() -> void:
	var _graph_nodes_array := _graph_nodes.values()
	_graph_nodes.clear()
	
	while not _graph_nodes_array.is_empty():
		var object_node_view := _graph_nodes_array.pop_back()
		_graph_canvas.remove_child(object_node_view)
		object_node_view.queue_free()
