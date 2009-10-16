#############################################################################
####
##
#W  general.gi                 ACE Package                   Alexander Hulpke
#W                                                                Greg Gamble
##
##  This file installs mainly non-interactive ACE  variables  and  functions.
##  Though Alexander will barely recognise it,  some  of his ideas are  still
##  present.
##    
#H  @(#)$Id: general.gi,v 1.26 2006/01/26 16:11:31 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Information Technology & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.("ace/gap/general_gi") :=
    "@(#)$Id: general.gi,v 1.26 2006/01/26 16:11:31 gap Exp $";


#############################################################################
####
##
#V  ACETCENUM . . . . . . . .  The ACE version of the coset enumerator TCENUM
##  . . . .  CosetTableFromGensAndRels is set to ACECosetTableFromGensAndRels
##
InstallValue(ACETCENUM, rec(
  name := "ACE (Advanced Coset Enumerator)",
  CosetTableFromGensAndRels := ACECosetTableFromGensAndRels
));

#############################################################################
####
##
#F  InfoACELevel . . . . . . . . . . . . . . .  Get the InfoLevel for InfoACE
##
##
InstallGlobalFunction(InfoACELevel, function()
  return InfoLevel(InfoACE);
end);

#############################################################################
####
##
#F  SetInfoACELevel . . . . . . . . . . . . . . Set the InfoLevel for InfoACE
##
##
InstallGlobalFunction(SetInfoACELevel, function(arg)
  if IsEmpty(arg) then
    SetInfoLevel(InfoACE, 1);     # Set to default level
  else
    SetInfoLevel(InfoACE, arg[1]);
  fi;
end);

#############################################################################
####
##
#F  ACEPackageVersion() 
##
##  returns the version number of the current ACE package.
##
InstallGlobalFunction(ACEPackageVersion, function()

  return GAPInfo.PackagesInfo.ace[1].Version;
end);

