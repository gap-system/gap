#############################################################################
##
#W  forms.gd	 	   	recog Package                    Frank Celler
#W                                                             Alice Niemeyer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright (C)  2006
##
##  This  file contains functions to compute forms invariant under
##  matrix groups.  
##

#############################################################################
##
#F  ClassicalForms_ScalarMultipleFrobenius( <field>, <mat> )
##
ClassicalForms_ScalarMultipleFrobenius := function( F, M )
    local   mpol,  d,  c,  z,  I,  q,  qq,  t,  a,  l, i0, Minv, tM, tMi;

    # compute the characteristic polynomial of <M>
    mpol := CharacteristicPolynomial(M);

    # get the position of the non-zero coefficients
    d := Degree(mpol);
    c := CoefficientsOfUnivariatePolynomial(mpol);
    z := Zero(F);

    I := Filtered( [0 .. d],  x -> (not IsZero(c[x+1]) ));
    q := Size(F);
    qq := Characteristic(F)^(LogInt(q,Characteristic(F))/2);

    Minv := M^-1;
    tM := Trace(M); tMi := Trace(Minv)^qq; # Frobenius of trace
    if (IsZero(tM) and not IsZero(tMi)) or
       (not IsZero(tM) and IsZero(tMi)) then 
        return false;
    fi;

    # make sure that <d> and <d>-i both occur
    if ForAny( I, x ->  IsZero(c[d-x+1]) )  then
        return false;
    fi;

    Add(I,q-1);
    # we need gcd one in order to get alpha exactly (ignoring +-)
    t := GcdRepresentation(I);
    i0:=I*t;

    if not IsZero(tM) and not IsZero(tMi) then
	return [i0, tM/tMi];
    fi;

    # compute gcd representation
    a:=c[1];
    l:=List([1..Length(I)-1], x ->(a*c[d-I[x]+1]^qq/c[I[x]+1]));

    a:=Product([1..Length(I)-1], x->l[x]^t[x]);
    # Now the scalar $\lambda$ satisfies $\lambda^{i_0}=a$

    # check: $\forall_i: \bar c_{d-i}c_0=c_i\lambda^i$
    if ForAny([1..Length(I)-1],x->l[x]<>a^QuoInt(I[x],i0)) then
        Info( InfoClassical, 1, 
         "characteristic polynomial does not reveal scalar\n" );
      return false;
    fi;

    # compute a square root of <alpha>
    a:=NthRoot(F,a,(qq+1)*i0);
    if a=fail then
        Info( InfoClassical, 1, 
        "characteristic polynomial does not reveal scalar\n" );
      return false;
    fi;
    return [i0,a];

end;


#############################################################################
##
#F  ClassicalForms_GeneratorsWithoutScalarsFrobenius( grp, forms )
##
ClassicalForms_GeneratorsWithoutScalarsFrobenius := function( grp )
    local   tries,  gens,  field,  m1,  a1,  new,  i;

    # start with 2 random elements,  at most 10 tries
    tries := 0;
    gens  := [];
    field := FieldOfMatrixGroup(grp);
    while Length(gens) < 2  do
        tries := tries + 1;
        if tries = 11  then return false;  fi;
        m1 := PseudoRandom(grp);
        a1 := ClassicalForms_ScalarMultipleFrobenius(field,m1);
        if IsList(a1) and a1[1]=1 then
	        a1:=a1[2];
	        Add(gens, m1*a1^-1);
        fi;
    od;
    new := GModuleByMats( gens, field );


    # the module must act absolutely irreducible
    while not MTX.IsAbsolutelyIrreducible(new)  do
        for i  in [ 1 .. 2 ]  do
            repeat
                tries := tries + 1;
                if tries > 10  then return false;  fi;
                m1 := PseudoRandom(grp);
                a1 := ClassicalForms_ScalarMultipleFrobenius(field,m1);
            until IsList(a1) and a1[1]=1;
	    a1:=a1[2];
            Add( gens, m1*a1^-1 );
        od;

        new := GModuleByMats( gens, field );
    od;

    # and return
    return new;
            
end;


