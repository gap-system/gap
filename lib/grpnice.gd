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
#F  MayBeHandledByNiceMonomorphism( <G> )
##
##  This filter is intended to deal with the following situation.
##  We have a group <A>G</A> that can be handled via a nice monomorphism
##  if it satisfies certain conditions, but we do not want to check these
##  conditions until we can take advantage of the nice monomorphism,
##  i.e., until the call of an operation for which a method is installed
##  that has <Ref Prop="IsHandledByNiceMonomorphism"/> as a requirement for
##  one of its arguments.
##
##  More precisely:
##  Only those operations are supported for which these methods get installed
##  via the functions <Q><C>SomethingMethodByNiceMonomorphismSomething</C></Q>
##  in <F>lib/grpnice.gi</F>.
##  If <Ref Filt="MayBeHandledByNiceMonomorphism"/> is set for <A>G</A>
##  then all these operations have also a method that gets installed with
##  requirements where <Ref Prop="IsHandledByNiceMonomorphism"/> is replaced
##  by <Ref Filt="MayBeHandledByNiceMonomorphism"/>.
##  These methods call <Ref Prop="IsHandledByNiceMonomorphism"/>;
##  if the result is <K>false</K> then <Ref Func="TryNextMethod"/> gets
##  called, if the result is <K>true</K> then the corresponding method gets
##  called that is installed for the situation that
##  <Ref Prop="IsHandledByNiceMonomorphism"/> is already stored.
##  Additionally, the filter <Ref Filt="MayBeHandledByNiceMonomorphism"/>
##  gets reset in both cases since it is not useful anymore.
##
##  The <Ref Filt="MayBeHandledByNiceMonomorphism"/> mechanism can be used
##  for example if <A>G</A> is a matrix group for which finiteness can be
##  decided but is not a priori known,
##  such as groups of matrices with entries in some cyclotomic field.
##  These groups can be handled by a nice monomorphism if they are finite,
##  hence a <Ref Prop="IsHandledByNiceMonomorphism"/> method can be installed
##  that checks finiteness.
##
##  The mechanism is <E>not</E> intended for situations where
##  <Ref Prop="IsHandledByNiceMonomorphism"/> cannot be decided.
##  For example, it is not suitable for arbitrary finitely presented groups.
##
##  The filter <Ref Prop="IsHandledByNiceMonomorphism"/> must not have
##  implications because it will be reset for a group as soon as we find out
##  the <Ref Prop="IsHandledByNiceMonomorphism"/> value for it.
##
DeclareFilter( "MayBeHandledByNiceMonomorphism" );


#############################################################################
##
##  The following functions are used as methods for operations that require
##  <Ref Filt="MayBeHandledByNiceMonomorphism"/> and call
##  <Ref Prop="IsHandledByNiceMonomorphism"/>.
##
BindGlobal( "MethodForMayBeHandledByNiceMonomorphism",
  function( meth, check )
    return function( obj... )
      local i, flag;

      for i in check do
        flag:= IsHandledByNiceMonomorphism( obj[i] );
        ResetFilterObj( obj[i], MayBeHandledByNiceMonomorphism );
        if not flag then
          TryNextMethod();
        fi;
      od;
      return CallFuncList( meth, obj );
    end;
  end );


