class_name GodDaggerTopologicalOrderIterator extends RefCounted


var _graph: GodDaggerGraph
var _queue: GodDaggerPriorityQueue
var _remaining_vertices_count: int
var _incoming_vertices_degree_map: Dictionary
var _current_vertex: GodDaggerGraph.GraphVertex


func _init(graph: GodDaggerGraph) -> void:
	self._graph = graph
	
	var vertex_set_size: int = graph.get_vertex_set().size()
	
	self._queue = GodDaggerPriorityQueue.new(vertex_set_size)
	self._remaining_vertices_count = vertex_set_size
	self._incoming_vertices_degree_map = _count_incoming_degrees()


func has_next() -> bool:
	if _current_vertex != null:
		return true
	
	_current_vertex = _advance()
	
	return _current_vertex != null


func get_next() -> GodDaggerGraph.GraphVertex:
	if not has_next():
		assert(
			false,
			"GodDagger BUG @GodDaggerTopologicalOrderIterator.get_next()." +
			"This function was called even though 'has_next()' reported 'false'!"
		)
		return null
	
	var vertex := _current_vertex
	_current_vertex = null
	return vertex


func _count_incoming_degrees() -> Dictionary:
	var incoming_vertices_degrees_map: Dictionary = {}
	
	for vertex in _graph.get_vertex_set():
		var incoming_degree: int = 0
		
		for other_vertex in vertex.get_incoming_vertices():
			var vertex_is_different := not other_vertex.equals(vertex)
			
			if not vertex_is_different:
				assert(
					vertex_is_different,
					"GodDagger detected that your dependencies don't form a direct acyclic graph!"
				)
				return incoming_vertices_degrees_map
			
			incoming_degree += 1
		
		incoming_vertices_degrees_map[vertex] = ModifiableInteger.new(incoming_degree)
		
		if incoming_degree == 0:
			_queue.add(vertex, 0.0)
	
	return incoming_vertices_degrees_map


func _advance() -> GodDaggerGraph.GraphVertex:
	var vertex: GodDaggerGraph.GraphVertex = _queue.next()
	
	if vertex != null:
		for other_vertex in vertex.get_outgoing_vertices():
			var incoming_degree: ModifiableInteger = _incoming_vertices_degree_map[other_vertex]
			if incoming_degree.get_value() > 0:
				incoming_degree.decrement()
				
				if incoming_degree.get_value() == 0:
					_queue.add(other_vertex, 0.0)
		
		_remaining_vertices_count -= 1
		
	elif _remaining_vertices_count > 0:
		assert(
			false,
			"GodDagger detected that your dependencies don't form a direct acyclic graph!"
		)
	
	return vertex


class ModifiableInteger extends RefCounted:
	
	var _value: int
	
	func _init(value: int) -> void:
		_value = value
	
	func get_value() -> int:
		return _value
	
	func decrement() -> void:
		_value -= 1
