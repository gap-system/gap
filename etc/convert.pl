#!/usr/bin/perl -w
# was: /usr/bin/perl -w
#
# Script to convert the GAP manual to HTML
# usage convert.pl [-cs] [-n sharepkg] <doc-directory> [<html-directory>]
#
# Caveats: 
#
#  1. This script assumes that the .toc file is up-to-date with the .tex files
#     and will almost certainly fail horribly if this is not true
#
#  2. The output files are CxxxSxxx.htm, (not .html) plus chapters.htm,
#     theindex.htm and biblio.htm. A (front page) 
#     file index.htm is assumed, but not created
#     Not all servers will serve .htm files as HTML without adjustments
#
#  3. The script assumes that the .tex files comply with GAP conventions, including
#     unwritten ones. It tries to follow the behaviour of the on-line browser
#
#  Options:
#
#    -c  file-per-chapter mode -- generates one HTML file CHAPxxx.htm for each chapter
#        sections are level 2 headings and anchors CHAPxxx.htm#SECTxxx. This is intended
#        for local browsing, especially under MS-DOS
# 
#    -s  silent running. Conversational messages are suppressed.
#
#    -n sharepkg
#        We are not building the main manual but the one for the share
#        package <sharepkg>. To get cross references to the main library
#        right, it assumes that the share package is in the right place.
#
#    -i index: Only one index file is produced.
#
#    -t tex-math: run `tth' (which must be installed on the local system) to
#       produce better HTML code for formulae. (it would be possible to
#       replace tth by another conversion, for example TeXexplorer).
#
#    html-directory defaults to the current director,
#
#    Example usage:
#      convert.pl -n mypkg doc htm
#

# Check PERL version
#
$] > 5 or die "Needs perl 5";

use Getopt::Std;


#
# Global variables 
#
#  $dir  -- the full pathname of the input directory, including a trailing /
#  $odir -- the full pathname of the output directory, including a trailing /
#  $opt_c and $opt_s set by getopts()
#  @chapters -- the chapters data structure
#  IN    -- the current input file (outputfiles are handled by select)
#  $footer -- the trailer put on every page
#  $indexcount -- used within chapters to number the index anchors
#


# getchaps:
#
# Scan the .tex and .toc files to get chapter names and numbers, 
# section names and numbers and associated filenames Loads up chapters and
# sections_by_name
#

# These match chapter and section lines in a .toc file
#

$chapexp = '\\\\chapcontents\s+\{(\d+)\}\s*\{(.+)\}\s*\{\d+\}';
$secexp = '\\\\seccontents\s+\{(\d+)\.(\d+)\}\s*\{(.+)\}\s*\{\d+\}';
#$ignoreexp = '\\\\tocstrut|\\\\appno|\\\\seccontents\s+\{\d+\}';

#
# used to standardize section names for use as hash indices.
# 

sub canonize {
    my ($key) = @_;
    $key =~ tr/A-Z/a-z/;
    $key =~ s/\s//g;
    $key =~ s/\\//g;
    $key;
}
sub kanonize {
    my ($key) = @_;
    $key =~ s/\\ / /g;
    $key =~ s/!/ /g;
    $key;
}

sub getchaps {
    open TOC, ( "${dir}manual.toc" ) || die "Can't open ${dir}manual.toc";
    my ($chap,$sec,$chapno,$chap_as_sec);
    while (<TOC>) {
        if ( /$chapexp/o ) {
	    $chapnam = $2;
	    $chanu   = $1;
		
	    # remove `(preliminary)' part that messes everything up
	    $chapnam =~ s/ \(preliminary\)//g;

            $chap = {name => $chapnam,  
                     number => $chanu};
            $chap_as_sec = {name => $chapnam,
                            chapnum => $chanu, 
                            secnum => 0,
                            chapter => $chap};
            $chap->{sections}[0] = $chap_as_sec;
            if (defined ($chapters[$chanu])) {
                die ("chapter number repeated");
            }
            $chapters[$chanu] = $chap;
        } elsif ( /$secexp/o ) {
            if (not defined ($chapters[$1])) {
                die ("section $2:$3 in unknown chapter $1");
            }
            if (defined ( $chapters[$1]{sections}[$2])) {
                die "section number repeated";
            }
            $sec = {name => $3,
                    secnum => $2, 
                    chapnum => $1,
                    chapter => $chapters[$1]};
            $chapters[$1]{sections}[$2] = $sec;
# this would produce warnings from empty chapters. Thus ignore.
#        } elsif ( $_ !~ /$ignoreexp/o ) {
#            print STDERR "Bad line: $_";
        }
    }
    close TOC;
    open TEX, ("${dir}manual.tex") || die "Can't open ${dir}manual.tex";
    $chapno = 0;
    while (<TEX>) {
        if ( /^[^%]*\\Input\{(.+)\}/ ) {
            if (not -f "$dir$1.tex" or not -r "$dir$1.tex") {
                print STDERR "Chapter file $1.tex does not exist in $dir\n";
            }
            $chapters[++$chapno]{file} = $1;
        }
    }
    close TEX;
}

sub getlabs {
    my ($bok) = @_;
    open LAB, ("$dir../$bok/manual.lab") ||
        die "Can't open $dir../$bok/manual.lab";
    while (<LAB>) {
        if ( /\\makelabel\s*\{([^}]+)\}\s*\{(\d+)\.(\d+)\}/ ) {
            $sections_by_name{canonize $1} = {chapnum => $2,
                                              secnum => $3};
        } elsif ( /\\makelabel\s*\{([^}]+)\}\s*\{(\d+)\.(\d+)\.(\d+)\}/ ) {
            $sections_by_name{canonize $1} = {chapnum => $2,
                                              secnum => $3};
        } elsif ( /\\makelabel\s*\{([^}]+)\}\s*\{(\d+)\}/ ) {
            $sections_by_name{canonize $1} = {chapnum => $2,
                                              secnum => 0};
        } else {
            print STDERR "Ignored line: $_ in $bok";
        }
    }
    close LAB;
}

