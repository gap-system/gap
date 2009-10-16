LieIsomorphism := function(L1,L2,S,varlist)

    local   cst,  filt,  n,  F,  ser1,  ser2,  cen1,  cen2,  dser1,  
            dser2,  H1,  cart1,  H2,  cart2,  lev1,  lev2,  nrad1,  
            nrad2,  HL1,  adH1,  i,  mat,  HL2,  adH2,  A1,  A2,  R1,  
            R2,  B1,  B2,  C1,  C2,  Id1,  b,  Id2,  spaces1,  inds,  
            j,  sp,  k,  sp1,  l,  sp2,  m,  sp3,  r,  sp4,  spaces2,  
            s,  bas1,  bas2,  pp,  cont,  bb1,  bb2,  i1,  i2,  x,  
            ii1,  T1,  T2,  vars,  str,  weights,  R,  indets,  
            map,  d,  mats,  bass1,  M,  I,  ll1,  p,  ll2,  
            o,  fl,  c,  ll3, npar;

    npar:= Length( varlist );

    cst:=function(T,S,i,j,k,a,b,c,map)
  
        local   cij,  pos,  p,  ef,  l,  mon,  m;
        
        cij:=T[i][j];
        pos:=Position(cij[1],k);
        if pos=fail then
            return T[Length(T)];
        else 
            if S=[] then
                return cij[2][pos];
            else
                if Length( map[1] )>0 and not (S[a][b][c] in F
                         or IsRat(S[a][b][c]) )  then
                    
                    # Here `p' is a polynomial in the variables used in
                    # stringtabs, we produce the same polynomial, but in
                    # the variables used in the ideal; it all boils down
                    # to renumbering of variables...
                    p:= ExtRepPolynomialRatFun( S[a][b][c] );
                    
                    ef:= [ ];
                    for l in [1,3..Length(p)-1] do
                        mon:= ShallowCopy( p[l] );
                        for m in [1,3..Length(mon)-1] do
                            pos:= Position( map[1], mon[m] );
                            mon[m]:= map[2][pos];
                        od;
                        Add( ef, mon );
                        Add( ef, p[l+1] );
                    od;
                    
                    return PolynomialByExtRep( FamilyObj( S[a][b][c] ), ef );
                else
                    return S[a][b][c];
                fi;
            fi;
        fi;
    end;

    filt:=function( b1, b2 )

        local sp;
        sp:=VectorSpace(F,b2);
        return Filtered(b1,y -> y in sp);
    end;
    
    n:=Dimension(L1);
    
    if n <> Dimension( L2 ) then return false; fi;
    
    F:=LeftActingDomain(L1);
    
    if F <> LeftActingDomain( L2 ) then return false; fi;
    
    if StructureConstantsTable( Basis( L1 ) ) = 
       StructureConstantsTable( Basis( L2 ) )  then 
       return true;
    fi;

    if Dimension(LieCentre(L1)) <> Dimension(LieCentre(L2))  then
      return false;
    fi;

    if Dimension(LieDerivedSubalgebra(L1))<>
      Dimension(LieDerivedSubalgebra(L2))  then
       return false;
    fi;

    ser1:=LieLowerCentralSeries(L1);
    ser2:=LieLowerCentralSeries(L2);
    
    if List(ser1,V->Dimension(V))<>List(ser2,V->Dimension(V)) then
        return false;
    fi;

    dser1:=LieDerivedSeries(L1);
    dser2:=LieDerivedSeries(L2);
    
    if List(dser1,V->Dimension(V))<>List(dser2,V->Dimension(V)) then
        return false;
    fi;


