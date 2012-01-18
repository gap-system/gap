#############################################################################
##
#W  brirrat.g            GAP 4 package CTblLib                  Thomas Breuer
##
#Y  Copyright (C)  2011,   Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##


#############################################################################
##
#F  CTblLib.StringPol( <pol>, <opensup>, <closesup> )
##
##  This function returns a string that describes a polynomial <pol> over
##  a finite prime field, the coefficients are represented by nonnegative
##  integers.
##  We need this function for producing text or HTML format,
##  by entering `"^"' or `"<sup>"' as <opensup>, and
##  `""' or `"<sup/>"' as <closesup>.
##
CTblLib.StringPol:= function( pol, opensup, closesup )
    local coeffs, deg, str, i, c;

    coeffs:= CoefficientsOfUnivariatePolynomial( pol );
    if IsEmpty( coeffs ) then
      return "0";
    fi;

    deg:= Length( coeffs ) - 1;
    str:= "";
    for i in [ deg, deg-1 .. 1 ] do
      c:= Int( coeffs[ i+1 ] );
      if c <> 0 then
        if 0 < Length( str ) then
          Append( str, " + " );
        fi;
        if c <> 1 then
          Append( str, String( c ) );
          Append( str, " " );
        fi;
        Append( str, "X" );
        if i <> 1 then
          Append( str, opensup );
          Append( str, String( i ) );
          Append( str, closesup );
        fi;
      fi;
    od;
    c:= Int( coeffs[1] );
    if c <> 0 then
      if 0 < Length( str ) then
        Append( str, " + " );
      fi;
      Append( str, String( c ) );
    fi;

    return str;
    end;


#############################################################################
##
#F  CTblLib.CompareStringPol( <str1>, <str2> )
##
##  Let <str1> and <str2> be either strings returned by `CTblLib.StringPol'
##  or the string "?".
##  Compare them first by the degrees of the polynomials,
##  and compare polynomials of the same degree with
##  `BrowseData.CompareAsNumbersAndNonnumbers'.
##
CTblLib.CompareStringPol:= function( str1, str2 )
    local pos, deg1, pos2, deg2;

    if   str1 = "?" then
      return str2 = "?";
    elif str2 = "?" then
      return true;
    fi;
      
    pos:= Position( str1, 'X' );
    if pos = fail then
      deg1:= 0;
    elif pos = Length( str1 ) or str1[ pos+1 ] <> '^' then
      deg1:= 1;
    else
      pos:= pos + 2;
      pos2:= pos;
      while pos2 <= Length( str1 ) and IsDigitChar( str1[ pos2 ] ) do
        pos2:= pos2 + 1;
      od;
      deg1:= Int( str1{ [ pos .. pos2-1 ] } );
    fi;

    pos:= Position( str2, 'X' );
    if pos = fail then
      deg2:= 0;
    elif pos = Length( str2 ) or str2[ pos+1 ] <> '^' then
      deg2:= 1;
    else
      pos:= pos + 2;
      pos2:= pos;
      while pos2 <= Length( str2 ) and IsDigitChar( str2[ pos2 ] ) do
        pos2:= pos2 + 1;
      od;
      deg2:= Int( str2{ [ pos .. pos2-1 ] } );
    fi;

    if   deg1 < deg2 then
      return true;
    elif deg2 < deg1 then
      return false;
    elif str1[1] = 'X' then
      if str2[1] = 'X' then
        return BrowseData.CompareAsNumbersAndNonnumbers( str1, str2 );
      else
        return true;
      fi;
    elif str2[1] = 'X' then
      return false;
    else
      return BrowseData.CompareAsNumbersAndNonnumbers( str1, str2 );
    fi;
    end;


