runtest := function()

Print(false and 1, "\n");
Print(true or 1, "\n");
Print(function() return false and 1; end(), "\n");
Print(function() return true or 1; end(), "\n");
Print(IsAssociative and IsAssociative, "\n");

# ensure we don't abort after an error
BreakOnError := false;

# trigger error 1:
CALL_WITH_CATCH({} -> Center and IsAssociative, []);

# trigger error 2:
CALL_WITH_CATCH({} -> IsAssociative and Center, []);

CALL_WITH_CATCH({} -> 1 and false, []);
CALL_WITH_CATCH({} -> 1 or true, []);

end;
