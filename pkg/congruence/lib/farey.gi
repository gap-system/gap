#############################################################################
##
#W farey.gi                The Congruence package                   Ann Dooms
#W                                                               Eric Jespers
#W                                                        Alexander Konovalov
##
#H $Id: farey.gi,v 1.1 2007/04/27 20:08:38 alexk Exp $
##
#############################################################################
    

#############################################################################
##
## IsFareySymbolDefaultRep
##
DeclareRepresentation( "IsFareySymbolDefaultRep", 
    IsPositionalObjectRep,
    [ 1, 2 ] );
    
    
#############################################################################
##
## FareySymbolByData( <gfs>, <labels> )
##
## This constructor creates Farey symbol with the given generalized Farey 
## sequence and list of labels. It also checks conditions from the definition
## of Farey symbol and returns an error if they are not satisfied
##
InstallMethod( FareySymbolByData, 
	"for two lists that are g.F.S. and labels for Farey symbol",
	[ IsList, IsList ],
	0,
	function( gfs, labels)
	local fs;
	fs :=Objectify( NewType( NewFamily("FareySymbolsFamily", IsFareySymbol), 
	                         IsFareySymbol), [ gfs, labels ] );
	if IsValidFareySymbol(fs) then                         
	  return fs;   
	else
	  Error("<fs> is not a valid Farey symbol !!! \n");
	fi;                          
	end);


#############################################################################
##
## GeneralizedFareySequence( <fs> )
## LabelsOfFareySymbol( <fs> )
##
## The data used to create the Farey symbol are stored as its attributes
##
InstallMethod( GeneralizedFareySequence,
    "for Farey symbol in default representation",
    [ IsFareySymbol ],
    fs -> fs![1]);

InstallMethod( LabelsOfFareySymbol,
    "for Farey symbol in default representation",
    [ IsFareySymbol ],
    fs -> fs![2] );     


#############################################################################
##
## ViewObj( fs )
## PrintObj( fs )
##    
InstallMethod( ViewObj,
    "for Farey symbol",
    [ IsFareySymbol ],
    0,
    function(fs)
    Print( GeneralizedFareySequence(fs), "\n",
           LabelsOfFareySymbol(fs) );
    end); 
    
InstallMethod( PrintObj,
    "for Farey symbol",
    [ IsFareySymbol ],
    0,
    function(fs)
    Print( "FareySymbolByData( ", GeneralizedFareySequence(fs), 
           ", ", LabelsOfFareySymbol(fs), " ] " );
    end);    
   
    
