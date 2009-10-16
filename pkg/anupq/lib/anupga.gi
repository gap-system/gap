#############################################################################
####
##
#A  anupga.gi                   ANUPQ package                    Frank Celler
#A                                                           & Eamonn O'Brien
#A                                                           & Benedikt Rothe
##
##  Install file for p-group generation of automorphism group  functions  and
##  variables.
##
#A  @(#)$Id: anupga.gi,v 1.7 2005/08/16 18:48:50 gap Exp $
##
#Y  Copyright 1992-1994,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1992-1994,  School of Mathematical Sciences, ANU,     Australia
##
#H  $Log: anupga.gi,v $
#H  Revision 1.7  2005/08/16 18:48:50  gap
#H  lib/{anupga.gi,anupq.gi,anupqprop.gi,anupqxdesc.gi}:
#H     deprecated `PrimeOfPGroup' replaced by `PrimePGroup'
#H  VERSION: new version will be 3.0
#H  CHANGES: keeping track of changes so far                               - GG
#H
#H  Revision 1.6  2004/02/03 18:49:04  gap
#H  anupga.gi: commented out dangerous warning, changed documentation of
#H             `PqSupplementInnerAutomorphisms' to reflect that it now returns
#H             a record rather than a group
#H  anupq.gi: `GAPInfo.DirectoriesTemporary' replaces `DIRECTORIES_TEMPORARY'
#H            (GAP 4.4 change)
#H  anupqi.gi: documentation of `PQ_AUT_INPUT' changed to reflect that it now
#H             returns a record rather than a group;
#H             `inhibit_orders' changed to `PqInhibitOrders' (cosmetic change
#H             for conformity of style)                                    - GG
#H
#H  Revision 1.5  2004/01/26 20:01:53  werner
#H  Fixed outstanding bug, reported by Boris Girnat
#H
#H  Revision 1.4  2002/11/19 08:47:30  gap
#H  init.g:    now use `StringFile' rather than iostreams to read `VERSION'
#H  testPq.in: Added -A option to GAP command.
#H  lib/{anusp.gi,anupga.gi}: As suggested by AH added `IsSyllableWordsFamily'
#H    as first argument to `FreeGroup' commands when the group is subsequently
#H    converted to a pc group
#H  tst/anupqeg.tst: Remade.
#H  README, VERSION, PkgInfo.g, doc/{install,intro,infra}.tex:
#H    Version 1.2 -> Version 1.3.                                         - GG
#H
#H  Revision 1.3  2002/10/31 13:56:38  werner
#H  Adjust to changes in autpgrp (GeneralizedPcgs)
#H
#H  Revision 1.2  2002/03/25 15:16:25  gap
#H  Added `PqDescendantsTreeCoclassOne' and supporting changes. - GG
#H
#H  Revision 1.1  2002/02/15 08:53:47  gap
#H  Moving `gap/lib' files to `lib'. - GG
#H
#H  Revision 1.24  2001/12/21 14:29:59  werner
#H  Install PqSupplementInnerAutomorphism() via DeclareGlobalFunction()
#H  and InstallGlobalFunction().
#H
#H  Revision 1.23  2001/12/03 06:09:11  werner
#H  Do not set the automorphism group in SupplementInnerAutomorphisms() as
#H  the function does not return the full automorphism group.           WN
#H
#H  Revision 1.22  2001/11/28 17:40:02  gap
#H  - added option `pQuotient'
#H  - standard presentation functions (`StandardPresentation', etc.) now
#H    simplified by passing prime, or quotient via options `Prime', `pQuotient'
#H  - io indices now don't avoid primes
#H  - made changes in other functions consequent on the above
#H    - GG
#H
#H  Revision 1.21  2001/11/24 09:34:55  gap
#H  Added `ANUPQWarnOfOtherOptions'. All user functions that use options now
#H  warn of unrecognised options at `InfoANUPQ' or `InfoWarning' level 1 if
#H  `ANUPQWarnOfOtherOptions' is set to `true' (by default it is `false'). - GG
#H
#H  Revision 1.20  2001/11/20 18:49:16  werner
#H  Handle automorphism returned from the ANUPQ more carefully.          WN
#H
#H  Revision 1.19  2001/11/20 17:16:49  werner
#H  Delay setting up the automorphism group for descendants.  We store the
#H  information returned by the ANUPQ in an attribute ANUPQAUtomorphisms and
#H  install a method for AutomorphismGroup() which uses that information.
#H  Also we now set IsPGroup for descendants.                             WN
#H
#H  Revision 1.18  2001/10/18 02:52:09  gap
#H  Now correctly detect when p-cover has been computed (for interactive
#H  use of `Pq', `PqPCover' etc.) - GG
#H
#H  Revision 1.17  2001/10/05 08:34:33  gap
#H  Added `PqSetPQuotientToGroup'. - GG
#H
#H  Revision 1.16  2001/09/29 22:04:19  gap
#H  `Pq', `PqEpimorphism', `PqPCover', `[Pq]StandardPresentation[Epimorphism]'
#H  now accept either an fp group or a pc group, and for each `ClassBound'
#H  defaults to 63 if not supplied except in the following case.
#H  If the group <F> supplied to `PqPCover' is a p-group and knows it is and
#H  `HasPrimePGroup(<F>)' is `true', `Prime' defaults to `PrimePGroup(<F>)' if
#H  not supplied, and if `HasPClassPGroup(<F>)' is `true' then `ClassBound'
#H  defaults to `PClassPGroup(<F>)' if not supplied or to 63 otherwise.
#H  The attributes and property `MultiplicatorRank', `NuclearRank' and
#H  `IsCapable' don't rely on the method to check that the group is a p-group
#H  and emit an error if `HasIsPGroup(<G>) and IsPGroup(<G>)' is `false' (the
#H  user must make sure the group knows it is a p-group first, except that
#H  `Pq', `PqEpimorphism', `PqPCover' ensure the group or image of the
#H  epimorphism have the property set). - GG
#H
#H  Revision 1.15  2001/09/25 15:23:15  gap
#H  Changed `PqPCover' to `PqComputePCover' to free up the name for another
#H  function that returns the p-cover of a group.
#H  Implemented suggestions from Bettina:
#H   - `PcgsAutomorphisms' is now set to
#H     `HasIsSolvableGroup(A) and IsSolvableGroup(A)' where A is the aut. gp.
#H   - `IsSolvableGroup' is being set for a descendant's aut. gp. if known
#H     to be soluble.                                                    - GG
#H
#H  Revision 1.14  2001/09/19 14:40:58  gap
#H  Bugfix for `PqWeight'. Various improvements. Got rid of `share'. - GG
#H
#H  Revision 1.13  2001/09/06 22:37:48  gap
#H  Now compute the aut. grp behind the scenes according to suggestion by
#H  Bettina. - GG
#H
#H  Revision 1.12  2001/08/30 01:09:54  gap
#H  - Make better use of InfoANUPQ, levels now mean:
#H    1:non-(timing,memory usage) output from `pq' and general info.
#H    2:timing,memory usage output from `pq'
#H    3:non-user invoked output from `pq' of nature of 1, 2
#H    4:commands sent to `pq' (behind a `ToPQ> ' prompt)
#H    5:menus and prompts and other info. that is usually meaningless to a user
#H    Still need to rethink `OutputLevel := 0' in this scheme. For the moment
#H    I've added a behind-the-scenes option: `nonuser' which makes all the
#H    output from `Pq', `PqDescendants' and `StandardPresentation' etc. get
#H    Info-ed at ANUPQ level 3.
#H  - Rationalised the `Display' functions. Now there is just
#H    `PqDisplayPcPresentation' and it uses whatever is the current `pq' menu.
#H  - Rationalised the ..Set..PrintLevel functions in the same way, except it
#H    is now called `PqSetOutputLevel' (like the `OutputLevel' option).
#H  - A number of functions now call `PQ_SET_GROUP_DATA' which may in turn
#H    call `PQ_DATA' which between them set the fields `name', `class' (current
#H    class), `forder' (factored order) and `ngens' (the no. of gen'rs for each
#H    class up to the current class) of the data record associated with an
#H    interactive process.
#H  - There are now functions: `PqFactoredOrder', `PqOrder', `PqNrPcGenerators',
#H    `PqPClass' and `PqWeight' (weight of a generator) which determine their
#H    values by looking at the fields `class', `forder' and `ngens' of the data
#H    record associated with a process. `PqCurrentGroup' is not useful yet.
#H  - Fixed bug in `PqDoConsistencyCheck'.
#H  - `PqDoExponentChecks', `PqDisplayStructure' (was `PqPrintStructure') and
#H    `PqDisplayAutomorphisms' now have their non-process-id arguments as the
#H    option `Bounds'.
#H  - There is now a guard against `pq' seg-faults just from changing menu.
#H     GG
#H
#H  Revision 1.11  2001/07/19 21:13:20  gap
#H  Renamed `PqSPSupplyAutomorphisms' to `PqSupplyAutomorphisms' and
#H          `PqSPExtendAutomorphisms' to `PqExtendAutomorphisms'
#H  (they correspond to items of the Advanced p-Quotient menu not the
#H  Standard Presentation menu). Deleted the `PQ_SUPPLY_AND_EXTEND_AUTOMORPHISMS'
#H  synonym of `PQ_SUPPLY_OR_EXTEND_AUTOMORPHISMS'. Generalised the NC versions
#H  doing items 1 to 4 of the pG menu, so that they did the ApG menu too. One
#H  common command `PQ_DISPLAY_PRESENTATION' now does item 5 of each menu and
#H  temporarily alters the `InfoANUPQ' level if necessary to ensure there is a
#H  display. - GG
#H
#H  Revision 1.10  2001/07/05 21:14:26  gap
#H  Bug fixes. ANUPQ_ARG_CHK now checks required options are set ... all
#H  functions that call it have been adjusted. The option `StepSize' had
#H  been mis-spelt `Stepsize' twice. - GG
#H
#H  Revision 1.9  2001/06/26 09:44:27  gap
#H  Just cleaning house. - GG
#H
#H  Revision 1.8  2001/06/21 23:04:20  gap
#H  src/*, include/*, Makefile.in:
#H   - pq binary now calls itself version 1.5 (global variable PQ_VERSION
#H     added in include/pq_author.h for this)
#H   - added -v option (gives pq version)
#H   - added -G option (equivalent to `-g -i -k' + assumes talking to GAP via
#H     an iostream ... extern variable: GAP4iostream added in include/global.h
#H     for this)
#H   - some idiosyncrasies in the menus cleaned up.
#H  standalone-doc/*:
#H   - updated ... see newly added header in guide.tex for details.
#H  gap/lib/anustab.g[id]:
#H   - replace gap/lib/anustab.g ... original code is now in function
#H     `PqStabiliserOfAllowableSubgroup'
#H  init.g,read.g:
#H   - now read in gap/lib/anustab.g[id] so that `PqStabiliserOfAllowableSubgroup'
#H     is defined. ANUPQ share package now calls itself Version 1.1.
#H  gap/lib/anupqhead.g:
#H   - now uses -v option of pq to extract the version. ANUPQData.infile is no
#H     longer defined.
#H  gap/lib/*.g[id] (other):
#H   - now when not being called to create a setup file GAP calls pq with the -G
#H     option. The setup file has comment on first line telling user to use:
#H     the `-i -g -k' flags. Modifications made to call
#H     `PqStabiliserOfAllowableSubgroup' in the `ToPQ' function when a
#H     `PQ_REQUEST' is detected.
#H   - `PQ_REQUEST' takes a string as argument and returns a boolean. It detects
#H     when a `GAP, please compute stabilisers!\n' request has been emitted by
#H     the `pq' binary.
#H  - GG
#H
#H  Revision 1.7  2001/06/19 17:21:39  gap
#H  - Non-interactive functions now use iostreams (when not creating a SetupFile).
#H  - The `Verbose' option has now been eliminated; it's function is now provided
#H    by using `InfoANUPQ'.
#H  - Data recorded for a non-interactive function is now stored in the record
#H    `ANUPQData.ni' entirely analogous to the interactive function records
#H    `ANUPQData.io[<i>]'.
#H  - `ToPQ' now takes care of the cases where the `pq' binary calls GAP to
#H    compute stabilisers.
#H  - A header was added to `anustab.g'. - GG
#H
#H  Revision 1.6  2001/06/16 15:05:04  werner
#H  Progress (?) with talking to pq
#H
#H  Revision 1.5  2001/06/15 17:35:38  werner
#H  Changing the way Process() is handled.                                WN
#H
#H  Revision 1.4  2001/06/13 21:34:25  gap
#H  - The non-interactive `PqDescendants' and `PqList' have been modified.
#H    o `PqList' now takes the option `SubList' which enables `PqDescendants'
#H      to call `PqList' and pass its `SubList' recursively (much neater).
#H    o The non-interactive `PqDescendants' no longer has `TmpDir' as an option,
#H      but it now has `PqWorkspace' like the other non-interactive functions.
#H  - There is now an interactive `PqDescendants'.
#H  - Menu item function: `PqPGConstructDescendants' has been added.
#H    (This does most of the work for `PqDescendants'.)
#H  - `PqStart' now accepts either an *fp group* or a *pc group*.
#H    (`PqDescendants' expects the group to be a pc group.)               - GG
#H
#H  Revision 1.3  2001/06/05 16:42:24  gap
#H  Up-to-the-minute changes. - GG
#H
#H  Revision 1.2  2001/06/05 12:09:22  gap
#H  Mainly half-baked changes, just to ensure CVS and me don't differ. - GG
#H
#H  Revision 1.1  2001/04/21 21:15:40  gap
#H  lib/
#H     *.g,*.gd:
#H     - following global variables modified to have `Pq' in them:
#H       `LetterInt' -> `PqLetterInt' (now defined in `anupga.g[id]')
#H       `EpimorphismStandardPresentation' -> `EpimorphismPqStandardPresentation'
#H       `StandardPresentation' -> `PqStandardPresentation'
#H       `FpGroupPcGroup' -> `PqFpGroupPcGroup'
#H       `IsIsomorphicPGroup' -> `IsPqIsomorphicPGroup'
#H       The last four functions now have methods of the same name as
#H       previously which are equivalent to the functions with `Pq' in them.
#H     anupqhead.g:
#H     - new file: defines `ANUPQData' record, `InfoANUPQ' and sets its level to 1,
#H       and outputs a banner.
#H     anupqprop.gd:
#H     - new file: contains previous contents of `anupq.gd'
#H     anupqopt.gd, anupqopt.gi:
#H     - new files: so far defines `ANUPQoptions', `SET_ANUPQ_OPTIONS'
#H     anupq.g -> anupq.gd, anupq.gi
#H     - headers put on files
#H     - `anupq.gd' has all the `DeclareGlobalFunction' and `DeclareGlobalVariable'
#H       commands, and `anupq.gi' is the old `.g' file converted to using
#H       `InstallGlobalFunction' and `InstallValue'.
#H     anupq.gi:
#H     - `ANUPQoptions' moved to `anupqopt.g[id]' and generalised.
#H     - `Pq'
#H       now accepts options; modified error messages ... usage now says to use
#H       options
#H     anupga.g -> anupga.gd, anupga.gi
#H     - headers put on files
#H     - `anupga.gd' has all the `DeclareGlobalFunction' and `DeclareGlobalVariable'
#H       commands, and `anupga.gi' is the old `.g' file converted to using
#H       `InstallGlobalFunction' and `InstallValue'.
#H     - `PqDescendants'
#H       now accepts options; its options are a field of the record in
#H       `ANUPQoptions' defined in `anupqopt.g[id]'
#H     anusp.g -> anusp.gd, anusp.gi
#H     - headers put on files
#H     - `anusp.gd' has all the `DeclareGlobalFunction' and `DeclareGlobalVariable'
#H       commands, and `anusp.gi' is the old `.g' file converted to using
#H       `InstallGlobalFunction' and `InstallValue'.
#H     - list of options for `StandardPresentation' etc. is now a field of the
#H       record `ANUPQoptions' in `anupqopt.g[id]'.
#H     - Operations/Methods declared and installed for
#H       `EpimorphismStandardPresentation', `StandardPresentation' and
#H       `FpGroupPcGroup', `IsIsomorphicPGroup' and each has a function
#H       counterpart with a `Pq' in its name.
#H     - `EpimorphismPqStandardPresentation', `PqStandardPresentation' now
#H       accept options. Their non-`Pq' method counterparts only accept
#H       options.
#H  - GG
#H
#H  Revision 1.3  2000/07/13 16:16:43  werner
#H  p-group generation now works for soluble automorphism groups and with
#H  the help of GAP3 for insoluble automorphism groups.
#H  We are getting there.                                                   WN
#H
#H  Revision 1.2  2000/07/12 17:00:06  werner
#H  Further work towards completing the GAP 4 interface to the ANU PQ.
#H                                                                      WN
#H
#H  Revision 1.1.1.1  1998/08/12 18:50:54  gap
#H  First attempt at adapting the ANU pq to GAP 4. 
#H
##
Revision.anupga_gi :=
    "@(#)$Id: anupga.gi,v 1.7 2005/08/16 18:48:50 gap Exp $";

