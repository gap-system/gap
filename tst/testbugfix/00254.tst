# Check that overloading of a loaded help book by another one works. This 
# makes sense if a book of a not loaded package is loaded in a workspace 
# and GAP is started with a root path that contains a newer version. 
# Reported by Sebastian Gutsche, fixed by FL on 2012-09-11
gap> old := ShallowCopy(HELP_KNOWN_BOOKS[2][1]);;
gap> HELP_KNOWN_BOOKS[2][1][3] := 
> Concatenation(HELP_KNOWN_BOOKS[2][1][3], "blabla");;
gap> CallFuncList(HELP_ADD_BOOK, old);
#I  Overwriting already installed help book 'tutorial'.
