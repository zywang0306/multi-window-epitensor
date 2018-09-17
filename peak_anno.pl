#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw(min max);

my ($arglistfile,$line,$varname,$val,$annopath,$annofile,$annoname,$tssfile,$enhfile,$exonfile,$intronfile,$intergenicfile,$peakpath,$peakannopath,$peakfile,$peaktssfile,$rempeaktssfile,$peakenhfile,$rempeakenhfile,$peakexonfile,$rempeakexonfile,$peakintronfile,$rempeakintronfile,$peakintergenicfile,$rempeakintergenicfile,$peakannofile,$command,$i,@items,@peakfiles,%arglist,%anno);

$arglistfile = shift;

open ARGLISTFILE, $arglistfile or die "Could not open $arglistfile: $!";

%arglist = ();
while($line = <ARGLISTFILE>)
{
    chomp($line);
    @items = split("\t",$line);
    $varname = $items[0];
    $val = $items[1];
    
    $arglist{$varname} = $val;
}

close ARGLISTFILE;

# locate tss, enh, exon, intron, intergenic annotation files
$annofile = $arglist{'annofile'};

open ANNOFILE, $annofile or die "Could not open $annofile: $!";

%anno = ();
while($line = <ANNOFILE>)
{
    chomp($line);
    @items = split("\t",$line);
    $annoname = $items[0];
    $anno{$annoname} = $items[1];
}

close ANNOFILE;

$tssfile = $anno{'tss'};
$enhfile = $anno{'enh'};
$exonfile = $anno{'exon'};
$intronfile = $anno{'intron'};
$intergenicfile = $anno{'intergenic'};

# Annotate peaks
$annopath = $arglist{'annopath'};
$peakpath = $arglist{'peakpath'};
$peakannopath = $arglist{'peakannopath'};

opendir (PEAKPATH, $peakpath) or die $!;
@peakfiles = grep { /.bed/ } readdir PEAKPATH;
closedir PEAKPATH;

for ($i=0; $i<@peakfiles; $i++)
{
	$peakfile = $peakfiles[$i];
	$peakannofile=$peakfile;
        $peakannofile=~s/.bed/.anno.bed/g;
        $peakannofile=join("",$peakannopath,$peakannofile);

        unless (-e $peakannofile)
        {
          $peaktssfile=$peakfile;
	  $peaktssfile=~s/.bed/.tss.bed/g;
	  $peaktssfile=join("",$peakannopath,$peaktssfile);
	  $rempeaktssfile=join("",$peakannopath,"rempeaktss.bed");
	  peak_anno1(join("",$peakpath,$peakfile),$tssfile,$peaktssfile,$rempeaktssfile,$peakannopath,"tss");
	  
	  $peakenhfile=$peakfile;
	  $peakenhfile=~s/.bed/.enh.bed/g;
	  $peakenhfile=join("",$peakannopath,$peakenhfile);
	  $rempeakenhfile=join("",$peakannopath,"rempeakenh.bed");
	  peak_anno1($rempeaktssfile,$enhfile,$peakenhfile,$rempeakenhfile,$peakannopath,"enh");
	  
	  $peakexonfile=$peakfile;
	  $peakexonfile=~s/.bed/.exon.bed/g;
	  $peakexonfile=join("",$peakannopath,$peakexonfile);
	  $rempeakexonfile=join("",$peakannopath,"rempeakexon.bed");
	  peak_anno1($rempeakenhfile,$exonfile,$peakexonfile,$rempeakexonfile,$peakannopath,"exon");
	  
	  $peakintronfile=$peakfile;
	  $peakintronfile=~s/.bed/.intron.bed/g;
	  $peakintronfile=join("",$peakannopath,$peakintronfile);
	  $rempeakintronfile=join("",$peakannopath,"rempeakintron.bed");
	  peak_anno1($rempeakexonfile,$intronfile,$peakintronfile,$rempeakintronfile,$peakannopath,"intron");
	  
	  $peakintergenicfile=$peakfile;
	  $peakintergenicfile=~s/.bed/.intergenic.bed/g;
	  $peakintergenicfile=join("",$peakannopath,$peakintergenicfile);
	  $rempeakintergenicfile=join("",$peakannopath,"rempeakintergenic.bed");
	  peak_anno1($rempeakintronfile,$intergenicfile,$peakintergenicfile,$rempeakintergenicfile,$peakannopath,"intergenic");
	  
	  $command = join(" ","cat",$peaktssfile,$peakenhfile,$peakexonfile,$peakintronfile,$peakintergenicfile,">",$peakannofile);
	  system($command);
	  
	  $command=join(" ","rm",$peaktssfile);
	  system($command);
	  $command=join(" ","rm",$peakenhfile);
	  system($command);
	  $command=join(" ","rm",$peakexonfile);
	  system($command);
	  $command=join(" ","rm",$peakintronfile);
	  system($command);
	  $command=join(" ","rm",$peakintergenicfile);
	  system($command);
	  
	  $command=join(" ","rm",$rempeaktssfile);
	  system($command);
	  $command=join(" ","rm",$rempeakenhfile);
	  system($command);
	  $command=join(" ","rm",$rempeakexonfile);
	  system($command);
	  $command=join(" ","rm",$rempeakintronfile);
	  system($command);
	  $command=join(" ","rm",$rempeakintergenicfile);
	  system($command);
        }  
}

