#############################################################################
##
#W  ComposeXML.gi                GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
## The files ComposeXML.gi/.gd contain a function which allows to construct
## a GAPDoc-XML document from several source files.
## These tools can also be used for collection/extracting other types of 
## documents.
##  

##  <#GAPDoc Label="ComposedDocument">
##  <ManSection >
##  <Func Arg="tagname, path, main, source[, info]" Name="ComposedDocument" />
##  <Func Arg="path, main, source[, info]" Name="ComposedXMLString" />
##  <Returns>a document as string, or a list with this string and
##  information about the source positions</Returns>
##  <Description>
##  
##  The argument <A>tagname</A> is the string used for the pseudo elements
##  which mark the pieces of a document to collect. (In <Ref Sect="DistrConv"/>
##  we used <C>GAPDoc</C> as <A>tagname</A>. The second function
##  <Ref Func="ComposedXMLString"/><C>( ... )</C> is an abbreviation for
##  <Ref Func="ComposedDocument"/><C>("GAPDoc", ... )</C>.<P/>
##  
##  The  argument <A>path</A>  must be  a  path to  some directory  (as
##  string or  directory object),  <A>main</A> the name  of a  file and
##  <A>source</A> a list  of file names. These file  names are relative
##  to <A>path</A>,  except they  start with  <C>"/"</C> to  specify an
##  absolute  path or  they  start with  <C>"gap://"</C>  to specify  a
##  file  relative  to the  &GAP;  roots  (see <Ref  Func="FilenameGAP"
##  />). The  document is  constructed via  the mechanism  described in
##  Section&nbsp;<Ref Sect="DistrConv"/>.<P/>
##  
##  First  the   files  given   in  <A>source</A>  are   scanned  for
##  chunks of the document marked  by <C>&lt;#<A>tagname</A>
##  Label="..."></C> and  <C>&lt;/#<A>tagname</A>></C> pairs.  
##  Then the file <A>main</A> is read and all <C>&lt;#Include  ...
##  ></C>-tags are  substituted recursively by other  files or chunks
##  of documentation found in the first step, respectively.<P/>
##  
##  If  the  optional  argument  <A>info</A>   is  given  and  set  to
##  <K>true</K>  this function  returns a  list <C>[str,  origin]</C>,
##  where <C>str</C> is a string  containing the composed document and
##  <C>origin</C> is  a sorted  list of entries  of the  form <C>[pos,
##  filename, line]</C>.  Here <C>pos</C>  runs through  all character
##  positions of starting lines or text pieces from different files in
##  <C>str</C>.  The  <C>filename</C>  and  <C>line</C>  describe  the
##  origin of this part of the collected document.<P/>
##  
##  Without the fourth argument only the string <C>str</C> is returned.
##  <P/>
##  
##  By default <Ref Func="ComposedDocument"/> runs  into an error if an
##  <C>&lt;#Include ...></C>-tag cannot be  substituted (because a file
##  or  chunk is  missing). This  behaviour can  be changed  by setting
##  <C>DOCCOMPOSEERROR  :=  false;</C>.  Then  the  missing  parts  are
##  substituted by a short note about  what is missing. Of course, this
##  feature is  only useful if  the resulting  document is a  valid XML
##  document (e.g., when the missing  pieces are complete paragraphs or
##  sections).<P/>
##  
##  <Log>
##  gap> doc := ComposedDocument("GAPDoc", "/my/dir", "manual.xml", 
##  > ["../lib/func.gd", "../lib/func.gi"], true);;
##  </Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# reset this if not found files or chunks should not run into an error
DOCCOMPOSEERROR := true;
InstallGlobalFunction(ComposedDocument, function(arg)
  local path, main, source, info, tagname, btag, etag,
        pieces, origin, fname, str, posnl, i, j, pre, pos, name, piece, 
        b, len, Collect, res, src, f, a, usedpieces, lenb, NormalizedFilename;
  # get arguments, 5th arg is optional for compatibility with older versions
  tagname := arg[1];
  btag := Concatenation("<#", tagname, " Label=\"");
  lenb := Length(btag);
  etag := Concatenation("<#/", tagname, ">");
  path := arg[2];
  main := arg[3];
  source := arg[4];
  if Length(arg) > 4 and arg[5] = true then
    info := true;
  else
    info := false;
  fi;
  if IsString(path) then
    path := Directory(path);
  fi;
  # utility
  NormalizedFilename := function(str)
    local res;
    if Length(str) > 6 and str{[1..6]} = "gap://" then
      res := FilenameGAP(str);
    elif Length(str) = 0 or str[1] <> '/' then
      res := Filename(path, str);
    else
      res := str;
    fi;
    if res = fail then
      res := str;
    fi;
    return res;
  end;
  # first we fetch the chunks from the source files
  pieces := rec();
  origin := rec();
  for f in source do
    fname := NormalizedFilename(f);
    Info(InfoGAPDoc, 2, "#I ComposedDocument: Searching for chunks in ",
                          fname, "\n");
    str := StringFile(fname);
    if str = fail then
      Info(InfoGAPDoc, 1, "#W WARNING: no file ", fname, 
                          " to compose document.\n");
      continue;
    fi;
    posnl := Positions(str, '\n');
    i := PositionSublist(str, btag);
    while i <> fail do
      j := i-1;
      while j > 0 and str[j] <> '\n' do
        j := j-1;
      od;
      pre := str{[j+1..i-1]};
      pos := Position(str, '\"', i+lenb-1);
      if pos=fail then
        Error(f, ": File ends within <#", tagname, " tag.\n");
      fi;     
      name := str{[i+lenb..pos-1]};
      i := Position(str, '\n', pos);
      if i=fail then
        Error(f, ": File ends within <#", tagname, " piece.\n");
      fi;
      pos := PositionSublist(str, etag, i);
      if pos=fail then
        Error(f, ": File ends within <#", tagname, " piece.\n");
      fi;
      while str[pos-1] <> '\n' do
        pos := pos-1;
      od;
      piece := SplitString(str{[i+1..pos-1]}, "\n", "");
      for a in [1..Length(piece)] do 
        b := 1;
        len := Minimum(Length(piece[a]), Length(pre));
        while b <= len and pre[b] = piece[a][b] do
          b := b+1;
        od;
        if b > 1 then
          piece[a] := piece[a]{[b..Length(piece[a])]};
        fi;
      od;
      for a in piece do 
        Add(a, '\n'); 
      od;
      Info(InfoGAPDoc, 3, "Found piece ", name, "\n");
      if IsBound(pieces.(name)) then
        Info(InfoGAPDoc, 1, "#W WARNING: overwriting piece with label \"",
             name,"\"\n#W   Previous occurrence: ",origin.(name)[1],
             " line ", origin.(name)[2],"\n",
             "#W   New occurrence: ",fname," line ",PositionSorted(posnl,
             i+1),"\n");
      fi;
      pieces.(name) := Concatenation(piece);
      # for each found piece store the filename and number of the first
      # line of the piece in that file
      origin.(name) := [fname, PositionSorted(posnl, i+1)];
      i := PositionSublist(str, btag, pos);
    od;
  od;

  # we do some bookkeeping which pieces are actually used
  usedpieces := [];
  
  # recursive substitution of files and chunks from above
  # In this helper [cont, from] is a pair [piece, orig] from above
  # or a pair [filename, 0].
  Collect := function(res, src, cont, from)
    local posnl, pos, i, len, new, p, j, piece, fname;
    # if piece is a whole file we simulate info as in 'pieces'
    if from = 0 then
      fname := cont;
      cont := StringFile(fname);
      if cont = fail and DOCCOMPOSEERROR = true then
        Error("Cannot include file ", fname, ".\n");
      elif cont = fail then
        cont := Concatenation("MISSING FILE ", fname, "\n");
        from := [fname, 1];
      else
        from := [fname, 1];
      fi;
    fi;
    posnl := Positions(cont, '\n');
    pos := 0;
    while pos <> fail do
      i := PositionSublist(cont, "<#Include ", pos);
      if i = fail then
        # in this case add the rest to res
        i := Length(cont) + 1;
      fi;
      len := Length(res);
      new := cont{[pos+1..i-1]};
      Append(res, new);
      p := PositionSorted(posnl, pos+1) + from[2] - 1;
      # add entry to 'src' for first character from current piece
      Add(src, [len+1, from[1], p]);
      j := Position(new, '\n');
      while j <> fail and j < Length(new) do
        # further entries to 'src' for each new line in current piece
        Add(src, [len+j+1, from[1], p+1]);
        j := Position(new, '\n', j);
        p := p+1;
      od;
      # now include by recursive call of this function
      if i <= Length(cont) then
        pos := Position(cont, '>', i);
        if pos = fail then
          Error("Input ends within <#Include ... tag.");
        fi;
        piece := SplitString(cont{[i+9..pos-1]}, "", "\"= ");
        if piece[1]="SYSTEM" then
          Collect(res, src, NormalizedFilename(piece[2]), 0);
        elif piece[1]="Label" then 
          if not IsBound(pieces.(piece[2])) and DOCCOMPOSEERROR=true then
            Error("Did not find chunk ", piece[2]);
          elif not IsBound(pieces.(piece[2])) then
            pieces.(piece[2]) := Concatenation("MISSING CHUNK ", piece[2]);
            origin.(piece[2]) := [Concatenation("MISSINGCHUNK ",piece[2]),1]; 
          fi;
          Add(usedpieces, piece[2]);
          Collect(res, src, pieces.(piece[2]), origin.(piece[2]));
        fi;
      else
        pos := fail;
      fi;
    od;
  end;
  res := "";
  src := [];
  # now start the recursion as #Include of the main file in empty string
  Collect(res, src, NormalizedFilename(main), 0);
  Info(InfoGAPDoc, 2, "#I Labels of chunks which were not used: ",
                      Difference(RecNames(pieces), usedpieces), "\n");
  if info then
    return [res, src];
  else
    # we allow this for compatibility with former versions
    return res;
  fi;
end);
InstallGlobalFunction(ComposedXMLString, function(arg)
  return CallFuncList(ComposedDocument, Concatenation(["GAPDoc"], arg));
end);
##  <#GAPDoc Label="OriginalPositionDocument">
##  <ManSection >
##  <Func Arg="srcinfo, pos" Name="OriginalPositionDocument" />
##  <Returns>A pair <C>[filename, linenumber]</C>.</Returns>
##  <Description>
##  Here <A>srcinfo</A>  must   be  a   data  structure  as   returned  as
##  second   entry   by <Ref  Func="ComposedDocument"  />   called   with
##  <A>info</A>=<K>true</K>. It returns for a given position <A>pos</A> in
##  the composed document the file name and line number from which that
##  text was collected.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(OriginalPositionDocument, function(srcinfo, pos)
  local r;
  r := PositionSorted(srcinfo, [pos]);
  if not IsBound(srcinfo[r]) or srcinfo[r][1] > pos then
    r := r-1;
  fi;
  return [srcinfo[r][2], srcinfo[r][3]];
end);

##  Utility for file names
##  <#GAPDoc Label="FilenameGAP"/>
##  <ManSection >
##  <Func Arg="fname" Name="FilenameGAP"/>
##  <Returns>file name as string or fail</Returns>
##  <Description>
##  
##  This functions  returns the full path  of a file with  name <A>fname</A>
##  relative to a  &GAP; root path, or  <K>fail</K> if such a  file does not
##  exist. The  argument <A>fname</A> can  optionally start with  the prefix
##  <C>"gap://"</C> which will be removed.
##  
##  <Log>
##  gap> FilenameGAP("hsdkfhs.g");
##  fail
##  gap> FilenameGAP("lib/system.g");
##  "/usr/local/gap4/lib/system.g"
##  gap> FilenameGAP("gap://lib/system.g");
##  "/usr/local/gap4/lib/system.g"
##  </Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(FilenameGAP, function(fpath)
  if Length(fpath) > 5 and fpath{[1..6]} = "gap://" then
    fpath := fpath{[7..Length(fpath)]};
  fi;
  return Filename(List(GAPInfo.RootPaths, Directory), fpath);
end);

