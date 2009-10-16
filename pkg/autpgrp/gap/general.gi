#############################################################################
##
#W  general.gi               AutPGrp package                     Bettina Eick
##
#H  @(#)$Id: general.gi,v 1.4 2009/08/31 07:40:15 gap Exp $
##
Revision.("autpgrp/gap/general_gi") :=
    "@(#)$Id: general.gi,v 1.4 2009/08/31 07:40:15 gap Exp $";

#############################################################################
##
#F Interrupt
##
Interrupt := function(text)
    local str, ans;
    Print("\n",text);
    Print(": \c");
    str := InputTextUser();
    ans := ReadLine(str);
    ans := ans{[1..Length(ans)-1]};
    Print("\n");
    return ans;
end;

#############################################################################
##
#F RewriteDef( pcgs, defn, p )
##
RewriteDef := function( pcgs, defn, p )
    local words, i, d, e, w;
    words := [];
    for i in [1..Length(defn)] do
        d := defn[i];
        if IsNegRat( d ) then
            Add( words, d );
        elif IsInt( d ) then
            w := pcgs[d]^p;
            e := ExponentsOfPcElement( pcgs, w );
            e[i] := 0;
            Add( words, [d, e] );
        elif IsList( d ) then
            w := Comm( pcgs[d[1]], pcgs[d[2]] );
            e := ExponentsOfPcElement( pcgs, w );
            e[i] := 0;
            Add( words, [d, e] );
        fi;
    od;
    return words;
end;

#############################################################################
##
#F SubstituteDef( def, gens, p )
##
SubstituteDef := function( def, gens, p )
   local i, e;

   # definition part
   if IsInt( def ) then
       return gens[-def];
   elif IsInt( def[1] ) then
       e := gens[def[1]]^p;
   else
       e := Comm( gens[def[1][1]], gens[def[1][2]] );
   fi;

   # tail part
   for i in [1..Length(def[2])] do
       if def[2][i] <> 0 then
           e := gens[i]^-def[2][i] * e;
       fi;
   od;
   return e;
end;

#############################################################################
##
#F DepthVector( vec )
##
#DepthVector := function( vec )
#    local i;
#    for i in [1..Length(vec)] do
#        if vec[i] <> 0 * vec[i] then
#            return i;
#        fi;
#    od;
#    return Length(vec) + 1;
#end;

#############################################################################
##
#F InducedPcgsByBasis( pcgs, basis )
##
InducedPcgsByBasis := function( pcgs, basis )
    local pcgsN, pcgsM, seq, pcs;
    pcgsN := NumeratorOfModuloPcgs( pcgs );
    pcgsM := DenominatorOfModuloPcgs( pcgs );
    seq   := List( basis, b -> PcElementByExponents( pcgs, b ) );
    pcs   := InducedPcgsByPcSequenceAndGenerators( pcgsN, pcgsM, seq );
    return InducedPcgsByPcSequenceNC( pcgsN, pcs );
end;

#############################################################################
##
#F IsHomoCyclic( G )
##
IsHomoCyclic := function( G )
    return IsAbelian(G) and Length(Set(AbelianInvariants(G))) = 1;
end;

#############################################################################
##
#F FrattiniQuotientPGroup( G )
##
FrattiniQuotientPGroup := function( G )
    local spec, firs, frat, H;
    spec := SpecialPcgs(G);
    firs := LGFirst(spec);
    frat := InducedPcgsByPcSequenceNC( spec, spec{[firs[2]..Length(spec)]});
    H := GroupByPcgs( spec mod frat );
    SetIsPGroup(H, true );
    SetPrimePGroup( H, PrimePGroup(G) );
    SetRankPGroup( H, firs[2] - 1 );
    H!.definitions := List( [1..firs[2]-1], x -> -x );
    return H;
end;

#############################################################################
##
#F InitGlAutos( H, mats )
##
InitGlAutos := function( H, mats )
    local pcgs;
    pcgs := Pcgs(H);
    return List( mats, x -> PGAutomorphism( H, pcgs, List( x, 
                       y -> PcElementByExponents( pcgs, y) ) ) );
end;

#############################################################################
##
#F InitAgAutos( H, p )
##
InitAgAutos := function( H, p )
    local pcgs, auts, alpha, fac, i, imgs;
    if p <> 2 then
        pcgs  := Pcgs(H);
        auts  := [];
        alpha := PrimitiveRoot( GF(p) );
        fac   := Factors( p - 1 );
        for i in [1..Length(fac)] do
            imgs := List( pcgs, x-> x^IntFFE( alpha ) );
            Add( auts, PGAutomorphism( H, pcgs, imgs ) );
            alpha := alpha ^ fac[i];
        od;
        return rec( auts := auts, rels := fac );
    else
        return rec( auts := [], rels := [] );
    fi;
end;

#############################################################################
##
#F EcheloniseMat( mat )
##
InstallGlobalFunction( EcheloniseMat,
  function( mat )
    local ech, tmp, i;

    if Length(mat) = 0 then return mat; fi;
    ech := SemiEchelonMat( mat );
    tmp := [];
    for i in [1..Length(ech.heads)] do
        if ech.heads[i] <> 0 then
            Add( tmp, ech.vectors[ech.heads[i]] );
        fi;
    od;
    return tmp;
  end);

#############################################################################
##
#F SumMat( mat1, mat2 )
##
SumMat := function( mat1, mat2 )
    local tmp;
    tmp := Concatenation( mat1, mat2 );
    tmp := EcheloniseMat( tmp );
    TriangulizeMat(tmp);
    return tmp;
end;

