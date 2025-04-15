class_name GodDaggerComponentsGenerator extends RefCounted


static func _generate_dependencies_declarations_with_template(
	dependencies: Array[GodDaggerParsingResult.CompiledResult.Dependency],
	template: String,
	initial_breaklines: String,
	ident_prefix: String,
	placeholder_if_empty: String,
) -> String:
	
	var generated_code: String = ""
	
	if dependencies.is_empty():
		generated_code = placeholder_if_empty
	
	for dependency in dependencies:
		if generated_code.is_empty():
			generated_code += initial_breaklines
			
			if not initial_breaklines.is_empty():
				generated_code += ident_prefix
		
		else:
			generated_code += "\n" + ident_prefix
		
		generated_code += template \
			.replace(
				GodDaggerTemplates.ARGUMENT_DEPENDENCY_CLASS,
				dependency.get_name(),
			) \
			.replace(
				GodDaggerTemplates.ARGUMENT_DEPENDENCY_CLASS_SNAKE_CASE,
				dependency.get_name().to_snake_case(),
			)
	
	return generated_code


static func _generate_dependencies_property_declarations(
	dependencies: Array[GodDaggerParsingResult.CompiledResult.Dependency],
) -> String:
	
	return _generate_dependencies_declarations_with_template(
		dependencies,
		GodDaggerTemplates.GODDAGGER_DEPENDENCY_PROPERTY_DECLARATION_TEMPLATE,
		"\n",
		"\t",
		"",
	)


static func _generate_dependencies_parameter_declarations(
	dependencies: Array[GodDaggerParsingResult.CompiledResult.Dependency],
) -> String:
	
	return _generate_dependencies_declarations_with_template(
		dependencies,
		GodDaggerTemplates.GODDAGGER_DEPENDENCY_PARAMETER_DECLARATION_TEMPLATE,
		"",
		"\t\t",
		"",
	)


static func _generate_dependencies_argument_to_property_assignments(
	dependencies: Array[GodDaggerParsingResult.CompiledResult.Dependency],
) -> String:
	
	return _generate_dependencies_declarations_with_template(
		dependencies,
		GodDaggerTemplates.GODDAGGER_DEPENDENCY_ARGUMENT_TO_PROPERTY_ASSIGNMENT_TEMPLATE,
		"\n",
		"\t\t",
		"pass",
	)


static func _generate_dependencies_argument_declarations(
	dependencies: Array[GodDaggerParsingResult.CompiledResult.Dependency],
) -> String:
	
	return _generate_dependencies_declarations_with_template(
		dependencies,
		GodDaggerTemplates.GODDAGGER_DEPENDENCY_ARGUMENT_DECLARATION_TEMPLATE,
		"",
		"\t\t\t",
		"",
	)


static func _generate_dependency_providers_implementations_for_component(
	component: GodDaggerParsingResult.CompiledResult.Component,
) -> String:
	
	var generated_code: String = ""
	
	for dependency in component.get_topologically_ordered_graph():
		if component.is_dependency_inherited(dependency):
			continue
		
		if not generated_code.is_empty():
			generated_code += "\n\n"
		
		var provision_module := dependency.get_provision_module()
		
		if provision_module:
			generated_code += GodDaggerTemplates \
				.GODDAGGER_MODULE_ASSISTED_DEPENDENCY_PROVIDER_TEMPLATE \
				.replace(
					GodDaggerTemplates.ARGUMENT_MODULE_CLASS,
					provision_module.get_module().get_name(),
				) \
				.replace(
					GodDaggerTemplates.ARGUMENT_MODULE_PROVISION_METHOD,
					provision_module.get_method_name(),
				)
			
		else:
			generated_code += GodDaggerTemplates \
				.GODDAGGER_CONSTRUCTOR_INJECTED_DEPENDENCY_PROVIDER_TEMPLATE
		
		var scope := dependency.get_scope()
		
		if scope:
			generated_code = generated_code.replace(
				GodDaggerTemplates.ASSIGN_DEPENDENCY_SCOPE_NULL_ARGUMENT_IF_APPLICABLE, "null,",
			)
		
		else:
			generated_code = generated_code.replace(
				GodDaggerTemplates.ASSIGN_DEPENDENCY_SCOPE_NULL_ARGUMENT_IF_APPLICABLE, "",
			)
		
		generated_code = generated_code \
			.replace(
				GodDaggerTemplates.ARGUMENT_DEPENDENCY_CLASS,
				dependency.get_name(),
			) \
			.replace(
				GodDaggerTemplates.DECLARE_DEPENDENCIES_PROPERTIES,
				_generate_dependencies_property_declarations(
					dependency.get_dependencies(),
				)
			) \
			.replace(
				GodDaggerTemplates.DECLARE_DEPENDENCIES_PARAMETERS,
				_generate_dependencies_parameter_declarations(
					dependency.get_dependencies(),
				)
			) \
			.replace(
				GodDaggerTemplates.ASSIGN_DEPENDENCIES_ARGUMENTS_TO_PROPERTIES,
				_generate_dependencies_argument_to_property_assignments(
					dependency.get_dependencies(),
				)
			) \
			.replace(
				GodDaggerTemplates.DECLARE_DEPENDENCIES_ARGUMENTS,
				_generate_dependencies_argument_declarations(
					dependency.get_dependencies(),
				)
			)
	
	return generated_code


static func _generate_dependency_providers_implementations(
	parsing_result: GodDaggerParsingResult.CompiledResult,
) -> String:
	
	var generated_code: String = ""
	
	for component in parsing_result.get_components():
		generated_code += _generate_dependency_providers_implementations_for_component(component)
	
	for subcomponent in parsing_result.get_subcomponents():
		generated_code += _generate_dependency_providers_implementations_for_component(subcomponent)
	
	return generated_code


static func _generate_subcomponents_implementations(
	parsing_result: GodDaggerParsingResult.CompiledResult,
) -> String:
	return ""


static func _generate_components_implementations(
	parsing_result: GodDaggerParsingResult.CompiledResult,
) -> String:
	return ""


static func generate_code_implementing_components(
	component_relationships_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary[String, GodDaggerGraph],
) -> GodDaggerParsingResult.CompiledResult:
	
	var parsing_result := GodDaggerParsingResult \
		.new(component_relationships_graph, components_to_objects_graphs) \
		._compile()
	
	var did_generate_components_implementation := GodDaggerFileUtils \
		._generate_script_with_contents(
			GodDaggerConstants.GODDAGGER_GENERATED_COMPONENTS_FILE_NAME,
			GodDaggerTemplates.GODDAGGER_GENERATED_COMPONENTS_TEMPLATE \
				.replace(
					GodDaggerTemplates.DECLARE_DEPENDENCY_PROVIDERS,
					_generate_dependency_providers_implementations(parsing_result),
				) \
				.replace(
					GodDaggerTemplates.DECLARE_SUBCOMPONENTS,
					_generate_subcomponents_implementations(parsing_result),
				) \
				.replace(
					GodDaggerTemplates.DECLARE_COMPONENTS,
					_generate_components_implementations(parsing_result),
				),
		)
	
	if did_generate_components_implementation:
		return parsing_result
		
	else:
		return GodDaggerParsingResult \
			.new(
				component_relationships_graph,
				components_to_objects_graphs,
				"Failed to generate code.",
			) \
			._compile()
