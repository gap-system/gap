#############################################################################
####
##
#W  options.gi                 ACE Package                        Greg Gamble
##
##  This file installs functions and records for manipulating ACE options.
##    
#H  @(#)$Id: options.gi,v 1.29 2006/01/26 16:11:31 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Information Technology & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.("ace/gap/options_gi") :=
    "@(#)$Id: options.gi,v 1.29 2006/01/26 16:11:31 gap Exp $";


#############################################################################
####
##
#V  KnownACEOptions . . . . . . record whose fields are the known ACE options
##  . . . . . . . . . . . . . . . . . .  each field is assigned a list of two 
##  . . . . . . . . . . . . . . . . . .  components:  [leastlength, listorfn]
##
##  The known ACE options  are the RecNames of KnownACEOptions.  The value of 
##  of each RecName is a list [ leastlength, listorfn ], where leastlength is
##  an integer specifying the least length of an abbreviation of the  RecName
##  that will match an ACE option,  and listorfn is either a list of  allowed 
##  values or a function that can be used to test that the value of an option 
##  is valid e.g. for the RecName "lookahead", we have knownOptions.lookahead 
##  equal to [ 4, [0..4] ] which indicates that "look", "looka", etc. are all 
##  valid abbreviations of the "lookahead" option,  and the values  that that 
##  option can take are in the (integer) range 0 to 4. 
##
##  If the allowed values listed for an option are 0 and 1,  then  false  and 
##  true are also permitted (we translate false and true to 0 and 1, respect-
##  ively when we call ACE). The empty string signifies that ACE  expects  no
##  value for that option.
##
##  Only single-word versions of options can be used by a user of ACE via the 
##  GAP interface e.g. "cc" is a synonym for "coset coincidence"  as  an  ACE
##  option,  but the latter,  being 2 words,  is  not available via  the  GAP 
##  interface.
##
##  The commented out options are known ACE options that probably  won't work
##  via the GAP interface ... if the user uses these  the  interface  program
##  CALL_ACE will complain: `unknown (possibly new) or bad'  but  still  pass 
##  these options to ACE ... at least the user will then know if ACE does not
##  respond as expected that the options should not be used.  We usually only 
##  warn that certain options might be bad, so that this interface has a good
##  chance of still being functional if new options are added to the ACE bin-
##  ary.
##
##  Some  options  are  `GAP-introduced'  i.e. technically they are  not  ACE 
##  options  ...  there is a comment beside such options;  and  they are also 
##  listed in NonACEbinOptions below.
##

InstallValue(KnownACEOptions, rec(
  # aceinfile, aceignore, aceignoreunknown, acenowarnings, silent (and 
  # further down: aceoutfile) are GAP-introduced options ... they  are
  # not ACE binary options.
  aceinfile := [5, IsString],
  aceignore := [5, x -> IsList(x) and ForAll(x, xi -> IsString(xi))],
  aceignoreunknown := [10, x -> IsList(x) and ForAll(x, xi -> IsString(xi))],
  acenowarnings := [6, [0,1]],
  aceecho := [7, [""]],
  aceincomment := [6, IsString],
  aceexampleoptions := [17, [0,1]],
  silent := [6, [0,1]],
  lenlex := [6, [0,1]],
  semilenlex := [10, [0,1]],
  incomplete := [10, [0,1]],
  sg := [2, IS_ACE_STRINGS],
  rl := [2, IS_ACE_STRINGS],
  aep  := [3, [1..7]],
  ai := [2, IsString],
  ao   := [2, IsString],      # "aceoutfile" is a GAP-introduced 
  aceoutfile := [4, IsString],# synonym for "ao"
  asis := [2, [0,1]],
  begin := [3, [""]],         # "begin" and "start" are synomyms
  start := [5, [""]],         # ... "end" synonym omitted (it is a GAP keyword)
  bye := [3, [""]],           # "bye", "exit" and "qui" are synonyms
  exit := [4, [""]],
  qui := [1, [""]],           # the "quit" form is not available since
                              # it's a GAP keyword
  cc   := [2, x -> IsInt(x) and x > 1],
  cfactor := [1, IsInt],      # "cfactor" and "ct" are synonyms
  ct   := [2, IsInt],
  check := [5, [""]],
  redo := [4, [""]],
  compaction := [3, [0..100]],
  continu := [4, [""]],       # "continue" is a GAP 4.3+ keyword
  cycles := [2, [""]],
  dmode := [4, [0..4]],
  dsize := [4, x -> x = 0 or IsPosInt(x)],
  default := [3, [""]],
  ds := [2, IS_INC_POS_INT_LIST],
  dr := [2, IS_INC_POS_INT_LIST],
  dump := [1, x -> x in ["",0,1,2] or
                   (IsList(x) and x[1] in [0..2] and
                    (Length(x) = 1 or (Length(x) = 2 and x[2] in [0,1])))],
  easy := [4, [""]],
  echo := [4, [0,1,2]],       # hijacked! ... we don't pass this to ACE
  enumeration := [4, IsString],
  felsch := [3, ["",0,1]],
  ffactor := [1, x -> x = 0 or IsPosInt(x)],# "ffactor" and "fill"
  fill := [3, x -> x = 0 or IsPosInt(x)],   # are synonyms ... there is
                                            # no "fi" since it's a GAP
                                            # keyword
  ## Most interface functions require the next 3 ACE options to be
  ## passed as arguments rather than options
  group := [2, x -> IsInt(x) or IsString(x) or
                    (IsList(x) and 
                     ForAll(x, xi -> IsString(xi) and
                                     (Length(xi) = 1) and
                                     IsLowerAlphaChar( xi[1] )))], 
                                               # For group generators
  generators := [3, IS_ACE_STRINGS],           # For subgroup generators
  relators := [3, IS_ACE_STRINGS],             # For group relators

  hard := [2, [""]],
  help := [1, [""]],
  hlt  := [3, [""]],
  hole := [2, [-1..100]],
  lookahead := [4, [0..4]],
  loop := [4, x -> x = 0 or IsPosInt(x)],
  max  := [3, x -> x = 0 or (IsInt(x) and x >= 2)],
  mendelsohn := [4, [0,1]],
  messages := [4, IsInt],   # "messages" and "monitor" are synonyms
  monitor := [3, IsInt],
  mode := [2, [""]],
  nc   := [2, ["",0,1]],    # "nc" and "normal" are synonyms
  normal := [6, ["",0,1]],
  no   := [2, x -> IsInt(x) and x >= -1],
  options := [3, [""]],
  oo   := [2, IsInt],       # "oo" and "order" are synonyms
  order := [5, IsInt],
  #parameters := [3, [""]], # decommissioned ACE option
  path := [4, [0,1]],
  pmode := [4, [0..3]],
  psize := [4, x -> x = 0 or 
                    (IsInt(x) and IsEvenInt(x) and IsPrimePowerInt(x))],
  sr := [2, ["",0,1,2,3,4,5]],
  print := [2, x -> x = "" or IsInt(x) or
                    (IsList(x) and Length(x) <= 3 and IsInt(x[1]) and
                     ForAll(x{[2..Length(x)]}, IsPosInt)) ],
  purec := [5, [""]],       # the ACE option is "pure c"
  purer := [5, [""]],       # the ACE option is "pure r"
  rc   := [2, x -> x = "" or IsInt(x) or 
                   (IsList(x) and Length(x) <= 2 and ForAll(x, IsInt))],
  recover := [4, [""]],     # "recover" and "contiguous"
  contiguous := [6, [""]],  # are synonyms ... "rec" is
                            # not an allowed abbreviation
                            # since it's a GAP  keyword
  rep  := [2, x -> x in [1..7] or
                   (IsList(x) and Length(x) <= 2 and x[1] in [1..7] and
                    ForAll(x{[2..Length(x)]}, IsInt))],
  #restart := [7, [""]],    # decommissioned ACE option
  rfactor := [1, IsInt],    # "rfactor" and "rt" are synonyms
  rt   := [2, IsInt],
  row  := [3, [0,1]],
  sc   := [2, IsInt],       # "sc" and "stabilising" are synonyms
  stabilising := [6, IsInt],
  sims := [4, [1,3,5,7,9]],
  standard := [2, [""]],
  statistics := [4, [""]],  # "statistics" and "stats" are synonyms
  stats := [5, [""]],
  style := [5, [""]],
  subgroup := [4, IsString],
  system := [3, IsString],
  text := [4, IsString],
  time := [2, x -> IsInt(x) and x >= -1],
  tw   := [2, x -> IsList(x) and Length(x) = 2 and 
                   IsInt(x[1]) and IsWord(x[2])],
  trace := [2, x -> IsList(x) and Length(x) = 2 and 
                    IsInt(x[1]) and IsWord(x[2])],
  workspace := [2, x -> IsInt(x) or 
                        (IsString(x) and x[Length(x)] in "0123456789kmgKMG")]
));

