#!/usr/bin/env perl
use strict;
use warnings;

use Time::HiRes;

if ( $ARGV[1] == 1 ) {
	$SIG{INT} = 'IGNORE';
	$SIG{TERM} = 'IGNORE';
}

Time::HiRes::sleep($ARGV[0]/1000)
