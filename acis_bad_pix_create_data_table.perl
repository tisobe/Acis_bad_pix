#!/usr/bin/perl

#################################################################################################
#												#
#	acis_bad_pix_create_data_table.perl: create a data display html sub pages 		#
#												#
#	author: t. isobe	(tisobe@cfa.harvard.edu)					#
#	last update: Mar 09, 2011								#
#												#
#################################################################################################

#######################################
#
#--- setting a few paramters
#

#--- output directory

open(FH, "/data/mta/Script/ACIS/Bad_pixels/house_keeping/dir_list");
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

for($iccd = 0; $iccd < 10; $iccd++){

#
#---- set pathes to directories, and other initializations
#
	$bad_pix = "$data_dir".'/Disp_dir/ccd'."$iccd";
	$hot_pix = "$data_dir".'/Disp_dir/hccd'."$iccd";
	$bad_col = "$data_dir".'/Disp_dir/col'."$iccd";

	$flickering_bad = "$data_dir".'/Disp_dir/flickering'."$iccd";
	$flichering_hot = "$data_dir".'/Disp_dir/hflickering'."$iccd";
	$flickering_col = "$data_dir".'/Disp_dir/flickering_col'."$iccd";

	$past_bad_pix = "$data_dir".'/Disp_dir/all_past_bad_pix'."$iccd";
	$past_hot_pix = "$data_dir".'/Disp_dir/all_past_hot_pix'."$iccd";
	$past_bad_col = "$data_dir".'/Disp_dir/all_past_bad_col'."$iccd";

	@bad_pix_list = ();
	@hot_pix_list = ();
	@bad_col_list = ();
	$bad_pix_cnt  = 0;
	$hot_pix_cnt  = 0;
	$bad_col_cnt  = 0;

	@flickering_bad_list = ();
	@flickering_hot_list = ();
	@flickering_col_list = ();
	$flickering_bad_cnt  = 0;
	$flickering_hot_cnt  = 0;
	$flickering_col_cnt  = 0;

	@past_bad_list = ();
	@past_hot_list = ();
	@past_col_list = ();
	$past_bad_cnt  = 0;
	$past_hot_cnt  = 0;
	$past_col_cnt  = 0;

#
#----- read data
#
	open(FH, "$bad_pix");
	while(<FH>){
		chomp $_;
		push(@bad_pix_list, $_);
		$bad_pix_cnt++;
	}
	close(FH);

	open(FH, "$hot_pix");
	while(<FH>){
		chomp $_;
		push(@hot_pix_list, $_);
		$hot_pix_cnt++;
	}
	close(FH);

	open(FH, "$bad_col");
	while(<FH>){
		chomp $_;
		push(@bad_col_list, $_);
		$bad_col_cnt++;
	}
	close(FH);

	open(FH, "$flickering_bad");
	while(<FH>){
		chomp $_;
		push(@flickering_bad_list, $_);
		$flickering_bad_cnt++;
	}
	close(FH);

	open(FH, "$flickering_hot");
	while(<FH>){
		chomp $_;
		push(@flickering_hot_list, $_);
		$flickering_hot_cnt++;
	}
	close(FH);

	open(FH, "$flickering_col");
	while(<FH>){
		chomp $_;
		push(@flickering_col_list, $_);
		$flickering_col_cnt++;
	}
	close(FH);

	open(FH, "$past_bad_pix");
	while(<FH>){
		chomp $_;
		push(@past_bad_list, $_);
		$past_bad_cnt++;
	}
	close(FH);

	open(FH, "$past_hot_pix");
	while(<FH>){
		chomp $_;
		push(@past_hot_list, $_);
		$past_hot_cnt++;
	}
	close(FH);

	open(FH, "$past_bad_col");
	while(<FH>){
		chomp $_;
		push(@past_col_list, $_);
		$past_col_cnt++;
	}
	close(FH);

#
#---- start printing the html pages
#
	$file_name = "$web_dir".'/Html_dir/ccd_data'."$iccd".'.html';

	open(OUT, ">$file_name");
	print OUT '<HTML><BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF"'; 
	print OUT 'VLINK="yellow" ALINK="#FF0000" background="./stars.jpg">',"\n";
	print OUT '<title> ACIS Bad Pixel List:',"CCD$iccd",'</title>',"\n";

	print OUT '<h3>CCD',"$iccd",'</h3>',"\n";
	print OUT '<br><br><a href ="./mta_bad_pixel_list.html">Back to the main page</a>',"\n";
	print OUT '<br><br>',"\n";

	print OUT '<table border=2 cellspacing=2 cellpadding=2 align=top>',"\n";
	print OUT '<tr>',"\n";;

	print OUT '<th>Current Warm Pixels</th>';
	print OUT '<th>Flickering Warm Pixels</th>';
	print OUT '<th>Past Warm Pixels</th>',"\n";

	print OUT '<th>Current Hot Pixels</th>';
	print OUT '<th>Flickering Hot Pixels</th>';
	print OUT '<th>Past Hot Pixels</th>',"\n";

	print OUT '<th>Current Warm Columns</th>';
	print OUT '<th>Flickering Warm Columns</th>';
	print OUT '<th>Past Warm Columns</th>',"\n";

	print OUT '</tr><tr>',"\n";;
#
#----- warm pixel cases
#
	print OUT '<td valign=top>',"\n";
	if($bad_pix_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $bad_pix_cnt; $i++){
			print OUT "<nobr>($bad_pix_list[$i])</nobr> <br>\n";
		}
	}
	print OUT '</td>',"\n";

	print OUT '<td valign=top>',"\n";
	if($flickering_bad_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $flickering_bad_cnt; $i++){
			print OUT "<nobr>$flickering_bad_list[$i]</nobr> <br>\n";
		}
	}
	print OUT '</td>',"\n";

	print OUT '<td valign=top>',"\n";
	if($past_bad_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $past_bad_cnt; $i++){
			print OUT "<nobr>$past_bad_list[$i]</nobr> <br>\n";
		}
	}
	print OUT '</td>',"\n";

