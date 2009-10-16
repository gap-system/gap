##############################################################################
##                                                                          ##
#I This is the declaration file for the constructive recognition package of ##
## black box classical groups.                                              ##
##                                                                          ##
############################################################################## 

IsBBGpElm := NewCategory ("IsBBGpElm", IsMultiplicativeElementWithInverse);
IsBBGpElmColl := CategoryCollections (IsBBGpElm);

IsPermBBGpElm := NewCategory ("IsPermBBGpElm", IsBBGpElm);
IsPermBBGpElmColl := CategoryCollections (IsPermBBGpElm);

IsNaturalPermBBGpElm := NewCategory ("IsNaturalPermBBGpElm", IsBBGpElm);
IsNaturalPermBBGpElmColl := CategoryCollections (IsNaturalPermBBGpElm);

IsMatrixBBGpElm := NewCategory ("IsMatrixBBGpElm", IsBBGpElm);
IsMatrixBBGpElmColl := CategoryCollections (IsMatrixBBGpElm);

### PAB 2-10-04  (more generally, we can implement quotient groups wherever we have
### an efficient membership test, but $p$-core is all we need for now...)
IsPQuotientBBGpElm := NewCategory ("IsPQuotientBBGpElm", IsBBGpElm);
IsPQuotientBBGpElmColl := CategoryCollections (IsPQuotientBBGpElm);

IsBBGp := IsGroup and IsBBGpElmColl;
IsPermBBGp := IsBBGp and IsPermBBGpElmColl;
IsNaturalPermBBGp := IsBBGp and IsNaturalPermBBGpElmColl;
IsMatrixBBGp := IsBBGp and IsMatrixBBGpElmColl;

### PAB 2-10-04
IsPQuotientBBGp := IsBBGp and IsPQuotientBBGpElmColl;

GpAsBBGp := NewOperation("GpAsBBGp", [IsGroup]);
BBGpAsPQuotientBBGp := NewOperation("BBGpAsPQuotientBBGp", [IsBBGp, IsInt]);
SubGpAsBBGp := NewOperation("SubGpAsBBGp", [IsBBGp, IsList]);



#############################################################################
##
#A Chain ( <bbgroup> )
##
## A Black Box Group will only have this attribute if it was constructed from
## a permutation group. The information that it contains is necessary for
## better pseudorandom elements.

Chain := NewAttribute("Chain", IsPermBBGp);
SetChain := Setter (Chain);
HasChain := Tester (Chain);


###########################################################################
##
## NaturalFlag is set true in a permutation group if it has to be converted
## to a black box group with natural group operations

NaturalFlag := NewProperty("NaturalFlag", IsPermBBGp);
SetNaturalFlag := Setter (NaturalFlag);
HasNaturalFlag := Tester (NaturalFlag);
         
#############################################################################
##
#F  PermInverseBBGp( <chain>, <perm> ) . . . . inverse in permutation bb group
##
##  given a list <perm> of permutations and a stabilizer chain <chain> for
##  the group $G$, the routine computes the inverse of perm as a list.

PermInverseBBGp := function (chain, perm)
local   i,          # loop variable
        y,          # element of permutation domain
        word,       # the list collecting the siftee of perm
        len,        # length of word
        inverse,    # the inverse of perm as a word; output
        len2,       # length of inverse
        coset,      # word representing a coset in a stabilizer
        stb;        # the stabilizer group we currently work with

    # perm must be a list of permutations itself!
    inverse := [];
    stb :=  chain;
    word := ShallowCopy(perm);
    while IsBound(stb.stabilizer) do
       y:=ImageInWord(stb.orbit[1],word);
       coset :=  CosetRepAsWord(stb.orbit[1],y,stb.transversal);
       len := Length(word);
       len2 := Length(inverse);
       for i in [1..Length(coset)] do
          word[len+i] := coset[i];
          inverse[len2+i] := coset[i];
       od;
       stb:=stb.stabilizer;
    od;
return inverse;
end;


##############################################################################
##
#F PermAltProd ( <chain> , <x> , <y> ) . . . inverse of x*y
##

PermAltProd := function (chain, x, y)
local   concat,     # concatenation of the input words
        inverse,    # the inverse of concat as a word 
        product;    # the inverse of inverse as a word; output
    # x,y must be lists of permutations themselves!
    concat := Concatenation(x,y);
    inverse := PermInverseBBGp( chain, concat );
return(inverse);
end; 


