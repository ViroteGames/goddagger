@tool
class_name GodDaggerInspectorPlugin extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is GodDaggerMainPanel


func _parse_property(
	object: Object,
	type: Variant.Type,
	property_name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool,
) -> bool:
	
	if not property_name.begins_with(GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_PREFIX):
		return false
	
	var is_property_for_summary := property_name \
		.ends_with(GodDaggerConstants.GODDAGGER_INSPECTOR_PROPERTY_SUMMARY_SUFFIX)
	
	match hint_string:
		GodDaggerConstants.BASE_GODDAGGER_COMPONENT_NAME:
			if is_property_for_summary:
				add_property_editor(property_name, ComponentSummaryDisplayProperty.new())
			else:
				add_property_editor(property_name, ComponentsEditorProperty.new())
			return true
		GodDaggerConstants.BASE_GODDAGGER_SUBCOMPONENT_NAME:
			if is_property_for_summary:
				add_property_editor(property_name, SubcomponentSummaryDisplayProperty.new())
			else:
				add_property_editor(property_name, SubcomponentsEditorProperty.new())
			return true
		GodDaggerConstants.BASE_GODDAGGER_MODULE_NAME:
			if is_property_for_summary:
				add_property_editor(property_name, ModuleSummaryDisplayProperty.new())
			else:
				add_property_editor(property_name, ModulesEditorProperty.new())
			return true
		GodDaggerConstants.BASE_GODDAGGER_SCOPE_NAME:
			add_property_editor(property_name, ScopeEditorProperty.new())
			return true
		_:
			if is_property_for_summary:
				add_property_editor(property_name, DependencySummaryDisplayProperty.new())
			else:
				add_property_editor(property_name, DependenciesEditorProperty.new())
			return true
	
	return false


class ComponentSummaryDisplayProperty extends GodDaggerDisplayProperty:
	
	var _summary_item: SidePanelDetailsItem
	var _current_value: GodDaggerParsingResult.CompiledResult.Component
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_summary_item() -> SidePanelDetailsItem:
		return _summary_item
	
	func _override_summary_item(value: Variant) -> SidePanelDetailsItem:
		_summary_item = SidePanelDetailsItem.Component.spawn(value)
		return _summary_item


class ComponentsEditorProperty extends GodDaggerEditorProperty:
	
	var _current_value: Array[GodDaggerParsingResult.CompiledResult.Component] = []
	
	func _on_update_property() -> void:
		_current_value = []
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_updated_control_text() -> String:
		if not _current_value.is_empty():
			return ", ".join(
				_current_value.map(
					func(module): return module.get_name()
				)
			)
		else:
			return "<No Component>"


class SubcomponentSummaryDisplayProperty extends GodDaggerDisplayProperty:
	
	var _summary_item: SidePanelDetailsItem
	var _current_value: GodDaggerParsingResult.CompiledResult.Subcomponent
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_summary_item() -> SidePanelDetailsItem:
		return _summary_item
	
	func _override_summary_item(value: Variant) -> SidePanelDetailsItem:
		_summary_item = SidePanelDetailsItem.Subcomponent.spawn(value)
		return _summary_item


class SubcomponentsEditorProperty extends GodDaggerEditorProperty:
	
	var _current_value: Array[GodDaggerParsingResult.CompiledResult.Subcomponent] = []
	
	func _on_update_property() -> void:
		_current_value = []
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_updated_control_text() -> String:
		if not _current_value.is_empty():
			return ", ".join(
				_current_value.map(
					func(module): return module.get_name()
				)
			)
		else:
			return "<No Subcomponent>"


class ModuleSummaryDisplayProperty extends GodDaggerDisplayProperty:
	
	var _summary_item: SidePanelDetailsItem
	var _current_value: GodDaggerParsingResult.CompiledResult.Module
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_summary_item() -> SidePanelDetailsItem:
		return _summary_item
	
	func _override_summary_item(value: Variant) -> SidePanelDetailsItem:
		_summary_item = SidePanelDetailsItem.Module.spawn(value)
		return _summary_item



class ModulesEditorProperty extends GodDaggerEditorProperty:
	
	var _current_value: Array[GodDaggerParsingResult.CompiledResult.Module] = []
	
	func _on_update_property() -> void:
		_current_value = []
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_updated_control_text() -> String:
		if not _current_value.is_empty():
			return ", ".join(
				_current_value.map(
					func(module): return module.get_name()
				)
			)
		else:
			return "<No Module>"


