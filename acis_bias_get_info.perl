#!/usr/bin/perl

#################################################################################################
#												#
#	acis_bias_get_info.perl: extract information about baisbackground entires		#
#												#
#	author: t. isobe (tisobe@cfa.harvard.edu)						#
#	last update: Sep 19, 2005								#
#												#
#################################################################################################

#######################################
#
#--- setting a few paramters
#

#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta_www/mta_bias_bkg/';
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';

#$bin_dir       = '/data/mta/MTA/bin/';
#$bdat_dir      = '/data/mta/MTA/data/';
#$web_dir       = '/data/mta_www/mta_bias_bkg_test';
#$house_keeping = '/data/mta/www/mta_bad_pixel/Test/house_keeping/';

#######################################


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

#
#---- use this to count how many CCDs are used for a particular observation
#
	@stamp_list = ();
	foreach $file (@data_list){
		@atemp = split(/acisf/,$file);
		@btemp = split(/N/,$atemp[1]);
		$head  = 'acis'."$btemp[0]";

		timeconv1($btemp[0]);
		$file_time  = $normal_time;			# $normal_time is output of timeconv1
		@ftemp      = split(/:/, $file_time);
		$today_time = "$ftemp[0]:$ftemp[1]";
#
#--- dump the fits header and find informaiton needed (ccd id, readmode)
#
		system("dmlist infile=$file outfile=./Working_dir/zdump opt=head");
		open(FH, './Working_dir/zdump');				
		$ccd_id = -999;
		$readmode = 'INDEF';

		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/, $_);
			if($_ =~ /CCD_ID/){
				$ccd_id      = $atemp[2];
				$ccd_id      =~ s/\s+//g;
			}elsif($_     =~ /READMODE/){
				$readmode    = $atemp[2];
				$readmode    =~ s/\s+//g;
			}elsif($_            =~ /DATAMODE/){
				$datamode    = $atemp[2];
				$datamode    =~ s/\s+//g;
			}elsif($_            =~ /FEP_ID/){
				$fep_id      = $atemp[2];
				$fep_id      =~ s/\s+//g;
			}elsif($_            =~ /STARTROW/){
				$start_row   = $atemp[2];
				$start_row   =~ s/\s+//g;
			}elsif($_            =~ /ROWCNT/){
				$rowcnt      = $atemp[2];
				$rowcnt      =~ s/\s+//g;
			}elsif($_            =~ /ORC_MODE/){
				$orc_mode    = $atemp[2];
				$orc_mode    =~ s/\s+//g;
			}elsif($_            =~ /DEAGAIN/){
				$deagain     = $atemp[2];
				$deagain     =~ s/\s+//g;
			}elsif($_            =~ /BIASALG/){
				$biasalg     = $atemp[2];
				$biasalg     =~ s/\s+//g;
			}elsif($_            =~ /BIASARG0/){
				$biasarg0    = $atemp[2];
				$biasarg0    =~ s/\s+//g;
			}elsif($_            =~ /BIASARG1/){
				$biasarg1    = $atemp[2];
				$biasarg1    =~ s/\s+//g;
			}elsif($_            =~ /BIASARG2/){
				$biasarg2    = $atemp[2];
				$biasarg2    =~ s/\s+//g;
			}elsif($_            =~ /BIASARG3/){
				$biasarg3    = $atemp[2];
				$biasarg3    =~ s/\s+//g;
			}elsif($_            =~ /INITOCLA/){
				$overclock_a = $atemp[2];
				$overclock_a =~ s/\s+//g;
			}elsif($_            =~ /INITOCLB/){
				$overclock_b = $atemp[2];
				$overclock_b =~ s/\s+//g;
			}elsif($_            =~ /INITOCLC/){
				$overclock_c = $atemp[2];
				$overclock_c =~ s/\s+//g;
			}elsif($_            =~ /INITOCLD/){
				$overclock_d = $atemp[2];
				$overclock_d =~ s/\s+//g;
			}
		}
		close(FH);
#
#---- only when the observation is TIMEED mode, process the data further
#		
		$find = 0;
		if($readmode =~ /^TIMED/i) {
			$find = 1;
		}

		if($find > 0){
			for($im = 0; $im < 10; $im++){			# loop for ccds
				if($im == $ccd_id){

					@atemp = split(/acisf/,$file);		
					@btemp = split(/N/,$atemp[1]);
					$htime = $btemp[0];
					push(@stamp_list, $htime);
		
					$overclock = $overclock_a;
					$bias_file = "$web_dir".'/Info_dir/CCD'."$im".'/quad0';
						open(QIN,">> $bias_file");
						printf QIN "%10.1f\t%4.2f\t",$htime,$overclock;
						print  QIN "$datamode\t";
						print  QIN "$fep_id\t$start_row\t$rowcnt\t$orc_mode\t";
						print  QIN "$deagain\t$biasalg\t$biasarg0\t$biasarg1\t";
						print  QIN "$biasarg2\t$biasarg3\t$biasarg4\n";
						close(QIN);
		
					$overclock = $overclock_b;
					$bias_file = "$web_dir".'/Info_dir/CCD'."$im".'/quad1';
						open(QIN,">> $bias_file");
						printf QIN "%10.1f\t%4.2f\t",$htime,$overclock;
						print  QIN "$datamode\t";
						print  QIN "$fep_id\t$start_row\t$rowcnt\t$orc_mode\t";
						print  QIN "$deagain\t$biasalg\t$biasarg0\t$biasarg1\t";
						print  QIN "$biasarg2\t$biasarg3\t$biasarg4\n";
						close(QIN);
		
					$overclock = $overclock_c;
					$bias_file = "$web_dir".'/Info_dir/CCD'."$im".'/quad2';
						open(QIN,">> $bias_file");
						printf QIN "%10.1f\t%4.2f\t",$htime,$overclock;
						print  QIN "$datamode\t";
						print  QIN "$fep_id\t$start_row\t$rowcnt\t$orc_mode\t";
						print  QIN "$deagain\t$biasalg\t$biasarg0\t$biasarg1\t";
						print  QIN "$biasarg2\t$biasarg3\t$biasarg4\n";
						close(QIN);
		
					$overclock = $overclock_d;
					$bias_file = "$web_dir".'/Info_dir/CCD'."$im".'/quad3';
						open(QIN,">> $bias_file");
						printf QIN "%10.1f\t%4.2f\t",$htime,$overclock;
						print  QIN "$datamode\t";
						print  QIN "$fep_id\t$start_row\t$rowcnt\t$orc_mode\t";
						print  QIN "$deagain\t$biasalg\t$biasarg0\t$biasarg1\t";
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
		open(CNO, ">>$web_dir/Info_dir/list_of_ccd_no");
		foreach $ent (@new){
			@atemp = split(/\./, $ent);
			print CNO "$atemp[0]\t${cnt.$ent}{cnt}[0]\n";
		}
		close(CNO);
	}
}

################################################################
### timeconv1: chnage sec time formant to yyyy:ddd:hh:mm:ss ####
################################################################

sub timeconv1 {
        ($time) = @_;
        $normal_time = `/home/ascds/DS.release/bin/axTime3 $time u s t d`;
}


