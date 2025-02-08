@tool
class_name GodDaggerPlugin extends EditorPlugin


func _enable_plugin():
	GodDaggerComponentsParser._build_dependency_graph_by_parsing_project_files()


func _apply_changes() -> void:
	GodDaggerComponentsParser._build_dependency_graph_by_parsing_project_files()


func _build() -> bool:
	return GodDaggerComponentsParser._build_dependency_graph_by_parsing_project_files()
