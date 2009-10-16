#############################################################################
####
##
#W  anupqid.gi              ANUPQ package                       Werner Nickel
#W                                                                Greg Gamble
##
##  This file installs functions to do with evaluating identities.
##
#H  @(#)$Id: anupqid.gi,v 1.1 2002/02/15 08:53:47 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqid_gi :=
    "@(#)$Id: anupqid.gi,v 1.1 2002/02/15 08:53:47 gap Exp $";


#############################################################################
##
#F  PqEvalSingleRelation( <proc>, <r>, <instances> )
##
InstallGlobalFunction( PqEvalSingleRelation, function( proc, r, instances )
    local   w, datarec;

#    Print( instances, "\n" );

    datarec := ANUPQDataRecord(proc);
    datarec.nwords := datarec.nwords + 1;
    w := CallFuncList( r, instances );
    if w <> w^0 then 
#        Print( w );
#        Print( "\n" );
#        PqSetOutputLevel( proc, 3 );
        PqCollect( proc, String(w) ); 
        PqEchelonise( proc );
#        PqSetOutputLevel( proc, 0 );
    fi;
end );

#############################################################################
##
#F  PqEnumerateWords( <proc>, <data>, <r> )
##
##    The parameters of PqEnumerateWords() have the following meaning:
##
##    <r>          a relation involving identical generators.
##    <instances>  the list of instances to be built up corresponding the
##                 identical generators. 
##    <n>          the index of the current word in <instances>
##    <g>          the next generator in the current word
##    <wt>         the weight that can be spent on the next generators.
##
InstallGlobalFunction( PqEnumerateWords, function( proc, data, r )
    local   n,  g,  wt,  u,  save_wt,  save_u,  save_g;

    n  := data.currentinst;
    g  := data.currentgen;
    wt := data.weightleft;
    u  := data.instances[ n ];

    save_wt := wt;
    save_u  := u;
    save_g  := g;

    if wt = 0 then
        PqEvalSingleRelation( proc, r, data.instances );
        Info( InfoANUPQ, 3, "Instance: ", data.instances[ n ] ); 
        return;
    fi;
    
    if g > Length( data.pcgens ) then return; fi;

    while g <= data.nrpcgens and data.pcweights[g] <= wt do
        while data.pcweights[g] <= wt do
            u := u * data.pcgens[g];
            wt := wt - data.pcweights[g];

            data.instances[ n ] := u;
            data.weightleft     := wt;
            data.currentgen     := g+1; 
            PqEnumerateWords( proc, data, r );

            if n < Length(data.instances) then
                data.currentinst := n+1;
                data.currentgen  := 1;
                PqEnumerateWords( proc, data, r );
                data.currentinst := n;
            fi;
        od;
        u  := save_u; wt := save_wt; g := g+1;
    od;
    data.instances[ n ] := save_u;
    data.weightleft     := save_wt;
    data.currentgen     := save_g;
end );

#############################################################################
##
#F  PqEvaluateIdentity( <proc>, <r>, <arity> )
##
InstallGlobalFunction( PqEvaluateIdentity, function( proc, r, arity )
    local   n,  class,  gens,  data,  c;

    n     := PqNrPcGenerators( proc );
    class := PqWeight( proc, n );
    if class > 1 then
        while n > 0 and PqWeight( proc, n ) = class do n := n-1; od;
    fi;

    if n = 0 then return; fi;

    gens := GeneratorsOfGroup( FreeGroup( n, "x" ) );
    data := rec( instances   := List( [1..arity], i->gens[1]^0 ),
                 currentinst := 1,
                 currentgen  := 1,
                 weightleft  := 0,
                 pcgens      := gens,
                 nrpcgens    := n,
                 pcweights   := List( [1..n], i->PqWeight( proc, i ) )
                 );
    
    for c in [1..class] do
#        Print( "words of class ", c, "\n" );
        data.weightleft := c;
        PqEnumerateWords( proc, data, r );
    od;

end );

