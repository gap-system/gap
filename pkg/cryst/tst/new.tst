
   C := SpaceGroupIT( 3, 133 );
   m := IdentityMat(4);
   C^m;

   C := SpaceGroupIT( 3, 133 );
   P := PointGroup( C );
   NormalizerInGLnZ( P );

   S := SpaceGroupBBNWZ( 4, 29, 7, 2, 1 );
   S := WyckoffStabilizer(WyckoffPositions(S)[1]);
   cl := ConjugacyClasses(S);
   Size( cl[1] );

   G := SpaceGroupBBNWZ( 4, 29, 7, 2, 1 );
   H := MaximalSubgroupRepsTG( G )[4];
   C := ColorGroup( G, H );
   ColorPermGroup( C );

   P := PointGroup( C );
   IsColorGroup( P );










