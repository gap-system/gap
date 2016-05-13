############################################################################
##  
#W  lbutil.g                 GAP Library                        Frank Lübeck
##  
##  
#Y  Copyright (C) 2004 The GAP Group
##  
##  This file contain a few simple tools for translating text files between
##  different line break conventions for Unix, DOS/Windows, MacOS.
##  


############################################################################
##  
#F  DosUnixLinebreaks( <infile>[, <outfile> ] ) . . . . . . translate
#F  text file with Unix line breaks to a file with DOS/Windows line breaks
##  
#F  UnixDosLinebreaks( <infile>[, <outfile> ] ) . . . . . . translate
#F  text file with DOS/Windows line breaks to a file with Unix line breaks
##  
#F  MacUnixLinebreaks( <infile>[, <outfile> ] ) . . . . . . translate
#F  text file with Unix line breaks to a file with MacOS line breaks
##  
#F  UnixMacLinebreaks( <infile>[, <outfile> ] ) . . . . . . translate
#F  text file with MacOS line breaks to a file with Unix line breaks
##  
##  <infile> must be the name of an existing text file and <outfile> the
##  name of a file to which the result is (over-)written. 
##  If not given <outfile> is the same as <infile>, so <infile> itself is
##  overwritten by the result.   
##  
##  DosUnix:
##  This function first substitutes all substrings "\r\n" in infile to
##  "\n" and then all "\n" to "\r\n". (So, existing "\r\n" are left alone
##  and "\n" without a previous "\r" are changed to "\r\n".) The result is
##  written to <outfile>.
##  
##  UnixDos:
##  This translates "\r\n" substrings to "\n".
##  
##  MacUnix:
##  This translates "\n" to "\r".
##  
##  UnixMac:
##  This translates "\r" to "\n".
##  

BindGlobal("DosUnixLinebreaks", function(arg)
  local infile, outfile, s;
  infile := arg[1];
  if Length(arg) > 1 then
    outfile := arg[2];
  else
    outfile := infile;
  fi;
  if not (IsString(infile) and IsString(outfile)) then
    Error("arguments must be strings describing the names of the input \n",
          "and output files.");
  fi;
  s := StringFile(infile);
  if s = fail then
    Error("cannot read input file.");
  fi;
  s := ReplacedString(s, "\r\n", "\n");
  s := ReplacedString(s, "\n", "\r\n");
  s := FileString(outfile, s);
  if s = fail then
    Error("cannot write output file.");
  fi;
end);

BindGlobal("UnixDosLinebreaks", function(arg)
  local infile, outfile, s;
  infile := arg[1];
  if Length(arg) > 1 then
    outfile := arg[2];
  else
    outfile := infile;
  fi;
  if not (IsString(infile) and IsString(outfile)) then
    Error("arguments must be strings describing the names of the input \n",
          "and output files.");
  fi;
  s := StringFile(infile);
  if s = fail then
    Error("cannot read input file.");
  fi;
  s := ReplacedString(s, "\r\n", "\n");
  s := FileString(outfile, s);
  if s = fail then
    Error("cannot write output file.");
  fi;
end);

BindGlobal("UnixMacLinebreaks", function(arg)
  local infile, outfile, s;
  infile := arg[1];
  if Length(arg) > 1 then
    outfile := arg[2];
  else
    outfile := infile;
  fi;
  if not (IsString(infile) and IsString(outfile)) then
    Error("arguments must be strings describing the names of the input \n",
          "and output files.");
  fi;
  s := StringFile(infile);
  if s = fail then
    Error("cannot read input file.");
  fi;
  s := ReplacedString(s, "\r", "\n");
  s := FileString(outfile, s);
  if s = fail then
    Error("cannot write output file.");
  fi;
end);

BindGlobal("MacUnixLinebreaks", function(arg)
  local infile, outfile, s;
  infile := arg[1];
  if Length(arg) > 1 then
    outfile := arg[2];
  else
    outfile := infile;
  fi;
  if not (IsString(infile) and IsString(outfile)) then
    Error("arguments must be strings describing the names of the input \n",
          "and output files.");
  fi;
  s := StringFile(infile);
  if s = fail then
    Error("cannot read input file.");
  fi;
  s := ReplacedString(s, "\n", "\r");
  s := FileString(outfile, s);
  if s = fail then
    Error("cannot write output file.");
  fi;
end);


