#!/usr/bin/env python
# -*- coding: ISO-8859-1 -*-
##  repack.py                                            Frank Lübeck
##  
##  Utility for creating several archive formats from one of them.
##  
##  $Id: repack.py,v 1.9 2008/06/23 14:27:37 gap Exp $


import sys, os, string, tempfile

usage = """Usage: 

     repack.py  <arch><ext> [-t] [-all] [-q]

where <ext> must be one of ".tar.gz", ".tar.bz2", ".zoo", or "-win.zip" and
<arch><ext> is an archive file of the corresponding type.

Then this program produces the archives of the remaining three types.
If the option -all is given then all four types of archives are (re)created
(e.g., to get a better compression, which is set to a maximum by this
program).

With the -q option the program doesn't print progress reports.
Unfortunately, there are no options to (un)zoo and (un)zip to get them 
quiet.

The ".zoo" and "-win.zip" archives contain information which files are text
files and introduce the correct line breaks depending on the operating
system. 

The text files are determined as follows:
- if the -t option is given, they are read from standard input assuming that
  the file names are separated by whitespace
Otherwise:
- if the given archive is of type ".zoo", then the files with a "|!TEXT!"
  comment are taken as text files
- otherwise those files with one of the following extensions are considered
  as text files: ".g", ".c", ".h", ".gi", ".gd", ".htm", ".txt", ".tex",
  ".bib", ".xml", ".gap", ".bib", ".tst", ".css", ".html"

This program assumes that the following programs are available:
- unzoo  (version from GAP distribution)
- zoo
- zip
- tar  (GNU version)
- gzip
- bzip2
- find  (GNU version)
- rm, mv, cd 
- python  (since this is a python program)
"""

ext = ''

quiet = '-q' in sys.argv

if len(sys.argv) < 2:
  print usage;
  sys.exit(22)

arch = sys.argv[1]

if len(sys.argv) > 2 and sys.argv[2] == '-t':
  txtfilesfromstdin = 1
else:
  txtfilesfromstdin = 0

if len(arch) > 3 and arch[-4:] == '.zoo':
  ext = '.zoo'
  arch = arch[0:-4]
elif len(arch) > 6 and arch[-7:] == '.tar.gz':
  ext = '.tar.gz'
  arch = arch[0:-7]
elif len(arch) > 7 and arch[-8:] == '.tar.bz2':
  ext = '.tar.bz2'
  arch = arch[0:-8]
elif len(arch) > 8 and arch[-8:] == '-win.zip':
  ext = '-win.zip'
  arch = arch[0:-8]

archbase = os.path.basename(arch)

if len(ext) == 0:
  print usage
elif not quiet:
  print 'Converting from archive  '+arch+ext

# getting the list of text files (and macbinary files if from zoo archive)
def selext(list, exts):
  res = [];
  for a in list:
    if os.path.splitext(a)[1] in exts:
      res.append(a)
  return res
  
textexts = [".g", ".c", ".h", ".gi", ".gd", ".htm", ".txt", ".tex", ".bib", 
            ".xml", ".gap", ".bib", ".tst", ".css", ".html" ]
textfiles = []
macbinfiles = []
if txtfilesfromstdin:
  textfiles = sys.stdin.read().split()
  if not quiet:
    print 'Got list of textfiles from input.'
elif ext == '.zoo':
  # get it from the zoo comments
  (inf,outf) = os.popen2('unzoo -v '+arch+'.zoo')
  inf.close()
  res = outf.read()
  outf.close()
  res = res.split('\n')
  for i in range(len(res)):
    if res[i] == '# !TEXT!':
      l = res[i-1]
      pos = string.find(l, ':')
      pos = string.find(l, ':', pos+1)
      end = string.rfind(l, ';')
      textfiles.append(l[pos+6:end])
    elif res[i] == '# !MACBINARY!':
      l = res[i-1]
      pos = string.find(l, ':')
      pos = string.find(l, ':', pos+1)
      end = string.rfind(l, ';')
      macbinfiles.append(l[pos+6:end])
  if not quiet:
    print 'Got list of text files from zoo archive.'
elif ext == '.tar.gz':
  (inf,outf) = os.popen2('tar tzf '+arch+'.tar.gz')
  inf.close()
  res = outf.read()
  outf.close()
  if not quiet:
    print 'Got list of text files from tar.gz archive by file extensions.'

  textfiles = selext(res.split('\n'), textexts)
