gap> START_TEST("format.tst");

# Some variables we will use for testing printing
gap> r1 := SymmetricGroup([3..5]);;
gap> r2 := AlternatingGroup([1,3,5]);;
gap> r3 := AlternatingGroup([11,12,13]);;

# Start with simple examples
gap> StringFormatted("a{}b{}c{}d", 1,(),"xyz");
"a1b()cxyzd"
gap> StringFormatted("{}{}{}", 1,(),"xyz");
"1()xyz"

# Check id types
gap> StringFormatted("{3}{2}{2}{3}{1}", 1,2,3,4);
"32231"
gap> StringFormatted("{a}{b}{a}", rec(a := (1,2), b := "ch"));
"(1,2)ch(1,2)"
gap> StringFormatted("{}", rec());
"rec(  )"
gap> StringFormatted("{1}", rec());
"rec(  )"

# Check double bracket matching
gap> StringFormatted("{{}}{}}}{{", 0);
"{}0}{"

# Error cases
gap> StringFormatted("{", 1);
Error, Invalid format string, no matching '}' at position 1
gap> StringFormatted("{abc", 1);
Error, Invalid format string, no matching '}' at position 1
gap> StringFormatted("}", 1);
Error, Mismatched '}' at position 1
gap> StringFormatted("{}{1}", 1,2,3,4);
Error, replacement field must either all have an id, or all have no id
gap> StringFormatted("{1}{}", 1,2,3,4);
Error, replacement field must either all have an id, or all have no id
gap> StringFormatted("{}{a}", rec(a := 1) );
Error, replacement field must either all have an id, or all have no id
gap> StringFormatted("{a}{}", rec(a := 1) );
Error, replacement field must either all have an id, or all have no id
gap> StringFormatted("{a}{b}{a}", 1,2);
Error, first data argument must be a record when using {a}
gap> StringFormatted("{a!x}", rec(a := r1));
Error, Invalid format: 'x'
gap> StringFormatted("{!x}", r1);
Error, Invalid format: 'x'
gap> StringFormatted([1,2]);
Error, Usage: StringFormatted(<string>, <data>...)

# Check format options
gap> StringFormatted("{1!s} {1!v} {1!d}", r1);
"SymmetricGroup( [ 3 .. 5 ] ) Sym( [ 3 .. 5 ] ) <object>\n"
gap> StringFormatted("{!s} {!v} {!d}", r1, r2, r3);
"SymmetricGroup( [ 3 .. 5 ] ) Alt( [ 1, 3 .. 5 ] ) <object>\n"
gap> StringFormatted("{a!s} {b!v} {c!d}", rec(a := r1, b := r2, c := r3));
"SymmetricGroup( [ 3 .. 5 ] ) Alt( [ 1, 3 .. 5 ] ) <object>\n"
gap> StringFormatted("{a!}", rec(a := r1));
"SymmetricGroup( [ 3 .. 5 ] )"
gap> StringFormatted("abc{}def",[1,2]) = "abc[ 1, 2 ]def";
true

# Test alternative functions
gap> PrintFormatted("abc\n\n");
Error, Usage: PrintFormatted(<string>, <data>...)
gap> PrintFormatted("abc{}\n", 2);
abc2
gap> str := "";
""
gap> PrintToFormatted(OutputTextString(str, false), "abc{}\n", [1,2]);
gap> Print(str);
abc[ 1, 2 ]
gap> PrintFormatted([1,2]);
Error, Usage: StringFormatted(<string>, <data>...)
gap> PrintToFormatted([1,2]);
Error, Function: number of arguments must be at least 2 (not 1)
gap> PrintToFormatted([1,2], "abc");
Error, Usage: PrintToFormatted(<stream>, <string>, <data>...)
gap> PrintToFormatted("*stdout*", [1,2]);
Error, Usage: PrintToFormatted(<stream>, <string>, <data>...)
gap> STOP_TEST("format.tst",1);