#############################################################################
##
#F  InstallNiceMonomorphismMethod( <oper>, <par>, <methtext>, <fampred>,
#F                                 <check>, <meth> )
##
##  Install the method <A>meth</A> for the operation <A>oper</A>,
##  for the case that the arguments satisfy the requirements in <A>par</A>
##  and such that for each position <M>i</M> in the list <A>check</A>,
##  also <Ref Prop="IsHandledByNiceMonomorphism"/> is required for the
##  <M>i</M>-th argument.
##  The family relation between the arguments is given by <A>fampred</A>,
##  and the comment for the method installation is <A>methtext</A>.
##
##  Additionally, install a method for the situation where
##  <Ref Prop="IsHandledByNiceMonomorphism"/> is replaced by
##  <Ref Filt="MayBeHandledByNiceMonomorphism"/>, such that this method
##  delegates to <A>meth</A> if the relevant arguments are in
##  <Ref Prop="IsHandledByNiceMonomorphism"/>.
##
BindGlobal( "InstallNiceMonomorphismMethod",
  function( oper, par, methtext, fampred, check, meth )
    local nargs, req1, req2, i;

    # Check the argument length.
    nargs:= NumberArgumentsFunction( meth );
    if nargs <> Length( par ) then
      Error( "need ", Pluralize( nargs, "argument" ), " for ",
             NameFunction( oper ) );
    fi;

    req1:= ShallowCopy( par );
    req2:= ShallowCopy( par );
    for i in check do
      req1[i]:= req1[i] and IsHandledByNiceMonomorphism;
      req2[i]:= req2[i] and MayBeHandledByNiceMonomorphism;
    od;

    # Install the methods.
    InstallOtherMethod( oper,
        Concatenation( "handled by nice monomorphism: ", methtext ),
        fampred,
        req1,
        0,
        meth );

    InstallOtherMethod( oper,
        Concatenation( "perhaps handled by nice monomorphism: ", methtext ),
        fampred,
        req2,
        0,
        MethodForMayBeHandledByNiceMonomorphism( meth, check ) );
  end );

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
#F  AttributeMethodByNiceMonomorphism( <oper>, <par>[, <meth>] )
##
BindGlobal( "AttributeMethodByNiceMonomorphism",
  function( oper, par, meth... )
  if Length( meth ) = 0 then
    meth:= obj -> oper( NiceObject( obj ) );
  else
    meth:= meth[1];
  fi;

  InstallNiceMonomorphismMethod( oper, par, "attribute",
    true, [ 1 ], meth );
end );


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismList( <oper>, <par> )
##
BindGlobal( "AttributeMethodByNiceMonomorphismList", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "attribute list",
    true, [ 1 ],
    function( obj )
      local nice;
      nice:= NiceMonomorphism( obj );
      return List( oper( NiceObject( obj ) ),
                   x -> PreImagesRepresentative( nice, x ) );
    end );
end );


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
BindGlobal( "AttributeMethodByNiceMonomorphismCollColl", function( oper, par )
 InstallNiceMonomorphismMethod( oper, par, "attribute CollColl",
   IsIdenticalObj, [ 1, 2 ],
    function( obj1, obj2 )
      if not IsIdenticalObj( NiceMonomorphism(obj1),
                             NiceMonomorphism(obj2) ) then
        TryNextMethod();
      fi;
      return oper( NiceObject(obj1), NiceObject(obj2) );
    end );
end );


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
BindGlobal( "AttributeMethodByNiceMonomorphismCollElm", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "attribute CollElm",
    IsCollsElms, [ 1 ],
    function( obj1, obj2 )
      local nice, img;
      nice:= NiceMonomorphism( obj1 );
      img := ImagesRepresentative( nice, obj2 : actioncanfail:= true );
      if img = fail or
         not ( img in ImagesSource( nice ) and
               PreImagesRepresentative( nice, img ) = obj2 ) then
        TryNextMethod();
      fi;
      return oper( NiceObject( obj1 ), img );
    end );
end );


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismCollElmOther( <oper>, <par>[, <meth>] )
##
BindGlobal( "AttributeMethodByNiceMonomorphismCollElmOther",
  function( oper, par, meth... )
  if Length( meth ) = 0 then
    meth:= function( obj1, obj2, obj3 )
      local nice, img;
      nice:= NiceMonomorphism( obj1 );
      img := ImagesRepresentative( nice, obj2 );
      return oper( NiceObject( obj1 ), img, obj3 );
    end;
  else
    meth:= meth[1];
  fi;

  InstallNiceMonomorphismMethod( oper, par, "attribute CollElmOther",
    true, [ 1 ], meth );
end );


#############################################################################
##
#F  AttributeMethodByNiceMonomorphismElmColl( <oper>, <par>[, <meth>] )
##
BindGlobal( "AttributeMethodByNiceMonomorphismElmColl",
  function( oper, par, meth... )
  if Length( meth ) = 0 then
    meth:= function( obj1, obj2 )
      local nice, img;
      nice:= NiceMonomorphism( obj2 );
      img := ImagesRepresentative( nice, obj1 : actioncanfail:= true );
      if img = fail or
         not (img in ImagesSource( nice ) and
              PreImagesRepresentative( nice, img ) = obj1) then
        TryNextMethod();
      fi;
      return oper( img, NiceObject( obj2 ) );
    end;
  else
    meth:= meth[1];
  fi;

  InstallNiceMonomorphismMethod( oper, par, "attribute ElmColl",
    IsElmsColls, [ 2 ], meth );
end );


