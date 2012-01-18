#############################################################################
##
#W  brspor.g             GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2007,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains
##  - a record `BibliographySporadicSimple' containing the customizations for
##    `BrowseBibliography' that are needed for showing the bibliographies in
##    the Atlas of Finite Groups and in the Atlas of Brauer Characters and
##  - a very small Browse application `BrowseBibliographySporadicSimple'
##    for showing these data.
##


#############################################################################
##
##  (Depending on the order of reading package files,
##  `BrowseBibliography' may be not yet bound.
##  Avoid the syntax error message.)
##
if not IsBound( BrowseBibliography ) then
  BrowseBibliography:= "dummy";
fi;


#############################################################################
##
#V  BibliographySporadicSimple
##
DeclareGlobalVariable( "BibliographySporadicSimple" );

InstallValue( BibliographySporadicSimple, rec(
    # auxiliary components
    emptycategory:= "(not assigned to a sporadic simple group)",
    groupnameinfo:= [
      [ "M11", "Mathieu group", "M<sub>11</sub>" ],
      [ "M12", "Mathieu group", "M<sub>12</sub>" ],
      [ "J1", "Janko group", "J<sub>1</sub>" ],
      [ "M22", "Mathieu group", "M<sub>22</sub>" ],
      [ "J2", "Janko group", "J<sub>2</sub>" ],
      [ "M23", "Mathieu group", "M<sub>23</sub>" ],
      [ "HS", "Higman-Sims group", "HS" ],
      [ "J3", "Janko group", "J<sub>3</sub>" ],
      [ "M24", "Mathieu group", "M<sub>24</sub>" ],
      [ "McL", "McLaughlin group", "M<sup>c</sup>L" ],
      [ "He", "Held group", "He" ],
      [ "Ru", "Rudvalis group", "Ru" ],
      [ "Suz", "Suzuki group", "Suz" ],
      [ "ON", "O'Nan group", "O'N" ],
      [ "Co3", "Conway group", "Co<sub>3</sub>" ],
      [ "Co2", "Conway group", "Co<sub>2</sub>" ],
      [ "Fi22", "Fischer group", "Fi<sub>22</sub>" ],
      [ "HN", "Harada-Norton group", "HN" ],
      [ "Ly", "Lyons group", "Ly" ],
      [ "Th", "Thompson group", "Th" ],
      [ "Fi23", "Fischer group", "Fi<sub>23</sub>" ],
      [ "Co1", "Conway group", "Co<sub>1</sub>" ],
      [ "J4", "Janko group", "J<sub>4</sub>" ],
      [ "Fi24'", "Fischer group", "Fi<sub>24</sub><sup>'</sup>" ],
      [ "B", "Baby monster group", "B" ],
      [ "M", "Monster group", "M" ],
    ],
    groupnames:= Concatenation( [ ~.emptycategory ],
                   List( ~.groupnameinfo, x -> x[1] ) ),

    # The following component is used in the manual example for
    # `BrowseMinimalDegrees'.
    groupNamesJan05:= [
      "M11", "M12", "2.M12", "J1", "M22", "2.M22", "3.M22", "4.M22", "6.M22",
      "12.M22", "J2", "2.J2", "M23", "HS", "2.HS", "J3", "3.J3", "M24",
      "McL", "3.McL", "He", "Ru", "2.Ru", "Suz", "2.Suz", "3.Suz", "6.Suz",
      "ON", "3.ON", "Co3", "Co2", "Fi22", "2.Fi22", "3.Fi22", "6.Fi22", "HN",
      "Ly", "Th", "Fi23", "Co1", "2.Co1", "J4", "Fi24'", "3.Fi24'", "B",
      "2.B", "M",
    ],

    # the data components
    filesshort:= [ "Atlas1bib.xml", "Atlas2bib.xml",
                   "ABCapp2bib.xml", "ABCbiblbib.xml" ],
    filecontents:= [ "ATLAS bibliography (p. 243)",
                     "ATLAS bibliography (pp. 244-251)",
                     "ABC appendix", "ABC bibliography" ],
    files:= List( ~.filesshort,
              x -> Filename( DirectoriesPackageLibrary( "atlasrep", "bibl" ),
                             x ) ),
    header:= "Bibliography of Sporadic Simple Groups",
    columns:= [ rec(
      identifier:= "sporsimp",
      viewLabel:= "G",
      type:= "values",
      create:= function( attr, id )
        local rows, r;
        rows:= [];
        for r in id do
          if IsBound( r[1].sporsimp ) and r[1].sporsimp <> ""
                                      and not r[1].sporsimp in rows then
            Add( rows, r[1].sporsimp );
          fi;
        od;
        return rows;
        end,
      viewSort:= function( nam1, nam2 )
        local list;
        # Sort sporadic simple groups according to their order.
        list:= BibliographySporadicSimple.groupnames;
        if nam1 = "Fi24'" then nam1:= "F3+"; fi;
        if nam2 = "Fi24'" then nam2:= "F3+"; fi;
        return Position( list, nam1 ) < Position( list, nam2 );
        end,
      viewValue:= function( x )
        if IsEmpty( x ) then
          return "";
        else
          return rec( rows:= x, align:= "tl" );
        fi;
        end,
      categoryValue:= value -> BrowseData.ReplacedEntry( value,
          [ "" ], [ BibliographySporadicSimple.emptycategory ] ),
      align:= "l",
      sortParameters:= [ "hide on categorizing", "no",
                         "add counter on categorizing", "yes",
                         "split rows on categorizing", "yes" ],
      ) ],
    choice:= [ "authors", "title", "year", "journal", "sporsimp",
               "sourcefilename" ],
    sortKeyFunction:= BrowseData.SortKeyFunctionBibRec,
 ) );


