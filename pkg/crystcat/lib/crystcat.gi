#############################################################################
##
#A  crystcat.gi                 GAP group library              Volkmar Felsch
##
#H  @(#)$Id: crystcat.gi,v 1.4 2000/04/18 16:10:04 gap Exp $
##
#Y  Copyright (C)  1994,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions  that allow to access most of the data which
##  are listed  in the tables  of the book  "Crystallographic groups of four-
##  dimensional space"  by Harold Brown, Rolf Buelow, Joachim Neubueser, Hans
##  Wondratschek, and Hans Zassenhaus (Wiley, New York, 1978).
##
##
##  For each  of the dimensions  2,  3,  and  4,  the tables  of the book are
##  arranged in the following hierarchical format:
##        dimension,
##          crystal family,
##            crystal system,
##              Q-class (geometric crystal class),
##                Z-class (arithmetic crystal class),
##                  space-group type.
##
##  The following conventions for  local variables are used throughout in all
##  functions of this library.
##
##  dim = dimension,
##  sys = crystal system number with respect to a given dimension,
##  qcl = Q-class number  with respect to given dimension and crystal system,
##  zcl = Z-class number with respect to given dimension, crystal system, and
##        Q-class,
##  sgt = space-group type  with respect to given dimension,  crystal system,
##        Q-class, and Z-class,
##  q   = Q-class number  with respect to the  list of all  Q-classes  of the
##        current dimension,
##  z   = Z-class number  with respect to the  list of all  Z-classes  of the
##        current dimension,
##  t   = space-group type  with respect to the list of all space-group types
##        of the current dimension,
##  CR  = catalogue   record   CrystGroupsCatalogue[dim]   for  the   current
##        dimension dim.
##
##  For most of the  functions in this library  there are two versions given,
##  a public version and an internal version  which are distinguished  by the
##  prefix  "CR_"  in the  name  of the  internal version  and  by  different
##  parameter lists.  The reason  for that distinction is  that in the public
##  functions  the  arguments  are  checked  for being  in range  whereas  no
##  argument checking is done in the internal functions.
##


#############################################################################
##
#M  CR_CharTableQClass( <CR parameter list> ) . . . char table of Q-class rep
##
##  'CR_CharTableQClass'  returns  the  character table  of a  representative
##  group of the specified Q-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'CharTableQClass'.
##
InstallGlobalFunction( CR_CharTableQClass, function ( param )

    local CR, dim, F, fgens, G, name, param1, qcl, sub, sys, table;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    CR := CrystGroupsCatalogue[dim];

    if dim = 4 and sys = 31 and 3 <= qcl and qcl <= 7 then

        # The given group is not solvable. Compute its table from a
        # permutation group isomorphic to the f.p. group.
        F := CR_FpGroupQClass( param );
        fgens := GeneratorsOfGroup( F );

        if qcl = 3 then
            # group 60.13 ($A_5$)
            sub := Subgroup( F, fgens{ [ 2 .. 4 ] } );
        elif qcl = 4 or qcl = 5 then
            # group 120.1 ($S_5$)
            sub := Subgroup( F, fgens{ [ 2, 3 ] } );
        elif qcl = 6 then
            # group 120.2 ($2 \times A_5$)
            sub := Subgroup( F, fgens{ [ 2 .. 4 ] } );
        elif qcl = 7 then
            # group 240.1 ($2 \times S_5$)
            sub := Subgroup( F, [ fgens[3], fgens[2]^2 ] );
        fi;
        param1 := [ dim, sys, qcl, 1 ];
        G := CR_MatGroupZClass( param1 );
        SetName( G, CR_Name( "MatGroupZClass", param1, 4 ) );

    else

        # The given group is solvable. Construct an isomorphic ag group
        # with a prime order pcgs and compute the table of that group.
        G := CR_PcGroupQClass( param, false );
        SetName( G, CR_Name( "FpGroupQClass", param, 3 ) );

    fi;

    table := CharacterTable( G );
    name := CR_Name( "CharTableQClass", param, 3 );
    SetName( table, name );
    SetIdentifier( table, name );

    return table;
end );

#############################################################################
##
#M  CR_DisplayQClass( <CR parameter list> ) . . .  display Q-class invariants
##
##  'CR_DisplayQClass'  displays  for the  specified  Q-class  the  following
##  information:
##  - the size of the groups in the Q-class,
##  - the isomorphism type of the groups in the Q-class,
##  - the Hurley pattern,
##  - the rational constituents,
##  - the number of Z-classes in the Q-class, and
##  - the number of space-group types in the Q-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'DisplayQClass'.
##
InstallGlobalFunction( CR_DisplayQClass, function ( param )

    local CR, dim, isotext, ord, pt1, pt2, pt3, q, qcl, snum, sys, text,
          type, zfirst, zlast, znum;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;

    ord := CR.orderQClass[q];
    type := QuoInt( CR.codedIsomorphismTypeQClass[q], 100 );
    isotext := RemInt( CR.codedIsomorphismTypeQClass[q], 100 );
    zfirst := CR.nullZClass[q] + 1;
    zlast := CR.nullZClass[q+1];
    znum := zlast - zfirst + 1;
    snum := CR.nullSpaceGroup[zlast+1] - CR.nullSpaceGroup[zfirst];
    pt1 := CR.codedDecompositionQClass[q];
    if pt1 > 4 then
        pt2 := QuoInt( pt1, 10 );
        pt3 := RemInt( pt1, 10 );
        pt1 := 1;
    fi;

    text := CR_TextStrings.QClass;

    # Print the Q-class type.
    if IsBound( CR.splittingQClass ) and CR.splittingQClass[q] then
        Print( text[8] );
    else
        Print( text[7] );
    fi;

    # Print "H" if the Q-class is a holohedry.
    if CR.hQClass[q] then Print( text[18] ); fi;

    # Print the Q-class parameters.
    Print( text[16], dim, text[15] );
    Print( sys, text[15], qcl, text[9] );

    # Print the order of the Q-class representative.
    Print( ord );

    # Print the isomorphism type of the Q-class representative.
    Print( text[10], ord, text[17], type );
    if isotext <> 0 then
        Print( text[20], CR_TextStrings.isomorphismType[isotext] );
    fi;

    # Print the Q-constituents.
    Print( text[21], text[pt1] );
    if pt1 = 1 then
        Print( CR_TextStrings.QConstituents[pt2], text[pt3] );
    fi;

    # Print the number of Z-classes in the given Q-class.
    pt1 := 11;
    if znum > 1 then pt1 := 12; fi;
    Print( znum, text[pt1] );

    # Print the number of space groups in the given Q-class.
    pt1 := 13;
    if snum > 1 then pt1 := 14; fi;
    Print( text[19], snum, text[pt1] );
    Print( "\n" );

end );

#############################################################################
##
#M  CR_DisplaySpaceGroupGenerators( <CR parameter list> ) . . . display space
#M  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  group generators
##
##  'CR_DisplaySpaceGroupGenerators'  displays the non-translation generators
##  of the space group specified by the given parameters.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'DisplaySpaceGroupGenerators'.
##
InstallGlobalFunction( CR_DisplaySpaceGroupGenerators, function ( param )

    local CR, dim, G, gen, gens, text;

    # Get some arguments.
    dim := param[1];
    CR := CrystGroupsCatalogue[dim];

    text := CR_TextStrings.spaceGroup;

    # Get the non-translation generators.
    gens := CR_GeneratorsSpaceGroup( param );

    # Print a heading.
    Print( text[13], CR_Name( "SpaceGroupOnLeftBBNWZ", param, 5 ), text[14] );

    # Print the non-translation generators.
    for gen in gens do PrintArray( gen ); Print( "\n" ); od;

end );

#############################################################################
##
#M  CR_DisplaySpaceGroupType( <CR parameter list> ) . . . . . . . . . display
#M  . . . . . . . . . . . . . . . . . . . . . . . . .  space group invariants
##
##  'CR_DisplaySpaceGroupType'  displays  for the  specified space-group type
##  the following information:
##  - the orbit size associated with the space-group type,
##  - the IT number (only in case dim = 2 or dim = 3), and
##  - the Hermann-Mauguin symbol (only in case dim = 2 or dim = 3).
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'DisplaySpaceGroupType'.
##
InstallGlobalFunction( CR_DisplaySpaceGroupType, function ( param )

    local CR, dim, it1, it2, obt, q, qcl, sgt, sys, t, text, z, zcl;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    zcl := param[4];
    sgt := param[5];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;
    z := CR.nullZClass[q] + zcl;
    t := CR.nullSpaceGroup[z] + sgt;

    text := CR_TextStrings.spaceGroup;

    # Print the space-group type.
    if dim > 2 and CR.splittingSpaceGroupType[t] then
        Print( text[2] );
    else
        Print( text[1] );
    fi;

    # Print the space group parameters.
    Print( text[6], dim, text[7] );
    Print( sys, text[7], qcl, text[7], zcl, text[7], sgt, text [12] );

    # Print the associated number in the International Tables.
    if dim <= 3 then
        it1 := t;
        it2 := 0;
        if dim = 3 then
            it1 := CR.internatTableSpaceGroupType[t];
            if it1 > 230 then
                it2 := QuoInt( it1, 1000 );
                it1 := RemInt( it1, 1000 );
            fi;
        fi;
        Print( text[3], it1, text[8], CR.HermannMauguinSymbol[it1] );
        if it2 = 0 then
            Print( text[10] );
        else
            Print( text[9], it2, text[8], CR.HermannMauguinSymbol[it2] );
            Print( text[11] );
        fi;
    else
        Print( text[10] );
    fi;

    # Print the orbit size.
    obt := 1;
    if sgt > 1 then
        obt := CR.orbitLengthSpaceGroup[t-z];
    fi;
    Print( text[5], obt );

    # Print a note, if the space group is fixed-point-free.
    if CR.fixedPointFreeSpaceGroup[t] then
        Print( text[4] );
    fi;
    Print( "\n" );

end );


