#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file  contains generic     methods   for groups handled    by  nice
##  monomorphisms..
##


#############################################################################
##
#A  NiceMonomorphism( <obj> )
##
##  <#GAPDoc Label="NiceMonomorphism">
##  <ManSection>
##  <Attr Name="NiceMonomorphism" Arg='obj'/>
##
##  <Description>
##  is a homomorphism that is defined (at least) on the whole of <A>obj</A>
##  and whose restriction to <A>obj</A> is injective.
##  The concrete morphism (and also the image group) will depend on the
##  representation of <A>obj</A>.
##  <P/>
##  WARNING: The domain of the homomorphism may be larger than <A>obj</A>.
##  To obtain the image of <A>obj</A> under the homomorphism, use
##  <Ref Attr="NiceObject"/>; see there for an example where it matters.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "NiceMonomorphism",
    IsObject );

InstallSubsetMaintenance( NiceMonomorphism,
        IsGroup and HasNiceMonomorphism, IsGroup );


#############################################################################
##
#F  IsNiceMonomorphism( <nhom> )
##
##  <ManSection>
##  <Func Name="IsNiceMonomorphism" Arg='nhom'/>
##
##  <Description>
##  This filter indicates that a mapping has been installed as the
##  <Ref Func="NiceMonomorphism"/> value of an object.
##  (Such mappings may need to be handled specially
##  because they should not refer to the <Ref Attr="NiceMonomorphism"/> value
##  of the source again.)
##  </Description>
##  </ManSection>
##
DeclareFilter("IsNiceMonomorphism");

#############################################################################
##
#O  RestrictedNiceMonomorphism(<hom>,<G>)
##
##  <ManSection>
##  <Oper Name="RestrictedNiceMonomorphism" Arg='hom, G'/>
##
##  <Description>
##  returns the restriction of the nice monomorphism <A>hom</A> onto
##  <A>G</A>.
##  In contrast to <Ref Func="RestrictedMapping"/>,
##  this operation returns an object which has the filter
##  <Ref Func="IsNiceMonomorphism"/> set.
##  (This is important for some operations like
##  <Ref Func="CompositionMapping"/>:
##  We do not want to compute the <Ref Func="AsGroupGeneralMappingByImages"/>
##  value of a nice monomorphism
##  &ndash;this would counteract the intention of a nice monomorphism.
##  Therefore some methods explicitly test whether a mapping is a nice
##  monomorphism.
##  <P/>
##  However for example in
##  <Ref Func="NaturalHomomorphismByNormalSubgroupOp"/>,
##  a restriction of the nice monomorphism has to be taken
##  because the nice monomorphism might be defined on too large a source,
##  in this case <Ref Func="RestrictedNiceMonomorphism"/> must be used!)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RestrictedNiceMonomorphism");

#############################################################################
##
#P  IsCanonicalNiceMonomorphism( <nhom> )
##
##  <#GAPDoc Label="IsCanonicalNiceMonomorphism">
##  <ManSection>
##  <Prop Name="IsCanonicalNiceMonomorphism" Arg='nhom'/>
##
##  <Description>
##  A nice monomorphism (see <Ref Attr="NiceMonomorphism"/> <A>nhom</A> is
##  canonical if the image set will only depend on the set of group elements
##  but not on the generating set and <Ref Oper="\&lt;"/> comparison
##  of group elements translates through the nice monomorphism.
##  This implies that equal objects will always have equal
##  <Ref Attr="NiceObject"/> values.
##  In some situations however this condition would be expensive to
##  achieve, therefore it is not guaranteed for every nice monomorphism.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsCanonicalNiceMonomorphism",IsGroupGeneralMapping);

#############################################################################
##
#A  CanonicalNiceMonomorphism( <obj> )
##
##  <ManSection>
##  <Attr Name="CanonicalNiceMonomorphism" Arg='obj'/>
##
##  <Description>
##  returns a <C>NiceMonomorphism</C> which is canonical (see
##  <C>IsCanonicalNiceMonomorphism</C>).
##  </Description>
##  </ManSection>
##
DeclareAttribute( "CanonicalNiceMonomorphism", IsObject );

#############################################################################
##
#A  NiceObject( <obj> )
##
##  <#GAPDoc Label="NiceObject">
##  <ManSection>
##  <Attr Name="NiceObject" Arg='obj'/>
##
##  <Description>
##  The <Ref Attr="NiceObject"/> value of <A>obj</A> is the image of
##  <A>obj</A> under the mapping stored as the value of
##  <Ref Attr="NiceMonomorphism"/> for <A>obj</A>.
##  <P/>
##  A typical example are finite matrix groups, which use a faithful action
##  on vectors to translate all calculations in a permutation group.
##  <P/>
##  <Example><![CDATA[
##  gap> gl:=GL(3,2);
##  SL(3,2)
##  gap> IsHandledByNiceMonomorphism(gl);
##  true
##  gap> NiceObject(gl);
##  Group([ (5,7)(6,8), (2,3,5)(4,7,6) ])
##  gap> Image(NiceMonomorphism(gl),Z(2)*[[1,0,0],[0,1,1],[1,0,1]]);
##  (2,6)(3,4,7,8)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "NiceObject",
    IsObject );


