#!/usr/bin/perl
use PGPLOT;

#################################################################################
#										#
#	acis_bad_pix_find_bad_pix.perl: find bad pixel, hot pixels, 		#
#				and warm columns and plots the results		#
#										#
#	author: t. isobe	(tisobe@cfa.harvard.edu)			#
#	last update:	Jul 29, 2005						#
#										#
#	input:									#
#		if $ARGV[0] = live: /dsops/ap/sdp/cache/*/acis/*bias0.fits	#
#			otherwse:   *bias0.fits in dir given by $ARGV[0]	#		
#		$web_dir/past_input_data: a list of the past input data		#
#		$web_dir/Defect/bad_pix_list: known bad pix list		#
#		$web_dir/Defect/Bad_col_list: known bad col list		#
#	output:									#
#		$web_dir/Defect/CCD*/						#
#			acis*_q*_max: bad pix candidates			#
#			acis*_q*_hot: hot pix candidates			#
#		$web_dir/Disp_dir/  						#
#			all_past_bad_col*: a list of all past bad columns	#
#			all_past_bad_pix*: a list of all past bad pixels	#
#			all_past_hot_pix*: a list of all past hot pixels	#
#			bad_col_cnt*:      a history of # of bad columns	#
#			bad_pix_cnt*:	   a history of # of bad pixels		#
#			ccd*:		   a list of today's bad pixels		#
#			change_ccd*:	   a history of changes of bad pixels   #
#			change_col*:	   a history of changes of bad columns	#
#			change_hccd*:	   a history of changes of hot pixels	#
#			col*:		   a list of today's bad columns	#
#			data_used.*:	   a list of data used for the CCD	#
#			flickering*:	   a list of flickering bad pixels	#
#			flickering_col*:   a list of flickering bad columns	#
#			flickering_col_save* a history of flickering columns	#
#			flickering_save*:  a history of flickering pixels	#
#			hccd*:		   a list of today's hot pixels		#
#			hflickering*:      a list of flickering hod pixels	#
#			hflickering_save*  a history of flickering hot pixels	#
#			hist_ccd*:	   a history of changes of hot pixels	#
#			hot_pix_cnt*:	   a history of # of hot pixels		#
#			imp_bad_col_save:  a history of changes of improved col #
#			imp_bad_pix_save*: a history of changes of improved pix	#
#			imp_ccd*:	   a history of improved pixels		#
#			imp_hccd*:	   a history of improved hot pixels	#
#			imp_hot_pix_save*: a history of improved hot pix cnt	#
#			new_bad_pix_save*: a history of improved bad pix cnt	#
#			new_ccd*:	   a history of appreared bad pix	#
#			new_hccd*:	   a history of appeared hot pixs	#
#			new_hot_pix_save*: a history of appeared hot pix cnt	#
#			today_new_col*:	   a list of today's bad columns	#
#			totally_new*:	   a list of totally new bad pix	#
#			totally_new_col*:  a list of totally new bad cols	#
#		$web_dir/Bias_save/CCD*/					#
#			quad*:  a list of time bias averge and sigma		#
#		$web_dir/Plot/							#
#			ccd*.gif: a plot of bias background			#
#			hist_ccd*.gif:	a plot of history of # of bad pix	#
#			hist_col*.gif:  a plot of history of # of bad col	#
#			hist_hccd*.gif:	a plot of history of # of hot pix	#
#										#
#										#
#	sub									#
#	----									#
#	get_dir:	find data files from /dspos/ap/sdp/cache		#
#			use daily update (indicated $ARGV[0]: live)		#
#	regroup_data:	read data from a given directory and regroup for the	#
#			next step						#
#	find_ydate:	find day of the year using on axTime3			#
#	int_file_for_day: 	prepare files for analysis, then call 		#
#				extract to find bad pix candidates		#
#	extract:	find bad pixel candidates				#
#	loca_chk:	cimpute a local mean around a givn pix 16x16		#
#	read_bad_pix_list:	read a knwon bad pixel/column list		#
#	rm_prev_bad_data:	rmove known bad pixels/columns from data	#	
#	select_bad_pix:	find bac pix appeared three consequtive files		#
#			actual findings are done in the following sub		#
#	find_bad_pix:	find bad pixels						#
#	add_to_list:	add bad pixels to output data list			#
#	print_bad_pix_data:	print bad pixl list ($web_dir/Disp_dir)		#
#	find_bad_col:	find bad columns					#
#	comp_to_local_avg_col: compute a local average column values		#
#	prep_col:	preparing bad column test				#
#	chk_bad_col:	find and print bad column lists (use the next sub)	#
#	print_bad_col:	print bad column lists					#
#	conv_time:	chnage time format from 1998.1.1 in sec to 		#
#			yyyy:ddd:hh:mm:ss					#
#	chk_old_data:	find data older than 30 days and move to save dir	#
#	count_new_imp:	count number of newly appeared and improved bad pix	#
#	cov_time_dom:	change time format from yyyy:ddd to dom			#
#	timeconv1:	chnage sec time formant to yyyy:ddd:hh:mm:ss		#
#	timeconv2:	change: yyyy:ddd form to sec time formart		#
#	data_for_html:	create data for web page display			#
#	today_dom:	find today dom						#
#	print_html:	update a html page for bad piexls			#
#	plot_hist:	plotting history of no. of bad pixel changes		#
#	count_bad_pix:	count number of bad pixels				#
#	plot_diff:	plotting routine					#
#	linr_fit:	least sq linear fit 					#
#	mv_old_data:	move old data from an active dir to a save dir		#
#	flickering_check:	check whcih pixels are flickering in the past 	#
#				90 days						#
#	conv_date_form4:	change date format from yy:mm:dd to yy:ydyd	#
#	rm_incomplete_data:	remove incomplete data so that we can fill	#
#				it correctly					#
#	adjust_hist_count:	couts # of bad pix from $web_dir/Disp_dir/hist*	#
#	conv_time_dom:	change date from yyyy:ddd to dom			#
#	find_more_bad_pix_info: find additional information about bad pix	#
#	find_flickering:	find flickering pixels				#
#	find_flickering_col:	find flickering cols				#
#	find_all_past_bad_pix:	make a list of all bad pixels in the past	#
#	find_all_past_bad_col:	make a list of all bad columns in the past	#
#	find_totally_new:	find first time bad pixels (call new_pix)	#
#	new_pix:	find first time bad pixels --- main script 		#
#	find_totally_new_col:	find first time bad columns			#
#										#
#################################################################################

#######################################
#
#--- setting a few paramters
#

#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta/www/mta_bad_pixel/';
$old_dir       = $web_dir;
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';

$bin_dir       = '/data/mta/MTA/bin/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta/www/mta_bad_pixel/Test/';
$old_dir       = $web_dir;
$house_keeping = '/data/mta/www/mta_bad_pixel/Test/house_keeping/';

$lookup   = '/home/ascds/DS.release/data/dmmerge_header_lookup.txt';    # dmmerge header rule lookup table

#--- factor for how may std out from the mean

$factor     = 5.0;
$col_factor = 3.0;
$hot_factor = 1000.0;

#######################################

