# This runs the examples from the ref manual chapter-wise and indicates
# differences in files EXAMPLEDIFFSnr where nr is the number of the chapter.

SaveWorkspace("wsp");

for i in [1..Length(exsref)] do
  Print("Checking ref, Chapter ",i,"\n");
  resfile := Concatenation( "EXAMPLEDIFFS", 
                            ListWithIdenticalEntries(2-Length(String(i)),'0'), 
                            String(i) );
  RemoveFile(resfile);
  Exec(Concatenation("echo 'RunExamples(exsref{[", String(i), 
       "]}",
  # By default compare up to whitespace, so some editing wrt. line breaks
  # or other whitespace in example output is accepted.
  # Comment the "WS" for comparison with \=.
  # Uncomment the "WSRS" or "RS" to change the source code to the 
  # current output.
       ", WS",
##         ", RS",
##         ", WSRS",
       ");' | ../../bin/gap.sh -b -r -A -q -L wsp > ", resfile ));
  str := StringFile(resfile);
  if str{[Length(str)-22..Length(str)]} = "# Running list 1 . . .\n" then
    RemoveFile(resfile);
  else
    pos := PositionSublist(str, "# Running list 1 . . .\n");
    FileString(resfile, str{[pos+23..Length(str)]});
    Print("    found differences in ref, see file ", resfile, "\n");
  fi;
od;
RemoveFile("wsp");
QUIT;