#############################################################################
##
#F  PqWithIdentity( <G>, <p>, <Cl>, <identity> )
##
##  constructs a <p>-quotient <Q> of the fp or pc group <G> of class at  most
##  <Cl> that satisfies $<identity>(<w1>, \dots, <wn>) =  1$  for  all  words
##  $<w1>, \dots, <wn>$ in the pc generators of <Q>. The  following  examples
##  demonstrate its usage.
##
##  \beginexample
###  gap> F := FreeGroup(2);                    
##  <free group on the generators [ f1, f2 ]>
##  gap> f := w -> w^4;
##  function( w ) ... end
##  gap> PqWithIdentity( F, 2, 20, f );
##  #I  Evaluated 5 instances.
##  #I  Class 2 with 5 generators.
##  #I  Evaluated 18 instances.
##  #I  Class 3 with 7 generators.
##  #I  Evaluated 44 instances.
##  #I  Class 4 with 10 generators.
##  #I  Evaluated 95 instances.
##  #I  Class 5 with 12 generators.
##  #I  Evaluated 192 instances.
##  #I  Class 6 with 12 generators.
##  <pc group of size 4096 with 12 generators>
##  gap> 
##  gap> G := F/[ F.1^11, F.2^11 ];
##  <fp group on the generators [ f1, f2 ]>
##  gap> f := function(u, v) return PqLeftNormComm( [u, v, v, v] ); end;
##  function( u, v ) ... end
##  gap> H := PqWithIdentity( G, 11, 20, f );
##  #I  Evaluated 14 instances.
##  #I  Class 2 with 3 generators.
##  #I  Evaluated 44 instances.
##  #I  Class 3 with 5 generators.
##  #I  Evaluated 122 instances.
##  #I  Class 4 with 5 generators.
##  <pc group of size 161051 with 5 generators>
##  gap> f( Random(H), Random(H) );
##  <identity> of ...
##  gap> f( H.1, H.2 );
##  <identity> of ...
##  \endexample
##
##  Compare    the    above    examples    with    those    generated     by:
##  `PqExample("B2-4-Id");' and `PqExample("11gp-3-Engel-Id");' which do  the
##  same as above using the function `Pq' with the `Identities' option.
##
##  `PqWithIdentity' and the functions it calls,  with  minor  modifications,
##  constitute the prototype provided by Werner Nickel,  for  constructing  a
##  quotient that satisfies an identity. The prototype  functions  have  been
##  merged into the single function `PQ_EVALUATE_IDENTITY' which is called by
##  `PQ_EVALUATE_IDENTITIES'    which    in     turn     is     called     by
##  `PQ_FINISH_NEXT_CLASS'   which   is   called   by   `PQ_NEXT_CLASS'   and
##  `PQ_EPI_OR_PCOVER',  if   the   `Identities'   option   has   been   set.
##  `PQ_EPI_OR_PCOVER' is the function called  by  `Pq',  `PqEpimorphism'  or
##  `PqPCover'.
##
InstallGlobalFunction( PqWithIdentity, function( G, p, Cl, identity )
    local   proc,  datarec,  prev_n,  class,  grp, arity;

    arity := NumberArgumentsFunction( identity );

    proc := PqStart( G : Prime := p );
    datarec := ANUPQData.io[ proc ];
    datarec.nwords := 0;

    prev_n := 0;
    Pq( proc : ClassBound := 1 );    class := 1;
    
    PqEvaluateIdentity( proc, identity, arity );
    PqEliminateRedundantGenerators( proc );

    if PqNrPcGenerators( proc ) = 0 then
        return TrivialGroup( IsPcGroup );
    fi;

    while class < Cl and prev_n <> PqNrPcGenerators( proc ) do
        prev_n := PqNrPcGenerators( proc );

        PqSetupTablesForNextClass( proc );
        PqTails( proc, 0 );
        PqDoConsistencyChecks( proc, 0, 0 );
        PqCollectDefiningRelations( proc );

        PqDoExponentChecks( proc );
        
        datarec.nwords := 0;
        PqEvaluateIdentity( proc, identity, arity );
        Info(InfoANUPQ, 2, "Evaluated ", datarec.nwords, " instances." );

        PqEliminateRedundantGenerators( proc );

        class := class + 1;
        
        Info(InfoANUPQ, 1, "Class ", class, " with ",
                           PqNrPcGenerators(proc), " generators." );
    od;

    grp := PqCurrentGroup( proc );

    PqQuit( proc );

    return grp;
end );
    
#############################################################################
##
#F  PQ_EVALUATE_IDENTITY( <proc>, <identity> )
##
InstallGlobalFunction( PQ_EVALUATE_IDENTITY, function( proc, identity )
    local   EnumerateWords, data, datarec, nwords, arity, c;

    EnumerateWords := function()
      local   i,  g,  wt,  u,  w,  save_wt,  save_u,  save_g;

      i  := data.currentinst;
      g  := data.currentgen;
      wt := data.weightleft;
      u  := data.instances[ i ];

      save_wt := wt;
      save_u  := u;
      save_g  := g;

      if wt = 0 then
        #evaluate a single relation
        nwords := nwords + 1;
        w := CallFuncList( identity, data.instances );
        if w <> w^0 then 
#         Print( w );
#         Print( "\n" );
#         PqSetOutputLevel( proc, 3 );
          PqCollect( proc, String(w) ); 
          PqEchelonise( proc );
#         PqSetOutputLevel( proc, 0 );
        fi;
        Info( InfoANUPQ, 3, "Instance: ", data.instances[ i ] ); 
        return;
      fi;
    
      while g <= data.nrpcgens and data.pcweights[g] <= wt do
        while data.pcweights[g] <= wt do
            u  := u * data.pcgens[g];
            wt := wt - data.pcweights[g];

            data.instances[ i ] := u;
            data.weightleft     := wt;
            data.currentgen     := g+1; 
            EnumerateWords();

            if i < Length(data.instances) then
                data.currentinst := i+1;
                data.currentgen  := 1;
                EnumerateWords();
                data.currentinst := i;
            fi;
        od;
        u  := save_u; wt := save_wt; g := g+1;
      od;
      data.instances[ i ] := save_u;
      data.weightleft     := save_wt;
      data.currentgen     := save_g;
    end;
  
    data := rec( nrpcgens := PqNrPcGenerators( proc ) );
    if data.nrpcgens = 0 then 
      return; 
    fi;

    datarec  := ANUPQDataRecord( proc );
    if datarec.class > 1 then
      data.nrpcgens := datarec.ngens[ Length(datarec.ngens) - 1 ];
    fi;

    nwords := 0;
    arity  := NumberArgumentsFunction(identity);

    data.pcgens      := GeneratorsOfGroup( FreeGroup( data.nrpcgens, "x" ) );
    data.instances   := List( [1 .. arity], i -> data.pcgens[1]^0 );
    data.currentinst := 1;
    data.currentgen  := 1;
    data.pcweights   := List( [1 .. data.nrpcgens], i -> PqWeight( proc, i ) );
    
    for c in [1 .. datarec.class] do
#        Print( "words of class ", c, "\n" );
      data.weightleft := c;
      EnumerateWords();
    od;
    Info(InfoANUPQ, 2, "Evaluated ", nwords, " instances." );
end );

#E  anupqid.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
