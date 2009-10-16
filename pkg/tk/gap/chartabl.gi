#############################################################################
##
#A  chartabl.gi                    for Tk                       Michael Ummels
##
##
#H  @(#)$Id: chartabl.gi,v 1.9 2003/09/28 13:41:14 gap Exp $
##
##  An interface to display character tables via Tk.
##

Revision.pkg_tk_gap_chartabl_gd :=
  "@(#)$Id: chartabl.gi,v 1.9 2003/09/28 13:41:14 gap Exp $";

##  The following two functions are taken from ctbl.gi in the GAP library and 
##  modified to the effect that data is not printed directly but stored
##  in a record for further processing.

# To avoid any warning:
if not(IsBound(last)) then last := true; fi;

InstallGlobalFunction( SelectedCharsToGAP,
  function(tab,pos)
    local  l,ll;
    l := SelectedRows( tab );
    ll := Irr( tab!.characterTable ){l};
    last := ll;
    Print( "\nThe characters with the following numbers have been stored in ",
           "'last':\n", l, "\n" );
    return;
  end ) ;

InstallGlobalFunction( SelectedClassesToGAP,
  function(tab,pos)
    local  l,ll;
    l := SelectedColumns( tab );
    last := l;
    Print( "\nThe following numbers of classes have been stored in ",
           "'last':\n", l, "\n" );
    return;
  end ) ;

InstallGlobalFunction( SubmatrixToGAP,
  function(tab,pos)
    local  l,r,c;
    l := SelectedCells( tab );
    r := Set(List(l,x->x[1]));
    c := Set(List(l,x->x[2]));
    if Length(r) = 1 and Length(c) = 1 then
        last := Irr(tab!.characterTable)[r[1]][c[1]];
        Print( "\nThe following entry has been stored in 'last':\n",
               "Row: ",r[1]," Column: ",c[1],"\n");
    else
        last := Irr(tab!.characterTable){r}{c};
        Print( "\nThe following submatrix has been stored in 'last':\n",
               "Rows: ", r, " Columns: ",c,"\n" );
    fi;
    return;
  end ) ;

InstallMethod( ShowCharacterTable, "for a character table", 
               [IsNearlyCharacterTable],
  function(tbl)
    return ShowCharacterTable(tbl,rec());
  end );

