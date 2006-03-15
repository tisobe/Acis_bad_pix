#!/usr/bin/perl
use PGPLOT;


#########################################################################################
#											#
#	acis_bias_moving_avg.perl: fit a moving average, 5th degree polynomial, 	#
#				  and envelope to bias-overclock data			#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: 03/14/2006								#
#											#
#########################################################################################

#
#----- an example input: /data/mta_www/mta_bias_bkg/Bias_save/CCD3/quad0
#

$file = $ARGV[0];
chomp $file;
#
#----- since the plotting range for CCD7 is siginificantly different from others,
#----- we need to mark it
#
$special = 0;
if($file =~ /CCD7/){
	$special = 7;
}
#
#--- extract CCD name and Node #
#
@atemp = split(/\//, $file);
$ncnt = 0;
foreach(@atemp){
	$ncnt++;
}
#
#--- a gif file name is here, something like: bias_plot_CCD3_quad0.gif
#
$out_name = 'bias_plot_'."$atemp[$ncnt-2]".'_'."$atemp[$ncnt-1]".'.gif';

#
#--- start reading data
#
@line = ();
@time = ();
@bias = ();
@err  = ();
@ovck = ();
@bmo  = ();
$cnt  = 0;

open(FH, "$file");
while(<FH>){
	chomp $_;
	push(@line, $_);
}
close(FH);
#
#---- sort data with date, and then remove duplicated lines
#
@temp = sort{$a<=>$b} @line;
$first = shift(@temp);
@new = ($first);
OUTER:
foreach $ent (@temp){
	foreach $comp (@new){
		if($ent eq $comp){
			next OUTER;
		}
	}
	push(@new, $ent);
}

$chk = 0;
$sum = 0;
foreach $ent (@new){
	@atemp = split(/\s+/, $ent);
#
#---- dom is  day of mission
#
	$dom   = $atemp[0]/86400 - 567;
#
#---- diff is difference between bias - overclock
#
	$diff = $atemp[1] - $atemp[3];
#
#---- there are a few cases, the diff value changed significantly. assume that that happens
#---- if error for the bias changed to larger than 20 (normally around 1), and last more than 10 times
#---- consequently.
#---- we call that time is to $stop_date.
#
	if($atemp[2] > 20 && $chk ==  0){
		$stop_date = $dom;
		if($err[$cnt-1] > 20 && $err[$cnt-2] > 20 && $err[$cnt-3] > 20 && $err[$cnt-10] > 20){
			$stop_date = $time[$cnt-11];
			$chk++;
		}
	}
	push(@time, $dom);
	push(@bias, $atemp[1]);
	push(@err,  $atemp[2]);
	push(@ovck, $atemp[3]);
	push(@bmo, $diff);
	if($chk == 0){
		$stop_date = $dom;
	}
	$sum += $diff;
	$cnt++;
}

#
#--- tmp_avg will be used to find outlayers for CCD 7
#
$tmp_avg = $sum/$cnt;

@date  = ();
@mvavg = ();
@sigma = ();
@max_sv = ();
@min_sv = ();
$tot   = 0;
#
#---- now computing 30 day moving average
#
$arange = 30;
#
#---- setting upper and lower rnage of moving arvarge computation this one is for CCD7
#---- others are set between -0.5 and 2.0
#
$sp_bot = $tmp_avg -2;
$sp_top = $tmp_avg +3;
for($i = $arange; $i < $cnt; $i++){
	$sum = 0;
	$sum2 = 0;
	$max = -1.e+5;
	$min = 1.e+5;
	if($time[$i] > $stop_date){
		last;
	}
#
#---- add the last 30 days of data
#
	for($j = 0; $j < $arange; $j++){
		if($special == 7){
			if($bmo[$i - $j] < $sp_bot || $bmo[$i - $j] > $sp_top){
				next;
			}
		}else{
			if($bmo[$i - $j] <-0.5 || $bmo[$i - $j] > 2.0){
				next;
			}
		}
		$sum += $bmo[$i - $j];
		$sum2+= $bmo[$i - $j] * $bmo[$i - $j];
		if($bmo[$i - $j] > $max){
			$max = $bmo[$i - $j];
		}
		if($bmo[$i - $j] < $min){
			$min = $bmo[$i - $j];
		}
	}
	$avg = $sum/$arange;
	$std = sqrt($sum2/$arange - $avg * $avg);
	push(@mvavg, $avg);
	push(@sigma, $std);
	push(@max_sv, $max);
	push(@min_sv, $min);
	push(@date, $time[$i]);
	$tot++;
}
#
#---- here we try to find a average of central part of data for CCD7
#
$sum = 0;
$scnt = 0;
$st = int(0.40 * $tot);
$ed = int(0.60 * $tot);
for($j = $st; $j < $ed; $j++){
	$sum += $mvavg[$j];
	$scnt++;
}
$all_avg = $sum/$scnt;

@temp = sort{$a<=>$b}@time;
$xmin = $temp[0];
$xmax = $temp[$cnt-1];

if($special == 7){
	$int_avg = int($all_avg);
	$idiff = $all_avg - $int_avg;
	if($idiff > 0.875){
		$int_avg++;
	}elsif($idiff > 0.625){
		$int_avg += 0.75;
	}elsif($idiff > 0.375){
		$int_avg += 0.5;
	}elsif($idiff > 0.125){
		$int_avg += 0.25;
	}
#
#---- here is a plotting range for CCD7
#	
	$ymin = 4.0;
	$ymax = 5.5;
	$ymin = $int_avg - 0.5;
	$ymax = $int_avg + 1.5;
}else{
#
#--- plotting range for all others
#
	$ymin =  -0.5;
	$ymax =  1.5;
}

pgbegin(0, "/cps",1,1);
pgsubp(1,2);
pgsch(2);
pgslw(2);
pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);
#
#---- data point plot
#
for($m = 0; $m < $cnt; $m++){
	pgpt(1,$time[$m], $bmo[$m], -1);
}

