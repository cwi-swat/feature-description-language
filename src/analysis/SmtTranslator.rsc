module analysis::SmtTranslator

import AST;
import List;

list[str] translateToSmt(set[FeatureDiagram] diagrams) {
  // first declare all variables
  list[str] smtCommands = ["(declare-const <name> Bool)" | str name <- {qn.name | /QualifiedName qn := diagrams}];
  
  for (FeatureDiagram dia <- diagrams) {
    smtCommands += translateDefs(dia);
    smtCommands += translateConstraints(dia.constraints);
  }
  
  return smtCommands;
}

list[str] translateConstraints(list[Constraint] constraints) =
  ([] | it + translateConstraint(c) | Constraint c <- constraints);

str translateConstraint(constraintDia(DiagramConstraint diaConst)) = translateDiagramConstraint(diaConst);
str translateConstraint(constraintUser(UserConstraint userConst)) = translateUserConstraint(userConst);

str translateDiagramConstraint(requires(QualifiedName feature1, QualifiedName feature2)) =
  "(assert (=\> <feature1.name> <feature2.name>))";

str translateDiagramConstraint(excludes(QualifiedName feature1, QualifiedName feature2)) =
  "(assert (=\> <feature1.name> (not <feature2.name>)))";

str translateUserConstraint(include(QualifiedName feature)) =
  "(assert <feature.name>)";

str translateUserConstraint(exclude(QualifiedName feature)) =
  "(assert (not <feature.name>))";
 

list[str] translateDefs(FeatureDiagram dia) =
  ([] | it + translateDef(def) | FeatureDefinition def <- dia.definitions.definitions); 
  
str translateDef(FeatureDefinition def) =
  "(assert (=\> <def.name> <translateExpr(def.expression)>))";
 
str translateExpr(requireAll(list[FeatureExpression] features)) =
  "(and <intercalate(" ", [translateFeatRef(f) | f <- features])>)"; 

str translateExpr(moreOf(list[FeatureExpression] features)) =
  "(or <intercalate(" ", [translateFeatRef(f) | f <- features])>)"; 

str translateExpr(oneOf(list[FeatureExpression] features)) {
  list[str] perm = [];
  
  for (int x <- [0 .. size(features)]) {
    list[str] elems = [];    
    
    for (int y <- [0 .. size(features)]) {
      elems += (x == y) ? translateFeatRef(features[y]) : "(not <translateFeatRef(features[y])>)";  
    }
    
    perm += "(and <intercalate(" ", elems)>)";
  }
  
  return "(or <intercalate(" ", perm)>)";
}

str translateFeatRef(feature(QualifiedName feature)) = feature.name;
str translateFeatRef(optional(FeatureExpression expression)) = "";
//str translateFeatRef(defaultValue(str atomic))

