#############################################################################
##
#W  types.g              GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: types.g,v 1.56 2009/08/19 14:53:40 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains implementations of the actual data types used in the
##  &ATLAS; of Group Representations.
##
Revision.( "atlasrep/gap/types_g" ) :=
    "@(#)$Id: types.g,v 1.56 2009/08/19 14:53:40 gap Exp $";


#############################################################################
##
#V  AtlasOfGroupRepresentationsInfo
##
BindGlobal( "AtlasOfGroupRepresentationsInfo", rec(

    # user parameters
    remote := true,

    servers := [
                 [ "brauer.maths.qmul.ac.uk", "Atlas/" ],
               ],

    wget := "prefer IO to wget",

    compress := false,

    displayFunction := Print,

    accessFunctions := AtlasOfGroupRepresentationsAccessFunctionsDefault,

    markprivate := "*",

    # system parameters (filled automatically)
    GAPnames := [],

    groupnames := [],

    ringinfo := [],

    permrepinfo := rec(),

    private := [],

    TableOfContents := rec( remote := rec(),
                            types := rec( rep   := [],
                                          prg   := [],
                                          cache := [] ) ),

    TOC_Cache := rec(),
    ) );


#############################################################################
##
#D  Permutation representations
##
##  <#GAPDoc Label="type:perm:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-p<A>n</A><A>id</A>B<A>m</A>.m<A>nr</A></C></Mark>
##  <Item>
##    a file in &MeatAxe; text file format
##    containing the <A>nr</A>-th generator of a permutation representation
##    on <A>n</A> points.
##    An example is <C>M11G1-p11B0.m1</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "rep", "perm", rec(

    # `<groupname>G<i>-p<n><id>B<m>.m<nr>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "p", IsDigitChar, IsLowerAlphaOrDigitChar,
                            "B", IsDigitChar, ".m", IsDigitChar ] ],
                        [ ParseBackwards, ParseForwards ] ],

    AddDescribingComponents := function( record, type )
      local repid, parsed, comp;

      repid:= record.identifier[2][1];
      parsed:= AGRParseFilenameFormat( repid, type[2].FilenameFormat );
      record.p:= Int( parsed[5] );
      record.id:= parsed[6];
      repid:= repid{ [ 1 .. Position( repid, '.' ) - 1 ] };
      if IsBound( AtlasOfGroupRepresentationsInfo.permrepinfo.( repid ) ) then
        repid:= AtlasOfGroupRepresentationsInfo.permrepinfo.( repid );
        for comp in [ "isPrimitive", "rankAction", "stabilizer",
                      "transitivity", "maxnr" ] do
          if IsBound( repid.( comp ) ) and repid.( comp ) <> "???" then
            record.( comp ):= repid.( comp );
          fi;
        od;
      fi;
    end,

    # `[ <i>, <n>, <id>, <m>, <filenames> ]'
    AddFileInfo := function( list, entry, name )
      local known;
      if 0 < entry[5] then
        known:= First( list, x -> x{ [ 1 .. 4 ] } = entry{ [3, 5, 6, 8 ] } );
        if known = fail then
          known:= entry{ [ 3, 5, 6, 8 ] };
          Add( known, [] );
          Add( list, known );
        fi;
        known[5][ entry[10] ]:= name;
        return true;
      fi;
      return false;
    end,

    DisplayOverviewInfo := [ "#", "r", function( tocs, groupname )
      # Put *all* types of representations together, in particular
      # assume that the functions for the other types are trivial!
      local types, info, no, private, j, toc, record, new, type;

      types:= AGRDataTypes( "rep" );
      if IsString( groupname[1] ) and 1 < Length( groupname ) then
        # Evaluate the conditions.
        info:= AtlasGeneratingSetInfo( tocs, groupname, types );
        no:= Length( info );
        private:= ForAny( info, x -> x.private );
      else
        # Just count the available entries.
        if IsString( groupname[1] ) then
          groupname:= groupname[1];
        fi;
        no:= 0;
        private:= false;
        for j in [ 1 .. Length( tocs ) ] do
          toc:= tocs[j];
          if IsBound( toc.( groupname ) ) then
            record:= toc.( groupname );
            new:= 0;
            for type in types do
              if IsBound( record.( type[1] ) ) then
                new:= new + Length( record.( type[1] ) );
              fi;
            od;
            if IsBound( toc.diridPrivate ) and 0 < new then
              private:= true;
            fi;
            no:= no + new;
          fi;
        od;
      fi;
      if no = 0 then
        no:= "";
      fi;
      return [ String( no ), private ];
    end ],

    AccessGroupCondition := function( info, cond )
      return  AGRCheckOneCondition( IsPermGroup, x -> x = true, cond )
          and AGRCheckOneCondition( IsPermGroup, cond )
          and AGRCheckOneCondition( IsMatrixGroup, x -> x = false, cond )
          and AGRCheckOneCondition( NrMovedPoints,
                  x -> ( IsFunction( x ) and x( info.p ) = true )
                       or info.p = x, cond )
          and AGRCheckOneCondition( IsTransitive,
                  x -> IsBound( info.transitivity ) and
                       ( IsFunction( x ) and x( info.transitivity > 0 ) = true )
                       or ( info.transitivity > 0 ) = x, cond )
          and AGRCheckOneCondition( Transitivity,
                  x -> IsBound( info.transitivity ) and
                       ( IsFunction( x ) and x( info.transitivity ) = true )
                       or info.transitivity = x, cond )
          and AGRCheckOneCondition( IsPrimitive,
                  x -> IsBound( info.isPrimitive ) and
                       ( IsFunction( x ) and x( info.isPrimitive ) = true )
                       or info.isPrimitive = x, cond )
          and AGRCheckOneCondition( RankAction,
                  x -> IsBound( info.rankAction ) and
                       ( IsFunction( x ) and x( info.rankAction ) = true )
                       or info.rankAction = x, cond )
          and AGRCheckOneCondition( Identifier,
                  x -> ( IsFunction( x ) and x( info.id ) = true )
                       or info.id = x, cond )
          and IsEmpty( cond );
    end,

    DisplayGroup := function( entry )
      local disp, repname, info, sep;

      disp:= Concatenation( "G <= Sym(",String(entry[2]),entry[3],")" );
      repname:= entry[5][1];
      repname:= repname{ [ 1 .. Position( repname, '.' )-1 ] };
      if IsBound( AtlasOfGroupRepresentationsInfo.permrepinfo.( repname ) ) then
        info:= AtlasOfGroupRepresentationsInfo.permrepinfo.( repname );
        disp:= [ disp ];
        if info.transitivity = 0 then
          # For intransitive repres., show the orbit lengths.
          Add( disp, Concatenation( "orbit lengths ",
            JoinStringsWithSeparator( List( info.orbits, String ), ", " ) ) );
          sep:= ", ";
        elif info.transitivity = 1 then
          # For transitivity 1, show the rank (if known).
          if IsBound( info.rankAction ) and info.rankAction <> "???" then
            Add( disp, Concatenation( "rank ", String( info.rankAction ) ) );
            sep:= ", ";
          fi;
        elif IsInt( info.transitivity ) then
          # For transitivity at least 2, show the transitivity.
          Add( disp, Concatenation( String( info.transitivity ), "-trans." ) );
          sep:= ", ";
        else
          # The transitivity is not known.
          Add( disp, "" );
          sep:= "";
        fi;
        if 0 < info.transitivity then
          # For transitive representations, more info may be available.
          if info.isPrimitive then
            if info.stabilizer <> "???" then
              Add( disp, Concatenation( sep, "on cosets of " ) );
              Add( disp, info.stabilizer );
              if info.maxnr <> "???" then
                Add( disp, Concatenation( " (",
                                          Ordinal( info.maxnr ), " max.)" ) );
              else
                Add( disp, "" );
              fi;
            elif info.maxnr <> "???" then
              Add( disp, Concatenation( sep, "on cosets of ",
                                        Ordinal( info.maxnr ), " max." ) );
            else
              Add( disp, "primitive" );
            fi;
          elif info.stabilizer <> "???" then
            Add( disp, Concatenation( sep, "on cosets of " ) );
            Add( disp, info.stabilizer );
          fi;
        fi;
      fi;
      return disp;
    end,

    TestFileHeaders := function( tocid, groupname, entry, type )
      local name, filename, len, file, line;

      if tocid = "local" then
        tocid:= "datagens";
      fi;

      # Each generator is stored in a file of its own.
      for name in entry[ Length( entry ) ] do

        # Fetch the file if necessary.
        filename:= AtlasOfGroupRepresentationsLocalFilenameTransfer( tocid,
                       groupname, name, type );
        if filename = fail then
          return Concatenation( "filename `", name, "' not found" );
        fi;
        filename:= filename[1];
        len:= Length( filename );
        if 3 < len and filename{ [ len-2 .. len ] } = ".gz" then
          filename:= filename{ [ 1 .. len-3 ] };
        fi;

        # Read the first line of the file.
        file:= InputTextFile( filename );
        if file = fail then
          return Concatenation( "cannot create input stream for file `",
                     filename,"'" );
        fi;
        InfoRead1( "#I  reading `",filename,"' started\n" );
        line:= ReadLine( file );
        if line = fail then
          CloseStream( file );
          return Concatenation( "no first line in file `",filename,"'" );
        fi;
while not '\n' in line do
  Append( line, ReadLine( file ) );
od;
        CloseStream( file );
        InfoRead1( "#I  reading `",filename,"' done\n" );

        # The header must consist of four nonnegative integers.
        line:= CMeatAxeFileHeaderInfo( line );
        if line = fail then
          return Concatenation( "illegal header of file `", filename,"'" );
        fi;

        # Start the specific tests for permutations.
        # Check mode, number of permutations, and degree.
        if   line[1] <> 12 then
          return Concatenation( "mode of file `", name,
                     "' differs from 12" );
        elif line[4] <> 1 then
          return Concatenation(
                "more than one permutation in file `", name, "'" );
        elif line[3] <> entry[2] then
          return Concatenation( "perm. degree in file `",
                     name, "' is ", String( line[3] ) );
        fi;

      od;
      return true;
    end,

    TestFiles := AGRTestFilesMTX,

    # Permutation representations are sorted according to
    # degree and identification string.
    SortTOCEntries := entry -> entry{ [ 2, 3 ] },

    PostprocessFileInfo := function( toc, record )
      local list, i;
      list:= record.perm;
      for i in [ 1 .. Length( list ) ] do
        if not IsDenseList( list[i][5] ) then
