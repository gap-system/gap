#############################################################################
##
#W  ctadmin.g           GAP character table library             Thomas Breuer
#W                                                               Ute Schiffer
##
#H  @(#)$Id: ctadmin.g,v 1.10 2004/02/02 08:08:47 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the data of the {\GAP} character table library that is
##  not automatically produced from the library files.
##
Revision.ctadmin_g :=
    "@(#)$Id: ctadmin.g,v 1.10 2004/02/02 08:08:47 gap Exp $";


#############################################################################
##
TBLNAME:= Concatenation( List( PKGNAME,
              x -> Concatenation( x, "ctbllib/data/;" ) ) );


#############################################################################
##
#F  Immutable( <obj> )
#F  MakeImmutable( <obj> )
#F  MakeReadOnlyGlobal( <obj> )
#F  TestPackageAvailability( ... )
#V  fail
#F  IsPosInt( <n> )
#V  TOM_TBL_INFO
#F  ListWithIdenticalEntries( <len>, <entry> )
#F  BindGlobal
#F  ValueGlobal
##
##  These are used in `ctprimar.tbl' but not available in {\GAP}~3.4.
##
if not IsBound( IsEmpty ) then
  IsEmpty:= list -> ( list = [] );
fi;
if not IsBound( Immutable ) then
  Immutable:= x -> x;
fi;
if not IsBound( MakeImmutable ) then
  MakeImmutable:= Ignore;
fi;
if not IsBound( MakeReadOnlyGlobal ) then
  MakeReadOnlyGlobal:= Ignore;
fi;
if not IsBound( TestPackageAvailability ) then
  TestPackageAvailability:= function( arg ) return true; end;
fi;
if not IsBound( fail ) then
  fail:= false;
fi;
if not IsBound( IsPosInt ) then
  IsPosInt:= ( n -> IsInt( n ) and 0 < n );
fi;
if not IsBound( TOM_TBL_INFO ) then
  TOM_TBL_INFO:= [];
fi;
if not IsBound( ListWithIdenticalEntries ) then
  ListWithIdenticalEntries:= function( len, entry )
      return List( [ 1 .. len ], i -> entry );
  end;
fi;
if not IsBound( BindGlobal ) then
  BindGlobal:= function( varname, value )
    if   varname = "LIBLIST" then
      LIBLIST:= value;
    elif varname = "TOM_TBL_INFO" then
      TOM_TBL_INFO:= value;
    else
      Error( "BindGlobal is not fully available in GAP 3" );
    fi;
  end;
fi;
ConstructSubdirect:= 0;
ConstructPermuted:= 0;
ConstructFactor:= 0;
if not IsBound( ValueGlobal ) then
  ValueGlobal:= function( varname )
    local constr, pos;
    constr:= [ "ConstructMixed", ConstructMixed,
               "ConstructProj",  ConstructProj,
               "ConstructDirectProduct",  ConstructDirectProduct,
               "ConstructSubdirect",  ConstructSubdirect,
               "ConstructIsoclinic",  ConstructIsoclinic,
               "ConstructV4G",  ConstructV4G,
               "ConstructGS3",  ConstructGS3,
               "ConstructPermuted",  ConstructPermuted,
               "ConstructFactor",  ConstructFactor,
               "ConstructClifford",  ConstructClifford ];
    pos:= Position( constr, varname );
    if pos <> fail then
      return constr[ pos+1 ];
    else
      Error( "ValueGlobal is not fully available in GAP 3" );
    fi;
  end;
fi;


#############################################################################
##
#V  CharTableDoubleCoverAlternating
#V  CharTableDoubleCoverSymmetric
##
##  These are used in `data/ctgeneri.tbl' but are not available in {\GAP}~3.
##
CharTableDoubleCoverAlternating := rec();
CharTableDoubleCoverSymmetric := rec();


#############################################################################
##
#F  Conductor( <obj> )
##
##  This is used in `data/ctgeneri.tbl'.
##
Conductor:= NofCyc;


#############################################################################
##
#V  GAP_4_SPECIALS
##
##  list of pairs whose first entries are the `identifier' values
##  of tables whose `construction' component would require {\GAP}~4 features,
##  and the second entries are the corresponding functions that do the same
##  in {\GAP}~3.
##
GAP_4_SPECIALS := [
[ "2.(2xF4(2)).2", function( tbl )
  local pi, irr, i, outer1, outer2, chi, j, adjustch, adjustcl, z;
  pi:= (2,3)(6,7)(10,11)(14,15)(18,19)(22,23)(28,29)(32,33)(40,41)(44,45)
       (48,49)(58,59)(62,63)(66,67)(70,71)(74,75)(78,79)(82,83)(86,87)(90,91)
       (96,97)(100,101)(110,111)(114,115)(118,119)(122,123)(126,127)(132,133)
       (136,137)(140,141)(144,145)(150,151)(158,159)(162,163)(166,167)(170,
       171)(174,175)(182,183)(186,187)(190,191)(196,197)(200,201)(204,205)
       (208,209)(212,213)(228,229)(234,235)(246,247)(254,255)(258,259)(264,
       265)(268,269)(272,273)(276,277)(280,281)(284,285)(288,289)(292,293)
       (296,297)(300,301);
  ConstructDirectProduct( tbl, [["2.F4(2).2"],["Cyclic",2]], pi, () );
  Unbind( tbl.orders );
  Unbind( tbl.fusions[ Length( tbl.fusions ) ] );
  Unbind( tbl.fusions[ Length( tbl.fusions ) ] );
  irr:= tbl.irreducibles;
  for i in [ 1 .. Length( irr ) ] do
    irr[i]:= ShallowCopy( irr[i] );
  od;
  outer1:= [215..302];
  outer2:= [3,4,7,8,11,12,15,16,19,20,23,24,26,29,30,33,34,36,38,41,42,45,46,
  49,50,52,54,56,59,60,63,64,67,68,71,72,75,76,79,80,83,84,87,88,91,92,94,97,
  98,101,102,104,106,108,111,112,115,116,119,120,123,124,127,128,130,133,134,
  137,138,141,142,145,146,148,151,152,154,156,159,160,163,164,167,168,171,172,
  175,176,178,180,183,184,187,188,191,192,194,197,198,201,202,205,206,209,210,
  213,214,216,218,220,222,224,226,229,230,232,235,236,238,240,242,244,247,248,
  250,252,255,256,259,260,262,265,266,269,270,273,274,277,278,281,282,285,286,
  289,290,293,294,297,298,301,302];
  i:= E(4);
  for chi in irr do
    if chi[1] = chi[2] then
      if chi[1] <> chi[2] or chi[1] <> chi[3] then
        for j in outer1 do
          chi[j]:= i * chi[j];
        od;
      fi;
    else
      for j in outer2 do
        chi[j]:= i * chi[j];
      od;
    fi;
  od;
  adjustch:= [183,184,185,186,191,192,193,194,195,196,197,198,199,200,201,202,
  209,210,211,212,217,218,219,220,223,224,225,226,237,238,239,240,265,266,267,
  268,271,272,273,274,275,276,277,278,287,288,289,290,291,292,293,294,295,296,
  297,298,299,300,301,302];
  adjustcl:=[227,228,229,230,233,234,235,236,245,246,247,248,253,254,255,256,
  257,258,259,260,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,
  278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,
  297,298,299,300,301,302];
  z:= E(8);
  for chi in irr{ adjustch{ [ 1, 3 .. 59 ] } } do
    for j in adjustcl do
      chi[j]:= z * chi[j];
    od;
  od;
  z:= E(8)^3;
  for chi in irr{ adjustch{ [ 2, 4 .. 60 ] } } do
    for j in adjustcl do
      chi[j]:= z * chi[j];
    od;
  od;
end ],
[ "C9Y3.3^5.U4(2)", function( tbl )
  local e, e8, e2, e7, chi, i;
  ConstructDirectProduct( tbl, [["Cyclic",3],["3.3^5.U4(2)"]] );
  Unbind( tbl.orders );
  Unbind( tbl.fusions[ Length( tbl.fusions ) ] );
  Unbind( tbl.fusions[ Length( tbl.fusions ) ] );
  for i in [ 1 .. Length( tbl.irreducibles ) ] do
    tbl.irreducibles[i]:= ShallowCopy( tbl.irreducibles[i] );
  od;
  e:= E(9);
  e8:= E(9)^8;
  e2:= E(9)^2;
  e7:= E(9)^7;
  for chi in tbl.irreducibles do
    if chi[2] = chi[1] * E(3) then
      for i in [ 86 .. 170 ] do
        chi[i]:= chi[i] * e8;
      od;
      for i in [ 171 .. 255 ] do
        chi[i]:= chi[i] * e7;
      od;
    elif chi[2] = chi[1] * E(3)^2 then
      for i in [ 86 .. 170 ] do
        chi[i]:= chi[i] * e;
      od;
      for i in [ 171 .. 255 ] do
        chi[i]:= chi[i] * e2;
      od;
    fi;
  od;
end ],
];


#############################################################################
##
#F  CharTableIsoclinic( <tbl> )
#F  CharTableIsoclinic( <tbl>, <classes_of_normal_subgroup> )
#F  CharTableIsoclinic( <tbl>, <nsg>, <center> )
##
##  for table of groups $2.G.2$, the character table of the isoclinic group
##  (see ATLAS, Chapter 6, Section 7)
##
CharTableIsoclinic;

CharTableIsoclinic := function( arg )
    local i,           # 'E(4)'
          j,           # loop variable
          chi,         # one character
          orders,
          class,
          map,
          tbl,         # input table
          linear,      # linear characters of 'tbl'
          isoclinic,   # the isoclinic table, result
          center,      # nontrivial class(es) contained in the center
          nsg,         # index 2 subgroup
          outer,       # classes outside the index 2 subgroup
          images,
          factorfusion,
          reg;         # restriction to regular classes

    # check the argument
    if not ( Length( arg ) in [ 1 .. 3 ] and IsCharTable( arg[1] ) )
       or ( Length( arg ) = 2 and not IsList( arg[2] ) ) then
      Error( "usage: CharTableIsoclinic( tbl ) resp.\n",
             "       CharTableIsoclinic( tbl, classes_of_nsg )");
    fi;

    # get the ordinary table if necessary
    if IsBound( arg[1].ordinary ) then
      tbl:= arg[1].ordinary;
    else
      tbl:= arg[1];
    fi;
    if not IsBound( tbl.powermap ) then
      tbl.powermap:= [];
    fi;

    # compute the isoclinic table of the ordinary table

    # Get the classes of the normal subgroup of index 2.
    if Length( arg ) = 1 then
      linear:= Filtered( tbl.irreducibles, x -> x[1] = 1 );
      for chi in linear do
        if Sum( tbl.classes{ KernelChar( chi ) } ) <> tbl.size / 2 then
          linear:= Difference( linear, [ chi ] );
        fi;
      od;
      if Length( linear ) > 1 then
        orders:= tbl.orders;
        center:= Filtered( [ 1 .. Length( tbl.classes ) ],
                           x -> tbl.classes[x] = 1 and orders[x] = 2 );
        if Length( center ) = 1 then
          center:= center[1];
          linear:= Filtered( linear, lambda -> lambda[ center ] = 1 );
        fi;
      fi;
      if Length( linear ) <> 1 then
        Error( "normal subgroup of index 2 not uniquely determined,\n",
               "use CharTableIsoclinic( tbl, classes_of_nsg )" );
      fi;
      nsg:= KernelChar( linear[1] );
    else
      if Sum( tbl.classes{ arg[2] } ) <> tbl.size / 2 then
        Error( "normal subgroup must have index 2" );
      fi;
      nsg:= arg[2];
    fi;

    # Get the central subgroup of order 2 lying in the above normal subgroup.
    center:= Filtered( nsg, x -> tbl.centralizers[1] = tbl.centralizers[x]
                                 and tbl.orders[x] = 2 );
    if Length( center ) <> 1 then
      Error( "Central subgroup of order 2 must be unique" );
    fi;
    center:= center[1];

    # make the record of the isoclinic table
    isoclinic:= rec(
                     identifier   := Concatenation( "Isoclinic(",
                                                    tbl.identifier, ")" ),
                     size         := tbl.size,
                     centralizers := Copy( tbl.centralizers ),
                     classes      := Copy( tbl.classes ),
                     orders       := Copy( tbl.orders ),
                     fusions      := [],
                     fusionsource := [],
                     powermap     := Copy( tbl.powermap ),
                     irreducibles := Copy( tbl.irreducibles ),
                     operations   := CharTableOps               );

    isoclinic.order:= isoclinic.size;
    isoclinic.name:= isoclinic.identifier;

    # classes outside the normal subgroup
    outer:= Difference( [ 1 .. Length( tbl.classes ) ], nsg );

    # adjust faithful characters in outer classes
    i:= E(4);
    for chi in Filtered( isoclinic.irreducibles,
                         x -> x[ center ] <> x[1] ) do
      for class in outer do
        chi[ class ]:= i * chi[ class ];
      od;
    od;

    # get the fusion map onto the factor group modulo the center
    CharTableFactorGroup( isoclinic, [ 1, center ] );   # very strange ...
    factorfusion:= isoclinic.fusions[1].map;
    isoclinic.fusions:= [];

    # adjust the power maps
    for j in [ 1 .. Length( isoclinic.powermap ) ] do
      if IsBound( isoclinic.powermap[j] ) then
        map:= isoclinic.powermap[j];
        if j mod 4 = 2 then

          # The squares lie in 'nsg'; for $g^2 = h$,
          # we have $(gi)^2 = hz$, so we must take the other
          # preimage under the factorfusion, if exists.

          for class in outer do
            images:= Filtered( Difference( nsg, [ map[class] ] ),
                              x -> factorfusion[x]
                                   = factorfusion[ map[ class ] ] );
            if Length( images ) = 1 then
              map[ class ]:= images[1];
              isoclinic.orders[ class ]:= 2 * isoclinic.orders[ images[1] ];
            fi;
          od;

        elif j mod 4 = 3 then
    
          # For $g^p = h$, we have $(gi)^p = hi^p = hiz$, so again
          # we must choose the other preimage under the
          # factorfusion, if exists; the 'p'-th powers lie outside
          # 'nsg' in this case.

          for class in outer do
            images:= Filtered( Difference( outer, [ map[ class ] ] ),
                              x -> factorfusion[x]
                                   = factorfusion[ map[ class ] ] );
            if Length( images ) = 1 then
              map[ class ]:= images[1];
            fi;
          od;

        fi;        # For j mod 4 in { 0, 1 } the map remains unchanged,
                   # since $g^p = h$ and $(gi)^p = hi^p = hi$ then.
      fi;
    od;

    # if we want the isoclinic table of a Brauer table then
    # transfer the normal subgroup information to the regular classes,
    # and adjust the irreducibles

    if tbl <> arg[1] then

      reg:= CharTableRegular( isoclinic, arg[1].prime );
      factorfusion:= GetFusionMap( reg, isoclinic );
      reg.irreducibles:= Copy( arg[1].irreducibles );
      center:= Position( factorfusion, center );
      outer:= Filtered( [ 1 .. Length( reg.centralizers ) ],
                        x -> factorfusion[x] in outer );

      for chi in Filtered( reg.irreducibles,
                           x -> x[ center ] <> x[1] ) do
        for class in outer do
          chi[ class ]:= i * chi[ class ];
        od;
      od;
  
      isoclinic:= reg;

    fi;

    # adjust the table name
    isoclinic.identifier:= Concatenation( "Isoclinic(",
                                          arg[1].identifier, ")" );

    # return the result
    return isoclinic;
    end;


