#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  See the comments in `lib/obsolete.gd'.
##


#############################################################################
##
#M  CharacteristicPolynomial( <F>, <mat> )
#M  CharacteristicPolynomial( <field>, <matrix>, <indnum> )
##
##  The documentation of these usages of CharacteristicPolynomial was
##  ambiguous, leading to surprising results if mat was over F but
##  DefaultField (mat) properly contained F.
##  Now there is a four argument version which allows to specify the field
##  which specifies the linear action of mat, and another which specifies
##  the vector space which mat acts upon.
##
##  In the future, the versions above could be given a different meaning,
##  where the first argument simply specifies both fields in the case
##  when they are the same.
##
##  The following provides backwards compatibility with  {\GAP}~4.4. in the
##  cases where there is no ambiguity.
##
InstallOtherMethod( CharacteristicPolynomial,
     "supply indeterminate 1",
    [ IsField, IsMatrix ],
    function( F, mat )
        return CharacteristicPolynomial (F, mat, 1);
    end );

InstallOtherMethod( CharacteristicPolynomial,
    "check default field, print error if ambiguous",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ],
function( F, mat, inum )
        if IsSubset (F, DefaultFieldOfMatrix (mat)) then
            Info (InfoObsolete, 1, "This usage of `CharacteristicPolynomial' is no longer supported. ",
                "Please specify two fields instead.");
            return CharacteristicPolynomial (F, F, mat, inum);
        else
            Error ("this usage of `CharacteristicPolynomial' is no longer supported, ",
                "please specify two fields instead.");
        fi;
end );


#############################################################################
##
#M  MultVector( <list1>, <poss1>, <list2>, <poss2>, <mult> )
##
InstallOtherMethod( MultVector, "obsolete five argument method",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsDenseList,
      IsDenseList,
      IsObject ],
    0,
function( l1, p1, l2, p2, m )
    Info(InfoObsolete, 1, "This usage of `MultVector` is no longer ",
           "supported and will be removed eventually." );
    l1{p1} := m * l2{p2};
end );

InstallOtherMethod( MultVector, "error if immutable", true,
    [ IsList,IsObject,IsObject,IsObject,IsObject],0,
    L1_IMMUTABLE_ERROR);

#############################################################################
##
#F  SetUserPreferences
##
##  Set the defaults of `GAPInfo.UserPreferences'.
##
##  We locate the first file `gap.ini' in GAP root directories,
##  and read it if available.
##  This must be done before `GAPInfo.UserPreferences' is used.
##  Some of the preferences require an initialization,
##  but this cannot be called before the complete library has been loaded.
##
BindGlobal( "SetUserPreferences", function( arg )
    local name, record;

    Info( InfoObsolete, 1, "");
    Info( InfoObsolete, 1, Concatenation( [
          "The call to 'SetUserPreferences' (probably in a 'gap.ini' file)\n",
          "#I  should be replaced by individual 'SetUserPreference' calls,\n",
          "#I  which are package specific.\n",
          "#I  Try 'WriteGapIniFile()'." ] ) );

    # Set the new values.
    if Length( arg ) = 1 then
      record:= arg[1];
      if not IsBound(GAPInfo.UserPreferences.gapdoc) then
        GAPInfo.UserPreferences.gapdoc := rec();
      fi;
      if not IsBound(GAPInfo.UserPreferences.gap) then
        GAPInfo.UserPreferences.gap := rec();
      fi;
      for name in RecNames( record ) do
        if name in [ "HTMLStyle", "TextTheme", "UseMathJax" ] then
          GAPInfo.UserPreferences.gapdoc.( name ):= record.( name );
        else
          GAPInfo.UserPreferences.gap.( name ):= record.( name );
        fi;
      od;
    fi;
    end );

##
#F  TemporaryGlobalVarName( [<prefix>] )   name of an unbound global variable
##
##  TemporaryGlobalVarName ( [<prefix>]  ) returns a string  that can be used
##  as the  name  of a global  variable  that is not bound   at the time when
##  TemporaryGlobalVarName()  is called.    The optional  argument prefix can
##  specify a string with which the name of the global variable starts.
##

InstallGlobalFunction( TemporaryGlobalVarName,
        function( arg )
    local   prefix,  nr,  gvar;

  Info(InfoObsolete, 2, "This usage of `TemporaryGlobalVarName` is no longer ",
         "supported and will be removed eventually." );

    if Length(arg) = 0 then
        prefix := "TEMP";
    elif Length(arg) = 1 and IsString( arg[1] ) then
        prefix := arg[1];
        CheckGlobalName( prefix );
    else
        return Error( "usage: TemporaryGlobalVarName( [<prefix>] )" );
    fi;

    nr := 0;
    gvar:= prefix;
    while ISBOUND_GLOBAL( gvar ) do
        nr := nr + 1;
        gvar := Concatenation( prefix, String(nr) );
    od;

    return gvar;
end );


