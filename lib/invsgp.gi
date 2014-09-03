#############################################################################
##
#W  invsgp.gd              GAP library                         J. D. Mitchell
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declaration of operations for inverse semigroups.
##

InstallImmediateMethod(GeneratorsOfSemigroup,
IsInverseSemigroup and HasGeneratorsOfInverseSemigroup, 0,
function(s)
  local gens, f;

  gens:=ShallowCopy(GeneratorsOfInverseSemigroup(s));
  Append(gens, List(gens, x-> x^-1));
  MakeImmutable(gens);
  return gens;
end); 


#

InstallMethod(IsInverseSubsemigroup, "for a semigroup and a semigroup",
[IsSemigroup, IsSemigroup],
function(s, t)
  return IsSubsemigroup(s, t) and IsInverseSemigroup(t);
end);

#

InstallMethod(AsInverseMonoid, "for an inverse monoid", 
[IsInverseMonoid], 100, IdFunc );

#

InstallMethod(AsInverseMonoid, "for an inverse semigroup",
[IsInverseSemigroup],
function(s)
  local gens, pos;

  if One(s)=fail then
    return fail;
  fi;

  gens:=ShallowCopy(GeneratorsOfInverseSemigroup(s));
  pos:=Position(gens, One(s));
  if pos<>fail then 
    Remove(gens, pos); 
  fi;
  return InverseMonoid(gens);
end);

#

InstallOtherMethod(IsInverseSemigroup, "for an object", [IsObject], ReturnFalse);

#

InstallMethod(\.,"for an inverse semigroup with generators and pos int",
[IsInverseSemigroup and HasGeneratorsOfInverseSemigroup, IsPosInt],
function(s, n)
  s:=GeneratorsOfInverseSemigroup(s);
  n:=NameRNam(n);
  n:=Int(n);
  if n=fail or Length(s)<n then
    Error("the second argument should be a positive integer not greater than",
     " the number of generators of the semigroup in the first argument");
  fi;
  return s[n];
end);

#

InstallMethod(\., "for an inverse monoid with generators and pos int",
[IsInverseMonoid and HasGeneratorsOfInverseMonoid, IsPosInt],
function(s, n)
  s:=GeneratorsOfInverseMonoid(s);
  n:=NameRNam(n);
  n:=Int(n);
  if n=fail or Length(s)<n then
    Error("usage: the second argument should be a pos int not greater than",
     " the number of generators of the semigroup in the first argument");
  fi;
  return s[n];
end);

#

InstallGlobalFunction(InverseMonoid,
function( arg )
  local out, i;

  if Length(arg)=0 or (Length(arg)=1 and HasIsEmpty(arg[1]) and IsEmpty(arg[1]))
   then 
    Error("usage: cannot create an inverse monoid with no generators,");
    return;
  fi;
  
  if IsAssociativeElement(arg[1]) or IsAssociativeElementCollection(arg[1]) 
   or (HasIsEmpty(arg[1]) and IsEmpty(arg[1])) then 
    out:=[]; 
    for i in [1..Length(arg)] do 
      if IsAssociativeElement(arg[i]) 
       and IsGeneratorsOfInverseSemigroup([arg[i]]) then 
        Add(out, arg[i]);
      elif IsAssociativeElementCollection(arg[i])
        and IsGeneratorsOfInverseSemigroup(arg[i]) then 
        #if HasGeneratorsOfInverseMonoid(arg[i]) then 
        #  Append(out, GeneratorsOfInverseMonoid(arg[i]));
        if HasGeneratorsOfInverseSemigroup(arg[i]) then 
          Append(out, GeneratorsOfInverseSemigroup(arg[i]));
        #elif HasGeneratorsOfMonoid(arg[i]) then 
        #  Append(out, GeneratorsOfMonoid(arg[i]));
        elif HasGeneratorsOfSemigroup(arg[i]) then
          Append(out, GeneratorsOfSemigroup(arg[i]));
        else
          Append(out, AsList(arg[i]));
        fi;
      elif i=Length(arg) and IsRecord(arg[i]) then 
        return InverseMonoidByGenerators(out, arg[i]);
      else
        if not IsEmpty(arg[i]) then 
          Error( "usage: InverseMonoid(<gen>,...), InverseMonoid(<gens>),"
           ,  "InverseMonoid(<D>)," );
          return;
        fi;
      fi;
    od;
    return InverseMonoidByGenerators(out);
  fi;
  Error( "usage: InverseMonoid(<gen>,...),InverseMonoid(<gens>),",
   "InverseMonoid(<D>),");
  return;
end);

#

