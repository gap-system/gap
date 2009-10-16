#############################################################################
##
#W  dllib.g               GAP 4 package `ctbllib'      Michael Cla\3en-Houben
##
#H  @(#)$Id: dllib.g,v 1.1 2005/05/17 08:51:03 gap Exp $
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "ctbllib/dlnames/dllib_g" ) :=
    "@(#)$Id: dllib.g,v 1.1 2005/05/17 08:51:03 gap Exp $";


#############################################################################
##
#V  DeltigLibUnipotentCharacters
##
BindGlobal( "DeltigLibUnipotentCharacters", [] );

#ReadPackage( "ctbllib", "dlnames/ltgroups.g" );
ReadPackage( "ctbllib", "dlnames/uctypeA.g" );
ReadPackage( "ctbllib", "dlnames/uctype2A.g" );
ReadPackage( "ctbllib", "dlnames/uctypeB.g" );
ReadPackage( "ctbllib", "dlnames/uctypeC.g" );
ReadPackage( "ctbllib", "dlnames/uctypeD.g" );
ReadPackage( "ctbllib", "dlnames/uctype2D.g" );
ReadPackage( "ctbllib", "dlnames/uctypeX.g" );


#############################################################################
##
#F  DeltigLibGetRecord( <record> )
#F  DeltigLibGetRecord( <string> )
##
BindGlobal( "DeltigLibGetRecord", function( r )
    if IsString( r ) then
      return First( DeltigLibUnipotentCharacters, x -> x.identifier = r );
    else
      return First( DeltigLibUnipotentCharacters,
          elem ->     elem.isoc = r.isoc
                  and elem.l = r.l
                  and ( ( IsBound( r.q ) and elem.q = r.q )
                        or ( IsBound( r.q2 ) and elem.q2 = r.q2 ) )
                  and ( ( not IsBound( r.isot ) ) or r.isot in elem.isot ) );
    fi;
    end );


#############################################################################
##
#E

