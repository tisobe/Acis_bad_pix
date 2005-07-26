#!/usr/bin/perl
use PGPLOT;

#########################################################################################
#											#
#	plot_sub_info.perl: plot bias background data of different classifications	#
#											#
#		author: t. isobe (tiosbe@cfa.harvard.edu)				#
#		last update: Jul 9, 2004						#
#											#
#########################################################################################
	
for($ccd = 0; $ccd < 10; $ccd++){
	for($quad = 0; $quad < 4; $quad++){
		$dir = '../Data/Info_dir/CCD'."$ccd".'/quad'."$quad";
#	
#--- overclock
#
		$dir2 = '../Data/Plots/Param_diff/CCD'."$ccd".'/CCD'."$ccd".'_q'."$quad";
		plot_param_dep();
#
#---- bias backgound
#

		$dir3 = '../Data/Plots/Param_diff/CCD'."$ccd".'/CCD'."$ccd".'_bias_q'."$quad";
		plot_param_dep2();
	}
}


########################################################################################
### plot_param_dep: plotting for overclock 		                             ###
########################################################################################

sub plot_param_dep{
	$file = $dir;
	
	$dest_dir = $dir2;
	
	open(FH, './Working_dir/list_of_ccd_no');
	@ttime = ();
	@ccd_no = ();
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		push(@ttime, $atemp[0]);
		push(@ccd_no, $atemp[1]);
	}
	close(FH);
	
	
	@time      = ();
	@overclock = ();
	@mode      = ();
	@ord_mode  = ();
	@outrow    = ();
	@num_row   = ();
	@sum2x2    = ();
	@deagain   = ();
	@biasalg   = ();
	@biasarg0  = ();
	@biasarg1  = ();
	@biasarg2  = ();
	@biasarg3  = ();
	#@biasarg4  = ();
	$cnt       = 0;
	$sum       = 0;
	
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/\t/, $_);
		$dom = ($atemp[0] - 48902399)/86400;
		push(@time,      $dom);
		push(@overclock, $atemp[1]);
		$sum += $atemp[1];
		push(@mode,      $atemp[2]);
		push(@ord_mode,  $atemp[3]);
		push(@outrow,    $atemp[4]);
		push(@num_row,   $atemp[5]);
		push(@sum2x2,    $atemp[6]);
		push(@deagain,   $atemp[7]);
		push(@blasalg,   $atemp[8]);
		push(@biasarg0,  $atemp[9]);
		push(@biasarg1,  $atemp[10]);
		push(@biasarg2,  $atemp[11]);
		push(@biasarg3,  $atemp[12]);
	#	push(@biasarg4,  $atemp[13]);
		$cnt++;
	}
	close(FH);
	
	if($cnt > 0){
		for($i = 0; $i < $cnt; $i++){
			if($mode[$i] eq 'FAINT'){
				push(@x1, $time[$i]);
				push(@y1, $overclock[$i]);
				$cnt1++;
			}elsif($mode[$i] eq 'VFAINT'){
				push(@x2, $time[$i]);
				push(@y2, $overclock[$i]);
				$cnt2++;
			}else{
				push(@x3, $time[$i]);
				push(@y3, $overclock[$i]);
				$cnt3++;
			}
		}
		
		$xmin = $time[0];
		$xmax = $time[$cnt-1];
		$avg = $sum/$cnt;
		$ymin = $avg - 100;
		$ymax = $avg + 100;
		
		pgbegin(0, "/ps",1,1);
		pgsubp(1,3);
		pgsch(2);
		pgslw(2);
		
		@x = @x1;
		@y = @y1;
		$tot = $cnt1;
		$title = 'Faint Mode';
		plot_routine();
		
		@x = @x2;
		@y = @y2;
		$tot = $cnt2;
		$title = 'Very Faint Mode';
		plot_routine();
		
		@x = @x1;
		@y = @y1;
		$title = 'Others';
		$tot = $cnt3;
		plot_routine();
		
		pgclos();
		system("./Prog/ps2gif  pgplot.ps $dest_dir/obs_mode.gif");
		system("rm pgplot.ps");
		
		for($i = 0; $i < $cnt; $i++){
			if($num_row[$i] == 1024){
				push(@x1, $time[$i]);
				push(@y1, $overclock[$i]);
				$cnt1++;
			}else{
				push(@x2, $time[$i]);
				push(@y2, $overclock[$i]);
				$cnt2++;
			}
		}
		
		pgbegin(0, "/ps",1,1);
		pgsubp(1,2);
		pgsch(2);
		pgslw(2);
		
		@x = @x1;
		@y = @y1;
		$tot = $cnt1;
		$title = 'Full Readout';
		plot_routine();
		
		@x = @x2;
		@y = @y2;
		$tot = $cnt2;
		$title = 'Partial Readout';
		plot_routine();
		
		pgclos();
		system("./Prog/ps2gif  pgplot.ps $dest_dir/partial_readout.gif");
		system("rm pgplot.ps");
		
		for($i = 0; $i < $cnt; $i++){
        		if($biasarg1[$i] == 9){
                		push(@x1, $time[$i]);
                		push(@y1, $overclock[$i]);
                		$cnt1++;
        		}elsif($biasarg1[$i] == 10){
                		push(@x2, $time[$i]);
                		push(@y2, $overclock[$i]);
                		$cnt2++;
        		}else{
                		push(@x3, $time[$i]);
                		push(@y3, $overclock[$i]);
                		$cnt3++;
        		}
		}
		
		pgbegin(0, "/ps",1,1);
		pgsubp(1,3);
		pgsch(2);
		pgslw(2);
		
		@x = @x1;
		@y = @y1;
		$tot = $cnt1;
		$title = 'Bias Arg 1 = 9';
		plot_routine();
		
		@x = @x2;
		@y = @y2;
		$tot = $cnt2;
		$title = 'Bias Arg 1 = 10';
		plot_routine();
		
		@x = @x3;
		@y = @y3;
		$tot = $cnt3;
		$title = 'Bias Arg 1 = others';
		plot_routine();
	
		pgclos();
		system("./Prog/ps2gif  pgplot.ps $dest_dir/bias_arg1.gif");
		system("rm pgplot.ps");
	
	
		$mstep = 0;
		OUTER:
		for($i = 0; $i < $cnt; $i++){
			for($m = $mstep; $m < $cnt; $m++){
				if($time[$i] == $ttime[$m]){
					if($ccd_no == 6){
						push(@x1, $time[$i]);
						push(@y1, $overclock[$i]);
						$cnt1++;
					}elsif($ccd_no == 5){
						push(@x2, $time[$i]);
						push(@y2, $overclock[$i]);
						$cnt2++;
					}else{
						push(@x3, $time[$i]);
						push(@y3, $overclock[$i]);
						$cnt3++;
					}
					$mstep = $m;
					next OUTER;
				}
			}
		}
		
		pgbegin(0, "/ps",1,1);
		pgsubp(1,3);
		pgsch(2);
		pgslw(2);
		
		@x = @x1;
		@y = @y1;
		$tot = $cnt1;
		$title = '# of CCDs = 6';
		plot_routine();
		
		@x = @x2;
		@y = @y2;
		$tot = $cnt2;
		$title = '# of CCDs = 5';
		plot_routine();
	
		@x = @x3;
		@y = @y3;
		$tot = $cnt3;
		$title = '# of CCDs: others';
		plot_routine();
		
		pgclos();
							
		system("./Prog/ps2gif  pgplot.ps $dest_dir/no_ccds.gif");
		system("rm pgplots.ps");
	}
}



