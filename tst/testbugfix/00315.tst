#2015/10/20 (Chris Jefferson)
gap> extS := ExternalSet(SymmetricGroup(4), [1..4],
>                   GeneratorsOfGroup(SymmetricGroup(4)),
>                   GeneratorsOfGroup(SymmetricGroup(4)),
>                   OnRight);
<xset:[ 1 .. 4 ]>
gap> ExternalSubset(extS);
[  ]^G
