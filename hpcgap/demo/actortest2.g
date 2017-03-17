MakeThreadLocal("MyCounter");

actor := StartActor( rec(
  _Init := function() MyCounter := 0; end,
  _AtExit := function() Display(MyCounter); Unbind(MyCounter); end,
  Inc := function() MyCounter := MyCounter + 1; end,
  Dec := function() MyCounter := MyCounter - 1; end,
  Finish := function() ExitActor(); end
) );

# The following calls are asynchronous rather than synchronous
# and return immediately; they will be executed when the actor
# receives the underlying message.

actor.Inc();
actor.Inc();
actor.Dec();
actor.Finish();