#############################################################################
####
##
#V  ACEOptionSynonyms . . . . . record whose fields are `preferred' known ACE
##  . . . . . . . . . . . . . . options that have synonyms.  The  values  are
##  . . . . . . . . . . . . . . . . . . . . lists of synonymous alternatives.
##
##

InstallValue(ACEOptionSynonyms, rec(
  ao   := ["aceoutfile"],
  ct   := ["cfactor"],
  fill := ["ffactor"],
  messages := ["monitor"],
  nc   := ["normal"],
  order := ["oo"],
  recover := ["contiguous"],
  rt   := ["rfactor"],
  sc   := ["stabilising"],
  tw   := ["trace"],
  stats := ["statistics"],
  start := ["begin"],
  bye  := ["exit", "qui"],
  redo := ["check"]
));

#############################################################################
####
##
#V  NonACEbinOptions . . . . . . . list of known ACE options that are not ACE
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . binary options.
##

InstallValue(NonACEbinOptions,
  [ "aceinfile",     "aceoutfile", "aceignore",    "aceignoreunknown",
    "acenowarnings", "aceecho",    "aceincomment", "aceexampleoptions",
    "echo",          "silent",     "lenlex",       "semilenlex",
    "incomplete" ]
);

#############################################################################
####
##
#V  ACE_INTERACT_FUNC_OPTIONS . . . . . list of non ACE options that are used
##  . . . . . . . . . . . . . . . . . . . .  by the interaction ACE functions
##

InstallValue(ACE_INTERACT_FUNC_OPTIONS,
  [ # used by: ACEConjugatesForNormalClosure
    "add",
    # used by: ACEOrders
    "suborder", 
    # used by: ACERandomlyApplyCosetCoincidence
    "attempts", "hibound", "lobound", "subindex" ]
);

#############################################################################
####
##
#V  ACEParameterOptions . .  record whose fields are the known ACE  parameter
##  . . . . . . . . . . . .  options.  Each  field is  assigned   the   known 
##  . . . . . . . . . . . .  default value, or is a record of default values.
##
##  An ACE `parameter' option, is a known ACE option for which the ACE binary
##  has a default value.  These are the `Run Parameters' that ACE lists  with 
##  the `sr: 1' command,  except for  `group',  `relators'  and  `generators'
##  (which the user provides a value for via arguments rather than options).
##
##  For the case that the value of a field of the ACEParameterOptions  record
##  is itself  a  record,  the  fields  of  that  record  are  `default'  and 
##  strategies for which the value assigned by that strategy differs from the
##  `default' strategy. A strategy here means a strategy option  concatenated
##  with any of its possible values (as strings).
##

InstallValue(ACEParameterOptions, rec(
  asis := 0,
  # `ct' is synonymous with `cfactor' but here we list just once.
  ct   := rec(default := 0, felsch0 := 1000, felsch1 := 1000, 
              hard := 1000, purec := 1000,   sims9 := 1000),
  compaction := rec(default := 10, easy := 100, purec := 100, purer := 100),
  dmode := rec(default := 4, easy := 0,  hlt := 0,
               purer := 0,   sims1 := 0, sims5 := 0),
  dsize := rec(default := 1000),
  enumeration := "G",
  # `fill' is synonymous with `ffactor' but here we list just once.
  fill := rec(default := 0, easy := 1,  felsch0 := 1, hlt := 1,
              purec := 1,   purer := 1, sims1 := 1,   sims3 := 1,
              sims5 := 1,   sims7 := 1, sims9 := 1),
  hole := -1,
  lookahead := rec(default := 0, hlt := 1),
  loop := 0,
  max  := 0,
  mendelsohn := rec(default := 0, sims5 := 1, sims7 := 1),
  messages := 0, # Synonymous with `monitor' but here we list just once.
  no   := rec(default := -1, easy := 0,  felsch0 := 0, hlt := 0,
              purec := 0,    purer := 0, sims1 := 0,   sims3 := 0,
              sims5 := 0,    sims7 := 0, sims9 := 0),
  path := rec(default := 0),
  pmode := rec(default := 3, easy := 0,  felsch0 := 0, hlt := 0,
               purec := 0,   purer := 0, sims1 := 0,   sims3 := 0,
               sims5 := 0,   sims7 := 0, sims9 := 0),
  psize := rec(default := 256),
  # `rt' is synonymous with `rfactor' but here we list just once.
  rt   := rec(default := 0,   easy := 1000,  hard := 1, 
              hlt := 1000,    purer := 1000, sims1 := 1000,
              sims3 := -1000, sims5 := 1000, sims7 := -1000),
  row  := rec(default := 1, felsch0 := 0, felsch1 := 0, 
              purec := 0,   purer := 0,   sims9 := 0),
  subgroup := "H",
  time := -1,
  workspace := 1000000
));