#
# Mainly diagnostic, prints the chapters data structure. Also
# checks that each section has the correct back reference to its
# chapter
#

sub printchaps {
    my @chapters = @_;
  CHAP: foreach $chapter (@chapters) {
      next CHAP unless (defined ($chapter));
      print "Chapter $chapter->{number} $chapter->{name} $chapter->{file}\n";
    SECT: foreach $section (@{$chapter->{sections}}) {
        next SECT unless defined ($section);
        print "    Section $section->{chapnum}.$section->{secnum} $section->{name}\n";
        if ($section->{chapter} ne $chapter ) {
            print "       loop problem\n";
        }
    }
      
  }
}

# Printed at the bottom of every page.
$footer = "<P>\n<address>GAP 4 manual<br>" .
    `date +"%B %Y"` . "</address></body></html>";


# The names of the section and chapter files are determined by this routine.
sub name2fn {
    my ($name,$ischap) = @_;
    my $bdir = "";

    # : indicates a cross-volume reference
    if (($name =~ /^(ref):(.+)$/) || ($name =~ /^(tut):(.+)$/) ||
	($name =~ /^(ext):(.+)$/) || ($name =~ /^(prg):(.+)$/)) {
      if ($mainman==1) {
	$bdir = "../$1/";
      }
      else {
	@word = split /:/ ,$name;
        $bdir = "../../../doc/htm/$word[0]/";
      }
    }
    elsif ($name =~ /^($book):(.+)$/) {
      my $bdir = "";
    } else {
        $name = "$book:$name";
    }
    
    my $sec = $sections_by_name{canonize $name};

    unless (defined ( $sec)) {
        return "badlink:$name";
    }
    my ($cnum,$snum) = ($sec->{chapnum},$sec->{secnum});
    if ($ischap == 1) {$snum=0}; # if we want a chapter reference

    $cnum = "0" x (3 - length $cnum) . $cnum;
    $snum = "0" x (3 - length $snum) . $snum;
    if ($opt_c) {
        if ($snum eq "000") {
            return "${bdir}CHAP${cnum}.htm";
        } else {
            return "${bdir}CHAP${cnum}.htm#SECT${snum}";
        }
    } else {
        return "${bdir}C${cnum}S$snum.htm";
    }
}


# Add an index entry.
sub inxentry {
    my ($fname,$key,$sec) = @_;
    my $new=1;
    my $curs="$sec->{chapnum}.$sec->{secnum}";
    unless (defined $index{$key}) {
        $index{$key} = [];
    }
    else {
      my $ar;
      for $ar (@{$index{$key}}) {
	if ( ($ar->[1])==$curs ) {
	  $new=0;
	}
      }
    }
    my $result="";
    if ($new==1) {
      $result = "<a name = \"I$indexcount\"></a>\n";
      push @{$index{$key}}, [ "$fname#I$indexcount", $curs ];
    }
    $indexcount++;
    $result;
} 


# Some characters must be represented differently in HTML.
sub html_literal {
    my ($lit) = @_;
    if    ($lit eq "<") { return "&lt;"; }
    elsif ($lit eq ">") { return "&gt;"; }
    elsif ($lit eq "&") { return "&amp;"; }
    else                { return $lit; }
}


