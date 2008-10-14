#!/usr/bin/perl

#
#---- this script clean up history file duplicated entries.
#
#		t. isobe (tisobe@cfa.harvard.edu);
#
#		Oct 14, 2008
#
#

#
#--- check whether there is enough space
#

system('df -k . > zspace');
open(FH, "./zspace");
while(<FH>){
        chomp $_;
        if($_ =~ /\%/){
                @atemp = split(/\s+/, $_);
                @btemp = split(/\%/, $atemp[4]);
                if($btemp[0] > 98%){
                        exit 0;
                }
        }
}


$in_list = `ls /data/mta_www/mta_bad_pixel/Disp_dir/*hist*`;
@list    = split(/\s+/, $in_list);

foreach $ent (@list){
	open(FH, "$ent");
	open(OUT, ">temp_file");
	while(<FH>){
		chomp $_;
		@atemp = split(/<>:/, $_);
		@btemp = split(/:/,  $atemp[1]);
		$cnt   = 0;
		foreach (@btemp){
			$cnt++;
		}
		if($cnt > 1){
			$first = shift(@btemp);
			@new   = ($first);
			OUTER:
			foreach $chk (@btemp){
				foreach $comp (@new){
					if($chk eq $comp){
						next OUTER;
					}
				}
				push(@new, $chk);
			}
			$line = "$atemp[0]".'<>';
			foreach $chk (@new){
				$line = "$line".':'."$chk";
			}
		}else{
				$line = $_;
		}
		print OUT "$line\n";
	}
	close(OUT);
	close(FH);
	system("mv temp_file $ent");
}