elif ext == '.tar.bz2':
  (inf,outf) = os.popen2('tar tjf '+arch+'.tar.bz2')
  inf.close()
  res = outf.read()
  outf.close()
  textfiles = selext(res.split('\n'), textexts)
  if not quiet:
    print 'Got list of text files from tar.bz2 archive by file extensions.'
elif ext == '-win.zip':
  (inf,outf) = os.popen2('unzip -qql '+arch+'-win.zip')
  inf.close()
  res = outf.read()
  outf.close()
  res = res.split('\n')
  for l in res:
    pos = string.find(l, ':')
    textfiles.append(l[pos+6:])
  textfiles = selext(textfiles, textexts)
  if not quiet:
    print 'Got list of text files from zip archive by file extensions.'


# create local directory for unpacking
tempfile.tempdir = './'
tmpdir = tempfile.mktemp()
os.mkdir(tmpdir)
if os.system('cp -p '+arch+ext+' '+tmpdir):
  sys.stderr.write('Cannot copy archive to temporary directory '+tmpdir+'.\n')
  sys.exit(15)
# now unpack
if ext == '.zoo':
  if os.system('cd '+tmpdir+'; umask 022; unzoo -x '+archbase+ext+' > /dev/null  2>&1 '):
    sys.stderr.write('Cannot unpack zoo file in '+tmpdir+'\n')
    sys.exit(1)
  if not quiet:
    print 'Unpacked the zoo archive.'
elif ext == '.tar.gz':
  if os.system('cd '+tmpdir+'; tar xpzf '+archbase+ext):
    sys.stderr.write('Cannot unpack tar.gz file in '+tmpdir+'\n')
    sys.exit(2)
  if not quiet:
    print 'Unpacked the tar.gz archive.'
elif ext == '.tar.bz2':
  if os.system('cd '+tmpdir+'; tar xpjf '+archbase+ext):
    sys.stderr.write('Cannot unpack tar.bz2 file in '+tmpdir+'\n')
    sys.exit(3)
  if not quiet:
    print 'Unpacked the tar.bz2 archive.'
elif ext == '-win.zip':
  if os.system('cd '+tmpdir+'; umask 022; unzip -a -q '+archbase+ext):
    sys.stderr.write('Cannot unpack zip file in '+tmpdir+'\n')
    sys.exit(4)
  if not quiet:
    print 'Unpacked the -win.zip archive.'

os.unlink(tmpdir+'/'+archbase+ext)

if '-all' in sys.argv:
  ext = ''
  if not quiet:
    print 'Will also recreate the given archive.'

# collect names of non-text files 
try:
  (inf,outf) = os.popen2('cd '+tmpdir+'; find * -print0')
  inf.close()
  res = outf.read()
  outf.close()
  res = res.split('\000')
  binfiles = filter(lambda nam: os.path.isfile(os.path.join(tmpdir, nam)) and \
                    not nam in textfiles and not nam in macbinfiles, res)
except:
  sys.stderr.write('Cannot get names of binary files for zip archive.\n')
  sys.exit(11)
if not quiet:
  print 'Found names of non-text files.'

# now repack into the other formats
if os.system('cd '+tmpdir+'; umask 022; tar cf '+archbase+'.tar *'):
  sys.stderr.write('Cannot create new tar file in '+tmpdir+'\n')
  sys.exit(5)
  if not quiet:
    print 'Created new tar archive.'

if ext <> '.tar.gz':
  if os.system('rm -f '+arch+'.tar.gz'):
    sys.stderr.write('Cannot delete existing file '+arch+'.tar.gz')
    sys.exit(17)
  if os.system('cp '+tmpdir+'/'+archbase+'.tar '+arch+'.tar; gzip -9 '+
               arch+'.tar'):
    sys.stderr.write('Cannot gzip the tar file '+arch+'.tar\n')
    sys.exit(6)
  if not quiet:
    print 'Created tar.gz archive.'
