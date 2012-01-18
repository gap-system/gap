#############################################################################
##
#W  csetperm.gi                     GAP library              Alexander Hulpke
#W                                                             Heiko Theißen
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for cosets of permutation groups
##

#############################################################################
##
#F  MinimizeExplicitTransversal( <U>, <maxmoved> )  . . . . . . . . . . local
##
InstallGlobalFunction( MinimizeExplicitTransversal, function( U, maxmoved )
    local   explicit,  lenflock,  flock,  lenblock,  index,  s;
    
    if     IsBound( U.explicit )
       and IsBound( U.stabilizer )  then
        explicit := U.explicit;
        lenflock := U.stabilizer.index * U.lenblock / Length( U.orbit );
        flock    := U.flock;
        lenblock := U.lenblock;
        index    := U.index;
        ChangeStabChain( U, [ 1 .. maxmoved ] );
        for s  in [ 1 .. Length( explicit ) ]  do
            explicit[ s ] := MinimalElementCosetStabChain( U, explicit[ s ] );
        od;
        Sort( explicit );
        U.explicit := explicit;
        U.lenflock := lenflock;
        U.flock    := flock;
        U.lenblock := lenblock;
        U.index    := index;
    fi;
end );

#############################################################################
##
#F  RightTransversalPermGroupConstructor( <filter>, <G>, <U> )  . constructor
##
MAX_SIZE_TRANSVERSAL := 100000;

BindGlobal( "RightTransversalPermGroupConstructor", function( filter, G, U )
  local GC, UC, noyet, orbs, domain, GCC, UCC, ac, nc, bpt, enum, i;

    GC := CopyStabChain( StabChainMutable( G ) );
    UC := CopyStabChain( StabChainMutable( U ) );
    noyet:=ValueOption("noascendingchain")<>true;
    if not IsTrivial( G )  then
        orbs := ShallowCopy( OrbitsDomain( U, MovedPoints( G ) ) );
        Sort( orbs, function( o1, o2 )
            return Length( o1 ) < Length( o2 ); end );
        domain := Concatenation( orbs );
	GCC:=GC;
	UCC:=UC;
        while    Length( GCC.genlabels ) <> 0
              or Length( UCC.genlabels ) <> 0  do
#Print(SizeStabChain(GCC),"/",SizeStabChain(UCC),":",
#  SizeStabChain(GCC)/SizeStabChain(UCC),"\n");
          if noyet and (
	  (SizeStabChain(GCC)/SizeStabChain(UCC)*10 >MAX_SIZE_TRANSVERSAL) or
	  (Length(UCC.genlabels)=0 and
	    SizeStabChain(GCC)>MAX_SIZE_TRANSVERSAL)
	    ) then
	    # we potentially go through many steps, making it expensive
	    ac:=AscendingChain(G,U:cheap);
	    # go in biggish steps through the chain
	    nc:=[ac[1]];
	    for i in [3..Length(ac)] do
	      if Size(ac[i])/Size(nc[Length(nc)])>MAX_SIZE_TRANSVERSAL then
		Add(nc,ac[i-1]);
	      fi;
	    od;
	    Add(nc,ac[Length(ac)]);
	    if Length(nc)>2 then
	      ac:=[];
	      for i in [Length(nc),Length(nc)-1..2] do
		Info(InfoCoset,4,"Recursive [",Size(nc[i]),",",Size(nc[i-1]));
		Add(ac,RightTransversal(nc[i],nc[i-1]
		      # do not try to factor again
		      :noascendingchain));
	      od;
	      return FactoredTransversal(G,U,ac);
	    fi;
	    noyet:=false;

	  fi;
	  bpt := First( domain, p -> not IsFixedStabilizer( GCC, p ) );
	  ChangeStabChain( GCC, [ bpt ], true  );  GCC := GCC.stabilizer;
	  ChangeStabChain( UCC, [ bpt ], false );  UCC := UCC.stabilizer;
        od;
    fi;

    AddCosetInfoStabChain(GC,UC,LargestMovedPoint(G));
    MinimizeExplicitTransversal(UC,LargestMovedPoint(G));

    enum := Objectify( NewType( FamilyObj( G ),
                           filter and IsList and IsDuplicateFreeList
                           and IsAttributeStoringRep ),
          rec( group := G,
            subgroup := U,
      stabChainGroup := GC,
   stabChainSubgroup := UC ) );

    return enum;
end );


