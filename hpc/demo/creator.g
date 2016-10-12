Creator := function(obj)
  local result, creators;
  creators := CREATOR_OF(obj);
  result := [];
  if creators[1] <> fail then
    Add(result, NAME_FUNC(creators[1]));
    Add(result, FilenameFunc(creators[1]));
    Add(result, StartlineFunc(creators[1]));
    Add(result, creators[1]);
  fi;
  if creators[2] <> fail then
    Add(result, NAME_FUNC(creators[2]));
    Add(result, FilenameFunc(creators[2]));
    Add(result, StartlineFunc(creators[2]));
    Add(result, creators[2]);
  fi;
  return result;
end;
