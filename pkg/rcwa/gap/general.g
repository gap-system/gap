#############################################################################
##
#W  general.g                 GAP4 Package `RCWA'                 Stefan Kohl
##
#H  @(#)$Id: general.g,v 1.46 2009/10/05 12:11:36 stefan Exp $
##
##  This file contains some more general pieces of code which are not direct-
##  ly related to RCWA. Some of them might perhaps later be moved into the
##  GAP Library or elsewhere.
##
Revision.general_g :=
  "@(#)$Id: general.g,v 1.46 2009/10/05 12:11:36 stefan Exp $";

#############################################################################
##
#S  Take care of the change of the interface for floats. ////////////////////
##
if   VERSION = "4.dev" or not IsBound( Float ) then
  if IsReadOnlyGlobal("Float") then MakeReadWriteGlobal("Float"); fi;
  BindGlobal( "Float",
    function ( a )
      if not IsString(a) then a := String(a); fi;
      return MACFLOAT_STRING(a);
    end );
fi;

#############################################################################
##
#S  Some GAP Library bugfixes. //////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#M  \*( <n>, infinity ) . . . . . . . . . . for positive integer and infinity
#M  \*( infinity, <n> ) . . . . . . . . . . for infinity and positive integer
#M  \*( infinity, infinity )  . . . . . . . . . . . for infinity and infinity
##
##  In GAP 4.4.7, the GAP Library function `DirectProduct' and the general
##  method for `DirectProductOp' run into error if one of the factors is
##  known to be infinite. The methods below are installed as a workaround.
##  As maybe there are further similar places where finiteness is assumed
##  implicitly, it may be good if these methods remain available after 4.4.8.
##
InstallMethod( \*, "for positive integer and infinity (RCWA)",
               ReturnTrue, [ IsPosInt, IsInfinity ], 0,
               function ( n, infty ) return infinity; end );
InstallMethod( \*, "for infinity and positive integer (RCWA)",
               ReturnTrue, [ IsInfinity, IsPosInt ], 0,
               function ( infty, n ) return infinity; end );
InstallMethod( \*, "for infinity and infinity (RCWA)",
               ReturnTrue, [ IsInfinity, IsInfinity ], 0,
               function ( infty1, infty2 ) return infinity; end );

#############################################################################
##
#S  Some utility functions for lists. ///////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  Positions( <list>, <elm> ) . (the Library function, for old GAP versions)
##
if not IsBound( Positions ) then
BindGlobal( "Positions",
  function ( list, elm )
    return Filtered( [ 1 .. Length( list ) ], i -> list[ i ] = elm );
  end );
fi;

#############################################################################
##
#F  DifferencesList( <list> ) . . . . differences of consecutive list entries
#F  QuotientsList( <list> ) . . . . . . quotients of consecutive list entries
#F  FloatQuotientsList( <list> )  . . . . . . . . . . . . dito, but as floats
##
if not IsBound( DifferencesList ) then # Don't overwrite if bound otherwise.
BindGlobal( "DifferencesList",
            list -> List( [ 2..Length(list) ], i -> list[i] - list[i-1] ) );
fi;
if not IsBound( QuotientsList ) then
BindGlobal( "QuotientsList",
            list -> List( [ 2 .. Length( list ) ],
                          pos -> list[ pos ] / list[ pos - 1 ] ) );
fi;
BindGlobal( "FloatQuotientsList",
            list -> List( QuotientsList( list ), Float ) );

#############################################################################
##
#F  SearchCycle( <l> ) . . . a utility function for detecting cycles in lists
##
DeclareGlobalFunction( "SearchCycle" );
InstallGlobalFunction( SearchCycle,

  function ( l )

    local  pos, incr, refine;

    if Length(l) < 2 then return fail; fi;
    pos := 1; incr := 1;
    while Length(Set(List([1..Int((Length(l)-pos+1)/incr)],
                          i->l{[pos+(i-1)*incr..pos+i*incr-1]}))) > 1 do
      pos := pos + 1; incr := incr + 1;
      if pos + 2*incr-1 > Length(l) then return fail; fi;
    od;
    refine := SearchCycle(l{[pos..pos+incr-1]});
    if refine <> fail then return refine;
                      else return l{[pos..pos+incr-1]}; fi;
  end );