if IsHPCGAP then
    BindThreadLocal("HIDDEN_GVARS",[]);
else
    HIDDEN_GVARS:=[];
fi;

InstallGlobalFunction(HideGlobalVariables,function(arg)
local p,i;

  Info(InfoObsolete, 2, "This usage of `HideGlobalVariables` is no longer ",
         "supported and will be removed eventually." );

  p:=Length(HIDDEN_GVARS);
  for i in arg do
    if IsString(i) then
      p:=p+1;
      HIDDEN_GVARS[p]:=i;
      p:=p+2;
      if ISBOUND_GLOBAL(i) then
        # variable is assigned
        HIDDEN_GVARS[p-1]:=VALUE_GLOBAL(i);
        if IS_READ_ONLY_GLOBAL(i) then
          HIDDEN_GVARS[p]:=true;
          MAKE_READ_WRITE_GLOBAL(i);
        else
          HIDDEN_GVARS[p]:=false;
        fi;
      else
        HIDDEN_GVARS[p-1]:=fail; # needs to be assigned
        HIDDEN_GVARS[p]:=fail;
      fi;
      # temporarily remove the variable
      UNBIND_GLOBAL(i);
    else
      Error("HideGlobalVariables requires the names as strings");
    fi;
  od;
end);

InstallGlobalFunction(UnhideGlobalVariables,function(arg)
local p,str,all,l,which;

  Info(InfoObsolete, 2, "This usage of `UnhideGlobalVariables` is no longer ",
         "supported and will be removed eventually." );

  all:=Length(arg)=0; # doe we want to unhide all?
  which:=arg;
  l:=Length(HIDDEN_GVARS);
  p:=l-2;
  while p>0 do
    str:=HIDDEN_GVARS[p];
    # do we want to unhide the variable?
    if all or str in which then
      # remove the value
      if ISBOUND_GLOBAL(str) then
        if IS_READ_ONLY_GLOBAL(str) then
          MAKE_READ_WRITE_GLOBAL(str);
        fi;
        UNBIND_GLOBAL(str);
      fi;

      if HIDDEN_GVARS[p+2]<>fail then
        #reassign a value
        ASS_GVAR(str,HIDDEN_GVARS[p+1]);
        if HIDDEN_GVARS[p+2]=true then
          MAKE_READ_ONLY_GLOBAL(str);
        fi;
      fi;

      # remove the corresponding "HIDDEN_GVARS" entry
      if not all then
        if p+2<l then
          # move
          HIDDEN_GVARS{[p..l-3]}:=HIDDEN_GVARS{[p+3..l]};
        fi;
        # remove
        Unbind(HIDDEN_GVARS[l-2]);
        Unbind(HIDDEN_GVARS[l-1]);
        Unbind(HIDDEN_GVARS[l]);
        l:=l-3;
        which:=Filtered(which,i->i<>str);
      fi;
    fi;
    p:=p-3;
  od;
  if all then
    HIDDEN_GVARS:=[];
  fi;
end);

#############################################################################
##
#F  RANDOM_SEED( <list> )
##
##  Moved to obsoletes in August 2019 for GAP 4.11.
##
##  Still used in francy, hap -- but only in the package tests (02/2025)
BindGlobal("RANDOM_SEED", function ( n )
    Init(GlobalRandomSource, n);
end );

##
##  The variables R_N and R_X used to part of the state of GAP's random number
##  generator, and even were mentioned in the documentation of GAP 4.4, albeit
##  only in a parenthesis, and as an alternative to StateRandom /
##  RestoreStateRandom, which in turn were made obsolete in GAP 4.5.
##
##  No code is known to use these, anywhere. But hypothetically, somebody might
##  have ancient GAP code sitting somewhere which tries to access these two
##  in some way. We thus try hard to make sure this leads to an error, instead
##  of possibly working silently, and leading to an erroneous computations.
##
BindGlobal("R_N", fail);
BindGlobal("R_X", fail);

# Moved to obsolete in Nov. 2021 for 4.12
InstallMethod( NaturalHomomorphism, "for a group with natural homomorphism stored",
    [ IsGroup ],
function(G)
  Info(InfoWarning,0,"The use of `NaturalHomomorphism` for a `FactorGroup`\n",
    "has been deprecated, as it caused side-effects.\n",
    "Proceed at risk!");

  if IsBound(G!.nathom) then
    return G!.nathom;
  else
    Error("no natural homomorphism stored");
  fi;
end);


#############################################################################
##
#F  TmpNameAllArchs( )
##
##  Not used in any redistributed package (02/2025)
DeclareObsoleteSynonym( "TmpNameAllArchs", "TmpName" );
