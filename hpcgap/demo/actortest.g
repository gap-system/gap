# Simple actor test

handlers := rec(
  _Init := function()
    Display(CurrentThread());
    Display("Hello, world!");
  end,

  _AtExit := function()
    Display(CurrentThread());
    Display("Goodbye, world!");
  end,

  print := function(x)
    Display(x);
  end,

  finish := function()
    ExitActor();
  end
);
actor := StartActor(handlers);
actor.print("a");
actor.print("b");
actor.print("c");
actor.print([1,2,3]);
actor.finish();
actor.print("should not be displayed");
