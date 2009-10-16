# the case identifiers
BindGlobal("RC_LINEAR","linear");
BindGlobal("RC_SYMPLECTIC","symplectic");
BindGlobal("RC_UNITARY","unitary");
BindGlobal("RC_ORTHPLUS","orthogonalplus");
BindGlobal("RC_ORTHMINUS","orthogonalminus");
BindGlobal("RC_ORTHCIRCLE","orthogonacircle");
BindGlobal("RC_IGNORE","ignore");
BindGlobal("RC_NOTAPPL","does not apply");
BindGlobal("RC_CASES",[UNKNOWN,RC_LINEAR,RC_SYMPLECTIC,RC_UNITARY,RC_ORTHMINUS,
           RC_ORTHPLUS,RC_ORTHCIRCLE,RC_IGNORE,RC_NOTAPPL]);

# this record will hold all the information about the recognition process so
# far and is the argument passed to most functions.
DeclareAttribute("RecognitionInfoRec",IsMatrixGroup,"mutable");

# the (proven) type of classical group
DeclareAttribute("GroupType",IsMatrixGroup);

# the case as far as we know 
DeclareRCAttribute("Case");

# A BasicPPD order
DeclareRCAttribute("BasicPPD");


# remove all ``unknown'' deductions
DeclareGlobalFunction("CleanRecognitionInfo");

DeclareGlobalFunction("RC_ApplicableParameters");

######################################################################
##
#F  RC_ReducibilityTest
##   
DeclareGlobalFunction("RC_ReducibilityTest");
                   
######################################################################
##
#F  TestRandomElement( INF )
##   
##  The  function  TestRandomElement() takes  a  group  <grp>  and  an
##  element <g> as  input.  It is assumed that  grp contains a  record
##  component   'recog'  storing  information   for  the   recognition
##  algorithm.  TestRandomElement() calls the  function IsPpdElement()
##  to determine whether <g> is a ppd(d, q;e)-element for some d/2 < e
##  <= d, and whether it is large.  If <g> is a ppd(d,q;e)-element the
##  value e is  added to  the set  grp.recognise.E, which records  all
##  values e  for  which  ppd-elements  have  been  selected.  If,  in
##  addition,  <g>   is   large,  e   is   also  stored   in  the  set
##  grp.recognise.LE,  which records all  values e  for which a  large
##  ppd-element has been selected.  The component grp.recognise.basic,
##  is  used to record  one value e for which a basic  ppd-element has
##  been  found,  as we  only require  one basic  ppd-element  in  our
##  algorithm.  Until such an element has been  found it is set to the
##  value 'false'.   Therefore the  function TestRandomElement()  only
##  calls the  function IsPpdElement() with input  parameters <g>, d*a
##  and p  if grp.recognise.basic  is  'false'.   If <g>  is  a  basic
##  ppd(d,q;e)-element then e is stored as grp.recognise.basic.
##  
DeclareGlobalFunction("TestRandomElement");

######################################################################
## 
#F  IsGeneric(INF ) . . . . . . .  is <grp> a generic subgroup
##
##   In  our  algorithm we attempt to find two different ppd-elements,
##  that is  a ppd(d, q; e_1)-element and a ppd(d, q; e_2)-element for
##  d/2 < e_1 < e_2 <= d.  We also require that  at least one  of them
##  is a large ppd-element and one  is a  basic ppd-element.   In that
##  case  <grp> is  a  generic  subgroup  of  GL(d,q).   The  function
##  IsGeneric()  takes  as  input  the  parameters <grp> and  <N_gen>.
##  It chooses up to <N_gen> random elements in <grp>.  If among these
##  it  finds  the  two  required  different  ppd-elements,  which  is
##  established   by    examining    the    sets    <grp>.recognise.E,
##  <grp>.recognise.LE,  and  <grp>.recognise.basic,  then it  returns  
##  true. If after <N_gen> independent  random selections  it fails to
##  find two  different  ppd-elements,  the  function returns 'false';
##  
DeclareRCAttribute("IsGeneric");

# does the group act irreducibly?
DeclareRCAttribute("RC_IsReducible");

#############################################################################
##
##  RuledOutExtFieldParameters
##
DeclareGlobalFunction("RuledOutExtFieldParameters");

#############################################################################
##
##  RC_IsExtensionField
##
DeclareGlobalFunction("RC_IsExtensionField");

#############################################################################
##
##  RecogniseClassicalNP(<grp>,<case>,<N>);
##
DeclareGlobalFunction("RecogniseClassicalNP");
DeclareSynonym("RecognizeClassicalNP",RecogniseClassicalNP);


