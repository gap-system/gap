gap> IsAutoGlobal("testglobalvar");
false
gap> g := function(x) Print("Checkg\n"); end;;
gap> f := function(x) Print("Checkf\n"); testglobalvar := 3; end;;
Syntax warning: Unbound global variable in stream:1
f := function(x) Print("Checkf\n"); testglobalvar := 3; end;;
                                    ^^^^^^^^^^^^^
gap> AUTO();
Error, Function: number of arguments must be at least 2 (not 0)
gap> AUTO(g);
Error, Function: number of arguments must be at least 2 (not 1)
gap> AUTO(g, 1);
gap> AUTO(g, 1, "testglobalvar");
gap> IsAutoGlobal("testglobalvar");
true
gap> testglobalvar;
Checkg
Error, Variable: automatic variable 'testglobalvar' must get a value by functi\
on call
gap> AUTO(f, 1, "testglobalvar");
gap> IsAutoGlobal("testglobalvar");
true
gap> testglobalvar;
Checkf
3
gap> IsAutoGlobal("testglobalvar");
false
gap> testglobalvar;
3
gap> Unbind(testglobalvar);
gap> IsAutoGlobal("testglobalvar");
false
#@if IsHPCGAP
gap> threadlocalvar := "test";;
gap> MakeThreadLocal("threadlocalvar");;
gap> IsAutoGlobal("threadlocalvar");
false
#@fi
