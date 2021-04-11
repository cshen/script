#!/usr/bin/env perl -s
#
# take a latex AUX file and change the bibstyle to subset or subset-nocomment
# depending on if the -c flag was given (-c means use comments), then rename
# the modified file to references.aux, run bibtex on it, rename the file
# references.bbl to references.bib and delete references.{aux,blg}.  This
# results in a BibTeX file which can be shipped with the latex source of the
# paper.  The \bibliography{} command in the latex file will need to be changed
# to use the newly generated bibliography.
#
# V. Khera	07-AUG-1992
# khera@cs.duke.edu
#
# Modified by Chunhua Shen, April 2012
# Script generates subset.bst and subset-nocomment.bst 
#
#




$tmpfile = "TEMPCSrefs_$$";
$outfile = "CSRef.bib";

$scriptname = "$0";


$SIG{'INT'} = 'handler';
$SIG{'QUIT'} = 'handler';
$SIG{'TERM'} = 'handler';
$| = 1;				# make sure output is flushed after print.


sub handler {
  local($sig) = @_;
  print "Got a SIG$sig -- cleaning up\n";
  &cleanup;
  exit 1;
}

sub cleanup {
  unlink <$tmpfile.*>;
  system('/bin/rm  subset.bst'); 
}


sub writebst {
 
# system('cp -f  /Users/cs/Dropbox/bin/subset.bst  . ')
# ARCHIVE=`awk '/^__DATA__/ {print NR + 1; exit 0; }' $0`
# tail -n+$ARCHIVE $0  >   /tmp/mylatex.ltx

system("tail -n+`awk '/^__DATA__/ {print NR + 1; exit 0; }' " ."$scriptname" . "` "  .  "$scriptname"  . " >subset.bst");

}

#
# $bibstyle = defined($c) ? "subset" : "subset-nocomment";
#
$bibstyle ="subset";

die "usage: $0   <auxfile>\n" unless $#ARGV == 0;

$infile = shift;

# canonicalize the name to end i .aux. assumes file is in current directory,
# even though a path may have been specified.  tough noogies, i say!
$infile =~ s#(.*/)?([^.]*).*#\2.aux#;

die "No such file $infile\n" unless -f $infile;

open(INF,$infile) || die "Cannot read $infile\n";
@auxdata = <INF>;		# slurp the whole file in
close(INF);


# write subset.bst to the current dir
writebst;

# create a new AUX file with subset bibstyle specified.
@result = grep(m/(\\citation|\\bibdata).*/ , @auxdata);
die "No citations or data files specified in $infile\n" unless @result;
push(@result,"\\bibstyle{$bibstyle}\n");

open (OUTF,">$tmpfile.aux") || die "Cannot create temp file\n";
print OUTF @result;
close(OUTF);

print "- Running bibtex...\n";

$result = system "bibtex $tmpfile";
die "- Error running bibtex\n" unless ($result >> 8) == 0;
rename ("$tmpfile.bbl", $outfile);

print "\n------------------------------------------\n";
print "- Output is in     $outfile\n";
print "------------------------------------------\n\n";

cleanup;





=begin perl comments 
__DATA__

%%
%% Required by aux2bib
%%
%%

ENTRY
  { abstract
    address
    author
    booktitle    
    category
    chapter
    comment
    earlier
    edition
    editor
    howpublished
    institution
    journal
    key
    keyword
    later
    month
    note
    number
    organization
    pages
    private
    publisher
    school
    series
    title
    type
    URL
    volume
    year
  }
  {}
  { label extra.label sort.label }

STRINGS { s t }

% output a field; the top is the text, the next to top is the name of
% the field, and we know that the text is nonnull.
% we start by finishing the previous line
FUNCTION {output.field}
{
  ", " write$		% write comma and newline
  newline$
  "  " write$		% and a respectable indentation

  swap$			% now field name is on top
  " = {" *		% put = {
  swap$ *		% now text is back on top; concatenate
  "}" *			% put }
  write$
}

% output if top not empty; below the top is the name of the field
FUNCTION {output}
{ duplicate$ empty$
    { pop$ pop$ }
    'output.field
  if$
}