#############################################################################
##
#R  IsRightTransversalPermGroupRep( <obj> ) . right transversal of perm group
##
DeclareRepresentation( "IsRightTransversalPermGroupRep",
    IsRightTransversalRep,
    [ "stabChainGroup", "stabChainSubgroup" ] );

InstallMethod( \[\],
    "for right transversal of perm. group, and pos. integer",
    true,
    [ IsList and IsRightTransversalPermGroupRep, IsPosInt ], 0,
    function( cs, num )
    return CosetNumber( cs!.stabChainGroup, cs!.stabChainSubgroup, num );
end );

InstallMethod( PositionCanonical,
    "for right transversal of perm. group, and permutation",
    IsCollsElms,
    [ IsList and IsRightTransversalPermGroupRep, IsPerm ], 0,
    function( cs, elm )
    return NumberCoset( cs!.stabChainGroup,
                        cs!.stabChainSubgroup,
                        elm );
end );

#############################################################################
##
#M  RightTransversalOp( <G>, <U> )  . . . . . . . . . . . . . for perm groups
##
InstallMethod( RightTransversalOp,
    "for two perm. groups",
    IsIdenticalObj,
    [ IsPermGroup, IsPermGroup ], 0,
    function( G, U )
    return RightTransversalPermGroupConstructor(
               IsRightTransversalPermGroupRep, G, U );
end );


#############################################################################
##
#F  AddCosetInfoStabChain( <G>, <U>, <maxmoved> ) . . . . . .  add coset info
##

