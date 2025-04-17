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


static func _generate_module_local_instantiations(
	modules: Array[GodDaggerParsingResult.CompiledResult.Module],
) -> String:
	
	var generated_code: String = ""
	
	for module in modules:
		if not generated_code.is_empty():
			generated_code = "\t\t"
		
		generated_code += GodDaggerTemplates.GODDAGGER_MODULE_LOCAL_INSTANTIATIONS_TEMPLATE \
			.replace(
				GodDaggerTemplates.ARGUMENT_MODULE_CLASS,
				module.get_name(),
			) \
			.replace(
				GodDaggerTemplates.ARGUMENT_MODULE_CLASS_SNAKE_CASE,
				module.get_name().to_snake_case(),
			)
	
	return generated_code


static func _generate_providers_argument_declarations(
	dependencies: Array[GodDaggerParsingResult.CompiledResult.Dependency],
) -> String:
	
	var generated_code: String = ""
	
	for dependency in dependencies:
		if not generated_code.is_empty():
			generated_code += "\n\t\t\t"
		
		generated_code += GodDaggerTemplates.GODDAGGER_PROVIDER_ARGUMENT_DECLARATION_TEMPLATE \
			.replace(
				GodDaggerTemplates.ARGUMENT_DEPENDENCY_CLASS_SNAKE_CASE,
				dependency.get_name().to_snake_case(),
			)
	
	return generated_code


static func _generate_providers_property_instantiations(
	dependencies: Array[GodDaggerParsingResult.CompiledResult.Dependency],
) -> String:
	
	var generated_code: String = ""
	
	for dependency in dependencies:
		if generated_code.is_empty():
			generated_code += "\n"
			
		else:
			generated_code += "\n"
		
		var provision_module := dependency.get_provision_module()
		
		if provision_module:
			generated_code += GodDaggerTemplates \
				.GODDAGGER_MODULE_ASSISTED_PROVIDER_CREATION_TO_PROPERTY_ASSIGNMENT_TEMPLATE \
				.replace(
					GodDaggerTemplates.ARGUMENT_MODULE_CLASS_SNAKE_CASE,
					provision_module.get_module().get_name().to_snake_case(),
				)
			
		else:
			generated_code += GodDaggerTemplates \
				.GODDAGGER_CONSTRUCTOR_INJECTED_PROVIDER_CREATION_TO_PROPERTY_ASSIGNMENT_TEMPLATE
		
		generated_code = generated_code \
			.replace(
				GodDaggerTemplates.ARGUMENT_DEPENDENCY_CLASS,
				dependency.get_name(),
			) \
			.replace(
				GodDaggerTemplates.ARGUMENT_DEPENDENCY_CLASS_SNAKE_CASE,
				dependency.get_name().to_snake_case(),
			) \
			.replace(
				GodDaggerTemplates.DECLARE_PROVIDERS_ARGUMENTS,
				_generate_providers_argument_declarations(dependency.get_dependencies()),
			)
	
	return generated_code


static func _generate_exposed_dependencies_access_method_declarations(
	dependencies: Array[GodDaggerParsingResult.CompiledResult.Dependency],
) -> String:
	
	var generated_code: String = ""
	
	for dependency in dependencies:
		if not generated_code.is_empty():
			generated_code += "\n\t"
		
		generated_code += GodDaggerTemplates \
			.GODDAGGER_EXPOSED_DEPENDENCY_ACCESS_METHOD_DECLARATION_TEMPLATE \
			.replace(
				GodDaggerTemplates.ARGUMENT_DEPENDENCY_CLASS,
				dependency.get_name(),
			) \
			.replace(
				GodDaggerTemplates.ARGUMENT_DEPENDENCY_CLASS_SNAKE_CASE,
				dependency.get_name().to_snake_case(),
			)
	
	return generated_code


static func _generate_component_implementation(
	component: GodDaggerParsingResult.CompiledResult.Component,
) -> String:
	
	return GodDaggerTemplates.GODDAGGER_COMPONENT_TEMPLATE \
		.replace(
			GodDaggerTemplates.ARGUMENT_COMPONENT_CLASS,
			component.get_class(),
		) \
		.replace(
			GodDaggerTemplates.DECLARE_DEPENDENCIES_PROPERTIES,
			_generate_dependencies_property_declarations(
				component.get_topologically_ordered_graph(),
			),
		) \
		.replace(
			GodDaggerTemplates.INSTANTIATE_MODULES,
			_generate_module_local_instantiations(component.get_modules()),
		) \
		.replace(
			GodDaggerTemplates.INSTANTIATE_PROVIDERS,
			_generate_providers_property_instantiations(
				component.get_topologically_ordered_graph(),
			),
		) \
		.replace(
			GodDaggerTemplates.DECLARE_EXPOSED_DEPENDENCIES_ACCESS_METHODS,
			_generate_exposed_dependencies_access_method_declarations(
				component.get_exposed_dependencies(),
			),
		)


static func _generate_subcomponents_implementations(
	parsing_result: GodDaggerParsingResult.CompiledResult,
) -> String:
	
	var generated_code: String = ""
	
	for component in parsing_result.get_subcomponents():
		generated_code += _generate_component_implementation(component)
	
	return generated_code


static func _generate_components_implementations(
	parsing_result: GodDaggerParsingResult.CompiledResult,
) -> String:
	
	var generated_code: String = ""
	
	for component in parsing_result.get_components():
		generated_code += _generate_component_implementation(component)
	
	return generated_code


static func _conflate_empty_structures(generated_code: String) -> String:
	
	var conflate_empty_constructors = RegEx.new()
	conflate_empty_constructors.compile("_init\\((\\W)*\\)")
	generated_code = conflate_empty_constructors.sub(generated_code, "_init()", true)
	
	var conflate_empty_constructor_calls = RegEx.new()
	conflate_empty_constructor_calls.compile("\\.new\\((\\W)*\\)")
	generated_code = conflate_empty_constructor_calls.sub(generated_code, ".new()", true)
	
	return generated_code


static func generate_code_implementing_components(
	component_relationships_graph: GodDaggerGraph,
	components_to_objects_graphs: Dictionary[String, GodDaggerGraph],
) -> GodDaggerParsingResult.CompiledResult:
	
	var parsing_result := GodDaggerParsingResult \
		.new(component_relationships_graph, components_to_objects_graphs) \
		._compile()
	
	var components_implementation_generated_code := GodDaggerTemplates \
		.GODDAGGER_GENERATED_COMPONENTS_TEMPLATE \
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
		) % randi() % 100000
	
	components_implementation_generated_code = _conflate_empty_structures(
		components_implementation_generated_code,
	)
	
	var did_generate_components_implementation := GodDaggerFileUtils \
		._generate_script_with_contents(
			"%s%s" % [
				GodDaggerConstants.GODDAGGER_GENERATED_COMPONENTS_FILE_NAME,
				randi() % 100000
			],
			components_implementation_generated_code,
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