% prints each field 
FUNCTION {output.bibfields}
{
% The fields, in what seems to be a good order
  "key" key output
  "author" author output
  "title" title output

  "journal" journal output
  "booktitle" booktitle output

  "chapter" chapter output
  "edition" edition output
  "editor" editor output

   crossref missing$
     { }
     { "crossref" crossref output }
   if$

  "year" year output
  "month" month output
  "series" series output
  "volume" volume output
  "number" number output
  "type" type output

  "pages" pages output

  "institution" institution output
  "school" school output
  "organization" organization output
  "publisher" publisher output
  "howpublished" howpublished output
  "address" address output

  "category" category output

  "note" note output

  "earlier" earlier output
  "later" later output

  "URL" URL output
  "keyword" keyword output
  "abstract" abstract output
  "comment" comment output
}

% Takes name of type as argument, and prints @ line
% then it prints each field 
FUNCTION {output.bibitem}
{
% write the @ line
  "@" swap$ * write$    		  % @type
  "{" cite$ * write$  		  % {citekey

  output.bibfields

% finish entry
  newline$
  "}" write$ 
  newline$
  newline$
}

FUNCTION {article}{ "Article" output.bibitem }

FUNCTION {book}{ "Book" output.bibitem }

FUNCTION {booklet}{ "Booklet" output.bibitem }

FUNCTION {inbook}{ "InBook" output.bibitem }

FUNCTION {incollection}{ "InCollection" output.bibitem }

FUNCTION {inproceedings}{ "InProceedings" output.bibitem }

FUNCTION {conference}{ "Conference" output.bibitem }

FUNCTION {manual}{ "Manual" output.bibitem }

FUNCTION {mastersthesis}{ "MastersThesis" output.bibitem }

FUNCTION {misc}{ "Misc" output.bibitem }

FUNCTION {phdthesis}{ "PhdThesis" output.bibitem }

FUNCTION {proceedings}{ "Proceedings" output.bibitem }

FUNCTION {techreport}{ "TechReport" output.bibitem }

FUNCTION {unpublished}{ "Unpublished" output.bibitem }

FUNCTION {default.type} { misc }

MACRO {jan} {"January"}

MACRO {feb} {"February"}

MACRO {mar} {"March"}

MACRO {apr} {"April"}

MACRO {may} {"May"}

MACRO {jun} {"June"}

MACRO {jul} {"July"}

MACRO {aug} {"August"}

MACRO {sep} {"September"}

MACRO {oct} {"October"}

MACRO {nov} {"November"}

MACRO {dec} {"December"}

MACRO {acmcs} {"ACM Computing Surveys"}

MACRO {acta} {"Acta Informatica"}

MACRO {cacm} {"Communications of the ACM"}

MACRO {ibmjrd} {"IBM Journal of Research and Development"}

MACRO {ibmsj} {"IBM Systems Journal"}

MACRO {ieeese} {"IEEE Transactions on Software Engineering"}

MACRO {ieeetc} {"IEEE Transactions on Computers"}

MACRO {ieeetcad}
 {"IEEE Transactions on Computer-Aided Design of Integrated Circuits"}

MACRO {ipl} {"Information Processing Letters"}

MACRO {jacm} {"Journal of the ACM"}

MACRO {jcss} {"Journal of Computer and System Sciences"}

MACRO {scp} {"Science of Computer Programming"}

MACRO {sicomp} {"SIAM Journal on Computing"}

MACRO {tocs} {"ACM Transactions on Computer Systems"}

MACRO {tods} {"ACM Transactions on Database Systems"}

MACRO {tog} {"ACM Transactions on Graphics"}

MACRO {toms} {"ACM Transactions on Mathematical Software"}

MACRO {toois} {"ACM Transactions on Office Information Systems"}

MACRO {toplas} {"ACM Transactions on Programming Languages and Systems"}

MACRO {tcs} {"Theoretical Computer Science"}

READ

% DFK use cite$ for sort key
FUNCTION {presort}
{
  cite$
  #1 entry.max$ substring$
  'sort.key$ :=
}

ITERATE {presort}

SORT

FUNCTION {begin.bib}
{
  "% BibTeX bibliography file" write$ 
  newline$ 
  newline$
}

EXECUTE {begin.bib}

ITERATE {call.type$}