##########

sub peak_anno1
{
	my ($peakfile,$annofile,$peakannofile,$rempeakfile,$workpath,$name);
	$peakfile = shift;
	$annofile = shift;
	$peakannofile = shift;
	$rempeakfile = shift;
	$workpath = shift;
	$name = shift;
	
	# create an empty peak_anno file and rempeakfile
	$command = join(" ","touch",$peakannofile);
	system($command);
	$command = join(" ","touch",$rempeakfile);
	system($command);
	
	if (-s $peakfile)
	{
		# Overlap peak with annotation file, return a 9-column bed file
		# column 1 - chromosome of genomic element
		# column 2 - start of genomic element
		# column 3 - stop of genomic element
		# column 4 - chromosome of peak
		# column 5 - start of peak
		# column 6 - stop of peak
		# column 7 - always "0"
		# column 8 - peak strength
		$command = join("","intersectBed -a ",$annofile," -b ",$peakfile," -wa -wb > ",$workpath,"peak_anno.bed");
		system($command);
		
		if (-s join("",$workpath,"peak_anno.bed"))
		{
			# extract column 1-4 and 9 from the above 9-column bed file, use as input for the "mergepeakanno" subroutine
			$command = join("","awk '{print \$1 \"\\t\" \$2 \"\\t\" \$3 \"\\t\" \$8}' ",$workpath,"peak_anno.bed | sort -k1,1 -k2,2g -k3,3g | mergeBed -d 0 -nms -i > ",$workpath,"peak_anno_anno.bed");
			system($command);
			
			# extract column 5-7 from the above 9-column bed file, these peaks will be removed in the "getrempeaks" subroutine
			$command = join("","awk '{print \$4 \"\\t\" \$5 \"\\t\" \$6}' ",$workpath,"peak_anno.bed > ",$workpath,"peak_anno_peak.bed");
			system($command);
			
			# One genomic element (e.g. TSS) may overlap with multiple peaks, choose the strongest peaks.
			mergepeakanno(join("",$workpath,"peak_anno_anno.bed"),$peakannofile,$workpath,$name);
			
			# One peak may overlap with multiple genomic elements (e.g. one peak partially overlap with both exon and intron), choose only one element in the order of TSS, enhancer, exon, intron, and intergenic regions.
			# In other words, if an peak overlaps with TSS, it cannot overlap with enhancer.
			# The "getrempeaks" subroutine returns the remaining peaks after overlapping with an element.
			getrempeaks($peakfile,join("",$workpath,"peak_anno_peak.bed"),$rempeakfile);
			
			$command = join("","rm ",$workpath,"peak_anno_anno.bed");
			system($command);
			
			$command = join("","rm ",$workpath,"peak_anno_peak.bed");
			system($command);
		}elsif (!-s join("",$workpath,"peak_anno.bed"))
		{
			$command = join(" ","cp",$peakfile,$rempeakfile);
			system($command);
		}
		
		$command = join("","rm ",$workpath,"peak_anno.bed");
		system($command);
	}
}

##########

sub mergepeakanno
{
	my ($infile,$outfile,$workpath,$name,$line,$chr,$start,$stop,$anno,$strength,$command,@items);
	
	$infile = shift;
	$outfile = shift;
	$workpath = shift;
	$name = shift;
	
	open INFILE, "<", $infile or die $!;
	open OUTFILE, ">", $outfile or die $!;
	
	while( $line = <INFILE>)
	{
		chomp($line);
		@items = split("\t",$line);
		$chr = $items[0];
		$start = $items[1];
		$stop = $items[2];
		
		@items = split(";",$items[3]);
                @items = spilit(",",$items);
		$strength = max @items;   # If multiple peaks overlap with one genomic element, select the strongest peak
		
		$line = join("\t",$chr,$start,$stop,$name,$strength);
		$line = join("",$line,"\n");
		
		print OUTFILE $line;
	}
	
	close(INFILE);
	close(OUTFILE);
}

##########

sub getrempeaks
{
	my ($peakfile,$annopeakfile,$rempeakfile,$command);
	
	# $peakfile - all peaks
	# $annopeakfile - already annotated peaks (need to be removed)
	# $rempeakfile - remaining peaks (output)
	
	$peakfile = shift;
	$annopeakfile = shift;
	$rempeakfile = shift;
	
	$command = join("","subtractBed -a ",$peakfile," -b ",$annopeakfile," > ",$rempeakfile);
	system($command);
}