InstallGlobalFunction( AddCosetInfoStabChain, function( G, U, maxmoved )
    local   orb,  pimg,  img,  vert,  s,  t,  index,
            block,  B,  blist,  pos,  sliced,  lenflock,  i,  j,
            ss,  tt,t1,t1lim;
    
    Info(InfoCoset,5,"AddCosetInfoStabChain [",
          SizeStabChain(G),",",SizeStabChain(U),"]");
    if IsEmpty( G.genlabels )  then
        U.index    := 1;
        U.explicit := [ U.identity ];
        U.lenflock := 1;
        U.flock    := U.explicit;
    else
        AddCosetInfoStabChain( G.stabilizer, U.stabilizer, maxmoved );
        
        # U.index := [G_1:U_1];
        U.index := U.stabilizer.index * Length( G.orbit ) / Length( U.orbit );
	Info(InfoCoset,5,"U.index=",U.index);
        
        # block := 1 ^ <U,G_1>; is a block for G.
        block := OrbitPerms( Concatenation( U.generators,
                 G.stabilizer.generators ), G.orbit[ 1 ] );
        U.lenblock := Length( block );
        lenflock := Length( G.orbit ) / U.lenblock;

        # For small indices,  permutations   are multiplied,  so  we  need  a
        # multiplied transversal.
        if     IsBound( U.stabilizer.explicit )
           and U.lenblock * maxmoved <= MAX_SIZE_TRANSVERSAL
           and U.index    * maxmoved <= MAX_SIZE_TRANSVERSAL * lenflock  then
            U.explicit := [  ];
            U.flock    := [ G.identity ];
            tt := [  ];  tt[ G.orbit[ 1 ] ] := G.identity;
            for t  in G.orbit  do
                tt[ t ] := tt[ t ^ G.transversal[ t ] ] /
                           G.transversal[ t ];
            od;
        fi;
        
        # flock := { G.transversal[ B[1] ] | B in block system };
        blist := BlistList( G.orbit, block );
        pos := Position( blist, false );
        while pos <> fail  do
            img := G.orbit[ pos ];
            B := block{ [ 1 .. U.lenblock ] };
            sliced := [  ];
            while img <> G.orbit[ 1 ]  do
                Add( sliced, G.transversal[ img ] );
                img := img ^ G.transversal[ img ];
            od;
            for i  in Reversed( [ 1 .. Length( sliced ) ] )  do
                for j  in [ 1 .. Length( B ) ]  do
                    B[ j ] := B[ j ] / sliced[ i ];
                od;
            od;
            Append( block, B );
            if IsBound( U.explicit )  then
                Add( U.flock, tt[ B[ 1 ] ] );
            fi;
            #UniteBlist( blist, BlistList( G.orbit, B ) );
            UniteBlistList(G.orbit, blist, B );
            pos := Position( blist, false, pos );
        od;
        G.orbit := block;
        
        # Let <s> loop over the transversal elements in the stabilizer.
        U.repsStab := List( [ 1 .. U.lenblock ], x ->
                           BlistList( [ 1 .. U.stabilizer.index ], [  ] ) );
        U.repsStab[ 1 ] := BlistList( [ 1 .. U.stabilizer.index ],
                                      [ 1 .. U.stabilizer.index ] );
        index := U.stabilizer.index * lenflock;
        s := 1;
        
        # For  large  indices, store only   the  numbers of  the  transversal
        # elements needed.
        if not IsBound( U.explicit )  then

            # If  the   stabilizer   is the   topmost  level   with  explicit
            # transversal, this must contain minimal coset representatives.
            MinimizeExplicitTransversal( U.stabilizer, maxmoved );
            
	    # if there are over 200 points, do a cheap test first.
	    t1lim:=Length(G.orbit);
	    if t1lim>200 then
	      t1lim:=50;
	    fi;

            orb := G.orbit{ [ 1 .. U.lenblock ] };
            pimg := [  ];
            while index < U.index  do
                pimg{ orb } := CosetNumber( G.stabilizer, U.stabilizer, s,
                                       orb );
                t := 2;
                while t <= U.lenblock  and  index < U.index  do

		    # do not test all points first if not necessary
		    # (test only at most t1lim points, if the test succeeds,
		    # test the rest)
		    # this gives a major speedup.
		    t1:=Minimum(t-1,t1lim);
                    # For this point  in the  block,  find the images  of the
                    # earlier points under the representative.
                    vert := G.orbit{ [ 1 .. t1 ] };
                    img := G.orbit[ t ];
                    while img <> G.orbit[ 1 ]  do
                        vert := OnTuples( vert, G.transversal[ img ] );
                        img  := img           ^ G.transversal[ img ];
                    od;

                    # If $Ust = Us't'$ then $1t'/t/s in 1U$. Also if $1t'/t/s
                    # in 1U$ then $st/t' =  u.g_1$ with $u  in U, g_1 in G_1$
                    # and $g_1  =  u_1.s'$ with $u_1  in U_1,  s' in S_1$, so
                    # $Ust = Us't'$.
                    if ForAll( [ 1 .. t1 ], i -> not IsBound
                       ( U.translabels[ pimg[ vert[ i ] ] ] ) )  then

		      # do all points
		      if t1<t-1 then
			vert := G.orbit{ [ 1 .. t - 1 ] };
			img := G.orbit[ t ];
			while img <> G.orbit[ 1 ]  do
			    vert := OnTuples( vert, G.transversal[ img ] );
			    img  := img           ^ G.transversal[ img ];
			od;
			if ForAll( [ t1+1 .. t - 1 ], i -> not IsBound
			  ( U.translabels[ pimg[ vert[ i ] ] ] ) )  then
			    U.repsStab[ t ][ s ] := true;
			    index := index + lenflock;
			fi;
		      else
                        U.repsStab[ t ][ s ] := true;
                        index := index + lenflock;
		      fi;
                    fi;

                    t := t + 1;
                od;
                s := s + 1;
            od;
            
        # For small indices, store a transversal explicitly.
        else
            for ss  in U.stabilizer.flock  do
                Append( U.explicit, U.stabilizer.explicit * ss );
            od;
            while index < U.index  do
                t := 2;
                while t <= U.lenblock  and  index < U.index  do
                    ss := U.explicit[ s ] * tt[ G.orbit[ t ] ];
                    if ForAll( [ 1 .. t - 1 ], i -> not IsBound
                           ( U.translabels[ G.orbit[ i ] / ss ] ) )  then
                        U.repsStab[ t ][ s ] := true;
                        Add( U.explicit, ss );
                        index := index + lenflock;
                    fi;
                    t := t + 1;
                od;
                s := s + 1;
            od;
            Unbind( U.stabilizer.explicit );
            Unbind( U.stabilizer.flock    );
        fi;
                    
    fi;
end );

