#############################################################################
##
#W  loaddata.g             GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: loaddata.g,v 1.2 2002/05/24 15:02:19 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "pkg/genus/loaddata_g" ) :=
    "@(#)$Id: loaddata.g,v 1.2 2002/05/24 15:02:19 gap Exp $";


#############################################################################
##
#V  MAXGENUS
##
##  For genera from $2$ to `MAXGENUS', the database is used by the functions
##  ...
##
##  (The following assignment is used to insert the maximum into the TeX
##  version of the package manual.)
##
BindGlobal( "MAXGENUS", 48 );

RUNTIME:= Ignore;

SIGNATUR := rec();

SIGNATUR.PrintRevision := function()
    local name;
    for name in Set( RecNames( Revision ) ) do
      if 10 < Length( name ) and name{ [ 1 .. 10 ] } = "pkg/genus/" then
        Print( name, ": ", Revision.( name ), "\n" );
      fi;
    od;
end;

ReadPkg( "genus", "data/special.g" );


#############################################################################
##
#F  SIGN( <g>, <n>, <sign>, <infostring> )
##
##  the function used in the data files `signat??'
##
BindGlobal( "SIGN", function( g, n, sign, infostring )
    local list;

    if not IsBound( ADM_SIGNATURES[g] ) then
      ADM_SIGNATURES[g]:= [];
    fi;
    list:= ADM_SIGNATURES[g];
    if not IsBound( list[ sign[1] + 1 ] ) then
      list[ sign[1] + 1 ]:= [];
    fi;
    list:= list[ sign[1] + 1 ];
    if not IsBound( list[n] ) then
      list[n]:= [];
    fi;
    list:= list[n];
    if not sign in list then
      Add( list, Signature( sign[1], sign{ [ 2 .. Length( sign ) ] } ) );
    fi;
#T infostring is lost!
#T ordering of signatures?
    end );


#############################################################################
##
#V  GROUPINFO
##
GROUPINFO := [];


#############################################################################
##
#F  GROU( <g>, <n>, <sign>, <descr> )
##
##  the function used in the data files `groups??'
##
GROU := function( g, n, sign, descr )
    Add( GROUPINFO, [ sign, n, descr ] );
    SIGN( g, n, sign, "dummy" );
#T improve this!
end;


#############################################################################
##
#F  SPECIAL( <g>, <m>, <signature> )
##
SPECIAL := function( g, m, signature )
    local i, entry, G;
    for i in [ 1 .. Length( SPECIAL_INFO ) ] do
      entry:= SPECIAL_INFO[i];
      if entry[1] = g and entry[2] = m and entry[3] =  signature then
        for G in entry[4] do
          Add( GROUPINFO, [ signature, m, G ] );
        od;
      fi;
    od;
    SIGN( g, m, signature, "dummy" );
end;


#############################################################################
##
#F  LoadGenusData( <g> )
##
##  loads the admissible signatures and groups of genus <g>.
##  The value of <g> must be at least $2$ and at most $48$.
##
LoadGenusData := function( g )
    GROUPINFO:= [];
    if not IsInt( g ) or g < 2 or MAXGENUS < g then
      Error( "<g> must be an integer in the range [ 2 .. ", MAXGENUS, " ]" );
    elif g < 10 then
      g:= Concatenation( "0", String( g ) );
    else
      g:= String( g );
    fi;
    ReadPkg( "genus", Concatenation( "data/groups", g ) );
end;


#############################################################################
##
#F  GroupDataForGenus( <g> )
##
##  returns the list of triples `[ <sign>, <n>, <descr> ]' describing all
##  isomorphism types of automorphism groups of compact Riemann surfaces
##  of genus <g>,
##  where <sign> is the underlying signature, <n> is the group order,
##  and <descr> is a description of the isomorphism type.
##  One can fetch a representative of the isomorphism type by applying
##  `GroupFromDescr' to <descr>.
##
##  The value of <g> must be at least $2$ and at most $48$.
##
GroupDataForGenus := function( g )
    local list, entry;
    LoadGenusData( g );
    list:= GROUPINFO;
    for entry in list do
      entry[1]:= Signature( entry[1][1], entry[1]{ [ 2 .. Length( entry[1] ) ] } );
    od;
    return list;
end;
#T should eventually disappear??


#############################################################################
##
#F  TGGroup( <desc> )
##
##  Construct the groups that are encoded as in the 2-groups library.
##
TGGroup := function( desc )
    local F,          # free group
          grp,        # group described by 'desc', result
          gens,       # generators of the group
          rels,       # relators of the group
          exps,       # exponent bit string
          rhs,        # right hand sides of the relators
          i, k, l;    # loop variables

    # make the generators
    F:= FreeGroup( desc[2] );
    gens := GeneratorsOfGroup( F );

    # make the right hand sides of the relations
    exps := desc[4];
    rhs := [];
    for i  in [1..desc[2]]  do
        rhs[i] := [];
        for k  in [1..i-1]  do
            rhs[i][k] := gens[1]^0;
            for l  in [k..i-1]  do
                rhs[l][k] := rhs[l][k] * gens[i]^(exps mod 2);
                exps := QuoInt( exps, 2 );
            od;
        od;
        rhs[i][i] := One( gens[1] );
    od;

    # make the relators
    rels := [];
    for i  in [1..desc[2]]  do
        Add( rels, gens[i]^2/rhs[i][i] );
        for k  in [1..i-1]  do
            Add( rels, Comm(gens[i],gens[k])/rhs[i][k] );
        od;
    od;

    # make the finite polycyclic group and enter rank and pclass
    grp := PolycyclicFactorGroup( F, rels );

    # return the finite polycyclic group
    return grp;
end;


#############################################################################
##
#F  GroupFromDescr( <descr> )
##
GroupFromDescr := function( descr )
    if IsGroup( descr ) then
      return descr;
    elif Length( descr ) = 2 then
      return SmallGroup( descr[1], descr[2] );
    else
      return TGGroup( descr );
    fi;
end;


#############################################################################
##
#E

