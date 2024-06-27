#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with strings and characters.
##


#############################################################################
##
#C  IsChar( <obj> ) . . . . . . . . . . . . . . . . .  category of characters
#C  IsCharCollection( <obj> ) . . . . . category of collections of characters
##
##  <#GAPDoc Label="IsChar">
##  <ManSection>
##  <Filt Name="IsChar" Arg='obj' Type='Category'/>
##  <Filt Name="IsCharCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>character</E> is simply an object in &GAP; that represents an
##  arbitrary character from the character set of the operating system.
##  Character literals can be entered in &GAP; by enclosing the character
##  in <E>singlequotes</E> <C>'</C>.
##  <Example><![CDATA[
##  gap> x:= 'a';  IsChar( x );
##  'a'
##  true
##  gap> '*';
##  '*'
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsChar", IS_OBJECT );

DeclareCategoryCollections( "IsChar" );


#############################################################################
##
#C  IsString( <obj> ) . . . . . . . . . . . . . . . . . . category of strings
##
##  <#GAPDoc Label="IsString">
##  <ManSection>
##  <Filt Name="IsString" Arg='obj'/>
##
##  <Description>
##  A <E>string</E> is a dense list (see&nbsp;<Ref Filt="IsList"/>,
##  <Ref Filt="IsDenseList"/>) of characters (see&nbsp;<Ref Filt="IsChar"/>);
##  thus strings are always homogeneous
##  (see&nbsp;<Ref Filt="IsHomogeneousList"/>).
##  <P/>
##  A string literal can either be entered as the list of characters
##  or by writing the characters between <E>doublequotes</E> <C>"</C>.
##  &GAP; will always output strings in the latter format.
##  However, the input via the double quote syntax enables &GAP; to store
##  the string in an efficient compact internal representation.
##  See <Ref Filt="IsStringRep"/> below for more details.
##  <P/>
##  Each character, in particular those which cannot be typed directly from
##  the keyboard, can also be typed in three digit octal notation, or
##  two digit hexadecimal notation.
##  And for some special characters (like the newline character) there is a
##  further possibility to type them,
##  see section <Ref Sect="Special Characters"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> s1 := ['H','e','l','l','o',' ','w','o','r','l','d','.'];
##  "Hello world."
##  gap> IsString( s1 );
##  true
##  gap> s2 := "Hello world.";
##  "Hello world."
##  gap> s1 = s2;
##  true
##  gap> s3 := "";  # the empty string
##  ""
##  gap> s3 = [];
##  true
##  gap> IsString( [] );
##  true
##  gap> IsString( "123" );  IsString( 123 );
##  true
##  false
##  gap> IsString( [ '1', '2', '3' ] );
##  true
##  gap> IsString( [ '1', '2', , '4' ] );  # strings must be dense
##  false
##  gap> IsString( [ '1', '2', 3 ] );  # strings must only contain characters
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsString", IsHomogeneousList, IS_STRING );

InstallTrueMethod( IsString, IsCharCollection and IsList );


#############################################################################
##
#R  IsStringRep( <obj> )
##
##  <#GAPDoc Label="IsStringRep">
##  <ManSection>
##  <Filt Name="IsStringRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  <Ref Filt="IsStringRep"/> is a special (internal) representation of dense
##  lists of characters.
##  Dense lists of characters can be converted into this representation
##  using <Ref Func="ConvertToStringRep"/>.
##  Note that calling <Ref Filt="IsString"/> does <E>not</E> change the
##  representation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentationKernel( "IsStringRep",
    IsInternalRep, IS_STRING_REP );


#############################################################################
##
#F  ConvertToStringRep( <obj> ) . . . . . . . . . . . . .  inplace conversion
##
##  <#GAPDoc Label="ConvertToStringRep">
##  <ManSection>
##  <Func Name="ConvertToStringRep" Arg='obj'/>
##
##  <Description>
##  If <A>obj</A> is a dense internally represented list of characters then
##  <Ref Func="ConvertToStringRep"/> changes the representation to
##  <Ref Filt="IsStringRep"/>.
##  This is useful in particular for converting the empty list <C>[]</C>,
##  which usually is in <Ref Filt="IsPlistRep"/>,
##  to <Ref Filt="IsStringRep"/>.
##  If <A>obj</A> is not a string then <Ref Func="ConvertToStringRep"/>
##  signals an error.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ConvertToStringRep", CONV_STRING );