######################################################################################
### plot_param_dep2: plotting for bias background                                  ###
######################################################################################

sub plot_param_dep2{

        $file = $dir;

        $dest_dir = $dir3;

	@btemp = split(/CCD/,$file);
	$in_file = 'CCD'."$btemp[1]";
	
	
	open(FH, './Working_dir/list_of_ccd_no');
	@ttime = ();
	@ccd_no = ();
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		push(@ttime, $atemp[0]);
		push(@ccd_no, $atemp[1]);
	}
	close(FH);
	
	
	@time      = ();
	@overclock = ();
	@mode      = ();
	@ord_mode  = ();
	@outrow    = ();
	@num_row   = ();
	@sum2x2    = ();
	@deagain   = ();
	@biasalg   = ();
	@biasarg0  = ();
	@biasarg1  = ();
	@biasarg2  = ();
	@biasarg3  = ();
	#@biasarg4  = ();
	$cnt       = 0;
	$sum       = 0;
	
	open(FH, "$file");
	while(<FH>){
		chomp $_;
		@atemp = split(/\t/, $_);
		$dom = ($atemp[0] - 48902399)/86400;
		push(@time,      $dom);
		push(@overclock, $atemp[1]);
		$sum += $atemp[1];
		push(@mode,      $atemp[2]);
		push(@ord_mode,  $atemp[3]);
		push(@outrow,    $atemp[4]);
		push(@num_row,   $atemp[5]);
		push(@sum2x2,    $atemp[6]);
		push(@deagain,   $atemp[7]);
		push(@blasalg,   $atemp[8]);
		push(@biasarg0,  $atemp[9]);
		push(@biasarg1,  $atemp[10]);
		push(@biasarg2,  $atemp[11]);
		push(@biasarg3,  $atemp[12]);
	#	push(@biasarg4,  $atemp[13]);
		$cnt++;
	}
	close(FH);
	
	open(FH, "../Data/Bias_save/$in_file");
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		$diff = $atemp[1] - $atemp[3];
		if(abs($diff) > 10){
			$diff = 0;
		}
		push(@bias, $diff);
	}
	close(FH);
	
	for($i = 0; $i < $cnt; $i++){
		if($mode[$i] eq 'FAINT'){
			push(@x1, $time[$i]);
			push(@y1, $bias[$i]);
			$cnt1++;
		}elsif($mode[$i] eq 'VFAINT'){
			push(@x2, $time[$i]);
			push(@y2, $bias[$i]);
			$cnt2++;
		}else{
			push(@x3, $time[$i]);
			push(@y3, $bias[$i]);
			$cnt3++;
		}
	}
	
	$xmin = $time[0];
	$xmax = $time[$cnt-1];
	$avg = $sum/$cnt;
	$ymin =  -0.5;
	$ymax =   1.5;
	
	pgbegin(0, "/ps",1,1);
	pgsubp(1,3);
	pgsch(2);
	pgslw(2);
	
	@x = @x1;
	@y = @y1;
	$tot = $cnt1;
	$title = 'Faint Mode';
	plot_routine();
	
	@x = @x2;
	@y = @y2;
	$tot = $cnt2;
	$title = 'Very Faint Mode';
	plot_routine();
	
	@x = @x1;
	@y = @y1;
	$title = 'Others';
	$tot = $cnt3;
	plot_routine();
	
	pgclos();
	system("./Prog/ps2gif  pgplot.ps $dest_dir/obs_mode.gif");
	system("rm pgplot.ps");
	
	for($i = 0; $i < $cnt; $i++){
		if($num_row[$i] == 1024){
			push(@x1, $time[$i]);
			push(@y1, $bias[$i]);
			$cnt1++;
		}else{
			push(@x2, $time[$i]);
			push(@y2, $bias[$i]);
			$cnt2++;
		}
	}
	
	pgbegin(0, "/ps",1,1);
	pgsubp(1,2);
	pgsch(2);
	pgslw(2);

	@x = @x1;
	@y = @y1;
	$tot = $cnt1;
	$title = 'Full Readout';
	plot_routine();
	
	@x = @x2;
	@y = @y2;
	$tot = $cnt2;
	$title = 'Partial Readout';
	plot_routine();
	
	pgclos();
	system("./Prog/ps2gif  pgplot.ps $dest_dir/partial_readout.gif");
	system("rm pgplot.ps");
	
	for($i = 0; $i < $cnt; $i++){
        	if($biasarg1[$i] == 9){
                	push(@x1, $time[$i]);
                	push(@y1, $bias[$i]);
                	$cnt1++;
        	}elsif($biasarg1[$i] == 10){
                	push(@x2, $time[$i]);
                	push(@y2, $bias[$i]);
                	$cnt2++;
        	}else{
                	push(@x3, $time[$i]);
                	push(@y3, $bias[$i]);
                	$cnt3++;
        	}
	}
	
	pgbegin(0, "/ps",1,1);
	pgsubp(1,3);
	pgsch(2);
	pgslw(2);
	
	@x = @x1;
	@y = @y1;
	$tot = $cnt1;
	$title = 'Bias Arg 1 = 9';
	plot_routine();
	
	@x = @x2;
	@y = @y2;
	$tot = $cnt2;
	$title = 'Bias Arg 1 = 10';
	plot_routine();
	
	@x = @x3;
	@y = @y3;
	$tot = $cnt3;
	$title = 'Bias Arg 1 = others';
	plot_routine();
	
	pgclos();
	system("./Prog/ps2gif  pgplot.ps $dest_dir/bias_arg1.gif");
	system("rm pgplot.ps");
	
	
	$mstep = 0;
	OUTER:
	for($i = 0; $i < $cnt; $i++){
		for($m = $mstep; $m < $cnt; $m++){
			if($time[$i] == $ttime[$m]){
				if($ccd_no == 6){
					push(@x1, $time[$i]);
					push(@y1, $bias[$i]);
					$cnt1++;
				}elsif($ccd_no == 5){
					push(@x2, $time[$i]);
					push(@y2, $bias[$i]);
					$cnt2++;
				}else{
					push(@x3, $time[$i]);
					push(@y3, $bias[$i]);
					$cnt3++;
				}
				$mstep = $m;
				next OUTER;
			}
		}
	}
	
	pgbegin(0, "/ps",1,1);
	pgsubp(1,3);
	pgsch(2);
	pgslw(2);
	
	@x = @x1;
	@y = @y1;
	$tot = $cnt1;
	$title = '# of CCDs = 6';
	plot_routine();
	
	@x = @x2;
	@y = @y2;
	$tot = $cnt2;
	$title = '# of CCDs = 5';
	plot_routine();
	
	@x = @x3;
	@y = @y3;
	$tot = $cnt3;
	$title = '# of CCDs: others';
	plot_routine();
	
	pgclos();
						
	system("./Prog/ps2gif  pgplot.ps $dest_dir/no_ccds.gif");
	system("rm pgplot.ps");

}

