#############################################################################
##
#W  userpref.g                  GAP library                     Thomas Breuer
#W                                                               Frank Lübeck
##
#Y  Copyright (C) 2012 The GAP Group
##
##  This file contains the functions dealing with the administration of
##  user preferences (declaring, setting, accessing).
##  The individual declarations happen somewhere else in GAP library files
##  or in package files.
##

#############################################################################
##
#F  DeclareUserPreference( <record> )
#F  SetUserPreference( [<package>, ]<name>, <value> )
#F  UserPreference( [<package>, ]<name> )
#F  ShowUserPreferences( package1, package2, ... )
#F  WriteGapIniFile( [<dir>][, ][true] )
##
##  <#GAPDoc Label="UserPreferences">
##  <ManSection>
##  <Heading>User preferences</Heading>
##  <Func Name="DeclareUserPreference" Arg="record"/>
##  <Func Name="SetUserPreference" Arg="[package, ]name, value"/>
##  <Func Name="UserPreference" Arg="[package, ]name"/>
##  <Func Name="ShowUserPreferences" Arg="package1, package2, ..."/>
##  <Func Name="WriteGapIniFile" Arg="[dir][,][ignorecurrent]"/>
##
##  <Description>
##  These functions deal with user preferences, for example the way how
##  &GAP;'s online help is shown.
##  The idea is that such preferences are declared and get default values
##  with <Ref Func="DeclareUserPreference"/>, the values can be set with
##  <Ref Func="SetUserPreference"/>, and the values can be accessed with
##  <Ref Func="UserPreference"/>.
##  <P/>
##  The function <Ref Func="ShowUserPreferences"/> shows an overview of the
##  currently available user preferences and their values in a pager.
##  (The choice of this pager is determined by the user preference
##  <C>"Pager"</C>.)
##  If arguments <A>package1</A>, <A>package2</A> etc. are given then the
##  overview is restricted to the packages with these names.
##  <P/>
##  The calls to <Ref Func="SetUserPreference"/> may appear in the user's
##  <F>gap.ini</F> file (see&nbsp;<Ref Sect="sect:gap.ini"/>).
##  This file can be created or updated with <Ref Func="WriteGapIniFile"/>;
##  optional arguments for this function are the directory path
##  <A>dir</A> (a string or a directory object) where the file shall be
##  written, and <A>ignorecurrent</A> (if the value is <K>true</K> then
##  a file with assignments of the default values for the user preferences
##  is written, not of their current values.
##  <P/>
##  Each user preference is identified by the case insensitive strings
##  <A>package</A> (the name of a &GAP; package) and <A>name</A>.
##  Thus several packages may declare independent user preferences with the
##  same <A>name</A> part.
##  The default for <A>package</A> is <C>"GAP"</C>.
##  <Ref Func="SetUserPreference"/> sets the value of the given user
##  preference to <A>value</A>, and 
##  <Ref Func="UserPreference"/> returns the current value.
##  Note that <Ref Func="UserPreference"/> returns <K>fail</K> if no user
##  preference for <A>package</A> and <A>name</A> exists;
##  thus the value <K>fail</K> of a user preference is equivalent to the
##  situation that this user preference is not available.
##  <P/>
##  It is possible to use <Ref Func="SetUserPreference"/> and
##  <Ref Func="UserPreference"/> for dealing with user preferences that have
##  not been declared with <Ref Func="DeclareUserPreference"/>.
##  (This is necessary in the situation that the <F>gap.ini</F> file sets
##  values for preferences which are declared later in &GAP; packages.)
##  Undeclared user preferences are ignored by <Ref Func="WriteGapIniFile"/>,
##  and are mentioned only briefly in the overview shown by
##  <Ref Func="ShowUserPreferences"/>.
##  <P/>
##  Note that the <Ref Func="SetUserPreference"/> calls in the <F>gap.ini</F>
##  file can set only values which are avaliable at the time when the
##  <F>gap.ini</F> is read.
##  Integers, strings, and lists of them are admissible,
##  but more involved objects may not be available.
##  In such a situation, the <Ref Func="SetUserPreference"/> call should be
##  placed in the <F>gaprc</F> file,
##  see&nbsp;<Ref Sect="sect:gap.ini"/> for details.
##  For example, the user preference <C>"UseColorPrompt"</C> admits a record
##  as its value whose components are available only after the
##  <Package>GAPDoc</Package> package has been loaded,
##  see&nbsp;<Ref Func="ColorPrompt"/>.
##  <P/>
##  The argument <A>record</A> of <Ref Func="DeclareUserPreference"/> must be
##  a record with the following components.
##  <P/>
##  <List>
##  <Mark><C>name</C></Mark>
##  <Item>
##    a string or a list of strings, the latter meaning several preferences
##    which belong together,
##  </Item>
##  <Mark><C>description</C></Mark>
##  <Item>
##    a list of strings describing the preference(s), one string for each
##    paragraph;
##    if several preferences are declared together then the description
##    refers to all of them,
##  </Item>
##  <Mark><C>default</C></Mark>
##  <Item>
##    the default value that is used,
##    or a function without arguments that computes this default value;
##    if several preferences are declared together then the value of this
##    component must be the list of default values for the individual
##    preferences.
##  </Item>
##  </List>
##  <P/>
##  The following components of <A>record</A> are optional.
##  <P/>
##  <List>
##  <Mark><C>check</C></Mark>
##  <Item>
##    a function that takes a value as its argument and returns either
##    <K>true</K> or <K>false</K>, depending on whether the given value
##    is admissible for this preference;
##    if several preferences are declared together then the number of
##    arguments of the function must equal the length of the <C>name</C>
##    list,
##  </Item>
##  <Mark><C>values</C></Mark>
##  <Item>
##    the list of admissible values, or a function without arguments
##    that returns this list,
##  </Item>
##  <Mark><C>multi</C></Mark>
##  <Item>
##    <K>true</K> or <K>false</K>, depending on whether one may choose
##    several values from the given list or just one;
##    needed (and useful only) if the <C>values</C> component is present,
##  </Item>
##  <Mark><C>package</C></Mark>
##  <Item>
##    the name of the &GAP; package to which the preference is assigned;
##    if the declaration happens inside a file that belongs to this package
##    then the value of this component is computed,
##    using <C>GAPInfo.PackageCurrent</C>;
##    otherwise, the default value for <C>package</C> is <C>"GAP"</C>,
##  </Item>
##  <Mark><C>omitFromGapIniFile</C></Mark>
##  <Item>
##    if the value is <K>true</K> then this user preference is ignored by
##    <Ref Func="WriteGapIniFile"/>.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> UserPreference( "MyFavouritePrime" );
##  fail
##  gap> DeclareUserPreference( rec(
##  >        name:= "MyFavouritePrime",
##  >        description:= [ "is not used, serves as an example" ],
##  >        default:= 2,
##  >        omitFromGapIniFile:= true ) );
##  gap> UserPreference( "MyFavouritePrime" );
##  2
##  gap> SetUserPreference( "MyFavouritePrime", 17 );
##  gap> UserPreference( "MyFavouritePrime" );
##  17
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
#T Concerning the `values' lists in the declaration:
#T - What shall happen if several preferences are declared together?
#T   It may be that the admissible choices for the second preference depend
#T   on the choice(s) for the first one.
#T - Support also an ``extendible menu'', i. e. a list of choices plus the
#T   possibility to enter a value not in the list.
##
GAPInfo.DeclarationsOfUserPreferences:= [];