InstallMethod( ShowCharacterTable, 
               "for a character table, and an options record",
               [IsNearlyCharacterTable,IsRecord],
  function( tbl, options)
    local i, j,              # loop variables
          chars,             # list of characters
          cnr,               # list of character numbers
          cletter,           # character name
          classes,           # list of classes
          powermap,          # list of primes
          centralizers,      # boolean
          fak,               # factorization
          primes,            # prime factors of order
          nam,               # classnames
          acol,              # counter for columns on whole page
          ncols,             # total number of columns
          q,                 # quadratic cyc / powermap entry
          indicator,         # list of primes
          indic,             # indicators
          stringEntry,       # local function
          stringEntryData,   # data accessed by `stringEntry'
          cc,                # column number
          charnames,         # list of character names
          charvals,          # matrix of strings of character values
          tbl_powermap,
          tbl_centralizers,
          line,              # here we collect one line of output
          coltit,            # column titles in table
          rowtit,            # row titles in table
          corner,            # descriptions in corner
          irrnames,          # names of irrationalities
          irrstack,          # values of irrationalitizes,
          no,                # number of prime factors
          nocoltit,          # number of column titles so far
          noindics,          # number of indicators shown
          p,                 # a prime
          result;            # in this object we collect the result

    # for easier reference:
    stringEntry:= CharacterTableDisplayStringEntryDefault;
    stringEntryData:= CharacterTableDisplayStringEntryDataDefault( tbl );

    # default:
    # options
    cletter:= "X";

    # choice of characters
    if IsBound( options.chars ) then
       if IsCyclotomicCollection( options.chars ) then
          cnr:= options.chars;
          chars:= List( Irr( tbl ){ cnr }, ValuesOfClassFunction );
       elif IsInt( options.chars ) then
          cnr:= [ options.chars ];
          chars:= List( Irr( tbl ){ cnr }, ValuesOfClassFunction );
       elif IsHomogeneousList( options.chars ) then
          chars:= options.chars;
          cletter:= "Y";
          cnr:= [ 1 .. Length( chars ) ];
       else
          chars:= [];
       fi;
    else
      chars:= List( Irr( tbl ), ValuesOfClassFunction );
      cnr:= [ 1 .. Length( chars ) ];
    fi;

    if IsBound( options.letter ) and Length( options.letter ) = 1 then
       cletter:= options.letter;
    fi;

    # choice of classes
    if IsBound( options.classes ) then
      if IsInt( options.classes ) then
        classes:= [ options.classes ];
      else
        classes:= options.classes;
      fi;
    else
      classes:= [ 1 .. NrConjugacyClasses( tbl ) ];
    fi;

    # choice of power maps
    tbl_powermap:= ComputedPowerMaps( tbl );
    powermap:= Filtered( [ 2 .. Length( tbl_powermap ) ],
                         x -> IsBound( tbl_powermap[x] ) );
    if IsBound( options.powermap ) then
       if IsInt( options.powermap ) then
          IntersectSet( powermap, [ options.powermap ] );
       elif IsList( options.powermap ) then
          IntersectSet( powermap, options.powermap );
       elif options.powermap = false then
          powermap:= [];
       fi;
    fi;

    # print factorized centralizer orders?
    centralizers:=    not IsBound( options.centralizers )
                   or options.centralizers;

    # print Frobenius-Schur indicators?
    indicator:= [];
    if     IsBound( options.indicator )
       and not ( IsBound( options.chars ) and IsMatrix( options.chars ) ) then
       if options.indicator = true then
          indicator:= [2];
       elif IsRowVector( options.indicator ) then
          indicator:= Set( Filtered( options.indicator, IsPosInt ) );
       fi;
    fi;

    # (end of options handling)

    # prepare centralizers
    if centralizers then
       fak:= FactorsInt( Size( tbl ) );
       primes:= Set( fak );
    fi;

    # prepare classnames
    nam:= ClassNames( tbl );

    # prepare character names
    if HasCharacterNames( tbl ) and not IsBound( options.chars ) then
      charnames:= CharacterNames( tbl );
    else
      charnames:= [];
      for i in [ 1 .. Length( cnr ) ] do
        charnames[i]:= Concatenation( cletter, ".", String( cnr[i] ) );
      od;
    fi;

    # prepare indicator
    if indicator <> [] and not HasComputedIndicators( tbl ) then
       indicator:= [];
    fi;
    if indicator <> [] then
       indic:= [];
       for i in indicator do
          if IsBound( ComputedIndicators( tbl )[i] ) then
            indic[i]:= [];
            for j in cnr do
              indic[i][j]:= ComputedIndicators( tbl )[i][j];
            od;
          fi;
       od;
       indicator:= Filtered( indicator, x-> IsBound( indic[x] ) );
    fi;

    # prepare list for strings of character values
    charvals:= List( chars, x -> [] );

    # total number of columns
    ncols:= Length(classes);

    # total number of indicators:
    noindics := Length(indicator);   # number of indicators shown
    
    # First the values:
    for i in [ 1 .. Length( cnr ) ] do
       for j in [1..noindics] do
          if IsBound(indic[indicator[j]][cnr[i]]) then
             if indicator[j] = 2 then
                if indic[indicator[j]][cnr[i]] = 0 then
                   charvals[i][j] := "o";
                elif indic[indicator[j]][cnr[i]] = 1 then
                   charvals[i][j] := "+";
                elif indic[indicator[j]][cnr[i]] = -1 then
                   charvals[i][j] := "-";
                fi;
             else
                if indic[indicator[j]][cnr[i]] = 0 then
                   charvals[i][j] := "0";
                else
                   charvals[i][j] := stringEntry( indic[indicator[j]][cnr[i]],
                                                  stringEntryData );
                fi;
             fi;
          else
             charvals[i][j] := "";
          fi;
       od;
       for acol in [1..ncols] do
          cc:= classes[ acol ];
          charvals[i][ acol + noindics ] := stringEntry( chars[i][ cc ], 
                                                         stringEntryData );
       od;
    od;

    result := GeneralizedTable(charvals);
    corner := Title(result);
    rowtit := RowTitles(result);
    coltit := ColumnTitles(result);
    nocoltit := 0;   # number of col titles so far

    # centralizers
    if centralizers then
       tbl_centralizers:= SizesCentralizers( tbl );
       for i in [1..acol] do
          fak:= FactorsInt( tbl_centralizers[classes[i]] );
          for j in [1..Length(primes)] do
             no := Number( fak, x -> x = primes[j] );
             if no = 0 then
                coltit[nocoltit+j][i+noindics] := ".";
             else
                coltit[nocoltit+j][i+noindics] := String(no);
             fi;
          od;
       od;
       for j in [1..Length(primes)] do
          corner[j+nocoltit][1] := String(primes[j]);
       od;
       nocoltit := nocoltit + Length(primes);
    fi;

    # class names
    for i in [ 1 .. acol ] do
       coltit[nocoltit+1][i+noindics] := nam[classes[i]];
    od;
    nocoltit := nocoltit+1;

    # power maps
    for i in [1..Length(powermap)] do
       p := powermap[i];
       corner[nocoltit+i][1] := Concatenation( String(p), "P" );
       for j in [1..acol] do
          q:= tbl_powermap[powermap[i]][classes[j]];
          if IsInt(q) then
             coltit[nocoltit+i][j+noindics] := nam[q];
          else
             coltit[nocoltit+i][j+noindics] := "?";
          fi;
       od;
    od;
    nocoltit := nocoltit + Length(powermap);

    # empty column resp. indicators
    if indicator <> [] then
       for i in [1..noindics] do
          coltit[nocoltit+1][i] := String( indicator[i] );
       od;
       nocoltit := nocoltit + 1;
    fi;

    # the characters
    for i in [1..Length(chars)] do

       # character name
       rowtit[i][1] := charnames[i];

    od;

    result := TkTable(result);
    SetJustification(result,TKTABLE_RIGHT_JUSTIFIED);
    Show(result);
    SetWindowTitle(result, Concatenation("Character Table ", Identifier(tbl)));

    # Now create the legend:
    irrstack:= stringEntryData.irrstack;
    if Length(irrstack) > 0 then
        result!.legendtop := TkWidget("toplevel");
        result!.legend := TkWidget("text",result!.legendtop,
                                   "-width 80 -background white -state normal",
                                   rec(height := 2*Length(irrstack)));
        result!.legscrolly := TkWidget("scrollbar",result!.legendtop,
                                       "-orient vertical");
        TkGrid(result!.legend,"-row 0 -column 0 -sticky news");
        TkGrid(result!.legscrolly,"-row 0 -column 1 -sticky ns");
        Tk("grid rowconfigure", result!.legendtop, "0 -weight 1");
        Tk("grid columnconfigure", result!.legendtop, "0 -weight 1");
        TkLink(result!.legend,result!.legscrolly,"v");
        if not IsEmpty( irrstack ) then
          irrnames:= stringEntryData.irrnames;
        fi;
        for i in [1..Length(irrstack)] do
          line := Concatenation( "\"", irrnames[i], " = ", String(irrstack[i]), 
                                 "\\n\"" );
          Tk(result!.legend,"insert end",line);
          q:= Quadratic( irrstack[i] );
          if q <> fail then
            line := Concatenation("\"  = ",q.display," = ",q.ATLAS,"\\n\"" );
            Tk(result!.legend,"insert end",line);
          fi;
        od;
        Tk(result!.legend,"configure -state disabled");
        Tk("wm title",result!.legendtop,
           Concatenation("\"Legend to Character Table ",Identifier(tbl),"\""));
    else
        result!.legend := fail;
        result!.legendtop := fail;
        result!.legscrolly := fail;
    fi;

    # Store Character table object within the table:
    result!.characterTable := tbl;

    # Install some nice functions:
    RegisterMenuItem( result, "Selected Characters to GAP",
                    SelectedCharsToGAP);
    RegisterMenuItem( result, "Selected Classes to GAP",
                    SelectedClassesToGAP);
    RegisterMenuItem( result,"Selected Submatrix to GAP",
                    SubmatrixToGAP);
    RegisterEvent(result, TkEvent("Destroy"), function(obj, env)
        if not obj!.legendtop = fail then
          TkDelete(obj!.legendtop);
        fi;
      end);
    # Now return the object:
    return result;
  end );
