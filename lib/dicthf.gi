#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Gene Cooperman, Scott Murray, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains some hashfunctions for objects in the GAP library.
##  This code was factored out from dict.gi to prevent cross dependencies
##  between dict.gi and the rest of the library.
##
#T  * This is all apparently completely undocumented.
#

InstallMethod(DenseIntKey,"default fail",true,[IsObject,IsObject],
        0,ReturnFail);

InstallMethod(SparseIntKey,"defaults to DenseIntKey",true,[IsObject,IsObject],
        0,DenseIntKey);

#############################################################################
##
#F  HashKeyBag(<obj>,<seed>,<skip>,<maxread>)
#F  HashKeyWholeBag(<obj>,<seed>)
##
##  returns a hash key which is given by the bytes in the bag storing <obj>.
##  The result is reduced modulo $2^{28}$ (on 32 bit systems) resp. modulo
##  $2^{60}$ (on 64 bit systems) to obtain a small integer.
##  As some objects carry excess data in their bag, the first <skip> bytes
##  will be skipped and <maxread> bytes (a value of -1 represents infinity)
##  will be read at most. (The proper values for these numbers might depend on
##  the internal representation used as well as on the word length of the
##  machine on which {\GAP} is running and care has to be taken when using
##  `HashKeyBag' to ensure identical key values for equal objects.)
##
##  The values returned by `HashKeyBag' are not guaranteed to be portable
##  between different runs of {\GAP} and no reference to their absolute
##  values ought to be made.
##
##  HashKeyWholeBag hashes all the contents of a bag, which is equivalent
##  to passing 0 and -1 as the third and fourth arguments of HashKeyBag.
##  Be aware that for many types in GAP (for example permutations), equal
##  objects may not have identical bags, so HashKeyWholeBag may return
##  different values for two equal objects.
##
BindGlobal("HashKeyBag",HASHKEY_BAG);
BindGlobal("HashKeyWholeBag", {x,y} -> HASHKEY_BAG(x,y,0,-1));

#############################################################################
##
#M  SparseIntKey(<objcol>)
##
InstallMethod(SparseIntKey,"for finite Gaussian row spaces",true,
    [ IsFFECollColl and IsGaussianRowSpace,IsObject ], 0,
function(m,v)
local f,n,bytelen,data,qq,i,b,nn;
  f:=LeftActingDomain(m);
  n:=Size(f);
  if n=2 then
    bytelen:=QuoInt(Length(v),8);
    if bytelen<=8 then
      # short GF2
      return x->NumberFFVector(x,2);
    else
      # long GF2
      data:=[2*GAPInfo.BytesPerVariable,bytelen];
      return function(x)
             if not IsGF2VectorRep(x) then
                 Info(InfoWarning,1,"uncompressed vector");
                 x:=ShallowCopy(x);
                 ConvertToGF2VectorRep(x);
               fi;
               return HashKeyBag(x,101,data[1],data[2]);
             end;
    fi;
  elif n < 256 then
    qq:=n; # log
    i:=0;
    while qq<=256 do
        qq:=qq*n;
        i:=i+1;
    od;
    # i is now the number of field elements per byte
    bytelen := QuoInt(Length(v),i);
    if bytelen<=8 then
      # short 8-bit
      return x->NumberFFVector(x,n);
    else
      # long 8 bit
      data:=[3*GAPInfo.BytesPerVariable,bytelen];
      # must check type
      #return x->HashKeyBag(x,101,data[1],data[2]);
      return function(x)
             if not Is8BitVectorRep(x) or
               Q_VEC8BIT(x)<>n then
                 Info(InfoWarning,1,"un- or miscompressed vector");
                 x:=ShallowCopy(x);
                 ConvertToVectorRep(x,n);
               fi;
               return HashKeyBag(x,101,data[1],data[2]);
             end;

    fi;
  elif n > 100000 and Characteristic( f ) < n then
    # large field, view it as an extension of its prime field
    # in order to avoid writing down all of its elements
    if Size( LeftActingDomain( f ) ) <> Characteristic( f ) then
      f:= AsField( PrimeField( f ), f );
    fi;
    b:= Basis( f );
    nn:= Size( LeftActingDomain( f ) );
    return function( v )
      local sy, x;
      sy:= 0;
      for x in v do
        sy:= n * sy + NumberFFVector( Coefficients( b, x ), nn );
      od;
      return sy;
    end;
  else
    # large field -- vector represented as plist.
    f:=AsSSortedList(f);
    return function(v)
           local x,sy,p;
              sy := 0;
              if IsZmodnZVectorRep(v) then
                for x in v![ELSPOS] do
                  sy := n*sy + (x-1);
                od;
              else
                for x in v do
                  p := Position(f, x);
# want to be quick: Assume no failures
#                 if p = fail then
#                     Error("NumberFFVector: Vector not over specified field");
#                 fi;
                  sy := n*sy + (p-1);
                od;
              fi;

            return sy;
           end;
  fi;
end);

#############################################################################
##
#M  SparseIntKey(<objcol>)
##
InstallMethod(SparseIntKey,"for bounded tuples",true,
    [ IsList,IsList and IsCyclotomicCollection ], 0,
function(m, v)
  if Length(m)<> 3 or m[1]<>"BoundedTuples" then
    TryNextMethod();
  fi;
  # Due to the way BoundedTuples are presently implemented we expect the input
  # to the hash function to always be a list of positive immediate integers. This means
  # that using HashKeyWholeBag should be safe.
  return function(x)
    Assert(1, IsPositionsList(x));
    if not IsPlistRep(x) then
      x := AsPlist(x);
    fi;
    return HashKeyWholeBag(x, 1);
  end;

  # alternative code w/o HashKeyBag
  ## build a weight vector to distinguish lists. Make entries large while staying clearly within
  ## immediate int (2^55 replacing 2^60, since we take subsequent primes).
  #step:=NextPrimeInt(QuoInt(2^55,Maximum(m[2])*m[3]));
  #weights:=[1];
  #len:=Length(v);
  ## up to 56 full, then increasingly reduce
  #len:=Minimum(len,8*RootInt(len));
  #while Length(weights)<len do
  #  Add(weights,weights[Length(weights)]+step);
  #  step:=NextPrimeInt(step);
  #od;
  #return function(a)
  #  return a*weights;
  #end;

end);

