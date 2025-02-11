class_name GodDaggerPriorityQueue extends RefCounted


var _array: Array[Variant] = []
var _first_free_spot: int


func _init(capacity_hint: int) -> void:
	_first_free_spot = 0
	
	if capacity_hint > 0:
		_array.resize(capacity_hint)


func size() -> int:
	return _first_free_spot


func add(value: Variant, priority: float) -> void:
	var previous_size = _array.size()
	
	if _first_free_spot >= previous_size:
		_array.resize((previous_size + 1) * 2)
		_first_free_spot = previous_size + 1
	
	else:
		_first_free_spot = previous_size
	
	for i in range(_first_free_spot - 1, -1, -1):
		if _array[i] == null:
			_first_free_spot = i
	
	_array[_first_free_spot] = [priority, value]
	
	if _first_free_spot != 0:
		_ensure_heap(_first_free_spot)
	
	_first_free_spot += 1


func _ensure_heap(index: int) -> void:
	var parent_index = _get_parent_index(index)
	
	if index == 0:
		return
	
	if _array[parent_index][0] < _array[index][0]:
		var parent = _array[parent_index]
		_array[parent_index] = _array[index]
		_array[index] = parent
		
		_ensure_heap(parent_index)


func _get_parent_index(index: int) -> int:
	return int(floor((index - 1) / 2.0))


func next() -> Variant:
	if _array.size() <= 0 or _first_free_spot <= 0:
		return null
	
	var next_value = _array[0]
	_array[0] = _array[_first_free_spot - 1]
	_array[_first_free_spot - 1] = null
	
	_first_free_spot -= 1
	_max_heapify(0)
	
	return next_value[1]


func _max_heapify(index: int) -> void:
	var lowest_priority_index = index
	
	var left_child_index = _get_left_child_index(index)
	
	if left_child_index < _first_free_spot and left_child_index <= _array.size() - 1:
		if _array[lowest_priority_index][0] < _array[left_child_index][0]:
			lowest_priority_index = left_child_index
	
	var right_child_index = _get_right_child_index(index)
	
	if right_child_index < _first_free_spot and right_child_index <= _array.size() - 1:
		if _array[lowest_priority_index][0] < _array[right_child_index][0]:
			lowest_priority_index = right_child_index
	
	if lowest_priority_index != index:
		var child = _array[lowest_priority_index]
		_array[lowest_priority_index] = _array[index]
		_array[index] = child
		
		_max_heapify(lowest_priority_index)


func _get_left_child_index(index: int) -> int:
	return (2 * index) + 1


func _get_right_child_index(index: int) -> int:
	return (2 * index) + 2


func clear() -> void:
	_array.clear()
	_first_free_spot = 0
