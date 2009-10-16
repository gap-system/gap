#WARNING:  Read this with Read(), _not_ ParRead()

#Environment: None
#TaskInput:   elt, where elt is an element of argument, list
#TaskOutput:  fnc(elt), where fnc is argument
#Task:        Compute fnc(elt) from elt [ Hence, DoTask = fnc ]
#UpdateEnvironment:  None

ParInstallTOPCGlobalFunction( "MyParList",
function( list, fnc )
  local result, iter;
  result := [];
  iter := Iterator(list);
  MasterSlave( function() if IsDoneIterator(iter) then return NOTASK;
                          else return NextIterator(iter); fi; end,
               fnc,
               function(input,output) result[input] := output; 
                                      return NO_ACTION; end,
               Error
             );
  return result;
end );

ParInstallTOPCGlobalFunction( "MyParListWithAglom",
function( list, fnc, aglomCount )
  local result, iter;
  result := [];
  iter := Iterator(list);
  MasterSlave( function() if IsDoneIterator(iter) then return NOTASK;
                          else return NextIterator(iter); fi; end,
               fnc,
               function(input,output)
                 local i;
                 for i in [1..Length(input)] do
                   result[input[i]] := output[i];
                 od;
                 return NO_ACTION;
               end,
               Error,  # Never called, can specify anything
               aglomCount
             );
  return result;
end );