##    if not IsLieNilpotent(L1) then
        
        H1:= CartanSubalgebra( L1 );
        if Dimension(H1) = n then 
            cart1:= [ L1 ]; 
        else 
            cart1:= [ L1, H1 ];
        fi;

        H2:= CartanSubalgebra( L2 );
        if Dimension( H2 ) = n then 
            cart2:= [ L2 ];
        else 
            cart2:= [ L2, H2 ];
        fi;

        if Dimension(H1) <> Dimension(H2) then return false; fi;

        lev1:= ShallowCopy( LeviMalcevDecomposition(L1) ); Add( lev1, L1 );
        lev2:= ShallowCopy( LeviMalcevDecomposition(L2) ); Add( lev2, L2 );
        lev1:= Filtered( lev1, x->Dimension(x)<>0 );
        lev2:= Filtered( lev2, x->Dimension(x)<>0 );
    
        if List(lev1,V->Dimension(V))<>List(lev2,V->Dimension(V)) then
            return false;
        fi;  
    
        nrad1:= [ L1 ];
        if not IsLieNilpotent( L1 ) then 
            Append( nrad1, LieLowerCentralSeries( LieNilRadical( L1 ) ) );
            Append( nrad1, LieUpperCentralSeries( LieNilRadical( L1 ) ) );
        fi;
        nrad1:= Filtered( nrad1, x->Dimension(x)<>0 );
    
        nrad2:= [ L2 ];
        if not IsLieNilpotent( L2 ) then 
            Append( nrad2, LieLowerCentralSeries( LieNilRadical( L2 ) ) );
            Append( nrad2, LieUpperCentralSeries( LieNilRadical( L2 ) ) );
        fi;
        nrad2:= Filtered( nrad2, x->Dimension(x)<>0 );
    
        if List(nrad1,V->Dimension(V))<>List(nrad2,V->Dimension(V)) then
            return false;
        fi;
    
    if not IsLieNilpotent(L1) then

        HL1:= ProductSpace( H1, L1 );
        while Dimension(H1)+Dimension(HL1) > Dimension(L1) do
            HL1:= ProductSpace( H1, HL1 );
        od;
    
        adH1:= [ ];
        for i in BasisVectors(Basis(H1)) do
            mat:= List( BasisVectors(Basis(HL1)), 
                        x -> Coefficients( Basis(HL1), i*x ) );
            Add( adH1, TransposedMat( mat ) );
        od;
    
        HL2:= ProductSpace( H2, L2 );
        while Dimension(H2)+Dimension(HL2) > Dimension(L2) do
            HL2:= ProductSpace( H2, HL2 );
        od;
    
        adH2:= [ ];
        for i in BasisVectors(Basis(H2)) do
            mat:= List( BasisVectors(Basis(HL2)), 
                        x -> Coefficients( Basis(HL2), i*x ) );
            Add( adH2, TransposedMat( mat ) );
        od;
        
        Add( adH1, IdentityMat( Dimension(HL1), F ) );
        Add( adH2, IdentityMat( Dimension(HL2), F ) );
        A1:= Algebra( F, adH1 );
        A2:= Algebra( F, adH2 );
        
        if Dimension(A1)<>Dimension(A2) then return false; fi;
        
        R1:= RadicalOfAlgebra( A1 );
        R2:= RadicalOfAlgebra( A2 );
        
        if Dimension(R1)<>Dimension(R2) then return false; fi;
        
        B1:=A1/R1; B2:=A2/R2;
        
        C1:= CentralIdempotentsOfAlgebra( B1 );
        C2:= CentralIdempotentsOfAlgebra( B2 );
        if Length(C1)<>Length(C2) then return false; fi;
        Id1:=[];
        for i in C1 do
            b:= List( BasisVectors(Basis(B1)), x -> x*i );
            Add( Id1, Dimension( VectorSpace( F, b ) ) );
        od;
        
        Id2:=[];
        for i in C2 do
            b:= List( BasisVectors(Basis(B2)), x -> x*i );
            Add( Id2, Dimension( VectorSpace( F, b ) ) );
        od;
        
        for i in Id1 do
            if not i in Id2 then return false; fi;
        od;
        
    fi;

    if Dimension(Derivations(Basis(L1))) <> 
       Dimension(Derivations(Basis(L2))) then
        return false; 
    fi;

    cen1:=ShallowCopy(LieUpperCentralSeries(L1));
    cen2:=ShallowCopy(LieUpperCentralSeries(L2));
    Add(cen1,L1); Add(cen2,L2);
    
    if List(cen1,V->Dimension(V))<>List(cen2,V->Dimension(V)) then
        return false;
    fi;
    
    
    ser1:=Filtered(ser1,x->Dimension(x)<>0);
    ser2:=Filtered(ser2,x->Dimension(x)<>0);
    cen1:=Filtered(cen1,x->Dimension(x)<>0);
    cen2:=Filtered(cen2,x->Dimension(x)<>0);
    dser1:=Filtered(dser1,x->Dimension(x)<>0);
    dser2:=Filtered(dser2,x->Dimension(x)<>0);

   
    spaces1:=[];
    inds:=[];
    for i in [1..Length(dser1)] do
        for j in [1..Length(ser1)] do
            sp:=Intersection(dser1[Length(dser1)-i+1],ser1[Length(ser1)-j+1]);
            for k in [1..Length(cen1)] do
                sp1:=Intersection(sp,cen1[Length(cen1)-k+1]);
                for l in [1..Length(cart1)] do
                    sp2:= Intersection( sp1, cart1[l] );
                    for m in [1..Length(lev1)] do
                        sp3:= Intersection( sp2, lev1[m] );
                        for r in [1..Length(nrad1)] do
                            sp4:= Intersection( sp3, nrad1[r] );
                            if not sp4 in spaces1 and Dimension(sp4) <> 0 then 
                                Add(spaces1,sp4); 
                                Add(inds,[i,j,k,l,m,r]);
                            fi;
                        od; 
                    od;
                od;
            od;
        od;
    od;

    SortParallel( spaces1, inds, function(V1,V2) 
        return Dimension(V1)<Dimension(V2); end );

    spaces2:=[];
    for s in [1..Length(inds)] do
        i:=inds[s][1]; j:=inds[s][2]; k:=inds[s][3]; l:=inds[s][4]; 
        m:=inds[s][5]; r:=inds[s][6];
        sp:=Intersection(dser2[Length(dser2)-i+1],ser2[Length(ser2)-j+1]);
        sp1:= Intersection( sp, cen2[Length(cen2)-k+1] );
        sp2:= Intersection( sp1, cart2[l] );
        sp3:= Intersection( sp2, lev2[m] );
        sp4:= Intersection( sp3, nrad2[r] );
        Add(spaces2,sp4);
    od;

    bas1:=List(spaces1,V->BasisVectors(Basis(V)));
    bas2:=List(spaces2,V->BasisVectors(Basis(V)));

    if List(spaces1,x->Dimension(x))<>List(spaces2,x->Dimension(x)) then
        return false;
    fi;