$file = `ls -d`;					# clearn up the directory
@file = split(//, $file);				

if($file =~ /Working_dir/){
	system("rm -rf ./Working_dir");
}
system("mkdir ./Working_dir");				# create working dirctory

if($file =~ /param/){
	system("rm -rf ./param");
}
system("mkdir ./param");

$input_type = $ARGV[0];                                 # two different types of input
chomp $input_type;       


if($input_type eq 'live'){
	get_dir();					# this is for the automated case
}else{
	regroup_data();
}

read_bad_pix_list();					# read known bad pixel list and bad col list

$dcnt = 1;

if($dcnt > 0){						# yes we have new data, so let compute
	
	system("rm $web_dir/Disp_dir/today*");
	for($kn = 0; $kn <= $kdir; $kn++){
		system("rm ./Working_dir/today*");
		$today_new_bad_pix  = 0;		# these are used to count how many new and improved
		$today_new_bad_pix5 = 0;		# bad pixels appeared today.
		$today_new_bad_pix7 = 0;
		$today_imp_bad_pix  = 0;
		$today_imp_bad_pix5 = 0;
		$today_imp_bad_pix7 = 0;
	
		$today_new_hot_pix  = 0;		# these are used to count how many new and improved
		$today_new_hot_pix5 = 0;		# hot pixels appeared today.
		$today_new_hot_pix7 = 0;
		$today_imp_hot_pix  = 0;
		$today_imp_hot_pix5 = 0;
		$today_imp_hot_pix7 = 0;
	
		$today_new_bad_col  = 0;		# these are used to count how many new and improved
		$today_new_bad_col5 = 0;		# bad columns appeared today.
		$today_new_bad_col7 = 0;
		$today_imp_bad_col  = 0;
		$today_imp_bad_col5 = 0;
		$today_imp_bad_col7 = 0;
	
		int_file_for_day();			# prepare files for analysis
	
		select_bad_pix();			# find bad pix appear three consequtive files
	
		prep_bad_col();				# preparing bad column test
	
		add_to_list();				# adding bad pixels to lists
	
		chk_bad_col();				# find and print bad columns
	
		print_bad_col();			# pint bad columns
	
		count_new_imp();			# count numbers of new and improved bad pixels

		if($input_type eq 'live'){
			chk_old_data();			# find data older than 30 days (7 days) and move to Save
		}

		data_for_html();			# create data for web page display
	}

	flickering_check();				# check which pixels are flickering in the past 90 days
	find_more_bad_pix_info();			# find additional information about bad pixels

	plot_hist();					# plotting history of bad pixel increase
	print_html();					# print up-dated html page for bad pixel
	adjust_hist_count();				# ounts # of bad pixels from Disp_dir/hist_ccd# files
}

mv_old_data();						# move old data from an active dir to a save dir

system("rm -rf ./Working_dir/");


#########################################################
### get_dir: find data files from /dsops/ap/sdp/cache ###
#########################################################

sub get_dir {
	open(FH, '$house_keeping/past_input_data');
	@past_list = ();
	@past_date_list = ();				# get a previous data list
	while(<FH>){
		chomp $_;
		push(@past_list, $_);
		@atemp = split(/\//, $_);
		@btemp = split(/_/, $atemp[5]);
		$year = $btemp[0];
		$month = $btemp[1];
		$day  = $btemp[2];
		conv_date_form4();
		push(@past_date_list, $date);
	}
	close(FH);

	system("ls /dsops/ap/sdp/cache/*/acis/*bias0.fits > ./Working_dir/zinput");
	@input_list = ();
	@new_list = ();					# find a new data candidates
	@new_date_list = ();
	@new_date_list2 = ();
	open(FH,'./Working_dir/zinput');
	while(<FH>){
		chomp $_;
		push(@input_list, $_);
		
		$old = 0;				# select new data and save
		OUTER:
		foreach $comp (@past_list){
			if($comp eq $_){
				$old = 1;
				last OUTER;
			}
		}
		if($old == 0){
			push(@new_list, $_);
			@atemp = split(/\//, $_);
			@btemp = split(/_/, $atemp[5]);
			$year  = $btemp[0];
			$month = $btemp[1];
			$day   = $btemp[2];
			conv_date_form4();
			push(@new_date_list, $date);
			$dir = "/$atemp[1]/$atemp[2]/$atemp[3]/$atemp[4]/$atemp[5]";
			push(@new_date, $dir);
		}
	}
	close(FH);
	system("mv $house_keeping/past_input_data $house_keeping/past_input_data~");
	system("mv ./Working_dir/zinput $house_keeping/past_input_data");

	@past_date_list = sort{$a<=> $b} @past_date_list;

	@temp = (shift(@past_date_list));		# remove duplicates from the past data
	OUTER:
	foreach $ent (@past_date_list){
        	foreach $comp (@temp){
                	if($comp == $ent){
                        	next OUTER;
                	}
        	}
        	push(@temp, $ent);
	}
	@past_date_list = @temp;

	@new_date_list = sort{$a <=> $b} @new_date_list;

	@temp = (shift(@new_date_list));		# remove duplicates from the new data
	OUTER:
	foreach $ent (@new_date_list){
        	foreach $comp (@temp){
                	if($comp == $ent){
                        	next OUTER;
                	}
        	}
        	push(@temp, $ent);
	}
	@new_date_list = @temp;

	@cnew_list = ();				# select un-processed data
	OUTER:
	foreach $ent (@new_date_list){
		foreach $comp (@past_date_list){
			if($ent == $comp){
				next OUTER;
			}
		}
		push(@cnew_list, $ent);
	}
	$chk_date = shift(@cnew_list);
	$plast_date = pop(@past_date_list);
		

	if(($chk_date ne '') && ($plast_date ne '') && ($chk_date <= $plast_date)){
		$cut_date = $chk_date;

		rm_incomplete_data();		# rm data from database for recomputation
	
		@new_date = ();
		foreach $ent (@input_list){
			@atemp = split(/\//,$ent);
			@btemp = split(/_/, $atemp[5]);
			$year = $btemp[0];
			$month = $btemp[1];
			$day = $btemp[2];
			conv_date_form4();
			
			if($date >= $chk_date){
				$dir = "/$atemp[1]/$atemp[2]/$atemp[3]/$atemp[4]/$atemp[5]";
				push(@new_date, $dir);
			}
		}
			
	}

	@new_date = sort{$a<=>$b} @new_date;
	$dcnt = 0;
	foreach(@new_date){
		$dcnt++;
	}
	$first = shift(@new_date);
	@dir1 = ($first);
	OUTER:
	foreach $ent (@new_date){
		foreach $comp (@dir1){
			if($ent eq $comp){
				next OUTER;
			}
		}
		push(@dir1, $ent);
	}

	@bias_bg_comp_list = ();	# this list will be used to compute bias background.
	$kdir = 0;			# find bias0 file names in today's new directories
	OUTER:
	foreach $dir (@dir1){
		$tdy_data = `ls $dir/acis/acis*bias0*`;
		@tyd_data_list = split(/\s+/, $tdy_data);
		$chk = 0;
		@{day_list.$kdir} = ();
		foreach $ent (@tyd_data_list){
			chomp $ent;
			push(@{day_list.$kdir}, $ent);
			push(@bias_bg_comp_list, $ent);
			$chk++;
		}
		if($chk > 0){
			$kdir++;
		}
	}
	if($kdir > 0){
		$kdir--;
	}
}

################################################################
### regroup_data: regroup data for further analysis          ###
################################################################

sub regroup_data{

	$t_input = `ls $input_type/acisf*fits`;
	@t_input_list = split(/\s+/, $t_input);
	@bias_bg_comp_list = ();				# this will be used to compute bias bg
        @data = ();
	$dcnt = 0;
        $cnt = 0;
        foreach $ent (@t_input_list){
                chomp $_;
                push(@data, $_);
		push(@bias_bg_comp_list, $_);
                $cnt++;
        }

        find_ydate($data[0]);                                   # chnage date format
        $day_start = $yday;                                     # first date of the data period

        find_ydate($data[$cnt-1]);
        $day_end = $yday;                                       # last date of the data period

        $diff = $day_end - $day_start;
        for($i = 0; $i <= $diff; $i++){
                @{day_list.$i} = ();                            # create arrays for # of dates
        }

        $comp_date = $day_start;
        $kdir = 0;
        foreach $ent (@data){
                find_ydate($ent);
                if($yday == $comp_date){
                        push(@{day_list.$kdir}, $ent);
                }else{
                        $comp_date = $yday;
                        $kdir++;
                        push(@{day_list.$kdir}, $ent);
                }
        }
	if($kdir >= 0){
		$dcnt++;
	}
}

################################################################
### find_ydate: find day of the year                         ###
################################################################

sub find_ydate {
        ($input) = @_;
        @atemp = split(/acisf/, $input);
        @btemp = split(/N/, $atemp[1]);
	$n_time = `/home/ascds/DS.release/bin/axTime3 $btemp[0] u s t d`;
        @atemp = split(/:/, $n_time);
        $yday = $atemp[1];
}


###########################################################
### int_file_for_day: prepare files for analysis        ###
###########################################################

sub int_file_for_day{

	for($n = 0; $n < 10; $n++){				# loop for ccds: initialization
		@{list.$n}      = ();
		@{todaylist.$n} = ();
		${cnt.$n}       = 0;
	}

	foreach $file (@{day_list.$kn}){			# loop for data of the $kn-th day
		@atemp = split(/acisf/,$file);
		@btemp = split(/N/,$atemp[1]);
		$head  = 'acis'."$btemp[0]";

		timeconv1($btemp[0]);				# time format to e.g. 2002:135:03:42:35	
		$file_time  = $normal_time;			# $normal_time is output of timeconv1
		@ftemp      = split(/:/, $file_time);
		$today_time = "$ftemp[0]:$ftemp[1]";

#
#---  dump the fits header and find informaiton needed (ccd id, readmode)
#
#$$$##		system("fdump $file ./Working_dir/zdump  - 1 clobber=yes");	
		system("dmlist infile=$file opt=head outfile=./Working_dir/zdump");
		open(FH, './Working_dir/zdump');			
		$ccd_id   = -999;
		$readmode = 'INDEF';
		$date_obs = 'INDEF';
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/, $_);
			if($_ =~ /CCD_ID/){
				$ccd_id      = $atemp[2];
			}elsif($_ =~ /READMODE/){
				$readmode    = $atemp[2];
			}elsif($_ =~ /DATE-OBS/){
				$date_obs    = $file_time;
				@dtemp       = split(/:/,$file_time);
				$dtime       = "$dtemp[0]:$dtemp[1]";
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
#
#---  if it is in a timed mode add to process list for the ccd
#		
		if($readmode =~ /^TIMED/i) {
			push(@{todaylist.$ccd_id}, $file);
			${cnt.$ccd_id}++;		
		}
	}

	@warm_data_list     = ();
	@hot_data_list      = ();
	for($im = 0; $im < 10; $im++){					# loop for ccds

		@{today_warm_list.$im}    = ();
		@{today_hot_list.$im}     = ();
#
#--- tdycnt is used as an indicator whether there are any data
#
		${tdycnt.$im} = ${cnt.$im};
		if(${cnt.$im} > 0){
			open(FOUT, ">>$web_dir/Disp_dir/data_used.$im");	# record for data used
			foreach $file (@{todaylist.$im}){
				@ntemp = split(/acisf/, $file);
				print FOUT "$date_obs: acisf$ntemp[1]\n";
			}
			close(FOUT);

			$first = shift(@{todaylist.$im});		
			if(${cnt.$im} > 1){				
				@atemp = split(/acisf/,$first);		
				@btemp = split(/N/,$atemp[1]);
				$head  = 'acis'."$btemp[0]";
				$htime = $btemp[0];

				timeconv1($btemp[0]);
				$file_time = $normal_time;
				@ftemp     = split(/:/, $file_time);
				$date_obs  = "$ftemp[0]:$ftemp[1]";		
#
#---  change fits file format to LONG
#
				$line ="$first".'[opt type=i4,null=-9999]';
				system("dmcopy \"$line\"  ./Working_dir/comb.fits clobber='yes'");
#
#--- merge all data into one
#
				foreach $pfile (@{todaylist.$im}){
					$line ="$pfile".'[opt type=i4,null=-9999]';
					system("dmcopy \"$line\"  ./Working_dir/temp.fits clobber='yes'");
#$$##					system("fimgtrim  infile=./Working_dir/temp.fits outfile=./Working_dir/temp2.fits  threshlo=indef threshup=4000  const_up=0 clobber=yes");
					system("dmimgthresh infile=./Working_dir/temp.fits outfile=./Working_dir/temp2.fits cut=\"0:4000\" value=0 clobber=yes");
					open(OUT, '>./Working_dir/zadd');			
					print OUT "./Working_dir/temp2.fits,0,0\n";
					close(OUT);
#$$##					system("fimgmerge ./Working_dir/comb.fits  \@./Working_dir/zadd ./Working_dir/comb2.fits clobber=yes");
					system("dmmerge "./Working_dir/comb.fits,./Working_dir/temp2.fits" outfile=./Working_dir/comb2.fits  outBlock='' columnList='' lookupTab=\"$lookup\" clobber=yes");
					system("mv ./Working_dir/comb2.fits ./Working_dir/comb.fits");
				}

			}else{
				@atemp = split(/acisf/,$first);		
				@btemp = split(/N/,$atemp[1]);
				$head  = 'acis'."$btemp[0]";
				$htime = $btemp[0];

				@ftemp    = split(/:/, $file_time);
				$date_obs = "$ftemp[0]:$ftemp[1]";
				$line     = "$first".'[opt type=i4,null=-9999]';
				system("dmcopy \"$line\"  ./Working_dir/temp.fits clobber='yes'");
#$$##				system("fimgtrim  infile=./Working_dir/temp.fits outfile=./Working_dir/comb.fits  threshlo=indef threshup=4000  const_up=0 clobber=yes");
				system("dmimgthresh infile=./Working_dir/temp.fits outfile=./Working_dir/comb.fits cut=\"0:4000\" value=0 clobber=yes");
			}
			
			$ccd_dir = "$house_keeping/Defect/CCD"."$im";
			system("rm ./Working_dir/out*.fits");

			system("dmcopy \"./Working_dir/comb.fits[x=1:256]\" ./Working_dir/out1.fits clobber='yes'");
			$q_file       = 'out1.fits';
			$min_file     = "$head".'_q1_min';            # setting a file name lower
			$max_file     = "$head".'_q1_max';            # setting a file name upper
			$hot_max_file = "$head".'_q1_hot';            # setting a file name hot
			$c_start      = 0;                            # starting column
			$xlow         = 1;
			$xhigh        = 256;
			extract();                                    # sub to extract pixels
			system("rm ./Working_dir/out1.fits");         # outside of acceptance range

			system("dmcopy \"./Working_dir/comb.fits[x=257:512]\" ./Working_dir/out2.fits clobber='yes'");
			$q_file       = 'out2.fits';
			$min_file     = "$head".'_q2_min';
			$max_file     = "$head".'_q2_max';
			$hot_max_file = "$head".'_q2_hot';
			$c_start      = 256;
			$xlow         = 257;
			$xhigh        = 512;
			extract();
			system("rm ./Working_dir/out2.fits");

			system("dmcopy \"./Working_dir/comb.fits[x=513:768]\" ./Working_dir/out3.fits clobber='yes'");
			$q_file       = 'out3.fits';
			$min_file     = "$head".'_q3_min';
			$max_file     = "$head".'_q3_max';
			$hot_max_file = "$head".'_q3_hot';
			$c_start      = 512;
			$xlow         = 513;
			$xhigh        = 768;
			extract();
			system("rm ./Working_dir/out3.fits");

			system("dmcopy \"./Working_dir/comb.fits[x=769:1024]\" ./Working_dir/out4.fits clobber='yes'");
			$q_file       = 'out4.fits';
			$min_file     = "$head".'_q4_min';
			$max_file     = "$head".'_q4_max';
			$hot_max_file = "$head".'_q4_hot';
			$c_start      = 768;
			$xlow         = 769;
			$xhigh        = 1024;
			extract();
			system("rm ./Working_dir/out4.fits");
#
#--- removing known bad pixels and bad columns
#
			@today_bad_list = @{today_warm_list.$im};
			rm_prev_bad_data();
	
			@today_bad_list = @{today_hot_list.$im};
			rm_prev_bad_data();
		}

	}
}


###############################################################
### extract: find bad pixel candidates                  #######
###############################################################

sub extract {
	open(UPPER, ">>$ccd_dir/$max_file");		# create data file; it could be empty
	close(UPPER);					# at the end, but it will be used for 
	open(HOT,">>$ccd_dir/$hot_max_file");		# bookkeeping later
	close(HOT);

	system("rm ./Working_dir/zout");
	system("fimgdmp ./Working_dir/$q_file ./Working_dir/zout 1 256  1 1024");# dump the image to an acsii file

	@warm_list = ();
	@hot_list = ();
        open(FH, './Working_dir/zout');

	for($i = 1;  $i <= 256; $i++){
		$sum[$i]    = 0;
		$sum2[$i]   = 0;
		$cnt[$i]    = 0;
		@{value.$i} = ();
	}

#
#--- since the ascii table is 7 columns by all y arrays you need to do some tricks to read in the data.
#
        OUTER:
        while(<FH>){
                chomp $_;
                @line = split(/\s+/, $_);
                $lcnt = 0;		
		foreach(@line){		
			$lcnt++;	
		}

                if($lcnt > 0 && $lcnt <=  8 && $div == 0) {
#
#--- reading column
#
                        @x_axis = @line;
                        $div    = 1;
                        $y_cnt  = 0;
                        next OUTER;
                }

                if($lcnt > 0) {
                        $y_pos = $line[1];
#
#--- reading data
#
                        for($i = 2; $i < $lcnt; $i++){
                                $x_pos = $x_axis[$i-1];
                                $val = $line[$i];
				$ent = 7*($y_pos - 1) + $x_pos;
#
#--- blank space is -9999
#
                                if($val > 0){
					${value.$x_pos}[$y_pos] = $val;
                                        $count++;
					$sum[$x_pos] += $val;
					$sum2[$x_pos] += $val*$val;
					$cnt[$x_pos]++;
                                }else{
					${value.$x_pos}[$y_pos] = -9999;
				}
                        }
                        $y_cnt++;
                        if($y_cnt >= 1024){
                                $div = 0;
                        }
                }
        }
        close(FH);

	find_bad_col();		# find bad columns
#
#--- devide the quad to 8x32 areas so that we can compare the each pix to a local average
#
	for($ry = 0;$ry < 32; $ry++){
		$ybot = 32*$ry + 1; 
		$ytop = $ybot + 31;	
		OUTER3:
		for($rx = 0; $rx < 8; $rx++){
			$xbot = 32*$rx + 1;
			$xtop = $xbot + 31;
			$sum = 0;
			$sum2 = 0;
			$count = 0;
			for($ix = $xbot; $ix<=$xtop; $ix++){
				OUTER2:
				for($iy = $ybot; $iy<=$ytop; $iy++){
					$val = ${value.$ix}[$iy];
					if($val == -999){
						next OUTER2;
					}
					$sum += $val;
					$sum2 += $val * $val;
					$count++;
				}
			}
			if($count < 1){
				next OUTER3;
			}
			$mean = $sum/$count;			# here is the local mean
			$std  = sqrt($sum2/$count - $mean * $mean);
			$warm = $mean + $factor*$std;		# define warm pix
			$hot  = $mean + $hot_factor;		# define hot pix
#
#--- now find bad pix candidates
#
			for($ix = $xbot; $ix<=$xtop; $ix++){
				OUTER2:
				for($iy = $ybot; $iy<=$ytop; $iy++){
					$val = ${value.$ix}[$iy];
					if($val == -999){
								# warm pix candidates	
						next OUTER2;
					}elsif($val > $warm && $val < $hot){
						local_chk();	# recompute a local mean 
						if($val > $cwarm){
							open(UPPER, ">>$ccd_dir/$max_file");
							print UPPER "$ix\t$iy\t$val\t$date_obs\t$cmean\t$cstd\n";
							close(UPPER);
							push(@warm_list,"$ccd_dir/$max_file");
						}
								# hot pix candidates
					}elsif($val >= $hot){
						local_chk();
						if($val > $chot){
							open(HOT,">>$ccd_dir/$hot_max_file");
							print HOT "$ix\t$iy\t$val\t$date_obs\t$cmean\t$cstd\n";
							close(HOT);
							push(@hot_list,"$ccd_dir/$hot_max_file");
						}
					}
				}
			}
		}
	}
#
#--- checking duplicates, if there are, remove it.
#
	$first = shift(@warm_list);
	@new_list = ("$first");
	OUTER:
	foreach $ent (@warm_list){
		foreach $comp (@new_list){
			if($ent eq $comp){
				next OUTER;
			}
		}
		push(@new_list, $ent);
	}
	open(OUT,">>./Working_dir/today_warm_list");
	foreach $ent (@new_list){
		if($ent ne ''){
			print OUT "$ent\n";
			push(@{today_warm_list.$im},$ent);
		}
	}
	close(OUT);

	$first = shift(@hot_list);
	@new_list = ("$first");
	OUTER:
	foreach $ent (@hot_list){
		foreach $comp (@new_list){
			if($ent eq $comp){
				next OUTER;
			}
		}
		push(@new_list, $ent);
	}
	open(OUT,">>./Working_dir/today_hot_list");
	foreach $ent (@new_list){
		if($ent ne ''){
			print OUT "$ent\n";
			push(@{today_hot_list.$im},$ent);
		}
	}
	close(OUT);
}


#########################################################################
### local_chk: compute a local mean around a givn pix. 16x16 area    ####
#########################################################################

sub local_chk {

	$x1 = $ix - 8;
	$x2 = $ix + 8;
	if($x1 < 0){				# check the case, when the pixel is
		$x2 += abs($x1);		# located at the coner, and cannot
		$x1 = 1;			# take 16x16 around it.
	}elsif($x2 > 256){			# if that is the case, shift the area
		$x1 -= ($x2 - 256);
		$x2 = 256;
	}
	$y1 = $iy - 8;
	$y2 = $iy + 8;
	if($y1 < 0){
		$y2 += abs($y1);
		$y1 = 1;
	}elsif($y2 > 256){
		$y1 -= ($y2 - 256);
		$y2 = 256;
	}
	$csum = 0;
	$csum2 = 0;
	$ccount = 0;
	for($xx = $x1; $xx <= $x2; $xx++){
		OUTER2:
		for($yy = $y1; $yy <= $y2; $yy++){
			$cval = ${value.$xx}[$yy];
			if($cval == -999){
				next OUTER2;
			}
			$csum += $cval;
			$csum2 += $cval * $cval;
			$ccount++;
		}
	}
	if($ccount > 0){
		$cmean = $csum/$ccount;
		$cstd =sqrt($csum2/$ccount - $cmean * $cmean);
		$cwarm = $cmean + $factor*$cstd;
		$chot  = $cmean +$hot_factor;
	}
}
	
############################################################################
###    read_bad_pix_list: read an existing bad pixel/column list	####
############################################################################

sub read_bad_pix_list{
	for($i = 0; $i < 10; $i++) {
		$name = 'col_ccd'."$i";	 	# column #      for bad columns
		$name2 = 'col_ccd_rs'."$i";     # starting row #
		$name3 = 'col_ccd_rf'."$i";     # ending row #
		@{$name} = ();		  	# easy way to change array names
		@{$name2} = ();
		@{$name3} = ();

		$name = 'pix_ccd_x'."$i";       # column #      for bad pixels
		$name2 = 'pix_ccd_x'."$i";      # row #
		@{$name} = ();
		@{$name2} = ();
	}

	open(FH, "$house_keeping/Defect/bad_col_list");      # a bad column list
	while(<FH>) {
		chomp $_;
		@atemp = split(//,$_);
		if($atemp[0] =~ /\d/) {
			@atemp = split(/:/,$_);
			$name = 'col_ccd'."$atemp[0]";
			$name2 = 'col_ccd_rs'."$atemp[0]";
			$name3 = 'col_ccd_rf'."$atemp[0]";
			push(@{$name},$atemp[1]);
			push(@{$name2},$atemp[2]);
			push(@{$name3},$atemp[3]);
		}
	}
	close(FH);

	open(FH, "$house_keeping/Defect/bad_pix_list");      # a bad pixel list
	while(<FH>) {
		chomp $_;
		@atemp = split(//,$_);
		if($atemp[0] =~ /\d/) {
			@atemp = split(/:/,$_);
			$name = 'pix_ccd_x'."$atemp[0]";
			$name2 = 'pix_ccd_y'."$atemp[0]";
			push(@{$name},$atemp[2]);
			push(@{$name2},$atemp[3]);
		}
	}
	close(FH);
}

####################################################################
####  rm_prev_bad_data: removing data in the list from the data####
####################################################################

sub rm_prev_bad_data {
	$bad_data = 'col_ccd'."$im";	   		# bad column list
	$bad_data_rs = 'col_ccd_rs'."$im";		# $im is ccd id from sub extract
	$bad_data_rf = 'col_ccd_rf'."$im";

	$bad_pix_x = 'pix_ccd_x'."$im";			# bad pixel list
	$bad_pix_y = 'pix_ccd_y'."$im";

	foreach $file (@today_bad_list) {
		@ntemp = split(/q/,$file);
		@mtemp = split(/_/,$ntemp[1]);
		$tquad = $mtemp[0] - 1;			# checking quad (and subtract 1)

		open(TEMP, ">./Working_dir/ztemp");
		open(FH, "$file");
		$zchk = 0;

		OUTER:
		while(<FH>) {
			chomp $_;
			@atemp = split(/\s+/,$_);	# check bad column

			if($atemp[1] > 1022){	
				next OUTER;
			}

			$atemp[0] = $atemp[0] + 256*$tquad;
			$rcnt = 0;
			foreach $comp (@{$bad_data}){		# check with known bad columns
				if($comp eq $atemp[0]
				&& ${$bad_data_rs}[$rcnt] <= $atemp[1]
				&& ${$bad_data_rf}[$rcnt] >= $atemp[1]){
					next OUTER;
				}
				$rcnt++;
			}

			$rcnt = 0;		       # check bad pixel
			foreach $comp (@{$bad_pix_x}){
				if($comp == $atemp[0]
				&& ${$bad_pix_y}[$rcnt] == $atemp[1]){
					next OUTER;
				}
				$rcnt++;
			}
					# if data is not in known bad pixel/column list
					# print out x y, value, time, mean and std of the area of obs
					# of the pixel

			print TEMP "$_\n";
			$zchk++;
		}
		close(FH);
		close(TEMP);

		system("rm $file");
		system("mv ./Working_dir/ztemp $file");
	}
}


##########################################################################
### select_bad_pix: find bad pix appears three consequtive files      ####
###                 actual finding is done in sub find_bd_pix	      ####
##########################################################################

sub select_bad_pix{
	
#
#---- read warm and hot pixel candidate file list; separate by CCDs
#
	for($ix = 0; $ix < 10; $ix++){
		@{today_warm_list.$ix} = ();
		@{today_hot_list.$ix}  = ();
	}

	open(FH, './Working_dir/today_warm_list');
	while(<FH>){
		chomp $_;
		@atemp = split(/CCD/, $_);
		@btemp = split(/\//, $atemp[1]);
		@ctemp = split(/acis/, $_);
		$ent = 'acis'."$ctemp[1]";
		$ix = $btemp[0];
		push(@{today_warm_list.$ix}, $ent);
	}
	close(FH);
	
	open(FH, './Working_dir/today_hot_list');
	while(<FH>){
		chomp $_;
		@atemp = split(/CCD/, $_);
		@btemp = split(/\//, $atemp[1]);
		@ctemp = split(/acis/, $_);
		$ent = 'acis'."$ctemp[1]";
		$ix = $btemp[0];
		push(@{today_hot_list.$ix}, $ent);
	}
	close(FH);

	for($sccd = 0; $sccd < 10; $sccd++){
		$tccd = 'CCD'."$sccd";
		$temp_file = `ls $house_keeping/Defect/$tccd`;
		@temp_file_list = split(/\s+/, $temp_file);

		@dquadmx1 = ();				# quad ind for warm pix
		@dquadmx2 = ();
		@dquadmx3 = ();
		@dquadmx4 = ();
		@dquadht1 = ();				# quad ind for hot pix
		@dquadht2 = ();
		@dquadht3 = ();
		@dquadht4 = ();
		$dmcnt1   = 0;
		$dmcnt2   = 0;
		$dmcnt3   = 0;
		$dmcnt4   = 0;
		$dhcnt1   = 0;
		$dhcnt2   = 0;
		$dhcnt3   = 0;
		$dhcnt4   = 0;

		foreach $ent (@temp_file_list){
#
#--- separate the data into each quad.
#
			chomp $_;
			@atemp = split(/_q/,$ent);
			if($atemp[1] eq '1_max'){	# warm pix
				push(@dquadmx1,$ent);
				$dmcnt1++;
			}elsif($atemp[1] eq '2_max'){
				push(@dquadmx2,$ent);
				$dmcnt2++;
			}elsif($atemp[1] eq '3_max'){
				push(@dquadmx3,$ent);
				$dmcnt3++;
			}elsif($atemp[1] eq '4_max'){
				push(@dquadmx4,$ent);
				$dmcnt4++;
			}elsif($atemp[1] eq '1_hot'){	# hot pix
				push(@dquadht1,$ent);
				$dhcnt1++;
			}elsif($atemp[1] eq '2_hot'){
				push(@dquadht2,$ent);
				$dhcnt2++;
			}elsif($atemp[1] eq '3_hot'){
				push(@dquadht3,$ent);
				$dhcnt3++;
			}elsif($atemp[1] eq '4_hot'){
				push(@dquadht4,$ent);
				$dhcnt4++;
			}
		}
#
#---- WARM PIXELS
#	
		@equadmx1 = ();
		@equadmx2 = ();
		@equadmx3 = ();
		@equadmx4 = ();
		$emcnt1 = 0;
		$emcnt2 = 0;
		$emcnt3 = 0;
		$emcnt4 = 0;

		foreach $line (@{today_warm_list.$sccd}){
			@etemp = split(/_q/,$line);
			if($etemp[1] eq '1_max'){
				push(@equadmx1,$line);
				$emcnt1++;
			}elsif($etemp[1] eq '2_max'){
				push(@equadmx2,$line);
				$emcnt2++;
			}elsif($etemp[1] eq '3_max'){
				push(@equadmx3,$line);
				$emcnt3++;
			}elsif($etemp[1] eq '4_max'){
				push(@equadmx4,$line);
				$emcnt4++;
			}
		}
	
		for($qno = 1; $qno < 5; $qno++){	# cycle quad 1 to 4
			$gtemp = 'dquadmx'."$qno";
			@dname = @{$gtemp};
			$gtemp = 'dmcnt'."$qno";
			$dcnt  = ${$gtemp};
			$gtemp = 'equadmx'."$qno";
			@ename = @{$gtemp};
			$gtemp  = 'emcnt'."$qno";
			$ecnt = ${$gtemp};
#
#--- specify a file from today's list, and find two previous data list.
#--- if there is not, drop from the warm pix file list
#
			for($i = 0; $i < $ecnt; $i++){
				$file3 = $ename[$i];		
				$ccnt = 0;			
				OUTER:				
				foreach $comp (@dname){		
					if($file3 eq $comp){	
						last OUTER;
					}
					$ccnt++;
				}
#
#--- if there are three files find a warm pix
#
				if($ccnt > 1){		
					$file2 = $dname[$ccnt-1];
					$file1 = $dname[$ccnt-2];
					$out_file = 'warm_data_list';

					find_bad_pix();		# check three files to find bad pix
				}
			}
		}

#
#--- HOT PIXELS
#

		@equadht1 = ();
		@equadht2 = ();
		@equadht3 = ();
		@equadht4 = ();
		$emcnt1 = 0;
		$emcnt2 = 0;
		$emcnt3 = 0;
		$emcnt4 = 0;

		foreach $line (@{today_hot_list.$sccd}){
			@atemp = split(/\//, $line);
			if($atemp[2] eq "$tccd"){
				@etemp = split(/_q/,$line);
				if($etemp[1] eq '1_hot'){
					push(@equadht1,$atemp[3]);
					$emcnt1++;
				}elsif($etemp[1] eq '2_hot'){
					push(@equadht2,$atemp[3]);
					$emcnt2++;
				}elsif($etemp[1] eq '3_hot'){
					push(@equadht3,$atemp[3]);
					$emcnt3++;
				}elsif($etemp[1] eq '4_hot'){
					push(@equadht4,$atemp[3]);
					$emcnt4++;
				}
			}
		}
	
		for($qno = 1; $qno < 5; $qno++){	# cycle quad 1 to 4
			$gtemp = 'dquadht'."$qno";
			@dname = @{$gtemp};
			$gtemp = 'dmcnt'."$qno";
			$dcnt  = ${$gtemp};
			$gtemp = 'equadht'."$qno";
			@ename = @{$gtemp};
			$gtemp  = 'emcnt'."$qno";
			$ecnt = ${$gtemp};
#
#--- specify a file from today's list, and find two previous data list.
#--- if there is not, drop from the hot pix file list
#
			for($i = 0; $i < $ecnt; $i++){
				$file3 = $ename[$i];		
				$ccnt = 0;			
				OUTER:				
				foreach $comp (@dname){		
					if($file3 eq $comp){	
						last OUTER;
					}
					$ccnt++;
				}
#
#--- if there are three files find a hot pix
#
				if($ccnt > 1){			
					$file2 = $dname[$ccnt-1];	
					$file1 = $dname[$ccnt-2];
					$out_file = 'hot_data_list';

					find_bad_pix();		# check 3 files for hot pix
				}
			}
		}
	}
}

###########################################################################
### find_bad_pix:  find bad pixels                                     ####
###########################################################################

sub find_bad_pix{


	@x1    = ();
	@y1    = ();
	@line1 = ();
	$cnt1  = 0;

	open(FH,"$house_keeping/Defect/$tccd/$file1");
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/,$_);
		push(@x1,$atemp[0]);
		push(@y1,$atemp[1]);
		push(@line1,$_);
		$cnt1++;
	}
	close(FH);
	
	@x2    = ();
	@y2    = ();
	@line2 = ();
	$cnt2  = 0;

	open(FH,"$house_keeping/Defect/$tccd/$file2");
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/,$_);
		push(@x2,$atemp[0]);
		push(@y2,$atemp[1]);
		push(@line2,$_);
		$cnt2++;
	}
	close(FH);
#
#--- comparing first two files to see whether there are same pixels listed
#--- if they do, save the information $cnt_s will be > 0 if the results are positive
#
	@x_save    = ();			
	@y_save    = ();		
	@line_save = ();	
	$cnt_s     = 0;		

	OUTER:
	for($i1 = 0; $i1 <= $cnt1; $i1++){
		for($i2 = 0; $i2 <= $cnt2; $i2++){
			if($x1[$i1] == $x2[$i2] && $y1[$i1] == $y2[$i2] && $x1[$i1] ne ''){
				push(@x_save, $x1[$i1]);
				push(@y_save, $y1[$i1]);
				push(@line_save,$line1[$i1]);
				$cnt_s++;
				next OUTER;
			}
		}
	}

	if($cnt_s > 0){
		@x3    = ();
		@y3    = ();
		@line3 = ();
		$cnt3  = 0;

		open(FH,"$house_keeping/Defect/$tccd/$file3");
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/,$_);
			push(@x3,$atemp[0]);
			push(@y3,$atemp[1]);
			push(@line3,$_);
			$cnt3++;
		}
		close(FH);
#
#--- here we compare the pix listed in first two files to those of the third file
#
		@x_conf    = ();	
		@y_conf    = ();	
		@line_conf = ();
#
#--- if the results are positive, $cnt_f > 0
#
		$cnt_f  = 0;		
		OUTER:
		for($i1 = 0; $i1 <= $cnt_s; $i1++){
			for($i3 = 0; $i3 <= $cnt3; $i3++){
				if($x_save[$i1] == $x3[$i3] && $y_save[$i1] == $y3[$i3]
					&& $x_save[$i1] ne ''){
					push(@x_conf, $x_save[$i1]);
					push(@y_conf, $y_save[$i1]);
					push(@line_conf, $line_save[$i1]);
					$cnt_f++;
					next OUTER;
				}
			}
		}

		if($cnt_f > 0){		# put the warm pixel information into $out_file
			for($ip = 0; $ip <= $cnt_f; $ip++){
				@atemp    = split(/\s+/,$line_conf[$ip]);
				@btemp    = split(/T/,$atemp[3]);
				@ctemp    = split(/-/,$btemp[0]);
				@dtemp    = split(/:/,$btemp[1]);
				$modtime1 = "$ctemp[0]"."$ctemp[1]"."$ctemp[2]";
				$modtime  = "$modtime1".'.'."$dtemp[0]"."$dtemp[1]"."$dtemp[2]";
				$qno1     = $qno - 1;

				if($x_conf[$ip] =~ /\d/){
					push(@{$out_file}, "$tccd:$qno1:$modtime:$x_conf[$ip]:$y_conf[$ip]");
				}
			}
		}
	}

	$first    = shift(@{$out_file});		# remove duplicated lines
	@new_data = ("$first");

	OUTER:
	foreach $ent (@{$out_file}){
		foreach $comp (@new_data){
			if($ent eq $comp){
				next OUTER;
			}
		}
		push(@new_data,$ent);
	}
	@{$out_file} = @new_data;
}


#################################################################
### add_to_list: adding bad pixels to lists                  ####
#################################################################

sub add_to_list {

#
#--- find out which data are currently in the output directory
#
	$temp_wdir = `ls $web_dir/Disp_dir`;
	@temp_wdir_list = split(/\s+/, $temp_wdir);
	@dir_ccd  = ();
	@dir_hccd = ();
	@dir_col  = ();
	@dir_hcol = ();
	foreach $ent (@temp_wdir_list){
#
#--- warm ccd lists
#
		@atemp = split(//, $ent);

		if($atemp[0] eq 'c' && $atemp[1] eq 'c'){
			push(@dir_ccd, $ent);
		}elsif($atemp[0] eq 'c' && $atemp[1] eq 'o'){
			push(@dir_col, $ent);
		}elsif($atemp[0] eq 'h' && $atemp[2] eq 'c'){
			push(@dir_hccd, $ent);	# hot ccd list
		}elsif($atemo[0] eq 'h' && $atemp[2] eq 'o'){
			push(@dir_hcol, $ent);
		}
#
#--- if today* lists are there,
#
		@btemp = split(/_/, $ent);
		if($btemp[0] eq 'today'){
			@ctemp = split(//, $btemp[2]);
#
#--- make sure that it is a correct one
#
			if($ctemp[0] eq 'c' && $ctemp[1] eq 'c'){
				@dtemp = split(/ccd/,$btemp[2]);
#
#--- only when there is today's data exist.
#
				if(${tdycnt.$dtemp[1]} > 0){
					system("rm $web_dir/Disp_dir/$ent");
				}
			}
		}
	}
#
#---  warm pix case
#
	@in_file = @warm_data_list;
	
	$nchk = 0;
	foreach (@in_file){
		$nchk++;
	}
	if($nchk > 0){
		for($it = 0; $it < 10; $it++){
			@{temp_ccd.$it} = ();
			${winuse.$it} = 0;
		}
		foreach $ent (@in_file){
			@dat_line = split(/:/, $ent);
			@dtemp = split(/CCD/, $dat_line[0]);
			$iccd = $dtemp[1];
			$quad = $dat_line[1];
			$xpos = $dat_line[4] + 256*$quad;
			$ypos = $dat_line[5];
			$line = "$xpos.$ypos";
			push(@{temp_ccd.$iccd},$line);
			${winuse.$iccd}++;
		}

		$switch = 'warm';
		print_bad_pix_data();			# print new output files
	}
#
#--- hot pix case
#
	@in_file = @hot_data_list;
	$nchk = 0;
	foreach (@in_file){
		$nchk++;
	}
	if($nchk > 0){
		for($it = 0; $it < 10; $it++){
			@{temp_ccd.$it} = ();
			${hinuse.$it} = 0;
		}
		foreach $ent (@in_file){
			@dat_line = split(/:/, $ent);
			@dtemp = split(/CCD/, $dat_line[0]);
			$iccd = $dtemp[1];
			$quad = $dat_line[1];
			$xpos = $dat_line[4] + 256*$quad;
			$ypos = $dat_line[5];
			$line = "$xpos.$ypos";
			push(@{temp_ccd.$iccd},$line);
			${hinuse.$iccd}++;
		}

		$switch = 'hot';
		print_bad_pix_data();
	}
}

##############################################################
### print_bad_pix_data: pinring out bad data list          ###
##############################################################

sub print_bad_pix_data{
	OUTER:
	for($ip = 0; $ip < 10; $ip++){
		if(${tdycnt.$ip} == 0){
			next OUTER;				# if there is no data for this date
		}						# skip this ccd

		if($switch eq 'warm'){
			$count = ${winuse.$ip};
		}elsif($switch eq 'hot'){
			$count = ${hinuse.$ip};
		}
#
#--- read current warm/hot pix list
#
		if($switch eq 'warm'){
			open(FH, "$web_dir/Disp_dir/ccd$ip");	
		}elsif($switch eq 'hot'){
			open(FH, "$web_dir/Disp_dir/hccd$ip");
		}

		$cnt = 0; 
		@x_save = ();
		@y_save = ();
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/, $_);
			@btemp = split(//, $_);
			if($btemp[0] ne '#'){
				push(@x_save, $atemp[0]);
				push(@y_save, $atemp[1]);
				$cnt++;
			}
		}
		close(FH);

		if($switch eq 'warm'){
#
#--- if new data is coming remove  old ones
#
			OUTER:
			foreach $ent (@dir_ccd){	
				$name = "ccd$ip";	
				if($name eq $ent){
					open(TEMP, ">>$web_dir/Disp_dir/hist_ccd$ip");
					@ctemp = split(/:/, $date_obs);
					$ctemp[1]--;
					$yestdate = "$ctemp[0]:$ctemp[1]";
					print TEMP "#$yestdate\n";
					close(TEMP);
					system("cat $web_dir/Disp_dir/ccd$ip >> $web_dir/Disp_dir/hist_ccd$ip");
					system("rm $web_dir/Disp_dir/ccd$ip");
					last OUTER;
				}
			}
		}elsif($switch eq 'hot'){
			OUTER:
			foreach $ent (@dir_hccd){
				$name = "hccd$ip";
				if($name eq $ent){
					open(TEMP2, ">>$web_dir/Disp_dir/hist_hccd$ip");
					@ctemp = split(/:/, $date_obs);
					$ctemp[1]--;
					$yestdate = "$ctemp[0]:$ctemp[1]";
					print TEMP2 "#$yestdate\n";
					close(TEMP2);
					system("cat $web_dir/Disp_dir/hccd$ip >> $web_dir/Disp_dir/hist_hccd$ip");
					system("rm $web_dir/Disp_dir/hccd$ip");
					last OUTER;
				}
			}
		}
#
#--- if there are bad pixels in today's list, check whether bad pixels in yesterday's list
#
		if($count > 0){						
			if($cnt > 0){				
				@x_hold = ();
				@y_hold = ();
				@x_new  = ();
				@y_new  = ();
				@x_imp  = ();
				@y_imp  = ();
				$hcnt = 0;
				$ncnt = 0;
				$icnt = 0;
#
#---  compare new data and old ones
#				
				OUTER:
				foreach $ent (@{temp_ccd.$ip}){			
					@pos = split(/\./,$ent);
					for($j = 0; $j < $cnt; $j++){
						if($pos[0] == $x_save[$j] 
				    		&& $pos[1] == $y_save[$j]){
#
#--- if new data exist in old one keep them
#
							push(@x_hold, $pos[0]);	
							push(@y_hold, $pos[1]);
							$hcnt++;
							next OUTER;
						}
					}
#
#--- if the new data are actually new bad pix, put them in here
#
					push(@x_new, $pos[0]);
					push(@y_new, $pos[1]);
					$ncnt++;
				}	
				OUTER:
				for($j = 0; $j < $cnt; $j++){
#
#--- check whether bad pix disappeared or not. if it does, put it in
#
					foreach $ent (@{temp_ccd.$ip}){		
						@pos = split(/\./,$ent);	
						if($pos[0] == $x_save[$j] 
			    			&& $pos[1] == $y_save[$j]){
							next OUTER;
						}
					}
					if($x_save[$j] =~ /\d/ && $y_save[$j] =~/\d/){
						push(@x_imp, $x_save[$j]);
						push(@y_imp, $y_save[$j]);
						$icnt++;
					}
				}	

				if($ncnt > 0){
#
#--- print out data; warm case
#
					if($switch eq 'warm'){		
						open(OUT,">$web_dir/Disp_dir/today_new_ccd$ip");
						if($ip == 5){
							$today_new_bad_pix5 += $ncnt;	# count # of new bad pix
						}elsif($ip == 7){
							$today_new_bad_pix7 += $ncnt;
						}else{
							$today_new_bad_pix  += $ncnt;
						}
#
#--- print out data; hot case
#
					}elsif($switch eq 'hot'){
						open(OUT,">$web_dir/Disp_dir/today_new_hccd$ip");
						if($ip == 5){
							$today_new_hot_pix5 += $ncnt;
						}elsif($ip == 7){
							$today_new_hot_pix7 += $ncnt;
						}else{
							$today_new_hot_pix  += $ncnt;
						}
					}
					print OUT "#Date: $dtime\n";
					for($k = 0; $k< $ncnt; $k++){
						print OUT "$x_new[$k]\t$y_new[$k]\n";
					}
					close(OUT);
					if($switch eq 'warm'){
						system("cat $web_dir/Disp_dir/today_new_ccd$ip >> $web_dir/Disp_dir/new_ccd$ip");
					}elsif($switch eq 'hot'){
						system("cat $web_dir/Disp_dir/today_new_hccd$ip>> $web_dir/Disp_dir/new_hccd$ip");
					}

					if($hcnt == 0){
						if($switch eq 'warm'){
							open(OUT2,">$web_dir/Disp_dir/ccd$ip");
						}elsif($switch eq 'hot'){
							open(OUT2,">$web_dir/Disp_dir/hccd$ip");
						}
						print OUT2 "#Date: $dtime\n";
						for($k = 0; $k< $ncnt; $k++){
							print OUT2 "$x_new[$k]\t$y_new[$k]\n";
						}
						close(OUT2);
					}
				}

				if($hcnt > 0){
#
#--- count # of existing bad pix
#
					if($switch eq 'warm'){
						open(OUT,">$web_dir/Disp_dir/ccd$ip");
					}elsif($switch eq 'hot'){
						open(OUT,">$web_dir/Disp_dir/hccd$ip");
					}
					for($k = 0; $k< $hcnt; $k++){
						print OUT "$x_hold[$k]\t$y_hold[$k]\n";
					}
					close(OUT);

					if($ncnt > 0){
						if($switch eq 'warm'){
							open(OUT2,">>$web_dir/Disp_dir/ccd$ip");
						}elsif($switch eq 'hot'){
							open(OUT2,">>$web_dir/Disp_dir/hccd$ip");
						}
						for($k = 0; $k< $ncnt; $k++){
							print OUT2 "$x_new[$k]\t$y_new[$k]\n";
						}
						close(OUT2);
					}
				}

				if($icnt > 0){	
#
#--- count # of improved bad pix
#
					if($switch eq 'warm'){
						open(OUT,">$web_dir/Disp_dir/today_imp_ccd$ip");
						if($ip == 5){
							$today_imp_bad_pix5 += $icnt;
						}elsif($ip == 7){
							$today_imp_bad_pix7 += $icnt;
						}else{
							$today_imp_bad_pix  += $icnt;
						}
					}elsif($switch eq 'hot'){
						open(OUT,">$web_dir/Disp_dir/today_imp_hccd$ip");
						if($ip == 5){
							$today_imp_hot_pix5 += $icnt;
						}elsif($ip == 7){
							$today_imp_hot_pix7 += $icnt;
						}else{
							$today_imp_hot_pix  += $icnt;
						}
					}
					print OUT "#Date: $dtime\n";
					for($k = 0; $k< $icnt; $k++){
						print OUT "$x_imp[$k]\t$y_imp[$k]\n";
					}
					close(OUT);

					if($switch eq 'warm'){
						system("cat $web_dir/Disp_dir/today_imp_ccd$ip >> $web_dir/Disp_dir/imp_ccd$ip");
 					}elsif($switch eq 'hot'){
						system("cat $web_dir/Disp_dir/today_imp_hccd$ip >> $web_dir/Disp_dir/imp_hccd$ip");
					}
				}
			}else{
#
#--- for the case creating new bad pix list
#
				$tcnt = 0;
				foreach (@{temp_ccd.$ip}){
					$tcnt++;
				}
				if($tcnt > 0){
					if($switch eq 'warm'){
						open(OUT,">$web_dir/Disp_dir/today_new_ccd$ip");
					}elsif($switch eq 'hot'){
						open(OUT,">$web_dir/Disp_dir/today_new_hccd$ip");
					}
					print OUT "#Date: $dtime\n";
					foreach $ent (@{temp_ccd.$ip}){
						@pos = split(/\./,$ent);
						print OUT  "$pos[0]\t$pos[1]\n";	
					}
					close(OUT);
					if($switch eq 'warm'){
						system("cat $web_dir/Disp_dir/today_new_ccd$ip >> $web_dir/Disp_dir/new_ccd$ip");
					}elsif($switch eq 'hot'){
						system("cat $web_dir/Disp_dir/today_new_hccd$ip >> $web_dir/Disp_dir/new_hccd$ip");
					}

					if($switch eq 'warm'){
						open(OUT2,">$web_dir/Disp_dir/ccd$ip");
						if($ip == 5){
							$today_new_bad_pix5 += $tcnt;
						}elsif($ip == 7){
							$today_new_bad_pix7 += $tcnt;
						}else{
							$today_new_bad_pix  += $tcnt;
						}
					}elsif($switch eq 'hot'){
						open(OUT2,">$web_dir/Disp_dir/hccd$ip");
						if($ip == 5){
							$today_new_hot_pix5 += $tcnt;
						}elsif($ip == 7){
							$today_new_hot_pix7 += $tcnt;
						}else{
							$today_new_hot_pix  += $tcnt;
						}
					}
					foreach $ent (@{temp_ccd.$ip}){
						@pos = split(/\./,$ent);
						print OUT2 "$pos[0]\t$pos[1]\n";	
					}
					close(OUT2);
				}
			}
		}else{						
#
#--- this is a case, no new data, but prev bad pix exists
#
			if($cnt > 0){
				if($switch eq 'warm'){
		     			open(OUT,">$web_dir/Disp_dir/today_imp_ccd$ip");
		     			if($ip == 5){
			      			$today_imp_bad_pix5 += $cnt;
		     			}elsif($ip == 7){
			      			$today_imp_bad_pix7 += $cnt;
		     			}else{
			      			$today_imp_bad_pix  += $cnt;
		    			}
		     		}elsif($switch eq 'hot'){
			     		open(OUT,">$web_dir/Disp_dir/today_imp_hccd$ip");
		     			if($ip == 5){
			      			$today_imp_hot_pix5 += $cnt;
		     			}elsif($ip == 7){
			      			$today_imp_hot_pix7 += $cnt;
		     			}else{
			      			$today_imp_hot_pix  += $cnt;
		    			}
		     		}
		     		print OUT "#Date: $dtime\n";
		     		for($k = 0; $k< $cnt; $k++){
			      		print OUT "$x_save[$k]\t$y_save[$k]\n";
		     		}
		     		close(OUT);
				if($switch eq 'warm'){
					system("cat $web_dir/Disp_dir/today_imp_ccd$ip >> $web_dir/Disp_dir/imp_ccd$ip");
				}elsif($switch eq 'hot'){
					system("cat $web_dir/Disp_dir/today_imp_hccd$ip >> $web_dir/Disp_dir/imp_hccd$ip");
				}
			}
 		}
	}
}

#######################################################################
###  find_bad_col: find bad columns                                 ###
#######################################################################

sub find_bad_col{
        $asum  = 0;
        $asum2 = 0;
        $fcnt = 0;
#
#--- make an average of averaged column value average of column is caluculated in sub extract.
#
        for($icol = 1; $icol <= 256; $icol++){		
                if($cnt[$icol] > 0){			
                        $avg[$icol] = $sum[$icol]/$cnt[$icol];
                        $asum  += $avg[$icol];
                        $asum2 += $avg[$icol] * $avg[$icol];
                        $fcnt++;
                }
        }
	if($fcnt > 0){
        	$cavg = $asum/$fcnt;
        	$std = sqrt($asum2/$fcnt - $cavg * $cavg);
        	$limit = $cavg + $col_factor * $std;			# setting limits
	
        	$outdir_name  = "$house_keeping/Defect/CCD"."$ccd_id".'/'."$head".'_col';
	
        	open(OUT,">>$outdir_name");
        	for($icol = 1; $icol <= 256; $icol++){
#
#--- compare to a global average
#
                	if($avg[$icol] > $limit){		

				comp_to_local_avg_col();	# compare to a local average

				if($avg[$icol] > $local_limit){
					$pind = 0;
#
#--- compare to existing bad col
#
				 	OUTER:
					foreach $bcol (@{col_ccd.$ccd_id}){
						if($icol == $bcol){
							$pind++;
							last OUTER;	
						}
					}
					if($pind == 0){
						$icol += $xlow;
                        			print OUT  "$icol\n";
					}
				}
                	}					# add to the bad column list
        	}
        	close(OUT);
	}
}

################################################################################
### comp_to_local_avg_col: compute  a local average col values          ########
################################################################################

sub comp_to_local_avg_col{
	$llow  = $icol - 5;			# setting a local range
	$lhigh = $icol + 5;

	if($llow < 1){				# setting lower range
		$diff  = $xlow - $llow;
		$lhigh += $diff;
		$llow   = $xlow;
	}

	if($lhigh > 256){			# setting higher range
		$diff =  $lhigh - $xhigh;
		$llow -= $diff;
		$lhigh = $xhigh;
	}

	$lsum = 0;
	$lsum2 = 0;
	$lcnt = 0;
	for($j = $llow; $j <= $lhigh; $j++){
		$lsum += $avg[$j];
		$lsum2 += $avg[$j]*$avg[$j];
		$lcnt++;
	}
	$local_limit = $limit;
	if($lcnt > 0){
		$lavg = $lsum/$lcnt;
		$lstd = sqrt($lsum2/$lcnt - $lavg*$lavg);
		$local_limit = $lavg + $col_factor*$lstd;
	}
}
		

################################################################################
### prep_col: preparing bad col test                                         ###
################################################################################

sub prep_bad_col {
#
#--- check the name of the last new_col lists
#
	$temp_wdir = `ls $web_dir/Disp_dir/today_new_col*`;
	@temp_wdir_list = split(/\s+/, $temp_wdir);
	@today_bad_col = ();
	foreach $ent (@temp_wdir_list){
		@ctemp = split(/col/, $ent);
		push(@today_bad_col, $ctemp[1]);
	}
#
#--- check the name of the last imp_col lists
#
	$temp_wdir = `ls $web_dir/Disp_dir/today_imp_col*`;
	@temp_wdir_list = split(/\s+/, $temp_wdir);
	@today_imp_col = ();
	foreach $ent (@temp_wdir_list){
		@ctemp = split(/col/, $ent);
		push(@today_imp_col, $ctemp[1]);
	}
#
#--- check the name of the last col lists
#
	$temp_wdir = `ls $web_dir/Disp_dir/col*`;
	@temp_wdir_list = split(/\s+/, $temp_wdir);
	@tcol_list = ();
	foreach $ent (@temp_wdir_list){
		@ctemp = split(/col/, $ent);
		push(@tcol_list, $ctemp[1]);
	}
#
#--- clean up old memories
#
	for($m = 0; $m < 10; $m++){
		@{col_data.$m} = ();
		${col_cnt.$m} = 0;
	}
#
#--- if there were bad_col lists
#
	foreach $ent (@today_bad_col){		
		if(${tdycnt.$ent} > 0){
			system("cat $web_dir/Disp_dir/today_new_col$ent >> $web_dir/Disp_dir/new_col$ent");
			system("rm  $web_dir/Disp_dir/today_new_col$ent");
		}
	}

	foreach $ent (@today_imp_col){
		if(${tdycnt.$ent} > 0){
			system("cat $web_dir/Disp_dir/today_imp_col$ent >> $web_dir/Disp_dir/imp_col$ent"); 
			system("rm  $web_dir/Disp_dir/today_imp_col$ent");
		}
	}
#
#--- read the last col list data
#
	foreach $ent (@tcol_list){		
		if(${tdycnt.$ent} > 0){
			@{col_data.$ent} = ();
			${col_cnt.$ent} = 0;
			open(IN, "$web_dir/Disp_dir/col$ent");

			OUTER:
			while(<IN>){
				chomp $_;
				@ctemp = split(//, $_);
				if($ctemp[0] eq '#'){
					next OUTER;
				}
				push(@{col_data.$ent}, $_);
				${col_cnt.$ent}++;
			}
			close(IN);

			system("rm $web_dir/Disp_dir/col$ent");
		}
	}
}

################################################################################
### chk_bad_col: find and print bad columns                                  ###
################################################################################


sub chk_bad_col {

	OUTER:
	for($k = 0; $k < 10; $k++){
		if(${tdycnt.$k} == 0){			# only when today's data exists
			next OUTER;
		}

		$temp_wdir = `ls $house_keeping/Defect/CCD$k/*col`;
		@temp_wdir_list = split(/\s+/, $temp_wdir);
		@col_list = ();
		$kcnt = 0;
		foreach $ent (@temp_wdir_list){
			push(@col_list, $ent);
			$kcnt++;
		}
#
#--- if there are 3 bad col lists, use them to find bad col candidates
#
		if( $kcnt > 2){				
			$n = 0;				
			$start = $kcnt - 1;
			$end   = $kcnt - 3;
			for($m = $start; $m >= $end; $m--){
				@{list.$n} = ();
				if($m == $start){
					@atemp = split(/acis/, $col_list[$m]);
					@btemp = split(/_/, $atemp[1]);
					$time_form1 = $btemp[0];

					conv_time();		  # getting readable time format

					@ttemp = split(/:/, $time_form2);
					$today_time = "$ttemp[0]:$ttemp[1]";
				}
#
#--- bad_col of the m-th file
#
				open(FH, "$col_list[$m]");
				while(<FH>){
					chomp $_;
					push(@{list.$n}, $_);
				}
				close(FH);
				$n++;
			}
			@two_list = ();
			$test = 0;
#
#--- compare the first two lists
#
			OUTER:
			foreach $ent (@{list.0}){
				foreach $comp (@{list.1}){
					if($ent == $comp){
						push(@two_list, $ent);
						$test++;
						next OUTER;
					}
				}
			}
			
			@{bad_col_list.$k} = ();
			${bcnt.$k} = 0;
#
#--- if there are candidates, try on the thrid file
#
			if($test > 0){				
				$chk = 0;			
				@temp_list = ();
				OUTER:			
				foreach $ent (@two_list){
					foreach $comp (@{list.2}){
						if($ent == $comp){
							push(@temp_list, $ent);
							$chk++;
							next OUTER;
						}
					}
				}
#
#--- remove duplicates
#
				if($chk > 0){			
					$first = shift(@temp_list);
					${bcnt.$k}++;
					@new = ($first);
					@{bad_col_list.$k} = @{new};
					OUTER:
					foreach $ent (@temp_list){
						foreach $comp (@new){
							if($ent == $comp){
								next OUTER;
							}
						}
						push(@new, $ent);
						push(@{bad_col_list.$k}, $ent);
						${bcnt.$k}++;
					}
				}
			}
		}
	}
}

########################################################################################
########################################################################################
########################################################################################

sub print_bad_col{
	OUTER:
	for($k = 0; $k < 10; $k++){

		if(${tdycnt.$k} == 0){			# only when today's data exists
			next OUTER;
		}
#
#--- if there are new bad cols, then...
#
		if(${bcnt.$k} > 0){
#
#--- if there are currently bad cols, then...
#
			if(${col_cnt.$k} > 0){
				@bad_col_new = ();
				@bad_col_imp = ();
				@col_hold = ();
				$chk_col_new = 0;
				$chk_col_imp = 0;
				$chk_col_hld = 0;

				OUTER:
				foreach $ent (@{bad_col_list.$k}){
					@ctemp = split(//, $ent);
					if($ctemp[0] eq '#'){
						next OUTER;
					}
					foreach $comp (@{col_data.$k}){
						if($ent == $comp){
							push(@col_hold, $ent);
							$chk_col_hld++;
							next OUTER;
						}
					}
					push(@bad_col_new, $ent);
					$chk_col_new++;
				}

				OUTER:
				foreach $ent (@{col_data.$k}){
					@ctemp = split(//, $ent);
					if($ctemp[0] eq '#'){
						next OUTER;
					}
					foreach $comp (@{bad_col_list.$k}){
						if($ent == $comp){
							next OUTER;
						}
					}
					push(@bad_col_imp, $ent);
					$chk_col_imp++;
				}

			
				if($chk_col_new > 0){
#
#--- count # of new col for plots
#
					if($k == 5){		
						$today_new_bad_col5 += $chk_col_new;
					}elsif($k == 7){
						$today_new_bad_col7 += $chk_col_new;
					}else{
						$today_new_bad_col += $chk_col_new;
					}
	
					open(OUT, ">$web_dir/Disp_dir/today_new_col$k");
					print OUT "#Date: $dtime\n";
					foreach $ent (@bad_col_new){
						print OUT "$ent\n";
					}
					close(OUT);
					if($chk_col_hld == 0){
						open(OUT2,">$web_dir/Disp_dir/col$k");
						print OUT2 "#Date: $dtime\n";
						foreach $ent (@bad_col_new){
							print OUT2 "$ent\n";
						}
						close(OUT2);
					}
				}
	
				if($chk_col_hld > 0){
					open(OUT,">$web_dir/Disp_dir/col$k");
					foreach $ent (@col_hold){
						print OUT "$ent\n";
					}
					close(OUT);
		
					if($chk_col_new > 0){
						open(OUT2, ">>$web_dir/Disp_dir/col$k");
						foreach $ent (@bad_col_new){
							print OUT2 "$ent\n";
						}
						close(OUT2);
					}
				}
	
				if($chk_col_imp > 0){
#
#--- count # of imp col for plots
#
					if($k == 5){		
						$today_imp_bad_col5 += $chk_col_imp;
					}elsif($k == 7){
						$today_imp_bad_col7 += $chk_col_imp;
					}else{
						$today_imp_bad_col += $chk_col_imp;
					}
	
					open(OUT, ">$web_dir/Disp_dir/today_imp_col$k");
					print OUT "#Date: $dtime\n";
					foreach $ent (@bad_col_imp){
						print OUT "$ent\n";
					}
					close(OUT);
				}
			}else{
				if(${bcnt.$k} > 0){
		    			open(OUT, ">$web_dir/Disp_dir/today_new_col$k");
					print OUT "#Date: $dtime\n";
					foreach $ent (@{bad_col_list.$k}){
						print OUT "$ent\n";	
					}
					close(OUT);

		    			open(OUT2, ">$web_dir/Disp_dir/col$k");
					print OUT2 "#Date: $dtime\n";
					foreach $ent (@{bad_col_list.$k}){
						print OUT2 "$ent\n";	
					}
					close(OUT2);
#
#--- count # of new col for plots
#
					if($k == 5){
						$today_new_bad_col5 += ${bcnt.$k};
					}elsif($k == 7){
						$today_new_bad_col7 += ${bcnt.$k};
					}else{
						$today_new_bad_col  += ${bcnt.$k};
					}
				}
			}
		}else{
			if(${col_cnt.$k} > 0){
				open(OUT,">$web_dir/Disp_dir/today_imp_col$k");
				print OUT "#Date: $dtime\n";
				foreach $ent (@{col_data.$k}){
					print OUT "$ent\n";
				}
				close(OUT);

				system("rm $web_dir/Disp_dir/col$k");
#
#--- count # of imp col for plots
#
				if($k == 5){		
					$today_imp_bad_col5 += ${col_cnt.$k};
				}elsif($k == 7){
					$today_imp_bad_col7 += ${col_cnt.$k};
				}else{
					$today_imp_bad_col  += ${col_cnt.$k};
				}
			}
		}
	}
}

########################################################################
### convert time formart: change time format to yyyy:dddd:hh:mm:ss  ####
########################################################################

sub conv_time{
	$time_form2 = `/home/ascds/DS.release/bin/axTime3 $time_form1 u s t d`;
}


#################################################################################
### chk_old_data: find data older than 30 days (7 days) and move to Save      ###
#################################################################################

sub chk_old_data{
	$day30 = 2592000;
	$day7  = 604800;

	($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
	$year = $uyear + 1900;
	$today = "$year:$uyday:$uhour:$umin:$usec";
	$today_chk = `/home/ascds/DS.release/bin/axTime3 $today t d u s`;
	
	$month_ago = $today_chk - $day30;
#	$week_ago  = $today_chk - $day7;

	for($k = 0; $k < 10; $k++){
		$temp_wdir = `ls $house_keeping/Defect/CCD$k/*`;
		@temp_wdir_list = split(/\s+/, $temp_wdir);
		foreach $ent (@temp_wdir_list){
			@atemp = split(/acis/, $ent);
			@btemp = split(/_/, $atemp[1]);
			if($btemp[0] < $month_ago){
#			if($btemp[0] < $week_ago){
				system("mv $ent $old_dir/Old_data/CCD$k/.");
				system("gzip $old_dir/Old_data/CCD$k/$ent");
			}
		}
	}
}

##############################################################################
### count_new_imp: count numbers of new and improved bad pixels           ####
##############################################################################

sub count_new_imp {

	conv_time_dom($dtime);		# change time to dom format

	$bad_pix_cnt  = 0;
	$bad_pix_cnt5 = 0;
	$bad_pix_cnt7 = 0;
#
#--- bad pixel case
#
	open(IN, "$web_dir/Disp_dir/bad_pix_cnt");	
#
#--- get the previous total bad pix counts for front side CCD
#
	while(<IN>){				
		chomp $_;
		@atemp = split(/:/, $_);
		$bad_pix_cnt = $atemp[3];
	}
	close(IN);

	$bad_pix_cnt += $today_new_bad_pix;			
	$bad_pix_cnt -= $today_imp_bad_pix;			# new total bad pix counts

	open(IN, "$web_dir/Disp_dir/bad_pix_cnt5");		# same as above, but for ccd 5
	while(<IN>){
		chomp $_;
		@atemp = split(/:/, $_);
		$bad_pix_cnt5 = $atemp[3];
	}
	close(IN);

	$bad_pix_cnt5 += $today_new_bad_pix5;
	$bad_pix_cnt5 -= $today_imp_bad_pix5;

	open(IN, "$web_dir/Disp_dir/bad_pix_cnt7");		# smae as above, but for ccd 7
	while(<IN>){
		chomp $_;
		@atemp = split(/:/, $_);
		$bad_pix_cnt7 = $atemp[3];
	}
	close(IN);

	$bad_pix_cnt7 += $today_new_bad_pix7;
	$bad_pix_cnt7 -= $today_imp_bad_pix7;
#
#--- new pix
#
	open(OUT,">>$web_dir/Disp_dir/new_bad_pix_save");	# newly appeared bad pix: imaging ccds
	print OUT "$dtime:$today_dom:$today_new_bad_pix\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/new_bad_pix_save5");	# newly appeared bad pix: ccd 5
	print OUT "$dtime:$today_dom:$today_new_bad_pix5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/new_bad_pix_save7");	# newly appeared bad pix: ccd 7
	print OUT "$dtime:$today_dom:$today_new_bad_pix7\n";
	close(OUT);
#
#--- improved pix
#
	open(OUT,">>$web_dir/Disp_dir/imp_bad_pix_save");	# improved bad pix: imaging ccds
	print OUT "$dtime:$today_dom:$today_imp_bad_pix\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/imp_bad_pix_save5");	# improved bad pix: ccd 5
	print OUT "$dtime:$today_dom:$today_imp_bad_pix5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/imp_bad_pix_save7");	# improved bad pix: ccd 7
	print OUT "$dtime:$today_dom:$today_imp_bad_pix7\n";
	close(OUT);
#
#--- total bad pix
#
	open(OUT,">>$web_dir/Disp_dir/bad_pix_cnt");		# total bad pix: imaging ccds
	print OUT "$dtime:$today_dom:$bad_pix_cnt\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/bad_pix_cnt5");		# total bad pix: ccd 5
	print OUT "$dtime:$today_dom:$bad_pix_cnt5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/bad_pix_cnt7");		# total bad pix: ccd 7
	print OUT "$dtime:$today_dom:$bad_pix_cnt7\n";
	close(OUT);

#
#--- hot pixel case
#

	$hot_pix_cnt  = 0;
	$hot_pix_cnt5 = 0;
	$hot_pix_cnt7 = 0;
#
#--- get the previous total hot pix counts for front side CCD
#
	open(IN, "$web_dir/Disp_dir/hot_pix_cnt");	
	while(<IN>){					
		chomp $_;
		@atemp = split(/:/, $_);
		$hot_pix_cnt = $atemp[3];
	}
	close(IN);

	$hot_pix_cnt += $today_new_hot_pix;
	$hot_pix_cnt -= $today_imp_hot_pix;			# new total hot pix counts

	open(IN, "$web_dir/Disp_dir/hot_pix_cnt5");		# same as above, but for ccd 5
	while(<IN>){
		chomp $_;
		@atemp = split(/:/, $_);
		$hot_pix_cnt5 = $atemp[3];
	}
	close(IN);

	$hot_pix_cnt5 += $today_new_hot_pix5;
	$hot_pix_cnt5 -= $today_imp_hot_pix5;

	open(IN, "$web_dir/Disp_dir/hot_pix_cnt7");		# smae as above, but for ccd 7
	while(<IN>){
		chomp $_;
		@atemp = split(/:/, $_);
		$hot_pix_cnt7 = $atemp[3];
	}
	close(IN);

	$hot_pix_cnt7 += $today_new_hot_pix7;
	$hot_pix_cnt7 -= $today_imp_hot_pix7;
#
#--- new pix
#
	open(OUT,">>$web_dir/Disp_dir/new_hot_pix_save");	# newly appeared hot pix: imaging ccds
	print OUT "$dtime:$today_dom:$today_new_hot_pix\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/new_hot_pix_save5");	# newly appeared hot pix: ccd 5
	print OUT "$dtime:$today_dom:$today_new_hot_pix5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/new_hot_pix_save7");	# newly appeared hot pix: ccd 7
	print OUT "$dtime:$today_dom:$today_new_hot_pix7\n";
	close(OUT);
#
#--- improved pix
#
	open(OUT,">>$web_dir/Disp_dir/imp_hot_pix_save");	# improved hot pix: imaging ccds
	print OUT "$dtime:$today_dom:$today_imp_hot_pix\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/imp_hot_pix_save5");	# improved hot pix: ccd 5
	print OUT "$dtime:$today_dom:$today_imp_hot_pix5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/imp_hot_pix_save7");	# improved hot pix: ccd 7
	print OUT "$dtime:$today_dom:$today_imp_hot_pix7\n";
	close(OUT);