#############################################################################
##
#F  NumberCoset( <G>, <U>, <r> )  . . . . . . . . . . . . . . coset to number
##
InstallGlobalFunction( NumberCoset, function( G, U, r )
    local   num,  b,  t,  u,  g1,  pnt,  bpt;
    
    if IsEmpty( G.genlabels )  or  U.index = 1  then
        return 1;
    fi;
    
    # Find the block number of $r$.
    bpt := G.orbit[ 1 ];
    b := QuoInt( Position( G.orbit, bpt ^ r ) - 1, U.lenblock );
        
    # For small indices, look at the explicit transversal.
    if IsBound( U.explicit )  then
        return b * U.lenflock + Position( U.explicit,
               MinimalElementCosetStabChain( U, r / U.flock[ b + 1 ] ) );
    fi;
        
    pnt := G.orbit[ b * U.lenblock + 1 ];
    while pnt <> bpt  do
        r   := r   * G.transversal[ pnt ];
        pnt := pnt ^ G.transversal[ pnt ];
    od;
    
    # Now $r$ stabilises the block. Find the first $t in G/G_1$ such that $Ur
    # = Ust$ for $s in G_1$. In this code, G.orbit[ <t> ] = bpt ^ $t$.
    num := b * U.stabilizer.index * U.lenblock / Length( U.orbit );
             # \_________This is [<U,G_1>:U] = U.lenflock_________/
    t := 1;
    pnt := G.orbit[ t ] / r;
    while not IsBound( U.translabels[ pnt ] )  do
        num := num + SizeBlist( U.repsStab[ t ] );
        t := t + 1;
        pnt := G.orbit[ t ] / r;
    od;
        
    # $r/t = u.g_1$ with $u in U, g_1 in G_1$, hence $t/r.u = g_1^-1$.
    u := U.identity;
    while pnt ^ u <> bpt  do
        u := u * U.transversal[ pnt ^ u ];
    od;
    g1 := LeftQuotient( u, r );  # Now <g1> = $g_1.t = u mod r$.
    while bpt ^ g1 <> bpt  do
        g1 := g1 * G.transversal[ bpt ^ g1 ];
    od;
                
    # The number of $r$  is the number of $g_1$  plus an offset <num> for
    # the earlier values of $t$.
    return num + SizeBlist( U.repsStab[ t ]{ [ 1 ..
                   NumberCoset( G.stabilizer, U.stabilizer, g1 ) ] } );

end );

