class_name GodDagger extends RefCounted

const GODDAGGER_PATH = "res://addons/goddagger"
const GENERATED_FOLDER_NAME = "generated"
const GENERATED_PATH = GODDAGGER_PATH + "/" + GENERATED_FOLDER_NAME


static func _clear_generated_files() -> bool:
	print("Clearing generated files...")
	
	var directory := DirAccess.open(GENERATED_PATH)
	if directory == null:
		return true
	
	directory.list_dir_begin()
	
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir():
			DirAccess.remove_absolute(GENERATED_PATH + "/" + file_name)
		
		file_name = directory.get_next()
		
	directory.list_dir_end()

	if DirAccess.remove_absolute(GENERATED_PATH) == OK:
		return true
	
	push_error(
		"GodDagger couldn't clear dedicated folder for generated scripts at %s/%s." \
		% [GODDAGGER_PATH, GENERATED_FOLDER_NAME]
	)
	return false


static func _generated_directory_exists() -> bool:
	var directory := DirAccess.open(GODDAGGER_PATH)
	if not directory.dir_exists(GENERATED_FOLDER_NAME):
		if directory.make_dir("generated") != OK:
			push_error(
				"GodDagger couldn't create dedicated folder for generated scripts at %s/%s." \
				% [GODDAGGER_PATH, GENERATED_FOLDER_NAME]
			)
			return false
	return true


static func _generate_script_with_contents(name: String, contents: String) -> void:
	if _generated_directory_exists():
		var file_path := "%s/%s.gd" % [GENERATED_PATH, name]
		print("GENERATING %s.gd..." % name)
		var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(contents)
		file.flush()
		file.close()
		load(file_path)
		print(
			"GENERATED %s.gd? ~> %s!" % [name, FileAccess.file_exists(file_path)]
		)


static func _build_dependency_graph_by_parsing_project_files() -> void:
	if not _clear_generated_files():
		return
	
	_generate_script_with_contents(
		"_goddagger_provider__electric_heater",
		"""
class_name _GodDaggerProvider__ElectricHeater extends RefCounted


func _init() -> void:
	pass


func _obtain() -> ElectricHeater:
	return ElectricHeater.new()
""",
	)
	
	_generate_script_with_contents(
		"_goddagger_provider__heater",
		"""
class_name _GodDaggerProvider__Heater extends RefCounted


var _example_module: ExampleModule
var _electric_heater_provider: _GodDaggerProvider__ElectricHeater


func _init(
	example_module: ExampleModule,
	electric_heater_provider: _GodDaggerProvider__ElectricHeater,
) -> void:
	self._example_module = example_module
	self._electric_heater_provider = electric_heater_provider


func _obtain() -> Heater:
	return _example_module.provide_heater(_electric_heater_provider._obtain())
""",
	)
	
	_generate_script_with_contents(
		"_goddagger_provider__thermosiphon",
		"""
class_name _GodDaggerProvider__Thermosiphon extends RefCounted


var _heater_provider: _GodDaggerProvider__Heater


func _init(
	heater_provider: _GodDaggerProvider__Heater,
) -> void:
	self._heater_provider = heater_provider


func _obtain() -> Thermosiphon:
	return Thermosiphon.new(_heater_provider._obtain())
""",
	)
	
	_generate_script_with_contents(
		"_goddagger_provider__pump",
		"""
class_name _GodDaggerProvider__Pump extends RefCounted


var _example_module: ExampleModule
var _thermosiphon_provider: _GodDaggerProvider__Thermosiphon


func _init(
	example_module: ExampleModule,
	thermosiphon_provider: _GodDaggerProvider__Thermosiphon,
) -> void:
	self._example_module = example_module
	self._thermosiphon_provider = thermosiphon_provider


func _obtain() -> Pump:
	return _example_module.provide_pump(_thermosiphon_provider._obtain())
""",
	)
	
	_generate_script_with_contents(
		"_goddagger_provider__coffee_maker",
		"""
class_name _GodDaggerProvider__CoffeeMaker extends RefCounted


var _heater_provider: _GodDaggerProvider__Heater
var _pump_provider: _GodDaggerProvider__Pump


func _init(
	heater_provider: _GodDaggerProvider__Heater,
	pump_provider: _GodDaggerProvider__Pump,
) -> void:
	self._heater_provider = heater_provider
	self._pump_provider = pump_provider


func _obtain() -> CoffeeMaker:
	return CoffeeMaker.new(_heater_provider._obtain(), _pump_provider._obtain())
""",
	)
	
	_generate_script_with_contents(
		"_goddager__example_component",
	"""
class_name GodDagger__ExampleComponent extends GodDaggerComponent


var _electric_heater_provider: _GodDaggerProvider__ElectricHeater
var _heater_provider: _GodDaggerProvider__Heater
var _thermosiphon_provider: _GodDaggerProvider__Thermosiphon
var _pump_provider: _GodDaggerProvider__Pump
var _coffee_maker_provider: _GodDaggerProvider__CoffeeMaker


func _init(example_module: ExampleModule) -> void:
	_electric_heater_provider = _GodDaggerProvider__ElectricHeater.new()
	_heater_provider = _GodDaggerProvider__Heater.new(example_module, _electric_heater_provider)
	_thermosiphon_provider = _GodDaggerProvider__Thermosiphon.new(_heater_provider)
	_pump_provider = _GodDaggerProvider__Pump.new(example_module, _thermosiphon_provider)
	_coffee_maker_provider = _GodDaggerProvider__CoffeeMaker.new(_heater_provider, _pump_provider)


func get_coffee_maker() -> CoffeeMaker:
	return _coffee_maker_provider._obtain()


static func create() -> GodDagger__ExampleComponent:
	return GodDagger__ExampleComponent.new(ExampleModule.new())
""",
	)
