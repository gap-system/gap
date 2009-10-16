##############################################################################
##
#F  ReductionToFiniteField( <value>, <p> )
##
#T replace the corresponding library function!
##  Let <value> be a cyclotomic integer (see~"IsCycInt"), and <p> a prime.
##  `ReductionToFiniteField' returns a pair `[ <pol>, <m> ]' where <pol> is
##  a polynomial over the field with <p> elements,
##  and <m> is an integer such that the field with $<p>^<m>$ elements is the
##  minimal field that contains the reduction under the ring homomorphism
##  ...
##  We have that the reduction of <value> is represented by <pol> modulo
##  the ideal spanned by the Conway polynomial (see~"ConwayPolynomial")
##  of degree <m>.
##
BindGlobal( "ReductionToFiniteField", function( value, p )
    local primefield,   # `GF(p)'
          x,            # indeterminate
          n,            # conductor of `value'
          k,            # degree of smallest field containing `n'-th roots
          conwaypol,    # `k'-th Conway polynomial in characteristic `p'
          size,         # `p^k'
          power,        # `( size - 1 ) / n'
          primes,
          m,            # degree of smallest field containing the result
          zero,         # zero of `primefield'
          l,
          mc,
          coeffs,
          y,
          fieldbase,
          i,
          sol,
          redsol;

    primefield:= GF(p);
    x:= Indeterminate( primefield );

    # If <value> belongs to a <p>-singular element then return `fail'.
    n:= Conductor( value );
    if n mod p = 0 then
      return fail;
    fi;

    # Catch the case where the reduction trivially lies in the prime field.
    if IsRat( value ) then
      return ( value mod p ) * One( x );
#T not a valid return value!!
    elif IsCycInt( value / p ) then
      return Zero( x );
    fi;

    # Compute the size $p^k$ of the smallest finite field of characteristic
    # `p' that contains `n'-th roots of unity.
    k:= OrderMod( p, n );

    # Give up if the required Conway polynomial is hard to compute.
    if not IsCheapConwayPolynomial( p, k ) then
      Info( InfoWarning, 1,
            "the Conway polynomial of degree ", k, " for p = ", p,
            " is not known" );
      return fail;
    fi;
    conwaypol:= ConwayPolynomial( p, k );

    # The root `E(n)' is identified with the smallest primitive `n'-th
    # root in the finite field, that is, the `(size-1) / n'-th power of
    # the primitive root of the field
    # (which is given by the Conway polynomial).
    size:= p^k;
    power:= ( size - 1 ) / n;
    value:= ValuePol( List( COEFFS_CYC( value ), y -> y mod p )
                      * One( primefield ),
                      PowerMod( x, power, conwaypol ) ) mod conwaypol;

    # Reduce the representation into the smallest finite field.
    # The currently known minimal field always has size `p^k'.
    m:= k;
    sol:= fail;

    if k <> 1 then

      primes:= Set( Factors( m ) );
      zero:= Zero( primefield );
      coeffs:= ShallowCopy( CoefficientsOfUnivariatePolynomial( value ) );
      while Length( coeffs ) < k do
        Add( coeffs, zero );
      od;

      while not IsEmpty( primes ) do

        for l in ShallowCopy( primes ) do

          # `p^(m/l)' is the candidate for next smaller field.
          mc:= m / l;

          # Compute a $GF(p)$-basis $(\hat{y}^i; 0\leq i\leq mc-1)$ of
          # the subfield of $GF( p^k )$ isomorphic with $GF( p^mc )$.
          y:= PowerMod( x, (size - 1) / (p^mc - 1), conwaypol );

          fieldbase:=[];
          for i in [ 1 .. mc ] do
            fieldbase[i]:= ShallowCopy( CoefficientsOfUnivariatePolynomial(
                               PowerMod( y, i-1, conwaypol ) ) );
            while Length( fieldbase[i] ) < k do
              Add( fieldbase[i], zero );
            od;
          od;

          # Check whether `value' is a linear combination of this basis.
          redsol:= SolutionMat( fieldbase, coeffs );
          if redsol = fail then
            RemoveSet( primes, l );
          else
            sol:= redsol;
            m:= mc;
          fi;

        od;

        IntersectSet( primes, Factors( m ) );

      od;
    fi;

    if sol <> fail then
      value:= ValuePol( sol, x );
#T and if fail?
    fi;

    # Return the reduction into the minimal field.
    return [ value, m ];
end );


