#!/usr/bin/perl
use encoding 'utf8';
use POSIX qw(strftime);

if($ARGV[0] eq "-h"){
	shift @ARGV;
	$h = $ARGV[0];
	shift @ARGV;
}else{
	$h = $ARGV[0];
}
$max_line = 56;
$page = 0;
$now = strftime "%Y-%m-%d %H:%M:%S", localtime;

@lines = <>;
for($i=0; $i<@lines; $i+=$max_line){
	print "\n\n";
	++$page;
	print "$now  $h  Page $page\n";
	print "\n\n";
	for($j=$i; $j<@lines && $j<$i +$max_line; $j++){
		$lines[$j] =~ s!//DOC.*!!;
		print $lines[$j];
	}
	for(; $j<$i+$max_line; $j++){
		print "\n";
	}
	$sheet = "";
	if($lines[$i] =~ /^([0-9]{1,}) /){
		my $num = int($1)/$max_line;
		$sheet = "\t\t\t\t  Sheet $num";
	}
	print "\n\n";
	print "$sheet\n";
	print "\n\n";
}

