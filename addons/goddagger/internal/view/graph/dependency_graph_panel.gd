class_name DependencyGraphPanel extends RefCounted


var _graph_canvas: GraphEdit
var _graph_nodes: Dictionary[String, ObjectGraphNode] = {}


func _init(graph_canvas: GraphEdit) -> void:
	_graph_canvas = graph_canvas


func _connect_graph_nodes(
	object: GodDaggerParsingResult.CompiledResult.Dependency,
	dependency: GodDaggerParsingResult.CompiledResult.Dependency,
) -> void:
	
	_graph_nodes[dependency.get_name()].set_slot_enabled_right(0, true)
	_graph_nodes[object.get_name()].set_slot_enabled_left(0, true)
	_graph_canvas.connect_node(dependency.get_name(), 0, object.get_name(), 0)


func draw_graph_for_component(
	component: GodDaggerParsingResult.CompiledResult.Component,
) -> void:
	
	var object_graph_layout := ObjectGraphLayout.new(component)
	var real_layers_amount := object_graph_layout.get_layers().size()
	
	for layer_number in real_layers_amount:
		var layer_visible_dependencies := [] if layer_number >= real_layers_amount \
			else object_graph_layout.get_layers()[layer_number].get_visible_dependencies()
		
		for object in layer_visible_dependencies:
			var object_node_view := ObjectGraphNode.spawn(object)
			_graph_nodes[object.get_name()] = object_node_view
			
			if not component is GodDaggerParsingResult.CompiledResult.Subcomponent:
				object_node_view.selected = true
		
			_graph_canvas.add_child(object_node_view)
	
	for layer_number in real_layers_amount - 1:
		var layer := object_graph_layout.get_layers()[layer_number]
		var next_layer := object_graph_layout.get_layers()[layer_number + 1]
		
		for dependency in layer.get_visible_dependencies():
			for object in next_layer.get_visible_dependencies():
				if dependency in object.get_dependencies():
					_connect_graph_nodes(object, dependency)
			
			for object in next_layer.get_hidden_dependencies():
				if dependency in object.get_dependencies():
					_connect_graph_nodes(object, dependency)
		
		for dependency in layer.get_hidden_dependencies():
			for object in next_layer.get_visible_dependencies():
				if dependency in object.get_dependencies():
					_connect_graph_nodes(object, dependency)
	
	_graph_canvas.call_deferred("do_draw_object_graph_layout", object_graph_layout)


func do_draw_object_graph_layout(object_graph_layout: ObjectGraphLayout) -> void:
	var real_layers_amount := object_graph_layout.get_layers().size()
	var total_layers_amount := real_layers_amount
	
	if total_layers_amount % 2 != 0:
		total_layers_amount += 1
	
	var layout_sizes: Array[int] = []
	layout_sizes.resize(total_layers_amount)
	
	var committed_width := 0
	var committed_height := 0
	var computing_width := 0
	var computing_height := 0
	var horizontal_padding := 60
	var vertical_padding := 30
	
	for layer_number in total_layers_amount:
		var layer_visible_dependencies := [] if layer_number >= real_layers_amount \
			else object_graph_layout.get_layers()[layer_number].get_visible_dependencies()
		
		for object in layer_visible_dependencies:
			var object_node_width := _graph_nodes[object.get_name()].get_size().x
			computing_width = max(object_node_width, computing_width)
		
		var layer_hidden_dependencies := [] if layer_number >= real_layers_amount \
			else object_graph_layout.get_layers()[layer_number].get_hidden_dependencies()
		
		for object in layer_hidden_dependencies:
			var object_node_width := _graph_nodes[object.get_name()].get_size().x
			computing_width = max(object_node_width, computing_width)
		
		var total_dependencies_amount := 0 if layer_number >= real_layers_amount \
			else object_graph_layout.get_layers()[layer_number].get_total_dependencies_amount()
		var total_cross_layer_links_amount := 0 if layer_number >= real_layers_amount \
			else object_graph_layout.get_layers()[layer_number].get_total_cross_layer_links_amount()
		
		var layer_vertical_size = total_dependencies_amount + total_cross_layer_links_amount
		
		if layer_vertical_size % 2 != 0:
			layer_vertical_size += 1
		
		layout_sizes[layer_number] = layer_vertical_size
		
		computing_width += horizontal_padding
		committed_width += computing_width
		
		# TODO get rid of this hardcoded 102, use dynamically calculated value instead
		computing_height = (102 + vertical_padding) * layer_vertical_size
		committed_height = max(computing_height, committed_height)
		
		computing_width -= horizontal_padding
		computing_height = 0
	
	for layer_number in layout_sizes.size():
		var layer_vertical_size := layout_sizes[layer_number]
		
		for layer_vertical_index in layer_vertical_size:
			var layer := object_graph_layout.get_layers()[layer_number]
			
			var object_index := layer_vertical_index
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
						layer_vertical_index * (committed_height / layer_vertical_size),
					) + Vector2(
						(committed_width / total_layers_amount) / 2,
						0,
					)
				# TODO also centralize this link_node_view within the layer vertical bounds.
			
			elif link_index < layer_cross_links.size():
				var dependency := layer_cross_links[link_index].get_dependency()
				
				var link_node_view := LinkGraphNode.spawn(
					_graph_nodes[dependency.get_name()], layer_number, layer_vertical_index,
				)
				link_node_view.position_offset = link_node_view.position_offset \
					- Vector2(
						committed_width / 2,
						committed_height / 2
					) + Vector2(
						layer_number * (committed_width / total_layers_amount),
						layer_vertical_index * (committed_height / layer_vertical_size),
					) + Vector2(
						(committed_width / total_layers_amount) / 2,
						0,
					)
				# TODO also centralize this link_node_view within the layer vertical bounds.
				
				var object := layer_cross_links[link_index].get_object()
				var object_node_view := _graph_nodes[object.get_name()]
				object_node_view.add_link_node(_graph_canvas, link_node_view)


func clear() -> void:
	var _graph_nodes_array := _graph_nodes.values()
	_graph_nodes.clear()
	
	while not _graph_nodes_array.is_empty():
		var object_node_view := _graph_nodes_array.pop_back()
		
		for child in _graph_canvas.get_children():
			if child == object_node_view:
				_graph_canvas.remove_child(object_node_view)
				break
		
		for link_node_view in object_node_view.get_and_clear_link_nodes():
			for child in _graph_canvas.get_children():
				if child == link_node_view:
					_graph_canvas.remove_child(link_node_view)
					break
			
			link_node_view.queue_free()
		
		object_node_view.queue_free()