# The next piece of code selects a minimal number of subspaces from
# 'bas1' and 'bas2' such that they span 'L1' and 'L2' respectively.

    b:=ShallowCopy(bas1[1]); sp:=VectorSpace(F,b); pp:=[1];
    for k in [2..Length(bas1)] do
        cont:=true;
        for l in [1..Length(bas1[k])] do
            if not bas1[k][l] in sp then 
                cont:=false; 
                Add(b,bas1[k][l]);
            fi;
        od;
        if not cont then
            Add(pp,k); sp:=VectorSpace(F,b);
        fi;
    od;
    bas1:=List(pp,ii->bas1[ii]);
    bas2:=List(pp,ii->bas2[ii]);
    
# After the next piece of code, 'bb1' will be a basis of 'L1' and 
# 'i1[k]' will be the index of the element of 'bas1' that contains
# 'bb1[k]' (similarly for 'bb2' and 'i2).
    
    bb1:=[]; bb2:=[];
    sp1:=VectorSpace(F,[Zero(L1)]); sp2:=VectorSpace(F,[Zero(L2)]);
    i1:=[]; i2:=[];
    for l in [1..Length(bas1)] do
        for k in [1..Length(bas1[l])] do
            x:=bas1[l][k];
            if not x in sp1 then Add(bb1,x); 
            sp1:=VectorSpace(F,bb1); Add(i1,l); fi;
            x:=bas2[l][k];
            if not x in sp2 then Add(bb2,x); 
            sp2:=VectorSpace(F,bb2); Add(i2,l); fi;
        od;
    od;
    
# The next statement ensures that all elements of 'bas1' contain elements of
# 'bb1'.
    
    bas1:=List(bas1,bb->filt(bb1,bb));
    bas2:=List(bas2,bb->filt(bb2,bb));

# Print the isomorphism...
if InfoLevel( InfoSingular )>=2 then

    sp := VectorSpace( F, [Zero(L1)] );
    b:=[];
    m:=0;
    for k in [1..Length(bas1)] do
        for l in [1..Length(bas1[k])] do
            x:=bas1[k][l];
            if not x in sp then
                Add(b,x);
                sp:=VectorSpace( F, b );
                m:=m+1;
                Print( x, " ---> " );
                for i in [1..Length(bas2[k])] do
                    j:= Position( bb2, bas2[k][i] );
                    Print( "x[",m,",",j,"](",bas2[k][i],") " );
                    if i<Length(bas2[k]) then Print("+ "); fi;
                od;
                Print("\n");
            fi;
        od;
    od;
    Print("\n");