#############################################################################
##
#V  Revision
##
##  This global variable is used throughout {\GAP}~4, and thus also in the
##  data files of the table library.
##
if not IsBound( Revision ) then
  Revision:= rec();
fi;


#############################################################################
##
#V  TABLEFILENAME
#V  LIBTABLE
##
TABLEFILENAME       := "";
LIBTABLE            := rec();
LIBTABLE.LOADSTATUS := rec();
LIBTABLE.clmelab    := [];
LIBTABLE.clmexsp    := [];


#############################################################################
##
#F  SET_TABLEFILENAME( <filename> )
##
SET_TABLEFILENAME := function( filename )
    TABLEFILENAME:= filename;
    LIBTABLE.( filename ):= rec();
end;


#############################################################################
##
#F  GALOIS( <chars>, <list> )
#F  TENSOR( <chars>, <list> )
##
##  are global variables used to store the library tables in compressed form.
##
##  The entry '[GALOIS,[<i>,<j>]]' in the 'irreducibles' or 'projectives'
##  component of a library table means the <j>-th Galois conjugate of
##  the <i>-th character.
##
##  The entry '[TENSOR,[<i>,<j>]]' in the 'irreducibles' or 'projectives'
##  component of a library table means the tensor product of the <i>-th
##  and the <j>-th character.
##
#F  EvalChars( <chars> )
##
##  replaces all entries of the form '[<func>,<list>]' in the list <chars>
##  by the result '<func>( <chars>, <list> )'.
##
GALOIS := function( chars, li )
    return List( chars[ li[1] ], x -> GaloisCyc( x, li[2] ) );
    end;

TENSOR := function( chars, list )
    local i, chi, psi, result;
    chi:= chars[ list[1] ];
    psi:= chars[ list[2] ];
    result:= [];
    for i in [ 1 .. Length( chi ) ] do result[i]:= chi[i] * psi[i]; od;
    return result;
    end;

EvalChars := function( chars )
    local i;
    for i in [ 1 .. Length( chars ) ] do
      if IsFunc( chars[i][1] ) then
        chars[i]:= chars[i][1]( chars, chars[i][2] );
      fi;
    od;
    end;


#############################################################################
##
#F  MBT( <arg> )
##
##  The library format of Brauer tables is a call to the function
##  'MBT', with the following arguments.
##
##   1. identifier of the table
##   2. field characteristic
##   3. text (list of lines)
##   4. block
##   5. defect
##   6. basic set
##   7. Brauer tree information
##   8. inverses of decomposition matrices restricted to basic sets
##   9. blocks of proper factor groups
##  10. list of generators for the group of table automorphisms
##  11. 2nd indicator (in characteristic 2 only)
##  12. (optional) record with additional components
##
MBT := function( arg )

    local i, record;

    record:= rec(
                  text          := arg[ 3],
                  prime         := arg[ 2],
                  block         := arg[ 4],
                  defect        := arg[ 5],
                  basicset      := arg[ 6],
                  brauertree    := arg[ 7],
                  decinv        := arg[ 8],
                  factorblocks  := arg[ 9],
                  automorphisms := arg[10],
                  indicator     := arg[11]
                 );

    for i in RecFields( record ) do
      if record.(i) = 0 then
        Unbind( record.(i) );
      fi;
    od;
    if Length( arg ) = 12 then
      for i in RecFields( arg[12] ) do
        record.(i):= arg[12].(i);
      od;
    fi;
    LIBTABLE.( TABLEFILENAME ).(
                 Concatenation( arg[1], "mod", String( arg[2] ) ) ):= record;
    end;


#############################################################################
##
#F  MOT( <arg> )
##
##  The library format of ordinary character tables is a call to the function
##  'MOT', with the following arguments.
##
##   1. identifier of the table
##   2. text (list of lines)
##   3. list of centralizer orders
##   4. list of power maps
##   5. list of irreducibles
##   6. list of generators for the group of table automorphisms
##   7. (optional) construction of the table
##
##  Each fusion is added by 'ALF', any other component of the table must be
##  added individually via 'ARC( <identifier>, <compname>, <compval> )'.
##
##  'MOT' constructs a (preliminary) table record, and puts it into the
##  component 'TABLEFILENAME' of 'LIBTABLE'.
##  The 'fusionsource' and 'projections' are dealt with when the table is
##  constructed by 'CharTableLibrary'.
##  Admissible names are notified by 'ALN( <name>, <othernames> )'.
##
MOT := function( arg )

    local record, i;

    # Construct the table record.
    record:= rec(
                  text             := arg[2],
                  centralizers     := arg[3],
                  powermap         := arg[4],
                  fusions          := [],
                  irreducibles     := arg[5],
                  automorphisms    := arg[6]
                 );

    for i in RecFields( record ) do
      if record.(i) = 0 then
        Unbind( record.(i) );
      fi;
    od;
    if IsBound( arg[7] ) then
      record.construction:= arg[7];
    fi;

    # Store the table record.
    LIBTABLE.( TABLEFILENAME ).( arg[1] ):= record;
    end;


#############################################################################
##
#F  LowercaseString( <string> ) . . . string consisting of lower case letters
##
LowercaseString := function( str )

    local alp, ALP, result, i, pos;

    alp:= "abcdefghijklmnopqrstuvwxyz";
    ALP:= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    result:= "";
    for i in str do
      pos:= Position( ALP, i );
      if pos = false then
        Add( result, i );
      else
        Add( result, alp[ pos ] );
      fi;
    od;
    return result;
    end;


#############################################################################
##
#F  NotifyCharTableName( <firstname>, <newnames> )
##
##  notifies the new names in the list <newnames> for the library table with
##  first name <firstname>, if there is no other table yet for that some of
##  these names are admissible.
##
NotifyCharTableName := function( firstname, newnames )

    local lower,
          pos,
          pos2,
          name,
          j;

    if not ( IsString( firstname )
             and IsList( newnames ) and ForAll( newnames, IsString ) ) then
      Error( "<firstname> and entries in list <newnames> must be strings" );
    fi;
    if ForAny( [ 1 .. Length( firstname ) - 2 ],
               x -> firstname{ [ x .. x+2 ] } = "mod" ) then
      Error( "Brauer tables must not have explicitly given 'othernames'" );
    fi;
    pos:= Position( LIBLIST.firstnames, firstname );
    if pos = false then
      Error( "no GAP library table with first name '", firstname, "'" );
    fi;
    lower:= List( newnames, LowercaseString );
    if ForAny( lower, x -> x in LIBLIST.allnames ) then
      Error( "<newnames> must contain only new names" );
    fi;
    Append( LIBLIST.allnames, lower );
    Append( LIBLIST.position, List( lower, x -> pos ) );
    SortParallel( LIBLIST.allnames, LIBLIST.position );
    end;


#############################################################################
##
#F  NotifyCharTable( <firstname>, <filename>, <othernames> )
##
##  notifies a new ordinary table to the library.
##  This table has 'identifier' component <firstname>,
##  it is contained in the file with name <filename>, and
##  it is known to have also the names contained in the list <othernames>.
##
##  'NotifyCharTable' modifies the global variable 'LIBLIST' after having
##  checked that there is no other table yet with admissible name equal to
##  <firstname> or contained in <othernames>.
##
NotifyCharTable := function( firstname, filename, othernames )

    local len, pos;

    if not ( IsString( firstname ) and IsString( filename )
                                   and IsList( othernames ) ) then
      Error( "<firstname>, <filename> must be strings, ",
             "<othernames> must be a list" );
    fi;
    if LowercaseString( firstname ) in LIBLIST.allnames then
      Error( "'", firstname, "' is already a valid name" );
    fi;
    Add( LIBLIST.firstnames, firstname );
    if not filename in LIBLIST.files then
      Add( LIBLIST.files, filename );
    fi;
    len:= Length( LIBLIST.firstnames );
    LIBLIST.filenames[ len ]:= Position( LIBLIST.files, filename );
    LIBLIST.fusionsource[ len ]:= [];
    NotifyCharTableName( firstname, [ firstname ] );
    NotifyCharTableName( firstname, othernames );

    # Allow natural names.
#T !!
end;


#############################################################################
##
#F  LibInfoCharTable( <tblname> )
##
##  is a record with components 'firstName' and 'fileName', the former being
##  the 'identifier' component of the library table for that <tblname> is an
##  admissible name, and the latter being the name of the file in that the
##  table is stored;
##  if no such table exists in the {\GAP} library then 'false' is returned.
##
##  If <tblname> contains the substring "mod" it is regarded as name of a
##  Brauer table, the first name is computed from that of the corresponding
##  ordinary table (which must exist) also if the library does not contain
##  the Brauer table.
##
LibInfoCharTable := function( tblname )

    local i, ordinfo, obj, pos;

    # Is 'tblname' the name of a Brauer table, i.e., has it the structure
    # '<ordname>mod<prime>' ?
    # If so, return '<firstordname>mod<prime>' where
    # '<firstordname> = LibInfoCharTable( <ordname> ).firstName'.

    tblname:= LowercaseString( tblname );
    for i in [ 1 .. Length( tblname ) - 2 ] do
      if tblname{ [ i .. i+2 ] } = "mod" then
        ordinfo:= LibInfoCharTable( tblname{ [ 1 .. i-1 ] } );
        if ordinfo <> false then
          Append( ordinfo.firstName, tblname{ [ i .. Length( tblname ) ] } );
          ordinfo.fileName[3]:= 'b';
        fi;
        return ordinfo;
      fi;
    od;

    # The name might belong to an ordinary table.
    pos:= PositionSorted( LIBLIST.allnames, tblname );
    if Length( LIBLIST.allnames ) < pos or
       LIBLIST.allnames[ pos ] <> tblname then
      pos:= false;
    fi;
    if pos <> false then
      pos:= LIBLIST.position[ pos ];
      if pos <> false then
        return rec( firstName := Copy( LIBLIST.firstnames[ pos ] ),
                    fileName  := Copy( LIBLIST.files[
                                             LIBLIST.filenames[ pos ] ] ) );
      fi;
      return false;
    fi;

    # The name might belong to a generic table.
    if tblname in LIBLIST.GENERIC.allnames then
      return rec( firstName := LIBLIST.GENERIC.firstnames[
                            Position( LIBLIST.GENERIC.allnames, tblname ) ],
                  fileName  := "ctgeneri" );
    fi;

    return false;
end;


#############################################################################
##
#F  FirstNameCharTable( <tblname> )
#F  FileNameCharTable( <tblname> )
##
FirstNameCharTable := function( name )
    name:= LibInfoCharTable( name );
    if name <> false then
      name:= name.firstName;
    fi;
    return name;
end;

FileNameCharTable := function( name )
    name:= LibInfoCharTable( name );
    if name <> false then
      name:= name.fileName;
    fi;
    return name;
end;


#############################################################################
##
#F  ALN( <name>, <names> )  . . . . . . . . . . . . . add library table names
##
ALN := NotifyCharTableName;


#############################################################################
##
#F  ALF( <from>, <to>, <map> ) . . . . . . . . . .  add library table fusions
#F  ALF( <from>, <to>, <map>, <text> )
##
ALF := function( arg )

    local pos;

    if ALN <> Ignore then

      # A file is read that does not belong to the official library.
      # Check that the names are valid.
      pos:= Position( LIBLIST.firstnames, arg[2] );
      if not arg[1] in RecFields( LIBTABLE.( TABLEFILENAME ) ) then
        Error( "source '", arg[1], "' is not stored in 'LIBTABLE.",
               TABLEFILENAME, "'" );
      elif pos = false then
        Error( "destination '", arg[2], "' is not a valid first name" );
      fi;

      # Check whether there was already such a fusion.
      if arg[1] in LIBLIST.fusionsource[ pos ] then
        Error( "there is already a fusion from '",
               arg[1], "' to '", arg[2], "'" );
      fi;

      # Store the fusion source.
      Add( LIBLIST.fusionsource[ pos ], arg[1] );

    fi;

    if Length( arg ) = 4 then
      Add( LIBTABLE.( TABLEFILENAME ).( arg[1] ).fusions,
           rec( name:= arg[2], map:= arg[3],
                text:= Concatenation( arg[4] ) ) );
    else
      Add( LIBTABLE.( TABLEFILENAME ).( arg[1] ).fusions,
           rec( name:= arg[2], map:= arg[3] ) );
    fi;
