#############################################################################
##
#W  smlinfo.gi               GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the ...
##

#############################################################################
##
#F  SMALL_GROUPS_INFORMATION
##
##  ...
SMALL_GROUPS_INFORMATION := [ ];

#############################################################################
##
#F  SmallGroupsInformation( size )
##
##  ...
InstallGlobalFunction( SmallGroupsInformation, function( size )
    local smav, idav, num, lib, t;

    smav := SMALL_AVAILABLE( size );
    idav := ID_AVAILABLE( size );

    if size = 1024 then
        Print( "The groups of size 1024 are not available. \n");
        return;
    fi;

    if smav = fail then
        Print( "The groups of size ", size, " are not available. \n");
        return;
    fi; 

    lib := 1;
    if IsBound( smav.lib ) then
        lib := smav.lib;
    fi;
    
    if IsBound( smav.number ) then
        num := smav.number;
    else
        num := NUMBER_SMALL_GROUPS_FUNCS[ smav.func ]( size, smav ).number;
    fi;
    if num = 1 then 
        Print("\n  There is 1 group of order ",size,".\n");
    else
        Print("\n  There are ",num," groups of order ",size,".\n" );
    fi;
 
    SMALL_GROUPS_INFORMATION[ smav.func ]( size, smav, num );

    Print("\n  This size belongs to layer ",lib,
          " of the SmallGroups library. \n");

    if idav <> fail then 
        Print("  IdSmallGroup is available for this size. \n \n");
    else        
        Print("  IdSmallGroup is not available for this size. \n \n");
    fi;
end );

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 1 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 1 ] := function( size, smav, num )
    Print("\n");
    Print("  The groups whose order factorises in at most 3 primes \n");
    Print("  have been classified by O. Hoelder. This classification is \n");
    Print("  used in the SmallGroups library. \n");
end;

SMALL_GROUPS_INFORMATION[ 2 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 3 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 4 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 5 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 6 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 7 ] := SMALL_GROUPS_INFORMATION[ 1 ];

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 8 .. 10 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 8 ] := function( size, smav, num )
    local ffid, prop, i, l;

    ffid := IdGroup( OneSmallGroup( size, FrattinifactorSize, size ) );
    
    atomic PROPERTIES_SMALL_GROUPS[ size ] do
    
    prop := PROPERTIES_SMALL_GROUPS[ size ].frattFacs;

    if not IsPrimePowerInt( size ) then
        Print("  They are sorted by their Frattini factors. \n");
        i := 1;
        if ffid[ 2 ] > 1 then
            repeat 
                if prop.pos[ i ][ 1 ] = -prop.pos[ i ][ 2 ] then
                    Print( "     ", prop.pos[ i ][ 1 ],
                       " has Frattini factor ", prop.frattFacs[ i ], ".\n"  );
                else
                    Print( "     ", prop.pos[ i ][ 1 ], " - ",
                       -prop.pos[ i ][ 2 ], " have Frattini factor ",
                       prop.frattFacs[ i ], ".\n"  );
                fi;
                i := i + 1;
            until prop.frattFacs[ i ] = ffid;
        fi;
        Print("     ", ffid[2], " - ", num, 
              " have trivial Frattini subgroup.\n");
    else
        Print("  They are sorted by their ranks. \n");
        Print("     ", 1, " is cyclic. \n");
        i := 2;
        repeat 
            l := Length( Factors( prop.frattFacs[ i ][1] ) );
            if prop.pos[ i ][ 1 ] = -prop.pos[ i ][ 2 ] then
                Print( "     ", prop.pos[ i ][ 1 ], " has rank ", l, ".\n"  );
            else
                Print( "     ", prop.pos[ i ][ 1 ], " - ",
                       -prop.pos[ i ][ 2 ], " have rank ", l, ".\n"  );
            fi;
            i := i + 1;
        until prop.frattFacs[ i ] = ffid;
        Print("     ", ffid[2], " is elementary abelian. \n");
    fi;

    Print( "\n  For the selection functions the values of the ",
           "following attributes \n  are precomputed and stored:\n ");
    if IsPrimePowerInt( size ) then
        Print( "    IsAbelian, PClassPGroup, RankPGroup,",
               " FrattinifactorSize and \n     FrattinifactorId. \n");
    else
        Print( "    IsAbelian, IsNilpotentGroup,", 
               " IsSupersolvableGroup, IsSolvableGroup, \n     LGLength,",
               " FrattinifactorSize and FrattinifactorId. \n");
    fi;
    
    od; # atomic PROPERTIES_SMALL_GROUPS[ size ] do
    