fi;

    ii1:=List( bb1, x -> Position( BasisVectors(Basis(L1)), x ) ); 
    T1:=StructureConstantsTable(Basis(L1,bb1));
    T2:=StructureConstantsTable(Basis(L2,bb2));

    if T1 = T2  then
       return true;
    fi;

    vars:= [ ];
    for i in [1..Length(bas1)] do
        vars[i]:= "d"; Append( vars[i], String(i) );
    od;

    for i in [1..n] do
        for j in [1..n] do
            str:= "x"; Append( str, String( i ) ); Append( str, String( j ) );
            Add( vars, str );
        od;
    od;
    
    if S <> [ ] then
        for i in [1..npar] do
            str:= "a"; Append( str, String( i ) );
            Add( vars, str );
        od;
    fi;

    weights:= [ ];
    for i in [1..Length(bas1)] do
        Add( weights, Length(bas1[i]) );
    od;
    for i in [1..n^2] do Add( weights, 1 ); od;
    
    if S<>[] then
        for i in [1..npar] do Add( weights, 5 ); od;
    fi;
    
    R:= PolynomialRing( F, vars : old );
    indets:= IndeterminatesOfPolynomialRing( R );
#    varlist:=[a1,a2,a3];
    
    # `map' is used to identify the indeterminates used in the stringtabs,
    # with the indeterminates used in the ideal...
    map:= [ List( varlist, x -> ExtRepPolynomialRatFun(x)[1][1]),  
            List( indets{[Length(indets)-npar+1..Length(indets)]}, x -> 
            ExtRepPolynomialRatFun(x)[1][1]) ];      
    
# Construct the matrices of which the determinants must go into the ideal.
# variable x_{ij} has number Length(bas1)+ (i-1)*n +j
    
    d:=0; b:=[]; sp:=VectorSpace(F,[Zero(L1)]); mats:= [ ];
    for k in [1..Length(bas1)] do
        
        bass1:=Filtered(bas1[k],v-> not v in sp );
        l:=Length(bass1)+d;
        M:= List( [d+1..l], x -> [] );
        for i in [d+1..l] do
            for j in [d+1..l] do
                M[i-d][j-d]:= indets[Length(bas1)+(i-1)*n+j];
            od;
        od;
        Add( mats, M );
        d:=l; Append(b,bass1); sp:=VectorSpace(F,b);
    od;
    
    
# Get the generators of the ideal...
    
    I:= [ ];
 
    for k in [1..n] do
        ll1:=List(bas2[i2[k]],y->Position(bb2,y));
        
        for l in [1..k-1] do
            p:= Zero( R );
            ll2:=List(bas2[i2[l]],y->Position(bb2,y));
            for o in [1..n] do
                fl:=0;
                for j in [1..n] do
                    for m in [1..n] do
                        c:=cst(T2,[],j,m,o,0,0,0,map);
                        if c<>Zero(F) then
                            if j in ll1 and m in ll2 then
                                
                                p:= p+ c*indets[Length(bas1)+(k-1)*n+j]*
                                    indets[Length(bas1)+(l-1)*n+m];
                                fl:=1;
                            fi;
                        fi;  
                    od;
                od;
                for j in [1..n] do

                    c:=cst(T1,S,l,k,j,ii1[l],ii1[k],ii1[j],map);
                    ll3:=List(bas2[i2[j]],y->Position(bb2,y));
                    if c<>Zero(F) and o in ll3 then
                        p:=p+c*indets[Length(bas1)+(j-1)*n+o];
                        fl:=1;
                    fi;
                od;
                if fl=1 then
                    Add( I, p ); 
                    p:=Zero( R );
                fi;
            od;
        od;
    od;
    
    for k in [1..Length(bas1)] do   
        p:= indets[k]*DeterminantMat( mats[k] )-1;
        Add( I, p );
    od;
    
    return [R,I,weights];
    
end;



LieIsomorphismCharP := function(L1,L2,S,varlist)


    local   cst,  filt,  n,  F,  ser1,  ser2,  cen1,  cen2,  dser1,  dser2, 
