#!/usr/bin/perl -w
#
# Script to convert the GAP manual to HTML
# usage convert.pl [-cs] <doc-directory> [<html-directory>]
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
#    html-directory defaults to the current director,
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
$ignoreexp = '\\\\tocstrut|\\\\appno|\\\\seccontents\s+\{\d+\}';

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
            $chap = {name => $2,  
                     number => $1};
            $chap_as_sec = {name => $2,
                            chapnum => $1, 
                            secnum => 0,
                            chapter => $chap};
            $chap->{sections}[0] = $chap_as_sec;
            if (defined ($chapters[$1])) {
                die ("chapter number repeated");
            }
            $chapters[$1] = $chap;
        } elsif ( /$secexp/o ) {
            if (not defined ($chapters[$1])) {
                die ("section in unknown chapter");
            }
            if (defined ( $chapters[$1]{sections}[$2])) {
                die "section number repeated";
            }
            $sec = {name => $3,
                    secnum => $2, 
                    chapnum => $1,
                    chapter => $chapters[$1]};
            $chapters[$1]{sections}[$2] = $sec;
        } elsif ( $_ !~ /$ignoreexp/o ) {
            print STDERR "Bad line: $_";
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
    my ($name) = @_;
    my $bdir = "";
    
    # : indicates a cross-volume reference
    if ($name =~ /^(\w\w\w):(.+)$/) {
        $bdir = "../$1/";
    } else {
        $name = "$book:$name";
    }
    
    my $sec = $sections_by_name{canonize $name};
    unless (defined ( $sec)) {
        return "badlink.htm#$name";
    }
    my ($cnum,$snum) = ($sec->{chapnum},$sec->{secnum});
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
    my $result = "<a name = \"I$indexcount\"></a>\n";
    unless (defined $index{$key}) {
        $index{$key} = [];
    }
    push @{$index{$key}}, [ "$fname#I$indexcount", 
                           "$sec->{chapnum}.$sec->{secnum}" ];
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
@HTMLaccents = ( "acute", "grave", "uml", "tilde", "circ", );

#
# This could probably be done more cleverly -- this routine is too long
#

sub convert_text {
    my $fname = $_[0];
    my $refchars = '[\\w\\s-`\',.:!?$]'; # these make up cross references
    my $boldcommands = 'GAP|CAS|ATLAS|[A-Z]|danger|exercise';
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
	  } else {
	      print STDERR "Line $. ignored in %display{html} mode, " .
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
      		  $outline .= inxentry($fname,$1,$sec);
      	      }
      	      next LINE;
      	  }
      	  # \> and \)  lines (joined with next line if ending in %)
	  if (/^\\[>)]/) {
	      $_ = gather $_;
	  }
      	  if (/^\\>`([^\']+)\'\{([^}]+)\}(!\{.*)?\s*$/) {
      	      $endline = "</code>";
      	      $outline .= inxentry($fname,"$2$3",$sec);
      	      $outline .= "<li><code>";
      	      $tt = 1;
      	      $rest = $1;
      	  } elsif (/^\\>([^!%(]+)(\([^!]*)?(!\{.*)?\s*$/) {
      	      $endline = "</code>";
      	      $outline .= inxentry($fname,"$1$3",$sec);
      	      $outline .= "<li><code>";
      	      $tt = 1;
      	      $rest = "$1$2";
      	  } elsif (/^\\\)(.*)$/) {
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
      	      $ref1 = name2fn $ref;
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
            if ($matched ne "%") {
                $outline .= html_literal $matched;
            }
            next SPECIAL;
        }

        # backslash
        if ($matched eq "\\") {
            # commands that begin a new output line
          NEWLINE: {
            if    ($rest =~ /^beginitems/ and not $inlist)
                                          { $outline .= "<p>\n<dl>";
                                            $inlist = 1;         }
            elsif ($rest =~ /^enditems/ and $inlist)
                                          { $outline .= "</dl>";
                                            $inlist = 0;         }
            elsif ($rest =~ /^beginlist/) { $outline .= "<ul>";  }
            elsif ($rest =~ /^endlist/)   { $outline .= "</ul>"; }
            elsif ($rest =~ /^answer/)    { $outline = "";
                                            $skip_lines = 1; }
            else  { last NEWLINE; }
            print "$outline\n";
            next LINE;
          }
            # commands that are replaced by HTML text
          REPLACE: {
            if    ($rest =~ /^($boldcommands)$EndLaTeXMacro/o) {
                   $outline .= "<strong>".uc($&)."</strong>"; }
            elsif ($rest =~ /^([hv]box|rm)/) { }
            elsif ($rest =~ /^enspace/)    { $outline .= "&nbsp;";       }
            elsif ($rest =~ /^quad/)       { $outline .= "&nbsp;";       }
            elsif ($rest =~ /^qquad/)      { $outline .= "&nbsp;&nbsp;"; }
            elsif ($rest =~ /^l?dots/)     { $outline .= "...";          }
            elsif ($rest =~ /^bs?f|stars/) { $outline .= "<hr>";         }
            elsif ($rest =~ /^cr/)         { $outline .= "<br>";         }
            elsif ($rest =~ /^fmark/)      { $outline .= "<li>";         }
            elsif ($rest =~ /^item\{[^}]*\}/) {
                   $outline .="<li type=disc>"; }
            elsif ($rest =~ /^itemitem\{[^}]*\}/) {
                   $outline .="<li type=circle>"; }
            elsif ($rest =~ /^cite\s*\{\s*(\w+)\s*\}/) {
                $outline .= "<a href=\"biblio.htm#$1\"><cite>$1</cite></a>"; }
            else  { last REPLACE; }
            $rest = $';
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
                $ref1 = name2fn $ref;
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
        $re = "^\\\\Chapter\\{$name1\\}";
    } else {
        $num = $sec->{chapnum} . "." .$sec->{secnum};
        $name = $sec->{name};  
        $name1 = quotemeta $name;
        $re = "^\\\\Section\\{$name1\\}";
    }
    $name2 = kanonize $name;
    $fname = name2fn $sec->{name};
    if ($fname =~ /\#/) { die "Filename $fname contains #" };
    open OUT, ">${odir}${fname}";
    select OUT;

    print  inxentry($fname,$name,$sec);
    print  "<html><head><title>[$book] $num $name2</title></head>\n";
    print  "<body bgcolor=\"ffffff\">\n<h1>$num $name2</h1>\n<p>";

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
      my $link = name2fn $subsec->{name};
      my $name2 = kanonize $subsec->{name};
      print  "<LI> <A HREF=\"$link\">$name2</a>\n";
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
    my $cfname = name2fn $chap->{name};
    print  "[<a href = \"../index.html\">Top</a>] ";
    if ($sec->{secnum} == 0) {
        if ($chap->{number} != 1) {
            my $prev = name2fn $chapters[$chap->{number} - 1]{name};
            print  "[<a href =\"$prev\">Previous</a>] ";
        }
        print  "[<a href = \"chapters.htm\">Up</a>] ";
        if ($chap->{number} != $#chapters) {
            my $next = name2fn $chapters[$chap->{number} + 1]{name};
            print  "[<a href =\"$next\">Next</a>] ";
        }
    } else {
        if ($sec->{secnum} != 1) {
            my $prev = name2fn $chap->{sections}[$sec->{secnum} - 1]{name};
            print  "[<a href =\"$prev\">Previous</a>] ";
        }
        print  "[<a href = \"$cfname\">Up</a>] ";
        if ($sec->{secnum} != $#{$chap->{sections}}) {
            my $next = name2fn $chap->{sections}[$sec->{secnum} + 1]{name};
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
<html><head><title>The GAP 4 $booktitle - Chapters</title></head>
<body bgcolor=\"ffffff\"><h1>The GAP 4 $booktitle - Chapters</h1><ol>
END
    ;

  CHAP: foreach $chap (@chapters) {
      unless (defined $chap) { next CHAP};
        my $link = name2fn $chap->{name};
        my $name2 = kanonize $chap->{name};
        print  "<li><a href=\"$link\">$name2</a>\n";
    }

    print  <<END
</ol><ul>
<li><a href=\"biblio.htm\">References</a>
<li><a href=\"theindex.htm\">Index</a>
</ul><p>
[<a href=\"../index.html\">Top</a>]<p>
END
    ;

    print $footer;
    close OUT;
    select STDOUT;

    # Touch the chapters file so that `make' recognizes the conversion
    # has been done.
    system "touch ${odir}chapters.htm";
}
    