# Gather lines ending in % together.
sub gather {
    my ($line) = @_;
    my $nextline;
    while ($line =~ /%+\s*$/ and $nextline = <IN>) {
	$line = $` . $nextline;
	chomp $line;
    }
    $line;
}


# This routine is called to process the text of the section
# the output file is assumed to be pre-selected. The input filehandle
# is simply IN
# 
# As we process, we can be in "normal" status (text), "maths" status 
# inside $ ... $, or "verbatim" status inside a multi-line example
#
# We separately track whether we are in bold or tt, 
# whether we are in a xxx: .... paragraph and whether we are reading
# a cross-reference that is split across multiple lines
#
# Finally, we track whether we have already
# emitted a <P> for this group of blank lines
#


$LaTeXbinops = "in|wedge|vee|cup|cap|otimes|oplus|le|ge|rightarrow";
$EndLaTeXMacro = "(?![A-Za-z])";
$TeXaccents = "\'`\"~^";  # ^ must come last, this is also used as regexp
@HTMLaccents = ( "acute;", "grave;", "uml;", "tilde;", "circ;", );

#
# This could probably be done more cleverly -- this routine is too long
#

sub convert_text {
    my $fname = $_[0];
    my $refchars = '[\\w\\s-`\',.:!()?$]'; # these make up cross references
    my $boldcommands = 'GAP|CAS|ATLAS|MOC|[A-Z]|danger|exercise';
    my $ref = "";
    my $endline = "";           # used for </code> at the end of line
    my $status = "normal";
    my ($bold,$tt,$it,$sub,$sup) = (0,0,0,0,0);
    my ($inlist,$inref,$donepar,$skip_lines,$html) = (0,0,0,0,0);

    #
    # Now we loop over lines. a line with 16 initial % signs marks 
    # end of section
    #

  LINE: while ($_ = <IN> and not /^\%{16,}/) {
      chomp;                    # drop the trailing newline
      my $rest = $_;            # rest of the line to scan
      my $outline = "";         # build the output in here

      # First we deal with various special whole lines.
      # \beginexample, \begintt, %display (this may end a $skip_lines)
      if ($status eq "normal" and
          ($_ =~ /^\\begin(example|tt)/ or
	   $_ =~ /^%display\{text\}/ and !$html)) {
          $status = "verbatim";
          $skip_lines = 0;
          print "<pre>\n";
          next LINE;
      } elsif ($status eq "normal" and
          $_ =~ /^%display\{html\}/) {
	  $status = "html";
	  $html = 1;  # if there was {html}, ignore subsequence {text}
          $skip_lines = 0;
          next LINE;
      } elsif ($status eq "html" and 
          $_ =~ /^%display\{text\}/) {
	  $status = "text";
	  $html = 0;  # ignore subsequence {text}
          $skip_lines = 0;
          next LINE;
      } elsif (/^%enddisplay/) {
	  if ($status eq "verbatim") {
	      print "</pre>\n";
	  }
	  $status = "normal";
	  $html = 0;
	  $skip_lines = 0;
	  next LINE;
      } elsif ($status eq "verbatim") {
	  # \endexample, \endtt
	  if (/^\\end(example|tt)/) {
	      $status = "normal";
	      print "</pre>\n";
	      next LINE;
	  }
	  # |_
	  if (/^\|_/) {
	      next LINE;
	  }
      } elsif ($status eq "html") {
	  if (/^%+/) {
	      print $';
	      print "\n";
	  } else {
	      print STDERR "Line $. ignored in %display{html} mode, " .
		  "because it didn't start with %";
	  }
	  next LINE;
      } elsif ($status eq "text") {
	  if (/^%+/) {
	  } else {
	      print STDERR "Line $. erraneous in %display{text} mode, " .
		  "because it didn't start with %";
	  }
	  next LINE;

      # The remaining special whole lines occur only in non-verbatim mode.
      } else {
	  
          # Line skipping.
	  if ($skip_lines) {
	      if ($skip_lines == 1 and $_ =~ /^\s*$/) {
		  $skip_lines = 0;
	      }
	      next LINE;
	  }
      	  # Paragraphs are ended by blank lines.
      	  if (/^\s*$/) {
	      unless ($donepar) {
		  $outline .=  "<p>\n";
		  $donepar = 1;
	      }
    
	      # If we get to the end of a paragraph we assume that we have
	      # lost track of what is going on, warn and try to resume.
	      if ($status eq "maths" or $inref) {
		  print STDERR "Paragraph ended in status $status at $.\n" .
		      "reverting to normal\n";
		  $outline .= "</I>" if ($status eq "maths");
		  $status = "normal";
	      }
      	      
	      print $outline;
      	      next LINE;
      	  }   
      	  # Paragraphs to be skipped by HTML.
      	  if (/^%display\{(text?|jpeg)\}/) {
      	      $skip_lines = 2;
      	      next LINE;
      	  }
          # Vertical skips.
      	  if (/^\\(med|big)skip/) {
      	      $outline .= "<p>";
      	      print "$outline\n";
      	      next LINE;
      	  } 
      	  # Index entries --  emit an  anchor  and remember  the index
      	  # keys  for   later there may   be  several on  one line and
      	  # several references to one key
      	  if  (/^\\index/) {
      	      while (/\\index\{(.*?)\}/g) {
      		  #$outline .= inxentry($fname,$1,$sec);
      		  $bla = inxentry($fname,$1,$sec);
      		  $outline .= $bla;
		  print "$outline\n";
      	      }
      	      next LINE;
      	  }
      	  # \> and \)  lines (joined with next line if ending in %)
	  if (/^\\[>)]/) {
	      $_ = gather $_;
	      # get rid of all `@' entries.
	      if (/([^@]*)@\{[^\}]*\}\s*([A-Z])/) {
		  $_ = $1." ".$2;
	      }
	  }
	  if (/^\\> *`([^\']+)\'\{([^}]+)\}(!\{.*)?\s*([A-Z])?\s*$/) {
      	      $endline = "</code>";
              if (!defined($3)) {$drei=""}
	      else {$drei=$3};
              if (!defined($4)) {$vier=""}
	      else {$vier=$4};
      	      $outline .= inxentry($fname,"$2$drei",$sec);
#print STDERR "x:$1 - $2 - $drei - $vier\n";
      	      $outline .= "<li><code>";
      	      $tt = 1;
      	      $rest = $1." ".$vier;
      	  }
	  elsif (/^\\> *`([^(]+) *(\([^\)]*\))\'[!-~]*( *[A-Z])$/) {
# entries created when refering to a declaration in a special file
# by \Declaration{blubber}[flutsch]
      	      $endline = "</code>";
              if (!defined($2)) {$zwei=""}
	      else {$zwei=$2};
              if (!defined($3)) {$drei=""}
	      else {$drei=$3};
      	      $outline .= inxentry($fname,"$1",$sec);
      	      $outline .= "<li><code>";
      	      $tt = 1;
      	      $rest = "$1$zwei$drei";
	  }
	  elsif (/^\\> *([^!%(]+)(\([^!]*)?(!\{.*)?\s*$/) {
      	      $endline = "</code>";
              if (!defined($2)) {$zwei=""}
	      else {$zwei=$2};
              if (!defined($3)) {$drei=""}
	      else {$drei=$3};
      	      $outline .= inxentry($fname,"$1$drei",$sec);
      	      $outline .= "<li><code>";
      	      $tt = 1;
      	      $rest = "$1$zwei";

      	  }
	  elsif (/^\\\) *(.*)$/) {
      	      $endline = "</code>";
      	      $outline .= "<br><code>";
      	      $tt = 1;
      	      $rest = $1;
          # Skip all other lines starting or ending in % or containing
          # `align'.
      	  } elsif ($status ne "verbatim" and
      		   $_ =~ /^\s*%|%\s*$|\\[a-z]+align/) {
      	      next LINE;
          }
      }

      # Here  we have a "non-special" line  to  process We scan it for
      # special   characters and   deal  with  them individually $rest
      # contains the text  that we have yet  to look at We  accumulate
      # the output  in $outline, rather  than printing  it because a &
      # requires us to back up to start of line
      $donepar = 0;
      
      # The (rare) situation that we are processing a multi-line cross
      # reference is handled specially.
      if ($inref) {
          # if it finishes on this line emit the link
          # otherwise keep accumulating it
          if ($rest =~ /^$refchars+\"/o) {
      	      $rest = $';
      	      chop($ref .= $&);
      	      $ref1 = name2fn($ref,0);
      	      $outline .= "<a href=\"$ref1\">$ref</a>";
      	      $inref = "0";
          } elsif ($rest =~ /^$refchars*$/o) {
      	      $ref .= "$rest ";
      	      next LINE;
          } else {
      	      die "Bad reference. So far $ref, now got $rest";
          }
      }

      # The main case, scan for special characters.
    SPECIAL: while ( $rest =~ /[\\{}\$<>`\'*\"&%~_^]/ ) {
        $outline .= $`;         # the part that we scanned past
        $rest = $';             # the remainder
        my $matched = $&;       # the character matched

        # In verbatim mode, everything is passed to HTML.
        if ($status eq "verbatim") {
#            if ($matched ne "%") {
                $outline .= html_literal $matched;
#            }
            next SPECIAL;
        }

        # backslash
        if ($matched eq "\\") {
            # commands that begin a new output line
          NEWLINE: {
            if    ($rest =~ /^beginitems/ and not $inlist)
                                          { $outline .= "<p>\n<dl compact>";
                                            $inlist = 1;         }
            elsif ($rest =~ /^enditems/ and $inlist)
                                          { $outline .= "</dl>";
                                            $inlist = 0;         }
            elsif ($rest =~ /^beginlist/) { $outline .= "<dl compact>";  }
            elsif ($rest =~ /^endlist/)   { $outline .= "</dl>"; }
            elsif ($rest =~ /^answer/)    { $outline = "";
                                            $skip_lines = 1; }
            else  { last NEWLINE; }
            print "$outline\n";
            next LINE;
          }
            # commands that are replaced by HTML text
          REPLACE: {
	    my $remainder = ""; # remaining stuff to be inserted
            if    ($rest =~ /^($boldcommands)$EndLaTeXMacro/o) {
                   $outline .= "<font face=\"helvetica,arial\">"
		               .uc($&)."</font>"; }
            elsif ($rest =~ /^([hv]box|rm)/) { }
            elsif ($rest =~ /^enspace/)    { $outline .= "&nbsp;";       }
            elsif ($rest =~ /^quad/)       { $outline .= "&nbsp;";       }
            elsif ($rest =~ /^qquad/)      { $outline .= "&nbsp;&nbsp;"; 
# we may not replace \" -- its used in strings
#	    } elsif ($rest =~ /^([$TeXaccents])(\w)/) {
#		$outline .= "&$2".$HTMLaccents[index($TeXaccents,$1)];
	    } elsif ($rest =~ /^accent\s*127\s*(\w)/) {
		$outline .= "&$1uml;";
	    } elsif ($rest =~ /^ss\s*/) { $outline .= "&szlig;";
	    } elsif ($rest =~ /^pif/) { $outline .= "'";}
            elsif ($rest =~ /^l?dots/)     { $outline .= "...";          }
            elsif ($rest =~ /^bs?f|stars/) { $outline .= "<hr>";         }
            elsif ($rest =~ /^cr/)         { $outline .= "<br>";         }
            elsif ($rest =~ /^fmark/)      { $outline .= "<li>";         }
            elsif ($rest =~ /^item\{([^}]*)\}/) {
                   $outline .="<dt>";
		   $remainder = $1."\\itmnd "; }
            elsif ($rest =~ /^itemitem\{([^}]*)\}/) {
                   $outline .="<dt>";
		   $remainder = "\\qquad".$1."\\itmnd "; }
	    # pseudo ``itemend'' character
            elsif ($rest =~ /^itmnd/)      { $outline .= "<dd>"; }
            elsif ($rest =~ /^cite\s*\{\s*(\w+)\s*\}/) {
                $outline .= "<a href=\"biblio.htm#$1\"><cite>$1</cite></a>"; }
            elsif ($rest =~ /^URL\{([^\}]*)\}/) {
                $outline .= "<a href=\"$1\">$1</a>"; }
            elsif ($rest =~ /^Mailto\{([^\}]*)\}/) {
                $outline .= "<a href=\"mailto:$1\">$1</a>"; }
            else  { last REPLACE; }
            $rest = $remainder.$';
            next SPECIAL;
          }
            # Try to get nice spacing around certain maths constructs that
            # are used a lot.
            if ($status eq "maths") {
              MATHREPLACE: {
                if    ($rest =~/^($LaTeXbinops)$EndLaTeXMacro/o) {
                       $outline .= " $1 "; }
                elsif ($rest =~/^backslash$EndLaTeXMacro/o) {
                       $outline .= " \\ "; }
                elsif ($rest =~/^split$EndLaTeXMacro/o) {
                       $outline .= ":"; }
                elsif ($rest =~/^langle$EndLaTeXMacro/o) {
                       $outline .= " &lt;"; }
                elsif ($rest =~ /^rangle$EndLaTeXMacro/o) {
                       $outline .= "&gt; "; }
                else  { last MATHREPLACE; }
                $rest = $';
                next SPECIAL;
              }
            }
            # Take the next character literally.
            if ($rest ne "")  {
                $outline .= html_literal substr($rest,0,1);
                $rest = substr($rest,1);
            }
            next SPECIAL;
        }

        # Subscripts and superscripts in math mode.
        if ($status eq "maths" and !$sub and !$sup) {
          SUBSUPER: {
            if    ($matched eq "_" and $rest =~ /^\{/) {
                   $outline .= "<sub>";
                   $sub = 1; if ($tt) { $tt++; } }
            elsif ($matched eq "^" and $rest =~ /^\{/) {
                   $outline .= "<sup>";
                   $sup = 1; if ($tt) { $tt++; } }
            elsif ($matched eq "_" and $rest =~ /^[^\\]/) {
                   $outline .= "<sub>$&</sub>"; }
            elsif ($matched eq "^" and $rest =~ /^[^\\]/) {
                   $outline .= "<sup>$&</sup>"; }
            else  { last SUBSUPER; }
            $rest = $';
            next SPECIAL;
          }
        }
        if ($matched =~ /[_^]/) {
            $outline .= $matched;
            next SPECIAL;
        }

        # Braces are ignored, but must must be balanced inside `...'.
        if ($matched eq "{") {
            if    ($tt)  { $tt++; }
	    if    ($sub) { $sub++; }
	    elsif ($sup) { $sup++; }
            next SPECIAL;
        }
        if ($matched eq "}") {
            if ($tt == 1) {
		die "Unbalanced braces in `...' ($outline$matched$rest)";
	    }
            if ($tt) { $tt--; }
            if ($sub and !--$sub) { $outline .= "</sub>"; }
	    if ($sup and !--$sup) { $outline .= "</sup>"; }
            next SPECIAL;
        }

        # A tilde is a non-break space.
        if ($matched eq "~") {
            $outline .= "&nbsp;";
            next SPECIAL;
        }

        # $ toggles maths mode.
        if ($matched eq "\$") {
          if ($opt_t) {
	    if ($status eq "normal") {
	      $tth= "";
	      if ($rest =~ /^\$/) {
		$rest = $';
		$tthdisp=1;
	      }
	      else {
		$tthdisp=0;
	      }
	      $status = "tth";
    
	      while ($status eq "tth") {
		if ( $rest =~ /[\$]/ ) {
		  $tth .= $`; # the part scanned past
		  $rest = $';
		  # remove $$ when ending display mode
		  if ($rest =~ /^\$/) { $rest = $'; }

		  # make a math mode string
                  if ($tthdisp eq 1) {
		    $tth = "\$\$".$tth."\$\$";
		  }
		  else {
		    $tth = "\$".$tth."\$";
		  }

		  # replace <...> by proper TeX
	          while ($tth =~ /(.*[^\\])<(.*[^\\])>(.*)/) {
		    $tth= $1."{\\it ".$2."\\/}".$3;
		  }

		  # replace `...' by proper TeX
	          while ($tth =~ /(.*[^\\])`(.*[^\\])\'(.*)/) {
		    $tth= $1."{\\tt ".$2."}".$3;
		  }

		  # replace \<,\> by proper TeX
	          while ($tth =~ /(.*[^\\])\\<(.*)/) {
		    $tth= $1."<".$2;
		  }
	          while ($tth =~ /(.*[^\\])\\>(.*)/) {
		    $tth= $1.">".$2;
		  }

		  # pass to tth to convert to HTML
		  open TTHIN, ">tthin";
		  if ($tth =~ /\\/) {
		    # there might be macros: Load our macros
#print STDERR "tth: ${tth}\n";
		    print TTHIN "\\input tthmacros.tex\n";
		  }
		  print TTHIN "${tth}\n";
		  close TTHIN;
		  `tth -r -i <tthin >tthout 2>/dev/null`;
		  open TTHOUT, "tthout";
		  $tth="";
		  while ( $tthin = <TTHOUT> ) {
		    chomp($tthin);
		    $tth .= $tthin;
		  }
		  close TTHOUT;
#print STDERR "out: ${tth}\n";

		  # replace italic typewriter (happens because we force
		  # italic letters) by roman ones
	          while ($tth =~ /(.*)<tt><i>(.*)<\/i><\/tt>(.*)/) {
		    $tth= $1."<tt>".$2."</tt>".$3;
		  }

		  # append the math stuff
		  $outline .= "<font size=\"+1\">".$tth."</font>"; 
		  $status = "normal";
		}
		else {
		  # we are in tth mode but the line has no $: continue
		  # into next line
		  $tth .= $rest." ";
		  $rest = <IN>;
		  chomp($rest);
		}
              }

	      next SPECIAL;
	    }
	    else {
	      die "math mode messup";
	    }
	  }
	  else {
            if ($rest =~ /^\$/) {
                $rest = $';
                $outline .= "<p>";
            }
            if ($status eq "maths") {
		if    ($sub) { die "Math mode ended during subscript ".
				   "($outline$matched$rest)"; }
		elsif ($sup) { die "Math mode ended during superscript ".
				   "($outline$matched$rest)"; }
                $status = "normal";
                $outline .= "</var>";
                if ($tt) { $outline .= "<code>"; }
                next SPECIAL;
            } 
            $status = "maths";
            if ($tt) { $outline .= "</code>"; }
            $outline .= "<var>";
            next SPECIAL;
	  }
        }

        # < > open and close italics.
        if ($matched eq "<") {
            if (not $it) {
                if ($tt) { $outline .= "</code>"; }
                $outline .= "<var>";
                $it = 1;
            } else {
                $outline .= "&lt;";
            }
            next SPECIAL;
        }
        if ($matched eq ">") {
            if ($it) {
                $outline .= "</var>";
                if ($tt) { $outline .= "<code>"; }
                $it = 0;
            } else {
                $outline .= "&gt;";
            }
            next SPECIAL;
        }

        # * in normal mode toggles bold-face.
        if ($matched eq "*") {  
            if ($status eq "normal" and not $tt) {
                if ($bold) {  
                    $outline .= "</strong>"; 
                    $bold = 0;
                } else {
                    $outline .= "<strong>"; 
                    $bold = 1;
                }
            } else {
                $outline .= "*";
            }
            next SPECIAL;
        }

        # ` and ' in normal mode control typewriter.
        if ($matched eq "`") {
            if (not $tt) {
                $outline .= "<code>";
                $tt = 1;
            } else {
                $tt = 0;
                if ($outline =~ /<code>$/) {
                    $outline = substr($outline,0,(length $outline)-6);
                } else {
                    $outline .= "</code>";
                }
                $outline .= "``";
            }
            next SPECIAL;
        }
        if ($matched eq "\'") {
            if ($tt == 1) {
                $outline .= "</code>";
                $tt = 0;
            } else {
                $outline .= "\'";
            }
            next SPECIAL;
        }

        # & signals a definition. We go back to start  of line for the
        # tag, and on  to end  of para for  the definition.  We do not
        # merge adjacent definitions into the same list.
        if ($matched eq "&") {
            if ($inlist) {
                $outline = "<dt>$outline<dd>";
            } 
            next SPECIAL;
        }

        # " starts a  cross-reference.  If it ends  on the  same input
        # line then  we can deal  with  it  at once  otherwise we  set
        # $inref.
        if ($matched eq "\"") {
            if ($tt) {
                $outline .= "\"";
                next SPECIAL;
            } 
            if ($rest =~ /^$refchars+\"/o) {
                $rest = $';
                chop($ref = $&);
                $ref1 = name2fn($ref,0);
                $outline .= "<a href=\"$ref1\">$ref</a>";
                next SPECIAL;
            }
            if ($rest =~ /^$refchars*$/o) {
                $ref = "$rest ";
                $inref = 1;
                print $outline;
                next LINE;
            } 
            die "Bad reference $rest at $_";
        }

        # Ignore from % to end of line, on-line browser does not do this.
        if ($matched eq "%") {
            print $outline."\n";
            next LINE;
        }
            
    }                           # SPECIAL
    print $outline.$rest.$endline."\n";
    if ($endline =~ /<\/code>/) {
        $tt = 0;
    }
    $endline ="";
  }      # LINE
}


sub startfile {
    my $sec = $_[0];
    my ($num, $name, $re, $fname, $name1, $name2);
    if ($sec->{secnum} == 0) {
        $sec->{chapnum} = $chap->{number};
        $num = $chap->{number};
        $name = $chap->{name};
        $name1 = quotemeta $name;
        $re = "^\\\\(Chapter|FakeChapter|PreliminaryChapter)\\{$name1\\}";
	$name2 = kanonize $name;
	$fname = name2fn($sec->{name},1);
    } else {
        $num = $sec->{chapnum} . "." .$sec->{secnum};
        $name = $sec->{name};  
        $name1 = quotemeta $name;
        $re = "^\\\\Section\\{$name1\\}";
	$name2 = kanonize $name;
	$fname = name2fn($sec->{name},0);
    }

    open OUT, ">${odir}${fname}";
    select OUT;

    print  "<html><head><title>[$book] $num $name2</title></head>\n";
    print  "<body bgcolor=\"ffffff\">\n";
    print  inxentry($fname,$name,$sec);
    print "<h1>$num $name2</h1><p>\n";

    ($fname, $re);
}

sub startsubsec {
    my $sec = $_[0];
    my $snum = $sec->{secnum};
    my $num = $sec->{chapnum} . "." .$snum;
    $snum = "0" x (3 - length $snum) . $snum;
    my $name = $sec->{name};  
    my $name1 = quotemeta $name;
    my $name2 = kanonize $name;
    print "<a name=\"SECT$snum\"><h2>$num $name2</h2></a>\n<p>";
    return "^\\\\Section\\{$name1\\}";
}

sub sectionlist {
    my $chap = $_[0];
    my $subsec;
    print  "<P>\n<H3>Sections</H3>\n<oL>\n";
  SUBSEC: for $subsec (@{$chap->{sections}}) {
      next SUBSEC if ($subsec->{secnum} == 0);
      my $link = name2fn($subsec->{name},0);
      my $name2 = kanonize $subsec->{name};
      print  "<li> <A HREF=\"$link\">$name2</a>\n";
  }
    print  "</ol><p>\n";
}

#
# Basically the chapter file is read in one pass, using information previously 
# read from the .toc file to fill in next and previous pointers and the like
#

sub navigation {
    my $sec = $_[0];
    my $chap = $sec->{chapter};
    my $cfname = name2fn($chap->{name},0);
    if ($mainman == 1) {
      print  "[<a href=\"../index.htm\">Top</a>] "
    };
    if ($sec->{secnum} == 0) {
        if ($chap->{number} != 1) {
            my $prev = name2fn($chapters[$chap->{number} - 1]{name},1);
            print  "[<a href =\"$prev\">Previous</a>] ";
        }
        print  "[<a href = \"chapters.htm\">Up</a>] ";
        if ($chap->{number} != $#chapters) {
            my $next = name2fn($chapters[$chap->{number} + 1]{name},1);
            print  "[<a href =\"$next\">Next</a>] ";
        }
    } else {
        if ($sec->{secnum} != 1) {
            my $prev = name2fn($chap->{sections}[$sec->{secnum} - 1]{name},0);
            print  "[<a href =\"$prev\">Previous</a>] ";
        }
        print  "[<a href = \"$cfname\">Up</a>] ";
        if ($sec->{secnum} != $#{$chap->{sections}}) {
            my $next = name2fn($chap->{sections}[$sec->{secnum} + 1]{name},0);
            print  "[<a href =\"$next\">Next</a>] ";
        }
    }
    print  "[<a href = \"theindex.htm\">Index</a>]\n";
}
    

sub convert_chap {
    my ($chap) = @_;
    my $re;
    my $fname;
    $indexcount = 0;
    open IN, $dir.$chap->{file}.".tex";
    $_ = <IN>;

    # loop, controlled by the list of sections that we expect
    # will fail, possibly messily if this does not match reality

    if ($opt_c) {               # each chapter in a single file
        ($fname,$re) = startfile $chap->{sections}[0];
    }

  SECT: for $sec (@{$chap->{sections}}) {

      # sort out what we are processing (chapter or section)
      # produce the header of the Web page

      if ($opt_c) {
          $re = startsubsec $sec unless ($sec->{secnum} == 0);
      } else {
          ($fname, $re) = startfile $sec;
      } 

      #
      # Look for the \Chapter or \Section line
      #

      while ( $_ !~ /$re/) {
          unless ($_ = <IN>) { 
              die "Missing chapter or section line matching $re" };
      };

      convert_text($fname);

      # Here we have processed the whole section and start to attach footers
      # to it. If it is really a chapter then it gets a list of its sections

      if ($sec->{secnum} == 0) {
          sectionlist $chap;
      }
      unless ($opt_c) {
          navigation $sec;
	  print $footer;
	  close OUT;
	  select STDOUT;
      }    
  }
    if ($opt_c) {
        navigation $chap->{sections}[0];
	print $footer;
	close OUT;
	select STDOUT;
    }
    close IN;
}



sub chapters_page {
    open OUT, ">${odir}chapters.htm";
    select OUT;

    print  <<END
<html><head><title>$booktitle - Chapters</title></head>
<body bgcolor=\"ffffff\"><h1>$booktitle - Chapters</h1><ol>
END
    ;

  CHAP: foreach $chap (@chapters) {
      unless (defined $chap) { next CHAP};
        my $link = name2fn($chap->{name},1);
        my $name2 = kanonize $chap->{name};
        print  "<li><a href=\"$link\">$name2</a>\n";
    }

    print  <<END
</ol><ul>
<li><a href=\"biblio.htm\">References</a>
<li><a href=\"theindex.htm\">Index</a>
</ul><p>
END
    ;
    if ($mainman == 1) {
      print  "[<a href=\"../index.htm\">Top</a>]<p>"
    };

    print $footer;
    close OUT;
    select STDOUT;

    # Touch the chapters file so that `make' recognizes the conversion
    # has been done.
    system "touch ${odir}chapters.htm";
}
    
sub caseless { lc($a) cmp lc ($b) or $a cmp $b }

sub index_page {
    my ($ent, $ref, $letter, $bstb, $nextletter);
    $letter = "_";
    $nextletter = "A";

    open OUT, ">${odir}theindex.htm";
    select OUT;
    print <<END
<html><head><title>$booktitle - Index ${letter}</title></head>
<body bgcolor=\"ffffff\"><h1>$booktitle - Index ${letter}</h1>
<p>
END
    ;
    foreach $bstb  ("A".."Z") {
      if ($opt_i) {
        print  "<a href=\"\#idx${bstb}\">$bstb</A> ";
      }
      else {
        print  "<a href=\"indx${bstb}.htm\">$bstb</A> ";
      }
    }
    print  "\n<dl>\n";

        
  ENTRY: for $ent (sort caseless keys %index) {
      $letter = uc(substr($ent,0,1));
      if ($letter ge "A" and $letter le "Z" and $nextletter le "Z") {
           until ($letter lt $nextletter) {
	     if ($opt_i) {
	      $nextletter++;
	      if ($letter lt $nextletter) {
		print "</dl><p>\n";
		print "<H2><A NAME=\"idx${letter}\">$letter</A></H2>\n";
		print "<dl>\n";
	      }
	    }
	    else {
	      print  "</dl><p>\n";
	       if ($mainman == 1) {
	 	 print  "[<a href=\"../index.htm\">Top</a>] "
	       };
	       print  "[<a href=\"chapters.htm\">Up</a>]";
	       print  "<p>\n$footer";
               $nextletter++;

	      close OUT;
	      select STDOUT;
	      open OUT, ">${odir}indx${letter}.htm";
	      select OUT;
	      print <<END
<html><head><title>$booktitle - Index ${letter}</title></head>
<body bgcolor=\"ffffff\"><h1>$booktitle - Index ${letter}</h1>
<p>
END
	      ;
	      foreach $bstb  ("A".."Z") {
		  print  "<a href=\"indx${bstb}.htm\">$bstb</A> ";
	      }
	      print  "\n<dl>\n";
	    }

          }
      }
      $ent1 = $ent;
      $ent1 =~ s/!/, /g;
      $ent1 =~ s/[{}]//g;
      print  "<dt>".kanonize $ent1." ";
      for $ref (@{$index{$ent}}) {
          print  "<a href=\"$ref->[0]\">$ref->[1]</a> ";
      }
      print  "\n";
    }
    print  "</dl><p>\n";
    if ($mainman == 1) {
      print  "[<a href=\"../index.htm\">Top</a>] "
    };
    print  "[<a href=\"chapters.htm\">Up</a>]";
    print  "<p>\n$footer";
    close OUT;
    select STDOUT;
}

sub biblio_page {
  my $infile = "${dir}manual.bbl";
  my $outfile = "${odir}biblio.htm";
  open OUT, ">${outfile}";
  select OUT;

  print <<END
<html><head><title>$booktitle - References</title></head>
<body bgcolor=\"ffffff\"><h1>$booktitle - References</h1><dl>
END
    ;

  if (-f $infile and -r $infile) {
    open IN, $infile;
    my ($brace,$embrace) = (0,-1);
    while (<IN>) {
        chomp;
        my $outline = "";
        if (/thebibliography/) { }
        elsif (/^\\bibitem\[\w+\]\{(\w+)\}/) {
            print "<dt><a name=\"$1\"><b>[$1]</b></a><dd>\n";
        } else {
            my $line = $_;
            if ($line =~ /^\\newblock/) { $outline .= "<br>";
                                          $line = $'; }
            while ($line =~ /[\${}<>~&\\]/) {
                $outline .= $`;
                $matched = $&;
                $line = $';
                if ($matched eq "\{") {
                    if ($line =~ /^\\em\s*/) { $embrace = $brace;
                                               $outline .= "<em>";
                                               $line = $'; }
                    $brace++;
                } elsif ($matched eq "\}") {
                    $brace--;
                    if ($brace == -1 ) {
			die "Unbalanced braces in bbl file ".
			    "($outline$matched$line";
		    } elsif ($brace == $embrace) { $outline .= "</em>";
						   $embrace = -1; }
                } elsif ($matched eq "\\") {
                    if ($line =~ /^([$TeXaccents])(\w)/) {
                        $outline .= "&$2".$HTMLaccents[index($TeXaccents,$1)];
                    } elsif ($line =~ /^accent\s*127\s*(\w)/) {
                        $outline .= "&$1uml;";
                    } elsif ($line =~ /^ss\s*/) { $outline .= "&szlig;";
                    } elsif ($line =~ /^pif/) {
                        $outline .= "'";
		    } elsif ($line =~ /^URL\{([^\}]*)\}/) {
			$outline .= "<a href=\"$1\">$1</a>"; 
                    } elsif ($line =~ /^-/) {
                        $outline .= ""; # hyphenation help -- ignore
                    } elsif ($line =~ /(.)/) { $outline .= html_literal $1; }
                    $line = $';
                } elsif ($matched eq "~" ) {
                    $outline .= "&nbsp;";
                } elsif ($matched ne "\$") {
                    $outline .= html_literal $matched;
                }
            }
            print "$outline$line\n";
        }
    }
  }
  print "</dl><p>\n";
  if ($mainman == 1) {
    print  "[<a href=\"../index.htm\">Top</a>] "
  };
  print "[<a href=\"chapters.htm\">Up</a>]";
  print "<p>\n$footer\n";
  close OUT;
  select STDOUT;
}

#
# Main program starts here
#
# Process option and sort out input and output directories   
#

getopts('csitn:');

chomp($dir = shift @ARGV);
if (substr($dir,0,1) ne "/") {
    $dir = `pwd` . "/" . $dir;
    $dir =~ s/\n//;
}
if (substr($dir,-1) ne "/") {
    $dir .= "/";
}
unless (-d $dir and -r $dir) {
    die "Can't use input directory $dir";
}

if ($opt_n) {
  # get book title
  $book=$opt_n;
  $booktitle = "The $opt_n share package";
  $mainman=0;
#print "c: $opt_c \n";
}
else {
  if ($dir =~ /\/([^\/]+)\/$/) {
      $book = $1;
  } else {
      die "Can't find basename of $dir";
  }
  if    ($book eq "tut") { $booktitle = "The GAP 4 Tutorial"; }
  elsif ($book eq "ref") { $booktitle = "The GAP 4 Reference Manual"; }
  elsif ($book eq "prg") { $booktitle = "The GAP 4 Programming Tutorial"; }
  elsif ($book eq "ext") { $booktitle = "The GAP 4 Programming Reference Manual"; }
  else  { die "Invalid book, must be tut, ref, prg or ext"; }
  $mainman=1;
}

if ($#ARGV != -1) {
    chomp($odir=shift @ARGV);
} else {
    $odir = "";
}
if (substr($odir,0,1) ne "/") {
    $odir = `pwd` . "/" . $odir;
    $odir =~ s/\n//;
}
if (substr($odir,-1) ne "/") {
    $odir .= "/";
}
unless (-d $odir and -w $odir) {
    die "Can't use output directory $odir";
}
print  "Reading input from $dir\n" unless ($opt_s);
print  "Creating output in $odir\n" unless ($opt_s);

if ($opt_t) {
  # create macro file for our expressions and macros not known to tth in TeX
  # mode.
  open TTHIN, ">tthmacros.tex";
  print TTHIN "\\def\\Q{{\\bf Q}}\\def\\Z{{\\bf Z}}\\def\\N{{\\bf N}}\n";
  print TTHIN "\\def\\frac#1#2{{{#1}\\over{#2}}}\\def\\colon{:}";
  close TTHIN;
}

getchaps;
print  "Processed TOC files\n" unless ($opt_s);
if ($mainman ==1 ) {
  getlabs "tut";
  getlabs "ref";
  getlabs "prg";
  getlabs "ext"; }
else {
  getlabs "../../doc/tut";
  getlabs "../../doc/ref";
  getlabs "../../doc/prg";
  getlabs "../../doc/ext"; 
  getlabs "doc"; # our documentation
}

print  "Processed LAB files\n" unless ($opt_s);

#
# OK go to work
#

CHAP: foreach $chap (@chapters) {
    unless (defined $chap) {
        next CHAP;
    }
    print  "$chap->{name}\n" unless ($opt_s);
    convert_chap $chap;
}

if ($opt_t) {
  # remove the tth stuff
  unlink 'tthin','tthout','tthmacros.tex';
}

print  "and the chapters page\n" unless ($opt_s);
chapters_page;
print  "and the index pages\n" unless ($opt_s);
index_page;
print  "and the references\n" unless ($opt_s);
biblio_page;
print  "done\n" unless ($opt_s);
