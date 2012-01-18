#############################################################################
##
##
#W  files.gd                   Example Package                  Werner Nickel
##
##  Declaration file for functions of the Example package.
##
#Y  Copyright (C) 1999,2001 University of St. Andrews, North Haugh,
#Y                          St. Andrews, Fife KY16 9SS, Scotland
##

#############################################################################
##
#F  EgSeparatedString( <str>, <c> ) . . . . . . . .  cut a string into pieces
##
DeclareGlobalFunction( "EgSeparatedString" );

#############################################################################
##
#F  ListDirectory([<dir>])  . . . . . . . . . . list the files in a directory
##
##  <#GAPDoc Label="ListDirectory">
##  <ManSection>
##  <Func Name="ListDirectory" Arg="[dir]"/>
##
##  <Description>
##  lists the files in directory <A>dir</A> (a string) 
##  or the current directory if called with no arguments.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ListDirectory" );

#############################################################################
##
#F  FindFile( <dir>, <file> ) . . . . . . . . find a file in a directory tree
##
##  <#GAPDoc Label="FindFile">
##  <ManSection>
##  <Func Name="FindFile" Arg="directory_name, file_name"/>
##  
##  <Description>
##  searches  for the  file   <A>file_name</A> in  the  directory  tree  
##  rooted at <A>directory_name</A> and returns the absolute path names 
##  of all occurrences of this file as a list of strings.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "FindFile" );

#############################################################################
##
#F  LoadedPackages() . . . . . . . . . . . . which share packages are loaded?
##
##  <#GAPDoc Label="LoadedPackages">
##  <ManSection>
##  <Func Name="LoadedPackages" Arg=""/>
##  
##  <Description>
##  returns a list with the names of the packages that have  been  loaded  so
##  far. All this does is execute
##  
##  <Example><![CDATA[
##  gap> RecNames( GAPInfo.PackagesLoaded );
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "LoadedPackages" );

#############################################################################
##
#F  Which( <prg> )  . . . . . . . . . . . . which program would Exec execute?
##
##  <#GAPDoc Label="Which">
##  <ManSection>
##  <Func Name="Which" Arg="prg"/>
##  
##  <Description>
##  returns the path of the program executed if 
##  <C>Exec(<A>prg</A>);</C> is called, e.g.
##  <Example><![CDATA[
##  gap> Which("date");         
##  "/bin/date"
##  gap> Exec("date");
##  Fri 28 Jan 2011 16:22:53 GMT
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "Which" );

#############################################################################
##
#F  WhereIsPkgProgram( <prg> ) . . . . the paths of any matching pkg programs
##
##  <#GAPDoc Label="WhereIsPkgProgram">
##  <ManSection>
##  <Func Name="WhereIsPkgProgram" Arg="prg"/>
##  
##  <Description>
##  returns a list of paths of programs with name <A>prg</A> in the current
##  packages loaded. Try:
##  <Example><![CDATA[
##  gap> WhereIsPkgProgram( "hello" );
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "WhereIsPkgProgram" );

#############################################################################
##
#F  HelloWorld() . . . . . . . . . . . . . . . . . . . . . . . . . . . guess!
##
##  <#GAPDoc Label="HelloWorld">
##  <ManSection>
##  <Func Name="HelloWorld" Arg=""/>
##  
##  <Description>
##  executes the C program <C>hello</C> provided by the &Example; package.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "HelloWorld" );

#############################################################################
##
#V  FruitCake . . . . . . . . . . . . . things one needs to make a fruit cake
##
##  <#GAPDoc Label="FruitCake">
##  <ManSection>
##  <Var Name="FruitCake"/>
##  
##  <Description>
##  is a record with the bits and pieces needed to make a boiled fruit cake.
##  Its fields satisfy the criteria for <Ref Func="Recipe"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalVariable( "FruitCake",
   "record with the bits and pieces needed to make a boiled fruit cake");

#############################################################################
##
#O  Recipe( <cake> ) . . . . . . . . . . . . . . . . . . . . display a recipe
##
##  <#GAPDoc Label="Recipe">
##  <ManSection>
##  <Oper Name="Recipe" Arg="cake"/>
##  
##  <Description>
##  displays the recipe for cooking <A>cake</A>, where <A>cake</A> is a 
##  record satisfying certain criteria explained here: its recognised 
##  fields are <C>name</C> (a string giving the type of cake or cooked  
##  item), <C>ovenTemp</C> (a string), <C>cookingTime</C> (a string), 
##  <C>ingredients</C> (a list of strings each containing an <C>_</C> 
##  which is used  to line up the entries and is replaced by a  blank),  
##  <C>method</C>  (a  list  of steps, each of which is a string or list 
##  of strings), and <C>notes</C> (a list of strings). The global variable
##  <Ref Var="FruitCake"/> provides an example of such a string.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "Recipe", [ IsRecord ] );

#E  files.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