#############################################################################
##
#F  PermProductBBGp( <chain>, <x>, <y> ) . . . . product in permutation bb group
##
##  given lists <x> and <y> of permutations and a stabilizer chain <chain> for
##  the group $G$, the routine computes xy as a list.

PermProductBBGp := function (chain, x, y)
local   inverse,    # the inverse of concat as a word 
        product;    # the inverse of inverse as a word; output

    # x,y must be lists of permutations themselves!
    inverse:=PermAltProd(chain,x,y);
    product := PermInverseBBGp( chain, inverse );
return product;
end;

    
############################################################################
##
#F PermEqualsBBGp( <chain> , <x> , <y> )
##
## For two strings, we test equality by tracing base images.

PermEqualsBBGp:=function( chain , x , y )
local stb;
    stb:=chain;    
    while IsBound(stb.stabilizer) do
      if not ImageInWord(stb.orbit[1],x)=ImageInWord(stb.orbit[1],y) then
           return(false);
      fi;
      stb:=stb.stabilizer;
    od;    
return(true);
end;

##############################################################################
##
#F PQuotientEqualsBBGp( <bbg> , <p> , <x> , <y> )
##
## PAB: 02-12-04
## this test presumes that the $p$-core of <gp> is nilpotent class-2:
## in particular, it covers the setting we 
## are interested in, namely extraspecial $p$-groups

PQuotientEqualsBBGp := function (gp, p, x, y)
local  w, gens, conj, comm, ord, i, j, equal, u, v, z, o, one, central;
   w:=x*Inverse(y);
      ## first test whether <w> has order dividing <p>( 2 , <p> )
   one:=One(gp);
   ord:=p*Gcd(p,2);
   o:=w^ord;

   if not ( o![1]=one![1] ) then return false; fi;

   gens:=GeneratorsOfGroup( gp );
   if ( Length(gens) < 11 ) then
       conj:=List( gens, x->w^x );
   else
       conj:=List( [1..10], i->w^PseudoRandom(gp) );
   fi;
   comm:=[];
   for i in [1..Length(conj)] do
      for j in [i+1..Length(conj)] do
         Add( comm, Comm( conj[i] , conj[j] ) );
      od;
   od;

   equal:=true;
      ## first ensure the elements of <comm> have order dividing <p>(2,<p>)
   for z in comm do
      o:=z^ord;
      equal := equal and (o![1]=one![1]);
         ## here we just want to test whether the underlying elements
	 ## are equal -- essentially this is just testing equality in
	 ## the original bb group, not the quotient.
   od;
   if (not equal) then return false; fi;
   for u in conj do
      for z in comm do
         v:=Comm(u,z);
         equal := equal and (v![1]=one![1]);
      od;
   od;

if ( equal ) then  ## want to detect whenever we have a noncentral element
     central:=true;
     for z in comm do
        central:=central and (z![1]=one![1]);
     od;
     if ( not central ) then   ## we have found our non-central element
Error(999);
     fi;
fi;

return equal;
end;

##############################################################################
##
#F EqualsModPCore( <bbg> , <p> , <x> , <y> )
##
## PAB: 02-16-04
## This test presumes that the $p$-core of <bbg> is nilpotent class-2.
## In particular, it covers the setting we are interested in: extraspecial $p$-groups
## The procedure is exactly as in <PQuotientEqualsBBGp> except the output is either
## a flag ( <true> or <false> ) or a black box group elements (a non-central element
## of the $p$-core of <bbg>

EqualsModPCore := function (gp, p, x, y)
local  w, gens, conj, comm, ord, i, j, equal, u, v, z, o, one, central;
   w:=x*Inverse(y);
      ## first test whether <w> has order dividing <p>( 2 , <p> )
   one:=One(gp);
   ord:=p*Gcd(p,2);
   o:=w^ord;

   if not ( o![1]=one![1] ) then return false; fi;

   gens:=GeneratorsOfGroup( gp );
   if ( Length(gens) < 11 ) then
       conj:=List( gens, x->w^x );
   else
       conj:=List( [1..10], i->w^PseudoRandom(gp) );
   fi;
   comm:=[];
   for i in [1..Length(conj)] do
      for j in [i+1..Length(conj)] do
         Add( comm, Comm( conj[i] , conj[j] ) );
      od;
   od;

   equal:=true;
      ## first ensure the elements of <comm> have order dividing <p>(2,<p>)
   for z in comm do
      o:=z^ord;
      equal := equal and (o![1]=one![1]);
         ## here we just want to test whether the underlying elements
	 ## are equal -- essentially this is just testing equality in
	 ## the original bb group, not the quotient.
   od;
   if (not equal) then return false; fi;
   for u in conj do
      for z in comm do
         v:=Comm(u,z);
         equal := equal and (v![1]=one![1]);
      od;
   od;

  if ( equal ) then  ## want to detect whenever we have a noncentral element
     central:=true;
     for z in comm do
        central:=central and (z![1]=one![1]);
     od;
     if ( not central ) then   ## we have found our non-central element
        return w;
     fi;
  fi;