##############################################################################
##
#F  CommonIrrationalityInfo( <irrat> )
#F  CommonIrrationalityInfo( <irratname> )
##
##  In the first form, <irrat> must be a cyclotomic integer.
##  In the second form, <irratname> must be a string describing an
##  irrational value as described in Chapter~6, Section~10 of~\cite{CCN85}
##  (see~"AtlasIrrationality" in the {\GAP} Reference Manual).
##
##  `CommonIrrationalityInfo' returns a record with the following components.
##  \beginitems
##  `conjugates'
##      the list $[ c_1, c_2, \ldots, c_n ]$ of algebraic conjugates
##      (see~"ref:Conjugates" in the {\GAP} Reference Manual)
##      of the algebraic integer $c_1$ in question,
##
##  `galois'
##      the sorted list $[ k_1, k_2, \ldots, k_n ]$ of the smallest positive
##      integers $k_i$ with the property that $`GaloisCyc'( c_1, k_i ) = c_i$,
##
##  `strings'
##      a list $[ s_1, s_2, \ldots, s_n ]$ of strings describing the values
##      $c_i$;
##      if an algebraic number <irrat> was given as the second argument then
##      $s_i$ is of the form $`A*'k_i$;
##      if a string <irratname> was given then
##      $s_i$ is of the form $<irratname>`*'k_i$ or $(<irratname>)`*'k_i$;
##      in both situations, $k_i$ is omitted or replaced by `*' if $n = 2$,
##  \enditems
#T in Appendix~1 of \cite{JLPW95}
##
BindGlobal( "CommonIrrationalityInfo", function( irratname )
    local irrat, N, conj, gal, strings, i;

    if IsCycInt( irratname ) then
      irrat:= irratname;
      irratname:= "A";
    elif IsString( irratname ) then
      irrat:= AtlasIrrationality( irratname );
    else
      Error( "<irratname> must be a (name of a) cyclotomic integer" );
    fi;

    if irrat = fail then
      Error( "<irratname> is not a valid name for an Atlas irrationality" );
    fi;

    N:= Conductor( irrat );

    conj:= Set( Conjugates( irrat ) );
    gal:= List( conj,
                c -> First( [ 1 .. N ], i -> GaloisCyc( irrat, i ) = c ) );
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
end );


##############################################################################
##
#F  SortedListOfCommonIrrationalitiesNames( <irratnames> )
##
##  Let <irratnames> be a list of strings denoting atomic irrationalities.
##  `SortedListOfCommonIrrationalitiesNames' returns a list that contains the
##  same strings but that is sorted in such a way that initial non-digit
##  substrings are ordered lexicographically and subsequent digit parts are
##  ordered w.r.t. the corresponding integers;
##  subsequent non-digit parts are ordered lexicographically.
##  For example, `"b5"' comes before `"b13"', and both precede `"i11"' and
##  `"i11**"'.
##
BindGlobal( "SortedListOfCommonIrrationalitiesNames", function( irratnames )
    local tosort, name, i, init1, pos, init2, result;

    tosort:= [];
    for name in irratnames do
      i:= 1;
      while i <= Length( name ) and IsAlphaChar( name[i] ) do
        i:= i+1;
      od;
      init1:= name{ [ 1 .. i-1 ] };
      pos:= i;
      while i <= Length( name ) and IsDigitChar( name[i] ) do
        i:= i+1;
      od;
      init2:= Int( name{ [ pos .. i-1 ] } );
      Add( tosort, [ init1, init2 ] );
    od;

    result:= ShallowCopy( irratnames );
    SortParallel( tosort, result );

    return result;
end );