#############################################################################
####
##
#V  ACEStrategyOptions  . list of known ACE options that are strategy options
##

InstallValue(ACEStrategyOptions,
  [ "default", "easy", "felsch", "hard", "hlt", "purec", "purer", "sims" ]
);

#############################################################################
####
##
#V  ACE_OPT_TRANSLATIONS  . . . . . record of ACE interface options for which
##  . . . . . . . . . . . . . . . . . the  ACE  binary has a different  name; 
##  . . . . . . . . . . . . . . . . . its fields are the ACE interface names,
##  . . . . . . . . . . . . . . . . . its values are the  ACE  binary  names.
##

InstallValue(ACE_OPT_TRANSLATIONS, rec(
  purec := "pure c", # These first two haven't been called NonACEbinOptions
  purer := "pure r", 
  aceoutfile := "ao",
  aceecho := "echo", 
  aceincomment := "#"
));

#############################################################################
####
##
#V  ACE_OPT_ACTIONS . . . . . . . record of special actions  of  ACE  options
##  . . . . . . . . . . . . . . . its fields are the ACE  option  names  with
##  . . . . . . . . . . . . . . . special actions, its values are the actions
##

InstallValue(ACE_OPT_ACTIONS, rec(
  purec := "passed to ACE via option: pure c",
  purer := "passed to ACE via option: pure r", 
  aceoutfile := "passed to ACE via option: ao",
  aceecho := "passed to ACE via option: echo",
  aceincomment := "passed as an ACE comment, behind a '#'",
  aceexampleoptions := "inserted by ACEExample, not passed to ACE"
));

#############################################################################
####
##
#V  ACE_ERRORS . . . . . . . . . . . . record of ACE interface error messages
##
##

InstallValue(ACE_ERRORS, rec(
  argnotopt := "should be passed as an argument, NOT an option"
));

#############################################################################
####
##
#V  ACE_OPT_SENTINELS . . . . . . . . . . . . . .  record of option sentinels
##
##  is a record whose fields are the  preferred  option  name  of  those  ACE
##  options that normally produce output and whose values are  either  `fail'
##  if there is no reliable way of detecting the last line  of  output  or  a
##  function of an input line <line> that returns `true'  if  <line>  is  the
##  last line of output expected for an option.
##

InstallValue(ACE_OPT_SENTINELS, rec(
  start := line -> Length(line) > 1 and line[ Length(line) - 1 ] = ')',
  redo  := line -> Length(line) > 1 and line[ Length(line) - 1 ] = ')',
  continu := line -> Length(line) > 1 and line[ Length(line) - 1 ] = ')',
  aep  := line -> IsMatchingSublist(line, "* P"),
  rep  := fail,
  cc   := line -> IsMatchingSublist(line, "Coset"),
  mode := line -> IsMatchingSublist(line, "start ="),
  nc   := fail,
  order := fail,
  options := line -> IsMatchingSublist(line, "  host info"),
  dump  := line -> IsMatchingSublist(line, "  #----"),
  sr    := line -> IsMatchingSublist(line, "  #----"),
  stats := line -> IsMatchingSublist(line, "  #----"),
  print := fail,
  rc   := line -> Length(line) > 12 and
                  line{[1..13]} in ["* No success;", "* An appropri",
                                    "   finite ind", "   * Unable t"],
  cycles := line -> Length(line) > 1 and line{[1..2]} in ["CO", "co"],
  recover := line -> Length(line) > 1 and line{[1..2]} in ["CO", "co"],
  standard := line -> Length(line) > 1 and line{[1..2]} in ["CO", "co"],
  sc   := fail,
  style := line -> IsMatchingSublist(line, "style ="),
  test := fail,
  tw   := line -> PositionSublist(line, "* word =") <> fail or
                  IsMatchingSublist(line, "* Trace ")
));

#############################################################################
####
##
#F  IS_INC_POS_INT_LIST . . . . . . Internal function used in KnownACEOptions
##  . . . . . . . .  returns true if argument is a single positive integer or
##  . . . . . . . . . . .  is a strictly increasing list of positive integers
##
InstallGlobalFunction(IS_INC_POS_INT_LIST, 
  x -> IsPosInt(x) or (IsPosInt(x[1]) and IsSSortedList(x)));

#############################################################################
####
##
#F  IS_ACE_STRINGS  . . . . . . . . Internal function used in KnownACEOptions
##  . . . . . . . . . returns true if argument is a string or list of strings
##
InstallGlobalFunction(IS_ACE_STRINGS, 
  x -> IsString(x) or (IsList(x) and ForAll(x, xi -> IsString(xi))));

#############################################################################
####
##
#F  IsKnownACEOption  . . . . . . . . Returns true if optname is a mixed case
##  . . . . . . . . . . . . . . . . . abbreviation    of    a    field     of
##  . . . . . . . . . . . . . . . . . .  KnownACEOptions, or false otherwise.
##
InstallGlobalFunction(IsKnownACEOption, 
  optname -> ACEOptionData(optname).known);

#############################################################################
####
##
#F  ACEPreferredOptionName  . . . . Returns the lowercase unabbreviated first
##  . . . . . . . . . . . . . . . . alternative of optname if it is  a  known
##  . . . . . . . . . . . . . . . . ACE  option,  or  optname  in  lowercase,
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  otherwise.
##
InstallGlobalFunction(ACEPreferredOptionName, 
  optname -> ACEOptionData(optname).synonyms[1]);

#############################################################################
####
##
#F  IsACEParameterOption  . . Returns true if ACEPreferredOptionName(optname) 
##  . . . . . . . . . . . . . . . . . . . . is a field of ACEParameterOptions
##
InstallGlobalFunction(IsACEParameterOption, 
  optname -> ACEPreferredOptionName(optname) in RecNames(ACEParameterOptions));

#############################################################################
####
##
#F  IsACEStrategyOption . . . Returns true if ACEPreferredOptionName(optname) 
##  . . . . . . . . . . . . . . . . . . . . . . . .  is in ACEStrategyOptions
##
InstallGlobalFunction(IsACEStrategyOption, 
  optname -> ACEPreferredOptionName(optname) in ACEStrategyOptions);

#############################################################################
####
##
#F  ACE_OPTIONS . . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . returns the options passed to an ACE interface function
##
##
InstallGlobalFunction(ACE_OPTIONS, function()
  if IsEmpty(OptionsStack) then
    return rec();
  else
    return OptionsStack[ Length(OptionsStack) ];
  fi;
end);