return equal;
end;

################################################################################
##
#F BBGpElmFromList( <family> , <list> )
##

BBGpElmFromList := function (elmfam, list)
return Objectify (elmfam!.defaultType, [list]);
end;



##############################################################################
##
#M  GpAsBBGp ( <perm group> )
##
InstallMethod(GpAsBBGp, "perm group -> black box group", true, [IsPermGroup],0,
function(grp)
local elmfam,gens,i,G;
  elmfam:=NewFamily("elements family of bbg",IsObject,IsPermBBGpElm);
  elmfam!.defaultType :=NewType(elmfam,
                                IsPermBBGpElm and IsPositionalObjectRep);

  # now tell the elements family about the underlying permutation group
  elmfam!.stabChainGroup:=StabChain(grp);

  SetOne(elmfam,BBGpElmFromList(elmfam,[One(grp)]));
  # make black box group elements from the permutation generators
  gens:=[];
  for i in GeneratorsOfGroup(grp) do
    Add(gens,BBGpElmFromList(elmfam,[i]));
  od;

  G:=GroupWithGenerators(gens,BBGpElmFromList(elmfam,[One(grp)]));
  SetChain(G,StabChain(grp));
return G;
end);

##############################################################################
##
#M  GpAsBBGp ( <perm group> )
##
InstallMethod(GpAsBBGp, "perm group -> black box group w/ natural operations",
 true, [IsPermGroup and NaturalFlag],0,
function(grp)
local elmfam,gens,i,G;
  elmfam:=NewFamily("elements family of bbg",IsObject,IsNaturalPermBBGpElm);
  elmfam!.defaultType :=NewType(elmfam,
                              IsNaturalPermBBGpElm and IsPositionalObjectRep);
  SetOne(elmfam,BBGpElmFromList(elmfam,One(grp)));
  # make black box group elements from the perm group generators
  gens:=[];
  for i in GeneratorsOfGroup(grp) do
    Add(gens,BBGpElmFromList(elmfam,i));
  od;

  G:=GroupWithGenerators(gens,BBGpElmFromList(elmfam,One(grp)));
return G;
end);


##############################################################################
##
#M  GpAsBBGp ( <matrix group> )
##
InstallMethod(GpAsBBGp, "matrix group -> black box group", true, [IsMatrixGroup],0,
function(grp)
local elmfam,gens,i,G;
  elmfam:=NewFamily("elements family of bbg",IsObject,IsMatrixBBGpElm);
  elmfam!.defaultType :=NewType(elmfam,
                                IsMatrixBBGpElm and IsPositionalObjectRep);
  SetOne(elmfam,BBGpElmFromList(elmfam,One(grp)));
  # make black box group elements from the matrix generators
  gens:=[];
  for i in GeneratorsOfGroup(grp) do
    Add(gens,BBGpElmFromList(elmfam,i));
  od;
  G:=GroupWithGenerators(gens,BBGpElmFromList(elmfam,One(grp)));
return G;
end);

###############################################################################
##
#M BBGpAsPQuotientBBGp( <bb group> )        ... PAB 2-10-04
##
InstallMethod( BBGpAsPQuotientBBGp, "bb group -> quotient bb group", true,
[IsBBGp,IsInt],0,
function( bbg , p )
local elmfam,gens,i,G,x;
  elmfam:=NewFamily("elements family of bbg",IsObject,IsPQuotientBBGpElm);
  elmfam!.defaultType := NewType( elmfam, IsPQuotientBBGpElm and IsPositionalObjectRep );
  elmfam!.prime:=p;
  SetOne(elmfam,BBGpElmFromList(elmfam,One(bbg)![1]));
  gens:=[];
  for i in GeneratorsOfGroup( bbg ) do
     x:=BBGpElmFromList(elmfam,i![1]);
     Add(gens,x);
  od;
  G:=GroupWithGenerators(gens,BBGpElmFromList(elmfam,One(bbg)![1]));
  elmfam!.group:=G;
return G;
end);

