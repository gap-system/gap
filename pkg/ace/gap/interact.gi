#############################################################################
##
#W  interact.gi                ACE Package                        Greg Gamble
##
##  This file  installs  commands for using ACE interactively via IO Streams.
##    
#H  @(#)$Id: interact.gi,v 1.45 2006/01/26 16:11:31 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Information Technology & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.("ace/gap/interact_gi") :=
    "@(#)$Id: interact.gi,v 1.45 2006/01/26 16:11:31 gap Exp $";

#############################################################################
####
##
#F  ACE_IOINDEX . . . . . . . . . . . .  Get the index of the ACEData.io list
##  . . . . . . . . . . . . . . . . . . . . . for an interactive ACE session.
##
InstallGlobalFunction(ACE_IOINDEX, function(arglist)
local ioIndex;

  if IsEmpty(arglist) then
    # Find the first bound ioIndex
    ioIndex := 1;
    while not(IsBound(ACEData.io[ioIndex])) and ioIndex < Length(ACEData.io) do
      ioIndex := ioIndex + 1;
    od;
    if IsBound(ACEData.io[ioIndex]) then
      return ioIndex;
    else
      Info(InfoACE + InfoWarning, 1, 
           "No interactive ACE sessions are currently active");
      return fail;
    fi;
  elif IsBound(ACEData.io[ arglist[1] ]) then
    return arglist[1];
  else
    Error("no such interactive ACE session\n");
  fi;
end);

#############################################################################
####
##
#F  ACE_IOINDEX_ARG_CHK . . . . . . . . Checks for the right no. of arguments
##  . . . . . . . . . . . . . . . . . . warns user of any  ignored  arguments 
##
InstallGlobalFunction(ACE_IOINDEX_ARG_CHK, function(arglist)
  if Length(arglist) > 1 then
    Info(InfoACE + InfoWarning, 1,
         "Expected 0 or 1 arguments, all but first argument ignored");
  fi;
end);

#############################################################################
##
#F  ACEDataRecord([<i>]) . . . . . . . . returns the data record of a process
##
InstallGlobalFunction(ACEDataRecord, function( arg )
  if not IsEmpty(arg) and arg[1] = 0 and IsBound( ACEData.ni ) then
    return ACEData.ni;
  else
    return ACEData.io[ CallFuncList(ACEProcessIndex, arg) ];
  fi;
end);

#############################################################################
####
##
#F  ACEProcessIndex . . . . . . . . . . . . . . . User version of ACE_IOINDEX
##
##  If given (at least) one integer argument returns the first argument if it
##  corresponds  to  an  active  interactive  process  or  raises  an  error,
##  otherwise it returns the default active interactive process. If the  user
##  provides more than one argument then all arguments other than  the  first
##  argument are ignored (and a warning is issued).
##
InstallGlobalFunction(ACEProcessIndex, function(arg)
local ioIndex;
  ACE_IOINDEX_ARG_CHK(arg);
  ioIndex := ACE_IOINDEX(arg);
  if ioIndex = fail then
    Error( "no currently active interactive ACE sessions" );
  fi;
  return ioIndex;
end);

#############################################################################
####
##
#F  ACEProcessIndices . . . . . . . . . .  Returns the list of indices of all
##  . . . . . . . . . . . . . . . . . . .  active interactive  ACE  processes
##
##
InstallGlobalFunction(ACEProcessIndices, function()
  return Filtered( [1..Length(ACEData.io)], i -> IsBound( ACEData.io[i] ) );
end);

#############################################################################
####
##
#F  IsACEProcessAlive . . . . . . . . . . Returns true if the stream  of  the
##  . . . . . . . . . . . . . . . . . . . interactive ACE process  determined
##  . . . . . . . . . . . . . . . . . . . by arg can be written to  (i.e.  is
##  . . . . . . . . . . . . . . . . . . . .  still alive) and false otherwise
##
InstallGlobalFunction(IsACEProcessAlive, function(arg)
  return not IsEndOfStream( CallFuncList(ACEDataRecord, arg).stream );
end);

#############################################################################
####
##
#F  ACEResurrectProcess . . . . . . . . . Re-generates the stream of the i-th
##  . . . . . . . . . . . . . . . . . . . interactive ACE process, where i is
##  . . . . . . . . . . . . . . . . . . . determined by  arg,  and  tries  to
##  . . . . . . . . . . . . . . . . . . . recover as much as possible of  the
##  . . . . . . . . . . . . . . . . . . . previous state from saved values of
##  . . . . . . . . . . . . . . . . . . . . .  the args and parameter options
##
##  The  args  of  the  i-th  interactive   ACE   process   are   stored   in
##  ACEData.io[i].args (a record with fields fgens, rels and sgens, which are
##  the   GAP   group   generators,   relators   and   subgroup   generators,
##  respectively). Option information is saved in ACEData.io[i].options  when
##  a user uses an interactive ACE interface function with  options  or  uses
##  SetACEOptions. Option information is saved in ACEData.io[i].parameters if
##  ACEParameters is used to extract from ACE the current values of  the  ACE
##  parameter options (this is generally less reliable unless one of the  ACE
##  modes has been run previously).
##
##  By default, ACEResurrectProcess  recovers  parameter  option  information
##  from    ACEData.io[i].options    if    it    is    bound,     or     from
##  ACEData.io[i].parameters if is bound, otherwise. To alter this behaviour,
##  the user is provided two options:
##
##   use := list  . list  may  contain  one  or   both   of   "options"   and
##                  "parameters". By default: use = ["options", "parameters"]
##
##   useboth  . . . (boolean) By default: useboth = false
##
##  If useboth is true, ACEResurrectProcess applies SetACEOptions  with  each
##  ACEData.io[i].(field) for each field ("options" or "parameters") that  is
##  bound and in use's list, in the order implied  by  list.  If  useboth  is
##  false,      ACEResurrectProcess      applies      SetACEOptions      with
##  ACEData.io[i].(field) for only the first field that  is  bound  in  use's
##  list.
##
InstallGlobalFunction(ACEResurrectProcess, function(arg)
local ioIndex, datarec, gens, ToACE, uselist, useone, saved, optname, field;

  ioIndex := CallFuncList(ACEProcessIndex, arg);
  datarec := ACEData.io[ ioIndex ];
  if not IsEndOfStream( datarec.stream ) then
    Info(InfoACE + InfoWarning, 1, 
         "Huh? Stream of interactive ACE process ", ioIndex, " not dead?");
    return fail;
  fi;

  # Restart the stream
  datarec.stream := InputOutputLocalProcess(ACEData.tmpdir, ACEData.binary, []);

  if IsBound(datarec.args) and IsBound(datarec.args.fgens) then
    gens := TO_ACE_GENS(datarec.args.fgens);
    ToACE := function(list) WRITE_LIST_TO_ACE_STREAM(datarec.stream, list); end;
    ToACE([ "Group Generators: ", gens.toace, ";" ]);
    Info(InfoACE, 1, "Group generators:", datarec.args.fgens);
    if IsBound(datarec.args.rels) then
      ToACE([ "Group Relators: ", 
              ACE_WORDS(datarec.args.rels, datarec.args.fgens, gens.acegens), 
              ";" ]);
      Info(InfoACE, 1, "Relators:", datarec.args.rels);
    else
      Info(InfoACE + InfoWarning, 1, "No relators.");
    fi;
    if IsBound(datarec.args.sgens) then
      ToACE([ "Subgroup Generators: ", 
              ACE_WORDS(datarec.args.sgens, datarec.args.fgens, gens.acegens), 
              ";" ]);
      Info(InfoACE, 1, "Subgroup generators:", datarec.args.sgens);
    else
      Info(InfoACE + InfoWarning, 1, "No subgroup generators.");
    fi;
  else
    Info(InfoACE + InfoWarning, 1, "No group generators.");
  fi;
    
  uselist := Filtered(ACE_VALUE_OPTION("use", ["options", "parameters"]),
                      field -> IsBound(datarec.(field)) );
  useone := not ACE_VALUE_OPTION("useboth", false);
  if IsEmpty(uselist) then
    Info(InfoACE + InfoWarning, 1, "Sorry. No parameter options recovered.");
  else
    if useone then
      uselist := uselist{[1]};
    fi;
    if "options" in uselist then
      # Scrub any non{-parameter,-strategy,-echo} options
      for optname in Filtered(
                         RecNames(datarec.options),
                         function(optname)
                           local prefname;
                           prefname := ACEPreferredOptionName(optname);
                           return prefname <> "echo" and
                                  not (prefname in ACEStrategyOptions) and
                                  not (prefname in RecNames(
                                                       ACEParameterOptions
                                                       ));
                         end
                         )
      do
        Unbind( datarec.options.(optname) );
      od;
      saved := rec(options := datarec.options);
      if IsBound(datarec.parameters) then
        saved.parameters := datarec.parameters;
      fi;
    else
      saved := rec( parameters := ShallowCopy(datarec.parameters) );
      if IsBound(datarec.options) then
        for optname in Filtered( 
                           RecNames(datarec.options),
                           optname -> ACEPreferredOptionName(optname) = "echo" 
                           )
        do
          saved.parameters.(optname) := datarec.options.(optname);
        od;
      fi;
    fi;
    Unbind( datarec.options );
    for field in uselist do
      PushOptions( saved.(field) );
      INTERACT_SET_ACE_OPTIONS("ACEResurrectProcess", datarec);
      PopOptions();
    od;
    Info(InfoACE, 1, "Options set to: ", GetACEOptions(ioIndex));
  fi;
  if not IsBound(datarec.options) then
    datarec.options := rec();
  fi;
end);

#############################################################################
####
##
#F  READ_ACE_ERRORS . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . . . . . . . reads interactive ACE output from
##  . . . . . . . . . . . . . . . . . . . . stream  when  none  is  expected.
##
##  Writes any output read to Info at InfoACE + InfoWarning level 1.
##
##  This function may miss data output by ACE purely because it wasn't  ready
##  at the time of the call. If it turns out that READ_ACE_ERRORS is used  in
##  a place where it's important that all data be collected  from  ACE,  then
##  the  call  to  READ_ACE_ERRORS  should  be  replaced   by   a   call   to
##  ENSURE_NO_ACE_ERRORS.
##
InstallGlobalFunction(READ_ACE_ERRORS, function(datarec)
local line;

  line := ReadAllLine(datarec.stream);
  while line <> fail do
    if not IsMatchingSublist(line, "** ERROR") and
       Length(line) > 1 and line[ Length(line) - 1 ] = ')' then
      #a `start', `aep' or `rep' option was slipped in
      datarec.enumResult := Chomp(line);
      datarec.stats := ACE_STATS(datarec.enumResult);
    fi;
    Info(InfoACE + InfoWarning, 1, Chomp(line));
    line := ReadAllLine(datarec.stream);
  od;
end);

#############################################################################
####
##
#F  ENSURE_NO_ACE_ERRORS  . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . . . . . . . . . .  purges all interactive ACE
##  . . . . . . . . . . . . . . . . . . . . . . . . . . .  output from stream
##
##  Writes any output read to Info at InfoACE + InfoWarning level 1.
##
##  This function is like READ_ACE_ERRORS but makes ACE write "***" which  we
##  use as a sentinel to ensure we get all output due to  be  collected  from
##  ACE.
##
InstallGlobalFunction(ENSURE_NO_ACE_ERRORS, function(datarec)

  PROCESS_ACE_OPTION(datarec.stream, "text", "***"); # Causes ACE to print "***"
  FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE,
                         line -> IsMatchingSublist(line, "***"));
end);

#############################################################################
####
##
#F  INTERACT_TO_ACE_WITH_ERRCHK . . . . . . . . . . . . .  Internal procedure
##  . . . . . . . . . . . . . .  interactive ToACE procedure with error check
##
##  Writes list to the interactive ACE iostream stream and reads from  stream
##  to check for errors. Any output read is written  to  Info  at  InfoACE  +
##  InfoWarning level 1. Used where no output is expected.
##
InstallGlobalFunction(INTERACT_TO_ACE_WITH_ERRCHK, function(datarec, list)

  WRITE_LIST_TO_ACE_STREAM(datarec.stream, list);
  READ_ACE_ERRORS(datarec);
end);

#############################################################################
####
##
#F  ACE_ENUMERATION_RESULT  . . . .  Get and return an ACE enumeration result
##
##
InstallGlobalFunction(ACE_ENUMERATION_RESULT, function(stream, readline)
  # Call LAST_ACE_ENUM_RESULT with first (3rd argument) set to true,
  # so that it returns on the first enumeration result (or error) found
  return  LAST_ACE_ENUM_RESULT(stream, readline, true);
end);

#############################################################################
####
##
#F  LAST_ACE_ENUM_RESULT  . . . .  Get and return the last enumeration result
##
##  Enumeration result lines are recognised by being ones that end  in  ")\n"
##  but not starting with "** " or " " (as ACE error diagnostics do) ... this
##  is potentially flaky.
##
##  Reads and Infos lines from stream via function readline until a  sentinel
##  "***" and returns the last enumeration result (or  error)  found,  unless
##  first = true, in which case, it simply returns on the  first  enumeration
##  result (or error) found (without looking for a sentinel "***").
##
InstallGlobalFunction(LAST_ACE_ENUM_RESULT, function(stream, readline, first)
local errmsg, onbreakmsg, IsLastLine, IsEnumLine, line, enumResult;

  if first = true then
    IsLastLine := line -> true;
    IsEnumLine := line -> Length(line) > 1 and line[ Length(line) - 1 ] = ')';
  else
    IsLastLine := line -> IsMatchingSublist(line, "***");
    IsEnumLine := line -> line = fail or IsMatchingSublist(line, "***") or 
                          Length(line) > 1 and line[ Length(line) - 1 ] = ')';
  fi;
  repeat
    line := Chomp(FLUSH_ACE_STREAM_UNTIL(stream, 3, 10, readline, IsEnumLine));
    if line = fail then
      errmsg := ["expected to find output ...",
                 "possibly, you have reached the limit of what can be",
                 "written to ACEData.tmpdir (temporary directory)."];
      onbreakmsg :=
                ["You can only 'quit;' from here.",
                 "You will have to redo the calculation, but before that",
                 "try running 'ACEDirectoryTemporary(<dir>);' for some",
                 "directory <dir> where you know you will not be so limited."];
      Error(ACE_ERROR(errmsg, onbreakmsg), "\n");
    elif IsMatchingSublist(line, "** ERROR") then
      Info(InfoACE + InfoWarning, 1, line);
      line := Chomp( readline(stream) );
      Info(InfoACE + InfoWarning, 1, line);
      enumResult := Concatenation("ACE Enumeration failed: ", line);
    elif (first = true) or not IsLastLine(line) then
      Info(InfoACE, 2, line);
      enumResult := line;
    else
      Info(InfoACE, 3, line);
    fi;
  until IsLastLine(line);
  if IsMatchingSublist(enumResult, "ACE Enum") and first <> fail then
    Error(enumResult, "\n");
  fi;
  return enumResult;
end);