InstallGlobalFunction(InverseSemigroup,
function( arg )
  local out, i;

  if Length(arg)=0 or (Length(arg)=1 and HasIsEmpty(arg[1]) and IsEmpty(arg[1]))
   then 
    Error("usage: cannot create an inverse semigroup with no generators,");
    return;
  fi;

  if IsAssociativeElement(arg[1]) or IsAssociativeElementCollection(arg[1]) 
    or (HasIsEmpty(arg[1]) and IsEmpty(arg[1])) then 
    out:=[]; 
    for i in [1..Length(arg)] do 
      if IsAssociativeElement(arg[i]) 
        and IsGeneratorsOfInverseSemigroup([arg[i]]) then 
        Add(out, arg[i]);
      elif IsAssociativeElementCollection(arg[i]) 
       and IsGeneratorsOfInverseSemigroup(arg[i]) then 
        if HasGeneratorsOfInverseSemigroup(arg[i]) then 
          Append(out, GeneratorsOfInverseSemigroup(arg[i]));
        elif HasGeneratorsOfSemigroup(arg[i]) then
          Append(out, GeneratorsOfSemigroup(arg[i]));
        else
          Append(out, arg[i]);
        fi;
      elif i=Length(arg) and IsRecord(arg[i]) then 
        return InverseSemigroupByGenerators(out, arg[i]);
      else
        if not IsEmpty(arg[i]) then 
          Error( "usage: InverseSemigroup(<gen>,...), InverseSemigroup(<gens>),"
          ,  "InverseSemigroup(<D>)," );
          return;
        fi;
      fi;
    od;
    return InverseSemigroupByGenerators(out);
  fi;
  Error( "usage: InverseSemigroup(<gen>,...),InverseSemigroup(<gens>),",
   "InverseSemigroup(<D>),");
  return;
end);

#

InstallMethod(InverseMonoidByGenerators, 
[IsAssociativeElementCollection],
function(gens)
  local s, one, pos;

  s:=Objectify( NewType (FamilyObj( gens ), IsMagmaWithOne and
   IsInverseSemigroup and IsAttributeStoringRep), rec());
  
  one:=One(gens);
  SetOne(s, one);
  pos:=Position(gens, one);
  
  if pos<>fail then 
    SetGeneratorsOfInverseSemigroup(s, gens);
    gens:=ShallowCopy(gens); 
    Remove(gens, pos);
    SetGeneratorsOfInverseMonoid(s, gens);
  else 
    SetGeneratorsOfInverseMonoid(s, gens);
    gens:=ShallowCopy(gens);
    Add(gens, one);
    SetGeneratorsOfInverseSemigroup(s, gens);
  fi;
  
  return s;
end);

#

InstallMethod(InverseSemigroupByGenerators, 
"for associative element with unique semigroup inverse collection",  
[IsAssociativeElementCollection],
function(gens)
  local s, pos;

  s:=Objectify( NewType (FamilyObj( gens ), IsMagma and
   IsInverseSemigroup and IsAttributeStoringRep), rec());
  SetGeneratorsOfInverseSemigroup(s, AsList(gens));
  
  if IsMultiplicativeElementWithOneCollection(gens) then 
    pos:=Position(gens, One(gens));
    if pos<>fail then 
      SetFilterObj(s, IsMonoid);
      gens:=ShallowCopy(gens);
      Remove(gens, pos);
      SetGeneratorsOfInverseMonoid(s, gens);
    fi;
  fi;
  return s;
end);

#

InstallMethod(InverseSubsemigroupNC, 
"for an inverse semigroup and element collection",
[IsInverseSemigroup, IsAssociativeElementCollection],
function(s, gens)
  local t;
  t:=InverseSemigroup(gens);
  SetParent(t, s);
  return t;
end);

#

InstallMethod(InverseSubsemigroup, 
"for an inverse semigroup and element collection",
[IsInverseSemigroup, IsAssociativeElementCollection],
function(s, gens)
  if ForAll(gens, x-> x in s) then 
    return InverseSubsemigroupNC(s, gens);
  fi;
  Error("the specified elements do not belong to the first argument,");
  return;
end);

#

InstallMethod(InverseSubmonoidNC, 
"for an inverse monoid and element collection",
[IsInverseMonoid, IsAssociativeElementCollection],
function(s, gens)
  local t;

  t:=InverseMonoid(gens);
  SetParent(t, s);
  return t;
end);

#

InstallMethod(InverseSubmonoid, 
"for an inverse monoid and element collection",
[IsInverseMonoid, IsAssociativeElementCollection],
function(s, gens)
  if ForAll(gens, x-> x in s) then 
    if One(s)<>One(gens) then 
      Append(gens, One(s));
    fi;
    return InverseSubmonoidNC(s, gens);
  fi;
  Error("the specified elements do not belong to the first argument,");
  return;
end);

#

InstallMethod(IsSubsemigroup, 
"for an inverse semigroup and inverse semigroup with generators",
[IsInverseSemigroup, IsInverseSemigroup and HasGeneratorsOfInverseSemigroup],
function(s, t)
  return ForAll(GeneratorsOfInverseSemigroup(t), x-> x in s);
end);

