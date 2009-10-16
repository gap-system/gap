# compute possible qq+1-th root of scalar for sesquilinear form.
# returns [i0,lambda] where (lambda*u)^(qq+1) (u a i0-th root of
# unity) are the possible scalars.
# returns `false' if the element admits no scalars. (I.e. no sesquilinear
# form possible)
InstallGlobalFunction(ClassicalForms_ScalarMultipleFrobenius,function(INF,cpol)
local   F,d,  c,  z,  I,  q,  qq,  t,  a,  l,i0;

    F:=INF.field;
    z:=Zero(F);

    d:=Degree(cpol);
    c:=CoefficientsOfUnivariatePolynomial(cpol);
    # get the position of the non-zero coefficients
    I:=Filtered([0..d],  x->c[x+1]<>z);
    q:=Size(F);
    #sqrt(q). Note that a^qq =\bar a
    qq:=Characteristic(F)^(LogInt(q,Characteristic(F))/2);

    # make sure that <d> and <d>-i both occur
    if ForAny(I, x->not (d-x) in I)  then
      SetzPreservedSesquilinearForm(INF,false);
      return false;
    fi;

    Add(I,q-1);
    # compute gcd representation
    t:=GcdRepresentation(I);
    i0:=I*t;

    a:=c[1];
    l:=List([1..Length(I)-1], x ->(a*c[d-I[x]+1]^qq/c[I[x]+1]));

    a:=Product([1..Length(I)-1], x->l[x]^t[x]);
    # Now the scalar $\lambda$ satisfies $\lambda^{i_0}=a$

    # check: $\forall_i: \bar c_{d-i}c_0=c_i\lambda^i
    if ForAny([1..Length(I)-1],x->l[x]<>a^QuoInt(I[x],i0)) then
      SetzPreservedSesquilinearForm(INF,false);
      return false;
    fi;
    
    a:=NthRoot(F,a,(qq+1)*i0);
    if a=fail then
      SetzPreservedSesquilinearForm(INF,false);
      return false;
    fi;
    return [i0,a];
end);


#############################################################################
##
#F  ClassicalForms_GeneratorsWithoutScalarsFrobenius(<module>)
##
InstallGlobalFunction(ClassicalForms_GeneratorsWithoutScalarsFrobenius,function(arg)
local   G,INF,module, gens,  field,  m1,  a1,  new,  i;

    INF:=arg[1];
    module:=INF.module;
    field:=INF.field;
    G:=INF.group;
    gens :=[];
    while Length(gens) < 2  do
	INF.count:=INF.count+1;
        if INF.count>INF.limit then
	  SetzPreservedSesquilinearForm(INF,UNKNOWN);
	  return false; 
	fi;
        m1:=PseudoRandom(G);
        a1:=ClassicalForms_ScalarMultipleFrobenius(INF,
	      CharacteristicPolynomial(m1));
	#TODO: might not terminate
        if IsList(a1) and a1[1]=1 then
	  a1:=a1[2];
	  Add(gens, m1*a1^-1);
        fi;
    od;
    new:=GModuleByMats(gens, field);

    # the module must act absolutely irreducible
    while not MTX.IsAbsolutelyIrreducible(new)  do
        for i  in [1..2]  do
            repeat
		INF.count:=INF.count+1;
		if INF.count>INF.limit then return false;  fi;
                m1:=PseudoRandom(G);
		a1:=ClassicalForms_ScalarMultipleFrobenius(INF,
		      CharacteristicPolynomial(m1));
	    #TODO: might not terminate
            until IsList(a1) and a1[1]=1;
	    a1:=a1[2];
            Add(gens, m1*a1^-1);
        od;
        new:=GModuleByMats(gens, field);
    od;

    # and return
    return new;
            
end);

