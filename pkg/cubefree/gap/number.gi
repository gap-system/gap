#############################################################################
##
#W  number.gi           Cubefree                               Heiko Dietrich
##                                                              
#H   @(#)$Id: number.gi,v 1.2 2007/05/08 07:58:50 gap Exp $
##


##############################################################################
##
#F  NumberCFSolvableGroups( arg )
##
## Counts the number of all cubefree solvable groups using the one-to-one
## correspondence. If the argument is [size,false] then the SmallGrps
## library is not used. If the argument is 'size' or [size,true] then
## it will be used.
##
InstallGlobalFunction(NumberCFSolvableGroups, function( arg ) 
    local smallGrp, size, number, cl, i,j, FOrders, F;

    # check
    if Size(arg)=1 then
        size     := arg[1];
        smallGrp := true;
    elif Size(arg)=2 then
        size     := arg[1];
        smallGrp := arg[2];
    else
        Error("Wrong input format: Either arg='size' or arg='size,bool'.\n");
    fi;
    if not IsBool(smallGrp) then
        Error("Second argument has to be Boolean.\n");
    fi;
    if not (IsInt( size ) and size>0) then
        Error("First argument has to be a positive  integer.\n");
    elif not IsCubeFreeInt( size ) then
        Error("First argument has to be a cube-free integer.\n"); 
    fi;

    Info(InfoCF,2,"    Count number of solvable groups of order ",size,".");

    if size = 1 then
        return 1;
    fi;

    # Squarefree groups are Frattini-free and solvable
    if IsSquareFreeInt(size) then
        return NumberSmallGroups(size);
    fi;

    cl := Product(List(Collected(FactorsInt(size)),x->x[1]));
   
    # Count all cube-free Frattini-free solvable groups F with
    # cl | |F| | size
    FOrders := Filtered(DivisorsInt(size),x-> x mod cl =0);
    number  := 0;
    for F in FOrders do
        if smallGrp and F<50001 then
	    if IsOddInt(F) then
                i := Size(Filtered([1..NumberSmallGroups(F)], x->
                      FrattinifactorSize(SmallGroup(F,x))= F));
	    else
                i := Size(Filtered([1..NumberSmallGroups(F)], x->
                      FrattinifactorSize(SmallGroup(F,x))= F and
		      IsSolvable(SmallGroup(F,x)) ));
            fi;
                number := number + i;
        else
            number := number + Size( cf_FrattFreeSolvGroups(F) );
        fi;;
    od;
    
    return number;
end);




##############################################################################
##
#F  NumberCFGroups( size )
##
## Counts all groups of cube-free order n. If the argument is [size,false]
## then the SmallGrps library is not used. If the argument is 'size' or 
## [size,true] then the SmallGroups library will be used.
##
InstallGlobalFunction(NumberCFGroups, function( arg ) 
    local nonAb, solvff, number, i, A, l, p, G, cl, FOrders, F, Fcl, psl, I,
          size, smallGrp;

    # check
    if Size(arg)=1 then 
        size     := arg[1];
        smallGrp := true;
    elif Size(arg)=2 then
        size     := arg[1];
        smallGrp := arg[2];
    else
        Error("Wrong input format: Either arg='size' or arg='size,bool'.\n");
    fi;
    if not IsBool(smallGrp) then
        Error("Second argument has to be Boolean.\n");
    fi;
    if not (IsInt( size ) and size>0) then
        Error("First argument has to be a positive integer.\n");
    elif not IsCubeFreeInt( size ) then
        Error("First argument has to be a cube-free integer.\n"); 
    fi;
  
    Info(InfoCF,1,"Count number of groups of order ",size,".");

    if size = 1 then
        return 1;
    fi;

    if (size <50001 and smallGrp) or IsSquareFreeInt(size) then
        return NumberSmallGroups(size);
    fi;

    # determine possible non-abelian factors
    cl     := List(Collected(FactorsInt(size)),x->x[1]);
    cl     := Filtered(cl, x-> IsCubeFreeInt(x-1) and IsCubeFreeInt(x+1)
                                  and x>3);
    nonAb  := List( cl, x-> x*(x-1)*(x+1)/2);
    nonAb  := Filtered(nonAb, x-> size mod x=0);
    nonAb  := Concatenation([1],nonAb);
    number := 0;
   
    for A in nonAb do
        number := number + NumberCFSolvableGroups( size/A,smallGrp );
    od;

   return(number);
end);
