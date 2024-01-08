#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Robert F. Morse.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for magma congruences
##
##  Maintenance and further development by:
##  Robert F. Morse
##  Andrew Solomon
##
##


#############################################################################
##
#M  PrintObj( <S> )
##  print a [left, right, two-sided] Magma Congruence
##

##  left magma congruence

InstallMethod( PrintObj,
    "for a left magma congruence",
    true,
    [ IsLeftMagmaCongruence ], 0,
    function( S )
        Print( "LeftMagmaCongruence( ... )" );
    end );

InstallMethod( PrintObj,
    "for a left magma congruence with known generating pairs",
    true,
    [ IsLeftMagmaCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "LeftMagmaCongruence( ",
               GeneratingPairsOfMagmaCongruence( S ), " )" );
    end );

##  right magma congruence

InstallMethod( PrintObj,
    "for a right magma congruence",
    true,
    [ IsRightMagmaCongruence ], 0,
    function( S )
        Print( "RightMagmaCongruence( ... )" );
    end );

InstallMethod( PrintObj,
    "for a right magma congruence with known generating pairs",
    true,
    [ IsRightMagmaCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "RightMagmaCongruence( ",
               GeneratingPairsOfMagmaCongruence( S ), " )" );
    end );


##  two sided magma congruence

InstallMethod( PrintObj,
    "for a magma congruence",
    true,
    [ IsMagmaCongruence ], 0,
    function( S )
        Print( "MagmaCongruence( ... )" );
    end );

InstallMethod( PrintObj,
    "for a magma Congruence with known generating pairs",
    true,
    [ IsMagmaCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "MagmaCongruence( ",
                GeneratingPairsOfMagmaCongruence( S ), " )" );
    end );

#############################################################################
##
#M  ViewObj( <S> )
##
##  view a [left,right,two-sided] magma congruence
##

##  left magma congruence

InstallMethod( ViewObj,
    "for a LeftMagmaCongruence",
    true,
    [ IsLeftMagmaCongruence ], 0,
    function( S )
        Print( "<LeftMagmaCongruence>" );
    end );

InstallMethod( ViewObj,
    "for a LeftMagmaCongruence with known generating pairs",
    true,
    [ IsLeftMagmaCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "<LeftMagmaCongruence with ",
               Length( GeneratingPairsOfMagmaCongruence( S ) ),
               " generating pairs>" );
    end );

##  right magma congruence

InstallMethod( ViewObj,
    "for a RightMagmaCongruence",
    true,
    [ IsRightMagmaCongruence ], 0,
    function( S )
        Print( "<RightMagmaCongruence>" );
    end );

InstallMethod( ViewObj,
    "for a RightMagmaCongruence with generators",
    true,
    [ IsRightMagmaCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "<RightMagmaCongruence with ",
               Length( GeneratingPairsOfMagmaCongruence( S ) ),
               " generating pairs>" );
    end );

## two sided magma congruence

InstallMethod( ViewObj,
    "for a magma congruence",
    true,
    [ IsMagmaCongruence ], 0,
    function( S )
        Print( "<MagmaCongruence>" );
    end );

InstallMethod( ViewObj,
    "for a magma congruence with generating pairs",
    true,
    [ IsMagmaCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "<MagmaCongruence with ",
               Length( GeneratingPairsOfMagmaCongruence( S ) ),
               " generating pairs>" );
    end );

#############################################################################
##
#M  LR2MagmaCongruenceByGeneratingPairsCAT(<F>,<rels>,<category>)
##
##  create the magma congruence with generating pairs <rels> as
##  a <category> where <category> is IsLeftMagmaCongruence,
##  IsRightMagmaCongruence or IsMagmaCongruence.
##
InstallGlobalFunction( LR2MagmaCongruenceByGeneratingPairsCAT,
function(F, gens, category )

    local r, cong, fam;

    # Check that the relations are all lists of length 2
    for r in gens do
        if Length(r) <> 2 then
            Error("A relation should be a list of length 2");
        fi;
    od;

    # Create the equivalence relation
    fam := GeneralMappingsFamily( ElementsFamily(FamilyObj(F)),
               ElementsFamily(FamilyObj(F)) );

    # Create the default type for the elements.
    cong := Objectify(NewType(fam,
                category and IsEquivalenceRelationDefaultRep), rec());
    SetSource(cong, F);
    SetRange(cong, F);

    # Add the generators in the appropriate attribute
    #    They are all set in a common place with special names
    #    as needed
    if (category = IsMagmaCongruence) then
        SetGeneratingPairsOfMagmaCongruence(cong, Immutable(gens));
    elif (category = IsLeftMagmaCongruence) then
        SetGeneratingPairsOfLeftMagmaCongruence(cong, Immutable(gens));
    elif (category = IsRightMagmaCongruence) then
        SetGeneratingPairsOfRightMagmaCongruence(cong, Immutable(gens));
    else
        Error("Invalid category ",category," of Magma congruence");
    fi;
    return cong;
end);


