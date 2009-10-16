
S := SpaceGroupIT(2,7);
P := PointGroup(S);
N := NormalizerInGLnZ(P);
gen := Filtered( GeneratorsOfGroup(N), x -> not x in P );
n := AugmentedMatrix( gen[1], [1/5,1/7] );
S2 := S^n;

c := ConjugatorSpaceGroupsStdSamePG( S, S2 );;
S^c=S2;

c := ConjugatorSpaceGroupsStdSamePG( S2, S );;
S2^c=S;

C1 := AugmentedMatrix( RandomInvertibleMat(2), [1/5,1/7] );
C2 := AugmentedMatrix( RandomInvertibleMat(2), [1/9,1/13] );

S1 := S^C1; IsSpaceGroup(S1);
S2 := S^C2; IsSpaceGroup(S2);
C  := ConjugatorSpaceGroups( S1, S2 );
S1^C = S2;