#############################################################################
##
#M  Trajectory( <f>, <n>, <length> )
#M  Trajectory( <f>, <n>, <terminal> )
#M  Trajectory( <f>, <n>, <halt> )
##
##  The general trivial methods.
##
InstallOtherMethod( Trajectory,
                    "for function, starting point and length (RCWA)",
                    ReturnTrue, [ IsFunction, IsObject, IsPosInt ], 0,

  function ( f, n, length )

    local  l, i;

    l := [n];
    for i in [2..length] do
      n := f(n);
      Add(l,n);
    od;
    return l;
  end );

InstallOtherMethod( Trajectory,
                    "for function, starting point and terminal set (RCWA)",
                    ReturnTrue, [ IsFunction, IsObject, IsListOrCollection ],
                    0,

  function ( f, n, terminal )

    local  l, i;

    l := [n];
    while not n in terminal do
      n := f(n);
      Add(l,n);
    od;
    return l;
  end );

InstallOtherMethod( Trajectory,
                    "for function, starting point and halting criterion (RCWA)",
                    ReturnTrue, [ IsFunction, IsObject, IsFunction ],
                    0,

  function ( f, n, halt )

    local  l, i;

    l := [n];
    while not halt(n) do
      n := f(n);
      Add(l,n);
    od;
    return l;
  end );

#############################################################################
##
#M  EquivalenceClasses( <list>, <relation> )
#M  EquivalenceClasses( <list>, <classinvariant> )
##
##  Returns a list of equivalence classes on <list> under <relation>
##  or a list of equivalence classes on <list> given by <classinvariant>,
##  respectively.
##
##  The argument <relation> must be a function which takes as arguments
##  two entries of <list> and returns either true or false, and which
##  describes an equivalence relation on <list>.
##  The argument <classinvariant> must be a function which takes as argument
##  an element of <list> and returns a class invariant.
##  
InstallOtherMethod( EquivalenceClasses,
                    "for a list and a relation or a class invariant (RCWA)",
                    ReturnTrue, [ IsList, IsFunction ], 0,

  function ( list, relation )

    local  classes, invs, longestfirst, byinvs, elm, pos, inserted, count;

    if IsEmpty(list) then return []; fi;

    longestfirst := function(c1,c2) return Length(c1) > Length(c2); end;
    byinvs := function(c1,c2) return relation(c1[1]) < relation(c2[1]); end;

    if   NumberArgumentsFunction(relation) = 1 then
      invs    := List(list,relation);
      classes := List(Set(invs),inv->list{Positions(invs,inv)});
      Sort(classes,byinvs);
    elif NumberArgumentsFunction(relation) = 2 then
      classes := [[list[1]]]; count := 0;
      for elm in list{[2..Length(list)]} do
        inserted := false; count := count + 1;
        for pos in [1..Length(classes)] do
          if relation(elm,classes[pos][1]) then
            Add(classes[pos],elm);
            inserted := true;
            break;
          fi;
        od;
        if   not inserted
        then classes := Concatenation(classes,[[elm]]); fi;
        if   count mod 100 = 0 # rough performance heuristics ...
        then Sort(classes,longestfirst); fi;
      od;
      Sort(classes,longestfirst);
    else TryNextMethod(); fi;

    return classes;
  end );

#############################################################################
##
#S  Some utilities for combinatorics. ///////////////////////////////////////
##
#############################################################################