#############################################################################
##
#M  CR_DisplayZClass( <CR parameter list> ) . . .  display Z-class invariants
##
##  'CR_DisplayZClass'  displays  for the  specified  Z-class  the  following
##  information:
##  - the Hermann-Mauguin symbol  of a representative space-group type  which
##    belongs to the Z-class (only in case dim = 2 or dim = 3),
##  - the Bravais type,
##  - some decomposability information,
##  - the number of space-group types belonging to the Z-class, and
##  - the size of the associated cohomology group.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'DisplayZClass'.
##
InstallGlobalFunction( CR_DisplayZClass, function ( param )

    local code, cohom, CR, decomp, dim, fam, q, qcl, sgt, snum, sys, t, text,
          type, z, zcl;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    zcl := param[4];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;
    z := CR.nullZClass[q] + zcl;
    sgt := param[5];

    fam := CR.familyCrystalSystem[sys];
    code := CR.codedPropertiesZClass[z];
    decomp := RemInt( code, 10 );
    code := QuoInt( code, 10 );
    type := RemInt( code, 10 );
    cohom := QuoInt( code, 10 );
    snum := CR.nullSpaceGroup[z+1] - CR.nullSpaceGroup[z];

    text := CR_TextStrings.ZClass;

    # Print the Z-class type.
    if IsBound( CR.splittingZClass ) and CR.splittingZClass[z] then
        Print( text[6] );
    else
        Print( text[5] );
    fi;

    # Print "B" if the Z-class is a Bravais Z-class.
    if CR.bZClass[z] then Print( text[15] ); fi;

    # Print the Z-class parameters.
    Print( text[14], dim, text[13] );
    Print( sys, text[13], qcl, text[13], zcl, text[12] );

    # Print the Hermann-Mauguin symbol.
    if dim <= 3 then
        if sgt = 0 then  sgt := 1;  fi;
        t := CR.nullSpaceGroup[z] + sgt;
        if dim = 3 then  t := CR.internatTableSpaceGroupType[t];  fi;
        if t > 230 then  t := QuoInt( t, 1000 );  fi;
        Print( text[11], CR.HermannMauguinSymbol[t], text[12] );
    fi;

    # Print family number and Bravais type.
    Print( text[7], CR_TextStrings.roman[fam], text[16],
        CR_TextStrings.roman[type] );
    Print( text[decomp] );

    # Print the number of space groups in the given Z-class.
    if snum = 1 then
        Print( text[17], snum, text[8] );
    else
        Print( text[17], snum, text[9] );
    fi;

    # Print the order of the cohomology group.
    Print( text[10], cohom, "\n" );

end );


#############################################################################
##
#M  CR_FpGroupQClass( <CR parameter list> ) . . . . Q-class rep as f.p. group
##
##  'CR_FpGroupQClass'  returns a f. p. group isomorphic to the groups in the
##  specified Q-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'FpGroupQClass'.
##
InstallGlobalFunction( CR_FpGroupQClass, function ( param )

    local CR, cr, crgens, crrels, dim, F, G, i, list, ngens, nrels, num, ord,
          q, qcl, rels, sys;

    dim := param[1];
    sys := param[2];
    qcl := param[3];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;

    ord := CR.orderQClass[q];

    if ord = 1 then

        F := FreeGroup( 0 );
        rels := [ ];

    else

        ngens := RemInt( CR.codedPresentationQClass[q], 10 );
        crgens := CR.generatorsQClass{ [ 8 - ngens .. 7 ] };

        num := QuoInt( CR.codedPresentationQClass[q], 10 );
        crrels := CR.relatorWordsQClass{ CR.relatorNumbersQClass[num] };
        nrels := Length( crrels );

        F := FreeGroup( ngens );
        if RemInt( ord, 60 ) = 0 then
            list := [ 1 .. nrels ];
        else
            list := Reversed( Concatenation(
                [ ngens + 1 .. nrels ], [ 1 .. ngens ] ) );
        fi;
        rels := List( list, i -> MappedWord( crrels[i], crgens,
            GeneratorsOfGroup( F ) ) );
    fi;
    G := F / rels;

    # Save the Q-class parameters in the group record.
    SetName( G, CR_Name( "FpGroupQClass", param, 3 ) );
    SetSize( G, ord );
    cr := rec( );
    cr.parameters := [ dim, sys, qcl ];
    SetCrystCatRecord( G, cr );

    return G;
end );


#############################################################################
##
#M  CR_GeneratorsSpaceGroup( <CR parameter list> ) . . space group generators
##
##  'CR_GeneratorsSpaceGroup'  returns the  non-translation generators of the
##  space group specified by the given parameters.
##
InstallGlobalFunction( CR_GeneratorsSpaceGroup, function ( param )

    local code, column, columnGeneratorSpaceGroup, CR, dim, dim1, gens, i, j,
          mat, modul, ngens, num, q, qcl, quot, sgt, sys, t, z, zcl;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    zcl := param[4];
    sgt := param[5];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;
    z := CR.nullZClass[q] + zcl;
    t := CR.nullSpaceGroup[z] + sgt;
    dim1 := dim + 1;
    modul := CR.modulSp;
    columnGeneratorSpaceGroup := CR.columnGeneratorSpaceGroup;

    code := 0;
    if t > CR.nullSpaceGroup[z] + 1 then
        code := CR.codedGeneratorsSpaceGroup[t-z];
    fi;

    gens := CR_GeneratorsZClass( dim, z );
    ngens := Length( gens );
    for i in [ 1 .. ngens ] do
        mat := gens[i];
        num := RemInt( code, modul ) + 1;
        code := QuoInt( code, modul );
        column := columnGeneratorSpaceGroup[num];
        quot := column[dim1];
        for j in [ 1 .. dim ] do
            mat[j][dim1] := column[j] / quot;
        od;
        mat[dim1] := ListWithIdenticalEntries( dim1, 0 );
        mat[dim1][dim1] := 1;
    od;

    return gens;
end );


#############################################################################
##
#M  CR_GeneratorsZClass( <dim>, <zclass> ) . . . . . . . .  matrix generators
##
##  'CR_GeneratorsZClass'   returns  a   set  of  matrix  generators   for  a
##  representative of the specified Z-class. These generators are chosen such
##  that  they  satisfy  the  defining  relators  which are  returned  by the
##  'CR_FpGroupQClass'  function for the representative  of the corresponding
##  Q-class.
##
InstallGlobalFunction( CR_GeneratorsZClass, function ( dim, z )

    local anz, code, codedGeneratorZClass, CR, gens, i, j, k, mat, modul,
          n, rowGeneratorZClass;

    CR := CrystGroupsCatalogue[dim];
    modul := CR.modulZ;
    rowGeneratorZClass := CR.rowGeneratorZClass;
    codedGeneratorZClass := CR.codedGeneratorZClass;
    n := CR.nullGeneratorsZClass[z];
    anz := CR.nullGeneratorsZClass[z+1] - n;
    gens := ListWithIdenticalEntries( anz, 0 );

    for i in [ 1 .. anz ] do
        mat := ListWithIdenticalEntries( dim, 0 );
        n := n + 1;
        code := CR.codedGeneratorZClass[n];
        for j in [ 1 .. dim ] do
            k := RemInt( code, modul ) + 1;
            code := QuoInt( code, modul );
            mat[j] := StructuralCopy( rowGeneratorZClass[k] );
        od;
        gens[i] := mat;
    od;

    return gens;
end );