sub caseless { lc($a) cmp lc ($b) or $a cmp $b }

sub index_page {
    my ($ent, $ref, $letter, $nextletter);
    open OUT, ">${odir}theindex.htm";
    select OUT;
    print <<END
<html><head><title>The GAP 4 $booktitle - Index</title></head>
<body bgcolor=\"ffffff\"><h1>The GAP 4 $booktitle - Index</h1>
<p>
END
    ;
    foreach $letter  ("A".."Z") {
        print  "<a href=\"theindex.htm#L$letter\">$letter</A> ";
    }
    print  "\n<ul>";

    $nextletter = "A";
        
  ENTRY: for $ent (sort caseless keys %index) {
      $letter = uc(substr($ent,0,1));
      if ($letter ge "A" and $letter le "Z" and $nextletter le "Z") {
           until ($letter lt $nextletter) {
               print  "<a name = \"L$nextletter\"></a>";
               $nextletter++;
           }
      }
      $ent1 = $ent;
      $ent1 =~ s/!/, /g;
      $ent1 =~ s/[{}]//g;
      print  "<LI>".kanonize $ent1." ";
      for $ref (@{$index{$ent}}) {
          print  "<a href=\"$ref->[0]\">$ref->[1]</a> ";
      }
      print  "\n";
    }
    print  "</ul><p>\n";
    print  "[<a href=\"../index.html\">Top</a>] ";
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
<html><head><title>The GAP 4 $booktitle - References</title></head>
<body bgcolor=\"ffffff\"><h1>The GAP 4 $booktitle - References</h1><dl>
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
                    } elsif ($line =~ /^ss\s*/) { $outline .= "&szlig;";
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
  print "</dl><p>\n[<a href=\"../index.html\">Top</a>] ";
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

getopts('cs');

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
if ($dir =~ /\/([^\/]+)\/$/) {
    $book = $1;
} else {
    die "Can't find basename of $dir";
}
if    ($book eq "tut") { $booktitle = "Tutorial"; }
elsif ($book eq "ref") { $booktitle = "Reference Manual"; }
elsif ($book eq "prg") { $booktitle = "Programming Tutorial"; }
elsif ($book eq "ext") { $booktitle = "Programming Reference Manual"; }
else  { die "Invalid book, must be tut, ref, prg or ext"; }
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

getchaps;
print  "Processed TOC files\n" unless ($opt_s);
getlabs "tut";
getlabs "ref";
getlabs "prg";
getlabs "ext";
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

print  "and the chapters page\n" unless ($opt_s);
chapters_page;
print  "and the index page\n" unless ($opt_s);
index_page;
print  "and the references\n" unless ($opt_s);
biblio_page;
print  "done\n" unless ($opt_s);
