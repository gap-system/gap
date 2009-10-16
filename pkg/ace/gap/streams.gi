#############################################################################
####
##
#W  streams.gi                 ACE Package                        Greg Gamble
##
##  This file installs non-user functions used in interactions with streams.
##    
#H  @(#)$Id: streams.gi,v 1.14 2006/01/26 16:11:31 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Information Technology & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.("ace/gap/streams_gi") :=
    "@(#)$Id: streams.gi,v 1.14 2006/01/26 16:11:31 gap Exp $";


#############################################################################
####
##
#F  ACE_PRINT_AND_EVAL( <varname>, <expr> ) . . . print and evaluate a string
##
##  emulates a user typing at the `gap> ' prompt: `<varname> := <expr>;'  and
##  prints and returns the evaluation of <expr>; <varname> and <expr>  should
##  be strings.
##
InstallGlobalFunction(ACE_PRINT_AND_EVAL, function(varname, expr)

  Print("gap> ", varname, " := ", ReplacedString(expr, "\n ", "\n>"), ";\n");
  expr := EvalString(expr);
  Print(expr, "\n");
  return expr;
end);

#############################################################################
####
##
#F  ACE_READ_NEXT_LINE(<iostream>) . read complete line but never return fail
##
##  We know there is a complete line to be got; so we  wait  for  it,  before
##  returning.
##
InstallGlobalFunction(ACE_READ_NEXT_LINE, function(iostream)
  return ReadAllLine(iostream, true);
end);

#############################################################################
####
##
#F  FLUSH_ACE_STREAM_UNTIL(<iostream>, <infoLevelFlushed>, <infoLevelMyLine>,
##    <readline>, <IsMyLine>) . . . . . . flush a stream until a desired line
##
##  reads lines in iostream <iostream> via function  <readline>  and  `Info's
##  those lines at `InfoACELevel' <infoLevelFlushed> until a line <line>  for
##  which `<IsMyLine>(<line>) is `true'. The line <line> is then `Info'-ed at
##  `InfoACELevel' <infoLevelMyLine> and returned.
##
InstallGlobalFunction(FLUSH_ACE_STREAM_UNTIL, 
function(iostream, infoLevelFlushed, infoLevelMyLine, readline, IsMyLine)
local line;

  line := readline(iostream);
  while not IsMyLine(line) do
    Info(InfoACE, infoLevelFlushed, Chomp(line));
    line := readline(iostream);
  od;
  if line <> fail and infoLevelMyLine < 10 then
    Info(InfoACE, infoLevelMyLine, Chomp(line));
  fi;
  return line;
end);

#############################################################################
####
##
#F  WRITE_LIST_TO_ACE_STREAM( <stream>, <list> ) . . . write to an ACE stream
##
##  writes the list <list> to the iostream <stream>, `Info's <list> following
##  a `ToACE> ' ``prompt'' at `InfoACE' level 4, returns `true' if successful
##  or `fail' otherwise.
##
InstallGlobalFunction(WRITE_LIST_TO_ACE_STREAM, function(stream, list)
local string;

  if not IsOutputTextStream(stream) and IsEndOfStream(stream) then
    Info(InfoACE + InfoWarning, 1, "Sorry. Process stream has died!");
    Info(InfoACE + InfoWarning, 1, 
         "You might like to try using 'ACEResurrectProcess(<i>);'");
    return fail;
  fi;
  string := Concatenation( List(list, String) );
  Info(InfoACE, 4, "ToACE> ", string);
  return WriteLine(stream, string);
end);

#E  streams.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