#############################################################################
####
##
#F  ACEWrite  . . . . . . . . . . . . . . . . . . . .  Primitive write to ACE
##
##  Writes the last argument to the i-th interactive ACE process, where i  is
##  the first argument if there are 2 arguments or  the  default  process  if
##  there is only 1 argument. The action is echoed via Info at InfoACE  level
##  4 (with a `ToACE> ' prompt). Returns true if successful in writing to the
##  stream and fail otherwise.
##
InstallGlobalFunction(ACEWrite, function(arg)

  if Length(arg) in [1, 2] then
    return WRITE_LIST_TO_ACE_STREAM( 
               CallFuncList(ACEDataRecord, arg{[1..Length(arg) - 1]}).stream,
               arg{[Length(arg)..Length(arg)]} );
  else
    Error("expected 1 or 2 arguments ... not ", Length(arg), " arguments\n");
  fi;
end);

#############################################################################
####
##
#F  ACERead . . . . . . . . . . . . . . . . . . . . . Primitive read from ACE
##
##  Reads a complete line of  ACE  output,  from  the  i-th  interactive  ACE
##  process, if there is output to be read and returns fail otherwise,  where
##  i is the first argument if there is 1 argument or the default process  if
##  there are no arguments.
##
InstallGlobalFunction(ACERead, function(arg)

  return ReadAllLine( CallFuncList(ACEDataRecord, arg).stream );
end);

#############################################################################
####
##
#F  ACEReadAll  . . . . . . . . . . . . . . . . . . . Primitive read from ACE
##
##  Reads and returns as many complete lines of ACE  output,  from  the  i-th
##  interactive ACE process, as there are to be read, as a  list  of  strings
##  with the trailing newlines removed and returns the empty list  otherwise,
##  where i is the first argument if there  is  1  argument  or  the  default
##  process if there are no arguments. Also writes via Info at InfoACE  level
##  3 each line read.
##
InstallGlobalFunction(ACEReadAll, function(arg)
local stream, lines, line;

  stream := CallFuncList(ACEDataRecord, arg).stream;
  lines := [];
  line := ReadAllLine(stream);
  while line <> fail do
    line := Chomp(line);
    Info(InfoACE, 3, line);
    Add(lines, line);
    line := ReadAllLine(stream);
  od;
  return lines;
end);

#############################################################################
####
##
#F  ACEReadUntil  . . . . . . . . . . . . . . . . . . Primitive read from ACE
##
##  Reads complete lines  of  ACE  output,  from  the  i-th  interactive  ACE
##  process, until a line for which IsMyLine(line) is true, where  i  is  the
##  first argument if the first argument is an integer or the default process
##  otherwise, and IsMyLine is the first function argument.  The  lines  read
##  are returned as a list of strings with the trailing newlines removed.  If
##  IsMyLine(line) is never true ACEReadUntil will  wait  indefinitely.  Also
##  writes via Info at InfoACE level 3 each line read. If there is  a  second
##  function argument it is used to modify each returned line; in this  case,
##  each line is emitted to  Info  before  modification,  but  each  line  is
##  modified before the IsMyLine test.
##
InstallGlobalFunction(ACEReadUntil, function(arg)
local idx1stfn, stream, IsMyLine, Modify, lines, line;

  idx1stfn := First([1..Length(arg)], i -> IsFunction(arg[i]));
  if idx1stfn = fail then
    Error("expected at least one function argument\n");
  elif Length(arg) > idx1stfn + 1 then
    Error("expected 1 or 2 function arguments, not ", 
          Length(arg) - idx1stfn + 1, "\n");
  elif idx1stfn > 2  then
    Error("expected 0 or 1 integer arguments, not ", idx1stfn - 1, "\n");
  else
    stream := CallFuncList(ACEDataRecord, arg{[1..idx1stfn - 1]}).stream;
    IsMyLine := arg[idx1stfn];
    if idx1stfn = Length(arg) then
      Modify := line -> line; # The identity function
    else
      Modify := arg[Length(arg)];
    fi;
    lines := [];
    repeat
      line := Chomp( ACE_READ_NEXT_LINE(stream) );
      Info(InfoACE, 3, line);
      line := Modify(line);
      Add(lines, line);
    until IsMyLine(line);
    return lines;
  fi;
end);

#############################################################################
####
##
#F  ACE_STATS . . . . . . . . . . . . . . . . Called by ACEStart and ACEStats
##  
##
InstallGlobalFunction(ACE_STATS, function(line)
local stats;

  # Parse line for statistics and return
  stats := Filtered(line, char -> char in ". " or char in CHARS_DIGITS);
  if not IsMatchingSublist(line, "INDEX") then
    # Enumeration failed so the index is missing 
    # ... shove a 0 index on the front of stats
    stats := Concatenation("0 ", stats);
  fi;
  stats := SplitString(stats, "", " .");

  return rec(index     := Int(stats[1]),
             cputime   := Int(stats[7])*10^Length(stats[8])+Int(stats[8]),
             cputimeUnits := Concatenation("10^-", String(Length(stats[8])),
                                           " seconds"),
             activecosets := Int(stats[2]),
             maxcosets := Int(stats[9]),
             totcosets := Int(stats[10]));
end);

#############################################################################
####
##
#F  ACE_COSET_TABLE
##
##
InstallGlobalFunction(ACE_COSET_TABLE, 
                      function(activecosets, acegens, iostream, readline)
local n, line, genColIndex, invColIndex, table, i, rowi, j, colj, invcolj;

  n := Length(acegens);

  # Skip some header until the ` coset ' line
  line := FLUSH_ACE_STREAM_UNTIL(iostream, 3, 3, readline, 
                                 line -> Length(line)>5 and
                                         line{[1..6]} in [" coset", "** ERR"]);
  if IsMatchingSublist(line, "** ERROR") then
    line := Chomp(readline(iostream));
    Info(InfoACE, 1, line);
    Error(line{[3..Length(line)]}, ". Try running ACEStart first.\n");
  fi;
  # Extract the coset table column headers
  rowi := SplitString(line, "", " |\n");

  # Look at the coset table column headers and determine the column
  # corresponding to each generator:
  #   colIndex[j] = Index of column(acegens[j])
  genColIndex := List(acegens, gen -> Position(rowi, gen));
  invColIndex := List(genColIndex, 
                      i -> ACE_IF_EXPR(
                               i + 1 in genColIndex or i + 1 > Length(rowi),
                               i,
                               i + 1,
                               0 # doesn't occur
                               ));
  # Discard the `---' line
  line := Chomp( readline(iostream) );
  Info(InfoACE, 3, line);

  # Now read the body of the coset table into table as a GAP List
  table := List([1 .. 2*n], j -> []);
  i := 0;
  repeat
    line := Chomp( readline(iostream) );
    Info(InfoACE, 3, line);
    i := i + 1;
    rowi := SplitString(line, "", " :|");
    for j in [1..n] do
      Add(table[2*j - 1], Int(rowi[ genColIndex[j] ]));
      Add(table[2*j],     Int(rowi[ invColIndex[j] ]));
    od;
  until i = activecosets;

  return table;
end);

#############################################################################
####
##
#F  ACE_MODE  . . . . . . . . . . . .  Start, continue or redo an enumeration
##  . . . . . . . . . . . .  also sets enumResult and stats fields of datarec
##
InstallGlobalFunction(ACE_MODE, function(mode, datarec)
  ENSURE_NO_ACE_ERRORS(datarec); # purge any output not yet collected
                                 # e.g. error messages due to unknown 
                                 # or inappropriate options
  WRITE_LIST_TO_ACE_STREAM(datarec.stream, [ mode, ";" ]);
  datarec.enumResult := ACE_ENUMERATION_RESULT(datarec.stream, 
                                               ACE_READ_NEXT_LINE);
  datarec.stats := ACE_STATS(datarec.enumResult);
end);
  
#############################################################################
####
##
#F  ACE_MODE_AFTER_SET_OPTS . . . . . . . Gets ACE stream index, sets options 
##  . . . . . . . . . . . . . . . . . . . and then calls ACE_MODE  to  start,
##  . . . . . . . . . . . . . . . . . . . . . continue or redo an enumeration
##
InstallGlobalFunction(ACE_MODE_AFTER_SET_OPTS, function(mode, arglist)
local ioIndex;
  ioIndex := CallFuncList(ACEProcessIndex, arglist);
  INTERACT_SET_ACE_OPTIONS(Flat( ["ACE", mode] ), ACEData.io[ioIndex]);
  if IsEmpty( ACEGroupGenerators(ioIndex) ) then
    Info(InfoACE + InfoWarning, 1, "ACE", mode, " : No group generators?!");
  else
    ACE_MODE(mode, ACEData.io[ioIndex]);
  fi;
  return ioIndex;
end);
  
#############################################################################
####
##
#F  CHEAPEST_ACE_MODE . . . . . . . . . . . . .  Does ACE_MODE(mode, datarec)
##  . . . . . . . . . . . . . . . . . . . . . for the cheapest mode available
##
InstallGlobalFunction(CHEAPEST_ACE_MODE, function(datarec)
local modes, mode;
  modes := ACE_MODES( datarec );
  mode := First( RecNames(modes), ACEmode -> modes.(ACEmode) );
  if mode = fail then
    Error("none of ACEContinue, ACERedo or ACEStart is possible. Huh???\n");
  else
    ACE_MODE(mode{[4..Length(mode)]}, datarec);
  fi;
end);
  
#############################################################################
####
##
#F  ACE_LENLEX_CHK  . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . for the interactive ACE process indexed by ioIndex,
##  . . . . . . . . . . . determine the coset  table  standardisation  scheme
##  . . . . . . . . . . . desired by the user: if "lenlex" ensure  `asis'  is
##  . . . . . . . . . . . enforced and re-emit the  relators  using  ACE_RELS
##  . . . . . . . . . . . with 4th arg `true' to avoid ACE swapping the first
##  . . . . . . . . . . . two generators, if  necessary;  when  found  to  be
##  . . . . . . . . . . . necessary `start' is invoked and if  dostandard  is
##  . . . . . . . . . . . true, `standard' is invoked. Finally the determined
##  . . . . . . . . . . . . . coset table standardisation scheme is returned.
##
InstallGlobalFunction(ACE_LENLEX_CHK, function(ioIndex, dostandard)
local datarec, standard;
  datarec := ACEData.io[ ioIndex ];  
  standard := ACE_COSET_TABLE_STANDARD( datarec.options );
  if (standard = "lenlex") and IsBound(datarec.enumResult) then
    if (not IsBound(datarec.enforceAsis) or not datarec.enforceAsis) and 
       not IsACEGeneratorsInPreferredOrder(ioIndex) then
      datarec.enforceAsis := true;
      PROCESS_ACE_OPTION(datarec.stream, "relators", 
                         ACE_RELS(ACERelators(ioIndex),
                                  ACEGroupGenerators(ioIndex),
                                  datarec.acegens,
                                  true));
      PROCESS_ACE_OPTION(datarec.stream, "asis", 1);
      ACE_MODE("Start", datarec);
    fi;
    if dostandard then
      PROCESS_ACE_OPTION(datarec.stream, "standard", "");
    fi;
  fi;
  return standard;
end);

#############################################################################
####
##
#F  SET_ACE_ARGS . . . . . . . . . . . . . . . . . . . . .  Set ACEStart args
##
##
InstallGlobalFunction(SET_ACE_ARGS, function(ioIndex, fgens, rels, sgens)
local datarec, gens;
  ioIndex := ACEProcessIndex(ioIndex); # Ensure ioIndex is valid
  fgens := ACE_FGENS_ARG_CHK(fgens);
  rels  := ACE_WORDS_ARG_CHK(fgens, rels, "relators");
  sgens := ACE_WORDS_ARG_CHK(fgens, sgens, "subgp gen'rs");
  
  gens := TO_ACE_GENS(fgens);
  datarec := ACEData.io[ ioIndex ];
  datarec.enforceAsis 
      := ( DATAREC_VALUE_ACE_OPTION(datarec, false, "lenlex") or
           VALUE_ACE_OPTION( ACE_OPT_NAMES(), false, "lenlex") ) and
         not IsACEGeneratorsInPreferredOrder(fgens, rels, "noargchk");
  datarec.echoargs := true; # If echo option is set INTERACT_SET_ACE_OPTIONS
                            # will echo args
  PROCESS_ACE_OPTION(datarec.stream, "group", gens.toace);
  PROCESS_ACE_OPTION(datarec.stream, "relators", 
                     ACE_RELS(rels, fgens, gens.acegens, datarec.enforceAsis));
  PROCESS_ACE_OPTION(datarec.stream, "generators", 
                     ACE_WORDS(sgens, fgens, gens.acegens));
  if datarec.enforceAsis then
    PROCESS_ACE_OPTION(datarec.stream, "asis", 1);
  fi;
  datarec.args := rec(fgens := fgens, rels := rels, sgens := sgens);
  datarec.acegens := gens.acegens;
  return ioIndex;
end);
  
#############################################################################
####
##
#F  NO_START_DO_ACE_OPTIONS . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . If set is true, set options for the  ACEStart
##  . . . . . . . . . . . . . . process indexed by ioIndex. If one of the new
##  . . . . . . . . . . . . . . options evokes an enumeration the  enumResult
##  . . . . . . . . . . . . . . and stats fields are re-set. All  ACE  output
##  . . . . . . . . . . . . . . is flushed. Called when no `start'  directive
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  is needed.
##
##
InstallGlobalFunction(NO_START_DO_ACE_OPTIONS, function(ioIndex, set)
local datarec, setEnumResult;
  datarec := ACEDataRecord(ioIndex);
  if not IsEmpty(OptionsStack) then
    setEnumResult := VALUE_ACE_OPTION( ACE_OPT_NAMES(), 
                                       fail, 
                                       ["start", "aep", "rep"] ) <> fail;
    if set then
      INTERACT_SET_ACE_OPTIONS("ACEStart", datarec);
    fi;
    PROCESS_ACE_OPTION(datarec.stream, "text", "***");
    if setEnumResult then
      datarec.enumResult 
          := LAST_ACE_ENUM_RESULT(datarec.stream, ACE_READ_NEXT_LINE, fail);
      if IsEmpty( ACEGroupGenerators(ioIndex) ) then
        Info(InfoACE + InfoWarning, 1, "ACEStart : No group generators?!");
        Unbind(datarec.enumResult);
        Unbind(datarec.stats);
      else
        datarec.stats := ACE_STATS(datarec.enumResult);
      fi;
    else
      FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE,
                             line -> IsMatchingSublist(line, "***"));
    fi;
  fi;
