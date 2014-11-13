#############################################################################
##
#W  newprofile.g                   GAP Library                  Chris Jefferson
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##  This file contains the gap frontend of profile.c in src.
##


#############################################################################
##
##
##  <#GAPDoc Label="ProfileLineByLine">
##  <ManSection>
##  <Func Name="ProfileLineByLine" Arg="filename,access,repeats"/>
##
##  <Description>
##  <Ref Func="ProfileLineByLine"/> begins GAP recording profiling
##  data to the file <A>filename</A>. <A>access</A> should be one of
##  "w" or "a", to denote if the file should be cleared before writing
##  ("w") or appended to ("a").
##  If <A>repeats</A> is false, GAP will only output each access to a
##  statement once. This makes the file useful for code coverage, but
##  less useful for profiling. If <A>repeats</A> is true, the created
##  file can get VERY large.
##  <P/>
##  Note that <A>repeats</A> is a global setting -- once a line access
##  has been outputted to any profiling file in a GAP session, then
##  it will not be outputted to any future call where <A>repeats</A>
##  is false.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ProfileLineByLine",function(name, access, repeats)
    
    if access <> "w" and access <> "a" then
        Error("access must be \"w\" or \"a\"");
    fi;
    
    return ACTIVATE_PROFILING(name, access, repeats);
end);

#############################################################################
##
##
##  <#GAPDoc Label="UnprofileLineByLine">
##  <ManSection>
##  <Func Name="UnprofileLineByLine" Arg=""/>
##
##  <Description>
##  Stops profiling which was previously started with
##  <Ref Func="ProfileLineByLine"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("UnprofileLineByLine",function()
    return DEACTIVATE_PROFILING();
end);

#############################################################################
##
##
##  <#GAPDoc Label="ActivateProfileColour">
##  <ManSection>
##  <Func Name="ActivateProfileColour" Arg=""/>
##
##  <Description>
##  Called with argument <K>true</K>,
##  <Ref Func="ActivateProfileColour"/>
##  makes GAP colour functions when printing them to show which lines
##  have been executed while profiling was active via
##  <Ref Func="ProfileLineByLine" /> at any time during this GAP session.
##  Passing <K>false</K> disables this behaviour.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
BIND_GLOBAL("ActivateProfileColour",function(b)
    return ACTIVATE_COLOR_PROFILING(b);
end);

#############################################################################
##
##
##  <#GAPDoc Label="ReadLineByLineProfile">
##  <ManSection>
##  <Func Name="ReadLineByLineProfile" Arg="filename"/>
##
##  <Description>
##  <Ref Func="ReadLineByLineProfile"/> reads a previous output of 
##  <Ref Func="ProfileLineByLine"/> (or the concatenation of several runs)
##  and converts it into a pair [l,readd,execd] where l is a list of all the files
##  which were access, and readd and execd are dictionaries, which map each
##  element of l to the lines in l which have statements on, and where
##  statements were executed, respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ReadLineByLineProfile",function(filename)
    local stream, line, eval, readdict, execdict, filelist;
    filelist := Set([]);
    
    readdict := NewDictionary(false, true, IsString);
    execdict := NewDictionary(false, true, IsString);
    stream := InputTextFile(filename);
    line := ReadLine(stream);
    while line <> fail do
        eval := EvalString(line);
        if not(eval.file in filelist) then
            AddSet(filelist, eval.file);
            AddDictionary(readdict, eval.file, Set([]));
            AddDictionary(execdict, eval.file, Set([]));
        fi;
        
        if eval.exec then
            AddSet(LookupDictionary(execdict, eval.file), eval.line);
        else
            AddSet(LookupDictionary(readdict, eval.file), eval.line);
        fi;
        line := ReadLine(stream);
    od;
    CloseStream(stream);
    return [filelist, readdict, execdict];
end);