if ext <> '.tar.bz2':
  if os.system('rm -f '+arch+'.tar.bz2'):
    sys.stderr.write('Cannot delete existing file '+arch+'.tar.bz2')
    sys.exit(18)
  if os.system('cp -p '+tmpdir+'/'+archbase+'.tar '+arch+
               '.tar; bzip2 -9 '+arch+'.tar'):
    sys.stderr.write('Cannot bzip2 the tar file '+arch+'.tar\n')
    sys.exit(7)
  if not quiet:
    print 'Created tar.bz2 archive.'

os.unlink(tmpdir+'/'+archbase+'.tar')

if ext <> '.zoo':
  if os.system('rm -f '+arch+'.zoo'):
    sys.stderr.write('Cannot delete existing file '+arch+'.zoo')
    sys.exit(19)
  # this is different from earlier versions of this script, now files and
  # comments are added at the same time, this can make the 'unzoo'ing 
  # dramatically faster
  for fn in textfiles:
    if os.system('cd '+tmpdir+"; (echo '!TEXT!'; echo '/END')|zoo aqhc  "+
                 archbase+'.zoo "'+fn+'" 2> /dev/null'):
      sys.stderr.write('Cannot add comment to file '+tmpdir+'/'+archbase+\
                       '.zoo\n')
      sys.exit(20)
  for fn in binfiles:
    if os.system('cd '+tmpdir+"; (echo '!BINARY!'; echo '/END')|zoo aqhc  "+
                 archbase+'.zoo "'+fn+'" 2> /dev/null'):
      sys.stderr.write('Cannot add comment to file '+tmpdir+'/'+archbase+\
                       '.zoo\n')
      sys.exit(9)
  for fn in macbinfiles:
    if os.system('cd '+tmpdir+"; (echo '!MACBINARY!'; echo '/END')|zoo aqhc  "+
                 archbase+'.zoo "'+fn+'" 2> /dev/null'):
      sys.stderr.write('Cannot add comment to file '+tmpdir+'/'+archbase+\
                       '.zoo\n')
      sys.exit(24)
  # adjust the time stamp to most recent file
  if os.system('cd '+tmpdir+"; zoo Tq  "+archbase+'.zoo'):
    sys.stderr.write('Cannot adjust time stamp of zoo file '+tmpdir+'/'+\
                     archbase+'.zoo\n')
    sys.exit(23)
  if os.system('mv '+tmpdir+'/'+archbase+'.zoo '+arch+'.zoo'):
    sys.stderr.write('Cannot copy file '+tmpdir+'/'+archbase+'.zoo\n')
    sys.exit(10)
  if not quiet:
    print 'Created zoo archive.'

if ext <> '-win.zip':
  if os.system('rm -f '+arch+'-win.zip'):
    sys.stderr.write('Cannot delete existing file '+arch+'-win.zip')
    sys.exit(20)

  # write lists of filenames in temporary files
  try:
    f = open(tmpdir+'/binfiles', 'w')
    f.write(string.join(binfiles, '\n'))
    f.close()
    f = open(tmpdir+'/textfiles', 'w')
    f.write(string.join(textfiles,'\n'))
    f.close()
  except:
    sys.stderr.write('Cannot write filenames to file in '+tmpdir+'.\n')
    sys.exit(12)
  # now create zip archive, the -l option changes the line breaks of text
  # files to DOS/Windows mode
  if (os.path.getsize(os.path.join(tmpdir, 'binfiles')) > 0 and \
      os.system('cd '+tmpdir+'; umask 022; cat binfiles | zip -9 -q '+\
      archbase+'-win.zip -@')) or \
     (os.path.getsize(os.path.join(tmpdir, 'textfiles')) > 0 and \
      os.system('cd '+tmpdir+'; umask 022; cat textfiles | zip -9 -l -q '+\
      archbase+'-win.zip -@')):
    sys.stderr.write('Cannot create zip archive  in '+tmpdir+'.\n')
    sys.exit(13)
  if os.system('mv '+tmpdir+'/'+archbase+'-win.zip '+arch+'-win.zip'):
    sys.stderr.write('Cannot copy zip file from '+tmpdir+'.\n')
    sys.exit(16)
  if not quiet:
    print 'Created -win.zip archive.'

# cleanup
if os.system('rm -rf '+tmpdir):
  sys.stderr.write('Cannot delete temporary directory '+tmpdir+'\n');
  sys.exit(14)
if not quiet:
  print 'Cleaned up temporary directory.'



