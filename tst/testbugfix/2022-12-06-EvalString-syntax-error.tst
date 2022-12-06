# make sure that syntax error messages during EvalString are displayed correctly
# See https://github.com/gap-system/gap/issues/5242
gap> EvalString( "(1" );
Syntax error: ) expected in stream:1
_EVALSTRINGTMP:=(1;
                  ^
Error, Could not evaluate string.

