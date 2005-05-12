#!/usr/local/bin/perl -ni.bak
print $_;
if (/^(.*)\(C\) +[0-9]{4} +School +Math +and +Comp.? +Sci.?,? +University +of +St.? +Andrews,? +Scotland(.*)$/)
  {
    print "$1Copyright (C) 2002 The GAP Group$2\n";
  }
