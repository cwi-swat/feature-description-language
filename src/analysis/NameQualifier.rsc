module analysis::NameQualifier

import AST;
import Resolver;
import Relation;

import IO;

set[FeatureDiagram] qualifyNames(set[FeatureDiagram] diagrams) {
  rel[loc,QualifiedName] defs = invert(resolveDefinitions(diagrams));
  rel[loc,QualifiedName] refs = invert(resolveReferences(diagrams));
  
  set[FeatureDiagram] result = {};
  
  for (FeatureDiagram dia <- diagrams) {
    result += visit(dia) {
      case definition(str name, FeatureExpression exp) => definition("<dia.name>_<name>", exp)
      
      case feature(str name) => feature("<dia.name>_<name>")
      case feature(str ns, str name) => feature("<ns>_<name>")
      case atomic(str name) => atomic("<dia.name>_<name>")
      case atomic(str ns, str name) => atomic("<ns>_<name>")
     }
  }
  
  return result;
}