##############################################################################
##
#F  IrratNamesInCambridgeFormatFiles( <dirname> )
##
##  get pairs `[ <irrat>, <prime> ]' from Cambridge files
##
BindGlobal( "IrratNamesInCambridgeFormatFiles", function( dirname )
    local string, dir, filenames, irratnames, name,
          filename, primes, pos, entry, n, ppos;

    # List the files (which might be gzipped).
    filenames:= Difference( DirectoryContents( dirname ), [ ".", ".." ] );

    # Loop over the files.
#T check whether the file is a Cambridge file at all?
    dir:= Directory( dirname );
    irratnames:= [];
    for name in filenames do

      # Read the file (which may be gzipped).
      if     3 < Length( name )
         and name{ [ -2 .. 0 ] + Length( name ) } = ".gz" then
        filename:= Filename( dir, name{ [ 1 .. Length( name ) - 3 ] } );
      else
        filename:= Filename( dir, name );
      fi;
#T needed?
      string:= StringFile( filename );
      string:= SplitString( string, "", " \n" );

      # If we are scanning a Brauer table then we just take the
      # defining prime.
      # For an ordinary table, we get the list of all possible
      # characteristics from the `#4' line.
      primes:= [];
      ppos:= PositionSublist( name, "mod" );
      if ppos = fail then
        pos:= Position( string, "#4" );
        if pos <> fail then
          pos:= pos+1;
          while pos <= Length( string ) and string[ pos ][1] <> '#' do
            entry:= string[ pos ];
            if IsDigitChar( entry[1] ) then
              entry:= Int( Filtered( entry, IsDigitChar ) );
              if 1 < entry then
                UniteSet( primes, FactorsInt( entry ) );
              fi;
            fi;
            pos:= pos + 1;
          od;
        fi;
      else
        pos:= 1;
        ppos:= Int( name{ [ ppos+3 .. Length( name ) ] } );
        if ppos <> fail then
          primes[1]:= ppos;
        fi;
      fi;

      # Get the atomic irrationalities from the `#5' lines.
      while pos <= Length( string ) do
        pos:= Position( string, "#5", pos-1 );
        if pos = fail then
          pos:= Length( string ) + 1;
        else
          while     pos <= Length( string )
                and ( string[ pos ][1] <> '#' or string[ pos ] = "#5" ) do
            entry:= string[ pos ];
            if ForAny( entry, IsAlphaChar ) and not 'o' in entry then
              entry:= entry{ [ PositionProperty( entry, IsAlphaChar ) .. Length( entry ) ] };
              ppos:= PositionProperty( entry, x -> x in "&+-*" );
              if ppos <> fail then
                string[ pos ]:= entry{ [ ppos .. Length( entry ) ] };
                entry:= entry{ [ 1 .. ppos-1 ] };
              else
                string[ pos ]:= "*";
              fi;
              while '\"' in entry do
                ppos:= Position( entry, '\"' );
                entry:= Concatenation( entry{ [ 1 .. ppos-1 ] }, "''",
                            entry{ [ ppos+1 .. Length( entry ) ] } );
              od;
              n:= Conductor( AtlasIrrationality( entry ) );
              UniteSet( irratnames,
                        List( Filtered( primes, p -> n mod p <> 0 ),
                              p -> [ entry, p ] ) );
            else
              pos:= pos + 1;
            fi;
          od;
        fi;
      od;

    od;

    # Return the list of pairs.
    return irratnames;
end );


##############################################################################
##
#T better use the stuff in htmlutils.g
##
FormatInfo:= rec(
      LaTeX := rec( suffix:= ".tex",
                    openmath:= "$",
                    closemath:= "$",
                    opensub:= LaTeXGlobals.sub[1],
                    closesub:= LaTeXGlobals.sub[2],
                    opensup:= LaTeXGlobals.super[1],
                    closesup:= LaTeXGlobals.super[2],
                    opencenter:= LaTeXGlobals.center[1],
                    closecenter:= LaTeXGlobals.center[2],
                    closefile:= "\\end{document}\n\n",
                    header:= function( title ) return Concatenation(
                      "\\begin{center}\n",
                      title,
                      "\n\\end{center}\n" ); end,
                    vspace:= "\n\\vspace*{1cm}\n\n",
                    star:= LaTeXGlobals.ast,
                    labels:= [ "$\\xi$", "$f$", "$C_n$" ] ),
      HTML  := rec( suffix:= ".htm",
                    openmath:= "", closemath:= "",
                    opensub:= HTMLGlobals.sub[1],
                    closesub:= HTMLGlobals.sub[2],
                    opensup:= HTMLGlobals.super[1],
                    closesup:= HTMLGlobals.super[2],
                    opencenter:= HTMLGlobals.center[1],
                    closecenter:= HTMLGlobals.center[2],
                    closefile:= HTMLFooter(),
                    header:= function( title ) return Concatenation(
                       "\n\n<!-- ------------------------------------------------------------------- -->\n",
                       "<font color=\"#009900\">\n",
                       "<h3 align=\"center\">",
                       title,
                       "</h3>\n",
                       "</font>\n\n" ); end,
                    vspace:= "\n<br>\n",
                    star:= HTMLGlobals.ast,
                    labels:= [ HTMLGlobals.xi,
                               "f",
                               "C<sub>n</sub>" ] ) );