#T better check whether the number of generators equals the number of
#T standard generators!
          Info( InfoAtlasRep, 1, "not all generators for ", list[i][5] );
          Unbind( list[i] );
        fi;
      od;
      if not IsDenseList( list ) then
        record.perm:= Compacted( list );
      fi;
    end,

    # We store the stem of the filename and the number of generators.
    TOCEntryString := function( typename, entry )
      return Concatenation( [
          "AGRTOC(\"", typename, "\",\"",
          entry[5][1]{ [ 1 .. Length( entry[5][1] ) - 1 ] },
          "\",",
          String( Length( entry[5] ) ),
          ");\n" ] );
    end,

    # The default access reads the text format files.
    # Note that `ScanMeatAxeMat' returns a list of permutations.
    ReadAndInterpretDefault := paths -> Concatenation( List( paths,
                                            ScanMeatAxeFile ) ),
    ) );


#############################################################################
##
#D  Matrix representations over finite fields
##
##  <#GAPDoc Label="type:matff:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-f<A>q</A>r<A>dim</A><A>id</A>B<A>m</A>.m<A>nr</A></C></Mark>
##  <Item>
##    a file in &MeatAxe; text file format
##    containing the <A>nr</A>-th generator of a matrix representation
##    over the field with <A>q</A> elements, of dimension <A>dim</A>.
##    An example is <C>S5G1-f2r4aB0.m1</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "rep", "matff",   rec(

    # `<groupname>G<i>-f<q>r<dim><id>B<m>.m<nr>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "f", IsDigitChar, "r", IsDigitChar,
                            IsLowerAlphaOrDigitChar,
                            "B", IsDigitChar, ".m", IsDigitChar ] ],
                        [ ParseBackwards, ParseForwards ] ],

    AddDescribingComponents := function( record, type )
      local parsed;

      parsed:= AGRParseFilenameFormat( record.identifier[2][1], 
                                       type[2].FilenameFormat );
      record.dim:= Int( parsed[7] );
      record.id:= parsed[8];
      record.ring:= GF( parsed[5] );
    end,

    # `[ <i>, <q>, <dim>, <id>, <m>, <filenames> ]'
    AddFileInfo := function( list, entry, name )
      local known;
      if IsPrimePowerInt( entry[5] ) and 0 < entry[7] then
        known:= First( list, x -> x{ [ 1 .. 5 ] }
                                  = entry{ [ 3, 5, 7, 8, 10 ] } );
        if known = fail then
          known:= entry{ [ 3, 5, 7, 8, 10 ] };
          Add( known, [] );
          Add( list, known );
        fi;
        known[6][ entry[12] ]:= name;
        return true;
      fi;
      return false;
    end,

    AccessGroupCondition := function( info, cond )
      return  AGRCheckOneCondition( IsMatrixGroup, x -> x = true, cond )
          and AGRCheckOneCondition( IsMatrixGroup, cond )
          and AGRCheckOneCondition( IsPermGroup, x -> x = false, cond )
          and AGRCheckOneCondition( Characteristic,
                  function( p )
                    local char;
                    char:= SmallestRootInt( Size( info.ring ) );
                    return char = p or IsFunction( p ) and p( char ) = true;
                  end,
                  cond )
          and AGRCheckOneCondition( Dimension,
                  x -> ( IsFunction( x ) and x( info.dim ) )
                       or info.dim = x, cond )
          and AGRCheckOneCondition( Ring,
                  R -> ( IsFunction( R ) and R( info.ring ) ) or
                       ( IsField( R ) and IsFinite( R )
                         and Size( info.ring ) mod Characteristic( R ) = 0
                         and DegreeOverPrimeField( R )
                            mod LogInt( Size( info.ring ),
                                        Characteristic( R ) ) = 0 ),
                         cond )
          and AGRCheckOneCondition( Identifier,
                  x -> ( IsFunction( x ) and x( info.id ) = true )
                       or info.id = x, cond )
          and IsEmpty( cond );
    end,

    DisplayGroup := x -> Concatenation( "G <= GL(",String(x[3]),x[4],",",
                                        String(x[2]),")" ),

    TestFileHeaders := function( tocid, groupname, entry, type )
      local name, filename, len, file, line, errors;

      if tocid = "local" then
        tocid:= "datagens";
      fi;

      # Each generator is stored in a file of its own.
      for name in entry[ Length( entry ) ] do

        # Fetch the file if necessary.
        filename:= AtlasOfGroupRepresentationsLocalFilenameTransfer( tocid,
                       groupname, name, type );
        if filename = fail then
          return Concatenation( "filename `", name, "' not found" );
        fi;
        filename:= filename[1];
        len:= Length( filename );
        if 3 < len and filename{ [ len-2 .. len ] } = ".gz" then
          filename:= filename{ [ 1 .. len-3 ] };
        fi;

        # Read the first line of the file.
        file:= InputTextFile( filename );
        if file = fail then
          return Concatenation( "cannot create input stream for file `",
                     filename,"'" );
        fi;
        InfoRead1( "#I  reading `",filename,"' started\n" );
        line:= ReadLine( file );
        if line = fail then
          CloseStream( file );
          return Concatenation( "no first line in file `",filename,"'" );
        fi;
while not '\n' in line do
  Append( line, ReadLine( file ) );
od;
        CloseStream( file );
        InfoRead1( "#I  reading `",filename,"' done\n" );

        # The header must consist of four nonnegative integers.
        line:= CMeatAxeFileHeaderInfo( line );
        if line = fail then
          return Concatenation( "illegal header of file `", filename,"'" );
        fi;

        # Start the specific tests for matrices over finite fields.
        # Check mode, field size, and dimension.
        errors:= "";
        if   6 < line[1] then
          Append( errors, Concatenation( "mode of file `", name,
                            "' is larger than 6" ) );
        elif line[2] <> entry[2] then
          Append( errors, Concatenation( "file `", name,
                            "': field is of size ", String( line[2] ) ) );
        elif line[3] <> entry[3] then
          Append( errors, Concatenation( "file `", name,
                            "': matrix dimension is ", String( line[3] ) ) );
        elif line[3] <> line[4] then
          Append( errors, Concatenation( "file `", name,
                            "': matrix is not square" ) );
        fi;
        if not IsEmpty( errors ) then
          return errors;
        fi;

      od;
      return true;
    end,

    TestFiles := AGRTestFilesMTX,

    # Matrix representations over finite fields are sorted according to
    # field size, dimension, and identification string.
    SortTOCEntries := entry -> entry{ [ 2 .. 4 ] },

    PostprocessFileInfo := function( toc, record )
      local list, i;
      list:= record.matff;
      for i in [ 1 .. Length( list ) ] do
        if not IsDenseList( list[i][6] ) then
#T better check whether the number of generators equals the number of
#T standard generators!
          Info( InfoAtlasRep, 1, "not all generators for ", list[i][6] );
          Unbind( list[i] );
        fi;
      od;
      if not IsDenseList( list ) then
        record.matff:= Compacted( list );
      fi;
    end,

    # We store the stem of the filename and the number of generators.
    TOCEntryString := function( typename, entry )
      return Concatenation( [
          "AGRTOC(\"", typename, "\",\"",
          entry[6][1]{ [ 1 .. Length( entry[6][1] ) - 1 ] },
          "\",",
          String( Length( entry[6] ) ),
          ");\n" ] );
    end,

    # The default access reads the text format files.
    ReadAndInterpretDefault := paths -> List( paths, ScanMeatAxeFile ),
    ) );


#############################################################################
##
#D  Matrix representations over the integers
##
##  <#GAPDoc Label="type:matint:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-Zr<A>dim</A><A>id</A>B<A>m</A>.g</C></Mark>
##  <Item>
##    a &GAP; readable file
##    containing all generators of a matrix representation
##    over the integers, of dimension <A>dim</A>.
##    An example is <C>A5G1-Zr4B0.g</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "rep", "matint",  rec(

    # `<groupname>G<i>-Zr<dim><id>B<m>.g'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                        [ "Zr", IsDigitChar, IsLowerAlphaOrDigitChar,
                          "B", IsDigitChar, ".g" ] ],
                        [ ParseBackwards, ParseForwards ] ],

    AddDescribingComponents := function( record, type )
      local parsed;

      parsed:= AGRParseFilenameFormat( record.identifier[2],
                                       type[2].FilenameFormat );
      record.dim:= Int( parsed[5] );
      record.id:= parsed[6];
      record.ring:= Integers;
    end,

    # `[ <i>, <dim>, <id>, <m>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      if 0 < entry[5] then
        Add( list, Concatenation( entry{ [ 3, 5, 6, 8 ] }, [ name ] ) );
        return true;
      fi;
      return false;
    end,

    AccessGroupCondition := function( info, cond )
      return  AGRCheckOneCondition( IsMatrixGroup, x -> x = true, cond )
          and AGRCheckOneCondition( IsMatrixGroup, cond )
          and AGRCheckOneCondition( IsPermGroup, x -> x = false, cond )
          and AGRCheckOneCondition( Characteristic,
                  p -> p = 0 or ( IsFunction( p ) and p( 0 ) = true ),
                  cond )
          and AGRCheckOneCondition( Dimension,
                  x -> ( IsFunction( x ) and x( info.dim ) )
                       or info.dim = x, cond ) 
          and AGRCheckOneCondition( Ring,
                  R -> ( IsFunction( R ) and R( Integers ) ) or
                       ( IsRing( R ) and IsCyclotomicCollection( R ) ), cond )
          and AGRCheckOneCondition( Identifier,
                  x -> ( IsFunction( x ) and x( info.id ) = true )
                       or info.id = x, cond )
          and IsEmpty( cond );
    end,

    TestFileHeaders := function( tocid, groupname, entry, type )
      return AGRTestFileHeadersDefault( tocid, groupname, entry, type,
               entry[2],
               function( entry, mats, filename )
                 if not ForAll( mats, mat -> ForAll( mat,
                                 row -> ForAll( row, IsInt ) ) ) then
                   return Concatenation( "matrices in `",filename,
                              "' are not over the integers" );
                 fi;
                 return true;
               end );
    end,

    DisplayGroup := x -> Concatenation( "G <= GL(",String(x[2]),x[3],",Z)" ),

    # Matrix representations over the integers are sorted according to
    # dimension and identification string.
    SortTOCEntries := entry -> entry{ [ 2, 3 ] },

    ReadAndInterpretDefault := path -> AtlasDataGAPFormatFile(
                                           path ).generators,
    ) );