#############################################################################
##
#F  ANUPQerror( <param> ) . . . . . . . . . . . . .  report illegal parameter
##
InstallGlobalFunction( ANUPQerror, function( param )
    Error(
    "Valid Options:\n",
    "    \"ClassBound\", <bound>\n",
    "    \"OrderBound\", <order>\n",
    "    \"StepSize\", <size>\n",
    "    \"PcgsAutomorphisms\"\n",
    "    \"RankInitialSegmentSubgroups\", <rank>\n",
    "    \"SpaceEfficient\"\n",
    "    \"AllDescendants\"\n",
    "    \"Exponent\", <exponent>\n",
    "    \"Metabelian\"\n",
    "    \"SubList\"\n",
    "    \"SetupFile\", <file>\n",
    "Illegal Parameter: \"", param, "\"" );
end );

#############################################################################
##
#F  ANUPQextractArgs( <args>) . . . . . . . . . . . . . . parse argument list
##
InstallGlobalFunction( ANUPQextractArgs, function( args )
    local   CR,  i,  act,  G,  match;

    # allow to give only a prefix
    match := function( g, w )
    	return 1 < Length(g) and 
            Length(g) <= Length(w) and 
            w{[1..Length(g)]} = g;
     end;

    # extract arguments
    G  := args[1];
    CR := rec( group := G );
    i  := 2;
    while i <= Length(args)  do
        act := args[i];

        # "ClassBound", <class>
        if match( act, "ClassBound" )  then
            i := i + 1;
            CR.ClassBound := args[i];
            if CR.ClassBound <= PClassPGroup(G) then
                Error( "\"ClassBound\" must be at least ", PClassPGroup(G)+1 );
            fi;

        # "OrderBound", <order>
        elif match( act, "OrderBound" )  then
            i := i + 1;
            CR.OrderBound := args[i];

        # "StepSize", <size>
        elif match( act, "StepSize" )  then
            i := i + 1;
            CR.StepSize := args[i];

        # "PcgsAutomorphisms"
        elif match( act, "PcgsAutomorphisms" )  then
            CR.PcgsAutomorphisms := true;

        # "RankInitialSegmentSubgroups", <rank>
        elif match( act, "RankInitialSegmentSubgroups" )  then
            i := i + 1;
            CR.RankInitialSegmentSubgroups := args[i];

        # "SpaceEfficient"
        elif match( act, "SpaceEfficient" ) then
            CR.SpaceEfficient := true;

        # "AllDescendants"
        elif match( act, "AllDescendants" )  then
            CR.AllDescendants := true;

        # "Exponent", <exp>
        elif match( act, "Exponent" )  then
            i := i + 1;
            CR.Exponent := args[i];

        # "Metabelian"
        elif match( act, "Metabelian" ) then
            CR.Metabelian := true;

        # "Verbose"
        elif match( act, "Verbose" )  then
            CR.Verbose := true;

        # "SubList"
        elif match( act, "SubList" )  then
            i := i + 1;
            CR.SubList := args[i];

        # temporary directory
        elif match( act, "TmpDir" )  then
            i := i + 1;
            CR.TmpDir := args[i];

        # "SetupFile", <file>
        elif match( act, "SetupFile" )  then
            i := i + 1;
            CR.SetupFile := args[i];

        # signal an error
        else
            ANUPQerror( act );
        fi;
        i := i + 1;
    od;
    return CR;

end );

