#!/usr/bin/perl

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

#######################################

system("ls $web_dir/Disp_dir/*cnt* > zdata_list"); 
@in_list = split(/\s+/, $list);

open(FH, "./zdata_list");

while(<FH>){
	chomp $_;
	$ent = $_;
print "$ent\n";
	clearnup_duplicate("$ent");
}

clean_up_dupl_entry();

################################################################
### sub clearnup_duplicate: remove duplicated lines          ###
################################################################

sub clearnup_duplicate {
        ($in_file) = @_;
        @test = ();
        open(CL, "$in_file");
        while(<CL>){
                chomp $_;
                push(@test, $_);
        }
        close(CHL);
        @ctemp = sort{$a<=>$b} @test;
        $first = shift(@ctemp);
        @cnew  = ($first);
        COUTER:
        foreach $cent (@ctemp){
                foreach $ccomp (@cnew){
                        @dtemp = split(/:/, $cent);
                        @etemp = split(/:/, $ccomp);
                        if($dtemp[0] == $etemp[0] && $dtemp[1] == $etemp[1]){
                                next COUTER;
                        }
                }
                push(@cnew, $cent);
        }

        @test = sort{$a<=>$b} @cnew;

        open(COUT, "> $in_file");
        foreach $cent (@test){
		@ftemp = split(/:/, $cent);
		if($ftemp[2] >0){
                	print COUT "$cent\n";
		}else{
			print COUT "$ftemp[0]:$ftemp[1]:0\n";
		}
        }
}

###################################################################
## clean_up_dupl_entry: remove duplicate line from history file ###
###################################################################

sub clean_up_dupl_entry{
	$in_list = `ls $web_dir/Disp_dir/hist_*`;
	@list = split(/\s+/, $in_list);
	foreach $ent (@list){
        	open(FH, "$ent");
        	open(OUT, '>ztemp');
        	while(<FH>){
                	chomp $_;
                	if($_ =~ /<>:/){
                        	@atemp = split(/<>:/, $_);
                        	@btemp = split(/:/,   $atemp[1]);
                        	$line = "$atemp[0]".'<>';
                	}else{
                        	@atemp = split(/<>/, $_);
                        	@btemp = split(/:/,   $atemp[2]);
                        	$line = "$atemp[0]<>$atemp[1]".'<>';
                	}
                	$first = shift(@btemp);
                	@new   = ("$first");
                	OUTER:
                	foreach $pix (@btemp){
                        	foreach $comp (@new){
                                	if($pix eq $comp){
                                        	next OUTER;
                                	}
                        	}
                        	push(@new, $pix);
                	}
	
                	foreach $pix (@new){
	
                        	$line = "$line".':'."$pix";
                	}
                	print OUT "$line\n";
        	}
        	close(FH);
        	close(OUT);
        	system("mv ztemp $ent");
	}
}
