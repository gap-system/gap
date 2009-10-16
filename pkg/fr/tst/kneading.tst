################################################################
## test kneading groups
################################################################
ee := 1; ff := 1; gg := 1;

testpre := function(f,g,n)
  ee := Enumerator(g){[1..n]};
  return First(ee,x->ImageElm(f,PreImagesRepresentative(f,x))<>x);
end;

testimg := function(f,g,n)
  ee := Enumerator(g){[1..n]};
  return First(ee,x->PreImageElm(f,ImageElm(f,x))<>x);
end;

test := function(s,t)
  local r;
  gg := BinaryKneadingGroup(s,t);
  ff := IsomorphismFpSubgroup(gg);
  AssignGeneratorVariables(Parent(Range(ff)));
  r := InputTextString(Concatenation(String(RelatorsOfFpGroup(Parent(Range(ff)))),";"));
  ee := READ_COMMAND(r,false);
  CloseStream(r);
  return List(ee,x->PreImageElm(ff,x));
end;

