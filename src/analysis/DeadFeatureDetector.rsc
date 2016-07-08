module analysis::DeadFeatureDetector

import AST;
import Load;
import Resolver;

import analysis::NameQualifier;
import analysis::SmtTranslator;
import smt::solver::SolverRunner;

import IO;

data DeadFeatureResult
  = noDeadFeaturesFound()
  | deadFeaturesFound(set[QualifiedName] deadFeatures)
  ;
  
DeadFeatureResult findDeadFeatures(FeatureDiagram dia) {
  // Make sure that the root node always is available
  dia = addConstraint(dia, constraintUser(include(feature(getRoot(dia).name)))); 
  
  // Resolve all included diagrams
  set[FeatureDiagram] dias = qualifyNames(resolveIncludes(dia));
  
  // Translate the 'static part' to SMT constraints
  list[str] smt = translateToSmt(dias);

  SolverPID pid = startSolver();
  
  loadSmtSetup(pid, smt);

  // check every feature individual whether it is dead or not
  set[QualifiedName] deadFeatures = {};
  
  for(/QualifiedName qn := dias) {
    str featureConstraint = translateUserConstraint(include(qn));
    bool isDead = !(isSatisfiable(pid, featureConstraint));
    
    if(isDead) {
      deadFeatures += qn;    
    }
  }  

  stopSolver(pid);
    
  return (deadFeatures == {}) ? noDeadFeaturesFound() : deadFeaturesFound(deadFeatures);
}

void loadSmtSetup(SolverPID pid, list[str] smt) {
  for (s <- smt) {
    runSolver(pid, s);
  }
}

FeatureDefinition getRoot(FeatureDiagram dia) = dia.definitions.definitions[0];

FeatureDiagram addConstraint(FeatureDiagram orig, Constraint newConstraint) =
  diagram(orig.name, orig.includes, orig.definitions, orig.constraints + newConstraint)[@location = orig@location];