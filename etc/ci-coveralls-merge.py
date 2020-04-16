#!/usr/bin/env python

# Hacked up merger for testing

from __future__ import print_function

import json
import os
import os.path
import sys

coverage_files = [ 'c-coveralls.json' ]

print("Merging coveralls json coverage") 

# Special-cased gap-coveralls.json, because we rely
# on GAP to set the correct service_name, pull-request number
# etc
print("file: gap-coveralls.json", end="")
if os.path.isfile('gap-coveralls.json'):
    with open('gap-coveralls.json', 'r') as f:
        merged = json.load(f)
    print(" done.")
else:
    print()
    print("WARNING: could not find gap-coveralls.json, quitting")
    sys.exit(0)

if not 'source_files' in merged:
    print("warning: source_files not in JSON dictionary read from gap-coveralls.json")
    merged['source_files'] = []

for fn in coverage_files:
    print("file: %s" % (fn,), end="")
    if os.path.isfile(fn):
        with open(fn, 'r') as f:
            cover = json.load(f)
            merged['source_files'].extend(cover['source_files'])
        print(" done.")
    else:
        print(" not found.")

if len(merged['source_files']) > 0:
    print("Merged:")
    for k in merged.keys():
        if (k != 'source_files'):
            print("%s: %s" % (k, merged[k]))   
    print("Writing merged profiles to merged-coveralls.json")
    with open('merged-coveralls.json', 'w+') as dump:
        json.dump(merged, dump)
else:
    print("No coverage found.")
print("Done. Bye.")
