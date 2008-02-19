#!/usr/bin/perl

#########################################################################################
#											#
#	create_new_and_imp_ccd_list.perl: create new and imp col history from hist_col	#
#											#
#		author: t. isobe (tisobe@cfa.harvard.edu)				#
#											#
#		last update: Feb 14, 2008						#
#											#
#########################################################################################

for($ccd = 0; $ccd < 10; $ccd++){
#
#--- set input/output file names
#
	$hist = 'hist_ccd'."$ccd";
	$new  = 'new_ccd'."$ccd";
	$imp  = 'imp_ccd'."$ccd";
	
	$hst_cnt  = 'ccd'."$ccd".'_cnt';

#
#--- read a history file
#
	open(FH, "$hist");
	@line = ();
	$cnt  = 0;
	while(<FH>){
		chomp $_;
		push(@line, $_);
		$cnt++;
	}
	close(FH);

	open(OUT,  "> new");
	open(OUT2, "> imp");
	open(OUT3, "> hcnt");
#
#--- get the value for the first entry; use this for step comparison
#
	@atemp = split(/<>/, $line[0]);
	@test  = split(/:/,  $atemp[2]);

	for($i = 1; $i < $cnt; $i++){
		$ccd_cnt = 0;
		$new_cnt = 0;
		$imp_cnt = 0;

		@atemp = split(/<>/, $line[$i]);
		@comp  = split(/:/,  $atemp[2]);
#
#--- newly appeared warm pixels
#
		@new   = ();
		$ncnt  = 0;
		OUTER:
		foreach $chk (@comp){
			$ccd_cnt++;
			for $chk2 (@test){
				if($chk == $chk2){
					next OUTER;
				}
			}
			if($chk ne ''){
				push(@new, $chk);
				$new_cnt++;
				$ncnt++;
			}
		}
		print OUT "$atemp[0]<>$atemp[1]"."<>";

		foreach $ent (@new){
			print OUT ":$ent";
		}
		print OUT  "\n";
#
#--- disappeared warm pixels
#
		@imp  = ();
		$ncnt = 0;
		OUTER:
		foreach	$chk (@test){
			foreach $chk2 (@comp){
				if($chk == $chk2){
					next OUTER;
				}
			}
			push(@imp, $chk);
			$imp_cnt++;
			$ncnt++;
		}

		print OUT2 "$atemp[0]<>$atemp[1]"."<>";

		foreach $ent (@imp){
			print OUT2 ":$ent";
		}
		print OUT2 "\n";
#
#---- put the current one to the comparison list for the next round
#
		@test = @comp;
#
#--- create history file
#
		$aline = "$atemp[0]<>$atemp[1]<>";
		print OUT3 "$aline".":$ccd_cnt:$new_cnt:$imp_cnt\n";

	}
	close(OUT);
	close(OUT2);
	close(OUT3);

	system("mv new $new");
	system("mv imp $imp");
	system("mv hcnt  $hst_cnt");
}