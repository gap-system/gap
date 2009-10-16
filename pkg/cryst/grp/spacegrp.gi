#############################################################################
##
#A  spacegrp.gi               Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Extraction functions for IT space groups
##

#############################################################################
##
#M  SpaceGroupSettingsIT . . . . . . . .available settings of IT space groups
##
InstallGlobalFunction( SpaceGroupSettingsIT, function( dim, nr )
   if   dim = 2 then
      if nr in [1..17] then
         return List( RecNames( SpaceGroupList2d[nr] ), x -> x[1] );
      else
         Error( "space group number must be in [1..17]" );
      fi;
   elif dim = 3 then
      if nr in [1..230] then
         return List( RecNames( SpaceGroupList3d[nr] ), x -> x[1] );
      else
         Error( "space group number must be in [1..230]" );
      fi;
   else
      Error( "only dimensions 2 and 3 are supported" );
   fi;
end );

#############################################################################
##
#M  SpaceGroupDataIT . . . . . . . . . . . data extractor for IT space groups
##
InstallGlobalFunction( SpaceGroupDataIT, function( r )

   local settings;

   if   r.dim = 2 then
      if r.nr in [1..17] then
         if IsBound( r.setting ) and r.setting <> '1' then
            Error( "requested setting is not available" );
         fi;
         r.setting := '1';
         return SpaceGroupList2d[r.nr].1;
      else
         Error( "in 2d, space group number must be in [1..17]" );
      fi;
   elif r.dim = 3 then
      if r.nr in [1..230] then
         settings := SpaceGroupSettingsIT( 3, r.nr );
         if IsBound( r.setting ) then
            if r.setting in settings then
               return SpaceGroupList3d[r.nr].([r.setting]);
            else
               Error( "requested setting is not available" );
            fi;
         else
            if 'b' in settings then
               r.setting := 'b';
               return SpaceGroupList3d[r.nr].b;
            elif '2' in settings then
               r.setting := '2'; 
               return SpaceGroupList3d[r.nr].2;
            elif 'h' in settings then
               r.setting := 'h'; 
               return SpaceGroupList3d[r.nr].h;
            else
               r.setting := '1';
               return SpaceGroupList3d[r.nr].1;
            fi;
         fi;
      else
         Error( "space group number must be in [1..230]" );
      fi;
   else
      Error( "only dimensions 2 and 3 are supported" );
   fi;
end );

#############################################################################
##
#M  SpaceGroupFunIT . . . . . . . . . constructor function for IT space group
##
InstallGlobalFunction( SpaceGroupFunIT, function( r )
   local data, gens, vec, name, norm, S, P, N;
   data := SpaceGroupDataIT( r );
   gens := ShallowCopy( data.generators );
   for vec in data.basis do
      Add( gens, AugmentedMatrix( IdentityMat( r.dim ), vec ) );
   od;
   if r.action = LeftAction then
      gens := List( gens, TransposedMat );
      norm := List( data.normgens, TransposedMat );
      name := "SpaceGroupOnLeftIT(";
      S := AffineCrystGroupOnLeftNC( gens, IdentityMat( r.dim+1 ) );
   else
      norm := data.normgens;
      name := "SpaceGroupOnRightIT(";
      S := AffineCrystGroupOnRightNC( gens, IdentityMat( r.dim+1 ) );
   fi;
   AddTranslationBasis( S, data.basis );
   SetName( S, Concatenation( name, String(r.dim), ",", String(r.nr),
                              ",'", [r.setting], "')" ) );
   P := PointGroup( S );
   N := GroupByGenerators( norm, One(P) );
   SetSize( N, data.normsize );
   SetNormalizerPointGroupInGLnZ( P, N );
   if data.basis = One(P) then
      SetNormalizerInGLnZ( P, N );
   fi;
   return S;
end );

#############################################################################
##
#M  SpaceGroupOnRightIT . . . . . . . .constructor for IT space group OnRight
##
InstallGlobalFunction( SpaceGroupOnRightIT, function( arg )
   local r;
   r := rec( dim := arg[1], nr := arg[2], action := RightAction );
   if IsBound( arg[3] ) then
      r.setting := arg[3];
   fi;
   return SpaceGroupFunIT( r );
end );

#############################################################################
##
#M  SpaceGroupOnLeftIT . . . . . . . . .constructor for IT space group OnLeft
##
InstallGlobalFunction( SpaceGroupOnLeftIT, function( arg )
   local r;
   r := rec( dim := arg[1], nr := arg[2], action := LeftAction );
   if IsBound( arg[3] ) then
      r.setting := arg[3];
   fi;
   return SpaceGroupFunIT( r );
end );

#############################################################################
##
#M  SpaceGroupIT . . . . . . . . . . . . . . . constructor for IT space group
##
InstallGlobalFunction( SpaceGroupIT, function( arg )
   local r;
   r := rec( dim := arg[1], nr := arg[2], action := CrystGroupDefaultAction );
   if IsBound( arg[3] ) then
      r.setting := arg[3];
   fi;
   return SpaceGroupFunIT( r );
end );