#############################################################################
##
#D  Matrix representations over algebraic number fields
##
##  <#GAPDoc Label="type:matalg:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-Ar<A>dim</A><A>id</A>B<A>m</A>.g</C></Mark>
##  <Item>
##    a &GAP; readable file
##    containing all generators of a matrix representation of dimension
##    <A>dim</A> over an algebraic number field not specified further.
##    An example is <C>A5G1-Ar3aB0.g</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "rep", "matalg",  rec(

    # `<groupname>G<i>-Ar<dim><id>B<m>.g'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                        [ "Ar", IsDigitChar, IsLowerAlphaOrDigitChar,
                          "B", IsDigitChar, ".g" ] ],
                        [ ParseBackwards, ParseForwards ] ],

    AddDescribingComponents := function( record, type )
      local parsed, info;

      parsed:= AGRParseFilenameFormat( record.identifier[2],
                                       type[2].FilenameFormat );
      record.dim:= Int( parsed[5] );
      record.id:= parsed[6];
      info:= record.identifier[2];
      info:= info{ [ 1 .. Position( info, '.' )-1 ] };
      info:= First( AtlasOfGroupRepresentationsInfo.ringinfo,
                    x -> x[1] = info );
      if info <> fail then
        record.ring:= info[3];
      fi;
    end,

    # `[ <i>, <dim>, <id>, <m>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      if 0 < entry[5] then
        Add( list, Concatenation( entry{ [ 3, 5, 6, 8 ] }, [ name ] ) );
        return true;
      fi;
      return false;
    end,

    AccessGroupCondition := function( info, cond )
      return  AGRCheckOneCondition( IsMatrixGroup, x -> x = true, cond )
          and AGRCheckOneCondition( IsMatrixGroup, cond )
          and AGRCheckOneCondition( IsPermGroup, x -> x = false, cond )
          and AGRCheckOneCondition( Characteristic,
                  p -> p = 0 or ( IsFunction( p ) and p( 0 ) = true ),
                  cond )
          and AGRCheckOneCondition( Dimension,
                  x -> ( IsFunction( x ) and x( info.dim ) = true )
                       or info.dim = x, cond )
          and AGRCheckOneCondition( Ring,
                  x -> IsIdenticalObj( x, Cyclotomics )
                       or ( IsBound( info.ring ) and
                            ( ( IsFunction( x ) and x( info.ring ) = true )
                             or ( IsRing( x ) and IsCyclotomicCollection( x )
                                  and IsSubset( x, info.ring ) ) ) ), cond )
          and AGRCheckOneCondition( Identifier,
                  x -> ( IsFunction( x ) and x( info.id ) = true )
                       or info.id = x, cond )
          and IsEmpty( cond );
    end,

    TestFileHeaders := function( tocid, groupname, entry, type )
      return AGRTestFileHeadersDefault( tocid, groupname, entry, type,
               entry[2],
               function( entry, mats, filename )
                 local info;

                 if not IsCyclotomicCollCollColl( mats ) then
                   return Concatenation( "matrices in `",filename,
                              "' are not over cyclotomics" );
                 elif ForAll( Flat( mats ), IsInt ) then
                   return Concatenation( "matrices in `",filename,
                              "' are over the integers" );
                 fi;
                 filename:= filename{ [ 1 .. Position( filename, '.' )-1 ] };
                 info:= First( AtlasOfGroupRepresentationsInfo.ringinfo,
                               triple -> triple[1] = filename );
                 if info = fail then
                   return Concatenation( "field info for `",filename,
                              "' missing" );
                 elif Field( Rationals, Flat( mats ) ) <> info[3] then
                   return Concatenation( "field info for `",filename,
                              "' should be ",
                              String( Field( Rationals, Flat( mats ) ) ) );
                 fi;
                 return true;
               end );
    end,

    DisplayGroup := function( x )
      local fieldstring;
      fieldstring:= x[5]{ [ 1 .. Length( x[5] )-2 ] };
      fieldstring:= First( AtlasOfGroupRepresentationsInfo.ringinfo,
                           p -> p[1] = fieldstring );
      if fieldstring = fail then
        fieldstring:= "C";
      else
        fieldstring:= fieldstring[2];
      fi;
      return Concatenation( "G <= GL(",String(x[2]),x[3],",",fieldstring,
                            ")" );
    end,

    # Matrix representations over algebraic extension fields are sorted
    # according to dimension and identification string.
    SortTOCEntries := entry -> entry{ [ 2, 3 ] },

    ReadAndInterpretDefault := path -> AtlasDataGAPFormatFile(
                                           path ).generators,
    ) );


#############################################################################
##
#D  Matrix representations over residue class rings
##
##  <#GAPDoc Label="type:matmodn:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-Z<A>n</A>r<A>dim</A><A>id</A>B<A>m</A>.g</C></Mark>
##  <Item>
##    a &GAP; readable file
##    containing all generators of a matrix representation of dimension
##    <A>dim</A> over the ring of integers mod <A>n</A>.
##    An example is <C>2A8G1-Z4r4aB0.g</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "rep", "matmodn", rec(

    # `<groupname>G<i>-Z<n>r<dim><id>B<m>.g'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "Z", IsDigitChar, "r", IsDigitChar,
                            IsLowerAlphaOrDigitChar,
                            "B", IsDigitChar, ".g" ] ],
                        [ ParseBackwards, ParseForwards ] ],

    AddDescribingComponents := function( record, type )
      local parsed;

      parsed:= AGRParseFilenameFormat( record.identifier[2],
                                       type[2].FilenameFormat );
      record.dim:= Int( parsed[7] );
      record.id:= parsed[8];
      record.ring:= ZmodnZ( parsed[5] );
    end,

    # `[ <i>, <n>, <dim>, <id>, <m>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      if 0 < entry[5] and 0 < entry[7] then
        Add( list, Concatenation( entry{ [ 3, 5, 7, 8, 10 ] }, [ name ] ) );
        return true;
      fi;
      return false;
    end,

    AccessGroupCondition := function( info, cond )
      return  AGRCheckOneCondition( IsMatrixGroup, x -> x = true, cond )
          and AGRCheckOneCondition( IsMatrixGroup, cond )
          and AGRCheckOneCondition( IsPermGroup, x -> x = false, cond )
          and AGRCheckOneCondition( Characteristic,
                  p -> p = fail or ( IsFunction( p ) and p( fail ) = true ),
                  cond )
          and AGRCheckOneCondition( Dimension,
                  x -> ( IsFunction( x ) and x( info.dim ) )
                       or info.dim = x, cond )
          and AGRCheckOneCondition( Ring,
                  R -> ( IsFunction( R ) and R( info.ring ) ) or
                       ( IsRing( R )
                  and IsZmodnZObjNonprimeCollection( R )
                  and ModulusOfZmodnZObj( One( R ) ) = Size( info.ring ) ),
                  cond )
          and AGRCheckOneCondition( Identifier,
                  x -> ( IsFunction( x ) and x( info.id ) = true )
                       or info.id = x, cond )
          and IsEmpty( cond );
    end,

    DisplayGroup := x -> Concatenation( "G <= GL(",String(x[3]),x[4],",Z/",
                                        String(x[2]),"Z)" ),

    TestFileHeaders := function( tocid, groupname, entry, type )
      return AGRTestFileHeadersDefault( tocid, groupname, entry, type,
               entry[3],
               function( entry, mats, filename )
                 if   not IsZmodnZObjNonprimeCollCollColl( mats ) then
                   return Concatenation( "matrices in `", filename,
                              "' are not over a residue class ring" );
                 elif ModulusOfZmodnZObj( mats[1][1][1] ) <> entry[2] then
                   return Concatenation( "matrices in `", filename,
                              "' are not over Z/", entry[2], "Z" );
                 fi;
                 return true;
               end );
    end,

    # Matrix representations over residue class rings are sorted according
    # to modulus, dimension, and identification string.
    SortTOCEntries := entry -> entry{ [ 2 .. 4 ] },

    ReadAndInterpretDefault := path -> AtlasDataGAPFormatFile(
                                           path ).generators,
    ) );


#############################################################################
##
#D  Quaternionic matrix representations
##
##  <#GAPDoc Label="type:quat:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-Hr<A>dim</A><A>id</A>B<A>m</A>.g</C></Mark>
##  <Item>
##    a &GAP; readable file
##    containing all generators of a matrix representation
##    over a quaternion algebra over an algebraic number field,
##    of dimension <A>dim</A>.
##    An example is <C>2A6G1-Hr2aB0.g</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "rep", "quat",  rec(

    # `<groupname>G<i>-Hr<dim><id>B<m>.g'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "Hr", IsDigitChar, IsLowerAlphaOrDigitChar,
                            "B", IsDigitChar, ".g" ] ],
                        [ ParseBackwards, ParseForwards ] ],

    AddDescribingComponents := function( record, type )
      local parsed, info;

      parsed:= AGRParseFilenameFormat( record.identifier[2],
                                       type[2].FilenameFormat );
      record.dim:= Int( parsed[5] );
      record.id:= parsed[6];
      info:= record.identifier[2];
      info:= info{ [ 1 .. Position( info, '.' )-1 ] };
      info:= First( AtlasOfGroupRepresentationsInfo.ringinfo,
                    x -> x[1] = info );
      if info <> fail then
        record.ring:= info[3];
      fi;
    end,

    # `[ <i>, <dim>, <id>, <m>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      if 0 < entry[5] then
        Add( list, Concatenation( entry{ [ 3, 5, 6, 8 ] }, [ name ] ) );
        return true;
      fi;
      return false;
    end,

    AccessGroupCondition := function( info, cond )
      return  AGRCheckOneCondition( IsMatrixGroup, x -> x = true, cond )
          and AGRCheckOneCondition( IsMatrixGroup, cond )
          and AGRCheckOneCondition( IsPermGroup, x -> x = false, cond )
          and AGRCheckOneCondition( Characteristic,
                  p -> p = 0 or ( IsFunction( p ) and p( 0 ) = true ),
                  cond )
          and AGRCheckOneCondition( Dimension,
                  x -> ( IsFunction( x ) and x( info.dim ) = true )
                       or info.dim = x, cond )
          and AGRCheckOneCondition( Ring,
                  x -> IsBound( info.ring ) and
                       ( ( IsFunction( x ) and x( info.ring ) = true )
                          or ( IsRing( x ) and IsQuaternionCollection( x ) 
                               and IsSubset( x, info.ring ) ) ), cond )
          and AGRCheckOneCondition( Identifier,
                  x -> ( IsFunction( x ) and x( info.id ) = true )
                       or info.id = x, cond )
          and IsEmpty( cond );
    end,

    TestFileHeaders := function( tocid, groupname, entry, type )
      return AGRTestFileHeadersDefault( tocid, groupname, entry, type,
               entry[2],
               function( entry, mats, filename )
                 local info;

                 if not ForAll( mats, IsQuaternionCollColl ) then
                   return Concatenation( "matrices in `",filename,
                              "' are not over the quaternions" );
                 fi;
                 filename:= filename{ [ 1 .. Position( filename, '.' )-1 ] };
                 info:= First( AtlasOfGroupRepresentationsInfo.ringinfo,
                               triple -> triple[1] = filename );
                 if info = fail then
                   return Concatenation( "field info for `",filename,
                              "' missing" );
                 elif Field( Flat( List( Flat( mats ), ExtRepOfObj ) ) )
                      <> EvalString( Concatenation( "Field",
                             info[2]{ [ Position( info[2], '(' ) ..
                                      Length( info[2] ) ] } ) ) then
                   return Concatenation( "field info for `", filename,
                              "' should involve ",
                              Field( Flat( List( Flat( mats ),
                                                 ExtRepOfObj ) ) ) );
                 fi;
                 return true;
               end );
    end,

    DisplayGroup := function( x )
      local fieldstring;
      fieldstring:= x[5]{ [ 1 .. Length( x[5] )-2 ] };
      fieldstring:= First( AtlasOfGroupRepresentationsInfo.ringinfo,
                           p -> p[1] = fieldstring );
      if fieldstring = fail then
        fieldstring:= "QuaternionAlgebra(C)";
      else
        fieldstring:= fieldstring[2];
      fi;
      return Concatenation( "G <= GL(",String(x[2]),x[3],",",fieldstring,
                            ")" );
    end,

    # Matrix representations over the quaternions are sorted according to
    # dimension and identification string.
    SortTOCEntries := entry -> entry{ [ 2, 3 ] },

    ReadAndInterpretDefault := path -> AtlasDataGAPFormatFile(
                                           path ).generators,
    ) );