end;


#############################################################################
##
#F  ACM( <spec>, <dim>, <val> ) . . . . . . . . . . . . . add Clifford matrix
##
##  <spec> is one of "elab", "exsp".
##  <dim> is the dimension of the Clifford matrix,
##  <val> is the Clifford matrix itself.
##
ACM := function( spec, dim, val )
    spec:= LIBTABLE.( Concatenation( "clm", spec ) );
    if not IsBound( spec[ dim ] ) then
      spec[ dim ]:= [];
    fi;
    Add( spec[ dim ], val );
end;


#############################################################################
##
#F  ARC( <name>, <comp>, <val> ) . . . . . . . add component of library table
##
ARC := function( name, comp, val )
    LIBTABLE.( TABLEFILENAME ).( name ).( comp ):= val;
end;


#############################################################################
##
#F  ConstructMixed( <tbl>, <subname>, <factname>, <plan>, <perm> )
##
##  <tbl> is the table of a group $m.G.a$,
##  <subname> is the name of a subgroup $m.G$ which is a cyclic central
##  extension of the (not necessarily simple) group $G$,
##  <factname> is the name of the factor group $G.a$ of <tbl> where the
##  outer automorphisms $a$ (a group of prime order) acts nontrivially on
##  the central $m$.
##  Then the faithful characters of <tbl> are induced characters of $m.G$.
##
##  <plan> is a list of lists, each containing the numbers of characters of
##  $m.G$ that form an orbit under the action of $a$
##  (so the induction of characters is simulated).
##  <perm> is the permutation that must be applied to the list of characters
##  that is obtained on appending the faithful characters to the
##  inflated characters of the factor group.
##
##  Examples of tables where this is used to compress the library files are
##  the tables of $3.F_{3+}.2$ (subgroup $3.F_{3+}$, factor group $F_{3+}.2$)
##  and $6.Fi_{22}.2$ (subgroup $6.Fi_{22}$, factor group $2.Fi_{22}.2$).
##
ConstructMixed := function( tbl, sub, fact, plan, perm )

    local factfus,  # factor fusion from 'tbl' to 'fact'
          subfus,   # subgroup fusion from 'sub' to 'tbl'
          proj,     # projection map of 'subfus'
          irreds,   # list of irreducibles
          zero;     # list of zeros to be appended to the characters

    fact    := CharTable( fact );
    sub     := CharTable( sub  );
    factfus := GetFusionMap( tbl, fact );
    subfus  := GetFusionMap( sub, tbl );
    proj    := ProjectionMap( subfus );
    irreds  := List( fact.irreducibles, x -> x{ factfus } );
    zero    := [ Maximum( subfus ) + 1 .. Length( tbl.centralizers ) ] * 0;
    Append( irreds, List( plan, entry ->
         Concatenation( Sum( sub.irreducibles{ entry } ){ proj }, zero ) ) );
    tbl.irreducibles:= Permuted( irreds, perm );
    end;


#############################################################################
##
#F  ConstructProj( <tbl>, <irrinfo> )
##
##  constructs irreducibles for projective tables from projectives of
##  a factor group table.
##
ConstructProj := function( tbl, irrinfo )
    local i, j, factor, fus, mult, irreds, linear, omegasquare, I,
          d, name, factfus, proj, adjust, Adjust,
          ext, lin, chi, faith, nccl, partner, divs, prox, foll,
          vals;

    nccl:= Length( tbl.centralizers );
    factor:= CharTable( irrinfo[1][1] );
    fus:= GetFusionMap( tbl, factor );
    mult:= tbl.centralizers[1] / factor.centralizers[1];
    irreds:= List( factor.irreducibles, x -> x{ fus } );
    linear:= Filtered( irreds, x -> x[1] = 1 );
    linear:= linear{ [ 2 .. Length( linear ) ] };

    # some roots of unity
    omegasquare:= E(3)^2;
    I:= E(4);

    # Loop over the divisors of 'mult' (a divisor of 12).
    # Note the succession for 'mult = 12'!
    if mult <> 12 then
      divs:= Difference( DivisorsInt( mult ), [ 1 ] );
    else
      divs:= [ 2, 4, 3, 6, 12 ];
    fi;

    for d in divs do

      # Construct the faithful irreducibles for an extension by 'd'.
      # For that, we split and adjust the portion of characters (stored
      # on the small table 'factor') as if we would create this extension,
      # and then we blow up these characters to the whole table.

      name:= irrinfo[d][1];
      partner:= irrinfo[d][2];
      proj:= First( factor.projectives, x -> x.name = name );
      faith:= List( proj.chars, y -> y{ fus } );
      proj:= Copy( proj.map );

      if name = tbl.identifier then
        factfus:= [ 1 .. Length( tbl.centralizers ) ];
      else
        factfus:= First( tbl.fusions, x -> x.name = name ).map;
      fi;
      Add( proj, Length( factfus ) + 1 );    # for termination of loop
      adjust:= [];
      for i in [ 1 .. Length( proj ) - 1 ] do
        for j in [ proj[i] .. proj[i+1]-1 ] do
          adjust[ j ]:= proj[i];
        od;
      od;

      # now we have to multiply the values on certain classes 'j' with
      # roots of unity, dependent on the value of 'd'\:

      Adjust:= [];
      for i in [ 1 .. d-1 ] do
        Adjust[i]:= Filtered( [ 1 .. Length( factfus ) ],
                              x -> adjust[ factfus[x] ] = factfus[x] - i );
      od;

      # d =  2\:\ classes in 'Adjust[1]' multiply with '-1'
      # d =  3\:\ classes in 'Adjust[x]' multiply
      #                       with 'E(3)^x' for the proxy cohort,
      #                       with 'E(3)^(2*x)' for the follower cohort
      # d =  4\:\ classes in 'Adjust[x]' multiply
      #                       with 'E(4)^x' for the proxy cohort,
      #                       with '(-E(4))^x' for the follower cohort,
      # d =  6\:\ classes in 'Adjust[x]' multiply with '(-E(3))^x'
      # d = 12\:\ classes in 'Adjust[x]' multiply with '(E(12)^7)^x'
      #
      # (*Note* that follower cohorts of classes never occur in projective
      #  ATLAS tables ... )

      # determine proxy classes and follower classes\:

      if Length( linear ) in [ 2, 5 ] then  # out in [ 3, 6 ]
        prox:= [];
        foll:= [];
        chi:= irreds[ Length( linear ) ];
        for i in [ 1 .. nccl ] do
          if chi[i] = omegasquare then
            Add( foll, i );
          else
            Add( prox, i );
          fi;
        od;
      elif Length( linear ) = 3 then        # out = 4
        prox:= [];
        foll:= [];
        chi:= irreds[2];
        for i in [ 1 .. nccl ] do
          if chi[i] = -I then Add( foll, i ); else Add( prox, i ); fi;
        od;
      else
        prox:= [ 1 .. nccl ];
        foll:= [];
      fi;

      if d = 2 then
        # special case without Galois partners
        for chi in faith do
          for i in Adjust[1] do chi[i]:= - chi[i]; od;
          Add( irreds, chi );
          for lin in linear do
            ext:= List( [ 1 .. nccl ], x -> lin[x] * chi[x] );
            if not ext in irreds then Add( irreds, ext ); fi;
          od;
        od;
      elif d = 12 then
        # special case with three Galois partners and 'lin = []'
        vals:= [ E(12)^7, - omegasquare, - I, E(3), E(12)^11, -1,
                 -E(12)^7, omegasquare, I, -E(3), -E(12)^11 ];
        for j in [ 1 .. Length( faith ) ] do
          chi:= faith[j];
          for i in [ 1 .. 11 ] do
            chi{ Adjust[i] }:= vals[i] * chi{ Adjust[i] };
          od;
          Add( irreds, chi );
          for i in partner[j] do
            Add( irreds, List( chi, x -> GaloisCyc( x, i ) ) );
          od;
        od;
      else

        if d = 3 then
          Adjust{ [ 1, 2 ] }:= [ Union( Intersection( Adjust[1], prox ),
                                        Intersection( Adjust[2], foll ) ),
                                 Union( Intersection( Adjust[2], prox ),
                                        Intersection( Adjust[1], foll ) ) ];
          vals:= [ E(3), E(3)^2 ];
        elif d = 4 then
          Adjust{ [ 1, 3 ] }:= [ Union( Intersection( Adjust[1], prox ),
                                        Intersection( Adjust[3], foll ) ),
                                 Union( Intersection( Adjust[3], prox ),
                                        Intersection( Adjust[1], foll ) ) ];
          vals:= [ I, -1, -I ];
        elif d = 6 then
          vals:= [ -E(3), omegasquare, -1, E(3), - omegasquare ];
        fi;

        for j in [ 1 .. Length( faith ) ] do
          chi:= faith[j];
          for i in [ 1 .. d-1 ] do
            chi{ Adjust[i] }:= vals[i] * chi{ Adjust[i] };
          od;
          Add( irreds, chi );
          for lin in linear do
            ext:= List( [ 1 .. nccl ], x -> lin[x] * chi[x] );
            if not ext in irreds then Add( irreds, ext ); fi;
          od;
          chi:= List( chi, x -> GaloisCyc( x, partner[j] ) );
          Add( irreds, chi );
          for lin in linear do
            ext:= List( [ 1 .. nccl ], x -> lin[x] * chi[x] );
            if not ext in irreds then Add( irreds, ext ); fi;
          od;
        od;

      fi;
    od;
    tbl.irreducibles:= irreds;
end;


#############################################################################
##
#F  ConstructDirectProduct( <tbl>, <factors> )
#F  ConstructDirectProduct( <tbl>, <factors>, <permclasses>, <permchars> )
##
##  special case of a 'construction' call for a library table <tbl>\:
##
##  constructs a direct product of the tables described in the list
##  <factors>, stores all those of its record components in <tbl>
##  that are not yet bound in <tbl>.
##  The 'fusions' component of <tbl> will be enlarged by the fusions of the
##  direct product (factor fusions).
##
##  If the optional arguments <permclasses>, <permchars> are given then
##  classes and characters of the result are sorted accordingly.
##
ConstructDirectProduct := function( arg )

    local tbl, factors, t, i, fld;

    tbl:= arg[1];
    factors:= arg[2];
    t:= CharTableLibrary( factors[1] );
    for i in [ 2 .. Length( factors ) ] do
      t:= CharTableDirectProduct( t, CharTableLibrary( factors[i] ) );
    od;
    if 2 < Length( arg ) then
      SortClassesCharTable( t, arg[3] );
      SortCharactersCharTable( t, arg[4] );
      Unbind( t.permutation );
    fi;
    for fld in Difference( RecFields( t ), RecFields( tbl ) ) do
      tbl.( fld ):= t.( fld );
    od;
    if 1 < Length( factors ) then
      Append( tbl.fusions, t.fusions );
    fi;
end;


#############################################################################
##
#F  ConstructIsoclinic( <tbl>, <factors> )
#F  ConstructIsoclinic( <tbl>, <factors>, <nsg> )
##
ConstructIsoclinic := function( arg )

    local tbl, factors, t, i, fld;

    tbl:= arg[1];
    factors:= arg[2];
    t:= CharTableLibrary( factors[1] );
    for i in [ 2 .. Length( factors ) ] do
      t:= CharTableDirectProduct( t, CharTableLibrary( factors[i] ) );
    od;
    if Length( arg ) = 2 then
      t:= CharTableIsoclinic( t );
    else
      t:= CharTableIsoclinic( t, arg[3] );
    fi;
    for fld in RecFields( t ) do
      if not IsBound( tbl.( fld ) ) then
        tbl.( fld ):= t.( fld );
      fi;
    od;
end;


#############################################################################
##
#F  ConstructV4G( <tbl>, <facttbl>, <aut>[, <ker>] )
##
##  Let <tbl> be the character table of a group of type $2^2.G$
##  where an outer automorphism of order 3 permutes the three involutions
##  in the central $2^2$.
##  Let <aut> be the permutation of classes of <tbl> induced by that
##  automorphism, and <facttbl> the name of the character table
##  of the factor group $2.G$.
##  Then 'ConstructV4G' constructs the irreducible characters of <tbl> from
##  that information.
##
ConstructV4G := function( arg )

    local tbl, facttbl, aut, ker, fus, chars;

    tbl:= arg[1];
    facttbl:= arg[2];
    aut:= arg[3];
    ker:= 2;
    if Length( arg ) = 4 then
      ker:= arg[4];
    fi;

    fus:= First( tbl.fusions, fus -> fus.name = facttbl ).map;
    ker:= Position( fus, ker );
    facttbl:= CharTable( facttbl );
    tbl.irreducibles:= Restricted( facttbl.irreducibles, fus );
    chars:= List( Filtered( tbl.irreducibles, x -> x[1] <> x[ ker ] ),
                  x -> Permuted( x, aut ) );
    Append( tbl.irreducibles, chars );
    Append( tbl.irreducibles, List( chars, x -> Permuted( x, aut ) ) );
end;