#

InstallMethod(\=, "for an inverse semigroups with generators",
[IsInverseSemigroup and HasGeneratorsOfInverseSemigroup, 
IsInverseSemigroup and HasGeneratorsOfInverseSemigroup],
function(s, t)
return ForAll(GeneratorsOfInverseSemigroup(s), x-> x in t) 
 and ForAll(GeneratorsOfInverseSemigroup(t), x-> x in s);
end);

#

#InstallMethod( PrintObj,
#    "for a inverse semigroup",
#    [ IsInverseSemigroup ],
#    function( S )
#    Print( "InverseSemigroup( ... )" );
#    end );

InstallMethod( String,
    "for a inverse semigroup",
    [ IsInverseSemigroup ],
    function( S )
    return "InverseSemigroup( ... )";
    end );

InstallMethod( PrintObj,
    "for a inverse semigroup with known generators",
    [ IsInverseSemigroup and HasGeneratorsOfInverseSemigroup ],
    function( S )
    Print( "InverseSemigroup( ", GeneratorsOfInverseSemigroup( S ), " )" );
    end );

InstallMethod( String,
    "for a inverse semigroup with known generators",
    [ IsInverseSemigroup and HasGeneratorsOfInverseSemigroup ],
    function( S )
    return STRINGIFY( "InverseSemigroup( ", 
     GeneratorsOfInverseSemigroup( S ), " )" );
    end );

InstallMethod( PrintString,
    "for a inverse semigroup with known generators",
    [ IsInverseSemigroup and HasGeneratorsOfInverseSemigroup ],
    function( S )
    return PRINT_STRINGIFY( "InverseSemigroup( ", 
     GeneratorsOfInverseSemigroup( S ), " )" );
    end );

InstallMethod( ViewString,
    "for a inverse semigroup",
    [ IsInverseSemigroup ],
    function( S )
    return "<inverse semigroup>" ;
    end );

InstallMethod( ViewString,
    "for a inverse semigroup with generators",
    [ IsInverseSemigroup and HasGeneratorsOfInverseSemigroup ],
    function( S )
    if Length(GeneratorsOfInverseSemigroup(S)) = 1 then
      return STRINGIFY( "<inverse semigroup with ", 
       Length( GeneratorsOfInverseSemigroup( S ) ), " generator>" );
    else
      return STRINGIFY( "<inverse semigroup with ", 
       Length( GeneratorsOfInverseSemigroup( S ) ),
           " generators>" );
    fi;
    end );

#

InstallMethod( String,
    "for a inverse monoid",
    [ IsInverseMonoid ],
    function( S )
    return "InverseMonoid( ... )";
    end );

InstallMethod( PrintObj,
    "for a inverse monoid with known generators",
    [ IsInverseMonoid and HasGeneratorsOfInverseMonoid ],
    function( S )
    Print( "InverseMonoid( ", GeneratorsOfInverseMonoid( S ), " )" );
    end );

InstallMethod( String,
    "for a inverse monoid with known generators",
    [ IsInverseMonoid and HasGeneratorsOfInverseMonoid ],
    function( S )
    return STRINGIFY( "InverseMonoid( ", 
     GeneratorsOfInverseMonoid( S ), " )" );
    end );

InstallMethod( PrintString,
    "for a inverse monoid with known generators",
    [ IsInverseMonoid and HasGeneratorsOfInverseMonoid ],
    function( S )
    return PRINT_STRINGIFY( "InverseMonoid( ", 
     GeneratorsOfInverseMonoid( S ), " )" );
    end );

InstallMethod( ViewString,
    "for a inverse monoid",
    [ IsInverseMonoid ],
    function( S )
    return "<inverse monoid>" ;
    end );

InstallMethod( ViewString,
    "for a inverse monoid with generators",
    [ IsInverseMonoid and HasGeneratorsOfInverseMonoid ],
    function( S )
    if Length(GeneratorsOfInverseMonoid(S)) = 1 then
      return STRINGIFY( "<inverse monoid with ", 
       Length( GeneratorsOfInverseMonoid( S ) ), " generator>" );
    else
      return STRINGIFY( "<inverse monoid with ", 
       Length( GeneratorsOfInverseMonoid( S ) ),
           " generators>" );
    fi;
    end );

#

InstallMethod( AsInverseSemigroup,
    "for an inverse semigroup",
    [ IsInverseSemigroup ], 100,
    IdFunc );

InstallMethod( AsInverseMonoid,
    "for an inverse monoid",
    [ IsInverseMonoid ], 100,
    IdFunc );


#

InstallMethod( IsRegularSemigroupElement, 
"for an inverse semigroup", IsCollsElms, 
[IsInverseSemigroup, IsAssociativeElement],
function(s, x)
return x in s;
end);

#EOF

