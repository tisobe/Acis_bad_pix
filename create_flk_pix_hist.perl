#!/usr/bin/perl 

#########################################################################################
#											#
#	create_flk_pix_hist.perl: create flickering warm pixel history files, count	#
#				  history file, cumlative warm pixel count histor 	#
#				  files (all warm pixels appeared even only once in	#
#				  the entire mission)					#
#											#
#		author: t. isobe (tisobe@cfa.harvard.edu)				#
#											#
#		last update: Feb 25, 2008						#
#											#
#########################################################################################

#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
#$bin_dir      = '//data/mta/Script/ACIS/Bad_pixels/Test/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta/www/mta_bad_pixel/';
$old_dir       = $web_dir;
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';

for($ccd = 0; $ccd < 10; $ccd++){
#
#--- set input/output file names
#
	$new_ccd     = "$web_dir".'/Disp_dir/new_ccd'."$ccd";		#--- use this (new_ccd#) for input
	$flk_ccd     = "$web_dir".'/Disp_dir/flk_ccd'."$ccd";		#--- flickering pix hist
	$flk_ccd_cnt = "$web_dir".'/Disp_dir/flk_ccd'."$ccd".'_cnt';	#--- flickering pix count hist
	$cum_ccd     = "$web_dir".'/Disp_dir/cum_ccd'."$ccd".'_cnt';	#--- cumulative # of warm pix

	open(FH,   "$new_ccd");
	open(OUT1, ">$flk_ccd");
	open(OUT2, ">$flk_ccd_cnt");
	open(OUT3, ">$cum_ccd");

	$cum_cnt   = 0;

	while(<FH>){
		chomp $_;
		@today_flk = ();
		$today_cnt = 0;
		@atemp     = split(/<>/, $_);
		$dom       = $atemp[0];
		$date      = $atemp[1];

		print OUT1 "$dom".'<>'."$date".'<>';

		print OUT2 "$dom".'<>'."$date".'<>';

		print OUT3 "$dom".'<>'."$date".'<>';

		if($atemp[2] =~ /\(/){
			@btemp = split(/<>:/, $_);
			@pixs  = split(/:/, $btemp[1]);
			foreach $pix (@pixs){
				$ent = $pix;
				$ent =~ s/\(//;
				$ent =~ s/\)//;
				$ent =~ s/\,/\./;
#
#--- find out whether the same pixel was warm in the past
#
				$p_dom = ${data.$ccd.$ent}{dom}[0];
				if($p_dom eq ''){
					$cum_cnt++;
				}else{	
#
#--- if it was, check whether it was in the last 90 days
#
					$diff = $dom - $p_dom;
					if($diff < 90){
						push(@today_flk, $pix);
						$today_cnt++;
					}
				}
#
#--- put the new date to the record
#
				%{data.$ccd.$ent} = (dom => ["$dom"]);
#
#--- if this is a new pix, count in cumulative count
#
			}
			foreach $ent (@today_flk){
				print OUT1 ":$ent";
			}


		}
		print OUT1 "\n";
		print OUT2 ":$today_cnt\n";
		print OUT3 ":$cum_cnt\n";
	}
	close(FH);
	close(OUT1);
	close(OUT2);
	close(OUT3);
}