#############################################################################
##
#F  ClassicalForms_ScalarMultipleDual( <field>, <mat> )
##
ClassicalForms_ScalarMultipleDual := function( F, M )
    local   mpol,  d,  c,  z,  I,  t,  a,  l,  q, i0, Minv;

    # compute the characteristic polynomial of <M>
    mpol := CharacteristicPolynomial(M);

    # get the position of the non-zero coefficients
    d := Degree(mpol);
    c:=CoefficientsOfUnivariatePolynomial(mpol);
    z := Zero(F);
    q := Size(F);
    I := Filtered( [ 0 .. d ],  x -> c[x+1] <> z );

    Minv := M^-1;
    if Trace(M) = z and Trace(Minv) <> z or
       Trace(M) <> z and Trace(Minv) = z then 
        return false;
    fi;
    # make sure that <d> and <d>-i both occur
    if ForAny( I, x -> not (d-x) in I )  then
        return false;
    fi;

    # we need gcd one in order to get alpha exactly (ignoring +-)
    Add(I,q-1);
    t := GcdRepresentation(I);
    i0:=I*t;

    a:=c[1];
    l:=List([1..Length(I)-1], x ->(a*c[d-I[x]+1]/c[I[x]+1]));

    a:=Product([1..Length(I)-1], x->l[x]^t[x]);
    # Now the scalar $\lambda$ satisfies $\lambda^{i_0}=a$

    # check: $\forall_i: c_{d-i}c_0=c_i\lambda^i
    if ForAny([1..Length(I)-1],x->(l[x]<>a^QuoInt(I[x],i0))) then
        Info( InfoClassical, 1, 
          "characteristic polynomial does not reveal scalar\n" );
      return false;
    fi;

    # compute a square root of <alpha>
    a:=NthRoot(F,a,2*i0);
    if a=fail then
        Info( InfoClassical, 1,"characteristic polynomial does not reveal scalar\n" );
      return false;
    fi;
    return [i0,a];

end;


#############################################################################
##
#F  ClassicalForms_GeneratorsWithoutScalarsDual( grp, forms )
##
ClassicalForms_GeneratorsWithoutScalarsDual := function( grp )
    local   tries,  gens,  field,  m1,  a1,  new,  i;

    # start with 2 random elements,  at most 10 tries
    tries := 0;
    gens  := [];
    field := FieldOfMatrixGroup(grp);
    while Length(gens) < 2  do
        tries := tries + 1;
        if tries > 10  then return false;  fi;
        m1 := PseudoRandom(grp);
        a1 := ClassicalForms_ScalarMultipleDual(field,m1);
        if IsList(a1) and a1[1]=1 then
	        a1:=a1[2];
	        Add(gens, m1*a1^-1);
        fi;
    od;
    new := GModuleByMats( gens, field );

    # the module must act absolutely irreducible
    while not MTX.IsAbsolutelyIrreducible(new)  do
        for i  in [ 1 .. 2 ]  do
            repeat
                tries := tries + 1;
                if tries > 10  then return false;  fi;
                m1 := PseudoRandom(grp);
                a1 := ClassicalForms_ScalarMultipleDual(field,m1);
            until IsList(a1) and a1[1]=1;
	        a1:=a1[2];
            Add(gens, m1*a1^-1);
        od;
        new := GModuleByMats( gens, field );
    od;

    # and return
    return new;
            
end;


#############################################################################
##
#F  ClassicalForms_Signum2( <field>, <form>, <quad> )
##
ClassicalForms_Signum2 := function( field, form, quad )
    local   base,  avoid,  i,  d,  j,  c,  k,  x,  sgn,  pol;

    # compute a new basis,  such that the symmetric form is standard
    base :=OneOp(form);
    form:=List(form,ShallowCopy);
    avoid := [];
    for i  in [ 1 .. Length(form)-1 ]  do

        # find first non zero entry
        d:=1;
        while d in avoid or IsZero(form[i][d])  do
	        d:=d+1;
        od;
        Add(avoid, d);

        # clear all other entries in this row & column
        for j  in [d+1..Length(form)]  do
            c := form[i][j]/form[i][d];
            if c <> Zero(field)  then
                for k  in [ i .. Length(form) ]  do
                    form[k][j] := form[k][j] - c*form[k][d];
                od;
		        AddRowVector(form[j],form[d],c);
		        AddRowVector(base[j],base[d],c);
            fi;
        od;
    od;

    # reshuffle base
    c := [];
    j := [];
    for i  in [ 1 .. Length(form) ]  do
        if not i in j  then
            k := form[i][avoid[i]];
            Add( c, base[i]/k );
            Add( c, base[avoid[i]] );
            Add( j, avoid[i] );
        fi;
    od;
    base := c;

    # and try to fix the quadratic form (this is not really necessary)
    x   := X(field);
    sgn := 1;
    for i  in [ 1, 3 .. Length(form)-1 ]  do
        c := base[i] * quad * base[i];
        if IsZero(c)  then
            c := base[i+1] * quad * base[i+1];
            if not IsZero(c) then
                AddRowVector(base[i+1],base[i],-c);
            fi;
        else
            j := base[i+1] * quad * base[i+1];
            if IsZero(j)  then
                AddRowVector(base[i],base[i+1],-c);
            else
                pol := Factors(x^2 + x/j + c/j);
                if Length(pol) = 2  then
                    pol:=List(pol,x->
		                 -CoefficientsOfUnivariatePolynomial(x)[1]);
                else
                    sgn := -sgn;
                fi;
            fi;
        fi;
    od;

    # and return
    return sgn;

