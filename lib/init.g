#############################################################################
##
#W  init.g                      GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file initializes GAP.
##
Revision.init_g :=
    "@(#)$Id$";


#############################################################################
##

#F  Ignore( <arg> )
##
#T  1996/08/07 M.Schoenert 'Ignore' should be in the kernel
#T  1996/09/08 S.Linton    Do we need it at all?
##
Ignore := function ( arg )  end;


#############################################################################
##
##  Define some global variables
##
SetFilterObj := "2b defined";
infinity := "2b defined";


#############################################################################
##
#F  ReplacedString( <string>, <old>, <new> )
##
ReplacedString := function ( string, old, new )
    local  res,  i,  k,  l;
    res := [];
    k := 1;
    l := false;
    for i  in [1..LEN_LIST(string)]  do
        if string{[i..i+LEN_LIST(old)-1]} = old  then
            l := i;
        fi;
        if string[i] = ';'  then
            if l <> false  then
                APPEND_LIST_INTR( res, string{[k..l-1]} );
                APPEND_LIST_INTR( res, new );
                APPEND_LIST_INTR( res, string{[l+LEN_LIST(old)..i]} );
            else
                APPEND_LIST_INTR( res, string{[k..i]} );
            fi;
            k := i + 1;
            l := false;
        fi;
    od;
    if l <> false  then
        APPEND_LIST_INTR( res, string{[k..l-1]} );
        APPEND_LIST_INTR( res, new );
        APPEND_LIST_INTR( res, string{[l+LEN_LIST(old)..LEN_LIST(string)]} );
    else
        APPEND_LIST_INTR( res, string{[k..LEN_LIST(string)]} );
    fi;
    return res;
end;


#############################################################################
##

#F  ReadPath( <path>, <name>, <ext>, <infomsg> )
##
READ_INDENT := "";

if not IsBound( InfoRead1 )  then InfoRead1 := Ignore;  fi;
if not IsBound( InfoRead2 )  then InfoRead2 := Ignore;  fi;

ReadPath := function ( path, name, ext, infomsg )
    local   readIndent, i, k, file, found;

    readIndent := SHALLOW_COPY_OBJ( READ_INDENT );
    APPEND_LIST_INTR( READ_INDENT, "  " );
    InfoRead1( "#I",READ_INDENT,infomsg,"( \"", name, "\" )\n" );
    i := 1;
    found := false;
    while not found  and i <= LEN_LIST(path)+1 do
        k := POS_LIST( path, ';', i-1 );
        if k = FAIL  then k := LEN_LIST(path)+1;  fi;
        file := path{[i..k-1]};
        APPEND_LIST_INTR( file, name );
        APPEND_LIST_INTR( file, ext );
        InfoRead2("#I  trying '",file,"'\n");
        found := READ( file );
        i := k + 1;
    od;
    READ_INDENT := readIndent;
    if found and READ_INDENT = ""  then
        InfoRead1( "#I  ",infomsg,"( \"", name, "\" ) done\n" );
    fi;
    return found;
end;


#############################################################################
##
#F  Read( <name> )
##
Read := function ( name )
    if not ReadPath( "", name, "", "Read" )  then
        Error("the file '",name,"' must exist and be readable");
    fi;
end;


#############################################################################
##

#V  LIBNAME
##
##  is exported from the kernel


#############################################################################
##
#F  ReadLib( <name> )
##
##  'ReadLib'  reads  in a  file  named  <name>,  this  name must include  an
##  extension.  The file must also define 'Revision.<name_ext>'.
##
ReadLib := function ( name )
    local   ext;

    if not ReadPath( LIBNAME, name, "", "ReadLib" )  then
        Error("the library file '",name,"' must exist and be readable");
    fi;
    ext := ReplacedString( name, ".", "_" );
    if not IsBound(Revision.(ext))  then
        Print( "#W  revision entry missing in \"", name, "\"\n" );
    fi;
end;


#############################################################################
##
#V  GRPNAME
##
GRPNAME := ReplacedString( LIBNAME, "lib", "grp" );
if GRPNAME = "./"  then GRPNAME := "../grp/";  fi;


#############################################################################
##
#F  ReadGrp( <name> )
##
ReadGrp := function ( name )
    local   ext;

    if not ReadPath( GRPNAME, name, "", "ReadGrp" )  then
        Error("the group file '",name,"' must exist and be readable");
    fi;
    ext := ReplacedString( name, ".", "_" );
    if not IsBound(Revision.(ext))  then
        Print( "#W  revision entry missing in \"", name, "\"\n" );
    fi;
end;