#
#--- total hot pix
#
	open(OUT,">>$web_dir/Disp_dir/hot_pix_cnt");		# total hot pix: imaging ccds
	print OUT "$dtime:$today_dom:$hot_pix_cnt\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/hot_pix_cnt5");		# total hot pix: ccd 5
	print OUT "$dtime:$today_dom:$hot_pix_cnt5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/hot_pix_cnt7");		# total hot pix: ccd 7
	print OUT "$dtime:$today_dom:$hot_pix_cnt7\n";
	close(OUT);

#
#--- col list count starts here
#
	
	$bad_col_cnt  = 0;
	$bad_col_cnt5 = 0;
	$bad_col_cnt7 = 0;

	open(IN, "$web_dir/Disp_dir/bad_col_cnt");		# get the previous total bad col counts
	while(<IN>){						# for front side CCD
		chomp $_;
		@atemp = split(/:/, $_);
		$bad_col_cnt = $atemp[3];
	}
	close(IN);

	$bad_col_cnt += $today_new_bad_col;
	$bad_col_cnt -= $today_imp_bad_col;			# new total bad col counts

	open(IN, "$web_dir/Disp_dir/bad_col_cnt5");		# same as above, but for ccd 5
	while(<IN>){
		chomp $_;
		@atemp = split(/:/, $_);
		$bad_col_cnt5 = $atemp[3];
	}
	close(IN);

	$bad_col_cnt5 += $today_new_bad_col5;
	$bad_col_cnt5 -= $today_imp_bad_col5;

	open(IN, "$web_dir/Disp_dir/bad_col_cnt7");		# smae as above, but for ccd 7
	while(<IN>){
		chomp $_;
		@atemp = split(/:/, $_);
		$bad_col_cnt7 = $atemp[3];
	}
	close(IN);

	$bad_col_cnt7 += $today_new_bad_col7;
	$bad_col_cnt7 -= $today_imp_bad_col7;
