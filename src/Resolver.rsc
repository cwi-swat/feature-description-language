module Resolver

import AST;
import Parse;
import Load;
import Set;

alias Included = set[FeatureDiagram];
alias Refs = rel[QualifiedName name, loc location];
alias Defs = rel[QualifiedName name, loc location];
alias ResolvedRefs = rel[loc ref, loc def];
alias RefsInDef = rel[loc def, loc ref];

Included resolveIncludes(FeatureDiagram fd) = resolveIncludes(fd, {});

private Included resolveIncludes(FeatureDiagram fd, set[str] alreadyIncluded) {
	alreadyIncluded += fd.name;

	includes = {};
	for (include <- fd.includes, include notin alreadyIncluded) {
		includes += resolveIncludes(load(fd@location.top.parent + "<include>.fdl"), alreadyIncluded);
	}
				
	return fd + includes;
}

Defs resolveDefinitions(Included diagrams) =
	{<feature(diagram.name, name), def@location> | diagram <- diagrams, /def:definition(str name, _) <- diagram} +
	{<atomic("<diagram.name>.<defName>", name), atom@location> | diagram <- diagrams, /def:definition(str defName, _) <- diagram, /atom:feature(atomic(str name)) <- def};

Refs resolveReferences(Included diagrams) =
	{<feature(diagram.name, name), ref@location> | diagram <- diagrams, /ref:feature(feature(str name)) <- diagram} +
	{<feature(ns, name), ref@location> | diagram <- diagrams, /ref:feature(feature(str ns, str name)) <- diagram};
	
RefsInDef resolveReferencesInDefinitions(Included diagrams) =
	{<def@location, ref@location> | /def:definition(_, fe) <- diagrams, /ref:feature(feature(_)) <- fe} + 
	{<def@location, ref@location> | /def:definition(_, fe) <- diagrams, /ref:feature(feature(_,_)) <- fe};
	
ResolvedRefs resolveFeatures(Defs definitions, Refs references) =
	{<use, df> | <qn, use> <- references, {df} := definitions[qn]};	
	