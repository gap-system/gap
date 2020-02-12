#!/usr/bin/perl -w
#
# Script to convert GAP manual TeX files to HTML
# Usage:
#  convert.pl [-csti] [-f <frontpage>] [-n <pkgname>] <doc-dir> [<html-dir>]
#
# Requirements: Perl (might need to edit the first line of this file)
#               TtH is not strictlty necessary but very desirable to treat
#               formulas.
#
#  Caveats: 
#
#  1. This script assumes that the .toc, .lab and .bbl files are up-to-date 
#     with the .tex files and will almost certainly fail horribly if they
#     are not.
#
#  2. The output files are CxxxSxxx.htm, (not .html) plus chapters.htm,
#     theindex.htm and biblio.htm, except when called with the -c option
#     (in which case, there are CHAPxxx.htm files instead of CxxxSxxx.htm).
#     A (front page) file index.htm is assumed, but not created.
#     Not all servers will serve .htm files as HTML without adjustments.
#
#  3. The script assumes that the .tex files comply with GAP conventions, 
#     including unwritten ones. It tries to follow the behaviour of TeX
#     assuming those conventions. The on-line browser attempts to provide
#     an ASCII equivalent. See BUGS.
#
#  4. The hierarchy of the HTML manuals assumed is of the following form:
#
#         <GAPDIR>/
#                 doc/
#                    <main>
#                 pkg/
#                    <pkg>/
#                         htm
#
#     for each main manual <main> (in: ref, tut) and each
#     package <pkg>. To make inter-linking between manuals work,
#     one should generally use the -c option for everything, (or not use
#     it for everything). Linking to package manuals from the main
#     manual can only be expected to work if the package manuals
#     are created using this converter.
#
#  5. Only the manual.lab files for books that are referenced via the
#     \UseReferences and \UseGapDocReferences commands in the manual.tex
#     file of the book being converted (and the book's own manual.lab 
#     file, of course) are read. Make sure all the \UseReferences and
#     \UseGapDocReferences commands needed are present! (The TeX-produced
#     manuals will be missing lots of cross-references also, if some are
#     missing.) You will get `Bad link' messages if you have some missing.
#
#  Options:
#
#    -c  file-per-chapter mode: Generates one HTML file CHAPxxx.htm 
#        for each chapter; sections are level 2 headings and anchors 
#        CHAPxxx.htm#SECTxxx.
#        This is intended for local browsing, especially under MS-DOS.
#        It may be used with the -n (package) option.
# 
#    -f <frontpage> 
#        Adds a "Top" link to link <frontpage> to each manual page, 
#        only available if -n option is also used.
# 
#    -s  silent running: Conversational messages are suppressed.
#
#    -n <pkgname>
#        We are not building the main manual but the one for the 
#        package <pkgname>. To get cross references to the main library
#        right, it assumes that the package is in the right place.
#        The -c option may be used with this option.
#
#    -i  index: Only one index file is produced.
#
#    -t  tex-math: Runs `tth' (which must be installed on the local system)
#        to produce better HTML code for formulae. (It would be possible to
#        replace tth by another conversion, for example TeXexplorer, but
#        (at least) the line calling `tth' would need to be modified.)

#    -u  Like -t, but uses `tth -u2' to produce unicode.
#
#    <doc-dir>  The directory where all the needed .tex, .toc, .lab and .bbl
#               files are located.
#
#    <html-dir> The directory (which should already exist) in which to put 
#               the generated .htm files. Defaults to the current directory,
#               if omitted.
#
#    Example usage:
#      convert.pl -n mypkg doc htm       # in directory .../pkg/mypkg
#      convert.pl -t -n mypkg doc htm    # ditto previous + use tth for maths
#      convert.pl -t -n mypkg -c doc htm # ditto previous + 1 file per chapter
#      convert.pl -t -c ../ref ref       # (for Ref manual) in dir .../doc/htm
#
#  FEATURES (and intended departures from the TeX behaviour)
#     .  Now interprets 2nd argument of an \atindex command if it is
#        of form @... and ignores the first argument, or otherwise it
#        interprets the first argument. Interprets ! as a comma and
#        indices output have no sub-headers.
#     .  The @... component of \> commands is ignored. The assumption
#        is that for: \>`...'{...}@{...}  the @{...} component is just
#        the {...} with font changes.
#     .  In a \beginitems ... \enditems environment everything is indented
#        except for the item headers, rather than just the paragraph
#        following the item header.
#     .  By default, the \beginlist ... \endlist environment is interpreted
#        as a compact description list. By adding %unordered or %ordered...
#        markup it will be interpreted as either an unordered or ordered
#        list respectively (see gapmacro documentation for details).
#     .  There are spacing differences e.g. \begintt ... \endtt etc.
#        environments are not indented.
#     .  Supports all accents of TeX, in probably the best way currently
#        possible with HTML.
#     .  Treats PseudoInput chapters in the `same' way as Input chapters.
#     .  With -t switch announces the version of TtH used.
#     .  Now supports %display{nontex}, %display{nontext} and
#        %display{nonhtml} variants of %display environment.
#     .  References to subsections are now interpreted as one would expect.
#
#  BUGS (and known departures from the TeX behaviour)
#     .  $a.b$ is only interpreted correctly in -t mode.
#     .  The citation keys that appear are the .bib file keys rather
#        than the keys BibTeX constructs with the `alpha' bib-style.
#
#  TODO
#     .  Refine macro_replace subroutine so it can also be used to purge 
#        2nd arg of \atindex macros.
#     .  For -t mode, scan for \def commands in manual.tex and write
#        to TTHIN (tthmacros.tex). Should we only look for a block
#        demarcated by %mathsmacros ... %endmathsmacros ?
#        These \def commands are only intended for such font
#        changing commands as: \def\B{{\cal B}} (`tth' provides a
#        script-type font).
#     .  Provide a table environment, if/when a \begintable ...
#        \endtable environment is added to gapmacro.tex.
#
#############################################################################

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
#  $lastnumchap -- number of last numerically numbered chapter
#


# These match chapter and section lines in a .toc file
#

$chapexp = '\\\\chapcontents\s+\{((?:\d+|[A-Z]))\}\s*\{(.+)\}\s*\{\d+\}';
$secexp = '\\\\seccontents\s+\{((?:\d+|[A-Z]))\.(\d+)\}\s*\{(.+)\}\s*\{\d+\}';
#$ignoreexp = '\\\\tocstrut|\\\\appno|\\\\seccontents\s+\{\d+\}';
$lastnumchap = 0;

# Variable that is set to 2 inside a nest of \itemitem s of a
# \beginlist ... \endlist environment
#

$listdepth = 0;

# This is augmented each time a line: \Package{...} is read in a manual.tex
# file, so that macro_replace knows to set a {\...} macro in sans-serif.
#

$sharepkg = "";

# The books converted to HTML with this converter
# The values set are: 0 or 1 according to whether or not -c was used.
#

%convertbooks = ();

# This is added to when scanning GAPDoc manuals. 
#

%gapdocbooks = ();

# Types of href label are:
# 0 (non -c books) : C<MMM>S<NNN>.htm
# 1 (-c books)     : CHAP<MMM>.htm#SECT<NNN>
# 2 (== $gapdoc)   : chap<M>.html#<gapdoc-id>
#
# It would be nice to support subsections properly like GapDoc,
# but this involves creating a subsection data-structure modelled
# on section, which is a mite non-trivial (maybe ... if I find time).
# For now in-text references go to the beginning of the chapter.
#
# BH: it might be easier to use tags based on the name of the function

$gapdoc = 2;

# sansserif:
#
# Used mainly to set GAP in sans serif font. Inside <title> ... </title>
# there should *not* be any tags, since they are not translated there by
# web browsers, and hence sansserif should *not* be applied to anything
# that ends up in the <title> ... </title> field, but *is* quite appropriate
# for the header in the <h1> ... </h1> field at the top of the body of an
# HTML file and anywhere else within the body of an HTML file.
#
sub sansserif {
    my ($name) = @_;
    return "<font face=\"Gill Sans,Helvetica,Arial\">$name</font>";
}

# booktitle_body:
#
# This is for generating the title of a document that goes in the 
# <h1> ... </h1> field at the top of the body, as opposed to the title 
# that goes in the <title> ... </title> field which should be unembellished.
#
sub booktitle_body {
    my ($bktitle, @prog_or_pkg) = @_;
    foreach $prog_or_pkg (@prog_or_pkg) {
        $newstring = sansserif $prog_or_pkg;
        $bktitle =~ s/$prog_or_pkg/$newstring/;
    }
    return $bktitle;
}

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

sub def_section_by_name {
    my ($sec, $chapno, $secno, $ssecno, $name) = @_;
    my $secname = canonize $1;
    if (defined $sections_by_name{$secname}) {
        if (($sections_by_name{$secname}->{chapnum} ne $chapno) ||
            ($sections_by_name{$secname}->{secnum}  ne $secno)  ||
            ($sections_by_name{$secname}->{ssecnum} ne $ssecno)) {
            print STDERR "Section: \"$secname\" already defined as: ",
                         "$sections_by_name{$secname}->{chapnum}.",
                         "$sections_by_name{$secname}->{secnum}.",
                         "$sections_by_name{$secname}->{ssecnum}\n";
            print STDERR "Now being redefined as: $chapno.$secno.$ssecno\n";
            $redefined_secname{$secname} = 1;
        } else {
            return;
        }
    }
    $sections_by_name{$secname}
         = {chapnum => $chapno,
            secnum  => $secno,
            ssecnum => $ssecno,
            name => $name};
   # print STDERR "Defined section \"$secname\": $chapno.$secno.$ssecno $name\n";
}

