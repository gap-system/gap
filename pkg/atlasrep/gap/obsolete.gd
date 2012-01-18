#############################################################################
##
#W  obsolete.gd          GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2011,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains declarations of global variables
##  that had been documented in earlier versions of the AtlasRep package.
##


#############################################################################
##
#F  AGRGNAN( <gapname>, <atlasname>[, <size>[, <maxessizes>[, "all"
#F           [, <compatinfo>]]]] )
##
##  This function is deprecated since version 1.5 of the package.
##
##  Let <A>gapname</A> be a string denoting a &GAP; group name,
##  and <A>atlasname</A> be a string denoting the corresponding
##  <Package>ATLAS</Package>-file name used in filenames of the
##  <Package>ATLAS</Package> of Group Representations.
##  The following optional arguments are supported.
##  <List>
##  <Mark><A>size</A></Mark>
##  <Item>
##    the order of the corresponding group,
##  </Item>
##  <Mark><A>maxessizes</A></Mark>
##  <Item>
##    a (not necessarily dense) list of orders of the maximal subgroups of
##    this group,
##  </Item>
##  <Mark><A>complete</A></Mark>
##  <Item>
##    the string <C>"all"</C> if the <A>maxessizes</A> list is known to be
##    complete, or the string <C>"unknown"</C> if not,
##  </Item>
##  <Mark><A>compatinfo</A></Mark>
##  <Item>
##    a list of entries of the form <C>[ std, factname, factstd, flag ]</C>
##    meaning that mapping standard generators of standardization <C>std</C>
##    to the factor group with &GAP; group name <C>factname</C>, via the
##    natural epimorphism, yields standard generators of standardization
##    <C>factstd</C> if <C>flag</C> is <K>true</K>.
##  </Item>
##  </List>
##  <P/>
##  <Ref Func="AGRGNAN"/> adds the list of its arguments to the list stored
##  in the <C>GAPnames</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>,
##  making the <Package>ATLAS</Package> data involving <A>atlasname</A>
##  accessible for the group with name <A>gapname</A>.
##  <P/>
##  An example of a valid call is
##  <C>AGRGNAN("A6.2_2","PGL29",360)</C>,
##  see also
##  Section&nbsp;<Ref Sect="sect:An Example of Extending AtlasRep"/>.
##
BindGlobal( "AGRGNAN", function( arg )
    local l;

    AGR.GNAN( arg[1], arg[2] );
    if IsBound( arg[3] ) then AGR.GRS( arg[1], arg[3] ); fi;
    if IsBound( arg[4] ) then AGR.MXO( arg[1], arg[4] ); fi;
    if IsBound( arg[5] ) and arg[5] = "all" then
      AGR.MXN( arg[1], Length( AGR.GAPnamesRec.( arg[1] )[3].sizesMaxes ) );
    fi;
    if IsBound( arg[6] ) then
      for l in arg[6] do
        AGR.STDCOMP( arg[1], l );
      od;
    fi;
    end );


#############################################################################
##
#F  AGRGRP( <dirname>, <simpname>, <groupname> )
#F  AGRRNG( ... )
#F  AGRTOC( <typename>, <filename>[, <nrgens>] )
#F  AGRTOCEXT( <atlasname>, <std>, <maxnr>, <files> )
##
##  These functions are deprecated since version 1.5 of the package.
##
##  These functions are used to create the initial table of contents for the
##  server data of the <Package>AtlasRep</Package> package when the file
##  <F>atlasprm.g</F> in the <F>gap</F> directory of the package is read.
##  Encoding the table of contents in terms of calls to <Ref Func="AGRGRP"/>,
##  <Ref Func="AGRTOC"/> and <Ref Func="AGRTOCEXT"/> is done by
##  <Ref Func="StringOfAtlasTableOfContents"/>.
##  <P/>
##  Each call of <Ref Func="AGRGRP"/> notifies the group with name
##  <A>groupname</A>,
##  which is related to the simple group with name <A>simpname</A>
##  and for which the data on the servers can be found in the directory
##  with name <A>dirname</A>.
##  <P/>
##  Each call of <Ref Func="AGRTOC"/> notifies an entry to the
##  <C>TableOfContents.remote</C> component of the global variable
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>.
##  The arguments must be the name <A>typename</A> of the data type to which
##  the entry belongs, the prefix <A>filename</A> of the data file(s),
##  and if given the number <A>nrgens</A> of generators, which are then
##  located in separate files.
##  <P/>
##  Each call of <Ref Func="AGRTOCEXT"/> notifies an entry to the
##  <C>maxext</C> component in the record for the group
##  with &ATLAS; name <A>atlasname</A> in the <C>TableOfContents.remote</C>
##  component of <Ref Var="AtlasOfGroupRepresentationsInfo"/>.
##  These entries concern straight line programs for computing generators of
##  maximal subgroups from information about straight line programs for
##  proper factor groups.
##
BindGlobal( "AGRGRP", function( arg ) CallFuncList( AGR.GRP, arg ); end );
BindGlobal( "AGRRNG", function( arg ) CallFuncList( AGR.RNG, arg ); end );
BindGlobal( "AGRTOC", function( arg ) CallFuncList( AGR.TOC, arg ); end );
BindGlobal( "AGRTOCEXT",
    function( arg ) CallFuncList( AGR.TOCEXT, arg ); end );


#############################################################################
##
#F  AGRParseFilenameFormat( <string>, <format> )
##
BindGlobal( "AGRParseFilenameFormat",
    function( arg ) CallFuncList( AGR.ParseFilenameFormat, arg ); end );


#############################################################################
##
#F  AtlasStraightLineProgram( ... )
##
##  This was the documented name before version 1.3 of the package,
##  when no straight line decisions and black box programs were available.
##  We keep it for backwards compatibility reasons,
##  but leave it undocumented.
##
DeclareSynonym( "AtlasStraightLineProgram", AtlasProgram );


#############################################################################
##
#F  OneAtlasGeneratingSet( ... )
##
##  This function is deprecated since version 1.3 of the package.
##  It was used in earlier versions,
##  when `OneAtlasGeneratingSetInfo' was not yet available.
##
BindGlobal( "OneAtlasGeneratingSet", function( arg )
    local res;

    res:= CallFuncList( OneAtlasGeneratingSetInfo, arg );
    if res <> fail then
      res:= AtlasGenerators( res.identifier );
    fi;
    return res;
    end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsShowUserParameters()
##
##  This function is deprecated since version 1.5 of the package,
##  one should use `AtlasOfGroupRepresentationsUserParameters' instead.
##
BindGlobal( "AtlasOfGroupRepresentationsShowUserParameters", function()
    Print( AtlasOfGroupRepresentationsUserParameters() );
    end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestClassScripts( ... )
#F  AtlasOfGroupRepresentationsTestCompatibleMaxes( ... )
#F  AtlasOfGroupRepresentationsTestFileHeaders( ... )
#F  AtlasOfGroupRepresentationsTestFiles( ... )
#F  AtlasOfGroupRepresentationsTestGroupOrders( ... )
#F  AtlasOfGroupRepresentationsTestStdCompatibility( ... )
#F  AtlasOfGroupRepresentationsTestSubgroupOrders( ... )
#F  AtlasOfGroupRepresentationsTestWords( ... )
##
##  These functions are deprecated since version 1.5 of the package.
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestClassScripts" );
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestCompatibleMaxes" );
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestFileHeaders" );
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestFiles" );
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestGroupOrders" );
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestStdCompatibility" );
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestSubgroupOrders" );
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestWords" );


#############################################################################
##
#E

