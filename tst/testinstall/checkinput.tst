#@local check, count, e, sideEffect
#
# Test CHECK_ALL_COMMANDS, the parse-only input completeness check: it
# classifies input as "complete", "incomplete" (truncated prefix of
# potentially valid input; a frontend should request more input) or "error",
# without executing or printing anything.
#
gap> START_TEST("checkinput.tst");
gap> check := s -> CHECK_ALL_COMMANDS(InputTextString(s)).status;;
gap> count := s -> CHECK_ALL_COMMANDS(InputTextString(s)).statements;;

# complete inputs
gap> check("1+1;");
"complete"
gap> check("1+1;;");
"complete"
gap> check("1+1; 2+2;");
"complete"
gap> check("");
"complete"
gap> check("# comment only\n");
"complete"
gap> check("# comment only");
"complete"
gap> check("1+1; # trailing comment");
"complete"
gap> check("f := function(x) return x; end;;");
"complete"
gap> check("if true then fi;");
"complete"
gap> check("x := 'a';");
"complete"
gap> check("s := \"\"\"a\"\"\";");
"complete"
gap> count("1+1; 2+2;");
2
gap> count("# comment only");
0

# quit, QUIT, help and pragmas parse as complete statements, and like
# everything else they are not executed by the check
gap> check("quit;");
"complete"
gap> check("QUIT;");
"complete"
gap> check("?some help topic");
"complete"
gap> check("#%some pragma\n");
"complete"
gap> check("while true do od;");
"complete"

# nothing is executed and nothing is printed
gap> sideEffect := 0;;
gap> check("sideEffect := 1;");
"complete"
gap> sideEffect;
0
gap> check("Print(999);");
"complete"

# incomplete inputs: open constructs
gap> check("1+");
"incomplete"
gap> check("1+1");
"incomplete"
gap> check("quit");
"incomplete"
gap> check("if 2 >");
"incomplete"
gap> check("if 2 > 1 then");
"incomplete"
gap> check("while true do");
"incomplete"
gap> check("for i in [1..3] do");
"incomplete"
gap> check("repeat");
"incomplete"
gap> check("f := function(x)");
"incomplete"
gap> check("f := x ->");
"incomplete"
gap> check("x := [1, 2");
"incomplete"
gap> check("r := rec(a := 1,");
"incomplete"

# incomplete inputs: end of input hit inside a token
gap> check("s := \"abc");
"incomplete"
gap> check("s := \"\"\"abc\nline2");
"incomplete"
gap> check("x := 'a");
"incomplete"
gap> check("1.5e");
"incomplete"
gap> check("1+1;\\");
"incomplete"

# a complete statement followed by an open construct is incomplete; the
# statement count reports how many statements already parsed completely
gap> check("1+1; if 2 >");
"incomplete"
gap> count("1+1; if 2 >");
1

# genuine syntax errors, including ones followed by valid statements
gap> check("1+;");
"error"
gap> check("1+; 2+2;");
"error"
gap> check("if then fi;");
"error"
gap> check("fi;");
"error"
gap> check("od;");
"error"
gap> check("f(;");
"error"
gap> check("x := \"abc\ndef\";");
"error"
gap> check("1+1;\n1+;");
"error"
gap> count("1+1;\n1+;");
1

# diagnostics are returned as records instead of being printed
gap> e := CHECK_ALL_COMMANDS(InputTextString("1+;")).errors[1];;
gap> [ e.message, e.isError, e.line, e.pos ];
[ "expression expected", true, 1, 2 ]
gap> e := CHECK_ALL_COMMANDS(InputTextString("1+1;\n1+;")).errors[1];;
gap> [ e.message, e.line ];
[ "expression expected", 2 ]
gap> CHECK_ALL_COMMANDS(InputTextString("if 2 >")).errors[1].message;
"expression expected"
gap> CHECK_ALL_COMMANDS(InputTextString("s := \"abc")).errors[1].message;
"String must end with \" before end of file"
gap> CHECK_ALL_COMMANDS(InputTextString("1+1;")).errors;
[  ]

# the argument must be an input stream
gap> CHECK_ALL_COMMANDS(fail);
Error, CHECK_ALL_COMMANDS: <instream> must be an input stream (not the value '\
fail')

#
gap> STOP_TEST("checkinput.tst");
