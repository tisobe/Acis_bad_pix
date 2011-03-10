#!/usr/bin/perl

#################################################################################
#										#
#	acis_bias_print_today_data.perl: this script print today's data list	#
#			                 for bias background computation	#
#										#
#		author: t. isobe (tisobe@cfa.harvard.edu)			#
#		last update: Mar 09, 2011					#
#										#
#################################################################################

#######################################
#
#--- setting a few paramters
#

#--- output directory

open(FH, "/data/mta/Script/ACIS/Bad_pixels/house_keeping/bias_dir_list");
@dir_list = ();
OUTER:
while(<FH>){
        if($_ =~ /#/){
                next OUTER;
        }
        chomp $_;
        push(@dir_list, $_);
}
close(FH);

$bin_dir       = $dir_list[0];
$bdat_dir      = $dir_list[1];
$web_dir       = $dir_list[2];
$exc_dir       = $dir_list[3];
$data_dir      = $dir_list[4];
$house_keeping = $dir_list[5];

#######################################

#
#--- find out which data are new for today
#

open(FH, "$house_keeping/past_input_data");
@data1 = ();
while(<FH>){
	chomp $_;
	push(@data1, $_);
}
close(FH);

$first    = $data1[0];
@atemp    = split(/\//,$first);
@btemp    = split(/_/,$atemp[5]);
$cut_date = "$btemp[0]$btemp[1]$btemp[2]";

open(FH, "$house_keeping/past_input_data~");
@data2 = ();

while(<FH>){
	chomp $_;
	push(@data2, $_);
}
close(FH);

$test = `ls -d `;
if($test =~ /Working_dir/){
	system("rm ./Working_dir/*");
}else{
	system("mkdir ./Working_dir");
}

open(OUT, ">./Working_dir/today_input_data");

OUTER:
foreach $ent (@data1){
	foreach $comp (@data2){
		if($ent eq $comp){
			next OUTER;
		}
	}
	@atemp = split(/\//,$ent);
	@btemp = split(/_/,$atemp[5]);
	$date  = "$btemp[0]$btemp[1]$btemp[2]";

	if($date >= $cut_date){
		print OUT "$ent\n";
	}
}

close(OUT);
