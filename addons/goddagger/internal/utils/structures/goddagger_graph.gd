class_name GodDaggerGraph extends RefCounted


var _name: String
var _vertex_set: Array[GraphVertex] = []
var _vertex_lookup_table: Dictionary = {}
var _children: Array[GodDaggerGraph] = []


func _init(name: String) -> void:
	self._name = name


func fork(name: String) -> GodDaggerGraph:
	var forked_graph := GodDaggerGraph.new(name)
	
	for value in get_topological_order():
		forked_graph.declare_graph_vertex(value)
		var vertex: GraphVertex = _vertex_lookup_table[value]
		
		for other_vertex in vertex.get_incoming_vertices():
			forked_graph.declare_vertices_link(other_vertex.get_value(), value)
		
		for tag in vertex.get_tags().keys():
			forked_graph.set_tag_to_vertex(value, tag, vertex.get_tags()[tag])
	
	_children.append(forked_graph)
	
	return forked_graph


func has_graph_vertex(value: Variant) -> bool:
	return _vertex_lookup_table.keys().has(value)


func declare_graph_vertex(value: Variant) -> void:
	if not _vertex_lookup_table.keys().has(value):
		_vertex_lookup_table[value] = GraphVertex.new(value)
		print("%s is now aware of: %s!" % [self._name, value])
	
	var vertex: GraphVertex = _vertex_lookup_table[value]
	_add_if_possible(vertex, _vertex_set)
	
	for child in _children:
		child.declare_graph_vertex(value)


func declare_vertices_link(from_value: Variant, to_value: Variant) -> void:
	if has_graph_vertex(from_value) and has_graph_vertex(to_value):
		var from_vertex: GraphVertex = _vertex_lookup_table[from_value]
		var to_vertex: GraphVertex = _vertex_lookup_table[to_value]
		from_vertex._add_edge_towards(to_vertex)
		print("%s formed a link from %s to %s..." % [self._name, from_value, to_value])
		
		for child in _children:
			child.declare_vertices_link(from_value, to_value)


func get_outgoing_vertices(value: Variant) -> Array[Variant]:
	var outgoing_vertices: Array[Variant] = []
	
	if not has_graph_vertex(value):
		return outgoing_vertices
	
	var vertex: GraphVertex = _vertex_lookup_table[value]
	for other_vertex in vertex.get_outgoing_vertices():
		outgoing_vertices.append(other_vertex.get_value())
	
	return outgoing_vertices


func get_topological_order() -> Array[Variant]:
	var topological_order: Array[Variant] = []
	
	var iterator := GodDaggerTopologicalOrderIterator.new(self)
	while iterator.has_next():
		topological_order.append(iterator.get_next().get_value())
	
	return topological_order


func set_tag_to_vertex(value: Variant, tag_name: String, tag_value: String) -> void:
	if has_graph_vertex(value):
		_vertex_lookup_table[value].set_tag(tag_name, tag_value)
	
	for child in _children:
		child.set_tag_to_vertex(value, tag_name, tag_value)


func get_vertex_tag(value: Variant, tag_name: String) -> Variant:
	if has_graph_vertex(value):
		var tags: Dictionary = _vertex_lookup_table[value].get_tags()
		
		if tags.keys().has(tag_name):
			return tags[tag_name]
	
	return null


func serialize() -> String:
	return "{\"%s\": \"%s\",\"%s\": [%s]}" % [
		GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_NAME,
		self._name,
		GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_VERTICES,
		"{\"%s\": \"%s\",\"%s\": [%s],\"%s\": [%s]}," \
		.repeat(_get_vertex_set().size()) % _flatten_array(
			_get_vertex_set().map(
				func (vertex: GraphVertex) -> Array: return [
					GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_VERTEX_NAME,
					vertex.get_value(),
					GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_TAGS,
					"{\"%s\": \"%s\", \"%s\": \"%s\",}," \
					.repeat(vertex.get_tags().keys().size()) % _flatten_array(
						vertex.get_tags().keys().map(
							func (key: String) -> Array: return [
								GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_TAG_NAME,
								key,
								GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_TAG_VALUE,
								vertex.get_tags()[key],
							]
						)
					),
					GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_OUTGOING_VERTICES,
					"{\"%s\": \"%s\"}," \
					.repeat(vertex.get_outgoing_vertices().size()) % _flatten_array(
						vertex.get_outgoing_vertices().map(
							func (other_vertex: GraphVertex) -> Array: return [
								GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_VERTEX_NAME,
								other_vertex.get_value(),
							]
						),
					)
				]
			)
		)
	]


func _get_vertex_set() -> Array[GraphVertex]:
	return _vertex_set


func _flatten_array(array: Array) -> Array:
	if array.is_empty():
		return []
	
	var flattened_array: Array = []
	flattened_array.resize(array.size() * array[0].size())
	
	for i in array.size():
		for j in array[i].size():
			flattened_array[i * array[0].size() + j] = array[i][j]
	
	return flattened_array


static func _add_if_possible(
	vertex: GraphVertex,
	vertices: Array[GraphVertex],
) -> void:
	
	for other_vertex in vertices:
		if other_vertex.equals(vertex):
			return
	
	vertices.append(vertex)


static func serialize_dictionary(dictionary: Dictionary) -> String:
	var serialized_dictionary: String = "{"
	for key in dictionary.keys():
		serialized_dictionary += "\n\"%s\": %s," % [
			key, dictionary[key].serialize().indent("\t")
		]
	serialized_dictionary += "}"
	return serialized_dictionary


static func build_from_dictionary(dictionary: Dictionary) -> GodDaggerGraph:
	var goddagger_graph: GodDaggerGraph = \
		GodDaggerGraph.new(dictionary[GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_NAME])
	
	var vertices = dictionary[GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_VERTICES]
	
	for vertex in vertices:
		var vertex_name = vertex[GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_VERTEX_NAME]
		goddagger_graph.declare_graph_vertex(vertex_name)
		
		var tags = vertex[GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_TAGS]
		for tag in tags:
			var tag_name = tag[GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_TAG_NAME]
			var tag_value = tag[GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_TAG_VALUE]
			goddagger_graph.set_tag_to_vertex(vertex_name, tag_name, tag_value)
		
		var outgoing_vertices_of_vertex = vertex[
			GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_OUTGOING_VERTICES
		]
		
		for other_vertex in outgoing_vertices_of_vertex:
			var other_vertex_name = other_vertex[
				GodDaggerConstants.GODDAGGER_GRAPH_SERIALIZED_KEY_VERTEX_NAME
			]
			goddagger_graph.declare_graph_vertex(other_vertex_name)
			goddagger_graph.declare_vertices_link(vertex_name, other_vertex_name)
	
	return goddagger_graph


class GraphVertex extends RefCounted:
	
	static var _next_id: int = 0
	
	var _id: int
	var _value: Variant
	var _incoming_vertices: Array[GraphVertex] = []
	var _outgoing_vertices: Array[GraphVertex] = []
	var _tags: Dictionary = {}
	
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
	
	func set_tag(tag_name: String, tag_value: String) -> void:
		_tags[tag_name] = tag_value
	
	func get_tags() -> Dictionary:
		return _tags
	
	func equals(other_vertex: GraphVertex) -> bool:
		if other_vertex == null:
			return false
		
		return _id == other_vertex._id