BindGlobal( "SparseIntKeyVecListAndMatrix", function(d,m)
local f,n,pow,fct;
  if IsList(d) and Length(d)>0 and IsMatrix(d[1]) then
    f:=DefaultScalarDomainOfMatrixList(d);
  else
    f:=DefaultScalarDomainOfMatrixList([m]);
  fi;

  fct:=SparseIntKey(f^Length(m[1]),m[1]);

  n:=Minimum(Size(f),11)^Minimum(12,QuoInt(Length(m[1]),2));
  #pow:=n^Length(m[1]);
  pow:=NextPrimeInt(n); # otherwise we produce huge numbers which take time
  return function(x)
          local i,gsy;
            gsy:=0;
            for i in x do
              gsy:=pow*gsy+fct(i);
            od;
            return gsy;
          end;
end );

InstallMethod(SparseIntKey,"for lists of vectors",true,
    [ IsFFECollColl,IsObject ], 0,
function(m,v)
local f;
if not (IsList(m) and IS_PLIST_REP(m) and ForAll(m,IsRowVector)) then
    TryNextMethod();
  fi;
  f:=DefaultFieldOfMatrix(m);
  return SparseIntKey(f^Length(v),v);
end);

InstallMethod(SparseIntKey,
  "for matrices over finite field vector spaces",true,
  [IsObject,IsFFECollColl and IsMatrix],0,
SparseIntKeyVecListAndMatrix);

InstallMethod(SparseIntKey,
  "for vector listsover finite field vector spaces",true,
  [IsObject,IsFFECollColl and IsList],0,
SparseIntKeyVecListAndMatrix);

#############################################################################
##
#M  SparseIntKey( <dom>, <key> ) for row spaces over finite fields
##
InstallMethod( SparseIntKey, "for row spaces over finite fields", true,
    [ IsObject,IsVectorSpace and IsRowSpace], 0,
function( key, dom )
  return function(key)
    local sz, n, ret, k,d;

    d:=LeftActingDomain( key );
    sz := Size(d);
    key := BasisVectors( CanonicalBasis( key ) );
    n := sz ^ Length( key[1] );
    ret := 1;
    for k in key do
        ret := ret * n + NumberFFVector( k, sz );
    od;
    return ret;
  end;
end );


InstallMethod(DenseIntKey,"integers",true,
  [IsObject,IsPosInt],0,
function(d,i)
  #T this function might cause problems if there are nonpositive integers
  #T used densely.
  return IdFunc;
end);

InstallMethod(SparseIntKey,"permutations, arbitrary domain",true,
  [IsObject,IsInternalRep and IsPerm],0,
function(d,pe)
  return function(p)
         local l;
           l:=LARGEST_MOVED_POINT_PERM(p);
           if IsPerm4Rep(p) then
             # is it a proper 4byte perm?
             if l>65536 then
               return HashKeyBag(p,255,GAPInfo.BytesPerVariable,4*l);
             else
               # the permutation does not require 4 bytes. Trim in two
               # byte representation (we need to do this to get consistent
               # hash keys, regardless of representation.)
               TRIM_PERM(p,l);
             fi;
            fi;
            # now we have a Perm2Rep:
            return HashKeyBag(p,255,GAPInfo.BytesPerVariable,2*l);
          end;
end);

#T Still to do: Permutation values based on base images: Method if the
#T domain given is a permgroup.

BindConstant( "DOUBLE_OBJLEN", 2*GAPInfo.BytesPerVariable );

InstallMethod(SparseIntKey,"kernel pc group elements",true,
  [IsObject,
    IsElementFinitePolycyclicGroup and IsDataObjectRep and IsNBitsPcWordRep],0,
function(d,e)
local l,p;
  # we want to use an small shift to avoid cancellation due to similar bit
  # patterns in many bytes (the exponent values in most cases are very
  # small). The pcgs length is a reasonable small value-- otherwise we get
  # already overlap for the generators alone.
  p:=FamilyObj(e)!.DefiningPcgs;
  l:=NextPrimeInt(Length(p)+1);
  p:=Product(RelativeOrders(p));
  while Gcd(l,p)>1 do
    l:=NextPrimeInt(l);
  od;
  return e->HashKeyBag(e,l,DOUBLE_OBJLEN,-1);
end);

InstallMethod(SparseIntKey,"pcgs element lists: i.e. pcgs",true,
  [IsObject,IsElementFinitePolycyclicGroupCollection and IsList],0,
function(d,p)
local o,e;

  if IsPcgs(p) then
    o:=OneOfPcgs(p);
  else
    o:=One(p[1]);
  fi;

  e:=SparseIntKey(false,o); # element hash fun
  o:=DefiningPcgs(FamilyObj(o));
  o:=Product(RelativeOrders(o)); # order of group
  return function(x)
         local i,h;
           h:=0;
           for i in x do
             h:=h*o+e(i);
           od;
           return h;
         end;
end);

InstallMethod(SparseIntKey, "for an object and transformation",
[IsObject, IsTransformation],
function(d, t)
  return x-> NumberTransformation(t, DegreeOfTransformation(t));
end);

