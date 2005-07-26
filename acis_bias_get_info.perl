#!/usr/bin/perl

#################################################################################################
#												#
#	get_info.perl: extract information about baisbackground entires				#
#												#
#	author: t. isobe (tisobe@cfa.harvard.edu)						#
#	last update: Jul 22, 2004								#
#												#
#################################################################################################

$list = $ARGV[0];

open(FH, "$list");
@data_list = ();
while(<FH>){
	chomp $_;
	push(@data_list, $_);
}
close(FH);
int_file_for_day();


###########################################################
### int_file_for_day: prepare files for analysis        ###
###########################################################

sub int_file_for_day{

	@stamp_list = ();				# use this to count how many CCDs are used for a particular observation
	foreach $file (@data_list){			# loop for data of the $kn-th day
		@atemp = split(/acisf/,$file);
		@btemp = split(/N/,$atemp[1]);
		$head = 'acis'."$btemp[0]";

		$file_time = $normal_time;			# $normal_time is output of timeconv1
		@ftemp = split(/:/, $file_time);
		$today_time = "$ftemp[0]:$ftemp[1]";

		system("fdump $file ./Working_dir/zdump  - 1 clobber=yes");	# dump the fits header and find
		open(FH, './Working_dir/zdump');				# informaiton needed (ccd id, readmode)
		$ccd_id = -999;
		$readmode = 'INDEF';
		$date_obs = 'INDEF';
		$dir_name = 'INDEF';
		while(<FH>){
			chomp $_;
			@atemp = split(/=/, $_);
			if($atemp[0] eq 'CCD_ID  '){
				@btemp = split(/\s+/, $atemp[1]);
				OUTER:
				foreach $ent (@btemp){
					if($ent =~ /\d/){
						$ccd_id = $ent;
						last OUTER;
					}
				}
			}elsif($atemp[0] =~ /READMODE/){
				@btemp = split(/\'/,$atemp[1]);
				$readmode = $btemp[1];
			}elsif($atemp[0] =~ /DATE-OBS/){
				@btemp = split(/\'/, $atemp[1]);
				$date_obs = $file_time;
				@dtemp = split(/:/,$file_time);
				$dtime = "$dtemp[0]:$dtemp[1]";
				$dir_name = $ctemp[1];
			}elsif($atemp[0] =~ /DATAMODE/){
				@btemp = split(/\'/,$atemp[1]);
				$datamode = $btemp[1];
				$datamode =~ s/\s+//g;
			}elsif($atemp[0] =~ /FEP_ID/){
				@btemp = split(/\//, $atemp[1]);
				$fep_id = $btemp[0];
				$fep_id =~ s/\s+//g;
			}elsif($atemp[0] =~ /STARTROW/){
				@btemp = split(/\//, $atemp[1]);
				$start_row = $btemp[0];
				$start_row =~ s/\s+//g;
			}elsif($atemp[0] =~ /ROWCNT/){
				@btemp = split(/\//, $atemp[1]);
				$rowcnt = $btemp[0];
				$rowcnt =~ s/\s+//g;
			}elsif($atemp[0] =~ /ORC_MODE/){
				@btemp = split(/\//, $atemp[1]);
				$orc_mode = $btemp[0];
				$orc_mode =~ s/\s+//g;
			}elsif($atemp[0] =~ /DEAGAIN/){
				@btemp = split(/\//, $atemp[1]);
				$deagain = $btemp[0];
				$deagain =~ s/\s+//g;
			}elsif($atemp[0] =~ /BIASALG/){
				@btemp = split(/\//, $atemp[1]);
				$biasalg = $btemp[0];
				$biasalg =~ s/\s+//g;
			}elsif($atemp[0] =~ /BIASARG0/){
				@btemp = split(/\//, $atemp[1]);
				$biasarg0 = $btemp[0];
				$biasarg0 =~ s/\s+//g;
			}elsif($atemp[0] =~ /BIASARG1/){
				@btemp = split(/\//, $atemp[1]);
				$biasarg1 = $btemp[0];
				$biasarg1 =~ s/\s+//g;
			}elsif($atemp[0] =~ /BIASARG2/){
				@btemp = split(/\//, $atemp[1]);
				$biasarg2 = $btemp[0];
				$biasarg2 =~ s/\s+//g;
			}elsif($atemp[0] =~ /BIASARG3/){
				@btemp = split(/\//, $atemp[1]);
				$biasarg3 = $btemp[0];
				$biasarg3 =~ s/\s+//g;
			}elsif($atemp[0] =~ /INITOCLA/){
				@btemp = split(/\//, $atemp[1]);
				$overclock_a = $btemp[0];
				$overclock_a =~ s/\s+//g;
			}elsif($atemp[0] =~ /INITOCLB/){
				@btemp = split(/\//, $atemp[1]);
				$overclock_b = $btemp[0];
				$overclock_b =~ s/\s+//g;
			}elsif($atemp[0] =~ /INITOCLC/){
				@btemp = split(/\//, $atemp[1]);
				$overclock_c = $btemp[0];
				$overclock_c =~ s/\s+//g;
			}elsif($atemp[0] =~ /INITOCLD/){
				@btemp = split(/\//, $atemp[1]);
				$overclock_d = $btemp[0];
				$overclock_d =~ s/\s+//g;
			}
		}
		close(FH);
		
		$find = 0;
		if($readmode =~ /^TIMED/i) {
			$find = 1;
		}

		if($find > 0){
			for($im = 0; $im < 10; $im++){					# loop for ccds
				if($im == $ccd_id){

					@atemp = split(/acisf/,$file);		
					@btemp = split(/N/,$atemp[1]);
					$htime = $btemp[0];
					push(@stamp_list, $htime);
		
					$overclock = $overclock_a;
					$bias_file = '../Data/Info_dir/CCD'."$im".'/quad0';
						open(QIN,">> $bias_file");
						printf QIN "%10.1f\t%4.2f\t",$htime,$overclock;
						print  QIN "$datamode\t";
						print  QIN "$fep_id\t$start_row\t$rowcnt\t$orc_mode\t";
						print  QIN "$deagain\t$biasalg\t$biasarg0\t$biasarg1\t";
						print  QIN "$biasarg2\t$biasarg3\t$biasarg4\n";
						close(QIN);
		
					$overclock = $overclock_b;
					$bias_file = '../Data/Info_dir/CCD'."$im".'/quad1';
						open(QIN,">> $bias_file");
						printf QIN "%10.1f\t%4.2f\t",$htime,$overclock;
						print  QIN "$datamode\t";
						print  QIN "$fep_id\t$start_row\t$rowcnt\t$orc_mode\t";
						print  QIN "$deagain,$biasalg\t$biasarg0\t$biasarg1\t";
						print  QIN "$biasarg2\t$biasarg3\t$biasarg4\n";
						close(QIN);
		
					$overclock = $overclock_c;
					$bias_file = '../Data/Info_dir/CCD'."$im".'/quad2';
						open(QIN,">> $bias_file");
						printf QIN "%10.1f\t%4.2f\t",$htime,$overclock;
						print  QIN "$datamode\t";
						print  QIN "$fep_id\t$start_row\t$rowcnt\t$orc_mode\t";
						print  QIN $deagain,"$biasalg\t$biasarg0\t$biasarg1\t";
						print  QIN "$biasarg2\t$biasarg3\t$biasarg4\n";
						close(QIN);
		
					$overclock = $overclock_d;
					$bias_file = '../Data/Info_dir/CCD'."$im".'/quad3';
						open(QIN,">> $bias_file");
						printf QIN "%10.1f\t%4.2f\t",$htime,$overclock;
						print  QIN "$datamode\t";
						print  QIN "$fep_id\t$start_row\t$rowcnt\t$orc_mode\t";
						print  QIN "$deagain,$biasalg\t$biasarg0\t$biasarg1\t";
						print  QIN "$biasarg2\t$biasarg3\t$biasarg4\n";
						close(QIN);
				}
			}	
		}
	}
#
#----- now count how many CCDs are used for a particular observations
#
	$cnt = 0;
	foreach (@stamp_list){
		$cnt++;
	}
	if($cnt > 0){
#
#--- first find how many time stamps are in the list
#
		@temp = @stamp_list;
		$first = shift(@temp);
		%{cnt.$first} = (cnt =>["0"]);
		@new = ($first);
		OUTER:
		foreach $ent (@temp){
			foreach $comp (@new){
				if($ent == $comp){
					next OUTER;
				}
			}
			push(@new, $ent);
			%{cnt.$ent} = (cnt =>["0"]);
		}
#
#--- count how many times one time stamps are repeated in the list
#

		foreach $ent (@stamp_list){
			${cnt.$ent}{cnt}[0]++;
		}
		open(CNO, '>>./Working_dir/list_of_ccd_no');
		foreach $ent (@new){
			@atemp = split(/\./, $ent);
			print CNO "$atemp[0]\t${cnt.$ent}{cnt}[0]\n";
		}
		close(CNO);
	}
}

