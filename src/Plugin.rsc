module Plugin

import AST;
import Parse;
import Load;
import Resolver;
import Checker;
import Visuals;

import util::IDE;
import util::Prompt;
import vis::Figure;
import vis::Render;
import IO;
import ValueIO;
import Message;

import ParseTree; 
import AST;
import Node;
import Map;

import analysis::DeadFeatureDetector;

anno rel[loc, loc] Tree@hyperlinks;

private str LANGUAGE_NAME = "Feature Description Language";
private str LANGUAGE_EXTENTION  = "fdl";

private alias Information = tuple[FeatureDiagram current, Included included, Defs defs, Refs refs, 	RefsInDef refsInDef, ResolvedRefs resolvedRefs];

public void main() {
	registerLanguage(LANGUAGE_NAME, LANGUAGE_EXTENTION, Tree(str src, loc l) {
    	return parseFeatureDiagram(src, l);
  	});
  	
	contribs = {
    	annotator(Tree (Tree fd) {
      		<ast, diagrams, defs, refs, refsInDef, resolvedRefs> = gatherInfo(fd);
    		     		
      		msgs = check(defs, refs, refsInDef, resolvedRefs);
      		return fd[@messages=msgs][@hyperlinks=resolvedRefs];
    	}),
    	
    	popup(
	      menu("Feature Diagram", [
	        action("Visualise", void (Tree fd, loc selection) {
	      		<_, diagrams, defs, refs, refsInDef, resolvedRefs> = gatherInfo(fd);
	        	
	        	check(defs, refs, refsInDef, resolvedRefs) == {}
	        		? renderFeatureDiagram(diagrams, defs, resolvedRefs)
	        		: alert("The diagram definition contains errors. They need to be fixed before the graph can be created");
	        	
	        }),
	        action("Save visualisation", void (Tree fd, loc selection) {
	      		<_, diagrams, defs, refs, refsInDef, resolvedRefs> = gatherInfo(fd);
	        	
	        	if (check(defs, refs, refsInDef, resolvedRefs) != {}) {
	        		alert("The diagram definition contains errors. They need to be fixed before the graph can be created");
	        	}
	        	
	        	name = prompt("Enter the file name for the visualisation: ");
	        	
	        	saveRenderedFeatureDiagram(|project://feature-diagram-language/bin/<name>.png|, diagrams, defs, resolvedRefs);
	        }),
	        menu("Analysis", [
	         action("Find Dead Features", void (Tree fd, loc selection) {
	           DeadFeatureResult result = findDeadFeatures(implodeFDL(fd));
	           
	           if (result == noDeadFeaturesFound()) {
	             alert("No dead features found");
	           } else {
	             alert("Dead features detected:
	                   '<for (QualifiedName qn <- result.deadFeatures) {>
	                   ' * <qn.name><}>
	                   '");
	           }	               
	         })
	        ])
	      ])
	    )    	
    };
    
    Information gatherInfo(Tree fd) {
  		ast = implodeFDL(fd);
		  diagrams = resolveIncludes(ast);
  		defs = resolveDefinitions(diagrams);
  		refs = resolveReferences(diagrams);
  		refsInDef = resolveReferencesInDefinitions(diagrams);	
  		resolved = resolveFeatures(defs, refs);
  		
  		return <ast, diagrams, defs, refs, refsInDef, resolved>;    	
    }
    
   	registerContributions(LANGUAGE_NAME, contribs);
}