end;


#############################################################################
##
#F  ClassicalForms_Signum( <field>, <form>, <quad> )
##
ClassicalForms_Signum := function( field, form, quad )
    local   sgn,  det,  sqr;

    # if dimension is odd,  the signum must be 0
    if Length(form) mod 2 = 1  then
        return [ 0 ];

    # hard case: characteristic is 2
    elif Characteristic(field) = 2  then
        Error( "characteristic must be odd" );
    fi;

    # easy case
    det := DeterminantMat(form);
    sqr := LogFFE( det, PrimitiveRoot(field)) mod 2 = 0;
    if (Length(form)*(Size(field)-1)/4) mod 2 = 0  then
        if sqr  then
            sgn := +1;
        else
            sgn := -1;
        fi;
    else
        if sqr  then
            sgn := -1;
        else
            sgn := +1;
        fi;
    fi;

    # and return
    return [ sgn, sqr ];

end;


#############################################################################
##
#F  ClassicalForms_QuadraticForm2( <field>, <form>, <gens>, <scalars> )
##
ClassicalForms_QuadraticForm2 := function( field, form, gens, scalars )
    local   H,  i,  j,  e,  b,  y,  x,  r,  l;

    # raise an error if char is not two
    if Characteristic(field) <> 2  then
        Error( "characteristic must be two" );
    fi;

    # construct the upper half of the form
    H := ZeroOp(form);
    for i  in [ 1 .. Length(form) ]  do
        for j  in [ i+1 .. Length(form) ]  do
            H[i][j] := form[i][j];
        od;
    od;
    
    # store the linear equations in <e>
    e := [];

    # loop over all generators
    b := [];
    for y  in [ 1 .. Length(gens) ]  do

        # remove scalars
        x := gens[y]*scalars[y]^-1;

        # first the right hand size
        r := x*H*TransposedMat(x)+H;

        # check <r>
        for i  in [ 1 .. Length(form) ]  do
            for j  in [ i+1 .. Length(form) ]  do
                if not IsZero(r[i][j]+r[j][i]) then
                    return false;
                fi;
            od;
        od;

        # and now the diagonals
        for i  in [ 1 .. Length(form)  ]  do
            l := [];
            for j  in [ 1 .. Length(form) ]  do
                l[j] := x[i][j]^2;
            od;
            l[i] := l[i]+1;
            Add( b, r[i][i] );
            Add( e, l );
        od;
    od;

    # and return a solution
    e := SolutionMat( TransposedMat(e), b );
    if e <> fail  then
        for i  in [ 1 .. Length(form) ]  do
            H[i][i] := e[i];
        od;
        return ImmutableMatrix(field,H);
    else
        return false;
    fi;

end;


#############################################################################
##
#F  ClassicalForms_QuadraticForm( <field>, <form> )
##
ClassicalForms_QuadraticForm := function( field, form )
    local   H,  i,  j;

    # special case if <p> = 2
    if Characteristic(field) = 2  then
        Error( "characteristic must be odd" );
    fi;

    # use upper half
    H := ZeroOp(form);
    for i  in [ 1 .. Length(form) ]  do
        H[i][i] := form[i][i]/2;
        for j  in [ i+1 .. Length(form) ]  do
            H[i][j] := form[i][j];
        od;
    od;

    # and return
    return H;

end;