#############################################################################
##
#F  GroupMethodByNiceMonomorphism( <oper>, <par> )
##
BindGlobal( "GroupMethodByNiceMonomorphism", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "group",
    true, [ 1 ],
    function( obj )
      local nice, img;
      nice := NiceMonomorphism( obj );
      img  := oper( NiceObject( obj ) );
      return GroupByNiceMonomorphism( nice, img );
    end );
end );


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollOther( <oper>, <par>[, <meth>] )
##
BindGlobal( "GroupMethodByNiceMonomorphismCollOther",
  function( oper, par, meth... )
  if Length( meth ) = 0 then
    meth:= function( obj, other )
      local nice, img;
      nice := NiceMonomorphism( obj );
      img  := oper( NiceObject( obj ), other );
      return GroupByNiceMonomorphism( nice, img );
    end;
  else
    meth:= meth[1];
  fi;

  InstallNiceMonomorphismMethod( oper, par, "group CollOther",
    true, [ 1 ], meth );
end );


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
BindGlobal( "GroupMethodByNiceMonomorphismCollColl", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "group CollColl",
    IsIdenticalObj, [ 1, 2 ],
    function( obj1, obj2 )
      local nice, img;
      nice := NiceMonomorphism( obj1 );
      if not IsIdenticalObj( nice, NiceMonomorphism( obj2 ) )  then
        TryNextMethod();
      fi;
      img := oper( NiceObject( obj1 ), NiceObject( obj2 ) );
      return GroupByNiceMonomorphism( nice, img );
    end );
end );


#############################################################################
##
#F  GroupMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
BindGlobal( "GroupMethodByNiceMonomorphismCollElm",
  function( oper, par, meth... )
  if Length( meth ) = 0 then
    meth:= function( obj1, obj2 )
      local nice, img, img1;
      nice := NiceMonomorphism( obj1 );
      img  := ImagesRepresentative( nice, obj2 : actioncanfail:= true );
      if img = fail or
         not (img in ImagesSource( nice ) and
              PreImagesRepresentative( nice, img ) = obj2) then
        TryNextMethod();
      fi;
      img1 := oper( NiceObject( obj1 ), img );
      return GroupByNiceMonomorphism( nice, img1 );
    end;
  else
    meth:= meth[1];
  fi;

  InstallNiceMonomorphismMethod( oper, par, "group CollElm",
    IsCollsElms, [ 1 ], meth );
end );


#############################################################################
##
#F  SubgroupMethodByNiceMonomorphism( <oper>, <par> )
##
BindGlobal( "SubgroupMethodByNiceMonomorphism", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "subgroup",
    true, [ 1 ],
    function( obj )
      local nice, img, sub;
      nice := NiceMonomorphism( obj );
      img  := oper( NiceObject( obj ) );
      sub  := GroupByNiceMonomorphism( nice, img );
      SetParent( sub, obj );
      return sub;
    end );
end );


#############################################################################
##
#F  SubgroupsMethodByNiceMonomorphism( <oper>, <par> )
##
BindGlobal( "SubgroupsMethodByNiceMonomorphism", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "subgroups",
    true, [ 1 ],
    function( obj )
      local nice, img, sub, i;
      nice := NiceMonomorphism( obj );
      img  := ShallowCopy( oper( NiceObject( obj ) ) );
      for i in [ 1 .. Length( img ) ] do
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
BindGlobal( "SubgroupMethodByNiceMonomorphismCollOther", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "subgroup CollOther",
    true, [ 1 ],
    function( obj, other )
      local nice, img, sub;
      nice := NiceMonomorphism( obj );
      img  := oper( NiceObject( obj ), other );
      sub  := GroupByNiceMonomorphism( nice, img );
      SetParent( sub, obj );
      return sub;
    end );
end );


