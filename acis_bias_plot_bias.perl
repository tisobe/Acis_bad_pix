#!/usr/bin/perl
use PGPLOT;

#########################################################################
#									#
#	acis_bias_plot_bias.perl: plots three types of figs for bias    #
#				  background html display		#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#	last upate: Mar 09, 2011					#
#									#
#########################################################################

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

for($ccd = 0; $ccd < 10; $ccd++){

	pgbegin(0, "/ps",1,1);
	pgsubp(2,2);
	pgsch(2);
	pgslw(2);	

	for($quad = 0; $quad < 4; $quad++){
		$file    = "$data_dir".'/Bias_save/'."CCD$ccd".'/'."quad$quad";
		@time    = ();
		@bias    = ();
		@error   = ();
		@overclk = ();
		$cnt     = 0;
		$sum1    = 0;
		$sum2    = 0;
		$sum3    = 0;

		open(FH, "$file"); 
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/,$_);
			$time  = ($atemp[0] - 48902399)/86400;
			push(@time, $time);
			push(@bias, $atemp[1]);
			push(@error, $atemp[2]);
			push(@overclk, $atemp[3]);
			$sum1 += $atemp[1];
			$sum2 += $atemp[2];
			$sum3 += $atemp[3];
			$cnt++;
		}
		close(FH);

		$diff  = $time[$cnt-1] - $time[0];
		$extra = 0.05 * $diff;
		$xmin  = $time[0] - $extra;
		$xmax  = $time[$cnt-1] + $extra;

		$ymin  = $sum1/$cnt - 100;
		$ymax  = $sum1/$cnt + 100;

		pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);
		pgslw(4);
		for($m = 0; $m < $cnt; $m++){
			pgpt(1, $time[$m], $bias[$m], -1);
		}
		pgslw(2);
	   
		$title = "CCD$ccd Quad$quad";
		pglabel("Time (DOM)", 'Bias', "$title");
	}
	pgclos();

	system("echo ''|/opt/local/bin/gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 | $bin_dir/ppmtogif > $web_dir/Plots/Bias_bkg/ccd$ccd.gif");

	system("rm pgplot.ps");

	pgbegin(0, "/ps",1,1);
	pgsubp(2,2);
	pgsch(2);
	pgslw(2);	

	for($quad = 0; $quad < 4; $quad++){
		$file    = "$data_dir".'/Bias_save/'."CCD$ccd".'/'."quad$quad";
		@time    = ();
		@bias    = ();
		@error   = ();
		@overclk = ();
		$cnt     = 0;
		$sum1    = 0;
		$sum2    = 0;
		$sum3    = 0;

		open(FH, "$file"); 
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/,$_);
			$time = ($atemp[0] - 48902399)/86400;
			push(@time, $time);
			push(@bias, $atemp[1]);
			push(@error, $atemp[2]);
			push(@overclk, $atemp[3]);
			$sum1 += $atemp[1];
			$sum2 += $atemp[2];
			$sum3 += $atemp[3];
			$cnt++;
		}
		close(FH);

		$diff  = $time[$cnt-1] - $time[0];
		$extra = 0.05 * $diff;
		$xmin  = $time[0] - $extra;
		$xmax  = $time[$cnt-1] + $extra;

		$ymin  = $sum3/$cnt - 100;
		$ymax  = $sum3/$cnt + 150;

		pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);
		pgslw(4);
		for($m = 0; $m < $cnt; $m++){
			pgpt(1, $time[$m], $overclk[$m], -1);
			$yl = $bias[$m] - $error[$m];
			$yt = $bias[$m] + $error[$m];
		}
		pgslw(2);
	   
		$title = "CCD$ccd Quad$quad";
		pglabel("Time (DOM)", 'Overclock Level', "$title");
	}
	pgclos();

	system("echo ''|/opt/local/bin/gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 | $bin_dir/ppmtogif > $web_dir/Plots/Overclock/ccd$ccd.gif");
	system("rm pgplot.ps");

	pgbegin(0, "/ps",1,1);
	pgsubp(2,2);
	pgsch(2);
	pgslw(2);	

	for($quad = 0; $quad < 4; $quad++){
		$file    = "$data_dir".'/Bias_save/'."CCD$ccd".'/'."quad$quad";
		@time    = ();
		@bias    = ();
		@error   = ();
		@overclk = ();
		@save    = ();
		$cnt     = 0;
		$sum1    = 0;
		$sum2    = 0;
		$sum3    = 0;

		open(FH, "$file"); 
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/,$_);
			$time = ($atemp[0] - 48902399)/86400;
			push(@time, $time);
			push(@bias, $atemp[1]);
			push(@error, $atemp[2]);
			push(@overclk, $atemp[3]);
			$diff = $atemp[1] - $atemp[3];
			push(@save, $diff);
			$sum1 += $atemp[1];
			$sum2 += $atemp[2];
			$sum3 += $atemp[3];
			$cnt++;
		}
		close(FH);

		$diff  = $time[$cnt-1] - $time[0];
		$extra = 0.05 * $diff;
		$xmin  = $time[0] - $extra;
		$xmax  = $time[$cnt-1] + $extra;

		$ymin  = -0.5;
		$ymax  =  1.5;
		if($ccd == 7){
			$ymin = 3.5;
			$ymax = 5.5;
		}

		pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);
		pgslw(4);
		for($m = 0; $m < $cnt; $m++){
			pgpt(1, $time[$m], $save[$m], -1);
		}
		pgslw(2);
	   
		$title = "CCD$ccd Quad$quad";
		pglabel("Time (DOM)", 'Bias', "$title");
	}
	pgclos();
	system("echo ''|/opt/local/bin/gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 | $bin_dir/ppmtogif > $web_dir/Plots/Sub/ccd$ccd.gif");
	system("rm pgplot.ps");
}
			