#            H1,  cart1,  H2,  cart2,  lev1,  lev2,  
#            HL1,  adH1,  mat,  HL2,  adH2,  A1,  A2,  R1,  
#            R2,  B1,  B2,  C1,  C2,  Id1,  b,  Id2,  
            nrad1,  nrad2,  i,  b,  spaces1,  inds,  
            j,  sp,  k,  sp1,  l,  sp2,  m,  sp3,  r,  sp4,  spaces2,  
            s,  bas1,  bas2,  pp,  cont,  bb1,  bb2,  i1,  i2,  x,  
            ii1,  T1,  T2,  vars,  str,  weights,  R,  indets,  
            map,  d,  mats,  bass1,  M,  I,  ll1,  p,  ll2,  
            o,  fl,  c,  ll3, npar;

    npar:= Length( varlist );

    cst:=function(T,S,i,j,k,a,b,c,map)
  
        local   cij,  pos,  p,  ef,  l,  mon,  m;
        
        cij:=T[i][j];
        pos:=Position(cij[1],k);
        if pos=fail then
            return T[Length(T)];
        else 
            if S=[] then
                return cij[2][pos];
            else
                if Length( map[1] )>0 and not (S[a][b][c] in F
                         or IsRat(S[a][b][c]) )  then

                    # Here `p' is a polynomial in the variables used in
                    # stringtabs, we produce the same polynomial, but in
                    # the variables used in the ideal; it all boils down
                    # to renumbering of variables...
                    p:= ExtRepPolynomialRatFun( S[a][b][c] );
                    
                    ef:= [ ];
                    for l in [1,3..Length(p)-1] do
                        mon:= ShallowCopy( p[l] );
                        for m in [1,3..Length(mon)-1] do
                            pos:= Position( map[1], mon[m] );
                            mon[m]:= map[2][pos];
                        od;
                        Add( ef, mon );
                        Add( ef, p[l+1] );
                    od;
                    
                    return PolynomialByExtRep( FamilyObj( S[a][b][c] ), ef );
                else
                    return S[a][b][c];
                fi;
            fi;
        fi;
    end;

    filt:=function( b1, b2 )

        local sp;
        sp:=VectorSpace(F,b2);
        return Filtered(b1,y -> y in sp);
    end;
    
    n:=Dimension(L1);
    
    if n <> Dimension( L2 ) then return false; fi;
    
    F:=LeftActingDomain(L1);
    
    if F <> LeftActingDomain( L2 ) then return false; fi;
    
    if StructureConstantsTable( Basis( L1 ) ) =
       StructureConstantsTable( Basis( L2 ) )  then
       return true;
    fi;

    if Dimension(LieCentre(L1)) <> Dimension(LieCentre(L2))  then
      return false;
    fi;

    if Dimension(LieDerivedSubalgebra(L1))<>
      Dimension(LieDerivedSubalgebra(L2))  then
       return false;
    fi;

    ser1:=LieLowerCentralSeries(L1);
    ser2:=LieLowerCentralSeries(L2);
    
    if List(ser1,V->Dimension(V))<>List(ser2,V->Dimension(V)) then
        return false;
    fi;
    
    dser1:=LieDerivedSeries(L1);
    dser2:=LieDerivedSeries(L2);
    
    if List(dser1,V->Dimension(V))<>List(dser2,V->Dimension(V)) then
        return false;
    fi;
    
    nrad1:= [ L1 ];
    if not IsLieNilpotent( L1 ) then 
        Append( nrad1, LieLowerCentralSeries( LieNilRadical( L1 ) ) );
        Append( nrad1, LieUpperCentralSeries( LieNilRadical( L1 ) ) );
    fi;
    nrad1:= Filtered( nrad1, x->Dimension(x)<>0 );
    
    nrad2:= [ L2 ];
    if not IsLieNilpotent( L2 ) then 
        Append( nrad2, LieLowerCentralSeries( LieNilRadical( L2 ) ) );
        Append( nrad2, LieUpperCentralSeries( LieNilRadical( L2 ) ) );
    fi;
    nrad2:= Filtered( nrad2, x->Dimension(x)<>0 );
    
    if List(nrad1,V->Dimension(V))<>List(nrad2,V->Dimension(V)) then
        return false;
    fi;
    
    if Dimension(Derivations(Basis(L1))) <> 
       Dimension(Derivations(Basis(L2))) then
        return false; 
    fi;
   
    cen1:=ShallowCopy(LieUpperCentralSeries(L1));
    cen2:=ShallowCopy(LieUpperCentralSeries(L2));
    Add(cen1,L1); Add(cen2,L2);
    
    if List(cen1,V->Dimension(V))<>List(cen2,V->Dimension(V)) then
        return false;
    fi;
    
    
    ser1:=Filtered(ser1,x->Dimension(x)<>0);
    ser2:=Filtered(ser2,x->Dimension(x)<>0);
    cen1:=Filtered(cen1,x->Dimension(x)<>0);
    cen2:=Filtered(cen2,x->Dimension(x)<>0);
    dser1:=Filtered(dser1,x->Dimension(x)<>0);
    dser2:=Filtered(dser2,x->Dimension(x)<>0);
    

    spaces1:=[];
    inds:=[];
    for i in [1..Length(dser1)] do
        for j in [1..Length(ser1)] do
            sp:=Intersection(dser1[Length(dser1)-i+1],ser1[Length(ser1)-j+1]);
            for k in [1..Length(cen1)] do
                sp1:=Intersection(sp,cen1[Length(cen1)-k+1]);
                for r in [1..Length(nrad1)] do
                    sp4:= Intersection( sp1, nrad1[r] );
                    if not sp4 in spaces1 and Dimension(sp4) <> 0 then 
                        Add(spaces1,sp4); 
                        Add(inds,[i,j,k,r]);
                    fi;
                od; 
            od;
        od;
    od;

    SortParallel( spaces1, inds, function(V1,V2) 
        return Dimension(V1)<Dimension(V2); end );

    spaces2:=[];
    for s in [1..Length(inds)] do
        i:=inds[s][1]; j:=inds[s][2]; k:=inds[s][3]; r:=inds[s][4]; 
        
        sp:=Intersection(dser2[Length(dser2)-i+1],ser2[Length(ser2)-j+1]);
        sp1:= Intersection( sp, cen2[Length(cen2)-k+1] );
        sp4:= Intersection( sp1, nrad2[r] );
        Add(spaces2,sp4);
    od;

    bas1:=List(spaces1,V->BasisVectors(Basis(V)));
    bas2:=List(spaces2,V->BasisVectors(Basis(V)));

    if List(spaces1,x->Dimension(x))<>List(spaces2,x->Dimension(x)) then
        return false;
    fi;