#############################################################################
##
#M  CR_InitializeRelators( <CR catalogue> )  . . . . . initialize CR relators
##
##  'CR_InitializeRelators'   initializes  the  relator  words  list  of  the
##  crystallographic goups catalogue.
##
InstallGlobalFunction( CR_InitializeRelators, function ( CR )

    local a, b, c, d, e, F, f, g, gens, rels;

    # Define the abstract generators.
    F := FreeGroup( "g", "f", "e", "d", "c", "b", "a" );
    g := F.1; f := F.2; e := F.3; d := F.4; c := F.5; b := F.6; a := F.7;

    gens := [ g, f, e, d, c, b, a ];

    # Define the relator words.
    rels := [ a, a^2, a^3, a^4, a^5, a^6, a^8, a^10, a^12, b^2, b^2/a,
      b^2/a^2, b^2/a^3, b^2/a^6, b^2/a^9, b^3, b^4, b^5, b^6, b^10, b^12,
      c^2, c^2/a^6, c^3, c^4, c^6, c^6/a^2, d^2, d^4, d^5, d^6, d^6/b^2,
      d^10, e^2, e^3, e^6, f^2, f^6, g^2, Comm(a,b), Comm(a,b)/a,
      Comm(a,b)/a^2, Comm(a,b)/a^3, Comm(a,b)/a^4, Comm(a,b)/a^6,
      Comm(a,b)/a^8, Comm(a,b)/a^10, Comm(a,b)/b^4, Comm(a,b)/b^8,
      Comm(a,b^2)/b^3, Comm(a,b^2)/b^6, Comm(a,b^3)/b^2, Comm(a,b^3)/b^4,
      Comm(a,b^4)/b, Comm(a,b^4)/b^2, Comm(a,b^5), Comm(a,b^6)/b^8,
      Comm(a,b^7)/b^6, Comm(a,b^8)/b^4, Comm(a,b^9)/b^2, Comm(a,c),
      Comm(a,c)/(b*a), Comm(a,c)/(b*a^2), Comm(a,c)/(b*a^4),
      Comm(a,c)/(b*a^6), Comm(a,c)/(b^2*a), Comm(a,c)/(b^2*a^2),
      Comm(a,c)/(b^5*a^2), Comm(a,c)/(b^5*a^5), Comm(a,c)/(b^8*a^2),
      Comm(a,c)/(c^3*b^3*a), Comm(a,c)/(c^5*b*a), Comm(a,c)/a, Comm(a,c)/a^2,
      Comm(a,c)/a^4, Comm(a,c)/a^6, Comm(a,c)/a^10, Comm(a,c)/b,
      Comm(a,c)/b^2, Comm(a,c^2)/(b*a), Comm(a,c^2)/(b^2*a^2),
      Comm(a,c^2)/(c^3*b^2*a^3), Comm(a,c^2)/(c^5*b^2*a^3),
      Comm(a,c^3)/(c^5*a), Comm(a,c^3)/(c^5*b^4*a^3), Comm(a,c^4)/(c*b*a^3),
      Comm(a,c^4)/(c*b^2*a^3), Comm(a,c^4)/(c^3*b^2*a^3),
      Comm(a,c^5)/(b*a^2), Comm(a,c^5)/(c*b^3*a^3), Comm(a,c^5)/(c^4*b^6),
      Comm(a,d), Comm(a,d)/(b*a), Comm(a,d)/(b*a^4), Comm(a,d)/(c*a),
      Comm(a,d)/(c*b*a), Comm(a,d)/(c*b*a^2), Comm(a,d)/(c*b^2*a),
      Comm(a,d)/(c*b^3), Comm(a,d)/(d^2*c*b*a), Comm(a,d)/a, Comm(a,d)/a^2,
      Comm(a,d)/a^10, Comm(a,d)/b, Comm(a,d)/b^2, Comm(a,d^2)/(d^3*b*a),
      Comm(a,d^2)/(d^8*b*a), Comm(a,d^3)/(d^2*b*a), Comm(a,d^4)/(d^3*c),
      Comm(a,d^4)/(d^8*c), Comm(a,d^5), Comm(a,d^6)/(d^2*c*b*a),
      Comm(a,d^7)/(d^8*b*a), Comm(a,d^8)/(d^2*b*a), Comm(a,d^9)/(d^8*c),
      Comm(a,e), Comm(a,e)/(c*b*a), Comm(a,e)/(d*b*a), Comm(a,e)/(d*b*a^2),
      Comm(a,e)/(d*c*a), Comm(a,e)/(d^3*c*b^2*a), Comm(a,e)/d^3, Comm(a,f),
      Comm(a,f)/(c*a), Comm(a,f)/(d*c*a), Comm(a,f)/a^2, Comm(a,f)/b,
      Comm(a,g), Comm(b,c), Comm(b,c)/(b*a), Comm(b,c)/(b*a^2),
      Comm(b,c)/(b*a^3), Comm(b,c)/(b^2*a), Comm(b,c)/(b^2*a^2),
      Comm(b,c)/(b^2*a^4), Comm(b,c)/(b^4*a), Comm(b,c)/(b^4*a^2),
      Comm(b,c)/(b^5*a), Comm(b,c)/(c^3*b^2*a), Comm(b,c)/(c^4*b*a^2),
      Comm(b,c)/(c^4*b^4*a^2), Comm(b,c)/a, Comm(b,c)/a^2, Comm(b,c)/a^3,
      Comm(b,c)/a^4, Comm(b,c)/b, Comm(b,c)/b^2, Comm(b,c)/b^4,
      Comm(b,c)/b^10, Comm(b,c^2)/(c*a), Comm(b,c^2)/(c^3*b^2*a^3),
      Comm(b,c^2)/(c^3*b^8*a), Comm(b,c^2)/a, Comm(b,c^3)/(c^2*b^2*a^2),
      Comm(b,c^3)/(c^4*b^2*a^2), Comm(b,c^3)/(c^4*b^4*a^2),
      Comm(b,c^4)/(c^3*b^3*a^3), Comm(b,c^4)/(c^5*a^3),
      Comm(b,c^4)/(c^5*b^3*a), Comm(b,c^5)/(c^2*b^4*a^2),
      Comm(b,c^5)/(c^3*a), Comm(b,c^5)/(c^3*b^2*a^3), Comm(b,d),
      Comm(b,d)/(b*a), Comm(b,d)/(c*a), Comm(b,d)/(c*b*a),
      Comm(b,d)/(c*b^3*a), Comm(b,d)/a, Comm(b,d)/a^2, Comm(b,d)/a^3,
      Comm(b,d)/a^9, Comm(b,d)/b^2, Comm(b,d)/b^4, Comm(b,d)/c,
      Comm(b,d)/d^2, Comm(b,d^2)/d^4, Comm(b,d^3)/d, Comm(b,d^3)/d^6,
      Comm(b,d^4)/d^3, Comm(b,d^4)/d^8, Comm(b,d^5), Comm(b,d^6)/d^2,
      Comm(b,d^7)/d^4, Comm(b,d^8)/d^6, Comm(b,d^9)/d^8, Comm(b,e),
      Comm(b,e)/(c*b*a), Comm(b,e)/(c*b^2*a), Comm(b,e)/(d*b^2*a),
      Comm(b,e)/(d*c*b^2), Comm(b,e)/a, Comm(b,e)/b^2, Comm(b,f),
      Comm(b,f)/(d*c*b*a), Comm(b,f)/(d*c*b^2), Comm(b,f)/b^2, Comm(b,g)/a,
      Comm(c,d), Comm(c,d)/(b*a), Comm(c,d)/(b*a^2), Comm(c,d)/(c*b),
      Comm(c,d)/(c*b*a), Comm(c,d)/(c*b*a^2), Comm(c,d)/(c*b*a^3),
      Comm(c,d)/(c*b^2*a), Comm(c,d)/(c^2*b*a^3), Comm(c,d)/(c^2*b^3),
      Comm(c,d)/(c^4*b), Comm(c,d)/(c^4*b*a), Comm(c,d)/(d^3*a),
      Comm(c,d)/(d^8*a), Comm(c,d)/b, Comm(c,d)/b^2, Comm(c,d)/c,
      Comm(c,d)/c^2, Comm(c,d)/c^4, Comm(c,d^2)/(d*c*a),
      Comm(c,d^2)/(d^6*c*a), Comm(c,d^3)/(c*a), Comm(c,d^4)/(d^3*c^2*a),
      Comm(c,d^4)/(d^8*c^2*a), Comm(c,d^5), Comm(c,d^6)/(d^8*a),
      Comm(c,d^7)/(d^6*c*a), Comm(c,d^8)/(c*a), Comm(c,d^9)/(d^8*c^2*a),
      Comm(c,e), Comm(c,e)/(b*a), Comm(c,e)/(d*a^2), Comm(c,e)/(d*b^2),
      Comm(c,e)/(d*c*b^3), Comm(c,e)/(d^3*b), Comm(c,e)/b^3, Comm(c,e)/d^3,
      Comm(c,f), Comm(c,f)/(c*a), Comm(c,f)/(d*c*b^3), Comm(c,f)/b,
      Comm(c,f)/b^3, Comm(c,g)/(d^3*c*b^3), Comm(d,e)/(c*b^3*a),
      Comm(d,e)/(d*c*a^2), Comm(d,e)/(d*c*b*a), Comm(d,e)/(d*c*b^2),
      Comm(d,e)/(d^3*b^3*a), Comm(d,e)/(d^3*c*b), Comm(d,e)/(d^4*c),
      Comm(d,e)/(d^4*c*b*a), Comm(d,e), Comm(d,f)/(c*b*a),
      Comm(d,f)/(d*c*b*a), Comm(d,f)/(d^4*c*b), Comm(d,f)/a^3, Comm(d,f)/c,
      Comm(d,g)/(e*d^5*c*b^3*a), Comm(e,f)/(e*b), Comm(e,f)/(e*c*a^3),
      Comm(e,f)/(e*d*c*a^2), Comm(e,f)/(e^4*c*b^3*a), Comm(e,f)/e,
      Comm(e,g)/(e^2*d^4*c*b^2*a), Comm(f,g)];

    CR[2].generatorsQClass := gens;
    CR[3].generatorsQClass := gens;
    CR[4].generatorsQClass := gens;

    CR[2].relatorWordsQClass := rels;
    CR[3].relatorWordsQClass := rels;
    CR[4].relatorWordsQClass := rels;

end );


