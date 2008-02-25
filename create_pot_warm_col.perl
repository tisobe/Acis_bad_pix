#!/usr/bin/perl 

#########################################################################################################
#													#
#	create_pot_warm_col.perl: create count history of flickering + currently warm columns		#
#													#
#		author: t. isobe (tisobe@cfa.harvard.edu)						#
#													#
#		last updated: Feb. 25, 2008								#
#													#
#########################################################################################################

#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta/www/mta_bad_pixel/';
$old_dir       = $web_dir;
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';


for($ccd = 0; $ccd < 10; $ccd++){
	$hst = "$web_dir".'/Disp_dir/hist_col'."$ccd";
	$flk = "$web_dir".'/Disp_dir/flk_col'."$ccd";
	$ptn = "$web_dir".'/Disp_dir/bad_col'."$ccd".'_cnt';

#
#--- read history file
#
	open(FH, "$hst");
	@hist_file = ();

	$h_file[$i]  = '';
	while(<FH>){
		chomp $_;
		@atemp = split(/<>:/, $_);
		@btemp = split(/<>/,  $atemp[0]);
		$hist_file[$btemp[0]] = $atemp[1];
	}
	close(FH);

#
#---- read flickering history file
#
	open(FH,  "$flk");
	open(OUT, ">$ptn");
	while(<FH>){
		chomp $_;
		$chk = 0;

		@atemp = split(/<>:/, $_);
		@btemp = split(/<>/,   $atemp[0]);

		print OUT "$atemp[0]".'<>';

#
#---- extract and add columns which are on flickering list but not curretnly warm
#
		if($hist_file[$btemp[0]] eq ''){
			if($atemp[1] ne ''){
				@ctemp = split(/:/, $atemp[1]);
				foreach $comp (@ctemp){
					if($comp ne ''){
						$chk++;
					}
				}
			}
		}else{
			@ctemp = split(/:/, $hist_file[$btemp[0]]);
			foreach $comp (@ctemp){
				if($comp ne ''){
					$chk++;
				}
			}
			if($atemp[2] ne ''){
				@dtemp = split(/:/, $atemp[1]);
				foreach $comp (@dtemp){
					if($comp ne ''){
						$chk++;
					}
				}
			}
		}
			
		print OUT ":$chk\n";
	}
	close(FH);
	close(OUT);
}
