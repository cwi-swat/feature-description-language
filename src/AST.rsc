module AST

data FeatureDiagram
	= diagram(str name, list[str] includes, FeatureDefinitions definitions, list[Constraint] constraints)
	;
	
data FeatureDefinitions 
	= definitions(list[FeatureDefinition] definitions)
	;
	
data FeatureDefinition
	= definition(str name, FeatureExpression expression) 
	;

data FeatureExpression
	= requireAll(list[FeatureExpression] features)
	| oneOf(list[FeatureExpression] features)
	| moreOf(list[FeatureExpression] features)
	| feature(QualifiedName feature)
	| optional(FeatureExpression expression) 
	| defaultValue(str atomic)
	;

data QualifiedName
    = feature(str name)
    | atomic(str name)
    | feature(str namespace, str name)
    | atomic(str namespace, str name)
    ;

data Constraint
	= constraintDia(DiagramConstraint diaConst)
	| constraintUser(UserConstraint userConst)
	;
	
data DiagramConstraint
	= requires(QualifiedName feature1, QualifiedName feature2) 
	| excludes(QualifiedName feature1, QualifiedName feature2)
	;
	
data UserConstraint
	= include(QualifiedName feature)
	| exclude(QualifiedName feature)
	; 

anno loc FeatureDiagram@location;
anno loc FeatureDefinition@location;
anno loc QualifiedName@location;
anno loc FeatureExpression@location;