class ScopeEditorProperty extends GodDaggerEditorProperty:
	
	var _current_value: GodDaggerParsingResult.CompiledResult.Scope
	
	func _on_update_property() -> void:
		_current_value = null
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_updated_control_text() -> String:
		if _current_value is GodDaggerParsingResult.CompiledResult.CompiledElement:
			return _current_value.get_name()
		else:
			return "<Unscoped>"


class DependencySummaryDisplayProperty extends GodDaggerDisplayProperty:
	
	var _summary_item: SidePanelDetailsItem
	var _current_value: GodDaggerParsingResult.CompiledResult.Dependency
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_summary_item() -> SidePanelDetailsItem:
		return _summary_item
	
	func _override_summary_item(value: Variant) -> SidePanelDetailsItem:
		_summary_item = SidePanelDetailsItem.Dependency.spawn(value)
		return _summary_item


class DependenciesEditorProperty extends GodDaggerEditorProperty:
	
	var _current_value: Array[GodDaggerParsingResult.CompiledResult.Dependency] = []
	
	func _on_update_property() -> void:
		_current_value = []
	
	func _get_current_value() -> Variant:
		return _current_value
	
	func _set_current_value(value: Variant) -> void:
		_current_value = value
	
	func _get_updated_control_text() -> String:
		if not _current_value.is_empty():
			return ", ".join(
				_current_value.map(
					func(dependency): return dependency.get_name()
				)
			)
		else:
			return "<No Dependencies>"


class GodDaggerDisplayProperty extends EditorProperty:
	
	var _container := VBoxContainer.new()
	var _updating := false
	
	func _init() -> void:
		add_child(_container)
		set_bottom_editor(_container)
		_refresh_control_text()
	
	func _get_current_value() -> Variant:
		return null
	
	func _set_current_value(value: Variant) -> void:
		pass
	
	func _get_summary_item() -> SidePanelDetailsItem:
		return null
	
	func _override_summary_item(value: Variant) -> SidePanelDetailsItem:
		return null
	
	func _update_property() -> void:
		var edited_object = get_edited_object()
		var edited_property = get_edited_property()
		
		match [edited_object, edited_property]:
			[null, null], [null, _], [_, null]:
				return
			[var object, var property] when not property in object:
				return
		
		var current_value = _get_current_value()
		var new_value = edited_object[edited_property]
		
		match [current_value, new_value]:
			[_, null]:
				return
			[var current, var new] when current == new:
				return
		
		_updating = true
		
		_set_current_value(new_value)
		_refresh_control_text()
		_updating = false
	
	func _refresh_control_text() -> void:
		var summary_item := _get_summary_item()
		if summary_item:
			_container.remove_child(summary_item)
		
		var current_value = _get_current_value()
		if current_value:
			_container.add_child(_override_summary_item(current_value))


class GodDaggerEditorProperty extends EditorProperty:
	
	var _container := VBoxContainer.new()
	var _property_control := Button.new()
	var _updating := false
	
	func _init() -> void:
		_container.add_child(_property_control)
		
		add_child(_container)
		set_bottom_editor(_container)
		add_focusable(_property_control)
		_refresh_control_text()
		_property_control.pressed.connect(_on_button_pressed)
	
	func _on_button_pressed() -> void:
		if _updating:
			return
		
		_on_update_property()
		_refresh_control_text()
		emit_changed(get_edited_property(), _get_current_value())
	
	func _on_update_property() -> void:
		pass
	
	func _get_current_value() -> Variant:
		return null
	
	func _set_current_value(value: Variant) -> void:
		pass
	
	func _update_property() -> void:
		var edited_object = get_edited_object()
		var edited_property = get_edited_property()
		
		match [edited_object, edited_property]:
			[null, null], [null, _], [_, null]:
				return
			[var object, var property] when not property in object:
				return
		
		var current_value = _get_current_value()
		var new_value = edited_object[edited_property]
		
		match [current_value, new_value]:
			[_, null]:
				return
			[var current, var new] when current == new:
				return
		
		_updating = true
		
		_set_current_value(new_value)
		_refresh_control_text()
		_updating = false
	
	func _refresh_control_text() -> void:
		_property_control.text = _get_updated_control_text()
	
	func _get_updated_control_text() -> String:
		return ""