end;
SMALL_GROUPS_INFORMATION[ 9 ] := SMALL_GROUPS_INFORMATION[ 8 ];
SMALL_GROUPS_INFORMATION[ 10 ] := SMALL_GROUPS_INFORMATION[ 8 ];

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 11, 17 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 11 ] := function( size, smav, num )
    local i, q;

    q := 2;
    if IsBound( smav.q ) then q := smav.q; fi;

    Print("  They are sorted by normal Sylow subgroups. \n");
    Print( "     1 - ", smav.pos[ 2 ], " are the nilpotent groups.\n" );
    for i in [ 2 .. Length( smav.types ) ] do
        Print( "     ", smav.pos[i] + 1, " - ", smav.pos[i+1] );
        if smav.types[ i ] = "p-autos" then 
            Print( " have a normal Sylow ", q,"-subgroup. \n");
        elif smav.types[ i ] = "none-p-nil" then 
            Print( " have no normal Sylow subgroup. \n");
        elif IsInt( smav.types[ i ] ) then
            Print( " have a normal Sylow ", smav.p, "-subgroup \n");
            Print( "                     with centralizer of index ");
            Print( q^smav.types[i],".\n");
        fi;
    od;
end;
SMALL_GROUPS_INFORMATION[ 17 ] := SMALL_GROUPS_INFORMATION[ 11 ];

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 12 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 12 ] := function( size, smav, num )

    if size = 1152 then
        Print("  They are sorted using Sylow subgroups. \n");
        Print("     1 - 2328 are nilpotent with Sylow 3-subgroup c9.\n" );
        Print("     2329 - 4656 are nilpotent with Sylow 3-subgroup 3^2.\n");
        Print("     4657 - 153312 are non-nilpotent with normal ");
        Print("Sylow 3-subgroup.\n");
        Print("     153313 - 157877 have no normal Sylow 3-subgroup.\n");
        return;
    fi;

    Print("  They are sorted using Hall subgroups. \n");
    Print( "     1 - 2328 are the nilpotent groups.\n" );
    Print( "     2329 - 236344 have a normal Hall (3,5)-subgroup.\n");
    Print( "     236345 - 240416 are solvable without normal Hall",
           " (3,5)-subgroup.\n");
    Print( "     240417 - 241004 are not solvable.\n" );
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 14 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 14 ] := function( size, smav, num )

    Print( "     1 - 10494213 are the nilpotent groups.\n" );
    Print( "     10494214 - 408526597 have a normal Sylow 3-subgroup.\n" );
    Print( "     408526598 - 408544625 have a normal Sylow 2-subgroup.\n" );
    Print( "     408544626 - 408641062 have no normal Sylow subgroup.\n" );
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 18 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 18 ] := function( size, smav, num )

    Print( "     1 is cyclic. \n");
    Print( "     2 - 10 have rank 2 and p-class 3.\n" );
    Print( "     11 - 386 have rank 2 and p-class 4.\n" );
    Print( "     387 - 1698 have rank 2 and p-class 5.\n" );
    Print( "     1699 - 2008 have rank 2 and p-class 6.\n" );
    Print( "     2009 - 2039 have rank 2 and p-class 7.\n" );
    Print( "     2040 - 2044 have rank 2 and p-class 8.\n" );
    Print( "     2045 has rank 3 and p-class 2.\n" );
    Print( "     2046 - 29398 have rank 3 and p-class 3.\n" );
    Print( "     29399 - 30617 have rank 3 and p-class 4.\n" );
    Print( "     30618 - 31239 have rank 3 and p-class 3.\n" );
    Print( "     31240 - 56685 have rank 3 and p-class 4.\n" );
    Print( "     56686 - 60615 have rank 3 and p-class 5.\n" );
    Print( "     60616 - 60894 have rank 3 and p-class 6.\n" );
    Print( "     60895 - 60903 have rank 3 and p-class 7.\n" );
    Print( "     60904 - 67612 have rank 4 and ", "p-class 2.\n" );
    Print( "     67613 - 387088 have rank 4 and ", "p-class 3.\n" );
    Print( "     387089 - 419734 have rank 4 and ", "p-class 4.\n" );
    Print( "     419735 - 420500 have rank 4 and ", "p-class 5.\n" );
    Print( "     420501 - 420514 have rank 4 and ", "p-class 6.\n" );
    Print( "     420515 - 6249623 have rank 5 and ", "p-class 2.\n" );
    Print( "     6249624 - 7529606 have rank 5 and ", "p-class 3.\n" );
    Print( "     7529607 - 7532374 have rank 5 and ", "p-class 4.\n" );
    Print( "     7532375 - 7532392 have rank 5 and ", "p-class 5.\n" );
    Print( "     7532393 - 10481221 have rank 6 and ", "p-class 2.\n" );
    Print( "     10481222 - 10493038 have rank 6 and ", "p-class 3.\n" );
    Print( "     10493039 - 10493061 have rank 6 and ", "p-class 4.\n" );
    Print( "     10493062 - 10494173 have rank 7 ", "and p-class 2.\n" );
    Print( "     10494174 - 10494200 have rank 7 ", "and p-class 3.\n" );
    Print( "     10494201 - 10494212 have rank 8 ", "and p-class 2.\n" );
    Print( "     10494213 is elementary abelian.\n");
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 19 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 19 ] := function( size, smav, num )

  Print("  They are sorted by their ranks. \n");
  Print( "     1 is cyclic. \n");
  Print( "     2 - 10 have rank 2. \n");
  Print( "     11 - 14 have rank 3. \n");
  Print( "     15 is elementary abelian. \n");
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 20 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 20 ] := function( size, smav, num )
    local p, a, b, c;

    p := Factors(size)[1];
    a:=27 + p   + 2*GcdInt(p-1,3) + GcdInt(p-1,4);
    b:=54 + 2*p + 2*GcdInt(p-1,3) + GcdInt(p-1,4);
    c:=60 + 2*p + 2*GcdInt(p-1,3) + GcdInt(p-1,4);

    Print( "  They are sorted by their ranks.\n" );
    Print( "     1 is cyclic.\n");
    Print( "     2 - ",a," have rank 2. \n");
    Print( "     ",a+1," - ",b," have rank 3. \n");
    Print( "     ",b+1," - ",c," have rank 4. \n");
    Print( "     ",c+1," is elementary abelian. \n");
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 21 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 21 ] := function( size, smav, num )

   Print( " \n");
   Print( "      Easterfield (1940) constructed a list of the groups of\n");
   Print( "      order p^6 for p >= 5.\n \n");

   Print( "      The database of parametrised presentations for the groups \n");
   Print( "      with order p^6 for p >= 5 is based on the Easterfield \n");
   Print( "      list, corrected by Newman, O'Brien and Vaughan-Lee (2004).\n");
   Print( "      It differs only in the addition of groups in isoclinism \n"); 
   Print( "      family $\\Phi_{13}$, in using the James (1980) presentations \n");
   Print( "      for the groups in $\\Phi_{19}$, and a small number of \n");
   Print( "      typographical amendments. The linear ordering employed is \n");
   Print( "      very close to that of Easterfield. \n \n");

   Print( "      Each group with order $p^6$ is described by a power- \n");
   Print( "      commutator presentation on 6 generators and 21 relations:\n");
   Print( "      15 are commutator relations and 6 are power relations. \n");
   Print( "      Each presentation has the prime $p$ as a parameter. \n");
   Print( "      The database contains about 500 parametrised \n");
   Print( "      presentations, most of these have $p$ as the only \n");
   Print( "      parameter. \n");