#############################################################################
##
#F  ConstructGS3( <tbls3>, <tbl2>, <tbl3>, <ind2>, <ind3>, <ext>, <perm> )
##
##  constructs the irreducibles of a table <tbls3> of type $G.S_3$ from the
##  tables <tbl2> and <tbl3> of $G.2$ and $G.3$, respectively.
##  <ind2> is a list of numbers denoting irreducibles of <tbl2>.
##  <ind3> is a list of pairs, each denoting irreducibles of <tbl3>.
##  <ext>  is a list of pairs, each denoting one irreducible of <tbl2>
##                             and one of <tbl3>.
##  <perm> is a permutation that must be applied to the irreducibles.
##
ConstructGS3 := function( tbls3, tbl2, tbl3, ind2, ind3, ext, perm )

    local fus2,       # fusion map 'tbl2' in 'tbls3'
          fus3,       # fusion map 'tbl3' in 'tbls3'
          proj2,      # projection $G.S3$ to $G.2$
          pos,        # position in 'proj2'
          proj2i,     # inner part of projection $G.S3$ to $G.2$
          proj2o,     # outer part of projection $G.S3$ to $G.2$
          proj3,      # projection $G.S3$ to $G.3$
          zeroon2,    # zeros for part of $G.2 \setminus G$ in $G.S_3$
          irr,        # irreducible characters of 'tbls3'
          i,          # loop over 'ind2'
          pair,       # loop over 'ind3' and 'ext'
          chi,        # character
          chii,       # inner part of character
          chio;       # outer part of character

    tbl2:= CharTable( tbl2 );
    tbl3:= CharTable( tbl3 );

    fus2:= GetFusionMap( tbl2, tbls3 );
    fus3:= GetFusionMap( tbl3, tbls3 );

    proj2:= ProjectionMap( fus2 );
    pos:= First( [ 1 .. Length( proj2 ) ], x -> not IsBound( proj2[x] ) );
    proj2i:= proj2{ [ 1 .. pos-1 ] };
    pos:= First( [ pos .. Length( proj2 ) ], x -> IsBound( proj2[x] ) );
    proj2o:= proj2{ [ pos .. Length( proj2 ) ] };
    proj3:= ProjectionMap( fus3 );

    zeroon2:= Difference( [ 1 .. Length( tbls3.centralizers ) ], fus3 ) * 0;

    irr:= [];

    # Induce the characters given by 'ind2' from 'tbl2'.
    Append( irr, Induced( tbl2, tbls3, tbl2.irreducibles{ ind2 } ) );

    # Induce the characters given by 'ind3' from 'tbl3'.
    for pair in ind3 do
      chi:= Sum( pair, x -> tbl3.irreducibles[x] );
      Add( irr, Concatenation( chi{ proj3 }, zeroon2 ) );
    od;

    # Put the extensions from 'tbl' together.
    for pair in ext do
      chii:= tbl3.irreducibles[ pair[1] ]{ proj3 };
      chio:= tbl2.irreducibles[ pair[2] ]{ proj2o };
      Add( irr, Concatenation( chii,  chio ) );
      Add( irr, Concatenation( chii, -chio ) );
    od;

    # Permute the characters with 'perm'.
    irr:= Permuted( irr, perm );

    # Store the irreducibles.
    tbls3.irreducibles:= irr;
end;


#############################################################################
##
#F  ConstructPermuted( <tbl>, <libnam>[, <prmclasses>, <prmchars>] )
##
##  The library table <tbl> is completed with help of the library table with
##  name <libnam>, whose classes and characters must be permuted by the
##  permutations <prmclasses> and <prmchars>, respectively.
##
ConstructPermuted := function( arg )
    local tbl, t, fld, automorphisms, irredinfo, classtext, fusions,
          projectives;

    tbl:= arg[1];
    t := CharTableLibrary( arg[2] );
    for fld  in RecFields( t )  do
      if not IsBound( tbl.( fld ) ) then
        tbl.(fld) := t.(fld);
      fi;
    od;
    if IsBound( tbl.automorphisms ) then
      automorphisms:= tbl.automorphisms;
      Unbind( tbl.automorphisms );
    fi;
    if IsBound( tbl.irredinfo ) then
      irredinfo:= tbl.irredinfo;
      Unbind( tbl.irredinfo );
    fi;
    if IsBound( tbl.classtext ) then
      classtext:= tbl.classtext;
      Unbind( tbl.classtext );
    fi;
    if IsBound( tbl.fusions ) then
      fusions:= tbl.fusions;
      tbl.fusions:= [];
    fi;
    if IsBound( tbl.projectives ) then
      projectives:= tbl.projectives;
      Unbind( tbl.projectives );
    fi;
    if 2 < Length( arg ) then
      SortClassesCharTable( tbl, arg[3] );
    fi;
    if 3 < Length( arg ) then
      SortCharactersCharTable( tbl, arg[4] );
    fi;
    Unbind( tbl.permutation );
    if IsBound( automorphisms ) then
      tbl.automorphisms:= automorphisms;
    fi;
    if IsBound( irredinfo ) then
      tbl.irredinfo:= irredinfo;
    fi;
    if IsBound( classtext ) then
      tbl.classtext:= classtext;
    fi;
    if IsBound( fusions ) then
      tbl.fusions:= fusions;
    fi;
    if IsBound( projectives ) then
      tbl.projectives:= projectives;
    fi;
end;


#############################################################################
##
#F  ConstructFactor( <tbl>, <libnam>, <kernel> )
##
##  The library table <tbl> is completed with help of the library table with
##  name <libnam>, whose classes and characters must be permuted by the
##  permutations <prmclasses> and <prmchars>, respectively.
##
ConstructFactor := function( tbl, libnam, kernel )
    local t, fld;
    t:= CharTableFactorGroup( CharTableLibrary( libnam ), kernel );
    for fld  in RecFields( t )  do
      if not IsBound( tbl.( fld ) ) then
        tbl.(fld) := t.(fld);
      fi;
    od;
end;


#############################################################################
##
#F  ConstructSubdirect( <tbl>, <factors>, <choice> )
##
##  The library table <tbl> is completed with help of the table got from
##  taking the direct product of the tables with names in the list <factors>,
##  and then taking the table consisting of the classes in the list <choice>.
##
ConstructSubdirect := function( tbl, factors, choice  )
    local t, i, fld;
    t:= CharTableLibrary( factors[1] );
    for i in [ 2 .. Length( factors ) ] do
      t:= CharTableDirectProduct( t, CharTableLibrary( factors[i] ) );
    od;
    t:= CharTableNormalSubgroup( t, choice );
    for fld in RecFields( t ) do
      if not IsBound( tbl.( fld ) ) then
        tbl.( fld ):= t.( fld );
      fi;
    od;
end;


#############################################################################
##
#F  UnpackedCll( <cll> )
##
##  is a record with the components 'mat', 'inertiagrps', 'fusionclasses',
##  and perhaps 'libname'.
##  These are the only components used in the construction of library
##  character tables encoded by Clifford matrices.
##
##  The meaning of <cll> is the same as in 'CllToClf'.
##
UnpackedCll := function( cll )

    local l, clmlist,  # library list of the possible matrices
          clf,         # Clifford matrix record, result
          pi;          # permutation to sort library matrices

    # Initialize the Clifford matrix record.
    clf:= rec(
               inertiagrps   := cll[1], 
               fusionclasses := cll[2]
              );

    if Length( cll[2] ) = 1 then

      clf.mat:= [ [ 1 ] ];

    elif Length( cll[3] ) = 2 then

      # is already unpacked, for example dimension 2
      clf.mat:= cll[3];

    else

      # Fetch the matrix from the library.
      cll:= cll[3];
      clf.libname:= cll;
      l:= cll[2];
      clmlist:= LibraryTables( Concatenation( "clm", cll[1] ) );
      if clmlist = false or not IsBound( clmlist[l] ) then
        Error( "sorry, component <mat> not found in the library" );
      fi;

      clf.mat:= Copy( clmlist[l][ cll[3] ] );

      # Sort the rows and columns of the Clifford matrix
      # w.r.t. the explicitly given permutations.
      if IsBound( cll[4] ) then
        clf.mat:= Permuted( clf.mat, cll[4] );
      fi;
      if IsBound( cll[5] ) then
        pi:= cll[5];
        clf.mat:= List( clf.mat, x -> Permuted( x, pi ) );
      fi;

    fi; 

    return clf;
end;


#############################################################################
##
#F  CllToClf( <tbl>, <cll> )
##
##  is a Clifford matrix for the table <tbl>.
##  It is constructed from the list <cll> that contains
##  the following entries.
##  1. list of indices of inertia factors
##  2. list of classes fusing in the factor group
##  3. identification of the matrix,
##     either unbound (then the matrix has dimension <= 2)
##     or a list containing
##       a. string '"elab"' or '"exsp"'
##       b. size of the Clifford matrix
##       c. index in the library file
##       d. (optional) necessary permutation of columns
##     or a list containing
##       a. the Clifford matrix itself and
##       b. the column weights.
##  4. (case '"exsp"') a list with items of record 'splitinfos':
##       a. classindex
##       b. p
##       c. numclasses
##       d. root
##
CllToClf := function( tbl, cll )

    local Ti,          # 
          factor,      # character table of the factor group G/N
          i, nr,
          dim,         # dimension of the matrix
          clf,         # expanded record
          pos,
          map;

    Ti:= tbl.cliffordTable.Ti;
    factor:= Ti.tables[1]; 
    if not IsBound( factor.classnames ) then
      ClassNamesCharTable( factor );
    fi;

    nr:= cll[2][1];
    dim:= Length( cll[2] );

    # Decode 'cll'.
    clf:= UnpackedCll( cll );

    # Fill the Clifford matrix record.
    clf.nr     := nr;
    clf.size   := dim;
    clf.order  := factor.orders[nr];
    clf.orders := [ factor.orders[nr] ];
    clf.elname := factor.classnames[nr];
    clf.full   := true;

    # Compute the row weights $b_a = |C_{T_m/N}(gN)|$.
    clf.roww:= List( [ 1 .. dim ],
                     i -> Ti.tables[ cll[1][i] ].centralizers[ cll[2][i] ] );

    # Compute the column weights $m_k = |Cl_{G/N}(gN)| / |Cl_G(g_k)|$.
    pos:= 0;
    for map in Ti.fusions do
      pos:= pos + Number( map, x -> x < nr );
    od;
    clf.colw:= List( [ 1 .. dim ],
                     i -> tbl.classes[ pos+i ] / factor.classes[nr] );

#     if dim = 1 then
#       if IsBound( cll[4] ) then
#         clf.colw := [cll[4][2]];
#       else
#         clf.colw := [1];
# #T ??
#       fi;
#     elif dim = 2 then
# 
#         factor:= Ti.tables[ clf.inertiagrps[2] ]; 
#         if not IsCharTable( factor ) then
#           factor:= CharTableLibrary( factor );
#         fi;
# 
#         if IsBound( cll[4] )  then
#             if cll[4][1] = 0 then #not really splitted
#                 clf.colw := cll[4][2]*[1, clf.roww[1]/clf.roww[2]];
#                 clf.mat:= [[1,1],[clf.roww[1]/clf.roww[2],-1]];
#             else
#                 clf.colw := [ 1, cll[4][2]-1 ];
#                 clf.mat:= [[1,1],[cll[4][4]*clf.colw[2],-cll[4][4]]];
#             fi;
#         else
#             clf.colw := [1, clf.roww[1]/clf.roww[2]];
#             clf.mat:= [[1,1],[clf.colw[2],-1]];
# #T but this holds only for split cosets!
#         fi;
#     fi; 

    # Handle the special case of extraspecial groups.
    if Length( cll ) = 4 then
      clf.splitinfos:= rec( classindex := cll[4][1],
                            p          := cll[4][2] );
      if IsBound( cll[4][3] ) then 
        clf.splitinfos.numclasses:= cll[4][3];
      fi;
      if IsBound( cll[4][4] ) then 
        clf.splitinfos.root:= cll[4][4];
      fi;
    fi;

    return clf;
end;


#############################################################################
##
#F  ConstructClifford( <tbl>, <cliffordtable> )
##
##  constructs the irreducibles of the ordinary character table <tbl> from
##  the Clifford matrices stored in '<tbl>.cliffordTable'.
##
ConstructClifford := function( tbl, cliffordTable )
    local i, j, n,
          AnzTi,
          tables,
          ct,        # list of lists of relevant characters,
                     # one for each inertia factor group
          clmexp,
          clmat,
          matsize,
          grps,
          newct,     # the list of irreducibles of 'tbl'
          rowct,     # actual row
          colct,     # actual column
          eintr,
          chars,
          linear,
          chi,       # loop over a character list
          lin,
          new;

    # Decode the 'cliffordTable' component of 'tbl'.
    cliffordTable:= rec( Ti:= rec( fusions:= cliffordTable[1],
                                       tables := cliffordTable[2] ),
                             cliffordrecords:= cliffordTable[3] );
    cliffordTable.Ti.ident:= Copy( cliffordTable.Ti.tables );

    # Get the character tables of the inertia groups, 
    # and store the relevant list of characters.
    tables:= cliffordTable.Ti.tables;
    AnzTi:= Length( tables );
    ct:= [];
    for i in [ 1 .. AnzTi ] do
      if tables[i][1] = "projectives" then
        eintr:= CharTableLibrary( [ tables[i][2] ] );
      else
        eintr:= CharTableLibrary( tables[i] );
      fi;
      if eintr = false then
        Error( "table of inertia factor group '", tables[i],
               "' not in the library" );
      fi;
      if tables[i][1] = "projectives" then

        # We must multiply the stored projectives with all linear characters
        # of the factor group in order to get the full list.
        chars:= First( eintr.projectives, x -> x.name = tables[i][3] ).chars;
        ct[i]:= [];
        linear:= Filtered( eintr.irreducibles, x -> x[1] = 1 );
        n:= Length( eintr.irreducibles );
        for chi in chars do
          for lin in linear do
            new:= List( [ 1 .. n ], x -> chi[x] * lin[x] );
            if not new in ct[i] then
              Add( ct[i], new );
            fi;
          od;
        od;

      else
        ct[i]:= eintr.irreducibles;
      fi;
      tables[i]:= eintr;
    od;

    # Construct the matrix of irreducibles characters.
    newct := List( tbl.centralizers, x -> [] );
    colct := 0;

    for i in cliffordTable.cliffordrecords do

      # Get the necessary components of the 'i'-th Clifford matrix,
      # and multiply it with the character tables of inertia factor groups.

      clmexp  := UnpackedCll( i );
      clmat   := clmexp.mat;
      matsize := Length( clmat );
      grps    := clmexp.inertiagrps;

      # Loop over the columns of the matrix.
      for n in [ 1 .. matsize ] do

        rowct := 0;
        colct := colct + 1;

        # Loop over the inertia factor groups.
        for j in [ 1 .. AnzTi ] do
          for chi in ct[j] do
            rowct:= rowct + 1;
            newct[rowct][colct]:= Sum( Filtered( [ 1 .. matsize ],
                                                 r -> grps[r] = j ),
               x -> clmat[x][n] * chi[ clmexp.fusionclasses[x] ]);
          od;
        od;

      od;

    od;

    tbl.irreducibles := newct;