#############################################################################
##
#D  Straight line programs for generators of maximal subgroups
##
##  <#GAPDoc Label="type:maxes:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-max<A>k</A>W<A>n</A></C></Mark>
##  <Item>
##    In this case, the file contains a straight line program that takes
##    generators of <M>G</M> w.r.t.&nbsp;the <A>i</A>-th set of standard
##    generators,
##    and returns a list of generators
##    (in general <E>not</E> standard generators)
##    for a subgroup <M>U</M> in the <A>k</A>-th class of maximal subgroups
##    of <M>G</M>.
##    An example is <C>J1G1-max7W1</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "maxes", rec(

    # `<groupname>G<i>-max<k>W<n>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "max", IsDigitChar, "W", IsDigitChar ] ],
                        [ ParseBackwards, ParseForwards ] ],

    # `[ <i>, <k>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      if 0 < entry[5] then
        Add( list, Concatenation( entry{ [ 3, 5 ] }, [ name ] ) );
        return true;
      fi;
      return false;
    end,

    DisplayOverviewInfo := [ "maxes", "r", function( tocs, groupname )
      local value, private, j, toc, record, comp, new, type;

      value:= [];
      private:= false;
      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( groupname ) ) then
          record:= toc.( groupname );
          for comp in [ "maxes", "maxext" ] do
            if IsBound( record.( comp ) ) then
              new:= List( record.( comp ), x -> x[2] );
              if IsBound( toc.diridPrivate ) and not IsEmpty( new ) then
                private:= true;
              fi;
              UniteSet( value, new );
            fi;
          od;
        fi;
      od;
      if IsEmpty( value ) then
        value:= "";
      else
        value:= String( Length( value ) );
      fi;
      return [ value, private ];
    end ],

    DisplayPRG := function( tocs, name, std, stdavail )
      local maxes, maxstd, private, j, toc, record, comp, i, result, line,
            entry;

      maxes   := [];
      maxstd  := [];
      private := "";

      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          for comp in [ "maxes", "maxext" ] do
            if IsBound( record.( comp ) ) then
              for i in record.( comp ) do
                if std = true or i[1] in std then
                  if IsBound( toc.diridPrivate ) then
                    private:= AtlasOfGroupRepresentationsInfo.markprivate;
                  fi;
                  if i[2] in maxes then
                    AddSet( maxstd[ Position( maxes, i[2] ) ], i[1] );
                  else
                    Add( maxes, i[2] );
                    Add( maxstd, [ i[1] ] );
                  fi;
                fi;
              od;
            fi;
          od;
        fi;
      od;
      SortParallel( maxes, maxstd );
      if 2 < Length( maxes ) then
        ConvertToRangeRep( maxes );
      fi;

      result:= [];
      if not IsEmpty( maxes ) then
        line:= "available maxes of G:";
        entry:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                       x -> x[2] = name );
        if Length( stdavail ) <= 1 then
          Append( line, "  " );
          Append( line, String( maxes ) );
          if IsBound( entry[5] ) and entry[5] = "all" then
            if Length( maxes ) = Length( entry[4] ) then
              Append( line, " (all)" );
            else
              Append( line, Concatenation( " (out of ",
                                String( Length( entry[4] ) ), ")" ) );
            fi;
          fi;
          Append( line, private );
          Append( line, "\n" );
          Add( result, line );
        else
          if IsBound( entry[5] ) and entry[5] = "all" then
            if Length( Set( maxes ) ) = Length( entry[4] ) then
              Append( line, Concatenation( " (all ",
                                String( Length( entry[4] ) ), ")\n" ) );
            else
              Append( line, Concatenation( " (out of ",
                                String( Length( entry[4] ) ), ")\n" ) );
            fi;
          fi;
          Append( line, "\n" );
          Add( result, line );
          for i in Union( maxstd ) do
            Add( result, Concatenation( "  ",
                String( maxes{ Filtered( [ 1 .. Length( maxes ) ],
                                         x -> i in maxstd[x] ) } ),
                private,
                "    (w.r.t. std. generators ", String( i ), ")\n" ) );
          od;
        fi;
      fi;
      return result;
    end,

    # Create the program from the identifier.
    AtlasProgram := function( type, identifier, prefix, groupname )
      local prog, toc, entry, result, i, gapname;

      # The second entry is either a filename or a filename plus info about
      # additional generators.
      if ForAll( identifier[2], IsString ) then
        # One program and some generators must be integrated.
        prog:= AGRFileContents( prefix, groupname, identifier[2][1], type );
        if prog = fail then
          return fail;
        fi;
        prog:= [ prog.program ];
        toc:= AtlasOfGroupRepresentationsInfo.TableOfContents.remote;
        if not IsBound( toc.( groupname ) ) or
           not IsBound( toc.( groupname ).maxextprg ) then
          return fail;
        fi;
        for entry in toc.( groupname ).maxextprg do
          if entry[1] = identifier[2][2] then
            Add( prog, StraightLineProgram( entry[2],
                           NrInputsOfStraightLineProgram( prog[1] ) ) );
            break;
          fi;
        od;
        if Length( prog ) = 1 then
          return fail;
        fi;
        prog:= IntegratedStraightLineProgramExt( prog );
        result:= rec( program         := prog,
                      standardization := identifier[3],
                      identifier      := identifier );
      else
        result:= AtlasProgramDefault( type, identifier, prefix, groupname );
      fi;

      # Set the size if available.
      if result <> fail then
        gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                         pair -> pair[2] = groupname );
        if IsBound( gapname[4] ) then
          i:= identifier[2];
          if not IsString( i ) then
            i:= identifier[2][1];
          fi;
          i:= AGRParseFilenameFormat( i, type[2].FilenameFormat )[5];
          if IsBound( gapname[4][i] ) then
            result.size:= gapname[4][i];
          fi;
        fi;
      fi;

      return result;
    end,

    # entry: `[ <std>, <maxnr>, <file> ]',
    # conditions: `[ "maxes", <maxnr> ]'
    AccessPRG := function( record, std, conditions )
      local entry;
      if Length( conditions ) = 2 and conditions[1] = "maxes"
                                  and IsPosInt( conditions[2] ) then
        if IsBound( record.maxes ) then
          for entry in record.maxes do
            if     ( std = true or entry[1] in std )
               and entry[2] = conditions[2] then
              return entry{ [ 3, 1 ] };
            fi;
          od;
        fi;
        if IsBound( record.maxext ) then
          for entry in record.maxext do
            if     ( std = true or entry[1] in std )
               and entry[2] = conditions[2] then
              if Length( entry[3] ) = 1 then
                return [ entry[3][1], entry[1] ];
              else
                return entry{ [ 3, 1 ] };
              fi;
            fi;
          od;
        fi;
      fi;
      return fail;
    end,

    # Maxes are sorted according to their natural position.
    SortTOCEntries := entry -> entry[2],

    # In addition to the tests in `AGRTestWordsSLPDefault',
    # compute the images in a representation if available,
    # and compare the group order with that stored in the
    # GAP Character Table Library (if available).
    TestWords:= function( tocid, name, file, type, verbose )
        local prog, prg, gens, pos, pos2, maxnr, gapname, storedsize, tbl,
              subname, subtbl, std, grp, size;

        # Read the program.
        if tocid = "local" then
          tocid:= "dataword";
        fi;
        prog:= AGRFileContents( tocid, name, file, type );
        if prog = fail then
          Print( "#E  file `", file, "' is corrupted\n" );
          return false;
        fi;

        # Check consistency.
        if prog = fail or not IsInternallyConsistent( prog.program ) then
          Print( "#E  program `", file, "' not internally consistent\n" );
          return false;
        fi;
        prg:= prog.program;

        # Create a list of trivial generators.
        gens:= ListWithIdenticalEntries(
                   NrInputsOfStraightLineProgram( prg ), () );

        # Run the program.
        gens:= ResultOfStraightLineProgram( prg, gens );

        # Compute the position in the `Maxes' list.
        pos:= PositionSublist( file, "-max" );
        pos2:= pos + 4;
        while file[ pos2 ] <> 'W' do
          pos2:= pos2 + 1;
        od;
        maxnr:= Int( file{ [ pos+4 .. pos2-1 ] } );

        # Fetch a perhaps stored value.
        gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                         pair -> name = pair[2] );
        if gapname = fail then
          Print( "#E  problem: no GAP name for `", name, "'\n" );
          return false;
        fi;
        storedsize:= fail;
        if IsBound( gapname[4] ) and IsBound( gapname[4][ maxnr ] ) then
          storedsize:= gapname[4][ maxnr ];
        fi;

        # Identify the group in the GAP Character Table Library.
        tbl:= CharacterTable( gapname[1] );
        if tbl = fail and storedsize = fail then
          if verbose then
            Print( "#I  no character table for `", gapname[1],
                   "', no check for `", file, "'\n" );
          fi;
          return true;
        fi;

        # Identify the subgroup in the GAP Character Table Library.
        if tbl <> fail then
          if HasMaxes( tbl ) then
            if Length( Maxes( tbl ) ) < maxnr then
              Print( "#E  program `", file,
                     "' contradicts `Maxes( ", tbl, " )'\n" );
              return false;
            fi;
            subname:= Maxes( tbl )[ maxnr ];
          else
            subname:= Concatenation( Identifier( tbl ), "M", String( maxnr ) );
          fi;
          subtbl:= CharacterTable( subname );
          if IsCharacterTable( subtbl ) then
            if storedsize <> fail and storedsize <> Size( subtbl ) then
              Print( "#E  program `", file,
                     "' contradicts stored subgroup order'\n" );
              return false;
            elif storedsize = fail then
              storedsize:= Size( subtbl );
            fi;
          elif storedsize = fail then
            if verbose then
              Print( "#I  no character table for `", subname,
                     "', no check for `", file, "'\n" );
            fi;
            return true;
          fi;
        fi;
        if storedsize = fail then
          return true;
        fi;

        # Compute the standardization.
        pos2:= pos - 1;
        while file[ pos2 ] <> 'G' do
          pos2:= pos2-1;
        od;
        std:= Int( file{ [ pos2+1 .. pos-1 ] } );

        # Get a representation if available, and map the generators.
        gapname:= gapname[1];
        gens:= OneAtlasGeneratingSetInfo( gapname, std, NrMovedPoints,
                   [ 2 .. AtlasOfGroupRepresentationsInfo.MaxTestDegree ] );
        if gens = fail then
          if verbose then
            Print( "#I  no perm. repres. for `", gapname,
                   "', no check for `", file, "'\n" );
          fi;
        else
          gens:= AtlasGenerators( gens );
          grp:= Group( gens.generators );
          if tbl <> fail then
            if IsBound( gens.size ) and gens.size <> Size( tbl ) then
              Print( "#E  wrong size for group`", gapname, "'\n" );
              return false;
            fi;
            SetSize( grp, Size( tbl ) );
          fi;
          gens:= ResultOfStraightLineProgram( prg, gens.generators );
          size:= Size( SubgroupNC( grp, gens ) );
          if size <> storedsize then
            Print( "#E  program `", file, "' for group of order ", size,
                   " not ", storedsize, "\n" );
            if subtbl <> fail then
              Print( "#E  (contradicts charatcer table of `",
                     Identifier( subtbl ), "')\n" );
            fi;
            return false;
          fi;
        fi;

        # No more tests are available.
        return true;
    end,

    ReadAndInterpretDefault := ScanStraightLineProgram,
    ) );


