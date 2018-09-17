#!/usr/bin/perl

use warnings;
use strict;
use Scalar::Util qw(looks_like_number);

my ($arglistfile,$line,$varname,$val,$pairpath,$mergedfile,$workpath,$command,$inline,$chr1a,$start1a,$stop1a,$anno1a,$strength1a,$chr2a,$start2a,$stop2a,$anno2a,$strength2a,$chr1b,$start1b,$stop1b,$anno1b,$strength1b,$chr2b,$start2b,$stop2b,$anno2b,$strength2b,$outline,@items,%arglist);

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

$pairpath = $arglist{'pairpath'};
$workpath = $arglist{'workpath'};
$mergedfile = join("",$pairpath,"peak_pair_merged.bed");

$command = join("","cat ",$pairpath,"/*.bed | sort -k1,1 -k2,2g -k3,3g -k6,6 -k7,7g -k8,8g > ",$workpath,"allpairs.bed");
system($command);

open(IN,"<",join("",$workpath,"allpairs.bed")) or die;
open(OUT,">",$mergedfile) or die;
if(-z join("",$workpath,"allpairs.bed")){die "empty file";} ### check if file has zero size. 
$inline = <IN>;
chomp($inline);
@items = split("\t",$inline);
$chr1a = $items[0];
$start1a = $items[1];
$stop1a = $items[2];
$anno1a = $items[3];
$strength1a = $items[4];
$chr2a = $items[5];
$start2a = $items[6];
$stop2a = $items[7];
$anno2a = $items[8];
$strength2a = $items[9];

# check the format of the input line.
# if not correct, go to the next line.
while(!$chr1a=~m/chr/ || !looks_like_number($start1a) || !looks_like_number($stop1a) || !looks_like_number($strength1a) || !$chr2a=~m/chr/ || !looks_like_number($start2a) || !looks_like_number($stop2a) || !looks_like_number($strength2a))
{
    $inline = <IN>;
    print "$inline\n";
    chomp($inline);
    @items = split("\t",$inline);
    $chr1a = $items[0];
    $start1a = $items[1];
    $stop1a = $items[2];
    $anno1a = $items[3];
    $strength1a = $items[4];
    $chr2a = $items[5];
    $start2a = $items[6];
    $stop2a = $items[7];
    $anno2a = $items[8];
    $strength2a = $items[9];
}

foreach $inline (<IN>)
{
    chomp($inline);
    @items = split("\t",$inline);
    $chr1b = $items[0];
    $start1b = $items[1];
    $stop1b = $items[2];
    $anno1b = $items[3];
    $strength1b = $items[4];
    $chr2b = $items[5];
    $start2b = $items[6];
    $stop2b = $items[7];
    $anno2b = $items[8];
    $strength2b = $items[9];
    
    # check the format of the input line.
    # if not correct, go to the next line.
    if (!$chr1b=~m/chr/ || !looks_like_number($start1b) || !looks_like_number($stop1b) || !looks_like_number($strength1b) || !$chr2b=~m/chr/ || !looks_like_number($start2b) || !looks_like_number($stop2b) || !looks_like_number($strength2b))
    {
        next;
    }    
    
    if ($chr1a eq $chr1b && $start1a==$start1b && $stop1a==$stop1b && $chr2a eq $chr2b && $start2a==$start2b && $stop2a==$stop2b && $strength1b*$strength2b>$strength1a*$strength2a)
    {
        $chr1a = $chr1b;
        $start1a = $start1b;
        $stop1a = $stop1b;
        $anno1a = $anno1b;
        $strength1a = $strength1b;
        $chr2a = $chr2b;
        $start2a = $start2b;
        $stop2a = $stop2b;
        $anno2a = $anno2b;;
        $strength2a = $strength2b;
    } elsif ($chr1a ne $chr1b || $start1a!=$start1b || $stop1a!=$stop1b || $chr2a ne $chr2b || $start2a!=$start2b || $stop2a!=$stop2b)
    {
        $outline = join("\t",$chr1a,$start1a,$stop1a,$anno1a,$strength1a,$chr2a,$start2a,$stop2a,$anno2a,$strength2a);
        $outline = join("",$outline,"\n");
        print OUT $outline;
        $chr1a = $chr1b;
        $start1a = $start1b;
        $stop1a = $stop1b;
        $anno1a = $anno1b;
        $strength1a = $strength1b;
        $chr2a = $chr2b;
        $start2a = $start2b;
        $stop2a = $stop2b;
        $anno2a = $anno2b;
        $strength2a = $strength2b;
    }
}

close(IN);
close(OUT);

$command = join("","rm ",$workpath,"allpairs.bed");
system($command);