#############################################################################
##
#M  LR2MagmaCongruenceByPartitionNCCAT(<F>,<part>,<category>)
##
##  create the magma congruence with partition <part> as
##  a <category> where <category> is IsLeftMagmaCongruence,
##  IsRightMagmaCongruence or IsMagmaCongruence.
##
##  <part> is a list of lists containing (at least) all of the non singleton
##  blocks of the partition.  It is not checked that <part> is actually
##  a congruence in the category specified.
##
InstallGlobalFunction( LR2MagmaCongruenceByPartitionNCCAT,
function(F, part, cat)

    local cong, fam;

    # The only cheap check we can do:
    if not IsElmsColls(FamilyObj(F), FamilyObj(part)) then
        Error("<part> should be a list of lists of elements of the magma");
    fi;


    # Create the equivalence relation
    fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(F)),
                ElementsFamily(FamilyObj(F)) );

    # Create the default type for the elements.
    cong :=  Objectify(NewType(fam,
                 cat and IsEquivalenceRelationDefaultRep), rec());
    SetSource(cong, F);
    SetRange(cong, F);
    SetEquivalenceRelationPartition(cong, part);


    return cong;
end);

#############################################################################
##
#M  LeftMagmaCongruenceByGeneratingPairs( <D>, <gens> )
#M  RightMagmaCongruenceByGeneratingPairs( <D>, <gens> )
#M  MagmaCongruenceByGeneratingPairs( <D>, <gens> )
##
InstallMethod( LeftMagmaCongruenceByGeneratingPairs,
    "for a magma and a list of pairs of its elements",
    IsElmsColls,
    [ IsMagma, IsList ], 0,
    function( M, gens )
        return LR2MagmaCongruenceByGeneratingPairsCAT(M, gens,
                   IsLeftMagmaCongruence);
    end );

InstallMethod( LeftMagmaCongruenceByGeneratingPairs,
    "for a magma and an empty list",
    true,
    [ IsMagma, IsList and IsEmpty ], 0,
    function( M, gens )
        return LR2MagmaCongruenceByGeneratingPairsCAT(M, gens,
                   IsLeftMagmaCongruence);
    end );

InstallMethod( RightMagmaCongruenceByGeneratingPairs,
    "for a magma and a list of pairs of its elements",
    IsElmsColls,
    [ IsMagma, IsList ], 0,
    function( M, gens )
        return LR2MagmaCongruenceByGeneratingPairsCAT(M, gens,
               IsRightMagmaCongruence);
    end );

InstallMethod( RightMagmaCongruenceByGeneratingPairs,
    "for a magma and an empty list",
    true,
    [ IsMagma, IsList and IsEmpty ], 0,
    function( M, gens )
        return LR2MagmaCongruenceByGeneratingPairsCAT(M, gens,
                   IsRightMagmaCongruence);
    end );

InstallMethod( MagmaCongruenceByGeneratingPairs,
    "for a magma and a list of pairs of its elements",
    IsElmsColls,
    [ IsMagma, IsList ], 0,
    function( M, gens )
      local c;


      c :=  LR2MagmaCongruenceByGeneratingPairsCAT(M, gens,
           IsMagmaCongruence);

      if HasIsSemigroup(M) and IsSemigroup(M) then
        SetIsSemigroupCongruence(c,true);
      fi;

      return c;
    end );


