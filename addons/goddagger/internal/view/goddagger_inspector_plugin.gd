@tool
class_name GodDaggerInspectorPlugin extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return true


func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool,
) -> bool:
	
	if name.begins_with(GodDaggerConstants.RENAMED_GODDAGGER_TOKEN_PREFIX):
		print("object: %s, type: %s, name: %s, hint_type: %s, hint_string: %s" % [
			object, type, name, hint_type, hint_string,
		])
		
		add_property_editor(name, ScopeEditorProperty.new())
		return true
	
	return false


class ScopeEditorProperty extends EditorProperty:
	
	var _property_control := Button.new()
	var _current_value = null
	var _updating := false
	
	func _init() -> void:
		add_child(_property_control)
		set_bottom_editor(_property_control)
		add_focusable(_property_control)
		_refresh_control_text()
		_property_control.pressed.connect(_on_button_pressed)
	
	func _on_button_pressed() -> void:
		if _updating:
			return
		
		_current_value = RootScope.new()
		_refresh_control_text()
		emit_changed(get_edited_property(), _current_value)
	
	func _update_property() -> void:
		var edited_object = get_edited_object()
		var edited_property = get_edited_property()
		
		match [edited_object, edited_property]:
			[null, null], [null, _], [_, null]:
				return
			[var object, var property] when not property in object:
				return
		
		var new_value = edited_object[edited_property]
		
		match [_current_value, new_value]:
			[_, null]:
				return
			[var current, var new] when current == new:
				return
		
		_updating = true
		_current_value = new_value
		_refresh_control_text()
		_updating = false
	
	func _refresh_control_text() -> void:
		print(_current_value)
		_property_control.text = _current_value.get_class() if _current_value != null else "Unscoped"
