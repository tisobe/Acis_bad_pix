#!/usr/bin/perl

#################################################################################################
#												#
#	acis_bad_pix_new_plot_set.perl: adjust old dataset, and create a new set of plots 	#
#					for warm pixs/cols					#
#			  		this is a control script.				#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: Feb 29, 2008							#
#												#
#################################################################################################

#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta/www/mta_bad_pixel/';
$old_dir       = $web_dir;
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';

#-- TEST ----
###$bin_dir = "/data/mta/Script/ACIS/Bad_pixels/Acis_bad_pix/";
#------------

system("cp $web_dir/Disp_dir/hist_ccd* $web_dir/Disp_dir/hist_col* .");

#
#--- warm pixel cases
#

###system("perl $bin_dir/fill_ccd_hist.perl");

system("perl $bin_dir/create_new_and_imp_ccd_list.perl");

system("perl $bin_dir/create_flk_pix_hist.perl");

system("perl $bin_dir/create_pot_warm_pix.perl");

system("perl $bin_dir/plot_ccd_history.perl");

system("perl $bin_dir/plot_front_ccd_history.perl");

#
#--- warm column cases
#

###system("perl $bin_dir/fill_col_hist.perl");

system("perl $bin_dir/create_new_and_imp_col_list.perl");

system("perl $bin_dir/create_flk_col_hist.perl");

system("perl $bin_dir/create_pot_warm_col.perl");

system("perl $bin_dir/plot_col_history.perl");

system("perl $bin_dir/plot_front_col_history.perl");


system("mv *gif $web_dir/Plots/");
system("mv bad* cum* ccd*cnt col*cnt hist* new* imp* flk*     $web_dir/Disp_dir/");

##system("mv *gif ./Plots/");
##system("mv bad* cum* ccd*cnt col*cnt hist* new* imp* flk*     ./Disp_dir/");
