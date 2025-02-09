class_name ExampleModule extends GodDaggerModule


var __injected_example_subcomponent: ExampleSubcomponent


func __provide_heater(electric_heater: ElectricHeater) -> Heater:
	return electric_heater

func __provide_pump(thermosiphon: Thermosiphon) -> Pump:
	return thermosiphon
