class_name CoffeeMaker extends RefCounted


var _heater: Heater
var _pump: Pump


@export_storage var __constructor_injected__
func _init(heater: Heater, pump: Pump) -> void:
	self._heater = heater
	self._pump = pump


func make_coffee() -> Coffee:
	print("Making coffee using heater: %s and pump: %s..." % [_heater, _pump])
	return Coffee.new()
	

func _to_string() -> String:
	return "CoffeeMaker"