#############################################################################
####
##
#F  CALL_ACE . . . . . . . . . Called by ACECosetTable, ACEStats and ACEStart
##
##
InstallGlobalFunction(CALL_ACE, function(ACEfname, fgens, rels, sgens)
local optnames, echo, errmsg, onbreakmsg, infile, datarec, ToACE, gens,
      standard, ignored;

  if ValueOption("aceexampleoptions") = true and
     IsBound(ACEData.aceexampleoptions) then
    SANITISE_ACE_OPTIONS(OptionsStack[ Length(OptionsStack) ],
                         ACEData.aceexampleoptions);
    PushOptions(ACEData.aceexampleoptions);
    Unbind(ACEData.aceexampleoptions);
    ACEData.options := OptionsStack[ Length(OptionsStack) ];
    PopOptions();
    OptionsStack[ Length(OptionsStack) ] := ACEData.options;
    Unbind(ACEData.options);
  fi;
  optnames := ACE_OPT_NAMES();
  # We have hijacked ACE's echo option ... we don't actually pass it to ACE
  echo := ACE_VALUE_ECHO(optnames);

  ECHO_ACE_ARGS( echo, ACEfname, rec(fgens := fgens, 
                                     rels  := rels, 
                                     sgens := sgens) );
  # Check arguments are valid
  while IsEmpty(fgens) do
    errmsg := 
        ["fgens (arg[1]) must be a non-empty list of group generators ..."];
    onbreakmsg := 
        ["Type: 'quit;' to quit to outer loop, or",
         "type: 'fgens := <val>; return;' to assign <val> to fgens to continue."
        ];
    Error(ACE_ERROR(errmsg, onbreakmsg), "\n");
  od;
  fgens := ACE_FGENS_ARG_CHK(fgens);
  rels  := ACE_WORDS_ARG_CHK(fgens, rels, "relators");
  sgens := ACE_WORDS_ARG_CHK(fgens, sgens, "subgp gen'rs");

  infile  := VALUE_ACE_OPTION(optnames, fail, "aceinfile");
  if ACEfname = "ACECosetTableFromGensAndRels" and infile <> fail then
    datarec := rec(
        infile  := infile,
        outfile := VALUE_ACE_OPTION(optnames, ACEData.outfile, "aceoutfile"),
        stream  := OutputTextFile(infile, false) );
    ToACE := function(list) WRITE_LIST_TO_ACE_STREAM(datarec.stream, list); end;
  else
    datarec := rec(
        stream := InputOutputLocalProcess(ACEData.tmpdir, ACEData.binary, []) );
    if datarec.stream = fail then
      Error("sorry! Run out of pseudo-ttys. Can't initiate stream\n");
    fi;
    if ACEfname <> ACEStart then
      datarec.procId := 0;
      ACEData.ni := datarec;
    fi;
    FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                           line -> IsMatchingSublist(line, "name", 3));
    ToACE := function(list) 
                 INTERACT_TO_ACE_WITH_ERRCHK(datarec, list);
             end;
  fi;
  datarec.args    := rec(fgens := fgens, rels := rels, sgens := sgens);
  datarec.options := ACE_OPTIONS();
  standard := ACE_COSET_TABLE_STANDARD( datarec.options );

  # Define the group generators ACE will use
  gens := TO_ACE_GENS(fgens);
  ToACE([ "Group Generators: ", gens.toace, ";"]);
  datarec.acegens := gens.acegens;

  # Define the group relators ACE will use
  datarec.enforceAsis := 
      (ACEfname <> "ACEStats") and (standard = "lenlex") and
      not IsACEGeneratorsInPreferredOrder(fgens, rels, "noargchk");
  ToACE([ "Group Relators: ", 
          ACE_RELS(rels, fgens, datarec.acegens, datarec.enforceAsis), ";" ]);

  # Define the subgroup generators ACE will use
  ToACE([ "Subgroup Generators: ", 
          ACE_WORDS(sgens, fgens, datarec.acegens), ";" ]);

  if ACEfname  = "ACECosetTableFromGensAndRels" then
    ignored := [ ];
  else 
    ignored := [ "aceinfile" ];
  fi;
  if ACEfname  = "ACEStart" then
    Add(ignored, "aceoutfile");
  fi;
  if datarec.enforceAsis then
    Add(ignored, "asis");
    ToACE([ "Asis: 1;" ]);
  fi;

  PROCESS_ACE_OPTIONS(
      ACEfname, optnames, optnames, echo, datarec, 
      rec(group      := ACE_ERRORS.argnotopt, # disallowed options
          generators := ACE_ERRORS.argnotopt,
          relators   := ACE_ERRORS.argnotopt), 
      ignored
      );
              
  if not IsInputOutputStream(datarec.stream) then
    if VALUE_ACE_OPTION(optnames, fail, ["start", "aep", "rep"]) = fail then
      # if the user hasn't issued there own enumeration initiation directive
      # ... initiate the enumeration
      ToACE([ "Start;" ]);
    fi;
    if ACEfname = "ACECosetTableFromGensAndRels" then
      if standard = "lenlex" then
        ToACE([ "Standard;" ]);
      fi;
      ToACE([ "Print Table;" ]);
    fi;
    CloseStream(datarec.stream);
  elif ACEfname <> "ACEStart" then
    if VALUE_ACE_OPTION(optnames, fail, ["start", "aep", "rep"]) = fail then
      ACE_MODE( "Start", datarec );
    fi;
    if ACEfname = "ACECosetTableFromGensAndRels" and standard = "lenlex" then
      ToACE([ "Standard;" ]);
    fi;
  fi;

  if ACEfname = "ACEStart" then
    datarec.procId := Length(ACEData.io) + 1;
    Add(ACEData.io, datarec);
    return Length(ACEData.io);
  elif ACEfname = "ACECosetTableFromGensAndRels" then
    datarec.silent := VALUE_ACE_OPTION(optnames, false, "silent");
  fi;
  return datarec;
end);

#############################################################################
####
##
#F  ACECosetTableFromGensAndRels . . . . . . .  Non-interactive ACECosetTable
##
##
InstallGlobalFunction(ACECosetTableFromGensAndRels, function(fgens, rels, sgens)
  # Use ACECosetTable non-interactively
  return ACECosetTable(fgens, rels, sgens);
end);

