#!/usr/bin/perl

#########################################################################################
#											#
#	fill_ccd_hist.perl: filling missing dates of col hist data with a null data	#
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


#
#--- find today's date
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
$end_year = 1900 + $uyear;
$uyday++;

#
#--- first make a full list of dom<--->year<>ydate list
#

for($year = 1999; $year <= $end_year; $year++){
	$end_day = 365;
	$chk     = 4 * int(0.25 * $year);
	if($chk == $year){
		$end_day = 366;
	}
	$last_dom = 0;
	OUTER:
	for($yday = 1; $yday <= $end_day; $yday++){
		if($year == 1999 && $yday < 202){
			next OUTER;
		}
		if($year == $end_year && $yday > $uyday){
			last OUTER;
		}

		$in_line    = "$year".":$yday";
		$dom        = ch_ydate_to_dom($in_line);
		$data[$dom] = $in_line;
		$last_dom   = $dom;
	}
}

#
#--- now fill the missing date
#

for($ccd = 0; $ccd < 10; $ccd++){
	$in_name = "$web_dir".'/Disp_dir/hist_ccd'."$ccd";
	open(FH, "$in_name");
	open(OUT, "> temp_out");
	$counter = 1;
	OUTER:
	while(<FH>){
		chomp $_;
		@atemp = split(/<>/, $_);
#
#--- if there is a data, use it.
#
		if($atemp[0] == $counter){
			print OUT "$_\n";
			$counter++;
			next OUTER;
		}
#
#--- if the date is missing, add the date to the list
#
		for($i = $counter; $i < $atemp[0]; $i++){
			print OUT  "$i".'<>'."$data[$i]".'<>'."\n";
		}
		print OUT "$_\n";
		$counter = $atemp[0]+1;
	}
	close(FH);
#
#--- fill up the last bits of dates
#
	if($counter < $last_dom){
		for($i = $counter; $i < $last_dom; $i++){
			print OUT "$i".'<>'."$data[$i]".'<>'."\n";
		}
	}
	close(OUT);

	system("mv temp_out $in_name");
}
	
##################################################################################
### ch_ydate_to_dom: change yyyy:ddd to dom (date from 1999:202)               ###
##################################################################################

sub ch_ydate_to_dom{
        ($in_date) = @_;
        chomp $in_date;
        @htemp     = split(/:/, $in_date);
        $hyear     = $htemp[0];
        $hyday     = $htemp[1];
        $hdiff     = $hyear - 1999;
        $acc_date  = $hdiff * 365;

        $hdiff    += 2;
        $leap_corr = int(0.25 * $hdiff);

        $acc_date += $leap_corr;
        $acc_date += $hyday;
        $acc_date -= 202;
        return($acc_date);
}