#############################################################################
##
#F  ANUPQauto( <G>, <gens>, <imgs> )  . . . . . . . .  construct automorphism
##
InstallGlobalFunction( ANUPQauto, function( G, gens, images )
   local   f;

   f := GroupHomomorphismByImagesNC( G, G, gens, images );
   SetIsBijective( f, true );
   SetKernelOfMultiplicativeGeneralMapping( f, TrivialSubgroup(G) );

   return f;
end );

#############################################################################
##
#F  ANUPQautoList( <G>, <gens>, <L> ) . . . . . . . construct a list of autos
##
InstallGlobalFunction( ANUPQautoList, function( G, gens, automs )
    local   D,  g,  igs,  auts,  i;

    # construct direct product elements
    D := [];
    for g  in [ 1 .. Length(gens) ]  do
	Add( D, Tuple( automs{[1..Length(automs)]}[g] ) );
    od;

    # and compute the abstract igs simultaneously
    igs := InducedPcgsByGeneratorsWithImages( Pcgs(G), gens, D );
    gens := igs[1];
    D := igs[2];


    # construct the automorphisms
    auts := [];
    for i in [ 1 .. Length(automs) ]  do
	Add( auts, ANUPQauto( G, gens, D{[1..Length(gens)]}[i] ) );
    od;

    # and then the automorphisms
    return auts;

end );