#############################################################################
##
#M  CR_MatGroupZClass( <CR parameter list> ) . .  Z-class rep as matrix group
##
##  'CR_MatGroupZClass'  returns  a  representative  group  of the  specified
##  Z-class.  The generators  of the  resulting matrix group  are chosen such
##  that they  satisfy  the  defining  relators  which  are  returned  by the
##  'CR_FpGroupQClass' function  for the representative  of the corresponding
##  Q-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'MatGroupZClass'.
##
InstallGlobalFunction( CR_MatGroupZClass, function ( param )

    local CR, cr, dim, G, gens, q, qcl, sys, z, zcl;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    zcl := param[4];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;
    z := CR.nullZClass[q] + zcl;

    if param{[2..4]} = [1,1,1] then
        gens := [];
    else
        gens := CR_GeneratorsZClass( dim, z );
    fi;
    G := Group( gens, Identity( CR.GLZ ) );

    # Save the Z-class parameters in the group record.
    SetSize( G, CR.orderQClass[CR.QClassZClass[z]] );
    SetName( G, CR_Name( "MatGroupZClass", param, 4 ) );
    cr := rec( );
    cr.parameters := [ dim, sys, qcl, zcl ];
    cr.conjugator := Identity( G );
    SetCrystCatRecord( G, cr );

    return G;
end );


#############################################################################
##
#M  CR_PcGroupQClass(<CR parameter list>,<warning>) . Q-class rep as pc group
##
##  'CR_PcGroupQClass'  returns  a pc group  isomorphic  to the groups in the
##  specified Q-class.  If <warning> = true, then a warning will be displayed
##  in case that the given presentation is not a prime order pcgs.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'PcGroupQClass'.
##
InstallGlobalFunction( CR_PcGroupQClass, function ( param, warning )

    local CR, cr, crgens, crrels, dim, F, G, i, ngens, nrels, num, ord, q,
          qcl, rels, sys;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;

    ord := CR.orderQClass[q];

    if RemInt( ord, 60 ) = 0 then
        Print( "#I  Warning: a non-solvable group can't be represented",
            " as a pc group\n" );
        return fail;
    fi;

    if ord = 1 then

        G := TrivialGroup( IsPcGroup );

    else

        ngens := RemInt( CR.codedPresentationQClass[q], 10 );
        crgens := CR.generatorsQClass{ [ 8 - ngens .. 7 ] };

        num := QuoInt( CR.codedPresentationQClass[q], 10 );
        crrels := CR.relatorWordsQClass{ CR.relatorNumbersQClass[num] };
        nrels := Length( crrels );

        F := FreeGroup( ngens );
        rels := List( [ 1 .. nrels ], i -> MappedWord( crrels[i],
            crgens, GeneratorsOfGroup( F ) ) );

        F := F / rels;
        G := PcGroupFpGroup( F );

        # Refine the pc series, if necessary.
        G := RefinedPcGroup( G );
        if warning and Length( GeneratorsOfGroup( G ) ) <>
            Length( GeneratorsOfGroup( F ) ) then
             Print( "#I  Warning: the presentation has been extended to get",
               " a prime order pcgs\n" );
        fi;

    fi;

    # Save the Q-class parameters in the group record.
    SetName( G, CR_Name( "PcGroupQClass", param, 3 ) );
    SetSize( G, ord );
    cr := rec( );
    cr.parameters := [ dim, sys, qcl ];
    SetCrystCatRecord( G, cr );

    return G;
end );


#############################################################################
##
#M  CR_Name( <string>, <CR parameter list>, <nparms> ) . . .  name of crystal
#M  . . . . . . . . . . . . . . . . . . . . . . . .  group or character table
##
##  'CR_Name'  returns  the "name"  of the  specified object  which  may be a
##  Z-class representative,  a Q-class representative or its character table,
##  or a space group.  The resulting name  is a string  which consists of the
##  given string  followed by the relevant parameters  which are separated by
##  commas and enclosed in parentheses.
##
InstallGlobalFunction( CR_Name, function ( string, param, nparms )

    local dim, name, qcl, sgt, sys, zcl;

    # Initialize the name by the given string and a left parenthesis.
    name := Concatenation( string, "( " );

    # Add the dimension.
    dim := param[1];
    name := Concatenation( name, String( dim ) );

    # Add the crystal system parameter.
    sys := param[2];
    name := Concatenation( name, ", " );
    name := Concatenation( name, String( sys ) );

    # Add the Q-class parameter.
    qcl := param[3];
    name := Concatenation( name, ", " );
    name := Concatenation( name, String( qcl ) );

    if nparms > 3 then

        # Add the Z-class parameter.
        zcl := param[4];
        name := Concatenation( name, ", " );
        name := Concatenation( name, String( zcl ) );

        if nparms > 4 then

            # Add the space-group type.
            sgt := param[5];
            name := Concatenation( name, ", " );
            name := Concatenation( name, String( sgt ) );
        fi;
    fi;

    # Close the name by a right parenthesis and return it.
    return Concatenation( name, " )" );
end );


#############################################################################
##
#M  CR_NormalizerZClass( <CR parameter list> ) . .  normalizer of Z-class rep
##
##  'CR_NormalizerZClass'   returns   the  normalizer  in  GL(dim,Z)  of  the
##  specified  Z-class  representative  matrix  group.  If the  order  of the
##  normalizer is  finite,  then the  group record components  "crZClass" and
##  "crConjugator" will be set properly.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'NormalizerZClass'.
##
InstallGlobalFunction( CR_NormalizerZClass, function ( param )

    local con, coninv, CR, cr, dim, gens, N, q1, qcl1, sys1, z, z1, z2, zcl1;

    # Get the arguments.
    dim := param[1];
    CR := CrystGroupsCatalogue[dim];
    z := CR.nullZClass[ CR.nullQClass[param[2]] + param[3] ] + param[4];

    z1 := RemInt( CR.codedNormalizerZClass[z], 1000 );
    z2 := QuoInt( CR.codedNormalizerZClass[z], 1000 );

    if z1 = 0 then

        gens := Concatenation(
            CR_GeneratorsZClass( dim, z ), CR_GeneratorsZClass( dim, z2 ) );

        N := Group( gens, Identity( CR.GLZ ) );
        SetSize( N, infinity );

    else

        gens := CR_GeneratorsZClass( dim, z1 );
        if z2 <> 0 then
            coninv := CR_GeneratorsZClass( dim, z2 )[1];
            con := coninv^-1;
            gens := coninv * gens * con;
        fi;

        q1 := CR.QClassZClass[z1];
        sys1 := CR.crystalSystemQClass[q1];
        qcl1 := q1 - CR.nullQClass[sys1];
        zcl1 := z1 - CR.nullZClass[q1];

        N := Group( gens, Identity( CR.GLZ ) );
        SetSize( N, CR.orderQClass[q1] );

        # Save the Z-class parameters in the normalizer group record.
        SetName( N, CR_Name( "NormalizerZClass", param, 4 ) );
        cr := rec( );
#       N.crZClass := [ dim, sys1, qcl1, zcl1 ];
        cr.parameters := [ dim, sys1, qcl1, zcl1 ];
        if z2 <> 0 then
#           N.crConjugator := con;
            cr.conjugator := con;
        else
#           N.crConjugator := Identity( N );
            cr.conjugator := Identity( N );
        fi;
        SetCrystCatRecord( N, cr );
    fi;

    return N;
end );


