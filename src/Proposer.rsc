module Proposer

import AST;
import Resolver;

import util::ContentCompletion;

import ParseTree;
import List;
import IO;

list[CompletionProposal] propose(FeatureDiagram current, Included diagrams, ResolvedRefs resolvedReference, Defs definitions, str prefix, int requestOffset) {
	if (!isReferencingFeature(current, requestOffset)) {
		return [];
	}
	
	proposals = createProposals(definitions, current.name);
	proposals = sort(proposals);
	proposals = filterPrefix(proposals, prefix);
	
	return proposals;	
}

private list[CompletionProposal] createProposals(Defs definitions, str diagramName) = 
	[sourceProposal("<ns>.<name>", "<ns>.<name> - Feature") | <qn(ns, name:/^[A-Z].*/), _> <- definitions, ns != diagramName] +
	[sourceProposal("<name>", "<name> - Feature") | <qn("<diagramName>", name:/^[A-Z].*/), _> <- definitions];

private bool isReferencingFeature(FeatureDiagram fd, int offset) {
	bottom-up-break visit(fd) {
		case reference:ref(_): if (isCursosWithin(reference@location, offset)) { return true; } 
	}
	
	return false;
}

private bool isCursosWithin(loc location, int offset) {
	if (offset < 0) return false;

	int begin = location.offset;
	int end = begin + location.length;	
	return begin <= offset && end >= offset;
}