#T support also Cambridge format!

## Tables of Marks:

InstallMethod( ShowTableOfMarks, "for a table of marks", 
               [IsTableOfMarks],
  function(tom)
    return ShowTableOfMarks(tom,rec());
  end );

InstallMethod( ShowTableOfMarks, 
               "for a table of marks, and an options record",
               [IsTableOfMarks,IsRecord],
  function( tom, options)
    local ci,cj,classes,coltit,corner,i,j,l,ll,out,outline,pos,result,rowtit,
      subs,vals,wt;

    #  default values.
    subs:= SubsTom(tom);
    ll:= Length(subs);
    classes:= [1..ll];
    vals:= MarksTom(tom);

    #  adjust parameters.
    if IsBound(options.classes) and IsList(options.classes) then
      classes:= options.classes;
    fi;
    if IsBound(options.form) then
      if options.form = "supergroups" then
        vals:= ShallowCopy(vals);
        wt:= WeightsTom(tom);
        for i in [1..ll] do
          vals[i]:= vals[i]/wt[i];
        od;
      elif options.form = "subgroups" then
        vals:= NrSubsTom(tom);
      fi;
    fi;

    l := Length(classes);
    out := [];
    # loop over rows:
    for i in [1..l] do
        outline := [];
        ci := classes[i];
        # loop over columns:
        for j in [1..i] do
          cj := classes[j];
          pos:= Position(subs[ci], cj);
          if pos = fail then
            Add(outline,".");
          else
            Add(outline,String(vals[ci][pos]));
          fi;
        od;
        Add(out,outline);
    od;
    result := GeneralizedTable(out);
    corner := Title(result);
    rowtit := RowTitles(result);
    coltit := ColumnTitles(result);
    for i in [1..l] do
        rowtit[i][1] := String(classes[i]);
        coltit[1][i] := String(classes[i]);
    od;
    corner[1][1] := Identifier(tom);
    result := TkTable(result);
    SetJustification(result,TKTABLE_RIGHT_JUSTIFIED);
    Show(result);
    SetWindowTitle(result, Concatenation("Table of Marks ", Identifier(tom)));
    result!.tableOfMarks := tom;
    return result;
  end);
 