#############################################################################
##
#M  CR_Parameters( [ <dim>, <system>, <qclass>, <zclass>, <sgtype> ], nparms)
#M  CR_Parameters( [ <dim>, <system>, <qclass>, <zclass> ], nparms )  . . . .
#M  CR_Parameters( [ <dim>, <system>, <qclass> ], nparms ) . . . . . internal
#M  CR_Parameters( [ <dim>, <IT number> ], nparms ) . . . . .  parameters for
#M  CR_Parameters( [ <Hermann-Mauguin symbol> ], nparms ) . .  crystal groups
##
##  Valid argument lists are
##
##     [ dim, sys, qcl, zcl, sgt ], 5
##     [ dim, sys, qcl, zcl ], 4
##     [ dim, sys, qcl ], 3
##     [ 3, it ], n
##     [ 2, it ], n
##     [ symbol ], n
##
##  where
##
##  dim = dimension,
##  sys = crystal system number with respect to a given dimension,
##  qcl = Q-class number  with respect to given dimension and crystal system,
##  zcl = Z-class number with respect to given dimension, crystal system, and
##        Q-class,
##  sgt = space-group type  with respect to given dimension,  crystal system,
##        Q-class, and Z-class,
##  it  = corresponding  number   in  the   International  Tables  (only  for
##        dimensions 2 and 3),
##  n   = 3 or 4 or 5,
##  symbol = Hermann-Mauguin symbol (only for dimensions 2 or 3).
##
##  'CR_Parameters' checks the given arguments to be consistent and in range,
##   and returns them in form of an "internal CR parameter list"
##
##      [ dim, sys, qcl, zcl, sgt ]
##
##  which  contains  the  "local parameters"  of the  respective object.  The
##  following  "global parameters"  of the  same  object  are used  as  local
##  variables.
##
##  q   = Q-class number  with respect to the  list of all  Q-classes  of the
##        current dimension,
##  z   = Z-class number  with respect to the  list of all  Z-classes  of the
##        current dimension,
##  t   = space-group type  with respect to the list of all space-group types
##        of the current dimension,
##  CR  = catalogue   record   CrystGroupsCatalogue[dim]   for  the   current
##        dimension dim.
##
InstallGlobalFunction( CR_Parameters, function ( args, nparms )

    local catlist, CR, dim, it, nargs, param, q, qcl, sgt, symbol, sys, t, z,
          zcl;

    # Check number of arguments.
    nargs := Length( args );
    if nargs <> nparms and nargs <> 1 and nargs <> 2 then
        Error( "illegal number of arguments" );
    fi;

    # Initialize the parameters list.
    param := ListWithIdenticalEntries( 5, 0 );

    if nargs < 3 then

        if nargs = 1 then

            # The argument is a Hermann-Mauguin symbol.
            symbol := args[1];
            it := Position( CR_2.HermannMauguinSymbol, symbol );
            if it <> fail then
                dim := 2;
            else
                it := Position( CR_3.HermannMauguinSymbol, symbol );
                if it = fail then
                    Error( "don't know the given Hermann-Mauguin symbol" );
                fi;
                dim := 3;
            fi;
            CR := CrystGroupsCatalogue[dim];
            catlist := CR.spaceGroupTypeInternatTable;

        else

            # The second argument is an International Table number.
            # Check the dimension parameter.
            dim := args[1];
            if not IsInt( dim ) or dim < 2 or 4 < dim then
                Error( "inconsistent dimension parameter" );
            fi;
            CR := CrystGroupsCatalogue[dim];

            # Check the IT number.
            it := args[2];
            catlist := CR.spaceGroupTypeInternatTable;
            if not IsInt( it ) or it < 1 or Length( catlist ) < it then
                Error( "illegal IT number" );
            fi;
        fi;

        # Reconstruct the space group parameters from the coded information
        # in the catalogue list and store them in the parameters list.
        param[1] := dim;
        z := RemInt( catlist[it], 100 );
        q := CR.QClassZClass[z];
        sys := CR.crystalSystemQClass[q];
        param[2] := sys;
        param[3] := q - CR.nullQClass[sys];
        if nparms > 3 then
            param[4] := z - CR.nullZClass[q];
            t := QuoInt( catlist[it], 100 );
            param[5] := t - CR.nullSpaceGroup[z];
        fi;

    else

        # Check the dimension parameter.
        dim := args[1];
        if not IsInt( dim ) or dim < 2 or 4 < dim then
            Error( "illegal dimension parameter" );
        fi;
        param[1] := dim;

        # Check the crystal system parameter.
        sys := args[2];
        CR := CrystGroupsCatalogue[dim];
        if not IsInt( sys ) or sys < 1 or Length( CR.nullQClass ) <= sys then
            Error( "crystal system parameter out of range" );
        fi;
        param[2] := sys;

        # Check the Q-class parameter and get the Q-class number with respect
        # to all Q-classes for dimension dim.
        qcl := args[3];
        if not IsInt( qcl ) or qcl < 1 or
            CR.nullQClass[sys+1] - CR.nullQClass[sys] < qcl then
            Error( "Q-class parameter out of range" );
        fi;
        param[3] := qcl;

        if nargs > 3 then
            # Check the Z-class parameter and get the Z-class number with
            # respect to all Z-classes for dimension dim.
            zcl := args[4];
            q := CR.nullQClass[sys] + qcl;
            if not IsInt( zcl ) or zcl < 1 or
                CR.nullZClass[q+1] - CR.nullZClass[q] < zcl then
                Error( "Z-class parameter out of range" );
            fi;
            param[4] := zcl;

            if nargs > 4 then
                # Check the space-group type parameter.
                sgt := args[5];
                z := CR.nullZClass[q] + zcl;
                if not IsInt( sgt ) or sgt < 1 or
                    CR.nullSpaceGroup[z+1] - CR.nullSpaceGroup[z] < sgt then
                    Error( "space-group type parameter out of range" );
                fi;
                param[5] := sgt;
            fi;
        fi;
    fi;

    return( param );
end );


#############################################################################
##
#M  CR_SpaceGroup( <CR parameter list> ) . . . . . . . . . . . .  space group
##
##  'CR_SpaceGroup'  returns  a  representative  matrix  group  (of dimension
##  dim+1) of the specified space-group type.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'SpaceGroup'.
##
##  In particular, the function expects that, whenever the order of the point
##  group is not a multiple of 60,  the given  point group presentation  is a
##  polycyclic power commutator presentation  containing  a list of  n  power
##  relators  and  n*(n-1)/2  commutator relators  in some  prescribed order,
##  where n is the number of its generators.
##
InstallGlobalFunction( CR_SpaceGroup, function ( param )

    local CR, cr, crgens, crrels, dim, dim1, exp, G, g, g1, gen, gens, gens0,
          i, i1, i2, idword, inv, j, mat, leng, names, ngens, ngens0, ngens1,
          nrels, num, q, qcl, rel, rels, S, subword, sys, word;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;
    dim1 := dim + 1;

    # Get the non-translation generators.
    if param{[2..5]} = [1,1,1,1] then
        gens := [];
    else
        gens := CR_GeneratorsSpaceGroup( param );
    fi;

    # Add the translation generators.
    for i in [ 1 .. dim ] do
        mat := StructuralCopy( CR.spaceGroupIdentity );
        mat[i][dim1] := 1;
        Add( gens, mat );
    od;

    # Construct the space group.
    S := Group( gens, CR.spaceGroupIdentity );

    # Initialize a finitly presented group G isomorphic to S.
    ngens := Length( GeneratorsOfGroup( S ) );
    ngens0 := ngens - dim;
    ngens1 := ngens0 + 1;
    names := List( [ 1 .. ngens ],
        i -> Concatenation( "g", String( i ) ) );
    G := FreeGroup( names );
    g := GeneratorsOfGroup( G );
    idword := One( g[1] );
    rels := [ ];

    # Extended the point group relators.
    if ngens0 > 0 then
        g1 := g{ [ 1 .. ngens0 ] };
        gens0 := gens{ [ 1 .. ngens0 ] };
        crgens := CR.generatorsQClass{ [ 8 - ngens0 .. 7 ] };
        num := QuoInt( CR.codedPresentationQClass[q], 10 );
        crrels := CR.relatorWordsQClass{ CR.relatorNumbersQClass[num] };
        nrels := Length( crrels );
        if RemInt( CR.orderQClass[q], 60 ) = 0 then

            # The point group is non-solvable, so just extend its relators
            # appropriately.
            for i in [ 1 .. nrels ] do
                mat := MappedWord( crrels[i], crgens, gens0 );
                word := idword;
                for j in [ 1 .. dim ] do
                    word := word * g[ngens0+j]^mat[j][dim1];
                od;
                Add( rels, MappedWord( crrels[i], crgens, g1 ) * word^-1 );
            od;
        else

            # The point group is solvable, so construct a polycyclic
            # power commutator presentation.
            if nrels <> ngens0 * ngens1 / 2 then
                Error( "This is a bug. You should never get here.\n" );
            fi;

            # First handle the power relators.
            for i in [ 1 .. ngens0 ] do
                rel := crrels[ngens1-i];
                leng := Length( rel );
                gen := crgens[i];
                if leng < 2 or Subword( rel, 1, 2 ) <> gen^2 then
                    Error( "This is a bug. You should never get here.\n" );
                fi;
                exp := 2;
                while exp < leng and Subword( rel, exp+1, exp+1 ) = gen do
                    exp := exp + 1;
                od;
                word := idword;
                if exp = leng then
                    mat := gens0[i]^exp;
                    for j in [ 1 .. dim ] do
                        word := word * g[ngens0+j]^mat[j][dim1];
                    od;
                    Add( rels, g[i]^exp * word^-1 );
                else
                    subword := Subword( rel, exp + 1, leng );
                    mat := MappedWord( subword, crgens, gens0 ) *
                        gens0[i]^exp;
                    for j in [ 1 .. dim ] do
                        word := word * g[ngens0+j]^mat[j][dim1];
                    od;
                    Add( rels, g[i]^exp * word^-1 * MappedWord(
                       subword, crgens, g1 ) );
                fi;
            od;

            # Now handle the commutator relators.
            i := nrels + 1;
            for i2 in [ 2 .. ngens0 ] do
                for i1 in [ 1 .. i2 - 1 ] do
                    i := i - 1;
                    rel := crrels[i];
                    leng := Length( rel );
                    if leng < 4 or Subword( rel, 1, 4 ) <>
                        Comm( crgens[i2], crgens[i1] ) then
                        Error("This is a bug. You should never get here.\n");
                    fi;
                    word := idword;
                    if leng = 4 then
                        mat := Comm( gens0[i2], gens0[i1] );
                        for j in [ 1 .. dim ] do
                            word := word * g[ngens0+j]^mat[j][dim1];
                        od;
                        Add( rels, Comm( g[i2], g[i1] ) *
                            word^-1 );
                    else
                        subword := Subword( rel, 5, leng );
                        mat := MappedWord( subword, crgens, gens0 ) *
                            Comm( gens0[i2], gens0[i1] );
                        for j in [ 1 .. dim ] do
                            word := word * g[ngens0+j]^mat[j][dim1];
                        od;
                        Add( rels, Comm( g[i2], g[i1] ) *
                            word^-1 * MappedWord( subword, crgens, g1 ) );
                    fi;
                od;
            od;
        fi;
    fi;

    # Add the remaining commutator relators.
    inv := List( gens, mat -> mat^-1 );
    for i2 in [ ngens1 .. ngens ] do

        # Add the relators which describe the action of the non-translation
        # generators on the translation generators.
        for i1 in [ 1 .. ngens0 ] do
            mat := inv[i2] * inv[i1] * gens[i2] * gens[i1];
            word := idword;
            for j in [ 1 .. dim ] do
                word := word * g[ngens0+j]^mat[j][dim1];
            od;
            Add( rels, Comm( g[i2], g[i1] ) * word^-1 );
        od;

        # Add the commutator relators for the translation generators.
        for i1 in [ ngens1 .. i2 - 1 ] do
            Add( rels, Comm( g[i2], g[i1] ) );
        od;
    od;

    # Save the finitely presented group G in the group record of S.
    G := G / rels;

    # Save the space group type parameters in the group record.
    SetSize( S, infinity );
    SetName( S, CR_Name( "SpaceGroupOnLeftBBNWZ", param, 5 ) );
    cr := rec( );
    cr.parameters := param;
    cr.fpGroup := G;
    SetCrystCatRecord( S, cr );

    return S;
end );