#############################################################################
##
## FareySymbol( <G> )
##
## For a subgroup of a finite index G, this attribute stores the 
## corresponding Farey symbol. The algorithm for its computation must work
## with any matrix group for which the membership test is available
##     
InstallMethod( FareySymbol,
	"for a congruence subgroup",
	[ IsCongruenceSubgroup ],
	0,
	function( G )
local    gfs, # generalized Farey sequence (g.F.S.)
      labels, # labels of this g.F.S.
          fs, # resulting Farey symbol
  i, j, k, t, # counters
      stepnr, # number of the inductive ste
   newvertex, # new vertex to be inserted on the current inductive step
  unpairednr, # number of the 1st vertex of the unpaired side 
   lastlabel, # last used label
         mat, # matrix by free pair of intervals
     unpairednumbers, # list of positions with assigned labels
        denominators, # denominators of current g.F.S. elements
possibledenominators, # list of denominators arising from these positions
              minden, # minimum of possible denominators
                 pos, # chosen position of minden in possibledenominators
            nrlabels, # number of labels assigned
              range1, # range for the search of odd and even labels 
              range2, # range for the search of free (i.e.numerical) labels
 isfirstlabelssearch; # flag for determining of the range1 and range2
#
# Initial data setup
#
if LevelOfCongruenceSubgroup(G)=1 then
  return FareySymbolByData( [ infinity, 0, infinity ], ["even","odd"]) ;
fi;
gfs := [ infinity, 0, infinity ];
labels:=[];
nrlabels:=0;
stepnr:=0;
lastlabel:=0;
isfirstlabelssearch:=true;
#
# we perform the next loop until we will have fully labeled gfs
#
while nrlabels < Length( gfs ) - 1 do
  stepnr:=stepnr+1;
  Info( InfoCongruence, 2, "Step ", stepnr, 
                           " : g.F.S. of length ", Length(gfs), 
                           " with ", nrlabels, " labels");   
  Info( InfoCongruence, 3, "   gfs = ", gfs );
  Info( InfoCongruence, 3, "labels = ", labels ); 
  #
  # 1. Choose any of the unpaired sides and insert new vertex
  #
  # 1.1. Find unpaired side that will give us a new vertex 
  #      with the minimal denominator (on the first step we
  #      do some trick to get [infinity,0,1,infinity])
  unpairednumbers := Filtered( [ 1 .. Length(gfs)-1 ], i -> 
                               not IsBound( labels[ i ] ) );
  Info( InfoCongruence, 3, "Positions of unpaired labels : ", unpairednumbers );
  # to avoid repeated calls of DenominatorOfGFSElement, we are caching
  # values of denominators from required positions  
  denominators := [];   
  for i in unpairednumbers do 
    if not IsBound(denominators[i]) then
      denominators[i]:=DenominatorOfGFSElement(gfs,i);
    fi;  
    denominators[i+1]:=DenominatorOfGFSElement(gfs,i+1);
  od;                          
  possibledenominators := List( unpairednumbers, i -> 
                                denominators[i] + denominators[i+1] );
  Info( InfoCongruence, 3, "Possible denominators : ", possibledenominators ); 
  minden := Minimum(possibledenominators);
  # we give priority to positive numbers in g.F.S. 
  pos:=PositionProperty( [ 1 .. Length(unpairednumbers) ], i -> 
                         ( possibledenominators[i] = minden ) and 
                         ( NumeratorOfGFSElement( gfs, unpairednumbers[i] ) >=0 ) );
  if pos=fail then
    pos:=PositionProperty( [ 1 .. Length(unpairednumbers) ], i -> 
                           possibledenominators[i] = minden );
  fi;                       
  unpairednr := unpairednumbers[ pos ]; 
  #i:=1;
  #repeat
  #  pos := PositionNthOccurrence( possibledenominators, minden, i );
  #  i := i+1;
  #  unpairednr := unpairednumbers[ pos ]; 
  #until NumeratorOfGFSElement(gfs, unpairednr) >= 0;
  #
  # 1.2. Compute new vertex by the Farey sequence rule
  #
  newvertex := ( NumeratorOfGFSElement(gfs, unpairednr) + 
                 NumeratorOfGFSElement(gfs, unpairednr+1) ) / minden;
  #
  # 1.3. Insert this new vertex and an empty spot for the label
  #      
  Info( InfoCongruence, 2, "Inserting ", newvertex, 
                           " at position ", unpairednr+1);
  Add( gfs, newvertex, unpairednr+1);
  Add( unpairednumbers, unpairednr, pos );
  for i in [ pos+1 .. Length(unpairednumbers) ] do
    unpairednumbers[i] := unpairednumbers[i]+1;
  od;
  Add( labels, "hole" , unpairednr );
  Unbind(labels[unpairednr]);
  #
  # 2. For each of new sides, we check if they are paired and
  #    assign labels, if this is the case
  #
  if isfirstlabelssearch then
    range1 := [ 1 .. Length(gfs)-1 ];
    range2 := [ 1 .. Length(gfs)-1 ];
  else
    # if we already checked all cases for all possible labels, 
    # on each new step it is enough to check only new intervals
    range1 := [ unpairednr, unpairednr+1 ];
    # Slower but more obvious options for range2 could be:
    # range2 := [ 1 .. Length(gfs)-1 ];
    # range2:= Filtered( [ 1 .. Length(gfs)-1 ], i -> not IsBound( labels[ i ] ) );
    # but we use the fastest one
    range2 := unpairednumbers;
  fi; 
  if not ( IsPrincipalCongruenceSubgroup(G) and 
           LevelOfCongruenceSubgroup(G) > 2 ) then
    for i in range1 do
      # we do not check that labels[i] is not bound because this is
      # guaranteed by the algorithm
      mat := MatrixByOddInterval( gfs, i );
      if mat in G or -mat in G then
        labels[i]:="odd";
        nrlabels:=nrlabels+1;
        Info( InfoCongruence, 2, "Putting label ", lastlabel,
                                 " at position ", i );      
      else
        mat := MatrixByEvenInterval( gfs, i );
        if mat in G or -mat in G then
          labels[i]:="even";
          nrlabels:=nrlabels+1;
          Info( InfoCongruence, 2, "Putting label ", lastlabel,
                                   " at position ", i );  
        fi;                               
      fi;
    od;
  fi;
  for i in range1 do
    for j in range2 do
      # we eliminate the case i=j since we always check different intervals
      # now we check that both labels[i] and labels[j] are not bound for a case
      # if they were already assigned during the search for odd/even labels
      if i<>j and not IsBound( labels[i] ) and not IsBound( labels[j] ) then
        mat := MatrixByFreePairOfIntervals( gfs, i, j );
        if mat in G or -mat in G then
          lastlabel := lastlabel+1;
          labels[i]:=lastlabel;
          labels[j]:=lastlabel;
          nrlabels:=nrlabels+2;
          Info( InfoCongruence, 2, "Putting label ", lastlabel,
            " at positions ", i, " and ", j );
          # since i-th interval can be paired only with one j-th interval,
          # we quit from inner loop and go to the next i
          break;  
        fi; 
      fi;
    od;  
  od;
  isfirstlabelssearch:=false;
  if stepnr mod 25000 = 0 then
    Error("You reached the checkpoint on the ", stepnr, "th iteration \n",
          "Currently you have g.F.S. of length ", Length(gfs), 
          " with ", nrlabels, " labels assigned \n",
          "Use the index of the subgroup to get an idea about possible length of the g.F.S.:\n",
          "it will be equal to the index of <G> in PSL_2Z minus the number of odd intervals in g.F.S.\n");
  fi;
od;
fs := FareySymbolByData( gfs, labels) ;
return fs;
end);    