#############################################################################
##
##
##  <#GAPDoc Label="OutputAnnotatedFiles">
##  <ManSection>
##  <Func Name="OutputAnnotatedFiles" Arg="cover, indir, outdir"/>
##
##  <Description>
##  <Ref Func="OutputAnnotatedFiles"/> takes <A>cover</A> (an output of
##  <Ref Func="ReadLineByLineProfile"/>), and two directory names. It outputs a copy
##  of each file in <A>cover</A> which is contained in <A>indir</A>
##  into <A>outdir</A>, annotated with which lines were executed.
##  <A>indir</A> may also be the name of a single file, in which case
##  only code coverage for that file is produced.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("OutputAnnotatedFiles",function(data, indir, outdir)
    local infile, outname, instream, outstream, line, allLines, 
          coverage, counter, overview, i,
          readlineset, execlineset, outchar, outputtext, 
          outputhtml, outputoverviewhtml;
    
    outputtext := function(lines, coverage, outstream)
      local i, outchar;
      for i in [1..Length(lines)] do
        if coverage[i] = 0 then
          outchar := "  ";
        elif coverage[i] = 1 then
          outchar := "* ";
        elif coverage[i] = 2 then
          outchar := "! ";
        elif coverage[i] = 3 then
          outchar := "- ";
        else
          Error("Internal error");
        fi;
        PrintTo(outstream, outchar, lines[i]);
      od;
    end;
    
    outputhtml := function(lines, coverage, outstream)
      local i, outchar, str;
      PrintTo(outstream, "<html><body>\n",
        "<style>\n",
        ".linenum { text-align: right; border-right: 3px solid #FFFFFF; }\n",
        ".exec { border-right: 3px solid #2EFE2E; }\n",
        ".missed { border-right: 3px solid #FE2E64; }\n",
        ".ignore { border-right: 3px solid #BDBDBD; }\n",
        "}\n",
        "</style>\n",
        "<table cellspacing='0' cellpadding='0'>\n");
      
      for i in [1..Length(lines)] do
        if coverage[i] = 0 then
          outchar := "nocode";
        elif coverage[i] = 1 then
          outchar := "exec";
        elif coverage[i] = 2 then
          outchar := "missed";
        elif coverage[i] = 3 then
          outchar := "ignore";
        else
          Error("Internal error");
        fi;
        
        str := List(lines[i]);
        str := ReplacedString(str, "&", "&amp;");
        str := ReplacedString(str, "<", "&lt;");
        str := ReplacedString(str, " ", "&nbsp;");
        PrintTo(outstream, "<tr>");
        PrintTo(outstream, "<td><p class='linenum ",outchar,"'>",i,"</p></td>");
        PrintTo(outstream, "<td><span><tt>",str,"</tt></span></td>");
        PrintTo(outstream, "</tr>");
      od;
            
      PrintTo(outstream,"</table></body></html>");
    end;
    
    outputoverviewhtml := function(overview, outdir)
      local filename, outstream, codecover, i;
      
      Sort(overview, function(v,w) return v.inname < w.inname; end);
      
      filename := Concatenation(outdir, "/index.html");
      outstream := OutputTextFile(filename, false);
      SetPrintFormattingStatus(outstream, false);
      PrintTo(outstream, "<html><body>\n",
        "<style>\n</style>\n",
        "<table cellspacing='0' cellpadding='0'>\n",
        "<tr><td valign='top'>\n");
      
      for i in [1..Length(overview)] do
        PrintTo(outstream, "<p><a href='",
           Remove(SplitString(overview[i].outname,"/")),
           "'>",overview[i].inname,"</a></p>");
      od;
      
      PrintTo(outstream, "</td><td class='text' valign='top'>");
      
      for i in overview do
        codecover := 1 - (i.readnotexeclines / (i.execlines + i.readnotexeclines));
        # We have to do a slightly horrible thing to get the formatting we want
        codecover := String(Floor(codecover*100.0));
        PrintTo(outstream, "<p>",codecover{[1..Length(codecover)-1]},"% (",
          i.execlines,"/",i.execlines + i.readnotexeclines,")</p>");
      od;
      
      PrintTo(outstream,"</td></tr></table></body></html>");
      CloseStream(outstream);
    end;
    
    overview := [];
    for infile in data[1] do
        if Length(indir) <= Length(infile)
                and indir = infile{[1..Length(indir)]} then
            readlineset := LookupDictionary(data[2], infile);
            execlineset := LookupDictionary(data[3], infile);
            outname := ReplacedString(infile, "/", "_");
            outname := Concatenation(outdir, "/", outname);
            outname := Concatenation(outname, ".html");
            instream := InputTextFile(infile);
            outstream := OutputTextFile(outname, false);
            SetPrintFormattingStatus(outstream, false);
            allLines := [];
            line := ReadLine(instream);
            while line <> fail do
              Add(allLines, line);
              line := ReadLine(instream);
            od;
            CloseStream(instream);
            
            coverage := List([1..Length(allLines)], x -> 0);
            for i in readlineset do
              coverage[i] := 2;
            od;
            for i in execlineset do
              coverage[i] := 1;
            od;
            
            Add(overview, rec(outname := outname, inname := infile,
            execlines := Length(Filtered(coverage, x -> x = 1)),
            readnotexeclines := Length(Filtered(coverage, x -> x = 2))));
            outputhtml(allLines, coverage, outstream);

            CloseStream(outstream);
        fi;
    od;    
    # Output an overview page
    outputoverviewhtml(overview, outdir);
end);
#############################################################################
##
#E