#############################################################################
##
#D  Straight line programs for class representatives
##
##  <#GAPDoc Label="type:classes:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-cclsW<A>n</A></C></Mark>
##  <Item>
##    In this case, the file contains a straight line program that returns
##    a list of conjugacy class representatives of <M>G</M>.
##    An example is <C>RuG1-cclsW1</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "classes", rec(

    # `<groupname>G<i>-cclsW<n>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "cclsW", IsDigitChar ] ],
                        [ ParseBackwards, ParseForwards ] ],

    # `[ <i>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, Concatenation( entry{ [ 3 ] }, [ name ] ) );
      return true;
    end,

    DisplayOverviewInfo := [ "cl", "r", function( tocs, groupname )
    local value, private, j, toc, record, i, pos, rel;

    value:= false;
    private:= false;
    for j in [ 1 .. Length( tocs ) ] do
      toc:= tocs[j];
      if IsBound( toc.( groupname ) ) then
        record:= toc.( groupname );
        if IsBound( record.classes ) and not IsEmpty( record.classes ) then
          value:= true;
        elif IsBound( record.cyc2ccl ) and IsBound( record.cyclic ) then
          for i in record.cyc2ccl do
            # Check that for scripts of the form
            # `<groupname>G<i>cycW<n>-cclsW<m>',
            # a script of the form `<groupname>G<i>-cycW<n>' is available.
            pos:= PositionSublist( i[2], "cycW" );
            rel:= Concatenation( i[2]{ [ 1 .. pos-1 ] }, "-",
                      i[2]{ [ pos .. Position( i[2], '-' ) - 1 ] } );
            if ForAny( record.cyclic, x -> x[2] = rel ) then
              value:= true;
              break;
            fi;
          od;
        fi;
        if value then
          if IsBound( toc.diridPrivate ) then
            private:= true;
          fi;
          break;
        fi;
      fi;
    od;
    if value then
      value:= "+";
    else
      value:= "-";
    fi;
    return [ value, private ];
    end ],

    DisplayPRG := function( tocs, name, std, stdavail )
      local ccl, c2c, cyc, private, j, toc, record, i, pos, rel;

      # (The information can be stored either directly or via two scripts
      # in `cyclic' and `cyc2ccl'.)
      ccl:= [];
      c2c:= [];
      cyc:= [];
      private:= "";
      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          if IsBound( record.classes ) then
            for i in record.classes do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                Add( ccl, i );
              fi;
            od;
          fi;
          if IsBound( record.cyc2ccl ) then
            for i in record.cyc2ccl do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                Add( c2c, i );
              fi;
            od;
          fi;
          if IsBound( record.cyclic ) then
            for i in record.cyclic do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                Add( cyc, i );
              fi;
            od;
          fi;
        fi;
      od;
      for i in c2c do

        # Check if for scripts of the form `<groupname>G<i>cycW<n>-cclsW<m>',
        # a script of the form `<groupname>G<i>-cycW<n>' is available.
        pos:= PositionSublist( i[2], "cycW" );
        rel:= Concatenation( i[2]{ [ 1 .. pos-1 ] }, "-",
                  i[2]{ [ pos .. Position( i[2], '-' ) - 1 ] } );
        if ForAny( cyc, x -> x[2] = rel ) then
          Add( ccl, i );
        fi;
      od;

      if IsEmpty( ccl ) then
        return [];
      elif 1 < Length( stdavail ) then
        return [ Concatenation( "class repres. of G available",
                                " for std. generators ",
                                String( Set( List( ccl, x -> x[1] ) ) ),
                                private, "\n" ) ];
      else
        return [ Concatenation( "class repres. of G available",
                                private, "\n" ) ];
      fi;
    end,

    # entry: `[ <std>, <file> ]',
    # conditions: `[ "classes" ]'
    AccessPRG := function( record, std, conditions )
      local entry, pos, rel, entry2;
      if not ( Length( conditions ) = 1 and conditions[1] = "classes" ) then
        return fail;
      fi;
      if IsBound( record.classes ) then
        for entry in record.classes do
          if std = true or entry[1] in std then
            return entry{ [ 2, 1 ] };
          fi;
        od;
      fi;
      if IsBound( record.cyclic ) and IsBound( record.cyc2ccl ) then
        for entry in record.cyc2ccl do
          if std = true or entry[1] in std then

            # Check if for scripts of the form
            # `<groupname>G<i>cycW<n>-cclsW<m>',
            # a script of the form `<groupname>G<i>-cycW<n>' is available.
            pos:= PositionSublist( entry[2], "cycW" );
            rel:= Concatenation( entry[2]{ [ 1 .. pos-1 ] }, "-",
                  entry[2]{ [ pos .. Position( entry[2], '-' ) - 1 ] } );
            for entry2 in record.cyclic do
              if entry2[2] = rel and ( std = true or entry2[1] in std ) then
                return [ [ entry[2], entry2[2] ], entry[1] ];
              fi;
            od;
          fi;
        od;
      fi;
      return fail;
    end,

    # Create the program from the identifier.
    AtlasProgram := function( type, identifier, prefix, groupname )
      local progs, prog, i, result;

      # The second entry is either a filename or a pair of filenames.
      if ForAll( identifier[2], IsString ) then
        # Two programs have to be composed.
        progs:= List( identifier[2],
                  name -> AGRFileContents( prefix, groupname, name, type ) );
        if fail in progs then
          return fail;
        fi;
        prog:= progs[1].program;
        for i in [ 2 .. Length( progs ) ] do
          prog:= CompositionOfStraightLinePrograms( prog, progs[i].program );
          if prog = fail then
            return fail;
          fi;
        od;
        result:= rec( program         := prog,
                      standardization := identifier[3],
                      identifier      := identifier );
        if IsBound( progs[1].outputs ) then
          # Take the outputs of the last program in the composition.
          result.outputs:= progs[1].outputs;
        fi;
        return result;

      elif IsString( identifier[2] ) then
        return AtlasProgramDefault( type, identifier, prefix, groupname );
      fi;
      return fail; 
    end,

    TestWords := function( tocid, name, file, type, verbose )
      return AGRTestWordsSLPDefault( tocid, name, file, type, true, verbose );
    end,

    ReadAndInterpretDefault := ScanStraightLineProgram,
    ) );


#############################################################################
##
#D  Straight line programs for representatives of cyclic subgroups
##
##  <#GAPDoc Label="type:cyclic:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-cycW<A>n</A></C></Mark>
##  <Item>
##    In this case, the file contains a straight line program that returns
##    a list of representatives of generators
##    of maximally cyclic subgroups of <M>G</M>.
##    An example is <C>Co1G1-cycW1</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "cyclic", rec(
    # `<groupname>G<i>-cycW<n>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "cycW", IsDigitChar ] ],
                        [ ParseBackwards, ParseForwards ] ],

    # `[ <i>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, Concatenation( entry{ [ 3 ] }, [ name ] ) );
      return true;
    end,

    DisplayOverviewInfo := DisplayOverviewInfoDefault( "cyc", "r", "cyclic" ),

    DisplayPRG := function( tocs, name, std, stdavail )
      local cyc, private, j, toc, record, i;
      cyc:= [];
      private:= "";
      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          if IsBound( record.cyclic ) then
            for i in record.cyclic do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                Add( cyc, i[2] );
              fi;
            od;
          fi;
        fi;
      od;

      if IsEmpty( cyc ) then
        return [];
      elif 1 < Length( stdavail ) then
        return [ Concatenation( "repres. of cyclic subgroups of G available",
                                " for std. generators ",
                                String( Set( List( cyc, x -> x[1] ) ) ),
                                private, "\n" ) ];
      else
        return [ Concatenation( "repres. of cyclic subgroups of G available",
                                private, "\n" ) ];
      fi;
    end,

    # entry: `[ <std>, <file> ]',
    # conditions: `[ "cyclic" ]'
    AccessPRG := function( record, std, conditions )
      local entry;
      if Length( conditions ) = 1 and conditions[1] = "cyclic"
                                  and IsBound( record.cyclic ) then
        for entry in record.cyclic do
          if std = true or entry[1] in std then
            return entry{ [ 2, 1 ] };
          fi;
        od;
      fi;
      return fail;
    end,

    TestWords := function( tocid, name, file, type, verbose )
      return AGRTestWordsSLPDefault( tocid, name, file, type, true, verbose );
    end,

    ReadAndInterpretDefault := ScanStraightLineProgram,
    ) );


