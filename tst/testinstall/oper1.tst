#
gap> IsMyProperty := NewProperty( "IsMyProperty", IsObject );
<Property "IsMyProperty">
gap> List([0..6], n->Length(METHODS_OPERATION(IsMyProperty, n)) / (BASE_SIZE_METHODS_OPER_ENTRY+n));
[ 0, 1, 0, 0, 0, 0, 0 ]
gap> List(MethodsOperation(IsMyProperty, 1), x->x.info);
[ "IsMyProperty: system getter" ]

#
gap> INSTALL_METHOD_FLAGS( IsMyProperty, "bla", {}->0, [IsObject], 0, {x}->fail );
Error, IsMyProperty: <famrel> must accept 1 arguments
gap> INSTALL_METHOD_FLAGS( IsMyProperty, "bla", fail, [IsObject], 0, {x}->fail );
Error, IsMyProperty: <famrel> must be a function, `true', or `false'
gap> INSTALL_METHOD_FLAGS( IsMyProperty, "bla", false, [IsObject], 0, {}->fail );
Error, IsMyProperty: <method> must accept 1 arguments

#
gap> InstallMethod();
Error, too few arguments given in <arglist>
gap> InstallMethod(1);
Error, too few arguments given in <arglist>
gap> InstallMethod(1,2);
Error, too few arguments given in <arglist>
gap> InstallMethod(1,2,fail);
Error, <opr> is not an operation
gap> InstallMethod(IsMyProperty,2,fail);
Error, <arglist>[2] must be a list of filters
gap> InstallMethod(IsMyProperty,[1..7],fail);
Error, methods can have at most 6 arguments
gap> InstallMethod(IsMyProperty,["false"],fail);
Error, string does not evaluate to a function
gap> InstallMethod(IsMyProperty,[],3);
Error, the method is missing in <arglist>
gap> InstallMethod(IsMyProperty,[IsPGroup],true);
Error, IsMyProperty: use `InstallTrueMethod' for <opr>
gap> InstallMethod(IsMyProperty,[],fail);
Error, the number of arguments does not match a declaration of IsMyProperty
gap> InstallMethod(IsMyProperty,[],{}->1);
Error, the number of arguments does not match a declaration of IsMyProperty
gap> InstallMethod(IsMyProperty,[IsGroup],{}->1);
Error, IsMyProperty: <method> must accept 1 arguments
gap> InstallMethod(IsMyProperty,{}->1,[IsGroup],{}->1);
Error, IsMyProperty: <famrel> must accept 1 arguments

# verify that no new methods were added
gap> List([0..6], n->Length(METHODS_OPERATION(IsMyProperty, n)) / (BASE_SIZE_METHODS_OPER_ENTRY+n));
[ 0, 1, 0, 0, 0, 0, 0 ]
gap> List(MethodsOperation(IsMyProperty, 1), x->x.info);
[ "IsMyProperty: system getter" ]

# actually install some methods
gap> InstallMethod(IsMyProperty,"for any object", [IsObject], false);
gap> InstallMethod(IsMyProperty,"for an integer", [IsInt], IsEvenInt);
gap> IsMyProperty(fail);
false
gap> IsMyProperty(0);
true
gap> IsMyProperty(1);
false
gap> List(MethodsOperation(IsMyProperty, 1), x->x.info);
[ "IsMyProperty: system getter", "IsMyProperty: for an integer", 
  "IsMyProperty: for any object" ]

# verify Reread does the right thing
gap> Reread(InputTextString("""InstallMethod(IsMyProperty,"for any object", [IsObject], x->x=fail);"""));
gap> IsMyProperty(fail);
true
gap> IsMyProperty(0);
true
gap> IsMyProperty(1);
false
gap> List(MethodsOperation(IsMyProperty, 1), x->x.info);
[ "IsMyProperty: system getter", "IsMyProperty: for an integer", 
  "IsMyProperty: for any object" ]

#
gap> RedispatchOnCondition();
Error, Usage: RedispatchOnCondition(oper[,info],fampred,reqs,cond,val)