InstallMethod( MagmaCongruenceByGeneratingPairs,
    "for a magma and an empty list",
    true,
    [ IsMagma, IsList and IsEmpty ], 0,
    function( M, gens )
      local c;

      c :=  LR2MagmaCongruenceByGeneratingPairsCAT(M, gens,
           IsMagmaCongruence);

      if HasIsSemigroup(M) and IsSemigroup(M) then
        SetIsSemigroupCongruence(c,true);
      fi;

      return c;
    end );

#############################################################################
##
#M  EquivalenceClasses( <E> )
##
##  For a MagmaCongruence
##
InstallMethod(EquivalenceClasses,
    "for magma congruences", true, [IsMagmaCongruence], 0,
    function(e)
        local part,         # the partition of the equivalence relation
              distinctreps; # the reprentatives of distinct non-trivial
                            # congruence classes

        part := EquivalenceRelationPartition(e);
        distinctreps := List(part,x->x[1]);
        return List(distinctreps, x->EquivalenceClassOfElementNC(e, x));
    end);

#############################################################################
##
#M  \*( <x1>, <x2> )
##
##  Product of congruence classes. As in fp-semigroups we just
##  multiply without worrying about getting the representative right.
##  Then we check equality when doing < or =.
##
InstallMethod( \*,
    "for two magma congruence classes",
    IsIdenticalObj,
    [ IsCongruenceClass, IsCongruenceClass ],
    0,

    function( x1, x2 )
        if EquivalenceClassRelation(x1) <> EquivalenceClassRelation(x2) then
            Error("Can only multiply classes of the same congruence");
        fi;
        return EquivalenceClassOfElementNC(EquivalenceClassRelation(x1),
                   Representative(x1)*Representative(x2));
    end );

############################################################################
##
#M  One(<congruence class>)
##
##  It is installed as
##  OtherMethod to appease GAP since the selection filters
##  IsCongruenceClass and IsMultiplicativeElementWithOne
##  match two declarations of One - the first filter for domains,
##  the second filter for IsMultiplicativeElementWithOne.
##
InstallOtherMethod(One,
"One(<congruence class>)", true,
[IsCongruenceClass and IsMultiplicativeElementWithOne], 0,
    function(x)
        return EquivalenceClassOfElement(EquivalenceClassRelation(x),
                   One(Representative(x)));
    end);