GAPInfo.UserPreferences:= rec();

DeclareUserPreference:= function( record )
    local name, package, default, i, up;

    if not IsRecord( record ) then
      Error( "<record> must be a record" );
    fi;

    # Check the mandatory components.
    for name in [ "name", "description", "default" ] do
      if not IsBound( record.( name ) ) then
        Error( "<record>.", name, " must be be bound" );
      fi;
    od;
    if not ( IsString( record.name ) or
             ( IsList( record.name ) and ForAll( record.name, IsString ) ) ) then
      Error( "<record>.name must be a string or a list of strings" );
    elif not ( IsList( record.description ) and
               ForAll( record.description, IsString ) ) then
      Error( "<record>.description must be a list of strings" );
    elif ForAll( record.name, IsString ) and
         not IsFunction( record.default ) and
         not ( IsList( record.default ) and
               Length( record.default ) = Length( record.name ) ) then
      Error( "<record>.default must correspond to record.name" );
    fi;

    # Check the optional components.
    if IsBound( record.check ) and not IsFunction( record.check ) then
      Error( "<record>.check, if bound, must be a function" );
    fi;
    if IsBound( record.values ) then
      if not ( IsList( record.values ) or IsFunction( record.values ) ) then
        Error( "<record>.values, if bound, must be a list or a function" );
      fi;
      if not ( IsBound( record.multi ) and
               record.multi in [ true, false ] ) then
        Error( "<record>.multi must be `true' or `false' ",
               "if record.values is bound" );
      fi;
    fi;
    if IsBound( record.package ) then
      if not IsString( record.package ) then
        Error( "<record>.package, if bound, must be a string" );
      fi;
      package:= LowercaseString( record.package );
    elif IsBound( GAPInfo.PackageCurrent ) then
      package:= LowercaseString( GAPInfo.PackageCurrent.PackageName );
    else
      package:= "gap";
    fi;

    # Accept the new preference declaration.
    record:= ShallowCopy( record );
    record.package:= package;
    record.omitFromGapIniFile:= IsBound( record.omitFromGapIniFile )
                                and record.omitFromGapIniFile = true;
    Add( GAPInfo.DeclarationsOfUserPreferences, record );

    # Set the default value, if not yet set.
    if IsFunction( record.default ) then
      default:= record.default();
      if not IsString( record.name ) and
         ( not IsList( default ) or
           Length( default ) <> Length( record.name ) ) then
        Error( "incompatible default values for preferences ",
               String( record.name ) );
      fi;
    else
      default:= StructuralCopy( record.default );
    fi;
    up := GAPInfo.UserPreferences;
    if not IsBound( up.( package ) ) then
      up.( package ):= rec();
    fi;
    if IsString( record.name ) then
      if not IsBound(up.( package ).( record.name )) then
        up.( package ).( record.name ):= default;
      fi;
    else
      for i in [ 1 .. Length( record.name ) ] do
        if not IsBound(up.( package ).( record.name[i] )) then
          up.( package ).( record.name[i] ):= default[i];
        fi;
      od;
    fi;