end);
  
#############################################################################
####
##
#F  ACEStart . . . . . . . . . . . . . .  Initiate an interactive ACE session
##
##
InstallGlobalFunction(ACEStart, function(arg)
local start, ioIndex, stream, datarec, gens;

  if Length(arg) > 5 then
    Error("expected at most 5 arguments ... not ", Length(arg), 
          " arguments.\n");
  elif Length(arg) = 2 and arg[1] <> 0 then
    Error("when called with 2 arguments, first argument should be 0.\n");
  elif not IsEmpty(arg) and arg[1] = 0 then
    start := false;
    arg := arg{[2..Length(arg)]};
  else
    start := true;
  fi;

  if Length(arg) in [3, 4] then
    if Length(arg) = 3 then #args are: fgens,  rels,  sgens
      ioIndex := CALL_ACE( "ACEStart", arg[1], arg[2], arg[3] );
    else             #arg{[2..4]} are: fgens,  rels,  sgens
      ioIndex := SET_ACE_ARGS( arg[1], arg[2], arg[3], arg[4] );
      NO_START_DO_ACE_OPTIONS(ioIndex, true);
    fi;
    if start then
      if IsEmpty( ACEGroupGenerators(ioIndex) ) then
        Info(InfoACE + InfoWarning, 1, "ACEStart : No group generators?!");
      else
        ACE_MODE( "Start", ACEData.io[ ioIndex ] );
      fi;
    elif Length(arg) = 3 then
      NO_START_DO_ACE_OPTIONS(ioIndex, false);
    fi;
  elif Length(arg) <= 1 and start then
    ioIndex := ACE_MODE_AFTER_SET_OPTS("Start", arg);
  else # start = false
    if Length(arg) = 1 then
      ioIndex := CallFuncList(ACEProcessIndex, arg);
    else
      stream := InputOutputLocalProcess(ACEData.tmpdir, ACEData.binary, []);
      if stream = fail then
        Error("sorry! Run out of pseudo-ttys. Can't initiate stream.\n");
      else
        Add( ACEData.io, rec(stream := stream, options := rec()) );
        ioIndex := Length(ACEData.io);
        ACEData.io[ioIndex].procId := ioIndex;
      fi;
    fi;
    NO_START_DO_ACE_OPTIONS(ioIndex, true);
  fi;
  ACE_LENLEX_CHK(ioIndex, false);
  return ioIndex;
end);

#############################################################################
##
#F  ACEQuit . . . . . . . . . . . . . . . .  Close an interactive ACE session
##
InstallGlobalFunction(ACEQuit, function(arg)
local ioIndex;

  ioIndex := CallFuncList(ACEProcessIndex, arg);
  CloseStream(ACEData.io[ioIndex].stream);
  Unbind(ACEData.io[ioIndex]);
end);

#############################################################################
##
#F  ACEQuitAll . . . . . . . . . . . . . . Close all interactive ACE sessions
##
InstallGlobalFunction(ACEQuitAll, function()
local ioIndex;

  for ioIndex in [1 .. Length(ACEData.io)] do
    if IsBound(ACEData.io[ioIndex]) then
      CloseStream(ACEData.io[ioIndex].stream);
      Unbind(ACEData.io[ioIndex]);
    fi;
  od;
end);

#############################################################################
##
#F  ACE_MODES . . . . . . . . . .  Returns a record of which of the ACE modes
##  . . . . . . . . . . . . . . . . . . Continue, Redo and Start are possible
##
InstallGlobalFunction(ACE_MODES, function(datarec)
local modes;

  READ_ACE_ERRORS(datarec);
  WRITE_LIST_TO_ACE_STREAM(datarec.stream, [ "mode;" ]);
  modes := SplitString(FLUSH_ACE_STREAM_UNTIL(
                           datarec.stream, 3, 2, ACE_READ_NEXT_LINE,
                           line -> IsMatchingSublist(line, "start = ")
                           ),
                       "",
                       " =,\n");
  return rec(ACEContinue := modes[4] = "yes", # Modes in order of `cheapness'
             ACERedo     := modes[6] = "yes",
             ACEStart    := modes[2] = "yes");
end);

#############################################################################
##
#F  ACEModes  . . . . . . . . . . . .  Returns a record of which of the modes
##  . . . . . . . . . . . . .  ACEContinue, ACERedo and ACEStart are possible
##
InstallGlobalFunction(ACEModes, function(arg)
  return ACE_MODES( CallFuncList(ACEDataRecord, arg) );
end);

#############################################################################
####
##
#F  ACEContinue  . . . . . . . . . . . .  Continue an interactive ACE session
##
##
InstallGlobalFunction(ACEContinue, function(arg)
  return ACE_MODE_AFTER_SET_OPTS("Continue", arg);
end);

#############################################################################
####
##
#F  ACERedo . . . . . . . . . . . . . . . . . Redo an interactive ACE session
##
##
InstallGlobalFunction(ACERedo, function(arg)
  return ACE_MODE_AFTER_SET_OPTS("Redo", arg);
end);

#############################################################################
####
##
#F  ACE_EQUIV_PRESENTATIONS . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . . . . . called  by   ACEAllEquivPresentations
##  . . . . . . . . . . . . . . . . . . and ACERandomEquivPresentations where
##  . . . . . . . . . . . . . . . . . . . . string matches the last line read
##
InstallGlobalFunction(ACE_EQUIV_PRESENTATIONS, function(ioIndex, string)
local datarec, out, run;
  datarec := ACEData.io[ ioIndex ];
  out := rec(line := FLUSH_ACE_STREAM_UNTIL(
                         datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                         line -> Length(line) > 5 and
                                 line{[1..6]} in [ "Group ", "** ERR" ] 
                         ),
             runs := []);
  if IsMatchingSublist(out.line, "** ERROR") then
    # Can only happen for ACERandomEquivPresentations
    out.line := ACEReadUntil(ioIndex, 
                             line -> IsMatchingSublist(line, string))[1];
    Error("ACERandomEquivPresentations:", out.line{[3..Length(out.line)]});
  fi;
  while not IsMatchingSublist(out.line, string) do
    run := rec(rels := ACE_GAP_WORDS(datarec,
                                     ACE_PARAMETER_WITH_LINE(ioIndex, 
                                                             "Group Relators",
                                                             out.line)),
               enumResult := ACE_ENUMERATION_RESULT(datarec.stream,
                                                    ACE_READ_NEXT_LINE));
    run.stats := ACE_STATS(run.enumResult);
    Add(out.runs, run);
    out.line := ACE_READ_NEXT_LINE(datarec.stream);
    Info(InfoACE, 3, Chomp(out.line));
  od;
  return out;
end);
#############################################################################
####
##
#F  ACEAllEquivPresentations . . . . . . . Tests all equivalent presentations
##
##  For the i-th interactive ACE process, generates and tests an  enumeration
##  for combinations of relator  ordering,  relator  rotations,  and  relator
##  inversions, according to the value of optval,  where  i  and  optval  are
##  determined by arg. The argument optval is considered as a binary  number;
##  its three bits are treated as flags, and control relator  rotations  (the
##  2^0 bit), relator inversions (the 2^1 bit) and relator orderings (the 2^2
##  bit), respectively; 1 means `active' and 0 means `inactive'.
##
##  Outputs a record with fields:
##
##    primingResult 
##        the ACE enumeration result message of the priming run;
##
##    primingStats
##        the enumeration result of the priming run as  a  GAP  ACEStats-like
##        record;
##
##    equivRuns
##        a list of data records, one for each run,  where  each  record  has
##        fields:
##
##      rels
##        the relators in the order used for the run,
##
##      enumResult
##        the ACE enumeration result message of the run, and
##
##      stats
##        the enumeration result as a GAP ACEStats-like record;
##
##    summary
##        a record with fields:
##
##      successes
##        the total number of  successful  (i.e.  having  finite  enumeration
##        index) runs,
##
##      runs
##        the total number of equivalent presentation runs executed,
##
##      maxcosetsRange
##        the  range  of  values  as   a   GAP   list   inside   which   each
##        `equivRuns[i].maxcosets' lies, and
##
##      totcosetsRange
##        the  range  of  values  as  a  {\GAP}  list   inside   which   each
##        `equivRuns[i].totcosets' lies.
##
InstallGlobalFunction(ACEAllEquivPresentations, function(arg)
local ioIndexAndOptval, ioIndex, datarec, aep, epRec, line;
  ioIndexAndOptval := ACE_IOINDEX_AND_ONE_VALUE(arg);
  ioIndex := ioIndexAndOptval[1];
  datarec := ACEData.io[ ioIndex ];

  line := EXEC_ACE_DIRECTIVE_OPTION(ioIndexAndOptval, "aep", 3, 
                                    line -> IsMatchingSublist(line, "* P"), 
                                    "", false);
  if not IsMatchingSublist(line, "* P") then
    Error("ACEAllEquivPresentations:", line{[3..Length(line)]});
  fi;

  aep := rec(primingResult := ACE_ENUMERATION_RESULT(datarec.stream,
                                                     ACE_READ_NEXT_LINE));
  aep.primingStats := ACE_STATS(aep.primingResult);

  epRec := ACE_EQUIV_PRESENTATIONS(ioIndex, "* There were");
  aep.equivRuns := epRec.runs;

  line := SplitString(epRec.line, "", "* Therwsucinu:\n");
  aep.summary := rec(successes := Int(line[1]), runs := Int(line[2]));
  line := Chomp( ACE_READ_NEXT_LINE(datarec.stream) );
  Info(InfoACE, 3, line);
  line := SplitString(line, "", "* maxcost=,");
  aep.summary.maxcosetsRange
       := EvalString( Concatenation( "[", line[1], "]" ) );
  aep.summary.totcosetsRange
       := EvalString( Concatenation( "[", line[2], "]" ) );
  return aep;
end);

#############################################################################
####
##
#F  ACERandomEquivPresentations . . . . . Tests a number of random equivalent 
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . presentations
##
##  For the i-th interactive  ACE  process,  generates  and  tests  n  random
##  enumeration for combinations of relator ordering, relator rotations,  and
##  relator inversions,  according  to  the  value  of  optval,  where  n  is
##  determined by optval, and  i  and  optval  are  determined  by  arg.  The
##  argument optval is considered as a binary  number;  its  three  bits  are
##  treated as flags, and control relator rotations (the  2^0  bit),  relator
##  inversions  (the  2^1  bit)  and  relator  orderings   (the   2^2   bit),
##  respectively; 1 means `active' and 0 means `inactive'.
##
##  Outputs a list of records, each record of which has fields:
##
##    rels
##        the relators in the order used for a presentation run,
##
##    enumResult
##        the ACE enumeration result message of the run, and
##
##    stats
##        the enumeration result of the run as a GAP ACEStats-like record.
##
InstallGlobalFunction(ACERandomEquivPresentations, function(arg)
local ioIndexAndOptval, ioIndex, datarec, stream;
  ioIndexAndOptval := ACE_IOINDEX_AND_ONE_VALUE(arg);
  ioIndex := ioIndexAndOptval[1];
  datarec := ACEData.io[ ioIndex ];
  stream := datarec.stream;

  READ_ACE_ERRORS(datarec); # purge any output not yet collected
  PROCESS_ACE_OPTION(stream, "rep", ioIndexAndOptval[2]);
  PROCESS_ACE_OPTION(stream, "text", "------------------------------------");

  return ACE_EQUIV_PRESENTATIONS(ioIndex, "------------").runs;
end);

#############################################################################
####
##
#F  ACEGroupGenerators  . . . . . . . . . . . Return the GAP group generators
##  . . . . . . . . . . . . . . . . . . . . . . of an interactive ACE session
##
##
InstallGlobalFunction(ACEGroupGenerators, function(arg)
local datarec, ioIndex;

  datarec := CallFuncList(ACEDataRecord, arg);
  ioIndex := datarec.procId;
  if not( IsBound( datarec.args ) and IsBound( datarec.args.fgens ) ) then
    Info(InfoACE + InfoWarning, 1, 
         "No group generators saved. Setting value(s) from ACE ...");
    return ACE_ARGS(ioIndex, "fgens");
  else
    return datarec.args.fgens;
  fi;
end);

#############################################################################
####
##
#F  ACERelators . . . . . . . . . . . . . . . . . . . Return the GAP relators
##  . . . . . . . . . . . . . . . . . . . . . . of an interactive ACE session
##
##
InstallGlobalFunction(ACERelators, function(arg)
local datarec, ioIndex;

  datarec := CallFuncList(ACEDataRecord, arg);
  ioIndex := datarec.procId;
  if not( IsBound( datarec.args ) and IsBound( datarec.args.rels ) ) then
    Info(InfoACE + InfoWarning, 1, 
         "No relators saved. Setting value(s) from ACE ...");
    return ACE_ARGS(ioIndex, "rels");
  else
    return datarec.args.rels;
  fi;
end);

#############################################################################
####
##
#F  ACESubgroupGenerators . . . . . . . .  Return the GAP subgroup generators
##  . . . . . . . . . . . . . . . . . . . . . . of an interactive ACE session
##
##
InstallGlobalFunction(ACESubgroupGenerators, function(arg)
local datarec, ioIndex;

  datarec := CallFuncList(ACEDataRecord, arg);
  ioIndex := datarec.procId;
  if not( IsBound( datarec.args ) and IsBound( datarec.args.sgens ) ) then
    Info(InfoACE + InfoWarning, 1, 
         "No subgroup generators saved. Setting value(s) from ACE ...");
    return ACE_ARGS(ioIndex, "sgens");
  else
    return datarec.args.sgens;
  fi;
end);

#############################################################################
####
##
#F  DISPLAY_ACE_REC_FIELD . . . . . . . . . . . . . Displays  a  record  that
##  . . . . . . . . . . . . . . . . . . . . . . . . is itself a record  field
##
##
InstallGlobalFunction(DISPLAY_ACE_REC_FIELD, function(datarec, field)

  if not IsBound(datarec.(field)) or datarec.(field) = rec() then
    Print("No ", field, ".\n");
  else
    Display(datarec.(field));
    Print("\n");
  fi;
end);