#############################################################################
##
#O  AllProducts( <D>, <k> ) . . all products of <k>-tuples of elements of <D>
#M  AllProducts( <l>, <k> ) . . . . . . . . . . . . . . . . . . . . for lists
##
DeclareOperation( "AllProducts", [ IsListOrCollection, IsPosInt ] );
InstallMethod( AllProducts,
               "for lists (RCWA)", ReturnTrue, [ IsList, IsPosInt ], 0,
               function ( l, k ) return List(Tuples(l,k),Product); end );

#############################################################################
##
#F  RestrictedPartitionsWithoutRepetitions( <n>, <S> )
##
##  Given a positive integer n and a set of positive integers S, this func-
##  tion returns a list of all partitions of n into distinct elements of S.
##  The only difference to `RestrictedPartitions' is that no repetitions are
##  allowed.
##
DeclareGlobalFunction( "RestrictedPartitionsWithoutRepetitions" );
InstallGlobalFunction( RestrictedPartitionsWithoutRepetitions,

  function ( n, S )

    local  look, comps;

    look := function ( comp, remaining_n, remaining_S )

      local  newcomp, newremaining_n, newremaining_S, part, l;

      l := Reversed(remaining_S);
      for part in l do
        newcomp        := Concatenation(comp,[part]);
        newremaining_n := remaining_n - part;
        if newremaining_n = 0 then Add(comps,newcomp);
        else
          newremaining_S := Set(Filtered(remaining_S,
                                         s->s<part and s<=newremaining_n));
          if newremaining_S <> [] then
            look(newcomp,newremaining_n,newremaining_S);
          fi;
        fi;
      od;
    end;

    comps := [];
    look([],n,S);
    return comps;
  end );

#############################################################################
##
#S  Some utilities for groups, group elements and homomorphisms. ////////////
##
#############################################################################

#############################################################################
##
#F  ListOfPowers( <g>, <exp> ) . . . . . .  list of powers <g>^1 .. <g>^<exp>
##
DeclareGlobalFunction( "ListOfPowers" );
InstallGlobalFunction(  ListOfPowers,

  function ( g, exp )

    local  powers, n;

    powers := [g];
    for n in [2..exp] do Add(powers,powers[n-1]*g); od;
    return powers;
  end );

#############################################################################
##
#O  GeneratorsAndInverses( <D> ) list of generators of <D> and their inverses
#M  GeneratorsAndInverses( <G> ) . . . . . . . . . . . . . . . . . for groups
##
DeclareOperation( "GeneratorsAndInverses", [ IsMagmaWithInverses ] );
InstallMethod( GeneratorsAndInverses,
               "for groups (RCWA)", true, [ IsGroup ], 0,
               G -> Concatenation(GeneratorsOfGroup(G),
                                  List(GeneratorsOfGroup(G),g->g^-1)) );

#############################################################################
##
#F  EpimorphismByGenerators( <D1>, <D2> ) .  epi.: gen's of <F>->gen's of <G>
#O  EpimorphismByGeneratorsNC( <D1>, <D2> ) .  NC version as underlying oper.
#M  EpimorphismByGeneratorsNC( <G>, <H> ) . . . . . . . . . . . .  for groups
##
DeclareOperation( "EpimorphismByGeneratorsNC", [ IsDomain, IsDomain ] );
InstallMethod( EpimorphismByGeneratorsNC,
               "for groups (RCWA)", ReturnTrue, [ IsGroup, IsGroup ], 0,
  function ( G, H )
    return GroupHomomorphismByImagesNC(G,H,GeneratorsOfGroup(G),
                                           GeneratorsOfGroup(H));
  end );
DeclareGlobalFunction( "EpimorphismByGenerators" );
InstallGlobalFunction( EpimorphismByGenerators,
  function ( D1, D2 )
    return EpimorphismByGeneratorsNC(D1,D2);
  end );