# The next piece of code selects a minimal number of subspaces from
# 'bas1' and 'bas2' such that they span 'L1' and 'L2' respectively.

    b:=ShallowCopy(bas1[1]); sp:=VectorSpace(F,b); pp:=[1];
    for k in [2..Length(bas1)] do
        cont:=true;
        for l in [1..Length(bas1[k])] do
            if not bas1[k][l] in sp then 
                cont:=false; 
                Add(b,bas1[k][l]);
            fi;
        od;
        if not cont then
            Add(pp,k); sp:=VectorSpace(F,b);
        fi;
    od;
    bas1:=List(pp,ii->bas1[ii]);
    bas2:=List(pp,ii->bas2[ii]);
    
# After the next piece of code, 'bb1' will be a basis of 'L1' and 
# 'i1[k]' will be the index of the element of 'bas1' that contains
# 'bb1[k]' (similarly for 'bb2' and 'i2).

    bb1:=[]; bb2:=[];
    sp1:=VectorSpace(F,[Zero(L1)]); sp2:=VectorSpace(F,[Zero(L2)]);
    i1:=[]; i2:=[];
    for l in [1..Length(bas1)] do
        for k in [1..Length(bas1[l])] do
            x:=bas1[l][k];
            if not x in sp1 then Add(bb1,x); 
            sp1:=VectorSpace(F,bb1); Add(i1,l); fi;
            x:=bas2[l][k];
            if not x in sp2 then Add(bb2,x); 
            sp2:=VectorSpace(F,bb2); Add(i2,l); fi;
        od;
    od;
    
# The next statement ensures that all elements of 'bas1' contain elements of
# 'bb1'.
    
    bas1:=List(bas1,bb->filt(bb1,bb));
    bas2:=List(bas2,bb->filt(bb2,bb));

# Print the isomorphism...
if InfoLevel( InfoSingular )>=2 then
    
    sp := VectorSpace( F, [Zero(L1)] );
    b:=[];
    m:=0;
    for k in [1..Length(bas1)] do
        for l in [1..Length(bas1[k])] do
            x:=bas1[k][l];
            if not x in sp then
                Add(b,x);
                sp:=VectorSpace( F, b );
                m:=m+1;
                Print( x, " ---> " );
                for i in [1..Length(bas2[k])] do
                    j:= Position( bb2, bas2[k][i] );
                    Print( "x[",m,",",j,"](",bas2[k][i],") " );
                    if i<Length(bas2[k]) then Print("+ "); fi;
                od;
                Print("\n");
            fi;
        od;
    od;
    Print("\n");

fi;

    ii1:=List( bb1, x -> Position( BasisVectors(Basis(L1)), x ) ); 
