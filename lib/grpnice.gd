#############################################################################
##
#W  grpnice.gd                  GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  contains generic     methods   for groups handled    by  nice
##  monomorphisms..
##
Revision.grpnice_gd :=
    "@(#)$Id$";


#############################################################################
##

#V  NICE_FLAGS
##
NICE_FLAGS := SUM_FLAGS-1;


#############################################################################
##

#A  NiceMonomorphism( <obj> )
##
NiceMonomorphism := NewAttribute(
    "NiceMonomorphism",
    IsObject );

SetNiceMonomorphism := Setter(NiceMonomorphism);
HasNiceMonomorphism := Tester(NiceMonomorphism);

InstallSubsetMaintainedMethod( NiceMonomorphism,
        IsGroup and HasNiceMonomorphism, IsGroup );

#############################################################################
##
#A  NiceObject( <obj> )
##
NiceObject := NewAttribute(
    "NiceObject",
    IsObject );

SetNiceObject := Setter(NiceObject);
HasNiceObject := Tester(NiceObject);


#############################################################################
##
#P  IsHandledByNiceMonomorphism( <obj> )
##
IsHandledByNiceMonomorphism := NewProperty(
    "IsHandledByNiceMonomorphism",
    IsObject );

SetIsHandledByNiceMonomorphism := Setter(IsHandledByNiceMonomorphism);
HasIsHandledByNiceMonomorphism := Tester(IsHandledByNiceMonomorphism);

InstallSubsetMaintainedMethod(IsHandledByNiceMonomorphism,
  IsHandledByNiceMonomorphism and IsGroup,IsGroup);

#############################################################################
##
#O  GroupByNiceMonomorphism( <nice>, <grp> )
##
GroupByNiceMonomorphism := NewOperation(
    "GroupByNiceMonomorphism",
    [ IsGroupHomomorphism, IsGroup ] );


#############################################################################
##

#F  AttributeMethodByNiceMonomorphism( <oper>, <par> )
##
AttributeMethodByNiceMonomorphism := function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        true,
        par,
        NICE_FLAGS,
        function( obj )
            return oper( NiceObject(obj) );
        end );
end;


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
AttributeMethodByNiceMonomorphismCollColl := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        IsIdentical,
        par,
        NICE_FLAGS,
        function( obj1, obj2 )
            if not IsIdentical( NiceMonomorphism(obj1),
                                NiceMonomorphism(obj2) )
            then
                TryNextMethod();
            fi;
            return oper( NiceObject(obj1), NiceObject(obj2) );
        end );
end;


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
AttributeMethodByNiceMonomorphismCollElm := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        IsCollsElms,
        par,
        NICE_FLAGS,
        function( obj1, obj2 )
            local   img;
            img := ImagesRepresentative( NiceMonomorphism(obj1), obj2 );
            if img = fail  then
                TryNextMethod();
            fi;
            return oper( NiceObject(obj1), img );
        end );
end;

#############################################################################
##
#F  AttributeMethodByNiceMonomorphismElmColl( <oper>, <par> )
##
AttributeMethodByNiceMonomorphismElmColl := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        IsElmsColls,
        par,
        NICE_FLAGS,
        function( obj1, obj2 )
            local   img;
            img := ImagesRepresentative( NiceMonomorphism(obj2), obj1 );
            if img = fail  then
                TryNextMethod();
            fi;
            return oper( img,NiceObject(obj2));
        end );
end;


#############################################################################
##

#F  GroupMethodByNiceMonomorphism( <oper>, <par> )
##
GroupMethodByNiceMonomorphism := function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        true,
        par,
        NICE_FLAGS,
        function( obj )
            local   nice,  img;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj) );
            return GroupByNiceMonomorphism( nice, img );
        end );
end;


#############################################################################
##
#F  SubgroupMethodByNiceMonomorphism( <oper>, <par> )
##
SubgroupMethodByNiceMonomorphism := function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        true,
        par,
        NICE_FLAGS,
        function( obj )
            local   nice,  img,  sub;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj) );
            sub  := GroupByNiceMonomorphism( nice, img );
            SetParent( sub, obj );
            return sub;
        end );
end;


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollOther( <oper>, <par> )
##
GroupMethodByNiceMonomorphismCollOther := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two argument for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        true,
        par,
        NICE_FLAGS,
        function( obj, other )
            local   nice,  img;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj), other );
            return GroupByNiceMonomorphism( nice, img );
        end );