#############################################################################
##
#F  CopyToStringRep( <obj> ) . . . . . . . . . . . . . . .  copy conversion
##
##  <#GAPDoc Label="CopyToStringRep">
##  <ManSection>
##  <Func Name="CopyToStringRep" Arg='obj'/>
##
##  <Description>
##  If <A>obj</A> is a dense internally represented list of characters then
##  <Ref Func="CopyToStringRep"/> copies <A>obj</A> to a new object with
##  representation
##  <Ref Filt="IsStringRep"/>.
##  If <A>obj</A> is not a string then <Ref Func="CopyToStringRep"/>
##  signals an error.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "CopyToStringRep", COPY_TO_STRING_REP );

#############################################################################
##
#V  CharsFamily . . . . . . . . . . . . . . . . . . . .  family of characters
##
##  <#GAPDoc Label="CharsFamily">
##  <ManSection>
##  <Fam Name="CharsFamily"/>
##
##  <Description>
##  Each character lies in the family <Ref Fam="CharsFamily"/>,
##  each nonempty string lies in the collections family of this family.
##  Note the subtle differences between the empty list <C>[]</C> and the
##  empty string <C>""</C> when both are printed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "CharsFamily", NewFamily( "CharsFamily", IsChar ) );


#############################################################################
##
#V  TYPE_CHAR . . . . . . . . . . . . . . . . . . . . . . type of a character
##
##  <ManSection>
##  <Var Name="TYPE_CHAR"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_CHAR", NewType( CharsFamily, IsChar and IsInternalRep ) );


#############################################################################
##
#V  TYPES_STRING . . . . . . . . . . . . . . . . . . . . . types of strings
##
##  <ManSection>
##  <Var Name="TYPES_STRING"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "StringFamily", NewFamily( "StringsFamily", IsCharCollection ) );

BIND_GLOBAL( "TYPES_STRING",
        [ NewType( StringFamily, IsString and IsStringRep and
                IsMutable ), # T_STRING

          NewType( StringFamily, IsString and IsStringRep ),
          # T_STRING + IMMUTABLE

          NewType (StringFamily, IsString and IsStringRep and
                  HasIsSSortedList and IsMutable ),
          # T_STRING_NSORT

          NewType (StringFamily, IsString and IsStringRep and
                  HasIsSSortedList ),
          # T_STRING_NSORT +IMMUTABLE

          NewType (StringFamily, IsString and IsStringRep and
                  IsSSortedList and IsMutable ),
          # T_STRING_SSORT

          NewType (StringFamily, IsString and IsStringRep and
                  IsSSortedList )
          # T_STRING_SSORT +IMMUTABLE
          ]);

if IsHPCGAP then
    MakeReadOnlySingleObj( TYPES_STRING );
fi;

#############################################################################
##
#F  IsEmptyString( <str> )  . . . . . . . . . . . . . . . empty string tester
##
##  <#GAPDoc Label="IsEmptyString">
##  <ManSection>
##  <Func Name="IsEmptyString" Arg='str'/>
##
##  <Description>
##  <Ref Func="IsEmptyString"/> returns <K>true</K> if <A>str</A> is the
##  empty string in the representation <Ref Filt="IsStringRep"/>,
##  and <K>false</K> otherwise.
##  Note that the empty list <C>[]</C> and the empty string <C>""</C> have
##  the same type, the recommended way to distinguish them is via
##  <Ref Func="IsEmptyString"/>.
##  For formatted printing, this distinction is sometimes necessary.
##  <!-- The type is the same because <C>IsStringRep</C> is not <E>set</E> in this type,-->
##  <!-- and <C>IsPlistRep</C> is <E>set</E>,-->
##  <!-- although <E>calling</E> <C>IsStringRep</C> for <C>[]</C> yields <K>false</K>,-->
##  <!-- and <E>calling</E> <C>IsPlistRep</C> for <C>""</C> yields <K>false</K>, too.-->
##  <P/>
##  <Example><![CDATA[
##  gap> l:= [];;  IsString( l );  IsEmptyString( l );  IsEmpty( l );
##  true
##  false
##  true
##  gap> l;  ConvertToStringRep( l );  l;
##  [  ]
##  ""
##  gap> IsEmptyString( l );  IsEmptyString( "" );  IsEmptyString( "abc" );
##  true
##  true
##  false
##  gap> ll:= [ 'a', 'b' ];  IsStringRep( ll );  ConvertToStringRep( ll );
##  "ab"
##  false
##  gap> ll;  IsStringRep( ll );
##  "ab"
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "IsEmptyString",
    obj ->     IsString( obj )
           and IsEmpty( obj )
           and IsStringRep( obj ) );


