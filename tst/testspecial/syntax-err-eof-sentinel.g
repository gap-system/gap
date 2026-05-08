# Regression test for a 0xFF byte leak in syntax-error context lines.
#
# When a syntax error fires after the scanner has advanced past EOF
# (e.g. parsing "h := ;" via READ_ALL_COMMANDS from a string with no
# trailing newline), the input-line buffer is replaced with the
# scanner's end-of-input sentinel (0xFF). Before the fix in
# src/scanner.c the SyntaxErrorOrWarning() pretty-printer would dump
# that sentinel verbatim alongside the error message — visible as a
# stray `ÿ` glyph in any UTF-8 / log-file consumer of *errout*
# (e.g. the JupyterKernel package).
errFile := Filename(DirectoryTemporary(), "syntax.log");;
errStream := OutputTextFile(errFile, false);;
SetPrintFormattingStatus(errStream, false);;

MakeReadWriteGlobal("ERROR_OUTPUT");;
saved := ERROR_OUTPUT;;
ERROR_OUTPUT := errStream;;
MakeReadOnlyGlobal("ERROR_OUTPUT");;

READ_ALL_COMMANDS(InputTextString("h := ;"), false, false, IdFunc);;

MakeReadWriteGlobal("ERROR_OUTPUT");;
ERROR_OUTPUT := saved;;
MakeReadOnlyGlobal("ERROR_OUTPUT");;
CloseStream(errStream);;

inStream := InputTextFile(errFile);;
captured := ReadAll(inStream);;
CloseStream(inStream);;

Print("contains-eof-sentinel: ", '\377' in captured, "\n");
Print("contains-error-message: ",
      PositionSublist(captured, "expression expected") <> fail, "\n");