# Ugly workaround for char p
# try LookUp( SmallLieAlgebra( GF(5), 5, 56 ) );
    while fail in ii1  do
        Print( "WARNING: using ugly workaround!\n", ii1 );
        ii1[Position( ii1, fail )]
         := Difference( [ 1 .. Length( ii1 ) ], ii1 )[1];
        Print( " --> ", ii1, "\n" );
    od;

    T1:=StructureConstantsTable(Basis(L1,bb1));
    T2:=StructureConstantsTable(Basis(L2,bb2));

    if T1 = T2  then
       return true;
    fi;

    vars:= [ ];
    for i in [1..Length(bas1)] do
        vars[i]:= "d"; Append( vars[i], String(i) );
    od;

    for i in [1..n] do
        for j in [1..n] do
            str:= "x"; Append( str, String( i ) ); Append( str, String( j ) );
            Add( vars, str );
        od;
    od;
    
    if S <> [ ] then
        for i in [1..npar] do
            str:= "a"; Append( str, String( i ) );
            Add( vars, str );
        od;
    fi;

    weights:= [ ];
    for i in [1..Length(bas1)] do
        Add( weights, Length(bas1[i]) );
    od;
    for i in [1..n^2] do Add( weights, 1 ); od;
    
    if S<>[] then
        for i in [1..npar] do Add( weights, 5 ); od;
    fi;
    
    R:= PolynomialRing( F, vars : old );
    indets:= IndeterminatesOfPolynomialRing( R );
#    varlist:=[a1,a2,a3];
    
    # `map' is used to identify the indeterminates used in the stringtabs,
    # with the indeterminates used in the ideal...
    map:= [ List( varlist, x -> ExtRepPolynomialRatFun(x)[1][1]),  
            List( indets{[Length(indets)-npar+1..Length(indets)]}, x -> 
            ExtRepPolynomialRatFun(x)[1][1]) ];      
    
# Construct the matrices of which the determinants must go into the ideal.
# variable x_{ij} has number Length(bas1)+ (i-1)*n +j
    
    d:=0; b:=[]; sp:=VectorSpace(F,[Zero(L1)]); mats:= [ ];
    for k in [1..Length(bas1)] do
        
        bass1:=Filtered(bas1[k],v-> not v in sp );
        l:=Length(bass1)+d;
        M:= List( [d+1..l], x -> [] );
        for i in [d+1..l] do
            for j in [d+1..l] do
                M[i-d][j-d]:= indets[Length(bas1)+(i-1)*n+j];
            od;
        od;
        Add( mats, M );
        d:=l; Append(b,bass1); sp:=VectorSpace(F,b);
    od;
    
    
# Get the generators of the ideal...
    
    I:= [ ];
 
    for k in [1..n] do
        ll1:=List(bas2[i2[k]],y->Position(bb2,y));
        
        for l in [1..k-1] do
            p:= Zero( R );
            ll2:=List(bas2[i2[l]],y->Position(bb2,y));
            for o in [1..n] do
                fl:=0;
                for j in [1..n] do
                    for m in [1..n] do

                        c:=cst(T2,[],j,m,o,0,0,0,map);
                        if c<>Zero(F) then
                            if j in ll1 and m in ll2 then
                                p:= p+ c*indets[Length(bas1)+(k-1)*n+j]*
                                    indets[Length(bas1)+(l-1)*n+m];
                                fl:=1;
                            fi;
                        fi;  
                    od;
                od;
                for j in [1..n] do

                    c:=cst(T1,S,l,k,j,ii1[l],ii1[k],ii1[j],map);
                    ll3:=List(bas2[i2[j]],y->Position(bb2,y));
                    if c<>Zero(F) and o in ll3 then
                        p:=p+c*indets[Length(bas1)+(j-1)*n+o];
                        fl:=1;
                    fi;
                od;
                if fl=1 then
                    Add( I, p );
                    p:=Zero(R);
                fi;
            od;
        od;
    od;
    
    for k in [1..Length(bas1)] do   
        p:= indets[k]*DeterminantMat( mats[k] )-1;
        Add( I, p );
    od;
    
    return [R,I,weights];
    
end;