######################################################################
##
#F  MagmaCongruencePartition(<cong>,<partialcond>)
##
##  This function sets one of the two attributes
##
##       EquivalenceRelationPartition
##       PartialClosureOfCongruence
##
##  depending on whether full closure is found or partial closure is
##  found. Both of these attributes are partitions of the magma's
##  elements. If a previously computed PartialClosureOfCongruence satisfies
##  the <partialcond> no computations are performed.
##
##  A left magma congruence, right magma congruence, and magma congruence
##  is the smallest equivalence relation containing the generating pairs
##  closed under the operations of left multiplication, right
##  multiplication or both respectively.
##
##  If the magma is infinite (or very large) it may not be possible to compute
##  the entire partition. <partialcond> allows for a stop condition (possibly)
##  short of full closure. The function <partialcond> takes two parameters
##  (congruence, forest). Other variables that might be needed by <partialcond>
##  should be assigned to globals variables before MagmaCongruencePartition is
##  called.
##
##  A PartialClosureOfCongruence reflects a partial computation that can be used
##  in subsequent computations. Hence it is a mutable attribute.
##
##  A partial closure is also provided if either one block or the number of
##  blocks exceeds 64,000 in length. The partial closure attribute is stored for
##  the user to inspect.
##
##  This algorithm is based on Atkinson et. al. (Group Theory on a
##  Microcomputer, in Computational Group Theory, 1984).
##
##  Non-trivial blocks are considered trees and the block system a forest
##
##  Data representation:
##     o Forest is a list of non-empty lists with no holes.
##     o Each list in the forest represents a non-empty tree of depth 1
##       with root the first element (hence it has at least 2 elements).
##
##     If follows from the data representations that full path compression
##     is used.
##
##     The merging of blocks can only be done via list Append.
##     This insures that the root of the left tree being merged does not change
##     and hence is an invariant.
##
######################################################################
BindGlobal("MagmaCongruencePartition",
    function(cong,partialcond)

        local C,         #Initial branches (given pairs)
              forest,    #Forest in which each tree is a block
              i,p,g,j,   #index variables
              r1,r2,     #roots of possible blocks to merge
              p1,p2,     #positions of the blocks
              gens,      #Required generators (in generality all the elements
              maxlimit,  #Maximum size for either a partition or number of
                         #    partition;
              checklimit,#Function for checking limit
              equivrel;  #Initial forest (if there is not partial closure)

        ## Set up limits on the size and number of partitions we can
        ##    create a check function
        ##
        maxlimit := 64000;
        checklimit := function()
            if Length(forest) >= maxlimit then return true; fi;
            if First(forest, x->Length(x)>=maxlimit) <> fail then return true; fi;
            return false;
        end;

        ## check that we know the generators ....
        ##
        if not HasGeneratingPairsOfMagmaCongruence(cong) then
            Error("MagmaCongruencePartition requires GeneratingPairsOfMagmaCongruence");
        fi;

        if not ((HasGeneratorsOfMagma(Source(cong)) or
                HasGeneratorsOfMagmaWithInverses(Source(cong))) or
               (HasIsFinite(Source(cong)) and IsFinite(Source(cong)) )) then
            Error("MagmaCongruencePartition requires generators for underlying semigroup or list of all elements");
        fi;

        ## does the partition already exist if so return done deal
        ##
        if HasEquivalenceRelationPartition(cong) then
            return;
        fi;

        ## check to see if we are to generate the trivial relation
        ##
        ## Filter all pairs of the form (a,a).
        ##   if this filtered set is empty return the diagonal
        ##   equivalence
        ##
        C := List(Filtered(GeneratingPairsOfMagmaCongruence(cong),
                 x->not x[1]=x[2]), ShallowCopy);

        if IsEmpty(C) then
            SetEquivalenceRelationPartition(cong,[]);
            return;
        fi;

        C := Set(C);

        ## Set the forest either to the partial closure from a previous
        ##   call or find the smallest equivalence relation
        ##   containing the filtered generators
        ##
        if HasPartialClosureOfCongruence(cong) then
            forest := ShallowCopy(PartialClosureOfCongruence(cong));
            C := ShallowCopy(cong!.C);
        else
            equivrel := EquivalenceRelationPartition(
                            EquivalenceRelationByPairsNC(Source(cong),C));
            forest := List(equivrel, ShallowCopy);
        fi;

        ## Check partial closure might be fulfilled by initial closure
        ##
        if partialcond(cong,forest) then
            SetPartialClosureOfCongruence(cong,forest);
            cong!.C := MakeImmutable(C);
            return;
        fi;

        ## Determine whether we can use generators or need
        ##     all the elements
        ##
        ## If the Magma is associative then use generators
        ##
        #T If the magam has a generating set but is not associative
        #T then use an iterator. One need to be implemented
        ##
        ## else use elements of the magma
        ##
        if HasGeneratorsOfMagmaWithInverses(Source(cong)) and
               HasIsAssociative(Source(cong)) and
                   IsAssociative(Source(cong)) then
            gens := GeneratorsOfMagmaWithInverses(Source(cong));
        elif HasGeneratorsOfMagma(Source(cong)) and
                 HasIsAssociative(Source(cong)) and
                     IsAssociative(Source(cong)) then
            gens := GeneratorsOfMagma(Source(cong));
        elif HasGeneratorsOfMagma(Source(cong)) and
                 HasIsFinite(Source(cong)) and
                     IsFinite(Source(cong)) then
            gens := AsSSortedList(Source(cong));
        else
            gens := AsSSortedList(Source(cong));
        fi;

        ##
        ## Work through the branches in the forest above
        ##    determining the closure wrt left and right
        ##    translations following Atkinson et. al.
        ##
        repeat

            p := C[1];
            RemoveSet(C,C[1]);

            for g in gens do

                p1 := Length(forest)+1;
                p2 := Length(forest)+1;

                if IsRightMagmaCongruence(cong) then
                    ##
                    ## Search the forest to see if each right translation
                    ##     is in one of the blocks (trees) in the forest
                    ##     Get out a soon as both are found
                    ##
                    for i in [1..Length(forest)] do
                        if p1>Length(forest) and p[1]*g in forest[i] then
                            r1 := forest[i][1];
                            p1 := i;
                            if p2<=Length(forest) then break; fi;
                        fi;
                        if p2>Length(forest) and p[2]*g in forest[i] then
                            r2 := forest[i][1];
                            p2 := i;
                            if p1<=Length(forest) then break; fi;
                        fi;
                    od;

                    ##
                    ## If the translation is not in any of the
                    ##     blocks already defined make the element
                    ##     a root to a potential block
                    ##
                    if p1=Length(forest)+1 then
                        r1:=p[1]*g;
                    fi;
                    if p2=Length(forest)+1 then
                        r2:=p[2]*g;
                    fi;
                    ##
                    ## If the roots are different
                    ##     merge the blocks they represent
                    ##
                    if r1<>r2 then
                        ##
                        ## Merging of two existing blocks
                        ##     we must complete the Append and
                        ##     get rid of the one block without
                        ##     leaving a hole
                        ##
                        if p1<=Length(forest) and p2<=Length(forest) and
                               not p1=p2 then
                            Append(forest[p1],forest[p2]);
                            Unbind(forest[p2]);

                            ## No holes are left is at the end otherwise
                            ##    move the last one into the middle
                            if p2<Length(forest) then
                                forest[p2]:=Remove(forest);
                            fi;

                        ## Simple cases of merging a new element with
                        ##     an existing block
                        elif p1<=Length(forest) and not p2<=Length(forest) then
                            Add(forest[p1],r2);

                        elif p2<=Length(forest) and not p1<=Length(forest) then
                            Add(forest[p2],r1);

                        ## Add new non-trivial block made up of r1 and r2
                        else
                             Add(forest,[r1,r2]);
                        fi;

                        ## Add the new branch to C
                        AddSet(C,[r1,r2]);
                    fi;

                fi;

                if IsLeftMagmaCongruence(cong) then

                    ##
                    ## Complete the left translations in an exact
                    ##     manner as above
                    ##

                    p1 := Length(forest)+1;
                    p2 := Length(forest)+1;

                    for i in [1..Length(forest)] do
                        if p1>Length(forest) and g*p[1] in forest[i] then
                            r1 := forest[i][1];
                            p1 := i;
                            if p2<=Length(forest) then break; fi;
                        fi;
                            if p2>Length(forest) and g*p[2] in forest[i] then
                            r2 := forest[i][1];
                            p2 := i;
                            if p1<=Length(forest) then break; fi;
                        fi;
                    od;

                    if p1=Length(forest)+1 then
                        r1:=g*p[1];
                    fi;

                    if p2=Length(forest)+1 then
                        r2:=g*p[2];
                    fi;

                    if r1<>r2 then
                        if p1<=Length(forest) and p2<=Length(forest)
                               and not p1=p2 then
                            Append(forest[p1],forest[p2]);
                            Unbind(forest[p2]);
                            if p2<Length(forest) then
                                forest[p2]:=Remove(forest);
                            fi;
                        elif p1<=Length(forest) and not p2<=Length(forest) then
                            Add(forest[p1],r2);
                        elif p2<=Length(forest) and not p1<=Length(forest) then
                            Add(forest[p2],r1);
                        else
                            Add(forest,[r1,r2]);
                        fi;
                        AddSet(C,[r1,r2]);
                    fi;
                fi;
            od;

            ## Exit conditions are:
            ##     full closure is complete
            ##     we have created a partition larger than our limit
            ##     partial closure condition is satisfied
            ##
        until IsEmpty(C) or checklimit() or partialcond(cong,forest);

        ## Set the equivalence partition if we have full closure
        ##
        if IsEmpty(C) then
            SetEquivalenceRelationPartition(cong,forest);

        ## Set partial closure if partialcond is met or
        ##   size limit has been reached
        ##
        elif partialcond(cong,forest) then
            SetPartialClosureOfCongruence(cong,forest);
            cong!.C := MakeImmutable(C);
        elif checklimit() then
            Info(InfoWarning,1,
                "The congruence has either over 64,000 blocks or a \n",
                "#I block with over 64,000 elements. Hence only a\n",
                "#I a partial closure has been completed. You may view\n",
                "#I this partition using the 'PartialClosureOfCongruence'\n",
                "#I attribute");
            SetPartialClosureOfCongruence(cong,forest);
            cong!.C := MakeImmutable(C);
        else
            Error("error, internal error in mgmcong.gi");
        fi;
    end);