##############################################################################
##
#F  CTblLib.CommonIrrationalityInfo( <irrat> )
#F  CTblLib.CommonIrrationalityInfo( <irratname> )
##
##  In the first form, <irrat> must be a cyclotomic integer $c$, say.
##  In the second form, <irratname> must be a string describing an
##  irrational value $c$ as described in [CCN85, Chapter 6, Section 10],
##  see "AtlasIrrationality" in the GAP Reference Manual.
##
##  `CTblLib.CommonIrrationalityInfo' returns a record with the following
##  components.
##
##  `conjugates'
##      the list $[ c_1, c_2, \ldots, c_n ]$ of algebraic conjugates
##      (see "Conjugates" in the GAP Reference Manual)
##      of the algebraic integer $c_1 = c$,
##
##  `galois'
##      the sorted list $[ k_1, k_2, \ldots, k_n ]$ of the smallest positive
##      integers $k_i$ with the property that $`GaloisCyc'( c, k_i ) = c_i$,
##
##  `strings'
##      a list $[ s_1, s_2, \ldots, s_n ]$ of strings describing the values
##      $c_i$;
##      if an algebraic number <irrat> was given as the second argument then
##      $s_i$ is of the form $`A*'k_i$;
##      if a string <irratname> was given then
##      $s_i$ is of the form $<irratname>`*'k_i$ or $(<irratname>)`*'k_i$;
##      in both situations, $k_i$ is omitted or replaced by `*' if $n = 2$,
##
CTblLib.CommonIrrationalityInfo:= function( irratname )
    local irrat, N, conj, gal, i, img, strings;

    if IsCycInt( irratname ) then
      irrat:= irratname;
      irratname:= "A";
    elif IsString( irratname ) then
      irrat:= AtlasIrrationality( irratname );
      if irrat = fail then
        Error( "<irratname> is not a valid name for an Atlas irrationality" );
      fi;
    else
      Error( "<irratname> must be a (name of a) cyclotomic integer" );
    fi;

    N:= Conductor( irrat );
    conj:= [ irrat ];
    gal:= [ 1 ];
    for i in [ 2 .. N ] do
      if GcdInt( N, i ) = 1 then
        img:= GaloisCyc( irrat, i );
        if not img in conj then
          Add( conj, img );
          Add( gal, i );
        fi;
      fi;
    od;
    SortParallel( gal, conj );

    strings:= [ irratname ];
    if ForAny( "+-&*", char -> char in irratname ) then
      if 2 < Length( conj ) then
        for i in [ 2 .. Length( conj ) ] do
          strings[i]:= Concatenation( "(", irratname, ")", "*",
                           String( gal[i] ) );
        od;
      elif ComplexConjugate( irrat ) = irrat then
        strings[2]:= Concatenation( "(", irratname, ")", "*" );
      else
        strings[2]:= Concatenation( "(", irratname, ")", "**" );
      fi;
    else
      if 2 < Length( conj ) then
        for i in [ 2 .. Length( conj ) ] do
          strings[i]:= Concatenation( irratname, "*", String( gal[i] ) );
        od;
      elif ComplexConjugate( irrat ) = irrat then
        strings[2]:= Concatenation( irratname, "*" );
      else
        strings[2]:= Concatenation( irratname, "**" );
      fi;
    fi;

    return rec( conjugates := conj,
                galois     := gal,
                strings    := strings );
    end;


#############################################################################
##
#F  CTblLib.PrepareCommonIrrationalitiesInfo()
##
##  Read the file that contains the names of irrationalities and the primes
##  for which they occur.
##  Extend this list by Galois conjugates.
##  (Do not compute the reductions modulo Conway polynomials.)
##
CTblLib.PrepareCommonIrrationalitiesInfo:= function()
    local mat, infos, maxprime, namelen, entry, info, len, i, name, p;

    if not IsBound( CTblLib.BrowseCommonIrrationalitiesInfo ) then
      if not IsBound( CTblLib.CommonIrrationalitiesInfo ) then
        ReadPackage( "ctbllib", "data/irrats.dat" );
      fi;

      mat:= [];
      infos:= [];
      maxprime:= 2;
      namelen:= 4;

      for entry in CTblLib.CommonIrrationalitiesInfo do
        # Extend the list by the Galois conjugates of this irrationality.
        # (Omit the negatives of quadratic irrationalities.)
        info:= CTblLib.CommonIrrationalityInfo( entry[1] );
        len:= Length( info.strings );
        if len = 2 and info.conjugates[1] = - info.conjugates[2] then
          len:= 1;
        fi;
        for i in [ 1 .. len ] do
          name:= info.strings[i];
          if namelen < Length( name ) then
            namelen:= Length( name );
          fi;
          for p in entry[2] do
            if maxprime < p then
              maxprime:= p;
            fi;

            # Store only the first two columns now,
            # compute the polynomials and their degrees on demand.
            Add( mat, [ rec( rows:= [ name ], align:= "l" ), String( p ) ] );
            Add( infos, rec( name:= name, p:= p, value:= info.conjugates[i] ) );
          od;
        od;
      od;

      CTblLib.BrowseCommonIrrationalitiesInfo:= rec(
          mat:= mat,
          infos:= infos,
          maxprime:= maxprime,
          namelen:= namelen,
        );
    fi;
    end;