##############################################################################
##
#F  CommonIrrationalitiesInfoString( <p>, <irratnames>, <format> )
##
##  table of Conway polynomials,
##  and table of irrationalities with reductions and degrees
##
BindGlobal( "CommonIrrationalitiesInfoString",
    function( p, irratnames, format )
    local formatinfo,
          conjugates, strings, name, record, i, pos, polstring, degrees,
          table2, val, d, f, table1, linesperpage, header, str;

    if   format = "LaTeX" then
      formatinfo:= FormatInfo.LaTeX;
    elif format = "HTML" then
      formatinfo:= FormatInfo.HTML;
    else
      Error( "<format> must be one of \"LaTeX\", \"HTML\"" );
    fi;

    # Sort the irrationalities.
    irratnames:= SortedListOfCommonIrrationalitiesNames( irratnames );

    conjugates := [];
    strings    := [];

    for name in irratnames do
      record:= CommonIrrationalityInfo( name );
      if record <> fail then
        if     Length( record.conjugates ) = 2
           and record.conjugates[1] = - record.conjugates[2] then
          Add( conjugates, record.conjugates[1] );
          Add( strings   , record.strings[1]    );
        else
          Append( conjugates, record.conjugates );
          Append( strings   , record.strings    );
        fi;
      fi;
    od;

    if IsEmpty( conjugates ) then
      return fail;
    fi;

    # Replace `*'.
    for i in [ 1 .. Length( strings ) ] do
      pos:= Position( strings[i], '*' );
      if pos <> fail then
        if pos = Length( strings[i] ) or strings[i][ pos+1 ] <> '*' then
          strings[i]:= Concatenation( strings[i]{ [ 1 .. pos-1 ] },
                           formatinfo.openmath,
                           formatinfo.star,
                           formatinfo.closemath,
                           strings[i]{ [ pos+1 .. Length( strings[i] ) ] } );
        else
          strings[i]:= Concatenation( strings[i]{ [ 1 .. pos-1 ] },
                           formatinfo.openmath,
                           formatinfo.star,
                           formatinfo.star,
                           formatinfo.closemath,
                           strings[i]{ [ pos+2 .. Length( strings[i] ) ] } );
        fi;
      fi;
    od;

    polstring:= function( pol )
      local coeffs, deg, zero, one, str, i;

      coeffs:= CoefficientsOfUnivariatePolynomial( pol );
      if IsEmpty( coeffs ) then
        return Concatenation( formatinfo.openmath, "0", formatinfo.closemath );
      fi;

      deg:= Length( coeffs ) - 1;
      zero:= Zero( coeffs[1] );
      one:= One( coeffs[1] );
      str:= ShallowCopy( formatinfo.openmath );
      for i in [ deg, deg-1 .. 1 ] do
        if coeffs[ i+1 ] <> zero then
          if coeffs[ i+1 ] <> one then
            Append( str, String( Int( coeffs[ i+1 ] ) ) );
          fi;
          Append( str, "X" );
          if i <> 1 then
            Append( str, formatinfo.opensup );
            Append( str, String( i ) );
            Append( str, formatinfo.closesup );
          fi;
          Append( str, "\n" );
          Append( str, " + " );
        fi;
      od;
      if coeffs[1] = zero then
        Unbind( str[ Length( str ) ] );
        Unbind( str[ Length( str ) ] );
        Unbind( str[ Length( str ) ] );
        Unbind( str[ Length( str ) ] );
      else
        Append( str, String( Int( coeffs[1] ) ) );
      fi;
      Append( str, formatinfo.closemath );
      return str;
    end;

    degrees:= [];

    table2:= [];
    for i in [ 1 .. Length( conjugates ) ] do
      f:= ReductionToFiniteField( conjugates[i], p );
      if f = fail then
        Print( "#I  failed to compute the reduction of ", strings[i],
               " mod ", p, "\n" );
      else
        d:= f[2];
        AddSet( degrees, d );
        Add( table2, [ strings[i], polstring( f[1] ),
                       Concatenation( formatinfo.openmath,
                                      "C",
                                      formatinfo.opensub,
                                      formatinfo.openmath,
                                      String( d ),
                                      formatinfo.closesub,
                                      formatinfo.closemath ) ] );
      fi;
    od;

    table1:= [];
    for d in degrees do
      Add( table1, [ Concatenation( formatinfo.openmath,
                                    "C",
                                    formatinfo.opensub,
                                    String( d ),
                                    formatinfo.closesub,
                                    formatinfo.closemath ),
                     Concatenation( formatinfo.openmath,
                                    "=",
                                    formatinfo.closemath ),
                     polstring( ConwayPolynomial( p, d ) ) ] );
    od;

    # Prepare the output string.
    # (For HTML, make the section heading an anchor.)
    header:= Concatenation(
                 "Common Irrationalities in Characteristic ",
                 formatinfo.openmath,
                 String( p ),
                 formatinfo.closemath );
    if format = "HTML" then
      header:= Concatenation( "<a name=\"char", String( p ), "\">",
                              header,
                              "</a>" );
    fi;
    header:= formatinfo.header( header );

#T (Be careful about page breaks in the LaTeX case.)
    linesperpage:= 40;

    str:= "";
    if not IsEmpty( table1 ) then

      Append( str, DisplayStringLabelledMatrix( table1,
                   rec( format    := format,
                        header    := header,
                        collabels := [],
                        colsep    := [],
                        colalign  := [ , "l", "c", "l" ],
                        rowlabels := [],
                        rowsep    := []      ) ) );

      Append( str, formatinfo.vspace );

      Append( str, DisplayStringLabelledMatrix( table2,
                   rec( format    := format,
                        collabels := formatinfo.labels,
                        colsep    := [ , , "|", "|" ],
                        colalign  := [ , "l", "l", "l" ],
                        rowlabels := []         ) ) );

      Append( str, formatinfo.vspace );
      Append( str, formatinfo.vspace );

    fi;

    # Return the result.
    return str;
end );