######################################################################
##
##  EquivalenceRelationPartition(<cong>)
##  Calculate the partition attribute of a left congruence
##
######################################################################

InstallMethod(EquivalenceRelationPartition,
    "for a left congruence on a magma",
    true,
    [IsLeftMagmaCongruence], 0,

    function(cong) # cong a congruence.

        # close the congruence with respect to left mult.
        MagmaCongruencePartition(cong,function(x,y) return false; end);
        return EquivalenceRelationPartition(cong);

    end);

######################################################################
##
##  EquivalenceRelationPartition(<cong>)
##  Calculate the partition attribute of a right congruence
##
######################################################################

InstallMethod(EquivalenceRelationPartition,
    "for a right congruence on a magma",
    true,
    [IsRightMagmaCongruence], 0,

    function(cong) # cong a congruence.

        # close the congruence with respect to right mult.
        MagmaCongruencePartition(cong,function(x,y) return false; end);
        return EquivalenceRelationPartition(cong);

    end);

######################################################################
##
##  EquivalenceRelationPartition(<cong>)
##  Calculate the partition attribute of a congruence
##
######################################################################

InstallMethod(EquivalenceRelationPartition,
    "for a congruence on a magma",
    true,
    [IsMagmaCongruence], 0,

    function(cong) # cong a congruence.

        # close the congruence with respect to left and right mult.
        MagmaCongruencePartition(cong,function(x,y) return false; end);
        return EquivalenceRelationPartition(cong);

    end);

