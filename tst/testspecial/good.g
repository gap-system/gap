Print("All is well\n");
# Mess with lvl to check that it doesn't affect the execution context elsewhere.
lvl := 42;
Unbind(lvl);
