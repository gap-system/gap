#!/usr/bin/env python

# Hacked up merger for testing

from __future__ import print_function

import hashlib
import json
import os
import os.path
import sys

def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

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

print("merging c-coveralls.json")
with open('c-coveralls.json', 'r') as f:
    input = json.load(f)
    sf = merged['source_files']
    for file in input['files']:
        name = file["file"]
        print("processing ", name)
        # TODO: normalize filename, remove leading "./"?
        source_digest = md5(name)
        max_line_number = max([line["line_number"] for line in file["lines"]])
        coverage = [None] * max_line_number
        result = { "name" : name, "source_digest" : source_digest, "coverage" : coverage }
        print("  MD5 hash = ", source_digest)
        for line in file["lines"]:
            if line["gcovr/noncode"]:
                continue
            coverage[line["line_number"]-1] = line["count"]
        sf.append(result)

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
