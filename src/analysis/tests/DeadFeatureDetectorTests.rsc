module analysis::tests::DeadFeatureDetectorTests

import Load;
import AST;

import analysis::DeadFeatureDetector;

import IO;

DeadFeatureResult testFindDeadFeatures()  = testFindDeadFeatures(|project://feature-description-language/src/analysis/tests/car_withDeadFeatures.fdl|);


DeadFeatureResult testFindDeadFeatures(loc file)  {
  FeatureDiagram testDia = load(file);
  return findDeadFeatures(testDia);
}

test bool testFindDeadFeatures_noDeadFeatures() =
  testFindDeadFeatures(|project://feature-description-language/src/analysis/tests/car_withoutDeadFeatures.fdl|) == noDeadFeaturesFound();

test bool testFindDeadFeatures_deadFeatures() =
  testFindDeadFeatures(|project://feature-description-language/src/analysis/tests/car_withDeadFeatures.fdl|) == deadFeaturesFound({atomic("car_lowPower"), atomic("car_mediumPower")}); 