#############################################################################
####
##
#F  DisplayACEOptions . . . . . . . . . . .  Displays the current ACE options
##
##
InstallGlobalFunction(DisplayACEOptions, function(arg)
  DISPLAY_ACE_REC_FIELD( CallFuncList(ACEDataRecord, arg), "options" );
end);

#############################################################################
####
##
#F  DisplayACEArgs  . . . . . . . . . . . . . . Displays the current ACE args
##
##
InstallGlobalFunction(DisplayACEArgs, function(arg)
  DISPLAY_ACE_REC_FIELD( CallFuncList(ACEDataRecord, arg), "args" );
end);

#############################################################################
####
##
#F  GET_ACE_REC_FIELD . . . . . . . . . . . . . . .  Returns a record that is
##  . . . . . . . . . . . . . . . . . . . . . . . .  itself  a  record  field
##  . . . . . . . . . . . . . . . . . . . . . . . .  associated   with     an
##  . . . . . . . . . . . . . . . . . . . . . . . . . interactive ACE process
##
##
InstallGlobalFunction(GET_ACE_REC_FIELD, function(arglist, field)
local datarec;

  datarec := CallFuncList(ACEDataRecord, arglist);
  if not IsBound(datarec.(field)) or datarec.(field) = rec() then
    Info(InfoACE + InfoWarning, 1, "No ", field, " saved.");
    return rec();
  else
    return datarec.(field);
  fi;
end);

#############################################################################
####
##
#F  GetACEOptions . . . . . . . . . . . . . . Returns the current ACE options
##
##
InstallGlobalFunction(GetACEOptions, function(arg)
  return GET_ACE_REC_FIELD(arg, "options");
end);

#############################################################################
####
##
#F  GetACEArgs . . . . . . . . . . . . . . . . . Returns the current ACE args
##
##
InstallGlobalFunction(GetACEArgs, function(arg)
  return GET_ACE_REC_FIELD(arg, "args");
end);

#############################################################################
####
##
#F  SET_ACE_OPTIONS . . . . . . . . . . . . . . . . . . .  Internal procedure
##  . . . . . . . . . . . . . . . . . . . . . . . . . Called by SetACEOptions
##
##  SetACEOptions has two forms: the  interactive  version  (below)  and  the
##  non-interactive version defined locally  within  ACECosetTable.  For  the
##  interactive version the data record datarec  is  ACEData.io[ioIndex]  for
##  some integer ioIndex. For the non-interactive version, which will only be
##  invoked from within a break-loop, datarec is ACEData.
##
InstallGlobalFunction(SET_ACE_OPTIONS, function(datarec)
local newoptnames;

  datarec.newoptions := NEW_ACE_OPTIONS();
  # First we need to scrub any option names in datarec.options that
  # match those in datarec.newoptions ... to ensure that *all* new
  # options are at the end of the stack
  SANITISE_ACE_OPTIONS(datarec.options, datarec.newoptions);
  PopOptions();
  Add(OptionsStack, datarec.options);
  PushOptions(datarec.newoptions);
  # The following is needed when SetACEOptions is invoked via ACEExample
  Unbind(OptionsStack[ Length(OptionsStack) ].aceexampleoptions);
  datarec.options := ShallowCopy( OptionsStack[ Length(OptionsStack) ] );
  # We ensure OptionsStack is the same length as before the call to 
  # SET_ACE_OPTIONS, and ensure the updated options are on top
  PopOptions();
  PopOptions();
  Add(OptionsStack, datarec.options);
  newoptnames := RecNames(datarec.newoptions);
  Unbind(datarec.newoptions);
  return newoptnames;
end);

#############################################################################
####
##
#F  ECHO_ACE_ARGS . . . . . . . . . . . . . . . . . . . .  Internal procedure
##  . . . . . . . . . . . . . . . . . . . . . . Echoes  the  values  of   the
##  . . . . . . . . . . . . . . . . . . . . . . fields: fgens, rels, sgens of
##  . . . . . . . . . . . . . . . . . . . . . . args  submitted  to  function
##  . . . . . . . . . . . . . . . . . . . . . . ACEfname if echo is positive.
##
InstallGlobalFunction(ECHO_ACE_ARGS, function(echo, ACEfname, args)
  if echo > 0 then
    Print(ACEfname, " called with the following arguments:\n");
    Print(" Group generators : ", args.fgens, "\n");
    Print(" Group relators : ", args.rels, "\n");
    Print(" Subgroup generators : ", args.sgens, "\n");
  fi;
end);

#############################################################################
####
##
#F  INTERACT_SET_ACE_OPTIONS  . . . . . . . . . . . . . .  Internal procedure
##  . . . . . . . . . . . . . . . . . . . . . . .  Passes new options to  ACE
##  . . . . . . . . . . . . . . . . . . . . . . .  and updates stored options
##
##  Called by the ACE function with name ACEfname and with datarec  equal  to
##  ACEData.io[ioIndex] for some integer ioIndex,  the  updated  options  are
##  stored in datarec.options.
##
InstallGlobalFunction(INTERACT_SET_ACE_OPTIONS, function(ACEfname, datarec)
local newoptnames, s, optnames, echo, ignored;
  datarec.modereqd := false;
  if not(IsEmpty(OptionsStack) or
         ForAll(RecNames(OptionsStack[ Length(OptionsStack) ]),
                optname -> optname in ACE_INTERACT_FUNC_OPTIONS)) then
    if IsBound(datarec.options) then
      newoptnames := SET_ACE_OPTIONS(datarec);
    else
      datarec.options := NEW_ACE_OPTIONS();
      newoptnames := RecNames(datarec.options);
    fi;
    optnames := RecNames(datarec.options);
    newoptnames := Filtered(
                       newoptnames,
                       optname -> not(optname in ACE_INTERACT_FUNC_OPTIONS));
    ignored := List(VALUE_ACE_OPTION(newoptnames, [], "aceignore"),
                    optname -> ACEPreferredOptionName(optname));
    datarec.modereqd := ForAny(newoptnames, 
                               function(optname)
                                 local prefname;
                                 
                                 prefname := ACEPreferredOptionName(optname);
                                 return not(prefname in NonACEbinOptions or
                                            prefname in ignored);
                               end);
    if ForAny(newoptnames, 
              optname -> ACEPreferredOptionName(optname)
                         in ["group", "relators", "generators"]) then
      for s in [ "Detected usage of a synonym of one (or more) of the options:",
                 "    `group', `relators', `generators'.",
                 "Discarding current values of args.",
                 "(The new args will be extracted from ACE, later)." ]
      do
        Info(InfoACE + InfoWarning, 1, s);
      od;
      Unbind(datarec.args);
      Unbind(datarec.acegens);
    fi;
    echo := ACE_VALUE_ECHO(optnames);
    if IsBound(datarec.echoargs) then
      if IsBound(datarec.args) then
        ECHO_ACE_ARGS( echo, ACEfname, datarec.args );
      fi;
      Unbind(datarec.echoargs);
    fi;
    PROCESS_ACE_OPTIONS(ACEfname, optnames, newoptnames, echo, datarec,
                        # disallowed (options) ... none
                        rec(),
                        # ignored
                        Concatenation( [ "aceinfile", "aceoutfile" ],
                                       ignored,
                                       ACE_IF_EXPR(
                                           IsBound(datarec.enforceAsis)
                                           and datarec.enforceAsis,
                                                   [ "asis" ], [], []) ));
  fi;
end);
  
#############################################################################
####
##
#F  SetACEOptions . . . . . . . . . . . .  Interactively, passes  new options 
##  . . . . . . . . . . . . . . . . . . .  to ACE and updates stored  options
##
InstallGlobalFunction(SetACEOptions, function(arg)
local datarec;

  if Length(arg) > 2 then
    Error("expected 0, 1 or 2 arguments ... not ", Length(arg), " arguments\n");
  elif Length(arg) in [1, 2] and IsRecord( arg[Length(arg)] ) then
    if not IsEmpty(OptionsStack) then
      Info(InfoACE + InfoWarning, 1,
           "Non-empty OptionsStack: SetACEOptions may have been called with");
      Info(InfoACE + InfoWarning, 1,
           "both a record argument and options. The order options are listed");
      Info(InfoACE + InfoWarning, 1,
           "may be incorrect. Please use separate calls to SetACEOptions,");
      Info(InfoACE + InfoWarning, 1,
           "e.g. 'SetACEOptions(<optionsRec>); SetACEOptions(: <options>);' ");
    fi;
    PushOptions( arg[Length(arg)] );
    datarec := CallFuncList(ACEDataRecord, arg{[1..Length(arg) - 1]});
    INTERACT_SET_ACE_OPTIONS("SetACEOptions", datarec);
    PopOptions();
  elif Length(arg) <= 1 then
    datarec := CallFuncList(ACEDataRecord, arg);
    INTERACT_SET_ACE_OPTIONS("SetACEOptions", datarec);
  else
    Error("2nd argument should have been a record\n");
  fi;
  if datarec.modereqd then
    CHEAPEST_ACE_MODE(datarec); 
  fi;
  ACE_LENLEX_CHK(datarec.procId, false);
end);

#############################################################################
####
##
#F  ACE_PARAMETER_WITH_LINE . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . . . . for the ACE process  of  index  ioIndex
##  . . . . . . . . . . . . . . . . . returns ACE's value  of  the  parameter
##  . . . . . . . . . . . . . . . . . identified by string starting with line
##
InstallGlobalFunction(ACE_PARAMETER_WITH_LINE, function(ioIndex, string, line)
  # Remove "<string>: " and trailing newline
  line := line{[Length(string) + 3 .. Length(line) - 1]};
  if line = "" or line[ Length(line) ] <> ';' then
    line := Flat([line,
                  List(ACEReadUntil(ioIndex, line -> line[Length(line)] = ';'),
                       line -> line{[3..Length(line)]}) # Scrub two blanks at
                                                        # beginning of lines
                  ]);
  fi;
  # Remove any blanks after commas and trailing ';'
  return ReplacedString(line{[1..Length(line) - 1]}, ", ", ",");
end);

#############################################################################
####
##
#F  ACE_PARAMETER . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . . . . .  for the ACE process of index ioIndex
##  . . . . . . . . . . . . . . . . . .  returns ACE's value of the parameter
##  . . . . . . . . . . . . . . . . . . . . . . . . . .  identified by string
##
InstallGlobalFunction(ACE_PARAMETER, function(ioIndex, string)
local line;
  line := FLUSH_ACE_STREAM_UNTIL(ACEData.io[ ioIndex ].stream, 3, 3, 
                                 ACE_READ_NEXT_LINE, 
                                 line -> Length(line) >= Length(string) and
                                         line{[1..Length(string)]} = string);
  return ACE_PARAMETER_WITH_LINE(ioIndex, string, line);
end);

#############################################################################
####
##
#F  ACE_GAP_WORDS . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . .  returns the translation into GAP of an ACE list of words
##
##  ACE stores words according to the BNF:
##      <word>      = <element> <word> | "(" <word> ")^" <power>
##      <power>     = <integer>
##      <element>   = <generator> | <inverse>
##      <generator> = <integer> <space> | <lowercase letter>
##      <inverse>   = "-" <generator> | <uppercase letter> 
##
InstallGlobalFunction(ACE_GAP_WORDS, function(datarec, words)
local GAPWord;
  
  GAPWord := function(word)
  local power, parts, elements;
    if word[1] = '(' then
      parts := SplitString(word, "", "()^");
      word := parts[1];
      power := Int(parts[2]);
    else
      power := 1;
    fi;
    if IsDigitChar(word[1]) or word[1] = '-' then
      elements := List(SplitString(word, " "), Int);
      # Convert to GAP elements
      elements := List(elements, 
                       function(element)
                         if element < 0 then
                           return datarec.args.fgens[ AbsInt(element) ]^-1;
                         else
                           return datarec.args.fgens[element];
                         fi;
                       end);
    else
      elements := List([1..Length(word)], i -> WordAlp(word, i));
      # Convert to GAP elements
      elements := List(elements, 
                       function(element)
                         if IsUpperAlphaChar(element[1]) then
                           return datarec.args.fgens[ 
                                      Position(
                                          datarec.acegens,
                                          LowercaseString(element)
                                          )
                                      ]^-1;
                         else
                           return datarec.args.fgens[ Position(datarec.acegens, 
                                                              element) ];
                         fi;
                       end);
    fi;
    return Product( elements, One(datarec.args.fgens[1]) )^power;
  end;

  return List(SplitString(words, ','), GAPWord);
end);

#############################################################################
####
##
#F  ACE_GENS  . . . . . . . . . . . . . . . . . . . . . .  Internal procedure
##  . . . . . . . . . . . . . . . sets datarec.args.fgens and datarec.acegens
##  . . . . . . . . . . . . . . . from the value of ACE's "Group  Generators"
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . parameter
##
InstallGlobalFunction(ACE_GENS, function(datarec, string)
local line;
  if IsAlphaChar(string[1]) then
    datarec.acegens := List([1..Length(string)], i -> WordAlp(string, i));
    datarec.args.fgens := GeneratorsOfGroup( FreeGroup(datarec.acegens) );
  else
    datarec.acegens := List([1..Int(string)], i -> String(i));
    datarec.args.fgens := GeneratorsOfGroup(FreeGroup(
                                                List(datarec.acegens, 
                                                     s -> Flat(["x", s]))
                                                ));
  fi;
end);

