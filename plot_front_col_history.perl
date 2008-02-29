#!/usr/bin/perl 
use PGPLOT;

#################################################################################################
#												#
#	plot_front_col_hsotry.perl: plot front col combined warm pixel history			#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: Feb 25, 2008							#
#												#
#################################################################################################


#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
#$bin_dir      = '//data/mta/Script/ACIS/Bad_pixels/Test/';
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

$today = "$end_year:$uyday";
$dom = ch_ydate_to_dom($today);

$xmin = 0;
$xmax = 1.1 * $dom;


pgbegin(0, '"./pgplot.ps"/cps',1,1);
pgsubp(1,3);
pgsch(2);
pgslw(4);

@x    = ();
@y    = ();
$tot  = 0;
for($i = 0; $i < $dom; $i++){
	$x[$i] = $i;
	$y[$i] = 0;
	$tot++;
}

foreach $ccd (0, 1, 2, 3, 4, 6, 8, 9){

#
#---- warm pixel counts
#
	$file = "$web_dir".'/Disp_dir/col'."$ccd".'_cnt';
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/<>/, $_);
		@btemp = split(/:/, $atemp[2]);

		if($ccd == 0){
#			push(@x, $atemp[0]);
			$y[$atemp[0]] = $btemp[1];
#			$tot++;
		}else{
			$y[$atemp[0]] += $btemp[1];
		}
	}
	close(FH);
}


@temp = sort{$a<=>$b} @y;
$med  = $temp[int($tot/2)];
$max  = $temp[int(0.98 * $tot)];
$min  = $temp[int(0.02 * $tot)];
if($min - 5 < 0){
	$ymin = 0;
}else{
	$ymin = $min;
}
$diff = $temp[$tot-1] - $max;
if($diff > 10){
	$ymax = int(1.4 * $max) + 3;
}else{ 
	$ymax = int(1.1 * $temp[$tot-1]) + 1;
}
$ymin = 0; 
$ymax = 1.1 * $temp[$tot -1];

pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);

pgmove($x[0], $y[0]);
for($i = 1; $i < $tot; $i++){
	pgdraw($x[$i], $y[$i]);
}

pglabel("Time (DOM)", "Counts", "Numbers of Warm Columns: Front Side CCDs");

#
#----- potentintial bad pixel counts
#

@x    = ();
@y    = ();
for($i = 0; $i < $dom; $i++){
	$x[$i] = $i;
	$y[$i] = 0;
}
$tot  = 0;
foreach $ccd (0, 1, 2, 3, 4, 6, 8, 9){
	$file = "$web_dir".'/Disp_dir/bad_col'."$ccd".'_cnt';
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/<>/, $_);
		@btemp = split(/:/, $atemp[2]);
		if($ccd == 0){
#			push(@x, $atemp[0]);
			$y[$atemp[0]] = $btemp[1];
			$tot++;
		}else{
			$y[$atemp[0]] += $btemp[1];
		}
	}
	close(FH);
}

@temp = sort{$a<=>$b} @y;
$med  = $temp[int($tot/2)];
$max  = $temp[int(0.98 * $tot)];
$min  = $temp[int(0.02 * $tot)];
if($min - 5 < 0){
	$ymin = 0;
}else{
	$ymin = $min;
}
$diff = $temp[$tot-1] - $max;
if($diff > 10){
	$ymax = int(1.4 * $max) + 3;
}else{ 
	$ymax = int(1.1 * $temp[$tot-1]) + 1;
}

$ymin = 0; 
$ymax = 1.1 * $temp[$tot-1];

pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);

pgmove($x[0], $y[0]);
for($i = 1; $i < $tot; $i++){
	pgdraw($x[$i], $y[$i]);
}

$title = "Numbers of Potential Warm Columns (Warm Columns + Flickering Columns)";
$title = "$title".": Front Side CCDs ";
pglabel("Time (DOM)", "Counts", "$title");

#
#----- cumulative warm pixel counts
#

@x    = ();
@y    = ();
$tot  = 0;
for($i = 0; $i < $dom; $i++){
	$x[$i] = $i;
	$y[$i] = 0;
	$tot++;
}
foreach $ccd (0, 1, 2, 3, 4, 6, 8, 9){
	$file = "$web_dir".'/Disp_dir/cum_col'."$ccd".'_cnt';
	$chk1 = 0;
	$chk2 = 0;
	open(FH, "$file");
	OUTER:
	while(<FH>){
		chomp $_;
		@atemp = split(/<>/, $_);
		@btemp = split(/:/, $atemp[2]);
		if($ccd == 0){
			if($atemp[0] == $chk1){
				next OUTER;
			}
			if($btemp[1] < $chk2){
				$btemp[1] = $chk2;
				$y[$atemp[0]] = $btemp[1];
			}else{
				$y[$atemp[0]] = $btemp[1];
				$chk2 = $btemp[1];
			}
			$chk1 = $atemp[0];
		}else{
			if($atemp[0] == $chk1){
				next OUTER;
			}
			if($btemp[1] < $chk2){
				$btemp[1] = $chk2;
				$y[$atemp[0]] += $btemp[1];
			}else{
				$y[$atemp[0]] += $btemp[1];
				$chk2 = $btemp[1];
			}
			$chk1 = $atemp[0];
		}
	}
	close(FH);
}

@temp = sort{$a<=>$b} @y;
$med  = $temp[int($tot/2)];
$max  = $temp[int(0.98 * $tot)];
$diff = 1.1 * $max - $med;

$min  = $med - $diff;
if($min < 0){
	$ymin = 0;
}else{
	$ymin = $min;
}

$ymax = $med + $diff;
$chk  = $ymax - $temp[$tot -1];
if($chk < 0){
	$ymax = int(1.1 * $temp[$tot-1]) + 1;
}elsif($chk > 10){
	$ymax = $temp[$tot -1] + 10;
}
$ymin = 0; 
$ymax = 1.1 * $temp[$tot-1];

pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);

pgmove($x[0], $y[0]);
$chk = 0;
for($i = 1; $i < $tot; $i++){
	if($y[$i] < $chk){
		pgdraw($x[$i], $chk);
	}else{
		pgdraw($x[$i], $y[$i]);
		$chk = $y[$i];
	}
}

$title = "Cumulative Numbers of Columns Which Were Warm Columns during the Mission: Front Side CCDs";
pglabel("Time (DOM)", "Counts", "$title");

pgclos();

$out_gif = 'hist_col_plot_front_side.gif';

system("echo ''|gs -sDEVICE=ppmraw  -r128x128 -q -NOPAUSE -sOutputFile=-  ./pgplot.ps|pnmcrop| pnmflip -r270 | ppmtogif > $out_gif");
	system("rm pgplot.ps");


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


