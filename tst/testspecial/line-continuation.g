#
# Verify that a CRLF after a line continuation increments the current line
# counter only once, so that both examples below report the error in line 2.
#
EvalString("123\\\n45x;");
quit;
EvalString("123\\\r\n45x;");
quit;
