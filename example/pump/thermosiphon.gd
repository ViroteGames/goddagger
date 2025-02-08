class_name Thermosiphon extends Pump


var _heater: Heater


func _init(heater: Heater) -> void:
	self._heater = heater


func _to_string() -> String:
	return "Thermosiphon"
