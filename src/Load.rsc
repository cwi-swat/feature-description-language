module Load

import Parse;
import AST;
import ParseTree;

FeatureDiagram load(loc l) = implodeFDL(parseFeatureDiagram(l));

FeatureDiagram implodeFDL(Tree fd) = implode(#FeatureDiagram, fd); 