#############################################################################
####
##
#F  ACE_OPT_NAMES . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . .  returns option names passed to an ACE interface function
##  . . . . . . . . . . . . . if acenowarnings is not an option it also warns
##  . . . . . . . . . . . . . . . . . . . . . . . .  about deprecated options
##
InstallGlobalFunction(ACE_OPT_NAMES, function()
local optnames;
  optnames := RecNames(ACE_OPTIONS());
  if not VALUE_ACE_OPTION(optnames, false, "acenowarnings") then
    if "messfile" in optnames then
      Info(InfoACE + InfoWarning, 1,
           "ACE Warning: ", 
           "Option `messfile' deprecated: use `ACEoutfile' instead");
    elif "outfile" in optnames then
      Info(InfoACE + InfoWarning, 1,
           "ACE Warning: ", 
           "Option `outfile' deprecated: use `ACEinfile' instead");
    fi;
  fi;
  return optnames;
end);

#############################################################################
####
##
#F  MATCHES_KNOWN_ACE_OPT_NAME  . . . . . . . . . . . . . . Internal function
##  . . . .  returns true iff optname is a valid abbreviation of knownoptname
##  . . . . . . . . . . . . . . . . . optname should be in lowercase already!
##
InstallGlobalFunction(MATCHES_KNOWN_ACE_OPT_NAME, 
function(knownoptname, optname)
  return IsMatchingSublist(knownoptname, optname) and
         KnownACEOptions.(knownoptname)[1] <= Length(optname);
end);

#############################################################################
####
##
#F  FULL_ACE_OPT_NAME . . . . . . . . . . . . . . . . . .  Internal procedure
##  . . . . . . sets opt.fullname to be the unabbreviated version of opt.name
##  . . . . . . . . . . .  if one exists among the fields of KnownACEOptions,
##  . . . . . . . . . . . . . . in which case, opt.known is also set to true;
##  . . . . . . . . . . .  otherwise,  opt.fullname  is set  to  opt.name  in 
##  . . . . . . . . . . . . . . lower case,  and  opt.known  is set to false.
##
InstallGlobalFunction(FULL_ACE_OPT_NAME, function(opt)
local lcaseoptname, list;
  lcaseoptname := LowercaseString(opt.name);
  list := Filtered(RecNames(KnownACEOptions), 
                   s -> MATCHES_KNOWN_ACE_OPT_NAME(s, lcaseoptname));
  opt.known := not( IsEmpty(list) );
  if opt.known then
    opt.fullname := list[1];  # We assume any match is unique!
  else
    opt.fullname := lcaseoptname;
  fi;
end);

#############################################################################
####
##
#F  ACE_OPTION_SYNONYMS . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . . . . . returns a list of synonyms of optname
##
##
InstallGlobalFunction(ACE_OPTION_SYNONYMS, function(optname)
local list, recname;
  list := [ optname ];
  for recname in RecNames(ACEOptionSynonyms) do
    if recname = optname or optname in ACEOptionSynonyms.(recname) then
      list := Concatenation( [ recname ], ACEOptionSynonyms.(recname) );
      break;
    fi;
  od;
  return list;
end);

#############################################################################
####
##
#F  ACE_IF_EXPR . . . . . . . . . . . . . . . . . . . . . .  An expression if
##
##
InstallGlobalFunction(ACE_IF_EXPR, function(bool, trueval, falseval, failval)
  if bool = true then
    return trueval;
  elif bool = false then
    return falseval;
  else
    return failval;
  fi;
end);
  
#############################################################################
####
##
#F  ACE_VALUE_OPTION  . . . . . . . . Essentially an extension of ValueOption
##  . . . . . . . . . . . . . . .  but also removes optname from OptionsStack
##
##  ACE_VALUE_OPTION(optname,  defaultval)  returns  ValueOption(optname)  if
##  optname is set and defaultval, otherwise.
##
##  ACE_VALUE_OPTION(optname, val,  trueval,  elseval).  If optname has value
##  val then return trueval else return elseval.
##
##  If ACE_VALUE_OPTION is called with a different no. of aguments to 1 or 2,
##  all but  the  first  argument  is  ignored,  and  ValueOption(arg[1])  is
##  returned. Calling ACE_VALUE_OPTION with no arguments is an error.
##
InstallGlobalFunction(ACE_VALUE_OPTION, function(arg)
local optval;
  optval := ValueOption(arg[1]);
  if not IsEmpty(OptionsStack) then
    Unbind( OptionsStack[ Length(OptionsStack) ].(arg[1]) );
  fi;
  if Length(arg) = 2 then
    return ACE_IF_EXPR(optval <> fail, optval, arg[2], arg[2]);
  elif Length(arg) = 4 then
    return ACE_IF_EXPR(optval = arg[2], arg[3], arg[4], arg[4]);
  elif not IsEmpty(arg) then
    # Ignore all but the first argument
    return optval;
  fi;
end);
  
#############################################################################
####
##
#F  ACE_VALUE_OPTION_ERROR(<optrec>, <optname>, <defaultval>, <IsOK>, <errmsg>)
##
##  returns:
##    `false' if `ValueOption(<option>) = fail' 
##               (and sets `<optrec>.(<optname>) := <defaultval>') or
##            if `<IsOK>( ValueOption(<option>) )'
##               (and sets `<optrec>.(<optname>) := ValueOption(<option>)')
##    `true'  if `not <IsOK>( ValueOption(<option>) )'
##               (and sets `<optrec>.errmsg := [<errmsg>]')
##
InstallGlobalFunction(ACE_VALUE_OPTION_ERROR, 
function(optrec, optname, defaultval, IsOK, errmsg)
local optval;
  optval := ValueOption(optname);
  if optval = fail then
    optrec.(optname) := defaultval;
  elif IsOK(optval) then
    optrec.(optname) := optval;
  else
    optrec.errmsg := [errmsg];
    return true;
  fi;
  return false;
end);
  
#############################################################################
####
##
#F  VALUE_ACE_OPTION  . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . checks among optnames for any settings of synonyms of optnm
##  . . . . . . . (or if optnm is a list  any  synonyms  of  the  members  of
##  . . . . . . . optnm). The latest such optname in  optnames  will  prevail
##  . . . . . . . and its value will be returned. Otherwise, if  there  isn't
##  . . . . . . . . . . . . . . . .  such an optname, defaultval is returned.
##
InstallGlobalFunction(VALUE_ACE_OPTION, function(optnames, defaultval, optnm)
local optname, optval, optnmlist;
  optval := defaultval;
  if IsString(optnm) then
    optnmlist := [ optnm ];
  else
    optnmlist := optnm; # This situation is special ... useful for checking
                        # whether a list of options have been set
  fi;
  optnmlist := Union( List(optnmlist, 
                           optname -> ACE_OPTION_SYNONYMS(optname)) );
  for optname in Filtered(optnames, 
                          optname -> ForAny(optnmlist,
                                            s ->
                                            MATCHES_KNOWN_ACE_OPT_NAME(
                                                s, 
                                                LowercaseString(optname)
                                                )
                                            )) 
  do
    optval := ValueOption(optname);
  od;
  return optval;
end);
  