#############################################################################
##
#F  CTblLib.CompareIrratNames( <nam1>, <nam2> )
##
##  We assume that <nam1> and <nam2> start with one lower alpha character,
##  optionally followed by a number of '\'' characters,
##  some digit characters,
##  and one or two '*' characters and some digit characters.
##
##  The two names are compared such that
##  - initial non-digit substrings are ordered lexicographically,
##  - subsequent dashes appear in non-decreasing order,
##  - subsequent digit parts are ordered w.r.t. the corresponding integers,
##  - subsequent non-digit parts (`*k', `**') are ordered lexicographically.
##
##  For example,
##  `"b5"' comes before `"b13"', both precede `"i11"' and `"i11**"',
##  and `"y24"' comes before `"y'24"' and this comes before `"y''24"';
##  also `"k'52"' comes before `"k56"' --this is the only incompatibility
##  with `BrowseData.CompareAsNumbersAndNonnumbers'.
##
CTblLib.CompareIrratNames:= function( nam1, nam2 )
    local pos1, pos2, len1, len2, comparenumber, i1, i2;

    # Compare the initial alphabet characters.
    if nam1[1] < nam2[1] then
      return true;
    elif nam2[1] < nam1[1] then
      return false;
    fi;

    len1:= Length( nam1 );
    len2:= Length( nam2 );
    if len1 = 1 then
      return len2 <> 1;
    elif len2 = 1 then
      return true;
    fi; 

    # Compute the numbers of '\'' characters.
    pos1:= 2;
    while nam1[ pos1 ] = '\'' do
      pos1:= pos1 + 1;
    od;
    pos2:= 2;
    while nam2[ pos2 ] = '\'' do
      pos2:= pos2 + 1;
    od;

    # Compute and compare the integer parts.
    comparenumber:= 0;
    i1:= pos1;
    i2:= pos2;
    while i1 <= len1 and nam1[ i1 ] in DIGITS do
      if i2 <= len2 and nam2[ i2 ] in DIGITS then
        if comparenumber = 0 then
          # This is the first digit, or previous digits were equal.
          if   nam1[ i1 ] < nam2[ i2 ] then
            comparenumber:= 1;
          elif nam1[ i1 ] <> nam2[ i2 ] then
            comparenumber:= -1;
          fi;
        fi;
      else
        # The first number is longer and thus larger.
        return false;
      fi;
      i1:= i1 + 1;
      i2:= i2 + 1;
    od;

    if i2 <= len2 and nam2[ i2 ] in DIGITS then
      # The second number is longer and thus larger.
      return true;
    fi;

    # The numbers have the same length.
    # Compare first the numbers, then the numbers of dashes.
    if   comparenumber = 1 then
      return true;
    elif comparenumber = -1 then
      return false;
    elif pos1 < pos2 then
      return true;
    elif pos2 < pos1 then
      return false;
    fi;

    # The numbers and the numbers of dashes are equal,
    # in particular `i1 = i2' holds.
    # Compare the suffixes.
    while i1 <= len1 do
      if   i1 > len2 then
        return false;
      elif nam1[ i1 ] <> nam2[ i1 ] then
        return nam1[ i1 ] <> nam2[ i1 ];
      fi;
      i1:= i1 + 1;
    od;

    # Now the longer string is larger.
    return i1 <= len2;
    end;