#############################################################################
##
#V  TBLNAME
##
TBLNAME := ReplacedString( LIBNAME, "lib", "tbl" );
if TBLNAME = "./"  then TBLNAME := "../tbl/";  fi;


#############################################################################
##
#F  ReadTbl( <name> )
##
ReadTbl := function ( name )
    local   ext;

    if not ReadPath( TBLNAME, name, ".tbl", "ReadTbl" )  then
     Error("the character table file '",name,"' must exist and be readable");
    fi;
    ext := SHALLOW_COPY_OBJ(name);
    APPEND_LIST_INTR( ext, "_tbl" );
    if not IsBound(Revision.(ext))  then
        Print( "#W  revision entry missing in \"", name, ".tbl\"\n" );
    fi;
end;


#############################################################################
##
#V  SMALLNAME
##
SMALLNAME := ReplacedString( LIBNAME, "lib", "small" );
if SMALLNAME = "./"  then SMALLNAME := "../small/";  fi;


#############################################################################
##
#F  ReadSmall( <name> )
##
ReadSmall := function ( name )
    local   ext;

    if not ReadPath( SMALLNAME, name, "", "ReadSmall" )  then
        Error("the group table file '",name,"' must exist and be readable");
    fi;
    ext := ReplacedString( name, ".", "_" );
    if not IsBound(Revision.(ext))  then
        Print( "#W  revision entry missing in \"", name, "\"\n" );
    fi;
end;


#############################################################################
##
#V  TRANSNAME
##
TRANSNAME := ReplacedString( LIBNAME, "lib", "trans" );
if TRANSNAME = "./"  then TRANSNAME := "../trans/";  fi;


#############################################################################
##

#V  Banner
##
if not QUIET and BANNER then
ReadPath( LIBNAME, "version.g", "", "ReadLib" );
P := function(a) Print( a, "\n" );  end;

P("");
P("ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA");
P("");
P("This is  an ALPHA version  of GAP 4.  Please  do not  redistribute this");
P("version, discuss it  in the  GAP forum,  or use  it  for more  than two");
P("weeks.  You can get a new version from");
P("");
P("                ftp://ftp.math.rwth-aachen.de");
P("");
P("Please report bugs and problems to");
P("");
P("                  gap4@Math.RWTH-Aachen.DE");
P("");
P("quoting the Version and Date below and the machine, operation system,");
P("and compiler used.");
P("");
P("ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA");
P("");
Print("Version:  ", VERSION, "\n");
Print("Date:     ", DATE, "\n");
P("");
P("ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA");
P("");
P("Loading the library, please be patient this may take a while.");
P("");
fi;


#############################################################################
##

#X  first read the very basic stuff that the kernel needs to function at all
##
ReadLib( "kernel.g"    );
ReadLib( "oper.g"      );
ReadLib( "kind.g"      );
ReadLib( "methsel.g"   );

ReadLib( "object.gd"   );
ReadLib( "coll.gd"     );
ReadLib( "list.gd"     );
ReadLib( "arith.gd"    );
ReadLib( "rest.gd"     );
ReadLib( "ffe.gd"      );
ReadLib( "listcoef.gd" );

ReadLib( "object.gi"   );
ReadLib( "coll.gi"     );
ReadLib( "listkind.gi" );
ReadLib( "arith.gi"    );
ReadLib( "rest.gi"     );
ReadLib( "listcoef.gi" );
#T  Does combinat.gi really need to be so early?
ReadLib( "combinat.gi" );


#############################################################################
##
#T  SL 1996/09/10 I think that this is the earliest place
#T                at which the present info.g? could be read
##
##  The assert stuff probbly could go earlier if we wanted it to
##
ReadLib( "info.gd"     );
ReadLib( "assert.gd"   );
ReadLib( "info.gi"     );
ReadLib( "assert.gi"   );


#############################################################################
##
#X  now read all the definition parts
##
ReadLib( "tuples.gd"   );

ReadLib( "matrix.gd"   );

ReadLib( "domain.gd"   );
ReadLib( "extaset.gd"  );
ReadLib( "extlset.gd"  );
ReadLib( "extrset.gd"  );
ReadLib( "extuset.gd"  );

ReadLib( "mapping.gd"  );
ReadLib( "mapphomo.gd" );

ReadLib( "magma.gd"    );
ReadLib( "semigrp.gd"  );
ReadLib( "monoid.gd"   );
ReadLib( "grp.gd"      );