# compute possible 2nd root of scalar for sesquilinear form.
# returns [i0,lambda] where (lambda*u)^2 (u a i0-th root of
# unity) are the possible scalars.
# returns `false' if the element admits no scalars. (I.e. no bilinear
# form possible)
InstallGlobalFunction(ClassicalForms_ScalarMultipleDual,function(INF,cpol)
local   F,  d,  c,  z,  I,  t,  a,  l,  q,i0;

    F:=INF.field;
    z:=Zero(F);
    q:=Size(F);

    d:=Degree(cpol);
    c:=CoefficientsOfUnivariatePolynomial(cpol);
    # get the position of the non-zero coefficients
    I:=Filtered([0..d],  x->c[x+1]<>z);

    # make sure that <d> and <d>-i both occur
    if ForAny(I, x->not (d-x) in I)  then
      SetzPreservedBilinearForm(INF,false);
      return false;
    fi;

    Add(I,q-1);
    # compute gcd representation
    t:=GcdRepresentation(I);
    i0:=I*t;

    a:=c[1];
    l:=List([1..Length(I)-1], x ->(a*c[d-I[x]+1]/c[I[x]+1]));

    a:=Product([1..Length(I)-1], x->l[x]^t[x]);
    # Now the scalar $\lambda$ satisfies $\lambda^{i_0}=a$

    # check: $\forall_i: c_{d-i}c_0=c_i\lambda^i
    if ForAny([1..Length(I)-1],x->l[x]<>a^QuoInt(I[x],i0)) then
      SetzPreservedBilinearForm(INF,false);
      return false;
    fi;

    a:=NthRoot(F,a,2*i0);
    if a=fail then
      SetzPreservedBilinearForm(INF,false);
      return false;
    fi;
    return [i0,a];
end);


#############################################################################
##
#F  ClassicalForms_GeneratorsWithoutScalarsDual(<module>)
##
InstallGlobalFunction(ClassicalForms_GeneratorsWithoutScalarsDual,function(arg)
    local   INF,G,module,  gens,  field,  m1,  a1,  new,  i;

    INF:=arg[1];
    module:=INF.module;
    field:=INF.field;
    G:=INF.group;
    gens :=[];
    while Length(gens) < 2  do
	INF.count:=INF.count+1;
        if INF.count>INF.limit then
	  SetzPreservedBilinearForm(INF,UNKNOWN);
	  return false; 
	fi;
        m1:=PseudoRandom(G);
        a1:=ClassicalForms_ScalarMultipleDual(INF,
	      CharacteristicPolynomial(m1));
	#TODO: might not terminate
	if IsList(a1) and a1[1]=1 then
	  a1:=a1[2];
	  Add(gens, m1*a1^-1);
        fi;
    od;
    new:=GModuleByMats(gens, field);

    # the module must act absolutely irreducible
    while not MTX.IsAbsolutelyIrreducible(new)  do
        for i  in [1..2]  do
            repeat
		INF.count:=INF.count+1;
		if INF.count>INF.limit then return false;  fi;
                m1:=PseudoRandom(G);
		a1:=ClassicalForms_ScalarMultipleDual(INF,
		      CharacteristicPolynomial(m1));
	    #TODO: might not terminate
            until IsList(a1) and a1[1]=1;
	    a1:=a1[2];
            Add(gens, m1*a1^-1);
        od;
        new:=GModuleByMats(gens, field);
    od;

    # and return
    return new;
            
end);