#############################################################################
##
#F  ClassicalForms_InvariantFormDual( <module>, <dmodule> )
##
ClassicalForms_InvariantFormDual := function( module, dmodule )
    local   hom,  scalars,  form,  iform,  identity,  field,  root,  
            q,  i,  m,  a,  quad,  sgn;

    # <dmodule> acts absolutely irreducible without scalars
    hom := MTX.Homomorphisms( dmodule, DualGModule(dmodule) );
    if 0 = Length(hom)  then
        return false;
    elif 1 < Length(hom)  then
        Error( "module acts absolutely irreducibly but two forms found" );
    fi;
    Info( InfoClassical, 1, "found homomorphism between V and V^*\n" );

    # make sure that the forms commute with the generators of <module>
    scalars  := [];
    form     := hom[1];
    iform    := form^-1;
    identity := One(form);
    field   :=  MTX.Field(module);
    root    :=  PrimitiveRoot(field);
    q        := Size(field);
    for i  in MTX.Generators(module)  do
        m := i * form * TransposedMat(i) * iform;
        a := m[1][1];
        if m <> a*identity  then
            Info(InfoClassical, 1, 
                "form is not invariant under all generators\n" );
            return false;
        fi;
	    a := NthRoot(field,a,2);
        Add( scalars, a );
    od;

    # check the type of form
    if TransposedMat(form) = -form  then
        Info(InfoClassical, 1, "form is symplectic\n" );
        if Characteristic(field) = 2  then
            quad := ClassicalForms_QuadraticForm2(
                field, form, MTX.Generators(module), scalars );
            if quad = false  then
                return [ "symplectic", form, scalars ];
            elif MTX.Dimension(module) mod 2 = 1  then
                Error( "no quadratic form but odd dimension" );
            elif ClassicalForms_Signum2( field, form, quad ) = -1  then
                return [ "orthogonalminus", form, scalars, quad ];
            else
                return [ "orthogonalplus", form, scalars, quad ];
            fi;
        else
            return [ "symplectic", form, scalars ];
        fi;
    elif TransposedMat(form) = form  then
        Info(InfoClassical, 1, "form is symmetric\n" );
        quad := ClassicalForms_QuadraticForm( field, form );
        if MTX.Dimension(module) mod 2 = 1  then
            return [ "orthogonalcircle", form, scalars, quad ];
        else
            sgn := ClassicalForms_Signum( field, form, quad );
            if sgn[1] = -1  then
                return [ "orthogonalminus", form, scalars, quad, sgn[2] ];
            else
                return [ "orthogonalplus", form, scalars, quad, sgn[2] ];
            fi;
        fi;
    else
        Info( InfoClassical, 1,"unknown form\n" );
        return [ "unknown", "dual", form, scalars ];
    fi;
end;


#############################################################################
##
#F  ClassicalForms_InvariantFormFrobenius( <module>, <fmodule> )
##
TransposedFrobeniusMat := function( mat, qq )
    local   i,  j;

#    f := Field(mat);
    mat:=MutableTransposedMat(mat);
    for i  in [ 1 .. Length(mat) ]  do
        for j  in [ 1 .. Length(mat[i]) ]  do
            mat[i][j] := mat[i][j]^qq;
        od;
    od;
    return mat;
end;

DualFrobeniusGModule := function(module)
local   F,  k,  dim,  mats,  dmats,  qq,  i,  j,  l;

  if SMTX.IsZeroGens(module) then
    return GModuleByMats([],module.dimension,SMTX.Field(module));
  else
    F := MTX.Field(module);
    k := LogInt( Size(F), Characteristic(F) );
    if k mod 2 = 1  then
        Error( "field <F> is not a square" );
    fi;
    dim   := MTX.Dimension(module);
    mats  := MTX.Generators(module);
    dmats := List(mats,i->List(i,ShallowCopy));
    qq    := Characteristic(F) ^ ( k / 2 );
    for i  in [ 1 .. Length(mats) ]  do
      for j  in [ 1 .. dim ]  do
	for l  in [ 1 .. dim ]  do
	  dmats[i][j][l] := mats[i][l][j]^qq;
	od;
      od;
      dmats[i]:=ImmutableMatrix(F,dmats[i]);
    od;

    return GModuleByMats(List(dmats,i->i^-1),F);
  fi;
end;


