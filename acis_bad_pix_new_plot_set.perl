#!/usr/bin/perl

#################################################################################################
#												#
#	acis_bad_pix_new_plot_set.perl: adjust old dataset, and create a new set of plots 	#
#					for warm pixs/cols					#
#			  		this is a control script.				#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: Mar 09, 2011							#
#												#
#################################################################################################

#--- output directory

open(FH, "/data/mta/Script/ACIS/Bad_pixels/house_keeping/dir_list");
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

#------------

system("cp $data_dir/Disp_dir/hist_ccd* $data_dir/Disp_dir/hist_col* .");

#
#--- warm pixel cases
#

system("/opt/local/bin/perl $bin_dir/create_new_and_imp_ccd_list.perl");

system("/opt/local/bin/perl $bin_dir/create_flk_pix_hist.perl");

system("/opt/local/bin/perl $bin_dir/create_pot_warm_pix.perl");

system("/opt/local/bin/perl $bin_dir/plot_ccd_history.perl");

system("/opt/local/bin/perl $bin_dir/plot_front_ccd_history.perl");

#
#--- warm column cases
#

system("/opt/local/bin/perl $bin_dir/create_new_and_imp_col_list.perl");

system("/opt/local/bin/perl $bin_dir/create_flk_col_hist.perl");

system("/opt/local/bin/perl $bin_dir/create_pot_warm_col.perl");

system("/opt/local/bin/perl $bin_dir/plot_col_history.perl");

system("/opt/local/bin/perl $bin_dir/plot_front_col_history.perl");


system("mv *gif $web_dir/Plots/");
#system("mv bad* cum* ccd*cnt col*cnt hist* new* imp* flk*     $data_dir/Disp_dir/");
