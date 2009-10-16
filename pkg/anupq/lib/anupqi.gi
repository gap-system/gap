#############################################################################
####
##
#W  anupqi.gi              ANUPQ package                          Greg Gamble
##
##  This file installs interactive functions that execute individual pq  menu
##  options.
##
#H  @(#)$Id: anupqi.gi,v 1.15 2005/08/25 14:20:13 werner Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqi_gi :=
    "@(#)$Id: anupqi.gi,v 1.15 2005/08/25 14:20:13 werner Exp $";

#############################################################################
##
#F  PQ_UNBIND( <datarec>, <fields> ) . . . . . unbind fields of a data record
##
##  unbinds the fields in the list <fields> of that data record <datarec>.
##
InstallGlobalFunction( PQ_UNBIND, function( datarec, fields )
local field;
  for field in fields do
    Unbind( datarec.(field) );
  od;
end );

#############################################################################
##
#F  PQ_AUT_GROUP( <G> ) . . . . . . . . . . . . . . . . .  automorphism group
##
##  returns the automorphism group of  a  $p$-group  as  a  record,  avoiding
##  computation if possible (currently it *isn't*  possible),  or  else  uses
##  {\AutPGrp}'s `AutomorphismGroupPGroup'.
##
InstallGlobalFunction( PQ_AUT_GROUP, function( G )

  local autgrp;

  if not IsPGroup(G) then
      Error("group <G> must be a p-group\n");
  fi;
  if false and HasANUPQAutomorphisms(G) then
      # Can't use this because we currently don't know how to interpret
      # the automorphism information returned by the standalone properly.

      autgrp := PqSupplementInnerAutomorphisms(G);
    
  elif false and HasAutomorphismGroup(G) then

      # Can't use existing automorphism information because it does not
      # contain the information required by the standalone.

      autgrp := AutomorphismGroup( G );

  elif RequirePackage("autpgrp") = true or IsAbelian(G) then

      autgrp := AutomorphismGroupPGroup(G);

  else
      return Error( "since package `AutPGrp' is not installed\n",
                    "<G> must have class 1 or <G>'s aut. group must be known.\n",
                    "Please install the `AutPGrp' package\n" );
  fi;
  return autgrp;
end );

#############################################################################
##
#F  PQ_AUT_INPUT( <datarec>, <G> : <options> ) . . . . . . automorphism input
##
##  inputs automorphism data for `<datarec>.group' given by <options> to  the
##  `pq' binary derived from the pc group  <G>  (used  in  option  1  of  the
##  $p$-Group Generation menu and option 2 of the Standard Presentation menu).
##
InstallGlobalFunction( PQ_AUT_INPUT, function( datarec, G )

  local   autrec,  nrautos,  rank,  gens,  i,  aut,  j,  g, exponents;
    
  autrec  := PQ_AUT_GROUP( G );
  nrautos := Length( autrec.glAutos ) + Length( autrec.agAutos );

  ## the automorphisms have to be in a special form which PQ_AUT_GROUP()
  ## *must* deliver.
  
  rank := RankPGroup( G );
  gens := PcgsPCentralSeriesPGroup( G );

  ToPQ(datarec, [ nrautos ], [ "  #number of automorphisms" ]);

  ##  First write out the automorphisms generating a soluble normal subgroup 
  ##  of the automorphism group of the p-group.  These automorphisms may
  ##  not have a faithful representation on the Frattini quotient of the
  ##  p-group and are treated accordingly by the standalone.
  ##
  ##  They are written out in bottom up fashion as this is the order in
  ##  which the orbit algorithm for a group given by an ag-system needs
  ##  them.  
  for i in Reversed([1..Length(autrec.agAutos)]) do
      aut := autrec.agAutos[i];

      for j in [1..rank] do
          g := gens[j];
          exponents := Flat( List( ExponentsOfPcElement(gens, Image( aut, g )),
                                   e -> [ String(e), " "] ) );

          ToPQ(datarec, [ exponents ],
               [ " #gen'r exp'ts of im(ag aut ", i, ", gen ", j, ")" ]);
      od;
  od;

  ##  Now output the automorphisms from the insoluble quotient of the
  ##  automorphism group of the p-group.  These have a faithful
  ##  representation on the Frattini quotient of the p-group and are
  ##  treated accordingly by the standalone.
  for i in Reversed( [1..Length(autrec.glAutos)] ) do
      aut := autrec.glAutos[i];

      for j in [1..rank] do
          g := gens[j];
          exponents := Flat( List( ExponentsOfPcElement(gens, Image( aut, g )),
                                   e -> [ String(e), " "] ) );

          ToPQ(datarec, [ exponents ],
               [ " #gen'r exp'ts of im(gl aut ", i, ", gen ", j, ")" ]);
      od;
  od;

  if PQ_MENU(datarec) = "pG" then
      ##  ?? Why only the pG menu ??
      ##  Finally, tell the standalone the number of soluble automorphisms
      ##  and the relative order of each automorphism. 
      ToPQ(datarec, [ Length(autrec.agOrder) ], 
           [ "  #number of soluble automorphisms" ]);
    
      for i in Reversed( [1..Length( autrec.agOrder )] ) do
          ToPQ( datarec, [ autrec.agOrder[i] ], 
                [ "  #rel order of ", i, "th ag automorphism" ] );
      od;
  fi;

end );

#############################################################################
##
#F  PQ_MANUAL_AUT_INPUT(<datarec>,<mlist>) . automorphism input w/o an Aut gp
##
##  inputs automorphism data for `<datarec>.group' given by  <mlist>  to  the
##  `pq' binary.
##
InstallGlobalFunction( PQ_MANUAL_AUT_INPUT, function( datarec, mlist )
local line, nauts, nsolauts, rank, nexpts, i, j, aut, exponents;
  nauts  := Length(mlist);
  rank   := Length(mlist[1]);
  ToPQ(datarec, [ nauts ], [ "  #no. of auts" ]);
  if datarec.line = "Input the number of exponents: " then
    nexpts := Length(mlist[1][1]);
    ToPQ(datarec, [ nexpts ], [ "  #no. of exponents" ]);
  fi;
  for i in [1..nauts] do
    aut := mlist[i];
    for j in [1..rank] do
      exponents := Flat( List( aut[j], e -> [ String(e), " "] ) );
      ToPQ(datarec, [ exponents ], 
                    [ " #gen'r exp'ts of im(aut ", i, ", gen ", j, ")" ]);
    od;
  od;
  if PQ_MENU(datarec) = "pG" then
    ##  ?? Why only the pG menu ??
    ##  Finally, tell the standalone the number of soluble automorphisms
    ##  and the relative order of each automorphism. 
    ToPQ(datarec, [ datarec.NumberOfSolubleAutomorphisms ], 
                  [ "  #number of soluble automorphisms" ]);
    if datarec.NumberOfSolubleAutomorphisms > 0 then
      for i in datarec.RelativeOrders do
        ToPQ( datarec, [ datarec.RelativeOrders[i] ], 
                       [ "  #rel order of ", i, "th ag automorphism" ] );
      od;
    fi;
  fi;
end );

#############################################################################
##
#F  PQ_AUT_ARG_CHK(<minnargs>, <args>) . checks args for a func defining auts
##
##  checks that  the  arguments  make  sense  for  a  function  that  defines
##  automorphisms, and if one fo the arguments is a list checks as much as is
##  possible that it is a list of  matrices  that  will  be  valid  input  as
##  automorphisms for the `pq' binary.  If  the  arguments  look  ok  a  list
##  containing the `ANUPQData.io' index of the data record and, if  relevant,
##  a list of matrices is returned.
##
InstallGlobalFunction( PQ_AUT_ARG_CHK, function( minnargs, args )
local ioIndex, datarec, mlist, rank, nexpts;
  if Length(args) < minnargs then
    Error("expected at least 1 argument\n"); #minnargs is 0 or 1
  elif 2 < Length(args) then
    Error("expected at most 2 arguments\n");
  fi;
  if not IsEmpty(args) and IsList(args[ Length(args) ]) then
    mlist := args[ Length(args) ];
    args := args{[1 .. Length(args) - 1]};
  fi;
  ioIndex := CallFuncList(PqProcessIndex, args);
  if not IsBound(mlist) then
    return [ioIndex];
  elif not( IsList(mlist) and ForAll(mlist, IsMatrix) and
            ForAll(Flat(mlist), i -> IsInt(i) and i >= 0) ) then
    Error("<mlist> must be a list of matrices with ",
          "non-negative integer coefficients\n");
  fi;
  datarec := ANUPQData.io[ ioIndex ];
  if IsBound( datarec.pQuotient ) then
    rank := RankPGroup( datarec.pQuotient );
  else
    rank := Length(mlist[1]); # Should we allow this?
  fi;
  if not ForAll(mlist, mat -> Length(mat) = rank) then
    Error("no. of rows in each matrix of <mlist> must be the rank of ",
          "p-quotient (", rank, ")\n");
  fi;
  nexpts := Length(mlist[1][1]);
  if not ForAll(mlist, mat -> Length(mat[1]) = nexpts) then
    Error("each matrix of <mlist> must have the same no. of columns\n");
  fi;
  return [ioIndex, mlist];
end );

#############################################################################
##
#F  PQ_PC_PRESENTATION( <datarec>, <menu> ) . . . . . .  p-Q/SP menu option 1
##
##  inputs  data  given  by  <options>  to  the   `pq'   binary   for   group
##  `<datarec>.group' to compute a  pc  presentation  (do  option  1  of  the
##  relevant menu) according to the  <menu>  menu,  where  <menu>  is  either
##  `"pQ"' (main $p$-Quotient menu) or `"SP' (Standard Presentation menu).
##
InstallGlobalFunction( PQ_PC_PRESENTATION, function( datarec, menu )
local gens, rels, p, fpgrp, identities, pcgs, len, strp, i, j, Rel, line;

  p := VALUE_PQ_OPTION("Prime", fail, datarec); # "Prime" is a `global' option

  PQ_MENU(datarec, menu);

  identities := menu = "pQ" and
                VALUE_PQ_OPTION("Identities", [], datarec) <> [];

  # Option 1 of p-Quotient/Standard Presentation Menu: defining the group
  ToPQk(datarec, [1], ["  #define group"]);
  if VALUE_PQ_OPTION("GroupName", "[grp]", datarec) = "[grp]" and
     IsBound(datarec.group) and IsBound(datarec.group!.Name) then
    datarec.GroupName := datarec.group!.Name;
  fi;
  ToPQk(datarec, ["name ",  datarec.GroupName], []);
  ToPQk(datarec, ["prime ", p], []);
  if identities then
    datarec.prevngens := 0;
    ToPQk(datarec, ["class ", 1], []);
  else
    ToPQk(datarec, ["class ", VALUE_PQ_OPTION("ClassBound", 63, datarec)], []);
  fi;
  ToPQk(datarec, ["exponent ", VALUE_PQ_OPTION("Exponent", 0, datarec)], []);
                                             # "Exponent" is a `global' option
  if VALUE_PQ_OPTION( "Metabelian", false, datarec ) = true then
    ToPQk(datarec, [ "metabelian" ], []);
  fi;
  ToPQk(datarec, ["output ", VALUE_PQ_OPTION("OutputLevel", 0, datarec)], []);

  if IsFpGroup(datarec.group) then
    gens := FreeGeneratorsOfFpGroup(datarec.group);
    rels := VALUE_PQ_OPTION("Relators", datarec);
    if rels = fail then
      rels := RelatorsOfFpGroup(datarec.group);
    elif ForAll( rels, rel -> PqParseWord(datarec.group, rel) ) then
      Info(InfoANUPQ, 2, "Relators parsed ok.");
    fi;
  elif not( IsPGroup(datarec.group) ) then
    fpgrp := FpGroupPcGroup( datarec.group );
    gens := FreeGeneratorsOfFpGroup(fpgrp);
    rels := RelatorsOfFpGroup(fpgrp);
  else
    pcgs := PcgsPCentralSeriesPGroup(datarec.group);
    len  := Length(pcgs);
    gens := List( [1..len], i -> Concatenation( "g", String(i) ) );
    strp := String(p);

    Rel := function(elt, eltstr)
      local rel, expts, factors;

      rel := eltstr;
      expts := ExponentsOfPcElement( pcgs, elt );
      if ForAny( expts, x -> x<>0 )  then
        factors 
            := Filtered(
                   List( [1..len], 
                         function(i)
                           if expts[i] = 0 then
                             return "";
                           fi;
                           return Concatenation(gens[i], "^", String(expts[i]));
                         end ),
                   factor -> factor <> "");
        Append(rel, "=");
        Append(rel, JoinStringsWithSeparator(factors, "*"));
      fi;
      return rel;
    end;

    rels := List( [1..len], 
                  i -> Rel( pcgs[i]^p, Concatenation(gens[i], "^", strp) ) );
    for i in [1..len] do
      for j in [1..i-1]  do
        Add(rels, Rel( Comm( pcgs[i], pcgs[j] ), 
                       Concatenation("[", gens[i], ",", gens[j], "]") ));
      od;
    od;
  fi;
  if Length(gens) > 511 then
    # The pq program defines MAXGENS to be 511 in `../include/runtime.h'
    # ... on the other hand, the number of pc gen'rs can be up to 65535
    Error("number of defining generators, ", Length(gens), ", too large.\n",
          "The pq program defines MAXGENS (the maximum number of defining\n",
          "generators) to be 511.\n");
  fi;
  datarec.gens := gens;
  datarec.rels := rels;
  ToPQk(datarec, "gens", []);
  datarec.match := true;
  ToPQ(datarec, "rels", []);
  ## pq is intolerant of long lines and integers that are split over lines
  #rels := Concatenation(
  #            "relators   { ", JoinStringsWithSeparator( rels, ", " ), " };");
  #while Length(rels) >= 69 do
  #  i := 68;
  #  while not (rels[i] in "*^, ") do i := i - 1; od;
  #  ToPQk(datarec, [ rels{[1 .. i]} ], []);
  #  rels := Concatenation( "  ", rels{[i + 1 .. Length(rels)]} );
  #od;
  #ToPQ(datarec, [ rels ], []);
  datarec.haspcp := true;
  # The `pq' only sets OutputLevel locally within the menu item
  # ... for the GAP interface this would be too confusing; so we
  # set it `globally'
  PQ_SET_OUTPUT_LEVEL(datarec, datarec.OutputLevel);
  PQ_SET_GRP_DATA(datarec);
  if identities and datarec.ngens[1] <> 0 then
    PQ_EVALUATE_IDENTITIES(datarec);
    VALUE_PQ_OPTION("ClassBound", 63, datarec);
    while datarec.class < datarec.ClassBound and 
          datarec.prevngens <> datarec.ngens[ datarec.class ] do
      PQ_NEXT_CLASS(datarec);
    od;
  fi;
end );

#############################################################################
##
#F  PqPcPresentation( <i> : <options> ) . . user version of p-Q menu option 1
#F  PqPcPresentation( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to compute the pc presentation  of  the  quotient  (determined  by
##  <options>) of the group of the process, which for process <i>  is  stored
##  as `ANUPQData.io[<i>].group'.
##
##  The  possible  <options>  are  the  same  as  for  the  interactive  `Pq'
##  (see~"Pq!interactive")   function,   namely:    `Prime',    `ClassBound',
##  `Exponent', `Relators', `GroupName', `Metabelian' and `OutputLevel'  (see
##  Chapter~"ANUPQ options" for a detailed description  for  these  options).
##  The option `Prime' is required  unless  already  provided  to  `PqStart'.
##  Also, option `ClassBound' *must* be supplied.
##
##  *Notes*
##
##  The pc presentation is held by the `pq' binary. There is no output  of  a
##  {\GAP} pc group; see~`PqCurrentGroup' ("PqCurrentGroup") if you need  the
##  corresponding {\GAP} pc group.
##
##  For those familiar with the `pq' binary, `PqPcPresentation' performs menu
##  item 1 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqPcPresentation, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqPcPresentation", true);
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_PC_PRESENTATION( datarec, "pQ" );
end );

#############################################################################
##
#F  PQ_SAVE_PC_PRESENTATION( <datarec>, <filename> ) . . .  p-Q menu option 2
##
##  directs the `pq' binary to save the pc presentation  previously  computed
##  for  `<datarec>.group'  to  <filename>  using  option  2  of   the   main
##  $p$-Quotient menu.
##
InstallGlobalFunction( PQ_SAVE_PC_PRESENTATION, function( datarec, filename )
  PQ_MENU(datarec, "pQ");
  ToPQ(datarec, [ 2 ], [ "  #save pc presentation to file" ]);
  datarec.filter := ["Presentation"];
  ToPQ(datarec, [ filename ], [ "  #filename" ]);
  Unbind(datarec.filter);
end );

#############################################################################
##
#F  PQ_PATH_CURRENT_DIRECTORY() . . . . . . . . . .  essentially the UNIX pwd
##
##  returns a string that is the path of the current directory.
##
InstallGlobalFunction( PQ_PATH_CURRENT_DIRECTORY, function()
local path, stream;
  path := "";
  stream := OutputTextString(path, true);
  if 0 = Process( DirectoryCurrent(), 
                  Filename(DirectoriesSystemPrograms(), "pwd"),
                  InputTextNone(), 
                  stream,
                  [] ) then
    CloseStream(stream);
    return Chomp(path);
  fi;
  Error("could not determine the path of the current directory!?!\n");
end );