#############################################################################
####
##
#F  ACE_ARGS  . . . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . for the ACE process indexed by  ioIndex  sets
##  . . . . . . . . . . . . . and returns ACEDataRecord(ioIndex).args.(field)
##  . . . . . . . . . . . . . . . . . . .  according to ACE's parameter value
##
##  If      ACEDataRecord(ioIndex).args      is      unset,      it       and
##  ACEDataRecord(ioIndex).acegens are set according to the  values  held  by
##  the ACE process indexed by ioIndex.
##
InstallGlobalFunction(ACE_ARGS, function(ioIndex, field)
local datarec, line;
  datarec := ACEDataRecord(ioIndex);
  if not IsBound(datarec.args) then
    datarec.args := rec();
  fi;
  if not IsBound(datarec.args.fgens) or field = "fgens" then
    WRITE_LIST_TO_ACE_STREAM(datarec.stream, [ "sr:1;" ]);
    line := FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE,
                                   line -> Length(line) > 8 and
                                           line{[1..9]} in [ "Group Gen",
                                                             "Group Rel" ]);
    if IsMatchingSublist(line, "Group Gen") then
      ACE_GENS(datarec, ACE_PARAMETER_WITH_LINE(ioIndex, 
                                                "Group Generators", 
                                                line));
    else
      datarec.acegens := [];
      datarec.args.fgens := [];
    fi;
  else
    WRITE_LIST_TO_ACE_STREAM(datarec.stream, [ "sr;" ]);
  fi;
  if not IsBound(datarec.args.rels) or field = "rels" then
    if not IsBound(line) or not IsMatchingSublist(line, "Group Rel") then
      line := FLUSH_ACE_STREAM_UNTIL(
                  datarec.stream, 3, 3, ACE_READ_NEXT_LINE,
                  line -> IsMatchingSublist(line, "Group Rel") );
    fi;
    datarec.args.rels := ACE_GAP_WORDS(datarec,
                                       ACE_PARAMETER_WITH_LINE(
                                           ioIndex, "Group Relators", line
                                           ));
  fi;
  if not IsBound(datarec.args.sgens) or field = "sgens" then
    datarec.args.sgens := ACE_GAP_WORDS(datarec,
                                        ACE_PARAMETER(ioIndex, 
                                                      "Subgroup Generators"));
  fi;
  FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                         line -> IsMatchingSublist(line, "  #--"));
  return datarec.args.(field);
end);

#############################################################################
####
##
#F  ACEParameters . . . . . .  Returns the ACE value of ACE parameter options
##
##  Also ensures for the interactive ACE process indexed by i that  the  args
##  and acegens fields of  ACEData.io[i]  are  set.  If  not,  it  sets  them
##  according to the values held by ACE process i (the assumption being  that
##  the user started the process via 'ACEStart(0);').
##
InstallGlobalFunction(ACEParameters, function(arg)
local ioIndex, datarec, line, fieldsAndValues, parameters, sgens, i, opt, val;

  ioIndex := CallFuncList(ACEProcessIndex, arg);
  datarec := ACEData.io[ ioIndex ];
  READ_ACE_ERRORS(datarec);
  WRITE_LIST_TO_ACE_STREAM(datarec.stream, [ "sr:1;" ]);
  datarec.parameters 
      := rec(enumeration := ACE_PARAMETER(ioIndex, "Group Name"));
  parameters := datarec.parameters;
  if not IsBound(datarec.args) then
    datarec.args := rec();
  fi;
  if not IsBound(datarec.acegens) or not IsBound(datarec.args.fgens) then
    line := FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE,
                                   line -> Length(line) > 8 and
                                           line{[1..9]} in [ "Group Gen",
                                                             "Group Rel" ]);
    if IsMatchingSublist(line, "Group Gen") then
      ACE_GENS(datarec, ACE_PARAMETER_WITH_LINE(ioIndex, 
                                                "Group Generators", 
                                                line));
    else
      datarec.args.fgens := [];
      datarec.acegens := [];
    fi;
  fi;
  if not IsBound(datarec.args.rels) then
    if not IsBound(line) or not IsMatchingSublist(line, "Group Rel") then
      line := FLUSH_ACE_STREAM_UNTIL(
                  datarec.stream, 3, 3, ACE_READ_NEXT_LINE,
                  line -> IsMatchingSublist(line, "Group Rel"));
    fi;
    datarec.args.rels := ACE_GAP_WORDS(datarec,
                                       ACE_PARAMETER_WITH_LINE(
                                           ioIndex, "Group Relators", line
                                           ));
  fi;
  parameters.subgroup := ACE_PARAMETER(ioIndex, "Subgroup Name");
  sgens := ACE_PARAMETER(ioIndex, "Subgroup Generators");
  if not IsBound(datarec.args.sgens) then
    datarec.args.sgens := ACE_GAP_WORDS(datarec, sgens);
  fi;
  fieldsAndValues :=
      SplitString( 
          ReplacedString(
              Flat( ACEReadUntil(ioIndex, 
                                 line -> IsMatchingSublist(line, "C:")) ),
              "Fi:", "Fil:"
              ),
          "", " :;" 
          );
  FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE,
                         line -> IsMatchingSublist(line, "  #---"));
  i := 1;
  while i < Length(fieldsAndValues) do
    val := Int(fieldsAndValues[i + 1]);
    if val = fail then
      # workspace can be an integer or a string
      val := fieldsAndValues[i + 1];
    fi;
    parameters.(ACEOptionData( fieldsAndValues[i] ).synonyms[1]) := val;
    i := i + 2;
  od;
  return parameters;
end);

#############################################################################
####
##
#F  ACEBinaryVersion 
##
##  Infos the version and component compilation details of  the  ACE  binary,
##  and returns the version of the ACE binary.
##
InstallGlobalFunction(ACEBinaryVersion, function(arg)
local ioIndex, datarec;

  ACE_IOINDEX_ARG_CHK(arg);
  ioIndex := ACE_IOINDEX(arg);
  if ioIndex = fail then 
    # Fire up a new stream ... which we'll close when we're finished
    datarec := ACEData.ni;
    datarec.stream 
        := InputOutputLocalProcess( ACEData.tmpdir, ACEData.binary, [] );
  else
    # Use interactive ACE process: ioIndex
    datarec := ACEData.io[ ioIndex ];
  fi;
  READ_ACE_ERRORS(datarec); # purge any output not yet collected
                            # e.g. error messages due to unknown options
  Info(InfoACE, 1, "ACE Binary Version: ", ACEData.version);
  WRITE_LIST_TO_ACE_STREAM(datarec.stream, [ "options;" ]);
  FLUSH_ACE_STREAM_UNTIL(datarec.stream, 1, 1, ACE_READ_NEXT_LINE,
                         line -> IsMatchingSublist(line, "  host info ="));
  if ioIndex = fail then 
    CloseStream(datarec.stream);
  fi;
  return ACEData.version;
end);

#############################################################################
####
##
#F  EXEC_ACE_DIRECTIVE_OPTION . . . . . . . . . . . . . . . Internal Function
##  . . . . . . . . . . . . . . . . . . .  executes an ACE `directive' option
##
##  An ACE `directive' option is an ACE option with name optname that returns
##  output; most are implemented by a function of form: ACEOptname.
##
##  For the stream and option value defined by arglist pass optname (the name
##  of an ACE option that expects a value) to ACE and flush the output  until
##  a line for which IsMyLine(line) is true or an error  is  encountered  and
##  then return the final line. If IsMyLine is the the null string  then  ACE
##  is also directed to print closeline via option  `text'  and  IsMyLine  is
##  defined to be true if a line matches closeline; in this way closeline  is
##  a sentinel. If both IsMyLine and  closeline  are  null  strings  then  we
##  expect no ACE output and  just  check  for  error  output  from  ACE.  If
##  IsMyLine is the null string, closeline is a non-null string and readUntil
##  is true then all lines read are returned rather than just the last line.
##
InstallGlobalFunction(EXEC_ACE_DIRECTIVE_OPTION, 
function(arglist, optname, infoLevel, IsMyLine, closeline, readUntil)
local datarec, optval, line;
  datarec := ACEData.io[ arglist[1] ];
  optval := arglist[2];
  READ_ACE_ERRORS(datarec); # purge any output not yet collected
                            # e.g. error messages due to unknown options
  PROCESS_ACE_OPTION(datarec.stream, optname, optval);

  if IsMyLine = "" then
    if closeline = "" then 
      # We don't expect any ACE output ... just check for errors
      READ_ACE_ERRORS(datarec);
      return;
    else
      PROCESS_ACE_OPTION(datarec.stream, "text", closeline);
      IsMyLine := line -> Chomp(line) = closeline;
      if readUntil then
        return ACEReadUntil(arglist[1], IsMyLine);
      fi;
    fi;
  else
    line := FLUSH_ACE_STREAM_UNTIL(datarec.stream, infoLevel, infoLevel, 
                                   ACE_READ_NEXT_LINE, 
                                   line -> IsMyLine(line) or
                                           IsMatchingSublist(line, "** ERROR"));
    if IsMatchingSublist(line, "** ERROR") then
      IsMyLine := line -> IsMatchingSublist(line, "   "); # 1 more line to flush
    else 
      return line;
    fi;
  fi;

  return FLUSH_ACE_STREAM_UNTIL(datarec.stream, infoLevel, infoLevel, 
                                ACE_READ_NEXT_LINE, IsMyLine);
end);

#############################################################################
####
##
#F  ACE_IOINDEX_AND_NO_VALUE  . . . . . . . . . . . . . . . Internal Function
##  . . . . . . . . . . . . . . . . . . . .  returns a list [ioIndex, optval]
##  . . . . . . . . . . . . . . . . . . . .  for a no-value  ACE  `directive'
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  option
##
InstallGlobalFunction(ACE_IOINDEX_AND_NO_VALUE, function(arglist)
  return [ CallFuncList(ACEProcessIndex, arglist), "" ];
end);

#############################################################################
####
##
#F  ACE_IOINDEX_AND_ONE_VALUE . . . . . . . . . . . . . . . Internal Function
##  . . . . . . . . . . . . . . . . . . . .  returns a list [ioIndex, optval]
##  . . . . . . . . . . . . . . . . . . . .  for a one-value ACE  `directive'
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  option
##
InstallGlobalFunction(ACE_IOINDEX_AND_ONE_VALUE, function(arglist)
  if Length(arglist) in [1,2] then
    return [ CallFuncList(ACEProcessIndex, arglist{[1..Length(arglist) - 1]}),
             arglist[Length(arglist)] ];
  else
    Error("expected 1 or 2 arguments ... not ", 
          Length(arglist), " arguments\n");
  fi;
end);

#############################################################################
####
##
#F  ACE_IOINDEX_AND_ONE_LIST  . . . . . . . . . . . . . . . Internal Function
##  . . . . . . . . . . . . . . . . . . . .  returns a list [ioIndex, optval]
##  . . . . . . . . . . . . . . . . . . . .  for a one-value ACE  `directive'
##  . . . . . . . . . . . . . . . . . . . .  option,  where  that   one-value
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  must be a list
##
InstallGlobalFunction(ACE_IOINDEX_AND_ONE_LIST, function(arglist)
  if not(Length(arglist) in [1,2]) then
    Error("expected 1 or 2 arguments ... not ", 
          Length(arglist), " arguments\n");
  elif IsString(arglist[ Length(arglist) ]) or 
       not IsList(arglist[ Length(arglist) ]) then
    Error("last argument should be a list\n");
  else
    return [ CallFuncList(ACEProcessIndex, arglist{[1..Length(arglist) - 1]}),
             arglist[Length(arglist)] ];
  fi;
end);

#############################################################################
####
##
#F  ACE_IOINDEX_AND_LIST  . . . . . . . . . . . . . . . . . Internal Function
##  . . . . . . . . . . . . . . . . . . . .  returns a list [ioIndex, optval]
##  . . . . . . . . . . . . . . . . . . . .  for a no-value or list-value ACE
##  . . . . . . . . . . . . . . . . . . . . . . . . . . .  `directive' option
##
InstallGlobalFunction(ACE_IOINDEX_AND_LIST, function(arglist)
  if Length(arglist) > 2 then
    Error("expected 0, 1 or 2 arguments ... not ", 
          Length(arglist), " arguments\n");
  elif Length(arglist) in [1, 2] and IsList( arglist[Length(arglist)] ) then
    return [ CallFuncList(ACEProcessIndex, arglist{[1..Length(arglist) - 1]}),
             arglist[Length(arglist)] ];
  elif Length(arglist) <= 1 then
    return [ CallFuncList(ACEProcessIndex, arglist), "" ];
  else
    Error("2nd argument should have been a list\n");
  fi;
end);

#############################################################################
####
##
#F  ACEDumpVariables . . . . . . . . . . . . . Dumps ACE's internal variables
##
##
InstallGlobalFunction(ACEDumpVariables, function(arg)
  EXEC_ACE_DIRECTIVE_OPTION(
      ACE_IOINDEX_AND_LIST(arg), "dump", 1, 
      line -> IsMatchingSublist(line, "  #----"), "", false);
end);

#############################################################################
####
##
#F  ACEDumpStatistics . . . . . . . . . . . . Dumps ACE's internal statistics 
##
##
InstallGlobalFunction(ACEDumpStatistics, function(arg)
  EXEC_ACE_DIRECTIVE_OPTION(
      ACE_IOINDEX_AND_NO_VALUE(arg), "statistics", 1, 
      line -> IsMatchingSublist(line, "  #----"), "", false);
end);

#############################################################################
####
##
#F  ACEStyle . . . . . . . . . . . . .  Returns the current enumeration style
##
##
InstallGlobalFunction(ACEStyle, function(arg)
local splitstyle;
  splitstyle := SplitString(
                    EXEC_ACE_DIRECTIVE_OPTION(
                        ACE_IOINDEX_AND_NO_VALUE(arg), "style", 3, 
                        line -> IsMatchingSublist(line, "style"), "", false
                        ),
                    "", " =\n"
                    );
  if Length(splitstyle) = 2 then
    return splitstyle[2];
  else
    return Flat([ splitstyle[2], " (defaulted)" ]);
  fi;
end);

#############################################################################
####
##
#F  ACEDisplayCosetTable  . . . . . . . .  Prints the current ACE coset table
##  . . . . . . . . . . . . . . . . . .  at its current level of completeness
##
##
InstallGlobalFunction(ACEDisplayCosetTable, function(arg)
local ioIndexAndValue, stream, closeline;
  ioIndexAndValue := ACE_IOINDEX_AND_LIST(arg);
  stream := ACEData.io[ ioIndexAndValue[1] ].stream;
  PROCESS_ACE_OPTION(stream, "print", ioIndexAndValue[2]);
  closeline := "------------------------------------------------------------";
  PROCESS_ACE_OPTION(stream, "text", closeline);
  FLUSH_ACE_STREAM_UNTIL(stream, 3, 3, ACE_READ_NEXT_LINE, 
                         line -> IsMatchingSublist(line, "CO:") or
                                 IsMatchingSublist(line, "co:") or
                                 IsMatchingSublist(line, "** ERROR"));
  FLUSH_ACE_STREAM_UNTIL(stream, 1, 3, ACE_READ_NEXT_LINE, 
                         line -> IsMatchingSublist(line, closeline));
end);

