gap> START_TEST("files.tst");

# Perform some general tests for reading from streams
# testName : A nice name to print out on failure
# openFunc : A zero-argument function which returns an InputStream
# lines : A list of the lines which should be in the file
# supportsPosition : Does the InputStream support
#               PositionStream/SeekPositionStream/RewindStream?
gap> testRead := function(testName, openFunc, lines, supportsPosition)
> local file, i, j, read, line, byte, concatlines;
> # Check we can read many times, to check we close properly
> for i in [1..100] do
>  file := openFunc();
>  for j in [1..Length(lines)] do
>    line := ReadAllLine(file);
>    if lines[j] <> line then
>      PrintFormatted("Expected {!v}, found {!v}, at line {} in {}\n",
>                     lines[j], line, j, testName);
>    fi;
>    # it is valid to get, or not get, end of stream at end of last line
>    if IsEndOfStream(file) and j < Length(lines) then
>      Print("Unexpected end of stream in ", testName);
>    fi;
>    if supportsPosition then
>      if PositionStream(file) <> Sum(lines{[1..j]},Length) then
>        PrintFormatted("At position {}, expected {}, on line {} of {}\n",
>          PositionStream(file), Sum(lines{[1..j]},Length), j, testName);
>      fi;
>    else
>      if PositionStream(file) <> fail then
>       Print("Unexpected PositionStream success ", testName, "\n");
>      fi;
>    fi;
>  od;
>  if ReadAllLine(file) <> fail then
>    Print("reading past end of file did not return 'fail' in ",testName, "\n");
>  fi;
>  if not IsEndOfStream(file) then
>    Print("failed to find end of stream in ", testName, "\n");
>  fi;
>  if supportsPosition then
>    if Length(lines) > 2 then
>       SeekPositionStream(file, Length(lines[1]));
>       if PositionStream(file) <> Length(lines[1]) then
>           Print("failed seek position ", testName, "\n");
>       fi;
>       if ReadAllLine(file) <> lines[2] then
>           Print("failed read after seek ", testName, "\n");
>       fi;
>   fi;
>   if not SeekPositionStream(file, 0) or PositionStream(file) <> 0 then
>       Print("failed seek to 0 ", testName, "\n");
>   fi;
>   if not SeekPositionStream(file, Sum(lines, Length)) or
>      PositionStream(file) <> Sum(lines, Length) then
>       Print("failed seek to end ", testName, "\n");
>   fi;
>   if ReadAllLine(file) <> fail then
>       Print("failed read past end of file ", testName, "\n");
>   fi;
>   if not RewindStream(file) or PositionStream(file) <> 0 then
>      Print("failed rewind stream ", testName, "\n");
>   fi;
>  else
>   if SeekPositionStream(file, 0) <> fail then
>      Print("Unexpected SeekPositionStream success ", testName, "\n");
>   fi;
>   if RewindStream(file) <> fail then
>      Print("Unexpected RewindStream success ", testName, "\n");
>   fi;
>  fi;
>  CloseStream(file);
>  file := openFunc();
>  concatlines := Concatenation(lines);
>  for i in [1..Length(concatlines)] do
>    byte := ReadByte(file);
>    if byte <> IntChar(concatlines[i]) then
>      PrintFormatted("Expected {}, found {}, at position {} in {}\n",
>        IntChar(concatlines[i]), byte, i, testName);
>    fi;
>    if i <> Length(concatlines) and IsEndOfStream(file) then
>       PrintFormatted("Unexpected end of stream in {}\n", testName);
>    fi;
>    if supportsPosition and PositionStream(file) <> i then
>       PrintFormatted("Expected to be at {}, instead at {}, in {}\n",
>         i, PositionStream(i), testName);
>    fi;
>  od;
>  if ReadByte(file) <> fail then
>    PrintFormatted("Unexpected extra byte in {}\n", testName);
>  fi;
>  if not IsEndOfStream(file) then
>    PrintFormatted("Expected end of stream in {}\n", testName);
>  fi;
>  CloseStream(file);
> od;
> end;;
gap> dir := DirectoriesLibrary("tst/testinstall/files");;
gap> lines := ["here is line 1\n", "\n", "here is line 2\n"];;
gap> testRead("example.txt", {} -> InputTextFile(Filename(dir, "example.txt")),
> lines, true);

# Test automatic gzip detection
gap> testRead("examplegz.txt", {} -> InputTextFile(Filename(dir, "examplegz.txt")),
> lines, true);
gap> testRead("empty.txt", {} -> InputTextFile(Filename(dir, "empty.txt")),
> [], true);
gap> testRead("lines string", {} -> InputTextString(Concatenation(lines)), lines, true);
gap> testRead("empty string", {} -> InputTextString(""), [], true);
gap> testRead("dummy input", {} -> InputTextNone(), [], true);
gap> STOP_TEST("files.tst", 1);
