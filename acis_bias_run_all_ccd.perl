#!/usr/bin/perl

#########################################################################################
#											#
#	acis_bias_run_all_ccd.perl: run moving_avg.perl for all CCD and nodes		#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Jun 04, 2009							#
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
#$web_dir       = '/data/mta_www/mta_bias_bkg_test';
#$house_keeping = '/data/mta/www/mta_bad_pixel/Test/house_keeping/';

#######################################

#
#---- plot special cases first
#
#system("perl $bin_dir/acis_bias_moving_avg.perl /data/mta_www/mta_bias_bkg/Bias_save/CCD0/quad0 2220 1e5");
#system("mv bias_plot_CCD0_quad0.gif $web_dir/Plots/Sub2/bias_plot_CCD0_quad0_second.gif");
#
#system("perl $bin_dir/acis_bias_moving_avg.perl /data/mta_www/mta_bias_bkg/Bias_save/CCD0/quad0 0 1e5");
#system("mv bias_plot_CCD0_quad0.gif $web_dir/Plots/Sub2/bias_plot_CCD0_quad0_special.gif");
#
#system("perl $bin_dir/acis_bias_moving_avg.perl /data/mta_www/mta_bias_bkg/Bias_save/CCD1/quad1 2220 1e5");
#system("mv bias_plot_CCD1_quad1.gif $web_dir/Plots/Sub2/bias_plot_CCD1_quad1_second.gif");
#
#system("perl $bin_dir/acis_bias_moving_avg.perl /data/mta_www/mta_bias_bkg/Bias_save/CCD1/quad1 0 1e5");
#system("mv bias_plot_CCD1_quad1.gif $web_dir/Plots/Sub2/bias_plot_CCD1_quad1_special.gif");


#
#--- general plotting
#

for($ccd = 0; $ccd < 10; $ccd++){
	for($node = 0; $node < 4; $node++){
		$file = '/data/mta_www/mta_bias_bkg/Bias_save/CCD'."$ccd".'/quad'."$node";
		system("/opt/local/bin/perl $bin_dir/acis_bias_moving_avg.perl $file");
		system("mv bias_plot_*.gif $web_dir/Plots/Sub2/");
	}
}
 