#############################################################################
##
#F  ClassicalForms_Signum2(<field>, <form>, <quad>)
##
InstallGlobalFunction(ClassicalForms_Signum2,function(field, form, quad)
    local   base,  avoid,  i,  d,  j,  c,  k,  x,  sgn,  pol;

    # compute a new basis,  such that the symmetric form is standard
    base :=OneOp(form);
    form:=List(form,ShallowCopy);
    avoid:=[];
    for i  in [1..Length(form)-1]  do

        # find first non zero entry
        d:=1;
        while d in avoid or IsZero(form[i][d])  do
	  d:=d+1;
        od;
        Add(avoid, d);

        # clear all other entries in this row & column
        for j  in [d+1..Length(form)]  do
            c:=-form[i][j]/form[i][d];
            if c<>field.zero  then
                for k  in [i..Length(form)]  do
                  form[k][j]:=form[k][j] + c*form[k][d];
                od;
                #form[j]:=form[j] + c*form[d];
                #base[j]:=base[j] + c*base[d];
		AddRowVector(form[j],form[d],c);
		AddRowVector(base[j],base[d],c);
            fi;
        od;
    od;

    # reshuffle base
    c:=[];
    j:=[];
    for i  in [1..Length(form)]  do
        if not i in j  then
            k:=form[i][avoid[i]];
            Add(c, base[i]/k);
            Add(c, base[avoid[i]]);
            Add(j, avoid[i]);
        fi;
    od;
    base:=c;

    # and try to fix the quadratic form (this is not really necessary)
    x  :=X(field);
    sgn:=1;
    for i  in [1, 3..Length(form)-1]  do
        c:=base[i] * quad * base[i];
        if IsZero(c)  then
            c:=base[i+1] * quad * base[i+1];
            if not IsZero(c)  then
                #base[i+1]:=base[i+1] - c*base[i];
                AddRowVector(base[i+1],base[i],-c);
            fi;
        else
            j:=base[i+1] * quad * base[i+1];
            if IsZero(j)  then
                #base[i]:=base[i] - c*base[i+1];
                AddRowVector(base[i],base[i+1],-c);
            else
                pol:=Factors(x^2 + x/j + c/j);
                if Length(pol) = 2  then
                    pol:=List(pol,x->
		      -CoefficientsOfUnivariatePolynomial(x)[1]);
                    base{[i,i+1]}:=[base[i]+pol[1]*base[i+1],
                        (base[i]+pol[2]*base[i+1])/(pol[1]+pol[2])];
                else
                    sgn:=-sgn;
                fi;
            fi;
        fi;
    od;

    # and return
    return [sgn,ImmutableMatrix(field,form)];

end);


#############################################################################
##
#F  ClassicalForms_Signum(<field>, <form>, <quad>)
##
InstallGlobalFunction(ClassicalForms_Signum,function(field, form, quad)
    local   sgn,  det,  sqr;

    # if dimension is odd,  the signum must be 0
    if Length(form) mod 2 = 1  then
        return [0];

    # hard case: characteristic is 2
    elif Characteristic(field) = 2  then
        Error("characteristic must be odd");
    fi;

    # easy case
    det:=DeterminantMat(form);
    sqr:=LogFFE(det, PrimitiveRoot(field)) mod 2 = 0;
    if (Length(form)*(Size(field)-1)/4) mod 2 = 0  then
        if sqr  then
            sgn:=+1;
        else
            sgn:=-1;
        fi;
    else
        if sqr  then
            sgn:=-1;
        else
            sgn:=+1;
        fi;
    fi;

    # and return
    return [sgn, sqr];

end);


#############################################################################
##
#F  ClassicalForms_QuadraticForm2(<field>, <form>, <gens>, <scalars>)
##
InstallGlobalFunction(ClassicalForms_QuadraticForm2,function(field, form, gens, scalars)
    local   H,  i,  j,  e,  b,  y,  x,  r,  l;

    # raise an error if char is not two
    if Characteristic(field)<>2  then
        Error("characteristic must be two");
    fi;

    # construct the upper half of the form
    H:=ZeroOp(form);
    for i  in [1..Length(form)]  do
        for j  in [i+1..Length(form)]  do
            H[i][j]:=form[i][j];
        od;
    od;
    
    # store the linear equations in <e>
    e:=[];

    # loop over all generators
    b:=[];
    for y  in [1..Length(gens)]  do

        # remove scalars
        x:=gens[y]*scalars[y]^-1;

        # first the right hand size
        r:=x*H*TransposedMat(x)+H;

        # check <r>
        for i  in [1..Length(form)]  do
            for j  in [i+1..Length(form)]  do
                if not IsZero(r[i][j]+r[j][i])  then
                    return false;
                fi;
            od;
        od;

        # and now the diagonals
        for i  in [1..Length(form) ]  do
            l:=[];
            for j  in [1..Length(form)]  do
                l[j]:=x[i][j]^2;
            od;
            l[i]:=l[i]+1;
            Add(b, r[i][i]);
            Add(e, l);
        od;
    od;

    # and return a solution
    e:=SolutionMat(TransposedMat(e), b);
    if e<>false  then
        for i  in [1..Length(form)]  do
            H[i][i]:=e[i];
        od;
        return ImmutableMatrix(field,H);
    else
        return false;
    fi;

end);


