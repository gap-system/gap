
############  here we provide some text themes to display the text
############  versions of GAPDoc manuals 

GAPDoc2TextProcs.OtherThemes := rec();

# components must be pairs of strings, but as abbreviations we allow
# - a string a starting with TextAttr.CSI for [a, TextAttr.reset]
# - another string a for [a, a]
GAPDoc2TextProcs.OtherThemes.default := rec(
  info := "the default theme",
  reset := TextAttr.reset,
  Heading := Concatenation(TextAttr.normal, TextAttr.underscore),
  Func := Concatenation(TextAttr.normal, TextAttr.4),
  Arg := Concatenation(TextAttr.normal, TextAttr.2),
  Example := Concatenation(TextAttr.normal, TextAttr.0),
  Package := TextAttr.bold,
  Returns := TextAttr.normal,
  URL := TextAttr.6,
  Mark := Concatenation(TextAttr.bold, TextAttr.5),
  K := Concatenation(TextAttr.normal, TextAttr.1),
  C := Concatenation(TextAttr.normal, TextAttr.1),
  F := Concatenation(TextAttr.normal, TextAttr.6),
  B := ["<", ">"],
  Emph := Concatenation(TextAttr.bold, ""),
  Ref := TextAttr.6,
  BibReset := TextAttr.reset,
  BibAuthor := Concatenation(TextAttr.bold, TextAttr.1),
  BibTitle := TextAttr.4,
  BibJournal := ["",""],
  BibVolume := TextAttr.4,
  BibLabel := TextAttr.5,
  Q := ["\"","\""],
  M := ["",""],
  Math := ["$","$"],
  Display := ["",""],
  Prompt := Concatenation(TextAttr.bold,TextAttr.4),
  BrkPrompt := Concatenation(TextAttr.bold,TextAttr.1),
  GAPInput := TextAttr.1,
  GAPOutput := TextAttr.reset,
  DefLineMarker := "\342\200\243 ",
  # must be two visible characters long
  ListBullet := " \342\200\242",
  # must be together two visible characters long
  EnumMarks := [" ","."],
  FillString := "\342\224\200\342\224\200\342\224\200",
  format := "",
  flush := "both",
);

GAPDoc2TextProcs.OtherThemes.classic := rec(
  info := "similar to GAPDoc default until GAP 4.4",
  reset := TextAttr.reset,
  Heading := Concatenation(TextAttr.bold, TextAttr.underscore, TextAttr.1),
  Func := Concatenation(TextAttr.bold, TextAttr.4),
  Arg := Concatenation(TextAttr.normal, TextAttr.4),
  Example := Concatenation(TextAttr.normal, TextAttr.5),
  Package := TextAttr.bold,
  Returns := TextAttr.bold,
  URL := TextAttr.4,
  Mark := Concatenation(TextAttr.bold, TextAttr.5),
  K := Concatenation(TextAttr.normal, TextAttr.2),
  C := Concatenation(TextAttr.normal, TextAttr.2),
  F := Concatenation(TextAttr.bold, ""),
  B := Concatenation(TextAttr.bold, TextAttr.b6),
  Emph := Concatenation(TextAttr.normal, TextAttr.6),
  Ref := TextAttr.bold,
  BibReset := TextAttr.reset,
  BibAuthor := Concatenation(TextAttr.bold, TextAttr.1),
  BibTitle := TextAttr.4,
  BibJournal := ["",""],
  BibVolume := TextAttr.4,
  BibLabel := TextAttr.5,
  Q := ["\"","\""],
  M := ["",""],
  Math := ["$","$"],
  Display := ["",""],
  Prompt := Concatenation(TextAttr.bold,TextAttr.4),
  BrkPrompt := Concatenation(TextAttr.bold,TextAttr.1),
  GAPInput := TextAttr.1,
  GAPOutput := TextAttr.reset,
  DefLineMarker := "> ",
  # must be two visible characters long
  ListBullet := "--", 
  # must be together two visible characters long
  EnumMarks := [" ","."],
  FillString := "------",
  format := "",
  flush := "both",
);

GAPDoc2TextProcs.OtherThemes.old := rec(
  info := "similar to old style manuals in GAP 3 and GAP 4.4",
  reset := "", 
  Heading := ["",""],
  Func := ["`","'"],
  Arg := ["<", ">"],
  Example := ["",""],
  Package := ["",""],
  Returns := ["",""],
  URL := ["<",">"],
  Mark := ["",""],
  K := ["`","'"],
  C := ["`","'"],
  F := ["`","'"],
  B := ["",""],
  Q := ["\"","\""],
  Emph := ["*","*"],
  Ref := ["\"","\""],
  BibReset := "",
  BibAuthor := ["",""],
  BibTitle := ["",""],
  BibJournal := ["",""],
  BibVolume := ["",""],
  BibLabel := ["",""],
  M := ["$", "$"],
  Math := ["$", "$"],
  Display := ["$$","$$"],
  Prompt := "",
  BrkPrompt := "",
  GAPInput := "",
  GAPOutput := "",
  DefLineMarker := "> ",
  # must be two visible characters long
  ListBullet := " -",
  # must be together two visible characters long
  EnumMarks := [" ","."],
  FillString := "---",
  format := "",
  flush := "both"
);
GAPDoc2TextProcs.OtherThemes.equalquotes := rec(
  info := "(together with \"old\") uses '...' instead of `...'", 
  C := "'",
  F := "'",
  K := "'",
  Func := "'"
);