#############################################################################
####
##
#F  DATAREC_VALUE_ACE_OPTION  . . . . . . . . . . . . . . . Internal function
##  . . . . . . . checks among RecNames(datarec.options) for any settings  of
##  . . . . . . . synonyms of optnm The latest such optname prevails and  its
##  . . . . . . . value is  returned.  Otherwise,  if  there  isn't  such  an
##  . . . . . . . optname  or  datarec.options  is  unbound,  defaultval   is
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . returned.
##
InstallGlobalFunction(DATAREC_VALUE_ACE_OPTION, 
                      function(datarec, defaultval, optnm)
local optname, optval;
  optval := defaultval;
  if IsBound(datarec.options) then
    for optname in Filtered(RecNames(datarec.options), 
                            optname -> ForAny(ACE_OPTION_SYNONYMS(optnm), 
                                              s ->
                                              MATCHES_KNOWN_ACE_OPT_NAME(
                                                  s, 
                                                  LowercaseString(optname)
                                                  )
                                              )) 
    do
      optval := datarec.options.(optname);
    od;
  fi;
  return optval;
end);
  
#############################################################################
####
##
#F  ACE_COSET_TABLE_STANDARD  . . . . . . Return either the user's choice for
##  . . . . . . . . . . . . . . . . . . . the CosetTableStandard or,  if  the
##  . . . . . . . . . . . . . . . . . . . user has made no choice,  a  string
##  . . . . . . . . . . . . . . . . . . . representing   the   current    GAP
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . standard.
##
##  A check among options for any settings of `lenlex' or  `semilenlex'.  The
##  latest such optname that is set to true is returned, or if  there  is  no
##  such setting a string representing the current GAP default  is  returned:
##  for  GAP  4.2  "GAPsemilenlex"  was  returned;  since  GAP   4.3,   "GAP"
##  concatenated  with  the  value  of  `CosetTableStandard'   (by   default,
##  "lenlex") is returned.
##
InstallGlobalFunction(ACE_COSET_TABLE_STANDARD, function(options)
local optname;
  for optname in Filtered(Reversed( RecNames(options) ), 
                          optname -> ForAny(["lenlex", "semilenlex"],
                                            s ->
                                            MATCHES_KNOWN_ACE_OPT_NAME(
                                                s, 
                                                LowercaseString(optname)
                                                )
                                            )) 
  do
    if options.(optname) = true then
      return ACEPreferredOptionName(optname);
    fi;
  od;
  return Concatenation("GAP", CosetTableStandard);
end);
  
#############################################################################
####
##
#F  ACE_VALUE_ECHO  . . . . . . . . . . . . . . . . . . . . Internal function
##
##
InstallGlobalFunction(ACE_VALUE_ECHO, function(optnames)
local echoval;
  echoval := VALUE_ACE_OPTION(optnames, 0, "echo");
  if echoval in KnownACEOptions.echo[2] then
    return echoval;
  else 
    return ACE_IF_EXPR(echoval = true, 1, 0, 0);
  fi;
end);
  
#############################################################################
####
##
#F  TO_ACE_GENS . . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . from the GAP free group generators fgens  returns
##  . . . . . . . . . . . . a record used to create the equivalent ACE  group
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  generators
##
##  Returns a record with fields: 
##
##    acegens
##        the ACE equivalent of fgens; and 
##
##    toace
##        the ACE directive string needed for the `group' option so that  ACE
##        uses acegens for its generators.
##
InstallGlobalFunction(TO_ACE_GENS, function(fgens)
local n, acegens;

  n := Length(fgens);
  # Define the generators ACE will use
  if n <= 26 then
    # if #generators <= 26 tell ACE to use alphabetic generators: a ...
    if ForAll(fgens, function(g)
                       local gstring;
                       gstring := String(g);
                       return Length(gstring) = 1 and
                              LowercaseString(gstring) = gstring;
                     end) 
    then
      # if all generators are represented by single lowercase letters
      # ... use the user's set of generators for ACE
      acegens := List(fgens, g -> String(g));
    else
      acegens := List([1..n], i -> WordAlp(CHARS_LALPHA, i));
    fi;
    return rec(acegens := acegens, toace := Flat(acegens));
  else
    # if #generators > 26 tell ACE to use numerical generators: 1 ...
    return rec(acegens := List([1..n], i -> String(i)), toace := n);
  fi;
end);

#############################################################################
####
##
#F  ACE_WORDS . . . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . .  returns the translation of words in generators fgens
##  . . . . . . . . . . .  to words in ACEgens (the generators ACE will use),
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  as one string.
##
InstallGlobalFunction(ACE_WORDS, function(words, fgens, ACEgens)
  words := ACE_WORDS_ARG_CHK(fgens, words, "");
  return JoinStringsWithSeparator(
             List(words, w -> String( MappedWord( w,
                                                  fgens,
                                                  GeneratorsOfGroup(
                                                      FreeGroup(ACEgens)
                                                      ) ) ) ) );
end);

#############################################################################
####
##
#F  ACE_RELS  . . . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . returns the translation of  the  relators  rels  in
##  . . . . . . . . . . . generators  fgens  to   words   in   ACEgens   (the
##  . . . . . . . . . . . generators ACE will use), as  one  string,  but  if
##  . . . . . . . . . . . enforceAsis is true  ensure  the  relator  for  the
##  . . . . . . . . . . . first generator (which we'll  represent  as  x)  is
##  . . . . . . . . . . . . . . . . .  translated as "x*x" rather than "x^2".
##
InstallGlobalFunction(ACE_RELS, function(rels, fgens, ACEgens, enforceAsis)
  if enforceAsis then
    return Concatenation( ACEgens[1], ACEgens[1], ", ",
                          ACE_WORDS(Filtered(rels, rel -> rel <> fgens[1]^2),
                                    fgens, ACEgens) );
  else
    return ACE_WORDS(rels, fgens, ACEgens);
  fi;
end);

#############################################################################
####
##
#F  ToACEGroupGenerators  . . . . . Given the GAP free group generators fgens
##  . . . . . . . . . . . . . . . . returns the ACE directive  string  needed
##  . . . . . . . . . . . . . . . . for the `group' option so that  ACE  uses
##  . . . . . . . . . . . . . . . . an   appropriate   equivalent   set    of
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . generators.
##
InstallGlobalFunction(ToACEGroupGenerators, function(fgens)

  fgens := ACE_FGENS_ARG_CHK(fgens);
  return TO_ACE_GENS(fgens).toace;
end);

