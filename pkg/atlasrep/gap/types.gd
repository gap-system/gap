#############################################################################
##
#W  types.gd             GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains declarations of the functions for administrating
##  the data types used in the &ATLAS; of Group Representations.
##


#############################################################################
##
#F  AGR.DeclareDataType( <kind>, <name>, <record> )
##
##  <#GAPDoc Label="AGRDeclareDataType">
##  <ManSection>
##  <Func Name="AGR.DeclareDataType" Arg='kind, name, record'/>
##
##  <Description>
##  Let <A>kind</A> be one of the strings <C>"rep"</C> or <C>"prg"</C>,
##  and <A>record</A> be a record.
##  <Ref Func="AGR.DeclareDataType"/> declares a new data type of
##  representations (if <A>kind</A> is <C>"rep"</C>) or of
##  programs (if <A>kind</A> is <C>"prg"</C>).
##  For each group used in the <Package>AtlasRep</Package> package,
##  the record that contains the information about the data will have
##  a component <A>name</A> whose value is a list
##  containing the data about the new type.
##  Examples of <A>name</A> are <C>"perm"</C>, <C>"matff"</C>,
##  and <C>"classes"</C>.
##  <P/>
##  <E>Mandatory components</E> of <A>record</A> are
##  <P/>
##  <List>
##  <Mark><C>FilenameFormat</C></Mark>
##  <Item>
##    This defines the format of the filenames containing data of the type
##    in question.
##    The value must be a list that can be used as the second argument of
##    <Ref Func="AGR.ParseFilenameFormat"/>,
##    such that only filenames of the type in question match.
##    (It is not checked whether this <Q>detection function</Q> matches
##    exactly one type, so declaring a new type needs care.)
##  </Item>
##  <Mark><C>AddFileInfo</C></Mark>
##  <Item>
##    This defines the information stored in the table of contents for the
##    data of the type.
##    The value must be a function that takes three arguments (the current
##    list of data for the type and the given group, a list returned
##    by <Ref Func="AGR.ParseFilenameFormat"/> for the given type,
##    and a filename).
##    This function adds the necessary parts of the data entry to the list,
##    and returns <K>true</K> if the data belongs to the type,
##    otherwise <K>false</K> is returned;
##    note that the latter case occurs if the filename matches the format
##    description but additional conditions on the parts of the name are
##    not satisfied (for example integer parts may be required to be
##    positive or prime powers).
##  </Item>
##  <Mark><C>ReadAndInterpretDefault</C></Mark>
##  <Item>
##    This is the function that does the work for the default
##    <C>contents</C> value of the <C>accessFunctions</C> component of
##    <Ref Var="AtlasOfGroupRepresentationsInfo"/>, see
##    Section&nbsp;<Ref Sect="sect:How to Customize the Access to Data files"/>.
##    This function must take a path and return the &GAP; object given by
##    this file.
##  </Item>
##  <Mark><C>AddDescribingComponents</C> (for <C>rep</C> only)</Mark>
##  <Item>
##    This function takes two arguments, a record (that will be returned by
##    <Ref Func="AtlasGenerators"/>, <Ref Func="OneAtlasGeneratingSetInfo"/>,
##    or <Ref Func="AllAtlasGeneratingSetInfos"/>) and the type record
##    <A>record</A>.
##    It sets the components <C>p</C>, <C>dim</C>, <C>id</C>, and <C>ring</C>
##    that are promised for return values of the abovementioned three
##    functions.
##  </Item>
##  <Mark><C>DisplayGroup</C> (for <C>rep</C> only)</Mark>
##  <Item>
##    This defines the format of the lines printed by
##    <Ref Func="DisplayAtlasInfo"/> for a given group.
##    The value must be a function that takes a list as returned by the
##    function given in the component <C>AddFileInfo</C>, and returns the
##    string to be printed for the representation in question.
##  </Item>
##  </List>
##  <P/>
##  <E>Optional components</E> of <A>record</A> are
##  <P/>
##  <List>
##  <Mark><C>DisplayOverviewInfo</C></Mark>
##  <Item>
##    This is used to introduce a new column in the output of
##    <Ref Func="DisplayAtlasInfo"/> when this is called
##    without arguments or with a list of group names as its only argument.
##    The value must be a list of length three, containing at its first
##    position a string used as the header of the column, at its second
##    position one of the strings <C>"r"</C> or <C>"l"</C>,
##    denoting right or left aligned column entries,
##    and at its third position a function that takes two arguments
##    (a list of tables of contents of the <Package>AtlasRep</Package>
##    package and a group name), and returns a list of length two,
##    containing the string to be printed as the column value and
##    <K>true</K> or <K>false</K>,
##    depending on whether private data is involved or not.
##    (The default is <K>fail</K>,
##    indicating that no new column shall be printed.)
##  </Item>
##  <Mark><C>DisplayPRG</C> (for <C>prg</C> only)</Mark>
##  <Item>
##    This is used in <Ref Func="DisplayAtlasInfo"/> for &ATLAS; programs.
##    The value must be a function that takes four arguments (a list of
##    tables of contents to examine, the name of the given group,
##    a list of integers or <K>true</K> for the required standardization,
##    and a list of all available standardizations), and returns the list
##    of lines (strings) to be printed as the information about the
##    available programs of the current type and for the given group.
##    (The default is to return an empty list.)
##  </Item>
##  <Mark><C>AccessGroupCondition</C> (for <C>rep</C> only)</Mark>
##  <Item>
##    This is used in <Ref Func="DisplayAtlasInfo"/> and
##    <Ref Func="OneAtlasGeneratingSetInfo"/>.
##    The value must be a function that takes two arguments
##    (a list as returned by <Ref Func="OneAtlasGeneratingSetInfo"/>,
##    and a list of conditions),
##    and returns <K>true</K> or <K>false</K>, depending on whether the
##    first argument satisfies the conditions.
##    (The default value is <Ref Func="ReturnFalse" BookName="ref"/>.)
##    <P/>
##    The function must support conditions such as
##    <C>[ IsPermGroup, true ]</C> and <C>[ NrMovedPoints, [ 5, 6 ] ]</C>,
##    in general a list of functions followed by a prescribed value,
##    a list of prescribed values, another (unary) function,
##    or the string <C>"minimal"</C>.
##    For an overview of the interesting functions,
##    see&nbsp;<Ref Func="DisplayAtlasInfo"/>.
##  </Item>
##  <Mark><C>AccessPRG</C> (for <C>prg</C> only)</Mark>
##  <Item>
##    This is used in <Ref Func="AtlasProgram"/>.
##    The value must be a function that takes three arguments (the record
##    with the information about the given group in the current table of
##    contents, an integer or a list of integers or <K>true</K> for the
##    required standardization, and a list of conditions given by the
##    optional arguments of <Ref Func="AtlasProgram"/>),
##    and returns either <K>fail</K> or a list that together with the group
##    name forms the identifier of a program that matches the
##    conditions.
##    (The default value is <Ref Func="ReturnFail" BookName="ref"/>.)
##  </Item>
##  <Mark><C>AtlasProgram</C> (for <C>prg</C> only)</Mark>
##  <Item>
##    This is used in <Ref Func="AtlasProgram"/> to create the
##    result value from the identifier.
##    (The default value is <C>AtlasProgramDefault</C>, which
##    works whenever the second entry of the identifier is the filename;
##    this is not the case for example if the program is the composition of
##    several programs.)
##  </Item>
##  <Mark><C>AtlasProgramInfo</C> (for <C>prg</C> only)</Mark>
##  <Item>
##    This is used in <Ref Func="AtlasProgramInfo"/> to create the
##    result value from the identifier.
##    (The default value is <C>AtlasProgramDefault</C>.)
##  </Item>
##  <Mark><C>TOCEntryString</C></Mark>
##  <Item>
##    This is used in <Ref Func="StoreAtlasTableOfContents"/>.
##    The value must be a function that takes two arguments
##    (the name <A>name</A> of the type and a list as returned by
##    <Ref Func="AGR.ParseFilenameFormat"/>
##    and returns a string that describes the appropriate function call.
##    (The default value is <C>TOCEntryStringDefault</C>.)
##  </Item>
##  <Mark><C>PostprocessFileInfo</C></Mark>
##  <Item>
##    This is used in the construction of a table of contents via
##    <Ref Func="ReloadAtlasTableOfContents"/>,
##    for testing or rearranging the data of the current table of contents.
##    The value must be a function that takes two arguments,
##    the table of contents record and the record in it that belongs to
##    one fixed group.
##    (The default function does nothing.)
##  </Item>
##  <Mark><C>SortTOCEntries</C></Mark>
##  <Item>
##    This is used in the construction of a table of contents
##    (see <Ref Func="ReloadAtlasTableOfContents"/>),
##    for sorting the entries after they have been added and after the
##    value of the component <C>PostprocessFileInfo</C> has been called.
##    The value must be a function that takes a list as returned by
##    <Ref Func="AGR.ParseFilenameFormat"/>,
##    and returns the sorting key.
##    (There is no default value, which means that no sorting is needed.)
##  </Item>
##  <Mark><C>TestFileHeaders</C> (for <C>rep</C> only)</Mark>
##  <Item>
##    This is used in the function <C>AGR.Test.FileHeaders</C>.
##    The value must be a function that takes the same four arguments as
##    <Ref Func="AGR.FileContents"/>,
##    except that the first argument <C>"datagens"</C> can be replaced by
##    <C>"local"</C> and that the third argument is a list as returned by
##    <Ref Func="AGR.ParseFilenameFormat"/>.
##    (The default value is <Ref Func="ReturnTrue" BookName="ref"/>.)
##  </Item>
##  <Mark><C>TestFiles</C> (for <C>rep</C> only)</Mark>
##  <Item>
##    This is used in the function <C>AGR.Test.Files</C>.
##    The format of the value and the default are the same as for
##    the value of the component <C>TestFileHeaders</C>.
##  </Item>
##  <Mark><C>TestWords</C> (for <C>prg</C> only)</Mark>
##  <Item>
##    This is used in the function <C>AGR.Test.Words</C>.
##    The value must be a function that takes five arguments where the first
##    four are the same arguments as for <Ref Func="AGR.FileContents"/>,
##    except that the first argument <C>"dataword"</C> can be replaced by
##    <C>"local"</C>,
##    and the fifth argument is <K>true</K> or <K>false</K>,
##    indicating verbose mode or not.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#V  AtlasOfGroupRepresentationsInfo
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsInfo">
##  <ManSection>
##  <Var Name="AtlasOfGroupRepresentationsInfo"/>
##
##  <Description>
##  This is a record that is defined in the file <F>gap/types.g</F> of the
##  package, with the following components.
##  <P/>
##  Components corresponding to <E>user parameters</E> (see
##  Section&nbsp;<Ref Sect="sect:User Parameters for the AtlasRep Package"/>)
##  are
##  <P/>
##  <List>
##  <Mark><C>remote</C></Mark>
##  <Item>
##    a boolean that controls what files are available;
##    if the value is <K>true</K> then &GAP; is allowed to try remotely
##    accessing any &ATLAS; file from the servers (see below) and thus all
##    files listed in the global table of contents are available,
##    if the value is <K>false</K> then &GAP; may access
##    only those files that are stored in the database directories of the
##    local &GAP; installation
##    (see Section&nbsp;<Ref Subsect="subsect:Local or remote access"/>),
##  </Item>
##  <Mark><C>servers</C></Mark>
##  <Item>
##    a list of pairs <C>[ </C><A>server</A><C>, </C><A>path</A><C> ]</C>,
##    where <A>server</A> is a string denoting the <F>http</F> address of
##    a server where files can be fetched that are not stored in the local
##    database,
##    and <A>path</A> is a string describing the path
##    where the data directories on the server reside,
##  </Item>
##  <Mark><C>wget</C></Mark>
##  <Item>
##    controls whether the &GAP; package
##    <Package>IO</Package><Index>IO package</Index> <Cite Key="IO"/>
##    or the external program
##    <F>wget</F><Index Key="wget"><F>wget</F></Index>
##    is used to fetch data files,
##    see&nbsp;<Ref Subsect="subsect:Accessing data files with wget or IO"/>,
##  </Item>
##  <Mark><C>compress</C></Mark>
##  <Item>
##    <Index Key="gzip"><F>gzip</F></Index>
##    a boolean that controls whether &MeatAxe; format text files are stored
##    in compressed form;
##    if the value is <K>true</K> then these files are compressed with
##    <F>gzip</F> after they have been fetched from a server, see
##    Section&nbsp;<Ref Subsect="subsect:Compressed or uncompressed data files"/>,
##  </Item>
##  <Mark><C>displayFunction</C></Mark>
##  <Item>
##    the function that is used by <Ref Func="DisplayAtlasInfo"/> for
##    printing the formatted data,
##    see Section&nbsp;<Ref Subsect="subsect:Customizing DisplayAtlasInfo"/>,
##  </Item>
##  <Mark><C>accessFunctions</C></Mark>
##  <Item>
##    a list of records, each describing how to access the data files, see
##    Sections <Ref Subsect="subsect:Customizing the Access to Data files"/>
##    and <Ref Sect="sect:How to Customize the Access to Data files"/>,
##    and
##  </Item>
##  <Mark><C>markprivate</C></Mark>
##  <Item>
##    a string used in <Ref Func="DisplayAtlasInfo"/> to mark private data,
##    see Section&nbsp; <Ref Sect="sect:Effect of Private Extensions"/>.
##  </Item>
##  </List>
##
##  <P/>
##
##  <E>System components</E> (which are computed automatically) are
##  <P/>
##  <List>
##  <Mark><C>GAPnames</C></Mark>
##  <Item>
##    a list of pairs, each containing the &GAP; name and the
##    &ATLAS;-file name of a group, see
##    Section&nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>,
##  </Item>
##  <Mark><C>groupnames</C></Mark>
##  <Item>
##    a list of triples, each containing at the first position the name of
##    the directory on each server that contains data about the group
##    <M>G</M> in question,
##    at the second position the name of the (usually simple) group for
##    which a subdirectory exists that contains the data about <M>G</M>,
##    and at the third position the &ATLAS;-file name used for <M>G</M>,
##    see Section&nbsp;<Ref Sect="sect:Filenames Used in the AGR"/>,
##  </Item>
##  <Mark><C>private</C></Mark>
##  <Item>
##    a list of pairs of strings used for administrating private data
##    (see Chapter&nbsp;<Ref Chap="chap:Private Extensions"/>);
##    the value is changed by
##    <Ref Func="AtlasOfGroupRepresentationsNotifyPrivateDirectory"/>
##    and <Ref Func="AtlasOfGroupRepresentationsForgetPrivateDirectory"/>,
##  </Item>
##  <Mark><C>characterinfo</C>, <C>permrepinfo</C>, <C>ringinfo</C></Mark>
##  <Item>
##    additional information about representations,
##    concerning the characters afforded,
##    the point stabilizers of permutation representations, and
##    the ring of definition of matrix representations;
##    this information is used by <Ref Func="DisplayAtlasInfo"/>,
##  </Item>
##  <Mark><C>TableOfContents</C></Mark>
##  <Item>
##    a record with at most the components <C>local</C>, <C>remote</C>,
##    <C>types</C>, and the names of private data directories.
##    The values of the components <C>local</C> and <C>remote</C> can be
##    computed automatically by <Ref Func="ReloadAtlasTableOfContents"/>,
##    the value of the component <C>types</C> is set in
##    <Ref Func="AGR.DeclareDataType"/>,
##    and the values of the components for local data directories are
##    created by
##    <Ref Func="AtlasOfGroupRepresentationsNotifyPrivateDirectory"/>.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We want to delay reading the table of contents until the data are really
##  accessed.
##
DeclareAutoreadableVariables( "atlasrep", "gap/types.g",
    [ "AtlasOfGroupRepresentationsInfo" ] );


#############################################################################
##
#A  Maxes( <tbl> )
##
##  <ManSection>
##  <Attr Name="Maxes" Arg='tbl'/>
##
##  <Description>
##  In some consistency checks, the &GAP; Character Table Library is used.
##  Since the AtlasRep package does not require the table library,
##  we declare the missing variables in order to avoid error messages.
##  </Description>
##  </ManSection>
##
if not IsBound( Maxes ) then
  DeclareAttribute( "Maxes", IsUnknown );
  InstallMethod( Maxes, [ IsUnknown ], Error );
fi;


#############################################################################
##
#E