GAPDoc2TextProcs.OtherThemes.none := rec();
GAPDoc2TextProcs.f := function()
  local dt, a;
  dt := GAPDoc2TextProcs.OtherThemes.default;
  # most empty, some copied from default
  for a in RecNames(dt) do
    GAPDoc2TextProcs.OtherThemes.none.(a) := "";
  od;
  for a in ["Q", "DefLineMarker", "ListBullet", "FillString", "EnumMarks"] do
    GAPDoc2TextProcs.OtherThemes.none.(a) := dt.(a);
  od;
  GAPDoc2TextProcs.OtherThemes.none.info := "plain text without markup";
end;
GAPDoc2TextProcs.f();
Unbind(GAPDoc2TextProcs.f);

GAPDoc2TextProcs.OtherThemes.ColorPrompt := rec(
  info := "show examples in ColorPrompt(true) style (default)",
  Prompt := Concatenation(TextAttr.bold,TextAttr.4),
  BrkPrompt := Concatenation(TextAttr.bold,TextAttr.1),
  GAPInput := TextAttr.1,
  GAPOutput := TextAttr.reset
);

GAPDoc2TextProcs.OtherThemes.noColorPrompt := rec(
  info := "show examples in ColorPrompt(false) style",
  Prompt := "",
  BrkPrompt := "",
  GAPInput := "",
  GAPOutput := ""
);

GAPDoc2TextProcs.OtherThemes.justify := rec(
  info := "left-right justify paragraphs (default)",
  flush := "left",
);
GAPDoc2TextProcs.OtherThemes.raggedright := rec(
  info := "do not left-right justify paragraphs",
  flush := "left",
);

InstallValue(GAPDocTextTheme, rec());

# this is only relevant for HPCGAP, record is used by the handler functions
# in the GAP help system
if IsBound(HPCGAP) then
  LockAndMigrateObj(GAPDocTextTheme, HELP_REGION);
fi;

# argument doesn't need all component, the missing ones are taken from default
InstallGlobalFunction(SetGAPDocTextTheme, function(arg)
  local r, res, h, af, v, a, nam, f, i;
  
  r := rec();
  for a in arg do
    if IsString(a) then
      if not IsBound(GAPDoc2TextProcs.OtherThemes.(a)) then
        Print("Only the following named text themes are available \
(choose one or several):\n");
        for nam in RecNames(GAPDoc2TextProcs.OtherThemes) do
          Print("  ",String(Concatenation("\"",nam,"\""), -25),
                GAPDoc2TextProcs.OtherThemes.(nam).info, "\n");
        od;
        return;
      else
        for f in RecNames(GAPDoc2TextProcs.OtherThemes.(a)) do
          r.(f) := GAPDoc2TextProcs.OtherThemes.(a).(f);
        od;
      fi;
    else
      for f in RecNames(a) do
        r.(f) := a.(f);
      od;
    fi;
  od;

  res := rec(hash := [[], []]);
  h := res.hash;
  af := GAPDoc2TextProcs.TextAttrFields;
  for i in [1..Length(af)] do
    if IsBound(r.(af[i])) then
      v := r.(af[i]);
    else
      v := GAPDoc2TextProcs.OtherThemes.default.(af[i]);
    fi;
    if IsString(v) then
      Add(h[1], Concatenation(String(i-1), "X"));
      Add(h[2], v);
      Add(h[1], Concatenation(String(100+i-1), "X"));
      if Length(v) > 1 and v{[1,2]} = TextAttr.CSI then
        Add(h[2], TextAttr.reset);
      else
        Add(h[2], v);
      fi;
    else
      Add(h[1], Concatenation(String(i-1), "X"));
      Add(h[2], v[1]);
      Add(h[1], Concatenation(String(100+i-1), "X"));
      Add(h[2], v[2]);
    fi;
    res.(af[i]) := [[h[1][2*i-1], h[1][2*i]],[h[2][2*i-1], h[2][2*i]]];
  od;
  SortParallel(h[1], h[2]);
  if IsBoundGlobal("HPCGAP") then
    # in HPCGAP `GAPDocTextTheme` and its entries must be visible to
    # all threads
    atomic HELP_REGION do
      for f in RecNames(res) do
        GAPDocTextTheme.(f) := CopyToRegion(res.(f), HELP_REGION);
      od;
    od;
  else
    for f in RecNames(res) do
      GAPDocTextTheme.(f) := res.(f);
    od;
  fi;
end);
SetGAPDocTextTheme(rec());