pgsci(4);
#
#---- 5th degree polynomial fitting: bottom envelope
#
$nterms = 5;
$mode = 0;
$npts = $tot;
@x_in = @date;
@y_in = @min_sv;
svdfit($npts, $nterms);

$yest = pol_val($nterms, $date[0]);
pgmove($date[0], $yest);
for($m = 1; $m < $tot; $m++){
	$yest = pol_val($nterms, $date[$m]);
	pgdraw($date[$m], $yest);
}
#
#---- 5th degree polynomial fitting: top envelope
#
$nterms = 5;
$mode = 0;
$npts = $tot;
@x_in = @date;
@y_in = @max_sv;
svdfit($npts, $nterms);
#
#---- moving average line
#
$yest = pol_val($nterms, $date[0]);
pgmove($date[0], $yest);
for($m = 1; $m < $tot; $m++){
	$yest = pol_val($nterms, $date[$m]);
	pgdraw($date[$m], $yest);
}
pgsci(1);

pgsci(2);
pgmove($date[0], $mvavg[0]);
for($m = 1; $m < $tot; $m++){
	pgdraw($date[$m], $mvavg[$m]);
}
pgsci(1);
#
#---- 5th degree polynomial fitting:  moving average
#---- avoid earlier data, since the variations are too large to fit
#---- a nice smooth line
#
$nterms = 5;
$mode = 0;
$npts = 0;
$pstart = 50;
$pend   = $xmax;
@x_in = ();
@y_in = ();

for($m = 0; $m < $cnt; $m++){
	if($date[$m] > $pstart && $date[$m] < $pend){
		$x_in[$npts] = $date[$m];
		$y_in[$npts] = $mvavg[$m];
		$npts++;
	}
}

svdfit($npts, $nterms);

pgsci(3);
$xnum  = int($xmax);

$yest = pol_val($nterms,$pstart);
pgmove($pstart, $yest);
#
#---- stop_date terminates moving average plots
#
for($m = $pstart; $m < $pend; $m++){
	if($m> $stop_date){
		last;
	}
	$yest = pol_val($nterms, $m);
	pgdraw($m, $yest);
}
pgsci(1);


