#############################################################################
##
#W  general.gi                      FORMAT                       Bettina Eick
#W                                      conversion from GAP3 by C.R.B. Wright
##
Revision.("format/lib/general.gi") :=
    "@(#)$Id: general.gi,v 1.7 2000/10/31 17:16:29 gap Exp $";

#############################################################################
#M  PPart( <elt>, <prime> ). . . . . . . . . . . . . . . . . . . . . . .local
##  generator of <prime>-Sylow subgroup of < <elt> >

InstallMethod( PPart, "generic unnormalized", true,
[IsMultiplicativeElementWithInverse, IsPosInt], 0,
function(g, prime)
  local o, facs, x;
  
  if not IsPrimeInt( prime ) then
    Error( prime, " must be a prime in PPart.");
  fi;
  
  o := Order(g);
  if o = 1 then return g; fi;
  
  facs := Factors(o);
  x := Length(Filtered(facs, y -> y = prime));
  return g^(o/(prime^x));  # no gcd normalization as in PrimePowerComponent
end);

#############################################################################
#M  PPrimePart( <elt>, <prime> ). . . . . . . . . . . . . . . . . . . . local
##  generator of <prime>-complement of < <elt> >

InstallMethod( PPrimePart, "generic unnormalized", true,
[IsMultiplicativeElementWithInverse, IsPosInt], 0,
function(g, prime)
  local o, facs, x;
  
  if not IsPrimeInt( prime ) then
    Error( prime, " must be a prime in PPrimePart.");
  fi;
  
  o := Order(g);
  if o = 1 then return g; fi;
  
  facs := Factors(o);
  x := Length(Filtered(facs, y -> y = prime));
  return g^(prime^x);  # no gcd normalization
end);

#############################################################################
#M  PiPrimePart( <elt>, <list of primes> ). . . . . . . . . . . . . . . local
##  generator of pi-complement of < <elt> >

InstallMethod( PiPrimePart, "generic unnormalized", true,
  [IsMultiplicativeElementWithInverse, IsList], 0,
function( g, pi )
  local p, o, facs, exp;
  
  for p in pi do
    if not IsPrimeInt(p) then
      Error(pi," is not a list of primes.\n");
    fi;
  od;
   
  o := Order(g);
  if o = 1 then return g; fi;
  facs := Factors(o);
  exp := Product(Filtered(facs, p -> p in pi));
  return g^exp;
end);

#############################################################################
#F  ( G, <pcgsR>, <pcgsL>, <pcgsK> ) . . . . . . . . . . local
##  find pcgs of [<L>, <R>] * <K>

InstallGlobalFunction(FCommutatorPcgs, 
function( G, pcgsR, pcgsL, pcgsK )
  local  K, gens, Rigs, C, r, g, c, spg;
  
  ## It is assumed that L/K is abelian.
  
  K := SubgroupByPcgs( G, pcgsK );
  if Length( pcgsK ) >0 then
    gens := pcgsL mod pcgsK;
  else
    gens := pcgsL;
  fi;
  Rigs := pcgsR mod pcgsL;
  C := [];
  for r in Rigs do
    for g in gens do
      c := Comm(r, g);
      if not c in K then
        AddSet(C, c);
      fi;
    od;
  od;
  if C = [] then return pcgsK; fi;
  spg := SpecialPcgs(G);
## normalized 4-20-00. Without it, system.base may not be normalized
## and FExponents will hang in a loop.
  return NormalizedPcgs( spg, 
      InducedPcgsByPcSequenceAndGenerators( spg, pcgsK, C) );
end);

#############################################################################
#F FCentralTest( G, <pcgsR>, <pcgsL>, <pcgsK> ) . . . . . . . . .local
## check [<L>, <R>] <= <K>

InstallGlobalFunction(FCentralTest, 
function( G, pcgsR, pcgsL, pcgsK )
  local K, gens, Rigs,  r, g, c;
  
  K := SubgroupByPcgs( G, pcgsK );
  gens := pcgsL mod pcgsK;
  Rigs := pcgsR mod pcgsL;
  for r in Rigs do
    for g in gens do
      c := Comm(r, g);
      if not c in K then
        return false;
      fi;
    od;
  od;
  return true;
end);


#############################################################################
#F  FExponents( <system>, <elt>, <field>, <int>, <int> ) . . . collector info
##

InstallGlobalFunction(FExponents, 
function( system, u, F, first, next )
  local   sph, depths, expo, d, i, tmp, max, j;
  
  # catch trivial case
  if Length( system.base ) = 0 then
    return [];
  fi;
  
  # set up
  sph    := SpecialPcgs( system.H );    ## may be known already as system.sph
  max    := Length( system.base );
  
  depths := system.depths{[first..max]};
  expo   := List( [first..max], x -> 0 );
  
  # iterate
  d := DepthOfPcElement( sph, u );
  i := Position( depths, d );
  while not IsBool(i) do
    tmp := LeadingExponentOfPcElement( sph, u );
    expo[ i ] := tmp;
    u := LeftQuotient( system.base[first+i-1]^tmp , u );
    d := DepthOfPcElement( sph, u );
    i := Position( depths, d );
  od;
  
  # cut tail off
  expo := expo{[1..next-first+1]};
  
  # throw it into the correct field
  if IsFFE( One( F ))  then
    return expo * One( F );
  elif IsInt( One( F ) )  then
    return expo;
  else
    Error(One( F ), " seems not to be a field element ");;
  fi;
end);


#############################################################################
#M  GpByNiceMonomorphism( <nice>, <group> )  construct group with nice obj
##  Same as undocumented GroupByNiceMonomorphism from the library.

InstallMethod( GpByNiceMonomorphism,
    true,
    [ IsGroupHomomorphism,
      IsGroup ],
    0,

function( nice, grp )
    local   fam,  pre;

    fam := FamilyObj( Source(nice) );
    pre := Objectify(NewType(fam,IsGroup and IsAttributeStoringRep), rec());
    SetIsHandledByNiceMonomorphism( pre, true );
    SetNiceMonomorphism( pre, nice );
    SetNiceObject( pre, grp );
    SetOne(pre,One(Source(nice)));
    UseIsomorphismRelation(grp,pre);
    return pre;
end );


#############################################################################
#F  SubgpMethodByNiceMonomorphism( <oper>, <par> )
##  Same as undocumented SubgroupMethodByNiceMonomorphism from the library.

BindGlobal( "SubgpMethodByNiceMonomorphism", function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        true,
        par,
        0,
        function( obj )
            local   nice,  img,  sub;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj) );
            sub  := GpByNiceMonomorphism( nice, img );
            SetParent( sub, obj );
            return sub;
        end );
end );


#############################################################################
#F  SubgpMethodByNiceMonomorphismCollOther( <oper>, <par> )
##  Same as undocumented SubgroupMethodByNiceMonomorphismCollOther.

BindGlobal( "SubgpMethodByNiceMonomorphismCollOther",
    function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        true,
        par,
        0,
        function( obj, other )
            local   nice,  img,  sub;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj), other );
            sub  := GpByNiceMonomorphism( nice, img );
            SetParent( sub, obj );
            return sub;
        end );
end );

#E  End of general.gi
