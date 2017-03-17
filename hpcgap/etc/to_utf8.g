##############################################################################
##  to_utf8.g                                                    Frank Lübeck
##  
##  This files contains a simple utility function which was used to convert the
##  encodings of the files in the GAP distribution to UTF-8. It also corrected 
##  spellings of (mainly) names from pre-latin1 times.
##  
TRANS := [["fuer ","für "],["Schoenert", "Schönert"],
         ["Thei\"sen","Theißen"],["Goetz ","Götz "],["Erzsebet","Erzsébet"],
         ["Araujo","Araújo"],["St. Andrews","St Andrews"],
         ["St.  Andrews","St Andrews"],["Gaehler","Gähler"],
         ["'Akos","Ákos"],["G\"ahler","Gähler"],
         [" Hofling"," Höfling"],[" Hoefling"," Höfling"],
         ["Horvath", "Horváth"],["Erzs'ebet Horv'ath","Erzsébet Horváth"],
         ["L\"ubeck","Lübeck"],[" Luebeck"," Lübeck"],["frank L","Frank L"],
         [" Neunhoeffer"," Neunhöffer"], ["G\"otz ","Götz "],
         ["Ferencz Rakowczi","Ferenc Ràkòczi"],["Sch\"onert","Schönert"],
         ["Akos","Ákos"],["Thei{\\ss}en","Theißen"],[" Theissen"," Theißen"],
         ["Universitaet","Universität"],
         ];

ConvertDirToUTF8 := function(dir)
  local cont, ff, s, u, ss, f, a, notouch;
  notouch := [".in",".shi",".tex",".bib",".dvi",".gz",
             ".zoo",".ps",".msk",".html",
             ];
  cont := DirectoryContents(dir);
  cont := Filtered(cont, f-> f <> "." and f <> "..");
  cont := Filtered(cont, function(f)
    if ForAny(notouch, a-> Length(f) >= Length(a) and 
       f{[Length(f)-Length(a)+1..Length(f)]} = a) then
      return false;
    else
      return true;
    fi;
  end);
  for f in cont do
    ff := Concatenation(dir,"/",f);
    if IsDirectoryPath(ff) then
      ConvertDirToUTF8(ff);
    else
      s := StringFile(ff);
      # try if utf8 (including ascii)
      u := Unicode(s, "utf8");
      if u = fail then
        # then we assume it is latin1
        u := Unicode(s, "latin1");
      fi;
      ss := Encode(u, "utf8");
      # not extremely efficient, but good enough
      for a in TRANS do
        ss := SubstitutionSublist(ss, a[1], a[2]);
      od;
      if ss <> s then
        AppendTo("UTF8LOG","+ ",ff,"\n");
        FileString(ff, ss);
      else
        AppendTo("UTF8LOG","- ",ff,"\n");
      fi;
    fi;
  od;
end;


# after checking out the CVS repository of GAP-dev into /cache/ggg
# the following was done:
##  mkdir /cache/ttt
##  cd /cache/ttt
##  rsync -av /cache/ggg .
##  cd ggg
##  rm -rf pkg mac* cnf bin
##  gapL <path to this file>/to_utf8.g
##  
# and in this GAP session: 
##  
##  ConvertDirToUTF8(".");
# the log file ./UTF8LOG shows which files were changed
#
# afterwards the encoding headers in the following files were changed:
# doc/dev/dev.xml doc/ref/main.xml doc/tut/main.xml  
# dev/DistributionUpdate/maindist/repack.py 