#############################################################################
##
#F  ANUPQSetAutomorphismGroup( <G>, <gens>, <automs>, <isSoluble> ) 
##
InstallGlobalFunction( ANUPQSetAutomorphismGroup, 
function( G, gens, centralAutos, otherAutos, relativeOrders, isSoluble )

    SetANUPQAutomorphisms( G, 
            rec( gens := gens, 
                 centralAutos   := centralAutos, 
                 otherAutos     := otherAutos, 
                 relativeOrders := relativeOrders,
                 isSoluble      := isSoluble ) );

    return;

end );

#############################################################################
##
#F  PqSupplementInnerAutomorphisms( <G> ) 
##
##  returns   a   record   analogous   to   what   is   returned    by    the
##  `AutomorphismGroupPGroup' function of the {\AutPGrp} package, except that
##  only  the  fields  `agAutos',  `agOrder'  and  `glAutos'  are  set.   The
##  automorphisms generate a subgroup of the automorphism  group  of  the  pc
##  group <D> that supplements the inner automorphism group  of  <D>  in  the
##  whole automorphism group of <D>. The group of automorphisms returned  may
##  be a proper subgroup of the full automorphism group. The  descendant  <D>
##  must   have   been   computed    by    the    function    `PqDescendants'
##  (see~"PqDescendants").
##