pglabel("Time (DOM)", "Bias - OverClock", "$title");

#
#---- plotting standard deviation of moving averages
#

pgenv($xmin, $xmax, 0, 0.5, 0, 0);

pgmove($date[0], $sigma[0]);
for($m = 1; $m< $tot; $m++){
	pgdraw($date[$m], $sigma[$m]);
}
#
#---- 5th degree polynomial fitting: standard deviations
#
$nterms = 5;
$mode = 0;
$npts = $tot;
$pstart = 50;
$pend   = $xmax;
@x_in = @date;
@y_in = @sigma;

svdfit($npts, $nterms);

$yest = pol_val($nterms,$pstart);
pgsci(2);
pgmove($pstart, $yest);
for($m = 1; $m < $tot; $m++){
	$yest = pol_val($nterms,$date[$m]);
	pgdraw($date[$m], $yest);
}
pgsci(1);


pglabel("Time (DOM)", "Sigma of Moving Average", "$title");

pgclos();
system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  ./pgplot.ps|/data/mta/MTA/bin/pnmcrop| /data/mta/MTA/bin/pnmflip -r270 |/data/mta/MTA/bin/ppmtogif > $out_name");

system("rm pgplot.ps");

########################################################################
###svdfit: polinomial line fit routine                               ###
########################################################################

######################################################################
#       Input:  @x_in: independent variable list
#               @y_in: dependent variable list
#               @sigmay: error in dependent variable
#               $npts: number of data points
#               $mode: mode of the data set mode = 0 is fine.
#               $nterms: polinomial dimention
#               input takes: svdfit($npts, $nterms);
#
#       Output: $a[$i]: coefficient of $i-th degree
#               $chisq: chi sq of the fit
#
#       Sub:    svbksb, svdcmp, pythag, funcs
#               where fun could be different (see at the bottom)
#
#       also see pol_val at the end of this file
#
######################################################################

sub svdfit{
#
#----- this code was taken from Numerical Recipes. the original is FORTRAN
#

        $tol = 1.e-5;

        my($ndata, $ma, @x, @y, @sig, @w, $i, $j, $tmp, $ma, $wmax, $sum,$diff);
        ($ndata, $ma) = @_;
        for($i = 0; $i < $ndata; $i++){
                $j = $i + 1;
                $x[$j] = $x_in[$i];
                $y[$j] = $y_in[$i];
                $sig[$j] = $sigmay[$i];
        }
#
#---- accumulate coefficients of the fitting matrix
#
        for($i = 1; $i <= $ndata; $i++){
                funcs($x[$i], $ma);
                if($mode == 0){
                        $tmp = 1.0;
                        $sig[$i] = 1.0;
                }else{
                        $tmp = 1.0/$sig[$i];
                }
                for($j = 1; $j <= $ma; $j++){
                        $u[$i][$j] = $afunc[$j] * $tmp;
                }
                $b[$i] = $y[$i] * $tmp;
        }
#
#---- singular value decompostion sub
#
        svdcmp($ndata, $ma);            ###### this also need $u[$i][$j] and $b[$i]
#
#---- edit the singular values, given tol from the parameter statements
#
        $wmax = 0.0;
        for($j = 1; $j <= $ma; $j++){
                if($w[$j] > $wmax) {$wmax = $w[$j]}
        }
        $thresh = $tol * $wmax;
        for($j = 1; $j <= $ma; $j++){
                if($w[$j] < $thresh){$w[$j] = 0.0}
        }

        svbksb($ndata, $ma);            ###### this also needs b, u, v, w. output is a[$j]
#
#---- evaluate chisq
#
        $chisq = 0.0;
        for($i = 1; $i <= $ndata; $i++){
                funcs($x[$i], $ma);
                $sum = 0.0;
                for($j = 1; $j <= $ma; $j++){
                        $sum  += $a[$j] * $afunc[$j];
                }
                $diff = ($y[$i] - $sum)/$sig[$i];
                $chisq +=  $diff * $diff;
        }
}


########################################################################
### svbksb: solves a*x = b for a vector x                            ###
########################################################################

