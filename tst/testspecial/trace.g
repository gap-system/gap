#
# tracing of operations
#

# create a dummy operation
o:=NewOperation("dummy",[]);
InstallOtherMethod(o,[],{}->[]);
InstallOtherMethod(o,[IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt,IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt,IsInt,IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt,IsInt,IsInt,IsInt,IsInt],{arg...}->arg);

# without tracing
o();
o(1);
o(1,2);
o(1,2,3);
o(1,2,3,4);
o(1,2,3,4,5);
o(1,2,3,4,5,6);
o(1,2,3,4,5,6,7); # not (yet?) supported

# with tracing
TraceMethods( o );
o();
o(1);
o(1,2);
o(1,2,3);
o(1,2,3,4);
o(1,2,3,4,5);
o(1,2,3,4,5,6);
o(1,2,3,4,5,6,7);
UntraceMethods( o ); # not (yet?) supported

# again without tracing
o();
o(1);
o(1,2);
o(1,2,3);
o(1,2,3,4);
o(1,2,3,4,5);
o(1,2,3,4,5,6);
o(1,2,3,4,5,6,7); # not (yet?) supported

#
# tracing of constructors
#

# create a dummy constructor
o:=NewConstructor("foobar",[IsObject]);
InstallOtherMethod(o,[IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt,IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt,IsInt,IsInt,IsInt],{arg...}->arg);
InstallOtherMethod(o,[IsInt,IsInt,IsInt,IsInt,IsInt,IsInt],{arg...}->arg);

# without tracing
o(IsInt);
o(IsInt,2);
o(IsInt,2,3);
o(IsInt,2,3,4);
o(IsInt,2,3,4,5);
o(IsInt,2,3,4,5,6);
o(IsInt,2,3,4,5,6,7); # not (yet?) supported

# with tracing
TraceMethods( o );
o(IsInt);
o(IsInt,2);
o(IsInt,2,3);
o(IsInt,2,3,4);
o(IsInt,2,3,4,5);
o(IsInt,2,3,4,5,6);
o(IsInt,2,3,4,5,6,7); # not (yet?) supported
UntraceMethods( o );

# again without tracing
o(IsInt);
o(IsInt,2);
o(IsInt,2,3);
o(IsInt,2,3,4);
o(IsInt,2,3,4,5);
o(IsInt,2,3,4,5,6);
o(IsInt,2,3,4,5,6,7); # not (yet?) supported