#############################################################################
##
#M JoinMagmaCongruences(<cong1>,<cong2>)
##
## Find the transitive closure of equivalence relations represented by
##    cong1 and cong2
##
InstallMethod(JoinMagmaCongruences,
    "for magma congruences", true,
    [IsMagmaCongruence, IsMagmaCongruence],0,

    function(c1,c2)
        local
            er,      # Join is equivalence relations
            cong;    # Join congruence

        # Check to see that the both congruences have the same
        #     parent magma
        #
        if Source(c1)<>Source(c2) then
            Error("usage: the source of <cong1> and <cong2> must be the same");
        fi;

        # Find the join of the two congruences ar equivalence relations
        #
        er := JoinEquivalenceRelations(c1,c2);

        # Create the congruence and set the partition to that of
        #     of er
        #
        cong := LR2MagmaCongruenceByGeneratingPairsCAT(Source(c1),
            Union(GeneratingPairsOfMagmaCongruence(c1),
                      GeneratingPairsOfMagmaCongruence(c2)),
            IsMagmaCongruence);

        cong!.EquivalenceRelationPartition := EquivalenceRelationPartition(er);

        if HasIsAssociative(Source(c1)) and IsAssociative(Source(c1)) then
            SetIsSemigroupCongruence(cong,true);
        fi;
        return cong;
    end);

#############################################################################
##
#M MeetMagmaCongruences(<cong1>,<cong2>)
##
## Find the meet of the equivalence relations represented by
##    cong1 and cong2
##
InstallMethod(MeetMagmaCongruences,
    "for magma congruences", true,
    [IsMagmaCongruence, IsMagmaCongruence],0,

    function(c1,c2)
        local
            er,      # Meet os equivalence relations
            cong;    # Meet congruence

        # Check to see that the both congruences have the same
        #     parent magma
        #
        if Source(c1)<>Source(c2) then
            Error("The source of <cong1> and <cong2> must be the same");
        fi;

        # Find the meet of the two congruences as equivalence relations
        #
        er := MeetEquivalenceRelations(c1,c2);

        # Create the congruence and set the partition to that of
        #     of er
        #
        cong := LR2MagmaCongruenceByGeneratingPairsCAT(Source(c1),
            Intersection(GeneratingPairsOfMagmaCongruence(c1),
                      GeneratingPairsOfMagmaCongruence(c2)),
            IsMagmaCongruence);

        cong!.EquivalenceRelationPartition := EquivalenceRelationPartition(er);

        if HasIsAssociative(Source(c1)) and IsAssociative(Source(c1)) then
            SetIsSemigroupCongruence(cong,true);
        fi;

        return cong;
    end);

