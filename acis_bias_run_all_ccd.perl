#!/usr/bin/perl

#########################################################################################
#											#
#	acis_bias_run_all_ccd.perl: run moving_avg.perl for all CCD and nodes		#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Mar 09, 2011							#
#											#
#########################################################################################

#######################################
#
#--- setting a few paramters
#

#--- output directory

open(FH, "/data/mta/Script/ACIS/Bad_pixels/house_keeping/bias_dir_list");
@dir_list = ();
OUTER:
while(<FH>){
        if($_ =~ /#/){
                next OUTER;
        }
        chomp $_;
        push(@dir_list, $_);
}
close(FH);

$bin_dir       = $dir_list[0];
$bdat_dir      = $dir_list[1];
$web_dir       = $dir_list[2];
$exc_dir       = $dir_list[3];
$data_dir      = $dir_list[4];
$house_keeping = $dir_list[5];

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
		$file = "$data_dir".'/Bias_save/CCD'."$ccd".'/quad'."$node";

		$file = "$data_dir".'/Bias_save/CCD'."$ccd".'/quad'."$node";
		system("/opt/local/bin/perl $bin_dir/acis_bias_moving_avg.perl $file");
		system("mv bias_plot_*.gif $web_dir/Plots/Sub2/");
	}
}
 