end;


#############################################################################
##
#F  BrauerTree( <decmat> )
##
##  returns the Brauer tree of the block <decmat> of a decomposition matrix,
##  if exists, and 'false' otherwise.
##
##  The decomposition matrix must consist of 0 and 1 if a Brauer tree exists.
##
BrauerTree := function( decmat )
    local i, j, brauertree, edge, len;

    if not ( IsMat( decmat )
             and ForAll( decmat, x -> ForAll( x, y -> y=0 or y=1 ) ) ) then
      Print( "#I BrauerTree: <decmat> is not decomposition matrix\n",
             "#I     of a block of cyclic defect\n");
      return false;
    fi;
    
    if decmat = [ [ 1 ] ] then return []; fi;
    
    brauertree:= [];
    for i in [ 1 .. Length( decmat[1] ) ] do

      # find the entries 1 in column 'i'
      edge:= [];
      for j in [ 1 .. Length( decmat ) ] do
        if decmat[j][i] = 1 then Add( edge, j ); fi;
      od;
      len:= Length( edge );

      # If 'len = 2', we have an ordinary edge of the tree; else this may
      # concern an exceptional character.
      
      if len = 2 then
        Add( brauertree, edge );
      else
        if Length( Set( decmat{ edge } ) ) <= 2 then

          # all or all but one ordinary irreducibles restrict identically
          Add( brauertree, edge );

        else
          Print( "#I BrauerTree: <decmat> is not decomposition",
                 " matrix\n",
                 "#I     of a block of cyclic defect\n");
          return false;
        fi;
      fi;
    od;
    return brauertree;
    end;


#############################################################################
##
#F  DecMat( <brauertree> )
##
##  Technically, a Brauer tree is a list <brauertree> where '<brauertree>[i]'
##  contains the positions of '1' in the 'i'-th column of the decomposition
##  matrix of the corresponding block.  So '<brauertree>[i]' has length 2 or
##  3 (in the case of exceptional characters).
##
##  'DecMat' returns the decomposition matrix of the block.
##
DecMat := function( brauertree )
    local i, j, max, decmat;
    max:= 1;
    for i in brauertree do max:= Maximum( max, Maximum(i) ); od;
    decmat:= NullMat( max, Length( brauertree ) );
    for i in [ 1 .. Length( brauertree ) ] do
      for j in brauertree[i] do decmat[j][i]:= 1; od;
    od;
    return decmat;
    end;


#############################################################################
##
#F  BasicSetBrauerTree( <brauertree> )
##
##  returns a basic set of the Brauer tree <brauertree>.
##  *Note* that this is a list of positions relative to the block, so it is
##  not compatible with the 'basicset' entries of Brauer tables.
##
BasicSetBrauerTree := function( brauertree )
    local i, degrees, basicset, edge, elm;
    brauertree:= Set( brauertree );
    basicset:= [];

    # degrees of the vertices
    degrees:= [];
    for edge in brauertree do
      for i in edge do
        if not IsBound( degrees[i] ) then
          degrees[i]:= 1;
        else
          degrees[i]:= degrees[i] + 1;
        fi;
      od;
    od;
 
    while brauertree <> [] do

      # take a vertex of degree 1, remove its edge, adjust 'degrees'
      elm:= Position( degrees, 1 );
      AddSet( basicset, elm );
      edge:= First( brauertree, x -> elm in x );
      RemoveSet( brauertree, edge );
      for i in edge do
        degrees[i]:= degrees[i] - 1;
      od;
    od;

    return basicset;
    end;


#############################################################################
##
#F  AddDecMats( <tbl> )
##
##  stores decomposition matrices of blocks in the 'block' component of
##  the Brauer table <tbl>
##
AddDecMats := function( tbl )
    local fus, block, ordchars, modchars;
    if not IsBound( tbl.blocks ) then
      Error( "<tbl> must be a Brauer table" );
    fi;
    fus:= GetFusionMap( tbl, tbl.ordinary );
    for block in tbl.blocks do
      if block.defect = 0 then
        block.decmat:= [ [ 1 ] ];
      else
        ordchars:= tbl.ordinary.irreducibles{ block.ordchars }{ fus };
        modchars:= tbl.irreducibles{ block.modchars };
        block.decmat:= Decomposition( modchars, ordchars, "nonnegative" );
      fi;
    od;
    end;


#############################################################################
##
#F  PartsBrauerTableName( <modname> )
##
##  returns a record with components 'ordname' (substring up to the
##  occurrence of 'mod' in <modname>) and 'prime' (the integer of the string
##  after 'mod').
##
PartsBrauerTableName := function( modname )

    local i, primestring, ordname, prime, digits;

    primestring:= 0;
    for i in [ 1 .. Length( modname ) - 2 ] do
      if modname{ [ i .. i + 2 ] } = "mod" then
        primestring:= modname{ [ i + 3 .. Length( modname ) ] };
        ordname:= modname{ [ 1 .. i-1 ] };
      fi;
    od;
    if primestring = 0 then
      Print( "#I PartsBrauerTableName: ", modname,
             " is no valid name\n",
             "#I      for a Brauer table\n" );
      return false;
    fi;
    
    digits:= "0123456789";
    primestring:= List( primestring, x -> Position( digits, x ) );
    if false in primestring then
      Print( "#I PartsBrauerTableName: ", modname,
             " is no valid name\n",
             "#I      for a Brauer table\n" );
      return false;
    fi;
    prime:= 0;
    for i in [ 1 .. Length( primestring ) ] do
      prime:= 10 * prime + ( primestring[i] - 1 );
    od;
    
    return rec( ordname:= ordname, prime:= prime );
    end;


#############################################################################
##
#F  BrauerTable( <name>, <ordtbl> )
##
##  returns the Brauer table with name <name>.
##  <ordtbl> is the corresponding ordinary table.
##
BrauerTable := function( name, ordtbl )

    local libtbl, i, j, ord, pow, reg, result, ordblocks, modblocks,
          defect, prime, irreducibles, restricted, block, basicset,
          class, images, chi, gal, newimages, pos, im, decmat,
          brauertree, filename, facttbl, offset, decinv,
          filename, fld;
    
    filename:= LibInfoCharTable( name ).fileName;
    fld:= LibraryTables( filename );

    if fld = false or not IsBound( fld.( name ) ) then
      Print("#E CharTable: no library table with name '",name,"'\n");
      return false;
    fi;
    libtbl:= Copy( fld.( name ) );
    libtbl.identifier:= name;

    reg:= CharTableRegular( ordtbl, libtbl.prime );
    prime:= libtbl.prime;

    result:= rec(
                  identifier    := libtbl.identifier,
                  text          := libtbl.text,
                  prime         := libtbl.prime,
    
                  size          := reg.size,
                  centralizers  := reg.centralizers,
                  orders        := reg.orders,
                  classes       := reg.classes,
                  powermap      := reg.powermap,
                  fusions       := [ rec( name:= ordtbl.identifier,
                                          map := GetFusionMap( reg, ordtbl ),
                                          type:= "choice" ) ],
    
                  irreducibles  := [],
                  irredinfo     := [],
                  blocks        := [],
                  ordinary      := ordtbl,
                  operations    := BrauerTableOps          );

    result.order:= result.size;
    result.name:= result.identifier;

#T just a hack ...
    result.defect:= libtbl.defect;
    result.block:= libtbl.block;
    if IsBound( libtbl.decinv ) then
      result.decinv:= libtbl.decinv;
    fi;
    if IsBound( libtbl.basicset ) then
      result.basicset:= libtbl.basicset;
    fi;
    if IsBound( libtbl.brauertree ) then
      result.brauertree:= libtbl.brauertree;
    fi;
#T end of the hack ...

    # if automorphisms are stored (as list of generators), convert to group
    if IsBound( libtbl.automorphisms ) then
      result.automorphisms:= Group( libtbl.automorphisms, () );
    fi;

    # complete the name change of 'reg'
    RemoveSet( ordtbl.fusionsource, reg.identifier );
    AddSet( ordtbl.fusionsource, libtbl.identifier );
        
    # initialize some components
    if not IsBound( libtbl.decinv ) then libtbl.decinv:= []; fi;

    block:= [];
    defect:= [];
    basicset:= [];
    brauertree:= [];
    decinv:= [];

    # If the distribution to blocks is stored on the table
    # then use it, otherwise compute it.
    ordblocks:= ordtbl.irredinfo;
    if     IsBound( ordblocks[1].pblock )
       and IsBound( ordblocks[1].pblock[ prime ] ) then
      ordblocks:= List( ordblocks, x -> x.pblock[ prime ] );
    else
      ordblocks:= PrimeBlocks( ordtbl, prime ).block;
    fi;
    ordblocks:= InverseMap( ordblocks );

    # get the blocks of factor groups if necessary;
    # 'factorblocks' is a list of pairs containing the names of the
    # tables that hold the blocks and the offset of basic set characters
    if IsBound( libtbl.factorblocks ) then

      for i in libtbl.factorblocks do
        facttbl:= Concatenation( i[1], "mod", String( libtbl.prime ) );
        if IsBound( LIBTABLE.( filename ).( facttbl ) ) then
          facttbl:= LIBTABLE.( filename ).( facttbl );
        else
          # The factor table is in another file (hopefully a rare case).
          facttbl:= CharTableLibrary( [ facttbl ] );
        fi;
        if block = [] then
          offset:= 0;
        else
          offset:= Maximum( block ) + 1 - Minimum( facttbl.block );
        fi;
        pos:= Length( defect );
        Append( defect, Copy( facttbl.defect ) );
        Append( block, offset + facttbl.block );
        for j in [ 1 .. Length( facttbl.defect ) ] do
          if facttbl.defect[j] <> 0 then
            if IsBound( facttbl.decinv ) and
               IsBound( facttbl.decinv[j] ) then
              if IsInt( facttbl.decinv[j] ) then
                decinv[ pos + j ]:=
                         Copy( facttbl.decinv[ facttbl.decinv[j] ] );
              else
                decinv[ pos + j ]:= Copy( facttbl.decinv[j] );
              fi;
              brauertree[ pos + j ]:= false;
              basicset[ pos + j ]:= i[2] + facttbl.basicset[j];
            else
              if IsInt( facttbl.brauertree[j] ) then
                brauertree[ pos + j ]:=
                      Copy( facttbl.brauertree[ facttbl.brauertree[j] ] );
              else
                brauertree[ pos + j ]:= facttbl.brauertree[j];
              fi;
              basicset[ pos + j ]:= ordblocks[ pos + j ]{
                            BasicSetBrauerTree( brauertree[ pos + j ] ) };
            fi;
          fi;
        od;
      od;

    fi;

    pos:= Length( defect );
    Append( defect, libtbl.defect );
    Append( block, libtbl.block );
    for j in [ 1 .. Length( libtbl.defect ) ] do
      if libtbl.defect[j] <> 0 then
        if IsBound( libtbl.decinv[j] ) then
          if IsInt( libtbl.decinv[j] ) then
            decinv[ pos + j ]:= Copy( libtbl.decinv[ libtbl.decinv[j] ] );
          else
            decinv[ pos + j ]:= Copy( libtbl.decinv[j] );
          fi;
          brauertree[ pos + j ]:= false;
          basicset[ pos + j ]:= libtbl.basicset[j];
        else
          if IsInt( libtbl.brauertree[j] ) then
            brauertree[ pos + j ]:=
                   Copy( libtbl.brauertree[ libtbl.brauertree[j] ] );
          else
            brauertree[ pos + j ]:= libtbl.brauertree[j];
          fi;
          basicset[ pos + j ]:= ordblocks[ pos + j ]{
                            BasicSetBrauerTree( brauertree[ pos + j ] ) };
        fi;
      fi;
    od;

    # compute the blocks and the irreducibles of each block,
    # and assign them to the right positions;
    # assign the known decomposition matrices and Brauer trees;
    # ignore defect 0 blocks
    irreducibles:= [];
    restricted:= Restricted( ordtbl, reg, ordtbl.irreducibles );

    modblocks := InverseMap( block );

    for i in [ 1 .. Length( ordblocks ) ] do

      if IsInt( ordblocks[i] ) then ordblocks[i]:= [ ordblocks[i] ]; fi;
      if IsInt( modblocks[i] ) then modblocks[i]:= [ modblocks[i] ]; fi;

      if defect[i] = 0 then
        irreducibles[ modblocks[i][1] ]:= restricted[ ordblocks[i][1] ];
        decinv[i]:= [ [1] ];
        basicset[i]:= ordblocks[i];
      else
     
        if IsBound( basicset[i] ) then
          if IsBound( brauertree[i] ) and brauertree[i] <> false then

            decinv[i]:= DecMat( brauertree[i]){
                             Filtered( [ 1 .. Length( ordblocks[i] ) ],
                                       x -> ordblocks[i][x] in basicset[i] )
                            }^(-1) ;
          fi;
          if IsBound( decinv[i] ) then
            block:= decinv[i] * restricted{ basicset[i] };
            for j in [ 1 .. Length( modblocks[i] ) ] do
              irreducibles[ modblocks[i][j] ]:= block[j];
            od;
          else
            Error( "at least one of the fields <decinv>, <brauertree> must",
                   " be bound at pos. ", i );
          fi;
        else
          Print( "#E BrauerTable: no basicset for block ", i, "\n" );
        fi;
      fi;

      result.blocks[i]:= rec( defect    := defect[i],
                              ordchars  := ordblocks[i],
                              modchars  := modblocks[i],
                              decinv    := decinv[i],
                              basicset  := basicset[i]  );
      if IsBound( brauertree[i] ) and brauertree[i] <> false then
        result.blocks[i].brauertree:= brauertree[i];
      fi;

    od;

    result.irreducibles:= irreducibles;
    
    # decode the 'irredinfo' field
    # (contains 2nd indicator if the prime is 2, else nothing)
    result.irredinfo:= List( result.irreducibles, x -> rec() );
    if IsBound( libtbl.indicator ) then
      for i in [ 1 .. Length( result.irredinfo ) ] do
        result.irredinfo[i].indicator:= [ , libtbl.indicator[i] ];
      od;
    fi;
    
