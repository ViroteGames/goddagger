class_name Thermosiphon extends Pump


var _heater: Heater


@export_storage var __constructor_injected
func _init(heater: Heater) -> void:
	self._heater = heater


func _to_string() -> String:
	return "Thermosiphon"
