# Installing an operation as a method for itself is forbidden (now, at least;
# it used to lead to a segfault if you ever managed to trigger that "method")
# Fixes GitHub issues #1286 and #4340.
gap> foo := NewOperation("foo", [IsObject]);;
gap> InstallMethod(foo, [IsInt], foo);
Error, Cannot install an operation as a method for itself
