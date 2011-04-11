#!/usr/bin/env python
import os, sys, fnmatch, os.path
#############################################################################
##
##  $Id$
##
## Argument: path to work on (relative or absolute)
## Requires: files "colorpatterns.txt" and "textbinarypatterns.txt" 
##           in its own directory
## Output  : files with lists of classified files, with relative or 
##           absolute paths dependently on whether the input path
##           was given as relative or absolute
##
if len(sys.argv) < 2 or (len(sys.argv) == 3 and sys.argv[1] != "-d"):
    print """Usage: classifyfiles.py [-d] DIRECTORY
      where DIRECTORY contains a checked out copy of GAP
      The optional -p option makes the script show multiple
      classifications, which may make sense and are ignored without -p.
      This script needs "patternscolor.txt" and "patternstextbinary.txt" 
      in its own directory. Five files are created in the current directory:
            listtextfiles.txt
            listbinaryfiles.txt
            listtextfilesfortools.txt
            listbinaryfilesfortools.txt
            listignoredfiles.txt
      It is guaranteed that the union of these file lists is all the
      non-directory files in DIRECTORY and that the lists are
      disjoint.
"""
    sys.exit(0)

me = os.path.realpath(sys.argv[0])
mypos = os.path.dirname(me)

def readfile(name,allowed):
    res = []
    f = open(name)
    while True:
        line = f.readline()
        if len(line) == 0: break
        line = line.strip()
        if line[0] == "#": continue
        if line[0] in allowed:
            res.append(line)
        else:
            print "Warning: "+name+" contains spurious line:\n"+line
    f.close()
    return res
   
# Read blackwhitegrey patterns:
bwg = readfile(os.path.join(mypos,"patternscolor.txt"),"+-Tt")

# Read textbinarytools patterns:
tb = readfile(os.path.join(mypos,"patternstextbinary.txt"),"TtBb")

def classify(name):
    # returns "+T", "+B", "TT", "TB" or "-"
    # and possibly prints out a warning
    color = ""
    ftype = ""
    for p in bwg:
        if fnmatch.fnmatch(name,p[1:]):
            if p[0] == "-": return "-"
            if p[0] == "+":
                color = "+"
            else:
                color = "T"
            if not(doublecheck): break
    if color == "":
        print 'Warning: "'+name+'" is not classified, assuming it is shipped.'
        color = "+"
    for p in tb:
        if fnmatch.fnmatch(name,p[1:]):
            if p[0] in "tT":
                if ftype == "B":
                    print 'Warning: "'+name+'" is both text and binary!'
                else:
                    ftype = "T"
            else:   # p[0] in "bB":
                if ftype == "T":
                    print 'Warning: "'+name+'" is both text and binary!'
                else:
                    ftype = "B"
            if not(doublecheck): break
    if ftype == "":
        print 'Warning: "'+name+'" is neither text nor binary, assuming text.'
        ftype = "T"
    return color+ftype

doublecheck = (len(sys.argv) == 3)
dirname = os.path.normpath(sys.argv[-1])
dirnamelen = len(dirname)+1

texts = open("listtextfiles.txt","w")
bins = open("listbinaryfiles.txt","w")
textt = open("listtextfilesfortools.txt","w")
bint = open("listbinaryfilesfortools.txt","w")
black = open("listignoredfiles.txt","w")

for root, dirs, files in os.walk(dirname):
    for f in files:
        name = os.path.join(root,f)
        c = classify(name[dirnamelen:])
        if c == "-":
            black.write(name+"\n")
        elif c == "+T":
            texts.write(name+"\n")
        elif c == "+B":
            bins.write(name+"\n")
        elif c == "TT":
            textt.write(name+"\n")
        elif c == "TB":
            textb.write(name+"\n")

texts.close()
bins.close()
textt.close()
bint.close()
black.close()