#T BAD HACK until incomplete tables disappeared ...
    if IsBound( libtbl.warning ) then
      Print( "#W warning for table of '", libtbl.identifier, "':\n",
             libtbl.warning, "\n" );
    fi;

    return result;
    end;


#############################################################################
##
#F  LibraryTables( <filename> )
##
LibraryTables := function( filename )

    local file;

    if not IsBound( LIBTABLE.LOADSTATUS.( filename ) )
       or LIBTABLE.LOADSTATUS.( filename ) = "unloaded" then

      # It is necessary to read a library file.
      # First unload all files which are not '"userloaded"', except that
      # with the ordinary resp. Brauer tables corresponding to those in
      # the file 'filename'
      for file in RecFields( LIBTABLE.LOADSTATUS ) do
        if LIBTABLE.LOADSTATUS.( file ) <> "userloaded" and
           filename{ [ 4 .. Length( filename ) ] }
            <> file{ [ 4 .. Length( file ) ] } then
          LIBTABLE.( file ):= rec();
          LIBTABLE.LOADSTATUS.( file ):= "unloaded";
        fi;
      od;

      # Try to read the file.
      LIBTABLE.( filename ):= rec();
      TABLEFILENAME:= filename;
#T allow to read files in other directories if the tables were notified there!
      if not ReadPath( TBLNAME, filename, ".tbl", "ReadTbl" ) then
        Print( "#E ReadTbl: no file with name '", filename,
               "' in the GAP table collection\n" );
        return false;
      fi;

      # Reset the load status.
      LIBTABLE.LOADSTATUS.( filename ):= "loaded";

    fi;

    return LIBTABLE.( filename );
    end;


#############################################################################
##
#F  CharTableLibrary( [ <tblname> ] )
##
##  returns the library table that is known to have name <tblname>,
##  if exists; otherwise 'false' is returned and a message is printed.
##
#F  CharTableLibrary( [ <series>, <parameters> ] )
##
##  returns the character table which is got from the generic table of the
##  series with name <series> by specialising with <parameters>, if these
##  parameters are admissible; otherwise 'false' is returned and a message
##  is printed.
##
CharTableLibrary := function( arglist )

    local i, j, tblname, firstname, filename, libtbl, fld, file,
          newirredinfo, info, pos, name, fus;

    if arglist = [] or not IsString( arglist[1] ) then

      Error( "usage: CharTableLibrary( [ <tblname> ] )\n",
             " resp. CharTableLibrary( [ <series>, <parameters> ] )" );

    elif Length( arglist ) = 1 then

      # 'CharTableLibrary( tblname )'
      tblname:= arglist[1];
      firstname:= LibInfoCharTable( tblname );
      if firstname = false then
        Print( "#E CharTableLibrary: no library table with name '",
               tblname, "'\n" );
        return false;
      fi;
      filename:= firstname.fileName;
      firstname:= firstname.firstName;

      if filename{ [ 1 .. 3 ] } = "ctb" then

        # Brauer table, call 'BrauerTable'
        # (First get the ordinary table.)
        return BrauerTable( firstname,
                  CharTable( PartsBrauerTableName( firstname ).ordname ) );

      fi;

      # ordinary or generic table

      fld:= LibraryTables( filename );

      if not IsBound( fld.( firstname ) ) then
        Print("#E CharTable: no library table with name '",tblname,"'\n");
        return false;
      fi;

      libtbl            := Copy( fld.( firstname ) );
      libtbl.identifier := firstname;
      libtbl.operations := CharTableOps;

      # If the table is a generic table, simply return it.
      if IsBound( libtbl.isGenericTable )
         and libtbl.isGenericTable = true then
        return libtbl;
      fi;

      # Concatenate the lines of the 'text' component.
   #  if IsBound( libtbl.text ) then
#T change back after comparison of the library!
      if IsBound( libtbl.text ) and IsString( libtbl.text[1] ) then
        libtbl.text:= Concatenation( libtbl.text );
      fi;

      # Store the fusion sources.
      pos:= Position( LIBLIST.firstnames, firstname );
      libtbl.fusionsource:= Copy( LIBLIST.fusionsource[ pos ] );

      # Evaluate characters encoded as '[GALOIS,[i,j]]' or '[TENSOR,[i,j]]'.
      if IsBound( libtbl.projectives ) then
        fld:= libtbl.projectives;
        libtbl.projectives:= [];
        for i in [ 1, 3 .. Length( fld ) - 1 ] do
          EvalChars( fld[i+1] );
          for fus in LIBLIST.projections do
            if fus[2] = firstname and fus[1] = fld[i] then
              Add( libtbl.projectives, rec(
                                            name  := fld[i],
                                            chars := fld[i+1],
                                            map   := fus[3]
                                           ) );
            fi;
          od;
        od;
      fi;

      # Obey the construction component.
      if IsBound( libtbl.construction ) then
#T changed!

        # There are tables whose construction component uses {\GAP}~4
        # features.
        # We circumvent these traps where possible.
        if ForAny( GAP_4_SPECIALS, pair -> libtbl.identifier = pair[1] ) then
          First( GAP_4_SPECIALS,
                 pair -> libtbl.identifier = pair[1] )[2]( libtbl );
        elif IsFunc( libtbl.construction ) then
          libtbl.construction( libtbl );
        else
          ApplyFunc(
              ValueGlobal( libtbl.construction[1] ),
              Concatenation( [ libtbl ],
                  libtbl.construction{ [ 2 ..  Length(
                      libtbl.construction ) ] } ) );
        fi;

      fi;

      # Maybe 'construction' destroyed the 'identifier' value \ldots
#T really?
      libtbl.identifier:= firstname;
      libtbl.name:= firstname;

      # initialize some components
      if not IsBound( libtbl.size ) then
        libtbl.size:= libtbl.centralizers[1];
      fi;
      libtbl.order:= libtbl.size;
      InitClassesCharTable( libtbl );
      if IsBound( libtbl.powermap ) and libtbl.powermap <> [] and
         not IsBound( libtbl.orders ) then
        libtbl.orders:= ElementOrdersPowermap( libtbl.powermap );
      fi;
      if not IsBound( libtbl.irreducibles ) then
        libtbl.irreducibles:= [];
      fi;
      if IsBound( libtbl.automorphisms ) 
         and IsList( libtbl.automorphisms ) then
        libtbl.automorphisms:= Group( libtbl.automorphisms, () );
      fi;

      # Evaluate characters encoded as '[GALOIS,[i,j]]' or '[TENSOR,[i,j]]'.
      EvalChars( libtbl.irreducibles );

      # if necessary, decode the irredinfo field
      # ('irredinfo' is then a record, its fields are lists, each element
      # a list of same length as 'irreducibles')
      if IsBound( libtbl.irredinfo ) then
        if IsRec( libtbl.irredinfo ) then
          newirredinfo:= List( libtbl.irreducibles, x -> rec() );
          for fld in RecFields( libtbl.irredinfo ) do
            info:= libtbl.irredinfo.( fld );
            for i in [ 1 .. Length( newirredinfo ) ] do
              newirredinfo[i].( fld ):= [];
            od;
            for i in [ 1 .. Length( info ) ] do
              for j in [ 1 .. Length( newirredinfo ) ] do
                if IsBound( info[i] ) then
                  newirredinfo[j].( fld )[i]:= info[i][j];
                fi;
              od;
            od;
          od;
          libtbl.irredinfo:= newirredinfo;
        fi;
      else
        libtbl.irredinfo:= List( libtbl.irreducibles, x -> rec() );
      fi;

      return libtbl;

    else

      if arglist[1] = "Quaternionic" and Length( arglist ) = 2
         and IsInt( arglist[2] ) then
        return CharTableQuaternionic( arglist[2] );

      elif arglist[1] = "GL" and Length( arglist ) = 3
           and IsInt( arglist[2] ) and IsInt( arglist[3] ) then

        # 'CharTable( GL, 2, q )'
        if arglist[2] = 2 then
          return CharTableSpecialized( CharTableLibrary(["GL2"]), arglist[3] );
        else
          Print( "#E CharTable: table of GL(", String( arglist[2] ),
                 ",q) not yet implemented." );
          return false;
        fi;

      elif arglist[1] = "SL" and Length( arglist ) = 3
           and IsInt( arglist[2] ) and IsInt( arglist[3] ) then

        # CharTable( SL, 2, q )
        if arglist[2] = 2 then
          if arglist[3] mod 2 = 0 then
            return CharTableSpecialized( CharTableLibrary(["SL2even"]),
                                         arglist[3] );
          else
            return CharTableSpecialized( CharTableLibrary(["SL2odd"]),
                                         arglist[3] );
          fi;
        else
          Print( "#E CharTableLibrary: table of SL(", String( arglist[2] ),
                 ",q) not yet implemented." );
          return false;
        fi;

      elif arglist[1] = "PSL" and Length( arglist ) = 3
           and IsInt( arglist[2] ) and IsInt( arglist[3] ) then

        # CharTable( PSL, 2, q )
        if arglist[2] = 2 then
          if arglist[3] mod 2 = 0 then
            return CharTableSpecialized( CharTableLibrary(["SL2even"]),
                                         arglist[3] );
          elif ( arglist[3] - 1 ) mod 4 = 0 then
            return CharTableSpecialized( CharTableLibrary(["PSL2even"]),
                                         arglist[3] );
          else
            return CharTableSpecialized( CharTableLibrary(["PSL2odd"]),
                                         arglist[3] );
          fi;
        else
          Print( "#E CharTableLibrary: table of PSL(", String( arglist[2] ),
                 ",q) not yet implemented." );
          return false;
        fi;

      elif arglist[1] = "GU" and Length( arglist ) = 3
           and IsInt( arglist[2] ) and IsInt( arglist[3] ) then

        # 'CharTable( GU, 3, q )'
        if arglist[2] = 3 then
          return CharTableSpecialized( CharTableLibrary(["GU3"]), arglist[3] );
        else
          Print( "#E CharTable: table of GU(", String( arglist[2] ),
                 ",q) not yet implemented." );
          return false;
        fi;

      elif arglist[1] = "SU" and Length( arglist ) = 3
           and IsInt( arglist[2] ) and IsInt( arglist[3] ) then

        # CharTable( SU, 3, q )
        if arglist[2] = 3 then
          return CharTableSpecialized( CharTableLibrary(["SU3"]),
                                         arglist[3] );
        else
          Print( "#E CharTableLibrary: table of SU(", String( arglist[2] ),
                 ",q) not yet implemented." );
          return false;
        fi;

      elif arglist[1] = "Suzuki" and Length( arglist ) = 2
           and IsInt( arglist[2] ) then
        if not Set( FactorsInt( arglist[2] ) ) = [2] then
          Print( "#E CharTable(\"Suzuki\",q): q must be a power of 2\n");
          return false;
        fi;
        return CharTableSpecialized( CharTableLibrary(["Suzuki"]),
             [arglist[2],2^((Length(FactorsInt(arglist[2]))+1)/2)] );

      else
        return
          CharTableSpecialized( CharTableLibrary([arglist[1]]), arglist[2] );
      fi;
    fi;
    end;


#############################################################################
##
#F  OfThose()
#F  IsSporadicSimple()
##
##  dummy functions for selection function
##
OfThose          := function( ) Error("this is just a dummy function" ); end;
IsSporadicSimple := function(G) Error("this is just a dummy function" ); end;
SchurCover  := function( ) Error("this is just a dummy function" ); end;
AutomorphismGroup
                := function( ) Error( "this is just a dummy function" ); end;


