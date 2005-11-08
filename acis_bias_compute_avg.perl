#!/usr/bin/perl

#########################################################################################
#											#
#	acis_bias_compute_avg.perl: compute averaged bias background.			#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Sep 19, 2005							#
#											#
#########################################################################################

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
#$web_dir       = '/data/mta/www/mta_bias_bkg_test/';
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

	foreach $file (@data_list){			
		@atemp      = split(/acisf/,$file);
		@btemp      = split(/N/,$atemp[1]);
		$head       = 'acis'."$btemp[0]";

		timeconv1($btemp[0]);                           # time format to e.g. 2002:135:03:42:35
		$file_time  = $normal_time;			# $normal_time is output of timeconv1
		@ftemp      = split(/:/, $file_time);
		$today_time = "$ftemp[0]:$ftemp[1]";

		system("dmlist infile=$file opt=head outfile=./zdump");

		open(FH, './zdump');				# informaiton needed (ccd id, readmode)
		$ccd_id = -999;
		$readmode = 'INDEF';

		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/, $_);
			if($_ =~  /CCD_ID/){
				$ccd_id      = $atemp[2];
			}elsif($_ =~ /READMODE/){
				$readmode    = $atemp[2];
			}elsif($_ =~ /INITOCLA/){
				$overclock_a = $atemp[2];
			}elsif($_ =~ /INITOCLB/){
				$overclock_b = $atemp[2];
			}elsif($_ =~ /INITOCLC/){
				$overclock_c = $atemp[2];
			}elsif($_ =~ /INITOCLD/){
				$overclock_d = $atemp[2];
			}
		}
		close(FH);
		
		$find = 0;
		if($readmode =~ /^TIMED/i) {
			$find = 1;
		}

		if($find > 0){
			OUTER:
			for($im = 0; $im < 10; $im++){					# loop for ccds
				if($im != $ccd_id){
					next OUTER;
				}

				@atemp = split(/acisf/,$file);		
				@btemp = split(/N/,$atemp[1]);
				$htime = $btemp[0];
		
				$line ="$file".'[opt type=i4,null=-9999]';
                                system("dmcopy \"$line\"  temp.fits clobber='yes'");

				system("dmimgthresh infile=temp.fits outfile=comb.fits cut=0:4000 clobber='yes'");
				
	
				system("dmcopy \"comb.fits[x=1:256]\" out1.fits clobber='yes'");
				$q_file = 'out1.fits';
				$bias_avg = 0;
				$bias_std = 0;
				$bias_file = "$web_dir/".'Bias_save/CCD'."$im".'/quad0';
				$c_start = 0;                                   # starting column
				$xlow  = 1;
				$xhigh = 256;
				$overclock = $overclock_a;
				quad_sep();                                      # sub to extract pixels
				system("rm out1.fits");                                 # outside of acceptance range

				if($htime > 0 && $bias_avg > 0){
					open(QIN,">> $bias_file");
					printf QIN "%10.1f\t%4.2f\t%4.2f\t%4.2f\n",$htime,$bias_avg,$bias_std,$overclock;
					close(QIN);
				}
	
				system("dmcopy \"comb.fits[x=257:512]\" out2.fits clobber='yes'");

				$q_file = 'out2.fits';
				$bias_avg = 0;
				$bias_std = 0;
				$bias_file = "$web_dir/".'Bias_save/CCD'."$im".'/quad1';
				$c_start = 256;
				$xlow  = 257;
				$xhigh = 512;
				$overclock = $overclock_b;
				quad_sep();
				system("rm out2.fits");

				if($htime > 0 && $bias_avg > 0){
					open(QIN,">> $bias_file");
					printf QIN "%10.1f\t%4.2f\t%4.2f\t%4.2f\n",$htime,$bias_avg,$bias_std,$overclock;
					close(QIN);
				}
	
				system("dmcopy \"comb.fits[x=513:768]\" out3.fits clobber='yes'");

				$q_file = 'out3.fits';
				$c_start = 512;
				$bias_avg = 0;
				$bias_std = 0;
				$bias_file = "$web_dir/".'Bias_save/CCD'."$im".'/quad2';
				$xlow  = 513;
				$xhigh = 768;
				$overclock = $overclock_c;
				quad_sep();
				system("rm out3.fits");

				if($htime > 0 && $bias_avg > 0){
					open(QIN,">> $bias_file");
					printf QIN "%10.1f\t%4.2f\t%4.2f\t%4.2f\n",$htime,$bias_avg,$bias_std,$overclock;
					close(QIN);
				}
	
				system("dmcopy \"comb.fits[x=769:1024]\" out4.fits clobber='yes'");

				$q_file = 'out4.fits';
				$c_start = 768;
				$bias_avg = 0;
				$bias_std = 0;
				$bias_file = "$web_dir/".'Bias_save/CCD'."$im".'/quad3';
				$xlow  = 769;
				$xhigh = 1024;
				$overclock = $overclock_d;
				quad_sep();
				system("rm out4.fits");
				if($htime > 0 && $bias_avg > 0){
					open(QIN,">> $bias_file");
					printf QIN "%10.1f\t%4.2f\t%4.2f\t%4.2f\n",$htime,$bias_avg,$bias_std,$overclock;
					close(QIN);
				}
			}	

		}

	}
}


###############################################################
### quad_sep: separate CCD info into quad size          #######
###############################################################

sub quad_sep{

	system("rm zout");
#
#---  dump the image to an acsii file
#
	system("dmlist $q_file opt=array > ./zout");

        open(FH, './zout');
        while(<FH>){
                chomp $_;
                @ctemp         = split(/\s+/, $_);
                if($ctemp[3] =~ /\d/ && $ctemp[4] =~ /\d/){
                        $x             = $ctemp[3];
                        $y             = $ctemp[4];
                        $val[$x][$y]   = $ctemp[6];
                }
        }

        for($i = 1;  $i <= 256; $i++){
                $sum[$i]    = 0;
                $sum2[$i]   = 0;
                $cnt[$i]    = 0;
        }
        for($i = 1; $i <= 256; $i++){
                for($j = 1; $j <= 256; $j++){
                        $sum[$i] += $val[$i][$j];
                        $sum2[$i] += $val[$i][$j] * $val[$i][$j];
                        $cnt[$i]++;
                }
        }

	system("rm zout");

	find_mean();					# find bad columns

}

#######################################################################
###  find_mean: compute mean values                                 ###
#######################################################################

sub find_mean{
        $asum  = 0;
        $asum2 = 0;
        $fcnt = 0;
        for($icol = 1; $icol <= 256; $icol++){			# make an average of averaged column value
                if($cnt[$icol] > 0){				# average of column is caluculated in 
                        $avg[$icol] = $sum[$icol]/$cnt[$icol];	# sub extract.
                        $asum  += $avg[$icol];
                        $asum2 += $avg[$icol]*$avg[$icol];
                        $fcnt++;
                }
        }
	if($fcnt > 0){
        	$cavg = $asum/$fcnt;
        	$std = sqrt($asum2/$fcnt - $cavg*$cavg);
		$bias_avg = $cavg;
		$bias_std = $std;
	}
}

################################################################
### timeconv1: chnage sec time formant to yyyy:ddd:hh:mm:ss ####
################################################################

sub timeconv1 {
        ($time) = @_;
        $normal_time = `/home/ascds/DS.release/bin/axTime3 $time u s t d`;
}