#############################################################################
##
#P  IsHandledByNiceMonomorphism( <obj> )
##
##  <#GAPDoc Label="IsHandledByNiceMonomorphism">
##  <ManSection>
##  <Prop Name="IsHandledByNiceMonomorphism" Arg='obj'/>
##
##  <Description>
##  If this property is <K>true</K>, high-valued methods that translate all
##  calculations in <A>obj</A> in the image under the
##  <Ref Attr="NiceMonomorphism"/> value of <A>obj</A>
##  become available for <A>obj</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty(
    "IsHandledByNiceMonomorphism",
    IsObject,NICE_FLAGS );

InstallSubsetMaintenance( IsHandledByNiceMonomorphism,
    IsHandledByNiceMonomorphism and IsGroup,
    IsGroup);

RUN_IN_GGMBI:=false; # If somebody would call `GHBI' to make a
                     # NiceMonomorphism, we would get an infinite recursion.
                     # This flag can be set to avoid GHBIs to be translated
                     # via the niceo. If it is set, the method which does
                     # this is passed over. It will be set by methods that
                     # create some niceos (or similar homomorphisms).

#############################################################################
##
#O  GroupByNiceMonomorphism( <nice>, <grp> )
##
##  <ManSection>
##  <Oper Name="GroupByNiceMonomorphism" Arg='nice, grp'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "GroupByNiceMonomorphism",
    [ IsGroupHomomorphism, IsGroup ] );


#############################################################################
##
#F  AttributeMethodByNiceMonomorphism( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="AttributeMethodByNiceMonomorphism" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "AttributeMethodByNiceMonomorphism", function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: Attribute",
        true,
        par,
        0,
        function( obj )
            return oper( NiceObject(obj) );
        end );
end );


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="AttributeMethodByNiceMonomorphismCollColl" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "AttributeMethodByNiceMonomorphismCollColl",
    function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: attribute CollColl",
        IsIdenticalObj,
        par,
        0,
        function( obj1, obj2 )
            if not IsIdenticalObj( NiceMonomorphism(obj1),
                                NiceMonomorphism(obj2) )
            then
                TryNextMethod();
            fi;
            return oper( NiceObject(obj1), NiceObject(obj2) );
        end );
end );


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="AttributeMethodByNiceMonomorphismCollElm" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "AttributeMethodByNiceMonomorphismCollElm", function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: attribute CollElm",
        IsCollsElms,
        par,
        0,
        function( obj1, obj2 )
            local   nice,img;
            nice:=NiceMonomorphism(obj1);
            img := ImagesRepresentative( nice, obj2:actioncanfail:=true );
            if img = fail or
              not (img in ImagesSource(nice) and
                PreImagesRepresentative(nice,img)=obj2) then
                TryNextMethod();
            fi;
            return oper( NiceObject(obj1), img );
        end );
end );

#############################################################################
##
#F  AttributeMethodByNiceMonomorphismElmColl( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="AttributeMethodByNiceMonomorphismElmColl" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "AttributeMethodByNiceMonomorphismElmColl", function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: attributeElmColl",
        IsElmsColls,
        par,
        0,
        function( obj1, obj2 )
            local   nice,img;
            nice:=NiceMonomorphism(obj2);
            img := ImagesRepresentative( nice, obj1 );
            if img = fail or
              not (img in ImagesSource(nice) and
                PreImagesRepresentative(nice,img)=obj1) then
                TryNextMethod();
            fi;
            return oper( img,NiceObject(obj2));
        end );
end );


#############################################################################
##
#F  GroupMethodByNiceMonomorphism( <oper>, <par> )
##
BindGlobal( "GroupMethodByNiceMonomorphism", function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism:group",
        true,
        par,
        0,
        function( obj )
            local   nice,  img;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj) );
            return GroupByNiceMonomorphism( nice, img );
        end );
end );


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollOther( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="GroupMethodByNiceMonomorphismCollOther" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "GroupMethodByNiceMonomorphismCollOther", function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: group CollOther",
        true,
        par,
        0,
        function( obj, other )
            local   nice,  img;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj), other );
            return GroupByNiceMonomorphism( nice, img );
        end );
