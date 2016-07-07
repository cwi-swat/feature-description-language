module Helper

extend Syntax;
extend Load;
extend Resolver;
extend Checker;
extend Visuals;

import Message;

void render(str diagram) = render(visualize(diagram));

void save(str diagram) = renderSave(visualize(diagram), |project://feature-diagram-language/bin/output.png|);

private Figure visualize(str diagram) {
	ast = loadExample("<diagram>.fdl");
	diagrams = resolveIncludes(ast);
	defs = resolveDefinitions(diagrams);
	refs = resolveReferences(diagrams);
	resolved = resolveFeatures(defs, refs);
	
	return visualize(diagrams, defs, resolved);
}

ResolvedRefs resolveFeatures(str diagram) {
	ast = loadExample("<diagram>.fdl");
	diagrams = resolveIncludes(ast);
	defs = resolveDefinitions(diagrams);
	refs = resolveReferences(diagrams);
	
	return resolveFeatures(diagrams, defs, refs);	
}

set[Message] check(str diagram) {
	ast = loadExample("<diagram>.fdl");
	diagrams = resolveIncludes(ast);
	defs = resolveDefinitions(diagrams);
	refs = resolveReferences(diagrams);
	refsInDef = resolveReferencesInDefinitions(diagrams);	
	resolved = resolveFeatures(diagrams, defs, refs);
	     		
    return check(defs, refs, refsInDef, resolved);
}

Included resolveIncludes(str diagram) = resolveIncludes(loadExample("<diagram>.fdl"));

Defs resolveDefinitions(str diagram) = resolveDefinitions(resolveIncludes(diagram));

Refs resolveUses(str diagram) = resolveReferences(resolveIncludes(diagram));