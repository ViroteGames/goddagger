class_name ExampleModule extends GodDaggerModule


func __provide_heater(electric_heater: ElectricHeater) -> Heater:
	return electric_heater


func __provide_pump(thermosiphon: Thermosiphon) -> Pump:
	return thermosiphon
