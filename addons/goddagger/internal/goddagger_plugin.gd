@tool
class_name GodDaggerPlugin extends EditorPlugin


var _inspector_plugin: GodDaggerInspectorPlugin = null
var _main_panel_scene_root_node: GodDaggerMainPanel = null


func _get_plugin_name() -> String:
	return GodDaggerViewConstants.GODDAGGER_MAIN_PANEL_TITLE


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")


func _has_main_screen() -> bool:
	return true


func _enter_tree() -> void:
	if not _inspector_plugin:
		_inspector_plugin = GodDaggerInspectorPlugin.new()
		add_inspector_plugin(_inspector_plugin)
	
	if not _main_panel_scene_root_node:
		var main_panel_scene := preload(GodDaggerViewConstants.MAIN_PANEL_SCENE_PATH)
		_main_panel_scene_root_node = main_panel_scene.instantiate()
		main_screen_changed.connect(_main_panel_scene_root_node._react_to_main_screen_change)
		EditorInterface.get_editor_main_screen().add_child(_main_panel_scene_root_node)
		_make_visible(false)


func _make_visible(visible: bool) -> void:
	if _main_panel_scene_root_node:
		_main_panel_scene_root_node.visible = visible


func _exit_tree() -> void:
	if _main_panel_scene_root_node:
		_main_panel_scene_root_node.queue_free()
		_main_panel_scene_root_node = null
	
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null


func _build() -> bool:
	var parsing_result := GodDaggerComponentsParser \
		._build_dependency_graph_by_parsing_project_files()
	
	var parse_error := parsing_result.get_parse_error()
	var has_parse_error := not parse_error.is_empty()
	assert(not has_parse_error, parse_error)
	return not has_parse_error