ClassicalForms_InvariantFormFrobenius := function( module, fmodule )
    local   fro,  hom,  form,  q,  qq,  k,  a,  scalars,  iform,  
            identity,  field,  root,  i,  m,  j;

    # <fmodule> acts absolutely irreducible without scalars
    fro := DualFrobeniusGModule(fmodule);
    hom := MTX.Homomorphisms(fmodule, fro);
    if 0 = Length(hom)  then
        return false;
    elif 1 < Length(hom)  then
        Error( "module acts absolutely irreducibly but two form found" );
    fi;
    Info( InfoClassical, 1,"found homomorphism between V and (V^*)^frob\n" );

    # invariant form might return a scalar multiple of our form
    field    := MTX.Field(module);
    form := hom[1];
    q  := Size(field);
    qq := Characteristic(field)^(LogInt(q,Characteristic(field))/2);
    k  := PositionNonZero(form[1]);
    a  := form[1][k] / form[k][1]^qq;
    a := NthRoot(field,a,(1-qq) mod (q-1));
    if a = fail then
      return false;
    fi;
    form := form * a^-1;


    # make sure that the forms commute with the generators of <module>
    scalars  := [];
    iform    := form^-1;
    identity := One(form);
    root     := PrimitiveRoot(field);
    for i  in MTX.Generators(module)  do
        m := i * form * TransposedFrobeniusMat(i,qq) * iform;
        a := m[1][1];
        if m <> a*identity  then
            Info(InfoClassical, 1, 
                 "form is not invariant under all generators\n" );
            return false;
        fi;
        a:=NthRoot(field,a,qq+1);
        Add( scalars, a );
    od;

    # check the type of form
    for i  in [ 1 .. Length(form) ]  do
        for j  in [ 1 .. Length(form) ]  do
            if form[i][j]^qq <> form[j][i]  then
                Info(InfoClassical, 1, "unknown form\n" );
                return [ "unknown", "frobenius", form, scalars ];
            fi;
        od;
    od;
    return [ "unitary", form, scalars ];

end;

# forms is  a record  which stores information  about which  forms the
# matrix  group grp  leaves  invariant.   It has  to  have the  record
# components .maybeDual and  .maybeFrobenius.  It sets .maybeDual
# to false if the cpoly c of  an element of the group grp excludes the
# possibility  that grp  leaves  invariant a  bilinear  form and  sets
# .maybeFrobenius to false  if the cpoly c of an  element of the group
# grp   excludes  the   possibility  that   grp  leaves   invariant  a
# sesquilinear form

InstallGlobalFunction(PossibleClassicalForms,
                       function(arg)

    local  I, d, z, f, t, i0, a, l, g, q, qq, forms, grp,  c, tM, tMi, Minv;

    if not Length(arg) in [2,3] then
        Error("Usage: PossibleClassicalForms( grp, g [,forms] )\n");
    fi;
    grp   := arg[1];
    g     := arg[2];
    if Length(arg) = 3 then
	forms := arg[3];
    else forms := rec();
         forms.maybeDual := true;
         f := DefaultFieldOfMatrixGroup(grp);
	 forms.field := f;
         forms.maybeFrobenius := DegreeOverPrimeField(f) mod 2 = 0;
    fi;

    c := CharacteristicPolynomial(g); 
    c := CoefficientsOfUnivariatePolynomial(c);

    d := DimensionOfMatrixGroup(grp); 
    f := forms.field;
    z := Zero(f);
    q := Size(f);
    Minv := g^-1;
    tM := Trace(g); tMi := Trace(Minv); 

    if forms.maybeFrobenius then
        qq := Characteristic(f)^(DegreeOverPrimeField(f)/2);
	tMi := tMi^qq;               # Frobenius of trace
    fi;

    if (IsZero(tM) and not IsZero(tMi)) or
       (not IsZero(tM) and IsZero(tMi)) then 
	forms.maybeFrobenius := false;
	forms.maybeDual := false;
        return false;
    fi;

    I := Filtered( [0 .. d],  x -> (not IsZero(c[x+1]) ));
    # make sure that <d> and <d>-i both occur
    if ForAny( I, x ->  IsZero(c[d-x+1]) )  then
	forms.maybeFrobenius := false;
	forms.maybeDual := false;
        return false;
    fi;
    Add(I,q-1);

    # we need gcd one in order to get alpha exactly (ignoring +-)
    t := GcdRepresentation(I);
    i0:=I*t;

    if not IsZero(tM) and not IsZero(tMi) then
	return [i0, tM/tMi];
    fi;


    if forms.maybeDual  then 
	    a  := c[1];
	    l  := List( [1..Length(I)-1], 
			x ->(a*c[d-I[x]+1]/c[I[x]+1]) );
	    g  := Product( [1..Length(I)-1],x -> l[x]^t[x] );
	    if ForAny( [1..Length(I)-1], x -> l[x]<>g^(I[x]/i0) )  then
		forms.maybeDual := false;
	    fi;
    fi;
    if forms.maybeFrobenius  then
	    a  := c[1];
	    l  := List([1..Length(I)-1], x ->
	               (a*c[d-I[x]+1]^qq/c[I[x]+1]));
	    g  := Product( [1..Length(I)-1],x -> l[x]^t[x] );
	    if ForAny( [1..Length(I)-1], x -> l[x]<>g^(I[x]/i0) )  then
	        forms.maybeFrobenius := false;
	    fi;
    fi;
    if forms.maybeDual = false and forms.maybeFrobenius = false then
	return false;
    else
	return true;
    fi;
end);