#############################################################################
####
##
#F  IsACEStandardCosetTable . . . . . . Returns true if table is standardised
##  . . . . . . . . . . . . . . . . . . according to GAP's default scheme  or
##  . . . . . . . . . . . . . . . . . . with the lenlex option, according  to
##  . . . . . . . . . . . . . . . . . . . . the lenlex standardisation scheme
##
InstallGlobalFunction(IsACEStandardCosetTable, function(table)
local standard, geninvIndices, index, next, j, i;

  standard := ACE_COSET_TABLE_STANDARD( ACE_OPTIONS() );
  if standard in ["lenlex", "GAPlenlex"] then
    geninvIndices := [1 .. Length(table)];
  elif standard in ["semilenlex", "GAPsemilenlex"] then
    geninvIndices := [1, 3 .. Length(table) - 1];
  else
    return IsStandardized(table); # Should only get here with GAP 4.3+
                                  # ... by which time `IsStandardized'
                                  # will hopefully have been generalised
                                  # to cope with any other standardisation
                                  # schemes
  fi;

  index := Length( table[1] );
  next := 2;
  for j in [1 .. index - 1] do
    for i in geninvIndices do
      if table[i][j] >= next then
        if table[i][j] > next then
          return false;
        fi;
        next := next + 1;
      fi;
    od;
  od;
  return true;
end);

#############################################################################
####
##
#F  IsACEGeneratorsInPreferredOrder . . . . . Returns true if the  generators
##  . . . . . . . . . . . . . . . . . . . . . gens are already in  the  order
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  preferred by ACE
##
##  For a presentation with more than one generator, the first  generator  of
##  which is an involution and the second is not, ACE prefers to  switch  the
##  first two generators. IsACEGeneratorsInPreferredOrder returns true if the
##  order of the generators gens would not  be  changed  by  ACE  and  false,
##  otherwise. When necessary, the argument rels (the  relators)  is  scanned
##  for relators that determine  whether  or  not  gens[1]  and  gens[2]  are
##  involutions.
##
##  If IsACEGeneratorsInPreferredOrder would return false, it is possible  to
##  enforce a user's order of the generators within ACE, by  enforcing  ACE's
##  `asis' option and passing the relator,  that  determines  gens[1]  is  an
##  involution,  explicitly  to  ACE   as:   gens[1]*gens[1]   (rather   than
##  gens[1]^2).
##
InstallGlobalFunction(IsACEGeneratorsInPreferredOrder, function(arg)
local ioIndex, gens, rels;

  if Length(arg) < 2 then
    ioIndex := CallFuncList(ACEProcessIndex, arg);
    gens := ACEGroupGenerators(ioIndex);
    rels := ACERelators(ioIndex);
  elif Length(arg) = 2 then
    gens := ACE_FGENS_ARG_CHK(arg[1]);
    rels := ACE_WORDS_ARG_CHK(gens, arg[2], "relators");
  elif Length(arg) = 3 and arg[3] = "noargchk" then
    # This scenario only intended for use internally
    gens := arg[1];
    rels := arg[2];
  else
    Error("expected at most 2 arguments, not ", Length(arg), " arguments.\n");
  fi;

  if Length(gens) = 1 or not ForAny(rels, rel -> rel = gens[1]^2) then
    return true;
  else
    return ForAny(rels, rel -> rel = gens[2]^2);
  fi;
end);

#############################################################################
####
##
#F  ACE_READ_AS_FUNC  . . . . . . . . . . . . . . . Variant of ReadAsFunction 
##  . . . . . . . . . . . .  that allows the passing of the function argument
##  . . . . . . . . . . . . . . . . . . . . ACEfunc to ReadAsFunction(file)()
##
##
InstallGlobalFunction(ACE_READ_AS_FUNC, function(file, ACEfunc)
local line, instream, rest;

  instream := InputTextFile(file);
  # We don't want the user to see this ... so we flush at InfoACE level 10.
  line := FLUSH_ACE_STREAM_UNTIL( instream, 10, 10, ReadLine,
                                  line -> IsMatchingSublist(line, "local") );
  rest := ReadAll(instream);
  CloseStream(instream);
  return ReadAsFunction(
             InputTextString(
                 Concatenation([ ReplacedString(line, ";", ", ACEfunc;"),
                                 "ACEfunc := ", NameFunction(ACEfunc), ";",
                                 rest ]) ) )();
end);