#############################################################################
####
##
#F  ToACEWords  . . . .  Returns the translation of words in generators fgens
##  . . . . . . . . . .  to equivalent ACE words, as one string, suitable for
##  . . . . . . . . . . . . . . . .  the `relators' and `generators' options.
##
InstallGlobalFunction(ToACEWords, function(fgens, words)

  fgens := ACE_FGENS_ARG_CHK(fgens);
  return ACE_WORDS(words, fgens, TO_ACE_GENS(fgens).acegens);
end);

#############################################################################
####
##
#F  ACE_FGENS_ARG_CHK( <fgens> )
##
##  Checks that <fgens> is a list of free group generators for the same  free
##  group, gives the user a chance to fix them if necessary, and then returns
##  the (repaired) <fgens>.
##
InstallGlobalFunction(ACE_FGENS_ARG_CHK, function(fgens)
local errmsg, onbreakmsg, error, fam;

  onbreakmsg := 
      ["Type: 'quit;' to quit to outer loop, or",
       "type: 'fgens := <val>; return;' to assign <val> to fgens to continue."];
  error := true;
  repeat
    if not IsList(fgens) then
        errmsg := ["fgens must be a *list* of free group gen'rs"];
    elif not ForAll(fgens, g -> IsAssocWordWithInverse(g) and
                                (NumberSyllables(g) = 1) and
                                (ExponentSyllable(g, 1) = 1)) then
      if ForAll(fgens, IsElementOfFpGroup) then
        errmsg := ["fgens must be a list of free group gen'rs,",
                   "not fp group elements e.g. use 'FreeGeneratorsOfFpGroup'",
                   "rather than 'GeneratorsOfGroup'"];
      else
        errmsg := ["fgens must be a list of free group gen'rs"];
      fi;
    else
      fam := FamilyObj(fgens[1]);
      if not ForAll(fgens{[2..Length(fgens)]}, g -> fam = FamilyObj(g)) then
        errmsg := ["fgens must all belong to the same free group"];
      else
        error := false;
      fi;
    fi;
    if error then
      Error(ACE_ERROR(errmsg, onbreakmsg), "\n");
    fi;
  until not error;
  return fgens;
end);

#############################################################################
####
##
#F  ACE_WORDS_ARG_CHK( <fgens>, <words>, <whicharg> )
##
##  Checks that <words> is a valid list of words in the free group generators
##  <fgens>. If not, an error message for  the  <whicharg>  (which  indicates
##  what type of words they are,  e.g.  "relators",  "subgp  gen'rs"  or  "")
##  argument is generated, telling the user how  to  fix  the  problem.  Once
##  everything is ok, <words> after being filtered of any  identity  elements
##  is returned.
##
InstallGlobalFunction(ACE_WORDS_ARG_CHK, function(fgens, words, whicharg)
local fam, errmsg, onbreakmsg;

  onbreakmsg := 
      ["Type: 'quit;' to quit to outer loop, or",
       "type: 'words := <val>; return;' to assign <val> to words to continue.",
       "Note: fgens is the list of free group generators."];
  
  fam := FamilyObj(fgens[1]);
  errmsg := "words ";
  if whicharg <> "" then
    errmsg := Concatenation(errmsg, "(", whicharg, ") ");
  fi;
  while not IsList(words) or not ForAll(words, w -> FamilyObj(w) = fam) do
    if IsList(words) and ForAll(words, IsElementOfFreeGroup) then
      errmsg := 
        [Concatenation(
             errmsg, "is a list of words in the *wrong* free grp gen'rs")];
    elif IsList(words) and ForAll(words, IsElementOfFpGroup) then
      errmsg := 
        [Concatenation(
             errmsg, "must be a list of words in the free group gen'rs,"),
         "not fp group elements. Perhaps, you should use 'UnderlyingElement'",
         "to convert each fp group element to a word in the free group gen'rs"];
    else
      errmsg := 
        [Concatenation(
             errmsg, "must be a list of words in the free group gen'rs")];
    fi;
    Error(ACE_ERROR(errmsg, onbreakmsg), "\n");
  od;
  return Filtered(words, word -> not IsOne(word));
end);