#############################################################################
##
#F  CreateCommonIrrationalityFiles( <irratsinfo>, <format>, <filename> )
##
BindGlobal( "CreateCommonIrrationalityFiles",
    function( irratsinfo, format, filename )
    local primes, formatinfo, str, n, k, rowportions, r, i, p, irrats,
          sizescreen;

    primes:= Set( List( irratsinfo, x -> x[2] ) );
    sizescreen:= SizeScreen();
    SizeScreen( [ 1000 ] );

#     if   format = "LaTeX" then
#       formatinfo:= FormatInfo.LaTeX;
#       str:= Concatenation( "\\documentclass[12pt]{article}\n",
#                            "\\begin{document}\n\n",
#                            "\\title{Irrationalities and Conway polynomials}\n\n" );
#     elif format = "HTML" then
      formatinfo:= FormatInfo.HTML;
      str:= HTMLHeader( "Irrationalities and Conway polynomials",
                        "Irrationalities and their p-modular reductions",
                        "Irrationalities and Conway polynomials" );

      # In the HTML case, add a table with crossrefs to the characteristics.
      Append( str, "\n\n<!-- ------------------------------------------------------------------- -->\n" );
      Append( str, "<font color=\"#009900\">\n" );
      Append( str, "<h3 align=\"center\">Characteristics Available</h3>\n" );
      Append( str, "</font>\n\n" );

      n:= Length( primes );

      k:= Int( n / 10 );
      rowportions:= List( [ 1 .. k ], x -> [ 1 .. 10 ] + (x-1)*10 );
      if k*10 < n then
        Add( rowportions, [ k*10+1 .. n ] );
      fi;

      Append( str, "<table align=\"center\">\n" );
      for r in rowportions do
        Append( str, "    <tr>\n" );
        for i in r do
          Append( str, "      <td align="right"><a href=\"char" );
          Append( str, String( primes[i] ) );
          Append( str, ".htm\">" );
          Append( str, String( primes[i] ) );
          Append( str, "</a></td>\n" );
          Append( str, "      <td>&nbsp;</td>\n" );
        od;
        Append( str, "    </tr>\n" );
      od;
      Append( str, "</table>\n\n" );
      Append( str, "<br>\n<br>\n\n" );

#     else
#       Error( "<format> must be one of \"LaTeX\", \"HTML\"" );
#     fi;

    Append( str, formatinfo.closefile );

    # Print the string to the file.
    PrintTo( Concatenation( "htm/", filename, ".htm" ), str );

    # Build the strings, one for each characteristic.
    for p in primes do

      irrats:= List( Filtered( irratsinfo, x -> x[2] = p ), x -> x[1] );
      if not IsEmpty( irrats ) then
        str:= HTMLHeader( "Irrationalities and Conway polynomials",
                          "Irrationalities and their p-modular reductions",
                          "Irrationalities and Conway polynomials" );

        Append( str, CommonIrrationalitiesInfoString( p, irrats, format ) );
        Append( str, "\n\n" );
        Append( str, formatinfo.closefile );

        # Print the string to the file.
        PrintTo( Concatenation( "htm/char", String( p ), ".htm" ), str );
      fi;

    od;

    # Reset the screen size.
    SizeScreen( sizescreen );
end );


##############################################################################
##
#E

