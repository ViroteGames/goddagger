class_name SidePanelDetailsItem extends MarginContainer


var _class_name_text: String
var _file_path_text: String
var _coded_details_text: String
var _parse_error_text: String


@onready var _class_name_view: Label = \
	$"VBoxContainer/HFlowContainer/SidePanelItemClassName"
@onready var _file_path_view: Label = \
	$"VBoxContainer/HFlowContainer/SidePanelItemFilePath"
@onready var _coded_details_view: CodeEdit = \
	$"VBoxContainer/SidePanelItemCodedDetails"
@onready var _parse_error_view: Label = \
	$"VBoxContainer/HFlowContainer2/SidePanelItemParseErrorDescription"


func populated_with(
	class_name_text: String,
	file_path_text: String,
	coded_details_text: String,
	parse_error_text: String,
) -> SidePanelDetailsItem:
	
	self._class_name_text = class_name_text
	self._file_path_text = file_path_text
	self._coded_details_text = coded_details_text
	self._parse_error_text = parse_error_text
	return self


func _ready() -> void:
	_class_name_view.text = _class_name_text
	_file_path_view.text = _file_path_text.replace("res:///", "")
	_coded_details_view.text = _coded_details_text
	
	if _parse_error_text.is_empty():
		_parse_error_view.visible = false
	else:
		_parse_error_view.text = _parse_error_text
		_parse_error_view.visible = true


static var _sidepanel_details_item_scene := \
	preload(GodDaggerViewConstants.SIDEPANEL_DETAILS_ITEM_SCENE_PATH)


static func spawn(
	class_name_text: String,
	file_path_text: String,
	coded_details_text: String,
	parse_error_text: String,
) -> SidePanelDetailsItem:
	
	return SidePanelDetailsItem \
		._sidepanel_details_item_scene \
		.instantiate() \
		.populated_with(
			class_name_text,
			file_path_text,
			coded_details_text,
			parse_error_text,
		)


class Component:
	
	static func spawn(
		component: GodDaggerParsingResult.CompiledResult.Component,
	) -> SidePanelDetailsItem:
		
		var coded_details_text := ""
		
		if component.get_scope().is_empty():
			coded_details_text += "~ unscoped"
		else:
			coded_details_text += "~ scoped to %s" % component.get_scope()
		
		if not component.get_modules().is_empty():
			coded_details_text += "\n~ uses %s" % ", ".join(component.get_modules())
		
		if not component.get_exposed_objects().is_empty():
			coded_details_text += "\n~ exposes %s" % ", ".join(component.get_exposed_objects())
		
		return SidePanelDetailsItem.spawn(
			component.get_name(),
			component.get_file_path(),
			coded_details_text,
			"",
		)
