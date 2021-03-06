#!/usr/bin/env /usr/local/bin/perl

#########################################################################################
#											#
#	create_new_and_imp_col_list.perl: create new and imp col history from hist_col	#
#											#
#		author: t. isobe (tisobe@cfa.harvard.edu)				#
#											#
#		last update: Apr 15, 2013						#
#											#
#########################################################################################

$comp_test = $ARGV[0];
chomp $comp_test;

@dir_list = ();

#--- output directory

if($comp_test =~ /test/i){
        $dir_list = '/data/mta/Script/ACIS/Bad_pixels/house_keeping/dir_list_test';
}else{
        $dir_list = '/data/mta/Script/ACIS/Bad_pixels/house_keeping/dir_list';
}

open(FH, $dir_list);
while(<FH>){
    chomp $_;
    @atemp = split(/\s+/, $_);
    ${$atemp[0]} = $atemp[1];
}
close(FH);


#----------------------------------------------------------

for($ccd = 0; $ccd < 10; $ccd++){
#
#--- set input/output file names
#
	$hist = "$data_dir".'/Disp_dir/hist_col'."$ccd";
	$new  = "$data_dir".'/Disp_dir/new_col'."$ccd";
	$imp  = "$data_dir".'/Disp_dir/imp_col'."$ccd";

	$hst_cnt = "$data_dir".'/Disp_dir/col'."$ccd".'_cnt';
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
	@atemp = split(/<>:/, $line[0]);
	@test  = split(/:/,   $atemp[1]);

	for($i = 1; $i < $cnt; $i++){
		$col_cnt = 0;
		$new_cnt = 0;
		$imp_cnt = 0;
		@atemp = split(/<>:/, $line[$i]);
		@comp  = split(/:/,   $atemp[1]);
#
#--- newly appeared warm columns
#
		@new   = ();
		$ncnt  = 0;
		OUTER:
		foreach $chk (@comp){
			$col_cnt++;
			for $chk2 (@test){
				if($chk == $chk2){
					next OUTER;
				}
			}
			push(@new, $chk);
			$new_cnt++;
			$ncnt++;
		}
		print OUT "$atemp[0]"."<>";
		if($ncnt == 0){
			print OUT ":";
		}
		foreach $ent (@new){
			print OUT ":$ent";
		}
		print OUT  "\n";
#
#--- disappeared warm columns
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
			$im_cnt++;
			$ncnt++;
		}

		print OUT2 "$atemp[0]"."<>";
		if($ncnt == 0){
			print OUT2 ":";
		}
		foreach $ent (@imp){
			print OUT2 ":$ent";
		}
		print OUT2 "\n";
#
#---- put the current one to the comparison list for the next round
#
		@test = @comp;
#
#--- print count history of current warm, new, and imp columns
#
		print OUT3  "$atemp[0]"."<>".":$col_cnt:$new_cnt:$imp_cnt\n";

	}
	close(OUT);
	close(OUT2);
	close(OUT3);

	system("mv new $new");
	system("mv imp $imp");
	system("mv hcnt  $hst_cnt");
}
