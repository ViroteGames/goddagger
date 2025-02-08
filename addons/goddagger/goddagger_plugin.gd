@tool
class_name GodDaggerPlugin extends EditorPlugin


func _enable_plugin():
	GodDagger._build_dependency_graph_by_parsing_project_files()


func _apply_changes() -> void:
	GodDagger._build_dependency_graph_by_parsing_project_files()


func _build() -> bool:
	return GodDagger._build_dependency_graph_by_parsing_project_files()
