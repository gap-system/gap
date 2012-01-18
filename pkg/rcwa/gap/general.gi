#############################################################################
##
#W  general.gi                 GAP4 Package `RCWA'                Stefan Kohl
##
##  This file contains some more general pieces of code which are not direct-
##  ly related to RCWA. Some of them might perhaps later be moved into the
##  GAP Library or elsewhere.
##
#############################################################################

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
#S  Some utility functions for lists and records. ///////////////////////////
##
#############################################################################

#############################################################################
##
#F  DifferencesList( <list> ) . . . . differences of consecutive list entries
#F  QuotientsList( <list> ) . . . . . . quotients of consecutive list entries
#F  FloatQuotientsList( <list> )  . . . . . . . . . . . . dito, but as floats
##
InstallGlobalFunction( DifferencesList,
                       list -> List( [ 2..Length(list) ],
                                     pos -> list[ pos ] - list[ pos-1 ] ) );
InstallGlobalFunction( QuotientsList,
                       list -> List( [ 2 .. Length( list ) ],
                                     pos -> list[ pos ] / list[ pos-1 ] ) );
InstallGlobalFunction( FloatQuotientsList,
                       list -> List( QuotientsList( list ), Float ) );

#############################################################################
##
#F  SearchCycle( <l> ) . . . a utility function for detecting cycles in lists
##
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
#F  AssignGlobals( <record> )
##
##  This auxiliary function assigns the record components of <record> to
##  global variables with the same names.
##
InstallGlobalFunction( AssignGlobals,

  function ( record )

    local  names, name;

    names := RecNames(record);
    for name in names do
      if IsBoundGlobal(name) then
        if IsReadOnlyGlobal(name)
        then
          MakeReadWriteGlobal(name);
          Info(InfoWarning,1,"The read-only global variable ",name,
                             " has been overwritten.");
        else
          Info(InfoWarning,1,"The global variable ",name,
                             " has been overwritten.");
        fi;
        UnbindGlobal(name);
      fi;
      BindGlobal(name,record.(name));
      MakeReadWriteGlobal(name);
    od;
    Print("The following global variables have been assigned:\n",
          names,"\n");
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
#S  The general trivial methods for `Trajectory'. ///////////////////////////
##
#############################################################################

#############################################################################
##
#M  Trajectory( <f>, <n>, <length> )
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

#############################################################################
##
#M  Trajectory( <f>, <n>, <terminal> )
##
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

#############################################################################
##
#M  Trajectory( <f>, <n>, <halt> )
##
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
#S  Some utilities for integers and combinatorics. //////////////////////////
##
#############################################################################

#############################################################################
##
#F  AllSmoothIntegers( <maxp>, <maxn> )
##
InstallGlobalFunction( AllSmoothIntegers,

  function ( maxp, maxn )

    local  extend, nums, primes, p;

    extend := function ( n, mini )

      local  i;

      if n > maxn then return; fi;
      Add(nums,n);
      for i in [mini..Length(primes)] do
        extend(primes[i]*n,i);
      od;
    end;

    primes := Filtered([2..maxp],IsPrimeInt);
    nums := [];
    extend(1,1);
    return Set(nums);
  end );

#############################################################################
##
#M  AllProducts( <D>, <k> ) . . all products of <k>-tuples of elements of <D>
#M  AllProducts( <l>, <k> ) . . . . . . . . . . . . . . . . . . . . for lists
##
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
InstallGlobalFunction(  ListOfPowers,

  function ( g, exp )

    local  powers, n;

    powers := [g];
    for n in [2..exp] do Add(powers,powers[n-1]*g); od;
    return powers;
  end );

#############################################################################
##
#M  GeneratorsAndInverses( <D> ) list of generators of <D> and their inverses
#M  GeneratorsAndInverses( <G> ) . . . . . . . . . . . . . . . . . for groups
##
InstallMethod( GeneratorsAndInverses,
               "for groups (RCWA)", true, [ IsGroup ], 0,
               G -> Concatenation(GeneratorsOfGroup(G),
                                  List(GeneratorsOfGroup(G),g->g^-1)) );

#############################################################################
##
#F  EpimorphismByGenerators( <D1>, <D2> ) .  epi.: gen's of <F>->gen's of <G>
#M  EpimorphismByGeneratorsNC( <D1>, <D2> ) .  NC version as underlying oper.
#M  EpimorphismByGeneratorsNC( <G>, <H> ) . . . . . . . . . . . .  for groups
##
InstallMethod( EpimorphismByGeneratorsNC,
               "for groups (RCWA)", ReturnTrue, [ IsGroup, IsGroup ], 0,
  function ( G, H )
    return GroupHomomorphismByImagesNC(G,H,GeneratorsOfGroup(G),
                                           GeneratorsOfGroup(H));
  end );
InstallGlobalFunction( EpimorphismByGenerators,
  function ( D1, D2 )
    return EpimorphismByGeneratorsNC(D1,D2);
  end );

#############################################################################
##
#M  AssignGeneratorVariables( <G> ) . .  for rcwa groups with at most 6 gen's
##
##  This method assigns the generators of <G> to global variables a, b, ... .
##
InstallMethod( AssignGeneratorVariables,
               "for rcwa groups with at most 6 generators (RCWA)",
               true, [ IsRcwaGroup ], 0,

  function ( G )

    local  gens, names, name, i;

    gens := GeneratorsOfGroup(G);
    if Length(gens) > 6 then TryNextMethod(); fi;
    names := "abcdef";
    for i in [1..Length(gens)] do
      name := names{[i]};
      if IsBoundGlobal(name) then
        if   IsReadOnlyGlobal(name)
        then Error("variable ",name," is read-only"); fi;
        UnbindGlobal(name);
        Info(InfoWarning,1,"The global variable ",name,
                           " has been overwritten.");
      fi;
      BindGlobal(name,gens[i]);
      MakeReadWriteGlobal(name);
    od;
    Print("The following global variables have been assigned: ");
    for i in [1..Length(gens)] do Print(names{[i]},", "); od;
    Print("\n");
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
#F  ReducedWordByOrdersOfGenerators( <w>, <orders> )
##
##  Reduce exponents of powers in a word modulo the orders of the
##  corresponding generators.
##
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
#S  Some utilities related to output or conversion to strings. //////////////
##
#############################################################################

#############################################################################
##
#F  LaTeXStringFactorsInt( <n> ) . . . . prime factorization in LaTeX format
##
InstallGlobalFunction( LaTeXStringFactorsInt,

  function ( n )

    local  facts, str, i; 

    if   not IsInt(n)
    then Error("usage: LaTeXStringFactorsInt( <n> ) for an integer <n>"); fi;

    if n < 0 then str := "-"; n := -n; else str := ""; fi;
    facts := Collected(Factors(n));
    for i in [1..Length(facts)] do
      Append(str,String(facts[i][1]));
      if facts[i][2] > 1 then
        Append(str,"^");
        if facts[i][2] >= 10 then Append(str,"{"); fi;
        Append(str,String(facts[i][2]));
        if facts[i][2] >= 10 then Append(str,"}"); fi;
      fi;
      if i < Length(facts) then Append(str," \\cdot "); fi;
    od;
    return str;
  end );

#############################################################################
##
#S  The code for loading and saving bitmap images. //////////////////////////
##
#############################################################################

#############################################################################
##
#F  SaveAsBitmapPicture( <picture>, <filename> ) . . . .  save bitmap picture
##
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

#############################################################################
##
#F  LoadBitmapPicture( <filename> ) . . . . . . . . . . . load bitmap picture
##
InstallGlobalFunction( LoadBitmapPicture,

  function ( filename )

    local  str, picture, height, width, fullwidth, vec8, chunk, x, y, i;

    if   not IsString(filename)
    then Error("usage: LoadBitmapPicture( <filename> )\n"); fi;

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

#############################################################################
##
#S  Some routines for drawing images. ///////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  DrawGrid( <U>, <range_y>, <range_x>, <filename> )
##
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
#S  Utility to run a demonstration in a talk. ///////////////////////////////
##
#############################################################################

#############################################################################
##
#F  RunDemonstration( <filename> ) . . . . . . . . . . .  run a demonstration
##
if not IsBound(last ) then last  := fail; fi;
if not IsBound(last2) then last2 := fail; fi;
if not IsBound(last3) then last3 := fail; fi;
if not IsBound(time ) then time  := fail; fi;

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
#S  Utility to convert GAP log files to XHTML 1.0 Strict. ///////////////////
##
#############################################################################

#############################################################################
##
#F  Log2HTML ( logfilename ) . . . . convert GAP log file to XHTML 1.0 Strict
##
InstallGlobalFunction( Log2HTML,

  function ( logfilename )

    local  outputname, s1, s2, header, footer, pos,
           lastlf, nextlf, crlf, prompt;

    if ARCH_IS_UNIX() then crlf := 1; else crlf := 2; fi;
    header := Concatenation(
                "<?xml version = \"1.0\" encoding = \"ISO-8859-1\"?>\n\n",
                "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n",
                "                      \"http://www.w3.org/TR/xhtml1/DTD/",
                "xhtml1-strict.dtd\">\n<html>\n\n<head>\n  <title> ",
                logfilename, " </title>\n  <link rel = \"stylesheet\" ",
                "type = \"text/css\" href = \"gaplog.css\" />\n",
                "</head>\n\n<body>\n\n<pre class = \"logfile\">\n");
    footer := "</pre> </body> </html>";
    s1 := StringFile(logfilename);
    pos := PositionSublist(s1,"gap>"); prompt := "gap> ";
    s2 := ReplacedString(s1{[1..pos-1]},"<","&lt;");
    while pos <> fail do
      s2 := Concatenation(s2,"<em class = \"prompt\">",prompt,"</em>");
      s2 := Concatenation(s2,"<em class = \"input\">");
      nextlf := Position(s1,'\n',pos); prompt := "gap>";
      if nextlf = fail then nextlf := Length(s1); fi;
      s2 := Concatenation(s2,ReplacedString(s1{[pos+5..nextlf-crlf]},
                                            "<","&lt;"),"</em>");
      while nextlf < Length(s1) and s1[nextlf+1] = '>' do
        s2 := Concatenation(s2,"\n<em class = \"prompt\">></em>",
                            "<em class = \"input\">");
        lastlf := nextlf;
        nextlf := Position(s1,'\n',lastlf);
        if nextlf = fail then nextlf := Length(s1); fi;
        s2 := Concatenation(s2,ReplacedString(s1{[lastlf+2..nextlf-crlf]},
                                              "<","&lt;"),"</em>");
      od;
      s2 := Concatenation(s2,"\n");
      pos := PositionSublist(s1,"\ngap>",nextlf-1);
      if pos = fail then pos := Length(s1); fi;
      if pos > nextlf then
        s2 := Concatenation(s2,"<em class = \"output\">",
                            ReplacedString(s1{[nextlf+1..pos-crlf]},
                                           "<","&lt;"),"</em>\n");
      fi;
      if pos > Length(s1) - 3 then break; fi;
    od;
    s2 := Concatenation(header,s2,footer);
    logfilename := LowercaseString(logfilename); 
    if   PositionSublist(logfilename,".log") <> fail
    then outputname := ReplacedString(logfilename,".log",".html");
    elif PositionSublist(logfilename,".txt") <> fail
    then outputname := ReplacedString(logfilename,".txt",".html");
    else outputname := Concatenation(logfilename,".html"); fi;
    FileString(outputname,s2);
  end );

#############################################################################
##
#S  Test utilities. /////////////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  ReadTestWithTimings( <filename> ) . . . read test file and return timings
##
InstallGlobalFunction( ReadTestWithTimings,

  function ( filename )

    local  timings, filewithtimings, inputlines, outputlines, isinput,
           line, nextline, pos, intest, commands, command, lastbuf, i;

    isinput := function ( line )
      if Length(line) < 1 then return false; fi;
      if line[1] = '>' then return true; fi;
      if Length(line) < 4 then return false; fi;
      if line{[1..4]} = "gap>" then return true; fi;
      return false;
    end;

    if   not IsString(filename)
    then Error("usage: ReadTestWithTimings( <filename> )"); fi;

    inputlines := SplitString(StringFile(filename),"\n");
    outputlines := []; intest := false; commands := []; command := [];
    for pos in [1..Length(inputlines)] do
      line := inputlines[pos];
      Add(outputlines,line);
      if PositionSublist(line,"START_TEST") <> fail then intest := true; fi;
      if PositionSublist(line,"STOP_TEST") <> fail then intest := false; fi;
      if intest then
        if isinput(line) then Add(command,line); fi;
        nextline := inputlines[pos+1];
        if not isinput(line) and isinput(nextline) then
          Add(commands,[pos-1,JoinStringsWithSeparator(command,"\n")]);
          command := [];
          Add(outputlines,"gap> lastbuf := [last,last2,last3];;");
          Add(outputlines,"gap> runtime := Runtime()-TEST_START_TIME;;");
          Add(outputlines,"gap> Add(TEST_TIMINGS,runtime);");
          Add(outputlines,"gap> TEST_START_TIME := Runtime();;");
          Add(outputlines,"gap> last3 := lastbuf[3];;");
          Add(outputlines,"gap> last2 := lastbuf[2];;");
          Add(outputlines,"gap> last1 := lastbuf[1];;");
        fi;
      fi;
    od;
    outputlines := JoinStringsWithSeparator(outputlines,"\n");
    filename := SplitString(filename,"/");
    filename := filename[Length(filename)];
    filewithtimings := Filename(DirectoryTemporary(),filename);
    FileString(filewithtimings,outputlines);
    Unbind(TEST_TIMINGS);
    BindGlobal("TEST_TIMINGS",[]);
    MakeReadWriteGlobal("TEST_TIMINGS");
    BindGlobal("TEST_START_TIME",Runtime());
    MakeReadWriteGlobal("TEST_START_TIME"); 
    Test(filewithtimings);
    timings := TEST_TIMINGS;
    UnbindGlobal("TEST_TIMINGS");
    UnbindGlobal("TEST_START_TIME");
    if   Length(timings) <> Length(commands)
    then Error("ReadTestWithTimings: #commands <> #timings"); fi;
    return List([1..Length(commands)],i->[commands[i],timings[i]]);
  end );

#############################################################################
##
#F  ReadTestCompareTimings( <filename> [,<timingsdir> [,<createreference> ] )
##
InstallGlobalFunction( ReadTestCompareRuntimes,

  function ( arg )

    local  filename, timingsdir, createreference, testdir,
           timingsname, slashpos, oldtimings, newtimings, testnrs,
           changes, changed, runtimechangesignificance, threshold, n, i;

    runtimechangesignificance := function ( oldtime, newtime )
      return AbsInt(newtime-oldtime)/(10*RootInt(oldtime)+100);
    end;

    filename := arg[1];
    slashpos := Positions(filename,'/');
    slashpos := slashpos[Length(slashpos)];
    testdir  := filename{[1..slashpos]};
    if   Length(arg) >= 2
    then timingsdir := arg[2]; else timingsdir := testdir; fi;
    if   Length(arg) >= 3
    then createreference := arg[3]; else createreference := false; fi;
    if not IsString(filename) or not IsBool(createreference) then
      Error("usage: ReadTestCompareTimings( <filename> ",
            "[, <createreference> ] )");
    fi;
    timingsname := ReplacedString(filename,testdir,timingsdir);
    timingsname := ReplacedString(timingsname,".tst",".runtimes");
    if   not IsExistingFile(timingsname)
    then createreference := true;
    else oldtimings := ReadAsFunction(timingsname)(); fi;
    newtimings := ReadTestWithTimings(filename);
    if createreference then
      PrintTo(timingsname,"return ",newtimings,";\n");
    else
      n := Length(oldtimings);
      if Length(newtimings) < n or TransposedMat(newtimings)[1]{[1..n]}
                                <> TransposedMat(oldtimings)[1]
      then
        Info(InfoWarning,1,"Test file ",filename);
        Info(InfoWarning,1,"has changed, thus performance ",
                           "cannot be compared.");
        Info(InfoWarning,1,"Please create new reference timings.");
      else
        testnrs := [1..n];
        changes := List([1..n],
                        i->runtimechangesignificance(newtimings[i][2],
                                                     oldtimings[i][2]));
        SortParallel(-changes,testnrs);
        threshold := 1; # significance threshold for runtime change
        changed := Filtered(testnrs,i->changes[i]>threshold);
        for i in changed do
          Print("Line ",oldtimings[i][1][1],": ");
          if   newtimings[i][2] < oldtimings[i][2]
          then Print("speedup "); else Print("slowdown "); fi;
          Print(oldtimings[i][2],"ms -> ",newtimings[i][2],"ms\n");
          Print(oldtimings[i][1][2],"\n");
        od;
      fi;
    fi;
  end );

#############################################################################
##
#E  general.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here