sub tonum { # Needed since chanu may be A,B,... for appendices
    my ($chanu) = @_;
    return $chanu =~ /\d+/ ? $chanu : $lastnumchap + ord($chanu) - ord('A') + 1;
}

# getchaps:
#
# Scan the .tex and .toc files to get chapter names and numbers, 
# section names and numbers and associated filenames.
# Loads up chapters and sections_by_name.
#

sub getchaps {
    open( TOC, "<${dir}manual.toc" ) 
        || die "Can't open ${dir}manual.toc.\n You can " .
               "create the .toc file by doing: tex manual (at least once).\n";
    my ($chap,$sec,$chapno,$chap_as_sec,$chapnam,$chanu);
    while (<TOC>) {
        if ( /$chapexp/o ) {
	    $chapnam = $2;
	    $chanu   = $1;
            $lastnumchap = $chanu if ( $chanu =~ /\d+/ );
		
	    # remove `(preliminary)' part that messes everything up
	    $chapnam =~ s/ \(preliminary\)//g;

            $chap = {name => $chapnam,  
                     number => $chanu};
            $chap_as_sec = {name => $chapnam,
                            chapnum => $chanu, 
                            secnum => 0,
                            chapter => $chap};
            $chap->{sections}[0] = $chap_as_sec;
            defined ($chapters[tonum $chanu]) && die "chapter number repeated";
            $chapters[tonum $chanu] = $chap;
        } elsif ( /$secexp/o ) {
            defined ($chapters[tonum $1])
                || die "section $2:$3 in unknown chapter $1";
            defined ($chapters[tonum $1]{sections}[$2]) 
                && die "section number repeated";
            $sec = {name => $3,
                    secnum => $2, 
                    chapnum => $1,
                    chapter => $chapters[tonum $1]};
            $chapters[tonum $1]{sections}[$2] = $sec;
# this would produce warnings from empty chapters. Thus ignore.
#        } elsif ( $_ !~ /$ignoreexp/o ) {
#            print STDERR "Bad line: $_";
        }
    }
    close TOC;
    open (TEX, "<${dir}manual.tex") || die "Can't open ${dir}manual.tex";
    $chapno = 0;
    while (<TEX>) {
        if ( /^[^%]*\\(|Pseudo)Input\{([^}]+)\}(\{([^}]+)\}\{([^}]+)\})?/ ) {
            if (not -f "$dir$2.tex" or not -r "$dir$2.tex") {
                print STDERR "Chapter file $2.tex does not exist in $dir\n";
            }
            if ($1 eq "") {
                $chapters[++$chapno]{file} = $2;
            } else {
       	        $chapnam = $5;
	        $chanu   = ++$chapno;
                $lastnumchap = $chanu;

                $chap = {name => $chapnam,  
                         number => $chanu};
                $chap_as_sec = {name => $chapnam,
                                chapnum => $chanu, 
                                secnum  => 0,
                                ssecnum => 0,
                                chapter => $chap};
                if ($4 ne $5) {
                    def_section_by_name("$book:$chapnam", $chanu, 0, 0, canonize $chapnam);
                    add_to_index(htm_fname($opt_c,$chanu,0, 0, ""), 
                                           $4, $chap_as_sec, 0);
                }

                $chap->{sections}[0] = $chap_as_sec;
                defined($chapters[$chanu]) && die "chapter number repeated";
                $chapters[$chanu] = $chap;
                $chapters[$chanu]{file} = $2;
            }
        } 
    }
    close TEX;
}