#############################################################################
####
##
#F  ACEExample( )
#F  ACEExample( <file>[, <ACEfunc>] )
##
##  With no arguments, or with single argument "index", or a string  that  is
##  not a filename  in  the  `examples'  directory,  an  index  of  available
##  examples is displayed.
##
##  With argument <file> that is a filename in the `examples' directory other
##  than "index" the example is displayed as it would  be  when  called  with
##  <ACEfunc> (or `ACEStats', if  the  2nd  argument  is  omitted)  and  then
##  executed via a call to `ReadAsFunction' and a little internal  ``magic''.
##  <ACEfunc>    must    be    one    of    `ACEStats'     (the     default),
##  `ACECosetTableFromGensAndRels'  (or  equivalently   `ACECosetTable',   or
##  `ACEStart'.
##
InstallGlobalFunction(ACEExample, function(arg)
local name, file, instream, line, ACEfunc,
      EnquoteIfString, optnames, lastoptname, optname;

  if IsEmpty(arg) then
    name := "index";
  else
    name := arg[1];
    if Length(arg) > 1 then
      ACEfunc := arg[2];
    else
      ACEfunc := ACEStats;
    fi;
    if not IsEmpty(OptionsStack) then
      ACEData.aceexampleoptions := OptionsStack[ Length(OptionsStack) ];
      PopOptions();
      PushOptions( rec(aceexampleoptions := true) );
    fi;
  fi;
  file := Filename( DirectoriesPackageLibrary( "ace", "examples"), name );
  if file = fail then
    Info(InfoACE + InfoWarning, 1,
         "Sorry! There is no ACE example file with name `", name, "'");
    name := "index";
    file := Filename( DirectoriesPackageLibrary("ace", "examples"), name );
  fi;
  # Display file ... after a few minor modifications
  instream := InputTextFile(file);
  if name <> "index" then
    line := FLUSH_ACE_STREAM_UNTIL( instream, 1, 10, ReadLine,
                                    line -> IsMatchingSublist(line, "local") );
    Info(InfoACE, 1,
         "#", line{[Position(line, ' ')..Position(line, ';') - 1]},
         " are local to ACEExample");
    line := FLUSH_ACE_STREAM_UNTIL( instream, 1, 10, ReadLine, 
                                    line -> IsMatchingSublist(line, "return") );
    Info(InfoACE, 1, 
         Chomp(ReplacedString(line, "return ACEfunc", NameFunction(ACEfunc)))
         );
    if IsBound(ACEData.aceexampleoptions) then
      line := FLUSH_ACE_STREAM_UNTIL(
                  instream, 1, 10, ReadLine, 
                  line -> PositionSublist(line, ");") <> fail );
      Info(InfoACE, 1, Chomp(ReplacedString(line, ");", ", ")));
      Info(InfoACE, 1, "    # User Options");
      optnames := ShallowCopy( RecNames(ACEData.aceexampleoptions) );
      lastoptname := optnames[ Length(optnames) ];
      Unbind(optnames[ Length(optnames) ]);

      EnquoteIfString := function(optval)
      # Puts quotes around optval if it's a string
        if IsString(optval) then
          return Concatenation(["\"", optval, "\""]);
        else
          return optval;
        fi;
      end;

      for optname in optnames do
        Info(InfoACE, 1, "      ", optname, " := ", 
                         EnquoteIfString(
                             ACEData.aceexampleoptions.(optname) ), ",");
      od;
      Info(InfoACE, 1, "      ", lastoptname, " := ", 
                       EnquoteIfString(
                           ACEData.aceexampleoptions.(lastoptname) ), ");");
    fi;
  fi;
  FLUSH_ACE_STREAM_UNTIL( instream, 1, 10, ReadLine, line -> line = fail );
  CloseStream(instream);
  if name <> "index" then
    return ACE_READ_AS_FUNC(file, ACEfunc);
  fi;
end);

#############################################################################
####
##
#F  ACEReadResearchExample  . . . . . . . .  Read  an  ACE  research  example 
##  . . . . . . . . . . . . . . . . . . . .  from the res-examples directory.
##
##  Currently,  all  examples  in  the  res-examples  directory   depend   on
##  pgrelfind.g, which with Info text doubles as an index. This  function  is
##  essentially equivalent to doing a Read of its argument or  "pgrelfind.g",
##  if there is no argument.
##
InstallGlobalFunction(ACEReadResearchExample, function(arg)
local name, file;

  if IsEmpty(arg) then
    name := "pgrelfind.g"; # If there is ever more than one key research
                           # example, we should replace this with an index
  else
    name := arg[1];
  fi;
  file := Filename( DirectoriesPackageLibrary( "ace", "res-examples"), name );
  if file = fail then
    Error("ACEReadResearchExample: Sorry! There is no ACE research example\n",
          "file with name \"", name, "\"\n");
  else
    Read(file);
  fi;
end);

