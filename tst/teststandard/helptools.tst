# This test checks various auxiliary functions used by the help system.
#
# For the test that systematically checks each manual section, see
# tst/testextra/helpsys.tst
#
gap> START_TEST("helptools.tst");
gap> ForAll(FindMultiSpelledHelpEntries(), i -> 
>    Length( Set( List( HELP_SEARCH_ALTERNATIVES( i[3] ), 
>                       j -> HELP_SEARCH_ALTERNATIVES(j) ) ) ) = 1 );
true
gap> Length(HELP_SEARCH_ALTERNATIVES("AnalyseMetacatalogOfCataloguesOfColourizationLabelingsOfCentreBySolvableNormalisersInNormalizerCentralizersInCentre"));
4096
gap> HELP_SEARCH_ALTERNATIVES("hasismapping");
[ "hasismapping", "ismapping", "setismapping" ]
gap> HELP_SEARCH_ALTERNATIVES("setismapping");
[ "hasismapping", "ismapping", "setismapping" ]
gap> HELP_SEARCH_ALTERNATIVES("ismapping");
[ "ismapping" ]

# Testing the code from `lib/helpt2t.g{d,i}` which converts TeX source code
# in `gapmacro.tex` format into text for the "screen" online help viewer.
#
# We add comment signs to the output since otherwise `Test` interprets GAP
# full and partial prompts as a GAP input.
#
# This is a helper function to display rendered text. It has an optional
# argument `key` to specify the search key and number of lines to print
# in this case (if we want a specific location in the documentation, we
# do not want to print all lines below).
#
gap> PrintRenderedText:=function( chapter, section, key... )
> local t2t, startline, lastline, i;
> atomic readwrite HELP_REGION do
>   if Length(key)=0 then
>     t2t:=HELP_PRINT_SECTION_TEXT(HELP_BOOK_INFO("mockpkg"),chapter,section);;
>     startline := 1;
>     lastline  := Length(t2t.lines);
>   else
>     t2t:=HELP_PRINT_SECTION_TEXT(HELP_BOOK_INFO("mockpkg"),chapter,section,key[1]);;
>     if t2t.start+key[2] > Length(t2t.lines) then
>       startline := Length(t2t.lines)-key[2]+1; 
>     else
>       startline := t2t.start;
>     fi;
>     lastline  := Minimum(t2t.start+key[2]-1,Length(t2t.lines));
>   fi;
>   for i in [startline..lastline] do 
>     Print("% ",t2t.lines[i],"\n");
>   od;
> od;
> end;;

# Load the help book for the mockpkg package
#
gap> HELP_ADD_BOOK("mockpkg","mockpkg",DirectoriesLibrary("tst/mockpkg/doc")[1]);

# First we test calling HELP_PRINT_SECTION_TEXT with three arguments
#
gap> PrintRenderedText(1,1 );
% Testing general text __________________________________ About this package
% 
% This  is a mock package to be used to test GAP library code related to GAP
% packages,  for  example  to  validate `PackageInfo.g` files. Clearly, it's
% not   available   anywhere,   and   it   has   it's  `ArchiveURL'  set  to
% `Concatenation(  ~.PackageWWWHome,  "/",  ~.PackageName, "-", ~.Version )'
% only for testing purposes.
% 
% 
% This   manual   is   used   to   construct   a  test  for  the  code  from
% `lib/helpt2t.g{d,i}'   which   converts   TeX  documentation   written  in
% `gapmacro.tex' format into text for the ``screen'' online help viewer.
% 
% --------------------------------------------------------------------------
% 
% Note  that `gapmacro.tex' format is obsolete. If you are planning to write
% new  documentation  for a GAP package, don't use it. Instead, we recommend
% to  use  the  GAPDoc  package  by  Frank  L"ubeck and Max Neunh"offer, see
% URL{http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/}.
% 
% If  you  have  any  questions,  please  contact  *GAP  Support*  by email:
% Mailto{support@gap-system.org}.
% 
% *Examples:*   The   following   text   demonstrates  various  features  of
% `gapmacro.tex' format.
% 
% This is an example of a GAP session:
% 
% -------------------------------- Example ---------------------------------
% gap> a:=42;
% 42
% --------------------------------------------------------------------------
% 
% This  assigns $42$ to the variable `a' (see Section "ref:Variables" in the
% GAP Reference Manual).
% 
% This is another example which is excluded from automated testing:
% 
% testexamplefalse
% 
% -------------------------------- Example ---------------------------------
% gap> Exec("date");
% Sun Oct 7 16:23:45 CEST 2001
% --------------------------------------------------------------------------
% 
% This is an example of using the matrix environment:
% 
%     b_N = {
%      1/2 (-1+sqrt{N}) if N equiv 1 (mod 4)
%      1/2 (-1+i sqrt{N}) if N equiv -1 (mod 4)
%     
% 
% This is an example of using the begintt environment:
% 
% A. X | B. Y | C. Z
% --------------------
% 1    | 2    | 3
% X    | Y    | Z
% --------------------
% 
% These common domains are defined by special macros:
% 
% natural  numbers                                                          
%     N
% 
% integers                                                                  
%     Z
% 
%                     Similarly, there are macros for Q, R, C, F, R.
% 
% This  is  a collection of symbols to exercise various special cases in the
% core to render them as a text:
% 
% (a) a ss a `a 'a ` a ' `a 'a \v\copyright
% 
% (b) \ua -a ^a .a "a a
% 
% (c) "a \ua \va
% 
% (d) more mathematical symbols:
% 
%     --  $ 1 / 2 $    $=$     $ . a  .  a ... a ' $
% 
%     --  $ < >  <>  1  mod  2  <=   >=  \ . o  |->  $
% 
%     --  $  |-->   ->   =>  tilde a  |-   <=>   x   in  y $
% 
%     --  $  for all   there exists  | : * [ ] '  U  $
% 
% Furthermore, $Sigma_{k}$ is given by
% 
%     Sigma_{k} = sum_{i in  N}(A_{i,k})
% 
% Finally,
% 
% > ...
% 
% produces no label and index entry, and 
% 
%  ...
% 
% is useful for producing a line in typewriter type.
% 
gap> PrintRenderedText(1,2);
% Testing various mansection formats ____________________ About this package
% 
% The following examples are taken from the gapmacro documentation.
% 
% > Size(<obj>)                                                            A
% 
% is an attribute of an object.
% 
% > Size(<obj>)!{for permutation groups}                                   A
% 
% is special form of the previous command for permutation groups.
% 
% > `<a> + <b>'{addition}
% 
% is used to display command as a header.
% 
% > `Size( <set> )'{size of a set}                                         A
% 
% is another example of the previous command.
% 
% > `Size( <list> )'{size!of a list}                                       A
% 
% is an example with a sub-entry.
% 
% > `Size( <obj> )'{size}                                                  A
% 
% is an example equivalent to the first one in this section.
% 
% > `Size( GL( <n>, <q> ) )'{Size!GL( n, q )}                              A
% 
% is a more complex example.
% 
% > `SomeGlobalVariable'                                                   V
% 
% is an example of a global variable.
% 

# Next, tests of calling HELP_PRINT_SECTION_TEXT with four arguments
gap> PrintRenderedText(1,2,"Size",4);
% 
% > Size(<obj>)                                                            A
% 
% is an attribute of an object.
gap> PrintRenderedText(1,2,"Size!for permutation groups",4);
% 
% > Size(<obj>)!{for permutation groups}                                   A
% 
% is special form of the previous command for permutation groups.
gap> STOP_TEST( "helptools.tst" );