end;


#############################################################################
##
#F  SetUserPreference( [<package>, ]<name>, <value> )
##
BindGlobal( "SetUserPreference", function( arg )
    local name, package, value, pref;

    if   Length( arg ) = 2 then
      name:= arg[1];
      package:= "gap";
      value:= arg[2];
    elif Length( arg ) = 3 then
      package:= LowercaseString( arg[1] );
      name:= arg[2];
      value:= arg[3];
    else
      Error( "usage: SetUserPreference( [<package>, ]<name>, <value> )" );
    fi;

    pref:= GAPInfo.UserPreferences;
    if not IsBound( pref.( package ) ) then
      # We may set a preference now that will become declared later.
      pref.( package ):= rec();;
    fi;
    pref:= pref.( package );
#T First check whether the desired value is admissible?
    pref.( name ):= value;
    end );


#############################################################################
##
#F  UserPreference( [<package>, ]<name> )
##
BindGlobal( "UserPreference", function( arg )
    local name, package, pref;

    if   Length( arg ) = 1 then
      name:= arg[1];
      package:= "gap";
    elif Length( arg ) = 2 then
      package:= LowercaseString( arg[1] );
      name:= arg[2];
    else
      Error( "usage: UserPreference( [<package>, ]<name> )" );
    fi;

    pref:= GAPInfo.UserPreferences;
    if not IsBound( pref.( package ) ) then
      # Here we assume that `fail' cannot be the value of a user preference.
      return fail;
    fi;
    pref:= pref.( package );
    if not IsBound( pref.( name ) ) then
      # Here we assume that `fail' cannot be the value of a user preference.
      return fail;
    fi;

    return pref.( name );
    end );