#############################################################################
##
#F  BrowseCommonIrrationalities()
##
##  <#GAPDoc Label="BrowseCommonIrrationalities">
##  <ManSection>
##  <Func Name="BrowseCommonIrrationalities" Arg=''/>
##
##  <Returns>
##  a list of info records for the irrationalities that have been
##  <Q>clicked</Q> in visual mode.
##  </Returns>
##
##  <Description>
##  This function shows the atomic irrationalities that occur in character
##  tables in the &ATLAS; of Finite Groups&nbsp;<Cite Key="CCN85"/> or the
##  &ATLAS; of Brauer Characters&nbsp;<Cite Key="JLPW95"/>, together with
##  descriptions of their reductions to the relevant finite fields
##  (in the same format as in <Cite Key="JLPW95" Where ="Appendix 1"/>),
##  in a browse table with the following columns.
##  <P/>
##  <List>
##  <Mark><C>name</C></Mark>
##  <Item>
##     the name of the irrationality,
##     see <Ref Func="AtlasIrrationality" BookName="ref"/>,
##  </Item>
##  <Mark><C>p</C></Mark>
##  <Item>
##     the characteristic,
##  </Item>
##  <Mark><C>value mod C_n</C></Mark>
##  <Item>
##     the corresponding reduction to a finite field of characteristic
##     <C>p</C>, given by the residue modulo the <C>n</C>-th
##     Conway polynomial (see <Ref Func="ConwayPolynomial" BookName="ref"/>),
##  </Item>
##  <Mark><C>n</C></Mark>
##  <Item>
##     the degree of the smallest extension of the prime field of
##     characteristic <C>p</C> that contains the reduction.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> n:= [ 14, 14, 14 ];;  # ``do nothing'' input (means timeout)
##  gap> BrowseData.SetReplay( Concatenation(
##  >         # categorize the table by the characteristics
##  >         "scrsc", n, n,
##  >         # expand characteristic 2
##  >         "srxq", n, n,
##  >         # scroll down
##  >         "DDD", n, n,
##  >         # and quit the application
##  >         "Q" ) );
##  gap> BrowseCommonIrrationalities();;
##  gap> BrowseData.SetReplay( false );
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "BrowseCommonIrrationalities", function()
    local r, infos, plen, winwidth, polwidth, sel_action, table, result;

    # Load the irrationalities info if necessary.
    CTblLib.PrepareCommonIrrationalitiesInfo();
    r:= CTblLib.BrowseCommonIrrationalitiesInfo;
    infos:= r.infos;

    # Compute column widths:
    # 13 characters are needed for the colsep entries,
    # the degree column needs 2 characters,
    # we get the width of the characteristics column from `maxprime', 
    # and the width of the names column is `namelen'.
    plen:= LogInt( r.maxprime, 10 ) + 1;
    winwidth:= NCurses.getmaxyx( 0 )[2];
    polwidth:= winwidth - r.namelen - plen - 15;

    sel_action:= rec(
      helplines:= [ "add the irrationality info to the result list" ],
      action:= function( t )
        local i;

        if t.dynamic.selectedEntry <> [ 0, 0 ] then
          i:= t.dynamic.indexRow[ t.dynamic.selectedEntry[1] ] / 2;
          Add( t.dynamic.Return, infos[i] );
        fi;
      end );

    # Construct the browse table.
    table:= rec(
      work:= rec(
        align:= "lt",
        header:= t -> BrowseData.HeaderWithRowCounter( t,
                        "Common Irrationalities in GAP",
                        Length( r.mat ) ),
        CategoryValues:= function( t, i, j )
          if   j = 2 then
            return [ t.work.main[ i/2 ][1].rows[1] ];
          elif j = 4 then
            return [ Concatenation( "p = ", t.work.main[ i/2 ][2] ) ];
          elif j = 6 then
            return [ Concatenation( t.work.Main( t, i/2, j/2 ) ) ];
          elif j = 8 then
            return [ Concatenation( "n = ",
                         t.work.Main( t, i/2, 4 ).rows[1] ) ];
          else
            Error( "this should not happen" );
          fi;
        end,

        # Avoid computing strings for all entries in advance.
        main:= r.mat,
        n:= 4,
        Main:= function( t, i, j )
          local p, red, level;

          p:= EvalString( t.work.main[i][2] );
          if not IsBound( infos[i].reduction ) then
            # Omit warnings, they mess up the browse table.
            level:= InfoLevel( InfoWarning );
            SetInfoLevel( InfoWarning, 0 );
            red:= ReductionToFiniteField( infos[i].value, p );
            SetInfoLevel( InfoWarning, level );
            if red = fail then
              red:= [ "?", "?" ];
            fi;
            infos[i].reduction:= red[1];
            infos[i].degree:= red[2];
          fi;
          if j = 3 then
            # the polynomial
            if infos[i].reduction = "?" then
              return [ "?" ];
            else  
              return SplitString( FormatParagraph(
                CTblLib.StringPol( infos[i].reduction, "^", "" ),
                polwidth, "left" ), "\n" );
            fi;
          elif j = 4 then
            # the degree of the field extension
            return rec( rows:= [ String( infos[i].degree ) ], align:= "r" );
          else
            Error( "this should not happen" );
          fi;
        end,

        labelsRow:= [],
        labelsCol:= [ [ rec( rows:= [ "name" ], align:= "l" ),
                        rec( rows:= [ "p" ], align:= "r" ),
                        rec( rows:= [ "value mod C_n" ], align:= "r" ),
                        rec( rows:= [ "n" ], align:= "r" ),
                      ] ],
        sepLabelsCol:= "=",
        sepRow:= "-",
        sepCol:= [ "| ", " | ", " | ", " | ", " |" ],

        widthCol:= [ , r.namelen,, plen,, polwidth,, 2 ],
        SpecialGrid:= BrowseData.SpecialGridLineDraw,
        Click:= rec(
          select_entry:= sel_action,
          select_row:= sel_action,
        ),
      ),
      dynamic:= rec(
        sortFunctionsForColumns:= [ CTblLib.CompareIrratNames,
                                    BrowseData.CompareLenLex,
                                    CTblLib.CompareStringPol,
                                    BrowseData.CompareLenLex ],
        Return:= [],
      ),
    );

    # Show the browse table.
    result:= NCurses.BrowseGeneric( table );

    # Construct the return value.
    return List( DuplicateFreeList( result ), ShallowCopy );
    end );


#############################################################################
##
##  Add the Browse application to the list shown by `BrowseGapData'.
##
BrowseGapDataAdd( "Common Irrationalities",
    BrowseCommonIrrationalities, true, "\
the list of atomic irrationalities that occur in ATLAS character \
tables, shown in a browse table whose columns contain the names, \
the characteristic p of the table, the degree d of the smallest \
field extension that contains the value, and the reduction modulo p \
(as the residue modulo the d-th Conway polynomial)" );


#############################################################################
##
#E

