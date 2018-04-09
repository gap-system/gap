#
# This file tests line continuations, i.e., GAP commands which span multiple
# lines with help of a backslash just before the new line, inside various
# kinds of GAP expressions
gap> START_TEST("linecontinuation.tst");

# in strings
gap> x:="foo\
> bar";
"foobar"

# in triple quoted string
gap> x:="""haha\
> !""";
"haha\\\n!"

# break keywords and operators like :=, <=, >= etc. in the middle
gap> 1 m\
> od 5;
1
gap> x :\
> =1;
1

# however, in comments, you cannot use line continuations:
gap> # 1234\
gap> 5;
5

#
gap> STOP_TEST("linecontinuation.tst", 1);