#############################################################################
####
##
#F  IsCompleteACECosetTable . . . . . Returns true if the current coset table 
##  . . . . . . . . . . . . . . . . . is  complete,  as  determined  by   the
##  . . . . . . . . . . . . . . . . . current value of the enumeration index,
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . and false otherwise
##
InstallGlobalFunction(IsCompleteACECosetTable, function(arg)
local datarec;
  datarec := CallFuncList(ACEDataRecord, arg);
  if not IsBound(datarec.stats) then
    CHEAPEST_ACE_MODE(datarec);
  fi;
  return datarec.stats.index <> 0;
end);

#############################################################################
####
##
#F  ACECosetRepresentative  . . . . . . . . Returns the coset  representative
##  . . . . . . . . . . . . . . . . . . . . of coset n, for the current coset
##  . . . . . . . . . . . . . . . . . . . . table held by interactive process
##  . . . . . . . . . . . . . . . . . . . . . . i, for i, n determined by arg
##
InstallGlobalFunction(ACECosetRepresentative, function(arg)
local ioIndexAndValue, datarec, coset, line, list;
  ioIndexAndValue := ACE_IOINDEX_AND_ONE_VALUE(arg);
  datarec := ACEData.io[ ioIndexAndValue[1] ];
  coset := ioIndexAndValue[2];
  READ_ACE_ERRORS(datarec); # purge any output not yet collected
  if coset = 1 then
    return One(ACEGroupGenerators( ioIndexAndValue[1] )[1]);
  elif coset > datarec.stats.activecosets then
    Error("ACECosetRepresentative: coset table has only ",
          datarec.stats.activecosets, " (<", coset, ") active coset nos.\n");
  fi;
  PROCESS_ACE_OPTION(datarec.stream, "print", [-coset, coset]);
  line := FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                                 line -> Length(line) > 1 and
                                         line{[1..2]} in ["--", "  "]);
  if IsMatchingSublist(line, "  ") then
    Error("ACECosetRepresentative: ", line{[4..Length(line)]});
  fi;
  list := ACEReadUntil(ioIndexAndValue[1], list -> true, 
                       line -> SplitString(line, "", "| "))[1];
  return ACE_GAP_WORDS(datarec, list[ Length(list) ])[1];
end);

#############################################################################
####
##
#F  ACECosetRepresentatives . . . . . . . . Returns the coset representatives
##  . . . . . . . . . . . . . . . . . . . . . .  of ACE's current coset table
##
##
InstallGlobalFunction(ACECosetRepresentatives, function(arg)
local ioIndex, datarec, line, activecosets, cosetreps;
  ioIndex := CallFuncList(ACEProcessIndex, arg);
  datarec := ACEData.io[ ioIndex ];
  if not IsBound(datarec.stats) then
    Error("ACECosetRepresentatives: no current table?\n");
  fi;
  READ_ACE_ERRORS(datarec); # purge any output not yet collected
  PROCESS_ACE_OPTION(datarec.stream, "print", -datarec.stats.activecosets);
  line := FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                                 line -> Length(line) > 1 and
                                         line{[1..2]} in ["co", "CO", "  "]);
  if IsMatchingSublist(line, "  ") then
    Error("ACECosetRepresentatives: ", line{[4..Length(line)]});
  fi;
  activecosets := Int( SplitString(line, "", "coCO: a=")[1] );
  FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                         line -> IsMatchingSublist(line, "     1 "));
  cosetreps := List(ACEReadUntil(
                        ioIndex, 
                        list -> Int(list[1]) = Minimum(
                                                   activecosets,
                                                   datarec.stats.activecosets),
                        line -> SplitString(line, "", "| ")
                        ),
                    list -> ACE_GAP_WORDS(datarec, list[ Length(list) ])[1]
                    );
  if datarec.stats.activecosets < activecosets then
    # We missed some
    PROCESS_ACE_OPTION(datarec.stream, "print", 
                       [-(datarec.stats.activecosets + 1), activecosets]);
    line := FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                                   line -> IsMatchingSublist(line, "---"));
    return Concatenation([One(ACEGroupGenerators(ioIndex)[1])],
                         cosetreps,
                         List(ACEReadUntil(ioIndex, 
                                           list -> Int(list[1]) = activecosets,
                                           line -> SplitString(line, "", "| ")),
                              list -> ACE_GAP_WORDS(
                                          datarec, list[ Length(list) ])[1]
                              )
                         );
  else
    return Concatenation([One(ACEGroupGenerators(ioIndex)[1])], cosetreps);
  fi;
end);

#############################################################################
####
##
#F  ACETransversal  . . . . . . . . . Returns ACECosetRepresentatives(arg) if
##  . . . . . . . . . . . . . . . . . the current coset  table  is  complete,
##  . . . . . . . . . . . . . . . . . . . . . . . . . . .  and fail otherwise
##
InstallGlobalFunction(ACETransversal, function(arg)
local ioIndex;
  ioIndex := CallFuncList(ACEProcessIndex, arg);  
  if IsCompleteACECosetTable(ioIndex) then
    return ACECosetRepresentatives(ioIndex);
  else
    Info(InfoACE + InfoWarning, 1,
         "ACETransversal: coset table is not complete");
    return fail;
  fi;
end);

#############################################################################
####
##
#F  ACECycles . . . . . . . . . . . . .  Display the cycles (permutations) of
##  . . . . . . . . . . . . . . . . . . . . .  the permutation representation
##
InstallGlobalFunction(ACECycles, function(arg)
local datarec, error, cycles;
  datarec := CallFuncList(ACEDataRecord, arg);
  READ_ACE_ERRORS(datarec); # purge any output not yet collected
                            # e.g. error messages due to unknown options
  PROCESS_ACE_OPTION(datarec.stream, "cycles", "");
  PROCESS_ACE_OPTION(datarec.stream, "text", ""); # Make ACE print a blank line
                                                  # ... that we use as sentinel
  error := IsMatchingSublist(
               FLUSH_ACE_STREAM_UNTIL( 
                   datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                   line -> Length(line) > 1 and
                           line{[1..2]} in ["**", "CO", "co"]
                   ),
               "**", 1);
  cycles := ACEReadUntil(datarec.procId, line -> line = "");
  if error then
    Info(InfoACE + InfoWarning, 1,
         ReplacedString(cycles[1], "   ", "ACECycles: "));
    return fail;
  else
    cycles := List(cycles, 
                   function(line)
                     local posEq;
                     posEq := Position(line, '=');
                     if posEq = fail then
                       return line;
                     elif IsMatchingSublist(line, "= identity", posEq) then
                       return ", ()";
                     else
                       return ReplacedString(line, line{[1..posEq]}, ",");
                     fi;
                   end);
    cycles[1][1] := '[';
    Add(cycles, "]");
    return EvalString( Concatenation(cycles) );
  fi;
end);

#############################################################################
####
##
#F  ACETraceWord  . . . . . . . . . . . . Traces word through the coset table
##  . . . . . . . . . . . . . . . . . . . of the i-th interactive ACE process
##  . . . . . . . . . . . . . . . . . . . starting at coset n, for i, n, word
##  . . . . . . . . . . . . . . . . . . . determined by arg, and  return  the
##  . . . . . . . . . . . . . . . . . . . final coset  number  if  the  trace
##  . . . . . . . . . . . . . . . . . . . . . . completes, and fail otherwise
##
InstallGlobalFunction(ACETraceWord, function(arg)
local ioIndex, datarec, twArgs, acegen, expected, line;
  if Length(arg) in [2,3] then
    datarec := CallFuncList(ACEDataRecord, arg{[1..Length(arg) - 2]});
    ioIndex := datarec.procId;
    twArgs := arg{[Length(arg) - 1..Length(arg)]};
    if not IsPosInt(twArgs[1]) then
      Error("ACETraceWord: coset number must be a positive integer\n"); 
    fi;
  else
    Error("expected 2 or 3 arguments ... not ", 
          Length(arg), " arguments\n");
  fi;
  READ_ACE_ERRORS(datarec); # purge any output not yet collected
  if IsOne(twArgs[2]) and twArgs[2] = One( ACEGroupGenerators(ioIndex)[1] ) then
    acegen := datarec.acegens[1];
    # The ACE binary does not recognise the empty string as the identity
    WRITE_LIST_TO_ACE_STREAM(
        datarec.stream, [ "tw:", twArgs[1], ",", acegen, "*", acegen, "^-1;" ]);
  else
    PROCESS_ACE_OPTION(datarec.stream, "tw", twArgs);
  fi;
  expected := Flat([String(twArgs[1]), " * word = "]){[1..8]};
  line := FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE, 
                                 line -> Length(line) > 7 and
                                         line{[1..8]} in [expected,
                                                          "* Trace ",
                                                          "** ERROR"]);
  if IsMatchingSublist(line, expected) then
    return Int(SplitString(line, "", " *word=\n")[2]);
  elif IsMatchingSublist(line, "* Trace ") then
    Info(InfoACE + InfoWarning, 1,
         "ACETraceWord:", line{[2..Length(line) - 1]});
    return fail;
  else
    line := Chomp( ACE_READ_NEXT_LINE(datarec.stream) );
    Info(InfoACE, 3, line);
    Error("ACETraceWord:", line{[3..Length(line)]});
  fi;
end);

#############################################################################
####
##
#F  ACE_ORDER . . . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . . . . . . .  called by ACEOrder and ACEOrders
##
##
InstallGlobalFunction(ACE_ORDER, function(ACEfname, ioIndexAndValue)
local lines, line, datarec;
  lines := EXEC_ACE_DIRECTIVE_OPTION(
               ioIndexAndValue, "order", 3, "", "---------------------", true);
  if lines[Length(lines) - 1][1] = '*' then
    line := lines[Length(lines) - 1];
    Info(InfoACE + InfoWarning, 1, ACEfname, ":", line{[2..Length(line)]});
    if ioIndexAndValue[2] > 0 then
      return fail;
    else
      return [];
    fi;
  elif IsMatchingSublist(lines[Length(lines) - 2], "** ERROR", 1) then
    line := lines[Length(lines) - 1];
    Error(ACEfname, ":", line{[3..Length(line)]}, "\n",
          "(most probably the value passed to ", ACEfname, 
          "\nwas inappropriate)\n");
  else
    datarec := ACEData.io[ ioIndexAndValue[1] ];
    return List(lines{[First([1..Length(lines)], 
                             i -> IsMatchingSublist(lines[i], "--------")) + 1
                       .. Length(lines) - 1]},
                function(line)
                  line := SplitString(line, "", "| ");
                  return rec(coset := Int(line[1]),
                             order := Int(line[2]),
                             rep := ACE_GAP_WORDS(datarec, line[3])[1]);
                end);
  fi;
end);

#############################################################################
####
##
#F  ACEOrders . . . . . . . . . . . . . . . . . . . Returns a list of records
##  . . . . . . . . . . . . . . . . . . rec(coset := n, order := o, rep := r)
##  . . . . . . . . . . . . . . . . . . of   all    coset    numbers    whose
##  . . . . . . . . . . . . . . . . . . representatives' orders  (modulo  the
##  . . . . . . . . . . . . . . . . . . subgroup) are either finite,  or,  if
##  . . . . . . . . . . . . . . . . . . invoked with the  `suborder'  option,
##  . . . . . . . . . . . . . . . . . . are multiples of the  value  assigned
##  . . . . . . . . . . . . . . . . . . to ` suborder', for  the  interactive
##  . . . . . . . . . . . . . . . . . . . . . . ACE process determined by arg
##
InstallGlobalFunction(ACEOrders, function(arg)
local ioIndex, suborder;
  ioIndex := CallFuncList(ACEProcessIndex, arg);
  suborder := ValueOption("suborder");
  if IsPosInt(suborder) then
    return ACE_ORDER("ACEOrders", [ioIndex, -suborder]);
  else
    if suborder <> fail then
      Info(InfoACE + InfoWarning, 1, 
           "ACEOrders: Expected positive integer value of suborder option");
      Info(InfoACE + InfoWarning, 1,
           "but received: ", suborder, ". Ignoring ... giving all orders.");
    fi;
    return ACE_ORDER("ACEOrders", [ioIndex, 0]);
  fi;
end);

#############################################################################
####
##
#F  ACEOrder  . . . . . . . . . . . . . . . . . . . . . . .  Returns a record
##  . . . . . . . . . . . . . . . . . . rec(coset := n, order := o, rep := r)
##  . . . . . . . . . . . . . . . . . . whose representative's order  (modulo
##  . . . . . . . . . . . . . . . . . . the  subgroup)  is  a   multiple   of
##  . . . . . . . . . . . . . . . . . . suborder,  a  positive  integer,   or
##  . . . . . . . . . . . . . . . . . . `fail' if  there  is  no  such  coset
##  . . . . . . . . . . . . . . . . . . number, for the i-th interactive  ACE
##  . . . . . . . . . . . . . . . . . . process, for i,  suborder  determined
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  by arg
##
##  Actually, suborder is also allowed to be a negative integer -n, in  which
##  case, `ACEOrder(i, -n)' is equivalent to `ACEOrders(i : suborder :=  n)';
##  or suborder may be zero, in which case, `ACEOrder(i, 0)' is equivalent to
##  `ACEOrders(i)'.
##
InstallGlobalFunction(ACEOrder, function(arg)
local ioIndexAndValue, orderlist;
  ioIndexAndValue := ACE_IOINDEX_AND_ONE_VALUE(arg);
  orderlist := ACE_ORDER("ACEOrder", ioIndexAndValue);
  if IsList(orderlist) and ioIndexAndValue[2] > 0 then
    return orderlist[1];
  else
    return orderlist;
  fi;
end);

#############################################################################
####
##
#F  ACECosetOrderFromRepresentative( <i>, <cosetrep> )
#F  ACECosetOrderFromRepresentative( <cosetrep> )
##
##  for the <i>-th (or default) interactive {\ACE} process return  the  order
##  (modulo the subgroup) of the coset with representative <cosetrep> a  word
##  in the free group generators.
##
##  *Note:*   
##  `ACECosetOrderFromRepresentative' calls `ACETraceWord' to  determine  the
##  coset (number) to which <cosetrep> belongs, and then scans the output  of
##  `ACEOrders' to determine the order of the coset (number).
##
InstallGlobalFunction(ACECosetOrderFromRepresentative, function(arg)
local ioIndexAndValue, ioIndex, cosetrep, coset, entry;
  ioIndexAndValue := ACE_IOINDEX_AND_ONE_VALUE(arg);
  ioIndex := ioIndexAndValue[1];
  cosetrep := ioIndexAndValue[2];
  if IsOne(cosetrep) and cosetrep = One( ACEGroupGenerators(ioIndex)[1] ) then
    return 1;
  fi;
  ACERecover(ioIndex);
  coset := ACETraceWord(ioIndex, 1, ioIndexAndValue[2]);
  if coset = fail or coset = 1 then
    return coset;
  fi;
  entry := First(ACE_ORDER("ACEOrder", [ioIndex, 0]),
                 entry -> entry.coset = coset);
  if entry = fail then
    return fail;
  fi;
  return entry.order;
end);