#############################################################################
##
#M  \in( <x>, <C> )
##
##  Checks whether <x> is contained in the magma congruence class <C>
##  If <C> is infinite, this will not necessarily terminate.
##
InstallMethod( \in, "for a magma congruence class", true,
     [IsObject, IsCongruenceClass], 0,

     function(x, C)
         local
             partialclosure,           #Partial closure
             part,                     #Partition
             rep,
             rel,
             class,
             GLOBAL_SEARCH_ELEMENT,
             GLOBAL_REP;

         # first ensure that <x> is in the right family
         if FamilyObj(x) <>
             ElementsFamily(FamilyObj(Source(EquivalenceClassRelation(C)))) then
             Error("incompatible arguments for \\in");
         fi;

         # quick check to see if element is representative
         if x=Representative(C) then return true; fi;

         ## If the partition has been computed let the equivalence relation
         ## method deal with it
         if HasEquivalenceRelationPartition(EquivalenceClassRelation(C)) then
             TryNextMethod();
         fi;

         ## We have partial closure see if this is enough
         ##
         if HasPartialClosureOfCongruence(EquivalenceClassRelation(C)) then
             part := PartialClosureOfCongruence(EquivalenceClassRelation(C));
             rep := Representative(C);
             class := First(part,y->rep in y);

             # the partial closure has the elements in the same class
             #    return true
             if class <> fail and x in class then
                 return true;
             fi;
         fi;

         ## Need to see if a partial closure can give an answer
         ##     NOT possible to give a negative solution if the number
         ##     of blocks or the size of a block is infinite
         ##
         GLOBAL_REP := Representative(C);
         GLOBAL_SEARCH_ELEMENT := x;
         rel := EquivalenceClassRelation(C);

         ## These global variables are constant and used
         ##     in the following partial closure test:
         ##     stop when the search element is found in
         ##     a block with the class's representative
         ##
         partialclosure :=
             function(cong, forest)
                 local block;
                 block := First(forest,y-> GLOBAL_SEARCH_ELEMENT in y);
                 if block=fail then return false; fi;
                 return  GLOBAL_REP in block;
             end;
         MagmaCongruencePartition(rel, partialclosure);

         ## We might have gotten a full closure from this call if so
         ##     delegate the next method to determine if we have
         ##     the element in the class
         ## Otherwise the partial condition must have been satisfied
         ##    return true
         ##
         if HasEquivalenceRelationPartition(rel) then
             TryNextMethod();
         else
             return true;
         fi;
     end);

#############################################################################
##
#M  Enumerator( <C> )
##
##  Enumerator for a magma congruence class.
##
InstallMethod( Enumerator, "for a magma congruence class", true,
    [IsCongruenceClass], 0,

    function(class)
        local   cong;  # the congruence of which class is a class

        cong := EquivalenceClassRelation(class);

        ## if the partition is already known, just go through the
        ## generic equivalence class method else compute the partition
        ## then get lazy and call generic equivalence
        ##
        if HasEquivalenceRelationPartition(EquivalenceClassRelation(class)) then
            TryNextMethod();
        else
            MagmaCongruencePartition(cong,function(x,y) return false; end);
            TryNextMethod();
        fi;

    end);

#############################################################################
##
#M      EquivalenceClassOfElement( <C>, <rep> )
#M      EquivalenceClassOfElementNC( <C>, <rep> )
##
##      Returns the equivalence class of an element <rep> with respect to a
##      magma congrucene <C>.   No calculation is performed at this stage.
##      We do not always wish to check that <rep> is in the underlying set
##      of <C>, since we may wish to use equivalence relations to perform
##      membership tests (for example when checking membership of a
##      transformation in a monoid, we use Greens relations and classes).
##
InstallMethod(EquivalenceClassOfElementNC,
"for magma congruence with no check",
[IsMagmaCongruence, IsObject],
function(rel, rep)
  local filts, new;

  filts:= IsCongruenceClass and IsEquivalenceClassDefaultRep;

  if IsMultiplicativeElementWithOne(rep) then
    filts:=filts and IsMultiplicativeElementWithOne;
  else
    filts:=filts and IsMultiplicativeElement;
  fi;

  if IsAssociativeElement(rep) then
    filts:=filts and IsAssociativeElement;
  fi;

  new:= Objectify(NewType(CollectionsFamily(FamilyObj(rep)), filts), rec());

  SetEquivalenceClassRelation(new, rel);
  SetRepresentative(new, rep);
  SetParent(new, UnderlyingDomainOfBinaryRelation(rel));
  return new;
end);