#############################################################################
##
#D  Straight line programs for computing class representatives from
#D      representatives of cyclic subgroups
##
##  <#GAPDoc Label="type:cyc2ccls:format">
##  <Mark><C><A>groupname</A>G<A>i</A>cycW<A>n</A>-cclsW<A>m</A></C></Mark>
##  <Item>
##    In this case, the file contains a straight line program that takes
##    the return value of the program in the file
##    <A>groupname</A><C>G</C><A>i</A><C>-cycW</C><A>n</A>
##    (see above),
##    and returns a list of conjugacy class representatives of <M>G</M>.
##    An example is <C>M11G1cycW1-cclsW1</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "cyc2ccl", rec(

    # `<groupname>G<i>cycW<n>-cclsW<m>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar, "cycW", IsDigitChar ],
                          [ "cclsW", IsDigitChar ] ],
                        [ ParseBackwards, ParseForwards ] ],

    # `[ <i>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, Concatenation( entry{ [ 3 ] }, [ name ] ) );
      return true;
    end,

    # entry: `[ <std>, <file> ]',
    # conditions: `[ "cyc2ccl" ]'
    AccessPRG := function( record, std, conditions )
      local entry;
      if Length( conditions ) = 1 and conditions[1] = "cyc2ccl"
                                  and IsBound( record.cyc2ccl ) then
        for entry in record.cyc2ccl do
          if std = true or entry[1] in std then
            return entry{ [ 2, 1 ] };
          fi;
        od;
      fi;
      return fail;
    end,

    TestWords := function( tocid, name, file, type, verbose )
      return AGRTestWordsSLPDefault( tocid, name, file, type, true, verbose );
    end,

    ReadAndInterpretDefault := ScanStraightLineProgram,
    ) );


#############################################################################
##
#D  Straight line programs for computing standard generators of
#D      maximal subgroups
##
##  <#GAPDoc Label="type:maxstd:format">
##  <Mark><C><A>groupname</A>G<A>i</A>max<A>k</A>W<A>n</A>-<A>subgroupname</A>G<A>j</A>W<A>m</A></C></Mark>
##  <Item>
##    In this case, the file contains a straight line program that takes
##    the return value of the program in the file
##    <A>groupname</A><C>G</C><A>i</A><C>-max</C><A>k</A><C>W</C><A>n</A>
##    (see above),
##    which are generators for a group <M>U</M>, say;
##    <A>subgroupname</A> is a name for <M>U</M>,
##    and the return value is a list of standard generators for <M>U</M>,
##    w.r.t.&nbsp;the <A>j</A>-th set of standard generators.
##    (Of course this implies that the groups in the <A>k</A>-th class of
##    maximal subgroups of <M>G</M> are isomorphic to the group with name
##    <A>subgroupname</A>.)
##    An example is <C>J1G1max1W1-L211G1W1</C>;
##    the first class of maximal subgroups of the Janko group <M>J_1</M>
##    consists of groups isomorphic to the linear group <M>L_2(11)</M>,
##    for which standard generators are defined.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "maxstd", rec(
    # `<groupname>G<i>max<k>W<n>-<subgroupname>G<j>W<m>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar, "max", IsDigitChar,
                            "W", IsDigitChar ],
                          [ IsChar, "G", IsDigitChar, "W", IsDigitChar ] ],
                        [ ParseBackwards, ParseBackwards ] ],

    # `[ <i>, <k>, <subgroupname>, <j>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, Concatenation( entry{ [ 3, 5, 8, 10 ] }, [ name ] ) );
      return true;
    end,

    PostprocessFileInfo := function( toc, record )
      local list, i;
      list:= record.maxstd;
      for i in [ 1 .. Length( list ) ] do
        if not IsBound( toc.( list[i][3] ) ) then
          Info( InfoAtlasRep, 3,
                "t.o.c. construction: ignoring name `", list[i][5], "'" );
          Unbind( list[i] );
        fi;
      od;
      if not IsDenseList( list ) then
        record.maxstd:= Compacted( list );
      fi;
    end,

    TestWords := function( tocid, name, file, type, verbose )
      return AGRTestWordsSLPDefault( tocid, name, file, type, false, verbose );
    end,

    ReadAndInterpretDefault := ScanStraightLineProgram,
    ) );


#############################################################################
##
#D  Straight line programs for computing images of standard generators
#D      under outer automorphisms
##
##  <#GAPDoc Label="type:out:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-a<A>outname</A>W<A>n</A></C></Mark>
##  <Item>
##    In this case, the file contains a straight line program that takes
##    generators of <M>G</M> w.r.t.&nbsp;the <A>i</A>-th set of standard
##    generators,
##    and returns the list of their images
##    under the outer automorphism <M>\alpha</M> of <M>G</M>
##    given by the name <A>outname</A>;
##    if this name is empty then <M>\alpha</M> is the unique nontrivial
##    outer automorphism of <M>G</M>;
##    if it is a positive integer <M>k</M> then <M>\alpha</M> is a
##    generator of the unique cyclic order <M>k</M> subgroup of the outer
##    automorphism group of <M>G</M>;
##    if it is of the form <C>2_1</C> or <C>2a</C>,
##    <C>4_2</C> or <C>4b</C>, <C>3_3</C> or <C>3c</C>
##    <M>\ldots</M> then <M>\alpha</M>
##    generates the cyclic group of automorphisms induced on <M>G</M> by
##    <M>G.2_1</M>, <M>G.4_2</M>, <M>G.3_3</M> <M>\ldots</M>;
##    finally, if it is of the form <A>k</A><C>p</C><A>d</A>,
##    with <A>k</A> one of the above forms and <A>d</A> an integer then
##    <A>d</A> denotes the number of dashes
##    appended to the automorphism described by <A>k</A>;
##    if <M><A>d</A> = 1</M> then <A>d</A> can be omitted.
##    Examples are <C>A5G1-aW1</C>, <C>L34G1-a2_1W1</C>,
##    <C>U43G1-a2_3pW1</C>, and <C>O8p3G1-a2_2p5W1</C>;
##    these file names describe the outer order <M>2</M> automorphism of
##    <M>A_5</M> (induced by the action of <M>S_5</M>)
##    and the order <M>2</M> automorphisms of
##    <M>L_3(4)</M>, <M>U_4(3)</M>, and <M>O_8^+(3)</M>
##    induced by the actions of
##    <M>L_3(4).2_1</M>, <M>U_4(3).2_2^{\prime}</M>,
##    and <M>O_8^+(3).2_2^{{\prime\prime\prime\prime\prime}}</M>,
##    respectively.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "out", rec(
    # `<groupname>G<i>-a<outname>W<n>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [  "a", IsChar, "W", IsDigitChar ] ],
                        [ ParseBackwards, ParseBackwardsWithPrefix ] ],

    # `[ <i>, <nam>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      local std, descr, pos, dashes, order, index;
      std:= entry[3];
      descr:= entry[5];
      pos:= Position( descr, 'p' );
      if pos = fail then
        dashes:= "";
        pos:= Length( descr ) + 1;
      elif pos = Length( descr ) then
        dashes:= "'";
      else
        dashes:= Int( descr{ [ pos+1 .. Length( descr ) ] } );
        if dashes = fail then
          return false;
        fi;
        dashes:= ListWithIdenticalEntries( dashes, '\'' );
      fi;
      descr:= descr{ [ 1 .. pos-1 ] };
      pos:= Position( descr, '_' );
      if pos = fail then
        order:= descr;
        index:= "";
      else
        order:= descr{ [ 1 .. pos-1 ] };
        index:= descr{ [ pos+1 .. Length( descr ) ] };
      fi;
      if Int( order ) = fail or Int( index ) = fail then
        return false;
      elif order = "" then
        order:= "2";
      fi;
      if index <> "" then
        order:= Concatenation( order, "_", index );
      fi;
      order:= Concatenation( order, dashes );
      Add( list, [ std, order, name ] );
      return true;
    end,

    DisplayOverviewInfo := [ "out", "r", function( tocs, groupname )
      local value, private, j, toc, record, new;

      value:= [];;
      private:= false;
      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( groupname ) ) then
          record:= toc.( groupname );
          if IsBound( record.out ) then
            new:= Set( List( record.out, x -> x[2] ) );
            if IsBound( toc.diridPrivate ) and not IsEmpty( new ) then
              private:= true;
            fi;
            UniteSet( value, new );
          fi;
        fi;
      od;
      value:= JoinStringsWithSeparator( value, "," );
      return [ value, private ];
    end ],

    DisplayPRG := function( tocs, name, std, stdavail )
      local out, private, j, toc, record, i;

      out:= [];
      private:= "";

      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          if IsBound( record.out ) then
            for i in record.out do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                Add( out, i[2] );
              fi;
            od;
          fi;
        fi;
      od;
      if not IsEmpty( out ) then
        out:= [ Concatenation( "available automorphisms:  ", String( out ),
                    private, "\n" ) ];
      fi;
      return out;
    end,

    # entry: `[ <std>, <autname>, <file> ]',
    # conditions: `[ "automorphism", <autname> ]'
    AccessPRG := function( record, std, conditions )
      local entry;
      if Length( conditions ) = 2 and conditions[1] = "automorphism"
                                  and IsBound( record.out ) then
        for entry in record.out do
          if     ( std = true or entry[1] in std )
             and entry[2] = conditions[2] then
            return entry{ [ 3, 2 ] };
          fi;
        od;
      fi;
      return fail;
    end,

    # It would be good to check whether the order of the automorphism
    # fits to the name of the script, but the scripts do not describe
    # automorphisms of minimal possible order.
    # (So the power given by the name of the script is an inner
    # automorphism; how could we check this with reasonable effort?)
    # Thus we check just whether the name fits to the structure of the
    # outer automorphism group and to the order of the automorphism.
    # (We copy the relevant part of the code of `AGRTestWordsSLPDefault'
    # into this function.)
    TestWords := function( tocid, name, file, type, verbose )
      local filename, prog, prg, gens, gapname, pos, claimedorder, tbl,
            outinfo, bound, imgs, order;

      # Read the program.
      if tocid = "local" then
        tocid:= "dataword";
      fi;
      prog:= AGRFileContents( tocid, name, file, type );
      if prog = fail then
        Print( "#E  file `", file, "' is corrupted\n" );
        return false;
      fi;

      # Check consistency.
      if prog = fail or not IsInternallyConsistent( prog.program ) then
        Print( "#E  program `", file, "' not internally consistent\n" );
        return false;
      fi;
      prg:= prog.program;

      # Create the list of (trivial) generators.
      gens:= ListWithIdenticalEntries( NrInputsOfStraightLineProgram( prg ),
                                       () );

      # Run the program.
      gens:= ResultOfStraightLineProgram( prg, gens );

      # Get the GAP name of `name'.
      gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                       pair -> name = pair[2] );
      if gapname = fail then
        Print( "#E  problem: no GAP name for `", name, "'\n" );
        return false;
      fi;
      gapname:= gapname[1];

      # Get the order of the automorphism from the filename.
      pos:= PositionSublist( file, "-a" );
      claimedorder:= file{ [ pos+2 .. Length( file ) ] };
      pos:= Position( claimedorder, 'W' );
      claimedorder:= claimedorder{ [ 1 .. pos-1 ] };
      pos:= Position( claimedorder, 'p' );
      if pos <> fail then
	if not ForAll( claimedorder{ [ pos+1 .. Length( claimedorder ) ] },
	               IsDigitChar ) then
	  Print( "#E  wrong number of dashes in `", file, "'\n" );
	  return false;
	elif claimedorder{ [ pos+1 .. Length( claimedorder ) ] } = "0" then
          Print( "#E  wrong name `", file, "'\n" );
	  return false;
	fi;
        claimedorder:= claimedorder{ [ 1 .. pos-1 ] };
      fi;
      pos:= Position( claimedorder, '_' );
      if pos <> fail then
        claimedorder:= claimedorder{ [ 1 .. pos-1 ] };
      fi;
      if not ForAll( claimedorder, IsDigitChar ) then
        Print( "#E  wrong name `", file, "'\n" );
	return false;
      fi;
      claimedorder:= Int( claimedorder );

      # Get the structure of the automorphism group.
      # If this group is cyclic then we compare orders.
      tbl:= CharacterTable( gapname );
      if tbl <> fail and HasExtensionInfoCharacterTable( tbl ) then
        outinfo:= ExtensionInfoCharacterTable( tbl )[2];
        if    outinfo = "" then
          Print( "#E  automorphism `", file,
                 "' for group without outer automorphisms\n" );
          return false;
        elif outinfo <> "2" and claimedorder = 0 then
          Print( "#E  automorphism `", file,
                 "' but the outer automorphism is not unique\n" );
          return false;
        elif Int( outinfo ) <> fail and claimedorder <> 0
             and Int( outinfo ) mod claimedorder <> 0 then
          Print( "#E  automorphism `", file,
                 "' for outer automorphism group ", outinfo, "\n" );
          return false;
        fi;
      fi;

      if claimedorder = 0 then
        claimedorder:= 2;
      fi;

      # Get generators of the group in question.
      gens:= OneAtlasGeneratingSetInfo( gapname );
      if gens <> fail and tbl <> fail then
        gens:= AtlasGenerators( gens );
        if gens <> fail then
          gens:= gens.generators;
          bound:= Exponent( tbl ) * claimedorder;
  
          # Compute the order of the automorphism.
          imgs:= ResultOfStraightLineProgram( prg, gens );
          order:= 1;
          while order < bound and imgs <> gens do
            imgs:= ResultOfStraightLineProgram( prg, imgs );
            order:= order + 1;
          od;
  
          if   imgs <> gens then
            Print( "#E  order ", order, " of automorphism `", file,
                   "' is larger than ", bound, "\n" );
            return false;
          elif order mod claimedorder <> 0 then
            Print( "#E  order ", order, " of automorphism `", file,
                   "' not divisible by ", claimedorder, "\n" );
            return false;
          fi;
        fi;
      fi;

      return true;
    end,

    ReadAndInterpretDefault := ScanStraightLineProgram,
    ) );