end;


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
GroupMethodByNiceMonomorphismCollColl := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        IsIdentical,
        par,
        NICE_FLAGS,
        function( obj1, obj2 )
            local   nice,  img;
            nice := NiceMonomorphism(obj1);
            if not IsIdentical( nice, NiceMonomorphism(obj2) )  then
                TryNextMethod();
            fi;
            img := oper( NiceObject(obj1), NiceObject(obj2) );
            return GroupByNiceMonomorphism( nice, img );
        end );
end;


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
GroupMethodByNiceMonomorphismCollElm := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        IsCollsElms,
        par,
        NICE_FLAGS,
        function( obj1, obj2 )
            local   nice,  img,  img1;
            nice := NiceMonomorphism(obj1);
            img  := ImagesRepresentative( nice, obj2 );
            if img = fail  then
                TryNextMethod();
            fi;
            img1 := oper( NiceObject(obj1), img );
            return GroupByNiceMonomorphism( nice, img1 );
        end );
end;


#############################################################################
##

#F  PropertyMethodByNiceMonomorphism( <oper>, <par> )
##
PropertyMethodByNiceMonomorphism :=
    AttributeMethodByNiceMonomorphism;


#############################################################################
##
#F  PropertyMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
PropertyMethodByNiceMonomorphismCollColl :=
    AttributeMethodByNiceMonomorphismCollColl;


#############################################################################
##
#F  PropertyMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
PropertyMethodByNiceMonomorphismCollElm :=
    AttributeMethodByNiceMonomorphismCollElm;


#############################################################################
##
#F  PropertyMethodByNiceMonomorphismElmColl( <oper>, <par> )
##
PropertyMethodByNiceMonomorphismElmColl :=
    AttributeMethodByNiceMonomorphismElmColl;


#############################################################################
##

#F  GroupSeriesMethodByNiceMonomorphism( <oper>, <par> )
##
GroupSeriesMethodByNiceMonomorphism := function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        true,
        par,
        NICE_FLAGS,
        function( obj )
            local   nice,  list,  i;
            nice := NiceMonomorphism(obj);
            list := ShallowCopy( oper( NiceObject(obj) ) );
            for i  in [ 1 .. Length(list) ]  do
                list[i] := GroupByNiceMonomorphism( nice, list[i] );
                SetParent( list[i], obj );
            od;
            return list;
        end );
end;


#############################################################################
##
#F  GroupSeriesMethodByNiceMonomorphismCollOther( <oper>, <par> )
##
GroupSeriesMethodByNiceMonomorphismCollOther := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two argument for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        true,
        par,
        NICE_FLAGS,
        function( obj, other )
            local   nice,  list,  i;
            nice := NiceMonomorphism(obj);
            list := ShallowCopy( oper( NiceObject(obj), other ) );
            for i  in [ 1 .. Length(list) ]  do
                list[i] := GroupByNiceMonomorphism( nice, list[i] );
                SetParent( list[i], obj );
            od;
            return list;
        end );
end;


#############################################################################
##
#F  GroupSeriesMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
GroupSeriesMethodByNiceMonomorphismCollColl := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        IsIdentical,
        par,
        NICE_FLAGS,
        function( obj1, obj2 )
            local   nice,  list,  i;
            nice := NiceMonomorphism(obj1);
            if not IsIdentical( nice, NiceMonomorphism(obj2) )  then
                TryNextMethod();
            fi;
            list := ShallowCopy(oper(NiceObject(obj1),NiceObject(obj2)));
            for i  in [ 1 .. Length(list) ]  do
                list[i] := GroupByNiceMonomorphism( nice, list[i] );
                SetParent( list[i], obj1 );
            od;
            return list;
        end );
end;


#############################################################################
##
#F  GroupSeriesMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
GroupSeriesMethodByNiceMonomorphismCollElm := function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NAME_FUNCTION(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism",
        IsCollsElms,
        par,
        NICE_FLAGS,
        function( obj1, obj2 )
            local   nice,  img,  list,  i;
            nice := NiceMonomorphism(obj1);
            img  := ImagesRepresentative( nice, obj2 );
            if img = fail  then
                TryNextMethod();
            fi;
            list := ShallowCopy( oper( NiceObject(obj1), img ) );
            for i  in [ 1 .. Length(list) ]  do
                list[i] := GroupByNiceMonomorphism( nice, list[i] );
                SetParent( list[i], obj1 );
            od;
            return list;
        end );
end;


#############################################################################
##

#E  grpnice.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