#
#--- new bad col
#
	open(OUT,">>$web_dir/Disp_dir/new_bad_col_save");	# newly appeared bad col: imaging ccds
	print OUT "$dtime:$today_dom:$today_new_bad_col\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/new_bad_col_save5");	# newly appeared bad col: ccd 5
	print OUT "$dtime:$today_dom:$today_new_bad_col5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/new_bad_col_save7");	# newly appeared bad col: ccd 7
	print OUT "$dtime:$today_dom:$today_new_bad_col7\n";
	close(OUT);
#
#--- improved col
#
	open(OUT,">>$web_dir/Disp_dir/imp_bad_col_save");	# improved bad col: imaging ccds
	print OUT "$dtime:$today_dom:$today_imp_bad_col\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/imp_bad_col_save5");	# improved bad col: ccd 5
	print OUT "$dtime:$today_dom:$today_imp_bad_col5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/imp_bad_col_save7");	# improved bad col: ccd 7
	print OUT "$dtime:$today_dom:$today_imp_bad_col7\n";
	close(OUT);
#
#--- total bad col
#
	open(OUT,">>$web_dir/Disp_dir/bad_col_cnt");		# total bad col: imaging ccds
	print OUT "$dtime:$today_dom:$bad_col_cnt\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/bad_col_cnt5");		# total bad col: ccd 5
	print OUT "$dtime:$today_dom:$bad_col_cnt5\n";
	close(OUT);

	open(OUT,">>$web_dir/Disp_dir/bad_col_cnt7");		# total bad col: ccd 7
	print OUT "$dtime:$today_dom:$bad_col_cnt7\n";
	close(OUT);
}


