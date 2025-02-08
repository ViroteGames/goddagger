class_name GodDaggerGraph extends RefCounted


var _vertex_set: Array[GraphVertex] = []


func declare_graph_vertex(vertex: GraphVertex) -> void:
	_add_if_possible(vertex, _vertex_set)


func get_vertex_set() -> Array[GraphVertex]:
	return _vertex_set


func get_topological_order() -> Array[GraphVertex]:
	var topological_order: Array[GraphVertex]
	
	var iterator := GodDaggerTopologicalOrderIterator.new(self)
	while iterator.has_next():
		topological_order.append(iterator.get_next())
	
	return topological_order


static func _add_if_possible(
	vertex: GraphVertex,
	vertices: Array[GraphVertex],
) -> void:
	
	for other_vertex in vertices:
		if other_vertex.equals(vertex):
			return
	
	vertices.append(vertex)


class GraphVertex extends RefCounted:
	
	static var _next_id: int = 0
	
	var _id: int
	var _value: Variant
	var _incoming_vertices: Array[GraphVertex] = []
	var _outgoing_vertices: Array[GraphVertex] = []
	
	func _init(value: Variant) -> void:
		self._id = _next_id
		self._value = value
		_next_id += 1
	
	func add_edge_towards(vertex: GraphVertex) -> void:
		GodDaggerGraph._add_if_possible(vertex, self._outgoing_vertices)
		GodDaggerGraph._add_if_possible(self, vertex._incoming_vertices)
	
	func get_incoming_vertices() -> Array[GraphVertex]:
		return _incoming_vertices
	
	func get_outgoing_vertices() -> Array[GraphVertex]:
		return _outgoing_vertices
	
	func equals(other_vertex: GraphVertex) -> bool:
		if other_vertex == null:
			return false
		
		return _id == other_vertex._id