#############################################################################
##
#D  Straight line programs for switching between different standardizations
##
##  <#GAPDoc Label="type:switch:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-G<A>j</A>W<A>n</A></C></Mark>
##  <Item>
##    In this case, the file contains a straight line program that takes
##    generators of <M>G</M> w.r.t.&nbsp;the <A>i</A>-th set of standard
##    generators, and returns standard generators of <M>G</M>
##    w.r.t.&nbsp;the <A>j</A>-th set of standard generators.
##    An example is <C>L35G1-G2W1</C>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "switch", rec(
    # `<groupname>G<i>-G<j>W<n>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [  "G", IsDigitChar, "W", IsDigitChar ] ],
                        [ ParseBackwards, ParseForwards ] ],

    # `[ <i>, <j>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, [ entry[3], entry[5], name ] );
      return true;
    end,

    DisplayPRG := function( tocs, name, std, stdavail )
      local switch, private, j, toc, record, i;

      switch:= [];
      private:= "";

      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          if IsBound( record.switch ) then
            for i in record.switch do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                Add( switch, Concatenation( String( i[1] ), " -> ",
                                 String( i[2] ) ) );
              fi;
            od;
          fi;
        fi;
      od;
      if not IsEmpty( switch ) then
        switch:= [ Concatenation( "available restandardizations:  ",
                       String( switch ), private, "\n" ) ];
      fi;
      return switch;
    end,

    # entry: `[ <std>, <descr>, <file> ]',
    # conditions: `[ "restandardize", <std2> ]'
    AccessPRG := function( record, std, conditions )
      local entry;
      if Length( conditions ) = 2 and conditions[1] = "restandardize"
                                  and IsBound( record.switch ) then
        for entry in record.switch do
          if     ( std = true or entry[1] in std )
             and conditions[2] = entry[2] then
            return entry{ [ 3, 1, 2 ] };
          fi;
        od;
      fi;
      return fail;
    end,

    TestWords := function( tocid, name, file, type, verbose )
      return AGRTestWordsSLPDefault( tocid, name, file, type, false, verbose );
    end,

    ReadAndInterpretDefault := ScanStraightLineProgram,
    ) );


#############################################################################
##
#D  Black box programs for finding standard generators
##
##  <#GAPDoc Label="type:find:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-find<A>n</A></C></Mark>
##  <Item>
##    <Index Subkey="for finding standard generators">black box program
##    </Index>
##    In this case, the file contains a black box program that takes
##    a group, and returns (if it is successful) a set of standard generators
##    for <A>G</A>, w.r.t.&nbsp;the <A>i</A>-th standardization.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "find", rec(
    # `<groupname>G<i>-find<j>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "find", IsDigitChar ] ],
                        [ ParseBackwards, ParseBackwardsWithPrefix ] ],

    # `[ <i>, <j>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, [ entry[3], entry[5], name ] );
      return true;
    end,

    DisplayOverviewInfo := DisplayOverviewInfoDefault( "fnd", "r", "find" ),
#T better number of pres.!

    DisplayPRG := function( tocs, name, std, stdavail )
      local find, private, j, toc, record, i;

      find:= [];
      private:= "";

      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          if IsBound( record.find ) then
            for i in record.find do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                AddSet( find, String( i[1] ) );
              fi;
            od;
          fi;
        fi;
      od;
      if IsEmpty( find ) then
        return [];
      elif 1 < Length( stdavail ) then
        return [ Concatenation( "standard generators finder available",
                                " for std. generators ",
                                JoinStringsWithSeparator( find, ", " ),
                                private, "\n" ) ];
      else
        return [ Concatenation( "standard generators finder available",
                                private, "\n" ) ];
      fi;
    end,

    # entry: `[ <std>, <version>, <file> ]',
    # conditions: `[ "find" ]'
    AccessPRG := function( record, std, conditions )
      local entry;
      if Length( conditions ) = 1 and conditions[1] = "find"
                                  and IsBound( record.find ) then
        for entry in record.find do
          if std = true or entry[1] in std then
            # the part of the identifier
            return entry{ [ 3, 1, 2 ] };
          fi;
        od;
      fi;
      return fail;
    end,

    ReadAndInterpretDefault := path -> ScanBBoxProgram( StringFile( path ) ),

    # If there is a representation for this group (independent of the
    # standardization) then we apply the script, and check whether at least
    # the whole group is generated by the result; if also a `check' script
    # is available for this standardization then we run it on the result.
    TestWords := function( tocid, name, file, type, verbose )
      local prog, prg, gapname, gens, G, res, pos, pos2, std, check;

      # Read the program.
      if tocid = "local" then
        tocid:= "dataword";
      fi;
      prog:= AGRFileContents( tocid, name, file, type );
      if prog = fail then
        Print( "#E  file `", file, "' is corrupted\n" );
        return false;
      fi;
      prg:= prog.program;

      # Get the GAP name of `name'.
      gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                       pair -> name = pair[2] );
      if gapname = fail then
        Print( "#E  problem: no GAP name for `", name, "'\n" );
        return false;
      fi;

      # Get generators of the group in question.
      gens:= OneAtlasGeneratingSetInfo( gapname[1] );
      if gens <> fail then
        gens:= AtlasGenerators( gens );
        if gens <> fail then
          gens:= gens.generators;
          G:= Group( gens );
          if IsBound( gapname[3] ) then
            SetSize( G, gapname[3] );
          fi;
          res:= ResultOfBBoxProgram( prg, G );
          if IsList( res ) and not IsString( res ) then
            # Compute the standardization.
            pos:= Position( file, '-' );
            pos2:= pos - 1;
            while file[ pos2 ] <> 'G' do
              pos2:= pos2-1;
            od;
            std:= Int( file{ [ pos2+1 .. pos-1 ] } );
            check:= AtlasProgram( gapname[1], std, "check" );
            if check <> fail then
              if not ResultOfStraightLineDecision( check.program, res ) then
                Print( "#E  return values of `", file,
                       "' do not fit to the check file\n" );
                return false;
              fi;
            fi;
            # Check the group order only for permutation groups.
            if IsPermGroup( G ) then
              if not IsSubset( G, res ) then
                Print( "#E  return values of `", file,
                       "' do not lie in the group\n" );
                return false;
              elif Size( SubgroupNC( G, res ) ) <> Size( G ) then
                Print( "#E  return values of `", file,
                       "' do not generate the group\n" );
                return false;
              fi;
            fi;
          fi;
        fi;
      fi;

      return true;
    end,

    ) );