#############################################################################
##
#F  ClassicalForms_QuadraticForm(<field>, <form>)
##
InstallGlobalFunction(ClassicalForms_QuadraticForm,function(field, form)
    local   H,  i,  j;

    # special case if <p> = 2
    if Characteristic(field) = 2  then
        Error("characteristic must be odd");
    fi;

    # use upper half
    H:=ZeroOp(form);
    for i  in [1..Length(form)]  do
        H[i][i]:=form[i][i]/2;
        for j  in [i+1..Length(form)]  do
            H[i][j]:=form[i][j];
        od;
    od;

    # and return
    return H;

end);


#############################################################################
##
#F  ClassicalForms_InvariantFormDual(<module>, <dmodule>)
##
InstallGlobalFunction(ClassicalForms_InvariantFormDual,function(INF,module, dmodule)
    local   hom,  scalars,  form,  iform,  identity,  field,  root,  
            q,  i,  m,  a,  quad,  sgn;

    # <dmodule> acts absolutely irreducible without scalars
    hom:=MTX.Homomorphisms(dmodule, MTX.DualModule(dmodule));
    if 0 = Length(hom)  then
        return false;
    elif 1 < Length(hom)  then
        Error("module acts absolutely irreducibly but two form found");
    fi;
    Info(InfoRecog,2,"found homomorphism between V and V^*");

    # make sure that the forms commute with the generators of <module>
    scalars :=[];
    form    :=hom[1];
    iform   :=form^-1;
    identity:=One(form);
    field   :=MTX.Field(module);
    root    :=PrimitiveRoot(field);
    q       :=Size(field);
    for i  in MTX.Generators(module)  do
        m:=i * form * TransposedMat(i) * iform;
        a:=m[1][1];
        if m<>a*identity  then
            Info(InfoRecog,2,"form is not invariant under all generators");
            return false;
        fi;
	a:=NthRoot(field,a,2);
        Add(scalars, a);
    od;

    # check the type of form
    if TransposedMat(form) = -form  then
	SetzRC_Scalars(INF,scalars);
        if Characteristic(field) = 2  then
            quad:=ClassicalForms_QuadraticForm2(
                field, form, MTX.Generators(module), scalars);
            if quad = false  then
	      SetzPreservedBilinearForm(INF,form);
	      SetzFormType(INF,RC_SYMPLECTIC);
	      return;
            elif MTX.Dimension(module) mod 2 = 1  then
                Error("no quadratic form but odd dimension");
	    #elif ClassicalForms_Signum2(field, form, quad) = -1  then
	    else 
	      form:=ClassicalForms_Signum2(field, form, quad);
              if form[1] = -1  then
		SetzPreservedBilinearForm(INF,form[2]);
		SetzFormType(INF,RC_ORTHMINUS);
		SetzPreservedQuadraticForm(INF,quad);
		return;
	      else
		SetzPreservedBilinearForm(INF,form[2]);
		SetzFormType(INF,RC_ORTHPLUS);
		SetzPreservedQuadraticForm(INF,quad);
		return;
	      fi;
	    fi;
        else
	  SetzPreservedBilinearForm(INF,form);
	  SetzFormType(INF,RC_SYMPLECTIC);
	  return;
        fi;
    elif TransposedMat(form) = form  then
        quad:=ClassicalForms_QuadraticForm(field, form);
	SetzPreservedBilinearForm(INF,form);
	SetzRC_Scalars(INF,scalars);
	SetzPreservedQuadraticForm(INF,quad);
        if IsOddInt(INF.d)  then
	  SetzFormType(INF,RC_ORTHCIRCLE);
	  return;
        else
            sgn:=ClassicalForms_Signum(field, form, quad);
            if sgn[1] = -1  then
		SetzFormType(INF,RC_ORTHMINUS);
		return;
            else
		SetzFormType(INF,RC_ORTHPLUS);
		return;
            fi;
        fi;
    else
      SetzFormType(INF,"unknown");
      return;
    fi;
end);


#############################################################################
##
#F  ClassicalForms_InvariantFormFrobenius(<module>, <fmodule>)
##
InstallGlobalFunction(TransposedFrobeniusMat,function(mat, qq)
local  f, i,  j;

    f:=DefaultFieldOfMatrix(mat);
    mat:=MutableTransposedMat(mat);
    for i  in [1..Length(mat)]  do
        for j  in [1..Length(mat[i])]  do
            mat[i][j]:=mat[i][j]^qq;
        od;
    od;
    mat:=ImmutableMatrix(f,mat);
    return mat;
end);