#############################################################################
####
##
#F  PROCESS_ACE_OPTIONS . . . . . . . . . . . . . . . . .  Internal procedure
##  . . . . . . . . . for the ACE function with name ACEfname process options
##  . . . . . . . . . (on the top of OptionsStack)  with  names  newoptnames,
##  . . . . . . . . . other than those  that  are  fields  of  disallowed  or
##  . . . . . . . . . listed in ignored, by sending them to ACE via the write
##  . . . . . . . . . function ToACE,  after  appropriate  translation  where
##  . . . . . . . . . necessary, mostly in the order specified by  the  user.
##  . . . . . . . . . The list optnames contains the names of  all  currently
##  . . . . . . . . . active options i.e. the fields of all options on top of
##  . . . . . . . . . the OptionsStack. If  echo  is  set  then  all  options
##  . . . . . . . . . processed are echoed along with an  indication  of  how
##  . . . . . . . . . they were handled by the interface. If the InfoLevel of
##  . . . . . . . . . InfoACE or InfoWarning is at least 1 and the  user  has
##  . . . . . . . . . not passed the  acenowarnings  option  then  a  warning
##  . . . . . . . . . message is issued for each optname that is a  field  of
##  . . . . . . . . . disallowed or is in ignored or for some other reason is
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ignored.
##
InstallGlobalFunction(PROCESS_ACE_OPTIONS, 
function(ACEfname, optnames, newoptnames, echo, datarec, disallowed, ignored)
local ToACE, IsValidOptionValue, CheckValidOption, ProcessOption, 
      AddIgnoreOptionsToIgnored, IsMyLine, nowarnings, ignoreunknown, 
      paramoptnames, strategy, opt, optname, line, invokesEnumeration;

  ToACE := function(list) 
    WRITE_LIST_TO_ACE_STREAM(datarec.stream, list);
  end;

  IsValidOptionValue := function(val)
    # Check that val is a valid value of opt.fullname.
    # This function will only be called when opt.known = true,
    # in which case, opt.fullname will be a field of KnownACEOptions
    if IsFunction(KnownACEOptions.(opt.fullname)[2]) then
      return KnownACEOptions.(opt.fullname)[2](val);
    elif IsBool(val) then
      return KnownACEOptions.(opt.fullname)[2] in ["", ["",0,1], [0,1]];
    else
      return val in KnownACEOptions.(opt.fullname)[2];
    fi;
  end;

  CheckValidOption := function(val)
    # If opt.fullname is a known allowed optname and val is a valid value,
    # warn the user of a possible error, if s/he wants to know and its
    # not an ignored option.
    if not(nowarnings or opt.ignore) then
      if opt.fullname in RecNames(disallowed) then
        Info(InfoACE + InfoWarning, 1,
             "ACE Warning: ", opt.name, ": ", disallowed.(opt.fullname));
      elif opt.known then
        if not IsValidOptionValue(val) then
          Info(InfoACE + InfoWarning, 1,
               "ACE Warning: ", val, ": ",
               "possibly not an allowed value of ", opt.name);
        fi;
      else
        Info(InfoACE + InfoWarning, 1,
             "ACE Warning: ", opt.name, ": unknown (maybe new) or bad option");
      fi;
    fi;
  end;

  ProcessOption := function(val)
    # Echo what we are about to do first, if the user has set the echo
    # option.
    if echo > 0 then
      if opt.ignore then
        Print(" ", opt.name, " := ", opt.value, " (ignored)\n");
      elif opt.fullname in RecNames(ACE_OPT_ACTIONS) then
        Print(" ", opt.name);
        if val = "" then
          Print(" (no value, ");
        else
          Print(" := ", opt.value, " (");
        fi;
        Print( ACE_OPT_ACTIONS.(opt.fullname), ")\n" );
      elif opt.fullname in NonACEbinOptions then
        Print(" ", opt.name, " := ", opt.value, " (not passed to ACE)\n");
      elif opt.list then
        Print(" ", opt.name, " := ", opt.value, 
              " (brackets are not passed to ACE)\n");
      elif val = "" then
        Print(" ", opt.name, " (no value)\n");
      else
        Print(" ", opt.name, " := ", val, "\n");
      fi;
    fi;
    # Warn user if opt.name is an unknown optname or has an unexpected value
    # if they want to know.
    CheckValidOption(val);
    # Now do it ... pass opt.ace (which is opt.name except when the ACE and
    # GAP optnames differ) to ACE with value val,  except if opt.name is to
    # be ignored or is a NonACEbinOption without a translation.
    if not opt.donotpass and not opt.ignore then
      if opt.fullname in RecNames(ACE_OPT_TRANSLATIONS) then
        # The ACE optname differs from the GAP optname
        opt.ace := ACE_OPT_TRANSLATIONS.(opt.fullname);
      else
        # The ACE optname is the same as the GAP optname
        opt.ace := opt.name;
      fi;
      if opt.list then
        ToACE([ opt.ace,":", 
                JoinStringsWithSeparator( List(val, String) ), ";" ]);
      elif val = "" then
        ToACE([ opt.ace, ";" ]);
      elif opt.fullname = "aceincomment" then
        ToACE([ opt.ace, val, ";" ]);
      else
        ToACE([ opt.ace, ":", val, ";" ]);
      fi;

      # Eventually we may include more general support for interpretation
      # of ACE output here ... for the moment we ensure the enumeration
      # result is set (for ACEStats) and the coset table is set (for
      # ACECosetTable[FromGensAndRels]) if there is an enumeration result
      if IsBound(datarec.procId) then
        if not IsBound( ACE_OPT_SENTINELS.(opt.synonyms[1]) ) then
          # Flush any available output ... it may contain errors
          line := ReadAllLine(datarec.stream);
          while line <> fail do
            Info(InfoACE + InfoWarning, 1, Chomp(line));
            line := ReadAllLine(datarec.stream);
          od;
        elif opt.fullname = "print" and IsBound(datarec.stats) and
             val in [ "", datarec.stats.activecosets ] and
             (datarec.stats.index <> 0 or 
              VALUE_ACE_OPTION(optnames, false, "incomplete") ) then
          datarec.cosettable := ACE_COSET_TABLE(datarec.stats.activecosets,
                                                datarec.acegens, 
                                                datarec.stream, 
                                                ACE_READ_NEXT_LINE);
        else
          if ACE_OPT_SENTINELS.(opt.synonyms[1]) = fail then
            ToACE([ "text:***" ]);
            IsMyLine := line -> IsMatchingSublist(line, "***");
          else
            IsMyLine := ACE_OPT_SENTINELS.(opt.synonyms[1]);
          fi;
          invokesEnumeration := opt.synonyms[1] in
                                ["start", "continu", "redo", "aep", "rep"];
          repeat
            line := ACE_READ_NEXT_LINE(datarec.stream);
            if invokesEnumeration and
               not IsMatchingSublist(line, "** ERROR") and
               Length(line) > 1 and line[ Length(line) - 1 ] = ')' then
              datarec.enumResult := Chomp(line);
              datarec.stats := ACE_STATS(datarec.enumResult);
            fi;
            Info(InfoACE + InfoWarning, 1, Chomp(line));
          until IsMyLine(line);
        fi;
      fi;

    fi;
  end;

  AddIgnoreOptionsToIgnored := function()
  local ignore, optname, opt;
    ignore := VALUE_ACE_OPTION(optnames, [], "aceignore");
    for optname in ignore do
      opt := rec(name := optname);
      FULL_ACE_OPT_NAME(opt); # sets opt.known and opt.fullname
      Add(ignored, opt.fullname);
    od;
  end;

  if echo > 0 then
    Print(ACEfname, " called with the following options:\n");
    if echo = 2 then
      paramoptnames := RecNames(ACEParameterOptions);
      strategy := "default";
    fi;
  fi;

  nowarnings := VALUE_ACE_OPTION(optnames, false, "acenowarnings");
  ignoreunknown := VALUE_ACE_OPTION(optnames, ACEIgnoreUnknownDefault,
                                    "aceignoreunknown");
  AddIgnoreOptionsToIgnored();

  for optname in newoptnames do
    opt := ACEOptionData(optname); # sets opt.name, opt.known, opt.fullname
                                   # and opt.synonyms
    opt.value := ValueOption(opt.name);
    if echo = 2 then
      paramoptnames := Difference(paramoptnames, opt.synonyms);
      if opt.fullname in ACEStrategyOptions then
        strategy := opt.fullname;
        if IsInt(opt.value) then
          strategy := Concatenation(strategy, String(opt.value));
        elif opt.value and (opt.fullname = "felsch") then
          strategy := "felsch0";     # Hmm! I'd like to do this differently!!
        fi;
      fi;
    fi;
    # We don't pass the NonACEbinOptions options to ACE unless they
    # have a translation (i.e. are fields of ACE_OPT_TRANSLATIONS)
    opt.donotpass := (opt.fullname in NonACEbinOptions) and
                     not (opt.fullname in RecNames(ACE_OPT_TRANSLATIONS));
    opt.ignore := opt.fullname in RecNames(disallowed) or
                  opt.fullname in ignored or
                  (ignoreunknown and not opt.known);
    opt.list := false;
    if opt.value = true then
      # An option detected by GAP as boolean may in fact be a no-value
      # option of ACE ... unknown ACE options detected as being true are
      # assumed to be no-value options (since the user can still over-ride
      # this behaviour by entering values of 0 or 1 explicitly e.g. 
      # ACEStats(... : `opt' := 1) )
      if not opt.known or IsValidOptionValue("") then
        ProcessOption("");
      else
        ProcessOption(1);
      fi; 
    elif opt.value = false then
      ProcessOption(0);
    elif not IsString(opt.value) and IsList(opt.value) then
      opt.list := true;
      ProcessOption(opt.value);
    else
      ProcessOption(opt.value);
    fi;
  od;

  if echo = 2 then
    Print("Other options set via ACE defaults:\n");
    for optname in paramoptnames do
      Print(" ", optname, " := "); 
      if IsRecord(ACEParameterOptions.(optname)) then
        if IsBound(ACEParameterOptions.(optname).(strategy)) then
          Print(ACEParameterOptions.(optname).(strategy), "\n");
        else
          Print(ACEParameterOptions.(optname).default, "\n");
        fi;
      else
        Print(ACEParameterOptions.(optname), "\n");
      fi;
    od;
  fi;

end);

