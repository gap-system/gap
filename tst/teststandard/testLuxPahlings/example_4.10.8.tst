#@local ct, ctmod3, projectives, t, ctn2, ctf, ctfprojectives
######################################################################
gap> START_TEST( "example_4.10.8.tst" );

######################################################################
gap> ct := CharacterTable("M11");;  ctmod3 := ct mod 3;;
gap> projectives := Irr(ct) * DecompositionMatrix(ctmod3);;

######################################################################
gap> t := TableOfMarks("M11");;
gap> ctn2 := CharacterTable( RepresentativeTom(t,26) ) ;;

######################################################################
gap> ctf:=CharacterTable(RepresentativeTom(t,26)/RepresentativeTom(t,3));;
gap> ctfprojectives := Irr(ctf)* DecompositionMatrix( ctf mod 3 );;
gap> SortedList( ctfprojectives );
[ VirtualCharacter( CharacterTable( Group([ f1, f2, f3 ]) ),
  [ 3, -1, -1, 0, 3, 0 ] ), VirtualCharacter( CharacterTable( Group(
    [ f1, f2, f3 ]) ), [ 3, -1, 1, 0, -3, 0 ] ), 
  VirtualCharacter( CharacterTable( Group([ f1, f2, f3 ]) ),
  [ 3, 1, -1, 0, -3, 0 ] ), VirtualCharacter( CharacterTable( Group(
    [ f1, f2, f3 ]) ), [ 3, 1, 1, 0, 3, 0 ] ) ]

######################################################################
gap> STOP_TEST( "example_4.10.8.tst" );