#############################################################################
##
#F  DataOfUserPreference( <pkgname>, <name> )
##
##  returns a record with the components
##  `description'
##  `values'
##      list of the form `[ <pkgname>, <name>, <value>, <default>, <fun> ]'
##
DataOfUserPreference:= function( pkgname, name )
    local pref, decl, result, default, fun, i, nami;

    pref:= GAPInfo.UserPreferences;
    if not IsBound( pref.( pkgname ) ) then
      return fail;
    fi;
    pref:= pref.( pkgname );
    if not IsBound( pref.( name ) ) then
      return fail;
    fi;

    # Check whether this preference has been declared.
    decl:= First( GAPInfo.DeclarationsOfUserPreferences,
                  r -> r.package = pkgname and
                       ( name = r.name or name in r.name ) );

    if decl = fail then
      # undeclared preference (just one)
      result:= rec(
           undeclared := true,
           description:= [ Concatenation( "undeclared user preference '",
                               name, "'" ) ],
           names:= [ name ],
           values:= [ [ pkgname, name, pref.( name ), fail, false ] ] );
      if pkgname <> "gap" then
        Append( result.description[1],
                Concatenation( " for package '", pkgname, "'" ) );
      fi;
    else
      # declared preference (perhaps several together)
      result:= rec( description:= decl.description,
                    omitFromGapIniFile:= decl.omitFromGapIniFile );

      default:= decl.default;
      fun:= false;
      if IsFunction( default ) then
        fun:= true;
        default:= default();
      fi;

      if decl.name = name then
        # just one value
        result.values:= [ [ pkgname, name, pref.( name ), default, fun ] ];
        result.names:= [ name ];
      else
        # several values together
        result.values:= [];
        result.names:= decl.name;
        for i in [ 1 .. Length( decl.name ) ] do
          nami:= decl.name[i];
          result.values[i]:= [ pkgname, nami, pref.( nami ), default[i], fun ];
        od;
      fi;

    fi;

    return result;
    end;


#############################################################################
##
#F  StringUserPreference( <data>, <ignorecurrent> )
##
StringUserPreference:= function( data, ignorecurrent )
    local string, width, format, paragraph, line;

    if data = fail then
      return "";
    fi;

    string:= [];
    width:= SizeScreen()[1] - 6;
    format:= ValueGlobal( "FormatParagraph" );
    for paragraph in data.description do
      Append( string, format( paragraph, width, "left", [ "##  ", "" ] ) );
    # Append( string, "##  " );
    # Append( string, line );
    # Append( string, "\n" );
    od;
    for line in data.values do
      if ignorecurrent then
        # set current value (line[3]) to default value (line[4])
        line := ShallowCopy(line);
        line[3] := line[4];
      fi;
      if line[3] = line[4] then
        Append( string, "# " );
      fi;
      Append( string, "SetUserPreference( \"" );
      if line[1] <> "gap" then
        Append( string, line[1] );
        Append( string, "\", \"" );
      fi;
      Append( string, line[2] );
      Append( string, "\", " );
      if IsStringRep( line[3] ) then
        Append( string, "\"" );
        Append( string, line[3] );
        Append( string, "\"" );
      else
        Append( string, String( line[3] ) );
      fi;
      Append( string, " );\n" );
    od;

    return string;
    end;