#############################################################################
##
#F  PQ_CHK_PATH(<filename>, <rw>, <datarec>) . . . . . . .  check/add to path
##
##  checks <filename> is a non-empty string, if it doesn't begin with  a  `/'
##  prepends a path for the current directory, and checks the result  is  the
##  name of a readable (resp. writable) if <rw> is `"r"' (resp.  if  <rw>  is
##  `"w"') and if there is no error returns the result.
##
InstallGlobalFunction( PQ_CHK_PATH, function( filename, rw, datarec )
  if not IsString(filename) or filename = "" then
    Error( "argument <filename> must be a non-empty string\n" );
  fi;
  if filename[1] <> '/' then
    # we need to do this as pq executes in ANUPQData.tmpdir
    filename := Concatenation(PQ_PATH_CURRENT_DIRECTORY(), "/", filename);
  fi;
  if rw = "r" then
    if IsReadableFile(filename) <> true then
      Error( "file with name <filename> is not readable\n" );
    fi;
  else # rw = "w"
    if not IsBound(datarec.setupfile) then
      PrintTo(filename, ""); # This is what will generate the error
                             # but it also ensures it's empty
    fi;
    if IsWritableFile(filename) <> true then
      Error( "file with name <filename> cannot be written to\n" );
    fi;
  fi;
  return filename;
end );

#############################################################################
##
#F  PqSavePcPresentation( <i>, <filename> ) . .  user ver. of p-Q menu opt. 2
#F  PqSavePcPresentation( <filename> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  program to save the pc presentation previously computed for the  quotient
##  of the group of that process to the file with  name  <filename>.  If  the
##  first character of the  string  <filename>  is  not  `/',  <filename>  is
##  assumed to be the path of a writable file relative to  the  directory  in
##  which  {\GAP}  was  started.  A   saved   file   may   be   restored   by
##  `PqRestorePcPresentation' (see~"PqRestorePcPresentation").
##
##  *Note:* For those familiar with the `pq'  binary,  `PqSavePcPresentation'
##  performs menu item 2 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqSavePcPresentation, function( arg )
local datarec, filename;
  if 0 = Length(arg) or Length(arg) > 2 then
    Error( "expected 1 or 2 arguments\n" );
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg{[1..Length(arg) - 1]});
  filename := PQ_CHK_PATH( arg[Length(arg)], "w", datarec );
  PQ_SAVE_PC_PRESENTATION( datarec, filename );
end );

#############################################################################
##
#F  PQ_RESTORE_PC_PRESENTATION( <datarec>, <filename> ) . . p-Q menu option 3
##
##  directs the `pq' binary to restore the pc presentation  previously  saved
##  to <filename> using option 3 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PQ_RESTORE_PC_PRESENTATION, function( datarec, filename )
  PQ_MENU(datarec, "pQ");
  ToPQ(datarec, [ 3 ], [ "  #restore pc presentation from file" ]);
  datarec.match := true;
  ToPQ(datarec, [ filename ], [ "  #filename" ]);
  datarec.haspcp := true;
  PQ_SET_GRP_DATA(datarec);
end );

#############################################################################
##
#F  PqRestorePcPresentation( <i>, <filename> ) . user ver. of p-Q menu opt. 3
#F  PqRestorePcPresentation( <filename> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  program to restore the pc presentation previously saved to <filename>, by
##  `PqSavePcPresentation'   (see~"PqSavePcPresentation").   If   the   first
##  character of the string <filename> is not `/', <filename> is  assumed  to
##  be the path of a readable file relative to the directory in which  {\GAP}
##  was started.
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqRestorePcPresentation'
##  performs menu item 3 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqRestorePcPresentation, function( arg )
local datarec, filename;
  if 0 = Length(arg) or Length(arg) > 2 then
    Error( "expected 1 or 2 arguments\n" );
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg{[1..Length(arg) - 1]});
  filename := PQ_CHK_PATH( arg[Length(arg)], "r", datarec );
  PQ_RESTORE_PC_PRESENTATION( datarec, filename );
end );

#############################################################################
##
#F  PQ_DISPLAY_PRESENTATION( <datarec> ) . . . . . . . . .  any menu option 4
##
##  directs the `pq' binary to display the pc presentation of  the  group  to
##  the current class, using option 4 of the current menu.
##
InstallGlobalFunction( PQ_DISPLAY_PRESENTATION, function( datarec )
  if datarec.menu[ Length(datarec.menu) ] <> 'G' and
     VALUE_PQ_OPTION("OutputLevel", datarec) <> fail then
    PQ_SET_OUTPUT_LEVEL( datarec, datarec.OutputLevel );
  fi;
  ToPQ(datarec, [ 4 ], [ "  #display presentation" ]);
end );

#############################################################################
##
#F  PQ_GRP_EXISTS_CHK( <datarec> ) . . check the `pq' binary knows about a gp
##
##  checks that `<datarec>.ngens' is set and non-empty (which can only happen
##  if the `pq' binary has been fed a group) and generates an error if not.
##
InstallGlobalFunction( PQ_GRP_EXISTS_CHK, function( datarec )
  if not IsBound(datarec.ngens) or IsEmpty(datarec.ngens) then
    Error( "huh! No current group defined for this process!?\n" );
  fi;
end );

#############################################################################
##
#F  PQ_SET_GRP_DATA( <datarec> ) .  save group data of current class of group
##
##  If `<datarec>.matchedline' is not  set  the  `pq'  binary  is  called  to
##  display the presentation; usually  `<datarec>.matchedline'  is  set  when
##  filtering `pq' output for lines starting with `"Group"' (the  value  set
##  for `<datarec>.match'), but no such  lines  occur  when  computing  a  pc
##  presentation with the `OutputLevel' option set to 0, or when restoring  a
##  pc presentation, or when computing tails etc. From this line  the  fields
##  `name', `class' and `forder' of the record <datarec> are set to the name,
##  class  and  factored   order   of   that   group,   respectively.   Also,
##  `<datarec>.ngens' is updated, and if it is afterwards incomplete and  the
##  call to `PQ_SET_GRP_DATA' was not initiated by `PQ_DATA'  then  `PQ_DATA'
##  is called to ensure `<datarec>.ngens' is complete.
##
InstallGlobalFunction( PQ_SET_GRP_DATA, function( datarec )
local line, classpos;
  if IsBound(datarec.setupfile) then 
    # A fudge ... some things we can only know by actually running it!
    Info(InfoANUPQ + InfoWarning,1, 
         "Guess made of `class' and `ngens' fields");
    Info(InfoANUPQ + InfoWarning,1, 
         "... please check commands ok by running without `SetupFile' option");
    Info(InfoANUPQ + InfoWarning,1, 
         "and comparing with `ToPQ> ' commands observed at InfoANUPQ level 4");
    datarec.class := datarec.ClassBound;
    datarec.ngens := [ 1 ];
    return;
  fi;
  # Either datarec.matchedline is of one of the following forms:
  # Group completed. Lower exponent-<p> central class = <c>, Order = <p>^<n>
  # Group: [grp] to lower exponent-<p> central class <c> has order <p>^<n>
  if not IsBound(datarec.matchedline) then
    PushOptions(rec(nonuser := true));
    ToPQ(datarec, [ 4 ], [ "  #display presentation" ]);
    PopOptions();
  fi;
  line := SplitString(datarec.matchedline, "", ":,. ^\n");
  if line[2] = "completed" then
    classpos := Position(line, "class") + 2;
    #if not IsBound(datarec.name) then #do we need to bother?
    #  datarec.name := "[grp]";
    #fi;
  else
    # Only the ``incomplete'' form of datarec.matchedline gives the name
    datarec.name := line[2];
    datarec.gpnum := JoinStringsWithSeparator( 
                         line{[3 .. Position(line, "to") - 1]}, " " );
    classpos := Position(line, "class") + 1;
  fi;
  datarec.class  := Int( line[classpos] );
  datarec.forder := List( line{[classpos + 3, classpos + 4]}, Int);
  PQ_UNBIND(datarec, ["match", "matchedline"]);
  # First see if we can update datarec.ngens cheaply
  if not IsBound(datarec.ngens) then
    datarec.ngens := [];
  fi;
  if datarec.class > 0 then
    datarec.ngens[ datarec.class ] := datarec.forder[2];
    #The `pq' binary reduces the class by 1 
    #if the no. of gen'rs doesn't increase
    Unbind( datarec.ngens[ datarec.class + 1 ] );
  fi;

  if not IsBound(datarec.inPQ_DATA) and not IsDenseList(datarec.ngens) then
    # It wasn't possible to update datarec.ngens cheaply
    PQ_DATA( datarec );
  fi;
end );

#############################################################################
##
#F  PQ_DATA( <datarec> ) . . . . gets class/gen'r data from (A)p-Q menu opt 4
##
##  ensures that the menu is a $p$-Quotient menu and that the output level is
##  3 and using option 4 of the now  current  menu  extracts  the  number  of
##  generators of each class currently known to the `pq' binary.  (The  order
##  of each $p$-class quotient is taken as $p^n$ where $n$ is the  number  of
##  generators for the class; this may be an over-estimate if tails have been
##  added  and  the  necessary  consistency  checks,  relation   collections,
##  exponent law checks and redundant generator eliminations  have  not  been
##  done for a class.) All output that would  have  appeared  at  `InfoANUPQ'
##  levels 1 or 2 if user-initiated is `Info'-ed at `InfoANUPQ' level 3.  The
##  menu and output level are reset to their original values (if changed)  on
##  leaving.
##
InstallGlobalFunction( PQ_DATA, function( datarec )
local menu, lev, ngen, i, line, class;
  if not( IsBound(datarec.haspcp) and datarec.haspcp ) then
    Error( "a pc presentation for the group of the process ",
           "has not yet been defined\n" );
  fi;
  PushOptions(rec(nonuser := true));
  datarec.inPQ_DATA := true;
  if datarec.menu[ Length(datarec.menu) ] <> 'Q' then
    menu := datarec.menu;
    PQ_MENU(datarec, "pQ");
  fi;
  if not IsBound(datarec.OutputLevel) then
    lev := 0;
    PQ_SET_OUTPUT_LEVEL( datarec, 3 );
  elif datarec.OutputLevel < 3 then
    lev := datarec.OutputLevel;
    PQ_SET_OUTPUT_LEVEL( datarec, 3 );
  fi;
  datarec.matchlist := ["Group", "Class", " is defined on "];
  datarec.matchedlines := [];
  ToPQ(datarec, [ 4 ], [ "  #display presentation" ]);
  datarec.matchedline := datarec.matchedlines[1];
  PQ_SET_GRP_DATA(datarec);
  for i in [2 .. Length(datarec.matchedlines)] do
    line := SplitString(datarec.matchedlines[i], "", " \n");
    if line[1] = "Class" then
      class := Int( line[2] );
      if class > 1 then
        datarec.ngens[class - 1] := Int(ngen);
        if class = datarec.class then
          break;
        fi;
      fi;
    else
      ngen := line[1];
    fi;
  od;
  if IsBound(menu) then
    PQ_MENU(datarec, menu);
  fi;
  if IsBound(lev) then
    PQ_SET_OUTPUT_LEVEL( datarec, lev );
  fi;
  PQ_UNBIND( datarec, ["matchlist", "matchedlines", "inPQ_DATA"] );
  PopOptions();
end );

#############################################################################
##
#F  PQ_DATA_CHK( <args> ) . . .  call PQ_DATA if class/gen'r data out-of-date
##
##  determines the data record <datarec>, calls `PQ_DATA'  if  necessary  and
##  returns <datarec>.
##
InstallGlobalFunction( PQ_DATA_CHK, function( args )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, args);
  if not IsBound(datarec.ngens) or IsEmpty(datarec.ngens) or 
     not IsDenseList(datarec.ngens) then
    PQ_DATA( datarec );
  fi;
  return datarec;
end );

#############################################################################
##
#F  PqFactoredOrder( <i> ) . the `pq' binary's current group's factored order
#F  PqFactoredOrder()
##
##  for the <i>th or default interactive {\ANUPQ} process, return an estimate
##  of the factored order of the lower exponent  $p$-class  quotient  of  the
##  group currently determined by the process as a list `[<p>, <n> ]'.
##
##  *Note:* The order of each $p$-class quotient is taken as $p^n$ where  $n$
##  is the number of generators for the class; this may be  an  over-estimate
##  if tails have been added and the necessary consistency  checks,  relation
##  collections, exponent law checks  and  redundant  generator  eliminations
##  have not yet been done for a class.
##
InstallGlobalFunction( PqFactoredOrder, function( arg )
  return PQ_DATA_CHK(arg).forder;
end );

#############################################################################
##
#F  PqOrder( <i> ) . . . .  the order of the current group of the `pq' binary
#F  PqOrder()
##
##  for the <i>th or default interactive {\ANUPQ} process, return an estimate
##  of the order of the  lower  exponent  $p$-class  quotient  of  the  group
##  currently determined by the process.
##
##  *Note:* The order of each $p$-class quotient is taken as $p^n$ where  $n$
##  is the number of generators for the class; this may be  an  over-estimate
##  if tails have been added and the necessary consistency  checks,  relation
##  collections, exponent law checks  and  redundant  generator  eliminations
##  have not been done for a class.
##
InstallGlobalFunction( PqOrder, function( arg )
local forder;
  forder := CallFuncList( PqFactoredOrder, arg );
  return forder[1]^forder[2];
end );

#############################################################################
##
#F  PqPClass( <i> ) . . . the p class of the current group of the `pq' binary
#F  PqPClass()
##
##  for the <i>th or default interactive {\ANUPQ} process, return  the  lower
##  exponent $p$-class of the quotient  group  currently  determined  by  the
##  process.
##
InstallGlobalFunction( PqPClass, function( arg )
  return PQ_DATA_CHK(arg).class;
end );

#############################################################################
##
#F  PqNrPcGenerators( <i> ) . number of pc gen'rs of `pq' binary's current gp
#F  PqNrPcGenerators()
##
##  for the <i>th or default interactive {\ANUPQ} process, return the  number
##  of pc generators of the lower exponent $p$-class quotient  of  the  group
##  currently determined by the process.
##
InstallGlobalFunction( PqNrPcGenerators, function( arg )
  return PQ_DATA_CHK(arg).forder[2];
end );

#############################################################################
##
#F  PqWeight( <i>, <j> ) . . . . . . . . . . . . . . .  weight of a generator
#F  PqWeight( <j> )
##
##  for the <i>th or default interactive {\ANUPQ} process, return the  weight
##  of the <j>th pc generator of the lower exponent $p$-class quotient of the
##  group currently determined by the process, or `fail' if there is no  such
##  numbered pc generator.
##
InstallGlobalFunction( PqWeight, function( arg )
local ngens, i, j;
  if not Length(arg) in [1, 2] then
    Error( "expected 1 or 2 arguments\n" );
  fi;
  j := arg[ Length(arg) ];
  if not IsPosInt(j) then
    Error( "argument <j> should be a positive integer\n" );
  fi;
  Unbind( arg[ Length(arg) ] );
  ngens := PQ_DATA_CHK(arg).ngens;
  return First([1 .. Length(ngens)], i -> ngens[i] >= j);
end );

#############################################################################
##
#F  PqCurrentGroup( <i> ) . extracts current p-quotient or p-cover as a pc gp
#F  PqCurrentGroup()
##
##  for the <i>th or default interactive {\ANUPQ} process, return  the  lower
##  exponent $p$-class quotient of the group or $p$-covering group  currently
##  determined by the process as a {\GAP} pc group.
##
InstallGlobalFunction( PqCurrentGroup, function( arg )
local datarec, out;
  datarec := PQ_DATA_CHK(arg);
  datarec.outfname := ANUPQData.outfile;
  PushOptions( rec(nonuser := true) );
  PQ_WRITE_PC_PRESENTATION(datarec, datarec.outfname);
  PopOptions();
  if IsBound(datarec.pcoverclass) and datarec.pcoverclass = datarec.class then
    out := "pCover";
  else
    out := "pQuotient";
  fi;
  PQ_GROUP_FROM_PCP( datarec, out );
  return datarec.(out);
end );

#############################################################################
##
#F  PqDisplayPcPresentation( <i> ) . . . .  user version of any menu option 4
#F  PqDisplayPcPresentation()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to display the pc presentation of  the  lower  exponent  $p$-class
##  quotient of the group currently determined by the process.
##
##  Except if the last command communicating  with  the  `pq'  binary  was  a
##  $p$-group generation command (for which there is only  a  verbose  output
##  level), to set the amount of information this command  displays  you  may
##  wish  to  call  `PqSetOutputLevel'  first  (see~"PqSetOutputLevel"),   or
##  equivalently pass the option `OutputLevel' (see~"option OutputLevel").
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqDisplayPcPresentation'
##  performs menu item 4 of the current menu of the `pq' binary.
##
InstallGlobalFunction( PqDisplayPcPresentation, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_GRP_EXISTS_CHK( datarec );
  PQ_DISPLAY_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_SET_OUTPUT_LEVEL(<datarec>, <lev>) . . . .  p-Q/SP/A p-Q menu option 5
##
##  inputs data to the `pq' binary to set the print level  to  <lev>  in  the
##  current menu or the ``basic'' $p$-Quotient menu if the current menu is  a
##  $p$-Group generation menu.
##
InstallGlobalFunction( PQ_SET_OUTPUT_LEVEL, function( datarec, lev )
  if datarec.menu[ Length(datarec.menu) ] = 'G' then
    PQ_MENU(datarec, "pQ");
  fi;
  ToPQ(datarec, [ 5 ], [ "  #set output level" ]);
  ToPQ(datarec, [ lev ], [ "  #output level" ]);
  datarec.OutputLevel := lev;
end );

#############################################################################
##
#F  PqSetOutputLevel( <i>, <lev> ) .  user version of p-Q/SP/A p-Q menu opt 5
#F  PqSetOutputLevel( <lev> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to set the output level of the `pq' binary to <lev>.
##
##  *Note:* For those  familiar  with  the  `pq'  binary,  `PqSetOutputLevel'
##  performs menu item 5 of the main (or advanced) $p$-Quotient menu, or  the
##  Standard Presentation menu.
##
InstallGlobalFunction( PqSetOutputLevel, function( arg )
local datarec, lev;
  if not(Length(arg) in [1, 2]) then
    Error( "1 or 2 arguments expected\n");
  fi;
  lev := arg[Length(arg)];
  if not(lev in [0..3]) then
    Error( "argument <lev> should be an integer in [0 .. 3]\n" );
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg{[1..Length(arg) - 1]});
  PQ_SET_OUTPUT_LEVEL( datarec, lev);
end );

