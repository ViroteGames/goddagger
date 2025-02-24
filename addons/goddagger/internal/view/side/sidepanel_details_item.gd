@tool
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


class Component extends RefCounted:
	
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
			component.get_parse_error(),
		)


class Subcomponent extends RefCounted:
	
	static func spawn(
		subcomponent: GodDaggerParsingResult.CompiledResult.Subcomponent,
	) -> SidePanelDetailsItem:
		
		var coded_details_text := ""
		
		if not subcomponent.get_linked_parents().is_empty():
			coded_details_text += "~ extends the following:"
			
			for linked_parent in subcomponent.get_linked_parents():
				coded_details_text += "\n\t~ %s via %s" % [
					linked_parent.get_component(), linked_parent.get_linking_module(),
				]
		
		if not coded_details_text.is_empty():
			coded_details_text += "\n"
		
		if subcomponent.get_scope().is_empty():
			coded_details_text += "~ unscoped"
		else:
			coded_details_text += "~ scoped to %s" % subcomponent.get_scope()
		
		if not subcomponent.get_modules().is_empty():
			coded_details_text += "\n~ uses %s" % ", ".join(subcomponent.get_modules())
		
		if not subcomponent.get_exposed_objects().is_empty():
			coded_details_text += "\n~ exposes %s" % ", ".join(subcomponent.get_exposed_objects())
		
		return SidePanelDetailsItem.spawn(
			subcomponent.get_name(),
			subcomponent.get_file_path(),
			coded_details_text,
			subcomponent.get_parse_error(),
		)


class Module extends RefCounted:
	
	static func spawn(
		module: GodDaggerParsingResult.CompiledResult.Module,
	) -> SidePanelDetailsItem:
		
		var coded_details_text := ""
		
		if not module.get_dependent_components().is_empty():
			if not coded_details_text.is_empty():
				coded_details_text += "\n"
			
			coded_details_text += "~ used by %s" % ", ".join(module.get_dependent_components())
		
		if not module.get_linked_subcomponents().is_empty():
			if not coded_details_text.is_empty():
				coded_details_text += "\n"
			
			coded_details_text += "~ links to %s" % ", ".join(module.get_linked_subcomponents())
		
		if not module.get_provisions().is_empty():
			if not coded_details_text.is_empty():
				coded_details_text += "\n"
			
			coded_details_text += "~ provisions the following:"
			
			for provision in module.get_provisions():
				coded_details_text += "\n\t~ %s%s depends on %s" % [
					provision.get_name(),
					"" if provision.get_scope().is_empty() \
					else " (scoped to %s)" % provision.get_scope(),
					", ".join(provision.get_dependencies())
				]
		
		return SidePanelDetailsItem.spawn(
			module.get_name(),
			module.get_file_path(),
			coded_details_text,
			module.get_parse_error(),
		)