#
#---- hot pixel cases
#
	print OUT '<td valign=top>',"\n";
	if($hot_pix_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $hot_pix_cnt; $i++){
			print OUT "<nobr>($hot_pix_list[$i])</nobr> <br>\n";
		}
	}
	print OUT '</td valign=top>',"\n";

	print OUT '<td>',"\n";
	if($flickering_hot_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $flickering_hot_cnt; $i++){
			print OUT "<nobr>$flickering_hot_list[$i]</nobr> <br>\n";
		}
	}
	print OUT '</td>',"\n";

	print OUT '<td valign=top>',"\n";
	if($past_hot_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $past_hot_cnt; $i++){
			print OUT "<nobr>$past_hot_list[$i]</nobr> <br>\n";
		}
	}
	print OUT '</td>',"\n";

#
#--- bad column cases
#

	print OUT '<td align=center valign=top>',"\n";
	if($bad_col_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $bad_col_cnt; $i++){
			print OUT "$bad_col_list[$i] <br>\n";
		}
	}
	print OUT '</td>',"\n";

	print OUT '<td align=center valign=top>',"\n";
	if($flickering_col_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $flickering_col_cnt; $i++){
			print OUT "$flickering_col_list[$i] <br>\n";
		}
	}
	print OUT '</td>',"\n";

	print OUT '<td align=center valign=top>',"\n";
	if($past_col_cnt == 0){
		print OUT '&#160',"\n";
	}else{
		for($i = 0; $i < $past_col_cnt; $i++){
			print OUT "$past_col_list[$i] <br>\n";
		}
	}
	print OUT '</td>',"\n";


	print OUT '</tr>',"\n";
	print OUT '</table>',"\n";
	close(OUT);
}

