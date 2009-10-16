#############################################################################
##
#A  tblgener.gi             GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
##
##  Table generation
##
#H  @(#)$Id: tblgener.gi,v 1.4 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/tblgener_gi") :=
    "@(#)$Id: tblgener.gi,v 1.4 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  CreateBoundsTable( <Sz>, <q> [, <info> ] ) . . constructs table of bounds
##
InstallMethod(CreateBoundsTable, "Sz, fieldsize, info", true, 
	[IsInt, IsInt, IsBool], 0, 
function(Sz, q, info) 
    local RulesList, LBT, UBT, FillPoints, NumberUnchanged, RuleNumber, file,
          WriteToFile, InitialTable, help, temp;

    help := 
      Concatenation("\n##\n",
              "##  Each entry [n][k] of one of the tables below contains\n",
              "##  a bound (the first table contains lowerbounds, the   \n",
              "##  second upperbounds) for a code with wordlength n and \n",
              "##  dimension k. Each entry contains one of the following\n",
              "##  items:                                               \n",
              "##                                                       \n",
              "##  FOR LOWER- AND UPPERBOUNDSTABLE                      \n",
              "##  [ 0, <d>, <ref> ]  from Brouwers table               \n",
              "##                                                       \n",
              "##  FOR LOWERBOUNDSTABLE                                 \n",
              "##  empty        k= 0, 1, n or d= 2 or (k= 2 and q= 2)   \n",
              "##  1            shortening a [ n + 1, k + 1 ] code      \n",
              "##  2            puncturing a [ n + 1, k ] code          \n",
              "##  3            extending a [ n - 1, k ] code           \n",
              "##  [ 4, <dd> ]  constr. B, of a [ n+dd, k+dd-1, d ] code\n",
              "##  [ 5, <k1> ]  an UUV-construction with a [ n / 2, k1 ]\n",
              "##               and a [ n / 2, k - k1 ] code            \n",
              "##  [ 6, <n1> ]  concatenation of a [ n1, k ] and a      \n",
              "##               [ n - n1, k ] code                      \n",
              "##  [ 7, <n1> ]  taking the residue of a [ n1, k + 1 ] code\n",
              "##                                                       \n",
              "##  FOR UPPERBOUNDSTABLE                                 \n",
              "##  empty        Griesmer bound                          \n",
              "##  11           shortening a [ n + 1, k + 1 ] code      \n",
              "##  12           puncturing a [ n + 1, k ] code          \n",
              "##  13           extending a [ n - 1, k ] code           \n",
              "##  [ 14, <dd> ] constr. B, with dd = dual distance      \n");


    InitialTable := function(to, lb)
        local n, k, d, i, j, sum, BT;
        BT := List([1..to], i-> [[i]]);      #RepetitionCodes
        for k in [2 .. to] do
            BT[k][k] := [1];         #WholeSpaceCode
            for n in [k+1 .. to] do
                if lb then
                    BT[n][k] := [2];
                else #upperbound
                    # Calculate Griesmer bound (for linear codes only)
                    # n >= Sum([0..k-1],i->DivUp(d,q^i));
                    d := BT[n-1][k][1] + 1;
                    sum := 0;
                    i := 1;
                    j := 1;
                    while j <= k do
                        # Calculate one term
                        sum := sum + QuoInt(d, i) + SignInt(d mod i);
                        i := i * q;
                        if i >= d then
                            # the rest will be one
                            sum := sum + k - j;
                            j := k;
                        fi;
                        j := j + 1;
                    od;
                    if sum <= n then
                        BT[n][k] := [d];
                    else
                        BT[n][k] := [d - 1];
                    fi;
                fi;
            od;
            if q = 2 and k > 2 then     #CordaroWagnerCode
                BT[k][2] := [ 2*Int( (k+1) / 3 ) - Int(k mod 3 / 2 ) ];
            fi;
        od;
        return BT;
    end;
    
    FillPoints := function( BT, lb )
        local pt, initialfile;
        GUAVA_TEMP_VAR := [false];
        if lb then
            initialfile := Filename(LOADED_PACKAGES.guava, 
									Concatenation("tbl/codes", 
												   String(q),".g") );
        else
            initialfile := Filename(LOADED_PACKAGES.guava, 
									Concatenation("tbl/upperbd",
												   String(q),".g") );
        fi;
        if initialfile = fail then
            Error("no table around for GF(",String(q),")");
        fi;
        if GUAVA_TEMP_VAR[1] = false then
            GUAVA_TEMP_VAR := GUAVA_TEMP_VAR{[ 2 .. Length(GUAVA_TEMP_VAR) ]};
        fi;
        for pt in GUAVA_TEMP_VAR do
            if (pt[1] <= Sz) and (pt[2] <= pt[1]) and
               ((lb      and pt[3] > BT[pt[1]][pt[2]][1]) or
               ((not lb) and pt[3] < BT[pt[1]][pt[2]][1])) then
                BT[pt[1]][pt[2]] := [pt[3], [ 0, pt[3], pt[4] ] ];
            fi;
        od;
        return BT;
    end;
        
    WriteToFile := function(BT)
        local list, k, n;
        Print(Concatenation( "][", String(q), "] := [\n#V   n = 1\n[  ]" ) );
        for n in [2 .. Sz] do
            list := [];
            for k in [1 .. n] do
                if Length( BT[n][k] ) = 2 then
                    list[k] := BT[n][k][2];
                fi;
            od;
            Print(Concatenation(",\n#V   n = ",String(n),"\n"), list);
        od;
        Print("];");
    end; 
#F              begin of rules for lowerbound

    RulesList := [];

# If a rule is added which is only valid for a special q (like q=2) the
# check for q should be around the Add(RulesList, function()....) :
# if q=2 then Add(RulesList, function() .... end); fi;

    # Extending
    Add(RulesList, function()
        local n, k, number;
        number := 0;
        for n in [1..Sz-1] do
            for k in [1..n] do
                if q=2 and IsOddInt(LBT[n][k][1]) then
                    if LBT[n+1][k][1] < LBT[n][k][1] + 1 then
                        LBT[n+1][k] := [LBT[n][k][1] + 1, 3 ];
                        number := number + 1;
                    fi;
                else
                    if LBT[n+1][k][1] < LBT[n][k][1] then
                        LBT[n+1][k] := [LBT[n][k][1], 3 ];
                        number := number + 1;
                    fi;
                fi;
            od;
        od;
        if info then Print(number," changes with Extending\n" ); fi;
        return number > 0;
    end);
    
    # UUV Construction
    Add(RulesList, function()
        local n, k1, k2, d, d1, number;
        number := 0;
        for n in [ 3 .. Int( Sz / 2 ) ] do
            for k1 in [ 1 .. n-2 ] do           # V is a ( n, k1, d1 )-code
                d1 := LBT[n][k1][1];
                for k2 in [ k1+1 .. n-1 ] do    # U is a ( n, k2, d2 )-code
                    d := 2 * LBT[n][k2][1];
                    if d1 < d  then d := d1;  fi; #faster then Minimum();
                    if LBT[2 * n][k1 + k2][1] < d then
                        LBT[2 * n][k1 + k2] := [d, [5, k2] ];
                        number := number + 1;
                    fi;
                od;
            od;
        od;
        if info then Print(number," changes with UUV\n" ); fi;
        return (number > 0);
    end);
    
    # Concatenation
    Add(RulesList, function()
        local n1, n2, k, d, number;
        number := 0;
        for k in [ 2 .. Sz ] do
            for n1 in [ k .. Int( Sz / 2 ) ] do
                for n2 in [ n1 .. Sz - n1 ] do
                    d := LBT[n1][k][1] + LBT[n2][k][1];
                    if LBT[n1 +  n2][k][1] < d then
                        LBT[n1 + n2][k] := [d, [6, n1 ] ];
                        number := number + 1;
                    fi;
                od;
            od;
        od;
        if info then Print(number," changes with Concatenation\n" ); fi;
        return number > 0;
    end);
    
    # Puncturing
    Add( RulesList, 
         function()
        local n, k, number;
        number := 0;
        for n in Reversed([2..Sz]) do
            for k in [1..n-1] do
                if LBT[n-1][k][1] < LBT[n][k][1] - 1 then
                    LBT[n-1][k] := [LBT[n][k][1] - 1, 2 ];
                    number := number + 1;
                fi;
            od;
        od;
        if info then Print(number," changes with Puncturing\n" ); fi;
        return (number > 0);
    end);
    
    # Shortening
    Add(RulesList,
        function()
        local n, k, number;
        number := 0;
        for n in Reversed([5 .. Sz]) do
            for k in [3 .. n-2] do
                if LBT[n-1][k-1][1] < LBT[n][k][1] then
                    LBT[n-1][k-1] := [LBT[n][k][1], 1 ];
                    number := number + 1;
                fi;
            od;
        od;
        if info then Print(number," changes with Shortening\n" ); fi;
        return (number > 0);
    end);
        
    # Taking the residue
    Add(RulesList, function()
        local n, k, temp, d, dnew, number;
        number := 0;
        for n in Reversed([ 4 .. Sz ]) do
            temp := LBT[n];
            for k in [ 3 .. n - 1 ] do
                d := temp[k][1];
                dnew := QuoInt(d,q)+SignInt(d mod q);# = (d/q) rounded up
                if ( n - d > k ) and (LBT[ n - d ][ k - 1 ][1] < dnew) then
                    LBT[ n - d ][ k - 1 ] := [ dnew, [ 7, n ] ];
                    number := number + 1;
                fi;
            od;
        od;
        if info then Print(number," changes with Residue\n" ); fi;
        return number > 0;
    end);
    
    # Construction B: M&S, Ch. 18, P. 9, Pg. 592
    Add(RulesList, function()
        local n, k, dd, number;
        number := 0;
        for n in Reversed([2..Sz]) do
            for k in Reversed([1..n-1]) do
                dd := UBT[n][n-k][1];     # upper bound for dual distance
                if n-dd > 0 and k-dd+1 > 0 and
                   LBT[n-dd][k-dd+1][1] < LBT[n][k][1] then
                    LBT[n-dd][k-dd+1] := [ LBT[n][k][1], [4, dd] ];
                    number := number + 1;
                fi;
            od;
        od;
        if info then Print(number," changes with Construction B\n" ); fi;
        return number > 0;
    end);
#F              begin of rules for lowerbound (not working)
#    # ConversionFieldCode (it appears that this rule is not needed)
#    if q = 2 then
#        temp := BT4[1];
#        Add(RulesList,
#            function()
#            local n, k, d, number;
#            number := 0;
#            for n in [ 2 .. Int(Sz/2) ] do
#                for k in [ 1 .. n - 1 ] do
#                    d := temp[n][k][1];
#                    if LBT[2*n][2*k][1] < d then
#                        LBT[2*n][2*k] := [ d , 8 ];
#                        number := number + 1;
#                    fi;
#                od;
#            od;
#        if info then Print(number," changes with ConversionField\n" ); fi;
#        return number > 0;
#        end);
#    fi;
#F              begin of rules for upperbound

    # Shortening
    Add(RulesList, function()
        local n, k, number;
        number := 0;
        for n in [ 2 .. Sz-1 ] do
            for k in [ 1 .. n - 1 ] do
                if UBT[ n + 1 ][ k + 1 ][ 1 ] > UBT[ n ][ k ][ 1 ] then
                    UBT[ n + 1 ][ k + 1 ] := [ UBT[ n ][ k ][ 1 ], 11 ];
                    number := number + 1;
                fi;
            od;
        od;
        if info then Print(number," changes with Shortening\n" ); fi;
        return number > 0;
    end);

    # Construction B
    Add(RulesList, function()
        local n, k, dd, s, number;
        number := 0;
        for n in [2..Sz] do
            for k in [1..n-1] do
                for s in [1..Sz-n-1] do
                    if s >= UBT[n+s][n-k+1][1] and
                       UBT[n+s][k+s-1][1] > UBT[n][k][1] then
                        UBT[n+s][k+s-1] := [ UBT[n][k][1], [14, s] ];
                        number := number + 1;
                    fi;
                od;
            od;
        od;
        if info then Print(number," changes with Construction B\n" ); fi;
        return number > 0;
    end);
    
    # Extending
    Add(RulesList, function()
        local n, k, number;
        number := 0;
        for n in Reversed([2..Sz]) do
            for k in [1..n-2] do
                if q=2 and IsOddInt(UBT[n][k][1]) then
                    if UBT[n-1][k][1] > UBT[n][k][1]-1 then
                        UBT[n-1][k] := [ UBT[n][k][1]-1, 13 ];
                        number := number + 1;
                    fi;
                else
                    if UBT[n-1][k][1] > UBT[n][k][1] then
                        UBT[n-1][k] := [ UBT[n][k][1], 13 ];
                        number := number + 1;
                    fi;
                fi;
            od;
        od;
        if info then Print(number," changes with Extending\n" ); fi;
        return number > 0;
    end);

    # Puncturing
    Add(RulesList, function()
        local n, k, number;
        number := 0;
        for n in [ 2 .. Sz-1 ] do
            for k in [ 2 .. n - 1 ] do
                if UBT[ n + 1 ][ k ][ 1 ] > UBT[ n ][ k ][ 1 ] + 1 then
                    UBT[ n + 1 ][ k ] := [ UBT[ n ][ k ][ 1 ] + 1, 12 ];
                    number := number + 1;
                fi;
            od;
        od;
        if info then Print(number," changes with Puncturing\n" ); fi;
        return number > 0;
    end);
#F              begin of rules for upperbound (not working)
#
#    # Taking the residue
#    Add(RulesList, function()
#        local n, k;
#        for n in [ 2 .. Sz-1 ] do
#            for k in [ 2 .. n - 1 ] do
#                if UBT[ n + q * UBT[ n ][ k ][ 1 ] ][ k + 1 ] >
#                   UBT[ n ][ k ][ 1 ] * q then
#                    UBT[ n + q * UBT[ n ] [ k ][ 1 ] ][ k + 1 ] :=
#                      [UBT[ n ][ k ][ 1 ] * q, [7, n + q * UBT[n][k][1]]];
#                    number := number + 1;
#                fi;
#            od;
#        od;
#    end);
#F              begin of body
    
    LBT := InitialTable( Sz,  true  );
    LBT := FillPoints  ( LBT, true  );
    UBT := InitialTable( Sz,  false );
    UBT := FillPoints  ( UBT, false );
    NumberUnchanged := 0;
    RuleNumber := 1;
    repeat
        if RulesList[RuleNumber]() then
            NumberUnchanged := 0;
        else
            NumberUnchanged := NumberUnchanged + 1;
        fi;
        if RuleNumber = Length(RulesList) then
            RuleNumber := 1;
            if info then Print("\n"); fi;
        else
            RuleNumber := RuleNumber + 1;
        fi;
    until NumberUnchanged >= Length(RulesList);

    # This way of saving the tables to a file make use of a nasty trick,
    # used to speed up things heavily
    
	##LR - This trick is not yet working in GAP4.  Until it does, 
	##  the tables will not be printed to the file.  
	if info then Print("\nSaving the bound tables...\n"); fi;
    file := Filename(LOADED_PACKAGES.guava,
					 Concatenation("tbl/bdtable",String(q),".g") );
    PrintTo(file, "#A  BOUNDS FOR q = ", String(q), help,
            "\n\nGUAVA_BOUNDS_TABLE[1", WriteToFile(LBT),
            "\n\nGUAVA_BOUNDS_TABLE[2", WriteToFile(UBT) );
    return [LBT,UBT];                    #just used for testing the program
end);


InstallOtherMethod(CreateBoundsTable, "Sz, fieldsize", true, 
	[IsInt, IsInt], 0, 
function(Sz, q) 
	return CreateBoundsTable(Sz, q, false); 
end); 

InstallOtherMethod(CreateBoundsTable, "Sz, field, info", true, 
	[IsInt, IsField, IsBool], 0, 
function(Sz, F, info) 
	return CreateBoundsTable(Sz, Size(F), info); 
end); 

InstallOtherMethod(CreateBoundsTable, "Sz, field", true, 
	[IsInt, IsField], 0, 
function(Sz, F) 
	return CreateBoundsTable(Sz, Size(F), false); 
end); 

