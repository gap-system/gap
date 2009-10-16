
DeclareInfoClass("InfoRecog");

DeclareRCAttribute("IsAbsIrred");

# TODO:  should these be rather proper attributes?
DeclareRCAttribute("IsSLContained");
DeclareRCAttribute("IsSymplecticGroup");
DeclareRCAttribute("IsUnitaryGroup");

InstallRCDeduction(IsAbsIrred,function(INF)
  if IsAbsIrred(INF)=false then
    SetzIsSLContained(INF,false);
    SetzIsSymplecticGroup(INF,false);
    SetzIsUnitaryGroup(INF,false);
  fi;
end);