sub getlabs {
  my ($bkdir) = @_;

  open (LAB, "<${bkdir}manual.lab") || print "Can't open ${bkdir}manual.lab";
    while (<LAB>) {
      if ( /\\setcitlab/ ) {
	  next; # We don't get the bibliography labels from here
      } elsif ( /\\GAPDocLabFile\s*\{([^}]+)\}/ ) {
        $gapdocbooks{$1} = 1;
        print STDERR "GapDoc books: ", keys(%gapdocbooks), "\n";
      } elsif (/\\makelabel\s*\{([^}]+)\}\s*\{(\w+)(\.(\d+))?(\.(\d+))?\}\{([^}]+)\}/) {
        def_section_by_name($1, $2, (defined($3) ? $4 : 0),
				      (defined($5) ? $6 : 0), $7);
      } elsif (/\\makelabel\s*\{([^}]+)\}\s*\{(\w+)(\.(\d+))?(\.(\d+))?\}/) {
          def_section_by_name($1, $2, (defined($3) ? $4 : 0),
          (defined($5) ? $6 : 0), "");
      } else {
	  chomp;
	  print STDERR "Ignored line: $_\n... in ${bkdir}manual.lab\n";
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
$footer = "<P>\n" . sansserif( "GAP 4 manual<br>" . `date +"%B %Y"` ) .
          "</body></html>";

# Section label ... this is the bit that goes after a # in an HREF link
# or is assigned to the value of NAME in an anchor.
#
sub sec_label {
    my ($c_s_gapdoc,$cnum,$snum,$ssnum) = @_;

    if ($c_s_gapdoc == $gapdoc) {
      return "s${snum}ss${ssnum}";
    }

    $snum = "0" x (3 - length $snum) . $snum;
    if ($c_s_gapdoc) {
        if ($snum eq "000") {
            return "";
        } elsif ($ssnum) {
            return "SSEC${snum}.$ssnum";
        } else {
            return "SECT${snum}";
        }
    } else {
        return ($ssnum) ? "SSEC$ssnum" : "";
    }
}

# The HREFs of subsections, sections and chapter files are determined by
# this routine directly if the chapter, section, subsection numbers are known.
sub htm_fname {
    my ($c_s_gapdoc,$cnum,$snum,$ssnum,$name) = @_;
    # print STDERR "making htm_fname from $cnum.$snum.$ssnum $name\n";

    my $seclabel = "$name";
    
    $seclabel = sec_label($c_s_gapdoc,$cnum,$snum,$ssnum) if ($seclabel eq "");
    $seclabel = "#$seclabel" if ($seclabel ne "");
    # print STDERR "made $seclabel\n";
 
    if ($c_s_gapdoc == $gapdoc) {
      return "chap${cnum}.html$seclabel";
    }
    
    $cnum = "0" x (3 - length $cnum) . $cnum;
    $snum = "0" x (3 - length $snum) . $snum;
    return ($c_s_gapdoc) ? "CHAP${cnum}.htm$seclabel" 
                         : "C${cnum}S$snum.htm$seclabel";
}

# Returns the value that $opt_c must have had when the book $book
# was compiled with this converter.
sub hreftype {
    my ($book, $bdir) = @_;
    if ( !(exists $convertbooks{$book}) ) {
      my @ls = `ls ${odir}$bdir`;
      $convertbooks{$book} 
          = (grep { m/^CHAP...[.]htm$/ } @ls) ?
                1 :             # .htm files have shape CHAP<MMM>.htm
                (grep { m/^CHAP...[.]htm$/ } @ls) ?
                    0 :         # .htm files have shape C<MMM>S<NNN>.htm
                    (grep { m/^chap...[.]html$/ } @ls) ?
                        2 :     # .html files have shape chapM.html
                        $opt_c; # can't determine the shape ... don't exist
                                # yet ... we assume the shape of the current
                                # manual being compiled.
    }
    return $convertbooks{$book};
}

# The names of the section and chapter files are determined by this routine
# when one has to determine the chapter and section number indirectly.
sub name2fn {
    my ($name,$ischap) = @_;
    my $bdir = "";
    my $c_s_gapdoc = $opt_c;

    # : indicates a cross-volume reference
    my $canon_name = canonize $name;
    #print STDERR "canon_name = $canon_name\n";
    if ( $canon_name =~ /^(ref|tut):/ ) {
      if ($mainman==1) {
	$bdir = "../$1/";
      } else {
        $bdir = "../../../doc/$1/";
      }
      $c_s_gapdoc = hreftype($1, $bdir);
    } elsif ($canon_name =~ /^([a-zA-Z_0-9]*):/ ) {
      # presumably a package name
      #print STDERR "package name = $1\n";
      if ($mainman==1) {
        if (exists $gapdocbooks{$1}) {    # a main manual referring
	  $bdir = "../../../pkg/$1/doc/"; # to a GapDoc-produced manual
          $c_s_gapdoc = $gapdoc;
        } else {
	  $bdir = "../../../pkg/$1/htm/";
          $c_s_gapdoc = hreftype($1, $bdir);
        }
      } elsif (exists $gapdocbooks{$1}) { # a package manual referring
	$bdir = "../../$1/doc/";          # to a GapDoc-produced manual
        $c_s_gapdoc = $gapdoc;
      } else {
	$bdir = "../../$1/htm/";
        $c_s_gapdoc = hreftype($1, $bdir);
      }
    } elsif ($canon_name !~ /^($book):/) {
        $name = "$book:$name";
        $canon_name = canonize $name;
    }
    $name =~ s/\s+/ /g;
    
    if (exists $redefined_secname{$canon_name}) {
        print STDERR "Ref to multiply defined label: ",
                     "\"$name\" at line $. of $chap->{file}.tex\n";
    }
    my $sec = $sections_by_name{$canon_name};

    unless (defined ( $sec)) {
        print STDERR "Bad link: \"$name\" at line $. of $chap->{file}.tex\n";
        return "badlink:$name";
    }
    return $bdir . htm_fname($c_s_gapdoc,
                             $sec->{chapnum}, 
                             ($ischap == 1) ? 0 : $sec->{secnum},
                             ($ischap == 1) ? 0 : $sec->{ssecnum},
                             $sec->{name});
}


# strip out the tag from cross book references for the body of links
sub name2linktext {
   my $name;
  ($name) = @_;
  $name =~ s/^(ref|tut)://;
  return $name;
}

#
# Add an index entry to the index. 
# ($hname = $fname or $fname#..., where $fname is a filename)
sub add_to_index {
    my ($hname, $key, $sec) = @_;
    my $secno = "$sec->{chapnum}.$sec->{secnum}";
    if (defined $sec->{ssecnum} and $sec->{ssecnum}) {
         $secno .= ".$sec->{ssecnum}";
    }
    push @{$index{$key}}, [ $hname, $secno ];
#   print STDERR "hname = $hname, key = $key, ";
#   print STDERR "sec = $secno\n";
}

#
# Create a label for an index entry, add it to the index if new,
# and return the label (which is an empty string if not new).
sub inxentry {
    my ($fname,$key,$sec) = @_;
    my $curs="$sec->{chapnum}.$sec->{secnum}";
#   print STDERR "curs = $curs\n";
#   print STDERR "fname = $fname, key = $key, ";
#   print STDERR "sec = $sec->{chapnum}.$sec->{secnum}\n";
    my $label = "<a name = \"I$indexcount\"></a>\n";
    if (defined $index{$key}) {
        my $ar;
        foreach $ar (@{$index{$key}}) {
	    if ( ($ar->[1]) eq $curs ) {
	       $label="";  # index entry is not new
               last;
	    }
        }
    } else {
        $index{$key} = [];
    }
    if ($label ne "") {
        add_to_index("$fname#I$indexcount", $key, $sec);
#       print STDERR "$fname#I$indexcount\n";
        $indexcount++;
    }
    return $label;
} 

#
# Return a NAME anchor for a subsection
#
sub subsec_name {
    my ($fname,$key,$sec) = @_;
#   print STDERR "curs = $curs\n";
#   print STDERR "sec = $sec->{chapnum}.$sec->{secnum}.$sec->{ssecnum}\n";
    $key =~ s/!\{(.*)\}$/!$1/;
    $key =~ s/\s+/ /g;
    my $canon_name =  canonize "$book:$key";
    my $sec_of_key = $sections_by_name{$canon_name};
    if (exists $redefined_secname{$key}) {
        print STDERR "Multiply defined label: ",
                     "\"$key\" at line $. of $chap->{file}.tex\n",
                     "... subsection will be unreachable\n";
        return "";
    } elsif ($sec_of_key->{chapnum} ne $sec->{chapnum} ||
             $sec_of_key->{secnum}  ne $sec->{secnum}) {
        print STDERR "Section of \"$key\" (",
                     "$sec_of_key->{chapnum}.$sec_of_key->{secnum}) ",
                     "doesn't agree with the current section (",
                     "$sec->{chapnum}.$sec->{secnum}) ",
                     "at line $. of $chap->{file}.tex\n",
                     "... subsection will be unreachable\n";
        return "";
    } else {
        my $curs = "$sec_of_key->{chapnum}.$sec_of_key->{secnum}" .
                                         ".$sec_of_key->{ssecnum}";
        my $label = sec_label($opt_c, $sec_of_key->{chapnum},
                                      $sec_of_key->{secnum},
                                      $sec_of_key->{ssecnum});
        if (defined $index{$key}) {
            my $ar;
            foreach $ar (@{$index{$key}}) {
	        if ( ($ar->[1]) eq $curs ) {
	           return "";  # index entry is not new
	        }
            }
        } else {
            $index{$key} = [];
        }
#       print STDERR "Subsection key: \"$key\"\n";
        add_to_index("$fname#$label", $key, $sec_of_key);
        return "<a name = \"$label\"></a>\n";
    }
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
    my ($line, $nontex) = @_;
    my $nextline;
    while ($line =~ s/%+\s*$// and defined($nextline = <IN>)) {
        $nextline =~ s/^%// if $nontex;
        unless ($nextline =~ /^%/) {
            $nextline =~ s/^\s*//;
	    $line .= $nextline;
	    chomp $line;
        }
    }
    return $line;
}


# This routine is called to process the text of the section
# the output file is assumed to be pre-selected. The input filehandle
# is simply IN
# 
# As we process, we can be in "normal" mode (text), "maths" mode 
# inside $ ... $, or "verbatim" mode inside a multi-line example
#
# We separately track whether we are in bold or tt, 
# whether we are in a xxx: .... paragraph and whether we are reading
# a cross-reference that is split across multiple lines
#
# Finally, we track whether we have already
# emitted a <P> for this group of blank lines
#


$boldcommands = 'CAS|[A-Z]|danger|exercise';
$TeXbinops = "in|wedge|vee|cup|cap|otimes|oplus|le|ge|rightarrow";
$EndTeXMacro = "(?![A-Za-z])";
$TeXaccents = "\'`~=^";  # ^ must come last, this is also used as regexp
# From these and the argument following the HTML symbol is built
# e.g. `a -> &agrave;
%accents = ( "\'" => "acute",  "19" => "acute",
             "`"  => "grave",  "18" => "grave", 
             "~"  => "tilde", "126" => "tilde",
             "^"  => "circ",   "94" => "circ",
             "c"  => "cedil",  "48" => "cedil",
             "H"  => "uml",   "125" => "uml",  "127" => "uml"  );
# These are the replacements for accents that have an empty argument
# or for which there is no single HTML symbol (so that the accent must 
# precede the argument)
%acc_0arg = ( "\'" => "\'",    "19" => "\'",
              "`"  => "`",     "18" => "`", 
              "~"  => "~",    "126" => "~",
              "="  => "macr",  "22" => "macr",
              "^"  => "^",     "94" => "^",
              "c"  => "",      "48" => "",    # too hard ... just omit
              "d"  => "",                     # too hard ... just omit
              "b"  => "",                     # too hard ... just omit
              "t"  => "",                     # too hard ... just omit
              "u"  => "\\u",   "21" => "\\u", # too hard ... put back
              "v"  => "\\v",   "20" => "\\v", # too hard ... put back
              "H"  => "uml",  "125" => "uml",  "127" => "uml"  );

# Calls tth to find out its version number
sub tth_version {
    `tth -H >tthout 2> tthout`;
    open (TTHOUT, "<tthout") || die "Can't read tthout\n";
    while (<TTHOUT>) {
        if (s/.*(Version [^ ]*).*/$1/) {
            close TTHOUT;
            system("rm tthout");
            chomp;
            return $_;
        }
    }
}


# We use this routine when using -t option to do any maths translation
sub tth_math_replace {
    my ($tth) = @_;
    open (TTHIN, ">tthin") || die "Can't create tthin";
#print STDERR "in: ${tth}\n";
    my $tthorig = $tth;
    # replace <...> by proper TeX
    while ($tth =~ /(.*?[^\\])<(.*?[^\\])>(.*)/) {
        $tth= $1."{\\it ".$2."\\/}".$3;
#print STDERR "tth: ${tth}\n";
    }
    # replace `...' by proper TeX
    while ($tth =~ /(.*[^\\])`(.*[^\\])\'(.*)/) { 
        $tth= $1."{\\tt ".$2."}".$3;
    }
    # replace \< by proper TeX
    while ($tth =~ /(.*[^\\])\\<(.*)/) {
        $tth= $1."<".$2;
    }
    #while ($tth =~ /(.*[^\\])\\>(.*)/) {
    #	$tth= $1.">".$2;
    #}

    $tth =~ s/([^\\]|^)([.])/$1\\cdot /g; # . not preceded by \ becomes \cdot
    $tth =~ s/\\[.]/./g;                  # \. becomes .
    $tth =~ s/(\\right)\\cdot/$1./g;      # ... except for \right. (leave as is)
    $tth =~ s/(\\not)\s*/$1/g;
    $tth =~ s/\\\*/*/g;
    if ($opt_t < 2.52) {
        $tth =~ s/\\not\\in(?![a-zA-Z])/\\notin/g;
        $tth =~ s/\\not\\subset/ not subset/g;
    }
    # Ensure display mode used for \buildrel and \choose constructions
    $tth =~ s/\$/\$\$/g if ($tth =~ /\\buildrel|\\choose/ and $tth !~ /\$\$/);
    if ($tth =~ /\\[A-Za-z]/) {
      # there might be macros: Load our macros
#print STDERR "tth: ${tth}\n";
      print TTHIN "\\input tthmacros.tex\n";
    }
    # we put in TTHBEGIN .. TTHEND
    # so we can strip out the superfluous <p>s
    # tth 2.78+ puts in, later.
    print TTHIN "TTHBEGIN${tth}TTHEND\n";
    close TTHIN;
    `$tthbin -r -i <tthin >tthout 2>/dev/null`; 
    open (TTHOUT, "<tthout") || die "Can't read tthout";
    $tth="";
    while ( $tthin = <TTHOUT> ) {
      chomp($tthin);
      $tth .= $tthin;
    }
    close TTHOUT;
#print STDERR "out: ${tth}\n";
    # only the stuff between TTHBEGIN and TTHEND
    # actually belongs to the formula translated
    $tth =~ s/.*TTHBEGIN(.*)TTHEND.*/$1/ 
        || do {print STDERR "!tth failed with input:\n $tthorig\n",
                            "!Null formula written to HTML file\n";
               $tth = "";};
    # tth leaves \mathbin etc. in ... get rid of them if present
    $tth =~ s/\\math(bin|rel|op)//g;
    # TtH up to version 2.86 doesn't know the following
    $tth =~ s/\\wr(?![a-zA-Z])/ wr /g;
    $tth =~ s/\\vdash(?![a-zA-Z])/ |- /g;
    $tth =~ s/\\tilde(?![a-zA-Z])/~/g; # needed for in-line maths
#print STDERR "stripped: ${tth}\n";

    # replace italic typewriter (happens because we force
    # italic letters) by roman typewriter style
    while ($tth =~ /(.*)<tt><i>(.*)<\/i><\/tt>(.*)/) {
      $tth= $1."<tt>".$2."</tt>".$3;
    }

    # increasing the font size doesn't affect maths displays
    # ... and `...' markup doesn't get increased in font size
    # So let's get rid of it.
    #$tth = "<font size=\"+1\">$tth</font>";
#print STDERR "enlarged: ${tth}\n";
    return $tth;
}

# 
# Takes a line of form: "<head><spaces>{<arg>}<rest>" 
# and returns an array with: <rest>, <arg>, <head>
# i.e. it finds the matching } for {.
sub get_arg {
    my ($line) = @_;
    if ($line =~ /\s*\{([^{}]*)/) {
        $line = $`;
        my $arg = $1;
        my $rest = $';
        my $nbraces = 1;
        while ($nbraces) {
            if ($rest =~ s/^(\{[^{}]*)//) {
                $arg .= $1;
                $nbraces++;
            } elsif ($nbraces == 1 and $rest =~ s/^\}//) {
                $nbraces--;
            } elsif ($rest =~ s/^(\}[^{}]*)//) {
                $arg .= $1;
                $nbraces--;
            } else { # abort ... but make sure braces match
                $rest = "{" x $nbraces . $rest;
                $arg .= "}" x ($nbraces - 1);
                $nbraces = 0;
            }
        }
        return ($rest, $arg, $line);
    } else {
        print STDERR "line:$line\n";
        die "Expected argument: at line $. of file";
    } 
}

#
# Given an accent macro with the \ or \accent stripped and the rest
# of a line with the macro's argument at it beginning return the
# HTML version of the accented argument and rest after the macro's
# argument has been stripped from it.
sub do_accent {
    my ($rest, $macro) = @_;
    $rest =~ /^(\w)|\{(\w?)\}/;
    $rest = $';
    my $arg = (defined $1) ? $1 : $2;
    $macro = ($arg eq "") ? $acc_0arg{$macro} : "&$arg$accents{$macro};";
    return ($rest, $macro);
}

#
# Takes rest which has a TeX macro without its \ at its beginning and
# returns the HTML version of the TeX macro and rest with the TeX macro
# stripped from it.
sub macro_replace {
    my ($rest) = @_;
    if ($rest =~ /^([$TeXaccents])\s*/) { 
        return do_accent($', $1);
    } 
    if ($rest =~ /^([a-zA-Z]+)\s*/) {
        $rest = $';
        my $macro = $1;
        if ($macro eq "accent") {
            $rest =~ /^(\d+)\s*/;
            $rest = $';
            $macro = $1;
            $macro = "" unless (defined $acc_0arg{$macro});
        }
        if (defined $accents{$macro})     { return do_accent($rest, $macro); }
        elsif (defined $acc_0arg{$macro}) { return ($rest, $acc_0arg{$macro}); }
        elsif ($macro eq "copyright")     { return ($rest, "&copy;"); }
        elsif ($macro eq "aa")            { return ($rest, "&aring;"); }
        elsif ($macro eq "AA")            { return ($rest, "&Aring;"); }
        elsif ($macro eq "lq")            { return ($rest, "`"); }
	elsif ($macro =~ /^(rq|pif)$/)    { return ($rest, "'"); }
        elsif ($macro =~ /^($boldcommands)$/) 
          { return ($rest,"<font face=\"helvetica,arial\">".uc($&)."</font>"); }
        elsif ($macro =~ /^(GAP|ATLAS|MOC$sharepkg)$/)
          { return ($rest, sansserif $macro); }
        elsif ($macro eq "package")
          { my ($last, $arg, $first) = get_arg("$rest"); # $first = ""
            return ($last, sansserif $arg);}
        elsif ($macro eq "sf")
          { my ($last, $arg, $first) = get_arg("{$rest"); # $first = ""
            return ($last, sansserif $arg);}
        elsif ($macro =~ /^([hv]box|rm|kernttindent|math(bin|rel|op))$/) 
          { return ($rest, "");}
        elsif ($macro =~ /^(obeylines|(begin|end)group)$/) 
          { return ($rest, "");}
        elsif ($macro =~ /^hfil(|l)$/)    { return ($rest, " ");}
        elsif ($macro =~ /^break$/)       { return ($rest, "<br>");}
        elsif ($macro =~ /^(it|sl)$/) 
          { my ($last, $arg, $first) = get_arg("{$rest"); # $first = ""
            return ("$arg}\\emphend $last", "<em>");}
	# pseudo ``emph'' end token
        elsif ($macro eq "emphend")      { return ($rest, "</em>");        }
        elsif ($macro eq "hrule")        { return ($rest, "<hr>");         }
        elsif ($macro eq "enspace")      { return ($rest, "&nbsp;");       }
        elsif ($macro eq "quad")         { return ($rest, "&nbsp;");       }
        elsif ($macro eq "qquad")        { return ($rest, "&nbsp;&nbsp;"); }
	elsif ($macro eq "ss")           { return ($rest, "&szlig;");      }
	elsif ($macro eq "o")            { return ($rest, "&oslash;");     }
	elsif ($macro eq "O")            { return ($rest, "&Oslash;");     }
        elsif ($macro =~ /^l?dots$/)     { return ($rest, "...");          }
        elsif ($macro =~ /^bs?f|stars$/) { return ($rest, "<hr>");         }
        elsif ($macro eq "cr")           { return ($rest, "<br>");         }
	# <li> in the next line would be invalid HTML
        elsif ($macro eq "fmark")        { return ($rest, "&nbsp;");         }
        elsif ($macro eq "item") 
          { ($rest, $itemarg, $first) = get_arg("$rest"); # $first = ""
            if ($listdepth == 2) {
                $listdepth = 1;
                if ($listtype eq "d") {
                    return ("$itemarg\\itmnd $rest", "\n</dl>\n<dt>");
                } else { #ignore bit in braces (ordered and unordered lists)
                    return ($rest, "\n</${listtype}l>\n<li>");
                }
            } else {
                if ($listtype eq "d") {
                    return ("$itemarg\\itmnd $rest", "<dt>");
                } else { #ignore bit in braces (ordered and unordered lists)
                    return ($rest, "<li>");
                }
            }
          }
        elsif ($macro eq "itemitem")
          { ($rest, $itemarg, $first) = get_arg("$rest"); # $first = ""
            $rest =~ /^(%(un|)ordered)? #defines $sublisttype
                       (\{([1aAiI])\})? #defines TYPE of ordered sublist
                       (\{(\d+)\})?     #defines START of ordered sublist
                       /x;
            if ($listdepth == 1) {
                $sublisttype = list_type($1, $2);
                $sublistentry = begin_list($sublisttype, $3, $4, $5, $6) . "\n";
                $listdepth = 2;
            } else {
                $sublistentry = "";
            }
            if ($sublisttype eq "d") {
                return ("$itemarg\\itmnd $rest", "$sublistentry<dt>");
            } else { #ignore bit in braces (ordered and unordered lists)
                return ($rest, "$sublistentry<li>");
            }
          }
	# pseudo ``itemend'' character
        elsif ($macro eq "itmnd")        { return ($rest, "<dd>");         }
        elsif ($macro eq "cite" and $rest =~ /^\{\s*(\S+)\s*\}/) 
          { return ($', "<a href=\"biblio.htm#$1\"><cite>$1</cite></a>"); }
        elsif ($macro eq "URL" and $rest =~ /^\{([^\}]*)\}/) 
          { return ($', "<a href=\"$1\">$1</a>"); }
        elsif ($macro eq "Mailto" and $rest =~ /^\{([^\}]*)\}/) 
          { return ($', "<a href=\"mailto:$1\">$1</a>"); }
        else                             { return ($rest, $macro); }
    } elsif ($rest =~ /^-/) { 
        return ($', ""); # hyphenation help -- ignore
    } elsif ($rest =~ /^</) { 
        return ($', "&lt;");
    } elsif ($rest =~ /^\&/) { 
        return ($', "&amp;");
    } else {
        $rest =~ /^./;
        return ($', $&);
    }
}

# Returns the type of a list

sub list_type {
    my ($type, $un) = @_;
    return ( !(defined $type) ) ? "d"          #descriptive
                                : ($un eq "un")
                                    ? "u"      #unordered
                                    : "o";     #ordered
}

# Returns a string for starting a list of the appropriate type

sub begin_list {
    my ($listtype, $otypedef, $otype, $ostartdef, $ostart) = @_;
    my $beginlist = "<${listtype}l";
    if      ($listtype eq "d") {
      $beginlist .= " compact";
    } elsif ($listtype eq "o") {
      if ( (defined $otypedef) && (defined $otype) ) {
        $beginlist .= " type=$otype";
        if ( (defined $ostartdef) && (defined $ostart) ) {
          $beginlist .= " start=$ostart";
        }
      }
    }
    $beginlist .= ">";
    return $beginlist;
}

#
# This could probably be done more cleverly -- this routine is too long
#

sub convert_text {
    my $fname = $_[0];
    my $refchars = '[\-\\w\\s`\',./:!()?$]'; # these make up cross references
    my $ref = "";
    my $endline = "";    # used for </code> at the end of line
    my $mode = "normal"; # $mode can be: 
                         #  "normal"   : TeX macros need to be interpreted
                         #  "verbatim" : No interpretation done, except that
                         #               || is converted to |.
                         #  "html"     : No interpretation done, except that
                         #               initial % is removed.
                         #  "maths"    : A variant of "normal" where inside
                         #               $...$ or $$...$$ (TeX's math mode)
    my $ttenv = 0;  # $ttenv is set to 1 in \begintt .. \endtt "verbatim" mode
    my $nontex = 0; # $nontex is set to 1 in %display{nontex} and 
                    #  %display{nontext} env'ts, for which $mode is "normal"
                    #  but initial % of each line is removed.
    my $skip_lines = 0; # $skip_lines is set non-zero in %display{tex},
                        #  %display{text}, %display{jpeg}, %display{nonhtml}
                        #  and \answer env'ts
    my ($bold,$tt,$it,$sub,$sup,$inlist,$inref,$donepar) = (0,0,0,0,0,0,0);
    my ($indexarg,$indexarg2,$zwei,$drei,$vier,$macro,$endmath,$endmathstring);

    #
    # Now we loop over lines. a line with 16 initial % signs marks 
    # end of section
    #

  LINE: while (defined($_ = <IN>) and not /^\%{16,}/) {
      chomp;                    # drop the trailing newline
      my $rest = $_;            # rest of the line to scan
      my $outline = "";         # build the output in here

      # First we deal with various special whole lines.
      # \beginexample, \begintt, %display (this may end a $skip_lines)
      if ($mode eq "normal" and /^\\begin(example|tt)/) {
          if ($_ =~ /^\\begintt/) { # This is to catch a \begintt .. \endtt
              $ttenv = 1;           # environment enclosing \beginexample ..
          }                         # \endexample
          $mode = "verbatim";
          $skip_lines = 0;
          print "<pre>\n";
          next LINE;
      } elsif ($mode eq "normal" and /^%display\{nontex(|t)\}/) {
	  $nontex = 1;
          $skip_lines = 0;
          next LINE;
      } elsif ($mode eq "normal" and /^%display\{(text?|jpeg|nonhtml)\}/) {
      	  # Paragraphs to be skipped by HTML.
	  $mode = "normal";
          $nontex = 0;
      	  $skip_lines = 2;
      	  next LINE;
      } elsif ($mode eq "normal" and /^%display\{html\}/) {
	  $mode = "html";
          $skip_lines = 0;
      } elsif ($mode eq "html" and /^%display\{text\}/) {
	  $mode = "normal";
          $nontex = 0;
          $skip_lines = 2;
          next LINE;
      } elsif (/^%enddisplay/ and !$ttenv) {
	  if ($mode eq "verbatim") {
	      print "</pre>\n";
	  }
	  $mode = "normal";
          $nontex = 0;
	  $skip_lines = 0;
	  next LINE;
      } elsif ($mode eq "verbatim") {
	  # \endexample, \endtt
	  if (/^\\endtt/ or (/^\\endexample/ and !$ttenv)) {
	      $mode = "normal";
              $ttenv = 0;
	      print "</pre>\n";
	      next LINE;
	  }
	  # |_
	  if (/^\|_/) {
	      next LINE;
	  }
      } elsif ($mode eq "html") {
	  if (/^%/) {
	      print "$'\n";
	  } else {
	      print STDERR "Line $. ignored in \%display{html} mode, " .
		           "because it didn't start with \%\n";
	  }
	  next LINE;
      } elsif ((!$nontex and /^%/) || 
               (!/\\(at|)index/ and /^([{}]|\s*\{?\\[a-zA-Z].*)%$/)) {
          # Ignore lines starting with a % except if in html or verbatim 
          # modes (dealt with above) or if in nontex mode which we deal 
          # with below.
          # Also ignore specific lines ending in a % (we have to be careful 
          # here -- % also indicates a continuation). The lines we ignore are 
          # those that match: "{%", "}%", "{\\X..%", "\\X..%" where X denotes
          # any letter and .. any sequence of chars. This is meant to exclude
          # lines like "{\obeylines ... %", "\begingroup ... %". If this proves
          # problematic the .tex files will need to use the %display{tex} env't
          # to exclude such lines.
          next LINE;

      # All that's left are whole lines that occur in "normal" mode
      } else {
	  
          # Line skipping.
	  if ($skip_lines) {
	      if ($skip_lines == 1 and $_ =~ /^\s*$/) {
		  $skip_lines = 0;
	      }
	      next LINE;
	  }

          # Remove initial % if there is one when in %display{nontex} or
          # %display{nontext} environment
          if ($nontex) {
              s/^%//;
              $rest = $_;
          }
          # a '%' at end-of-line indicates a continuation
          $_ = gather($_, $nontex);
          
      	  # Paragraphs are ended by blank lines.
      	  if (/^\s*$/) {
	      unless ($donepar) {
		  $outline .=  "<p>\n";
		  $donepar = 1;
	      }
    
	      # If we get to the end of a paragraph we assume that we have
	      # lost track of what is going on, warn and try to resume.
	      if ($mode eq "maths" or $inref) {
		  print STDERR "Paragraph ended in $mode mode at $.\n" .
		               "reverting to normal\n";
		  $outline .= "</I>" if ($mode eq "maths");
		  $mode = "normal";
	      }
      	      
	      print $outline;
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
      	  if  (/^\\(at|)index/) {
              # $_ = gather($_, $nontex); # already done above
      	      while (/\\((at|)index(tt|))\{/g) {
                  ($rest, $indexarg) = (get_arg("{".$'))[0,1];
                  if ($1 eq "atindex") {
                    ($indexarg2) = (get_arg($rest))[1];
                    if ($indexarg2 =~ /^@/) {
                        $indexarg = $';
                        $indexarg =~ s/\\noexpand\s*`([^']*)'/$1/g;
                        $indexarg =~ s/\\noexpand\s*<([^>]*)>/$1/g;
                        $indexarg =~ s/\\noexpand//g;
                        $indexarg =~ s/\|.*//; # remove "|indexit" if present
                        # $indexarg might still have macros ...
                        # we should do something about these too
                    }
                  }
                  # Just the crudest form of macro removal - probably enough
                  $indexarg =~ s/\\(.)/$1/g;
                  $indexarg =~ s/\$//g; #assume $s match in pairs!!
                  $bla = inxentry($fname,$indexarg,$sec);
      		  $outline .= $bla;
		  print "$outline\n";
      	      }
      	      next LINE;
      	  }
      	  # \> and \)  lines (joined with next line if ending in %)
	  if (/^\\[>)]/) {
	      # $_ = gather($_, $nontex); # already done above
              # if \> with ` or ( without a matching ' or ) gather lines
              if ( /^\\> *\`/ ) {        # line should have ended in a %
                  while ( !/\'/ ) { $_ = gather("$_%", $nontex); }
              } elsif ( /^\\>.*\(/ ) {   # line should have ended in a %
                  while ( !/\)/ ) { $_ = gather("$_%", $nontex); }
              }
	      # get rid of @{...} or @`...' if present.
              if (/@/) {
                  # print STDERR "before:$_\n";
                  if (s/@\s*(\{[^{}]*\}|\`[^\']*\')\s*/ /) { # easy 
                  } elsif (/@\s*/) { 
                      # nested braces ... need to find matching brace
                      $_ = $`;
                      ($rest) = get_arg($');
                      $_ .= " $rest";
                      $rest ="";
                  }
                  # print STDERR "after:$_\n";
                  print STDERR "@ still present at $_" if (/@/);
              }
	  }
          # if there is a comment in square brackets we extract it now
          # ... this way if this feature is undesirable we can easily get
          #     rid of it
          my $comment = "";
          # These cases [<something>] is not a comment:
          # \><anything>;   # [<arg>] here is treated as an optional arg
          # \>`<func-with-args>'{<func>![gdfile]} # possibility from
          #                                       # buildman.pe \Declaration
          if (/^\\>(.*;|`[^\']+\'\{[^}!]*!\[[^\]]*\]})/) {
              ;
          } elsif (/^\\>.*\(/) {
              if (s/^(\\>[^(]*\([^)]*\)[^\[]*)(\[[^\]]*\])/$1/) {
                  $comment = " $2";
              }
          } elsif (s/^(\\>[^\[]*)(\[[^\]]*\])/$1/) {
              $comment = " $2";
          }
          # \>`<variable>' V
	  if (/^\\> *`([^\']+)\'\s*(\[[^\]]*\])?\s*V?\s*$/) {
      	      $endline = "</code>";
      	      $outline .= subsec_name($fname,$1,$sec); # $1 = <variable>
              $outline .= "<dt>" if $inlist;
      	      $outline .= "<li><code>";
      	      $tt = 1;
      	      $rest = $1.$comment." V";
      	  }
          # \>`<non-func>'{<label>}[!<sub-entry>][ <capital>]
          # <capital> is usually one of A-Z (but any non-space will be matched)
	  elsif (/^\\> *`([^\']+)\'\s*\{([^}]+)\}(!\{.*\})?\s*([^\s]+)?\s*$/) {
              # $1 = <non-func> $2 = <label> [$3 = !<sub-entry>][$4 = <capital>]
      	      $endline = "</code>";
              $drei = defined($3) ? $3 : "";
              $vier = defined($4) ? " $4" : "";
	      # $2$drei = <label><sub-entry> 
      	      $outline .= subsec_name($fname,"$2$drei",$sec);
#print STDERR "non-func:$1 - $2 - $drei - $vier |$2$drei|\n";
              $outline .= "<dt>" if $inlist;
      	      $outline .= "<li><code>";
      	      $tt = 1;
      	      $rest = $1.$comment.$vier;
      	  }
          # \><func>[(<args>)][!{<sub-entry>}][ <capital>]
          # <capital> is usually one of A-Z (but any non-space will be matched)
	  elsif (/^\\> *([^(]+)(\([^)]*\))?(!\{.*\})?\s*([^\s]+)?\s*$/) {
              # $1 = <func> $2 = (<args>) [$3 = !<sub-entry>][$4 = <capital>]
      	      $endline = "</code>";
              $zwei = defined($2) ? $2 : "";
              $drei = defined($3) ? $3 : "";
              $vier = defined($4) ? " $4" : "";
      	      $outline .= subsec_name($fname,"$1$drei",$sec);
	      # $1$drei = <func><sub-entry> 
#print STDERR "func:$1 - $zwei - $drei - $vier |$1$drei|\n";
              $outline .= "<dt>" if $inlist;
      	      $outline .= "<li><code>";
      	      $tt = 1;
      	      $rest = $1.$zwei.$comment.$vier;

      	  }
	  elsif (/^\\\>/) {
              die "Didn't find an appropriate \\> match for $_ ... syntax?";
      	  }
	  elsif (/^\\\) *(.*)$/) {
      	      $endline = "</code>";
              $outline .= "<dt>" if $inlist;
              if ($donepar) {
      	          $outline .= "<code>";
              } else {
      	          $outline .= "<br><code>";
              }
      	      $tt = 1;
      	      $rest = $1;
          # Skip all other lines starting or ending in % or containing
          # `align'.
      	  } elsif ($mode ne "verbatim" and
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
	      $ref2 = name2linktext($ref);
      	      $outline .= "<a href=\"$ref1\">$ref2</a>";
      	      $inref = "0";
          } elsif ($rest =~ /^$refchars*$/o) {
      	      $ref .= "$rest ";
      	      next LINE;
          } else {
      	      die "Bad reference. So far $ref, now got $rest";
          }
      }

      # || really means | in verbatim mode
      $rest =~ s/\|\|/\|/g if ($mode eq "verbatim");

      # The main case, scan for special characters.
    SPECIAL: while ( $rest =~ /[\\{}\$<>`\'*\"&%~_^]/ ) {
        $outline .= $`;         # the part that we scanned past
        $rest = $';             # the remainder
        my $matched = $&;       # the character matched

        # In verbatim mode, everything is passed to HTML.
        if ($mode eq "verbatim") {
#            if ($matched ne "%") {
                $outline .= html_literal $matched;
#            }
            next SPECIAL;
        }

        # backslash
        if ($matched eq "\\") {
            # commands that begin a new output line
          NEWLINE: {
            if      ($rest =~ /^beginitems/ and not $inlist) { 
                $outline .= "<p>\n<dl compact>";
                $inlist = 1;
            } elsif ($rest =~ /^enditems/ and $inlist) { 
                $outline .= "</dl>";
                $inlist = 0;
            } elsif ($rest =~ /^beginlist
                               (%(un|)ordered)? #defines $listtype
                               (\{([1aAiI])\})? #defines TYPE of ordered list
                               (\{(\d+)\})?     #defines START of ordered list
                               /x ) {
                $listtype = list_type($1, $2);
                $outline .= begin_list($listtype, $3, $4, $5, $6);
                $listdepth = 1;
            } elsif ($rest =~ /^endlist/) {
                $outline .= ("</${listtype}l>") x $listdepth;
                $listdepth = 0;
            } elsif ($rest =~ /^answer/) {
                $outline = "";
                $skip_lines = 1;
            } else {
                last NEWLINE;
            }
            print "$outline\n";
            next LINE;
          }
            # commands that are replaced by HTML text
          REPLACE: {
            ($rest, $macro) = macro_replace($rest);
            $outline .= $macro;
            next SPECIAL;
          }
            # Try to get nice spacing around certain maths constructs that
            # are used a lot.
            if ($mode eq "maths") {
              MATHREPLACE: {
                if    ($rest =~/^($TeXbinops)$EndTeXMacro/o) {
                       $outline .= " $1 "; }
                elsif ($rest =~/^backslash$EndTeXMacro/o) {
                       $outline .= " \\ "; }
                elsif ($rest =~/^split$EndTeXMacro/o) {
                       $outline .= ":"; }
                elsif ($rest =~/^langle$EndTeXMacro/o) {
                       $outline .= " &lt;"; }
                elsif ($rest =~ /^rangle$EndTeXMacro/o) {
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
        if ($mode eq "maths" and !$sub and !$sup) {
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
                # print STDERR "o:$outline,m:$matched,r:$rest\n";
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
            $endmath = "[\$][\$]";
            $endmathstring = "\$\$";
          } else {
            $endmath = "[\$]";
            $endmathstring = "\$";
          }
          if ($opt_t) {
	    if ($mode eq "normal") {
	      $tth= "";
	      $mode = "tth";
    
	      while ($mode eq "tth") {
		if ( $rest =~ /$endmath/ ) {
		  $tth .= $`; # the part scanned past
		  $rest = $';

		  # make a math mode string
		  $tth = "$endmathstring$tth$endmathstring";

		  # pass $tth to tth to convert to HTML
                  # and append the result
		  $outline .= tth_math_replace($tth);
		  $mode = "normal";
		}
		else {
		  # we are in tth mode but the line has no terminating
                  # $ or $$: continue into next line
                  if ($rest =~ s/%$//) { # Mirror TeX behaviour when
                      $tth .= $rest;     # line ends in a % ...
                      $rest = <IN>;      # swallow whitespace at
                      $rest =~ s/^\s*//; # beginning of next line
                  } else {
		      $tth .= $rest." ";
		      $rest = <IN>;
                  }
		  chomp($rest);
		}
              }

	      next SPECIAL;
	    } else {
	      die "math mode messup";
	    }
	  } else {
            $outline .= "<p>" if ($endmathstring eq "\$\$");
            if ($mode eq "maths") {
		if    ($sub) { die "Math mode ended during subscript ".
				   "($outline$matched$rest)"; }
		elsif ($sup) { die "Math mode ended during superscript ".
				   "($outline$matched$rest)"; }
                $mode = "normal";
                $outline .= "</var>";
                if ($tt) { $outline .= "<code>"; }
                next SPECIAL;
            } 
            $mode = "maths";
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
            if ($mode eq "normal" and not $tt) {
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
            if ($tt) {
                $outline .= "`";
            } elsif ( $rest =~ /^`/ ) {
                $rest = $';
                $outline .= "``";
            } else {
                $tt = 1;
                $outline .= "<code>";
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
                $outline = "<dt>$outline<dd>"; # Sometimes we get an extra
            }                                  # <dt> we don't need ...
            next SPECIAL;                      # but it has no effect :)
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
                $ref2 = name2linktext($ref,0);
                $outline .= "<a href=\"$ref1\">$ref2</a>";
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


sub metaquote {
    my $name = quotemeta $_[0];
    $name =~ s/\\ /\\s+/g;
    return $name;
}

sub startfile {
    my $sec = $_[0];
    my ($num, $name, $re, $fname, $name1, $name2);
    if ($sec->{secnum} == 0) {
        $sec->{chapnum} = $chap->{number};
        $num = $chap->{number};
        $name = $chap->{name};
        $name1 = metaquote $name;
        $re = "^\\\\(Chapter|PreliminaryChapter)\\{$name1\\}";
    } else {
        $num = $sec->{chapnum} . "." .$sec->{secnum};
        $name = $sec->{name};  
        $name1 = metaquote $name;
        $re = "^\\\\Section\\{$name1\\}";
    }
    $name2 = kanonize $name;
    $fname = htm_fname($opt_c, 
                       $sec->{chapnum}, $sec->{secnum}, $sec->{ssecnum}, "");

    open ( OUT, ">${odir}${fname}" ) || die "Can't write to ${odir}${fname}";
    select OUT;

    print  "<html><head><title>[$book] $num $name2</title></head>\n";
    print  "<body text=\"\#000000\" bgcolor=\"\#ffffff\">\n";
    add_to_index($fname, $name, $sec);
    navigation( ($opt_c) ? $chap->{sections}[0] : $sec );
    print "<h1>$num $name2</h1><p>\n";

    return ($fname, $re);
}

sub startsec {
    my $sec = $_[0];
    my $snum = $sec->{secnum};
    my $name = $sec->{name};  
    add_to_index(htm_fname($opt_c, $sec->{chapnum}, $snum, 0, ""), $name, $sec);
    my $num = $sec->{chapnum} . "." .$snum;
    $snum = "0" x (3 - length $snum) . $snum;
    my $name1 = metaquote $name;
    my $name2 = kanonize $name;
    print "<h2><a name=\"SECT$snum\">$num $name2</a></h2>\n<p>";
    return "^\\\\Section\\{$name1\\}";
}

sub sectionlist {
    my $chap = $_[0];
    my $sec;
    print  "<P>\n<H3>Sections</H3>\n<oL>\n";
  SUBSEC: for $sec (@{$chap->{sections}}) {
      next SUBSEC if ($sec->{secnum} == 0);
      my $link = htm_fname($opt_c, $sec->{chapnum}, $sec->{secnum}, 0, "");
      my $name2 = kanonize $sec->{name};
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
    my $cfname = htm_fname($opt_c, $sec->{chapnum}, 0, 0, "");
    if ($mainman == 1) {
      print  "[<a href=\"../index.htm\">Top</a>] "
    } else {
        if ($opt_f) {
            print  "[<a href=\"$opt_f\">Top</a>] "
        }
    };
    if ($sec->{secnum} == 0) {
        print  "[<a href = \"chapters.htm\">Up</a>] ";
        if (tonum($chap->{number}) != 1) {
            my $prev = htm_fname($opt_c,
                                 $chapters[tonum($chap->{number}) - 1]{number},
                                 0, 0, "");
            print  "[<a href =\"$prev\">Previous</a>] ";
        }
        if (tonum($chap->{number}) != $#chapters) {
            my $next = htm_fname($opt_c,
                                 $chapters[tonum($chap->{number}) + 1]{number},
                                 0, 0, "");
            print  "[<a href =\"$next\">Next</a>] ";
        }
    } else {
        print  "[<a href = \"$cfname\">Up</a>] ";
        if ($sec->{secnum} != 1) {
            my $prev = htm_fname($opt_c, $chap->{number}, $sec->{secnum} - 1, 
                                 0, "");
            print  "[<a href =\"$prev\">Previous</a>] ";
        }
        if ($sec->{secnum} != $#{$chap->{sections}}) {
            my $next = htm_fname($opt_c, $chap->{number}, $sec->{secnum} + 1,
                                 0, "");
            print  "[<a href =\"$next\">Next</a>] ";
        } elsif (tonum($chap->{number}) != $#chapters) {
            my $next = htm_fname($opt_c,
                                 $chapters[tonum($chap->{number}) + 1]{number},
                                 0, 0, "");
            print  "[<a href =\"$next\">Next</a>] ";
        }
    }
    print  "[<a href = \"theindex.htm\">Index</a>]\n";
}
    

sub convert_chap {
    my ($chap) = @_;
    my ($re, $startre, $fname, $secline);
    $indexcount = 0;
    open (IN, "<$dir$chap->{file}.tex") 
        || die "Can't read $dir$chap->{file}.tex";
    $_ = <IN>;

    # loop, controlled by the list of sections that we expect
    # will fail, possibly messily if this does not match reality

    # The call to startfile produces navigation + a chapter heading
    if ($opt_c) {               # each chapter in a single file
        ($fname,$re) = startfile $chap->{sections}[0];
    }

  # note we *need* $sec to act globally in what follows!
  SECT: for $sec (@{$chap->{sections}}) {

      # sort out what we are processing (chapter or section)
      # produce the header of the Web page

      if ($opt_c) {
          $re = startsec $sec unless ($sec->{secnum} == 0);
      } else {
          # The call to startfile produces navigation + a section heading
          ($fname, $re) = startfile $sec;
#         print STDERR "fname: $fname, re: $re\n";
      } 
      ($startre = $re) =~ s/(^[^\{]*\{).*/$1/;

      #
      # Look for the \Chapter or \Section line
      #

      while ( !/$startre/ ) {
          unless (defined($_ = <IN>)) { 
              die "Missing chapter or section line matching $startre" };
      };
      
      chomp;
      $secline = $_;
      while ( $secline !~ /\}/ ) {
          unless (defined($_ = <IN>)) { 
              die "Missing chapter or section line matching $re" };
          chomp;
          s/\%.*//;
          $secline .= " $_";
      };

      unless ($secline =~ /$re/) {
          die "Missing chapter or section line matching $re"
      };

      # If this is the beginning of a chapter, we list its sections
      if ($sec->{secnum} == 0) {
          if (defined($chap->{sections}[1])) {
              sectionlist $chap;
          } else {
              print STDERR "Warning: Chapter has no sections\n";
          }
      }

      # Now we print the section body
      convert_text($fname);
      print "<p>\n";

      # If it's one file per section ... add navigation etc. at end of file
      unless ($opt_c) {
          navigation $sec;
          print $footer;
          close OUT;
          select STDOUT;
      }    
    }

    # If it's one file per chapter ... add navigation etc. at end of file
    if ($opt_c) {
        navigation $chap->{sections}[0];
	print $footer;
	close OUT;
	select STDOUT;
    }
    close IN;
}



sub chapters_page {
    open (OUT, ">${odir}chapters.htm") 
        || die "Can't write to ${odir}chapters.htm";
    select OUT;

    print  <<END
<html><head><title>$booktitle - Chapters</title></head>
<body text=\"\#000000\" bgcolor=\"\#ffffff\">
<h1>$booktitle_body - Chapters</h1>
<ul>
<li><a href=\"theindex.htm\">Index</a>
</ul>
<ol>
END
    ;

  CHAP: foreach $chap (@chapters) {
      unless (defined $chap) { next CHAP};
        my $link = htm_fname($opt_c, $chap->{number}, 0, 0, "");
        my $name2 = kanonize $chap->{name};
        print  "</ol><ol type=\"A\">\n" if ( $chap->{number} eq "A" );
        print  "<li><a href=\"$link\">$name2</a>\n";
    }

    print  <<END
</ol>
<ul>
<li><a href=\"biblio.htm\">References</a>
<li><a href=\"theindex.htm\">Index</a>
</ul><p>
END
    ;
    if ($mainman == 1) {
      print  "[<a href=\"../index.htm\">Top</a>]<p>"
    } else {
        if ($opt_f) {
            print  "[<a href=\"$opt_f\">Top</a>] "
        }
    };
    print $footer;
    close OUT;
    select STDOUT;

    # Touch the chapters file so that `make' recognizes the conversion
    # has been done.
    system "touch ${odir}chapters.htm";
}
    
sub caseless { lc($a) cmp lc ($b) or $a cmp $b }

sub index_head {
    my ($letter, @letters) = @_;
    my ($bstb);
    print <<END
<html><head><title>$booktitle - Index ${letter}</title></head>
<body text=\"\#000000\" bgcolor=\"\#ffffff\">
<h1>$booktitle_body - Index ${letter}</h1>
<p>
END
    ;
#   print STDERR $letter, @letters, "\n";
    foreach $bstb  (@letters) {
      if ($opt_i) {
        print  "<a href=\"\#idx${bstb}\">$bstb</A>\n";
      }
      elsif ($bstb eq "_") {
        print  "<a href=\"theindex.htm\">$bstb</A>\n";
      }
      else {
        print  "<a href=\"indx${bstb}.htm\">$bstb</A>\n";
      }
    }
}
    
sub index_end {
    print  "</dl><p>\n";
    if ($mainman == 1) {
      print  "[<a href=\"../index.htm\">Top</a>] "
    } else {
        if ($opt_f) {
            print  "[<a href=\"$opt_f\">Top</a>] "
        }
    };
    print  "[<a href=\"chapters.htm\">Up</a>]";
    print  "<p>\n$footer";
}

sub index_page {
    my ($ent, $ref, $letter, $bstb, $thisletter, @entries, %letters, @letters);
    %letters = $opt_i ? ()
                      : ("_" => ""); # With multiple indices, the "_"
                                     # index is theindex.htm
    foreach $ent (keys %index) {
      $bstb = uc(substr($ent,0,1));
      if ($bstb lt "A" or $bstb gt "Z") {$bstb = "_";}
      $letters{$bstb} = "";
    }
    @letters = sort caseless keys %letters;

    $letter = $opt_i ? "" : "_";
    open (OUT, ">${odir}theindex.htm")
        || die "Can't write to ${odir}theindex.htm";
    select OUT;
    index_head($letter, @letters);

  ENTRY: foreach $ent (sort caseless keys %index) {
      $thisletter = uc(substr($ent,0,1));
      if ($thisletter lt "A" or $thisletter gt "Z") {$thisletter = "_";}
      if ($letter eq "") { # Only happens first time round for $opt_i
        $letter = $thisletter; 
        print "<H2><A NAME=\"idx${letter}\">$letter</A></H2>\n<dl>\n";
      }
      elsif ($letter ne $thisletter) {
        $letter = $thisletter;
        if ($opt_i) {
	  print "</dl><p>\n";
	  print "<H2><A NAME=\"idx${letter}\">$letter</A></H2>\n<dl>\n";
	}
	else {
          index_end;
	  close OUT;
	  select STDOUT;
	  open (OUT, ">${odir}indx${letter}.htm")
              || die "Can't write to ${odir}indx${letter}.htm";
	  select OUT;
	  index_head($letter, @letters);
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
    index_end;
    close OUT;
    select STDOUT;
}

sub biblio_page {
    my $infile = "${dir}manual.bbl";
    my $outfile = "${odir}biblio.htm";
    my $macro;
    open (OUT, ">${outfile}") || die "Can't write to ${outfile}";
    select OUT;

    print <<END
<html><head><title>$booktitle - References</title></head>
<body text=\"\#000000\" bgcolor=\"\#ffffff\">
<h1>$booktitle_body - References</h1><dl>
END
    ;

    if (-f $infile and -r $infile) {
      open IN, "<$infile";
      my ($brace,$embrace) = (0,-1);
      while (<IN>) {
        chomp;
        my $outline = "";
        if (/newcommand/ || /thebibliography/) { }
        elsif (/^\\bibitem\[[^\]]+\]\{([^\}]+)\}/) {
            print "<dt><a name=\"$1\"><b>[$1]</b></a><dd>\n";
        } else {
            my $line = $_;
            if ($line =~ /^\s*\\newblock/) { $outline .= "<br>";
                                             $line = $'; }
            while ($line =~ /[\${}<>~&\\]/) {
                $outline .= $`;
                $matched = $&;
                $line = $';
                if ($opt_t and $matched eq "\$" and $line =~ /([^\$]*\$)/) {
                    # if we are using the -t option and we have 
                    # detected a *simple* maths formula $...$ pass it
                    # off directly to tth_math_replace. Bibliographies
                    # should only have very simple maths formulae. If
                    # it's broken over a line, we won't detect it.
                    $matched .= $&;
                    $outline .= tth_math_replace($matched);
                    $line = $';
                } elsif ($matched eq "\{") {
                    if ($line =~ /^\\(em|it)\s*/) { $embrace = $brace;
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
		    if ($line =~ /^cite\{([^\}]*)\}/) {
			$outline .= "<a href=\"#$1\"><cite>$1</cite></a>"; 
                        $line = $';
		    } else {
                        ($line, $macro) = macro_replace($line);
                        $outline .= $macro;
                    } 
                } elsif ($matched eq "~" ) {
                    $outline .= "&nbsp;";
                } elsif ($matched ne "\$") {
                    $outline .= html_literal $matched;
                }
            }
            print "$outline$line\n";
        }
      }
    } else {
        print STDERR "Warning: did not find a .bbl file ... ok?\n";
    }
    print "</dl><p>\n";
    if ($mainman == 1) {
      print  "[<a href=\"../index.htm\">Top</a>] "
    } else {
        if ($opt_f) {
          print  "[<a href=\"$opt_f\">Top</a>] "
        }
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

getopts('csitun:f:');

if (!$opt_c) {$opt_c = 0;} # just to ensure it is not empty

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

if ($opt_t) {
  my ($whichtth) = `which tth`;
  chomp($whichtth);
  if ($whichtth !~ m+/tth$+) {
    print STDERR "!! tth: not in path.\n$whichtth\n",
                 "... Maths formulae will vanish!",
                 " Install tth or avoid -t option.\n";
  }
  $tthbin="tth";
}

if ($opt_u) {
  my ($whichtth) = `which tth`;
  chomp($whichtth);
  if ($whichtth !~ m+/tth$+) {
    print STDERR "!! tth: not in path.\n$whichtth\n",
                 "... Maths formulae will vanish!",
                 " Install tth or avoid -t option.\n";
  }
  $tthbin="tth -u2";
}

if ($opt_n) {
  # get book title
  $book=$opt_n;
  #$booktitle = "$opt_n : a GAP example";
  $booktitle = "$opt_n : a GAP 4 package";
  $booktitle_body = booktitle_body($booktitle, ("GAP", $opt_n));
  $mainman=0;
  $footer = "<P>\n<address>$opt_n manual<br>" .
    `date +"%B %Y"` . "</address></body></html>";
#print "c: $opt_c \n";
} else {
  if ($opt_f) {
      die "option -f can only be used together with -n ";
  }
  if ($dir =~ /\/([^\/]+)\/$/) {
      $book = $1;
  } else {
      die "Can't find basename of $dir";
  }
  if      ($book eq "tut") { 
      $booktitle = "The GAP 4 Tutorial";
  } elsif ($book eq "ref") { 
      $booktitle = "The GAP 4 Reference Manual"; 
  } else  { 
      die "Invalid book, must be tut or ref"; 
  }
  $booktitle_body = booktitle_body($booktitle, "GAP");
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

if ($opt_t || $opt_u) {
  # create macro file for our expressions and macros not known to tth in TeX
  # mode.
  $opt_t = tth_version;
  print STDERR "Using TtH $opt_t to translate maths formulae.\n";
  $opt_t =~ s/Version //;
  open (TTHIN, ">tthmacros.tex") || die "Can't create tthmacros.tex";
  print TTHIN "\\def\\Q{{\\bf Q}}\\def\\Z{{\\bf Z}}\\def\\N{{\\bf N}}\n",
              "\\def\\R{{\\bf R}}\\def\\F{{\\bf F}}\n";
  print TTHIN "\\def\\calR{{\\cal R}}\\def\\I{{\\cal I}}\n",
              "\\def\\frac#1#2{{{#1}\\over{#2}}}\\def\\colon{:}\n",
              "\\def\\longmapsto{\\mapsto}\\def\\lneqq{<}\n",
              "\\def\\hookrightarrow{\\rightarrow}\n";
  if ($opt_t < 2.52) {
     # We work-around most of the deficiencies of versions of TtH
     # prior to Version 2.52 ... but can't easily fix the lack of
     # proper treatment of \not.
     print STDERR 
           "Your version of TtH does not know many TeX commands.\n",
           "It is recommended that you upgrade to the latest version from\n",
           " http://hutchinson.belmont.ma.us/tth/tth-noncom/download.html\n";
     print TTHIN "\\def\\mid{ | }\\def\\lbrack{[}\\def\\rbrack{]}\n",
                 "\\def\\gets{\\leftarrow}\\def\\land{\\wedge}\n";
  }
  close TTHIN;
}

getchaps;
print  "Processed TOC files\n" unless ($opt_s);

open (TEX, "<${dir}manual.tex") || die "Can't open ${dir}manual.tex";
getlabs $dir;
while (<TEX>) {
  if (/\\UseReferences\{\/([^}]*)}/) {
      getlabs "/$1/";
  } elsif (/\\UseReferences\{([^}]*)}/) {
      getlabs "$dir$1/";
  } elsif (/\\UseGapDocReferences\{\/([^}]*)}/) {
      getlabs "/$1/";
  } elsif (/\\UseGapDocReferences\{([^}]*)}/) {
      getlabs "$dir$1/";
#      ($gapdocbook = $1) =~ s?.*/([^/]*)/doc?$1?;
#      $gapdocbooks{$gapdocbook} = 1;
#      print STDERR "GapDoc books: ", keys(%gapdocbooks), "\n";
  } elsif (/\\Package\{([^}]*)}/) {
      $sharepkg .= "|$1"; 
  }
}
print  "Processed LAB files\n" unless ($opt_s);

#
# OK go to work
#

CHAP: foreach $chap (@chapters) {
  unless (defined $chap) {
      next CHAP;
  }
  print "$chap->{number}. $chap->{name} ... $chap->{file}.tex\n" 
      unless ($opt_s);
  convert_chap $chap;
}

print  "and the chapters page\n" unless ($opt_s);
chapters_page;
print  "and the index pages\n" unless ($opt_s);
index_page;
print  "and the references\n" unless ($opt_s);
biblio_page;

if ($opt_t || $opt_u ) {
  # remove the tth stuff
  unlink 'tthin','tthout','tthmacros.tex';
}

print  "done\n" unless ($opt_s);
#############################################################################
