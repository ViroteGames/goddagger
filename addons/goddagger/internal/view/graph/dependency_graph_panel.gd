class_name DependencyGraphPanel extends RefCounted


var _graph_canvas: GraphEdit
var _graph_nodes: Dictionary[String, ObjectGraphNode] = {}


func _init(graph_canvas: GraphEdit) -> void:
	self._graph_canvas = graph_canvas


func draw_graph_for_component(
	component: GodDaggerParsingResult.CompiledResult.Component,
) -> void:
	
	var object_graph_layout := ObjectGraphLayout.new(component)
	
	var committed_width := 0
	var committed_height := 0
	var computing_width := 0
	var computing_height := 0
	var horizontal_padding := 60
	var vertical_padding := 0
	
	var real_layers_amount := object_graph_layout.get_layers().size()
	var total_layers_amount := real_layers_amount
	
	if total_layers_amount % 2 != 0:
		total_layers_amount += 1
	
	var layout_sizes: Array[int] = []
	layout_sizes.resize(total_layers_amount)
	
	for layer_number in total_layers_amount:
		computing_width = 124 + horizontal_padding
		
		var layer_visible_dependencies := [] if layer_number >= real_layers_amount \
			else object_graph_layout.get_layers()[layer_number].get_visible_dependencies()
		
		for object in layer_visible_dependencies:
			var object_node_view := ObjectGraphNode.spawn(object.get_name())
			_graph_nodes[object.get_name()] = object_node_view
		
		var total_dependencies_amount := 0 if layer_number >= real_layers_amount \
			else object_graph_layout.get_layers()[layer_number].get_total_dependencies_amount()
		var total_cross_layer_links_amount := 0 if layer_number >= real_layers_amount \
			else object_graph_layout.get_layers()[layer_number].get_total_cross_layer_links_amount()
		
		var layer_vertical_size = total_dependencies_amount + total_cross_layer_links_amount
		
		if layer_vertical_size % 2 != 0:
			layer_vertical_size += 1
		
		layout_sizes[layer_number] = layer_vertical_size
		
		computing_height = (164 + vertical_padding) * layer_vertical_size
		
		committed_width += computing_width
		committed_height = max(computing_height, committed_height)
		
		computing_width = 0
		computing_height = 0
	
	for layer_number in layout_sizes.size():
		var layer_vertical_size := layout_sizes[layer_number]
		
		for item_index in layer_vertical_size:
			var layer := object_graph_layout.get_layers()[layer_number]
			
			var object_index := item_index
			var layer_dependencies := layer.get_visible_dependencies()
			
			var link_index := object_index - layer_dependencies.size()
			var layer_cross_links := layer.get_visible_cross_layer_links()
			
			if object_index < layer_dependencies.size():
				var object := layer_dependencies.get_dependency_at(object_index)
				
				var object_node_view := _graph_nodes[object.get_name()]
				object_node_view.position_offset = object_node_view.position_offset \
					- Vector2(
						committed_width / 2,
						committed_height / 2
					) + Vector2(
						layer_number * (committed_width / total_layers_amount),
						item_index * (committed_height / layer_vertical_size),
					) + Vector2(
						(committed_width / total_layers_amount) / 2,
						0,
					)
				
				_graph_canvas.add_child(object_node_view)
			
			elif link_index < layer_cross_links.size():
				# TODO we are ready to draw cross_layer link! replace the drawing below with it.
				
				var object := layer_cross_links[link_index].get_dependency()
				
				var object_node_view := ObjectGraphNode.spawn(object.get_name())
				object_node_view.position_offset = object_node_view.position_offset \
					- Vector2(
						committed_width / 2,
						committed_height / 2
					) + Vector2(
						layer_number * (committed_width / total_layers_amount),
						item_index * (committed_height / layer_vertical_size),
					) + Vector2(
						(committed_width / total_layers_amount) / 2,
						0,
					)
				
				_graph_canvas.add_child(object_node_view)


func clear() -> void:
	var _graph_nodes_array := _graph_nodes.values()
	_graph_nodes.clear()
	
	while not _graph_nodes_array.is_empty():
		var object_node_view := _graph_nodes_array.pop_back()
		
		for child in _graph_canvas.get_children():
			if child == object_node_view:
				_graph_canvas.remove_child(object_node_view)
				break
		
		object_node_view.queue_free()
