#!/usr/bin/perl

#########################################################################################
#											#
#	acis_bias_run_all_ccd.perl: run moving_avg.perl for all CCD and nodes		#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: 03/15/2006								#
#											#
#########################################################################################


#######################################
#
#--- setting a few paramters
#

#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta_www/mta_bias_bkg/';
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';

#$bin_dir       = '/data/mta/MTA/bin/';
#$bdat_dir      = '/data/mta/MTA/data/';
#$web_dir       = '/data/mta_www/mta_bias_bkg_test/';
#$house_keeping = '/data/mta/www/mta_bad_pixel/Test/house_keeping/';

#######################################


for($ccd = 0; $ccd < 10; $ccd++){
	for($node = 0; $node < 4; $node++){
		$file = '/data/mta_www/mta_bias_bkg/Bias_save/CCD'."$ccd".'/quad'."$node";
		system("perl acis_bias_moving_avg.perl $file");
		system("mv *gif $web_dir/Plots/Sub2/");
	}
}

system("perl acis_bias_moving_avg_special.perl");
system("mv *gif $web_dir/Plots/Sub2/");
 

