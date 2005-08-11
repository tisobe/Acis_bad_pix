#!/usr/bin/perl

#################################################################################
#										#
#	acis_bias_print_today_data.perl: this script print today's data list	#
#			                 for bias background computation	#
#										#
#		author: t. isobe (tisobe@cfa.harvard.edu)			#
#		last update: Aug 1, 2005					#
#										#
#################################################################################

#######################################
#
#--- setting a few paramters
#

#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta_www/mta_bias_bkg/';
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta_www/mta_bias_bkg_test/';
$house_keeping = '/data/mta/www/mta_bad_pixel/Test/house_keeping/';

#######################################

#
#--- find out which data are new for today
#

open(FH, "$house_keeping/past_input_data");
@data1 = ();
while(<FH>){
	chomp $_;
	push(@data1, $_);
}
close(FH);

$first    = $data1[0];
@atemp    = split(/\//,$first);
@btemp    = split(/_/,$atemp[5]);
$cut_date = "$btemp[0]$btemp[1]$btemp[2]";

open(FH, "$house_keeping/past_input_data~");
@data2 = ();

while(<FH>){
	chomp $_;
	push(@data2, $_);
}
close(FH);

$test = `ls -d `;
if($test =~ /Working_dir/){
	system("rm ./Working_dir/*");
}else{
	system("mkdir ./Working_dir");
}

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
	$date  = "$btemp[0]$btemp[1]$btemp[2]";

	if($date >= $cut_date){
		print OUT "$ent\n";
	}
}

close(OUT);