#############################################################################
####
##
#F  ACECosetsThatNormaliseSubgroup  . . . . . . .  Determine  coset   numbers
##  . . . . . . . . . . . . . . . . . . . . . . .  whose      representatives
##  . . . . . . . . . . . . . . . . . . . . . . .  normalise   the   subgroup
##
##  For the i-th interactive ACE process and n, where i and n are  determined
##  by arg:
##
##  * If n > 0, the list of the first n non-trivial (i.e.  excluding coset 1)
##    coset numbers whose representatives normalise the subgroup is returned.
##  * If n < 0, a list  of  records  with  fields  `coset'  and  `rep'  which
##    represent the coset number and a representative, respectively,  of  the
##    first n non-trivial coset numbers whose representatives  normalise  the  
##    subgroup is returned.
##  * If n = 0, a list  of  records  with  fields  `coset'  and  `rep'  which
##    represent the coset number and a representative, respectively,  of  all
##    non-trivial coset numbers whose representatives normalise the  subgroup
##    is returned.
##
InstallGlobalFunction(ACECosetsThatNormaliseSubgroup, function(arg)
local ACEfname, ioIndexAndValue, lines, line, datarec;
  ACEfname := "ACECosetsThatNormaliseSubgroup";
  ioIndexAndValue := ACE_IOINDEX_AND_ONE_VALUE(arg);
  lines := EXEC_ACE_DIRECTIVE_OPTION(
               ioIndexAndValue, "sc", 3, "", "---------------------", true);
  if Length(lines) > 2 and 
     IsMatchingSublist(lines[Length(lines) - 2], "** ERROR", 1) then
    line := lines[Length(lines) - 1];
    Error(ACEfname, ":", line{[3..Length(line)]}, "\n",
          "(most probably the value passed to ", ACEfname, 
          "\nwas inappropriate)\n");
  else
    if IsMatchingSublist(lines[Length(lines) - 1], "* Nothing found", 1) then
      lines := [];
      Info(InfoACE + InfoWarning, 1, "no nontrivial normalising cosets found");
    else
      lines := lines{[First([1..Length(lines)], 
                            i -> IsMatchingSublist(lines[i], "Stabil")) + 1 ..
                      Length(lines) - 1]};
    fi;
    if ioIndexAndValue[2] > 0 then
      return List(lines, line -> Int( SplitString(line, "", " ")[1] ));
    else
      datarec := ACEData.io[ ioIndexAndValue[1] ];
      return List(lines,
                  function(line)
                    line := SplitString(line, "", " ");
                    return rec(coset := Int(line[1]),
                               rep := ACE_GAP_WORDS(datarec, line[2])[1]);
                  end);
    fi;
  fi;
end);

#############################################################################
##
#F  ACECosetTable  . . . . . . . . . . . .  Extracts the coset table from ACE
##
InstallGlobalFunction(ACECosetTable, function(arg)
local ioIndex, iostream, datarec, fgens, standard, incomplete,
      cosettable, errmsg, onbreakmsg, SetACEOptions, DisplayACEOptions;

  if Length(arg) = 2 or Length(arg) > 3 then
    Error("expected 0, 1 or 3 arguments ... not ", Length(arg), " arguments\n");
  elif Length(arg) <= 1 then
    # Called as an interactive ACE command
    ioIndex := CallFuncList(ACEProcessIndex, arg);
    datarec := ACEData.io[ ioIndex ];
    INTERACT_SET_ACE_OPTIONS("ACECosetTable", datarec);
    if not IsEmpty(OptionsStack) or not IsBound(datarec.stats) then
      CHEAPEST_ACE_MODE(datarec); 
    fi;
    standard := ACE_LENLEX_CHK(ioIndex, true);
    incomplete := datarec.stats.index = 0 and
                  DATAREC_VALUE_ACE_OPTION(datarec, false, "incomplete");
    if not incomplete and datarec.stats.index = 0 then
      Info(InfoACE + InfoWarning, 1, 
           "The `ACE' coset enumeration failed with the result:");
      Info(InfoACE + InfoWarning, 1, datarec.enumResult);
      Info(InfoACE + InfoWarning, 1, "Try relaxing any restrictive options.");
      Info(InfoACE + InfoWarning, 1, "For interactive ACE process <i>,");
      Info(InfoACE + InfoWarning, 1, 
           "type: 'DisplayACEOptions(<i>);' to see current ACE options.");
      return fail;
    else
      WRITE_LIST_TO_ACE_STREAM(datarec.stream, [ "Print Table;" ]);
      cosettable := ACE_COSET_TABLE(datarec.stats.activecosets, 
                                    datarec.acegens, 
                                    datarec.stream, 
                                    ACE_READ_NEXT_LINE);
    fi;
  else
    # Called non-interactively
    ACEData.ni := rec();

    onbreakmsg := ["Try relaxing any restrictive options",
                   "e.g. try the `hard' strategy or increasing `workspace'",
                   "type: '?strategy options' for info on strategies",
                   "type: '?options for ACE' for info on options",
                   "type: 'DisplayACEOptions();' to see current ACE options;",
                   "type: 'SetACEOptions(:<option1> := <value1>, ...);'",
                   "to set <option1> to <value1> etc.",
                   "(i.e. pass options after the ':' in the usual way)",
                   "... and then, type: 'return;' to continue.",
                   "Otherwise, type: 'quit;' to quit to outer loop."];

    SetACEOptions := function()
      if not IsEmpty(OptionsStack) and 
         datarec.optionsStackDepth in [0, Length(OptionsStack)] then
        SET_ACE_OPTIONS(datarec);
      fi;
    end;

    DisplayACEOptions := function()
      DISPLAY_ACE_REC_FIELD( datarec, "options" );
    end;

    repeat
      datarec :=
          CALL_ACE( "ACECosetTableFromGensAndRels", arg[1], arg[2], arg[3] );
      standard := ACE_COSET_TABLE_STANDARD( ACE_OPTIONS() );
      if IsBound(datarec.infile) then
        # User only wanted an ACE input file to use directly with standalone
        Info(InfoACE, 1, "ACE standalone input file: ", datarec.infile);
        return;
      fi;
      incomplete := datarec.stats.index = 0 and
                    VALUE_ACE_OPTION(ACE_OPT_NAMES(), false, "incomplete");
      if not incomplete and datarec.stats.index = 0 then
        CloseStream(datarec.stream);
        if datarec.silent then
          return fail;
        else
          datarec.options := ACE_OPTIONS();
          datarec.optionsStackDepth := Length(OptionsStack);
          if not IsBound(datarec.origOptionsStackDepth) then
            datarec.origOptionsStackDepth := datarec.optionsStackDepth;
          fi;
          if datarec.optionsStackDepth > 0 then
            # We pop options here, in case the user decides to quit
            PopOptions();
          fi;
          errmsg := ["no coset table ...",
                     "the `ACE' coset enumeration failed with the result:",
                      datarec.enumResult];
          Error(ACE_ERROR(errmsg, onbreakmsg), "\n");
          if datarec.options <> rec() then
            Add(OptionsStack, datarec.options);
            Unbind(datarec.options);
          fi;
        fi;
      else
        if IsBound(datarec.cosettable) then
          cosettable := datarec.cosettable;
          Unbind(datarec.cosettable);
        else
          WRITE_LIST_TO_ACE_STREAM(datarec.stream, [ "Print Table;" ]);
          cosettable := ACE_COSET_TABLE(datarec.stats.activecosets,
                                        datarec.acegens, 
                                        datarec.stream, 
                                        ACE_READ_NEXT_LINE);
        fi;
        CloseStream(datarec.stream);
        if IsBound(datarec.origOptionsStackDepth) and
           (datarec.origOptionsStackDepth = 0) and 
           not IsEmpty(OptionsStack) 
        then
          PopOptions();
        fi;
        Unbind(datarec.optionsStackDepth);
        Unbind(datarec.origOptionsStackDepth);
        break;
      fi;
    until false;
  fi;
  if incomplete then
    StandardizeTable(cosettable, "lenlex");
    Info(InfoACE + InfoWarning, 1, 
         "ACECosetTable: Coset table is incomplete, reduced ",
         "& lenlex standardised.");
  elif standard = "semilenlex" then
    StandardizeTable(cosettable, "semilenlex");
  elif IsMatchingSublist(standard, "GAP") or standard = "semilenlex" then
    StandardizeTable(cosettable);
  fi;
  return cosettable;
end);

#############################################################################
####
##
#F  ACEStats  . . . Get the subgroup index, time and number of cosets defined
##  . . . . . . . . . .  during an interactive or non-interactive ACE session
##
InstallGlobalFunction(ACEStats, function(arg)
local datarec, iostream, line, stats;

  if Length(arg) <= 1 then 
    # Called as an interactive ACE command
    datarec := CallFuncList(ACEDataRecord, arg);
    INTERACT_SET_ACE_OPTIONS("ACEStats", datarec);
    if not IsEmpty(OptionsStack) then
      CHEAPEST_ACE_MODE(datarec);
    fi;
    return datarec.stats;
  elif Length(arg) = 3 then              # args are: fgens,   rels,  sgens
    # Called non-interactively
    datarec := CALL_ACE("ACEStats", arg[1], arg[2], arg[3]);
    CloseStream( datarec.stream );
    return datarec.stats;
  else
    Error("expected 0, 1 or 3 arguments ... not ", Length(arg), " arguments\n");
  fi;
end);

#############################################################################
####
##
#F  ACERecover  . . . . . . . . . . . . Recover space from dead coset numbers
##  . . . . . . . . . . . . . . for interactive ACE process determined by arg
##
InstallGlobalFunction(ACERecover, function(arg)
  EXEC_ACE_DIRECTIVE_OPTION(
      ACE_IOINDEX_AND_NO_VALUE(arg), "recover", 3, 
      line -> Length(line) > 1 and line{[1..2]} in ["CO", "co"], "", false);
end);

#############################################################################
####
##
#F  ACEStandardCosetNumbering . . Reassigns coset numbers in lenlex  standard
##  . . . . . . . . . . . . . . . order   for   interactive    ACE    process
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . determined by arg
##
InstallGlobalFunction(ACEStandardCosetNumbering, function(arg)
  EXEC_ACE_DIRECTIVE_OPTION(
      ACE_IOINDEX_AND_NO_VALUE(arg), "standard", 3, 
      line -> Length(line) > 1 and line{[1..2]} in ["CO", "co"], "", false);
end);

#############################################################################
####
##
#F  ACEAddRelators  . . . . . . . . . . . . . . . Add relatorlist to relators 
##  . . . . . . . . . . . . . . . for interactive ACE process and relatorlist
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . determined by arg
##
##  Also sets and returns ACEData.io[i].args.rels, where i is  the  index  of
##  the interactive ACE process.
##
InstallGlobalFunction(ACEAddRelators, function(arg)
local ioIndexAndOptval, ioIndex, datarec;
  ioIndexAndOptval := ACE_IOINDEX_AND_ONE_LIST(arg);
  ioIndex := ioIndexAndOptval[1];
  datarec := ACEData.io[ ioIndex ];
  if not IsBound(datarec.enforceAsis) then
    datarec.enforceAsis := false;
  fi;
  EXEC_ACE_DIRECTIVE_OPTION(
      [ ioIndex, ACE_RELS(ioIndexAndOptval[2], # relatorlist
                          ACEGroupGenerators(ioIndex),
                          datarec.acegens,
                          datarec.enforceAsis) ],
      "rl", 3, "", "", false
      );
  CHEAPEST_ACE_MODE(datarec);
  return ACE_ARGS(ioIndex, "rels");
end);

#############################################################################
####
##
#F  ACEAddSubgroupGenerators  . . . . . . . . . Add generatorlist to relators 
##  . . . . . . . . . . . . . . for interactive ACE process and generatorlist
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . determined by arg
##
##  Also sets and returns ACEData.io[i].args.sgens, where i is the  index  of
##  the interactive ACE process.
##
InstallGlobalFunction(ACEAddSubgroupGenerators, function(arg)
local ioIndexAndOptval, ioIndex, datarec;
  ioIndexAndOptval := ACE_IOINDEX_AND_ONE_LIST(arg);
  ioIndex := ioIndexAndOptval[1];
  datarec := ACEData.io[ ioIndex ];
  EXEC_ACE_DIRECTIVE_OPTION(
      [ ioIndex, ACE_WORDS(ioIndexAndOptval[2], # generatorlist
                           ACEGroupGenerators(ioIndex),
                           datarec.acegens) ],
      "sg", 3, "", "", false
      );
  CHEAPEST_ACE_MODE(datarec);
  return ACE_ARGS(ioIndex, "sgens");
end);

#############################################################################
####
##
#F  ACE_WORDS_OR_UNSORTED . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . check val is a word list of goodwords, if  so
##  . . . . . . . . . . . . . . return the sorted list  of  indices  of  word
##  . . . . . . . . . . . . . . list in goodwords or report that  some  words
##  . . . . . . . . . . . . . . are not of wordtype. If  val  is  an  integer
##  . . . . . . . . . . . . . . list  a  sorted  integer  list  is  returned.
##  . . . . . . . . . . . . . . Otherwise, if  val  is  not  a  list  or  not
##  . . . . . . . . . . . . . . . . . . . . . . homogeneous, val is returned.
##
InstallGlobalFunction(ACE_WORDS_OR_UNSORTED, function(val, goodwords, wordtype)
local badwords;
  if IsList(val) then
    if ForAll(val, IsWord) then
      badwords := Filtered(val, w -> not(w in goodwords));
      if IsEmpty(badwords) then
        return SortedList(List(val, w -> Position(goodwords, w)));
      else
        Error(badwords, " are not ", wordtype, "\n");
      fi;
    elif ForAll(val, IsInt) then
      return SortedList(val);
    fi;
  fi;
  # Let the default error message sort it out
  return val;
end);