ReadLib( "addmagma.gd" );
ReadLib( "addcoset.gd" );
ReadLib( "ring.gd"     );
ReadLib( "module.gd"   );
ReadLib( "basis.gd"    );
ReadLib( "basismut.gd" );
ReadLib( "vspc.gd"     );
ReadLib( "algebra.gd"  );
ReadLib( "alglie.gd"   );
ReadLib( "algsc.gd"    );
ReadLib( "liefam.gd"   );
ReadLib( "integer.gd"  );
ReadLib( "numtheor.gd" );

ReadLib( "ratfun.gd"   );

ReadLib( "field.gd"    );
ReadLib( "zmodnz.gd"   );
ReadLib( "cyclotom.gd" );
ReadLib( "fldabnum.gd" );
ReadLib( "padics.gd"   );
ReadLib( "ringpoly.gd" );
ReadLib( "upoly.gd"    );
ReadLib( "polyrat.gd"  );
ReadLib( "algfld.gd"   );

ReadLib( "unknown.gd"  );

ReadLib( "word.gd"     );

# files dealing with rewriting systems
ReadLib( "rws.gd"      );
ReadLib( "rwspcclt.gd" );
ReadLib( "rwsgrp.gd"   );
ReadLib( "rwspcgrp.gd" );

# files dealing with polycyclic generating systems
ReadLib( "pcgs.gd"     );
ReadLib( "pcgsind.gd"  );
ReadLib( "pcgspcg.gd"  );
ReadLib( "pcgsmodu.gd" );
ReadLib( "pcgsperm.gd" );
ReadLib( "pcgsspec.gd" );

# files dealing with finite polycyclic groups
ReadLib( "grppc.gd"    );

ReadLib( "mgmring.gd"  );
ReadLib( "grptbl.gd"   );

ReadLib( "grpperm.gd"  );
ReadLib( "stbcbckt.gd" );
ReadLib( "ghom.gd"     );
ReadLib( "ghompcgs.gd" );
ReadLib( "gprd.gd"     );
ReadLib( "ghomperm.gd" );
ReadLib( "oprt.gd"     );
ReadLib( "stbc.gd"     );
ReadLib( "clas.gd"     );
ReadLib( "csetgrp.gd"  );
ReadLib( "factgrp.gd"  );
ReadLib( "grppcrep.gd" );

ReadLib( "onecohom.gd" );
ReadLib( "grppccom.gd" );

ReadLib( "morpheus.gd" );
ReadLib( "grplatt.gd"  );

# files dealing with fp groups
ReadLib( "grpfp.gd"    );

# files dealing with trees and hash tables
ReadLib( "hash.gd"     );

# files needed for Deep Thought
ReadLib( "dt.g" );

# group library
ReadGrp( "basic.gd"    );
ReadGrp( "perf.gd"     );

# family predicates (needed for all 'InstallMethod')
ReadLib( "fampred.g"   );

ReadLib( "list.gi"     ); # was too early

# files dealing with nice monomorphism
# grpnice uses some family predicates, so fampred.g must be known
ReadLib( "grpnice.gd"  );

# files dealing with matrix groups (grpffmat.gd needs grpnice.gd)
ReadLib( "grpmat.gd"   );
ReadLib( "grpffmat.gd" );

#############################################################################
##
#X  now read profiling functions
##
ReadLib( "profile.g"   );


#############################################################################
##
#T  1996/09/01 M.Schoenert this helps performance
##
IMPLICATIONS:=IMPLICATIONS{[Length(IMPLICATIONS),Length(IMPLICATIONS)-1..1]};
HIDDEN_IMPS:=HIDDEN_IMPS{[Length(HIDDEN_IMPS),Length(HIDDEN_IMPS)-1..1]};


#############################################################################
##
#X  now read all the implementation parts
##
ReadLib( "matrix.gi"   );

ReadLib("tuples.gi"    );


ReadLib( "domain.gi"   );
ReadLib( "mapping.gi"  );
ReadLib( "mapprep.gi"  );
ReadLib( "mapphomo.gi" );

ReadLib( "magma.gi"    );
ReadLib( "semigrp.gi"  );
ReadLib( "monoid.gi"   );

ReadLib( "grp.gi"      );

ReadLib( "addmagma.gi" );
ReadLib( "addcoset.gi" );

ReadLib( "ring.gi"     );

ReadLib( "module.gi"   );
ReadLib( "modfree.gi"  );
ReadLib( "modulrow.gi" );
ReadLib( "modulmat.gi" );
ReadLib( "basis.gi"    );
ReadLib( "basismut.gi" );
ReadLib( "vspc.gi"     );
ReadLib( "vspcrow.gi"  );
ReadLib( "vspcmat.gi"  );
# ReadLib( "vspchom.gi"  );