################################################################
### cov_time_dom: change date (yyyy:ddd) to dom             ####
################################################################

sub conv_time_dom {
	($input_time) = @_;
	@atemp = split(/:/, $input_time);
	$tyear = $atemp[0];
	$tyday = $atemp[1];

	$totyday = 365*($tyear - 1999);
	if($tyear > 2000){
		$totyday++;
	}
	if($tyear > 2004){
		$totyday++;
	}
	if($tyear > 2008){
		$totyday++;
	}
	if($tyear > 2012){
		$totyday++;
	}

	$today_dom = $totyday + $tyday - 202;
}

################################################################
### timeconv1: chnage sec time formant to yyyy:ddd:hh:mm:ss ####
################################################################

sub timeconv1 {
	($time) = @_;
	$normal_time = `/home/ascds/DS.release/bin/axTime3 $time u s t d`;
}

################################################################
### timeconv2: change: yyyy:ddd form to sec time formart    ####
################################################################

sub timeconv2 {
	($time) = @_;
	$sec_form_time = `/home/ascds/DS.release/bin/axTime3 $time t d u s`;
}


################################################################
### data_for_html: create data for web page display	   #####
################################################################

sub data_for_html{

	$temp_wdir      = `ls $web_dir/Disp_dir/`;	# find out what are in Disp_dir
	@temp_wdir_list = split(/\s+/, $temp_wdir);

	@ccd_list       = ();
	@col_list       = ();
	@today_new_ccd  = ();
	@today_imp_ccd  = ();
	@today_new_col  = ();
	@today_imp_col  = ();
	@hccd_list      = ();
	@hcol_list      = ();
	@today_new_hccd = ();
	@today_imp_hccd = ();
	@today_new_hcol = ();
	@today_imp_hcol = ();

	$ccd_cnt        = 0;
	$col_cnt        = 0;
	$tdy_imp        = 0;
	$tdy_new        = 0;
	$tdy_imp_col    = 0;
	$tdy_new_col    = 0;
	$hccd_cnt       = 0;
	$hcol_cnt       = 0;
	$htdy_imp       = 0;
	$htdy_new       = 0;
	$htdy_imp_col   = 0;
	$htdy_new_col   = 0;
#
#--- check which data are in the Disp_dir
#
	foreach $ent (@temp_wdir_list){	
		@atemp = split(/\d/, $ent);
#
#--- wam pix case
#
		if($atemp[0] eq 'ccd'){			# bad pix data
			push(@ccd_list, $ent);
			$ccd_cnt++;
		}elsif($atemp[0] eq 'col'){		# bad col data
			push(@col_list, $ent);
			$col_cnt++;
		}elsif($atemp[0] eq 'today_new_ccd'){	# new bad pix data
			push(@today_new_ccd, $ent);
			$tdy_new++;
		}elsif($atemp[0] eq 'today_imp_ccd'){	# imp pix data
			push(@today_imp_ccd, $ent);
			$tdy_imp++;
		}elsif($atemp[0] eq 'today_new_col'){	# new bad col data
			push(@today_new_col,$ent);
			$tdy_new_col++;
		}elsif($atemp[0] eq 'today_imp_col'){	#imp col data
			push(@today_imp_col,$ent);
			$tdy_imp_col++;
#
#--- hot case
#
		}elsif($atemp[0] eq 'hccd'){		# bad pix data
			push(@hccd_list, $ent);
			$hccd_cnt++;
		}elsif($atemp[0] eq 'hcol'){		# bad col data
			push(@hcol_list, $ent);
			$hcol_cnt++;
		}elsif($atemp[0] eq 'today_new_hccd'){	# new bad pix data
			push(@today_new_hccd, $ent);
			$htdy_new++;
		}elsif($atemp[0] eq 'today_imp_hccd'){	# imp pix data
			push(@today_imp_hccd, $ent);
			$htdy_imp++;
		}elsif($atemp[0] eq 'today_new_hcol'){	# new bad col data
			push(@today_new_hcol,$ent);
			$htdy_new_col++;
		}elsif($atemp[0] eq 'today_imp_hcol'){	#imp col data
			push(@today_imp_hcol,$ent);
			$htdy_imp_col++;
		}
	}

	OUTER:
	for($is = 0; $is < 10; $is++){			# loop around ccds

		if(${tdycnt.$is} == 0){			# only when we have today's ccd data
			next OUTER;
		}
#
#--- ccd data check
#
		${ccd_ind.$is} = 0;			# indicater for whether ccd*$is has
		OUTER:					# bad pix data in
		foreach $ent (@ccd_list){
			$cname = "ccd$is";
			if($ent eq $cname){
				${ccd_ind.$is}++;
				last OUTER;
			}
		}

		@imp_data = ();
		@new_data = ();
		$i_ind = 0;
		$n_ind = 0;
		$i_name = "today_imp_ccd$is";
		$n_name = "today_new_ccd$is";
#
#--- read in today's new bad pix position
#
		OUTER:
		foreach $ent (@today_new_ccd){		
			if($ent eq $n_name){
				@new_data = ();

				open(IN, "$web_dir/Disp_dir/today_new_ccd$is");

				while(<IN>){
					chomp $_;
					@atemp = split(/:/, $_);
					if($atemp[0] eq '#Date'){
						$ntdy_date = $_;
						@ttemp     = split(/:/, $_);
						$ntime_ind = "$ttemp[1]$ttemp[2]";
					}else{
						push(@new_data, $_);
						$n_ind++;
					}
				}
				close(IN);
				last OUTER;
			}
		}

		OUTER:
		foreach $ent (@today_imp_ccd){
			if($ent eq $i_name){
				@imp_data = ();

				open(IN, "$web_dir/Disp_dir/today_imp_ccd$is");

				while(<IN>){
					chomp $_;
					@atemp = split(/:/, $_);
					if($atemp[0] eq '#Date'){
						$itdy_date = $_;
						@ttemp     = split(/:/, $_);
						$itime_ind = "$ttemp[1]$ttemp[2]";
					}else{
						push(@imp_data, $_);
						$i_ind++;
					}
				}
				close(IN);
				last OUTER;
			}
		}

		if($n_ind > 0 || $i_ind > 0){

			open(OUT, ">>$web_dir/Disp_dir/change_ccd$is");

			if($ntime_ind == $itime_ind){
				$diff = $n_ind - $i_ind;
				print OUT "\n$ntdy_date\n";
				if($diff ==  0){
					for($it = 0; $it < $n_ind; $it++){
						@data_new = split(/\t+/, $new_data[$it]);
						@data_imp = split(/\t+/, $imp_data[$it]);
						print OUT "New=($data_new[0], $data_new[1])\t";
						print OUT "Imp=($data_imp[0], $data_imp[1])\n";
					}
				}elsif($diff > 0){
					for($it = 0; $it < $i_ind; $it++){
						@data_new = split(/\t+/, $new_data[$it]);
						@data_imp = split(/\t+/, $imp_data[$it]);
						print OUT "New=($data_new[0], $data_new[1])\t";
						print OUT "Imp=($data_imp[0], $data_imp[1])\n";
					}
					for($it = $i_ind; $it < $n_ind; $it++){
						@data_new = split(/\t+/, $new_data[$it]);
						print OUT "New=($data_new[0], $data_new[1])\n";
					}
				}elsif($diff < 0){
					for($it = 0; $it < $n_ind; $it++){
						@data_new = split(/\t+/, $new_data[$it]);
						@data_imp = split(/\t+/, $imp_data[$it]);
						print OUT "New=($data_new[0], $data_new[1])\t";
						print OUT "Imp=($data_imp[0], $data_imp[1])\n";
					}
					for($it = $n_ind; $it < $i_ind; $it++){
						@data_imp = split(/\t+/, $imp_data[$it]);
						print OUT "	      \t";
						print OUT "Imp=($data_imp[0], $data_imp[1])\n";
					}
				}
			}elsif($ntime_ind < $itime_ind){
				print OUT "\n$itdy_date\n";

				for($it = 0 ; $it < $n_ind; $it++){
					@data_new = split(/\t+/, $new_data[$it]);
					print OUT "New=($data_new[0], $data_new[1])\n";
				}
				for($it = 0; $it < $i_ind; $it++){
					@data_imp = split(/\t+/, $imp_data[$it]);
					print OUT "	      \t";
					print OUT "Imp=($data_imp[0], $data_imp[1])\n";
				}

			}elsif($itime_ind < $ntime_ind){
				print OUT "\n$ntdy_date\n";

				for($it = 0; $it < $i_ind; $it++){
					@data_imp = split(/\t+/, $imp_data[$it]);
					print OUT "	      \t";
					print OUT "Imp=($data_imp[0], $data_imp[1])\n";
				}

				for($it = 0 ; $it < $n_ind; $it++){
					@data_new = split(/\t+/, $new_data[$it]);
					print OUT "New=($data_new[0], $data_new[1])\n";
				}
			}
			close(OUT)
		}
	
#
#--- hccd data check
#
		${hccd_ind.$is} = 0;			# indicater for whether ccd*$is has
		OUTER:					# bad pix data in
		foreach $ent (@hccd_list){
			$cname = "hccd$is";
			if($ent eq $cname){
				${hccd_ind.$is}++;
				last OUTER;
			}
		}

		@imp_data = ();
		@new_data = ();
		$i_ind    = 0;
		$n_ind    = 0;
		$i_name   = "today_imp_hccd$is";
		$n_name   = "today_new_hccd$is";
#
#--- read in today's new bad pix position
#
		OUTER:
		foreach $ent (@today_new_hccd){
			if($ent eq $n_name){
				@new_data = ();

				open(IN, "$web_dir/Disp_dir/today_new_hccd$is");

				while(<IN>){
					chomp $_;
					@atemp = split(/:/, $_);
					if($atemp[0] eq '#Date'){
						$ntdy_date = $_;
						@ttemp     = split(/:/, $_);
						$ntime_ind = "$ttemp[1]$ttemp[2]";
					}else{
						push(@new_data, $_);
						$n_ind++;
					}
				}
				close(IN);
				last OUTER;
			}
		}

		OUTER:
		foreach $ent (@today_imp_hccd){
			if($ent eq $i_name){
				@imp_data = ();

				open(IN, "$web_dir/Disp_dir/today_imp_hccd$is");

				while(<IN>){
					chomp $_;
					@atemp = split(/:/, $_);
					if($atemp[0] eq '#Date'){
						$itdy_date = $_;
						@ttemp     = split(/:/, $_);
						$itime_ind = "$ttemp[1]$ttemp[2]";
					}else{
						push(@imp_data, $_);
						$i_ind++;
					}
				}
				close(IN);
				last OUTER;
			}
		}

		if($n_ind > 0 || $i_ind > 0){

			open(OUT, ">>$web_dir/Disp_dir/change_hccd$is");

			if($ntime_ind == $itime_ind){
				$diff = $n_ind - $i_ind;
				print OUT "\n$ntdy_date\n";
				if($diff ==  0){
					for($it = 0; $it < $n_ind; $it++){
						@data_new = split(/\t+/, $new_data[$it]);
						@data_imp = split(/\t+/, $imp_data[$it]);
						print OUT "New=($data_new[0], $data_new[1])\t";
						print OUT "Imp=($data_imp[0], $data_imp[1])\n";
					}
				}elsif($diff > 0){
					for($it = 0; $it < $i_ind; $it++){
						@data_new = split(/\t+/, $new_data[$it]);
						@data_imp = split(/\t+/, $imp_data[$it]);
						print OUT "New=($data_new[0], $data_new[1])\t";
						print OUT "Imp=($data_imp[0], $data_imp[1])\n";
					}
					for($it = $i_ind; $it < $n_ind; $it++){
						@data_new = split(/\t+/, $new_data[$it]);
						print OUT "New=($data_new[0], $data_new[1])\n";
					}
				}elsif($diff < 0){
					for($it = 0; $it < $n_ind; $it++){
						@data_new = split(/\t+/, $new_data[$it]);
						@data_imp = split(/\t+/, $imp_data[$it]);
						print OUT "New=($data_new[0], $data_new[1])\t";
						print OUT "Imp=($data_imp[0], $data_imp[1])\n";
					}
					for($it = $n_ind; $it < $i_ind; $it++){
						@data_imp = split(/\t+/, $imp_data[$it]);
						print OUT "	      \t";
						print OUT "Imp=($data_imp[0], $data_imp[1])\n";
					}
				}
			}elsif($ntime_ind < $itime_ind){
				print OUT "\n$itdy_date\n";

				for($it = 0 ; $it < $n_ind; $it++){
					@data_new = split(/\t+/, $new_data[$it]);
					print OUT "New=($data_new[0], $data_new[1])\n";
				}
				for($it = 0; $it < $i_ind; $it++){
					@data_imp = split(/\t+/, $imp_data[$it]);
					print OUT "	      \t";
					print OUT "Imp=($data_imp[0], $data_imp[1])\n";
				}

			}elsif($itime_ind < $ntime_ind){
				print OUT "\n$ntdy_date\n";

				for($it = 0; $it < $i_ind; $it++){
					@data_imp = split(/\t+/, $imp_data[$it]);
					print OUT "	      \t";
					print OUT "Imp=($data_imp[0], $data_imp[1])\n";
				}

				for($it = 0 ; $it < $n_ind; $it++){
					@data_new = split(/\t+/, $new_data[$it]);
					print OUT "New=($data_new[0], $data_new[1])\n";
				}
			}
			close(OUT)
		}
#
#--- col
#
		${col_ind.$is} = 0;
		OUTER:
		foreach $ent (@col_list){
			$cname="col$is";
			if($ent eq $cname){
				${col_ind.$is}++;
				last OUTER;
			}
		}

		@imp_data = ();
		@new_data = ();
		$i_ind = 0;
		$n_ind = 0;
		$i_name = "today_imp_col$is";
		$n_name = "today_new_col$is";

		OUTER:
		foreach $ent (@today_new_col){
			if($ent eq $n_name){

				open(IN, "$web_dir/Disp_dir/today_new_col$is");

				while(<IN>){
					chomp $_;
					@atemp = split(/:/, $_);
					if($atemp[0] eq '#Date'){
						$ntdy_date = $_;
						@ttemp = split(/:/, $_);
						$ntime_ind = "$ttemp[1]$ttemp[2]";
					}else{
						push(@new_data, $_);
						$n_ind++;
					}
				}
				close(IN);
				last OUTER;
			}
		}

		OUTER:
		foreach $ent (@today_imp_col){
			if($ent eq $i_name){

				open(IN, "$web_dir/Disp_dir/today_imp_col$is");

				while(<IN>){
					chomp $_;
					@atemp = split(/:/, $_);
					if($atemp[0] eq '#Date'){
						$itdy_date = $_;
						@ttemp = split(/:/, $_);
						$itime_ind = "$ttemp[1]$ttemp[2]";
					}else{
						push(@imp_data, $_);
						$i_ind++;
					}
				}
				close(IN);
				last OUTER;
			}
		}

		if($n_ind > 0 || $i_ind > 0){

			open(OUT, ">>$web_dir/Disp_dir/change_col$is");

			if($ntime_ind == $itime_ind){
				$diff = $n_ind - $i_ind;
				print OUT "\n$ntdy_date\n";
				if($diff ==  0){
					for($it = 0; $it < $n_ind; $it++){
						print OUT "New=$new_data[$it]\t";
						print OUT "Imp=$imp_data[$it]\n";
					}
				}elsif($diff > 0){
					for($it = 0; $it < $i_ind; $it++){
						print OUT "New=$new_data[$it]\t";
						print OUT "Imp=$imp_data[$it]\n";
					}
					for($it = $i_ind; $it < $n_ind; $it++){
						print OUT "New=$new_data[$it]\n";
					}
				}elsif($diff < 0){
					for($it = 0; $it < $n_ind; $it++){
						print OUT "New=$new_data[$it]\t";
						print OUT "Imp=$imp_data[$it]\n";
					}
					for($it = $n_ind; $it < $i_ind; $it++){
						print OUT "	      \t";
						print OUT "Imp=$imp_data[$it]\n";
					}
				}
			}elsif($ntime_ind < $itime_ind){
				print OUT "\n$itdy_date\n";

				for($it = 0 ; $it < $n_ind; $it++){
					print OUT "New=$new_data[$it]\n";
				}
				for($it = 0; $it < $i_ind; $it++){
					print OUT "	      \t";
					print OUT "Imp=$imp_data[$it]\n";
				}

			}elsif($itime_ind < $ntime_ind){
				print OUT "\n$ntdy_date\n";

				for($it = 0; $it < $i_ind; $it++){
					print OUT "	      \t";
					print OUT "Imp=$imp_data[$it]\n";
				}

				for($it = 0 ; $it < $n_ind; $it++){
					print OUT "New=$new_data[$it]\n";
				}
			}
			close(OUT)
		}
	}
}

################################################################
### today_dom: find today dom				    ####
################################################################

sub find_today_dom{

	($hsec, $hmin, $hhour, $hmday, $hmon, $hyear, $hwday, $hyday, $hisdst)= localtime(time);

	if($hyear < 1900) {
		$hyear = 1900 + $hyear;
	}
	$month = $hmon + 1;
	#$hyday++;

	if ($hyear == 1999) {
		$dom = $hyday - 202 + 1;
	}elsif($hyear >= 2000){
		$dom = $hyday + 163 + 1 + 365 * ($hyear - 2000);
		if($hyear > 2000) {
			$dom++;
		}
		if($hyear > 2004) {
			$dom++;
		}
		if($hyear > 2008) {
			$dom++;
			$dom++;
		}
		if($hyear > 2012) {
			$dom++;
		}
	}
}

################################################################
### print_html: print up-dated html page for bad pixel      ####
################################################################