LookUp:= function( L )

    local F,i,K,file,n,lst,slist,look,ff,dd,pb,G,
          lie_tables, varlist,
          gens, pol, eli, roots;

    dd:= DirectSumDecomposition(L);
    if Length(dd)>1 then
        Print("Perform a direct sum decomposition first\n");
        Print("using the function DirectSumDecomposition\n");
        Print("and try to identify the direct summands.\n");
    else 
        F:=LeftActingDomain(L);
        n:= Dimension(L);
        if n=0 or n=1 then 
            # the Lie algebra is the unique 0- or 1-dimensional Lie algebra
            return 1;
        fi; 

        lie_tables:= LieTables( F, n, [] );
        lst:= lie_tables[1]; 
        slist:= lie_tables[2]; 
        varlist:= lie_tables[3];

        Info(InfoSingular, 2, "Looking for L in the list dim", n );
        for i in [1..Length(lst)] do
            if StructureConstantsTable(Basis(L)) = lst[i] then
                return i;
            fi;
            K:= LieAlgebraByStructureConstants(F, lst[i]);
            if Characteristic( F ) = 0 then
                pb:=LieIsomorphism( K, L, slist[i], varlist);
            else
                pb:=LieIsomorphismCharP( K, L, slist[i], varlist);
            fi;
            if IsList( pb ) then
                if not HasTrivialGroebnerBasis (Ideal( pb[1], pb[2] )) then 


# The following is experimental code that suggests the value of the
# parameter for a Lie algebra isomorphic to one in a one-parameter family
# of Lie algebras.

                    if Length( slist[i] )>1 and Length( varlist ) = 1  then
                        gens := GeneratorsOfLeftOperatorRingWithOne( pb[1] );

# the other indeterminates (not the parameter) are the following
                        pol := Product( gens{[ 1 .. Length( gens ) - 1 ]} );

# the other indeterminates are eliminated by Singular
                        pol := ParseGapPolyToSingPoly( pol );
                        eli := SingularInterface( "eliminate",
                           Concatenation( "GAP_groebner, ", pol ), "ideal" );

                        gens := GeneratorsOfTwoSidedIdeal( eli );
                        if Length( gens ) = 1 and
                           IsUnivariatePolynomial( gens[1] ) and
                           Degree( gens[1] ) <> 0 and
                           Degree( gens[1] ) <> infinity  then

# We have an equation in the parameter
                            roots := RootsOfUPol( F, gens[1] );
                            if Length(roots) <> 0 then
                              Print( "PARAMETER: one in ", roots, "\n" );
                            else

# maybe the parameter is not in the underlying field of the algebra
# in this case the algebras are only "weakly" isomorphic!

                              roots := RootsOfUPol( "split",gens[1] );
                              Print( "PARAMETER: (in splitting field) one in ",
                                      roots, "\n" );
                            fi;

                        fi;
                    fi;

# end of experimental code


                    return i;
                fi;
            elif pb = true then 
                return i;
            fi;
        od;
        if TestJacobi(StructureConstantsTable(Basis(L)))<> true then
              return "not a Lie algebra (TestJacobi) ";
        elif not ForAll( List( Basis(L), x->x*x ), x->x=Zero(L) ) then
              return "not a Lie algebra (IsZeroSquaredRing) ";
        fi;
        return fail;
    fi;
end;



Compare := function ( L, n )
# This function compares the Lie algebra L with the n-th element of the 
# data of the Lie algebras, and return the ideal in which the Groebner
# basis can be calculated.
    local  F, d, s, K, pb;
    F := LeftActingDomain( L );
    d := Dimension( L );
    s := LieTables( F, d, [  ] );
    K := LieAlgebraByStructureConstants( F, s[1][n] );
    if Characteristic( F ) = 0  then
        pb := LieIsomorphism( K, L, s[2][n], s[3] );
    else
        pb := LieIsomorphismCharP( K, L, s[2][n], s[3] );
    fi;
    return pb;
end;



AreIsomorphic:=function( K, L )
    
    # Test whether the Lie algebras K, L are isomorphic.
    
    local   char,  pb;
    
    char:= Characteristic( LeftActingDomain( K ) );

    if char = 0 then
        pb:=LieIsomorphism( K, L, [], []);
    else
        pb:=LieIsomorphismCharP( K, L, [], []);
    fi;
    
    if IsList( pb ) then
        return not HasTrivialGroebnerBasis( Ideal( pb[1], pb[2] ) );
    else
        return pb;
    fi;
    
    
end;



AreSimilar:=function( K, L )

    # Test whether the Lie algebras K, L are similar.

    local   char,  pb;

    char:= Characteristic( LeftActingDomain( K ) );

    if char = 0 then
        pb:=LieIsomorphism( K, L, [], []);
    else
        pb:=LieIsomorphismCharP( K, L, [], []);
    fi;

    if IsList( pb ) then
        return true;
    else
        return pb;
    fi;


end;