#############################################################################
##
#F  PQ_NEXT_CLASS( <datarec> ) . . . . . . . . . . . . . .  p-Q menu option 6
##
##  directs the `pq' binary to calculate the next class of `<datarec>.group',
##  using option 6 of the main $p$-Quotient menu.
##
#T  Another possibility for checking for whether a queue factor is needed
#T  is to test for `<datarec>.hasAuts'.
##
InstallGlobalFunction( PQ_NEXT_CLASS, function( datarec )
local line;
  PQ_MENU(datarec, "pQ");
  PQ_UNBIND(datarec, ["pQuotient", "pQepi", "pCover"]);
  if VALUE_PQ_OPTION("Identities", [], datarec) <> [] then
    if datarec.class >= 1 then
      datarec.prevngens := datarec.ngens[ datarec.class ];
    fi;
    PQ_P_COVER(datarec);
    PQ_FINISH_NEXT_CLASS(datarec);
  else
    datarec.match := true;
    ToPQ(datarec, [ 6 ], [ "  #calculate next class" ]);
    if IsMatchingSublist(datarec.line, "Input queue factor:") then
      ToPQ(datarec, [ VALUE_PQ_OPTION("QueueFactor", 15) ],
                    [ " #queue factor"]);
    fi;
    PQ_SET_GRP_DATA(datarec);
  fi;
end );

#############################################################################
##
#F  PqNextClass( <i> [: <option>]) . . . .  user version of p-Q menu option 6
#F  PqNextClass( [: <option>])
##
##  for the <i>th or default interactive {\ANUPQ} process, direct the `pq' to
##  calculate the next class of `ANUPQData.io[<i>].group'.
##
##  \atindex{option QueueFactor}{@option \noexpand`QueueFactor'}
##  `PqNextClass'  accepts  the  option   `QueueFactor'   (see   also~"option
##  QueueFactor") which should be a positive integer  if  automorphisms  have
##  been previously supplied. If the `pq' binary requires a queue factor  and
##  none is supplied via the option `QueueFactor' a default of 15 is taken.
##
##  *Notes*
##
##  The single command: `PqNextClass(<i>);' is equivalent to executing
##
##  \){\kernttindent}PqSetupTablesForNextClass(<i>);
##  \){\kernttindent}PqTails(<i>, 0);
##  \){\kernttindent}PqDoConsistencyChecks(<i>, 0, 0);
##  \){\kernttindent}PqCollectDefiningRelations(<i>);
##  \){\kernttindent}PqDoExponentChecks(<i>);
##  \){\kernttindent}PqEliminateRedundantGenerators(<i>);
##
##  For those familiar with the `pq' binary, `PqNextClass' performs menu item
##  6 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqNextClass, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqNextClass", true);
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_GRP_EXISTS_CHK( datarec );
  PQ_NEXT_CLASS( datarec );
end );

#############################################################################
##
#F  PQ_P_COVER( <datarec> ) . . . . . . . . . . . . . . . . p-Q menu option 7
##
##  directs  the  `pq'  binary  to  compute   the   $p$-covering   group   of
##  `<datarec>.group', using option 7 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PQ_P_COVER, function( datarec )
local savefile;
  PQ_MENU(datarec, "pQ");
  Unbind( datarec.pCover );
  datarec.match := true;
  ToPQ(datarec, [ 7 ], [ "  #compute p-cover" ]);
  PQ_SET_GRP_DATA(datarec);
  datarec.pcoverclass := datarec.class;
  Unbind(datarec.capable);
end );

#############################################################################
##
#F  PqComputePCover( <i> ) . . . . . . . .  user version of p-Q menu option 7
#F  PqComputePCover()
##
##  for the <i>th or default interactive {\ANUPQ} process, direct the `pq' to
##  compute the $p$-covering group of `ANUPQData.io[<i>].group'.
##
##  *Notes*
##
##  The single command: `PqComputePCover(<i>);' is equivalent to executing
##
##  \){\kernttindent}PqSetupTablesForNextClass(<i>);
##  \){\kernttindent}PqTails(<i>, 0);
##  \){\kernttindent}PqDoConsistencyChecks(<i>, 0, 0);
##  \){\kernttindent}PqEliminateRedundantGenerators(<i>);
##
##  For those familiar with the `pq' binary, `PqComputePCover' performs  menu
##  item 7 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqComputePCover, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_GRP_EXISTS_CHK( datarec );
  PQ_P_COVER( datarec );
end );

#############################################################################
##
#F  PQ_EVALUATE_IDENTITIES(<datarec>) . evaluate Identities option identities
##
InstallGlobalFunction( PQ_EVALUATE_IDENTITIES, function( datarec )
local identity, procId;
  procId := datarec.procId;
  for identity in VALUE_PQ_OPTION("Identities", [], datarec) do
    PQ_EVALUATE_IDENTITY(procId, identity);
  od;
  PQ_ELIMINATE_REDUNDANT_GENERATORS( datarec );
  Info(InfoANUPQ, 1, "Class ", datarec.class, " with ",
                     PqNrPcGenerators(procId), " generators." );
end );

#############################################################################
##
#F  PqEvaluateIdentities( <i> ) . . . . evaluate Identities option identities
#F  PqEvaluateIdentities()
##
##  for the  <i>th  or  default  interactive  {\ANUPQ}  process,  invoke  the
##  evaluation  of  identities  defined  by  the  `Identities'  option,   and
##  eliminate any redundant pc generators formed. Since a previous  value  of
##  `Identities'  is  saved  in  the  data  record  of  the  process,  it  is
##  unnecessary to pass the `Identities' if set previously.
##
##  *Note:* This function is mainly implemented at the {\GAP} level. It  does
##  not correspond to a menu item of the `pq' program.
##
InstallGlobalFunction( PqEvaluateIdentities, function( arg )
  PQ_OTHER_OPTS_CHK("PqEvaluateIdentities", true);
  PQ_EVALUATE_IDENTITIES( CallFuncList(ANUPQDataRecord, arg) );
end );

#############################################################################
##
#F  PQ_FINISH_NEXT_CLASS( <datarec> ) . . .  take the p-cover to a next class
##
##  does the usual operations required after calculating the  <p>-cover  that
##  brings the pcp back to a next class, except that it  also  slips  in  the
##  evaluation of the identities of the `Identities' option.
##
InstallGlobalFunction( PQ_FINISH_NEXT_CLASS, function( datarec )
  PushOptions( rec(nonuser := true) );
  PQ_COLLECT_DEFINING_RELATIONS( datarec );
  PQ_DO_EXPONENT_CHECKS( datarec, [1, datarec.class] );
  PQ_EVALUATE_IDENTITIES( datarec );
  PopOptions();
end );

#############################################################################
##
#F  PQ_COLLECT( <datarec>, <word> ) . . . . . . . . . . . A p-Q menu option 1
##
##  instructs the  `pq'  binary  to  do  a  collection  on  <word>  a  string
##  representing a word in the  current  pc  generators,  e.g.  `"x3*x2*x1"',
##  using option 1 of the interactive $p$-Quotient menu.
##
InstallGlobalFunction( PQ_COLLECT, function( datarec, word )

  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 1 ], [ "  #do individual collection" ]);
  datarec.match := "The result of collection is";
  ToPQ(datarec, [ word, ";"], [ "  #word to be collected" ]);
  return PQ_WORD(datarec);
end );

#############################################################################
##
#F  PQ_CHECK_WORD( <datarec>, <wordOrList>, <ngens> ) . .  check word or list
##
##  checks that <wordOrList> is a valid word in  the  current  pc  generators
##  (<ngens> is the number of current pc  generators)  or  a  valid  list  of
##  generator number-exponent pairs that  will  generate  such  a  word,  and
##  either emits an error or returns the valid word.
##
InstallGlobalFunction( PQ_CHECK_WORD, function( datarec, wordOrList, ngens )
local parts, gens;
  if not IsList(wordOrList) or 
     not IsString(wordOrList) and 
     not ForAll(wordOrList, pair -> IsList(pair) and 2 = Length(pair) and
                                    ForAll(pair, IsInt) ) then
    Error( "argument <wordOrList> should be a string e.g. \"x3*x2^2*x1\",\n",
           "or a list of gen'r no.-exponent pairs from which such a word ",
           "may be generated\n" );
  fi;
  if IsString(wordOrList) then
    #check word makes sense
    PqParseWord(ngens, wordOrList);
    
  elif IsList(wordOrList) then
    if not ForAll(wordOrList, 
                  pair -> IsPosInt(pair[1]) and pair[1] <= ngens) then
      Error( "generator numbers in argument <wordOrList> must be in the ",
             "range: ", "[1 .. ", ngens, "]\n" );
    fi;
    wordOrList := JoinStringsWithSeparator(
                      List( wordOrList, 
                            pair -> Concatenation( "x", String(pair[1]),
                                                   "^", String(pair[2]) ) ),
                      "*" );
  fi;
  if IsEmpty(wordOrList) then
    wordOrList := "x1^0";
  fi;
  return wordOrList;
end );

#############################################################################
##
#F  PQ_WORD( <datarec> ) . . . .  parse pq output for a word in pc generators
##
##  parses `<datarec>.matchedline' for a word in the  current  pc  generators
##  and returns it as a list of gen'r no.-exponent  pairs;  `<datarec>.match'
##  must have previously been set.
##
InstallGlobalFunction( PQ_WORD, function( datarec )
local word;
  word := SplitString( datarec.matchedline{[Length(datarec.match) + 1 ..
                                            Length(datarec.matchedline)]},
                       "", " \n" );
  if word = [ "IDENTITY" ] then
    word := [];
  else
    word := List( word, 
                  function(syl)
                    syl := List( SplitString(syl, "", ".^"), Int );
                    if 1 = Length(syl) then
                      Add(syl, 1);
                    fi;
                    return syl;
                  end );
  fi;
  PQ_UNBIND(datarec, ["match", "matchedline"]);
  return word;
end );

#############################################################################
##
#F  PQ_CHK_COLLECT_COMMAND_ARGS( <args> ) . . check args for a collect cmd ok
##
##  returns a list of valid arguments for  a  low-level  collect  command  or
##  generates an error.
##
InstallGlobalFunction( PQ_CHK_COLLECT_COMMAND_ARGS, function( args )
local datarec, wordOrList, ngens;
  if IsEmpty(args) or 2 < Length(args) then
    Error( "1 or 2 arguments expected\n");
  fi;
  wordOrList := args[Length(args)];
  datarec := CallFuncList(ANUPQDataRecord, args{[1..Length(args) - 1]});
  ngens := datarec.ngens[ Length(datarec.ngens) ];
  wordOrList := PQ_CHECK_WORD(datarec, wordOrList, ngens);
  return [datarec, wordOrList];
end );

#############################################################################
##
#F  PqCollect( <i>, <word> ) . . . . . .  user version of A p-Q menu option 1
#F  PqCollect( <word> )
##
##  for the <i>th or default interactive {\ANUPQ} process, instruct the  `pq'
##  program to do a collection on <word>, a word in the current pc generators
##  (the form of <word> required is described below). `PqCollect' returns the
##  resulting word of the collection as a list of generator number,  exponent
##  pairs (the same form as the second allowed  input  form  of  <word>;  see
##  below).
##
##  The argument <word> may be input in either of the following ways:
##
##  \beginlist%ordered
##
##  \item{1.}
##  <word> may be a string, where the <i>th pc generator  is  represented  by
##  `x<i>', e.g.~`"x3*x2^2*x1"'. This way is quite versatile  as  parentheses
##  and left-normed commutators -- using square brackets, in the same way  as
##  `PqGAPRelators' (see~"PqGAPRelators") -- are permitted; <word> is checked
##  for correct syntax via `PqParseWord' (see~"PqParseWord").
##
##  \item{2.}
##  Otherwise, <word> must be a list of generator number, exponent  pairs  of
##  integers, i.e.~ each pair represents a ``syllable'' so that  `[  [3,  1],
##  [2, 2], [1, 1] ]' represents the same word as that of the  example  given
##  for the first allowed form of <word>.
##
##  \endlist
##
##  *Note:* For those familiar with the  `pq'  program,  `PqCollect'  performs
##  menu item 1 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCollect, function( arg )
  return CallFuncList( PQ_COLLECT, PQ_CHK_COLLECT_COMMAND_ARGS(arg) );
end );

#############################################################################
##
#F  PQ_SOLVE_EQUATION( <datarec>, <a>, <b> ) . . . . . .  A p-Q menu option 2
##
##  inputs data to the `pq' binary for option 2 of the Advanced  $p$-Quotient
##  menu, to solve $<a> * <x> = <b>$ for <x>.
##
InstallGlobalFunction( PQ_SOLVE_EQUATION, function( datarec, a, b )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 2 ], [ "  #solve equation" ]);
  ToPQ(datarec, [ a, ";" ], [ "  #word a" ]);
  ToPQ(datarec, [ b, ";" ], [ "  #word b" ]);
end );

#############################################################################
##
#F  PqSolveEquation( <i>, <a>, <b> ) . .  user version of A p-Q menu option 2
#F  PqSolveEquation( <a>, <b> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to solve $<a> * <x> = <b>$ for <x>.
##
##  *Note:*
##  For those familiar  with  the  `pq'  binary,  `PqSolveEquation'  performs
##  menu item 2 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSolveEquation, function( arg )
local len, datarec;
  len := Length(arg);
  if not(len in [2,3]) then
    Error("expected 2 or 3 arguments\n");
  fi;
  #@need to add argument checking for a and b@
  datarec := CallFuncList(ANUPQDataRecord, arg{[1 .. len - 2]});
  PQ_SOLVE_EQUATION( datarec, arg[len - 1], arg[len] );
end );

#############################################################################
##
#F  PQ_COMMUTATOR( <datarec>, <words>, <pow>, <item> ) . A p-Q menu opts 3/24
##
##  inputs data to the `pq' binary  for  option  3  or  24  of  the  Advanced
##  $p$-Quotient menu, to compute the left  normed  commutator  of  the  list
##  <words> of words in the generators raised to  the  integer  power  <pow>,
##  where <item> is `"3 #commutator"' for option 3  or  `"24  #commutator  of
##  defining genrs"' for option 24.
##
InstallGlobalFunction( PQ_COMMUTATOR, function( datarec, words, pow, item )
local i;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, item[1], item[2]);
  ToPQ(datarec, [ Length(words) ], [ "  #no. of components" ]);
  for i in [1..Length(words)] do
    ToPQ(datarec, [ words[i], ";" ], [ "  #word ", i ]);
  od;
  datarec.match := "The commutator is";
  ToPQ(datarec, [ pow ], [ "  #power" ]);
  return PQ_WORD(datarec);
end );

#############################################################################
##
#F  PQ_COMMUTATOR_CHK_ARGS( <args> ) . . . . check args for commutator cmd ok
##
##  returns a list of valid arguments for a low-level commutator  command  or
##  generates an error.
##
InstallGlobalFunction( PQ_COMMUTATOR_CHK_ARGS, function( args )
local len, words, pow, item, datarec, ngens;
  len := Length(args);
  if not(len in [3, 4]) then
    Error("expected 3 or 4 arguments\n");
  fi;
  words := args[len - 2];
  pow   := args[len - 1];
  item  := args[len];
  if not IsPosInt(pow) then
    Error( "argument <pow> must be a positive integer\n" );
  fi;
  datarec := CallFuncList(ANUPQDataRecord, args{[1 .. len - 3]});
  if item[1][1] = 3 then
    ngens := datarec.ngens[ Length(datarec.ngens) ];
  else
    ngens := datarec.ngens[ 1 ];
  fi;
  words := List( words, w -> PQ_CHECK_WORD(datarec, w, ngens) );
  return [datarec, words, pow, item];
end );