sub svbksb {
#
#----- this code was taken from Numerical Recipes. the original is FORTRAN
#
        my($m, $n, $i, $j, $jj, $s);
        ($m, $n) = @_;
        for($j = 1; $j <= $n; $j++){
                $s = 0.0;
                if($w[$j] != 0.0) {
                        for($i = 1; $i <= $m; $i++){
                                $s += $u[$i][$j] * $b[$i];
                        }
                        $s /= $w[$j];
                }
                $tmp[$j] = $s;
        }

        for($j = 1; $j <= $n; $j++){
                $s = 0.0;
                for($jj = 1; $jj <= $n; $jj++){
                        $s += $v[$j][$jj] * $tmp[$jj];
                }
                $i = $j -1;
                $a[$i] = $s;
        }
}

########################################################################
### svdcmp: compute singular value decomposition                     ###
########################################################################

sub svdcmp {
#
#----- this code wass taken from Numerical Recipes. the original is FORTRAN
#
        my ($m, $n, $i, $j, $k, $l, $mn, $jj, $x, $y, $s, $g);
        ($m, $n) = @_;

        $g     = 0.0;
        $scale = 0.0;
        $anorm = 0.0;

        for($i = 1; $i <= $n; $i++){
                $l = $i + 1;
                $rv1[$i] = $scale * $g;
                $g = 0.0;
                $s = 0.0;
                $scale = 0.0;
                if($i <= $m){
                        for($k = $i; $k <= $m; $k++){
                                $scale += abs($u[$k][$i]);
                        }
                        if($scale != 0.0){
                                for($k = $i; $k <= $m; $k++){
                                        $u[$k][$i] /= $scale;
                                        $s += $u[$k][$i] * $u[$k][$i];
                                }
                                $f = $u[$i][$i];

                                $ss = $f/abs($f);
                                $g = -1.0  * $ss * sqrt($s);
                                $h = $f * $g - $s;
                                $u[$i][$i] = $f - $g;
                                for($j = $l; $j <= $n; $j++){
                                        $s = 0.0;
                                        for($k = $i; $k <= $m; $k++){
                                                $s += $u[$k][$i] * $u[$k][$j];
                                        }
                                        $f = $s/$h;
                                        for($k = $i; $k <= $m; $k++){
                                                $u[$k][$j] += $f * $u[$k][$i];
                                        }
                                }
                                for($k = $i; $k <= $m; $k++){
                                        $u[$k][$i] *= $scale;
                                }
                        }
                }

                $w[$i] = $scale * $g;
                $g = 0.0;
                $s = 0.0;
                $scale = 0.0;
                if(($i <= $m) && ($i != $n)){
                        for($k = $l; $k <= $n; $k++){
                                $scale += abs($u[$i][$k]);
                        }
                        if($scale != 0.0){
                                for($k = $l; $k <= $n; $k++){
                                        $u[$i][$k] /= $scale;
                                        $s += $u[$i][$k] * $u[$i][$k];
                                }
                                $f = $u[$i][$l];

                                $ss = $f /abs($f);
                                $g  = -1.0 * $ss * sqrt($s);
                                $h = $f * $g - $s;
                                $u[$i][$l] = $f - $g;
                                for($k = $l; $k <= $n; $k++){
                                        $rv1[$k] = $u[$i][$k]/$h;
                                }
                                for($j = $l; $j <= $m; $j++){
                                        $s = 0.0;
                                        for($k = $l; $k <= $n; $k++){
                                                $s += $u[$j][$k] * $u[$i][$k];
                                        }
                                        for($k = $l; $k <= $n; $k++){
                                                $u[$j][$k] += $s * $rv1[$k];
                                        }
                                }
                                for($k = $l; $k <= $n; $k++){
                                        $u[$i][$k] *= $scale;
                                }
                        }
                }

                $atemp = abs($w[$i]) + abs($rv1[$i]);
                if($atemp > $anorm){
                        $anorm = $atemp;
                }
        }

        for($i = $n; $i > 0; $i--){
                if($i < $n){
                        if($g != 0.0){
                                for($j = $l; $j <= $n; $j++){
                                        $v[$j][$i] = $u[$i][$j]/$u[$i][$l]/$g;
                                }
                                for($j = $l; $j <= $n; $j++){
                                        $s = 0.0;
                                        for($k = $l; $k <= $n; $k++){
                                                $s += $u[$i][$k] * $v[$k][$j];
                                        }
                                        for($k = $l; $k <= $n; $k++){
                                                $v[$k][$j] += $s * $v[$k][$i];
                                        }
                                }
                        }
                        for($j = $l ; $j <= $n; $j++){
                                $v[$i][$j] = 0.0;
                                $v[$j][$i] = 0.0;
                        }
                }
                $v[$i][$i] = 1.0;
                $g = $rv1[$i];
                $l = $i;
        }

        $istart = $m;
        if($n < $m){
                $istart = $n;
        }
        for($i = $istart; $i > 0; $i--){
                $l = $i + 1;
                $g = $w[$i];
                for($j = $l; $j <= $n; $j++){
                        $u[$i][$j] = 0.0;
                }

                if($g != 0.0){
                        $g = 1.0/$g;
                        for($j = $l; $j <= $n; $j++){
                                $s = 0.0;
                                for($k = $l; $k <= $m; $k++){
                                        $s += $u[$k][$i] * $u[$k][$j];
                                }
                                $f = ($s/$u[$i][$i])* $g;
                                for($k = $i; $k <= $m; $k++){
                                        $u[$k][$j] += $f * $u[$k][$i];
                                }
                        }
                        for($j = $i; $j <= $m; $j++){
                                $u[$j][$i] *= $g;
                        }
                }else{
                        for($j = $i; $j <= $m; $j++){
                                $u[$j][$i] = 0.0;
                        }
                }
                $u[$i][$i]++;
        }

        OUTER2:
        for($k = $n; $k > 0; $k--){
                for($its = 0; $its < 30; $its++){
                        $do_int = 0;
                        OUTER:
                        for($l = $k; $l > 0; $l--){
                                $nm = $l -1;
                                if((abs($rv1[$l]) + $anorm) == $anorm){
                                        last OUTER;
                                }
                                if((abs($w[$nm]) + $anorm) == $anorm){
                                        $do_int = 1;
                                        last OUTER;
                                }
                        }
                        if($do_int == 1){
                                $c = 0.0;
                                $s = 1.0;
                                for($i = $l; $i <= $k; $i++){
                                        $f = $s * $rv1[$i];
                                        $rv1[i] = $c * $rv1[$i];
                                        if((abs($f) + $anorm) != $anorm){
                                                $g = $w[$i];
                                                $h = pythag($f, $g);
                                                $w[$i] = $h;
                                                $h = 1.0/$h;
                                                $c = $g * $h;
                                                $s = -1.0 * $f * $h;
                                                for($j = 1; $j <= $m; $j++){
                                                        $y = $u[$j][$nm];
                                                        $z = $u[$j][$i];
                                                        $u[$j][$nm] = ($y * $c) + ($z * $s);
                                                        $u[$j][$i]  = -1.0 * ($y * $s) + ($z * $c);
                                                }
                                        }
                                }
                        }

                        $z = $w[$k];
                        if($l == $k ){
                                if($z < 0.0) {
                                        $w[$k] = -1.0 * $z;
                                        for($j = 1; $j <= $n; $j++){
                                                $v[$j][$k] *= -1.0;
                                        }
                                }
                                next OUTER2;
                        }else{
                                if($its == 29){
                                        print "No convergence in 30 iterations\n";
                                        exit 1;
                                }
                                $x = $w[$l];
                                $nm = $k -1;
                                $y = $w[$nm];
                                $g = $rv1[$nm];
                                $h = $rv1[$k];
                                $f = (($y - $z)*($y + $z) + ($g - $h)*($g + $h))/(2.0 * $h * $y);
                                $g = pythag($f, 1.0);

                                $ss = $f/abs($f);
                                $gx = $ss * $g;

                                $f = (($x - $z)*($x + $z) + $h * (($y/($f + $gx)) - $h))/$x;

                                $c = 1.0;
                                $s = 1.0;
                                for($j = $l; $j <= $nm; $j++){
                                        $i = $j +1;
                                        $g = $rv1[$i];
                                        $y = $w[$i];
                                        $h = $s * $g;
                                        $g = $c * $g;
                                        $z = pythag($f, $h);
                                        $rv1[$j] = $z;
                                        $c = $f/$z;
                                        $s = $h/$z;
                                        $f = ($x * $c) + ($g * $s);
                                        $g = -1.0 * ($x * $s) + ($g * $c);
                                        $h = $y * $s;
                                        $y = $y * $c;
                                        for($jj = 1; $jj <= $n ; $jj++){
                                                $x = $v[$jj][$j];
                                                $z = $v[$jj][$i];
                                                $v[$jj][$j] = ($x * $c) + ($z * $s);
                                                $v[$jj][$i] = -1.0 * ($x * $s) + ($z * $c);
                                        }
                                        $z = pythag($f, $h);
                                        $w[$j] = $z;
                                        if($z != 0.0){
                                                $z = 1.0/$z;
                                                $c = $f * $z;
                                                $s = $h * $z;
                                        }
                                        $f = ($c * $g) + ($s * $y);
                                        $x = -1.0 * ($s * $g) + ($c * $y);
                                        for($jj = 1; $jj <= $m; $jj++){
                                                $y = $u[$jj][$j];
                                                $z = $u[$jj][$i];
                                                $u[$jj][$j] = ($y * $c) + ($z * $s);
                                                $u[$jj][$i] = -1.0 * ($y * $s) + ($z * $c);
                                        }
                                }
                                $rv1[$l] = 0.0;
                                $rv1[$k] = $f;
                                $w[$k] = $x;
                        }
                }
        }
}