#############################################################################
#
# GeneratorsByFareySymbol( fs )
#
InstallGlobalFunction( GeneratorsByFareySymbol,
function( fs )
local gfs, labels, usedlabels, gens, i, j, m;
gfs := GeneralizedFareySequence(fs);
labels := LabelsOfFareySymbol(fs);
usedlabels:=[];
gens:=[];
for i in [ 1 .. Length(labels) ] do
  if labels[i]="even" then
    Info( InfoCongruence, 2, "labels[", i, "] = ", labels[i] );
    m := MatrixByEvenInterval( gfs, i );
    Add( gens, m );
    if InfoLevel( InfoCongruence ) = 2 then
      Display(m);
    fi;  
  elif labels[i]="odd" then
    Info( InfoCongruence, 2, "labels[", i, "] = ", labels[i] );
    m := MatrixByOddInterval( gfs, i );
    Add( gens, m );
    if InfoLevel( InfoCongruence ) = 2 then
      Display(m);
    fi;     
  elif not labels[i] in usedlabels then
    j := PositionNthOccurrence( labels, labels[i], 2 );
    Info( InfoCongruence, 2, "labels[", i, "] = ", labels[i], 
                          " = labels[", j, "]" );
    m := MatrixByFreePairOfIntervals( gfs, i, j );
    Add( gens, m );
    Add( usedlabels, labels[i] );
    if InfoLevel( InfoCongruence ) = 2 then
      Display(m);
    fi;    
  fi;
od;
return gens;
end);


#############################################################################
#
# IndexInPSL2ZByFareySymbol( fs )
#
# By the proposition 7.2 [Kulkarni], for the Farey symbol with underlying
# generalized Farey sequence { infinity, x0, x1, ..., xn, infinity }, the
# index in PSL_2(Z) is given by the formula d = 3*n + e3, where e3 is the 
# number of odd intervals.
#
InstallGlobalFunction( IndexInPSL2ZByFareySymbol,
function( fs )
local n, e3, x, d; 
n := Length( GeneralizedFareySequence(fs) ) - 3;
e3:= Number( LabelsOfFareySymbol(fs), x -> x = "odd" );
d := 3 * n + e3;
return d;
end);


#############################################################################
##
#E
##