#############################################################################
####
##
#F  PROCESS_ACE_OPTION  . . . . . . . . . . . . . . . . .  Internal procedure
##  . . . . . . . . . . . . . . . . . . . . . process  a  single  ACE  option
##  . . . . . . . . . . . . . . . . . . . . . that  hasn't  been  passed  via
##  . . . . . . . . . . . . . . . . . . . . . . . . .  GAP's option mechanism
##
##  Checks optval is a valid value of optname (which must  be  lowercase  and
##  unabbreviated) and pass it ACE by writing to stream.
##
InstallGlobalFunction(PROCESS_ACE_OPTION, function(stream, optname, optval)
local aceoptname, error;

  # Check that optval is a valid value of optname.
  if IsFunction(KnownACEOptions.(optname)[2]) then
    error := not KnownACEOptions.(optname)[2](optval);
  else
    error := not (optval in KnownACEOptions.(optname)[2]);
  fi;
  
  if error then
    Info(InfoACE + InfoWarning, 1, 
         "ACE Warning: ", optval, ": ",
         "possibly not an allowed value of ", optname);
  fi;

  if optname in RecNames(ACE_OPT_TRANSLATIONS) then
    # The ACE optname differs from the GAP optname
    aceoptname := ACE_OPT_TRANSLATIONS.(optname);
  else
    # The ACE optname is the same as the GAP optname
    aceoptname := optname;
  fi;

  if optval = "" then
    WRITE_LIST_TO_ACE_STREAM(stream, [ aceoptname, ";" ]);
  elif not IsString(optval) and IsList(optval) then
    WRITE_LIST_TO_ACE_STREAM(
        stream, [ aceoptname,":", 
                  JoinStringsWithSeparator( List(optval, String) ), ";" ]
        );
  else
    WRITE_LIST_TO_ACE_STREAM(stream, [ aceoptname, ":", optval, ";" ]);
  fi;

  return error;
end);

#############################################################################
####
##
#F  ACEOptionData . . .  returns a record of the known data of an option name
##
##  For argument optname the fields of the returned record are:
##    name  . . . .  optname (unchanged);
##    known . . . .  true iff optname is a valid mixed case abbreviation of a 
##                   KnownACEOption field;
##    fullname  . .  the lower case unabbreviated  form  of  optname  if  the
##                   `known' field is set `true',  or optname in  lower case, 
##                   otherwise;
##    synonyms  . .  a list of KnownACEOptions fields that are  option  names
##                   synonymous with optname, if the  `known'  field  is  set
##                   set `true', or list with just fullname otherwise;
##    abbrev  . . .  the shortest lowercase abbreviation of  optname  if  the 
##                   `known' field is set `true', or fullname otherwise.
##
InstallGlobalFunction(ACEOptionData, function(optname)
local opt;
  opt := rec(name := optname);
  FULL_ACE_OPT_NAME(opt); # Sets the `known' and `fullname' fields
  if opt.known then
    opt.synonyms := ACE_OPTION_SYNONYMS(opt.fullname);
    opt.abbrev := opt.fullname{[1 ..  KnownACEOptions.(opt.fullname)[1]]};
  else
    opt.synonyms := [ opt.fullname ];
    opt.abbrev := opt.fullname;
  fi;
  return opt;
end);

#############################################################################
####
##
#F  SANITISE_ACE_OPTIONS  . . . . . . . . . . . . . . . .  Internal procedure
##  . . . . . . . . . . . . . . . . . . . . . . . .  Called by SetACEOptions,
##  . . . . . . . . . . . . . . . . . or by CALL_ACE when CALL_ACE is invoked
##  . . . . . . . . . . . . . . . . . by   ACEExample   with   user   options
##
##  Scrubs any option  names  in  optsrec  that match  those  in  newoptsrec,
##  to ensure that *all* new options are at the end of  optsrec  when  it  is 
##  updated with options from newoptsrec.
##
InstallGlobalFunction(SANITISE_ACE_OPTIONS, function(optsrec, newoptsrec)
local newoptnames, optname, opt;
    newoptnames := Concatenation(
                       List(RecNames(newoptsrec),
                            optname -> ACEOptionData(optname).synonyms)
                       );
    for optname in RecNames(optsrec) do
      opt := rec(name := optname);
      FULL_ACE_OPT_NAME(opt); # Sets opt.fullname
      if opt.fullname in newoptnames then
        Unbind(optsrec.(optname));
      fi;
    od;
end);

#############################################################################
####
##
#F  NEW_ACE_OPTIONS()
##
##  Looks at OptionsStack and returns the new options.
##
InstallGlobalFunction(NEW_ACE_OPTIONS, function()
local newoptions, oldoptions, oldnames, optname;
    if IsEmpty(OptionsStack) then
      return rec();
    elif Length(OptionsStack) = 1 then
      return OptionsStack[ Length(OptionsStack) ];
    else
      newoptions := ShallowCopy( OptionsStack[ Length(OptionsStack) ] );
      oldoptions := OptionsStack[ Length(OptionsStack) - 1 ];
      oldnames := RecNames(oldoptions);
      for optname in RecNames(newoptions) do
        if optname in oldnames and 
           oldoptions.(optname) = newoptions.(optname) then
          Unbind( newoptions.(optname) );
        fi;
      od;
      return newoptions;
    fi;
end);

#E  options.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
