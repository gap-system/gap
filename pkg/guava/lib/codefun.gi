#############################################################################
##
#A  codefun.gi               GUAVA                              Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains non-dispatched functions to get info of codes
##
#H  @(#)$Id: codefun.gi,v 1.4 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codefun_gi") :=
    "@(#)$Id: codefun.gi,v 1.4 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  GuavaToLeon( <C>, <file> )  .  converts a code to a form Leon can read it
##
##  converts a code in Guava format to a library in a format that is readable
##  by Leon's programs.
##

InstallMethod(GuavaToLeon, "method for unrestricted code, filename", 
	true, [IsCode, IsString], 0, 
function (C, file)
    local w, vector, G, coord, n, k, TheMat, IR1SAVE, IR2SAVE;
    G := GeneratorMat(C);
    k := Dimension(C);
    n := WordLength(C);
    PrintTo(file, "LIBRARY code;\n");
    
    # using "String" here causes problems when this function
    # is run before the string library is loaded *and* InfoRead1
    # and/or InfoRead2 is set to "Print".

	##LR - is this still needed? 
    # ugly hack: temporarily disable InfoRead1 and InfoRead2
    
    IR1SAVE := InfoRead1; InfoRead1 := Ignore;
    IR2SAVE := InfoRead2; InfoRead2 := Ignore;
    
    AppendTo(file,"code=seq(",String(Size(LeftActingDomain(C))),",",String(k),
            ",",String(n),",seq(\n");
    
    InfoRead1 := IR1SAVE;
    InfoRead2 := IR2SAVE;
    
    # end of ugly hack.
    
    for vector in [1..k] do
        for coord in [1..n-1] do
            AppendTo(file,IntFFE(G[vector][coord]),",");
        od;
        AppendTo(file, IntFFE(G[vector][n]));
        if vector < k then
            AppendTo(file,",\n");
        fi;
    od;
    AppendTo(file, "\n));\nFINISH;");
end);
  
  
#############################################################################
##
#F  WeightHistogram ( <C> [, <height>] )  . . . . .  plots the weights of <C>
##
##  The maximum length of the columns is <height>. Default height is one
##  third of the screen size.
##
InstallMethod(WeightHistogram, 
	"method for unrestricted code and screen height", 
	true, [IsCode, IsInt], 0, 
function(C, height)
    local wd, max, data, i, j, n, spaces, nr, Scr, char;
    Scr := SizeScreen();
    char := "*";
    n := WordLength(C);
    if n+2 >= Scr[1] then
        Error("histogram does not fit on screen");
    elif n+2 > Int(Scr[1] / 2) then
        spaces := "";
        nr := 0;
    elif n+2 > Int(Scr[1] / 4) then
        spaces := " ";
        nr := 1;
    else
        spaces := "  ";
        nr := 2;
    fi;
    wd := WeightDistribution(C);
    max := Maximum(wd);
    if max < height then
        height := max;
    fi;
    data := List(wd, w -> Int(w/max*height));
    Print(max);
    for i in [0..n*(nr+1)-Length(String(max))] do
        Print("-");
    od;
    Print("\n");
    for i in height - [0..height-1] do
        for j in data do
            if j >= i then
                Print(Concatenation(char,spaces));
            else
                Print(Concatenation(" ",spaces));
            fi;
        od;
        Print("\n");
    od;
    for i in [0..n] do
        if wd[i+1] = 0 then
            Print("-");
        else
            Print("+");
        fi;
        for j in [2..nr+1] do
            Print("-");
        od;
        #Print("-");
    od;
    Print("\n");
    for i in [0..n] do
        Print(i mod 10,spaces);
    od;
    Print("\n ",spaces);
    for i in [1..n] do
        if i mod 10 = 0 then
            Print(Int(i / 10),spaces);
        else
            Print(" ",spaces);
        fi;
    od;
    Print("\n");
end);

InstallOtherMethod(WeightHistogram, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C) 
	local Scr; 
	Scr := SizeScreen(); 
	WeightHistogram(C, Int(Scr[2]/3));  
end); 


#############################################################################
##
#F  MergeHistories( <C>, <S> [, <C1> .. <Cn> ] ) . . . . . .  list of strings
##
##

InstallGlobalFunction(MergeHistories, 
function(arg)  
    local i, his, names;
    if Length( arg ) > 1 then
        names := "UVWXYZ";
        his := [];
        for i in [1..Length(arg)] do
            Add(his, Concatenation( [ names[i] ], ": ", arg[i][1]) );
            Append( his, List( arg[i]{[2..Length(arg[i])]}, line -> 
                    Concatenation("   ", line ) ) );
        od;
        return his;
    else
        Error("usage: MergeHistories( <C1> , <C2> [, <C3> .. <Cn> ] )");
    fi;
end);