#############################################################################
##
#F  BrowseBibliographySporadicSimple()
##
##  <#GAPDoc Label="BrowseBibliographySporadicSimple">
##  <ManSection>
##  <Func Name="BrowseBibliographySporadicSimple" Arg=''/>
##
##  <Returns>
##  a record as returned by
##  <Ref Func="ParseBibXMLExtString" BookName="gapdoc"/>.
##  </Returns>
##  <Description>
##  If the &GAP; package <Package>Browse</Package> (see <Cite Key="Browse"/>)
##  is loaded then this function is available.
##  It opens a browse table whose rows correspond to the entries of the
##  bibliographies in the &ATLAS; of Finite Groups <Cite Key="CCN85"/>
##  and in the &ATLAS; of Brauer Characters <Cite Key="JLPW95"/>.
##  <P/>
##  The function is based on
##  <Ref Func="BrowseBibliography" BookName="browse"/>,
##  see the documentation of this function for details, e.g., about the
##  return value.
##  <P/>
##  The returned record encodes the bibliography entries corresponding to
##  those rows of the table that are <Q>clicked</Q> in visual mode,
##  in the same format as the return value of
##  <Ref Func="ParseBibXMLExtString" BookName="gapdoc"/>,
##  see the manual of the &GAP; package &GAPDoc; <Cite Key="GAPDoc"/>
##  for details.
##  <P/>
##  <Ref Func="BrowseBibliographySporadicSimple"/> can be called also via
##  the menu shown by <Ref Func="BrowseGapData" BookName="Browse"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> if IsBound( BrowseBibliographySporadicSimple ) then
##  >   enter:= NCurses.keys.ENTER;;  nop:= [ 14, 14, 14 ];;
##  >   BrowseData.SetReplay( Concatenation(
##  >     # choose the application
##  >     "/Bibliography of Sporadic Simple Groups", [ enter, enter ],
##  >     # search in the title column for the Atlas of Finite Groups
##  >     "scr/Atlas of finite groups", [ enter,
##  >     # and quit
##  >     nop, nop, nop, nop ], "Q" ) );
##  >   BrowseGapData();;
##  >   BrowseData.SetReplay( false );
##  > fi;
##  ]]></Example>
##  <P/>
##  The bibliographies contained in the &ATLAS; of Finite Groups
##  <Cite Key="CCN85"/> and in the &ATLAS; of Brauer Characters
##  <Cite Key="JLPW95"/> are available online in HTML format, see
##  <URL>http://www.math.rwth-aachen.de/~Thomas.Breuer/atlasrep/bibl/index.html</URL>.
##  <P/>
##  The source data in BibXMLext format, which are used by
##  <Ref Func="BrowseBibliographySporadicSimple"/>,
##  is part of the <Package>AtlasRep</Package> package,
##  in four files with suffix <F>xml</F> in the package's <F>bibl</F>
##  directory.
##  Note that each of the two books contains two bibliographies.
##  <P/>
##  Details about the BibXMLext format, including information how to
##  transform the data into other formats such as BibTeX,
##  can be found in the &GAP; package
##  <Package>GAPDoc</Package> (see <Cite Key="GAPDoc"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "BrowseBibliographySporadicSimple", function()
    return BrowseBibliography( BibliographySporadicSimple );
    end );


#############################################################################
##
##  Undo the dummy assignment.
##
if IsString( BrowseBibliography ) then
  Unbind( BrowseBibliography );
fi;


#############################################################################
##
##  Add the Browse application to the list shown by `BrowseGapData'.
##
BrowseGapDataAdd( "Bibliography of Sporadic Simple Groups",
    BrowseBibliographySporadicSimple, true, "\
the contents of the bibliographies contained in the Atlas of Finite Groups \
and in the Atlas of Brauer Characters, \
based on the same Browse application as the menu entry \
``GAP Bibliography''; \
try ?BrowseBibliographySporadicSimple for details" );


#############################################################################
##
#E

