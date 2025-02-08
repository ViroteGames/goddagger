class_name GodDaggerEntryPoint extends Node


var _component_name: String
var _component: GodDaggerComponent


func _declared_component_name() -> String:
	return ""


func _get_component() -> GodDaggerComponent:
	return _component


func _init() -> void:
	var component_name := _declared_component_name()
	if component_name == null:
		assert(false, "GodDaggerEntryPoint needs a declared component name.")
	else:
		self._component_name = component_name
	
	var component := GodDagger.get_component(_component_name)
	if component == null:
		assert(
			false,
			"GodDaggerEntryPoint has non-existent declared component named '%s'." % _component_name
		)
	else:
		self._component = component