sub print_html{

	find_today_dom();

	open(OUT,">$web_dir/mta_bad_pixel_list.html");

	print OUT '<HTML><BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="yellow"';
	print OUT 'ALINK="#FF0000" background="./stars.jpg">',"\n";
	print OUT '<title> ACIS Bad Pixel List </title>',"\n";
	print OUT "\n";

	print OUT '<CENTER><H2>ACIS Bad Pixel List</H2></CENTER>',"\n";

	print OUT '<CENTER><H3>Updated ';
	print OUT "$hyear-$month-$hmday  ";
	print OUT "\n";
	print OUT "<br>";
	$hyday++;					# hyday starts from day 0 in localtime(time) function
	print OUT "DAY OF YEAR: $hyday ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF MISSION: $dom ";
	print OUT '</H3></CENTER>';
	print OUT '<P>',"\n";
	print OUT '<font size="-1" color="yellow">',"\n";
	print OUT 'Columns in Table',"\n";
	print OUT '<UL>',"\n";
	print OUT '<li>Warm Pixel: a list of warm pixels currently observed',"\n";
	print OUT '<li>Flickering: any warm pixels which were on and off 3 times or more in the last 3 months',"\n";
	print OUT '<li>Past Warm Pixels: a list of all pixels appeared as warm pixels in past',"\n";
	print OUT '<li>History: history of when a particular warm pixel was on or off',"\n";

	print OUT '<li>Hot Pixel: a list of hot pixels currently observed',"\n";
	print OUT '<li>Flickering: any hot pixels which were on and off 3 times or more in the last 3 months',"\n";
	print OUT '<li>Past Hot Pixels: a list of all pixels appeared as hot pixels in past',"\n";
	print OUT '<li>History: history of when a particular hot pixel was on or off',"\n";

	print OUT '<li>Warm Column: a list of warm columns currently observed',"\n";
	print OUT '<li>Flickering: any warm columns which were on and off 3 times or more in the last 3 months',"\n";
	print OUT '<li>Past Warm Columns: a list of all columns appeared as warm columns in past',"\n";
	print OUT '<li>History: history of when a particular warm columns was on or off',"\n";
	print OUT '</font></ul>',"\n";

	$tot_warm = 0;
	$tot_hot  = 0;
	$tot_col  = 0;
	for($kccd = 0; $kccd < 10; $kccd++){
		$tot_warm += ${tot_new_pix.$kccd};
		$tot_hot  += ${tot_new_hot.$kccd};
		$tot_col  += ${tot_new_col.$kccd};
	}
		
	print OUT '</P><BR><P></font><HR>',"\n";
	print OUT '<H2>Previously unknown bad pixels/columns appeared in the last 14 days:<H2></P> ',"\n";
	print OUT '<Table BORDER=2 Cellspacing = 2 Cellpadding =3>',"\n";
#
#---- warm pix
#
	print OUT '<TR><TH>Warm Pixels</TH>',"\n";
	if($tot_warm > 0){
		print OUT '<TD>&#160</TD></TR>',"\n";
		for($kccd = 0; $kccd < 10; $kccd++){
			if(${tot_new_pix.$kccd} > 0){
				print OUT "<TH>CCD $kccd</TH>","\n";
				print OUT '<TD>';
				open(IN,"$web_dir/Disp_dir/totally_new$kccd");
				while(<IN>){
					chomp $_;
					print OUT "$_\n";
				}
				
				close(IN);
				print OUT '</TD></TR>',"\n";
			}
		}
	}else{
		print OUT '<TD>No New Warm Pixels</TD></TR>',"\n";
	}
#
#--- hot pix
#
	print OUT '<TR><TH>Hot Pixels</TH>',"\n";
	if($tot_hot > 0){
		print OUT '<TD>&#160</TD></TR>',"\n";
		for($kccd = 0; $kccd < 10; $kccd++){
			if(${tot_new_hot.$kccd} > 0){
				print OUT "<TH>CCD $kccd</TH>","\n";
				print OUT '<TD>';
				open(IN,"$web_dir/Disp_dir/totally_new_hot$kccd");
				while(<IN>){
					chomp $_;
					print OUT "$_\n";
				}
				close(IN);
				print OUT '</TD></TR>',"\n";
			}
		}
	}else{
		print OUT '<TD>No New Hot Pixels</TD></TR>',"\n";
	}
#
#--- bad col
#
	print OUT '<TR><TH>Bad Columns</TH>',"\n";
	if($tot_col > 0){
		print OUT '<TD>&#160</TD></TR>',"\n";
		for($kccd = 0; $kccd < 10; $kccd++){
			if(${tot_new_col.$kccd} > 0){
				print OUT "<TH>CCD $kccd</TH>","\n";
				print OUT '<TD>';
				open(IN,"$web_dir/Disp_dir/totally_new_col$kccd");
				while(<IN>){
					chomp $_;
					print OUT "$_\n";
				}
				close(IN);
				print OUT '</TD></TR>',"\n";
			}
		}
	}else{
		print OUT '<TD>No New Bad Columns</TD></TR>',"\n";
	}
	print OUT '</TABLE><BR>',"\n";



#	print OUT '</ul>',"\n";
#	print OUT '</font>',"\n";
	print OUT '</P>',"\n";
	print OUT '<P><H2>Bad Pixels/Columns</P>',"\n";
#	print OUT '<CENTER>',"\n";
	print OUT '<Table BORDER=2 Cellspacing = 2 Cellpadding =3 Align=center>',"\n";
	print OUT '<TR>',"\n";
	print OUT '<TH>CCD</TH>';
	print OUT '<TH>Data</TH>';
	print OUT '<TH>Warm Pixel History</TH>';
	print OUT '<TH>Hot Pixel History</TH>';
	print OUT '<TH>Bad Column History</TH>';
	print OUT '<TH>Data List</TH>',"\n";
	print OUT '</TR>',"\n";

	$test = `ls $web_dir/Disp_dir/*`;
	for($i = 0; $i < 10; $i++) {
		print OUT '<TR><TD>CCD',"$i</TD>\n";

#------  data display page

		if(${ccd_ind.$i} > 0  || ${hccd_ind.$i} > 0){
			print OUT '<td><a href = "./Html_dir/ccd_data',"$i",'.html">Bad Pixels Today</a></td>',"\n";
		}else{
			print OUT '<td><a href = "./Html_dir/ccd_data',"$i",'.html">No Bad Pixels Today</a></td>',"\n";
		}

#----- warm pix history

		if($test =~ /change_ccd$i/){
			print OUT '<TD><a href=./Disp_dir/',"change_ccd$i",'>Change</a></TD>',"\n";
		}else{
			print OUT '<TD>No History</TD>',"\n";
		}

#----- hot pix history

		if($test =~ /change_hccd$i/){
			print OUT '<TD><a href=./Disp_dir/',"change_hccd$i",'>Change</a></TD>',"\n";
		}else{
			print OUT '<TD>No History</TD>',"\n";
		}
#
#----- bad column history
#
		if($test =~ /change_col$i/){
			print OUT '<TD><a href=./Disp_dir/',"change_col$i",'>Change</a></TD>',"\n";
		}else{
			print OUT '<TD>No History</TD>',"\n";
		}
#
#----- data used
#
		print OUT '<TD><a href=./Disp_dir/',"data_used.$i",'>Data Used</a></TD>',"\n";
	}

	print OUT '</TR>',"\n";

	print OUT '</TABLE>',"\n";
	print OUT '</CENTER>',"\n";
	print OUT '<spacer type=vertical size=5>',"\n";
	print OUT '<font size=-0.5>',"\n";
	print OUT '<BR>',"\n";
	print OUT 'Bad Pixel Trend Plots<br>',"\n";
#	print OUT '<a href=./bad_pix_hist> ASCII Data<br>',"\n";
	print OUT '<a href=./Plots/hist_ccd.gif>Plot for History of Bad Pixel: Front Side CCDs</a><br>',"\n";
	print OUT '<a href=./Plots/hist_ccd5.gif>Plot for History of Bad Pixel: CCD 5</a><br>',"\n";
	print OUT '<a href=./Plots/hist_ccd7.gif>Plot for History of Bad Pixel: CCD 7</a><br>',"\n";

	print OUT '<a href=./Plots/hist_hccd.gif>Plot for History of Hot Pixel: Front Side CCDs</a><br>',"\n";
	print OUT '<a href=./Plots/hist_hccd5.gif>Plot for History of Hot Pixel: CCD 5</a><br>',"\n";
	print OUT '<a href=./Plots/hist_hccd7.gif>Plot for History of Hot Pixel: CCD 7</a><br>',"\n";

	print OUT '<a href=./Plots/hist_col.gif>Plot for History of Bad Columns: Front Side CCDs</a><br>',"\n";
	print OUT '<a href=./Plots/hist_col5.gif>Plot for History of Bad Columns: CCD 5</a><br>',"\n";
	print OUT '<a href=./Plots/hist_col7.gif>Plot for History of Bad Columns: CCD 7</a><br>',"\n";
	print OUT '</font>';


	print OUT '</u><P>',"\n";
	print OUT '<font size="-1" color="yellow">',"\n";
	print OUT 'A bad pixel was selected as follows:',"\n";
	print OUT '<ul>',"\n";
	print OUT '<li> acis*bias0.fits in a given period were obtained',"\n";
	print OUT '<li> compute an average of count rates for each ccd',"\n";
	print OUT '<li> compare each pixel to the average, and if a pixel value',"\n";
	print OUT 'was 5 sigma  higher than the average,  a local average (32x32) was computed.',"\n";
	print OUT '<li>if the pixel value was still 5 sigma higher than the local average,',"\n";
	print OUT 'it was marked as a possible candidate for a warm pixel.',"\n";
	print OUT '<li> if three consequtive bias frames had the same pixel marked as a',"\n";
	print OUT 'warm pixel candidate, the pixel was listed as a warm pixel.',"\n";
	print OUT '<li> if the pixel was located at the edge of the CCD (y = 1023, 1024), it',"\n";
	print OUT 'was droped form the list.',"\n";
	print OUT '<br>',"\n";

	print OUT '<li>for a hot pixel, a process was same, except a threshold was ',"\n";
	print OUT 'a ccd  average plus 1000 counts',"\n";
	print OUT '<br>',"\n";

	print OUT '</ul>';
	print OUT 'A bad column was selected as follows:',"\n";
	print OUT '<ul>';
	print OUT '<li> each column was averaged out, and compared to an average for an entire ccd.',"\n";
	print OUT '<li> if the average of the column was 5 sigma  higher than the average of the ccd',"\n";
	print OUT 'compare the column average to a local average (10 columns).',"\n";
	print OUT '<li> if the column was still 5 sigma higher than the local average, mark it as',"\n";
	print OUT 'a bad column candidate',"\n";
	print OUT '<li> if the column appeared as a bad column for a 3 consequtive frames, it was ',"\n";
	print OUT 'marked as a real bad column.',"\n";
	print OUT '</font>',"\n";
	print OUT '</ul>',"\n";

	close(OUT);

}

#############################################################################
### plot_hist: plotting history of bad pixel increase                    ####
#############################################################################