end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 24 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 24 ] := function( size, smav, num )
    local i, set, c;

    Print( "\n" );
    Print( "  The groups of squarefree order have a cylic socle and a " );
    Print( "cylic socle factor.\n" );

    Print( "\n" );
    i := 0;
    for set in smav.sets do
        c := Product( smav.primes{ set.kp } );
        if c = 1 then
            Print( "    1 is abelian\n" );
        elif set.number = 1 then
            Print( "    ", i + 1, " has socle C_" );
            Print( size / c, " and factor C_", c, "\n" );
        else
            Print( "    ", i + 1, " - ", i + set.number, " have socle C_" );
            Print( size / c, " and factor C_", c, "\n" );
        fi;
        i := i + set.number;
    od;
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 25 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 25 ] := function( size, smav, num )
    local i, set, c;
    Print( "\n" );
    Print( "  The groups of cubefree order are either solvable or a direct ",
           "product of \n  the form PSL( 2, p ) x solvable group. ",
           "The cubefree solvable groups are \n  determined by their Frattini",
           " factor.\n\n" );

    i := 0;
    for set in smav.sets do
      if set.psl_p = 1 then
        if set.size_phi = 1 then
          if set.number = 1 then
            Print( "    ", i + 1, " is solvable and Frattini free\n" );
          else
            Print( "    ", i + 1, " - ", i + set.number, " are solvable ",
                   "and Frattini free\n" );
          fi;
        else
          if set.number = 1 then
            Print( "    ", i + 1, " is solvable with Frattini factor of ",
                   "size ", set.size_ff, "\n" );
          else
            Print( "    ", i + 1, " - ", i + set.number, " are solvable ",
                   "with Frattini factor of size ", set.size_ff, "\n" );
          fi;
        fi;
      elif
        set.size_ff = 1 then
          Print( "    ", i + 1, " is PSL( 2, ", set.psl_p, " )\n" );
      else
        if set.size_phi = 1 then
          if set.number = 1 then
            Print( "    ", i + 1, " is PSL( 2, ", set.psl_p, " ) x F, F ",
                   "solvable and Frattini free of order ", set.size_ff, "\n");
          else
            Print( "    ", i + 1, " - ", i + set.number, " are PSL( 2, ",
                   set.psl_p, " ) x F_i, F_i solvable ",
                   "Frattini free of order ", set.size_ff, "\n" );
          fi;
        else
          if set.number = 1 then
            Print( "    ", i + 1, " is PSL( 2, ", set.psl_p, " ) x G, G ",
                   "solvable of order ", set.size_ff * set.size_phi,
                   " with a Frattini factor\n      of order ", set.size_ff,
                   "\n");
          else
            Print( "    ", i + 1, " - ", i + set.number, " are PSL( 2, ",
                   set.psl_p, " ) x G_i, G_i ", "solvable of order ",
                   set.size_ff * set.size_phi, " with a",
                   "\n      Frattini factor of order ", set.size_ff, "\n");
          fi;
        fi;
      fi;
      i := i + set.number;
    od;
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 26 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 26 ] := function( size, smav, num )

   Print( " \n");
   Print( "      E.A. O'Brien and M.R. Vaughan-Lee determined presentations\n");
   Print( "      of the groups with order p^7. A preprint of their paper is\n");
   Print( "      available at\n" );
   Print( "      http://www.math.auckland.ac.nz/%7Eobrien/research/p7/paper-p7.pdf\n\n" ); 
   Print( "      For p in { 3, 5, 7, 11 } explicit lists of groups of order\n");
   Print( "      p^7 have been produced and stored into the database.\n\n");
   Print( "      Giving the power commutator presentations of any of these\n");
   Print( "      groups using a standard notation they might be reduced to 35\n");
   Print( "      elements of the group or a 245 p-digit number.\n\n");
   Print( "      Only 56 of these digits may be unlike 0 for any group and\n");
   Print( "      even these 56 digits are mostly like 0. Further on these\n");
   Print( "      digits are often quite likely for sequences of subsequent\n");
   Print( "      groups. Thus storage of groups was done by finding a so\n");
   Print( "      called head group and a so called tail. Along the tail\n");
   Print( "      only the different digits compared to the head are relevant.\n");
   Print( "      Even the tails occur more or less often and this is used\n");
   Print( "      to improve storage too. Since p^7 is too big the data is\n");
   Print( "      stored into some remaing holes of SMALL_GROUP_LIB at\n");
   Print( "      Primes[ p + 10 ].\n");

end;

MakeImmutable( SMALL_GROUPS_INFORMATION );