#############################################################################
##
#F  AllCharTableNames( )  . . . . . . all ordinary table names in the library
#F  AllCharTableNames( IsSimple, true )
#F  AllCharTableNames( IsSporadicSimple, true )
#F  AllCharTableNames( <func>, <val> )
#F  AllCharTableNames( ..., OfThose, AutomorphismGroup )
#F  AllCharTableNames( ..., OfThose, SchurCover )
#F  AllCharTableNames( ..., OfThose, <func> )  #  e.g. <func> = CharTable ???
##
##  selection function for {\GAP} library tables
##
AllCharTableNames := function( arg )

    local sporsimp, list, pos, i, t, pp, oft, funcs, resul,
          newlist, multinfo, autoinfo, simpinfo;

    if Length( arg ) = 0 then

      # all table names in the library
      return Copy( LIBLIST.firstnames );

    fi;

    # table names of sporadic simple groups
    # (sorted according to size)

    sporsimp:= LIBLIST.sporadicSimple;
    multinfo:= List( LIBLIST.simpleInfo, x -> x[1] );
    autoinfo:= List( LIBLIST.simpleInfo, x -> x[3] );
    simpinfo:= List( LIBLIST.simpleInfo, x -> x[2] );

    # initialize the names list;
    # supported up to now: special cases 'IsSimple', 'IsSporadicSimple'

    if   arg[1] = IsSimple and arg[2] = true then
      list:= Copy( simpinfo );
      pos:= 3;
    elif arg[1] = IsSporadicSimple and arg[2] = true then
      list:= sporsimp;
      pos:= 3;
    else
      list:= LIBLIST.firstnames;
      pos:= 1;
    fi;

    # now there are two possibilities:
    # Either one filters the actual list 'list',
    # or we reach an 'OfThose', so we replace each entry of 'list' by
    # the list of images under the mapping instruction after 'OfThose'
    while pos <= Length( arg ) do

       oft:= Position( arg, OfThose, pos - 1 );
       if oft = false then
         oft:= Length( arg ) + 1;
       fi;

       # filter between two 'OfThose' mappings
       funcs:= [];
       resul:= [];
       for i in [ pos, pos + 2 .. oft - 2 ] do
         Add( funcs, arg[  i  ] );
         Add( resul, arg[ i+1 ] );
       od;

       if funcs <> [] then
         newlist:= [];
         for i in list do
           t:= CharTable( i );
           if ForAll( [ 1 .. Length( funcs ) ],
                      x -> funcs[x]( t ) = resul[x] ) then
             Add( newlist, i );
           fi;
         od;
       else
         newlist:= list;
       fi;

       if Length( arg ) > oft then

         # mapping instruction 'OfThose',
         # supported special cases are
         # 'SchurCover', 'AutomorphismGroup'.
       
         list:= [];
       
         if   arg[ oft + 1 ] = SchurCover then
       
           for i in newlist do

             pp:= Position( simpinfo, i );
             if pp = false then
               Error( "no info about Schur multiplier of '", i,
                      "' stored" );
             fi;
             if multinfo[ pp ] = "" then
               Add( list, simpinfo[ pp ] );
             else
               Add( list, Concatenation( multinfo[ pp ], ".",
                                         simpinfo[ pp ] ) );
             fi;
       
           od;
       
         elif arg[ oft + 1 ] = AutomorphismGroup then
           
           for i in newlist do

             pp:= Position( simpinfo, i );
             if pp = false then
               Error( "no info about automorphism group of '", i,
                      "' stored" );
             fi;
             if autoinfo[ pp ] = "" then
               Add( list, simpinfo[ pp ] );
             else
               Add( list, Concatenation( simpinfo[ pp ], ".",
                                         autoinfo[ pp ] ) );
             fi; 

           od;
       
         else
       
           list:= [];
           for i in newlist do
             resul:= arg[ oft+1 ]( i );
             if   IsString( resul ) then
               Add( list, resul );
             elif ForAll( resul, IsString ) then
               UniteSet( list, resul );
             else
               Error( "<arg>[", oft+1, "] must return a (list of) strings" );
             fi;
           od;
       
         fi;  

       else

         list:= newlist;

       fi;

       pos:= oft + 2;

     od;

     return list;

     end;
#T change strategy: if necessary construct the character table once,
#T then trace it through the whole argument!


#############################################################################
##
#F  ShrinkClifford( <tbl> )
##
##  shrinks the cliffordtable in a compact form, the cliffordrecords are
##  changed to library version
##  in the library-chartable only cltbl.ident of the inertiagfactorgroups 
##  are stored. "ident" is bound in CliffordTable and should be correct.
##  the user is responsible for the correctness of "ident" himself
##
ShrinkClifford := function( tbl )

    local i, flds, cltbl;

    cltbl:= tbl.cliffordTable;
    cltbl.Ti.tables := cltbl.Ti.ident;

    cltbl.cliffordrecords:= [];

    for i in  [1..cltbl.size] do

      cltbl.cliffordrecords[i]:= ClfToCll( cltbl.(i) );
      Unbind( cltbl.(i) );

    od;

    Unbind( tbl.irreducibles);
    Unbind( cltbl.Ti.ident );
    Unbind( cltbl.Ti.expN );

    for flds in [ "name", "grpname", "elements", "isDomain", "operations",
                  "charTable", "size", "expN" ] do
      Unbind( cltbl.(flds) );
    od;
    end;


#############################################################################
##
#F  TextString( <text> )
##
##  returns a string that is printed as
##
##  [
##  "<line_1>\n",
##  "<line_1>\n",
##  ...
##  "<line_n>"
##  ]
##
##  where <line_i> is the <i>-th line of the output of 'Print( <text> )',
##  except that the doublequotes are escaped.
##
##  *Note* that the ']' is the last output character.
##
TextString := function( text )
    local str, start, stop, line, len, pos;
    str:=  "[\n\"";
    stop:= 1;
    len:= Length( text );
    while stop <= len do
      start:= stop;
      while stop <= len and text[stop] <> '\n' do
        stop:= stop + 1;
      od;
      line:= text{ [ start .. stop-1 ] };
      pos:= Position( line, '\"' );
      while pos <> false do
        line:= Concatenation( line{ [ 1 .. pos-1 ] },
               "\\\"", line{ [ pos+1 .. Length( line ) ] } );
        pos:= Position( line, '\"', pos + 1 );
      od;
      Append( str, line );
      if stop <= len then
        Append( str, "\\n\",\n\"" );
        stop:= stop+1;     # skip the '\n'
      fi;
    od;
    Append( str, "\"\n]" );
    return str;
    end;


#############################################################################
##
#F  BlanklessPrint( <obj> )
##
##  outputs <obj> without unnecessary blanks;
##
##  ('text' field and strings in a 'irreducibles' list are not treated
##   in a special way!)
##
BlanklessPrint := function( obj )
    local i, flds;
    if TYPE( obj ) = "string" then
      if '\n' in obj then
        Print( TextString( obj ) );
      else
        Print( "\"", obj, "\"" );
      fi;
    elif IsList( obj ) then
      Print( "[" );
      for i in [ 1 .. Length( obj ) - 1 ] do
        if IsBound( obj[i] ) then BlanklessPrint( obj[i] ); fi;
        Print( "," );
      od;
      if obj <> [] then BlanklessPrint( obj[ Length( obj ) ] ); fi;
      Print( "]" );
    elif IsRec( obj ) then
      Print( "rec(" );
      flds:= RecFields( obj );
      for i in [ 1 .. Length( flds ) - 1 ] do
        Print( flds[i], ":=" );
        BlanklessPrint( obj.( flds[i] ) );
        Print( ",\n" );
      od;
      if Length( flds  ) > 0 then
        i:= Length( flds );
        Print( flds[i], ":=" );
        BlanklessPrint( obj.( flds[i] ) );
      fi;
      Print( ")" );
    else
      Print( obj );
    fi;
    end;


#############################################################################
##
#F  ShrinkChars( <chars> )
##
##  returns the list corresponding to the list <chars> where
##
##  each '<chars>[<k>]' that is the tensor product of '<chars>[<i>]'
##  and a linear character '<chars>[j]' with $i, j \leq k$ is replaced by
##  the string '\"[TENSOR,[<i>,<j>]]\"', and
##
##  each '<chars>[<k>]' that is the <j>-th Galois conjugate of '<chars>[<i>]'
##  with $i \leq k$ is replaced by the string '\"[GALOIS,[<i>,<j>]]\"'.
##
##  (used by 'PrintToLib')
##
ShrinkChars := function( chars )
    local i, j, k, N, oldchars, linear, chi, fams, pos, ppos;

    linear:= Filtered( chars, x -> x[1] = 1 );
    fams:= GaloisMat( chars ).galoisfams;
    chars:=    ShallowCopy( chars );
    oldchars:= ShallowCopy( chars );

    if Length( linear ) > 1 then
      ppos:= List( linear, x -> Position( chars, x ) );
      for i in [ 1 .. Length( chars ) ] do
        chi:= chars[i];
        if not IsString( chi ) then
          for j in [ 1 .. Length( linear ) ] do
            pos:= Position( chars, Tensored( [ linear[j] ],[ chi ] )[1] );
            if pos <> false and pos > i and pos > ppos[j] then
              chars[ pos ]:= Concatenation( "\n[TENSOR,[",
                                  String(i),",",String( ppos[j] ),"]]");
            fi;
          od;
        fi;
      od;
    fi;

    for i in [ 1 .. Length( chars ) ] do
      if IsList( fams[i] ) then
        for j in [ 2 .. Length( fams[i][1] ) ] do
          if fams[i][1][j] <= Length( chars ) then
            chi:= chars[ fams[i][1][j] ];
            if not IsString( chi ) then
              N:= Lcm( List( chi, NofCyc ) );
              k:= First( [ 2..N ], x -> chi = List( oldchars[i],
                                                    y -> GaloisCyc(y,x) ) );
              chars[ fams[i][1][j] ]:=Concatenation("\n[GALOIS,[",
                                               String(i),",",String(k),"]]");
            fi;
          fi;
        od;
      fi;
    od;

    return chars;
    end;


#############################################################################
##
#F  ClfToCll( <clf> )
##
##  returns a list encoding the information in the Clifford matrix record
##  <clf>.
##  <clf> must contain the components 'mat', ...
##
##  See "CllToClf" for the meaning of the entries.
##
ClfToCll := function( clf )

    local p,       # position of the Clifford matrix clm in CLM[*]
          cll,     # compressed record
          clm,     # the pure Clifford matrix consisting of "mat" and "colw"
          clmlist, # list of stored cliffordrecords
          l,
          lname,   # name of item in the library 
          list,    #
          tr;

    # Check the input.
    if not IsRec( clf ) or
       not IsBound( clf.inertiagrps ) or
       not IsBound( clf.fusionclasses ) or
       not IsBound( clf.mat ) then
      Error( "<clf> must be record with components 'inertiagrps', 'mat' ",
             "and 'fusionclasses'" );
    fi;

    l:= Length( clf.mat[1] ); 
    cll:= [ clf.inertiagrps, clf.fusionclasses ];

    if IsBound( clf.splitinfos )  then 
      lname := "exsp";
      cll[4]:= [ clf.splitinfos.classindex, clf.splitinfos.p ];
      if IsBound( clf.splitinfos.numclasses ) then
        cll[4][3]:= clf.splitinfos.numclasses;
      fi;
      if IsBound( clf.splitinfos.root ) then
        cll[4][4]:= clf.splitinfos.root;
      fi;
    else
      lname := "elab"; 
    fi;

    if l = 2  then

      # Store the full matrix.
      cll[3]:= clf.mat;

    elif 2 < l then

      clm:= clf.mat;
      cll[3]:= clm;

      # Try to find the matrix in the library of Clifford matrices.
      clmlist := LibraryTables( Concatenation( "clm", lname ) );
      if not IsList( clmlist ) then
        Error( "#E ClfToCll: can't find library of Clifford matrices.\n" );
      fi;

      if IsBound( clmlist[l] ) then

        list:= clmlist[l];
        p:= Position( list, clm );
        if p <> false then

          # Just store the library code.
          cll[3]:= [ lname, l, p ];
          return cll;

        else

          # The matrix itself is not in the library.
          # Perhaps it is contained up to permutations of rows/columns,
          # in this case print an appropriate message.
          for p in [ 1 .. Length( list ) ] do

            tr:= TransformingPermutations( clm, list[p] );
            if tr <> false then

              # The matrix can be permuted to a library matrix.
              cll[3]:= [ lname, l, p ];
              if tr.rows <> () then
                cll[3][4]:= tr.rows^-1;
              fi;
              if tr.columns <> () then
                cll[3][5]:= tr.columns^-1;
              fi;
              return cll;

            fi;

          od;

          Print( "#I Clifford matrix not found in the library\n" );

# 'clm' not found in library, either because given libname is wrong or
# the matrix must be added first by an authorized person. 
# The order would be:
#           PrintClmsToLib( <file>, [clf] );

        fi;
      fi;
    fi;

    return cll;
    end;


#############################################################################
##
#F  PrintFusion( <name>, <fus> )
##
PrintFusion := function( name, fus )

    local i, linelen;

    linelen:= Length( name ) + Length( fus.name ) + 11;
    Print( "ALF(\"", name, "\",\"", fus.name, "\",[" );
    for i in [ 1 .. Length( fus.map ) - 1 ] do
      if linelen + Length( String( fus.map[i] ) ) + 1 < 75 then
        linelen:= linelen + Length( String( fus.map[i] ) ) + 1;
      else
        Print( "\n" );
        linelen:= Length( String( fus.map[i] ) ) + 1;
      fi;
      Print( fus.map[i], "," );
    od;
    i:= Length( fus.map );
    if linelen + Length( String( fus.map[i] ) ) + 1 < 75 then
      linelen:= linelen + Length( String( fus.map[i] ) ) + 1;
    else
      Print( "\n" );
      linelen:= Length( String( fus.map[i] ) ) + 1;
    fi;
    Print( fus.map[i], "]" );
    if IsBound( fus.text ) then
      Print( ",", TextString( fus.text ) );
    fi;
    Print( ");\n" );
    end;