#############################################################################
##
#F  PqCommutator( <i>, <words>, <pow> ) . user version of A p-Q menu option 3
#F  PqCommutator( <words>, <pow> )
##
##  for  the  <i>th  or  default  interactive  {\ANUPQ}  process,  compute  a
##  user-defined commutator in the pc generators of  the  class  1  quotient,
##  i.e.~the pc generators that correspond to the original fp or pc group  of
##  the process, and return  the  result  as  a  list  of  generator  number,
##  exponent pairs. The form required for each word of <words> is the same as
##  that required for the <word> argument of  `PqCollect'  (see~"PqCollect").
##  The form of  the  output  word  is  also  the  same  as  for  `PqCollect'
##  (see~"PqCollect").
##
##  *Notes*
##
##  It is illegal for any word of <words> to contain pc generators of  weight
##  larger      than      1.      Except      for      this      distinction,
##  `PqCommutatorDefiningGenerators'   works   just    like    `PqCommutator'
##  (see~"PqCommutator"). 
##
##  For those familiar with the `pq' program, `PqCommutatorDefiningGenerators'
##  performs menu item 24 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCommutator, function( arg )
  return CallFuncList( PQ_COMMUTATOR, 
                       PQ_COMMUTATOR_CHK_ARGS( 
                           Concatenation( arg, [[[3], ["  #commutator"]]] ) ) );
end );

#############################################################################
##
#F  PQ_SETUP_TABLES_FOR_NEXT_CLASS( <datarec> ) . . . . . A p-Q menu option 6
##
##  inputs data to the `pq' binary for option 6 of the Advanced  $p$-Quotient
##  menu to set up tables for next class.
##
InstallGlobalFunction( PQ_SETUP_TABLES_FOR_NEXT_CLASS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 6 ], [ "  #set up tables for next class" ]);
  datarec.match := true;
  PQ_SET_GRP_DATA(datarec); #Just to be sure it's up-to-date
  datarec.setupclass := datarec.class;
end );

#############################################################################
##
#F  PqSetupTablesForNextClass( <i> ) . .  user version of A p-Q menu option 6
#F  PqSetupTablesForNextClass()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary  to  set  up  tables  for  the  next  class.  As  as  side-effect,
##  after   `PqSetupTablesForNextClass(<i>)'   the    value    returned    by
##  `PqPClass(<i>)' will be one more than it was previously.
##
##  *Note:*
##  For those familiar  with  the  `pq'  binary,  `PqSetupTablesForNextClass'
##  performs menu item 6 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSetupTablesForNextClass, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_SETUP_TABLES_FOR_NEXT_CLASS( datarec );
end );

#############################################################################
##
#F  PQ_INSERT_TAILS( <datarec>, <weight>, <which> )  . .  A p-Q menu option 7
##
##  inputs data to the `pq' binary for option 7 of the Advanced  $p$-Quotient
##  menu, to add and/or compute tails.
##
InstallGlobalFunction( PQ_INSERT_TAILS, function( datarec, weight, which )
local intwhich;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  intwhich := Position( [ "compute and add", "add", "compute" ], which ) - 1;
  ToPQ(datarec, [ 7 ], [ "  #", which, " tails" ]);
  ToPQ(datarec, [ weight ], [ " #weight of tails" ]);
  ToPQ(datarec, [ intwhich ], [ "  #", which ]);
  if intwhich <= 1 then
    datarec.match := true;
    PQ_SET_GRP_DATA(datarec);
  fi;
end );

#############################################################################
##
#F  PQ_CHK_TAILS_ARGS( <args> ) . . . . .  check args for insert tails cmd ok
##
InstallGlobalFunction( PQ_CHK_TAILS_ARGS, function( args )
local weight, datarec;
  if IsEmpty(args) or 2 < Length(args) then
    Error( "1 or 2 arguments expected\n");
  fi;
  weight := args[Length(args)];
  datarec := CallFuncList(ANUPQDataRecord, args{[1 .. Length(args) - 1]});
  if not IsBound(datarec.setupclass) or datarec.class <> datarec.setupclass then
    Error( "tables to start next class have not been set up.\n",
           "Please call `PqSetupTablesForNextClass' first\n" );
  fi;
  if not(weight = 0 or weight in [2 .. datarec.class]) then
    Error( "argument <weight> should be an integer in [0] U [2 .. <class>],\n",
           "where <class> is the current class (", datarec.class, ")\n" );
  fi;
  return datarec;
end );

#############################################################################
##
#F  PqAddTails( <i>, <weight> ) . . . .  adds tails using A p-Q menu option 7
#F  PqAddTails( <weight> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to add tails of weight <weight> if  <weight>  is  in  the  integer
##  range `[2 .. PqPClass(<i>)]' (assuming <i> is the number of the  process)
##  or for all weights if `<weight> = 0'. See `PqTails' ("PqTails") for  more
##  details.
##
##  *Note:*
##  For those familiar with the `pq' binary, `PqAddTails' uses menu item 7 of
##  the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqAddTails, function( arg )
  PQ_INSERT_TAILS( PQ_CHK_TAILS_ARGS(arg), arg[Length(arg)], "add" );
end );

#############################################################################
##
#F  PqComputeTails( <i>, <weight> ) . . computes tails using A p-Q menu opt 7
#F  PqComputeTails( <weight> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to compute tails of weight <weight> if <weight> is in the  integer
##  range `[2 .. PqPClass(<i>)]' (assuming <i> is the number of the  process)
##  or for all weights if `<weight> = 0'. See `PqTails' ("PqTails") for  more
##  details.
##
##  *Note:*
##  For those familiar with the `pq' binary, `PqComputeTails' uses menu  item
##  7 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqComputeTails, function( arg )
  PQ_INSERT_TAILS( PQ_CHK_TAILS_ARGS(arg), arg[Length(arg)], "compute" );
end );

#############################################################################
##
#F  PqTails( <i>, <weight> ) . computes and adds tails using A p-Q menu opt 7
#F  PqTails( <weight> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to compute and add tails of weight <weight> if <weight> is in  the
##  integer range `[2 .. PqPClass(<i>)]' (assuming <i> is the number  of  the
##  process) or for all weights if `<weight> = 0'.
##
##  If <weight> is non-zero, then tails that  introduce  new  generators  for
##  only weight <weight> are computed and added, and  in  this  case  and  if
##  `<weight> \< PqPClass(<i>)', it is assumed that the tails that  introduce
##  new  generators  for  each  weight  from  `PqPClass(<i>)'  downto  weight
##  `<weight>  +  1'  have  already  been  added.  You  may  wish   to   call
##  `PqSetMetabelian' (see~"PqSetMetabelian") prior to calling `PqTails'.
##
##  *Notes*
##
##  For its use in the context of finding the next class  see  "PqNextClass";
##  in     particular,     a     call     to      `PqSetupTablesForNextClass'
##  (see~"PqSetupTablesForNextClass")  needs  to  have  been  made  prior  to
##  calling `PqTails'.
##
##  The single command: `PqTails(<i>, <weight>);' is equivalent to
##
##  \){\kernttindent}PqComputeTails(<i>, <weight>);
##  \){\kernttindent}PqAddTails(<i>, <weight>);
##
##  For those familiar with the `pq' binary, `PqTails' uses menu  item  7  of
##  the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqTails, function( arg )
  PQ_INSERT_TAILS(PQ_CHK_TAILS_ARGS(arg), arg[Length(arg)], "compute and add");
end );

#############################################################################
##
#F  PQ_DO_CONSISTENCY_CHECKS(<datarec>, <weight>, <type>) .  A p-Q menu opt 8
##
##  inputs data to the `pq' binary for option 8 of the Advanced  $p$-Quotient
##  menu, to do consistency checks.
##
InstallGlobalFunction( PQ_DO_CONSISTENCY_CHECKS, 
function( datarec, weight, type )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 8 ], [ "  #check consistency" ]);
  ToPQ(datarec, [ weight ], [ " #weight to be checked" ]);
  ToPQ(datarec, [ type ], [ "  #type" ]);
end );

#############################################################################
##
#F  PqDoConsistencyChecks(<i>,<weight>,<type>) . user ver of A p-Q menu opt 8
#F  PqDoConsistencyChecks( <weight>, <type> )
##
##  for the <i>th or default interactive  {\ANUPQ}  process,  do  consistency
##  checks for weight <weight> if <weight> is in the  integer  range  `[3  ..
##  PqPClass(<i>)]' (assuming <i> is the number of the process)  or  for  all
##  weights if `<weight> = 0', and for type <type> if <type> is in the  range
##  `[1, 2, 3]' (see below) or for all types if `<type> = 0'. (For its use in
##  the context of finding the next class see "PqNextClass".)
##
##  The  *type*   of   a   consistency   check   is   defined   as   follows.
##  `PqDoConsistencyChecks(<i>, <weight>, <type>)' for  <weight>  in  `[3  ..
##  PqPClass(<i>)]' and the given  value  of  <type>  invokes  the  following
##  `PqJacobi' checks (see~"PqDoConsistencyCheck"):
##
##  \beginitems
##
##  `<type> = 1':&
##  `PqJacobi(<i>, <a>, <a>, <a>)' checks for  pc  generators  of  index  <a>
##  satisfying `2 * PqWeight(<i>, <a>) + 1 = <weight>'.
##
##  `<type> = 2':&
##  `PqJacobi(<i>, <b>, <b>, <a>)' checks for pc generators of  indices  <b>,
##  <a> satisfying `<b> > <a>' and `PqWeight(<i>, <b>) + PqWeight(<i>, <a>) +
##  1 = <weight>'.
##
##  `<type> = 3':&
##  `PqJacobi(<i>, <c>, <b>, <a>)' checks for pc generators of  indices  <c>,
##  <b>, <a> satisfying `<c> > <b> > <a>' and the sum of the weights of these
##  generators equals <weight>.
##
##  \enditems
##
##  *Notes*
##
##  `PqWeight(<i>, <j>)' returns the weight of the <j>th  pc  generator,  for
##  process <i> (see~"PqWeight").
##
##  It is assumed that tails for the given weight (or weights)  have  already
##  been added (see~"PqTails").
##
##  For those familiar with the `pq' binary, `PqDoConsistencyChecks' performs
##  menu item 8 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDoConsistencyChecks, function( arg )
local len, datarec, weight, type;
  len := Length(arg);
  if not(len in [2, 3]) then
    Error("expected 2 or 3 arguments\n");
  fi;
  weight := arg[len - 1];
  type   := arg[len];
  arg := arg{[1 .. len - 2]};
  datarec := CallFuncList(ANUPQDataRecord, arg);
  if not IsBound(datarec.setupclass) or datarec.class <> datarec.setupclass then
    Error( "tables to start next class have not been set up.\n",
           "Please call `PqSetupTablesForNextClass' first\n" );
  fi;
  if not(weight = 0 or weight in [3 .. datarec.class]) then
    Error( "argument <weight> should be an integer in [0] U [3 .. <class>],\n",
           "where <class> is the current class (", datarec.class, ")\n" );
  fi;
  if not(type in [0..3]) then
    Error( "argument <type> should be in [0,1,2,3]\n" );
  fi;
  PQ_DO_CONSISTENCY_CHECKS( datarec, weight, type );
end );

#############################################################################
##
#F  PQ_COLLECT_DEFINING_RELATIONS( <datarec> ) . . . . .  A p-Q menu option 9
##
##  inputs data to the `pq' binary for option 9 of the Advanced  $p$-Quotient
##  menu, to collect defining relations.
##
InstallGlobalFunction( PQ_COLLECT_DEFINING_RELATIONS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 9 ], [ "  #collect defining relations" ]);
end );

#############################################################################
##
#F  PqCollectDefiningRelations( <i> ) . . user version of A p-Q menu option 9
#F  PqCollectDefiningRelations()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to collect the images of the defining relations of the original fp
##  group of the process, with respect to the current pc presentation, in the
##  context of finding the  next  class  (see~"PqNextClass").  If  the  tails
##  operation  is  not  complete  then  the  relations   may   be   evaluated
##  incorrectly.
##
##  *Note:*
##  For those familiar with  the  `pq'  binary,  `PqCollectDefiningRelations'
##  performs menu item 9 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCollectDefiningRelations, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_COLLECT_DEFINING_RELATIONS( datarec );
end );

#############################################################################
##
#F  PQ_DO_EXPONENT_CHECKS( <datarec>, <bnds> ) . . . . . A p-Q menu option 10
##
##  inputs data to the `pq' binary to do exponent checks for weights  between
##  <bnds> inclusive, using option 10 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_DO_EXPONENT_CHECKS, function( datarec, bnds )
  #@does default only at the moment@
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  datarec.match := "Group is complete";
  ToPQ(datarec, [ 10 ], [ " #do exponent checks" ]);
  if IsBound(datarec.matchedline) and
     IsMatchingSublist(datarec.matchedline, "Group is complete") then
    PQ_UNBIND(datarec, ["match", "matchedline"]);
    datarec.complete := true;
    return;
  elif IsMatchingSublist(datarec.line, "Input exponent law") then
    ToPQ(datarec, [ VALUE_PQ_OPTION("Exponent", 0, datarec) ],
                  [ "  #exponent" ]);
  fi;
  ToPQ(datarec, [ bnds[1] ], [ " #start weight" ]);
  ToPQ(datarec, [ bnds[2] ], [ " #end weight"   ]);
  ToPQ(datarec, [ 1 ], [ "  #do default check" ]);
  Unbind(datarec.match);
end );

#############################################################################
##
#F  PqDoExponentChecks(<i>[: Bounds := <list>]) . user ver A p-Q menu opt. 10
#F  PqDoExponentChecks([: Bounds := <list>])
##
##  for the <i>th or default interactive {\ANUPQ} process, direct  the  `pq'
##  binary to do exponent checks for weights (inclusively) between the bounds
##  of `Bounds' or for all weights if `Bounds' is not given. The value <list>
##  of `Bounds' (assuming the interactive process is numbered <i>) should  be
##  a list of  two  integers  <low>,  <high>  satisfying  $1  \le  <low>  \le
##  <high> \le `PqPClass(<i>)'$ (see~"PqPClass").
##
##  *Note:*
##  For those familiar with the `pq'  binary,  `PqDoExponentChecks'  performs
##  menu item 10 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDoExponentChecks, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqDoExponentChecks", true);
  datarec := PQ_DATA_CHK(arg);
  PQ_DO_EXPONENT_CHECKS( datarec, PQ_BOUNDS(datarec, datarec.class) );
end );

#############################################################################
##
#F  PQ_ELIMINATE_REDUNDANT_GENERATORS( <datarec> ) . . . A p-Q menu option 11
##
##  inputs data to the `pq' binary for option 11 of the Advanced $p$-Quotient
##  menu, to eliminate redundant generators.
##
InstallGlobalFunction( PQ_ELIMINATE_REDUNDANT_GENERATORS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 11 ], [ " #eliminate redundant generators" ]);
  datarec.match := true;
  PQ_SET_GRP_DATA(datarec);
end );

#############################################################################
##
#F  PqEliminateRedundantGenerators( <i> ) .  user ver of A p-Q menu option 11
#F  PqEliminateRedundantGenerators()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to eliminate redundant generators of the current $p$-quotient.
##
##  *Note:*
##  For those familiar with the `pq' binary, `PqEliminateRedundantGenerators'
##  performs menu item 11 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEliminateRedundantGenerators, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_ELIMINATE_REDUNDANT_GENERATORS( datarec );
end );

#############################################################################
##
#F  PQ_REVERT_TO_PREVIOUS_CLASS( <datarec> ) . . . . . . A p-Q menu option 12
##
##  inputs data to the `pq' binary for option 12 of the Advanced $p$-Quotient
##  menu, to abandon the current class and revert to the previous class.
##
InstallGlobalFunction( PQ_REVERT_TO_PREVIOUS_CLASS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 12 ], [ " #revert to previous class" ]);
  Unbind( datarec.ngens[ datarec.class ] );
  datarec.match := true;
  PQ_SET_GRP_DATA(datarec); #Just to be sure it's up-to-date
  datarec.setupclass := datarec.class - 1;
end );

#############################################################################
##
#F  PqRevertToPreviousClass( <i> ) . . . user version of A p-Q menu option 12
#F  PqRevertToPreviousClass()
##
##  for the <i>th or default interactive {\ANUPQ} process, direct  the  `pq'
##  binary to abandon the current class and revert to the previous class.
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqRevertToPreviousClass'
##  performs menu item 12 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqRevertToPreviousClass, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_REVERT_TO_PREVIOUS_CLASS( datarec );
end );

#############################################################################
##
#F  PQ_SET_MAXIMAL_OCCURRENCES( <datarec>, <noccur> ) . .  A p-Q menu opt. 13
##
##  inputs data to the  `pq'  binary,  to  set  the  maximal  occurrences  of
##  generators of weight 1 in generator definitions, using option 13  of  the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_SET_MAXIMAL_OCCURRENCES, function( datarec, noccur )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 13 ], [ " #set maximal occurrences" ]);
  ToPQ(datarec, [ JoinStringsWithSeparator( List(noccur, String), " " ) ],
                [ " #max occurrences of weight 1 gen'rs"]);
end );

#############################################################################
##
#F  PqSetMaximalOccurrences( <i>, <noccur> ) . user ver of A p-Q menu opt. 13
#F  PqSetMaximalOccurrences( <noccur> )
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to set maximal occurrences of  the  weight  1  generators  in  the
##  definitions of pcp generators of the group of the process; <noccur>  must
##  be a list of non-negative integers of  length  the  number  of  weight  1
##  generators (i.e.~the rank of the class 1 $p$-quotient of the group of the
##  process). An entry of `0' for a particular generator indicates that there
##  is no limit on the number of occurrences for the generator.
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqSetMaximalOccurrences'
##  performs menu item 13 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSetMaximalOccurrences, function( arg )
local len, noccur, datarec;
  len := Length(arg);
  if not(len in [1, 2]) then
    Error( "expected 1 or 2 arguments\n");
  fi;
  noccur := arg[len];
  if not IsList(noccur) or not ForAll(noccur, x -> IsInt(x) and x >= 0) then
    Error( "<noccur> argument must be a list of non-negative integers\n" );
  fi;
  arg := arg{[1 .. len - 1]};
  datarec := PQ_DATA_CHK(arg);
  if Length(noccur) <> datarec.ngens[1] then
    Error( "<noccur> argument must be a list of length equal to\n",
           "the no. of generators of weight 1 (",  datarec.ngens[1], ")\n" );
  fi;
  PQ_SET_MAXIMAL_OCCURRENCES( datarec, noccur );