end );


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="GroupMethodByNiceMonomorphismCollColl" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "GroupMethodByNiceMonomorphismCollColl", function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism:group CollColl",
        IsIdenticalObj,
        par,
        0,
        function( obj1, obj2 )
            local   nice,  img;
            nice := NiceMonomorphism(obj1);
            if not IsIdenticalObj( nice, NiceMonomorphism(obj2) )  then
                TryNextMethod();
            fi;
            img := oper( NiceObject(obj1), NiceObject(obj2) );
            return GroupByNiceMonomorphism( nice, img );
        end );
end );


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="GroupMethodByNiceMonomorphismCollElm" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "GroupMethodByNiceMonomorphismCollElm", function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: group CollElm",
        IsCollsElms,
        par,
        0,
        function( obj1, obj2 )
            local   nice,  img,  img1;
            nice := NiceMonomorphism(obj1);
            img  := ImagesRepresentative( nice, obj2:actioncanfail:=true );
            if img = fail or
              not (img in ImagesSource(nice) and
                PreImagesRepresentative(nice,img)=obj2) then
                TryNextMethod();
            fi;
            img1 := oper( NiceObject(obj1), img );
            return GroupByNiceMonomorphism( nice, img1 );
        end );
end );


#############################################################################
##
#F  SubgroupMethodByNiceMonomorphism( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="SubgroupMethodByNiceMonomorphism" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "SubgroupMethodByNiceMonomorphism", function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: Subgroup",
        true,
        par,
        0,
        function( obj )
            local   nice,  img,  sub;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj) );
            sub  := GroupByNiceMonomorphism( nice, img );
            SetParent( sub, obj );
            return sub;
        end );
end );

#############################################################################
##
#F  SubgroupsMethodByNiceMonomorphism( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="SubgroupsMethodByNiceMonomorphism" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "SubgroupsMethodByNiceMonomorphism", function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: subgroups",
        true,
        par,
        0,
        function( obj )
            local   nice,  img,  sub,i;
            nice := NiceMonomorphism(obj);
            img  := ShallowCopy(oper( NiceObject(obj) ));
            for i in [1..Length(img)] do
              sub  := GroupByNiceMonomorphism( nice, img[i] );
              SetParent( sub, obj );
              img[i]:=sub;
            od;
            return img;
        end );
end );


#############################################################################
##
#F  SubgroupMethodByNiceMonomorphismCollOther( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="SubgroupMethodByNiceMonomorphismCollOther" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "SubgroupMethodByNiceMonomorphismCollOther",
    function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: subgroup CollOther",
        true,
        par,
        0,
        function( obj, other )
            local   nice,  img,  sub;
            nice := NiceMonomorphism(obj);
            img  := oper( NiceObject(obj), other );
            sub  := GroupByNiceMonomorphism( nice, img );
            SetParent( sub, obj );
            return sub;
        end );
end );


#############################################################################
##
#F  SubgroupMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="SubgroupMethodByNiceMonomorphismCollColl" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "SubgroupMethodByNiceMonomorphismCollColl", function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: Subgroup CollColl",
        IsIdenticalObj,
        par,
        0,
        function( obj1, obj2 )
            local   nice,  img,  sub;
            if not IsSubgroup( obj1, obj2 )  then
                TryNextMethod();
            fi;
            nice := NiceMonomorphism(obj1);
            img:=ImagesSet(nice,obj2);
            if img = fail or
              not (IsSubset(ImagesSource(nice),img) and
                PreImagesSet(nice,img)=obj2) then
                TryNextMethod();
            fi;
            img := oper( NiceObject(obj1), img );
            sub := GroupByNiceMonomorphism( nice, img );
            SetParent( sub, obj1 );
            return sub;
        end );
end );


#############################################################################
##
#F  SubgroupMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="SubgroupMethodByNiceMonomorphismCollElm" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "SubgroupMethodByNiceMonomorphismCollElm", function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: subgroup CollElm",
        IsCollsElms,
        par,
        0,
        function( obj1, obj2 )
            local   nice,  img,  img1,  sub;
            nice := NiceMonomorphism(obj1);
            img  := ImagesRepresentative( nice, obj2:actioncanfail:=true );
            if img = fail or
              not (img in ImagesSource(nice) and
                PreImagesRepresentative(nice,img)=obj2) then
                TryNextMethod();
            fi;
            img1 := oper( NiceObject(obj1), img );
            sub  := GroupByNiceMonomorphism( nice, img1 );
            SetParent( sub, obj1 );
            return sub;
        end );
end );


#############################################################################
##
#F  PropertyMethodByNiceMonomorphism( <oper>, <par> )
##
DeclareSynonym( "PropertyMethodByNiceMonomorphism",
    AttributeMethodByNiceMonomorphism );


