#!/usr/bin/perl 

#########################################################################################
#											#
#	acis_bias_html_update.perl: update bias backgroud html page			#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Aug 8, 2005							#
#											#
#########################################################################################


#######################################
#
#--- setting a few paramters
#

#--- output directory

$bin_dir       = '/data/mta4/MTA/bin/';
$bdat_dir      = '/data/mta4/MTA/data/';
$web_dir       = '/data/mta_www/mta_bias_bkg/';
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';

$bin_dir       = '/data/mta4/MTA/bin/';
$bdat_dir      = '/data/mta4/MTA/data/';
$web_dir       = '/data/mta_www/mta_bias_bkg_test/';
$house_keeping = '/data/mta/www/mta_bad_pixel/Test/house_keeping/';

#######################################

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst) = localtime(time);
$uyear += 1900;
$month = $umon + 1;

$line =  "Last Update: $month/$umday/$uyear";

open(FH, "$web_dir/bias_home.html");
open(OUT, "> ./temp");
while(<FH>){
	chomp $_;
	if($_ =~ /Last Update/){
		print OUT "$line\n";
	}else{
		print OUT "$_\n";
	}
}
close(OUT);
close(FH);
system("mv ./temp $web_dir/bias_home.html");