##!!  Muss angepasst werden auf die jetzt besser verstandenen Anforderungen
##!!  an Automorphismen, nämlich der Unterscheideung zwischen solchen, die
##!!  auf der Frattinigruppe treu operieren und solche, die dies nicht tuen.

InstallGlobalFunction( "PqSupplementInnerAutomorphisms",
function( G )
    local   gens,  automs,  A, centralAutos, otherAutos;

#Print( "Attention: the function PqSupplementInnerAutomorphisms()",
#       " is outdated and dangerous\n" );

    if not HasANUPQAutomorphisms( G ) then
        return Error( "group does not carry automorphism information" );
    fi;

    automs := ANUPQAutomorphisms( G );

    gens := automs.gens;

    centralAutos := ANUPQautoList( G, gens, automs.centralAutos );
    otherAutos   := ANUPQautoList( G, gens, automs.otherAutos );
    
    return rec( agAutos := centralAutos,
                agOrder := automs.relativeOrders,
                glAutos := otherAutos );

end );

#############################################################################
##
#F  ANUPQprintExps( <pqi>, <lst> ) . . . . . . . . . . .  print exponent list
##
InstallGlobalFunction( ANUPQprintExps, function( pqi, lst )
    local   first,  l,  j;

    l := Length(lst);
    first := true;
    for j  in [1 .. l]  do
        if lst[j] <> 0  then
          if not first  then
              AppendTo( pqi, "*" );
          fi;
          first := false;
          AppendTo( pqi, "g", j, "^", lst[j] );
        fi;
    od;
end );