sub plot_hist{
	@day_list = ();
	@new_list = ();
	@imp_list = ();
	$save_date = 'null';

############### bad columns and bad row lists are here; ################
	$ccd = 5;
	@{bad_col.$ccd} = (1,2,3,509,510,511,513,515);
	@{bad_row.$ccd} = (313);
	$ccd = 7;
	@{bad_col.$ccd} = (4,509,510,511,512,513,514,515,516);
########################################################################

	count_bad_pix();	# find how many new and improved warm pixels were occured
		
	$icnt = 0;
	foreach $ent (@day_list){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	
#
#--- prepareing plottings
#

#
#---	Imaging CCDs
#
		
	$icnt = 0;
	foreach $ent (@imp_day_list){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	
	$count = $icnt;
	$xmin = $new_day_list[1] - 3;
	find_today_dom();
	$xmax = $dom + 3;

	$ymin = -1;
	$ymax = 20;						# setting y plotting range

	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels
	@x = @new_day_list;
	@y = @new_list;
	$title = 'Numbers of New Warm Pixels: Front Side CCDs';
	plot_diff();						# ploting routine
	
	$icnt = 0;
	foreach $ent (@new_day_list){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @imp_day_list;
	@y = @imp_list;						#improved warm pixels
	$title = 'Numbers of Disappeared Warm Pixels: Front Side CCDs';
	plot_diff();
	
	$icnt = 0;
	foreach $ent (@diff_day_list){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$no_write = 1;						# relative # of warm pixels
	@x = @diff_day_list;
	@y = @diff_list;
	$tot = $icnt -2;
	linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;
	
	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";


	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_list;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;

	if($ymax < 20){
		$ymax = 20;
	}

	$ymax = 50;
	$title = 'Numbers of Warm Pixels Changes: Front CCDs';
	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 | $bin_dir/ppmtogif > $web_dir/Plots/hist_ccd.gif");
	system("rm pgplot.ps");

#
#---	 CCD 5
#
		
	$icnt = 0;
	foreach $ent (@new_day_list5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$ymin = -1;
	$ymax = 20;
	
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels
	@x = @new_day_list5;
	@y = @new_list5;
	$title = 'Numbers of New Warm Pixels: CCD 5';
	plot_diff();						# ploting routine
		
	$icnt = 0;
	foreach $ent (@imp_day_list5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @imp_day_list5;						#improved warm pixels
	@y = @imp_list5;						#improved warm pixels
	$title = 'Numbers of Disappeared Warm Pixels: CCD 5';
	plot_diff();
	
	$no_write = 1;						# relative # of warm pixels
	$icnt = 0;
	foreach $ent (@diff_day_list5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @diff_day_list5;
	@y = @diff_list5;
	$tot = $icnt -2;
	linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;
	
	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";
	
	
	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_list5;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;
	if($ymax < 20){
		$ymax = 20;
	}

	$ymax = 50;
	$title = 'Numbers of Warm Pixels Changes: CCD5';
	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 |$bin_dir/ppmtogif > $web_dir/Plots/hist_ccd5.gif");
	system("rm pgplot.ps");

#
#--- CCD7
#
	$icnt = 0;
	foreach $ent (@new_day_list7){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$ymin = -1;
	$ymax = 20;
	
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels
	$icnt = 0;
	foreach $ent (@imp_day_list7){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @new_day_list7;
	@y = @new_list7;
	$title = 'Numbers of New Warm Pixels: CCD 7';
	plot_diff();						# ploting routine
	
	@x = @imp_day_list7;						#improved warm pixels
	@y = @imp_list7;						#improved warm pixels
	$title = 'Numbers of Disappeared Warm Pixels: CCD 7';
	plot_diff();
	
	$no_write = 1;						# relative # of warm pixels
	$icnt = 0;
	foreach $ent (@diff_day_list7){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @diff_day_list7;
	@y = @diff_list7;
	$tot = $icnt -2;
	linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;
	
	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";
	
	
	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_list;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;

	if($ymax < 20){
		$ymax = 20;
	}

	$ymax = 50;
	$title = 'Numbers of Warm Pixels Changes: CCD 7';
	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 |$bin_dir/ppmtogif > $web_dir/Plots/hist_ccd7.gif");
	system("rm pgplot.ps");

#
#---     Hot:
#

#
#--- 	Imaging CCDs
#

	$icnt = 0;
	foreach $ent (@new_day_hlist){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$ymin = -1;
	$ymax = 20;						# setting y plotting range

	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels

	$icnt = 0;
	foreach $ent (@imp_day_hlist){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @new_day_hlist;
	@y = @new_hlist;
	$title = 'Numbers of New Hot Pixels: Front Side CCDs';
	plot_diff();						# ploting routine
	
	@x = @imp_day_hlist;						#improved warm pixels
	@y = @imp_hlist;						#improved warm pixels
	$title = 'Numbers of Disappeared Hot Pixels: Front Side CCDs';
	plot_diff();
	
	$no_write = 1;						# relative # of warm pixels

	$icnt = 0;
	foreach $ent (@diff_day_hlist){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @diff_day_hlist;
	@y = @diff_hlist;
	$tot = $icnt -2;
	linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;
	
	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";


	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_hlist;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;
	if($ymax < 20){
		$ymax = 20;
	}

	$ymax = 50;
	$title = 'Numbers of Hot Pixels Changes: Front CCDs';
	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 |$bin_dir/ppmtogif > $web_dir/Plots/hist_hccd.gif");
	system("rm pgplot.ps");

#
#----	 CCD 5
#
	$icnt = 0;
	foreach $ent (@new_day_hlist5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$ymin = -1;
	$ymax = 20;
	
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels
	$icnt = 0;
	@x = @new_day_hlist5;
	@y = @new_hlist5;
	$title = 'Numbers of New Hot Pixels: CCD 5';
	plot_diff();						# ploting routine
	
	$icnt = 0;
	foreach $ent (@imp_day_hlist5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @imp_day_hlist5;						#improved warm pixels
	@y = @imp_hlist5;						#improved warm pixels
	$title = 'Numbers of Disappeared Hot Pixels: CCD 5';
	plot_diff();
	
	$no_write = 1;						# relative # of warm pixels
	$icnt = 0;
	foreach $ent (@diff_day_hlist5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @diff_day_hlist5;
	@y = @diff_hlist5;
	$tot = $icnt -2;
	linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;
	
	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";
	
	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_hlist5;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;
	if($ymax < 20){
		$ymax = 20;
	}
	$title = 'Numbers of Hot Pixels Changes: CCD5';

	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 |$bin_dir/ppmtogif > $web_dir/Plots/hist_hccd5.gif");
	system("rm pgplot.ps");

#
#---	 CCD7
#
	$icnt = 0;
	foreach $ent (@new_day_hlist7){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$ymin = -1;
	$ymax = 20;
	
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels
	@x = @new_day_hlist7;
	@y = @new_hlist7;
	$title = 'Numbers of New Hot Pixels: CCD 7';
	plot_diff();						# ploting routine
	
	$icnt = 0;
	foreach $ent (@imp_day_hlist7){				# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @imp_day_hlist7;						#improved warm pixels
	@y = @imp_hlist7;						#improved warm pixels
	$title = 'Numbers of Disappeared Hot Pixels: CCD 7';
	plot_diff();
	
	$no_write = 1;						# relative # of warm pixels
	$icnt = 0;
	foreach $ent (@diff_day_hlist7){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @diff_day_hlist7;
	@y = @diff_hlist7;
	$tot = $icnt -2;
	linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;
	
	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";
	
	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_hlist;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;
	if($ymax < 20){
		$ymax = 20;
	}

	$ymax = 50;
	$title = 'Numbers of Hot Pixels Changes: CCD 7';

	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 |$bin_dir/ppmtogif > $web_dir/Plots/hist_hccd7.gif");
	system("rm pgplot.ps");

#
#---	 Col: Front Side CCDs
#
	$icnt = 0;
	foreach $ent (@new_day_col_list){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$ymin = -1;
	$ymax = 20;
	
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels
	@x = @new_day_col_list;
	@y = @new_col_list;
	$title = 'Numbers of New Warm Columns: Front Side CCDs';
	plot_diff();						# ploting routine
	
	$icnt = 0;
	foreach $ent (@imp_day_col_list){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @imp_day_col_list;						#improved warm pixels
	@y = @imp_col_list;						#improved warm pixels
	$title = 'Numbers of Disappeared Warm Columns: Front Side CCDs';
	plot_diff();
	
	$no_write = 1;						# relative # of warm pixels
	$icnt = 0;
	foreach $ent (@diff_day_col_list){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @diff_day_col_list;
	@y = @diff_col_list;
	$tot = $icnt -2;
	linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;
	
	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";
	
	
	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_list;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;
	if($ymax < 20){
		$ymax = 20;
	}

	$ymax = 50;
	$title = 'Numbers of Warm Column Changes: Front Side CCDs';

	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 |$bin_dir/ppmtogif > $web_dir/Plots/hist_col.gif");
	system("rm pgplot.ps");

#
#---	 Col: CCD 5
#
	$icnt = 0;
	foreach $ent (@new_day_col_list5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$ymin = -1;
	$ymax = 20;
	
	$ymax_temp = $ymax_new;
	if($ymax_imp > $ymax_temp){
		$ymax_temp = $ymax_imp;
	}
	if($ymax_diff > $ymax_temp){
		$ymax_temp = $ymax_diff;
	}
	if($ymax_temp > $ymax){
		$ymax = $ymax_temp;
	}
	
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels
	@x = @new_day_col_list5;
	@y = @new_col_list5;
	$title = 'Numbers of New Warm Columns: CCD 5';
	plot_diff();						# ploting routine
	
	$icnt = 0;
	foreach $ent (@imp_day_col_list5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @imp_day_col_list5;						#improved warm pixels
	@y = @imp_col_list5;						#improved warm pixels
	$title = 'Numbers of Disappeared Warm Columns: CCD 5';
	plot_diff();
	
	$no_write = 1;						# relative # of warm pixels
	$icnt = 0;
	foreach $ent (@diff_day_col_list5){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @diff_day_col_list5;
	@y = @diff_col_list5;
	$tot = $icnt -2;
	linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;
	
	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";
	
	
	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_list;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;
	if($ymax < 20){
		$ymax = 20;
	}

	$ymax = 50;
	$title = 'Numbers of Warm Columns: CCD 5';

	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 |$bin_dir/ppmtogif > $web_dir/Plots/hist_col5.gif");
	system("rm pgplot.ps");

#
#---	 Col: CCD 7
#
	$icnt = 0;
	foreach $ent (@new_day_col_list7){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	$ymin = -1;
	$ymax = 20;
	
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgbegin(0, "/ps",1,1);                                  # here the plotting start
	pgsubp(1,3);                                            # pg routine: panel
	pgsch(2);                                               # pg routine: charactor size
	pgslw(4);          
	
	$no_write = 0 ;						# new warm pixels
	@x = @new_day_col_list7;
	@y = @new_col_list7;
	$title = 'Numbers of New Warm Columns: CCD 7';
	plot_diff();						# ploting routine
	
	$icnt = 0;
	foreach $ent (@imp_day_col_list7){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @imp_day_col_list7;					#improved warm pixels
	@y = @imp_col_list7;						#improved warm pixels
	$title = 'Numbers of Disappeared Warm Columns: CCD 7';
	plot_diff();

	$no_write = 1;						# relative # of warm pixels
	$icnt = 0;
	foreach $ent (@diff_day_col_list7){	# just counting input
		$tot[$icnt] = 0;
		$icnt++;
	}
	$count = $icnt;
	@x = @diff_day_col_list7;
	@y = @diff_col_list7;
	$tot = $icnt -2;
		linr_fit();
	$xb = $x[2];
	$xe = $x[$tot];
	$yb = $int + $slope*$xb;
	$ye = $int + $slope*$xe;

	@atemp = split(/\./,$slope);
	@btemp = split(//,$atemp[1]);
	$slope = "$atemp[0]".'.'."$btemp[0]$btemp[1]$btemp[2]$btemp[3]";
	
	$ymin = -1;
	@atemp = sort{$a<=>$b} @diff_list;
	$i = $icnt - 1;
	$ymax = $atemp[$i] + 3;
	if($ymax < 20){
		$ymax = 20;
	}

	$ymax = 50;
	$title = 'Numbers of Warm Columns: CCD 7';

	plot_diff();
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  pgplot.ps|$bin_dir/pnmcrop| $bin_dir/pnmflip -r270 |$bin_dir/ppmtogif > $web_dir/Plots/hist_col7.gif");
	system("rm pgplot.ps");

}

##################################################################################
### count_bad_pix: count number of bad pixels                                  ###
##################################################################################


sub count_bad_pix {
#	@day_list       = ();

	@diff_day_list      = ();
	@diff_day_list5     = ();
	@diff_day_list7     = ();
	@diff_day_hlist     = ();
	@diff_day_hlist5    = ();
	@diff_day_hlist7    = ();
	@diff_day_col_list  = ();
	@diff_day_col_list5 = ();
	@diff_day_col_list7 = ();
	@new_day_list       = ();
	@new_day_list5      = ();
	@new_day_list7      = ();
	@new_day_hlist      = ();
	@new_day_hlist5     = ();
	@new_day_hlist7     = ();
	@new_day_col_list   = ();
	@new_day_col_list5  = ();
	@new_day_col_list7  = ();
	@imp_day_list       = ();
	@imp_day_list5      = ();
	@imp_day_list7      = ();
	@imp_day_hlist      = ();
	@imp_day_hlist5     = ();
	@imp_day_hlist7     = ();
	@imp_day_col_list   = ();
	@imp_day_col_list5  = ();
	@imp_day_col_list7  = ();

	@diff_list          = ();
	@diff_list5         = ();
	@diff_list7         = ();
	@diff_hlist         = ();
	@diff_hlist5        = ();
	@diff_hlist7        = ();
	@diff_col_list      = ();
	@diff_col_list5     = ();
	@diff_col_list7     = ();
	@new_list           = ();
	@new_list5          = ();
	@new_list7          = ();
	@new_hlist          = ();
	@new_hlist5         = ();
	@new_hlist7         = ();
	@new_col_list       = ();
	@new_col_list5      = ();
	@new_col_list7      = ();
	@imp_list           = ();
	@imp_list5          = ();
	@imp_list7          = ();
	@imp_hlist          = ();
	@imp_hlist5         = ();
	@imp_hlist7         = ();
	@imp_col_list       = ();
	@imp_col_list5      = ();
	@imp_col_list7      = ();

#
#---- bad pixels
#
	open(FH, "$web_dir/Disp_dir/bad_pix_cnt");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@day_list, $atemp[2]);
		push(@diff_day_list, $atemp[2]);
		push(@diff_list, $atemp[3]);
	}
	close(FH);

	open(FH, "$web_dir/Disp_dir/bad_pix_cnt5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@diff_day_list5, $atemp[2]);
		push(@diff_list5, $atemp[3]);
	}
	close(FH);

	open(FH, "$web_dir/Disp_dir/bad_pix_cnt7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@diff_day_list7, $atemp[2]);
		push(@diff_list7, $atemp[3]);
	}
	close(FH);


	open(FH, "$web_dir/Disp_dir/hot_pix_cnt");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@diff_day_hlist, $atemp[2]);
		push(@diff_hlist, $atemp[3]);
	}
	close(FH);

	open(FH, "$web_dir/Disp_dir/hot_pix_cnt5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@diff_day_hlist5, $atemp[2]);
		push(@diff_hlist5, $atemp[3]);
	}
	close(FH);

	open(FH, "$web_dir/Disp_dir/hot_pix_cnt7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@diff_day_hlist7, $atemp[2]);
		push(@diff_hist7, $atemp[3]);
	}
	close(FH);

	open(FH, "$web_dir/Disp_dir/bad_col_cnt");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@diff_day_col_list, $atemp[2]);
		push(@diff_col_list, $atemp[3]);
	}
	close(FH);

	open(FH, "$web_dir/Disp_dir/bad_col_cnt5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@diff_day_col_list5, $atemp[2]);
		push(@diff_col_list5, $atemp[3]);
	}
	close(FH);

	open(FH, "$web_dir/Disp_dir/bad_col_cnt7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@diff_day_col_list7, $atemp[2]);
		push(@diff_col_list7, $atemp[3]);
	}
	close(FH);
#
#---	New
#
	open(FH, "$web_dir/Disp_dir/new_bad_pix_save");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_list, $atemp[2]);
		push(@new_list, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/new_bad_pix_save5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_list5, $atemp[2]);
		push(@new_list5, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/new_bad_pix_save7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_list7, $atemp[2]);
		push(@new_list7, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/new_hot_pix_save");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_hlist, $atemp[2]);
		push(@new_hlist, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/new_hot_pix_save5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_hlist5, $atemp[2]);
		push(@new_hlist5, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/new_hot_pix_save7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_hlist7, $atemp[2]);
		push(@new_hlist7, $atemp[3]);
	}


	open(FH, "$web_dir/Disp_dir/new_bad_col_save");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_col_list, $atemp[2]);
		push(@new_col_list, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/new_bad_col_save5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_col_list5, $atemp[2]);
		push(@new_col_list5, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/new_bad_col_save7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@new_day_col_list7, $atemp[2]);
		push(@new_col_list7, $atemp[3]);
	}
#
#--- Improved
#
	open(FH, "$web_dir/Disp_dir/imp_bad_pix_save");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_list, $atemp[2]);
		push(@imp_list, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/imp_bad_pix_save5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_list5, $atemp[2]);
		push(@imp_list5, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/imp_bad_pix_save7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_list7, $atemp[2]);
		push(@imp_list7, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/imp_hot_pix_save");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_hlist, $atemp[2]);
		push(@imp_hlist, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/imp_hot_pix_save5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_hlist5, $atemp[2]);
		push(@imp_hlist5, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/imp_hot_pix_save7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_hlist7, $atemp[2]);
		push(@imp_hlist7, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/imp_bad_col_save");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_col_list, $atemp[2]);
		push(@imp_col_list, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/imp_bad_col_save5");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_col_list5, $atemp[2]);
		push(@imp_col_list5, $atemp[3]);
	}

	open(FH, "$web_dir/Disp_dir/imp_bad_col_save7");
	while(<FH>){
		chomp $_;
		@atemp = split(/:/,$_);
		push(@imp_day_col_list7, $atemp[2]);
		push(@imp_col_list7, $atemp[3]);
	}
}

#####################################################################
#####################################################################
#####################################################################

sub plot_diff {
	pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);


	pgpt(1, $x[1], $y[1], -1);
	for($m = 2; $m < $count - 1; $m++){
		pgdraw($x[$m],$y[$m]);
		pgpt(1, $x[$m], $y[$m], -1);
	}

	pglabel("Time (Day of Mission)", "Counts","$title");
#
#--- add extra info, if it is for the change plot
#

	if($no_write == 1) {	
		pgpt(1,$xb,$yb,-1);
		pgdraw($xe,$ye);
		pgtext($xmin+5,$ymax-4,"Slope: $slope");
	}
}


#####################################################################
### linr_fit: linear least sq fit routine                        ####
#####################################################################

sub linr_fit {
	$sumx  = 0;
	$sumx2 = 0;
	$sumy  = 0;
	$sumy2 = 0;
	$sumxy = 0;
	for($i = 0; $i <$tot -1; $i++){
		$sumx  += $x[$i];
		$sumx2 += $x[$i]*$x[$i];
		$sumy  += $y[$i];
		$sumy2 += $y[$i]*$y[$i];
		$sumxy += $x[$i]*$y[$i];
	}

	$int = 0;
	$slope = 0;

	$del = $tot*$sumx2 - $sumx*$sumx;
	if($del > 0){
		$int = ($sumx2*$sumy - $sumx*$sumxy)/$del;
		$slope = ($tot*$sumxy - $sumx*$sumy)/$del;
	}
}

#####################################################################
### mv_old_data: move old data from an active dir to a save dir   ###
#####################################################################

sub mv_old_data{
	($hsec, $hmin, $hhour, $hmday, $hmon, $hyear, $hwday, $hyday, $hisdst)= localtime(time);
	$year = 1900 + $hyear;
	$hyday -= 90;
	if($hyday < 0) {
		$year--;
		$hyday = 365 + $hyday;
	}
	
	$time = "$year:$hyday:00:00:00";
	timeconv2($time);
	
	for($dccd = 0; $dccd < 10; $dccd++){
		system("chmod 775  $house_keeping/Defect/CCD$dccd/*");
		system("ls -l $house_keeping/Defect/CCD$dccd/* > ./Working_dir/list");
		open(FH, './Working_dir/list');
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/, $_);
#			if($atemp[3] > 0) {
				@btemp = split(/acis/, $atemp[7]);
				$old_file = 'acis'."$btemp[1]";
				@ctemp = split(/_/, $btemp[1]);
				if($ctemp[0] < $sec_form_time){
					system("mv  $atemp[7] $web_dir/Old_data/CCD$dccd/.");
					system("gzip $web_dir/Old_data/CCD$dccd/$old_file");
				}
#			}else{
#				system("rm $atemp[7]");
#			}
		}
		close(FH);
		system("rm ./Working_dir/list");
	}
}


#################################################################################
### flickering_check: check which pixels are flickering in the past 90 days   ###
#################################################################################


sub flickering_check{
	($hsec, $hmin, $hhour, $hmday, $hmon, $hyear, $hwday, $hyday, $hisdst)= localtime(time);
#
#--- find date for 90 days ago
#
	$tyear = 1900 + $hyear;
	$pdate = $hyday - 90;

	if ($pdate < 1){
		$pdate += 365;
		$tyear--;
	}
	if($pdate < 10){
		$pdate = '00'."$pdate";
	}elsif($pdate < 100){
		$pdate = '0'."$pdate";
	}

	$chkdate = "$tyear$pdate";

	for($iccd = 0; $iccd < 10; $iccd++){

		@data = ();
		@coord = ();
#
#--- read data and find which pixels appeared in the past.
#
		open(IN, "$web_dir/Disp_dir/new_ccd$iccd");	
		while(<IN>){			
			chomp $_;
			push(@data, $_);
			if($_ =~ /^\#Date/){
			}else{
				@btemp = split(/\s+/,$_);	# some intializations
				$pos   = "$btemp[0].$btemp[1]";
				${cnt.$btemp[0].$btemp[1]} = 0;
				push(@coord,$pos );
			}
		}
		close(IN);
#
#--- possible candidates for flckering pixels
#
		@coord = sort {$a<=>$b} @coord;
		$first = shift(@coord);
		@new = ("$first");
		OUTER:
		foreach $ent (@coord){
			foreach $comp (@new){
				if($ent eq $comp){
					next OUTER;
				}
			}
			push(@new, $ent);
		}
	
#
#--- check the last 90 days and count how many times it went on and off
#	
		$rd_ind = 0;
		foreach $ent (@data){		
			if($ent  =~ /^\#Date/){	
				@atemp = split(/:/, $ent);
				$cdate = "$atemp[1]$atemp[2]";
				if($cdate > $chkdate){
					$rd_ind++;
				}
			}elsif($rd_ind > 0){
				@btemp = split(/\s+/,$ent);
				${cnt.$btemp[0].$btemp[1]}++;
			}
		}
		
		${fck_cnt.$iccd} = 0;

		open(OUT, "> $web_dir/Disp_dir/flickering$iccd");
#
#--- if pixels went on and off more than 4 times record they are flickering pixels
#
		foreach $ent (@new){		
			@ct = split(/\./, $ent);
			if(${cnt.$ct[0].$ct[1]} > 4){
				print OUT "($ct[0], $ct[1])\n";
				${fck_cnt.$iccd}++;
			}
		}
		close(OUT);
	}
}

#####################################################################
### conv_date_form4: change date form                             ###
#####################################################################

sub conv_date_form4{
	if($month == 1){$add = 0}
	elsif($month == 2){$add  = 31}
	elsif($month == 3){$add  = 59}
	elsif($month == 4){$add  = 90}
	elsif($month == 5){$add  = 120}
	elsif($month == 6){$add  = 151}
	elsif($month == 7){$add  = 181}
	elsif($month == 8){$add  = 212}
	elsif($month == 9){$add  = 243}
	elsif($month == 10){$add = 273}
	elsif($month == 11){$add = 304}
	elsif($month == 12){$add = 334}
	
	if($year == 2000 || $year == 2004 || $year == 2008 || $year == 2012){
		if($month > 3){
			$add++;
		}
	}
	$ydate = $add + $day;
	if($ydate < 10){
		$ydate = int ($ydate);
		$ydate = "00$ydate";
	}elsif($ydate < 100){
		$ydate = int ($ydate);
		$ydate = "0$ydate";
	}
	$date = "$year$ydate";
}

##################################################################################
### rm_imcomplete_data: remove incomplete data so that we can fill it correctly ##
##################################################################################


sub rm_incomplete_data{
	
	
	@ttemp   = split(//, $cut_date);
	$tyear   = "$ttemp[0]$ttemp[1]$ttemp[2]$ttemp[3]";
	$tdate   = "$ttemp[4]$ttemp[5]$ttemp[6]";
	$date    = "$tyear:$tdate";
	$tdate   = "$date:00:00:00";
	$secdate = `/home/ascds/DS.release/bin/axTime3 $tdate t d u s`;
	
	foreach $file  ('bad_col_cnt','bad_col_cnt5','bad_col_cnt7',
			'bad_pix_cnt','bad_pix_cnt5','bad_pix_cnt7',
			'hot_pix_cnt','hot_pix_cnt5','hot_pix_cnt7',
			'imp_bad_col_save','imp_bad_col_save5','imp_bad_col_save7',
			'imp_bad_pix_save','imp_bad_pix_save5','imp_bad_pix_save7',
			'imp_hot_pix_save','imp_hot_pix_save5','imp_hot_pix_save7',
			'new_bad_col_save','new_bad_col_save5','new_bad_col_save7',
			'new_bad_pix_save','new_bad_pix_save5','new_bad_pix_save7',
			'new_hot_pix_save','new_hot_pix_save5','new_hot_pix_save7'){
	
		open(FH, "$web_dir/Disp_dir/$file");
		open(OUT, '>./Working_dir/temp');
		OUTER:
		while(<FH>){
			chomp $_;
			@atemp = split(/:/, $_);
			$ind = "$atemp[0]$atemp[1]";
			if($ind >= $cut_date){
				last OUTER;
			}else{
				print OUT "$_\n";
			}
		}
		close(OUT);
		close(FH);
		system("mv ./Working_dir/temp $web_dir/Disp_dir/$file");
	}
	
	for($iccd = 0; $iccd < 10; $iccd++){
		open(FH, "$web_dir/Disp_dir/date_used.$iccd");
		open(OUT, '>./Working_dir/temp');
		while(<FH>){
			chomp $_;
			@atemp = split(/:/, $_);
			$ind = "$atemp[0]$atemp[1]";
			if($ind >= $cut_date){
				last OUTER;
			}else{
				print OUT  "$_\n";
			}
		}
		close(OUT);
		close(FH);
		system("mv ./Working_dir/temp $web_dir/Disp_dir/data_used.$iccd");
	}
	
	foreach $head ('change_ccd', 'change_col', 'imp_ccd', 'new_ccd', 'imp_col', 'new_col'){
		for($iccd = 0; $iccd < 10; $iccd++){
			open(FH, "$web_dir/Disp_dir/$head$iccd");
			open(OUT,'>./Working_dir/temp');
			OUTER:
			while(<FH>){
				chomp $_;
				if($_ =~ /^\#/){
					@atemp = split(/:/, $_);
					$ind = "$atemp[1]$atemp[2]";
					if($ind >= $cut_date){
						last OUTER;
					}else{
						print OUT "$_\n";
					}
				}else{
					print OUT "$_\n";
				}
			}
			close(OUT);
			close(FH);
			system("mv ./Working_dir/temp $web_dir/Disp_dir/$head$iccd");
		}
	}

	foreach $head ('hist_ccd'){
		for($iccd = 0; $iccd < 10; $iccd++){
	
			open(FH, "$web_dir/Disp_dir/$head$iccd");
			open(OUT,'>./Working_dir/temp');
			OUTER:
			while(<FH>){
				chomp $_;
				if($_ =~ /^\#/){
					@atemp = split(/\#/, $_);
					@btemp = split(/:/, $atemp[1]);
					$ind = "$btemp[0]$btemp[1]";
					if($ind >= $cut_date){
						last OUTER;
					}else{
						print OUT "$_\n";
					}
				}else{
					print OUT "$_\n";
				}
			}
			close(OUT);
			close(FH);
			system("mv ./Working_dir/temp $web_dir/Disp_dir/$head$iccd");
		}
	}


	for($iccd = 0; $iccd < 10; $iccd++){
		$temp_wdir = `ls $house_keeping/Defect/CCD$iccd/* `;
		@temp_wdir_list = split(/\s+/, $temp_wdir);
		foreach $ent (@temp_wdir_list){
			@atemp = split(/acis/, $dir);
			@btemp = split(/\_/, $atemp[1]);
			if($btemp[0] > $secdate){
				system("rm $dir");
			}
		}
	}
}


######################################################################################
# this script counts # of bad pixels from Disp_dir/hist_ccd# files.
######################################################################################

sub adjust_hist_count{

	for($iccd = 0; $iccd < 10; $iccd++){
		$file = "$web_dir/Disp_dir/hist_ccd"."$iccd";
		$out  = "$web_dir/Disp_dir/bad_pix_cnt"."$iccd";
		open(FH, "$file");
		open(OUT, ">$out");
		$cnt  = 0;
		$year = 1900;
		$date = 365;
		
		while(<FH>){
			chomp $_;
			@etemp = split(//, $_);
			@ftemp = split(/:/, $_);
			if($ftemp[0] eq '#Date'){
			}elsif($etemp[0] eq '#'){
				if($year ne 1900){
					print OUT  "$year:$date:$today_dom:$cnt\n";
					if($iccd != 5 && $iccd != 7){
						$ind = "$year.$date";
						$add = ${data.$ind}{cnt}[0] + $cnt;
						%{data.$ind} =( year => ["$year"],
						  		date => ["$date"],
						  		dom  => ["$today_dom"],
						  		cnt  => ["$add"]
								);
						push(@date_list, $ind);
					}
				}
				@atemp = split(/:/, $_);
				@btemp = split(/\#/, $atemp[0]);
				$year  = $btemp[1];
				$date  = $atemp[1];

				conv_time_to_dom();

				if($date < 10){
					$date = '00'."$date";
				}elsif($date < 100){
					$date = '0'."$date";
				}
				$cnt = 0;
			}else{
				$cnt++;
			}
		}
		close(FH);
		close(OUT);
		print OUT "$year:$date:$today_dom:$cnt\n";
		if($iccd != 5 && $iccd != 7){
			$ind = "$year.$date";
			$add = ${data.$ind}{cnt}[0] + $cnt;
			%{data.$ind} =( year => ["$year"],
			  		date => ["$date"],
			  		dom  => ["$today_dom"],
			  		cnt  => ["$add"]
					);
			push(@date_list, $ind);
		}
	
		$first = shift(@date_list);
		@new_list = ($first);

		OUTER:
		foreach $ent (@date_list){
			foreach $comp (@new_list){
				if($ent == $comp){
					next OUTER;
				}
			}
			push(@new_list, $ent);
		}

		@new_list = sort{$a <=> $b} @new_list;
		open(OUT, ">$web_dir/Disp_dir/bad_pix_cnt");

		foreach $ent (@new_list){
			print OUT "${data.$ent}{year}[0]:${data.$ent}{date}[0]:";
			print OUT "${data.$ent}{dom}[0]:${data.$ent}{cnt}[0]\n";
		}
		close(OUT);
	}
}

################################################################
### cov_time_dom: change date (yyyy:ddd) to dom             ####
################################################################

sub conv_time_to_dom {
        $tyear = $year;
        $tyday = $date;

        $totyday = 365 * ($tyear - 1999);
        if($tyear > 2000){
                $totyday++;
        }
        if($tyear > 2004){
                $totyday++;
        }
        if($tyear > 2008){
                $totyday++;
        }
        if($tyear > 2012){
                $totyday++;
        }

        $today_dom = $totyday + $tyday - 202;
}




###################################################################################
### find_more_bad_pix_info; find additional information about bad pixels        ###
###################################################################################

sub find_more_bad_pix_info{
	for($iccd = 0 ; $iccd < 10; $iccd++){
#
#---  warm pixels    
#	
		$file = "$web_dir/Disp_dir/change_ccd$iccd";
	
		$out  = "$web_dir/Disp_dir/all_past_bad_pix$iccd";
		find_all_past_bad_pix();
		${past_cnt.$iccd} = $tot;
	
		system("mv $web_dir/Disp_dir/flickering$iccd $web_dir/Disp_dir/flickering_save$iccd");
		$out  = "$web_dir/Disp_dir/flickering$iccd";
		find_flickering(); 
		${fck_cnt.$iccd} = $tot;
#
#---  hot pixels    
#	
		$file = "$web_dir/Disp_dir/change_hccd$iccd";
	
		$out  = "$web_dir/Disp_dir/all_past_hot_pix$iccd";
		find_all_past_bad_pix();
		${past_hot_cnt.$iccd} = $tot;
	
		system("mv $web_dir/Disp_dir/hflickering$iccd $web_dir/Disp_dir/hflickering_save$iccd");
		$out  = "$web_dir/Disp_dir/hflickering$iccd";
		find_flickering(); 
		${fck_cnt_h.$iccd} = $tot;
#
#--- bad columns
#	
		$file = "$web_dir/Disp_dir/change_col$iccd";
	
		$out  = "$web_dir/Disp_dir/all_past_bad_col$iccd";
		find_all_past_bad_col();
		${past_col_cnt.$iccd} = $tot;
	
		system("mv $web_dir/Disp_dir/flickering_col$iccd $web_dir/Disp_dir/flickering_col_save$iccd");
		$out  = "$web_dir/Disp_dir/flickering_col$iccd";
		find_flickering_col(); 
		${fck_cnt_col.$iccd} = $tot;
	}
	
#
#---- find bad pixels and columns which has never been observered before
#

	find_totally_new();
	find_totally_new_col();
}

####################################################################################
### find_flickering: finding flickering pixels                                   ###
####################################################################################

sub find_flickering{
#
#-----find today's date
#
	($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst) = localtime(time);
#
#---- flickering pixels are any pixels which were on and off 3 or more times in the last 90 days
#
	$tyear = $uyear +1900;
	$check_date = $uyday - 90;
	
	if ($check_date < 0){
		$tyear--;
		$check_date += 365;
	}
	
	@hold = ();
	$echk = 0;
#
#--- open up the past change file, and check which pixels are in the list
#
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(//,$_);
#
#---- finding the date of the pixels listed
#
		if($atemp[0] eq '#'){
			@btemp = split(/#Date:/, $_);
			@ctemp = split(/:/, $btemp[1]);
			$eyear = $ctemp[0];
			$eyear =~ s/\s+//g;
			$edate = $ctemp[1];

			if($eyear > $tyear){
				$echk++;
			}elsif($eyear == $tyear && $edate >= $check_date){
				$echk++;
			}
#
#---- if the date is 90 days or less, save the pixel info
#
		}else{
			if($echk > 0){
				@atest = split(/=/, $_);
				if($atest[0] eq 'New'){
					@btest = split(/\(/,$atest[1]);
					@ctest = split(/\,/, $btest[1]);
					$x = $ctest[0];
					@dtest = split(/\)/, $ctest[1]);
					$y = $dtest[0];
					$y =~ s/\s+//;
					if($y < 10){
						$y = '000'."$y";
					}elsif($y < 100){
						$y = '00'."$y";
					}elsif($y < 1000){
						$y = '0'."$y";
					}
					push(@hold, "$x.$y");
				}
			}
		}
	}
	close(FH);

#
#---- count how many times a specific pixel went on and off 
#
	@sorted_hold = sort {$a<=>$b}@hold;
	$first = shift(@sorted_hold);

	@new = ($first);
	${cnt.$first} = 1;

	OUTER:
	foreach $ent (@sorted_hold){
		foreach $comp (@new){
			if($ent == $comp){
				${cnt.$comp}++;
				next OUTER;
			}
		}
		push(@new, $ent);
		${cnt.$ent} = 1;
	}
	
	$tot = 0;
	open(OUT, ">$out");
	foreach $ent (@new){
#
#---- if the pixel went on and off 3 times or more print it out
#
		if(${cnt.$ent} > 2){
			@atemp = split(/\./, $ent);
	
			$x = $atemp[0];
	
			@btemp = split(//, $atemp[1]);
			if($btemp[0] == 0 && $btemp[1] == 0 && $btemp[2] == 0){
				$y = "   $btemp[3]";
			}elsif($btemp[0] == 0 && $btemp[1] == 0){
				$y = "  $btemp[2]$btemp[3]";
			}elsif($btemp[0] == 0){
				$y = " $btemp[1]$btemp[2]$btemp[3]";
			}else{
				$y = $atemp[1];
			}
			push(@hold, "$x,$y");

			if($x < 10){
				print OUT  "(   $x,$y)\n";
			}elsif($x < 100){
				print OUT  "(  $x,$y)\n";
			}elsif($x < 1000){
				print OUT  "( $x,$y)\n";
			}else {
				print OUT  "($x,$y)\n";
			}
			$tot++;
		}
	}
	close(OUT);
}

####################################################################################
### find_flickering_col: finding flickering cols                                 ###
####################################################################################

sub find_flickering_col{
#
#-----find today's date
#
	($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst) = localtime(time);
#
#---- flickering pixels are any cols  which were on and off 3 or more times in the last 90 days
#
	$tyear = $uyear +1900;
	$check_date = $uyday - 90;
	
	if ($check_date < 0){
		$tyear--;
		$check_date += 365;
	}
	
	@hold = ();
	$echk = 0;
#
#--- open up the past change file, and check which pixels are in the list
#
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(//,$_);
#
#---- finding the date of the pixels listed
#
		if($atemp[0] eq '#'){
			@btemp = split(/#Date:/, $_);
			@ctemp = split(/:/, $btemp[1]);
			$eyear = $ctemp[0];
			$eyear =~ s/\s+//g;
			$edate = $ctemp[1];

			if($eyear > $tyear){
				$echk++;
			}elsif($eyear == $tyear && $edate >= $check_date){
				$echk++;
			}
#
#---- if the date is 90 days or less, save the pixel info
#
		}else{
			if($echk > 0){
				@atest = split(/=/, $_);

				if($atest[0] eq 'New'){
					unless($atest[2] =~ /\d/){
						$atest[1] =~ s/\s+//;
						push(@hold, $atest[1]);
					}
				}
			}
		}
	}
	close(FH);

#
#---- count how many times a specific pixel went on and off 
#
	@sorted_hold = sort {$a<=>$b}@hold;
	$first = shift(@sorted_hold);

	@new = ($first);
	${cnt.$first} = 1;
	OUTER:
	foreach $ent (@sorted_hold){
		foreach $comp (@new){
			if($ent == $comp){
				${cnt.$comp}++;
				next OUTER;
			}
		}
		push(@new, $ent);
		${cnt.$ent} = 1;
	}
	
	$tot = 0;
	open(OUT, ">$out");
#
#---- if the pixel went on and off 3 times or more print it out
#
	foreach $ent (@new){
		if(${cnt.$ent} > 2){
			print OUT  "$ent\n";
			$tot++;
		}
	}
	close(OUT);
}	


#################################################################################
### find_all_past_bad_pix: make a list of all bad pixels in the past         ####
#################################################################################

sub find_all_past_bad_pix {

	@hold = ();
#
#----- open pxiel change history file, and find all bad pixels in the past
#
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/=/, $_);
		if($atemp[0] eq 'New'){
			@btemp = split(/\(/,$atemp[1]);
			@ctemp = split(/\,/, $btemp[1]);
			$x = $ctemp[0];
			@dtemp = split(/\)/, $ctemp[1]);
			$y = $dtemp[0];
			$y =~ s/\s+//;
			if($y < 10){
				$y = '000'."$y";
			}elsif($y < 100){
				$y = '00'."$y";
			}elsif($y < 1000){
				$y = '0'."$y";
			}
			push(@hold, "$x.$y");
		}
	}
	close(FH);
	
#
#----- remove duplicates
#
	@sorted_hold = sort {$a<=>$b}@hold;
	$first = shift(@sorted_hold);

	@new = ($first);
	OUTER:
	foreach $ent (@sorted_hold){
		foreach $comp (@new){
			if($ent eq $comp){
				next OUTER;
			}
		}
		push(@new, $ent);
	}	
	$test_cnt = 0;
	foreach $ent  (@new){
		if($ent =~ /\d/){
			$test_cnt++;
		}
	}
	
	$tot = 0;
	open(OUT, "> $out");
	if($test_cnt > 0){
		foreach $ent (@new){
			@atemp = split(/\./, $ent);
		
			$x = $atemp[0];
			
			@btemp = split(//, $atemp[1]);
			if($btemp[0] == 0 && $btemp[1] == 0 && $btemp[2] == 0){
				$y = "   $btemp[3]";
			}elsif($btemp[0] == 0 && $btemp[1] == 0){
				$y = "  $btemp[2]$btemp[3]";
			}elsif($btemp[0] == 0){
				$y = " $btemp[1]$btemp[2]$btemp[3]";
			}else{
				$y = $atemp[1];
			}
			push(@hold, "$x,$y");
			if($x < 10){
				print OUT "(   $x,$y)\n";
			}elsif($x < 100){
				print OUT "(  $x,$y)\n";
			}elsif($x < 1000){
				print OUT "( $x,$y)\n";
			}else {
				print OUT "($x,$y)\n";
			}
			$tot++;
		}
	}
	close(OUT);
}

#################################################################################
### find_all_past_bad_col: make a list of all bad columns in the past        ####
#################################################################################

sub find_all_past_bad_col {

	@hold = ();
#
#----- open pxiel change history file, and find all bad pixels in the past
#
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/=/, $_);
		if($atemp[0] eq 'New'){
			unless($atemp[2] =~ /\d/){
				push(@hold, $atemp[1]);
			}
		}
	}
	close(FH);
	
#
#----- remove duplicates
#
	@sorted_hold = sort {$a<=>$b}@hold;
	$first = shift(@sorted_hold);

	@new = ($first);
	OUTER:
	foreach $ent (@sorted_hold){
		foreach $comp (@new){
			if($ent eq $comp){
				next OUTER;
			}
		}
		push(@new, $ent);
	}	
	
	$test_cnt = 0;
	foreach $ent  (@new){
		if($ent =~ /\d/){
			$test_cnt++;
		}
	}
	$tot = 0;
	open(OUT, "> $out");
	if($test_cnt > 0){
		foreach $ent (@new){
			print OUT "$ent\n";
			$tot++;
		}
	}
	close(OUT);
}

###############################################################################
### find_totally_new: find first time bad pixels ---- calling new_pix       ###
###############################################################################

sub find_totally_new {
#
#---- warm pixels
#
	$file1 = "$web_dir/Disp_dir/totally_new*";
	$file2 = "$web_dir/Disp_dir/ccd*";
	$file3 = "$web_dir/Disp_dir/all_past_bad_pix";
	$file4 = "$web_dir/Disp_dir/totally_new";
	$out_ind = 'tot_new_pix';
	new_pix();
#
#---- hot pixels
#
	$file1 = "$web_dir/Disp_dir/totally_new_hot*";
	$file2 = "$web_dir/Disp_dir/hccd*";
	$file3 = "$web_dir/Disp_dir/all_past_hot_pix";
	$file4 = "$web_dir/Disp_dir/totally_new_hot";
	$out_ind = 'tot_new_hot';
	new_pix();
}

###############################################################################
### new_pix: find first time bad pixels --- main script                    ####
###############################################################################

sub new_pix {
#
#--- find today's date
#

	($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst) = localtime(time);
	$uyear += 1900;

#
#--- find which ccd has the new bad pixel in past
#
	$temp_file = `ls $file1`;
	@totally_new = ();
	@totally_new = split(/\s+/, $temp_file);

	foreach $file (@totally_new){
		open(FH, "$file");
		open(OUT, '>./Working_dir/zout');
		while(<FH>){
			chomp $_;
			@atemp = split(/\)/, $_);
			$c_date = $atemp[1];
			$c_date =~ s/\s+//g;
			@btemp = split(/:/, $c_date);
			$c_year = $btemp[0];
			$c_day  = $btemp[1];
			$c_day14 = $c_day + 14;
#
#----- check whether the bad pixel is listed 14 days or more. if it is, remove
#
			if($c_day14 > 365){
				$c_year++;
				$c_day14 -= 365;
			}
			if($c_year > $uyear) {
				print OUT "$_\n";
			}elsif($c_year == $uyear && $c_day14 >= $uyday){
				print OUT "$_\n";
			}
		}
		close(OUT);
		close(FH);
		system("mv ./Working_dir/zout $file");
	}
#
#---- find today's bad pixels
#
	$temp_file = `ls $file2`;
	@ccd_list  = split(/\s+/, $temp_file);

	foreach $file (@ccd_list){
		@atemp = split(/ccd/, $file);
		$kccd  = $atemp[1];
#
#---- first read all bad pxiels appeared in the past
#
		$comp_file = "$file3"."$kccd";

		@x_save = ();
		@y_save = ();
		$comp_cnt = 0;

		open(FH, "$comp_file");
		while(<FH>){
			chomp $_;
			@atemp = split(/\(/, $_);
			@btemp = split(/\)/, $atemp[1]);
			@ctemp = split(/\,/, $btemp[0]);
			$x = $ctemp[0];
			$x =~ s/\s+//g;
			push(@x_save, $x);
			$y = $ctemp[1];
			$y =~ s/\s+//g;
			push(@y_save, $y);
			$comp_cnt++;
		}
		close(FH);
#
#--- today's list
#
		open(FH, "$file");
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/, $_);
			$x = $atemp[0];
			$x =~ s/\s+//g;
			$y = $atemp[1];
			$y =~ s/\s+//g;
#
#--- indicator for new bad pixels
#
			$new_ind = 0;

			OUTER:
			for($k = 0; $k < $comp_cnt; $k++){
				if($x == $x_save[$k] && $y == $y_save[$k]){
					$new_ind = 1;
					last OUTER;
				}
			}
			${$out_ind.$kccd} = 0;

			if($new_ind == 0){
				$first_day = "$uyear:$uyday";
				open(OUT,">>$web_dir/Disp_dir/totally_new$kccd");
				print OUT "($x,$y)\t$first_day\n";
				close(OUT);
				${$out_ind.$kccd}++;
			}
		}
	}
}

###############################################################################
### find_totally_new_col: find first time bad columns 			    ###
###############################################################################

sub find_totally_new_col {

#
#------ find today's date
#
	($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst) = localtime(time);
	$uyear += 1900;
#
#------- find which ccd has the new bad columns in past
#
	$temp_file = `ls $web_dir/Disp_dir/totally_new_col*`;
	@totally_new = split(/\s+/, $temp_file);

	foreach $file (@totally_new){
		open(FH, "$file");
		open(OUT, '>./Working_dir/zout');
		while(<FH>){
			chomp $_;
			@atemp = split(/\)/, $_);
			$c_date = $atemp[1];
			$c_date =~ s/\s+//g;
			@btemp = split(/:/, $c_date);
			$c_year = $btemp[0];
			$c_day  = $btemp[1];
			$c_day14 = $c_day + 14;
#
#----- check whether the bad pixel is listed 14 days or more. if it is, remove
#
			if($c_day14 > 365){
				$c_year++;
				$c_day14 -= 365;
			}

			if($c_year > $uyear) {
				print OUT "$_\n";
			}elsif($c_year == $uyear && $c_day14 >= $uyday){
				print OUT "$_\n";
			}
		}
		close(OUT);
		close(FH);
		system("mv ./Working_dir/zout $file");
	}
#
#---- find today's bad pixels
#
	$temp_file = `ls $web_dir/Disp_dir/col*`;
	@col_list  = split(/\s+/, $temp_file);

	foreach $file (@col_list){
		@atemp = split(/col/, $file);
		$kccd = $atemp[1];
#
#---- first read all bad pxiels appeared in the past
#
		$comp_file = "$web_dir/Disp_dir/all_past_bad_col"."$kccd";

		@col_save = ();
		$comp_cnt = 0;

		open(FH, "$comp_file");
		while(<FH>){
			chomp $_;
			push(@col_save, $_);
			$comp_cnt++;
		}
		close(FH);
#
#--- today's list
#
		open(FH, "$file");
		while(<FH>){
			chomp $_;
			$col = $_;
			$col =~ s/\s+//g;
#
#--- indicator for new bad pixels
#
			$new_ind = 0;

			OUTER:
			for($k = 0; $k < $comp_cnt; $k++){
				if($col == $col_save[$k]){
					$new_ind = 1;
					last OUTER;
				}
			}
			${tot_new_col.$kccd} = 0;

			if($new_ind == 0){
				$first_day = "$uyear:$uyday";
				open(OUT,">>$web_dir/Disp_dir/totally_new_col$kccd");
				print OUT "$col\t$first_day\n";
				close(OUT);
				${tot_new_col.$kccd}++;
			}
		}
		close(FH);
	}
}