############################################################################
##
#M  String( <str> ) . . . . . . . . . . . . . . . . . . . . . .  for a string
##
InstallMethod( String,
    "for a string (do nothing)",
    [ IsString ],
    function(s)
      if Length(s) = 0 and not IsStringRep(s) then
        return "[  ]";
      else
        return s;
      fi;
    end);


############################################################################
##
#M  String( <str> ) . . . . . . . . . . . . . . . . . . . .  for a character
##
InstallMethod( String,
    "for a character",
    [ IsChar ],
    function(ch)
      local res; res := "\'"; Add(res, ch); Add(res, '\''); return res;
    end);


#############################################################################
##
#F  UserHomeExpand( <str> ) . . . . . . . . . . . . expand leading ~ in str
##
##  <#GAPDoc Label="UserHomeExpand">
##  <ManSection>
##  <Func Name="UserHomeExpand" Arg='str'/>
##  <Description>
##  If the string <A>str</A> starts with a <C>'~'</C> character this
##  function returns a new string with the leading <C>'~'</C> substituted by
##  the user's home directory as stored in <C>GAPInfo.UserHome</C>.
##  Otherwise <A>str</A> is returned unchanged.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("UserHomeExpand", function(str)
  if IsString(str) and Length(str) > 0 and str[1] = '~'
        and IsString(GAPInfo.UserHome) and Length( GAPInfo.UserHome ) > 0 then
    return Concatenation( GAPInfo.UserHome, str{[2..Length(str)]});
  else
    return str;
  fi;
end);


# the character set definitions might be needed when processing files, thus
# they must come earlier.
BIND_GLOBAL("CHARS_DIGITS",MakeImmutable(LIST_SORTED_LIST("0123456789")));
BIND_GLOBAL("CHARS_UALPHA",
  MakeImmutable(LIST_SORTED_LIST("ABCDEFGHIJKLMNOPQRSTUVWXYZ")));
BIND_GLOBAL("CHARS_LALPHA",
  MakeImmutable(LIST_SORTED_LIST("abcdefghijklmnopqrstuvwxyz")));
BIND_GLOBAL("CHARS_ALPHA",
  MakeImmutable(LIST_SORTED_LIST("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")));
BIND_GLOBAL("CHARS_SYMBOLS",
  MakeImmutable(LIST_SORTED_LIST(" !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")));


#############################################################################
##
#F  _StripEscapeSequences( <str> ) . . . . . remove escape sequences from str
##
##  <#GAPDoc Label="_StripEscapeSequences">
##  <ManSection >
##  <Func Arg="str" Name="_StripEscapeSequences" />
##  <Returns>string without escape sequences</Returns>
##  <Description>
##  This function returns the string one gets from the string <A>str</A> by
##  removing all escape sequences. If <A>str</A> does not contain such a
##  sequence then <A>str</A> itself is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("_StripEscapeSequences", function(str)
  local   esc,  res,  i,  ls,  p;
  esc := CHAR_INT(27);
  res := "";
  i := 1;
  ls := Length(str);
  while i <= ls do
    if str[i] = esc then
      i := i+1;
      while not str[i] in CHARS_ALPHA do
        i := i+1;
      od;
      # first letter is last character of escape sequence
      i := i+1;
      # remove \027 marker of inner escape sequences as well
      if IsBound(str[i]) and str[i] = '\027' then
        i := i+1;
      fi;
    else
      p := Position(str, esc, i);
      if p=fail then
        if i=1 then
          # don't copy if no escape there
          return str;
        else
          Append(res, str{[i..ls]});
          return res;
        fi;
      else
        Append(res, str{[i..p-1]});
        i := p;
      fi;
    fi;
  od;
  return res;
end);