#############################################################################
##
#F  ClassicalForms( <grp> [, <formtype>] )
##
InstallGlobalFunction(ClassicalForms, function( arg )
    local   grp,  forms,  field,   i,  g, qq,  c,
            module,  invariantforms,  dmodule,  fmodule,  form;

    # unpack the arguments
    grp := arg[1];
    # try to find the possibilities in the default case
    if not IsMatrixGroup(grp)  then
        Error("Usage: first argument must be a matrix group ");
    fi;

    forms := rec();
    field := DefaultFieldOfMatrixGroup(grp);
    forms.field := field;
    forms.invariantforms := [];
    forms.maybeDual      := false;
    forms.maybeFrobenius := false;

    # set up the field and other information
    module := GModuleByMats(GeneratorsOfGroup(grp),field);

    # set the possibilities
    if 1 = Length(arg)  then 
        forms.maybeDual      := true;
        forms.maybeFrobenius := DegreeOverPrimeField(field) mod 2 = 0;
    else
        for i  in arg{[2..Length(arg)]}  do
            if i = "dual"  then
                forms.maybeDual := true;
            elif i = "frobenius" then
                forms.maybeFrobenius := DegreeOverPrimeField(field) mod 2 = 0;
            else
                Error( "unknown type \"", i, "\"" );
            fi;
        od;
    fi;
    if forms.maybeFrobenius  then
        qq := Characteristic(field)^(DegreeOverPrimeField(field)/2);
    fi;


    # We first preform some inexpensive tests with a few random elements
    if Length(arg) = 1 then
        for i in [1 .. 8]  do
            g := PseudoRandom(grp); 
            if forms.maybeDual or forms.maybeFrobenius  then 
                PossibleClassicalForms( grp, g, forms );
            fi;
        od;
    fi;

    # if all forms are excluded then we are finished 
    if not forms.maybeDual and not forms.maybeFrobenius  then
            Add( forms.invariantforms, [ "linear" ] );
	    return forms;
    fi;

    # <grp> must act absolutely irreducibly
    if not MTX.IsAbsolutelyIrreducible(module)  then	
        Info( InfoClassical, 1,  "grp not absolutely irreducible\n" );
        Add( forms.invariantforms, [ "unknown" ] );
        return forms;
    fi;

    # try to find generators without scalars
    if forms.maybeDual  then
        dmodule := ClassicalForms_GeneratorsWithoutScalarsDual(grp);
        if dmodule = false  then
#            Add( forms.invariantforms, [ "unknown" ] );
            forms.maybeDual := false;
        fi;
    fi;
    if forms.maybeFrobenius  then
        fmodule := ClassicalForms_GeneratorsWithoutScalarsFrobenius(grp);
        if fmodule = false  then
#            Add( forms.invariantforms, [ "unknown" ] );
            forms.maybeFrobenius := false;
        fi;
    fi;

    # now try to find an invariant form
    if forms.maybeDual  then
        form := ClassicalForms_InvariantFormDual(module,dmodule);
        if form <> false  then
            Add( forms.invariantforms, form );
        else
            forms.maybeDual := false;
#            Add( forms.invariantforms, [ "unknown", "dual" ] );
        fi;
    fi;

    if forms.maybeFrobenius  then
        form := ClassicalForms_InvariantFormFrobenius(module,fmodule);
        if form <> false  then
            Add( forms.invariantforms, form );
        else
            forms.maybeFrobenius := false;
#            Add( forms.invariantforms, [ "unknown", "frobenius" ] );
        fi;
    fi;
    # if all forms are excluded then we are finished 
    if not forms.maybeDual and not forms.maybeFrobenius  then
            Add( forms.invariantforms, [ "linear" ] );
    fi;
    return forms;

end );

