#############################################################################
##
#W  Central.gi               FGA package                    Christian Sievers
##
##  Method installations for centralizers in free groups
##
#H  @(#)$Id: Central.gi,v 1.2 2003/08/06 16:24:48 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/Central_gi") :=
    "@(#)$Id: Central.gi,v 1.2 2003/08/06 16:24:48 gap Exp $";


#############################################################################
##
#M  CentralizersOp( <group>, <elm> )
##
InstallMethod( CentralizerOp,
    "for an element in a free group",
    IsCollsElms,
    [ IsFreeGroup, IsElementOfFreeGroup ],
    function(G,g)
        local i, l, len, div, w, f, p, pp, c;

        if g=One(G) then
            return G;
        fi;

        w := LetterRepAssocWord(g);
        i := 1;
        l := Length(w);

        while w[i] = -w[l] do
            i := i+1;
            l := l-1;
        od;

        len := l-i+1;

        pp := PrimePowersInt(len);
        f  := 1;

        while f<Length(pp) do
            div := pp[f];
            p   := pp[f+1];
            while p > 0 and 
                  w{[i..i+len-(len/div)-1]} = w{[i+len/div..i+len-1]} do
                len := len/div;
                p   := p-1;
            od;
            f := f+2;
        od;

#       return Group(AssocWordByLetterRep(FamilyObj(g), w{[i..i+len-1]})^
#                    AssocWordByLetterRep(FamilyObj(g), w{[l+1..Length(w)]}) );

        c := FindPowLetterRep(G, w{[1..i-1]}, w{[i..i+len-1]},
                                 w{[l+1..Length(w)]} );
        if c = fail then
            return TrivialSubgroup(G);
        else
            return Group(c);
        fi;
    end );

#############################################################################
##
#M  CentralizerOp( <group>, <subgroup> )
##
InstallMethod( CentralizerOp,
    "for a subgroup of a free group",
    IsIdenticalObj,
    [ IsFreeGroup, IsFreeGroup ],
    function(F,G)
    local r;
    r := RankOfFreeGroup(G);
    if r >= 2 then
        return TrivialSubgroup(F);
    elif r = 1 then
        return Centralizer(F, FreeGeneratorsOfGroup(G)[1]);
    else    # (r = 0)
        return F;
    fi;
    end );


#############################################################################
##
#E
