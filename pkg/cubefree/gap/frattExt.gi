#############################################################################
##
#W  frattExt.gi           Cubefree                             Heiko Dietrich
##                                                               
#H   @(#)$Id: frattExt.gi,v 1.2 2007/05/08 07:58:50 gap Exp $
##


##
## These functions determine the  Frattini extensions. 
## Basically, already implemented methods of the GAP Package GrpConst are
## used.
##

############################################################################# 
## 
#F FrattiniExtensionCF( code, o ) 
## 
## Computes the Frattini extensions of the group given by 'code' of order 'o'
InstallGlobalFunction(FrattiniExtensionCF, function( code, o ) 
    local F, rest, primes, modus, H, i, modul, found, j, M, cc, c; 
 
    Info(InfoCF,1,"Computes Frattini extension.");

    # get F and the trivial case 
    F      := PcGroupCodeRec( code ); 
    rest   := o / code.order; 
    if rest = 1 then return F; fi; 
 
    # construct irreducible modules for F 
    primes := Factors( rest ); 
    modus  := List( primes, x -> IrreducibleModules( F, GF(x), 1 )[2] ); 
    FindUniqueModules( modus ); 
 
    # set up 
    H := PcGroupCodeRec( code ); 
 
    # loop over primes 
    for i in [1..Length(primes)] do 
        modul := List( modus[i], x -> EnlargedModule( x, F, H ) ); 
        found := false; 
        j := 0; 
        while not found do 
            j := j+1; 
            M := modul[j]; 
            cc := TwoCohomology( H, M ); 
            if Dimension( Image( cc.cohom ) ) > 0 then 
                c := PreImagesRepresentative( cc.cohom, 
                                      Basis(Image(cc.cohom))[1]); 
                H := ExtensionSQ( cc.collector, H, M, c ); 
                found := true; 
            fi; 
        od; 
    od; 
    return H; 
end); 
 
############################################################################# 
## 
#F ConstructAllCFGroups( size ) 
## 
## Computes all cube-free groups of order n up to isomorphism
##
InstallGlobalFunction(ConstructAllCFGroups, function ( size ) 
    local cl, free, ext, t, primes, ffOrd, lv, nonAb, p, A, nSize, facNSize,
          groups, arg1, arg2; 
 
    Info(InfoCF,1,"Construct all groups of order ",size,".");   

    # check
    if not IsPosInt( size ) or not IsCubeFreeInt( size ) then
        Error("Argument has to be a positive cube-free integer.\n"); 
    fi;

    # catch the case of size = 1 
    if size = 1 then 
        return [TrivialGroup()]; 
    fi; 
  
    # if size is square-free, then the groups of order size
    # are Frattini-free and solvable
    if IsSquareFreeInt(size) then
        return(List(cf_FrattFreeSolvGroups(size),x->PcGroupCodeRec(x)));
    fi;

    # set up
    groups := [];
    cl     := Collected( Factors( size ) ); 

    # determine the possible non-abelian factors PSL(2,p)
    nonAb:=[TrivialGroup()];
    for p in cl do
        arg1 := (p[1]>3) and (size mod (p[1]*(p[1]-1)*(p[1]+1) / 2)=0);
        arg2 := IsCubeFreeInt(p[1]+1) and IsCubeFreeInt(p[1]-1);
        if arg1 and arg2 then
            if Size(PSL(2,p[1]))=size then
                Add(groups,PSL(2,p[1]));
            else
                Add(nonAb,PSL(2,p[1]));
            fi;
        fi;
    od;

    # for every non-abelian A compute a solvable complement
    for A in nonAb do
        nSize    := size/Size(A);
        facNSize := Collected(FactorsInt(nSize));    
 
        # determine the possible Frattini-factors
        primes := Product(List(facNSize,x->x[1]));
        ffOrd  := Filtered(DivisorsInt(nSize),x-> x mod primes =0);
        free   := [];
        for lv in ffOrd do
            free := Concatenation(free,cf_FrattFreeSolvGroups(lv));
        od;
        ext    := List(free,x -> FrattiniExtensionCF(x,nSize)); 
        groups := Concatenation(groups,List(ext,x->DirectProduct(A,x)));
    od;

    return groups; 
end ); 
 
############################################################################# 
## 
#F ConstructAllCFSolvableGroups( size ) 
## 
## Computes all cube-free solvable groups of order n up to isomorphism
##
InstallGlobalFunction(ConstructAllCFSolvableGroups, function ( size ) 
    local cl, free, ext, t, primes, ffOrd, lv, p, groups; 

    # check
    if not IsPosInt( size ) or not IsCubeFreeInt( size ) then
        Error("Argument has to be a positive cube-free integer.\n"); 
    fi;

    Info(InfoCF,1,"Construct all solvable groups of order ",size,".");

    # catch the case of size = 1 
    if size = 1 then 
        return [TrivialGroup()]; 
    fi; 
  
    # if size is square-free, then the groups of order size
    # are Frattini-free and solvable
    if IsSquareFreeInt(size) then
        return(List(cf_FrattFreeSolvGroups(size),x->PcGroupCodeRec(x)));
    fi;

    # set up
    groups := [];
    cl     := Collected( Factors( size ) );  
 
    # determine the possible Frattini-factors
    primes := Product(List(cl,x->x[1]));
    ffOrd  := Filtered(DivisorsInt(size),x-> x mod primes =0);
    free   := [];
    for lv in ffOrd do
        free := Concatenation(free,cf_FrattFreeSolvGroups(lv));
    od;
    ext    := List(free,x -> FrattiniExtensionCF(x,size)); 
    groups := Concatenation(groups,ext);
    
    return groups; 
end );  



