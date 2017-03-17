# This runs the examples from the reference manual chapter-wise and indicates
# differences in files EXAMPLEDIFFSnr where nr is the number of the chapter.

for i in [1..Length(exsref)] do
  Print("Checking ref, Chapter ",i,"\n");
  if Length(exsref[i])=0 then
    Print("Skipping ref, Chapter ",i," - no examples \n");
  else 
    resfile := Concatenation( "EXAMPLEDIFFS", 
                              ListWithIdenticalEntries(2-Length(String(i)),'0'), 
                              String(i) );
    RemoveFile(resfile);
    Exec( Concatenation( 
      "echo 'Read(\"exsref.g\"); RunExamples(exsref{[",
      String(i), 
      "]}, rec(compareFunction := \"uptowhitespace\") );' | ../../bin/gap.sh -b -S -r -A -q > ", resfile ) );
#    Exec( Concatenation( "echo 'Test(\"ref", String(i), ".tst",
#      "\", rec(compareFunction := \"uptowhitespace\") );' | ../../bin/gap.sh -b -S -r -A -q > ", resfile ) );

    str := StringFile(resfile);
    if Length(str)=0 then
      Print("test crashed\n");
      PrintTo( resfile, "test crashed\n");
    elif str{[Length(str)-22..Length(str)]} = "# Running list 1 . . .\n" then
      RemoveFile(resfile);
    else
      pos := PositionSublist(str, "# Running list 1 . . .\n");
      FileString(resfile, str{[pos+23..Length(str)]});
      Print("    found differences in ref, see file ", resfile, "\n");
    fi;
  fi;  
od;