#############################################################################
##
#F  PrintToLib( <file>, <tbl> )
##
##  prints the character table <tbl> in library format to the file
##  '<file>.tbl'; this is the filename relative to a directory given by
##  'TBLNAME'.
##
PrintToLib := function( file, tbl )

    local func;

    if not ( IsRec( tbl ) and IsBound( tbl.identifier ) ) then
      Error( "usage: PrintToLib( <file>, <tbl> ) for ",
             "character table record <tbl>" );
    fi;

    tbl:= ShallowCopy( tbl );

    # if 'file' has already extension '.tbl', remove this
    if Length( file ) > 3 and
      file{ [ Length( file ) - 3 .. Length( file ) ] } = ".tbl" then
      file:= file{ [ 1 .. Length( file ) - 4 ] };
    fi;

    func:= function( tbl )

    local flds,
          i, j,
          name,
          special, 
          chars,
          fusions,
          libinfo,
          maxes,
          fld, 
          info,
          newirredinfo,
          fus,
          names,
          linelen;

    name:= tbl.identifier;

    # header;
    # check whether the file name contains special characters

    if '.' in file then
      file:= Concatenation( "(\"", file, "\")" );
    fi;

    # Check whether the representative orders are redundant.
    if IsBound( tbl.powermap ) and tbl.powermap <> [] and
       IsBound( tbl.orders ) and
       tbl.orders = ElementOrdersPowermap( tbl.powermap ) then
      Unbind( tbl.orders );
    fi;
    if IsBound( tbl.size ) and tbl.size = tbl.centralizers[1] then
      Unbind( tbl.size );
    fi;

    if IsBound( tbl.fusions ) then
      fusions:= tbl.fusions;
    else
      fusions:= [];
    fi;
    if IsBound( tbl.libinfo ) then
      libinfo:= tbl.libinfo;
    else
      libinfo:= rec();
    fi;
    if IsBound( tbl.maxes ) then
      maxes:= tbl.maxes;
    else
      maxes:= [];
    fi;

    # Remove redundant components.
    for fld in [ "classes", "fusionsource", "group",
                 "inverse", "name", "operations", "order", "ordinary",
                 "projections", "projectionsource",
                 "fusions", "libinfo", "maxes" ] do
      Unbind( tbl.( fld ) );
    od;

    for fld in [ "irreducibles", "irredinfo", "decinv", "decmat" ] do
      if IsBound( tbl.( fld ) ) and tbl.( fld ) = [] then
        Unbind( tbl.( fld ) );
      fi;
    od;

    if IsBound( tbl.brauertree ) then
      for i in [ 1 .. Length( tbl.brauertree ) ] do
        if IsBound( tbl.brauertree[i] ) then
          if tbl.brauertree[i] = false then
            Unbind( tbl.brauertree[i] );
          else
            Unbind( tbl.basicset[i] );
          fi;
        fi;
      od;
      if tbl.basicset = [] then Unbind( tbl.basicset ); fi;
      if tbl.brauertree = [] then Unbind( tbl.brauertree ); fi;
    fi;

    # shrink the irreducibles and projectives
    if IsBound( tbl.irreducibles ) then
      if not IsBound( tbl.construction ) then   # maybe one prints a table
                                                # that is not evaluated by
                                                # 'CharTable' !
        EvalChars( tbl.irreducibles );
      fi;
      if IsMat( tbl.irreducibles ) then         # not list of projectives info
        tbl.irreducibles:= ShrinkChars( tbl.irreducibles );
      fi;
    fi;
    if IsBound( tbl.projectives ) then
      tbl.projectives:= Copy( tbl.projectives );
      for i in [ 1 .. Length( tbl.projectives ) ] do
        EvalChars( tbl.projectives[i].chars );
        tbl.projectives[i].chars:= ShrinkChars( tbl.projectives[i].chars );
      od;
    fi;

    # Shrink the Clifford records.
    if IsBound( tbl.cliffordTable ) then
      if IsBound( tbl.irreducibles ) then
        tbl.cliffordTable:= Copy( tbl.cliffordTable );
#T Shallow?
        ShrinkClifford( tbl );
      fi;
      if IsRec( tbl.cliffordTable ) then
        tbl.cliffordTable:= [ tbl.cliffordTable.Ti.fusions,
                              tbl.cliffordTable.Ti.tables,
                              tbl.cliffordTable.cliffordrecords ];
      fi;
    fi;

    # if necessary, encode the irredinfo component

    if IsBound( tbl.irredinfo ) and IsList( tbl.irredinfo ) then
      newirredinfo:= rec();
      for fld in RecFields( tbl.irredinfo[1] ) do
        newirredinfo.( fld ):= [];
        info:= tbl.irredinfo[1].( fld );
        for i in [ 1 .. Length( info ) ] do
          if IsBound( info[i] ) then
            newirredinfo.( fld )[i]:=
                         List( tbl.irredinfo, x -> x.( fld )[i] );
          fi;
        od;
      od;
      tbl.irredinfo:= newirredinfo;
    fi;

    # Replace 'automorphisms' by the generators list.
    if IsBound( tbl.automorphisms ) and IsGroup( tbl.automorphisms ) then
      tbl.automorphisms:= tbl.automorphisms.generators;
    fi;
    if IsBound( tbl.galomorphisms ) and IsGroup( tbl.galomorphisms ) then
      tbl.galomorphisms:= tbl.galomorphisms.generators;
    fi;

    # special cases are 'irreducibles' and 'projectives' since
    # after the call of 'ShrinkChars' they may
    # contain strings which shall be printed without '"'

    special:= function( chars )
    local j;
    Print( "[" );
    for j in [ 1 .. Length( chars ) - 1 ] do
      if IsBound( chars[j] ) then
        if IsString( chars[j] ) then
          Print( chars[j] );            # strip the '"'
        else
          BlanklessPrint( chars[j] );
        fi;
      fi;
      Print( "," );
    od;
    if chars <> [] then
      j:= Length( chars );
      if IsString( chars[j] ) then
        Print( chars[j] );                # strip the '"'
      else
        BlanklessPrint( chars[j] );
      fi;
    fi;
    Print( "]" );
    end;

    # Print the compulsory components.
    Print( "MOT(\"", tbl.identifier, "\",\n" );
    if IsBound( tbl.text ) then
      Print( TextString( tbl.text ), ",\n" );
    else
      Print( "0,\n" );
    fi;
    if IsBound( tbl.centralizers ) then
      BlanklessPrint( tbl.centralizers );
      Print( ",\n" );
    else
      Print( "0,\n" );
    fi;
    if IsBound( tbl.powermap ) then
      BlanklessPrint( tbl.powermap );
      Print( ",\n" );
    else
      Print( "0,\n" );
    fi;
    if IsBound( tbl.irreducibles ) then
      special( tbl.irreducibles );
      Print( ",\n" );
    else
      Print( "0,\n" );
    fi;
    if IsBound( tbl.automorphisms ) then
      BlanklessPrint( tbl.automorphisms );
    else
      Print( "0" );
    fi;
    if IsBound( tbl.construction ) then
#T changed!
      if   tbl.construction = ConstructDirectProduct then
        Print( ",\nConstructDirectProduct" );
      elif tbl.construction = ConstructClifford then
        Print( ",\nConstructClifford" );
      else
        Print( ",\n", tbl.construction );
      fi;
# better more careful!
    fi;
    Print( ");\n" );

    Unbind( tbl.identifier    );
    Unbind( tbl.text          );
    Unbind( tbl.centralizers  );
    Unbind( tbl.powermap      );
    Unbind( tbl.irreducibles  );
    Unbind( tbl.automorphisms );
    Unbind( tbl.construction  );

    # Print the optional components.
    flds:= RecFields( tbl );

    for fld in flds do

      Print( "ARC(\"", name, "\",\"", fld, "\"," );

      if fld = "projectives" then
        chars:= tbl.projectives;
        Print( "[" );
        for j in chars do
          Print( "\"", j.name, "\"," );
          special( j.chars );
          Print( "," );
        od;
        Print( "]" );
      else
        BlanklessPrint( tbl.( fld ) );
      fi;
      Print( ");\n" );

    od;

    # Write the fusion assignments to the file.
    if fusions <> [] then
      for fus in fusions do
        PrintFusion( name, fus );
      od;
    fi;

    # Write the names information to the file.
    if libinfo <> rec() then
      names:= [];
      if IsBound( libinfo.othernames ) then
        Append( names, libinfo.othernames );
      fi;
      if IsBound( libinfo.CASnames ) then
        Append( names, libinfo.CASnames );
      fi;
      if names <> [] then
        linelen:= Length( name ) + 8;
        Print( "ALN(\"", name, "\",[" );
        for i in [ 1 .. Length( names )-1 ] do
          if linelen + Length( names[i] ) + 3 < 77 then
            linelen:= linelen + Length( names[i] ) + 3;
          else
            Print( "\n" );
            linelen:= Length( names[i] ) + 3;
          fi;
          Print( "\"", names[i], "\"," );
        od;
        if linelen + Length( names[ Length( names ) ] ) + 5 >= 77 then
          Print( "\n" );
        fi;
        Print( "\"", names[ Length( names ) ], "\"]);\n" );
      fi;
    fi;

    # Write the 'maxes' information to the file.
    if maxes <> [] then
      linelen:= Length( name ) + 16;
      Print( "ARC(\"", name, "\",\"maxes\",[" );
      for i in [ 1 .. Length( maxes )-1 ] do
        if IsBound( maxes[i] ) then
          if linelen + Length( maxes[i] ) + 3 < 77 then
            linelen:= linelen + Length( maxes[i] ) + 3;
          else
            Print( "\n" );
            linelen:= Length( maxes[i] ) + 3;
          fi;
          Print( "\"", maxes[i], "\"," );
        else
          if linelen + 1 < 77 then
            linelen:= linelen + 1;
          else
            Print( "\n" );
            linelen:= 1;
          fi;
          Print( "," );
        fi;
      od;
      if linelen + Length( maxes[ Length( maxes ) ] ) + 5 >= 77 then
        Print( "\n" );
      fi;
      Print( "\"", maxes[ Length( maxes ) ], "\"]);\n" );
    fi;

    end;

    AppendTo( Concatenation( file, ".tbl" ), func( tbl ), "\n" );
    end;


################################################################################
##
#F  PrintClmsToLib( <file>, <clms> )
##
##   prints the cliffordmatrices in libraryversion in a list on the file <file>
##   which are not yet in the cliffordmatrix library or in this list
##
##   <clms> must be a cliffordtable or a list of cliffordrecords
##   if splitted, each cliffordrecord must contain "splitinfos",
##
PrintClmsToLib := function( filename, clms )

    local  ind, i, il, lclms, clm, size,
        l,      # clmname
        clmlist,# list of cliffordmatrices in the library
        lname, filename,# name of the file in the library
        ir,     # the internal record used here of the library
        found;  # whether the clm is already in the library

    if not( IsCliffordTable( clms ) or 
            IsList( clms ) and ForAll( clms, x-> IsBound( x.mat ) and 
                          IsBound( x.colw ) ) )  then
        Error( "usage: PrintClmsToLib( <file>, <clms> ) for a list ",
               "of cliffordrecords or a cliffordtable " ); 
    fi;

    if IsList( clms ) then lclms := Length( clms );
    else                   lclms := clms.size;
    fi;

    ir := [];
    for ind in [1..lclms] do
        if IsList( clms ) then clm := clms[ind];
        else       clm := clms.(ind);
        fi;

        size := 0; 
        if IsBound( clm.mat )  then size := Length( clm.mat[1] ); fi;

        if size = 0  then
            Print("#I PrintClmsToLib: no <mat> and <colw>. Nothing done.\n");
        elif  size > 2  then
            if IsBound( clm.splitinfos )  then
              lname := "exsp";
            else
              lname := "elab";
            fi;
            l := Concatenation( lname, String( size ));

            clmlist := LibraryTables( Concatenation( "clm", lname ) );
            found := false;
            if IsBound( clmlist[ size ] ) then
                i := 0;
                il := Length( clmlist[ size ] );
                while ( not found and i < il ) do
                    i := i+1;
                    found := clmlist[ size ][i][1] = clm.mat 
                         and clmlist[ size ][i][2] = clm.colw;
                od;
            fi;
            if not found and IsBound( ir[size] ) then
                i := 0;
                il := Length( ir[size] );
                while ( not found and i < il ) do
                    i := i+1;
                    found := ir[size][i][1] = clm.mat 
                         and ir[size][i][2] = clm.colw;
                od;
            fi;

            if not found then
                if IsBound( ir[size] )  then
                  ir[size][Length( ir[size] )+1] := 
                                         [clm.mat, clm.colw];
                else
                  ir[size] := [ [clm.mat, clm.colw] ];
                fi;
            else
                Print( "#I PrintClmsToLib: Matrix ", ind, 
                       " already in library or in ", filename, ".\n" );
            fi;
        fi;
    od;

    PrintTo( filename, ir, "\n" );

    return;
end;


#############################################################################
##                                                             
#F  OrbitsResidueClass( <pq>, <set> )
##
OrbitsResidueClass := function( pq, set )                   
    local gen,
          orbs,
          pnt,                                                         
          orb,                 
          i;                                                         

    # If `pq' is a pair `[ <p>, <q> ]' then take a residue class mod <p>
    # of order <q>.
    # If `pq' is a triple `[ <p>, <q>, <k> ]' then take the orbits of the
    # automorphism $\ast <k>$ modulo <p>, which is assumed to have order <q>.
    if Length( pq ) = 2 then
      gen:= PowerModInt( PrimitiveRootMod( pq[1] ), (pq[1]-1)/pq[2], pq[1] );
    else
      gen:= pq[3];
    fi;
    orbs:= [];
    while Length( set ) <> 0 do
      pnt:= set[1];
      orb:= [];                                                              
      for i in [ 1 .. pq[2] ] do
        orb[i]:= pnt;              
        pnt:= ( pnt * gen ) mod pq[1];
      od;                                                 
      Add( orbs, orb );
      SubtractSet( set, orb );
    od;
    return orbs;
end;


#############################################################################
##
#E