#############################################################################
##
#M  AbelianInvariants( <G> ) . .  for groups knowing an iso. to a pcp group
#M  AbelianInvariants( <G> ) . .  for groups knowing an iso. to a perm.-group
##
InstallMethod( AbelianInvariants,
               "for groups knowing an isomorphism to a pcp group", true,
               [ IsGroup and HasIsomorphismPcpGroup ], 0,
               G -> AbelianInvariants(Image(IsomorphismPcpGroup(G))) );
InstallMethod( AbelianInvariants,
               "for groups knowing an isomorphism to a permutation group",
               true, [ IsGroup and HasIsomorphismPermGroup ], 0,
               G -> AbelianInvariants(Image(IsomorphismPermGroup(G))) );

#############################################################################
##
#F  FindGroupRelations( <G>, <r> ) . placebo `ReturnFail' if FR is not loaded
##
if   not IsReadOnlyGlobal( "FindGroupRelations" )
then FindGroupRelations := ReturnFail; fi;

#############################################################################
##
#F  ReducedWordByOrdersOfGenerators( <w>, <orders> )
##
##  Reduce exponents of powers in a word modulo the orders of the
##  corresponding generators.
##
DeclareGlobalFunction( "ReducedWordByOrdersOfGenerators" );
InstallGlobalFunction(  ReducedWordByOrdersOfGenerators,

  function ( w, orders )

    local  ext, fam, i;

    fam := FamilyObj(w);
    ext := ShallowCopy(ExtRepOfObj(w));
    for i in [1,3..Length(ext)-1] do
      if orders[ext[i]] < infinity then
        ext[i+1] := ext[i+1] mod orders[ext[i]];
        if   ext[i+1] > orders[ext[i]]/2
        then ext[i+1] := ext[i+1] - orders[ext[i]]; fi;
      fi;
    od;
    return ObjByExtRep(fam,ext);
  end );

#############################################################################
##
#S  The code for loading and saving bitmap images. //////////////////////////
##
#############################################################################

#############################################################################
##
#F  SaveAsBitmapPicture( <picture>, <filename> )
##
##  Writes the pixel matrix <picture> to a bitmap- (bmp-) picture file
##  named <filename>. The filename should include the entire pathname.
##
##  The argument <picture> can be a GF(2) matrix, in which case a monochrome
##  picture file is generated. In this case, zeros stand for black pixels and
##  ones stand for white pixels.
##
##  The argument <picture> can also be an integer matrix, in which case
##  a 24-bit True Color picture file is generated. In this case, the entries
##  of the matrix are supposed to be integers n = 65536*red+256*green+blue in
##  the range 0,...,2^24-1 specifying the RGB values of the colors of the
##  pixels.
##
if not IsBound( SaveAsBitmapPicture ) then
DeclareGlobalFunction( "SaveAsBitmapPicture" );
InstallGlobalFunction( SaveAsBitmapPicture,

  function ( picture, filename )

    local  AppendHex, Append16Bit, Append32Bit, str, colored,
           height, width, fullwidth, length, offset, vec8, pix,
           chunk, fill, x, y, n, i;

    Append16Bit := function ( n )
      Add(str,CHAR_INT(n mod 256)); Add(str,CHAR_INT(Int(n/256)));
    end;

    Append32Bit := function ( n )
      Add(str,CHAR_INT(n mod 256)); n := Int(n/256);
      Add(str,CHAR_INT(n mod 256)); n := Int(n/256);
      Add(str,CHAR_INT(n mod 256)); n := Int(n/256);
      Add(str,CHAR_INT(n));
    end;

    if not IsMatrix(picture) or not IsString(filename)
      or (not IsInt(picture[1][1]) and not picture[1][1] in GF(2))
    then Error("usage: SaveAsBitmapPicture( <picture>, <filename> )\n"); fi;

    colored := IsInt(picture[1][1]);
    height  := Length(picture);
    width   := Length(picture[1]);
    if colored then fullwidth := width + (width mod 4)/3;
    elif width mod 32 <> 0 then
      fullwidth := width + 32 - width mod 32;
      fill := List([1..fullwidth-width],i->Zero(GF(2)));
      ConvertToGF2VectorRep(fill);
      picture := List(picture,line->Concatenation(line,fill));
    else fullwidth := width; fi;
    str := "BM";
    if colored then offset := 54; length := 3 * fullwidth * height + offset;
               else offset := 62; length := (fullwidth * height)/8 + offset;
    fi;
    for n in [length,0,offset,40,width,height] do Append32Bit(n); od;
    Append16Bit(1);
    if colored then
      Append16Bit(24);
      for i in [1..6] do Append32Bit(0); od;
      for y in [1..height] do
        for x in [1..width] do
          pix := picture[y][x];
          Add(str,CHAR_INT(pix mod 256)); pix := Int(pix/256);
          Add(str,CHAR_INT(pix mod 256)); pix := Int(pix/256);
          Add(str,CHAR_INT(pix));
        od;
        for i in [1..width mod 4] do Add(str,CHAR_INT(0)); od;
      od;
    else # monochrome picture
      Append16Bit(1);
      for i in [1..6] do Append32Bit(0); od;
      Append32Bit(0); Append32Bit(2^24-1);
      vec8 := List([0..255],i->CoefficientsQadic(i+256,2){[8,7..1]})*Z(2)^0;
      for i in [1..256] do ConvertToGF2VectorRep(vec8[i]); od;
      for y in [1..height] do
        for x in [1,9..fullwidth-7] do
          Add(str,CHAR_INT(PositionSorted(vec8,picture[y]{[x..x+7]})-1));
        od;
      od;
    fi;
    FileString(filename,str);
  end );