#############################################################################
##
#V  ANUPGAGlobalVariables
##
InstallValue( ANUPGAGlobalVariables,
              [ "ANUPQgroups", 
                "ANUPQautos", 
                "ANUPQmagic" ] );

#############################################################################
##
#F  PqList( <file> [: SubList := <sub>]) . . . . .  get a list of descendants
##
InstallGlobalFunction( PqList, function( file )
    local   var,  lst,  groups,  autos,  sublist,  func;

    PQ_OTHER_OPTS_CHK("PqList", false);
    # check arguments
    if not IsString(file) then
        Error( "usage: PqList( <file> [: SubList := <sub>])\n" );
    fi;

    for var in ANUPGAGlobalVariables do
        HideGlobalVariables( var );
    od;

    # try to read <file>
    if not READ( file ) or not IsBoundGlobal( "ANUPQmagic" )  then

        for var in ANUPGAGlobalVariables do
            UnhideGlobalVariables( var );
        od;
        return false;
    fi;

    # <lst> will hold the groups
    lst := [];
    if IsBoundGlobal( "ANUPQgroups" ) then
        groups := ValueGlobal( "ANUPQgroups" );
        if IsBoundGlobal( "ANUPQautos" ) then
            autos := ValueGlobal( "ANUPQautos" );
        fi;

        sublist := VALUE_PQ_OPTION("SubList", [ 1 .. Length( groups ) ]);
        if not IsList(sublist) then
            sublist := [ sublist ];
        fi;

        for func  in sublist  do
            groups[func](lst);
            if IsBound( autos) and IsBound( autos[func] )  then
                autos[func]( lst[Length(lst)] );
            fi;
        od;
    fi;
    
    for var in ANUPGAGlobalVariables do
        UnhideGlobalVariables( var );
    od;

    # return the groups
    return lst;

end );

#############################################################################
##
#F  PqLetterInt( <n> ) . . . . . . . . . . . . . . . 
##
InstallGlobalFunction( PqLetterInt, function ( n )
    local  letters, str, x, d;
    letters := [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", 
        "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" ]
     ;
    if n < 1  then
        Error( "number must be positive" );
    elif n <= Length( letters )  then
        return letters[n];
    fi;
    str := "";
    n := n - 1;
    d := 1;
    repeat
        x := n mod Length( letters ) + d;
        str := Concatenation( letters[x], str );
        n := QuoInt( n, Length( letters ) );
        if n < 26  then
            d := 0;
        fi;
    until n < 1;
    return str;
end );

