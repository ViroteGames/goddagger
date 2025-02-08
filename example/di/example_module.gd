class_name ExampleModule extends GodDaggerModule


func provide_heater(electric_heater: ElectricHeater) -> Heater:
	return electric_heater


func provide_pump(thermosiphon: Thermosiphon) -> Pump:
	return thermosiphon