#############################################################################
##
#F  ShowStringUserPreference( <data> )
##
ShowStringUserPreference:= function( data )
    local string, width, format, line, paragraph, suff;

    if data = fail then
      return "";
    fi;

    # Show the name(s), with indent 2.
    string:= [];
    width:= SizeScreen()[1] - 6;
    Append( string, "  " );
    for line in data.values do
      Append( string, line[2] );
      Append( string, ", " );
    od;
    string[ Length( string ) - 1 ]:= ':';
    string[ Length( string ) ]:= '\n';

    # Show the formatted description, with indent 4.
    format:= ValueGlobal( "FormatParagraph" );
    for paragraph in data.description do
      Append( string, format( paragraph, width, "left", [ "    ", "" ] ) );
    od;

    # Show the default value(s), with indent 6.
    if Length( data.values ) = 1 then
      suff:= "";
    else
      suff:= "s";
    fi;
    Append( string, "\n    default" );
    Append( string, suff );
    if data.values[1][5] then
      Append( string, " (computed at runtime)" );
    fi;
    Append( string, ":\n" );
    for line in data.values do
      Append( string, "      " );
      if IsStringRep( line[4] ) then
        Append( string, "\"" );
        Append( string, line[4] );
        Append( string, "\"" );
      else
        Append( string, String( line[4] ) );
      fi;
      Append( string, "\n" );
    od;

    # Show the current value(s), with indent 6.
    Append( string, "\n    current value" );
    Append( string, suff );
    Append( string, ":\n" );
    if ForAll( data.values, line -> line[3] = line[4] ) then
      Append( string, "      equal to the default" );
      Append( string, suff );
      Append( string, "\n" );
    else
      for line in data.values do
        Append( string, "      " );
        if IsStringRep( line[3] ) then
          Append( string, "\"" );
          Append( string, line[3] );
          Append( string, "\"" );
        else
          Append( string, String( line[3] ) );
        fi;
        Append( string, "\n" );
      od;
    fi;

    return string;
    end;


#############################################################################
##
#F  StringUserPreferences( arg )
##
StringUserPreferences:= function( arg )
    local ignorecurrent, pref, str, pkglist, pkgname, done, name, data;
    
    if Length(arg) > 0 and arg[1] = true then
      ignorecurrent := true;
    else
      ignorecurrent := false;
    fi;

    pref:= GAPInfo.UserPreferences;
    str:= "";

    # Run over the preferences, first the ones that belong to GAP,
    # then the ones that belong to packages
    pkglist := Concatenation(["gap"], Difference(RecNames( pref ), ["gap"] ));
## HACKUSERPREF  temporary until all packages are adjusted
    pkglist := Filtered(pkglist, a-> not a in ["Pager","ReadObsolete"]);
    for pkgname in pkglist do
      Append( str, ListWithIdenticalEntries( 77, '#' ) );
      Append( str, "\n\n" );
      done:= [];
      if IsRecord( pref.( pkgname ) ) then
        for name in Set( RecNames( pref.( pkgname ) ) ) do
          if not name in done then
            data:= DataOfUserPreference( pkgname, name );
            if not IsBound( data.undeclared ) and
               not data.omitFromGapIniFile then
              Append( str, StringUserPreference( data, ignorecurrent ) );
              Append( str, "\n" );
            fi;
            UniteSet( done, data.names );
          fi;
        od;
      fi;
    od;

    return str;
    end;


#############################################################################
##
#F  ShowUserPreferences( arg )
##
##  show the list of all declared user preferences
##
ShowUserPreferences:= function(arg)
    local pkglist, pref, str, pkgname, nam, done, undec, name, data, i, pfun;

    pref:= GAPInfo.UserPreferences;
    if Length(arg) > 0 then
      pkglist := List(arg, LowercaseString);
    else
      # if no list given use all  packages with preferences, "gap" first
      pkglist := Concatenation(  [ "gap" ], 
                       Difference( RecNames( pref ), [ "gap" ] ) );
    fi;

