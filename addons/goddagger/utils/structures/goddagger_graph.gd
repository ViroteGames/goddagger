class_name GodDaggerGraph extends RefCounted


var _vertex_set: Array[GraphVertex] = []
var _vertex_lookup_table: Dictionary = {}


func has_graph_vertex(value: Variant) -> bool:
	return _vertex_lookup_table.keys().has(value)


func declare_graph_vertex(value: Variant) -> void:
	if not _vertex_lookup_table.keys().has(value):
		_vertex_lookup_table[value] = GraphVertex.new(value)
		print("Graph is now aware of: %s!" % value)
	
	var vertex: GraphVertex = _vertex_lookup_table[value]
	_add_if_possible(vertex, _vertex_set)


func declare_vertices_link(from_vertex_value: Variant, to_vertex_value: Variant) -> void:
	var from_vertex: GraphVertex = _vertex_lookup_table[from_vertex_value]
	var to_vertex: GraphVertex = _vertex_lookup_table[to_vertex_value]
	from_vertex._add_edge_towards(to_vertex)
	print("Graph formed a link from %s to %s..." % [from_vertex_value, to_vertex_value])


func get_vertex_set() -> Array[GraphVertex]:
	return _vertex_set


func get_topological_order() -> Array[Variant]:
	var topological_order: Array[Variant]
	
	var iterator := GodDaggerTopologicalOrderIterator.new(self)
	while iterator.has_next():
		topological_order.append(iterator.get_next().get_value())
	
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
	
	func get_value() -> Variant:
		return _value
	
	func _add_edge_towards(vertex: GraphVertex) -> void:
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