#############################################################################
##
#M  CR_ZClassRepsDadeGroup( <CR parameter list>, <d> )  . . . .  Z-class reps
#M  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . in Dade group
##
##  'CR_ZClassRepsDadeGroup'  returns  a  list of  representatives  of  those
##  conjugacy classes  of subgroups of the given Dade group  which consist of
##  groups belonging to the given Z-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'ZClassRepsDadeGroup'.
##
InstallGlobalFunction( CR_ZClassRepsDadeGroup, function ( param, d )

    local code, con, CR, cr, dim, G, gens, i, j, k, mat, matinv, modul, n1,
          n2, name, q, qcl, reps, rowConjugatorDadeGroup, sys, z, zcl;

    # Get the arguments.
    dim := param[1];
    sys := param[2];
    qcl := param[3];
    zcl := param[4];
    CR := CrystGroupsCatalogue[dim];
    q := CR.nullQClass[sys] + qcl;
    z := CR.nullZClass[q] + zcl;

    rowConjugatorDadeGroup := CR.rowConjugatorDadeGroup;
    n1 := CR.nullDadeGroupsZClass[z] + 1;
    n2 := CR.nullDadeGroupsZClass[z+1];
    reps := [ ];

    # Loop over all Dade groups containing groups from the given Z-class.
    for i in [ n1 .. n2 ] do

        # Check the Dade group for being the given one.
        code := CR.codedDadeGroupsZClass[i];
        if RemInt( code, 10 ) = d then

            # Construct the representative matrix group of the given Z-class.
            gens := CR_GeneratorsZClass( dim, z );
            name := CR_Name( "MatGroupZClass", param, 4 );

            # Conjugate the group, if necessary.
            con := QuoInt( code, 10);
            if con = 0 then

                G := Group( gens, Identity( CR.GLZ ) );
                SetName( G, name );
                mat := Identity( G );

            else

                modul := 140;
                matinv := ListWithIdenticalEntries( dim, 0 );
                code := CR.codedConjugatorDadeGroup[con];
                for j in [ 1 .. dim ] do
                    k := RemInt( code, modul );
                    code := QuoInt( code, modul );
                    matinv[j] := StructuralCopy( rowConjugatorDadeGroup[k] );
                od;
                mat := matinv^-1;
                gens := matinv * gens * mat;
                G := Group( gens, Identity( CR.GLZ ) );
                SetName( G, Concatenation( Concatenation( name, "^" ),
                    String( mat ) ) );
            fi;

            # Save the Z-class parameters in the group record.
            SetSize( G, CR.orderQClass[CR.QClassZClass[z]] );

            cr := rec( );
            cr.parameters := [ dim, sys, qcl, zcl ];
            cr.conjugator := mat;
            SetCrystCatRecord( G, cr );

            # Save the group in the list.
            Add( reps, G );
        fi;
    od;

    return reps;
end );


#############################################################################
##
#M  CharTableQClass( <dim>, <system>, <qclass> ) . . . . . .  character table
#M  CharTableQClass( <dim>, <IT number> ) . . . . . . . . . . .  of a Q-class
#M  CharTableQClass( <Hermann-Mauguin symbol> ) . . . .  representative group
##
##  'CharTableQClass'  returns the  character table of a representative group
##  of the specified Q-class.
##
InstallGlobalFunction( CharTableQClass, function ( arg )

    local T, param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 3 );

    # Construct the character table of the class representative group.
    T := CR_CharTableQClass( param );

    return T;
end );


#############################################################################
##
#M  DisplayCrystalFamily( <dim>, <family> ) . . . . . . . . . .  display some
#M  . . . . . . . . . . . . . . . . . . . . . . . . crystal family invariants
##
##  'DisplayCrystalFamily'  displays  for the  specified  crystal family  the
##  following information:
##  - the family name,
##  - the number of parameters,
##  - the common rational decomposition pattern,
##  - the common real decomposition pattern,
##  - the number of crystal systems in the family, and
##  - the number of Bravais flocks in the family.
##
InstallGlobalFunction( DisplayCrystalFamily, function ( dim, fam )

    local bnum, code, CR, pnum, pt, qdecomp, rdecomp, snum, text;

    # Check the dimension parameter.
    if not IsInt( dim ) or dim < 2 or 4 < dim then
        Error( "dimension out of range (must be 2, 3, or 4)" );
    fi;
    CR := CrystGroupsCatalogue[dim];

    # Check the family parameter.
    if not IsInt( fam ) or fam < 1 or Length( CR.nameCrystalFamily ) < fam
        then Error( "family parameter out of range" );
    fi;

    code := CR.codedPropertiesFamily[fam];
    rdecomp := RemInt( code, 10 );
    code := QuoInt( code, 10 );
    qdecomp := RemInt( code, 10 );
    code := QuoInt( code, 10 );
    bnum := RemInt( code, 10 );
    pnum := QuoInt( code, 10 );
    snum := Number( CR.familyCrystalSystem, x -> x = fam );

    text := CR_TextStrings.family;

    # Print the family number.
    Print( text[12], CR_TextStrings.roman[fam] );

    # Print the name of the family.
    Print( text[13], CR.nameCrystalFamily[fam] );

    # Print the number of free parameters.
    Print( text[14], pnum, text[16] );
    if pnum > 1 then
        Print( text[15] );
    fi;
    Print( text[19] );

    # Print the rational decomposition pattern.
    if qdecomp = 1 then
        Print( text[10], text[1], text[14] );
    elif qdecomp > 1 then
        Print( text[10], text[2], text[qdecomp], text[14] );
    fi;

    # Print the real decomposition pattern.
    if rdecomp = 1 then
        Print( text[11], text[1] );
    elif rdecomp > 1 then
        Print( text[11], text[2], text[rdecomp] );
    fi;

    # Print the number of crystal systems in the given family.
    pt := 19;
    if qdecomp = 0 then pt := 14; fi;
    Print( text[pt], snum, text[17] );
    if snum > 1 then
        Print( text[15] );
    fi;

    # Print the number of Bravais flocks.
    Print( text[14], bnum, text[18] );
    if bnum > 1 then
        Print( text[15] );
    fi;

    Print( "\n" );

end );


#############################################################################
##
#M  DisplayCrystalSystem( <dim>, <system> ) . . . . . . . . . .  display some
#M  . . . . . . . . . . . . . . . . . . . . . . . . crystal system invariants
##
##  'DisplayCrystalSystem'  displays  for the  specified  crystal system  the
##  following information:
##  - the number of Q-classes in the crystal system, and
##  - the triple  (dim, sys, qcl)  of parameters of the Q-class  which is the
##    holohedry of the crystal system.
##
InstallGlobalFunction( DisplayCrystalSystem, function ( dim, sys )

    local CR, qnum, text;

    # Check the dimension parameter.
    if not IsInt( dim ) or dim < 2 or 4 < dim then
        Error( "dimension out of range (must be 2, 3, or 4)" );
    fi;
    CR := CrystGroupsCatalogue[dim];

    # Check the crystal system parameter.
    if not IsInt( sys ) or sys < 1 or Length( CR.nullQClass ) <= sys then
        Error( "system parameter out of range" );
    fi;

    qnum := CR.nullQClass[sys+1] - CR.nullQClass[sys];

    text := CR_TextStrings.crystalSystem;

    # Print the crystal system number.
    Print( text[1], sys );

    # Print the number of Q-classes in the given crystal system.
    if qnum = 1 then
        Print( text[6], qnum, text[2] );
    else
        Print( text[6], qnum, text[3] );
    fi;

    # Print the holohedry.
    Print( text[4], dim, text[5], sys, text[5], qnum, text[7] );
    Print( "\n" );

end );


#############################################################################
##
#M  DadeGroup( <dim>, <n> ) . . . . . . . . . . . . . . . . . . .  Dade group
##
##  'DadeGroup'  returns the n-th Dade group of dimension dim.
##
InstallGlobalFunction( DadeGroup, function ( dim, n )

    local CR, G, param;

    # Check the dimension parameter.
    if not IsInt( dim ) or dim < 2 or 4 < dim then
        Error( "dimension out of range (must be 2, 3, or 4)" );
    fi;
    CR := CrystGroupsCatalogue[dim];

    # Check the given Dade group number for being in range.
    if not IsInt( n ) or n < 1 or Length( CR.parametersDadeGroup ) < n then
        Error( "Dade group number out of range" );
    fi;

    param := CR.parametersDadeGroup[n];
    G := CR_MatGroupZClass( param );

    return G;
end );


