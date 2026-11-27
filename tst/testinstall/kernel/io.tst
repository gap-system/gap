#
# Tests for reading files with src/io.c; only real files take the path that
# scans them in place, streams do not
#
#@local cwd,read
gap> START_TEST("kernel/io.tst");
gap> cwd := GAP_getcwd();;
gap> ChangeDirectoryCurrent(Filename(DirectoryTemporary(), ""));
true
gap> read := function(content)
>     FileString("t.g", content);
>     Read("t.g");
> end;;

# a NUL byte hides the rest of its line
gap> read("Print(\"before\\n\"); \000 Print(\"lost\\n\");\nPrint(\"after\\n\");\n");
before
after

# CRLF and lone CR line ends; Windows counts a lone CR as a line end
gap> read("Print([1,\r\n2,\r\nINPUT_LINENUMBER()], \"\\n\");\r\n");
[ 1, 2, 3 ]
gap> read("Print([3,\r4], \"\\n\");\n");
[ 3, 4 ]

# a comment, a line and a file longer than the 32 KB line buffer
gap> read(Concatenation("# ", ListWithIdenticalEntries(40000, 'a'),
>                       "\n\n1 +;\n"));
Syntax error: expression expected in t.g:3
1 +;
   ^
gap> read(Concatenation("Print(Length([",
>      JoinStringsWithSeparator(ListWithIdenticalEntries(20000, "1"), ","),
>      "]));\nPrint(\" \", INPUT_LINENUMBER(), \"\\n\");\n"));
20000 2
gap> read(Concatenation("Print(Length([\n",
>      Concatenation(ListWithIdenticalEntries(10000, "1,\n")),
>      "1]), \" \", INPUT_LINENUMBER(), \"\\n\");\n"));
10001 10002

# tokens on both sides of the point where a long line is split
gap> read(Concatenation(ListWithIdenticalEntries(32757, ' '),
>                       "Print([1..2], \"\\n\");\n"));
[ 1 .. 2 ]
gap> read(Concatenation(ListWithIdenticalEntries(32758, ' '),
>                       "Print(1.5, \"\\n\");\n"));
1.5

# no newline at the end of the file
gap> read("Print(5, \"\\n\");");
5
gap> read("Print(6, \"\\n\");\n# comment");
6

# line continuations; one at the end of a comment does not continue it
gap> read("Print([12\\\n34, \"ab\\\ncd\"], \"\\n\");\n");
[ 1234, "abcd" ]
gap> read("# comment \\\nPrint(7, \"\\n\");\n");
7

# a 0xFF byte ends a comment
gap> read("# comment \377 Print(8, \"\\n\");\n");
8

#
gap> ChangeDirectoryCurrent(cwd);
true
gap> STOP_TEST("kernel/io.tst");