end );

#############################################################################
##
#F  PQ_SET_METABELIAN( <datarec> ) . . . . . . . . . . . A p-Q menu option 14
##
##  inputs data to the `pq' binary for option 14 of the Advanced $p$-Quotient
##  menu, to set the metabelian flag.
##
InstallGlobalFunction( PQ_SET_METABELIAN, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 14 ], [ " #set metabelian" ]);
end );

#############################################################################
##
#F  PqSetMetabelian( <i> ) . . . . . . . user version of A p-Q menu option 14
#F  PqSetMetabelian()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to enforce metabelian-ness.
##
##  *Note:* 
##  For those familiar  with  the  `pq'  binary,  `PqSetMetabelian'  performs
##  menu item 14 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSetMetabelian, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_SET_METABELIAN( datarec );
end );

#############################################################################
##
#F  PQ_DO_CONSISTENCY_CHECK( <datarec>, <c>, <b>, <a> ) . A p-Q menu option 15
##
##  inputs data to the `pq' binary for option 15 of the Advanced $p$-Quotient
##  menu, to do a consistency check.
##
InstallGlobalFunction( PQ_DO_CONSISTENCY_CHECK, function( datarec, c, b, a )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 15 ], [ " #do individual consistency check" ]);
  ToPQ(datarec, [ c, " ", b, " ", a ], [ "  #generator indices"]);
end );

#############################################################################
##
#F  PqDoConsistencyCheck(<i>, <c>, <b>, <a>) .  user ver of A p-Q menu opt 15
#F  PqDoConsistencyCheck( <c>, <b>, <a> )
#F  PqJacobi(<i>, <c>, <b>, <a>)
#F  PqJacobi( <c>, <b>, <a> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to do the Jacobi consistency check  for  the  pc  generators  with
##  indices <c>, <b>, <a> which should be non-increasing  positive  integers,
##  i.e.~$<c>   \ge   <b>   \ge   <a>$.   For   further   explanation,    see
##  `PqDoConsistencyChecks' ("PqDoConsistencyChecks").
##
##  *Note:*
##  For those familiar  with  the  `pq'  binary,  `PqDoConsistencyCheck'  and
##  `PqJacobi' perform menu item 15 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDoConsistencyCheck, function( arg )
local len, c, b, a, datarec;
  len := Length(arg);
  if not(len in [3, 4]) then
    Error( "expected 3 or 4 arguments\n" );
  fi;
  c := arg[len - 2];
  b := arg[len - 1];
  a := arg[len];
  arg := arg{[1 .. len - 3]};
  datarec := CallFuncList(ANUPQDataRecord, arg);
  if not IsBound(datarec.setupclass) or datarec.class <> datarec.setupclass then
    Error( "tables to start next class have not been set up.\n",
           "Please call `PqSetupTablesForNextClass' first\n" );
  fi;
  if not ForAll([c, b, a], IsPosInt) or datarec.class < c or c < b or b < a then
    Error( "pc generator indices must be non-increasing ",
           "integers in [1 .. <class>],\n",
           "where <class> is the current class (", datarec.class, ")\n" );
  fi;
  PQ_DO_CONSISTENCY_CHECK( datarec, c, b, a );
end );

#############################################################################
##
#F  PQ_COMPACT( <datarec> ) . . . . . . . . . . . . . .  A p-Q menu option 16
##
##  inputs data to the `pq' binary for option 16 of the Advanced $p$-Quotient
##  menu, to do a compaction.
##
InstallGlobalFunction( PQ_COMPACT, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 16 ], [ " #compact" ]);
end );

#############################################################################
##
#F  PqCompact( <i> ) . . . . . . . . . . user version of A p-Q menu option 16
#F  PqCompact()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to do a compaction.
##
##  *Note:*
##  For those familiar with the `pq' binary, `PqCompact' performs  menu  item
##  16 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCompact, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_COMPACT( datarec );
end );

#############################################################################
##
#F  PQ_ECHELONISE( <datarec> ) . . . . . . . . . . . . . A p-Q menu option 17
##
##  inputs data to the `pq' binary for option 17 of the Advanced $p$-Quotient
##  menu, to echelonise.
##
InstallGlobalFunction( PQ_ECHELONISE, function( datarec )
local line, redgen;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  datarec.match := "Generator";
  ToPQ(datarec, [ 17 ], [ " #echelonise" ]);
  if IsBound(datarec.matchedline) and 
     PositionSublist(datarec.matchedline, "redundant") <> fail then
    line := SplitString(datarec.matchedline, "", " \n");
    redgen := Int( line[2] );
  else
    redgen := fail;
  fi;
  PQ_UNBIND(datarec, ["match", "matchedline"]);
  return redgen;
end );

#############################################################################
##
#F  PqEchelonise( <i> ) . . . . . . . .  user version of A p-Q menu option 17
#F  PqEchelonise()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  program to echelonise the word most recently collected by `PqCollect'  or
##  `PqCommutator' against the relations of the current pc presentation,  and
##  return the number of  the  generator  made  redundant  or  `fail'  if  no
##  generator was made redundant. A call to `PqCollect' (see~"PqCollect")  or
##  `PqCommutator' (see~"PqCommutator") needs to be performed prior to  using
##  this command.
##
##  *Note:*
##  For those familiar with the `pq'  binary,  `PqEchelonise'  performs  menu
##  item 17 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEchelonise, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  return PQ_ECHELONISE( datarec );
end );

#############################################################################
##
#F  PQ_SUPPLY_OR_EXTEND_AUTOMORPHISMS(<datarec>[,<mlist>])  A p-Q menu opt 18
##
##  inputs data to the `pq' binary for option 18 of the Advanced $p$-Quotient
##  menu.  If  a  list  <mlist>  of  matrices   with   non-negative   integer
##  coefficients  is  supplied  it  is  used  to  ``supply''   automorphisms;
##  otherwise, previously supplied automorphisms are ``extended''.
##
InstallGlobalFunction( PQ_SUPPLY_OR_EXTEND_AUTOMORPHISMS, function( arg )
local datarec;
  datarec := arg[1];
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  if 1 = Length(arg) then
    ToPQ(datarec, [ 18 ], [ " #extend auts" ]);
  else
    ToPQ(datarec, [ 18 ], [ " #supply auts" ]);
    CallFuncList(PQ_MANUAL_AUT_INPUT, arg);
  fi;
  datarec.hasAuts := true;
end );

#############################################################################
##
#F  PqSupplyAutomorphisms(<i>, <mlist>) . . supply auts via A p-Q menu opt 18
#F  PqSupplyAutomorphisms( <mlist> )
##
##  for the  <i>th  or  default  interactive  {\ANUPQ}  process,  supply  the
##  automorphism  data  provided  by  the  list  <mlist>  of  matrices   with
##  non-negative integer coefficients. Each matrix in <mlist> must  have  the
##  same dimensions; in particular, the number of rows of each matrix must be
##  the number of pc generators of the  current  $p$-quotient  of  the  group
##  associated with the interactive {\ANUPQ} process.
##
##  *Note:*
##  For those familiar with the  `pq'  binary,  `PqSupplyAutomorphisms'  uses
##  menu item 18 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSupplyAutomorphisms, function( arg )
local args;
  args := PQ_AUT_ARG_CHK(1, arg);
  args[1] := ANUPQData.io[ args[1] ];
  if IsBound(args[1].hasAuts) and args[1].hasAuts then
    Error("huh! already have automorphisms.\n",
          "Perhaps you wanted to use `PqExtendAutomorphisms'\n");
  fi;
  CallFuncList( PQ_SUPPLY_OR_EXTEND_AUTOMORPHISMS, args );
end );

#############################################################################
##
#F  PqExtendAutomorphisms( <i> ) . . . . .  extend auts via A p-Q menu opt 18
#F  PqExtendAutomorphisms()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to extend previously-supplied automorphisms.
##
##  *Note:*
##  For those familiar with the  `pq'  binary,  `PqExtendAutomorphisms'  uses
##  menu item 18 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqExtendAutomorphisms, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  if not(IsBound(datarec.hasAuts) and datarec.hasAuts) then
    Error("huh! don't have any automorphisms to extend.\n",
          "Perhaps you wanted to use `PqSupplyAutomorphisms'\n");
  fi;
  PQ_SUPPLY_OR_EXTEND_AUTOMORPHISMS( datarec );
end );

#############################################################################
##
#F  PQ_CLOSE_RELATIONS( <datarec>, <qfac> ) . . . . . .  A p-Q menu option 19
##
##  inputs data to the `pq' binary for option 19 of the Advanced $p$-Quotient
##  menu, to apply automorphisms.
##
InstallGlobalFunction( PQ_CLOSE_RELATIONS, function( datarec, qfac )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 19 ], [ " #close relations"  ]);
  ToPQ(datarec, [ qfac ], [ " #queue factor" ]);
end );

#############################################################################
##
#F  PqApplyAutomorphisms( <i>, <qfac> ) . .  user ver of A p-Q menu option 19
#F  PqApplyAutomorphisms( <qfac> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to apply automorphisms; <qfac> is the queue factor e.g. `15'.
##
##  *Note:*
##  For those familiar with  the  `pq'  binary,  `PqCloseRelations'  performs
##  menu item 19 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqApplyAutomorphisms, function( arg )
local len, datarec, qfac;
  len := Length(arg);
  if not(len in [1, 2]) then
    Error("expected 1 or 2 arguments\n");
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg{[1 .. len - 1]});
  PQ_CLOSE_RELATIONS( datarec, arg[len] );
end );

#############################################################################
##
#F  PQ_DISPLAY( <datarec>, <opt>, <type>, <bnds> ) .  A p-Q menu option 20/21
##
##  inputs data to the `pq' binary  for  Advanced  $p$-Quotient  menu  option
##  <opt> (<opt> should be 20 or 21) to display the generator  structure  (if
##  `<opt> = 20' and `<type> = "structure"') or to display automorphisms  (if
##  `<opt> = 21' and `<type> =  "automorphisms"'),  for  the  pcp  generators
##  numbered between the bounds determined by the option `Bounds' or for  all
##  pcp generators if `Bounds' is not set.
##
InstallGlobalFunction( PQ_DISPLAY, function( datarec, opt, type, bnds )
  PQ_MENU(datarec, "ApQ");
  if VALUE_PQ_OPTION("OutputLevel", datarec) <> fail then
    PQ_SET_OUTPUT_LEVEL( datarec, datarec.OutputLevel );
  fi;
  ToPQ(datarec, [ opt ],     [ " #display ", type ]);
  ToPQ(datarec, [ bnds[1] ], [ " #no. of first generator" ]);
  ToPQ(datarec, [ bnds[2] ], [ " #no. of last generator"  ]);
end );

#############################################################################
##
#F  PQ_BOUNDS( <datarec>, <hibnd> ) . . provide bounds from option or default
##
##  extracts a list of two integer bounds from option  `Bounds'  if  set,  or
##  otherwise uses `[1 .. <hibnd>]' as default. If `Bounds' is set  they  are
##  checked to lie in the range `[1 .. <hibnd>]' and an error is generated if
##  they are not. If there is no error the list of two bounds  determined  by
##  the above is returned.
##
InstallGlobalFunction( PQ_BOUNDS, function( datarec, hibnd )
local bounds;
  bounds := VALUE_PQ_OPTION("Bounds");
  if bounds = fail then
    return [1, hibnd];
  elif bounds[2] > hibnd then 
    # most checking has already been done by VALUE_PQ_OPTION
    Info(InfoWarning + InfoANUPQ, 1, 
         "2nd bound ", bounds[2], " of `Bounds' can be at most ", hibnd);
    Info(InfoWarning + InfoANUPQ, 1, 
         "... replacing this bound most with", hibnd);
    return [bounds[1], hibnd];
  else
    return bounds;
  fi;
end );

#############################################################################
##
#F  PqDisplayStructure(<i>[: Bounds := <list>]) . user ver A p-Q menu opt. 20
#F  PqDisplayStructure([: Bounds := <list>])
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary  to  display  the  structure  for  the  pcp  generators   numbered
##  (inclusively) between the bounds of `Bounds' or  for  all  generators  if
##  `Bounds' is not  given.  The  value  <list>  of  `Bounds'  (assuming  the
##  interactive process is numbered <i>) should be a  list  of  two  integers
##  <low>,  <high>  satisfying  `1  \<=  <low>   \<=   PqNrPcGenerators(<i>)'
##  (see~"PqNrPcGenerators"). `PqDisplayStructure' also  accepts  the  option
##  `OutputLevel' (see e.g.~"Pq" where the option is listed).
##
##  *Note:*
##  For those familiar with the `pq'  binary,  `PqDisplayStructure'  performs
##  option 20 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDisplayStructure, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqDisplayStructure", true);
  datarec := PQ_DATA_CHK(arg);
  PQ_DISPLAY( datarec, 20, "structure", 
              PQ_BOUNDS(datarec, datarec.forder[2]) );
end );

#############################################################################
##
#F  PqDisplayAutomorphisms(<i>[: Bounds := <list>]) . u ver A p-Q menu opt 21
#F  PqDisplayAutomorphisms([: Bounds := <list>])
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to display the automorphism actions on the pcp generators numbered
##  (inclusively) between the bounds of `Bounds' or  for  all  generators  if
##  `Bounds' is not  given.  The  value  <list>  of  `Bounds'  (assuming  the
##  interactive process is numbered <i>) should be a  list  of  two  integers
##  <low>,   <high>   satisfying   $1    \le    <low>    \le    <high>    \le
##  `PqNrPcGenerators(<i>)'$  (see~"PqNrPcGenerators").  `PqDisplayStructure'
##  also accepts the option `OutputLevel' (see "option OutputLevel").
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,   `PqDisplayAutomorphisms'
##  performs menu item 21 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDisplayAutomorphisms, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqDisplayAutomorphisms", true);
  datarec := PQ_DATA_CHK(arg);
  PQ_DISPLAY( datarec, 21, "automorphisms", 
              PQ_BOUNDS(datarec, datarec.forder[2]) );
end );

#############################################################################
##
#F  PQ_COLLECT_DEFINING_GENERATORS( <datarec>, <word> ) . . A p-Q menu opt 23
##
##  instructs the  `pq'  binary  to  do  a  collection  on  <word>  a  string
##  representing a word in the  weight 1  pc  generators,  e.g.  `"x2^2*x1"',
##  using option 23 of the interactive $p$-Quotient menu.
##
InstallGlobalFunction( PQ_COLLECT_DEFINING_GENERATORS, function( datarec, word )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 23 ], [ " #collect defining generators" ]);
  datarec.match := "The result of collection is";
  ToPQ(datarec, [ word, ";" ], [ "  #word to be collected" ]);
  return PQ_WORD(datarec);
end );

#############################################################################
##
#F  PqCollectWordInDefiningGenerators(<i>,<word>) . u ver of A p-Q menu op 23
#F  PqCollectWordInDefiningGenerators( <word> )
##
##  for  the  <i>th  or  default  interactive  {\ANUPQ}  process,  collect  a
##  user-defined word in the pc generators of the class 1 quotient,  i.e.~the
##  pc generators that correspond to the original  fp  or  pc  group  of  the
##  process, with respect to the current pc presentation, in the  context  of
##  finding the next class (see~"PqNextClass"), and return the result of  the
##  collection as a list of generator  number,  exponent  pairs.  The  <word>
##  argument may be input in either of the two ways described for `PqCollect'
##  (see~"PqCollect"). It is not illegal for <word> to contain pc  generators
##  of weight larger than 1, but they are  intrepreted  as  representing  the
##  identity;   `PqCollectWordInDefiningGenerators'   works   exactly    like
##  `PqCollect' except for this distinction.
##
##  *Note:*
##  For those familiar with the  `pq'  program,  `PqCollectDefiningGenerators'
##  performs menu item 23 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCollectWordInDefiningGenerators, function( arg )
  return CallFuncList( PQ_COLLECT_DEFINING_GENERATORS, 
                       PQ_CHK_COLLECT_COMMAND_ARGS(arg) );
end );

#############################################################################
##
#F  PqCommutatorDefiningGenerators(<i>,<words>,<pow>) . user ver A p-Q opt 24
#F  PqCommutatorDefiningGenerators( <words>, <pow> )
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to compute the left norm commutator of the list <words>  of  words
##  in the generators raised to the integer power <pow>.
##
##  *Note:*
##  For those familiar with the `pq' binary, `PqCommutatorDefiningGenerators'
##  performs option 24 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCommutatorDefiningGenerators, function( arg )
  return CallFuncList( PQ_COMMUTATOR, 
                       PQ_COMMUTATOR_CHK_ARGS(
                           Concatenation(
                               arg, 
                               [[[24], [" #commutator of defining genrs"]]] )
                           ) );
end );

