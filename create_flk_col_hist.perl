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
#		last update: Feb 25, 2008						#
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
	$new_col     = "$web_dir".'/Disp_dir/new_col'."$ccd";		#--- use this (new_ccd#) for input
	$flk_col     = "$web_dir".'/Disp_dir/flk_col'."$ccd";		#--- flickering col hist
	$flk_col_cnt = "$web_dir".'/Disp_dir/flk_col'."$ccd".'_cnt';	#--- flickering col count hist
	$cum_col     = "$web_dir".'/Disp_dir/cum_col'."$ccd".'_cnt';	#--- cumulative # of warm col

	open(FH,   "$new_col");
	open(OUT1, ">$flk_col");
	open(OUT2, ">$flk_col_cnt");
	open(OUT3, ">$cum_col");

	$cum_cnt   = 0;

	while(<FH>){
		chomp $_;
		@today_flk = ();
		$today_cnt = 0;
		@atemp     = split(/<>:/, $_);
		$day       = $atemp[0];
		@ctemp     = split(/<>/, $day);
		$dom       = @ctemp[0];

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
						$today_cnt++;
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
			$chk = 0;
			foreach $ent (@today_flk){
				if($chk == 0){
					print OUT1 "$ent";
					$chk++;
				}else{
					print OUT1 ":$ent";
				}
			}


		}
		print OUT1 "\n";
		print OUT2 "$today_cnt\n";
		print OUT3 "$cum_cnt\n";
	}
	close(FH);
	close(OUT1);
	close(OUT2);
	close(OUT3);
}

