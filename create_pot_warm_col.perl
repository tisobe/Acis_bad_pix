#!/usr/bin/perl 

#########################################################################################################
#													#
#	create_pot_warm_col.perl: create count history of flickering + currently warm columns		#
#													#
#		author: t. isobe (tisobe@cfa.harvard.edu)						#
#													#
#		last updated: Mar  09, 2011								#
#													#
#########################################################################################################

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

#------------------------------------------


for($ccd = 0; $ccd < 10; $ccd++){
	$hst = "$data_dir".'/Disp_dir/hist_col'."$ccd";
	$flk = "$data_dir".'/Disp_dir/flk_col'."$ccd";
	$ptn = "$data_dir".'/Disp_dir/bad_col'."$ccd".'_cnt';

#
#--- read history file
#
	open(FH, "$hst");
	@hist_file = ();

	$h_file[$i]  = '';
	OUTER:
	while(<FH>){
		chomp $_;
		@atemp = split(/<>:/, $_);
		@btemp = split(/<>/,  $atemp[0]);
		if($btemp[0] < 0){
			next OUTER;
		}
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