#############################################################################
####
##
#F  ACEDeleteRelators . . . . . . . . . . .  Delete relatorlist from relators 
##  . . . . . . . . . . . . . . . for interactive ACE process and relatorlist
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . determined by arg
##
##  Also sets and returns ACEData.io[i].args.rels, where i is  the  index  of
##  the interactive ACE process.
##
InstallGlobalFunction(ACEDeleteRelators, function(arg)
local ioIndexAndOptval;
  ioIndexAndOptval := ACE_IOINDEX_AND_ONE_LIST(arg);
  ioIndexAndOptval[2] := ACE_WORDS_OR_UNSORTED(ioIndexAndOptval[2],
                                               ACERelators(ioIndexAndOptval[1]),
                                               "relators");
  EXEC_ACE_DIRECTIVE_OPTION(ioIndexAndOptval, "dr", 3, "", "", false);
  CHEAPEST_ACE_MODE(ACEData.io[ ioIndexAndOptval[1] ]);
  return ACE_ARGS(ioIndexAndOptval[1], "rels");
end);

#############################################################################
####
##
#F  ACEDeleteSubgroupGenerators . . . . .  Delete generatorlist from relators 
##  . . . . . . . . . . . . . . for interactive ACE process and generatorlist
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . determined by arg
##
##  Also sets and returns ACEData.io[i].args.sgens, where i is the  index  of
##  the interactive ACE process.
##
InstallGlobalFunction(ACEDeleteSubgroupGenerators, function(arg)
local ioIndexAndOptval;
  ioIndexAndOptval := ACE_IOINDEX_AND_ONE_LIST(arg);
  ioIndexAndOptval[2] := ACE_WORDS_OR_UNSORTED(ioIndexAndOptval[2],
                                               ACESubgroupGenerators(
                                                   ioIndexAndOptval[1]
                                                   ),
                                               "subgroup generators");
  EXEC_ACE_DIRECTIVE_OPTION(ioIndexAndOptval, "ds", 3, "", "", false);
  CHEAPEST_ACE_MODE(ACEData.io[ ioIndexAndOptval[1] ]);
  return ACE_ARGS(ioIndexAndOptval[1], "sgens");
end);

#############################################################################
####
##
#F  ACECosetCoincidence . . . . . . . . . . Force the coincidence of coset  n 
##  . . . . . . . . . . . . . . . . . . . . with coset 1, for the interactive
##  . . . . . . . . . . . . . . . . . . . . ACE  process  i  and  integer   n
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . determined by arg
##
##  Essentially, the coset representative of coset n is added to the subgroup
##  generators, ACERedo and ACESubgroupGenerators are invoked, and the  coset
##  representative of coset n is returned.
##
InstallGlobalFunction(ACECosetCoincidence, function(arg)
local ioIndexAndOptval, cosetrep, datarec;
  ioIndexAndOptval := ACE_IOINDEX_AND_ONE_VALUE(arg);
  cosetrep := EXEC_ACE_DIRECTIVE_OPTION(
                  ioIndexAndOptval, "cc", 3, 
                  line -> IsMatchingSublist(line, "Coset"), "", false);
  if IsMatchingSublist(cosetrep, "  ") then
    return fail; # Error in input
  fi;
  datarec := ACEData.io[ ioIndexAndOptval[1] ];
  FLUSH_ACE_STREAM_UNTIL(datarec.stream, 3, 3, ACE_READ_NEXT_LINE,
                         line -> IsMatchingSublist(line, "*"));
  CHEAPEST_ACE_MODE(datarec);
  ACE_ARGS(ioIndexAndOptval[1], "sgens");
  return ACE_GAP_WORDS(
             datarec,
             cosetrep{[Position(cosetrep, ':') + 2..Length(cosetrep) - 1]}
             )[1];
end);

#############################################################################
####
##
#F  ACERandomCoincidences( <i>, <subindex> )
#F  ACERandomCoincidences( <subindex>)
#F  ACERandomCoincidences( <i>, [<subindex>] )
#F  ACERandomCoincidences( [<subindex>] )
#F  ACERandomCoincidences( <i>, [<subindex>, <attempts>] )
#F  ACERandomCoincidences( [<subindex>, <attempts>] )
##
##  for  the  <i>th  (or  default)  interactive  {\ACE}  process  started  by
##  `ACEStart', attempt up to <attempts> (or, in the  first  four  forms,  8)
##  times to find nontrivial subgroups with index a multiple of <subindex> by
##  repeatedly making random coset numbers coincident with coset 1 and seeing
##  what happens. The starting coset table must be non-empty, but must  *not*
##  be        complete        (use         `ACERandomlyApplyCosetCoincidence'
##  (see~"ACERandomlyApplyCosetCoincidence")  if  your   table   is   already
##  complete).  For  each   attempt,   we   repeatedly   add   random   coset
##  representatives to the subgroup and `redo' the enumeration. If the  table
##  becomes  too  small,  the  attempt  is  aborted,  the  original  subgroup
##  generators restored, and another attempt made. If  an  attempt  succeeds,
##  then   the   new   set    of    subgroup    generators    is    retained.
##  `ACERandomCoincidences' returns  the  list  of  new  subgroup  generators
##  added.  Use  `ACESubgroupGenerators'   (see~"ACESubgroupGenerators")   to
##  determine the current subgroup generator list.
##
InstallGlobalFunction(ACERandomCoincidences, function(arg)
local ioIndexAndOptval, datarec, index, sgens, lines, newsgens;
  ioIndexAndOptval := ACE_IOINDEX_AND_ONE_VALUE(arg);
  datarec := ACEData.io[ ioIndexAndOptval[1] ];
  sgens := ACE_ARGS(ioIndexAndOptval[1], "sgens");
  READ_ACE_ERRORS(datarec); # purge any output not yet collected
  if not IsBound(datarec.stats) then
    CHEAPEST_ACE_MODE(datarec);
  fi;
  index := datarec.stats.index;
  if index <> 0 then
    Error("ACERandomCoincidences: enumeration index is already finite!\n");
  fi;
  PROCESS_ACE_OPTION(datarec.stream, "rc", ioIndexAndOptval[2]);
  # Perhaps it's wasteful to use ACEReadUntil here ...
  lines := ACEReadUntil(ioIndexAndOptval[1],
                        line -> Length(line)>12 and
                                line{[1..13]} in ["* No success;",
                                                  "* An appropri",
                                                  "   finite ind",
                                                  "   * Unable t"]);
  if IsMatchingSublist(lines[Length(lines)], "* An appropri", 1) then
    datarec.enumResult := lines[Length(lines) - 1];
    datarec.stats := ACE_STATS(datarec.enumResult);
  else
    Info(InfoACE + InfoWarning, 1, "ACERandomCoincidences: Unsuccessful!");
    newsgens := Difference(ACE_ARGS(ioIndexAndOptval[1], "sgens"), sgens);
    if not IsEmpty(newsgens) then
      ACEDeleteSubgroupGenerators(ioIndexAndOptval[1], newsgens);
      Info(InfoACE + InfoWarning, 1, "Subgroup generators restored.");
    fi;
  fi;
  return Difference(ACE_ARGS(ioIndexAndOptval[1], "sgens"), sgens);
end);

#############################################################################
####
##
#F  ACERandomlyApplyCosetCoincidence( <i> [: subindex := <subindex>, 
##                                           hibound := <hibound>,
##                                           lobound := <lobound>,
##                                           attempts := <attempts>] )
#F  ACERandomlyApplyCosetCoincidence( [: subindex := <subindex>, 
##                                       hibound := <hibound>,
##                                       lobound := <lobound>,
##                                       attempts := <attempts>] )
##
##  for  the  <i>th  (or  default)  interactive  {\ACE}  process  started  by
##  `ACEStart', attempt up to <attempts> (or, by default, 8) times to find  a
##  larger proper  subgroup,  by  repeatedly  applying  `ACECosetCoincidence'
##  (see~"ACECosetCoincidence") and seeing what happens. The  starting  coset
##  table   must   already   be   complete    (use    `ACERandomCoincidences'
##  (see~"ACERandomCoincidences") if your table is not already complete).  By
##  default, `<subindex> = 1', <hibound> is the existing subgroup  index  and
##  `<lobound> = 1'. If after an attempt the  new  index  is  a  multiple  of
##  <subindex>, less than <hibound> and greater than <lobound> then  the  the
##  process terminates and  the  list  of  new  subgroup  representatives  is
##  returned. Otherwise, if an attempt reaches a  stage  where  the  criteria
##  cannot be satisfied,  the  attempt  is  aborted,  the  original  subgroup
##  generators    restored,     and     another     attempt     made.     Use
##  `ACESubgroupGenerators' (see~"ACESubgroupGenerators")  to  determine  the
##  current subgroup generator list.
##
InstallGlobalFunction(ACERandomlyApplyCosetCoincidence, function(arg)
local ioIndex, datarec, index, opt, sgens, try, trycosetrep, tries, newsgens;
  ioIndex := CallFuncList(ACEProcessIndex, arg);
  datarec := ACEData.io[ ioIndex ];
  index := ACEStats(ioIndex).index;
  if index = 0 then
    Error("ACERandomlyApplyCosetCoincidence: coset table must be complete.\n");
  fi;
  opt := rec();
  if ACE_VALUE_OPTION_ERROR(
         opt, "subindex", 1, d -> IsPosInt(d) and (index mod d = 0),
         "option `subindex' must be a positive divisor of current index"
         ) or
     ACE_VALUE_OPTION_ERROR(
         opt, "hibound", index, h -> 1 < h and h <= index,
         "option `hibound' must be > 1 and at most the current index"
         ) or
     ACE_VALUE_OPTION_ERROR(
         opt, "lobound", 1, lo -> 1 <= lo and lo < index,
         "option `lobound' must be at least 1 and less than the current index"
         ) or
     ACE_VALUE_OPTION_ERROR(
         opt, "attempts", 8, IsPosInt,
         "option `attempts' must be a positive integer"
         )
  then
     opt.onbreakmsg := ["You can only 'quit;' from here."];
     PopOptions();
     Error(ACE_ERROR(opt.errmsg, opt.onbreakmsg), "\n");
  fi;
  if opt.attempts > index - 1 then
    opt.attempts := index - 1;
  fi;

  sgens := ACESubgroupGenerators(ioIndex);
  tries := [];
  newsgens := [];
  ACERecover(ioIndex);
  while Length(tries) < opt.attempts and (datarec.stats.index >= opt.hibound) do
    repeat
      try := Random([2 .. datarec.stats.index]);
      trycosetrep := ACECosetRepresentative(ioIndex, try);
    until not(trycosetrep in tries);
    Add(tries, try);
    Add(newsgens, ACECosetCoincidence(ioIndex, try));
    Info(InfoACE, 1, "Added new subgroup gen'r:");
    Info(InfoACE, 1, "  ", newsgens[ Length(newsgens) ]);
    if datarec.stats.index <= opt.lobound or 
       (datarec.stats.index mod opt.subindex <> 0) then
      # abort
      Info(InfoACE, 1, "Subgroup index (", datarec.stats.index, ") ",
                       "has become too small ...");
      Info(InfoACE, 1, "restoring original subgroup gen'rs.");
      ACEDeleteSubgroupGenerators(ioIndex, newsgens);
      newsgens := [];
    else
      Info(InfoACE, 1, "New subgroup index = ", datarec.stats.index);
    fi;
    ACERecover(ioIndex);
  od;
  if ACEStats(ioIndex).index >= opt.hibound then
    Info(InfoACE, 1, "ACERandomlyApplyCosetCoincidence: Unsuccessful!");
  fi;
  return Difference(ACESubgroupGenerators(ioIndex), sgens);
end);

#############################################################################
####
##
#F  ACEConjugatesForSubgroupNormalClosure . .  Returns conjugates of subgroup  
##  . . . . . . . . . . . . . . . . . . . . .  generators by generators (that
##  . . . . . . . . . . . . . . . . . . . . .  can  be  determined   to   be)
##  . . . . . . . . . . . . . . . . . . . . .  needed for normal  closure  of
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  the subgroup
##
##  Tests that each conjugate of a subgroup generator by  a  group  generator
##  can be traced from coset 1 to a coset number other than coset 1, for  the
##  i-th interactive ACE process, where i is determined by arg. The  list  of
##  conjugates that were determined to belong to cosets other  than  coset  1
##  (the subgroup) is returned; and, if called with the `add'  option,  these
##  conjugates are also added to the existing list of subgroup generators.
##
InstallGlobalFunction(ACEConjugatesForSubgroupNormalClosure, function(arg)
local ACEfname, ioIndex, add, lines, line, datarec;
  ACEfname := "ACEConjugatesForSubgroupNormalClosure";
  ioIndex := CallFuncList(ACEProcessIndex, arg);
  add := ValueOption("add");
  if not IsBool(add) then
    Info(InfoACE + InfoWarning, 1,
         ACEfname, ": Expected boolean value of add option");
    Info(InfoACE + InfoWarning, 1,
         "but received: ", add, ". Ignoring ... no new generators will be.");
    Info(InfoACE + InfoWarning, 1,
         "added to the subgroup");
    add := "";
  elif add <> true then
    add := "";
  else
    add := 1;
  fi;
  lines := EXEC_ACE_DIRECTIVE_OPTION(
               [ioIndex, add], "nc", 3, "", "---------------------", true);
  if lines[Length(lines) - 1] = "* All (traceable) conjugates in subgroup" then
    Info(InfoACE + InfoWarning, 1, 
         ACEfname, ": All (traceable) conjugates in subgp");
    return [];
  elif IsMatchingSublist(lines[Length(lines) - 2], "** ERROR", 1) then
    line := lines[Length(lines) - 1];
    Error(ACEfname, ":", line{[3..Length(line)]}, "\n",
          "(most probably the value passed to ", ACEfname, 
          "\nwas inappropriate)\n");
  else
    datarec := ACEData.io[ ioIndex ];
    if add = 1 then
      CHEAPEST_ACE_MODE(datarec);
      ACE_ARGS(ioIndex, "sgens"); # Update saved subgroup generators
    fi;
    return List(Filtered(lines, 
                         line -> IsMatchingSublist(line, "Conjugate by grp") or
                                 # in case we have an old src for ACE
                                 IsMatchingSublist(line, "Grp")),
                function(line)
                  line := SplitString(line, '"');
                  return ACE_GAP_WORDS(datarec, line[4])[1]
                         ^ ACE_GAP_WORDS(datarec, line[2])[1];
                end);
  fi;
end);

#E  interact.gi . . . . . . . . . . . . . . . . . . . . . . . . .  ends here 