#############################################################################
##
#F  PQ_WRITE_PC_PRESENTATION( <datarec>, <filename> ) .  A p-Q menu option 25
##
##  tells the `pq' binary to write a pc presentation to the  file  with  name
##  <filename> for group `<datarec>.group'  (option  25  of  the  interactive
##  $p$-Quotient menu).
##
InstallGlobalFunction( PQ_WRITE_PC_PRESENTATION, function( datarec, filename )
  if not IsBound(datarec.setupfile) then
    PrintTo(filename, "");   #to ensure it's writable and empty
  fi;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 25 ], [ " #set output file" ]);
  ToPQ(datarec, [ filename ], []);
  ToPQ(datarec, [ 2 ], [ "  #output in GAP format" ]);
end );

#############################################################################
##
#F  PqWritePcPresentation( <i>, <filename> ) . user ver. of A p-Q menu opt 25
#F  PqWritePcPresentation( <filename> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to write a pc presentation to the file with  name  <filename>  for
##  the group of that process for which a pc presentation has been previously
##  computed, where the group of a process is the one given as first argument
##  when `PqStart' was called to initiate that process (for process  <i>  the
##  group is stored as `ANUPQData.io[<i>].group'). If the first character  of
##  the string <filename> is not `/', <filename> is assumed to be the path of
##  a writable file relative to the directory in which {\GAP} was started. If
##  a pc presentation has not been previously computed by  the  `pq'  binary,
##  then  `pq'  is  called  to  compute  it   first,   effectively   invoking
##  `PqPcPresentation' (see~"PqPcPresentation").
##
##  *Note:* For those familiar with the `pq' binary,  `PqPcWritePresentation'
##  performs menu item 25 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqWritePcPresentation, function( arg )
local filename, datarec;
  if 2 < Length(arg) or IsEmpty(arg) then
    Error("expected one or two arguments.\n");
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg{[1..Length(arg) - 1]});
  filename := PQ_CHK_PATH( arg[Length(arg)], "w", datarec );
  if not( IsBound(datarec.pCover) and datarec.pcoverclass = datarec.class or
          IsBound(datarec.pQuotient) ) then
    Error( "no p-quotient or p-cover has been computed\n" );
  fi;
  PQ_WRITE_PC_PRESENTATION( datarec, filename );
end );

#############################################################################
##
#F  PQ_WRITE_COMPACT_DESCRIPTION( <datarec> ) . . . . .  A p-Q menu option 26
##
##  tells the `pq' binary to write a compact description to a file.
##
InstallGlobalFunction( PQ_WRITE_COMPACT_DESCRIPTION, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 26 ], [ " #write compact description to file" ]);
end );

#############################################################################
##
#F  PqWriteCompactDescription( <i> ) . . user version of A p-Q menu option 26
#F  PqWriteCompactDescription()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to write a compact description to a file.
##
##  *Note:*
##  For those familiar  with  the  `pq'  binary,  `PqWriteCompactDescription'
##  performs menu item 26 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqWriteCompactDescription, function( arg )
  PQ_WRITE_COMPACT_DESCRIPTION( CallFuncList(ANUPQDataRecord, arg) );
end );

#############################################################################
##
#F  PQ_EVALUATE_CERTAIN_FORMULAE( <datarec> ) . . . . .  A p-Q menu option 27
##
##  inputs data to the `pq' binary for option 27 of the Advanced $p$-Quotient
##  menu, to evaluate certain formulae.
##
InstallGlobalFunction( PQ_EVALUATE_CERTAIN_FORMULAE, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 27 ], [ " #evaluate certain formulae" ]);
end );

#############################################################################
##
#F  PqEvaluateCertainFormulae( <i> ) . . user version of A p-Q menu option 27
#F  PqEvaluateCertainFormulae()
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to evaluate certain formulae.
##
##  *Note:*
##  For those familiar  with  the  `pq'  binary,  `PqEvaluateCertainFormulae'
##  performs option 27 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEvaluateCertainFormulae, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_EVALUATE_CERTAIN_FORMULAE( datarec );
end );

#############################################################################
##
#F  PQ_EVALUATE_ACTION( <datarec> ) . . . . . . . . . .  A p-Q menu option 28
##
##  inputs data to the `pq' binary for option 28 of the Advanced $p$-Quotient
##  menu, to evaluate the action.
##
InstallGlobalFunction( PQ_EVALUATE_ACTION, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 28 ], [ " #evaluate action" ]);
end );

#############################################################################
##
#F  PqEvaluateAction( <i> ) . . . . . .  user version of A p-Q menu option 28
#F  PqEvaluateAction()
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to evaluate the action.
##
##  *Note:*
##  For those familiar with  the  `pq'  binary,  `PqEvaluateAction'  performs
##  option 28 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEvaluateAction, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_EVALUATE_ACTION( datarec );
end );

#############################################################################
##
#F  PQ_EVALUATE_ENGEL_IDENTITY( <datarec> ) . . . . . .  A p-Q menu option 29
##
##  inputs data to the `pq' binary for option 29 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_EVALUATE_ENGEL_IDENTITY, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 29 ], [ " #evaluate Engel identity" ]);
end );

#############################################################################
##
#F  PqEvaluateEngelIdentity( <i> ) . . . user version of A p-Q menu option 29
#F  PqEvaluateEngelIdentity()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqEvaluateEngelIdentity' performs option 29 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEvaluateEngelIdentity, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_EVALUATE_ENGEL_IDENTITY( datarec );
end );

#############################################################################
##
#F  PQ_PROCESS_RELATIONS_FILE( <datarec> ) . . . . . . . A p-Q menu option 30
##
##  inputs data to the `pq' binary for option 30 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_PROCESS_RELATIONS_FILE, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ 30 ], [ " #process relations file" ]);
end );

#############################################################################
##
#F  PqProcessRelationsFile( <i> ) . . .  user version of A p-Q menu option 30
#F  PqProcessRelationsFile()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqProcessRelationsFile' performs option 30 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqProcessRelationsFile, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_PROCESS_RELATIONS_FILE( datarec );
end );

#############################################################################
##
#F  PqSPComputePcpAndPCover(<i> : <options>) . . . user ver of SP menu opt. 1
#F  PqSPComputePcpAndPCover( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to compute for the group of that process a pc presentation  up  to
##  the $p$-quotient of maximum class or the value of the option `ClassBound'
##  and the $p$-cover of that  quotient,  and  sets  up  tabular  information
##  required for computation of a standard presentation. Here the group of  a
##  process is the one given as first argument when `PqStart' was  called  to
##  initiate  that  process  (for  process  <i>  the  group  is   stored   as
##  `ANUPQData.io[<i>].group').
##
##  The possible <options> are `Prime', `ClassBound', `Relators', `Exponent',
##  `Metabelian' and `OutputLevel' (see Chapter~"ANUPQ Options" for  detailed
##  descriptions of these options). The option `Prime' is normally determined
##  via `PrimePGroup', and so is not required unless the group  doesn't  know
##  it's a $p$-group and `HasPrimePGroup' returns `false'.
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqSPComputePcpAndPCover'
##  performs option 1 of the Standard Presentation menu.
##
InstallGlobalFunction( PqSPComputePcpAndPCover, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqSPComputePcpAndPCover", true);
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_PC_PRESENTATION( datarec, "SP" );
end );

#############################################################################
##
#F  PQ_SP_STANDARD_PRESENTATION(<datarec>[,<mlist>] :<options>) SP menu opt 2
##
##  inputs data given by <options> to the `pq' binary to compute  a  standard
##  presentation for group `<datarec>.group'. If argument <mlist> is given it
##  is assumed to be the automorphism group data required.  Otherwise  it  is
##  assumed that `<datarec>.pQuotient' exists and that {\GAP} can compute its
##  automorphism group and the  necessary  automorphism  group  data  can  be
##  derived from `<datarec>.pQuotient'. This uses option 2  of  the  Standard
##  Presentation menu.
##
InstallGlobalFunction( PQ_SP_STANDARD_PRESENTATION, function( arg )
local datarec, savefile;
  datarec := arg[1];
  savefile := PQ_CHK_PATH( 
                  VALUE_PQ_OPTION( "StandardPresentationFile",
                                   Filename( ANUPQData.tmpdir, "SPres" ) ),
                  "w", datarec);
  PQ_MENU(datarec, "SP");
  ToPQ(datarec, [ 2 ], [ "  #compute standard presentation" ]);
  ToPQ(datarec, [ savefile ], [ "  #file for saving pres'n" ]);
  ToPQ(datarec, [ VALUE_PQ_OPTION("ClassBound", 63)], [ "  #class bound" ]);

  if 1 = Length(arg) then
    PQ_AUT_INPUT( datarec, datarec.pQuotient );
  else
    PQ_MANUAL_AUT_INPUT( datarec, arg[2] );
  fi;
  ToPQ_BOOL(datarec, VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec),
                     "compute pcgs gen. seq. for auts.");
end );

#############################################################################
##
#F  PqSPStandardPresentation(<i>[,<mlist>]:<options>)  user ver SP menu opt 2
#F  PqSPStandardPresentation([<mlist>] : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data  given
##  by <options> to compute a standard presentation for  the  group  of  that
##  process.  If  argument  <mlist>  is  given  it  is  assumed  to  be   the
##  automorphism group data required. Otherwise it is assumed that a call  to
##  either      `Pq'      (see~"Pq!interactive")      or      `PqEpimorphism'
##  (see~"PqEpimorphism!interactive") has generated a $p$-quotient  and  that
##  {\GAP} can compute  its  automorphism  group  from  which  the  necessary
##  automorphism group data can be derived. The group of the process  is  the
##  one given as first argument when `PqStart' was  called  to  initiate  the
##  process (for process <i> the group is stored as `ANUPQData.io[<i>].group'
##  and     the     $p$-quotient     if     existent     is     stored     as
##  `ANUPQData.io[<i>].pQuotient').  If  <mlist>   is   not   given   and   a
##  $p$-quotient of the group has not been  previously  computed  a  class  1
##  $p$-quotient is computed.
##
##  `PqSPStandardPresentation' accepts three options, all optional:
##
##  \beginitems
##
##  `StandardPresentationFile := <filename>'&
##  Specifies that the file to which the standard presentation is written has
##  name <filename>. If the first character of the string <filename>  is  not
##  `/', <filename> is assumed to be the path of a writable file relative  to
##  the directory in which {\GAP} was started. If this option is  omitted  it
##  is written to the file with the name generated by the command  `Filename(
##  ANUPQData.tmpdir, "SPres" );', i.e.~the file with name  `"SPres"' in  the
##  temporary directory in which the `pq' binary executes.
##
##  `ClassBound := <n>' &
##  Specifies that the $p$-quotient computed has lower exponent-$p$ class  at
##  most <n>. If this option is omitted a default of 63 is used.
##
##  `PcgsAutomorphisms' &
##  Specifies that a polycyclic  generating  sequence  for  the  automorphism
##  group of the group of the process (which must be *soluble*), be  computed
##  and passed to the `pq' binary.  This  increases  the  efficiency  of  the
##  computation;  it  also  prevents  the  `pq'  from  calling   {\GAP}   for
##  orbit-stabilizer calculations. See section "Computing  Descendants  of  a
##  p-Group" for further explanations.
##
##  \enditems
##
##  *Note:* For those familiar with  the  `pq'  binary,  `PqSPPcPresentation'
##  performs option 2 of the Standard Presentation menu.
##
InstallGlobalFunction( PqSPStandardPresentation, function( arg )
local args, datarec;
  args := PQ_AUT_ARG_CHK(0, arg);
  datarec := ANUPQData.io[ args[1] ];
  if 1 = Length(args) and not IsBound(datarec.pQuotient) then
    PQ_EPI_OR_PCOVER( args[1] : PqEpiOrPCover := "pQuotient");
  fi;
  args[1] := datarec;
  CallFuncList( PQ_SP_STANDARD_PRESENTATION, args );
end );

#############################################################################
##
#F  PQ_SP_SAVE_PRESENTATION( <datarec>, <filename> ) . . . . SP menu option 3
##
##  directs the `pq' binary to  save  the  standard  presentation  previously
##  computed for `<datarec>.group'  to  <filename>  using  option  3  of  the
##  Standard Presentation menu.
##
InstallGlobalFunction( PQ_SP_SAVE_PRESENTATION, function( datarec, filename )
  PQ_MENU(datarec, "SP");
  ToPQ(datarec, [ 3 ], [ "  #save standard presentation to file" ]);
  ToPQ(datarec, [ filename ], [ "  #filename" ]);
end );

#############################################################################
##
#F  PqSPSavePresentation( <i>, <filename> ) . .  user ver of SP menu option 3
#F  PqSPSavePresentation( <filename> )
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to save the standard  presentation  previously  computed  for  the
##  group of that process to the file with name <filename>, where  the  group
##  of a process is the one given as first argument when `PqStart' was called
##  to initiate that process. If the first character of the string <filename>
##  is not `/' <filename> is assumed to  be  the  path  of  a  writable  file
##  relative to the directory in which {\GAP} was started.
##
##  *Note:* For those familiar with the `pq'  binary,  `PqSPSavePresentation'
##  performs option 3 of the Standard Presentation menu.
##
InstallGlobalFunction( PqSPSavePresentation, function( arg )
local datarec, filename;
  PQ_OTHER_OPTS_CHK("PqSPSavePresentation", true);
  if 0 = Length(arg) or Length(arg) > 2 then
    Error( "expected 1 or 2 arguments\n" );
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg{[1..Length(arg) - 1]});
  filename := PQ_CHK_PATH( arg[Length(arg)], "w", datarec );
  PQ_SP_SAVE_PRESENTATION( datarec, filename );
end );

#############################################################################
##
#F  PQ_SP_COMPARE_TWO_FILE_PRESENTATIONS(<datarec>,<f1>,<f2>) . SP menu opt 6
##
##  inputs data to the `pq' binary for option 6 of the Standard  Presentation
##  menu, to compare the presentations in the files with names <f1> and  <f2>
##  and returns `true' if they are identical and `false' otherwise.
##
InstallGlobalFunction( PQ_SP_COMPARE_TWO_FILE_PRESENTATIONS, 
function( datarec, f1, f2 )
local line;
  PQ_MENU(datarec, "SP");
  ToPQ( datarec, [ 6 ], [ "  #compare two file presentations" ]);
  ToPQ( datarec, [ f1 ], [ "  #1st filename" ]);
  datarec.match := "Identical";
  datarec.filter := ["Identical"];
  ToPQ(datarec, [ f2 ], [ "  #2nd filename" ]);
  line := SplitString(datarec.matchedline, "", "? \n");
  PQ_UNBIND(datarec, ["match", "matchedline", "filter"]);
  return EvalString( LowercaseString( line[3] ) );
end );

#############################################################################
##
#F  PqSPCompareTwoFilePresentations(<i>,<f1>,<f2>)  user ver of SP menu opt 6
#F  PqSPCompareTwoFilePresentations(<f1>,<f2>)
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to compare the presentations in the files with names <f1> and <f2>
##  and returns `true' if they are identical and `false' otherwise. For  each
##  of the strings <f1> and <f2>, if the first character is not a `/' then it
##  is assumed to be the path of a readable file relative to the directory in
##  which {\GAP} was started.
##
##  *Notes*
##
##  The presentations in files <f1> and <f2> must have been generated by  the
##  `pq' binary but they do *not* need to be *standard* presentations.
##
##   For      those      familiar      with      the       `pq'       binary,
##   `PqSPCompareTwoFilePresentations' performs  option  6  of  the  Standard
##   Presentation menu.
##
InstallGlobalFunction( PqSPCompareTwoFilePresentations, function( arg )
local len, datarec, f1, f2;
  len := Length(arg);
  if not(len in [2, 3]) then
    Error( "expected 2 or 3 arguments\n" );
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg{[1..len - 2]});
  f1 := PQ_CHK_PATH( arg[len - 1], "r", datarec );
  f2 := PQ_CHK_PATH( arg[len], "r", datarec );
  return PQ_SP_COMPARE_TWO_FILE_PRESENTATIONS( datarec, f1, f2 );
end );

#############################################################################
##
#F  PQ_SP_ISOMORPHISM( <datarec> ) . . . . . . . . . . . . . SP menu option 8
##
##  computes the mapping  from  the  automorphism  group  generators  to  the
##  generators of the standard presentation,  using  option  8  of  the  main
##  Standard Presentation menu.
##
InstallGlobalFunction( PQ_SP_ISOMORPHISM, function( datarec )
  PQ_MENU(datarec, "SP");
  ToPQ(datarec, [ 8 ], [ "  #compute isomorphism" ]);
end );

#############################################################################
##
#F  PqSPIsomorphism( <i> ) . . . . . . . . . user version of SP menu option 8
#F  PqSPIsomorphism()
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  program to compute the isomorphism mapping  from  the  $p$-group  of  the
##  process  to  its  standard  presentation.  This   function   provides   a
##  description      only;      for      a      {\GAP}      object,       use
##  `EpimorphismStandardPresentation'
##  (see~"EpimorphismStandardPresentation!interactive").
##
##  *Note:* For  those  familiar  with  the  `pq'  program,  `PqSPIsomorphism'
##  performs menu item 8 of the Standard Presentation menu.
##
InstallGlobalFunction( PqSPIsomorphism, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_SP_ISOMORPHISM( datarec );
end );