#############################################################################
##
#F  SubgroupMethodByNiceMonomorphismCollColl( <oper>, <par> )
##
BindGlobal( "SubgroupMethodByNiceMonomorphismCollColl", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "subgroup CollColl",
    IsIdenticalObj, [ 1, 2 ],
    function( obj1, obj2 )
      local nice, img, sub;
      if not IsSubgroup( obj1, obj2 )  then
        TryNextMethod();
      fi;
      nice := NiceMonomorphism( obj1 );
      img:=ImagesSet( nice, obj2 );
      if img = fail or
         not ( IsSubset( ImagesSource( nice ), img ) and
               PreImagesSet( nice, img ) = obj2 ) then
        TryNextMethod();
      fi;
      img := oper( NiceObject( obj1 ), img );
      sub := GroupByNiceMonomorphism( nice, img );
      SetParent( sub, obj1 );
      return sub;
    end );
end );


#############################################################################
##
#F  SubgroupMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
BindGlobal( "SubgroupMethodByNiceMonomorphismCollElm", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "subgroup CollElm",
    IsCollsElms, [ 1 ],
    function( obj1, obj2 )
      local nice, img, img1, sub;
      nice := NiceMonomorphism( obj1 );
      img  := ImagesRepresentative( nice, obj2 : actioncanfail:= true );
      if img = fail or
         not ( img in ImagesSource( nice ) and
               PreImagesRepresentative (nice , img ) = obj2 ) then
        TryNextMethod();
      fi;
      img1 := oper( NiceObject( obj1 ), img );
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
DeclareSynonym( "PropertyMethodByNiceMonomorphismCollColl",
    AttributeMethodByNiceMonomorphismCollColl );


#############################################################################
##
#F  PropertyMethodByNiceMonomorphismCollElm( <oper>, <par> )
##
DeclareSynonym( "PropertyMethodByNiceMonomorphismCollElm",
    AttributeMethodByNiceMonomorphismCollElm );


#############################################################################
##
#F  PropertyMethodByNiceMonomorphismElmColl( <oper>, <par> )
##
DeclareSynonym( "PropertyMethodByNiceMonomorphismElmColl",
    AttributeMethodByNiceMonomorphismElmColl );


#############################################################################
##
#F  GroupSeriesMethodByNiceMonomorphism( <oper>, <par> )
##
BindGlobal( "GroupSeriesMethodByNiceMonomorphism", function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "GroupSeries",
    true, [ 1 ],
    function( obj )
      local nice, list, i;
      nice := NiceMonomorphism( obj );
      list := oper( NiceObject( obj ) );
      if not IsList( list ) then
        # The result may be 'fail'.
        return list;
      fi;
      list:= ShallowCopy( list );
      for i in [ 1 .. Length( list ) ] do
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
BindGlobal( "GroupSeriesMethodByNiceMonomorphismCollOther",
  function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "GroupSeries CollOther",
    true, [ 1 ],
    function( obj, other )
      local nice, list, i;
      nice := NiceMonomorphism( obj );
      list := ShallowCopy( oper( NiceObject( obj ), other ) );
      for i in [ 1 .. Length( list ) ] do
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
BindGlobal( "GroupSeriesMethodByNiceMonomorphismCollColl",
  function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "GroupSeries CollColl",
    IsIdenticalObj, [ 1, 2 ],
    function( obj1, obj2 )
      local nice, list, i;
      nice := NiceMonomorphism( obj1 );
      if not IsIdenticalObj( nice, NiceMonomorphism( obj2 ) )  then
        TryNextMethod();
      fi;
      list := ShallowCopy( oper( NiceObject( obj1 ), NiceObject( obj2 ) ) );
      for i in [ 1 .. Length( list ) ] do
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
BindGlobal( "GroupSeriesMethodByNiceMonomorphismCollElm",
  function( oper, par )
  InstallNiceMonomorphismMethod( oper, par, "GroupSeries CollElm",
    IsCollsElms, [ 1 ],
    function( obj1, obj2 )
      local nice, img, list, i;
      nice := NiceMonomorphism( obj1 );
      img  := ImagesRepresentative( nice, obj2 : actioncanfail:= true );
      if img = fail or
         not ( img in ImagesSource( nice ) and
               PreImagesRepresentative( nice, img ) = obj2 ) then
        TryNextMethod();
      fi;
      list := ShallowCopy( oper( NiceObject( obj1 ), img ) );
      for i in [ 1 .. Length( list ) ] do
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
