@tool
class_name GodDaggerPlugin extends EditorPlugin


#func _enable_plugin():
	#GodDaggerComponentsParser._build_dependency_graph_by_parsing_project_files()
#
#
#func _apply_changes() -> void:
	#GodDaggerComponentsParser._build_dependency_graph_by_parsing_project_files()


var _main_panel_scene_root_node: Node = null


func _get_plugin_name() -> String:
	return GodDaggerConstants.MAIN_PANEL_TITLE


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")


func _has_main_screen() -> bool:
	return true


func _enter_tree() -> void:
	if not _main_panel_scene_root_node:
		var main_panel_scene := preload(GodDaggerConstants.MAIN_PANEL_SCENE_PATH)
		_main_panel_scene_root_node = main_panel_scene.instantiate()
		EditorInterface.get_editor_main_screen().add_child(_main_panel_scene_root_node)
		_make_visible(false)


func _make_visible(visible: bool) -> void:
	if _main_panel_scene_root_node:
		_main_panel_scene_root_node.visible = visible


func _exit_tree() -> void:
	if _main_panel_scene_root_node:
		_main_panel_scene_root_node.queue_free()


func _build() -> bool:
	return GodDaggerComponentsParser._build_dependency_graph_by_parsing_project_files()