## HACKUSERPREF  temporary until all packages are adjusted
    pkglist := Filtered(pkglist, a-> not a in ["Pager","ReadObsolete"]);

    str:= "";
    for pkgname in pkglist do
      Append( str, "\n" );
      Append( str, "User preferences defined by " );
      if IsBound(GAPInfo.PackagesInfo.(pkgname)) then
        nam := GAPInfo.PackagesInfo.(pkgname)[1].PackageName;
      elif pkgname = "gap" then
        nam := "GAP";
      else 
        nam := pkgname;
      fi;
      Append( str, nam );
      Append( str, ":\n\n" );
      done:= [];
      undec := [];
      if IsRecord( pref.( pkgname ) ) then
        for name in Set( RecNames( pref.( pkgname ) ) ) do
          if not name in done then
            data:= DataOfUserPreference( pkgname, name );
            if not IsBound(data.undeclared) then
              Append( str, ShowStringUserPreference( data ) );
              Append( str, "\n" );
              UniteSet( done, data.names );
            else
              Add(undec, name);
            fi;
          fi;
        od;
      fi;
      if Length(undec) > 0 then
        Append(str, "Undeclared preferences: ");
        Append(str, undec[1]);
        for i in [2..Length(undec)] do
          Append(str, ", ");
          Append(str, undec[i]);
        od;
      fi;

      Append( str, "\n" );
    od;

    pfun := ValueGlobal("Pager");
    pfun(rec( lines := str, formatted := true));
    end;


#############################################################################
##
#F  WriteGapIniFile( [<dir>, ][true] )
##
WriteGapIniFile:= function( arg )
  local ignorecurrent, f, df, ret, target, str, res;
  # check if current settings should be used
  if true in arg then 
    ignorecurrent := true;
  else 
    ignorecurrent := false;
  fi;
  # check if target directory is given as string or directory object
  f := First(arg, IsString);
  if f <> fail then
    df := Directory(f);
  else
    df := First(arg, IsDirectory);
    if df <> fail then
      f := df![1];
    fi;
  fi;
  # otherwise use users GAPInfo.UserGapRoot
  if f = fail then
    if GAPInfo.UserGapRoot = fail then
      Error("Your system does not support a user specific default root path.\n\
Please specify directory to write gap.ini file.");
      return fail;
    else
      f := GAPInfo.UserGapRoot;
      df := Directory(f);
    fi;
  fi;
  # maybe create GAPInfo.UserGapRoot
  if not IsDirectoryPath(f) then
    ret := CreateDir(f);
    if ret = fail then
      Error("Cannot create directory ",f,"\nError message: ",
            LastSystemError().message,"\n");
      return fail;
    fi;
  fi;
  # name of target file
  target := Filename(df, "gap.ini");
  # if target exists copy it to <target>.bak
  if IsExistingFile(target) then
    str := StringFile(target);
    if str = fail then
      Error("Cannot read existing file ",target,".\n");
      return fail;
    fi;
    ret := FileString(Concatenation(target, ".bak"), str);
    if ret = fail then
      Error("Cannot write backup file ",target,".bak.\nError message: ",
            LastSystemError().message,".\n");
      return fail;
    else
      Info(InfoWarning, 1, "Copied existing gap.ini to ", target, ".bak");
    fi;
  fi;
  # content of resulting file as string
  res := StringUserPreferences(ignorecurrent);
  if ARCH_IS_WINDOWS() then
    # use DOS/Windows style line breaks
    res := ReplacedString(res, "\n", "\r\n");
  fi;
  # finally write the gap.ini file
  ret := FileString(target, res);
  if ret = fail then
    Error("Cannot write target file ",target,".\nError message: ",
          LastSystemError().message,".\n");
    return fail;
  fi;
  Info(InfoWarning, 1, "File ", target, " successfully written.");
  return true;
end;


#############################################################################
##
#E

