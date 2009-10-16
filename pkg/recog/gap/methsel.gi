#############################################################################
##
##  methsel.gi            recog package                   Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Our own method selection.
##
##  $Id: methsel.gi,v 1.4 2006/10/10 16:30:47 gap Exp $
##
#############################################################################

#
# A method is described by a record with the following components:
#  method     : the function itself
#  rank       : an integer rank
#  stamp      : a string describing the method uniquely
#  comment    : an optional comment to describe the method for humans
#  
# A database of methods is just a list of such records.
#
# Data for the method selection process is collected in another record
# with the following components:
#   falsemethods  : a record where each method that did not succeed
#                   left its stamp
#   failedmethods : a record where each method that failed temporarily
#                   left its stamp
#   successmethod : the stamp of the successful method in the end
#   tolerance     : last value of tolerance counter, see below
#   result        : either fail or true
#
# Add a method to a database with "AddMethod" and call a method from a
# database with "CallMethods".
#
InstallGlobalFunction( "AddMethod", function(arg)
  # First argument is the method database, second is the method itself,
  # third is the rank, fourth is the stamp. An optional 5th argument is
  # the comment.
  local comment,db,i,l,mr,p;
  if Length(arg) < 4 or Length(arg) > 5 then
      Error("Usage: AddMethod(database,method,rank,stamp [,comment] );");
  fi;
  db := arg[1];
  mr := rec(method := arg[2],rank := arg[3],stamp := arg[4]);
  if Length(arg) = 5 then
      mr.comment := arg[5];
  else
      mr.comment := "";
  fi;
  l := Length(db);
  p := First([1..l],i->db[i].rank <= mr.rank);
  if p = fail then
      Add(db,mr);
  else
      for i in [l,l-1..p] do
          db[i+1] := db[i];
      od;
      db[i] := mr;
  fi;
end);

# A constant:
InstallValue( NotApplicable, "NotApplicable" );

InstallGlobalFunction( "CallMethods", function(arg)
  # First argument is a record that describes the method selection process.
  # Second argument is a number, the tolerance limit.
  # All other arguments are handed through to the methods.

  local i,methargs,ms,result,tolerance,tolerancelimit,db;

  if Length(arg) < 2 then
      Error("CallMethods needs at least two arguments!");
  fi;
  db := arg[1];
  ms := rec(failedmethods := rec(), falsemethods := rec());
  tolerancelimit := arg[2];
  methargs := arg{[3..Length(arg)]};
  
  # Initialize record:
  tolerance := 0;    # reuse methods that failed that many times
  repeat   # a loop to try all over again with higher tolerance
      i := 1;
      while i <= Length(db) do
          if not(IsBound(ms.falsemethods.(db[i].stamp))) and
             (not(IsBound(ms.failedmethods.(db[i].stamp))) or
              ms.failedmethods.(db[i].stamp) <= tolerance) then

              # We try this one:
              Info(InfoMethSel,3,"Calling  rank ",db[i].rank,
                       " method \"", db[i].stamp,"\"...");
              result := CallFuncList(db[i].method,methargs);
              if result = false then
                  Info(InfoMethSel,3,"Finished rank ",db[i].rank,
                       " method \"", db[i].stamp,"\": false.");
                  ms.falsemethods.(db[i].stamp) := 1;
                  i := 1;    # start all over again
              elif result = fail then
                  Info(InfoMethSel,2,"Finished rank ",db[i].rank,
                       " method \"", db[i].stamp,"\": fail.");
                  if IsBound(ms.failedmethods.(db[i].stamp)) then
                      ms.failedmethods.(db[i].stamp) :=
                          ms.failedmethods.(db[i].stamp) + 1;
                  else
                      ms.failedmethods.(db[i].stamp) := 1;
                  fi;
                  i := 1;    # start all over again
              elif result = NotApplicable then
                  Info(InfoMethSel,3,"Finished rank ",db[i].rank,
                       " method \"", db[i].stamp,"\": not applicable.");
                  i := i + 1;   # just try the next one
              else    # otherwise we have a result
                  Info(InfoMethSel,2,"Finished rank ",db[i].rank,
                       " method \"", db[i].stamp,"\": success.");
                  ms.successmethod := db[i].stamp;
                  ms.result := result;
                  ms.tolerance := tolerance;
                  return ms;
              fi;
          else
              Info(InfoMethSel,4,"Skipping rank ",db[i].rank," method \"",
                   db[i].stamp,"\".");
              i := i + 1;
          fi;
      od;
      # Nothing worked, increase tolerance:
      Info(InfoMethSel,1,"Increasing tolerance to ",tolerance);
      tolerance := tolerance + 1;
  until tolerance > tolerancelimit;
  Info(InfoMethSel,1,"Giving up!");
  ms.result := fail;
  ms.tolerance := tolerance;
  return ms;
end);

