#!/usr/bin/env python
# -*- coding: ISO-8859-1 -*-
#  $Id$    Frank Lübeck

import sys, os, string

if '-h' in sys.argv or len(sys.argv) != 3:
  print '''Usage:
  addpackage.py <name> PackageInfoURL

Here <name> is translated to lower case. If not present, a directory
../pkg/<name> is created and a short PackageInfo.g file just containing the
package PackageName and PackageInfoURL is written in that directory.
'''
  sys.exit(1)

# start to create some related directories if not present
for dn in ['../pkg', '../pkg/away', '../tmp', '../archives', '../log']:
  if not os.path.exists(dn):
    os.makedirs(dn, 0755)
    print 'Created directory ',dn


name = sys.argv[1]
lname = string.lower(name)
dirname = '../pkg/'+lname
url = sys.argv[2]

print 'Initializing package update directory\nPackage name: '+name+\
      '\nDirectory: '+dirname+'\nURL of PackageInfo.g: '+url+'\n\n'

# creating directory
if not os.path.exists(dirname):
  try: 
    os.mkdir(dirname)
  except:
    print 'Error: Cannot create directory '+dirname
    sys.exit(2)

# init PackageInfo.g file
pkginf = '''# init PackageInfo.g file
SetPackageInfo( rec(
PackageName := "'''+name+'''",
PackageInfoURL := "'''+url+'''"
) );
'''

# write it
try:
  f = file(os.path.join(dirname, 'PackageInfo.g'), 'w')
  f.write(pkginf)
  f.close()
  print 'Written initial version of PackageInfo.g file.'
except:
  print 'Error: Cannot write initial version of PackageInfo.g file.'
  sys.exit(3)