#############################################################################
##
#F  PQ_PG_SUPPLY_AUTS( <datarec>[, <mlist>], <menu> ) .  p-G/A p-G menu opt 1
##
##  defines the automorphism group of `<datarec>.group', using  option  1  of
##  the main or Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_SUPPLY_AUTS, function( arg )
  local datarec;

  CallFuncList( PQ_MENU, arg{[1, Length(arg)]});
  datarec := arg[1];
  if 2 < Length(arg) and 
     VALUE_PQ_OPTION("NumberOfSolubleAutomorphisms", 0, datarec) > 0 and
     Length(VALUE_PQ_OPTION("RelativeOrders", [], datarec)) 
        <> datarec.NumberOfSolubleAutomorphisms then
    Error("the number of elements of option \"RelativeOrders\" should equal\n",
          "the value of option \"NumberOfSolubleAutomorphisms\" (",
          datarec.NumberOfSolubleAutomorphisms, ")\n");
  fi;
  ToPQ(datarec, [ 1 ], [ "  #supply automorphism data" ]);
  if 2 = Length(arg) then
    PQ_AUT_INPUT( datarec, datarec.group );
  else
    CallFuncList( PQ_MANUAL_AUT_INPUT, arg{[1 .. 2]} );
  fi;
end );

#############################################################################
##
#F  PqPGSupplyAutomorphisms( <i>[, <mlist>] ) .  user ver of pG menu option 1
#F  PqPGSupplyAutomorphisms([<mlist>])
##
##  for the <i>th or default interactive {\ANUPQ} process,  supply  the  `pq'
##  binary with the automorphism group data needed  for  the  group  of  that
##  process    (for    process    <i>    the    group    is     stored     as
##  `ANUPQData.io[<i>].group'). If  the  argument  <mlist>  is  omitted  then
##  {\GAP} *must* be able to determine the automorphism group of the group of
##  the process. Otherwise the automorphism data  is  provided  from  <mlist>
##  which  should  be  a  list  of   matrices   with   non-negative   integer
##  coefficients, where  each  matrix  must  have  the  same  dimensions;  in
##  particular, the number of rows of each matrix must be  the  rank  of  the
##  group of the process.
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqPGSupplyAutomorphisms'
##  performs option 1 of the main $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGSupplyAutomorphisms, function( arg )
local args;
  args := PQ_AUT_ARG_CHK(0, arg);
  args[1] := ANUPQData.io[ args[1] ];
  Add(args, "pG");
  CallFuncList( PQ_PG_SUPPLY_AUTS, args );
end );

#############################################################################
##
#F  PQ_PG_EXTEND_AUTOMORPHISMS( <datarec> ) . . . . . p-G/A p-G menu option 2
##
##  inputs data to the `pq' binary for option  2  of  the  main  or  Advanced
##  $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_EXTEND_AUTOMORPHISMS, function( datarec )
  if not(PQ_MENU(datarec) in ["pG", "ApG"]) then
    PQ_MENU(datarec, "pG");
  fi;
  ToPQ(datarec, [ 2 ], [ "  #extend automorphisms" ]);
end );

#############################################################################
##
#F  PqPGExtendAutomorphisms( <i> ) .  user version of p-G/A p-G menu option 2
#F  PqPGExtendAutomorphisms()
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to compute the extensions of the automorphisms defined by  calling
##  `PqPGSupplyAutomorphisms' (see~"PqPGSupplyAutomorphisms"). You  may  wish
##  to set the `InfoLevel' of `InfoANUPQ' to 2 (or more) in order to see  the
##  output from the `pq' (see~"InfoANUPQ").
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqPGExtendAutomorphisms'
##  performs option 2 of the main or advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGExtendAutomorphisms, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_PG_EXTEND_AUTOMORPHISMS( datarec );
end );

#############################################################################
##
#F  PQ_PG_RESTORE_GROUP(<datarec>, <cls>, <n>) . . . . . p-G/A p-G menu opt 3
##
##  inputs data to the `pq' binary to restore group <n> of  class  <cls>  for
##  option 3 of the main or Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_RESTORE_GROUP, function( datarec, cls, n )
  if not(PQ_MENU(datarec) in ["pG", "ApG"]) then
    PQ_MENU(datarec, "pG");
  fi;
  ToPQ(datarec, [ 3 ], [ "  #restore group from file" ]);
  if IsString(cls) then
    ToPQ(datarec, [ cls ], [ "  #filename" ]);
  else
    ToPQ(datarec, [ datarec.GroupName, "_class", cls ], [ "  #filename" ]);
  fi;
  ToPQ(datarec, [ n ], [ "  #no. of group" ]);
  if IsInt(cls) then
    datarec.match := true;
    PQ_SET_GRP_DATA(datarec);
    datarec.capable := datarec.class > cls;
    datarec.pcoverclass := datarec.class;
  fi;
end );

#############################################################################
##
#F  PqPGSetDescendantToPcp( <i>, <cls>, <n> ) . u ver of p-G/A p-G menu opt 3
#F  PqPGSetDescendantToPcp( <cls>, <n> )
#F  PqPGSetDescendantToPcp( <i> [: Filename := <name> ])
#F  PqPGSetDescendantToPcp([: Filename := <name> ])
#F  PqPGRestoreDescendantFromFile(<i>, <cls>, <n>)
#F  PqPGRestoreDescendantFromFile( <cls>, <n> )
#F  PqPGRestoreDescendantFromFile( <i> [: Filename := <name> ])
#F  PqPGRestoreDescendantFromFile([: Filename := <name> ])
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to restore group <n> of class <cls> from a temporary  file,  where
##  <cls> and <n> are positive integers,  or  the  group  stored  in  <name>.
##  `PqPGSetDescendantToPcp'    and    `PqPGRestoreDescendantFromFile'    are
##  synonyms;  they  make  sense  only  after  a  prior  call  to   construct
##  descendants          by          say           `PqPGConstructDescendants'
##  (see~"PqPGConstructDescendants")  or  the   interactive   `PqDescendants'
##  (see~"PqDescendants!interactive"). In the `Filename'  option  forms,  the
##  option defaults to the last filename in which a presentation  was  stored
##  by the `pq' binary.
##
##  *Note:*
##  For those familiar with the  `pq'  binary,  `PqPGSetDescendantToPcp'  and
##  `PqPGRestoreDescendantFromFile' perform  menu  item  3  of  the  main  or
##  advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGSetDescendantToPcp, function( arg )
local len, datarec, cls, n;
  PQ_OTHER_OPTS_CHK("PqPGSetDescendantToPcp", true);
  len := Length(arg);
  if len > 3 or not(ForAll(arg, IsPosInt)) then
    Error("expected at most 3 positive integer arguments\n");
  fi;
  if len in [2, 3] then
    cls := arg[len - 1];
    n   := arg[len];
    arg := arg{[1 .. len - 2]};
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  if len in [2, 3] then
    if not( IsBound(datarec.ndescendants) and 
            IsBound( datarec.ndescendants[cls] ) ) then
      Error( "descendants for class ", cls, " have not been constructed\n" );
    elif datarec.ndescendants[cls][1] < n then
      Error( "there is no group ", n, " saved (<n> must be <= ",
             datarec.ndescendants[cls][1], ")\n" );
    fi;
    PQ_PG_RESTORE_GROUP(datarec, cls, n);
  else
    PQ_PG_RESTORE_GROUP(datarec, VALUE_PQ_OPTION("Filename", datarec.des), 1);
  fi;
end );

#############################################################################
##
#F  PQ_PG_CONSTRUCT_DESCENDANTS( <datarec> : <options> ) .  p-G menu option 5
##
##  inputs  data  given  by  <options>  to  the  `pq'  binary  to   construct
##  descendants, using option 5 of the main $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_CONSTRUCT_DESCENDANTS, function( datarec )
local nodescendants, class, firstStep, expectedNsteps, optrec, line, ngroups,
      cls, totngroups, onestage;

  onestage := IsBound(datarec.des) and IsBound(datarec.des.onestage) and
              datarec.des.onestage;
  if not onestage then
    datarec.des := rec();
  fi;
  VALUE_PQ_OPTION("CustomiseOutput", false, datarec.des);
  if not onestage then
    # deal with the easy answer
    if VALUE_PQ_OPTION("OrderBound", 0, datarec.des) <> 0 and 
       IsPGroup(datarec.group) and
       datarec.des.OrderBound <= LogInt(Size(datarec.group), 
                                        PrimePGroup(datarec.group)) then
      return 0;
    fi;

    # We do these here to ensure an error doesn't occur mid-input of the menu
    # item data 
    if IsBound(datarec.capable) then
      #group has come from a `PqPGRestoreGroupFromFile' command
      if not datarec.capable then
        Info(InfoWarning + InfoANUPQ, 1, "group restored from file is incapable");
        return 0;
      fi;
    fi;
    if not IsBound(datarec.pcoverclass) or 
       datarec.pcoverclass <> datarec.class then
      Error("the p-cover of the last p-quotient has not yet been computed!\n");
    fi;

    # sanity checks
    if VALUE_PQ_OPTION("ClassBound", datarec.pcoverclass, datarec.des)
       < datarec.pcoverclass then
      Error("option `ClassBound' must be at least ", datarec.pcoverclass, "\n");
    fi;
  fi;

  if     VALUE_PQ_OPTION("SpaceEfficient", false, datarec.des) and 
     not VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec) then
    Info(InfoWarning + InfoANUPQ, 1,
         "\"SpaceEfficient\" ignored since \"PcgsAutomorphisms\" is set.");
  fi;

  if not onestage then
    if VALUE_PQ_OPTION("StepSize", datarec.des) <> fail then
      if datarec.des.OrderBound <> 0 then
        Error("\"StepSize\" and \"OrderBound\" ",
              "must not be set simultaneously\n");
      fi;
      expectedNsteps := datarec.des.ClassBound - datarec.pcoverclass + 1;
      if IsList(datarec.des.StepSize) then
        firstStep := datarec.des.StepSize[1];
        if Length(datarec.des.StepSize) <> expectedNsteps then
          Error( "the number of step-sizes in the \"StepSize\" list must\n",
                 "equal ", expectedNsteps, " (one more than the difference\n",
                 "of \"ClassBound\" and the class of the p-covering group)\n" );
        fi;
      else
        firstStep := datarec.des.StepSize;
      fi;
      if HasNuclearRank(datarec.group) and 
         firstStep > NuclearRank(datarec.group) then
#          Error("the first \"StepSize\" element (= ", firstStep, ") must not be\n",
#                "greater than the \"Nuclear Rank\" (= ",
#                NuclearRank(datarec.group), ")\n");
          return 0;
      fi;
    fi;

    PQ_MENU(datarec, "pG");
    datarec.matchlist := [" is an invalid starting group"];
    datarec.matchedlines := [];
    ToPQ(datarec, [ 5 ], [ "  #construct descendants" ]);
    nodescendants := not IsEmpty(datarec.matchedlines);
    PQ_UNBIND( datarec, ["matchlist", "matchedlines"] );
    if nodescendants then
      return 0;
    fi;
    ToPQ(datarec, [ datarec.des.ClassBound ], [ " #class bound" ]);

    #Construct all descendants?
    if not IsBound(datarec.des.StepSize) then
      ToPQ(datarec, [ 1 ], [ "  #do construct all descendants" ]);
      #Set an order bound for descendants?
      if datarec.des.OrderBound <> 0 then
        ToPQ(datarec, [ 1 ], [ "  #do set an order bound" ]);
        ToPQ(datarec, [ datarec.des.OrderBound ], [ " #order bound" ]);
      else
        ToPQ(datarec, [ 0 ], [ "  #do not set an order bound" ]);
      fi;
    else
      ToPQ(datarec, [ 0 ], [ "  #do not construct all descendants" ]);
      if expectedNsteps = 1 then
        # Input step size
        ToPQ(datarec, [ firstStep ], [ "  #step size" ]);

        # Constant step size?
      elif IsInt(datarec.des.StepSize) then
        ToPQ(datarec, [ 1 ], [ "  #set constant step size" ]);
        ToPQ(datarec, [ datarec.des.StepSize ], [ "  #step size" ]);
      else
        ToPQ(datarec, [ 0 ], [ "  #set variable step size" ]);
        ToPQ(datarec, [ JoinStringsWithSeparator(
                            List(datarec.des.StepSize, String), " ") ],
                      [ "  #step sizes" ]);
      fi;
    fi;

  else
    PQ_MENU(datarec, "ApG");
    ToPQ(datarec, [ 5 ], [ "  #single stage" ]);
    ToPQ(datarec, [ VALUE_PQ_OPTION("StepSize", datarec.des) ],
                  [ " #step size" ]);
  fi;
  ToPQ_BOOL(datarec, VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec),
                     "compute pcgs gen. seq. for auts.");
  ToPQ_BOOL(datarec, VALUE_PQ_OPTION("BasicAlgorithm", false, datarec.des),
                     "use default algorithm");
  if not datarec.des.BasicAlgorithm then
    ToPQ(datarec, [ VALUE_PQ_OPTION(
                        "RankInitialSegmentSubgroups", 0, datarec.des) ],
                  [ "  #rank of initial segment subgrp" ]);
    if datarec.PcgsAutomorphisms then
      ToPQ_BOOL(datarec, datarec.des.SpaceEfficient, "be space efficient");
    fi;
    VALUE_PQ_OPTION("AllDescendants", true, datarec.des);
    ToPQ_BOOL(datarec,
              not VALUE_PQ_OPTION( "CapableDescendants", 
                                   not datarec.des.AllDescendants,
                                   datarec.des ),
              "completely process terminal descendants");
    ToPQ(datarec, [ VALUE_PQ_OPTION("Exponent", 0, datarec) ],
                  [ "  #exponent" ]); # "Exponent" is a `global' option
    ToPQ_BOOL(datarec, VALUE_PQ_OPTION("Metabelian", false, datarec.des),
                       "enforce metabelian law");
  fi;
  datarec.matchlist := [ "group saved on file", "groups saved on file" ];
  datarec.matchedlines := [];
  if IsRecord(datarec.des.CustomiseOutput) and
     not IsEmpty( Intersection( RecNames(datarec.des.CustomiseOutput),
                                ["perm", "orbit", "group", "autgroup", "trace"]
                                ) ) then
    ToPQ(datarec, [ 0 ], [ "  #customise output" ]);
    PQ_CUSTOMISE_OUTPUT( datarec, "perm", "perm. grp output",
                         ["print degree",
                          "print extended auts",
                          "print aut. matrices",
                          "print permutations"] );
    PQ_CUSTOMISE_OUTPUT( datarec, "orbit", "orbit output",
                         ["print orbit summary",
                          "print complete orbit listing"] );
    PQ_CUSTOMISE_OUTPUT( datarec, "group", "group output",
                         ["print allowable subgp standard matrix",
                          "print pres'n of reduced p-covers",
                          "print pres'n of immediate descendants",
                          "print nuclear rank of descendants",
                          "print p-mult'r rank of descendants"] );
    PQ_CUSTOMISE_OUTPUT( datarec, "autgroup", "aut. grp output",
                         ["print commutator matrix",
                          "print aut. grp descriptions of descendants",
                          "print aut. grp orders of descendants"] );
    PQ_CUSTOMISE_OUTPUT( datarec, "trace", "provide algorithm trace", [] );
  else
    ToPQ(datarec, [ 1 ], [ "  #default output" ]);
  fi;
  if onestage then
    ToPQ(datarec, [ VALUE_PQ_OPTION("Filename", "onestage", datarec.des) ],
                  [ " #output filename" ]);
    Unbind(datarec.des.onestage);
  else
    if not IsBound(datarec.ndescendants) then
      datarec.ndescendants := [];
    fi;
    totngroups := 0;
    for line in datarec.matchedlines do
      line := SplitString(line, "", " \n");
      ngroups := Int( line[1] );
      cls := SplitString( line[ Length(line) ], "", "_" );
      cls := Int( cls[2]{[6 .. Length( cls[2] )]} );
      datarec.ndescendants[cls] := [ngroups, line[2] = "capable"];
      totngroups := totngroups + ngroups;
    od;
    PQ_UNBIND(datarec, ["matchlist", "matchedlines"]);
    return totngroups;
  fi; 
end );

#############################################################################
##
#F  PqPGConstructDescendants( <i> : <options> ) . user ver. of p-G menu op. 5
#F  PqPGConstructDescendants( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to construct descendants prescribed by <options>, and  return  the
##  number of descendants constructed. The options possible are `ClassBound',
##  `OrderBound',              `StepSize',               `PcgsAutomorphisms',
##  `RankInitialSegmentSubgroups',  `SpaceEfficient',   `CapableDescendants',
##  `AllDescendants',     `Exponent',     `Metabelian',     `BasicAlgorithm',
##  `CustomiseOutput'. (Detailed descriptions of these options may  be  found
##  in Chapter~"ANUPQ Options".)
##
##  `PqPGConstructDescendants' requires that the `pq' binary  has  previously
##  computed a pc presentation and a $p$-cover for  a  $p$-quotient  of  some
##  class of the group of the process.
##
##  *Note:* 
##  For those  familiar  with  the  `pq'  binary,  `PqPGConstructDescendants'
##  performs menu item 5 of the main $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGConstructDescendants, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqPGConstructDescendants", true);
  datarec := CallFuncList(ANUPQDataRecord, arg);
  return PQ_PG_CONSTRUCT_DESCENDANTS( datarec );
end );