#############################################################################
## Methods for group operations
##

InstallMethod(PrintObj,"bbg elms",true,[IsBBGpElm],0,
function(e)
  Print("BBGpElm ",e![1]);
end);

InstallMethod(One,"bbg elms",true,[IsBBGpElm],0,
function(e)
  return One(FamilyObj(e));
end);

InstallMethod(\*,"bbg elms",IsIdenticalObj,[IsPermBBGpElm,IsPermBBGpElm],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  return BBGpElmFromList(fam,
	      PermProductBBGp(fam!.stabChainGroup, a![1], b![1] ));
end);

InstallMethod(\=,"bbg elms",IsIdenticalObj,[IsPermBBGpElm,IsPermBBGpElm],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  return  PermEqualsBBGp(fam!.stabChainGroup, a![1], b![1] );
end);

InstallMethod(InverseOp,"bbg elms",true,[IsPermBBGpElm],0,
function(a)
local fam;
  fam:=FamilyObj(a);
  return BBGpElmFromList(fam,
	      PermInverseBBGp(fam!.stabChainGroup, a![1] ));
end);

InstallMethod(\*,"bbg elms",IsIdenticalObj,[IsNaturalPermBBGpElm,
IsNaturalPermBBGpElm],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  return BBGpElmFromList(fam, a![1] * b![1] );
end);

InstallMethod(\=,"bbg elms",IsIdenticalObj,[IsNaturalPermBBGpElm,
IsNaturalPermBBGpElm],0,
function(a,b)
  return  a![1] =b![1] ;
end);

InstallMethod(\<,"bbg elms",IsIdenticalObj,[IsNaturalPermBBGpElm,
IsNaturalPermBBGpElm],0,
function(a,b)
  return  a![1]<b![1] ;
end);

InstallMethod(InverseOp,"bbg elms",true,[IsNaturalPermBBGpElm],0,
function(a)
local fam;
  fam:=FamilyObj(a);
  return BBGpElmFromList(fam,
	      Inverse( a![1] ));
end);

InstallMethod(\*,"bbg elms",IsIdenticalObj,[IsMatrixBBGpElm,IsMatrixBBGpElm],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  return BBGpElmFromList(fam, a![1] * b![1] );
end);

### PAB: 02-12-04
InstallMethod(\*,"bbg elms",IsIdenticalObj,[IsPQuotientBBGpElm,IsPQuotientBBGpElm],0,
function(a,b)
local fam,x;
  fam:=FamilyObj(a);
  x:=BBGpElmFromList(fam, a![1] * b![1] );
  return x;
end);

InstallMethod(\=,"bbg elms",IsIdenticalObj,[IsMatrixBBGpElm,IsMatrixBBGpElm],0,
function(a,b)
  return  a![1]=b![1] ;
end);


InstallMethod(\<,"bbg elms",IsIdenticalObj,[IsMatrixBBGpElm,IsMatrixBBGpElm],0,
function(a,b)
  return  a![1]<b![1] ;
end);

InstallMethod(InverseOp,"bbg elms",true,[IsMatrixBBGpElm],0,
function(a)
local fam;
  fam:=FamilyObj(a);
  return BBGpElmFromList(fam,
	      Inverse( a![1] ));
end);

### PAB: 02-12-04
InstallMethod(InverseOp,"bbg elms",true,[IsPQuotientBBGpElm],0,
function(a)
local fam, x;
   fam:=FamilyObj(a);
   x:=BBGpElmFromList(fam,Inverse( a![1] ));
   return x;
end);

### PAB: 02-12-04
InstallMethod(\=,"bbg elms",IsIdenticalObj,[IsPQuotientBBGpElm,IsPQuotientBBGpElm],0,
function(a,b)
   local fam;
   fam:=FamilyObj(a);
return (PQuotientEqualsBBGp(fam!.group,fam!.prime,a,b) );
end);


##############################################################################
##
#A PseudoRandom( <bbgroup> )                  . . . random function in bbg

InstallMethod( PseudoRandom , "method for permbbgs with chain" , true , 
  [HasChain] , 0 ,
function( bbg )
local fam, chain;
   chain := Chain( bbg );
   fam := FamilyObj(GeneratorsOfGroup(bbg)[1]);
return BBGpElmFromList(fam, RandomElmAsWord( chain ) );
end); 