####################################################################
### plot_routine: plotting figs                                  ###
####################################################################

sub plot_routine{
	least_fit();
	pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);
	pgslw(3);
	for($m = 0; $m < $tot; $m++){
		pgpt(1,$x[$m], $y[$m], -1);
	}
	$ys = $int + $slope*$x[0];
	$ye = $int + $slope*$x[$tot-1];
	pgpt(1,$x[0],$ys,-1);
	pgdraw($x[$tot-1],$ye);
	pgslw(2);
	$xw = $x[0]+ 30;
	$yw = $ymax -0.3;
	pgptxt($xw, $yw, 0, 0, "Slope: $slope");
	pglabel("Time (DOM)", 'Bias', "$title");
}

####################################################################
### least_fit: least sq. fit routine                             ###
####################################################################

sub least_fit{
        $lsum = 0;
        $lsumx = 0;
        $lsumy = 0;
        $lsumxy = 0;
        $lsumx2 = 0;
        $lsumy2 = 0;

        for($fit_i = 0; $fit_i < $tot;$fit_i++) {
                $lsum++;
                $lsumx += $x[$fit_i];
                $lsumy += $y[$fit_i];
                $lsumx2+= $x[$fit_i]*$x[$fit_i];
                $lsumy2+= $y[$fit_i]*$y[$fit_i];
                $lsumxy+= $x[$fit_i]*$y[$fit_i];
        }

        $delta = $lsum*$lsumx2 - $lsumx*$lsumx;
	if($delta > 0){
        	$int   = ($lsumx2*$lsumy - $lsumx*$lsumxy)/$delta;
        	$slope = ($lsumxy*$lsum - $lsumx*$lsumy)/$delta;
		$slope = sprintf "%2.4f",$slope;
	}else{
		$int = 999999;
		$slope = 0.0;
	}
}