#############################################################################
####
##
#F  ACEPrintResearchExample . . . . . . . . Print  an  ACE  research  example 
##  . . . . . . . . . . . . . . . . . . . . from the  res-examples  directory
##  . . . . . . . . . . . . . . . . . . . . to the terminal  or  to  a  file,
##  . . . . . . . . . . . . . . . . . . . . . . . minus header and Info text.
##
##  ACEPrintResearchExample(examplefile) 
##      prints examplefile in res-examples directory to the terminal
##
##  ACEPrintResearchExample(examplefile, outfile) 
##      prints examplefile in res-examples directory to outfile
##
InstallGlobalFunction(ACEPrintResearchExample, function(arg)
local outstream, print, file, instream, line;

  if IsEmpty(arg) then
    Error("expected 1 or 2 arguments\n");
  fi;

  file := Filename( DirectoriesPackageLibrary( "ace", "res-examples"), arg[1] );
  if file = fail then
    Error("ACEPrintResearchExample: Sorry! There is no ACE research example ",
          "file with name `", arg[1], "'\n");
  fi;

  if Length(arg) > 1 then
    outstream := OutputTextFile(arg[2], false);
    print := function(line) WriteAll(outstream, line); end;
  else
    print := Print;
  fi;

  instream := InputTextFile(file);
  repeat
    line := ReadLine(instream);
  until IsMatchingSublist(line, "## Begin");
  line := ReadLine(instream);
  while not IsMatchingSublist(line, "## End") do
    print(line);
    line := ReadLine(instream);
  od;
  CloseStream(instream);

  if print <> Print then
    CloseStream(outstream);
  fi;
end);

#############################################################################
####
##
#F  ACEDirectoryTemporary( <dir> )
##
##  calls the UNIX command `mkdir' to create <dir>, which must be  a  string,
##  and if successful a directory  object  for  <dir>  is  both  assigned  to
##  `ACEData.tmpdir'  and   returned.   The   fields   `ACEData.infile'   and
##  `ACEData.outfile' are also set to be files in  `ACEData.tmpdir',  and  on
##  exit from {\GAP} <dir> is removed.
##
InstallGlobalFunction(ACEDirectoryTemporary, function(dir)
local created;

  # check arguments
  if not IsString(dir) then
    Error("usage: ACEDirectoryTemporary( <dir> ) : <dir> must be a string.\n");
  fi; 

  # create temporary directory
  created := Process(DirectoryCurrent(),
                     Filename( DirectoriesSystemPrograms(), "sh" ),
                     InputTextUser(),
                     OutputTextUser(),
                     [ "-c", Concatenation("mkdir ", dir) ]);
  if created = fail then
    return fail;
  fi;

  Add( GAPInfo.DirectoriesTemporary, dir );
  ACEData.tmpdir := Directory(dir);
  ACEData.infile := Filename(ACEData.tmpdir, "in");
  ACEData.outfile := Filename(ACEData.tmpdir, "out");
  return ACEData.tmpdir;
end);

#############################################################################
####
##
#F  ACE_ERROR(<errmsg>, <onbreakmsg>)
##
##  sets `OnBreakMessage' to  print  <onbreakmsg>  in  order  to  generate  a
##  one-off user-friendly message of how the user may recover from the error,
##  and returns an error message formed from <errmsg> to be used by Error.
##
##  <errmsg> and <onbreakmsg> should be lists of strings;  <onbreakmsg>  must
##  be non-empty and its first member must not be a null string.
##
InstallGlobalFunction(ACE_ERROR, function(errmsg, onbreakmsg)
local NormalOnBreak, NormalOnBreakMessage;

  errmsg := JoinStringsWithSeparator(errmsg, "\n ");
  NormalOnBreakMessage := OnBreakMessage;
  onbreakmsg[1]{[1]} := LowercaseString( onbreakmsg[1]{[1]} );
  OnBreakMessage := function()
    local s;

    for s in onbreakmsg do
      Print(" ", s, "\n");
    od;
    OnBreakMessage := NormalOnBreakMessage;
  end;

  return errmsg;
end);

#############################################################################
####
##
#F  CallACE . . . . . . . . . . . . . . . . . . . . . . . . . . .  deprecated
##
InstallGlobalFunction(CallACE, function(arg)

  Error("CallACE is deprecated: Use `ACECosetTableFromGensAndRels' or\n",
        "`ACECosetTable'.\n");
end);

#E  general.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