InstallMethod(EquivalenceClassOfElementNC,
        "for magma congruence with no check", true,
        [IsLeftMagmaCongruence, IsObject], 0,
function(rel, rep)
    local new;

    if IsMultiplicativeElementWithOne(rep) then
         new:= Objectify(NewType(CollectionsFamily(FamilyObj(rep)),
                   IsCongruenceClass and IsEquivalenceClassDefaultRep
                   and IsMultiplicativeElementWithOne), rec());
    else
         new:= Objectify(NewType(CollectionsFamily(FamilyObj(rep)),
                   IsCongruenceClass and IsEquivalenceClassDefaultRep
                   and IsMultiplicativeElement), rec());
    fi;

    SetEquivalenceClassRelation(new, rel);
    SetRepresentative(new, rep);
    SetParent(new, UnderlyingDomainOfBinaryRelation(rel));
    return new;
end);

InstallMethod(EquivalenceClassOfElementNC,
    "for magma congruence with no check", true,
    [IsRightMagmaCongruence, IsObject], 0,
    function(rel, rep)
        local new;

        if IsMultiplicativeElementWithOne(rep) then
             new:= Objectify(NewType(CollectionsFamily(FamilyObj(rep)),
                       IsCongruenceClass and IsEquivalenceClassDefaultRep
                       and IsMultiplicativeElementWithOne), rec());
        else
             new:= Objectify(NewType(CollectionsFamily(FamilyObj(rep)),
                       IsCongruenceClass and IsEquivalenceClassDefaultRep
                       and IsMultiplicativeElement), rec());
        fi;

        SetEquivalenceClassRelation(new, rel);
        SetRepresentative(new, rep);
        SetParent(new, UnderlyingDomainOfBinaryRelation(rel));
        return new;
    end);

InstallMethod(EquivalenceClassOfElement, "for magma congruence with checking", true,
    [IsMagmaCongruence, IsObject], 0,
    function(rel, rep)

        if not rep in UnderlyingDomainOfBinaryRelation(rel) then
            Error("Representative must lie in underlying set of the relation");
        fi;

        return EquivalenceClassOfElementNC(rel, rep);
    end);

InstallMethod(EquivalenceClassOfElement, "for left magma congruence with checking", true,
    [IsLeftMagmaCongruence, IsObject], 0,
    function(rel, rep)

        if not rep in UnderlyingDomainOfBinaryRelation(rel) then
            Error("Representative must lie in underlying set of the relation");
        fi;

        return EquivalenceClassOfElementNC(rel, rep);
    end);

InstallMethod(EquivalenceClassOfElement, "for right magma congruence with checking", true,
    [IsRightMagmaCongruence, IsObject], 0,
    function(rel, rep)

        if not rep in UnderlyingDomainOfBinaryRelation(rel) then
            Error("Representative must lie in underlying set of the relation");
        fi;

        return EquivalenceClassOfElementNC(rel, rep);
    end);

#############################################################################
##
#M  ImagesElm( <rel>, <elm> )  . . . for a  magma congruence
##  assume we can compute the partition
##
InstallMethod( ImagesElm,
    "for magma congruence and element",
    FamSourceEqFamElm,
    [ IsMagmaCongruence, IsObject ], 0,
    function( rel, elm )
        return Set(Enumerator(EquivalenceClassOfElement(rel,elm)));
    end);

#############################################################################
##
#M  ImagesElm( <rel>, <elm> )  . . . for a left magma congruence
##  assume we can compute the partition
##
InstallMethod( ImagesElm,
    "for magma congruence and element",
    FamSourceEqFamElm,
    [ IsLeftMagmaCongruence, IsObject ], 0,
    function( rel, elm )
        return Set(Enumerator(EquivalenceClassOfElement(rel,elm)));
    end);

#############################################################################
##
#M  ImagesElm( <rel>, <elm> )  . . . for a  right magma congruence
##  assume we can compute the partition
##
InstallMethod( ImagesElm,
    "for magma congruence and element",
    FamSourceEqFamElm,
    [ IsRightMagmaCongruence, IsObject ], 0,
    function( rel, elm )
        return Set(Enumerator(EquivalenceClassOfElement(rel,elm)));
    end);