#############################################################################
##
#F  PQ_DESCENDANTS( <args> ) . . . . . . . . . construct descendants of group
##
InstallGlobalFunction( PQ_DESCENDANTS, function( args )
    local   datarec, p, class, G, ndescendants;

    datarec := ANUPQ_ARG_CHK("PqDescendants", args);
    if datarec.calltype = "interactive" and IsBound(datarec.descendants) then
        Info(InfoANUPQ, 1, 
             "`PqDescendants' should not be called more than once for the");
        Info(InfoANUPQ, 1, 
             "same process ... returning previously computed descendants.");
        return datarec.descendants;
    elif datarec.calltype = "GAP3compatible" then
        # ANUPQ_ARG_CHK calls PQ_DESCENDANTS itself in this case
        # (so datarec.descendants has already been computed)
        return datarec.descendants;
    fi;

    PQ_AUT_GROUP(datarec.group); # make sure we have the aut. grp.

    # if <G> is not capable and we want to compute something, return
    if HasIsCapable(datarec.group) and not IsCapable(datarec.group) and 
       VALUE_PQ_OPTION("SetupFile") = fail then
        datarec.descendants := [];
        return datarec.descendants;
    fi;

    PushOptions(rec(nonuser := true));
    p     := PrimePGroup(datarec.group);
    class := PClassPGroup(datarec.group);
    if not( IsBound(datarec.pQuotient) and 
            p = PrimePGroup(datarec.pQuotient) and
            class = datarec.class or
            IsBound(datarec.pCover) and
            p = PrimePGroup(datarec.pCover) and
            IsBound(datarec.pcoverclass) and 
            class = datarec.pcoverclass - 1 ) then
        PQ_PC_PRESENTATION( datarec, "pQ" : Prime := p, ClassBound := class );
    fi;
    if not( IsBound(datarec.pCover) and p = PrimePGroup(datarec.pCover) and
            class = datarec.pcoverclass - 1 ) then
        PQ_P_COVER( datarec );
    fi;
    PQ_PG_SUPPLY_AUTS( datarec, "pG" );
    ndescendants := PQ_PG_CONSTRUCT_DESCENDANTS( datarec );
    PopOptions();

    if datarec.calltype = "non-interactive" then
        PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL(datarec);
        if IsBound( datarec.setupfile ) then
            return true;
        fi;
    fi;
        
    if ndescendants = 0 then
        datarec.descendants := [];
        return datarec.descendants;
    fi;

    datarec.descendants 
        := PqList( Filename( ANUPQData.tmpdir, "GAP_library" ) : recursive );
    for G in datarec.descendants do
        if not HasIsCapable(G)  then
            SetIsCapable( G, false );
        fi;
        SetFeatureObj( G, IsPGroup, true );
    od;

    return datarec.descendants;
end );

#############################################################################
##
#F  PqDescendants( <G> ... )  . . . . . . . . .  construct descendants of <G>
#F  PqDescendants( <i> )
#F  PqDescendants()
##
InstallGlobalFunction( PqDescendants, function( arg )
    return PQ_DESCENDANTS(arg);
end );

#############################################################################
##
#F  PqSetPQuotientToGroup( <i> ) . . . set p-quotient as the group of process
#F  PqSetPQuotientToGroup()
##
InstallGlobalFunction( PqSetPQuotientToGroup, function( arg )
local datarec;
    ANUPQ_IOINDEX_ARG_CHK(arg);
    datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
    if not IsBound(datarec.pQuotient) then
        Error( "p-quotient has not yet been calculated!\n" );
    fi;
    datarec.group := datarec.pQuotient;
end );

