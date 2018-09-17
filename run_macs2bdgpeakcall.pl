#!/usr/bin/perl

use strict;
use warnings;

my ($arglistfile,$line,$varname,$val,$bedgraphpath,$peakpath,$workpath,$command,@items,%arglist);

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

$bedgraphpath = $arglist{'bedgraphpath'};
$peakpath = $arglist{'peakpath'};
$workpath = $peakpath;

$command = join("","bash macs2bdgpeakcall.bash -b ",$bedgraphpath," -p ",$peakpath," -w ",$workpath);
system($command);
