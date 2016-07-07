module Syntax

extend lang::std::Layout;
extend lang::std::Id;

lexical FeatureName = [a-z A-Z 0-9 _] !<< [A-Z][a-z A-Z 0-9 _]* !>> [a-z A-Z 0-9 _];
lexical AtomicFeatureName = ([a-z A-Z 0-9 _] !<< [a-z][a-z A-Z 0-9 _]* !>> [a-z A-Z 0-9 _]) \ Keyword;

start syntax FeatureDiagram 
	= diagram: "diagram" Id name ("include" {Include ","}* includes)? "features" FeatureDefinitions definitions ("constraints" Constraint* constraints)?;

syntax Include
	= fileName: Id fileName;

syntax FeatureDefinitions
	= definitions: FeatureDefinition* definitions;

syntax FeatureDefinition
	= definition: FeatureName name ":" FeatureExpression expression; 

syntax FeatureExpression
	= requireAll: "all" "(" FeatureList list ")"
	| oneOf: "one-of" "(" FeatureList list ")"
	| moreOf: "more-of" "(" FeatureList list ")"
	| feature: QualifiedName feature
	| optional: FeatureExpression expression "?" 
	| defaultValue: "default" "=" AtomicFeatureName
	;
	
syntax QualifiedName 
	= feature: FeatureName feature
	| atomic: AtomicFeatureName atomic
	| feature: Id namespace "." FeatureName feature
	| atomic: Id namespace "." AtomicFeatureName atomic
	;
	
syntax FeatureList
	= {FeatureExpression ","}+
	;

syntax Constraint
	= constraintDia: DiagramConstraint diaConst
	| constraintUser: UserConstraint userConst
	;
		
syntax DiagramConstraint
	= requires: QualifiedName feature1 "requires" QualifiedName feature2 
	| excludes: QualifiedName feature1 "excludes" QualifiedName feature2
	;
	
syntax UserConstraint
	= include: "include" QualifiedName feature
	| exclude: "exclude" QualifiedName feature
	; 
	
keyword Keyword
  = "include" | "exclude" | "requires" | "excludes" | "all" | "one-of" | "more-of" | "diagram" | "features" | "constraints" | "default";
  