InstallGlobalFunction(DualFrobeniusGModule,function(module)
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
end);


InstallGlobalFunction(ClassicalForms_InvariantFormFrobenius,function(INF,module, fmodule)
    local   fro,  hom,  form,  q,  qq,  k,  a,  scalars,  iform,  
            identity,  field,  root,  i,  m,  j;

    # <fmodule> acts absolutely irreducible without scalars
    fro:=DualFrobeniusGModule(fmodule);
    hom:=MTX.Homomorphisms(fmodule, fro);
    if 0 = Length(hom)  then
        return false;
    elif 1 < Length(hom)  then
        Error("module acts absolutely irreducibly but two form found");
    fi;
    Info(InfoRecog,2,"found homomorphism between V and (V^*)^frob");

    # invariant form might return a scalar multiply of our form
    field   :=INF.field;
    form:=hom[1];
    q :=Size(field);
    qq:=Characteristic(field)^(LogInt(q,Characteristic(field))/2);
    k :=PositionNonZero(form[1]);
    a :=form[1][k] / form[k][1]^qq;
    a:=NthRoot(field,a,(1-qq) mod (q-1));
    if a=fail then
      return false;
    fi;
    form:=form * a^-1;

    # make sure that the forms commute with the generators of <module>
    scalars :=[];
    iform   :=form^-1;
    identity:=form^0;
    for i  in MTX.Generators(module)  do
      m:=i * form * TransposedFrobeniusMat(i,qq) * iform;
      a:=m[1][1];
      if m<>a*identity  then
	Info(InfoRecog,2,"form is not invariant under all generators");
	return false;
      fi;
      a:=NthRoot(field,a,qq+1);
      Add(scalars, a);
    od;

    # check the type of form
    for i  in [1..Length(form)]  do
        for j  in [1..Length(form)]  do
            if form[i][j]^qq<>form[j][i]  then
                Info(InfoRecog,2,"unknown form");
                return fail;
            fi;
        od;
    od;
    SetzFormType(INF,RC_UNITARY);
    SetzPreservedSesquilinearForm(INF,form);
    SetzRC_Scalars(INF,scalars);

end);


#############################################################################
##
#F  ClassicalForms(<grp>)
##
InstallGlobalFunction(DoClassicalForms,function(arg)
    local   INF,grp,  field,  z,  d,  i,  qq,  A,  c,  I,  t,  
            a,  l,  g,  module,  forms,  dmod,  fmod,  form,cpol,locallimit;

    INF:=arg[1];
    forms:=[];

    # set up the field and other information
    field:=INF.field;
    z:=Zero(field);
    d:=INF.d;
    #INF.isFrobenius:=LogInt(Size(field),Characteristic(field)) mod 2 = 0;
    if LogInt(Size(field),Characteristic(field)) mod 2<>0 then
      SetzPreservedSesquilinearForm(INF,false);
    fi;

    # The forms which are not excluded in INF are still interesting

    if not HatPreservedSesquilinearForm(INF)  then
        qq:=Characteristic(field) ^ (LogInt(Size(field),
              Characteristic(field)) / 2);
    fi;

    locallimit:=INF.count+10;
    while (not (HatPreservedSesquilinearForm(INF) and
          HatPreservedBilinearForm(INF)) and INF.count<locallimit) do
      repeat
	g:=PseudoRandom(INF.group);
      until not IsOne(g);
      cpol:=CharacteristicPolynomial(g);
      INF.count:=INF.count+1;
      if not HatPreservedBilinearForm(INF) then
        ClassicalForms_ScalarMultipleDual(INF,cpol);
      fi;
      if not HatPreservedSesquilinearForm(INF) then
        ClassicalForms_ScalarMultipleFrobenius(INF,cpol);
      fi;
    od;

    if not (HatPreservedSesquilinearForm(INF) and 
      HatPreservedBilinearForm(INF)) or
      PreservedSesquilinearForm(INF)=UNKNOWN or
      PreservedBilinearForm(INF)=UNKNOWN then

      module:=INF.module;
	
      if not MTX.IsAbsolutelyIrreducible(module) then
        return [["unknown", "absolutely reducible"]];
      fi;

      if not HatPreservedBilinearForm(INF) then
        dmod:=ClassicalForms_GeneratorsWithoutScalarsDual(INF);
      fi;

      if not HatPreservedSesquilinearForm(INF) then
        fmod:=ClassicalForms_GeneratorsWithoutScalarsFrobenius(INF);
      fi;

      if not HatPreservedBilinearForm(INF) then
        ClassicalForms_InvariantFormDual(INF,module,dmod);
      fi;

      if not HatPreservedSesquilinearForm(INF) then
        ClassicalForms_InvariantFormFrobenius(INF,module,fmod);
      fi;


    fi;
end);

