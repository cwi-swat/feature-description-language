module analysis::tests::TranslaterTests

import analysis::NameQualifier;
import analysis::SmtTranslator;

import Load;
import AST;
import Resolver;

import IO;

void testQualifier(loc file) {
  set[FeatureDiagram] dias = qualifyNames(resolveIncludes(load(file)));
  iprintln(dias);    
}

void testTranslation(loc file) {
  list[str] smtCommands = translateToSmt(qualifyNames(resolveIncludes(load(file))));
  
  for (s <- smtCommands) {
    println(s);
  }
}
