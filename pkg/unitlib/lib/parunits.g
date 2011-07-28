#############################################################################
##  
#W  parunits.g             The UnitLib package            Alexander Konovalov
#W                                                            Elena Yakimenko
##
#H  $Id: parunits.g,v 1.3 2010/08/04 09:32:39 alexk Exp $
##
#############################################################################


InstallGlobalFunction( NormalizedUnitCFpower, 
function( arg )
local id, p, i, name, KG, e, wb, coef, f, fgens, w, j;
id:=arg[1][1];
p:=arg[1][2];
i:=arg[1][3];
name := Concatenation( "GroupRingOfSmallGroup", String(id[1]), "_", String(id[2]) );
if not IsBoundGlobal( name ) then
	BindGlobal( name, GroupRing( GF(p), SmallGroup(id) ) );
fi;
KG := EvalString( name );
e := One( KG );
wb := WeightedBasis( KG );
f := FreeGroup( Length(wb.weightedBasis) );
fgens := GeneratorsOfGroup( f );
coef := NormalizedUnitCF( KG, (wb.weightedBasis[i]+e)^p );
w := One( f );
for j in [1..Length(coef)] do
  if not coef[j]=0 then
    w := w*fgens[j]^IntFFE(coef[j]);
  fi;
od;
if w=One(f) then 
	w := "";
else
	w := String(w);
fi;	
return [ i, w ];
end);


InstallGlobalFunction( NormalizedUnitCFcommutator,
function( arg )
local id, p, i, j, name, KG, e, wb, coef, f, fgens, w, k;
id:=arg[1][1];
p:=arg[1][2];
i:=arg[1][3];
j:=arg[1][4];
name := Concatenation( "GroupRingOfSmallGroup", String(id[1]), "_", String(id[2]) );
if not IsBoundGlobal( name ) then
	BindGlobal( name, GroupRing( GF(p), SmallGroup(id) ) );
fi;
KG := EvalString( name );
e := One( KG );
wb := WeightedBasis( KG );
f := FreeGroup( Length(wb.weightedBasis) );
fgens := GeneratorsOfGroup( f );
coef := NormalizedUnitCF( KG, Comm( wb.weightedBasis[i]+e, wb.weightedBasis[j]+e ) );
w := One( f );
for k in [1..Length( coef )] do
  if not coef[k]=0 then
    w := w*fgens[k]^IntFFE(coef[k]);
  fi;
od;
if w=One(f) then 
	w := "";
else
	w := String(w^-1);
fi;	
return [ j, i, w ];
end);


InstallGlobalFunction( ParPcNormalizedUnitGroup,
function( KG ) 
    local id, i, j, e, wb, lwb, f, rels, rels1, rels2, fgens, w, 
          listargs, coeffs, res, coef, k, U, z, p, t, coll, r;

	id := IdGroup( UnderlyingGroup( KG ) );
	
    if not IsPrime(Size(LeftActingDomain(KG))) then
      TryNextMethod();
    else           
      Info(LAGInfo, 2, "LAGInfo: Computing the pc normalized unit group ..." );
         
      e := One( KG );
      z := Zero( LeftActingDomain( KG ) );
      p := Characteristic( LeftActingDomain( KG ) );
         
      wb := WeightedBasis( KG );
      lwb := Length(wb.weightedBasis);
         
      f := FreeGroup( lwb );
      fgens := GeneratorsOfGroup( f );
      AssignGeneratorVariables( f );
      # rels := [ ];

      coll:=SingleCollector( f, List( [1 .. lwb ], i -> p ) );
      # TODO: Understand why CombinatorialCollector does not work?
    
      Info(LAGInfo, 3, "LAGInfo: relations for ", lwb,
                       " elements of weighted basis");     
                       
      listargs := List( [1..lwb], i -> [ id, p, i ] );                     
      rels1 := ParListWithSCSCP( listargs, "NormalizedUnitCFpower" );

      for i in [ 1 .. Length(rels1) ] do
          if rels1[i][2] = "" then
          		r := One(f);
          else 
          		r := EvalString( rels1[i][2] );
          fi;				
          SetPower( coll, rels1[i][1], r );
      od;
      
      Info(LAGInfo, 3, "LAGInfo: commutators for ", lwb, 
                       " elements of weighted basis");     

      if IsCommutative(KG) then

        for i in [1..lwb-1] do
          for j in [i+1..lwb] do
            # Add( rels, Comm( fgens[i],fgens[j] ) );
            SetCommutator( coll, j, i, One(f) );
          od;
        od;
      
      else  
      
        listargs := Concatenation( List( [ 1 .. lwb-1 ], i -> 
                                         List( [ i+1 .. lwb ], j -> 
                                               [ id, p, i, j ] ) ) );  
                                               
        rels2 := ParListWithSCSCP( listargs, "NormalizedUnitCFcommutator" );     

        for i in [ 1 .. Length(rels2) ] do
        	if rels2[i][3] = "" then
          		r := One(f);
          	else 
          		r := EvalString( rels2[i][3] );
          	fi;
            SetCommutator( coll, rels2[i][1], rels2[i][2], r );
		od;

      fi;
           
      Info(LAGInfo, 2, "LAGInfo: finished, converting to PcGroup" );

      U:=GroupByRwsNC(coll); # before we used U:=PcGroupFpGroup( f/rels );
      SetIsGroupOfUnitsOfMagmaRing(U,false);
      SetIsNormalizedUnitGroupOfGroupRing(U,true);
      SetIsPGroup(U, true);
      SetUnderlyingGroupRing(U,KG);     
      return U;
    fi;
end);


#############################################################################
#
# ParSavePcNormalizedUnitGroup( G )
#
InstallGlobalFunction( ParSavePcNormalizedUnitGroup,
function( G )
local p, K, KG, V, codestring, libfile, output, d, x;
if not IsPGroup( G ) then
  Error( "<G> is not a p-group !!! \n" );
fi;
if Size(G) <= 243 then
  Print( "WARNING : the normalized unit group V(KG) of the modular group algebra \n",
         " of the given group <G> is already included in the library and \n", 
	 "You can access it using the function PcNormalizedUnitGroupSmallGroup.\n",
	 "The description you are going to generate will be stored in the directory \n",
	 "unitlib/userdata, but will be not used by PcNormalizedUnitGroupSmallGroup. \n" );
fi;
p := PrimePGroup( G );
K := GF( p );
KG:= GroupRing( K, G );
V := ParPcNormalizedUnitGroup( KG );
codestring := HexStringInt( CodePcGroup( V ) );
libfile := Concatenation( 
             GAPInfo.PackagesInfo.( "unitlib" )[1].InstallationPath,
             "/userdata/u",
             String( IdGroup( G )[1] ), "_",
             String( IdGroup( G )[2] ), ".g");
output := OutputTextFile( libfile, false );
SetPrintFormattingStatus( output, false );
PrintTo(  output, "return [ " );
AppendTo( output, "\042", codestring, "\042" );
AppendTo( output, ", ");
AppendTo( output, [ List( DimensionBasis( G ).dimensionBasis, ExtRepOfObj), 
                    DimensionBasis( G ).weights ] );
AppendTo( output, " ];" );
CloseStream( output );
return true; 
end );