fi;

#############################################################################
##
#F  ReadFromBitmapPicture( <filename> )
##
##  Reads the bitmap picture file <filename> created by `SaveAsBitmapPicture'
##  back into GAP. The function returns the pixel matrix <picture>, as it has
##  been passed as an argument to `SaveAsBitmapPicture'. The file passed to
##  this function must be an uncompressed monochrome or 24-bit True Color
##  bitmap file.
##
if not IsBound( ReadFromBitmapPicture ) then
DeclareGlobalFunction( "ReadFromBitmapPicture" );
InstallGlobalFunction( ReadFromBitmapPicture,

  function ( filename )

    local  str, picture, height, width, fullwidth, vec8, chunk, x, y, i;

    if   not IsString(filename)
    then Error("usage: ReadFromBitmapPicture( <filename> )\n"); fi;

    str    := StringFile(filename);
    width  := List(str{[19..22]},INT_CHAR) * List([0..3],i->256^i);
    height := List(str{[23..26]},INT_CHAR) * List([0..3],i->256^i);
    if INT_CHAR(str[29]) = 24 then # 24-bit RGB picture
      fullwidth := width + (width mod 4)/3;
      picture := List([1..height],
                      y->List([1..Int(fullwidth)],
                              x->List(str{[55+3*(fullwidth*(y-1)+x-1)..
                                           55+3*(fullwidth*(y-1)+x-1)+2]},
                                      INT_CHAR)
                                *[1,256,65536]));
    else # monochrome picture
      if width mod 32 = 0 then fullwidth := width;
                          else fullwidth := width + 32 - width mod 32; fi;
      vec8 := List([0..255],i->CoefficientsQadic(i+256,2){[8,7..1]})*Z(2)^0;
      for i in [1..256] do ConvertToGF2VectorRep(vec8[i]); od;
      picture := List([1..height],y->Concatenation(List([1,9..fullwidth-7],
                     x->vec8[INT_CHAR(str[63+(fullwidth*(y-1)+x-1)/8])+1])));
    fi;
    if width = fullwidth then return picture;
                         else return picture{[1..height]}{[1..width]}; fi;
  end );
fi;