#############################################################################
##
#F  SavePqList( <file>, <lst> ) . . . . . . . . .  save a list of descendants
##
InstallGlobalFunction( SavePqList, function( file, list )
    local   appendExp,  l,  G,  pcgs,  p,  i,  w,  str,  word,  j,  
            automorphisms,  r;

    # function to add exponent vector
    appendExp := function( str, word )
        local   first, s, oldLen, i, w;

        first  := true;
        s      := str;
        oldLen := 0;
        for i  in [ 1 .. Length (word) ]  do
            if word[i] <> 0 then
                w := Concatenation( "G.", String (i) );
                if word[i] <> 1  then
                    w := Concatenation( w, "^", String(word[i]) );
                fi;
                if not first  then
                    w := Concatenation( "*", w );
                fi;
                if Length(s)+Length(w)-oldLen >= 77  then
                    s := Concatenation( s, "\n" );
                    oldLen := Length(s);
                fi;
                s := Concatenation( s, w );
                first := false;
            fi;
        od;
        if first  then
            s := Concatenation( s, "G.1^0" );
        fi;
        return s;
    end;

    # print head of file
    PrintTo(  file, "ANUPQgroups := [];\n"    );
    AppendTo( file, "Unbind(ANUPQautos);\n\n" );

    # run through all groups in <list>
    for l  in [ 1 .. Length(list) ]  do
        G    := list[l];
        pcgs := PcgsPCentralSeriesPGroup( G );
        p    := PrimePGroup( G );
        AppendTo( file, "## group number: ", l, "\n"                     );
        AppendTo( file, "ANUPQgroups[", l, "] := function( L )\n"        );
        AppendTo( file, "local   G,  A,  B;\n"                           );
        AppendTo( file, "G := FreeGroup( IsSyllableWordsFamily,\n"       );
        AppendTo( file, "                ", Length(pcgs), ", \"G\" );\n" );
        AppendTo( file, "G := G / [\n"                                   );

        # at first the power relators
        for i in [ 1 .. Length(pcgs) ]  do
            if 1 < i  then
                AppendTo( file, ",\n" );
            fi;
            w   := pcgs[i]^p;
            str := Concatenation( "G.", String(i), "^", String(p) );
            if w <> One(G) then
                word := ExponentsOfPcElement( pcgs, w );
                str  := Concatenation( str, "/(" );
                str  := appendExp( str,word );
                str  := Concatenation( str, ")" );
            fi;
            AppendTo( file, str );
        od;

        # and now the commutator relators
        for i  in [ 1 .. Length(pcgs)-1 ]  do
            for j  in [ i+1 .. Length(pcgs) ]  do
                w := Comm( pcgs[j], pcgs[i] );
                if w <> One(G) then
                    word := ExponentsOfPcElement( pcgs, w );
                    str  := Concatenation(
                                ",\nComm( G.", String(j),
                                ", G.", String(i), " )/(" );
                    str := appendExp( str, word );
                    AppendTo( file, str, ")" );
                fi;
            od;
        od;
        AppendTo( file, "];\n" );

        # convert group into an ag group, save presentation
        AppendTo( file, "G := PcGroupFpGroupNC(G);\n"              );

        # add automorphisms
        if HasAutomorphismGroup(G) then
            AppendTo( file, "A := [];\nB := [" );
    	    for r  in [ 1 .. RankPGroup(G) ]  do
                AppendTo( file, "G.", r );
                if r <> RankPGroup(G)  then
                    AppendTo( file, ", " );
    	    	else
    	    	    AppendTo( file, "];\n" );
                fi;
            od;
            automorphisms := GeneratorsOfGroup( AutomorphismGroup( G ) );
            for j  in [ 1 .. Length(automorphisms) ]  do
                AppendTo( file, "A[", j, "] := [");
                for r  in [ 1 .. RankPGroup(G) ]  do
                    word := Image( automorphisms[j], pcgs[r] );
                    word := ExponentsOfPcElement( pcgs, word );
                    AppendTo( file, appendExp( "", word ) );
                    if r <> RankPGroup(G)  then
                        AppendTo (file, ", \n");
                    fi;
                od;
                AppendTo( file, "]; \n");
            od;
    	    AppendTo( file, "ANUPQSetAutomorphismGroup( G, B, A, " );
            if HasIsSolvableGroup( AutomorphismGroup(G) ) then
                AppendTo( file, IsSolvableGroup( G ), " );\n" );
            else
                AppendTo( file, false, " );\n" );
            fi;
        fi;

        if HasNuclearRank( G ) then
            AppendTo( file, "SetNuclearRank( G, ", NuclearRank(G), " );\n" );
        fi;
        if HasIsCapable( G ) then
            AppendTo( file, "SetIsCapable( G, ", IsCapable(G), " );\n" );
        fi;
        if HasANUPQIdentity( G ) then
            AppendTo( file, "SetANUPQIdentity( G, ", 
                    ANUPQIdentity(G), " );\n" );
        fi;

        AppendTo( file, "Add( L, G );\n" );
        AppendTo( file, "end;\n\n\n"     );
    od;

    # write a magic string to the files
    AppendTo( file, "ANUPQmagic := \"groups saved to file\";\n" );
end );

#E  anupga.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
