#!/usr/bin/perl 
use PGPLOT;

#################################################################################################
#												#
#	plot_front_ccd_histry.perl: plot front ccd combined warm pixel history			#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: Feb 22, 2008							#
#												#
#################################################################################################

#--- output directory

$bin_dir       = '/data/mta/MTA/bin/';
#$bin_dir      = '//data/mta/Script/ACIS/Bad_pixels/Test/';
$bdat_dir      = '/data/mta/MTA/data/';
$web_dir       = '/data/mta/www/mta_bad_pixel/';
$old_dir       = $web_dir;
$house_keeping = '/data/mta/www/mta_bad_pixel/house_keeping/';


pgbegin(0, '"./pgplot.ps"/cps',1,1);
pgsubp(1,3);
pgsch(2);
pgslw(4);

@x    = ();
@y    = ();
$tot  = 0;
foreach $ccd (0, 1, 2, 3, 4, 6, 8, 9){

#
#---- warm pixel counts
#
	$file = "$web_dir".'/Disp_dir/ccd'."$ccd".'_cnt';
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/<>/, $_);

		@btemp = split(/:/, $atemp[2]);
		if($ccd == 0){
			push(@x, $atemp[0]);
			$y[$atemp[0]] = $btemp[1];
			$tot++;
		}else{
			$y[$atemp[0]] += $btemp[1];
		}
	}
	close(FH);
}


@temp = sort{$a<=>$b} @x;
$xmin = 0;
$xmax = 1.1 * $temp[$tot -1];

@temp = sort{$a<=>$b} @y;
$med  = $temp[$tot/2];
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

pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);

pgmove($x[0], $y[0]);
for($i = 1; $i < $tot; $i++){
	pgdraw($x[$i], $y[$i]);
}

pglabel("Time (DOM)", "Counts", "Numbers of Warm Pixels: Front Side CCDs");

#
#----- potentintial bad pixel counts
#

@x    = ();
@y    = ();
$tot  = 0;
foreach $ccd (0, 1, 2, 3, 4, 6, 8, 9){
	$file = "$web_dir".'/Disp_dir/bad_ccd'."$ccd".'_cnt';
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/<>/, $_);

		@btemp = split(/:/, $atemp[2]);
		if($ccd == 0){
			push(@x, $atemp[0]);
			$y[$atemp[0]] = $btemp[1];
			$tot++;
		}else{
			$y[$atemp[0]] += $btemp[1];
		}
	}
	close(FH);
}

@temp = sort{$a<=>$b} @x;
$xmin = 0;
$xmax = 1.1 * $temp[$tot -1];

@temp = sort{$a<=>$b} @y;
$med  = $temp[$tot/2];
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

pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);

pgmove($x[0], $y[0]);
for($i = 1; $i < $tot; $i++){
	pgdraw($x[$i], $y[$i]);
}

$title = "Numbers of Potential Warm Pixels (Warm Pixels + Flickering Pixels)";
$title = "$title".": Front Side CCDs ";
pglabel("Time (DOM)", "Counts", "$title");

#
#----- cumulative warm pixel counts
#

@x    = ();
@y    = ();
$tot  = 0;
foreach $ccd (0, 1, 2, 3, 4, 6, 8, 9){
	$file = "$web_dir".'/Disp_dir/cum_ccd'."$ccd".'_cnt';
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/<>/, $_);

		@btemp = split(/:/, $atemp[2]);
		if($ccd == 0){
			push(@x, $atemp[0]);
			$y[$atemp[0]] = $btemp[1];
			$tot++;
		}else{
			$y[$atemp[0]] += $btemp[1];
		}
	}
	close(FH);
}

@temp = sort{$a<=>$b} @x;
$xmin = 0;
$xmax = 1.1 * $temp[$tot -1];

@temp = sort{$a<=>$b} @y;
$med  = $temp[$tot/2];
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

pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);

pgmove($x[0], $y[0]);
for($i = 1; $i < $tot; $i++){
	pgdraw($x[$i], $y[$i]);
}

$title = "Cumulative Numbers of Pixels Which Were Warm Pixels during the Mission: Front Side CCDs";
pglabel("Time (DOM)", "Counts", "$title");

pgclos();

$out_gif = 'hist_plot_front_side.gif';

system("echo ''|gs -sDEVICE=ppmraw  -r128x128 -q -NOPAUSE -sOutputFile=-  ./pgplot.ps|pnmcrop| pnmflip -r270 | ppmtogif > $out_gif");
	system("rm pgplot.ps");

		