#############################################################################
##
#F  CosetNumber( <arg> )  . . . . . . . . . . . . . . . . . . number to coset
##
InstallGlobalFunction( CosetNumber, function( arg )
    local   G,  U,  num,  tup,  b,  t,  rep,  pnt,  bpt,  index,  len;

    # Get the arguments.
    G := arg[ 1 ];  U := arg[ 2 ];  num := arg[ 3 ];
    if Length( arg ) > 3  then  tup := arg[ 4 ];
                          else  tup := false;     fi;

    if num = 1  then
        if tup = false  then  return G.identity;
                        else  return tup;         fi;
    fi;
    
    # Find the block $b$ addressed by <num>.
    if IsBound( U.explicit )  then
        index := U.lenflock;
    else
        index := U.stabilizer.index * U.lenblock / Length( U.orbit );
               # \_________This is [<U,G_1>:U] = U.lenflock_________/
    fi;
    b := QuoInt( num - 1, index );
    num := ( num - 1 ) mod index + 1;
        
    # For small indices, look at the explicit transversal.
    if IsBound( U.explicit )  then
        if tup = false  then
            return U.explicit[ num ] * U.flock[ b + 1 ];
        else
            return List( tup, t -> t / U.flock[ b + 1 ] / U.explicit[ num ] );
        fi;
    fi;
        
    # Otherwise, find the point $t$ addressed by <num>.
    t := 1;
    len := SizeBlist( U.repsStab[ t ] );
    while num > len  do
        num := num - len;
        t := t + 1;
        len := SizeBlist( U.repsStab[ t ] );
    od;
    if len < U.stabilizer.index  then
        num := PositionNthTrueBlist( U.repsStab[ t ], num );
    fi;
        
    # Find the representative $s$ in   the stabilizer addressed by <num>  and
    # return $st$.
    rep := G.identity;
    bpt := G.orbit[ 1 ];
    if tup = false  then
        pnt := G.orbit[ b * U.lenblock + 1 ];
        while pnt <> bpt  do
            rep := rep * G.transversal[ pnt ];
            pnt := pnt ^ G.transversal[ pnt ];
        od;
        pnt := G.orbit[ t ];
        while pnt <> bpt  do
            rep := rep * G.transversal[ pnt ];
            pnt := pnt ^ G.transversal[ pnt ];
        od;
        return CosetNumber( G.stabilizer, U.stabilizer, num ) / rep;
    else
        pnt := G.orbit[ b * U.lenblock + 1 ];
        while pnt <> bpt  do
            tup := OnTuples( tup, G.transversal[ pnt ] );
            pnt := pnt ^ G.transversal[ pnt ];
        od;
        pnt := G.orbit[ t ];
        while pnt <> bpt  do
            tup := OnTuples( tup, G.transversal[ pnt ] );
            pnt := pnt ^ G.transversal[ pnt ];
        od;
        return CosetNumber( G.stabilizer, U.stabilizer, num, tup );
    fi;
end );

#############################################################################
##
#M  AscendingChainOp(<G>,<pnt>) . . . approximation of
##
InstallMethod( AscendingChainOp, "PermGroup", IsIdenticalObj,
  [IsPermGroup,IsPermGroup],0,
function(G,U)
local s,c,mp,o,i,step;
  s:=G;
  c:=[G];
  repeat
    mp:=MovedPoints(s);
    o:=ShallowCopy(OrbitsDomain(s,mp));
    Sort(o,function(a,b) return Length(a)<Length(b);end);
    i:=1;
    step:=false;
    while i<=Length(o) and step=false do
      if not IsTransitive(U,o[i]) then
	Info(InfoCoset,2,"AC: orbit");
	o:=ShallowCopy(OrbitsDomain(U,o[i]));
	Sort(o,function(a,b) return Length(a)<Length(b);end);
	s:=Stabilizer(s,Set(o[1]),OnSets);
	step:=true;
      elif Index(G,U)>NrMovedPoints(U) 
	  and IsPrimitive(s,o[i]) and not IsPrimitive(U,o[i]) then
	Info(InfoCoset,2,"AC: blocks");
	s:=Stabilizer(s,Set(List(MaximalBlocks(U,o[i]),Set)),
                      OnSetsDisjointSets);
	step:=true;
      else
	i:=i+1;
      fi;
    od;
    if step then
      Add(c,s);
    fi;
  until step=false or Index(s,U)=1; # we could not refine better
  if Index(s,U)>1 then
    Add(c,U);
  fi;
  Info(InfoCoset,2,"Indices",List([1..Length(c)-1],i->Index(c[i],c[i+1])));
  return RefinedChain(G,Reversed(c));
end);

InstallMethod(CanonicalRightCosetElement,"Perm",IsCollsElms,
  [IsPermGroup,IsPerm],0,
function(U,e)
  return MinimalElementCosetStabChain(MinimalStabChain(U),e);
end);

InstallMethod(\<,"RightCosets of perm group",IsIdenticalObj,
  [IsRightCoset and IsPermCollection,IsRightCoset and IsPermCollection],0,
function(a,b)
  # for permutation groups the canonical rep is the smallest element of the
  # coset
  if ActingDomain(a)<>ActingDomain(b) then
    return ActingDomain(a)<ActingDomain(b);
  fi;
  return CanonicalRepresentativeOfExternalSet(a)
         <CanonicalRepresentativeOfExternalSet(b);
end);


#############################################################################
##
#E  csetperm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