ReadLib( "algebra.gi"  );
ReadLib( "alglie.gi"   );
ReadLib( "algliess.gi" );
ReadLib( "algsc.gi"    );
ReadLib( "algmat.gi"   );
ReadLib( "liefam.gi"   );

ReadLib( "integer.gi"  );
ReadLib( "numtheor.gi" );

ReadLib( "ratfun.gi"   );
ReadLib( "ratfunul.gi" );
ReadLib( "ringpoly.gi" );
ReadLib( "upoly.gi"    );
ReadLib( "polyfinf.gi" );
ReadLib( "polyrat.gi"  );
ReadLib( "algfld.gi"   );

ReadLib( "unknown.gi"  );

ReadLib( "field.gi"    );
ReadLib( "fieldfin.gi" );
ReadLib( "zmodnz.gi"   );
ReadLib( "ffe.gi"      );
ReadLib( "rational.gi" );
ReadLib( "gaussian.gi" );
ReadLib( "cyclotom.gi" );
ReadLib( "fldabnum.gi" );
ReadLib( "padics.gi"   );

ReadLib( "meataxe.gi"  );

ReadLib( "word.gi"     );
ReadLib( "wordrep.gi"  );

# files dealing with free semigroups, monoids, groups
ReadLib( "smgrpfre.gi" );
ReadLib( "monofree.gi" );
ReadLib( "grpfree.gi"  );

# files dealing with rewriting systems
ReadLib( "rws.gi"      );
ReadLib( "rwspcclt.gi" );
ReadLib( "rwspcsng.gi" );
ReadLib( "rwspcftl.gi" );
ReadLib( "rwsgrp.gi"   );
ReadLib( "rwspcgrp.gi" );
ReadLib( "rwsdt.gi" );

# files dealing with polycyclic generating systems
ReadLib( "pcgs.gi"     );
ReadLib( "pcgsind.gi"  );
ReadLib( "pcgspcg.gi"  );
ReadLib( "pcgsmodu.gi" );
ReadLib( "pcgscomp.gi" );
ReadLib( "pcgsperm.gi" );
ReadLib( "pcgsspec.gi" );

# files dealing with finite polycyclic groups
ReadLib( "grppc.gi"    );
ReadLib( "grppcint.gi" );
ReadLib( "grppcprp.gi" );
ReadLib( "grppcatr.gi" );

ReadLib( "mgmring.gi"  );
ReadLib( "grptbl.gi"   );

ReadLib( "ghom.gi"     );
ReadLib( "ghompcgs.gi" );
ReadLib( "gprd.gi"     );
ReadLib( "ghomperm.gi" );
ReadLib( "grpperm.gi"  );
ReadLib( "gprdperm.gi" );
ReadLib( "oprt.gi"     );
ReadLib( "oprtperm.gi" );
ReadLib( "oprtpcgs.gi" );
ReadLib( "partitio.gi" );
ReadLib( "stbc.gi"     );
ReadLib( "stbcbckt.gi" );
ReadLib( "stbcrand.gi" );
ReadLib( "clas.gi"     );
ReadLib( "claspcgs.gi" );
ReadLib( "clasperm.gi" );
ReadLib( "csetgrp.gi"  );
ReadLib( "csetperm.gi" );
ReadLib( "csetpc.gi"   );
ReadLib( "factgrp.gi"  );
ReadLib( "grppcrep.gi" );

ReadLib( "onecohom.gi" );
ReadLib( "grppccom.gi" );

# files dealing with nice monomorphism
ReadLib( "grpnice.gi"  );

ReadLib( "morpheus.gi" );
ReadLib( "grplatt.gi"  );

# files dealing with matrix groups
ReadLib( "grpmat.gi"   );
ReadLib( "grpffmat.gi" );

# files dealing with fp groups
ReadLib( "grpfp.gi"    );
#ReadLib( "grpfpelm.gi" );

# files dealing with trees and hash tables
ReadLib( "hash.gi"     );

# files dealing with overloaded operations
ReadLib( "overload.g"  );


#############################################################################
##
#X  group library
##
ReadGrp( "basicpcg.gi" );
ReadGrp( "basicprm.gi" );
ReadGrp( "basicmat.gi" );
ReadGrp( "perf.grp"    );


#############################################################################
##
#X  Read library of groups of order up to 1000 without 512 and 768
##
ReadSmall( "smallgrp.g" );


#############################################################################
##
#X  Read transitive groups library
##
if not ReadPath( TRANSNAME, "trans", ".grp","ReadTrans") then
  Error(
    "the transitive group library file trans.grp must exist and be readable"
    );
fi;

#############################################################################
##
#E  init.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
