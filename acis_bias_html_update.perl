#!/usr/bin/perl 

#########################################################################################
#											#
#	acis_bias_html_update.perl: update bias backgroud html page			#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Mar 09, 2011							#
#											#
#########################################################################################


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

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst) = localtime(time);
$uyear += 1900;
$month = $umon + 1;

$line =  "Last Update: $month/$umday/$uyear";

open(FH, "$web_dir/bias_home.html");
open(OUT, "> ./temp");
while(<FH>){
	chomp $_;
	if($_ =~ /Last Update/){
		print OUT "$line\n";
	}else{
		print OUT "$_\n";
	}
}
close(OUT);
close(FH);
system("mv ./temp $web_dir/bias_home.html");