#############################################################################
##
#S  Some routines for drawing images. ///////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  DrawGrid( <U>, <range_y>, <range_x>, <filename> )
##
##  Draws a picture of the residue class union <U> of Z^2 or the partition
##  <U> of Z^2 into residue class unions, respectively.
##
DeclareGlobalFunction( "DrawGrid" );
InstallGlobalFunction( DrawGrid,

  function ( U, range_y, range_x, filename )

    local  grid, x, y, one, offset_x, offset_y, colors, color, pos;

    if   not (   IsResidueClassUnionOfZxZ(U)
              or IsList(U) and ForAll(U,IsResidueClassUnionOfZxZ))
      or not IsRange(range_y) or not IsRange(range_x)
      or not IsString(filename)
    then
      Error("usage: DrawGrid( <U>, <range_y>, <range_x>, <filename> )\n");
      return fail;
    fi;

    offset_x := -Minimum(range_x) + 1;
    offset_y := -Minimum(range_y) + 1;

    if IsResidueClassUnionOfZxZ(U) then

      grid     := NullMat(Length(range_y),Length(range_x),GF(2));
      one      := One(GF(2));

      for y in range_y do for x in range_x do
        if not [y,x] in U then grid[y+offset_y][x+offset_x] := one; fi;
      od; od;

    else

      colors := [[255,0,0],[0,255,0],[0,0,255],[255,255,0],[255,0,255],
                 [0,255,255],[255,128,128],[128,255,128],[128,128,255]]
              * [65536,256,1];

      grid := NullMat(Length(range_y),Length(range_x));

      for y in range_y do
        for x in range_x do
          pos := First([1..Length(U)],k->[y,x] in U[k]);
          if   pos = fail then color := 0;
          elif pos > Length(colors) then color := 2^24-1;
          else color := colors[pos]; fi;
          grid[y+offset_y][x+offset_x] := color;
        od;
      od;

    fi;

    SaveAsBitmapPicture( grid, filename );

  end );

#############################################################################
##
#S  Utilities to be used in talks. //////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  RunDemonstration( <filename> ) . . . . . . . . . . .  run a demonstration
##
##  This is a function to run little demonstrations, for example in talks.
##  It is adapted from the function `Demonstration' in the file lib/demo.g
##  of the main GAP distribution. 
##
if not IsBound(last ) then last  := fail; fi;
if not IsBound(last2) then last2 := fail; fi;
if not IsBound(last3) then last3 := fail; fi;
if not IsBound(time ) then time  := fail; fi;

DeclareGlobalFunction( "RunDemonstration" );
InstallGlobalFunction( RunDemonstration,

  function ( filename )

    local  input, string, lines, doublesemicolonlines,
           keyboard, linenumber, result, storedtime;

    string := StringFile( filename );
    if string = fail then Error( "Cannot open file ", filename ); fi;
    lines := SplitString(string,"\n");
    doublesemicolonlines := Filtered( [1..Length(lines)],
                                      i -> Number(lines[i],ch->ch=';') > 1 );

    input := InputTextFile( filename );
    InputLogTo( OutputTextUser(  ) );
    keyboard := InputTextUser();

    Print( "\033[1m\033[34mgap> \033[0m\c" );
    linenumber := 1;

    while CHAR_INT( ReadByte( keyboard ) ) <> 'q' do
      storedtime := Runtime();
      # Print( "\033[31m\c" );
      result := READ_COMMAND( input, true ); # Executing the command.
      # Print( "\033[0m\c" );
      time := Runtime() - storedtime;
      if result <> SuPeRfail then
        last3 := last2;
        last2 := last;
        last := result;
        if   not linenumber in doublesemicolonlines
        then View( result ); Print( "\n" ); fi;
      fi;
      if IsEndOfStream( input ) then break; fi;
      Print( "\033[1m\033[34mgap> \033[0m\c" );
      linenumber := linenumber + 1;
    od;

    Print( "\n" );
    CloseStream( keyboard );
    CloseStream( input );
    InputLogTo();

  end );

#############################################################################
##
#E  general.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here