########################################################################
### pythag: compute sqrt(x**2 + y**2) without overflow               ###
########################################################################

sub pythag{
        my($a, $b);
        ($a,$b) = @_;

        $absa = abs($a);
        $absb = abs($b);
        if($absa == 0){
                $result = $absb;
        }elsif($absb == 0){
                $result = $absa;
        }elsif($absa > $absb) {
                $div    = $absb/$absa;
                $result = $absa * sqrt(1.0 + $div * $div);
        }elsif($absb > $absa){
                $div    = $absa/$absb;
                $result = $absb * sqrt(1.0 + $div * $div);
        }
        return $result;
}

########################################################################
### funcs: linear polymonical fuction                                ###
########################################################################

sub funcs {
        my($inp, $pwr, $kf, $temp);
        ($inp, $pwr) = @_;
        $afunc[1] = 1.0;
        for($kf = 2; $kf <= $pwr; $kf++){
                $afunc[$kf] = $afunc[$kf-1] * $inp;
        }
}

########################################################################
### funcs2 :Legendre polynomial function                            ####
########################################################################

sub funcs2 {
#
#---- this one is not used in this script
#
        my($inp, $pwr, $j, $f1, $f2, $d, $twox);
        ($inp, $pwr) = @_;
        $afunc[1] = 1.0;
        $afunc[2] = $inp;
        if($pwr > 2){
                $twox = 2.0 * $inp;
                $f2   = $inp;
                $d    = 1.0;
                for($j = 3; $j <= $pwr; $j++){
                        $f1 = $d;
                        $f2 += $twox;
                        $d++;
                        $afunc[$j] = ($f2 * $afunc[$j-1] - $f1 * $afunc[$j-2])/$d;
                }
        }
}


######################################################################
### pol_val: compute a value for polinomial fit for  give coeffs   ###
######################################################################

sub pol_val{
###############################################################
#       Input: $a[$i]: polinomial parameters of i-th degree
#               $dim:  demension of the fit
#               $x:    dependent variable
#       Output: $out:  the value at $x
###############################################################
        my ($x, $dim, $i, $j, $out);
        ($dim, $x) = @_;
        funcs($x, $dim);
        $out = $a[0];
        for($i = 1; $i <= $dim; $i++){
                $out += $a[$i] * $afunc[$i +1];
        }
        return $out;
}


