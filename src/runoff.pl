#!/usr/bin/perl

my $n = 0;
my $v = 0;
my $max_line = 56;
my $line_len = 75;
if($ARGV[0] eq "-v") {
	$v = 1;
	shift @ARGV;
}
if($ARGV[0] eq "-n") {
	$n = $ARGV[1];
	shift @ARGV;
	shift @ARGV;
}
$n = int(($n+$max_line-1)/$max_line)*$max_line - 1;

$file = $ARGV[0];
@lines = <>;
$linenum = 0;
foreach (@lines) {
	$linenum++;
	chomp;
	s/\s+$//;
	my $len = length();
	if($len >= $line_len) {# && $_ =~ /^[^\*\/]*$/){
		print STDERR "$file:$linenum: line ($len) too long than $line_len \n";
   print STDERR "$_\n";
	}
}
@outlines = ();
$nextout = 0;

for($i=0; $i<@lines; ){
	# Skip leading blank lines.
	$i++ while $i<@lines && $lines[$i] =~ /^$/;
	last if $i>=@lines;

	# If the rest of the file fits, use the whole thing.
	if(@lines <= $i+$max_line && !grep { /PAGEBREAK/ } @lines){
		$breakbefore = @lines;
	}else{
		# Find a good next page break;
		# Hope for end of function.
		# but settle for a blank line (but not first blank line
		# in function, which comes after variable declarations).
		$breakbefore = $i;
		$lastblank = $i;
		$sawbrace = 0;
		$breaksize = 15;  # 15 lines to get to function
		for($j=$i; $j<$i+$max_line && $j < @lines; $j++){
			if($lines[$j] =~ /PAGEBREAK!/){
				$lines[$j] = "";
				$breakbefore = $j;
				$breaksize = $max_line;
				last;
			}
			if($lines[$j] =~ /PAGEBREAK:\s*([0-9]+)/){
				$breaksize = $1;
				$breakbefore = $j;
				$lines[$j] = "";
			}
			if($lines[$j] =~ /^};?$/){
				$breakbefore = $j+1;
				$breaksize = 15;
			}
			if($lines[$j] =~ /^{$/){
				$sawbrace = 1;
			}
			if($lines[$j] =~ /^$/){
				if($sawbrace){
					$sawbrace = 0;
				}else{
					$lastblank = $j;
				}
			}
		}
		if($j<@lines && $lines[$j] =~ /^$/){
			$lastblank = $j;
		}

		# If we are not putting enough on a page, try a blank line.
		if($breakbefore - $i < $max_line - $breaksize && $lastblank > $breakbefore 
      && $lastblank >= $i+$max_line - 5){
			if($v){
				print STDERR "breakbefore $breakbefore i $i breaksize $breaksize\n";
			}
			$breakbefore = $lastblank;
			$breaksize = 5;  # only 5 lines to get to blank line
		}

		# If we are not putting enough on a page, force a full page.
		if($breakbefore - $i < $max_line - $breaksize && $breakbefore != @lines){
			$breakbefore = $i + $max_line;
			$breakbefore = @lines if @lines < $breakbefore;
		}

		if($breakbefore < $i+2){
			$breakbefore = $i+2;
		}
	}

	# Emit the page.
	$i50 = $i + $max_line;
	for(; $i<$breakbefore; $i++){
		printf "%05d %s\n", ++$n, $lines[$i];
	}

	# Finish page
	for($j=$i; $j<$i50; $j++){
		printf "%05d \n", ++$n;
	}
}