#############################################################################
##
#M  DadeGroupNumbersZClass( <dim>, <system>, <qclass>, <zclass> )  . . . Dade
#M  DadeGroupNumbersZClass( <dim>, <IT number> ) . . . . . . . . . . .  group
#M  DadeGroupNumbersZClass( <Hermann-Mauguin symbol> ) . . . . . . .  numbers
##
##  'DadeGroupNumbersZClass'  returns  a list  of the  numbers of  those Dade
##  groups which contain groups from the given Z-class.
##
InstallGlobalFunction( DadeGroupNumbersZClass, function ( arg )

    local CR, dim, i, n1, n2, nums, param, z;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 4 );
    dim := param[1];
    CR := CrystGroupsCatalogue[dim];
    z := CR.nullZClass[ CR.nullQClass[param[2]] + param[3] ] + param[4];

    # Construct the list and return it.
    n1 := CR.nullDadeGroupsZClass[z] + 1;
    n2 := CR.nullDadeGroupsZClass[z+1];
    nums := List( [ n1 .. n2 ],
        i -> RemInt( CR.codedDadeGroupsZClass[i], 10 ) );

    return Set( nums );

end );


#############################################################################
##
#M  DisplayQClass( <dim>, <system>, <qclass> )  . . . . . . . . . . . display
#M  DisplayQClass( <dim>, <IT number> ) . . . . . . . . . . . .  some Q-class
#M  DisplayQClass( <Hermann-Mauguin symbol> ) . . . . . . . . . .  invariants
##
##  'DisplayQClass'   displays   for  the  specified  Q-class  the  following
##  information:
##  - the size of the groups in the Q-class,
##  - the isomorphism type of the groups in the Q-class,
##  - the Hurley pattern,
##  - the rational constituents,
##  - the number of Z-classes in the Q-class, and
##  - the number of space-group types in the Q-class.
##
InstallGlobalFunction( DisplayQClass, function ( arg )

    local param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 3 );

    # Display some invariants of the given Q-class.
    CR_DisplayQClass( param );

end );


#############################################################################
##
#M  DisplaySpaceGroupGenerators( <dim>, <system>,<qclass>,<zclass>,<sgtype> )
#M  DisplaySpaceGroupGenerators( <dim>, <IT number> ) . . display space group
#M  DisplaySpaceGroupGenerators( <Hermann-Mauguin symbol> ) . . .  generators
##
##  'DisplaySpaceGroupGenerators'  displays the non-translation generators of
##  the space group specified by the given parameters.
##
InstallGlobalFunction( DisplaySpaceGroupGenerators, function ( arg )

    local param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 5 );

    # Display the non-translation generators of the space group type
    # representative matrix group.
    CR_DisplaySpaceGroupGenerators( param );

end );


#############################################################################
##
#M  DisplaySpaceGroupType( <dim>, <system>, <qclass>, <zclass>, <sgtype> )  .
#M  DisplaySpaceGroupType( <dim>, <IT number> ) . . . . .  display some space
#M  DisplaySpaceGroupType( <Hermann-Mauguin symbol> ) . . .  group invariants
##
##  'DisplaySpaceGroupType'  displays for the  specified space-group type the
##  following information:
##  - the orbit size associated with the space-group type,
##  - the IT number (only in case dim = 2 or dim = 3), and
##  - the Hermann-Mauguin symbol (only in case dim = 2 or dim = 3).
##
InstallGlobalFunction( DisplaySpaceGroupType, function ( arg )

    local param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 5 );

    # Display some invariants of the given space-group type.
    CR_DisplaySpaceGroupType( param );

end );


#############################################################################
##
#M  DisplayZClass( <dim>, <system>, <qclass>, <zclass> ) . . . . . .  display
#M  DisplayZClass( <dim>, <IT number> )  . . . . . . . . . . . . some Z-class
#M  DisplayZClass( <Hermann-Mauguin symbol> ) . . . . .. . . . . . invariants
##
##  'DisplayZClass'   displays   for  the  specified  Z-class  the  following
##  information:
##  - the Hermann-Mauguin symbol  of a representative space-group type  which
##    belongs to the Z-class (only in case dim = 2 or dim = 3),
##  - the Bravais type,
##  - some decomposability information,
##  - the number of space-group types belonging to the Z-class, and
##  - the size of the associated cohomology group.
##
InstallGlobalFunction( DisplayZClass, function ( arg )

    local param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 4 );

    # Display some invariants of the given Z-class.
    CR_DisplayZClass( param );

end );


#############################################################################
##
#M  FpGroupQClass( <dim>, <system>, <qclass> ) . . . . . . . . . . .  Q-class
#M  FpGroupQClass( <dim>, <IT number> ) . . . . . . . . . . .  representative
#M  FpGroupQClass( <Hermann-Mauguin symbol> ) . . . . . . . . . as f.p. group
##
##  'FpGroupQClass'  returns a  f. p. group  isomorphic to the groups  in the
##  specified Q-class.
##
InstallGlobalFunction( FpGroupQClass, function ( arg )

    local F, param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 3 );

    # Construct the the corresponding f.p. group.
    F := CR_FpGroupQClass( param );

    return F;
end );


#############################################################################
##
#M  MatGroupZClass( <dim>, <system>, <qclass>, <zclass> ) . . . . . . Z-class
#M  MatGroupZClass( <dim>, <IT number> )  . . . . . . . . . .  representative
#M  MatGroupZClass( <Hermann-Mauguin symbol> )  . . . . . . . as matrix group
##
##  'MatGroupZClass' returns a representative group of the specified Z-class.
##  The generators  of the resulting matrix group  are chosen such  that they
##  satisfy   the    defining   relators    which   are   returned   by   the
##  'FpGroupQClass'  function  for the  representative  of the  corresponding
##  Q-class.
##
InstallGlobalFunction( MatGroupZClass, function ( arg )

    local G, param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 4 );

    # Construct the class representative matrix group.
    G := CR_MatGroupZClass( param );

    return G;
end );


#############################################################################
##
#M  NormalizerZClass( <dim>, <system>, <qclass>, <zclass> ) . . .  normalizer
#M  NormalizerZClass( <dim>, <IT number> ) . . . . . . . . . . . of a Z-class
#M  NormalizerZClass( <Hermann-Mauguin symbol> ) . . . . representative group
##
##  'NormalizerZClass'  returns the normalizer in GL(dim,Z)  of the specified
##  Z-class representative matrix group.  If the  order of the  normalizer is
##  finite,  then the  group record components  "crZClass" and "crConjugator"
##  will be set properly.
##
InstallGlobalFunction( NormalizerZClass, function ( arg )

    local N, param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 4 );

    # Construct the normalizer in GL(dim,Z) of the class representative
    # matrix group.
    N := CR_NormalizerZClass( param );

    return N;
end );


#############################################################################
##
#M  NrCrystalFamilies( <dim> ) . . . . . . . . . . number of crystal families
##
##  'NrCrystalFamilies'  returns the  number of crystal families of the given
##  dimension.
##
InstallGlobalFunction( NrCrystalFamilies, function ( dim )

    # Check the dimension parameter.
    if not IsInt( dim ) or dim < 2 or 4 < dim then
        Error( "dimension out of range (must be 2, 3, or 4)" );
    fi;

    return Length( CrystGroupsCatalogue[dim].nameCrystalFamily );
end );


#############################################################################
##
#M  NrCrystalSystems( <dim> ) . . . . . . . . . . . number of crystal systems
##
##  'NrCrystalSystems'  returns  the number  of crystal systems  of the given
##  dimension.
##
InstallGlobalFunction( NrCrystalSystems, function ( dim )

    # Check the dimension parameter.
    if not IsInt( dim ) or dim < 2 or 4 < dim then
        Error( "dimension out of range (must be 2, 3, or 4)" );
    fi;

    return Length( CrystGroupsCatalogue[dim].familyCrystalSystem );
end );


#############################################################################
##
#M  NrDadeGroups( <dim> ) . . . . . . . . . . . . . . . number of Dade groups
##
##  'NrDadeGroups'  returns the number of Dade groups of the given dimension.
##
InstallGlobalFunction( NrDadeGroups, function ( dim )

    # Check the dimension parameter.
    if not IsInt( dim ) or dim < 2 or 4 < dim then
        Error( "dimension out of range (must be 2, 3, or 4)" );
    fi;

    return Length( CrystGroupsCatalogue[dim].parametersDadeGroup );
end );


#############################################################################
##
#M  NrQClassesCrystalSystem( <dim>, <system> ) . . . . .  number of Q-classes
##
##  'NrQClassesCrystalSystem'  returns the  number of Q-classes  in the given
##  crystal system.
##
InstallGlobalFunction( NrQClassesCrystalSystem, function ( dim, sys )

    local CR;

    # Check the dimension parameter.
    if not IsInt( dim ) or dim < 2 or 4 < dim then
        Error( "dimension out of range (must be 2, 3, or 4)" );
    fi;
    CR := CrystGroupsCatalogue[dim];

    # Check the crystal system parameter.
    if not IsInt( sys ) or sys < 1 or Length( CR.nullQClass ) <= sys then
        Error( "system parameter out of range" );
    fi;

    return CR.nullQClass[sys+1] - CR.nullQClass[sys];
end );


