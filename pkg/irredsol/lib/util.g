############################################################################
##
##  util.g                        IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: util.g,v 1.2 2011/05/07 18:55:55 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#F  DECLARE_IRREDSOL_SYNONYMS
##
##  declare two synonyms, one for UK English, and one for a shorter form
##  
BindGlobal ("DECLARE_IRREDSOL_SYNONYMS", 
     function (name)
          local name2;
          name2 := ReplacedString (name, "Solvable", "Soluble");
          if name2 <> name then
                DeclareSynonym (name2, ValueGlobal (name));
          fi;
          name2 := ShallowCopy (name);
          name2 := ReplacedString (name2, "AbsolutelyIrreducibleSolvable", "AIS");
          name2 := ReplacedString (name2, "IrreducibleSolvable", "IrredSol");
          # name2 := ReplacedString (name2, "PrimitiveSolvable", "PrimSol");
          # name2 := ReplacedString (name2, "Primitive", "Prim");
          # name2 := ReplacedString (name2, "Solvable", "Sol");
          # name2 := ReplacedString (name2, "Matrix", "Mat");
          # name2 := ReplacedString (name2, "Indices", "Inds");
          # name2 := ReplacedString (name2, "Minimal", "Min");
          # name2 := ReplacedString (name2, "Maximal", "Max");
          # name2 := ReplacedString (name2, "Dimension", "Dim");
          # name2 := ReplacedString (name2, "Extension", "Ext");
          # name2 := ReplacedString (name2, "Fingerprint", "Fp");
          if name2 <> name then
                DeclareSynonym (name2, ValueGlobal (name));
          fi;
     end);


############################################################################
##
#F  DECLARE_IRREDSOL_FUNCTION
##
##  Declare global function and synonyms
##  
BindGlobal ("DECLARE_IRREDSOL_FUNCTION", 
     function (name)
          DeclareGlobalFunction (name);
          DECLARE_IRREDSOL_SYNONYMS (name);
     end);

############################################################################
##
#F  DECLAE_IRREDSOL_OBSOLETE
##
##  
##  
BindGlobal ("DECLAE_IRREDSOL_OBSOLETE", 
     function (name, new)
          BindGlobal (name, function (arg)
                Info (InfoWarning, 1, "The function `", name, "' is deprecated. ",
                     "Please use `", new, "' instead.");
                return CallFuncList (ValueGlobal (new), arg);
          end);
     end);


############################################################################
##
#F  CopyListEntries
##
##  replacement for GAP 4.5 kernel function
##  
if not IsBound (CopyListEntries) then
    BindGlobal ("CopyListEntries", 
        function (src, from1, step1, dst, from2, step2, n)
            dst{[from2, from2+step2..from2+(n-1)*step2]} := 
                src{[from1, from1+step1..from1+(n-1)*step1]};
        end);
fi;


############################################################################
##
#E
##