#############################################################################
##
#F  PqAPGSupplyAutomorphisms( <i>[, <mlist>] ) . user ver of A p-G menu opt 1
#F  PqAPGSupplyAutomorphisms([<mlist>])
##
#T  This is implemented, but not documented in the manual. There is one line
#T  different in the C code between this menu item and the corresponding p-G
#T  menu item. I don't understand the difference. - GG
##  for the <i>th or default interactive {\ANUPQ} process,  supply  the  `pq'
##  binary with the automorphism group data needed  for  the  group  of  that
##  process    (for    process    <i>    the    group    is     stored     as
##  `ANUPQData.io[<i>].group'). If  the  argument  <mlist>  is  omitted  then
##  {\GAP} *must* be able to determine the automorphism group of the group of
##  the process. Otherwise the automorphism data  is  provided  from  <mlist>
##  which  should  be  a  list  of   matrices   with   non-negative   integer
##  coefficients, where  each  matrix  must  have  the  same  dimensions;  in
##  particular, the number of rows of each matrix must be  the  rank  of  the
##  group of the process.
##
##  *Note:*
##  For those  familiar  with  the  `pq'  binary,  `PqAPGSupplyAutomorphisms'
##  performs menu item 1 of the Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGSupplyAutomorphisms, function( arg )
local args;
  args := PQ_AUT_ARG_CHK(0, arg);
  args[1] := ANUPQData.io[ args[1] ];
  Add(args, "ApG");
  CallFuncList( PQ_PG_SUPPLY_AUTS, args );
end );

#############################################################################
##
#F  PqAPGSingleStage( <i> : <options> ) . user version of A p-G menu option 5
#F  PqAPGSingleStage( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to do a single stage of the descendants construction algorithm  as
##  prescribed  by  <options>.   The   possible   options   are   `StepSize',
##  `PcgsAutomorphisms',   `RankInitialSegmentSubgroups',   `SpaceEfficient',
##  `CapableDescendants',   `AllDescendants',    `Exponent',    `Metabelian',
##  `BasicAlgorithm' and `CustomiseOutput'. (Detailed descriptions  of  these
##  options may be found in Chapter~"ANUPQ Options".)
##
##  *Note:*
##  For those familiar with  the  `pq'  binary,  `PqAPGSingleStage'  performs
##  option 5 of the Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGSingleStage, function( arg )
local datarec, ngroups;
  PQ_OTHER_OPTS_CHK("PqAPGSingleStage", true);
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_MENU(datarec, "ApG");
  datarec.des.onestage := true;
  PQ_PG_CONSTRUCT_DESCENDANTS(datarec);
end );

#############################################################################
##
#F  PQ_APG_DEGREE( <datarec>, <step>, <rank> ) . . . . .  A p-G menu option 6
##
##  inputs data to the `pq' binary for option 6  of  the  Advanced  $p$-Group
##  Generation menu, to compute definition sets and find the degree.
##
InstallGlobalFunction( PQ_APG_DEGREE, function( datarec, step, rank )
local expt, line;
  expt := VALUE_PQ_OPTION("Exponent", 0, datarec);
  PQ_MENU(datarec, "ApG");
  ToPQ(datarec, [ 6 ], [ "  #compute defn sets and find degree" ]);
  ToPQ(datarec, [ step ], [ " #step size" ]);
  ToPQ(datarec, [ rank ], [ " #rank of initial segment subgroup" ]);
  datarec.match := "Degree of permutation group";
  ToPQ(datarec, [ expt ], [ " #exponent" ]);
  line := SplitString(datarec.matchedline, "", " \n");
  Unbind(datarec.match);
  return Int( line[6] );
end );

#############################################################################
##
#F  PqAPGDegree(<i>,<step>,<rank>[: Exponent := <n>]) . u ver A p-G menu op 6
#F  PqAPGDegree( <step>, <rank> [: Exponent := <n> ])
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary  to  compute  definition  sets  and  return  the  degree  of   the
##  permutation group. Here the step-size <step> and the rank <rank>  of  the
##  initial segment subgroup are positive integers. See~"option Exponent" for
##  the one recognised option `Exponent'.
##
##  *Note:* For those familiar with the `pq' binary,  `PqAPGDegree'  performs
##  menu item 6 of the Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGDegree, function( arg )
local len, datarec;
  PQ_OTHER_OPTS_CHK("PqAPGDegree", true);
  len := Length(arg);
  if not(len in [2, 3] or ForAll(arg, IsPosInt)) then
    Error("expected 2 or 3 positive integer arguments\n");
  fi;
  datarec := CallFuncList(ANUPQDataRecord, arg{[1 .. len - 2]});
  return PQ_APG_DEGREE( datarec, arg[len - 1], arg[len] );
end );

#############################################################################
##
#F  PQ_APG_PERMUTATIONS( <datarec> ) . . . . . . . . . .  A p-G menu option 7
##
##  inputs data to the `pq' binary for option 7  of  the  Advanced  $p$-Group
##  Generation menu, to compute permutations of subgroups.
##
InstallGlobalFunction( PQ_APG_PERMUTATIONS, function( datarec )
local pcgsauts, efficient, printauts, printperms;
  pcgsauts  := VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec);
  efficient := VALUE_PQ_OPTION("SpaceEfficient", false, datarec.des);
  printauts := VALUE_PQ_OPTION("PrintAutomorphisms", false);
  printperms := VALUE_PQ_OPTION("PrintPermutations", false);
  PQ_MENU(datarec, "ApG");
  ToPQ(datarec, [ 7 ], [ "  #compute permutations" ]);
  ToPQ_BOOL(datarec, pcgsauts, "compute pcgs gen. seq. for auts.");
  ToPQ_BOOL(datarec, efficient, "be space efficient");
  ToPQ_BOOL(datarec, printauts, "print automorphism matrices");
  ToPQ_BOOL(datarec, printperms, "print permutations");
end );

#############################################################################
##
#F  PqAPGPermutations( <i> : <options> ) . user version of A p-G menu optn. 7
#F  PqAPGPermutations( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to compute permutations of subgroups. Here the  options  <options>
##  recognised       are        `PcgsAutomorphisms',        `SpaceEfficient',
##  `PrintAutomorphisms' and `PrintPermutations' (see Chapter~"ANUPQ Options"
##  for details).
##
##  *Note:* For those familiar  with  the  `pq'  binary,  `PqAPGPermutations'
##  performs menu item 7 of the Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGPermutations, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqAPGPermutations", true);
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_PERMUTATIONS( datarec );
end );

#############################################################################
##
#F  PQ_APG_ORBITS( <datarec> ) . . . . . . . . . . . . .  A p-G menu option 8
##
##  inputs data to the `pq' binary for menu item 8 of the Advanced  $p$-Group
##  Generation menu, to compute orbits.
##
InstallGlobalFunction( PQ_APG_ORBITS, function( datarec )
local pcgsauts, efficient, output, summary, listing, line, norbits;
  pcgsauts  := VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec);
  efficient := VALUE_PQ_OPTION("SpaceEfficient", false, datarec.des);
  output := VALUE_PQ_OPTION("CustomiseOutput", rec(orbit := []), datarec.des);
  if not( IsRecord(output) and IsBound(output.orbit) and 
          IsList(output.orbit) ) then
    output := rec(orbit := []);
  fi;
  summary   := IsBound( output.orbit[1] ) and output.orbit[1] in [1, true];
  listing   := IsBound( output.orbit[2] ) and output.orbit[2] in [1, true];
  PQ_MENU(datarec, "ApG");
  ToPQ(datarec, [ 8 ], [ "  #compute orbits" ]);
  ToPQ_BOOL(datarec, pcgsauts, "compute pcgs gen. seq. for auts.");
  ToPQ_BOOL(datarec, efficient, "be space efficient");
  if summary then
    datarec.match := "Number of orbits is";
  elif listing then
    datarec.match := "Orbit ";
  fi;
  PQ_APG_CUSTOM_OUTPUT( datarec, "orbit", "orbit output",
                        ["print orbit summary",
                         "print complete orbit listing"] );
  if summary or listing then
    line := SplitString(datarec.matchedline, "", " \n");
    if summary then
      norbits := Int( line[5] );
    else
      norbits := Int( line[2] );
    fi;
    Unbind(datarec.match);
  else
    norbits := "";
  fi;
  return norbits;
end );

#############################################################################
##
#F  PqAPGOrbits( <i> : <options> ) . . .  user version of A p-G menu option 8
#F  PqAPGOrbits( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to compute the orbit action of the automorphism group, and  return
##  the number of orbits, if either a summary or a complete listing (or both)
##  of orbit information was requested. Here the options <options> recognised
##  are `PcgsAutomorphisms',  `SpaceEfficient',  and  `CustomiseOutput'  (see
##  Chapter~"ANUPQ Options" for details). For  the  `CustomiseOutput'  option
##  only the setting of the `orbit' is recognised (all other  fields  if  set
##  are ignored).
##
##  *Note:* For those familiar with the `pq' binary,  `PqAPGOrbits'  performs
##  menu item 8 of the Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGOrbits, function( arg )
local datarec, norbits;
  PQ_OTHER_OPTS_CHK("PqAPGOrbits", true);
  datarec := CallFuncList(ANUPQDataRecord, arg);
  norbits := PQ_APG_ORBITS( datarec );
  if norbits <> "" then
    return norbits;
  fi;
end );

#############################################################################
##
#F  PQ_APG_ORBIT_REPRESENTATIVES( <datarec> ) . . . . . . A p-G menu option 9
##
##  inputs data to the `pq' binary for menu item 9 of the Advanced  $p$-Group
##  Generation menu, to process orbit representatives.
##
InstallGlobalFunction( PQ_APG_ORBIT_REPRESENTATIVES, function( datarec )
local pcgsauts, efficient, exponent, metabelian, alldescend, outputfile;
  pcgsauts  := VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec);
  efficient := VALUE_PQ_OPTION("SpaceEfficient", false, datarec.des);
  exponent  := VALUE_PQ_OPTION("Exponent", false, datarec);
  metabelian := VALUE_PQ_OPTION("Metabelian", false, datarec);
  alldescend := not VALUE_PQ_OPTION(
                        "CapableDescendants",
                        VALUE_PQ_OPTION("AllDescendants", true),
                        datarec.des);
  outputfile := VALUE_PQ_OPTION("Filename", "redPCover", datarec.des);
  VALUE_PQ_OPTION("CustomiseOutput", rec(), datarec.des);
  PQ_MENU(datarec, "ApG");
  ToPQ(datarec, [ 9 ], [ "  #process orbit reps" ]);
  ToPQ_BOOL(datarec, pcgsauts, "compute pcgs gen. seq. for auts.");
  ToPQ_BOOL(datarec, efficient, "be space efficient");
  ToPQ_BOOL(datarec, alldescend, "completely process terminal descendants");
  ToPQ(datarec, [ exponent ], [ " #exponent" ]);
  ToPQ_BOOL(datarec, metabelian, " set metabelian");
  PQ_APG_CUSTOM_OUTPUT( datarec, "group", "group output",
                        ["print allowable subgp standard matrix",
                         "print pres'n of reduced p-covers",
                         "print pres'n of immediate descendants",
                         "print nuclear rank of descendants",
                         "print p-mult'r rank of descendants"] );
  PQ_APG_CUSTOM_OUTPUT( datarec, "autgroup", "aut. grp output",
                        ["print commutator matrix",
                         "print aut. grp descriptions of descendants",
                         "print aut. grp orders of descendants"] );
  ToPQ(datarec, [ outputfile ], [ " #output filename" ]);
end );

#############################################################################
##
#F  PqAPGOrbitRepresentatives(<i> : <options>) . user ver of A p-G menu opt 9
#F  PqAPGOrbitRepresentatives(: <options>)
##
##  for the <i>th or default interactive {\ANUPQ} process,  direct  the  `pq'
##  binary to process  the  orbit  representatives  and  output  the  reduced
##  $p$-cover to a file. The options <options> may be any of  the  following:
##  are  `PcgsAutomorphisms',  `SpaceEfficient',  `Exponent',   `Metabelian',
##  `CapableDescendants' (or `AllDescendants'), `CustomiseOutput' (where only
##  the `group' and `autgroup' fields are  recognised)  and  `Filename'  (see
##  Chapter~"ANUPQ Options"  for  details).  If  `Filename'  is  omitted  the
##  reduced $p$-cover is written to the file `"redPCover"' in  the  temporary
##  directory whose name is stored in `ANUPQData.tmpdir'.
##
##  *Note:*
##  For those familiar  with  the  `pq'  binary,  `PqAPGOrbitRepresentatives'
##  performs option 9 of the Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGOrbitRepresentatives, function( arg )
local datarec;
  PQ_OTHER_OPTS_CHK("PqAPGOrbitRepresentatives", true);
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_ORBIT_REPRESENTATIVES( datarec );
end );

#############################################################################
##
#F  PQ_APG_ORBIT_REPRESENTATIVE( <datarec> ) . . . . . . A p-G menu option 10
##
##  inputs data to the `pq' binary for option 10 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_ORBIT_REPRESENTATIVE, function( datarec )
end );

#############################################################################
##
#F  PqAPGOrbitRepresentative( <i> ) . .  user version of A p-G menu option 10
#F  PqAPGOrbitRepresentative()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGOrbitRepresentative' performs option 10 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGOrbitRepresentative, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_ORBIT_REPRESENTATIVE( datarec );
end );

#############################################################################
##
#F  PQ_APG_STANDARD_MATRIX_LABEL( <datarec> ) . . . . .  A p-G menu option 11
##
##  inputs data to the `pq' binary for option 11 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_STANDARD_MATRIX_LABEL, function( datarec )
end );

#############################################################################
##
#F  PqAPGStandardMatrixLabel( <i> ) . .  user version of A p-G menu option 11
#F  PqAPGStandardMatrixLabel()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGStandardMatrixLabel' performs option 11 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGStandardMatrixLabel, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_STANDARD_MATRIX_LABEL( datarec );
end );

#############################################################################
##
#F  PQ_APG_MATRIX_OF_LABEL( <datarec> ) . . . . . . . .  A p-G menu option 12
##
##  inputs data to the `pq' binary for option 12 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_MATRIX_OF_LABEL, function( datarec )
end );

#############################################################################
##
#F  PqAPGMatrixOfLabel( <i> ) . . . . .  user version of A p-G menu option 12
#F  PqAPGMatrixOfLabel()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGMatrixOfLabel' performs option 12 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGMatrixOfLabel, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_MATRIX_OF_LABEL( datarec );
end );

#############################################################################
##
#F  PQ_APG_IMAGE_OF_ALLOWABLE_SUBGROUP( <datarec> ) . .  A p-G menu option 13
##
##  inputs data to the `pq' binary for option 13 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_IMAGE_OF_ALLOWABLE_SUBGROUP, function( datarec )
end );

#############################################################################
##
#F  PqAPGImageOfAllowableSubgroup( <i> ) user version of A p-G menu option 13
#F  PqAPGImageOfAllowableSubgroup()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGImageOfAllowableSubgroup' performs option 13 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGImageOfAllowableSubgroup, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_IMAGE_OF_ALLOWABLE_SUBGROUP( datarec );
end );

#############################################################################
##
#F  PQ_APG_RANK_CLOSURE_OF_INITIAL_SEGMENT( <datarec> )  A p-G menu option 14
##
##  inputs data to the `pq' binary for option 14 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_RANK_CLOSURE_OF_INITIAL_SEGMENT, function( datarec )
end );

#############################################################################
##
#F  PqAPGRankClosureOfInitialSegment( <i> )  user version of A p-G menu option 14
#F  PqAPGRankClosureOfInitialSegment()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGRankClosureOfInitialSegment' performs option 14 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGRankClosureOfInitialSegment, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_RANK_CLOSURE_OF_INITIAL_SEGMENT( datarec );
end );

#############################################################################
##
#F  PQ_APG_ORBIT_REPRESENTATIVE_OF_LABEL( <datarec> ) .  A p-G menu option 15
##
##  inputs data to the `pq' binary for option 15 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_ORBIT_REPRESENTATIVE_OF_LABEL, function( datarec )
end );

#############################################################################
##
#F  PqAPGOrbitRepresentativeOfLabel( <i> )  user version of A p-G menu option 15
#F  PqAPGOrbitRepresentativeOfLabel()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGOrbitRepresentativeOfLabel' performs option 15 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGOrbitRepresentativeOfLabel, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_ORBIT_REPRESENTATIVE_OF_LABEL( datarec );
end );

#############################################################################
##
#F  PQ_APG_WRITE_COMPACT_DESCRIPTION( <datarec> ) . . .  A p-G menu option 16
##
##  inputs data to the `pq' binary for option 16 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_WRITE_COMPACT_DESCRIPTION, function( datarec )
end );

#############################################################################
##
#F  PqAPGWriteCompactDescription( <i> )  user version of A p-G menu option 16
#F  PqAPGWriteCompactDescription()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGWriteCompactDescription' performs option 16 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGWriteCompactDescription, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_WRITE_COMPACT_DESCRIPTION( datarec );
end );

#############################################################################
##
#F  PQ_APG_AUTOMORPHISM_CLASSES( <datarec> ) . . . . . . A p-G menu option 17
##
##  inputs data to the `pq' binary for option 17 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_AUTOMORPHISM_CLASSES, function( datarec )
end );

#############################################################################
##
#F  PqAPGAutomorphismClasses( <i> ) . .  user version of A p-G menu option 17
#F  PqAPGAutomorphismClasses()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGAutomorphismClasses' performs option 17 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGAutomorphismClasses, function( arg )
local datarec;
  datarec := CallFuncList(ANUPQDataRecord, arg);
  PQ_APG_AUTOMORPHISM_CLASSES( datarec );
end );

#E  anupqi.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