#############################################################################
##
#M  NrSpaceGroupTypesZClass( <dim>, <system>, <qclass>, <zclass> ) . . number
#M  NrSpaceGroupTypesZClass( <dim>, <IT number> ) . . . . . .  of space-group
#M  NrSpaceGroupTypesZClass( <Hermann-Mauguin symbol> ) . .  types in Z-class
##
##  'NrSpaceGroupTypesZClass'  returns the number of space-group types in the
##  given Z-class.
##
InstallGlobalFunction( NrSpaceGroupTypesZClass, function ( arg )

    local CR, param, z;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 4 );
    CR := CrystGroupsCatalogue[param[1]];
    z := CR.nullZClass[ CR.nullQClass[param[2]] + param[3] ] + param[4];

    return CR.nullSpaceGroup[z+1] - CR.nullSpaceGroup[z];
end );


#############################################################################
##
#M  NrZClassesQClass( <dim>, <system>, <qclass> )  . . . . . . . .  number of
#M  NrZClassesQClass( <dim>, <IT number> ) . . . . . . . . . . . .  Z-classes
#M  NrZClassesQClass( <Hermann-Mauguin symbol> ) . . . . . . . . . in Q-class
##
##  'NrZClassesQClass'  returns the number of Z-classes in the given Q-class.
##
InstallGlobalFunction( NrZClassesQClass, function ( arg )

    local CR, param, q;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 3 );
    CR := CrystGroupsCatalogue[param[1]];
    q := CR.nullQClass[param[2]] + param[3];

    return CR.nullZClass[q+1] - CR.nullZClass[q];
end );


#############################################################################
##
#M  PcGroupQClass( <dim>, <system>, <qclass> )  . . . . . . . . . . . Q-class
#M  PcGroupQClass( <dim>, <IT number> ) . . . . . . . . . . .  representative
#M  PcGroupQClass( <Hermann-Mauguin symbol> ) . . . . . . . . . . as ag group
##
##  'PcGroupQClass'  returns  an ag group  isomorphic  to the  groups  in the
##  specified Q-class.
##
InstallGlobalFunction( PcGroupQClass, function ( arg )

    local A, param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 3 );

    # Construct the corresponding ag group (if solvable).
    A := CR_PcGroupQClass( param, true );

    return A;
end );


#############################################################################
##
#M  SpaceGroupOnLeftBBNWZ( <dim>, <system>, <qclass>, <zclass>, <sgtype> ) 
#M  SpaceGroupOnLeftBBNWZ( <dim>, <IT number> ) . . . . . . . . . . . . . . .
#M  SpaceGroupOnLeftBBNWZ( <Hermann-Mauguin symbol> ) . . . . . . space group
##
##  'SpaceGroupOnLeftBBNWZ' returns a  representative matrix group 
##  (of dimension dim+1) of the specified space-group type.
##
InstallGlobalFunction( SpaceGroupOnLeftBBNWZ, function ( arg )

    local G, param;

    # Evaluate the given arguments.
    param := CR_Parameters( arg, 5 );

    # Construct the space group.
    G := CR_SpaceGroup( param );
    SetIsAffineCrystGroupOnLeft( G, true );
    AddTranslationBasis( G, IdentityMat( param[1] ) );
    SetIsSpaceGroup( G, true );
    SetIsSymmorphicSpaceGroup( G, param[5]=1 );
    return G;
end );


#############################################################################
##
#M  SpaceGroupOnRightBBNWZ( <dim>, <system>, <qclass>, <zclass>, <sgtype> ) .
#M  SpaceGroupOnRightBBNWZ( <dim>, <IT number> )  . . . . . . . . . . . . . .
#M  SpaceGroupOnRightBBNWZ( <Hermann-Mauguin symbol> )  . . . . . . . . . . .
#M  SpaceGroupOnRightBBNWZ( S ) . . . . . . . . . . . .transposed space group
##
##  'SpaceGroupOnRightBBNWZ'  returns the transposed matrix group of
##  the given or specified space group.
##
##  The reason is the following. Each space group is presented in the form of
##  a group of augmented matrices (of dimension dim+1) of the following form:
##
##          [  M  | t ]
##          [-----+---]          Here, M is the `linear part' and
##          [  0  | 1 ]          t is the `translational part'.
##
##  Therefore,  the natural action of a space group in this form  is from the
##  left.  This collides with the convention in GAP  to have all actions from
##  the right. This function does the necessary conversions. In fact, it does
##  not only transpose the matrices, but it also adapts the relators given in
##  S.fpGroup to the new generators.
##
InstallGlobalFunction( SpaceGroupOnRightBBNWZ, function( arg )

    local cr, F, G, narg, param, rel, rels, S, T;

    # Evaluate the arguments.
    narg := Length( arg );
    if narg = 1 and IsGroup( arg[1] ) and HasCrystCatRecord( arg[1] )
    and Length( CrystCatRecord( arg[1] ).parameters ) = 5
    then
        # The argument is the space group S to be transposed.
        # Get a copy G of the finitely presented group involved in S.
        S := arg[1];
        cr := CrystCatRecord( S );
        param := cr.parameters;
    else
        # Construct the space group S to be transposed from the arguments
        # and get the finitely presented group G involved in S.
        param := CR_Parameters( arg, 5 );
        S := CR_SpaceGroup( param );
        cr := CrystCatRecord( S );
    fi;

    # Get the f.p. group G associated to S.
    G := cr.fpGroup;
    F := FreeGroupOfFpGroup( G );

    # construct the group T generated by the transposed generators of S.
    T := Group( List( GeneratorsOfGroup( S ), TransposedMat ), One ( S ) );
    cr := rec( );
    cr.parameters := param;
    SetCrystCatRecord( T, cr );

    SetName( T, CR_Name( "SpaceGroupOnRightBBNWZ", param, 5 ) );
    SetSize( T, Size( S ) );

    # Reverse each relator in the presentation of G and construct the f.p.
    # group defined by these reversed relators.
    rels := List( RelatorsOfFpGroup( G ), rel -> Reversed( rel ) );
    cr.fpGroup := F / rels;

    # Return the transposed group.
    SetIsAffineCrystGroupOnRight( T, true );
    AddTranslationBasis( T, IdentityMat( param[1] ) );
    SetIsSpaceGroup( T, true );
    SetIsSymmorphicSpaceGroup( T, param[5]=1 );
    return T;
end );


#############################################################################
##
#M  SpaceGroupBBNWZ( <dim>, <system>, <qclass>, <zclass>, <sgtype> ) .
#M  SpaceGroupBBNWZ( <dim>, <IT number> )  . . . . . . . . . . . . . .
#M  SpaceGroupBBNWZ( <Hermann-Mauguin symbol> )  . . . . . . . . . . .
##
##  Calls either `SpaceGroupOnRightBBNWZ' or `SpaceGroupOnLeftBBNWZ'
##  depending on the value of `CrystGroupDefaultAction'
##
InstallGlobalFunction( SpaceGroupBBNWZ, function( arg )
   local p;
   p := CR_Parameters( arg, 5 );
   if CrystGroupDefaultAction = RightAction then
         return SpaceGroupOnRightBBNWZ( p[1], p[2], p[3], p[4], p[5] );
    else
         return SpaceGroupOnLeftBBNWZ( p[1], p[2], p[3], p[4], p[5] );
    fi;
end );


#############################################################################
##
#M  ZClassRepsDadeGroup( <dim>, <system>, <qclass>, <zclass>, <n> ) . . . . .
#M  ZClassRepsDadeGroup( <dim>, <IT number>, <n> ) . . . . . . . Z-class reps
#M  ZClassRepsDadeGroup( <Hermann-Mauguin symbol>, <n> ) . . .  in Dade group
##
##  'ZClassRepsDadeGroup'  returns  a   list  of  representatives   of  those
##  conjugacy classes  of subgroups of the given Dade group  which consist of
##  groups belonging to the given Z-class.
##
InstallGlobalFunction( ZClassRepsDadeGroup, function ( arg )

    local CR, d, dim, nargs, param, reps;

    # Check the number of arguments;
    nargs := Length( arg );
    if nargs < 2 then
        Error( "illegal number of arguments" );
    fi;

    # Evaluate the given Z-class arguments.
    param := CR_Parameters( arg{ [ 1 .. nargs - 1 ] }, 4 );

    # Check the Dade group argument;
    d := arg[nargs];
    dim := param[1];
    CR := CrystGroupsCatalogue[dim];
    if not IsInt( d ) or d < 1 or Length( CR.parametersDadeGroup ) < d then
        Error( "Dade group parameter out of range" );
    fi;

    # Construct the list of representative Z-class groups.
    reps := CR_ZClassRepsDadeGroup( param, d );

    return reps;
end );


#############################################################################
##
#M  FpGroupSpaceGroupBBNWZ( <S> ) . . FpGroup isomorphic to BBNWZ space group
##
InstallGlobalFunction( FpGroupSpaceGroupBBNWZ, function( S )
    local F;
    F := CrystCatRecord(S).fpGroup;
    SetName( F, Concatenation( "FpGroup", Name(S) ) );
    return F;
end );


CR_InitializeRelators( CrystGroupsCatalogue );

