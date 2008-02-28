#!/usr/bin/perl 

#########################################################################################
#											#
#	create_flk_col_hist.perl: create flickering warm column history files, count	#
#				  history file, cumlative warm columnl count history	#
#				  files (all warm columns appeared even only once in	#
#				  the entire mission)					#
#											#
#		author: t. isobe (tisobe@cfa.harvard.edu)				#
#											#
#		last update: Feb 28, 2008						#
#											#
#########################################################################################


#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta/www/mta_bad_pixel/';
$old_dir       = $web_dir;
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';

for($ccd = 0; $ccd < 10; $ccd++){
#
#--- set input/output file names
#
	$hst_col     = "$web_dir".'/Disp_dir/hist_col'."$ccd";		#--- col history file
	$new_col     = "$web_dir".'/Disp_dir/new_col'."$ccd";		#--- use this (new_ccd#) for input
	$flk_col     = "$web_dir".'/Disp_dir/flk_col'."$ccd";		#--- flickering col hist
	$flk_col_cnt = "$web_dir".'/Disp_dir/flk_col'."$ccd".'_cnt';	#--- flickering col count hist
	$cum_col     = "$web_dir".'/Disp_dir/cum_col'."$ccd".'_cnt';	#--- cumulative # of warm col
#
#--- read currently active warm column list
#

	open(FH,   "$hst_col");
	@hist_col  = ();
	while(<FH>){
		chomp $_;
		@atemp = split(/<>/,  $_);
		$dom   = $atemp[0];
		@btemp = split(/<>:/, $_);
		$hist_col[$dom] = $btemp[1];
	}
	close(FH);

	open(FH,   "$new_col");
	open(OUT1, ">$flk_col");
	open(OUT2, ">$flk_col_cnt");
	open(OUT3, ">$cum_col");

	$cum_cnt   = 0;
	@flikering = ();
	while(<FH>){
		chomp $_;
		@atemp     = split(/<>:/, $_);
		$day       = $atemp[0];
		@ctemp     = split(/<>/, $day);
		$dom       = @ctemp[0];
		@today_flk = ();

		print OUT1 "$day".'<>:';

		print OUT2 "$day".'<>:';

		print OUT3 "$day".'<>:';

		if($atemp[1] ne ''){
			@list  = split(/:/, $atemp[1]);
			foreach $col (@list){
#
#--- find out whether the same column was warm in the past
#
				$p_dom = ${data.$ccd.$col}{dom}[0];
				if($p_dom eq ''){
					$cum_cnt++;
				}else{	
#
#--- if it was, check whether it was in the last 90 days
#
					$diff = $dom - $p_dom;
					if($diff < 90){
						push(@today_flk, $col);
					}
				}
#
#--- put the new date to the record
#
				%{data.$ccd.$col} = (dom => ["$dom"]);
#
#--- if this is a new col, count in cumulative count
#
			}
		}
#
#--- check whether all columns in the list is still active flickering columns
#
		@current = @today_flk;
		@temp    = ();
		OUTER2:
		foreach $ent (@flikering){
			foreach $comp (@current){
				if($ent == $comp){
					next OUTER2;
				}
			}
			push(@temp, $ent);
		}
			
		OUTER3:
		foreach $ent (@temp){
			if($ent eq '' || $ent !~ /\d/){
				next OUTER3;
			}
			$p_dom = ${data.$ccd.$ent}{dom}[0];
			$diff = $dom - $p_dom;
			if($diff < 90){
				push(@current, $ent);
			}
		}

#
#---- remove cols listed on currently active list (from hist_col*)
#---- so that only dimmed flickering columns are listed
#
		@today_flk = ();
		@active    = split(/:/, $hist_col[$dom]);
		OUTER4:
		foreach $ent (@current){
			foreach $comp (@active){
				if($ent  == $comp){
					next OUTER4;
				}
			}
			push(@today_flk, $ent);
		}


		$today_cnt = 0;
		foreach $ent (@today_flk){
			if($today_cnt == 0){
				print OUT1 "$ent";
				$today_cnt++;
			}else{
				print OUT1 ":$ent";
				$today_cnt++;
			}
		}
		@flikering = @current;


		print OUT1 "\n";
		print OUT2 "$today_cnt\n";
		print OUT3 "$cum_cnt\n";
	}
	close(FH);
	close(OUT1);
	close(OUT2);
	close(OUT3);
}