#############################################################################
##
#D  Straight line programs for checking standard generators
##
##  <#GAPDoc Label="type:check:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-check<A>n</A></C></Mark>
##  <Item>
##    <Index>semi-presentation</Index>
##    In this case, the file contains a straight line decision that takes
##    generators of <M>G</M>, and returns <K>true</K> if these generators are
##    standard generators w.r.t.&nbsp;the <A>i</A>-th standardization,
##    and <K>false</K> otherwise.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "check", rec(
    # `<groupname>G<i>-check<j>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "check", IsDigitChar ] ],
                        [ ParseBackwards, ParseBackwardsWithPrefix ] ],

    # `[ <i>, <j>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, [ entry[3], entry[5], name ] );
      return true;
    end,

    DisplayOverviewInfo := [ "chk", "r", function( tocs, groupname )
    local value, private, j, toc, record, i, pos, rel;

    value:= "-";
    private:= false;
    for j in [ 1 .. Length( tocs ) ] do
      toc:= tocs[j];
      if IsBound( toc.( groupname ) ) then
        record:= toc.( groupname );
        if ( IsBound( record.check ) and not IsEmpty( record.check ) ) or
           ( IsBound( record.pres ) and not IsEmpty( record.pres ) ) then
          value:= "+";
          if IsBound( toc.diridPrivate ) then
            private:= true;
          fi;
          break;
        fi;
      fi;
    od;
    return [ value, private ];
    end ],

    DisplayPRG := function( tocs, name, std, stdavail )
      local check, private, j, toc, record, comp, i;

      check:= [];
      private:= "";

      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          for comp in [ "check", "pres" ] do
            if IsBound( record.( comp ) ) then
              for i in record.( comp ) do
                if std = true or i[1] in std then
                  if IsBound( toc.diridPrivate ) then
                    private:= AtlasOfGroupRepresentationsInfo.markprivate;
                  fi;
                  AddSet( check, String( i[1] ) );
                fi;
              od;
            fi;
          od;
        fi;
      od;
      if IsEmpty( check ) then
        return [];
      elif 1 < Length( stdavail ) then
        return [ Concatenation( "standard generators checker available",
                                " for std. generators ",
                                JoinStringsWithSeparator( check, ", " ),
                                private, "\n" ) ];
      else
        return [ Concatenation( "standard generators checker available",
                                private, "\n" ) ];
      fi;
    end,

    # entry: `[ <std>, <version>, <file> ]',
    # conditions: `[ "check" ]'
    AccessPRG := function( record, std, conditions )
      local entry, comp;

      if Length( conditions ) = 1 and conditions[1] = "check" then
        for comp in [ "check", "pres" ] do
          if IsBound( record.( comp ) ) then
            for entry in record.( comp ) do
              if std = true or entry[1] in std then
                # the part of the identifier
                return entry{ [ 3, 1, 2 ] };
              fi;
            od;
          fi;
        od;
      fi;
      return fail;
    end,

    TestWords := function( tocid, name, file, type, verbose )
        return AGRTestWordsSLDDefault( tocid, name, file, type,
                 [ IsChar, "G", IsDigitChar, "-check", IsDigitChar ],
                 verbose ); end,

    ReadAndInterpretDefault := path -> ScanStraightLineDecision(
                                           StringFile( path ) ),
    ) );


#############################################################################
##
#D  BBox programs representing presentations
##
##  <#GAPDoc Label="type:pres:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-P<A>n</A></C></Mark>
##  <Item>
##    <Index>presentation</Index>
##    In this case, the file contains a straight line decision that takes
##    some group elements, and returns <K>true</K> if these elements are
##    standard generators for <A>G</A>,
##    w.r.t.&nbsp;the <A>i</A>-th standardization,
##    and <K>false</K> otherwise.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "pres", rec(
    # `<groupname>G<i>-P<j>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "P", IsDigitChar ] ],
                        [ ParseBackwards, ParseBackwardsWithPrefix ] ],

    # `[ <i>, <j>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, [ entry[3], entry[5], name ] );
      return true;
    end,


    DisplayOverviewInfo := DisplayOverviewInfoDefault( "prs", "r", "pres" ),
#T better number of pres.!

    DisplayPRG := function( tocs, name, std, stdavail )
      local pres, private, j, toc, record, i;

      pres:= [];
      private:= "";

      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          if IsBound( record.pres ) then
            for i in record.pres do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                AddSet( pres, String( i[1] ) );
              fi;
            od;
          fi;
        fi;
      od;
      if IsEmpty( pres ) then
        return [];
      elif 1 < Length( stdavail ) then
        return [ Concatenation( "presentation available",
                                " for std. generators ",
                                JoinStringsWithSeparator( pres, ", " ),
                                private, "\n" ) ];
      else
        return [ Concatenation( "presentation available",
                                private, "\n" ) ];
      fi;
    end,

    # entry: `[ <std>, <version>, <file> ]',
    # conditions: `[ "presentation" ]'
    AccessPRG := function( record, std, conditions )
      local entry;
      if Length( conditions ) = 1 and conditions[1] = "presentation"
                                  and IsBound( record.pres ) then
        for entry in record.pres do
          if std = true or entry[1] in std then
            # the part of the identifier
            return entry{ [ 3, 1, 2 ] };
          fi;
        od;
      fi;
      return fail;
    end,

    TestWords := function( tocid, name, file, type, verbose )
        return AGRTestWordsSLDDefault( tocid, name, file, type,
                 [ IsChar, "G", IsDigitChar, "-P", IsDigitChar ],
                 verbose ); end,

    ReadAndInterpretDefault := path -> ScanStraightLineDecision(
                                           StringFile( path ) ),
    ) );


#############################################################################
##
#D  Other straight line programs
##
##  <#GAPDoc Label="type:otherscripts:format">
##  <Mark><C><A>groupname</A>G<A>i</A>-X<A>descr</A>W<A>n</A></C></Mark>
##  <Item>
##    In this case, the file contains a straight line program that takes
##    generators of <M>G</M> w.r.t.&nbsp;the <A>i</A>-th set of standard
##    generators, and whose return value corresponds to <A>descr</A>.
##    This format is used only in private extensions
##    (see Chapter&nbsp;<Ref Chap="chap:Private Extensions"/>),
##    such a script can be accessed with <A>descr</A> as the third argument
##    of <Ref Func="AtlasProgram"/>.
##  </Item>
##  <#/GAPDoc>
##
AGRDeclareDataType( "prg", "otherscripts", rec(

    # `<groupname>G<i>-X<descr>W<n>'
    FilenameFormat := [ [ [ IsChar, "G", IsDigitChar ],
                          [ "X", IsChar, "W", IsDigitChar ] ],
                        [ ParseBackwards, ParseBackwardsWithPrefix ] ],

    # `[ <i>, <descr>, <filename> ]'
    AddFileInfo := function( list, entry, name )
      Add( list, Concatenation( entry{ [ 3, 5 ] }, [ name ] ) );
      return true;
    end,

    DisplayPRG := function( tocs, name, std, stdavail )
      local result, other, private, j, toc, record, i;
      other:= [];
      private:= "";
      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          if IsBound( record.otherscripts ) then
            for i in record.otherscripts do
              if std = true or i[1] in std then
                if IsBound( toc.diridPrivate ) then
                  private:= AtlasOfGroupRepresentationsInfo.markprivate;
                fi;
                Add( other, Concatenation( "\"", i[2], "\"", private ) );
              fi;
            od;
          fi;
        fi;
      od;
      if not IsEmpty( other ) then
        other:= [ Concatenation( "available other scripts:\n   ",
                      JoinStringsWithSeparator( other, "\n   " ),
                      "\n" ) ];
      fi;
      return other;
    end,

    # entry: `[ <std>, <descr>, <file> ]',
    # conditions: `[ "other", <descr> ]'
    AccessPRG := function( record, std, conditions )
      local entry;
      if Length( conditions ) = 2 and conditions[1] = "other"
                                  and IsBound( record.otherscripts ) then
        for entry in record.otherscripts do
          if     ( std = true or entry[1] in std )
             and entry[2] = conditions[2] then
            return entry{ [ 3, 1 ] };
          fi;
        od;
      fi;
      return fail;
    end,

    TestWords := function( tocid, name, file, type, verbose )
      return AGRTestWordsSLPDefault( tocid, name, file, type, false, verbose );
    end,

    ReadAndInterpretDefault := ScanStraightLineProgram,
    ) );


#############################################################################
##
##  Read the server's table of contents.
##  Preferably a user file is taken because it might be a more recent version,
##  otherwise the file that was distributed with the package is read.
##
##  Note that the file <F>types.g</F> is notified with
##  <C>DeclareAutoreadableVariables</C>,
##  in order to delay the evaluation of the data.
##
##  <#GAPDoc Label="ATLASREP_TOCFILE">
##  Alternatively, one can add a line to the user's <F>.gaprc</F> file
##  (see&nbsp;<Ref Sect="The .gaprc file" BookName="ref"/>),
##  which assigns the filename of the current <F>gap/atlasprm.g</F> file
##  (as an absolute path or relative to the user's home directory,
##  cf.&nbsp;<Ref Func="Directory" BookName="ref"/>)
##  to the global variable <C>ATLASREP_TOCFILE</C>;
##  <Index Key="ATLASREP_TOCFILE"><C>ATLASREP_TOCFILE</C></Index>
##  in this case, this file is read instead of the one from the package
##  distribution when the package is loaded.
##  <#/GAPDoc>
##
if IsBound( ATLASREP_TOCFILE ) then
  if not IsReadableFile( ATLASREP_TOCFILE ) then
    Error( "the file for the global `ATLASREP_TOCFILE' is not readable" );
  elif not READ( ATLASREP_TOCFILE ) then
    Error( "problem reading the file for the global `ATLASREP_TOCFILE'" );
  fi;
else
  ReadPackage( "atlasrep", "gap/atlasprm.g" );
fi;


#############################################################################
##
#E