InstallRCMethod(FormType,function(I)
  DoClassicalForms(I);
  if HatFormType(I) then
    return FormType(I);
  elif HatPreservedSesquilinearForm(I) and PreservedSesquilinearForm(I)=false
   and HatPreservedBilinearForm(I) and PreservedBilinearForm(I)=false then
    return RC_LINEAR;
  else
    Error("TODO: why is there no form type?");
  fi;
end);


#    #if 1 = Length(arg)  then
#        for i  in [1..8]  do
#            if INF.isDual or INF.isFrobenius  then
#                repeat
#                    A:=PseudoRandom(module);
#                until A<>grp.identity;
#                c:=CharacteristicPolynomial(FiniteFieldMatrices, A);
#                c:=c.coefficients;
#            fi;
#            if INF.isDual  then
#                I:=Filtered([0..d], x->c[x+1]<>z);
#                if ForAny(I, x->c[d-x+1] = z)  then
#                    INF.isDual:=false;
#                else
#                    t :=GcdRepresentation(I);
#                    i0:=I*t;
#                    a :=c[1];
#                    l :=List([1..Length(I)], 
#                                x ->(a*c[d-I[x]+1]/c[I[x]+1]));
#                    g :=Product([1..Length(I)],x->l[x]^t[x]);
#                    if ForAny([1..Length(I)], x->l[x]<>g^(I[x]/i0))  then
#                        INF.isDual:=false;
#                    fi;
#                fi;
#            fi;
#            if INF.isFrobenius  then
#                I:=Filtered([0..d], x->c[x+1]<>z);
#                if ForAny(I, x->c[d-x+1] = z)  then
#                    INF.isFrobenius:=false;
#                else
#                    t :=GcdRepresentation(I);
#                    i0:=I*t;
#                    a :=c[1];
#                    l :=List([1..Length(I)], x ->
#                               (a*c[d-I[x]+1]^qq/c[I[x]+1]));
#                    g :=Product([1..Length(I)],x->l[x]^t[x]);
#                    if ForAny([1..Length(I)], x->l[x]<>g^(I[x]/i0))  then
#                        INF.isFrobenius:=false;
#                    fi;
#                fi;
#            fi;
#        od;
#    fi;
#
#    # nothing left?
#    if not INF.isDual and not INF.isFrobenius  then
#        return [["linear"]];
#    fi;
#
#    # <grp> must act irreducible
#    if not IsAbsolutelyIrreducible(module)  then
#        return [["unknown", "absolutely reducible"]];
#    fi;
#
#    # try to find generators without scalars
#    if INF.isDual  then
#        dmodule:=ClassicalForms_GeneratorsWithoutScalarsDual(module);
#        if dmodule = false  then
#            Add(forms, ["unknown"]);
#            INF.isDual:=false;
#        fi;
#    fi;
#    if INF.isFrobenius  then
#        fmodule:=ClassicalForms_GeneratorsWithoutScalarsFrobenius(module);
#        if fmodule = false  then
#            Add(forms, ["unknown"]);
#            INF.isFrobenius:=false;
#        fi;
#    fi;
#
#    # now try to find an invariant form
#    if INF.isDual  then
#        form:=ClassicalForms_InvariantFormDual(module,dmodule);
#        if form<>false  then
#            Add(forms, form);
#        else
#            Add(forms, ["unknown", "dual"]);
#        fi;
#    fi;
#    if INF.isFrobenius  then
#        form:=ClassicalForms_InvariantFormFrobenius(module,fmodule);
#        if form<>false  then
##            Add(forms, form);
#        else
#            Add(forms, ["unknown", "frobenius"]);
#        fi;
#    fi;
#    return forms;
#
##end;
#
