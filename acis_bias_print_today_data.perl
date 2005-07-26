#!/usr/bin/perl

#################################################################################
#										#
#	print_today_data.perl: this script print today's data list for		#
#			       bias background computation			#
#										#
#		author: t. isobe (tisobe@cfa.harvard.edu)			#
#		last update: Jul 8, 2004					#
#										#
#################################################################################

open(FH, './Working_dir/past_input_data');
@data1 = ();
while(<FH>){
	chomp $_;
	push(@data1, $_);
}
close(FH);

$first = $data1[0];
@atemp = split(/\//,$first);
@btemp = split(/_/,$atemp[5]);
$cut_date = "$btemp[0]$btemp[1]$btemp[2]";

open(FH, './Working_dir/past_input_data~');
@data2 = ();
while(<FH>){
	chomp $_;
	push(@data2, $_);
}
close(FH);

open(OUT, ">./Working_dir/today_input_data");
OUTER:
foreach $ent (@data1){
	foreach $comp (@data2){
		if($ent eq $comp){
			next OUTER;
		}
	}
	@atemp = split(/\//,$ent);
	@btemp = split(/_/,$atemp[5]);
	$date = "$btemp[0]$btemp[1]$btemp[2]";
	if($date >= $cut_date){
		print OUT "$ent\n";
	}
}

