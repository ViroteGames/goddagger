class_name GodDaggerFileUtils extends RefCounted


const BASE_PROJECT_PATH := "res://"
const GODDAGGER_PATH := BASE_PROJECT_PATH + "addons/goddagger"
const GENERATED_FOLDER_NAME := "generated"
const GENERATED_PATH := GODDAGGER_PATH + "/" + GENERATED_FOLDER_NAME


static func _get_component_file_name(component_name: String) -> String:
	return "%s/_goddagger__%s.gd" % [GENERATED_PATH, component_name.to_snake_case()]


static func _generate_script_with_contents(file_name: String, contents: String) -> bool:
	if _generated_directory_exists():
		var file_path := "%s/%s.gd" % [GENERATED_PATH, file_name]
		print("Generating file %s..." % file_path)
		var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(contents)
		file.flush()
		file.close()
		return FileAccess.file_exists(file_path)
	
	return false


static func _generated_directory_exists() -> bool:
	var directory := DirAccess.open(GODDAGGER_PATH)
	if not directory.dir_exists(GENERATED_FOLDER_NAME):
		var directory_created := directory.make_dir(GENERATED_FOLDER_NAME) == OK
		assert(
			directory_created,
			"GodDagger couldn't create dedicated folder for generated scripts at %s/%s." \
				% [GODDAGGER_PATH, GENERATED_FOLDER_NAME]
		)
		return directory_created
	
	return true


static func _clear_generated_files() -> bool:
	print("Clearing generated files...")
	
	var directory := DirAccess.open(GENERATED_PATH)
	if directory == null:
		return true
	
	_do_iterate_through_directory_and_do(
		GENERATED_PATH,
		directory,
		func (absolute_directory_path: String) -> void:
			pass,
		func (absolute_file_path: String) -> void:
			DirAccess.remove_absolute(absolute_file_path),
	)
	
	var clear_successful := DirAccess.remove_absolute(GENERATED_PATH) == OK
	
	assert(
		clear_successful,
		"Couldn't clear dedicated folder for generated scripts at %s." % [GENERATED_PATH],
	)
	return clear_successful


static func _iterate_through_directory_recursively_and_do(
	operation_for_each_file: Callable,
) -> void:
	
	var directory := DirAccess.open(BASE_PROJECT_PATH)
	if directory != null:
		_do_iterate_through_directory_and_do(
			BASE_PROJECT_PATH,
			directory,
			func (absolute_directory_path: String) -> void:
				_do_iterate_through_directory_recursively_and_do.call(
					absolute_directory_path, operation_for_each_file,
				),
			operation_for_each_file,
		)


static func _do_iterate_through_directory_and_do(
	directory_path: String,
	directory: DirAccess,
	operation_for_each_directory: Callable,
	operation_for_each_file: Callable,
) -> void:
	
	directory.list_dir_begin()
	
	var file_name := directory.get_next()
	while file_name != "":
		if directory.current_is_dir():
			operation_for_each_directory.call("%s/%s" % [directory_path, file_name])
		else:
			operation_for_each_file.call("%s/%s" % [directory_path, file_name])
		
		file_name = directory.get_next()
		
	directory.list_dir_end()


static func _do_iterate_through_directory_recursively_and_do(
	absolute_directory_path: String,
	operation_for_each_file: Callable,
) -> void:
	var directory := DirAccess.open(absolute_directory_path)
	if directory == null:
		return
	
	_do_iterate_through_directory_and_do(
		absolute_directory_path,
		directory,
		func (nested_absolute_directory_path: String) -> void:
			_do_iterate_through_directory_recursively_and_do.call(
				nested_absolute_directory_path, operation_for_each_file,
			),
		operation_for_each_file,
	)
