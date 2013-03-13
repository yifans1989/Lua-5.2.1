#!/bin/sh

echo This script takes a minute to run.  Be patient. 1>&2

#LC_CTYPE=C export LC_CTYPE
max_line=56;

# pad stdin to multiple of 120lines
pad()
{
	awk '{print} END{for(; NR%120!=0; NR++) print ""}'
}

# create formatted (numbered) files
mkdir -p fmt
rm -f fmt/*
cp README fmt
files=`grep -v '^#' pcodefile.list | awk '{print $1}'`
#n=99
n=0
for i in $files
do
	perl ./runoff.pl -n $n $i >fmt/$i
	nn=`tail -1 fmt/$i | sed 's/ .*//; s/^0*//'`
	if [ "x$nn" != x ]; then
		n=$nn
	fi
done

# create table of contents
cat toc.hdr >fmt/toc
pr -e8 -t pcodefile.list | awk '
/^[a-z0-9]/ {
	s=$0
	f="fmt/"$1
	getline<f
	close(f)
	n=$1
	printf("%02d %s\n", n/56, s);
	printf("TOC: %04d %s\n", n, s) >"fmt/tocdata"
	next
}
{
	print
}' | pr -3 -t >>fmt/toc
cat toc.ftr >>fmt/toc

# check for bad alignments
perl -e '
	$leftwarn = 0;
	while(<>){
		chomp;
		s!#.*!!;
		s!\s+! !g;
		s! +$!!;
		next if /^$/;
		
		if(/TOC: (\d+) (.*)/){
			$toc{$2} = $1;
			next;
		}
		
		if(/sheet1: (left|right)$/){
			print STDERR "assuming that sheet 1 is a $1 page.  double-check!\n";
			$left = $1 eq "left" ? "13579" : "02468";
			$right = $1 eq "left" ? "02468" : "13579";
			next;
		}
		
		if(/even: (.*)/){
			$file = $1;
			if(!defined($toc{$file})){
				print STDERR "Have no toc for $file\n";
				next;
			}
			if($toc{$file} =~ /^\d\d[^0]/){
				print STDERR "$file does not start on a fresh page.\n";
			}
			next;
		}
		
		if(/odd: (.*)/){
			$file = $1;
			if(!defined($toc{$file})){
				print STDERR "Have no toc for $file\n";
				next;
			}
			if($toc{$file} !~ /^\d\d5/){
				print STDERR "$file does not start on a second half page.\n";
			}
			next;
		}
		
		if(/(left|right): (.*)/){
			$what = $1;
			$file = $2;
			if(!defined($toc{$file})){
				print STDERR "Have no toc for $file\n";
				next;
			}
			if($what eq "left" && !($toc{$file} =~ /^\d[$left][05]/)){
				print STDERR "$file does not start on a left page [$toc{$file}]\n";
			}
			# why does this not work if I inline $x in the if?
			$x = ($toc{$file} =~ /^\d[$right][05]/);
			if($what eq "right" && !$x){
				print STDERR "$file does not start on a right page [$toc{$file}] [$x]\n";
			}
			next;
		}
		
		print STDERR "Unknown spec: $_\n";
	}
' fmt/tocdata runoff.spec

# make definition list
cd fmt
perl -e '
	while(<>) {
		chomp;

		s!//.*!!;
		s!/\*([^*]|[*][^/])*\*/!!g;
		s!\s! !g;
		s! +$!!;

		# look for declarations like char* x;
		if (/^[0-9]+ typedef .* u(int|short|long|char);/) {
			next;
		}
		if (/^[0-9]+ extern/) {
			next;
		}
		if (/^[0-9]+ struct [a-zA-Z0-9_]+;/) {
			next;
		}
		if (/^([0-9]+) #define +([A-za-z0-9_]+) +?\(.*/) {
			print "$1 $2\n"
		}
		elsif (/^([0-9]+) #define +([A-Za-z0-9_]+) +([^ ]+)/) {
			print "$1 $2 $3\n";
		}
		elsif (/^([0-9]+) #define +([A-Za-z0-9_]+)/) {
			print "$1 $2\n";
		}
		
		if(/^^([0-9]+) \.globl ([a-zA-Z0-9_]+)/){
			$isglobl{$2} = 1;
		}
		if(/^^([0-9]+) ([a-zA-Z0-9_]+):$/ && $isglobl{$2}){
			print "$1 $2\n";
		}
		
		if (/\(/) {
			next;
		}

		if (/^([0-9]+) (((static|struct|extern|union|enum) +)*([A-Za-z0-9_]+))( .*)? +([A-Za-z_][A-Za-z0-9_]*)(,|;|=| =)/) {
			print "$1 $7\n";
		}
		
		elsif(/^([0-9]+) (enum|struct|union) +([A-Za-z0-9_]+) +{/){ 
			print "$1 $3\n";
		}
		# TODO: enum members
	}
' $files >defs

(for i in $files
do
	case "$i" in
	*.S)
		cat $i | sed 's;#.*;;; s;//.*;;;'
		;;
	*)
		cat $i | sed 's;//.*;;; s;"([^"\\]|\\.)*";;;'
	esac
done
) >alltext

perl -n -e 'print if s/^([0-9]+ [a-zA-Z0-9_]+)\(.*$/\1/;' alltext |
	egrep -v ' (STUB|usage|main|if|for)$' >>defs
#perl -n -e 'print if s/^([0-9]+) STUB\(([a-zA-Z0-9_]+)\)$/\1 \2/;' alltext \
#	>>defs
(
>s.defs

# make reference list
for i in `awk '{print $2}' defs | sort -f | uniq`
do
	defs=`egrep '^[0-9]+ '$i'( |$)' defs | awk '{print $1}'`
	echo $i $defs >>s.defs
	uses=`egrep -h '([^a-zA-Z_0-9])'$i'($|[^a-zA-Z_0-9])' alltext | awk '{print $1}'`
	if [ "x$defs" != "x$uses" ]; then
		echo $i $defs
		echo $uses |fmt -29 | sed 's/^/    /'
#	else
#		echo $i defined but not used >&2
	fi
done
) >refs

# build defs list
awk '
{
	printf("%04d %s\n", $2, $1);
	for(i=3; i<=NF; i++)
		printf("%04d    \" \n", $i);
}
' s.defs > t.defs

# format the whole thing
(
	perl ../print.pl README
	perl ../print.pl -h "table of contents" toc
	# pr -t -2 t.defs | perl ../print.pl -h "definitions" | pad
	# pr -t -l$max_line -2 refs | perl ../print.pl -h "cross-references" | pad
	if test $# -eq 0
	then
		pr -t -l$max_line -2 refs | perl ../print.pl -h "cross-references"
	fi
	# print.pl -h "definitions" -2 t.defs | pad
	# print.pl -h "cross-references" -2 refs | pad 
	for i in $files
	do
		perl ../print.pl -h "$i" $i
	done
) | mpage -m30t30b -o -bLetter -T -t -1 -FCourier >all.ps
grep Pages: all.ps

# if we have the nice font, use it
nicefont=../LucidaSans-Typewriter83
if [ -f $nicefont ]
then
	echo nicefont
	(sed 1q all.ps; cat $nicefont; sed '1d; s/Courier/LucidaSans-Typewriter83/' all.ps) >allf.ps
else
	echo ugly font!
	cp all.ps allf.ps
fi
ps2pdf allf.ps ../lua-5.2.1.pdf
cd ..
pdftops lua-5.2.1.pdf lua-5.2.1.ps
rm -rf fmt

