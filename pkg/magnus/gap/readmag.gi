#############################################################################
##
#W  readmag.gi           Magnus Client Package                   Steve Linton
##
#H  @(#)$Id: readmag.gi,v 1.1 2000/04/14 09:19:30 sal Exp $
##
#Y  (C) 200 School  Comp. Sci., University of St.  Andrews, Scotland
##
##  This file implements some utility functions useful when GAP is being 
##  used as a client in Magnus packages
##
Revision.readmag_gi :=
    "@(#)$Id: readmag.gi,v 1.1 2000/04/14 09:19:30 sal Exp $";

InstallGlobalFunction(IsWhiteSpaceChar, function( char )
    return char in [' ','\n','\r', CHAR_INT(9)];
end);


InstallGlobalFunction(SkipWS, function( stream )
    local c;
    c := fail;
    while true do
        c := ReadByte( stream );
        if c = fail then
            return fail;
        fi;
        if not IsWhiteSpaceChar(CHAR_INT(c)) then
            return c;
        fi;
    od;
end);
      

InstallGlobalFunction(MagnusReadWord, function(stream, gennames, gens, f)
    local c, word,x,name,p,sgn,exp;
    word := One(f);
    c := SkipWS(stream);
    if c = fail then
        return fail;
    fi;
    c := CHAR_INT(c);
    while true do
        x := One(f);
        if IsAlphaChar(c) then
            name := [c];
            while true do
                c := ReadByte(stream);
                if c = fail then
                    return fail;
                fi;
                c := CHAR_INT(c);
                if IsAlphaChar(c) or IsDigitChar(c) then
                    Add(name, c);
                else 
                    break;
                fi;
            od;
            if IsWhiteSpaceChar(c) then
                c := SkipWS(stream);
                if c = fail then
                    return fail;
                fi;
                c := CHAR_INT(c);
            fi;
            p := Position(gennames,name);
            if p = fail then
                return fail;
            fi;
            x := gens[p];
            if c = '^' then
                c := SkipWS(stream);
                if c = fail then
                    return fail;
                fi;
                c := CHAR_INT(c);
                sgn := 1;
                exp := 0;
                if c = '-' then
                    sgn := -1;
                    c := ReadByte(stream);
                    if c = fail then
                        return fail;
                    fi;
                    c := CHAR_INT(c);
                fi;
                if not IsDigitChar(c) then
                    return fail;
                fi;
                while true do
                    exp := 10*exp + INT_CHAR(c) - INT_CHAR('0');
                    c := ReadByte(stream);
                    if c = fail then
                        return fail;
                    fi;
                    c := CHAR_INT(c);
                    if not IsDigitChar(c) then
                        break;
                    fi;
                od;
                x := x^(sgn*exp);
            fi;
            Info(InfoMagnus,2,"syllable ",x);
            word := word*x;
        fi;
        if IsWhiteSpaceChar(c) then
            c := SkipWS(stream);
            if c = fail then
                return fail;
            fi;
            c := CHAR_INT(c);
        fi;
        if not IsAlphaChar(c) and not c = '1' then
            break;
        fi;
    od;
    return [c,word];
end);


InstallGlobalFunction(MagnusReadFPGroup, function(stream)
    local c, gennames, name, f, x, gens, g, rels, exp, sgn, rel, p;
    c := SkipWS(stream);
    if c = fail then
        return c;
    fi;
    c := CHAR_INT(c);
    if c <> '<' then 
        return fail;
    fi;
    gennames := [];
    c := fail;
    while true do
       c := SkipWS(stream);
       if c = fail then
           return c;
       fi;
       c := CHAR_INT(c);
       if IsAlphaChar(c) then
           name := [c];
           while true do
               c := ReadByte(stream);
               if c = fail then
                   return fail;
               fi;
               c := CHAR_INT(c);
               if IsAlphaChar(c) or IsDigitChar(c) then
                   Add(name, c);
               else 
                   break;
               fi;
           od;
           ConvertToStringRep(name);
           Add(gennames, name);
       else
           return fail;
       fi;
       Info(InfoMagnus,1, "generator ",name);
       if IsWhiteSpaceChar(c) then
           c := SkipWS(stream);
           if c = fail then
               return fail;
           fi;
           c := CHAR_INT(c);
       fi;
       if c = ';' then
           break;
       fi;
       if c <> ',' then
           return fail;
       fi;
   od;
   
   f := FreeGroup(gennames);
   gens := GeneratorsOfGroup(f);
   rels := [];
   while true do
       x := MagnusReadWord(stream, gennames, gens, f);
       if x = fail then
           return fail;
       fi;
       Add(rels,x[2]);
       c := x[1];
       Info(InfoMagnus,1, "relator ",rel);
       if c = '>' then
           break;
       fi;
   od;
   g := f/rels;
   return [g, gennames];
end);


InstallGlobalFunction(MagnusReadWordList,function(stream, g, names)
    local c,gens,w,words;
    c := SkipWS(stream);
    if c = fail then
        return fail;
    fi;
    c := CHAR_INT(c);
    if c <> '{' then
        return fail;
    fi;
    words := [];
    gens := GeneratorsOfGroup(g);
    while true do
        w := MagnusReadWord( stream, names, gens, g);
        Info(InfoMagnus,1, "word ",w[2]," next ",w[1]);
        if w = fail then
            return fail;
        fi;
        c := w[1];
        Add(words, w[2]);
        if c = '}' then
            break;
        fi;
        if c <> ',' then
            return fail;
        fi;
    od;
    return words;
end);
            
    