#############################################################################
##
#F  PropertyMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="PropertyMethodByNiceMonomorphismCollColl" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonym( "PropertyMethodByNiceMonomorphismCollColl",
    AttributeMethodByNiceMonomorphismCollColl );


#############################################################################
##
#F  PropertyMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="PropertyMethodByNiceMonomorphismCollElm" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonym( "PropertyMethodByNiceMonomorphismCollElm",
    AttributeMethodByNiceMonomorphismCollElm );


#############################################################################
##
#F  PropertyMethodByNiceMonomorphismElmColl( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="PropertyMethodByNiceMonomorphismElmColl" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonym( "PropertyMethodByNiceMonomorphismElmColl",
    AttributeMethodByNiceMonomorphismElmColl );


#############################################################################
##
#F  GroupSeriesMethodByNiceMonomorphism( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="GroupSeriesMethodByNiceMonomorphism" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "GroupSeriesMethodByNiceMonomorphism", function( oper, par )

    # check the argument length
    if 1 <> Length(par)  then
        Error( "need only one argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: GroupSeries",
        true,
        par,
        0,
        function( obj )
            local   nice,  list,  i;
            nice := NiceMonomorphism(obj);
            list := oper( NiceObject(obj) );
            if not IsList( list ) then
              # The result may be 'fail'.
              return list;
            fi;
            list:= ShallowCopy( list );
            for i  in [ 1 .. Length(list) ]  do
                list[i] := GroupByNiceMonomorphism( nice, list[i] );
                SetParent( list[i], obj );
            od;
            return list;
        end );
end );


#############################################################################
##
#F  GroupSeriesMethodByNiceMonomorphismCollOther( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="GroupSeriesMethodByNiceMonomorphismCollOther" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "GroupSeriesMethodByNiceMonomorphismCollOther",
    function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two argument for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: GroupSeries CollOther",
        true,
        par,
        0,
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
end );


#############################################################################
##
#F  GroupSeriesMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="GroupSeriesMethodByNiceMonomorphismCollColl" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "GroupSeriesMethodByNiceMonomorphismCollColl",
    function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;
    par[2] := par[2] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism: GroupSeries CollColl",
        IsIdenticalObj,
        par,
        0,
        function( obj1, obj2 )
            local   nice,  list,  i;
            nice := NiceMonomorphism(obj1);
            if not IsIdenticalObj( nice, NiceMonomorphism(obj2) )  then
                TryNextMethod();
            fi;
            list := ShallowCopy(oper(NiceObject(obj1),NiceObject(obj2)));
            for i  in [ 1 .. Length(list) ]  do
                list[i] := GroupByNiceMonomorphism( nice, list[i] );
                SetParent( list[i], obj1 );
            od;
            return list;
        end );
end );


#############################################################################
##
#F  GroupSeriesMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
##  <ManSection>
##  <Func Name="GroupSeriesMethodByNiceMonomorphismCollElm" Arg='oper, par'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "GroupSeriesMethodByNiceMonomorphismCollElm",
    function( oper, par )

    # check the argument length
    if 2 <> Length(par)  then
        Error( "need two arguments for ", NameFunction(oper) );
    fi;
    par    := ShallowCopy(par);
    par[1] := par[1] and IsHandledByNiceMonomorphism;

    # install the method
    InstallOtherMethod( oper,
        "handled by nice monomorphism:GroupSeries CollElm",
        IsCollsElms,
        par,
        0,
        function( obj1, obj2 )
            local   nice,  img,  list,  i;
            nice := NiceMonomorphism(obj1);
            img  := ImagesRepresentative( nice, obj2:actioncanfail:=true );
            if img = fail or
              not (img in ImagesSource(nice) and
                PreImagesRepresentative(nice,img)=obj2) then
                TryNextMethod();
            fi;
            list := ShallowCopy( oper( NiceObject(obj1), img ) );
            for i  in [ 1 .. Length(list) ]  do
                list[i] := GroupByNiceMonomorphism( nice, list[i] );
                SetParent( list[i], obj1 );
            od;
            return list;
        end );
end );

#############################################################################
##
#A  SeedFaithfulAction( <grp> )
##
##  <#GAPDoc Label="SeedFaithfulAction">
##  <ManSection>
##  <Attr Name="SeedFaithfulAction" Arg='grp'/>
##
##  <Description>
##  If this attribute does not hold the (default) value of <A>fail</A>, it
##  is a record with components <A>points</A> (a list of orbit seeds
##  and <A>ops</A> a list of action functions, such that the action of the
##  group <A>grp</A> on the orbits specified this way is faithful and of
##  minimal degree. In this case, a nice monomorphism for <A>grp</A> will be
##  determined using this action, and no degree reduction attempt is made.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "SeedFaithfulAction",
    IsGroup );
